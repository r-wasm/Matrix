				/* CHOLMOD factors */
#include "CHMfactor.h"

/**
 * Evaluate the logarithm of the square of the determinant of L
 *
 * @param f pointer to a CHMfactor object
 *
 * @return log(det(L)^2)
 *
 */
double chm_factor_ldetL2(CHM_FR f)
{
    int i, j, p;
    double ans = 0;

    if (f->is_super) {
	int *lpi = (int*)(f->pi), *lsup = (int*)(f->super);
	for (i = 0; i < f->nsuper; i++) { /* supernodal block i */
	    int nrp1 = 1 + lpi[i + 1] - lpi[i],
		nc = lsup[i + 1] - lsup[i];
	    double *x = (double*)(f->x) + ((int*)(f->px))[i];

	    for (R_xlen_t jn = 0, j = 0; j < nc; j++, jn += nrp1) { // jn := j * nrp1
		ans += 2 * log(fabs(x[jn]));
	    }
	}
    } else {
	int *li = (int*)(f->i), *lp = (int*)(f->p);
	double *lx = (double *)(f->x);

	for (j = 0; j < f->n; j++) {
	    for (p = lp[j]; li[p] != j && p < lp[j + 1]; p++) {};
	    if (li[p] != j) {
		error(_("diagonal element %d of Cholesky factor is missing"), j);
		break;		/* -Wall */
	    }
	    ans += log(lx[p] * ((f->is_ll) ? lx[p] : 1.));
	}
    }
    return ans;
}

/**
 * Update the numerical values in the factor f as A + mult * I, if A is
 * symmetric, otherwise AA' + mult * I
 *
 * @param f pointer to a CHM_FR object.  f is updated upon return.
 * @param A pointer to a CHM_SP object, possibly symmetric
 * @param mult multiple of the identity to be added to A or AA' before
 * decomposing.
 *
 * @note: A and f must be compatible.  There is no check on this
 * here.  Incompatibility of A and f will cause the CHOLMOD functions
 * to take an error exit.
 *
 */
CHM_FR chm_factor_update(CHM_FR f, CHM_SP A, double mult)
{
    int ll = f->is_ll;
    double mm[2] = {0, 0};
    mm[0] = mult;
    // NB: Result depends if A is "dsC" or "dgC"; the latter case assumes we mean AA' !!!
    if (!cholmod_factorize_p(A, mm, (int*)NULL, 0 /*fsize*/, f, &c))
	/* -> ./CHOLMOD/Cholesky/cholmod_factorize.c */
	error(_("cholmod_factorize_p failed: status %d, minor %d of ncol %d"),
	      c.status, f->minor, f->n);
    if (f->is_ll != ll)
	if(!cholmod_change_factor(f->xtype, ll, f->is_super, 1 /*to_packed*/,
				  1 /*to_monotonic*/, f, &c))
	    error(_("cholmod_change_factor failed"));
    return f;
}

/* MJ: unused or no longer needed, with replacement
   in ./factorizations.c or in ../R/factorizations.R
*/
#if 0

SEXP CHMfactor_to_sparse(SEXP x)
{
    CHM_FR L = AS_CHM_FR(x), Lcp;
    CHM_SP Lm;
    R_CheckStack();

    /* cholmod_factor_to_sparse changes its first argument. Make a copy */
    Lcp = cholmod_copy_factor(L, &c);
    if (!(Lcp->is_ll))
	if (!cholmod_change_factor(Lcp->xtype, 1, 0, 1, 1, Lcp, &c))
	    error(_("cholmod_change_factor failed with status %d"), c.status);
    Lm = cholmod_factor_to_sparse(Lcp, &c); cholmod_free_factor(&Lcp, &c);

    SEXP dimnames = PROTECT(GET_SLOT(x, Matrix_DimNamesSym)),
	res = PROTECT(chm_sparse_to_SEXP(
			  Lm, 1 /* dofree */, -1 /* uploT */, 0 /* Rkind */,
			  "N" /* diag */, dimnames /* dn */));
    UNPROTECT(2);
    return res;
}

