#ifndef MATRIX_LAPACK_ETC_H
#define MATRIX_LAPACK_ETC_H

/* Copy and paste from WRE : */

// before any R headers, or define in PKG_CPPFLAGS
#ifndef  USE_FC_LEN_T
# define USE_FC_LEN_T
#endif
#include <Rconfig.h>

# define usePR18534fix

#include <R_ext/Lapack.h>
#ifndef FCONE
# define FCONE
#endif

#endif /* MATRIX_LAPACK_ETC_H */
