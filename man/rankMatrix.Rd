\name{rankMatrix}
\title{Rank of a Matrix}
%
\keyword{algebra}
\keyword{utilities}
%
\alias{rankMatrix}
\alias{qr2rankMatrix}
%
\description{
  Compute \sQuote{the} matrix rank, a well-defined functional in theory(*),
  somewhat ambiguous in practice.  We provide several methods, the
  default corresponding to Matlab's definition.

  (*) The rank of a \eqn{n \times m}{n x m} matrix \eqn{A}, \eqn{rk(A)},
      is the maximal number of linearly independent columns (or rows); hence
      \eqn{rk(A) \le min(n,m)}{rk(A) <= min(n,m)}.
}
\usage{
rankMatrix(x, tol = NULL,
           method = c("tolNorm2", "qr.R", "qrLINPACK", "qr",
                      "useGrad", "maybeGrad"),
           sval = svd(x, 0, 0)$d, warn.t = TRUE, warn.qr = TRUE)

qr2rankMatrix(qr, tol = NULL, isBqr = is.qr(qr), do.warn = TRUE)
}
\arguments{
  \item{x}{numeric matrix, of dimension \eqn{n \times m}{n x m}, say.}
  \item{tol}{nonnegative number specifying a (relative,
    \dQuote{scalefree}) tolerance for testing of
    \dQuote{practically zero} with specific meaning depending on
    \code{method}; by default, \code{max(dim(x)) * \link{.Machine}$double.eps}
    is according to Matlab's default (for its only method which is our
    \code{method="tolNorm2"}).}
  \item{method}{a character string specifying the computational method
    for the rank, can be abbreviated:
    \describe{
      \item{\code{"tolNorm2"}:}{the number of singular values
	\code{>= tol * max(sval)};}
      \item{\code{"qrLINPACK"}:}{for a dense matrix, this is the rank of
	\code{\link[base]{qr}(x, tol, LAPACK=FALSE)} (which is
	\code{qr(...)$rank});
	\cr
	This ("qr*", dense) version used to be \emph{the} recommended way to
	compute a matrix rank for a while in the past.

	For sparse \code{x}, this is equivalent to \code{"qr.R"}.
      }
      \item{\code{"qr.R"}:}{this is the rank of triangular matrix
	\eqn{R}, where \code{qr()} uses LAPACK or a "sparseQR" method
	(see \code{\link{qr-methods}}) to compute the decomposition
	\eqn{QR}.  The rank of \eqn{R} is then defined as the number of
	\dQuote{non-zero} diagonal entries \eqn{d_i} of \eqn{R}, and
	\dQuote{non-zero}s fulfill
	\eqn{|d_i| \ge \mathrm{tol}\cdot\max(|d_i|)}{|d_i| >= tol * max(|d_i|)}.
      }
      \item{\code{"qr"}:}{is for back compatibility; for dense \code{x},
	it corresponds to \code{"qrLINPACK"}, whereas for sparse
	\code{x}, it uses \code{"qr.R"}.

	For all the "qr*" methods, singular values \code{sval} are not
	used, which may be crucially important for a large sparse matrix
	\code{x}, as in that case, when \code{sval} is not specified,
	the default, computing \code{\link{svd}()} currently coerces
	\code{x} to a dense matrix.
      }
      \item{\code{"useGrad"}:}{considering the \dQuote{gradient} of the
	(decreasing) singular values, the index of the \emph{smallest} gap.}
      \item{\code{"maybeGrad"}:}{choosing method \code{"useGrad"} only when
	that seems \emph{reasonable}; otherwise using \code{"tolNorm2"}.}

%% FIXME say more
    }
  }
  \item{sval}{numeric vector of non-increasing singular values of
    \code{x}; typically unspecified and computed from \code{x} when
    needed, i.e., unless \code{method = "qr"}.}
  \item{warn.t}{logical indicating if \code{rankMatrix()} should warn
    when it needs \code{\link{t}(x)} instead of \code{x}.  Currently, for
    \code{method = "qr"} only, gives a warning by default because the
    caller often could have passed \code{t(x)} directly, more efficiently.}
  \item{warn.qr}{in the \eqn{QR} cases (i.e., if \code{method} starts with
    \code{"qr"}), \code{rankMatrix()} calls
    \code{qr2rankMarix(.., do.warn = warn.qr)}, see below.}

