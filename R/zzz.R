## ~~~~ PACKAGE ENVIRONMENTS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## Recording default values of Matrix.* options
.MatrixEnv <- new.env(parent = emptyenv(), hash = FALSE)

## Storing settings from 'cholmod_common'
.chm_common <- new.env(parent = emptyenv())


## ~~~~ NAMESPACE HOOKS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.onLoad <- function(libname, pkgname) {
    ## For backwards compatibility with earlier versions of R,
    ## at least until x.y.z if we have Depends: R (>= x.y.z)
    if((Rv <- getRversion()) < "4.1.3" &&
       ## Namespace not locked yet, but being defensive here:
       !environmentIsLocked(Mns <- parent.env(environment()))) {
        assign("...names", envir = Mns, inherits = FALSE,
               function() eval(quote(names(list(...))), sys.frame(-1L)))
        if(Rv < "4.0.0") {
            assign("deparse1", envir = Mns, inherits = FALSE,
                   function(expr, collapse = " ", width.cutoff = 500L, ...)
                       paste(deparse(expr, width.cutoff, ...),
                             collapse = collapse))
            assign("sequence.default", envir = Mns, inherits = FALSE,
                   function(nvec, from = 1L, by = 1L, ...)
                       unlist(.mapply(seq.int,
                                      list(from = as.integer(from),
                                           by = as.integer(by),
                                           length.out = as.integer(nvec)),
                                      NULL),
                              recursive = FALSE, use.names = FALSE))
            assign("tryInvokeRestart", envir = Mns, inherits = FALSE,
                   function(r, ...)
                       tryCatch(invokeRestart(r, ...),
                                error = function(e) invisible(NULL)))
        }
    }

    ## verbose:
    ## logical/integer (but often supplied as double),
    ## deciding _if_ conditions are signaled
    v <- as.integer(Sys.getenv("R_MATRIX_VERBOSE", "0"))
    assign("verbose", if(is.na(v)) 0L else v, envir = .MatrixEnv)

    ## warn:
    ## logical/integer (but often supplied as double),
    ## deciding _what_ conditions are signaled
    ## (0=message, 1=warning, 2=error)
    w <- as.integer(Sys.getenv("R_MATRIX_WARN", "0"))
    assign("warn", if(is.na(w)) 0L else w, envir = .MatrixEnv)

    ## ambiguityNotes:
    ## show S4 method dispatch ambiguity notes if TRUE
    aN <- as.logical(Sys.getenv("R_MATRIX_AMBIGUITY_NOTES", "false"))
    aN <- (!is.na(aN) && aN) || !is.null(getOption("ambiguousMethodSelection"))
    assign("ambiguityNotes", aN, envir = .MatrixEnv)
    if(!aN)
        options(ambiguousMethodSelection = # ?methods::testInheritedMethods
                    `environment<-`(function(cond) NULL, emptyenv()))

    ## warnDeprecatedCoerce:
    ## <=0 ... no conditions signaled
    ##   1 ... persistent warning
    ## >=2 ... persistent error
    ##  NA ... one-time message { d(g.|.C)Matrix } or warning { others }
    wDC <- as.integer(Sys.getenv("R_MATRIX_WARN_DEPRECATED_COERCE", NA))
    assign("warnDeprecatedCoerce", wDC, envir = .MatrixEnv)

    ## warnSqrtDefault:
    ## <=0 ... no conditions signaled
    ##   1 ... persistent warning
    ## >=2 ... persistent error
    ##  NA ... one-time warning
    wSD <- as.integer(Sys.getenv("R_MATRIX_WARN_SQRT_DEFAULT", NA))
    assign("warnSqrtDefault", wDC, envir = .MatrixEnv)

    .Call(CHM_set_common_env, .chm_common)
    NULL
}

.onUnload <- function(libpath) {
    library.dynam.unload("Matrix", libpath)
    if(!.MatrixEnv[["ambiguityNotes"]])
        options(ambiguousMethodSelection = NULL)
    NULL
}


## ~~~~ DEPRECATED ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

