# Forecast a time series with TimesFM

`timesfm()` produces a zero-shot probabilistic forecast of a univariate
time series using the pretrained TimesFM 2.5 (200M) foundation model.
There is no training step: the model reads your series as context and
forecasts in a single forward pass.

Loading the pretrained weights is the slow part, so it happens once per
session and the model is reused by later calls.

## Usage

``` r
timesfm(y, horizon)
```

## Arguments

- y:

  A numeric vector or `ts` object: the observed series, oldest first,
  with no missing values (impute or drop them first). Series longer than
  1024 points are used from the most recent 1024.

- horizon:

  Number of future steps to forecast, between 1 and 256.

## Value

An object of class `"timesfm"`: a list with elements

- `mean` — numeric vector of point forecasts, length `horizon`.

- `quantiles` — numeric matrix with `horizon` rows and columns `q10` ...
  `q90`: the deciles of the forecast distribution.

- `horizon` — the forecast length.

## Examples

``` r
if (FALSE) { # \dontrun{
fc <- timesfm(AirPassengers, horizon = 24)
fc

fc$mean
fc$quantiles[, c("q10", "q90")]  # an 80% interval
} # }
```
