# ponytail: thin reticulate wrapper, one file, mirroring the tabfm package;
# model loads once per session and is reused by every forecast

timesfm_py <- NULL

the <- new.env(parent = emptyenv())

.onLoad <- function(libname, pkgname) {
  reticulate::use_virtualenv("r-timesfm", required = FALSE)
  timesfm_py <<- reticulate::import("timesfm", delay_load = TRUE)
}

#' Install the TimesFM Python package
#'
#' @description
#' `install_timesfm()` installs the underlying
#' [TimesFM Python package](https://github.com/google-research/timesfm)
#' (PyTorch backend) into a dedicated virtualenv via
#' [reticulate::py_install()]. You only need to run it once per machine.
#'
#' @param envname Name of the virtualenv to install into. The default,
#'   `"r-timesfm"`, is discovered automatically by reticulate when the
#'   package loads.
#' @param ... Additional arguments passed on to [reticulate::py_install()].
#' @returns `NULL`, invisibly. Called for its side effect.
#' @seealso [timesfm()] to forecast once installation is complete.
#' @family setup
#' @examples
#' \dontrun{
#' install_timesfm()
#' }
#' @export
install_timesfm <- function(envname = "r-timesfm", ...) {
  # timesfm needs a recent Python; drop any stale env built with an older one
  if (reticulate::virtualenv_exists(envname)) {
    py <- reticulate::virtualenv_python(envname)
    ver <- sub("^Python ", "", system2(py, "--version", stdout = TRUE))
    if (numeric_version(ver) < "3.10") {
      message("Recreating '", envname, "': its Python ", ver,
              " is too old for timesfm (needs >= 3.10).")
      reticulate::virtualenv_remove(envname, confirm = FALSE)
    }
  }
  if (!reticulate::virtualenv_exists(envname)) {
    reticulate::virtualenv_create(envname, version = ">=3.10")
  }
  reticulate::py_install("timesfm[torch]", envname = envname, pip = TRUE, ...)
  invisible(NULL)
}

# checkpoint download + model compile is the expensive part, so pay it once
# per session, not once per forecast
timesfm_model <- function() {
  if (is.null(the$model)) {
    quiet_hf_nag()
    model <- timesfm_py$TimesFM_2p5_200M_torch$from_pretrained(
      "google/timesfm-2.5-200m-pytorch"
    )
    model$compile(timesfm_py$ForecastConfig(
      max_context = 1024L,
      max_horizon = 256L,
      normalize_inputs = TRUE,
      use_continuous_quantile_head = TRUE,
      force_flip_invariance = TRUE,
      infer_is_positive = TRUE,
      fix_quantile_crossing = TRUE
    ))
    the$model <- model
  }
  the$model
}

# The HF Hub nags about unauthenticated downloads on every weights load, via
# both warnings and logging. It's advisory only (rate limits), so drop just
# that message.
quiet_hf_nag <- function() {
  if (isTRUE(the$quieted)) return(invisible())
  reticulate::py_run_string(paste(
    "import warnings, logging",
    "warnings.filterwarnings('ignore', message='.*unauthenticated requests.*')",
    "logging.getLogger('huggingface_hub').addFilter(",
    "    lambda r: 'unauthenticated requests' not in r.getMessage())",
    sep = "\n"
  ))
  the$quieted <- TRUE
  invisible()
}

#' Forecast a time series with TimesFM
#'
#' @description
#' `timesfm()` produces a zero-shot probabilistic forecast of a univariate
#' time series using the pretrained TimesFM 2.5 (200M) foundation model.
#' There is no training step: the model reads your series as context and
#' forecasts in a single forward pass.
#'
#' Loading the pretrained weights is the slow part, so it happens once per
#' session and the model is reused by later calls.
#'
#' @param y A numeric vector or `ts` object: the observed series, oldest
#'   first. Series longer than 1024 points are used from the most recent
#'   1024.
#' @param horizon Number of future steps to forecast, between 1 and 256.
#' @returns An object of class `"timesfm"`: a list with elements
#'   * `mean` — numeric vector of point forecasts, length `horizon`.
#'   * `quantiles` — numeric matrix with `horizon` rows and columns
#'     `q10` ... `q90`: the deciles of the forecast distribution.
#'   * `horizon` — the forecast length.
#' @examples
#' \dontrun{
#' fc <- timesfm(AirPassengers, horizon = 24)
#' fc
#'
#' fc$mean
#' fc$quantiles[, c("q10", "q90")]  # an 80% interval
#' }
#' @export
timesfm <- function(y, horizon) {
  y <- as.numeric(y)
  if (length(y) < 2 || !any(is.finite(y))) {
    stop("`y` must be a numeric series with at least 2 finite values.")
  }
  if (!is.numeric(horizon) || length(horizon) != 1 || is.na(horizon) ||
      horizon < 1 || horizon > 256) {
    stop("`horizon` must be a single number between 1 and 256, not ",
         deparse(substitute(horizon)), " = ", format(horizon), ".")
  }

  res <- timesfm_model()$forecast(
    horizon = as.integer(horizon),
    inputs = list(y)
  )

  # point forecast: 1 x horizon; quantiles: 1 x horizon x 10 (mean, q10..q90)
  q <- res[[2]][1, , , drop = TRUE]
  q <- matrix(q, ncol = 10)[, -1, drop = FALSE]  # drop the repeated mean
  colnames(q) <- paste0("q", seq(10, 90, by = 10))
  structure(
    list(
      mean = as.vector(res[[1]][1, ]),
      quantiles = q,
      horizon = as.integer(horizon)
    ),
    class = "timesfm"
  )
}

#' @export
print.timesfm <- function(x, ...) {
  cat("TimesFM 2.5 zero-shot forecast | horizon", x$horizon, "\n")
  print(utils::head(
    cbind(mean = x$mean, x$quantiles[, c("q10", "q50", "q90")])
  ))
  if (x$horizon > 6) cat("... and", x$horizon - 6, "more steps\n")
  invisible(x)
}
