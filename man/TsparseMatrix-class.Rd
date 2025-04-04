\name{TsparseMatrix-class}
\title{Class "TsparseMatrix" of Sparse Matrices in Triplet Form}
%
\docType{class}
\keyword{array}
\keyword{classes}
%
\alias{TsparseMatrix-class}
%
\alias{as.vector,TsparseMatrix-method}
\alias{coerce,TsparseMatrix,CsparseMatrix-method}
\alias{coerce,TsparseMatrix,RsparseMatrix-method}
\alias{coerce,TsparseMatrix,denseMatrix-method}
\alias{coerce,TsparseMatrix,generalMatrix-method}
\alias{coerce,TsparseMatrix,matrix-method}
\alias{coerce,TsparseMatrix,packedMatrix-method}
\alias{coerce,TsparseMatrix,sparseVector-method}
\alias{coerce,TsparseMatrix,unpackedMatrix-method}
\alias{coerce,TsparseMatrix,vector-method}
\alias{coerce,matrix,TsparseMatrix-method}
\alias{coerce,numLike,TsparseMatrix-method}
\alias{diag,TsparseMatrix-method}
\alias{diag<-,TsparseMatrix-method}
\alias{t,TsparseMatrix-method}
%
\description{The \code{"TsparseMatrix"} class is the virtual class of
  all sparse matrices coded in triplet form.  Since it is a virtual class,
  no objects may be created from it.  See
  \code{showClass("TsparseMatrix")} for its subclasses.
}
\section{Slots}{
  \describe{
    \item{\code{Dim}, \code{Dimnames}:}{from the \code{"\linkS4class{Matrix}"} class,}
    \item{\code{i}:}{Object of class \code{"integer"} - the row indices
      of non-zero entries \emph{in 0-base}, i.e., must be in
      \code{0:(nrow(.)-1)}.}
    \item{\code{j}:}{Object of class \code{"integer"} - the column
      indices of non-zero entries.  Must be the same length as slot
      \code{i} and \emph{0-based} as well, i.e., in
      \code{0:(ncol(.)-1)}.   For numeric Tsparse matrices, \code{(i,j)}
      pairs can occur more than once, see \code{\linkS4class{dgTMatrix}}.
    }
  }
}
\section{Extends}{
Class \code{"sparseMatrix"}, directly.
Class \code{"Matrix"}, by class \code{"sparseMatrix"}.
}
\section{Methods}{
  Extraction (\code{"["}) methods, see
  \code{\link{[-methods}}.%-> ./Xtrct-methods.Rd
}
\note{
  Most operations with sparse matrices are performed using the
  compressed, column-oriented or \code{\linkS4class{CsparseMatrix}}
  representation.  The triplet representation is convenient for
  creating a sparse matrix or for reading and writing such
  matrices.  Once it is created, however, the matrix is generally
  coerced to a \code{\linkS4class{CsparseMatrix}} for further
  operations.

  Note that all \code{new(.)}, \code{\link{spMatrix}} and
  \code{\link{sparseMatrix}(*, repr="T")} constructors
  for \code{"TsparseMatrix"} classes implicitly add (i.e., \dQuote{sum up})
  \eqn{x_k}'s that belong to identical \eqn{(i_k, j_k)} pairs, see, the
  example below, or also \code{"\linkS4class{dgTMatrix}"}.

  For convenience, methods for some operations such as \code{\%*\%}
  and \code{crossprod} are defined for
  \code{\linkS4class{TsparseMatrix}} objects.  These methods simply
  coerce the \code{\linkS4class{TsparseMatrix}} object to a
  \code{\linkS4class{CsparseMatrix}} object then perform the
  operation.
}
% \author{Martin Maechler}
\seealso{
  its superclass, \code{\linkS4class{sparseMatrix}}, and the
  \code{\linkS4class{dgTMatrix}} class, for the links to other classes.
}
\examples{
showClass("TsparseMatrix")
## or just the subclasses' names
names(getClass("TsparseMatrix")@subclasses)

T3 <- spMatrix(3,4, i=c(1,3:1), j=c(2,4:2), x=1:4)
T3 # only 3 non-zero entries, 5 = 1+4 !
\dontshow{stopifnot(nnzero(T3) == 3)}
}
