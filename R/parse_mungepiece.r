#' Translate a list of arguments passed to a mungebit into a mungepiece
#'
#' For example, one can pass a training function, a prediction function,
#' and additional arguments, and the constructed mungepiece will hold
#' these arguments, ready to call the attached mungebit on a given dataframe.
#'
#' @name parse_mungepiece
#' @param args a list. This can be of the formats
#'   \code{list(train_fn, ...)}, \code{list(list(train_fn, predict_fn), ...)},
#'   and \code{list(list(train_fn, ...), list(predict_fn, ...))}. In the first
#'   example, the train and predict function are assumed to be identical. In
#'   the first two examples, the arguments to these functions are assumed to
#'   be identical (for example, if the same kind of filter needs to be applied
#'   to a data set that is about to be trained as to one about to be
#'   predicted). Finally, the last example is the most flexible and allows
#'   different parameters for the training and prediction function,
#'   respectively. The given training and prediction functions are used to
#'   construct a \code{mungebit}, and the resulting \code{mungebit} and 
#'   the remaining arguments are stored in a \code{mungepiece}.
#' @param train_only logical. Whether or not to leave the \code{trained}
#'    parameter on each mungebit to \code{TRUE} or \code{FALSE} accordingly.
#'    For example, if \code{stagerunner = TRUE} and we are planning to re-use
#'    the stagerunner for prediction, it makes sense to leave the mungebits
#'    untrained. (Note that this will prevent one from being able to run the
#'    predict functions!)
#' @return the parsed mungepiece
#' @export
#' @examples
#' \dontrun{
#' doubler <- column_transformation(function(x) x * 2)
#' mp <- parse_mungepiece(list(doubler, 'Sepal.Length')) 
#' iris2 <- mungeplane(iris)
#' mp$run(iris2)
#' stopifnot(all.equal(iris2$data[[1]], 2 * iris[[1]]))
#' 
#' # TODO: Way more examples, unit tests
#' 
#' }
parse_mungepiece <- function(args, train_only = FALSE) {
  if (is.mungepiece(args)) return(args)
  if (is(args, 'stageRunner')) return(args)
  if (is.mungebit(args) || is.function(args)) args <- list(args)
  if (is.mungebit(args[[1]])) {
    # We construct a *new* mungebit from the old one to avoid shareable state.
    mb <- mungebit(args[[1]]$train_function, args[[1]]$predict_function,
                   enforce_train = !train_only)
    return(mungepiece(mb, args[-1]))
  }
  stopifnot(is.list(args))  
  if (is.list(args) && length(args) == 1 && is.mungepiece(args[[1]]))
    return(args[[1]])

  if (is.list(args[[1]]) && length(args) > 1 && is.list(args[[2]]) &&
      length(args[[1]]) > 0 && is.function(args[[1]][[1]]) &&
      length(args[[2]]) > 0 && is.function(args[[2]][[1]])) {
    # train and predict functions have separate arguments
    # list(list(train_fn, ...), list(predict_fn, ...))
    train_fn <- args[[1]][[1]]
    args[[1]][[1]] <- NULL
    train_args <- args[[1]]
    
    predict_fn <- args[[2]][[1]]
    args[[2]][[1]] <- NULL
    predict_args <- args[[2]]
  } else {
    stopifnot(length(args) > 0)
    if (is.list(args[[1]])) {
      # list(list(train_fn, predict_fn), ...)
      stopifnot(length(args[[1]]) == 2)
      train_fn <- args[[1]][[1]]
      predict_fn <- args[[1]][[2]]
    } else {
      # list(train_fn, ...)
      train_fn <- args[[1]]
      predict_fn <- train_fn
    }
                      
    args[[1]] <- NULL
    train_args <- args
    predict_args <- train_args
  }
  stopifnot((is.function(train_fn) || is.null(train_fn)) && 
            (is.function(predict_fn) || is.null(predict_fn)))
  if (!is.null(train_fn)) class(train_fn) <- 'function'    # Clear triggers
  if (!is.null(predict_fn)) class(predict_fn) <- 'function'

  mungepiece(mungebit(train_fn, predict_fn, enforce_train = !train_only),
             train_args,
             predict_args)
}


