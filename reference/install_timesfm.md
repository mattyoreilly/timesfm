# Install the TimesFM Python package

`install_timesfm()` installs the underlying [TimesFM Python
package](https://github.com/google-research/timesfm) (PyTorch backend)
into a dedicated virtualenv via
[`reticulate::py_install()`](https://rstudio.github.io/reticulate/reference/py_install.html).
You only need to run it once per machine.

## Usage

``` r
install_timesfm(envname = "r-timesfm", ...)
```

## Arguments

- envname:

  Name of the virtualenv to install into. The default, `"r-timesfm"`, is
  discovered automatically by reticulate when the package loads.

- ...:

  Additional arguments passed on to
  [`reticulate::py_install()`](https://rstudio.github.io/reticulate/reference/py_install.html).

## Value

`NULL`, invisibly. Called for its side effect.

## See also

[`timesfm()`](https://mattyoreilly.github.io/timesfm/reference/timesfm.md)
to forecast once installation is complete.

## Examples

``` r
if (FALSE) { # \dontrun{
install_timesfm()
} # }
```