..2dge <- function(from) {
    .Deprecated(new = ".dense2g", package = "Matrix")
    .dense2g(from, "d")
}
.C2nC <- function(from, isTri) {
    .Deprecated(new = ".sparse2kind", package = "Matrix")
    .sparse2kind(from, "n")
}
.T2Cmat <- function(from, isTri) {
    .Deprecated(new = ".T2CR", package = "Matrix")
    .T2CR(from, Csparse = TRUE)
}
.asmatrix <- function(x) {
    .Deprecated(new = "as(., \"matrix\")", package = "Matrix")
    as(x, "matrix")
}
.dense2sy <- function(from, ...) {
    .Deprecated(new = ".M2sym", package = "Matrix")
    .M2sym(from, ...)
}
.diag2mat <- function(from) {
    .Deprecated(new = "as(., \"matrix\")", package = "Matrix")
    .diag2m(from)
}
.diag2sT <- function(from, uplo = "U", kind = ".", drop0 = TRUE) {
    .Deprecated(new = ".diag2sparse", package = "Matrix")
    .diag2sparse(from, code = `substr<-`(".sT", 1L, 1L, kind),
                 uplo = uplo, drop0 = drop0)
}
.diag2tT <- function(from, uplo = "U", kind = ".", drop0 = TRUE) {
    .Deprecated(new = ".diag2sparse", package = "Matrix")
    .diag2sparse(from, code = `substr<-`(".tT", 1L, 1L, kind),
                 uplo = uplo, drop0 = drop0)
}
.dsy2dsp <- function(from) {
    .Deprecated(new = "pack", package = "Matrix")
    pack(from)
}
.dsy2mat <- function(from, keep.dimnames = TRUE) {
    .Deprecated(new = ".dense2m", package = "Matrix")
    to <- .dense2m(from)
    if (!keep.dimnames)
        dimnames(to) <- NULL
    to
}
.dxC2mat <- function(from, chkUdiag) {
    .Deprecated(new = ".sparse2m", package = "Matrix")
    .sparse2m(from)
}
.m2dgC <- function(from) {
    .Deprecated(new = ".m2sparse", package = "Matrix")
    .m2sparse(from, "dgC")
}
.m2lgC <- function(from) {
    .Deprecated(new = ".m2sparse", package = "Matrix")
    .m2sparse(from, "lgC")
}
.m2ngC <- function(from) {
    .Deprecated(new = ".m2sparse", package = "Matrix")
    if(anyNA(from))
        stop("attempt to coerce matrix with NA to ngCMatrix")
    .m2sparse(from, "ngC")
}
.m2ngCn <- function(from, na.is.not.0 = FALSE) {
    .Deprecated(new = ".m2sparse", package = "Matrix")
    if(!na.is.not.0 && anyNA(from))
        stop("attempt to coerce matrix with NA to ngCMatrix")
    .m2sparse(from, "ngC")
}
.m2ngTn <- function(from, na.is.not.0 = FALSE) {
    .Deprecated(new = ".m2sparse", package = "Matrix")
    if(!na.is.not.0 && anyNA(from))
        stop("attempt to coerce matrix with NA to ngCMatrix")
    .m2sparse(from, "ngT")
}
.n2dgT <- function(from) {
    .Deprecated(new = ".sparse2kind", package = "Matrix")
    .sparse2kind(from, "d")
}
.nC2d <- function(from) {
    .Deprecated(new = ".sparse2kind", package = "Matrix")
    .sparse2kind(from, "d")
}
.nC2l <- function(from) {
    .Deprecated(new = ".sparse2kind", package = "Matrix")
    .sparse2kind(from, "l")
}

## Utility for Matrix.DeprecatedCoerce(); see below
.as.via.virtual <- function(Class1, Class2, from = quote(from)) {
    if(!isClassDef(Class1))
        Class1 <- getClassDef(Class1)
    if(!isClassDef(Class2))
        Class2 <- getClassDef(Class2)
    if(!grepl("^[dln](di|ge|tr|sy|tp|sp|[gts][CRT])Matrix$", Class2@className))
        stop("invalid 'Class2'")
    contains1 <- names(Class1@contains)
    contains2 <- names(Class2@contains)
    virtual <- list(c("dMatrix", "lMatrix", "nMatrix"),
                    c("generalMatrix", "triangularMatrix", "symmetricMatrix"),
                    c("CsparseMatrix", "RsparseMatrix", "TsparseMatrix",
                      "diagonalMatrix", "unpackedMatrix", "packedMatrix"))
    to <- from
    for(v in virtual) {
        if(any(m <- match(v, contains2, 0L) > 0L)) {
            v1 <- v[m][1L]
            if(match(v1, contains1, 0L) == 0L)
                to <- call("as", to, v1)
        }
    }
    to
}

