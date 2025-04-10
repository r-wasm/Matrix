\name{dpoMatrix-class}
\title{Positive Semi-definite Dense (Packed | Non-packed) Numeric Matrices}
%
\docType{class}
\keyword{array}
\keyword{classes}
%
\alias{dpoMatrix-class}
\alias{dppMatrix-class}
\alias{corMatrix-class}
\alias{pcorMatrix-class}
%
\alias{Arith,dpoMatrix,logical-method}
\alias{Arith,dpoMatrix,numeric-method}
\alias{Arith,logical,dpoMatrix-method}
\alias{Arith,numeric,dpoMatrix-method}
\alias{Ops,dpoMatrix,logical-method}
\alias{Ops,dpoMatrix,numeric-method}
\alias{Ops,logical,dpoMatrix-method}
\alias{Ops,numeric,dpoMatrix-method}
\alias{coerce,dpoMatrix,corMatrix-method}
\alias{coerce,dpoMatrix,dppMatrix-method}
\alias{coerce,matrix,dpoMatrix-method}
\alias{determinant,dpoMatrix,logical-method}
%
\alias{Arith,dppMatrix,logical-method}
\alias{Arith,dppMatrix,numeric-method}
\alias{Arith,logical,dppMatrix-method}
\alias{Arith,numeric,dppMatrix-method}
\alias{Ops,dppMatrix,logical-method}
\alias{Ops,dppMatrix,numeric-method}
\alias{Ops,logical,dppMatrix-method}
\alias{Ops,numeric,dppMatrix-method}
\alias{coerce,dppMatrix,dpoMatrix-method}
\alias{coerce,dppMatrix,pcorMatrix-method}
\alias{coerce,matrix,dppMatrix-method}
\alias{determinant,dppMatrix,logical-method}
%
\alias{coerce,matrix,corMatrix-method}
%
\alias{coerce,matrix,pcorMatrix-method}
%
\description{
  \itemize{
    \item{The \code{"dpoMatrix"} class is the class of
      positive-semidefinite symmetric matrices in nonpacked storage.}
    \item{The \code{"dppMatrix"} class is the same except in packed
      storage.  Only the upper triangle or the lower triangle is
      required to be available.}
    \item{The \code{"corMatrix"} and \code{"pcorMatrix"} classes
      represent correlation matrices.  They extend \code{"dpoMatrix"}
      and \code{"dppMatrix"}, respectively, with an additional slot
      \code{sd} allowing restoration of the original covariance matrix.}
  }
}
\section{Objects from the Class}{Objects can be created by calls of the
  form \code{new("dpoMatrix", ...)} or from \code{crossprod} applied to
  an \code{"dgeMatrix"} object.}
\section{Slots}{
  \describe{
    \item{\code{uplo}:}{Object of class \code{"character"}. Must be
      either "U", for upper triangular, and "L", for lower triangular.}
    \item{\code{x}:}{Object of class \code{"numeric"}. The numeric
      values that constitute the matrix, stored in column-major order.}
    \item{\code{Dim}:}{Object of class \code{"integer"}. The dimensions
      of the matrix which must be a two-element vector of non-negative
      integers.}
    \item{\code{Dimnames}:}{inherited from class \code{"Matrix"}}
    \item{\code{factors}:}{Object of class \code{"list"}.  A named
      list of factorizations that have been computed for the matrix.}

    \item{\code{sd}:}{(for \code{"corMatrix"} and \code{"pcorMatrix"})
      a \code{\link{numeric}} vector of length \code{n} containing the
      (original) \eqn{\sqrt{var(.)}}{sqrt(var(.))} entries which allow
      reconstruction of a covariance matrix from the correlation matrix.}
  }
}
\section{Extends}{
  Class \code{"dsyMatrix"}, directly.\cr
  Classes \code{"dgeMatrix"}, \code{"symmetricMatrix"}, and many more
  by class \code{"dsyMatrix"}.
}
\section{Methods}{
  \describe{
    \item{chol}{\code{signature(x = "dpoMatrix")}:
      Returns (and stores) the Cholesky decomposition of \code{x}, see
      \code{\link{chol}}.}
    \item{determinant}{\code{signature(x = "dpoMatrix")}:
      Returns the \code{\link{determinant}} of \code{x}, via
      \code{chol(x)}, see above.}
    \item{rcond}{\code{signature(x = "dpoMatrix", norm = "character")}:
      Returns (and stores) the reciprocal of the condition number of
      \code{x}.  The \code{norm} can be \code{"O"} for the
      one-norm (the default) or \code{"I"} for the infinity-norm.  For
      symmetric matrices the result does not depend on the norm.}
    \item{solve}{\code{signature(a = "dpoMatrix", b = "....")}}{, and}
    \item{solve}{\code{signature(a = "dppMatrix", b = "....")}}{work
      via the Cholesky composition, see also the Matrix \code{\link{solve-methods}}.}
    \item{Arith}{\code{signature(e1 = "dpoMatrix", e2 = "numeric")} (and
      quite a few other signatures): The result of (\dQuote{elementwise}
      defined) arithmetic operations is typically \emph{not}
      positive-definite anymore.  The only exceptions, currently, are
      multiplications, divisions or additions with \emph{positive}
      \code{length(.) == 1} numbers (or \code{\link{logical}}s).}
  }
}
%\references{}
%\author{}
\note{Currently the validity methods for these classes such as
  \code{\link{getValidity}(getClass("dpoMatrix"))} for efficiency reasons
  only check the diagonal entries of the matrix -- they may not be negative.
  This is only necessary but not sufficient for a symmetric matrix to be
  positive semi-definite.

  A more reliable (but often more expensive) check for positive
  semi-definiteness would look at the signs of \code{diag(\link{BunchKaufman}(.))}
  (with some tolerance for very small negative values), and for (strict)
  positive definiteness at something like
  \code{!inherits(tryCatch(chol(.), error=identity), "error")} .
  Indeed, when \emph{coercing} to these classes, a version
  of \code{\link{Cholesky}()} or \code{\link{chol}()} is
  typically used, e.g., see \code{selectMethod("coerce",
    c(from="dsyMatrix", to="dpoMatrix"))} .
}
\seealso{
  Classes \code{\linkS4class{dsyMatrix}} and \code{\linkS4class{dgeMatrix}};
  further, \code{\link{Matrix}}, \code{\link{rcond}},
  \code{\link[base]{chol}}, \code{\link[base]{solve}}, \code{\link{crossprod}}.
}
\examples{
\dontshow{ % for R_DEFAULT_PACKAGES=NULL
library(utils, pos = "package:base", verbose = FALSE)
}
h6 <- Hilbert(6)
rcond(h6)
str(h6)
h6 * 27720 # is ``integer''
solve(h6)
str(hp6 <- as(h6, "dppMatrix"))

### Note that  as(*, "corMatrix")  *scales* the matrix
(ch6 <- as(h6, "corMatrix"))
stopifnot(all.equal(h6 * 27720, round(27720 * h6), tolerance = 1e-14),
          all.equal(ch6@sd^(-2), 2*(1:6)-1, tolerance= 1e-12))
chch <- Cholesky(ch6, perm = FALSE)
stopifnot(identical(chch, ch6@factors$Cholesky),
          all(abs(crossprod(as(chch, "dtrMatrix")) - ch6) < 1e-10))
}