SEXP CHMfactor_solve(SEXP a, SEXP b, SEXP system)
{
    CHM_FR L = AS_CHM_FR(a);
    SEXP bb = PROTECT(dense_as_general(b, 'd', 2, 0));
    CHM_DN B = AS_CHM_DN(bb), X;
    int sys = asInteger(system);
    R_CheckStack();

    if (!(sys--))		/* align with CHOLMOD defs: R's {1:9} --> {0:8},
				   see ./CHOLMOD/Cholesky/cholmod_solve.c */
	error(_("system argument is not valid"));

    X = cholmod_solve(sys, L, B, &c);
    SEXP ans = chm_dense_to_SEXP(X, 1/*do_free*/, 0/*Rkind*/,
				 GET_SLOT(bb, Matrix_DimNamesSym), FALSE);
    UNPROTECT(1);
    return ans;
}

SEXP CHMfactor_spsolve(SEXP a, SEXP b, SEXP system)
{
    CHM_FR L = AS_CHM_FR(a);
    CHM_SP B = AS_CHM_SP__(b);
    int sys = asInteger(system);
    R_CheckStack();

    if (!(sys--))		/* align with CHOLMOD defs: R's {1:9} --> {0:8},
				   see ./CHOLMOD/Cholesky/cholmod_solve.c */
	error(_("system argument is not valid"));

    // dimnames:
    SEXP dn = PROTECT(allocVector(VECSXP, 2));
    // none from a: our CHMfactor objects have no dimnames
    SET_VECTOR_ELT(dn, 1, duplicate(VECTOR_ELT(GET_SLOT(b, Matrix_DimNamesSym), 1)));
    SEXP ans = chm_sparse_to_SEXP(cholmod_spsolve(sys, L, B, &c),
				  1/*do_free*/, 0/*uploT*/, 0/*Rkind*/, "", dn);
    UNPROTECT(1);
    return ans;
}

SEXP CHMfactor_updown(SEXP upd, SEXP C_, SEXP L_)
{
    CHM_FR L = AS_CHM_FR(L_), Lcp;
    CHM_SP C = AS_CHM_SP__(C_);
    int update = asInteger(upd);
    R_CheckStack();

    Lcp = cholmod_copy_factor(L, &c);
    int r = cholmod_updown(update, C, Lcp, &c);
    if(!r) error(_("cholmod_updown() returned %d"), r);
    return chm_factor_to_SEXP(Lcp, 1);
}

SEXP CHMfactor_ldetL2(SEXP x)
{
    CHM_FR L = AS_CHM_FR(x); R_CheckStack();

    return ScalarReal(chm_factor_ldetL2(L));
}

// called from R   .updateCHMfactor(object, parent, mult)
SEXP CHMfactor_update(SEXP object, SEXP parent, SEXP mult)
{
    CHM_FR L = AS_CHM_FR(object), Lcp;
    CHM_SP A = AS_CHM_SP__(parent);
    R_CheckStack();
    
    Lcp = cholmod_copy_factor(L, &c);
    Lcp = chm_factor_update(Lcp, A, asReal(mult));

    SEXP res = PROTECT(chm_factor_to_SEXP(Lcp, 1)),
	dimnames = PROTECT(GET_SLOT(object, Matrix_DimNamesSym));
    SET_SLOT(res, Matrix_DimNamesSym, dimnames);
    UNPROTECT(2);
    return res;
}

// update its argument *in place*  <==> "destructive" <==> use with much caution!
SEXP destructive_CHM_update(SEXP object, SEXP parent, SEXP mult)
{
    CHM_FR L = AS_CHM_FR(object);
    CHM_SP A = AS_CHM_SP__(parent);
    R_CheckStack();

    chm_factor_update(L, A, asReal(mult));
    return R_NilValue;

}

SEXP CHMfactor_ldetL2up(SEXP x, SEXP parent, SEXP mult)
{
    SEXP ans = PROTECT(duplicate(mult));
    int i, nmult = LENGTH(mult);
    double *aa = REAL(ans), *mm = REAL(mult);
    CHM_FR L = AS_CHM_FR(x), Lcp;
    CHM_SP A = AS_CHM_SP__(parent);
    R_CheckStack();

    Lcp = cholmod_copy_factor(L, &c);
    for (i = 0; i < nmult; i++)
	aa[i] = chm_factor_ldetL2(chm_factor_update(Lcp, A, mm[i]));
    cholmod_free_factor(&Lcp, &c);
    UNPROTECT(1);
    return ans;
}

#endif /* MJ */