Matrix.DeprecatedCoerce <- function(Class1, Class2) {
    if(!isClassDef(Class1))
        Class1 <- getClassDef(Class1)
    if(!isClassDef(Class2))
        Class2 <- getClassDef(Class2)
    w <- getOption("Matrix.warnDeprecatedCoerce",
                   .MatrixEnv[["warnDeprecatedCoerce"]])
    if(is.atomic(w) && length(w) == 1L &&
       ((w.na <- is.na(w <- as.integer(w))) || w > 0L)) {
        cln1 <- Class1@className
        cln2 <- Class2@className

        old <- sprintf("as(<%s>, \"%s\")", cln1, cln2)
        new <- deparse1(.as.via.virtual(Class1, Class2, quote(.)))

        if(w.na)
            on.exit(options(Matrix.warnDeprecatedCoerce = 0L))
        if(w.na && grepl("d(g.|.C)Matrix", cln2)) {
            cond <-
                tryCatch(.Deprecated(old = old, new = new, package = "Matrix"),
                         deprecatedWarning = identity)
            message(conditionMessage(cond), domain = NA)
        } else {
            if(!w.na && w > 1L) {
                oop <- options(warn = 2L)
                on.exit(options(oop))
            }
            .Deprecated(old = old, new = new, package = "Matrix")
        }
    }
    invisible(NULL)
}

