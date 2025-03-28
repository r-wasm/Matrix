#ifndef MATRIX_SUBSCRIPT_H
#define MATRIX_SUBSCRIPT_H

#include "Mutils.h"

/* defined in ./sparse.c : */
SEXP CRsparse_as_Tsparse(SEXP);
SEXP Tsparse_as_CRsparse(SEXP, SEXP);
SEXP R_sparse_as_general(SEXP);
SEXP R_sparse_force_symmetric(SEXP, SEXP);

SEXP R_subscript_1ary    (SEXP x, SEXP i);
SEXP R_subscript_1ary_mat(SEXP x, SEXP i);
SEXP R_subscript_2ary    (SEXP x, SEXP i, SEXP j);

#endif
