# timesfm() validates y and horizon before touching Python

    Code
      timesfm("not a series", horizon = 12)
    Condition
      Warning in `timesfm()`:
      NAs introduced by coercion
      Error in `timesfm()`:
      ! `y` must be a numeric series of at least 2 values with no missing or infinite values.
    Code
      timesfm(c(1, NA, NaN), horizon = 12)
    Condition
      Error in `timesfm()`:
      ! `y` must be a numeric series of at least 2 values with no missing or infinite values.
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

