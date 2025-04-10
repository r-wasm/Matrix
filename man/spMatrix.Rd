\name{spMatrix}
\title{Sparse Matrix Constructor From Triplet}
%
\keyword{array}
\keyword{utilities}
%
\alias{spMatrix}
%
\description{
  User friendly construction of a sparse matrix (inheriting from class
  \code{\linkS4class{TsparseMatrix}}) from the triplet representation.

  This is much less flexible than \code{\link{sparseMatrix}()} and hence
  somewhat \emph{deprecated}.
}
\usage{
spMatrix(nrow, ncol, i = integer(), j = integer(), x = double())
}
\arguments{
  \item{nrow, ncol}{integers specifying the desired number of rows and
    columns.}
  \item{i,j}{integer vectors of the same length specifying the locations
    of the non-zero (or non-\code{TRUE}) entries of the matrix.}
  \item{x}{atomic vector of the same length as \code{i} and \code{j},
    specifying the values of the non-zero entries.}
}
\value{
  A sparse matrix in triplet form, as an \R object inheriting from both
  \code{\linkS4class{TsparseMatrix}} and
  \code{\linkS4class{generalMatrix}}.

  The matrix \eqn{M} will have
  \code{M[i[k], j[k]] == x[k]}, for \eqn{k = 1,2,\ldots, n}, where
  \code{n = length(i)} and
  \code{M[ i', j' ] == 0} for all other pairs \eqn{(i',j')}.
}
\seealso{\code{\link{Matrix}(*, sparse=TRUE)} for the more usual
  constructor of such matrices.  Then, \code{\link{sparseMatrix}}
  is more general and flexible than \code{spMatrix()} and by default
  returns a \code{\linkS4class{CsparseMatrix}} which is often slightly
  more desirable.   Further, \code{\link{bdiag}} and
  \code{\link{Diagonal}} for (block-)diagonal matrix constructors.

  Consider \code{\linkS4class{TsparseMatrix}} and similar class
  definition help files.
}
\examples{
\dontshow{ % for R_DEFAULT_PACKAGES=NULL
library(stats, pos = "package:base", verbose = FALSE)
library(utils, pos = "package:base", verbose = FALSE)
}
## simple example
A <- spMatrix(10,20, i = c(1,3:8),
                     j = c(2,9,6:10),
                     x = 7 * (1:7))
A # a "dgTMatrix"
summary(A)
str(A) # note that *internally* 0-based indices (i,j) are used

L <- spMatrix(9, 30, i = rep(1:9, 3), 1:27,
              (1:27) \%\% 4 != 1)
L # an "lgTMatrix"


## A simplified predecessor of  Matrix'  rsparsematrix() function :

 rSpMatrix <- function(nrow, ncol, nnz,
                       rand.x = function(n) round(rnorm(nnz), 2))
 {
     ## Purpose: random sparse matrix
     ## --------------------------------------------------------------
     ## Arguments: (nrow,ncol): dimension
     ##          nnz  :  number of non-zero entries
     ##         rand.x:  random number generator for 'x' slot
     ## --------------------------------------------------------------
     ## Author: Martin Maechler, Date: 14.-16. May 2007
     stopifnot((nnz <- as.integer(nnz)) >= 0,
               nrow >= 0, ncol >= 0, nnz <= nrow * ncol)
     spMatrix(nrow, ncol,
              i = sample(nrow, nnz, replace = TRUE),
              j = sample(ncol, nnz, replace = TRUE),
              x = rand.x(nnz))
 }

 M1 <- rSpMatrix(100000, 20, nnz = 200)
 summary(M1)
}
