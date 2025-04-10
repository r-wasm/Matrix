\name{dsCMatrix-class}
\title{Numeric Symmetric Sparse (column compressed) Matrices}
%
\docType{class}
\keyword{array}
\keyword{classes}
%
\alias{dsCMatrix-class}
\alias{dsTMatrix-class}
%
\alias{Arith,dsCMatrix,dsCMatrix-method}
\alias{coerce,dsCMatrix,RsparseMatrix-method}
\alias{determinant,dsCMatrix,logical-method}
%
\alias{determinant,dsTMatrix,logical-method}
%
\description{The \code{dsCMatrix} class is a class of symmetric, sparse
  numeric matrices in the compressed, \bold{c}olumn-oriented format.  In
  this implementation the non-zero elements in the columns are sorted
  into increasing row order.

  The \code{dsTMatrix} class is the class of symmetric, sparse numeric
  matrices in \bold{t}riplet format.
}
\section{Objects from the Class}{
  Objects can be created by calls of the form \code{new("dsCMatrix",
    ...)} or \code{new("dsTMatrix", ...)}, or automatically via e.g.,
  \code{as(*, "symmetricMatrix")}, or (for \code{dsCMatrix}) also
  from \code{\link{Matrix}(.)}.

  Creation \dQuote{from scratch} most efficiently happens via
  \code{\link{sparseMatrix}(*, symmetric=TRUE)}.
}
\section{Slots}{
  \describe{
    \item{\code{uplo}:}{A character object indicating if the upper
      triangle (\code{"U"}) or the lower triangle (\code{"L"}) is stored.}
    \item{\code{i}:}{Object of class \code{"integer"} of length nnZ
      (\emph{half} number of non-zero elements).  These are the row
      numbers for each non-zero element in the lower triangle of the matrix.}
    \item{\code{p}:}{(only in class \code{"dsCMatrix"}:) an
      \code{\link{integer}} vector for providing pointers, one for each
      column, see the detailed description in \code{\linkS4class{CsparseMatrix}}.}
    \item{\code{j}:}{(only in class \code{"dsTMatrix"}:) Object of
      class \code{"integer"} of length nnZ (as \code{i}).  These are the
      column numbers for each non-zero element in the lower triangle of
      the matrix.}
    \item{\code{x}:}{Object of class \code{"numeric"} of length nnZ --
      the non-zero elements of the matrix (to be duplicated for full matrix).}
    \item{\code{factors}:}{Object of class \code{"list"} - a list
      of factorizations of the matrix. }
    \item{\code{Dim}:}{Object of class \code{"integer"} - the dimensions
     of the matrix - must be an integer vector with exactly two
     non-negative values.}
  }
}
\section{Extends}{
  Both classes extend classes and \code{\linkS4class{symmetricMatrix}}
  \code{\linkS4class{dsparseMatrix}} directly;
  \code{dsCMatrix} further directly extends
  \code{\linkS4class{CsparseMatrix}}, where
  \code{dsTMatrix} does \code{\linkS4class{TsparseMatrix}}.
}
\section{Methods}{
  \describe{
    \item{solve}{\code{signature(a = "dsCMatrix", b = "....")}: \code{x
	<- solve(a,b)} solves \eqn{A x = b} for \eqn{x}; see
      \code{\link{solve-methods}}.}
    \item{chol}{\code{signature(x = "dsCMatrix", pivot = "logical")}:
      Returns (and stores) the Cholesky decomposition of \code{x}, see
      \code{\link{chol}}.}
    \item{Cholesky}{\code{signature(A = "dsCMatrix",...)}:
      Computes more flexibly Cholesky decompositions,
      see \code{\link{Cholesky}}.}
    \item{determinant}{\code{signature(x = "dsCMatrix", logarithm =
	"missing")}: Evaluate the determinant of \code{x} on the
      logarithm scale.  This creates and stores the Cholesky factorization.}
    \item{determinant}{\code{signature(x = "dsCMatrix", logarithm =
	"logical")}: Evaluate the determinant of \code{x} on the
      logarithm scale or not, according to the \code{logarithm}
      argument.  This creates and stores the Cholesky factorization.}
    \item{t}{\code{signature(x = "dsCMatrix")}: Transpose.  As for all
      symmetric matrices, a matrix for which the upper triangle is
      stored produces a matrix for which the lower triangle is stored
      and vice versa, i.e., the \code{uplo} slot is swapped, and the row
      and column indices are interchanged.}
    \item{t}{\code{signature(x = "dsTMatrix")}: Transpose.  The
      \code{uplo} slot is swapped from \code{"U"} to \code{"L"} or vice
      versa, as for a \code{"dsCMatrix"}, see above.}
  }
}
%\references{}
%\author{}
%\note{}
\seealso{
  Classes \code{\linkS4class{dgCMatrix}}, \code{\linkS4class{dgTMatrix}},
  \code{\linkS4class{dgeMatrix}} and those mentioned above.
}
\examples{
\dontshow{ % for R_DEFAULT_PACKAGES=NULL
library(utils, pos = "package:base", verbose = FALSE)
}
mm <- Matrix(toeplitz(c(10, 0, 1, 0, 3)), sparse = TRUE)
mm # automatically dsCMatrix
str(mm)
mT <- as(as(mm, "generalMatrix"), "TsparseMatrix")

## Either
(symM <- as(mT, "symmetricMatrix")) # dsT
(symC <- as(symM, "CsparseMatrix")) # dsC
## or
sT <- Matrix(mT, sparse=TRUE, forceCheck=TRUE) # dsT

sym2 <- as(symC, "TsparseMatrix")
## --> the same as 'symM', a "dsTMatrix"
\dontshow{
stopifnot(identical(sT, symM), identical(sym2, symM),
          class(sym2) == "dsTMatrix",
	  identical(sym2[1,], sT[1,]),
	  identical(sym2[,2], sT[,2]))
}
}
