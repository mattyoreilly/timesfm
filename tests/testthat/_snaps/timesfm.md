# timesfm() validates y and horizon before touching Python

    Code
      timesfm("not a series", horizon = 12)
    Condition
      Warning in `timesfm()`:
      NAs introduced by coercion
      Error in `timesfm()`:
      ! `y` must be a numeric series with at least 2 finite values.
    Code
      timesfm(c(1, NA, NaN), horizon = 12)
    Condition
      Error:
      ! Python module timesfm was not found.
      
      Detected Python configuration:
      
      python:         /Users/mattoreilly/Library/Caches/org.R-project.R/R/reticulate/uv/cache/archive-v0/KF_xaigBphOsAmlr/bin/python
      libpython:      /Users/mattoreilly/Library/Caches/org.R-project.R/R/reticulate/uv/python/cpython-3.12.13-macos-aarch64-none/lib/libpython3.12.dylib
      pythonhome:     /Users/mattoreilly/Library/Caches/org.R-project.R/R/reticulate/uv/cache/archive-v0/KF_xaigBphOsAmlr:/Users/mattoreilly/Library/Caches/org.R-project.R/R/reticulate/uv/cache/archive-v0/KF_xaigBphOsAmlr
      virtualenv:     /Users/mattoreilly/Library/Caches/org.R-project.R/R/reticulate/uv/cache/archive-v0/KF_xaigBphOsAmlr/bin/activate_this.py
      version:        3.12.13 (main, Jun 23 2026, 15:44:24) [Clang 22.1.3 ]
      numpy:          /Users/mattoreilly/Library/Caches/org.R-project.R/R/reticulate/uv/cache/archive-v0/KF_xaigBphOsAmlr/lib/python3.12/site-packages/numpy
      numpy_version:  2.5.1
      timesfm:        [NOT FOUND]
      
      NOTE: Python version was forced by py_require()
    Code
      timesfm(1:10, horizon = 0)
    Condition
      Error in `timesfm()`:
      ! `horizon` must be a single number between 1 and 256, not 0 = 0.
    Code
      timesfm(1:10, horizon = 500)
    Condition
      Error in `timesfm()`:
      ! `horizon` must be a single number between 1 and 256, not 500 = 500.
    Code
      timesfm(1:10, horizon = c(1, 2))
    Condition
      Error in `timesfm()`:
      ! `horizon` must be a single number between 1 and 256, not c(1, 2) = 12.

# print() summarises the forecast

    Code
      print(fake)
    Output
      TimesFM 2.5 zero-shot forecast | horizon 12 
           mean q10 q50 q90
      [1,]    1   1   1   1
      [2,]    2   2   2   2
      [3,]    3   3   3   3
      [4,]    4   4   4   4
      [5,]    5   5   5   5
      [6,]    6   6   6   6
      ... and 6 more steps

