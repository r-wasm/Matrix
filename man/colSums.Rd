\name{colSums-methods}
\title{Form Row and Column Sums and Means}
%
\docType{methods}
\keyword{algebra}
\keyword{arith}
\keyword{array}
\keyword{methods}
%
\alias{colSums}
\alias{colSums-methods}
\alias{colMeans}
\alias{colMeans-methods}
\alias{rowSums}
\alias{rowSums-methods}
\alias{rowMeans}
\alias{rowMeans-methods}
%
\alias{colSums,CsparseMatrix-method}
\alias{colSums,RsparseMatrix-method}
\alias{colSums,TsparseMatrix-method}
\alias{colSums,denseMatrix-method}
\alias{colSums,diagonalMatrix-method}
\alias{colSums,indMatrix-method}
%
\alias{colMeans,CsparseMatrix-method}
\alias{colMeans,RsparseMatrix-method}
\alias{colMeans,TsparseMatrix-method}
\alias{colMeans,denseMatrix-method}
\alias{colMeans,diagonalMatrix-method}
\alias{colMeans,indMatrix-method}
%
\alias{rowSums,CsparseMatrix-method}
\alias{rowSums,RsparseMatrix-method}
\alias{rowSums,TsparseMatrix-method}
\alias{rowSums,denseMatrix-method}
\alias{rowSums,diagonalMatrix-method}
\alias{rowSums,indMatrix-method}
%
\alias{rowMeans,CsparseMatrix-method}
\alias{rowMeans,RsparseMatrix-method}
\alias{rowMeans,TsparseMatrix-method}
\alias{rowMeans,denseMatrix-method}
\alias{rowMeans,diagonalMatrix-method}
\alias{rowMeans,indMatrix-method}
%
\description{
  Form row and column sums and means for
  objects, for \code{\linkS4class{sparseMatrix}} the result may
  optionally be sparse (\code{\linkS4class{sparseVector}}), too.
  Row or column names are kept respectively as for \pkg{base} matrices
  and \code{\link{colSums}} methods, when the result is
  \code{\link{numeric}} vector.
}
\usage{
colSums (x, na.rm = FALSE, dims = 1L, \dots)
rowSums (x, na.rm = FALSE, dims = 1L, \dots)
colMeans(x, na.rm = FALSE, dims = 1L, \dots)
rowMeans(x, na.rm = FALSE, dims = 1L, \dots)

\S4method{colSums}{CsparseMatrix}(x, na.rm = FALSE,
        dims = 1L, sparseResult = FALSE)
\S4method{rowSums}{CsparseMatrix}(x, na.rm = FALSE,
        dims = 1L, sparseResult = FALSE)
\S4method{colMeans}{CsparseMatrix}(x, na.rm = FALSE,
        dims = 1L, sparseResult = FALSE)
\S4method{rowMeans}{CsparseMatrix}(x, na.rm = FALSE,
        dims = 1L, sparseResult = FALSE)
}
\arguments{
  \item{x}{a Matrix, i.e., inheriting from  \code{\linkS4class{Matrix}}.}
  \item{na.rm}{logical.  Should missing values (including \code{NaN})
    be omitted from the calculations?}
  \item{dims}{completely ignored by the \code{Matrix} methods.}
  \item{\dots}{potentially further arguments, for method \code{<->}
    generic compatibility.}
  \item{sparseResult}{logical indicating if the result should be sparse,
    i.e., inheriting from class \code{\linkS4class{sparseVector}}.  Only
    applicable when \code{x} is inheriting from a
    \code{\linkS4class{sparseMatrix}} class.}
}
% \details{
%   ~~ If necessary, more details than the description above ~~
% }
\value{
  returns a numeric vector if \code{sparseResult} is \code{FALSE} as per
  default.  Otherwise, returns a \code{\linkS4class{sparseVector}}.

  \code{\link{dimnames}(x)} are only kept (as \code{\link{names}(v)})
  when the resulting \code{v} is \code{\link{numeric}}, since
  \code{\link{sparseVector}}s do not have names.
}
%\author{Martin}
\seealso{\code{\link[base]{colSums}} and the
  \code{\linkS4class{sparseVector}} classes.
}
\examples{
(M <- bdiag(Diagonal(2), matrix(1:3, 3,4), diag(3:2))) # 7 x 8
colSums(M)
d <- Diagonal(10, c(0,0,10,0,2,rep(0,5)))
MM <- kronecker(d, M)
dim(MM) # 70 80
length(MM@x) # 160, but many are '0' ; drop those:
MM <- drop0(MM)
length(MM@x) # 32
  cm <- colSums(MM)
(scm <- colSums(MM, sparseResult = TRUE))
stopifnot(is(scm, "sparseVector"),
          identical(cm, as.numeric(scm)))
rowSums (MM, sparseResult = TRUE) # 14 of 70 are not zero
colMeans(MM, sparseResult = TRUE) # 16 of 80 are not zero
## Since we have no 'NA's, these two are equivalent :
stopifnot(identical(rowMeans(MM, sparseResult = TRUE),
                    rowMeans(MM, sparseResult = TRUE, na.rm = TRUE)),
	  rowMeans(Diagonal(16)) == 1/16,
	  colSums(Diagonal(7)) == 1)

## dimnames(x) -->  names( <value> ) :
dimnames(M) <- list(paste0("r", 1:7), paste0("V",1:8))
M
colSums(M)
rowMeans(M)
## Assertions :
stopifnot(exprs = {
    all.equal(colSums(M),
              structure(c(1,1,6,6,6,6,3,2), names = colnames(M)))
    all.equal(rowMeans(M),
              structure(c(1,1,4,8,12,3,2)/8, names = paste0("r", 1:7)))
})
}
