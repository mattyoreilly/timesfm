# R-side behaviour: input validation and the print method. None of these
# touch Python.

test_that("timesfm() validates y and horizon before touching Python", {
  expect_snapshot(error = TRUE, {
    timesfm("not a series", horizon = 12)
    timesfm(c(1, NA, NaN), horizon = 12)
    timesfm(1:10, horizon = 0)
    timesfm(1:10, horizon = 500)
    timesfm(1:10, horizon = c(1, 2))
  })
})

test_that("print() summarises the forecast", {
  fake <- structure(
    list(
      mean = as.numeric(1:12),
      quantiles = matrix(
        rep(as.numeric(1:12), 9), ncol = 9,
        dimnames = list(NULL, paste0("q", seq(10, 90, by = 10)))
      ),
      horizon = 12L
    ),
    class = "timesfm"
  )
  expect_snapshot(print(fake))
})

# Integration: the real Python path. Opt-in via TIMESFM_TEST_FULL=1.

test_that("forecast round trip works", {
  skip_if_no_timesfm()

  y <- as.numeric(AirPassengers)
  fc <- timesfm(y, horizon = 24)

  expect_s3_class(fc, "timesfm")
  expect_length(fc$mean, 24L)
  expect_true(all(is.finite(fc$mean)))
  expect_identical(dim(fc$quantiles), c(24L, 9L))
  expect_identical(colnames(fc$quantiles), paste0("q", seq(10, 90, by = 10)))

  # quantiles are non-decreasing across each row (fix_quantile_crossing)
  expect_true(all(apply(fc$quantiles, 1, function(r) !is.unsorted(r))))

  # AirPassengers is strongly trending upwards; a sane forecast continues
  # above the series' overall mean
  expect_true(mean(fc$mean) > mean(y))

  # ts input gives the same result as its numeric values
  expect_identical(timesfm(AirPassengers, horizon = 24)$mean, fc$mean)

  # forecasts are plain R data: they serialize and restore exactly, with no
  # live Python references (unlike tabfm fits, there is nothing to rebuild)
  path <- tempfile(fileext = ".rds")
  on.exit(unlink(path))
  saveRDS(fc, path)
  expect_identical(readRDS(path), fc)
})
