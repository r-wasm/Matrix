####--------- Test interfaces to other non-standard Packages ---------------

## for R_DEFAULT_PACKAGES=NULL :
library(grDevices)
library(stats)
library(utils)

library(Matrix)
source(system.file("test-tools.R", package = "Matrix"))# identical3() etc
MatrixRversion <- pkgRversion("Matrix")


###-- 1)  'graph' (from Bioconductor) ---------------------------
###-- ==  =======                     ---------------------------

if(requireNamespace("graph")) {

    if(packageVersion("graph") <= "1.10.2") {

    ## graph 1.10.x for x <= 2 had too many problems  as(<graph>, "matrix")
    cat("Version of 'graph' is too old --- no tests done here!\n")

    } else if(pkgRversion("graph") != MatrixRversion) {

    cat(sprintf("The R version (%s) of 'graph' installation differs from the Matrix one (%s)\n",
                pkgRversion("graph"), MatrixRversion))

    } else { ## do things

    if(doPdf <- !dev.interactive(orNone = TRUE))
        pdf("other-pkgs-graph.pdf")

    ## 0) Simplest non-trivial graph: has no weights:
    g0 <- graph::graphNEL(paste(1:2), edgeL=list("1"="2"), "directed")
    m0 <- as(g0, "Matrix")
    stopifnot(is(m0,"ngCMatrix"), dim(m0) == c(2,2), which(m0) == 3)
    g. <- as(m0, "graph") ## failed in Matrix <= 1.1-0
    m. <- as(g., "Matrix")
    stopifnot( identical(m., m0) ) ## but (g0, g.) differ: the latter has '1' weights

    ## 1) undirected

    V <- LETTERS[1:4]
    edL <- vector("list", length=4)
    names(edL) <- V
    ## 1a) unweighted
    for(i in 1:4)
        edL[[i]] <- list(edges = 5-i)
    gR <- new("graphNEL", nodes=V, edgeL=edL)
    str(graph::edges(gR))
    sm.g <- as(gR, "sparseMatrix")
    str(sm.g) ## dgC: TODO: want 'ds.' (symmetric)
    validObject(sm.g)
    show( sm.g )## (incl colnames !)

    ## 1b) weighted
    set.seed(123)
    for(i in 1:4)
        edL[[i]] <- list(edges = 5-i, weights=runif(1))
    gRw <- new("graphNEL", nodes=V, edgeL=edL)
    str(graph::edgeWeights(gRw))
    sm.gw <- as(gRw, "sparseMatrix")
    str(sm.gw) ## *numeric* dgCMatrix
    validObject(sm.gw)
    show( sm.gw )## U[0,1] numbers in anti-diagonal

    ## 2) directed
    gU <- gR; graph::edgemode(gU) <- "directed"
    sgU <- as(gU, "sparseMatrix")
    str(sgU) ## 'dgC'
    validObject(sgU)
    show( sgU )

    ## Reverse :  sparseMatrix -> graph
    sm.g[1,2] <- TRUE
    gmg  <-  as(sm.g, "graph")
    validObject(gmg2 <-  as(sm.g, "graphNEL"))
    gmgw <-  as(sm.gw, "graph")
    validObject(gmgw2 <- as(sm.gw, "graphNEL"))
    gmgU <-  as(sgU, "graph")
    validObject(gmgU2 <- as(sgU, "graphNEL"))
    stopifnot(identical(gmg, gmg2),
              identical(gmgw, gmgw2),
              identical(gmgU, gmgU2))

    data(CAex, package = "Matrix")
    cc <- crossprod(CAex)
    ## work around bug in 'graph': diagonal must be empty:
    diag(cc) <- 0; cc <- drop0(cc)
    image(cc)
    gg <- as(cc, "graph")

    ## Don't run on CRAN and don't trigger 'R CMD check' :
    if(doExtras && match.fun("requireNamespace")("Rgraphviz"))
        get("plot", asNamespace("Rgraphviz"), mode = "function")(gg, "circo")

    stopifnot(all.equal(graph::edgeMatrix(gg),
                        rbind(from = c(rep(1:24, each=2), 25:48),
                              to   = c(rbind(25:48,49:72), 49:72))))

    if(doPdf)
        dev.off()

    } # {else}

} # end{graph}


###-- 2)  'SparseM' ---------------------------------------------
###-- ==  ========= ---------------------------------------------

if(requireNamespace("SparseM")) {

    if(pkgRversion("SparseM") != MatrixRversion) {

    cat(sprintf("The R version (%s) of 'SparseM' installation differs from the Matrix one (%s)\n",
                pkgRversion("SparseM"), MatrixRversion))

    } else { ## do things

	set.seed(1)
	a <- round(rnorm(5*4), 2)
	a[abs(a) < 0.7] <- 0
	A <- matrix(a,5,4)
	print(M <- Matrix(A))
	stopifnot(
            validObject(A.csr <- SparseM::as.matrix.csr(A)),
            validObject(At.csr <- SparseM::as.matrix.csr(t(A))),
            validObject(A.csc <- SparseM::as.matrix.csc(A)),
            identical(At.csr, t(A.csr)),
            identical(A, as.matrix(A.csr)),
            identical(A.csr, as(M, "matrix.csr")),
            identical(A.csc, as(M, "matrix.csc")),
            identical3(M, as(A.csr, "CsparseMatrix"), as(A.csr, "dgCMatrix")),
            identical(t(M), as(At.csr, "CsparseMatrix"))
            )

	## More tests, notably for triplets
	A.coo <- SparseM::as.matrix.coo(A)
	str(T  <- as(M, "TsparseMatrix")) # has 'j' sorted
	str(T. <- as(A.coo, "TsparseMatrix")) # has 'i' sorted

	T3 <- as(as(T, "matrix.coo"), "Matrix") # dgT
	M3 <- as(A.csr,               "Matrix") # dgC
	M4 <- as(A.csc,               "Matrix") # dgC
	M5 <- as(as(M, "matrix.coo"), "Matrix") # dgT
	uniqT <- uniqTsparse
	stopifnot(identical4(uniqT(T), uniqT(T.), uniqT(T3), uniqT(M5)),
		  identical3(M, M3, M4))

    } # {else}

} # end{SparseM}
