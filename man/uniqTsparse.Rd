\name{uniqTsparse}
\title{Unique (Sorted) TsparseMatrix Representations}
%
\keyword{array}
\keyword{logic}
\keyword{manip}
\keyword{utilities}
%
\alias{uniqTsparse}
\alias{anyDuplicatedT}
%
\description{
  Detect or \dQuote{unify} (or \dQuote{standardize}) non-unique
  \code{\linkS4class{TsparseMatrix}} matrices, prducing unique
  \eqn{(i,j,x)} triplets which are \emph{sorted}, first in \eqn{j}, then
  in \eqn{i} (in the sense of \code{\link{order}(j,i)}).

  Note that \code{new(.)}, \code{\link{spMatrix}} or
  \code{\link{sparseMatrix}} constructors for \code{"dgTMatrix"} (and
  other \code{"\linkS4class{TsparseMatrix}"} classes) implicitly add
  \eqn{x_k}'s that belong to identical \eqn{(i_k, j_k)} pairs.

  \code{anyDuplicatedT()} reports the index of the first duplicated
  pair, or \code{0} if there is none.

  \code{uniqTsparse(x)} replaces duplicated index pairs \eqn{(i,j)} and their
  corresponding \code{x} slot entries by the triple \eqn{(i,j, sx)}
  where \code{sx = sum(x [<all pairs matching (i,j)>])}, and for logical
  \code{x}, addition is replaced by logical \eqn{or}.
}
\usage{
uniqTsparse(x, class.x = c(class(x)))
anyDuplicatedT(x, di = dim(x))
}
\arguments{
  \item{x}{a sparse matrix stored in triplet form, i.e., inheriting
    from class \code{\linkS4class{TsparseMatrix}}.}
  \item{class.x}{optional character string specifying \code{class(x)}.}
  \item{di}{the matrix dimension of \code{x}, \code{\link{dim}(x)}.}
}
%% \details{
%% }
\value{
  \code{uniqTsparse(x)} returns a \code{\linkS4class{TsparseMatrix}}
  \dQuote{like x}, of the same class and with the same elements, just
  internally possibly changed to \dQuote{unique} \eqn{(i,j,x)} triplets
  in \emph{sorted} order.

  \code{anyDuplicatedT(x)} returns an \code{\link{integer}} as
  \code{\link{anyDuplicated}}, the \emph{index}
  of the first duplicated entry (from the \eqn{(i,j)} pairs)
  if there is one, and \code{0} otherwise.
}
\seealso{
 \code{\linkS4class{TsparseMatrix}}, for uniqueness, notably
 \code{\linkS4class{dgTMatrix}}.
}
\examples{
\dontshow{ % for R_DEFAULT_PACKAGES=NULL
library(stats, pos = "package:base", verbose = FALSE)
library(utils, pos = "package:base", verbose = FALSE)
}
example("dgTMatrix-class", echo=FALSE)
## -> 'T2'  with (i,j,x) slots of length 5 each
T2u <- uniqTsparse(T2)
stopifnot(## They "are" the same (and print the same):
          all.equal(T2, T2u, tol=0),
          ## but not internally:
          anyDuplicatedT(T2)  == 2,
          anyDuplicatedT(T2u) == 0,
          length(T2 @x) == 5,
          length(T2u@x) == 3)

## is 'x' a "uniq Tsparse" Matrix ?  [requires x to be TsparseMatrix!]
non_uniqT <- function(x, di = dim(x))
  is.unsorted(x@j) || anyDuplicatedT(x, di)
non_uniqT(T2 ) # TRUE
non_uniqT(T2u) # FALSE

T3 <- T2u
T3[1, c(1,3)] <- 10; T3[2, c(1,5)] <- 20
T3u <- uniqTsparse(T3)
str(T3u) # sorted in 'j', and within j, sorted in i
stopifnot(!non_uniqT(T3u))

## Logical l.TMatrix and n.TMatrix :
(L2 <- T2 > 0)
validObject(L2u <- uniqTsparse(L2))
(N2 <- as(L2, "nMatrix"))
validObject(N2u <- uniqTsparse(N2))
stopifnot(N2u@i == L2u@i, L2u@i == T2u@i,  N2@i == L2@i, L2@i == T2@i,
          N2u@j == L2u@j, L2u@j == T2u@j,  N2@j == L2@j, L2@j == T2@j)
# now with a nasty NA  [partly failed in Matrix 1.1-5]:
L.0N <- L.1N <- L2
L.0N@x[1:2] <- c(FALSE, NA)
L.1N@x[1:2] <- c(TRUE, NA)
validObject(L.0N)
validObject(L.1N)
(m.0N <- as.matrix(L.0N))
(m.1N <- as.matrix(L.1N))
stopifnot(identical(10L, which(is.na(m.0N))), !anyNA(m.1N))
symnum(m.0N)
symnum(m.1N)
}
