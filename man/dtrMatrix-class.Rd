\name{dtrMatrix-class}
\title{Triangular, dense, numeric matrices}
%
\docType{class}
\keyword{array}
\keyword{classes}
%
\alias{dtrMatrix-class}
%
\description{
  The \code{"dtrMatrix"} class is the class of triangular, dense,
  numeric matrices in nonpacked storage.  The \code{"dtpMatrix"} class
  is the same except in packed storage, see \code{\link{pack}()}.
}
\section{Objects from the Class}{
  Objects can be created by calls of the form \code{new("dtrMatrix", ...)}.
}
\section{Slots}{
  \describe{
    \item{\code{uplo}:}{Object of class \code{"character"}. Must be
      either "U", for upper triangular, and "L", for lower triangular.}
    \item{\code{diag}:}{Object of class \code{"character"}. Must be
      either \code{"U"}, for unit triangular (diagonal is all ones), or
      \code{"N"}; see \code{\linkS4class{triangularMatrix}}.}
    \item{\code{x}:}{Object of class \code{"numeric"}. The numeric
      values that constitute the matrix, stored in column-major order.}
    \item{\code{Dim}:}{Object of class \code{"integer"}. The dimensions
      of the matrix which must be a two-element vector of non-negative
      integers.}
  }
}
\section{Extends}{
  Class \code{"ddenseMatrix"}, directly.
  Class \code{"triangularMatrix"}, directly.
  Class \code{"Matrix"} and others, by class \code{"ddenseMatrix"}.
}
\section{Methods}{
  Among others (such as matrix products, e.g. \code{?\link{crossprod-methods}}),
  \describe{
    \item{norm}{\code{signature(x = "dtrMatrix", type = "character")}}
    \item{rcond}{\code{signature(x = "dtrMatrix", norm = "character")}}
    \item{solve}{\code{signature(a = "dtrMatrix", b = "....")}}{efficientely
      use a \dQuote{forwardsolve} or \code{backsolve} for a lower or
      upper triangular matrix, respectively, see also
      \code{\link{solve-methods}}.}
    \item{+, -, *, \dots, ==, >=, \dots}{all the \code{\link{Ops}} group
      methods are available.  When applied to two triangular matrices,
      these return a triangular matrix when easily possible.}
  }
}
%\references{}
%\author{}
\seealso{
  Classes \code{\linkS4class{ddenseMatrix}}, \code{\linkS4class{dtpMatrix}},
  \code{\linkS4class{triangularMatrix}}
}
\examples{%% this is used from ./dtpMatrix-class.Rd (change with care!)
\dontshow{ % for R_DEFAULT_PACKAGES=NULL
library(utils, pos = "package:base", verbose = FALSE)
}
(m <- rbind(2:3, 0:-1))
(M <- as(m, "generalMatrix"))

(T <- as(M, "triangularMatrix")) # formally upper triangular
(T2 <- as(t(M), "triangularMatrix"))
stopifnot(T@uplo == "U", T2@uplo == "L", identical(T2, t(T)))

m <- matrix(0,4,4); m[upper.tri(m)] <- 1:6
(t1 <- Matrix(m+diag(,4)))
str(t1p <- pack(t1))
(t1pu <- diagN2U(t1p))
stopifnot(exprs = {
   inherits(t1 , "dtrMatrix"); validObject(t1)
   inherits(t1p, "dtpMatrix"); validObject(t1p)
   inherits(t1pu,"dtCMatrix"); validObject(t1pu)
   t1pu@x == 1:6
   all(t1pu == t1p)
   identical((t1pu - t1)@x, numeric())# sparse all-0
})
}