## "Granular" coercions available in Matrix 1.4-1,
## all candidates for deprecation in Matrix 1.5-0:
if(FALSE) {
stopifnot(packageVersion("Matrix") == "1.4.1")
dput(lapply(grep("to=\"[dln](di|ge|tr|sy|tp|sp|[gts][CRT])Matrix\"",
                 capture.output(showMethods("coerce")),
                 value = TRUE),
            function(s) unname(eval(str2lang(paste0("c(", s, ")"))))))
}
## Note:  Allow  as(*, "dpoMatrix")  to check for pos.(semi)definite-ness
.from.to <- list(c("ddenseMatrix", "dgeMatrix"), c("ddiMatrix", "dgCMatrix"),
                 c("ddiMatrix", "dgeMatrix"), c("ddiMatrix", "dtCMatrix"),
                 c("dgCMatrix", "dgeMatrix"), c("dgCMatrix", "dgTMatrix"),
                 c("dgCMatrix", "dsCMatrix"), c("dgCMatrix", "dtCMatrix"),
                 c("dgCMatrix", "lgCMatrix"), c("dgCMatrix", "ngCMatrix"),
                 c("dgeMatrix", "dgCMatrix"), c("dgeMatrix", "dgTMatrix"),
                 c("dgeMatrix", "dspMatrix"), c("dgeMatrix", "dsTMatrix"),
                 c("dgeMatrix", "dsyMatrix"), c("dgeMatrix", "dtrMatrix"),
                 c("dgeMatrix", "lgeMatrix"), c("dgTMatrix", "dgCMatrix"),
                 c("dgTMatrix", "dgeMatrix"), c("dgTMatrix", "dsTMatrix"),
                 c("dgTMatrix", "dtCMatrix"), c("dgTMatrix", "dtTMatrix"),
                 c("dsCMatrix", "dgCMatrix"), c("dsCMatrix", "dgeMatrix"),
                 c("dsCMatrix", "dgTMatrix"), c("dsCMatrix", "dsRMatrix"),
                 c("dsCMatrix", "dsTMatrix"), c("dsCMatrix", "dsyMatrix"),
                 c("dsCMatrix", "lsCMatrix"), c("dsCMatrix", "nsCMatrix"),
                 c("dspMatrix", "dsyMatrix"), c("dspMatrix", "lspMatrix"),
                 c("dsTMatrix", "dgeMatrix"), c("dsTMatrix", "dgTMatrix"),
                 c("dsTMatrix", "dsCMatrix"), c("dsTMatrix", "dsyMatrix"),
                 c("dsTMatrix", "lsTMatrix"), c("dsyMatrix", "dsCMatrix"),
                 c("dsyMatrix", "dspMatrix"), c("dsyMatrix", "dsTMatrix"),
                 c("dsyMatrix", "lsyMatrix"), c("dtCMatrix", "dgCMatrix"),
                 c("dtCMatrix", "dgeMatrix"), c("dtCMatrix", "dgTMatrix"),
                 c("dtCMatrix", "dsCMatrix"), c("dtCMatrix", "dtrMatrix"),
                 c("dtCMatrix", "dtTMatrix"), c("dtCMatrix", "ltCMatrix"),
                 c("dtCMatrix", "ntCMatrix"), c("dtpMatrix", "dtrMatrix"),
                 c("dtpMatrix", "dtTMatrix"), c("dtpMatrix", "ltpMatrix"),
                 c("dtrMatrix", "dtpMatrix"), c("dtrMatrix", "ltrMatrix"),
                 c("dtTMatrix", "dgeMatrix"), c("dtTMatrix", "dgTMatrix"),
                 c("dtTMatrix", "dtCMatrix"), c("dtTMatrix", "dtrMatrix"),
                 c("indMatrix", "ngeMatrix"), c("indMatrix", "ngTMatrix"),
                 c("lgCMatrix", "dgCMatrix"), c("lgCMatrix", "lgeMatrix"),
                 c("lgCMatrix", "lgTMatrix"), c("lgCMatrix", "ltCMatrix"),
                 c("lgeMatrix", "dgeMatrix"), c("lgeMatrix", "lgCMatrix"),
                 c("lgeMatrix", "lgTMatrix"), c("lgeMatrix", "lspMatrix"),
                 c("lgeMatrix", "lsyMatrix"), c("lgeMatrix", "ltpMatrix"),
                 c("lgeMatrix", "ltrMatrix"), c("lgTMatrix", "dgTMatrix"),
                 c("lgTMatrix", "lgCMatrix"), c("lgTMatrix", "lgeMatrix"),
                 c("lgTMatrix", "lsCMatrix"), c("lgTMatrix", "ltTMatrix"),
                 c("lMatrix", "dgCMatrix"), c("lsCMatrix", "dsCMatrix"),
                 c("lsCMatrix", "lgCMatrix"), c("lsCMatrix", "lgTMatrix"),
                 c("lsCMatrix", "lsTMatrix"), c("lspMatrix", "dspMatrix"),
                 c("lspMatrix", "lgeMatrix"), c("lspMatrix", "lsyMatrix"),
                 c("lsTMatrix", "lgCMatrix"), c("lsTMatrix", "lgTMatrix"),
                 c("lsTMatrix", "lsCMatrix"), c("lsTMatrix", "lsyMatrix"),
                 c("lsyMatrix", "dsyMatrix"), c("lsyMatrix", "lgeMatrix"),
                 c("lsyMatrix", "lspMatrix"), c("ltCMatrix", "lgCMatrix"),
                 c("ltCMatrix", "ltTMatrix"), c("ltpMatrix", "dtpMatrix"),
                 c("ltpMatrix", "lgeMatrix"), c("ltpMatrix", "ltrMatrix"),
                 c("ltrMatrix", "dtrMatrix"), c("ltrMatrix", "lgeMatrix"),
                 c("ltrMatrix", "ltpMatrix"), c("ltTMatrix", "dtTMatrix"),
                 c("ltTMatrix", "lgCMatrix"), c("ltTMatrix", "lgTMatrix"),
                 c("ltTMatrix", "ltCMatrix"), c("ltTMatrix", "ltrMatrix"),
                 ## c("matrix.coo", "dgCMatrix"), c("matrix.coo", "dgTMatrix"),
                 ## c("matrix.csc", "dgCMatrix"), c("matrix.csr", "dgCMatrix"),
                 ## c("matrix.csr", "dgRMatrix"),
                 ## c("matrix", "dgCMatrix"),
                 c("matrix", "dgeMatrix"), c("matrix", "dgRMatrix"),
                 c("matrix", "dgTMatrix"), c("matrix", "dsCMatrix"),
                 c("matrix", "dspMatrix"), c("matrix", "dsTMatrix"),
                 c("matrix", "dsyMatrix"), c("matrix", "dtCMatrix"),
                 c("matrix", "dtpMatrix"), c("matrix", "dtrMatrix"),
                 c("matrix", "dtTMatrix"), c("matrix", "lgCMatrix"),
                 c("matrix", "lgeMatrix"), c("matrix", "lgTMatrix"),
                 c("matrix", "lsCMatrix"), c("matrix", "lspMatrix"),
                 c("matrix", "lsyMatrix"), c("matrix", "ltCMatrix"),
                 c("matrix", "ltpMatrix"), c("matrix", "ltrMatrix"),
                 c("matrix", "ltTMatrix"), c("matrix", "ngCMatrix"),
                 c("matrix", "ngeMatrix"), c("matrix", "ngTMatrix"),
                 c("matrix", "nspMatrix"), c("matrix", "nsyMatrix"),
                 c("matrix", "ntCMatrix"), c("matrix", "ntpMatrix"),
                 c("matrix", "ntrMatrix"), c("matrix", "ntTMatrix"),
                 c("ngCMatrix", "dgCMatrix"), c("ngCMatrix", "lgCMatrix"),
                 c("ngCMatrix", "ntCMatrix"), c("ngeMatrix", "dgeMatrix"),
                 c("ngeMatrix", "lgeMatrix"), c("ngeMatrix", "ngCMatrix"),
                 c("ngeMatrix", "ngTMatrix"), c("ngeMatrix", "nspMatrix"),
                 c("ngeMatrix", "nsyMatrix"), c("ngeMatrix", "ntpMatrix"),
                 c("ngeMatrix", "ntrMatrix"), c("ngTMatrix", "dgTMatrix"),
                 c("ngTMatrix", "lgeMatrix"), c("ngTMatrix", "lgTMatrix"),
                 c("ngTMatrix", "ngCMatrix"), c("ngTMatrix", "ngeMatrix"),
                 c("ngTMatrix", "ntTMatrix"), c("nsCMatrix", "dsCMatrix"),
                 c("nsCMatrix", "lsCMatrix"), c("nsCMatrix", "ngCMatrix"),
                 c("nsCMatrix", "nsTMatrix"), c("nspMatrix", "dspMatrix"),
                 c("nspMatrix", "lspMatrix"), c("nspMatrix", "ngeMatrix"),
                 c("nspMatrix", "nsyMatrix"), c("nsTMatrix", "dsTMatrix"),
                 c("nsTMatrix", "ngCMatrix"), c("nsTMatrix", "ngTMatrix"),
                 c("nsTMatrix", "nsCMatrix"), c("nsTMatrix", "nsyMatrix"),
                 c("nsyMatrix", "dsyMatrix"), c("nsyMatrix", "lsyMatrix"),
                 c("nsyMatrix", "ngeMatrix"), c("nsyMatrix", "nspMatrix"),
                 c("ntCMatrix", "dtCMatrix"), c("ntCMatrix", "ltCMatrix"),
                 c("ntCMatrix", "ngCMatrix"), c("ntpMatrix", "dtpMatrix"),
                 c("ntpMatrix", "ltpMatrix"), c("ntpMatrix", "ngeMatrix"),
                 c("ntpMatrix", "ntrMatrix"), c("ntrMatrix", "dtrMatrix"),
                 c("ntrMatrix", "ltrMatrix"), c("ntrMatrix", "ngeMatrix"),
                 c("ntrMatrix", "ntpMatrix"), c("ntTMatrix", "dtTMatrix"),
                 c("ntTMatrix", "ngCMatrix"), c("ntTMatrix", "ngTMatrix"),
                 c("ntTMatrix", "ntCMatrix"), c("ntTMatrix", "ntrMatrix"),
                 c("numLike", "dgeMatrix"), c("RsparseMatrix", "dgeMatrix"))

