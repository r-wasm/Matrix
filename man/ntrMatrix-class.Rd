\name{ntrMatrix-class}
\title{Triangular Dense Logical Matrices}
%
\docType{class}
\keyword{array}
\keyword{classes}
%
\alias{ntrMatrix-class}
\alias{ntpMatrix-class}
%
\alias{!,ntrMatrix-method}
%
\alias{!,ntpMatrix-method}
%
\description{
  The \code{"ntrMatrix"} class is the class of triangular, dense,
  logical matrices in nonpacked storage.  The \code{"ntpMatrix"} class
  is the same except in packed storage.
}
\section{Slots}{
  \describe{
    \item{\code{x}:}{Object of class \code{"logical"}. The logical
      values that constitute the matrix, stored in column-major order.}
    \item{\code{uplo}:}{Object of class \code{"character"}. Must be
      either "U", for upper triangular, and "L", for lower triangular.}
    \item{\code{diag}:}{Object of class \code{"character"}. Must be
      either \code{"U"}, for unit triangular (diagonal is all ones), or
      \code{"N"}; see \code{\linkS4class{triangularMatrix}}.}
    \item{\code{Dim},\code{Dimnames}:}{The dimension (a length-2
      \code{"integer"}) and corresponding names (or \code{NULL}), see the
      \code{\linkS4class{Matrix}} class.}
    \item{\code{factors}:}{Object of class \code{"list"}.  A named
      list of factorizations that have been computed for the matrix.}
  }
}
\section{Extends}{
  \code{"ntrMatrix"} extends class \code{"ngeMatrix"}, directly, whereas\cr
  \code{"ntpMatrix"} extends class \code{"ndenseMatrix"}, directly.

  Both extend Class \code{"triangularMatrix"}, directly,
  and class \code{"denseMatrix"}, \code{"lMatrix"} and others,
  \emph{in}directly, use \code{\link{showClass}("nsyMatrix")}, e.g., for
  details.
}
\section{Methods}{
  Currently, mainly \code{\link{t}()} and coercion methods (for
  \code{\link{as}(.)}; use, e.g.,
  \code{\link{showMethods}(class="ntrMatrix")} for details.
}
\seealso{
  Classes \code{\linkS4class{ngeMatrix}}, \code{\linkS4class{Matrix}};
  function \code{\link[base]{t}}
}
\examples{
\dontshow{ % for R_DEFAULT_PACKAGES=NULL
library(utils, pos = "package:base", verbose = FALSE)
}
showClass("ntrMatrix")

str(new("ntpMatrix"))
(nutr <- as(upper.tri(matrix(, 4, 4)), "ndenseMatrix"))
str(nutp <- pack(nutr)) # packed matrix: only 10 = 4*(4+1)/2 entries
!nutp # the logical negation (is *not* logical triangular !)
## but this one is:
stopifnot(all.equal(nutp, pack(!!nutp)))
}