%% qr2rankMatrix():
  \item{qr}{an \R object resulting from \code{\link{qr}(x,..)}, i.e.,
    typically inheriting from \code{\link{class}} \code{"\link{qr}"} or
    \code{"\linkS4class{sparseQR}"}.}
  \item{isBqr}{\code{\link{logical}} indicating if \code{qr} is resulting
    from \pkg{base} \code{\link[base]{qr}()}.  (Otherwise, it is typically
    from \pkg{Matrix} package sparse \code{\link[Matrix]{qr}}.)}
  \item{do.warn}{logical; if true, warn about non-finite (or in the
    \code{sparseQR} case negative)
    diagonal entries in the \eqn{R} matrix of the \eqn{QR} decomposition.
    Do not change lightly!}
}
\details{
  \code{qr2rankMatrix()} is typically called from \code{rankMatrix()} for
  the \code{"qr"}* \code{method}s, but can be used directly - much more
  efficiently in case the \code{qr}-decomposition is available anyway.
}
\note{For large sparse matrices \code{x}, unless you can specify
  \code{sval} yourself, currently \code{method = "qr"} may
  be the only feasible one, as the others need \code{sval} and call
  \code{\link{svd}()} which currently coerces \code{x} to a
  \code{\linkS4class{denseMatrix}} which may be very slow or impossible,
  depending on the matrix dimensions.

  Note that in the case of sparse \code{x}, \code{method = "qr"}, all
  non-strictly zero diagonal entries \eqn{d_i} where counted, up to
  including \pkg{Matrix} version 1.1-0, i.e., that method implicitly
  used \code{tol = 0}, see also the \code{set.seed(42)} example below.
}
\value{
  If \code{x} is a matrix of all \code{0} (or of zero dimension), the rank
  is zero; otherwise, typically a positive integer in \code{1:min(dim(x))}
  with attributes detailing the method used.

  There are rare cases where the sparse \eqn{QR} decomposition
  \dQuote{fails} in so far as the diagonal entries of \eqn{R}, the
  \eqn{d_i} (see above), end with non-finite, typically \code{\link{NaN}}
  entries.  Then, a warning is signalled (unless \code{warn.qr} /
  \code{do.warn} is not true) and \code{NA} (specifically,
  \code{\link{NA_integer_}}) is returned.
}
% \references{
% %% ~put references to the literature/web site here ~
% }
\author{Martin Maechler; for the "*Grad" methods building on
  suggestions by Ravi Varadhan.
}
\seealso{
 \code{\link{qr}}, \code{\link{svd}}.
}
\examples{
\dontshow{ % for R_DEFAULT_PACKAGES=NULL
library(stats, pos = "package:base", verbose = FALSE)
}
rankMatrix(cbind(1, 0, 1:3)) # 2

(meths <- eval(formals(rankMatrix)$method))

## a "border" case:
H12 <- Hilbert(12)
rankMatrix(H12, tol = 1e-20) # 12;  but  11  with default method & tol.
sapply(meths, function(.m.) rankMatrix(H12, method = .m.))
## tolNorm2   qr.R  qrLINPACK   qr  useGrad maybeGrad
##       11     11         12   12       11        11
## The meaning of 'tol' for method="qrLINPACK" and *dense* x is not entirely "scale free"
rMQL <- function(ex, M) rankMatrix(M, method="qrLINPACK",tol = 10^-ex)
rMQR <- function(ex, M) rankMatrix(M, method="qr.R",     tol = 10^-ex)
sapply(5:15, rMQL, M = H12) # result is platform dependent
##  7  7  8 10 10 11 11 11 12 12 12  {x86_64}
sapply(5:15, rMQL, M = 1000 * H12) # not identical unfortunately
##  7  7  8 10 11 11 12 12 12 12 12
sapply(5:15, rMQR, M = H12)
##  5  6  7  8  8  9  9 10 10 11 11
sapply(5:15, rMQR, M = 1000 * H12) # the *same*
\dontshow{
  (r12 <- sapply(5:15, rMQR, M = H12))
  stopifnot(identical(r12, sapply(5:15, rMQR, M = H12 / 100)),
            identical(r12, sapply(5:15, rMQR, M = H12 * 1e5)))

  rM1 <- function(ex, M) rankMatrix(M, tol = 10^-ex)
  (r12 <- sapply(5:15, rM1, M = H12))
  stopifnot(identical(r12, sapply(5:15, rM1, M = H12 / 100)),
            identical(r12, sapply(5:15, rM1, M = H12 * 1e5)))
}

## "sparse" case:
M15 <- kronecker(diag(x=c(100,1,10)), Hilbert(5))
sapply(meths, function(.m.) rankMatrix(M15, method = .m.))
#--> all 15, but 'useGrad' has 14.
sapply(meths, function(.m.) rankMatrix(M15, method = .m., tol = 1e-7)) # all 14

## "large" sparse
n <- 250000; p <- 33; nnz <- 10000
L <- sparseMatrix(i = sample.int(n, nnz, replace=TRUE),
                  j = sample.int(p, nnz, replace=TRUE),
                  x = rnorm(nnz))
(st1 <- system.time(r1 <- rankMatrix(L)))                # warning+ ~1.5 sec (2013)
(st2 <- system.time(r2 <- rankMatrix(L, method = "qr"))) # considerably faster!
r1[[1]] == print(r2[[1]]) ## -->  ( 33  TRUE )
\dontshow{
stopifnot(r1[[1]] == 33, 33 == r2[[1]])
if(interactive() || nzchar(Sys.getenv("R_MATRIX_CHECK_EXTRA")))
    stopifnot(st2[[1]] < 0.2) # seeing 0.03 (on ~ 2010-hardware; R 3.0.2)
}
## another sparse-"qr" one, which ``failed'' till 2013-11-23:
set.seed(42)
f1 <- factor(sample(50, 1000, replace=TRUE))
f2 <- factor(sample(50, 1000, replace=TRUE))
f3 <- factor(sample(50, 1000, replace=TRUE))
D <- t(do.call(rbind, lapply(list(f1,f2,f3), as, 'sparseMatrix')))
dim(D); nnzero(D) ## 1000 x 150 // 3000 non-zeros (= 2\%)
stopifnot(rankMatrix(D,           method='qr') == 148,
	  rankMatrix(crossprod(D),method='qr') == 148)

## zero matrix has rank 0 :
stopifnot(sapply(meths, function(.m.)
                        rankMatrix(matrix(0, 2, 2), method = .m.)) == 0)
}
