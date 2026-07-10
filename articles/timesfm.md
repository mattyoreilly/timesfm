# Get started with timesfm

TimesFM is a foundation model for time series from Google Research.
Where a traditional forecasting workflow makes you choose a model
family, fit it, and tune it per series, TimesFM does none of that: it
was pretrained on a large corpus of time series, and it forecasts your
series *zero-shot* — it reads the observed values as context and
predicts the future in a single forward pass, the way a language model
completes a sentence.

``` r

library(timesfm)
```

*(Code in this vignette isn’t evaluated when the package is built,
because it needs a local Python setup and a one-time weights download.)*

## One-time setup

TimesFM’s inference code is a Python package, which timesfm drives
through reticulate.
[`install_timesfm()`](https://mattyoreilly.github.io/timesfm/reference/install_timesfm.md)
creates a dedicated virtualenv (it needs Python \>= 3.10 and will tell
you if it can’t find one) and installs the PyTorch backend:

``` r

install_timesfm()
```

The first forecast downloads the pretrained weights from the Hugging
Face Hub and caches them in `~/.cache/huggingface/`. Once cached, add
`HF_HUB_OFFLINE=1` to your `~/.Renviron` to skip the Hub’s revalidation
requests and load straight from disk.

## Forecasting

[`timesfm()`](https://mattyoreilly.github.io/timesfm/reference/timesfm.md)
takes the observed series — a numeric vector or `ts`, oldest first — and
a horizon:

``` r

fc <- timesfm(AirPassengers, horizon = 24)
fc
```

“Fitting” happens inside the forward pass; there is nothing to train.
The loaded model stays in memory, so repeated forecasts in a session are
fast.

The result holds point forecasts and the deciles of the forecast
distribution:

``` r

fc$mean               # point forecasts, length 24
fc$quantiles          # 24 x 9 matrix, columns q10 ... q90
```

The deciles give you prediction intervals directly — `q10` and `q90`
bound an 80% interval, `q50` is the median:

``` r

plot(AirPassengers, xlim = c(1949, 1963))
lines(ts(fc$mean, start = c(1961, 1), frequency = 12), col = "blue")
lines(ts(fc$quantiles[, "q10"], start = c(1961, 1), frequency = 12), lty = 2)
lines(ts(fc$quantiles[, "q90"], start = c(1961, 1), frequency = 12), lty = 2)
```

## When should you reach for TimesFM?

TimesFM shines when you have many heterogeneous series and no time to
model each one, or when you want a strong baseline before investing in a
bespoke model. It is not the right tool when:

- you need covariates/regressors, holidays, or hierarchical
  reconciliation — reach for [fable](https://fable.tidyverts.org) or
  [prophet](https://facebook.github.io/prophet/).
- your series is longer-memory than 1024 observations or you need
  forecasts beyond 256 steps.
- you can’t ship a Python runtime: inference always runs through the
  Python package.
