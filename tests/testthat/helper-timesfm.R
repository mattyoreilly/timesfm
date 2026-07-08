# Real-model integration tests are opt-in: a forecast loads the pretrained
# weights, which is far too slow for routine test runs and R CMD check.
# Run them deliberately with: Sys.setenv(TIMESFM_TEST_FULL = "1")
skip_if_no_timesfm <- function() {
  testthat::skip_if_not(
    nzchar(Sys.getenv("TIMESFM_TEST_FULL")),
    "set TIMESFM_TEST_FULL=1 to run slow integration tests"
  )
  have <- tryCatch(
    reticulate::py_module_available("timesfm"),
    error = function(e) FALSE
  )
  testthat::skip_if_not(have, "timesfm Python module not available")
}