.def.template <- function(from) {
    cd1 <- getClassDef(.FROM)
    cd2 <- getClassDef(.TO)
    Matrix.DeprecatedCoerce(cd1, cd2);
    to <- .CALL
    if(identical(as.character(class(to)), .TO))
        return(to)
    ## Coercion via virtual generated a _subclass_ of the target class
    to.strict <- new(.TO)
    for (nm in slotNames(cd2))
        slot(to.strict, nm) <- slot(to, nm)
    to.strict
}
for (.f.t in .from.to) {
    .f <- .f.t[1L]
    .t <- .f.t[2L]
    .def <- .def.template
    .env <- list(.FROM = .f, .TO = .t, .CALL = .as.via.virtual(.f, .t))
    body(.def) <- do.call(substitute, list(body(.def), .env))
    setAs(.f, .t, .def)
}
rm(.from.to, .f.t, .f, .t, .def.template, .def, .env)

setAs("CHMfactor", "Matrix",
      function(from) {
          if(FALSE) {
          .Deprecated(old = "as(<CHMfactor>, \"Matrix\")",
                      new = "expand1(., \"L\")",
                      package = "Matrix")
          }
          expand1(from, "L")
      })

setAs("CHMfactor", "dMatrix",
      function(from) {
          if(FALSE) {
          .Deprecated(old = "as(<CHMfactor>, \"dMatrix\")",
                      new = "expand1(., \"L\")",
                      package = "Matrix")
          }
          expand1(from, "L")
      })

