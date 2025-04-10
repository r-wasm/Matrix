## METHODS FOR CLASS: RsparseMatrix (virtual)
## sparse matrices in compressed sparse row (CSR) format
## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


setReplaceMethod("[", signature(x = "RsparseMatrix", i = "index", j = "missing",
				value = "replValue"),
		 function (x, i, j, ..., value)
		 replTmat(.CR2T(x), i=i, , value=value))

setReplaceMethod("[", signature(x = "RsparseMatrix", i = "missing", j = "index",
				value = "replValue"),
		 function (x, i, j, ..., value)# extra " , ": want nargs() == 4
		 replTmat(.CR2T(x), , j=j, value=value))

setReplaceMethod("[", signature(x = "RsparseMatrix", i = "index", j = "index",
				value = "replValue"),
		 function (x, i, j, ..., value)
		 replTmat(.CR2T(x), i=i, j=j, value=value))

setReplaceMethod("[", signature(x = "RsparseMatrix", i = "index", j = "missing",
				value = "sparseVector"),
		 function (x, i, j, ..., value) {
                     if(nargs() == 3L)
                         replTmat(.CR2T(x), i=i, value=value) # x[i] <- v
                     else replTmat(.CR2T(x), i=i, , value=value) # x[i, ] <- v
                 })

setReplaceMethod("[", signature(x = "RsparseMatrix", i = "missing", j = "index",
				value = "sparseVector"),
		 function (x, i, j, ..., value)# extra " , ": want nargs() == 4
		 replTmat(.CR2T(x), , j=j, value=value))

setReplaceMethod("[", signature(x = "RsparseMatrix", i = "index", j = "index",
				value = "sparseVector"),
		 function (x, i, j, ..., value)
		 replTmat(.CR2T(x), i=i, j=j, value=value))


setReplaceMethod("[", signature(x = "RsparseMatrix", i = "matrix", j = "missing",
				value = "replValue"),
                 function (x, i, j, ..., value) {
                     if(nargs() == 3L)
                         .TM.repl.i.mat(.CR2T(x), i=i, value=value)
                     else replTmat(.CR2T(x), i=as.vector(i), , value=value)
                 })
