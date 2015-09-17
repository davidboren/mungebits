# Version 0.3.6

* A critical fix for the `munge` function that initializes each mungepiece
  at munge-time to ensure no pollution of train/predict when `enforce_train = FALSE`.

# Version 0.3.0

  * The mungebitsTransformations package was renamed to syberiaMungebits,
    and its functions `column_transformation` and `multi_column_transformation`
    now reside in this (mungebits) package. The purpose of this migration is to
    enforce clearer cohesion between abstract / general methods (this package)
    and domain-specific / dependent methods (syberiaMungebits package).

