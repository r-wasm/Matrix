\name{dgTMatrix-class}
\title{Sparse matrices in triplet form}
%
\docType{class}
\keyword{array}
\keyword{classes}
%
\alias{dgTMatrix-class}
%
\alias{+,dgTMatrix,dgTMatrix-method}
\alias{determinant,dgTMatrix,logical-method}
%
\description{The \code{"dgTMatrix"} class is the class of sparse
  matrices stored as (possibly redundant) triplets.  The internal
  representation is not at all unique, contrary to the one for class
  \code{\linkS4class{dgCMatrix}}.
}
\section{Objects from the Class}{
  Objects can be created by calls of the form
  \code{new("dgTMatrix", ...)}, but more typically via
  \code{\link{spMatrix}()} or \code{\link{sparseMatrix}(*, repr = "T")}.
}
\section{Slots}{
  \describe{
    \item{\code{i}:}{\code{\link{integer}} row indices of non-zero
      entries \emph{in 0-base}, i.e., must be in \code{0:(nrow(.)-1)}.}
    \item{\code{j}:}{\code{\link{integer}} column indices of non-zero
      entries.  Must be the same length as slot \code{i} and
      \emph{0-based} as well, i.e., in \code{0:(ncol(.)-1)}.}
    \item{\code{x}:}{\code{\link{numeric}} vector - the (non-zero)
      entry at position \code{(i,j)}.  Must be the same length as slot
      \code{i}.  If an index pair occurs more than once, the corresponding
      values of slot \code{x} are added to form the element of the matrix.}
    \item{\code{Dim}:}{Object of class \code{"integer"} of length 2 -
      the dimensions of the matrix.}
  }
}
\section{Methods}{
  \describe{
    \item{+}{\code{signature(e1 = "dgTMatrix", e2 = "dgTMatrix")}}
    \item{image}{\code{signature(x = "dgTMatrix")}: plots an image of
      \code{x} using the \code{\link[lattice]{levelplot}} function}
    \item{t}{\code{signature(x = "dgTMatrix")}: returns the transpose of
      \code{x}}
  }
}
%\references{}
%\author{}
\note{Triplet matrices are a convenient form in which to construct sparse
  matrices after which they can be coerced to
  \code{\linkS4class{dgCMatrix}} objects.

  Note that both \code{new(.)} and \code{\link{spMatrix}} constructors
  for \code{"dgTMatrix"} (and other \code{"\linkS4class{TsparseMatrix}"}
  classes) implicitly add \eqn{x_k}'s that belong to identical
  \eqn{(i_k, j_k)} pairs.

  However this means that a matrix typically can be stored in more than
  one possible \code{"\linkS4class{TsparseMatrix}"} representations.
  Use \code{\link{uniqTsparse}()} in order to ensure uniqueness of the
  internal representation of such a matrix.
}
\seealso{
  Class \code{\linkS4class{dgCMatrix}} or the superclasses
  \code{\linkS4class{dsparseMatrix}} and
  \code{\linkS4class{TsparseMatrix}}; \code{\link{uniqTsparse}}.
}
\examples{
\dontshow{ % for R_DEFAULT_PACKAGES=NULL
library(utils, pos = "package:base", verbose = FALSE)
}
m <- Matrix(0+1:28, nrow = 4)
m[-3,c(2,4:5,7)] <- m[ 3, 1:4] <- m[1:3, 6] <- 0
(mT <- as(m, "TsparseMatrix"))
str(mT)
mT[1,]
mT[4, drop = FALSE]
stopifnot(identical(mT[lower.tri(mT)],
                    m [lower.tri(m) ]))
mT[lower.tri(mT,diag=TRUE)] <- 0
mT

## Triplet representation with repeated (i,j) entries
## *adds* the corresponding x's:
T2 <- new("dgTMatrix",
          i = as.integer(c(1,1,0,3,3)),
          j = as.integer(c(2,2,4,0,0)), x=10*1:5, Dim=4:5)
str(T2) # contains (i,j,x) slots exactly as above, but
T2 ## has only three non-zero entries, as for repeated (i,j)'s,
   ## the corresponding x's are "implicitly" added
stopifnot(nnzero(T2) == 3)
}