setAs("CHMfactor", "dsparseMatrix",
      function(from) {
          if(FALSE) {
          .Deprecated(old = "as(<CHMfactor>, \"dsparseMatrix\")",
                      new = "expand1(., \"L\")",
                      package = "Matrix")
          }
          expand1(from, "L")
      })

setAs("CHMfactor", "sparseMatrix",
      function(from) {
          if(FALSE) {
          .Deprecated(old = "as(<CHMfactor>, \"sparseMatrix\")",
                      new = "expand1(., \"L\")",
                      package = "Matrix")
          }
          expand1(from, "L")
      })

setAs("CHMfactor", "CsparseMatrix",
      function(from) {
          if(FALSE) {
          .Deprecated(old = "as(<CHMfactor>, \"CsparseMatrix\")",
                      new = "expand1(., \"L\")",
                      package = "Matrix")
          }
          expand1(from, "L")
      })

setAs("CHMfactor", "RsparseMatrix",
      function(from) {
          if(FALSE) {
          .Deprecated(old = "as(<CHMfactor>, \"RsparseMatrix\")",
                      new = "as(expand1(., \"L\"), \"RsparseMatrix\")",
                      package = "Matrix")
          }
          as(expand1(from, "L"), "RsparseMatrix")
      })

setAs("CHMfactor", "TsparseMatrix",
      function(from) {
          if(FALSE) {
          .Deprecated(old = "as(<CHMfactor>, \"TsparseMatrix\")",
                      new = "as(expand1(., \"L\"), \"TsparseMatrix\")",
                      package = "Matrix")
          }
          as(expand1(from, "L"), "TsparseMatrix")
      })

setAs("CHMfactor", "triangularMatrix",
      function(from) {
          if(FALSE) {
          .Deprecated(old = "as(<CHMfactor>, \"triangularMatrix\")",
                      new = "as(expand1(., \"L\"), \"triangularMatrix\")",
                      package = "Matrix")
          }
          as(expand1(from, "L"), "triangularMatrix")
      })

setAs("CHMfactor", "pMatrix",
      function(from) {
          if(FALSE) {
          .Deprecated(old = "as(<CHMfactor>, \"pMatrix\")",
                      new = "expand1(., \"P1\")",
                      package = "Matrix")
          }
          expand1(from, "P1")
      })

setMethod("chol2inv", signature(x = "CHMfactor"),
          function(x, ...) {
              if(FALSE) {
              .Deprecated(old = "chol2inv(<CHMfactor>)",
                          new = "solve(.)",
                          package = "Matrix")
              }
              solve(x)
          })


## ~~~~ DEFUNCT ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

cBind <- function(..., deparse.level = 1)
    .Defunct(new = "cbind", package = "Matrix")
rBind <- function(..., deparse.level = 1)
    .Defunct(msg = "rbind", package = "Matrix")


## ~~~~ "MISCELLANEOUS" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.SuiteSparse_version <- function() {
    v <- .Call(get_SuiteSparse_version)
    package_version(list(major = v[1L], minor = paste(v[2:3], collapse = ".")))
}
