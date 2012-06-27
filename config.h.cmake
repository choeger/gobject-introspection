/* The size of `boolean', as computed by sizeof. */
#cmakedefine SIZEOF_BOOLEAN @SIZEOF_BOOLEAN@

/* The size of `char', as computed by sizeof. */
#cmakedefine SIZEOF_CHAR @SIZEOF_CHAR@

/* The size of `double', as computed by sizeof. */
#cmakedefine SIZEOF_DOUBLE @SIZEOF_DOUBLE@

/* The size of `float', as computed by sizeof. */
#cmakedefine SIZEOF_FLOAT @SIZEOF_FLOAT@

/* The size of `int', as computed by sizeof. */
#cmakedefine SIZEOF_INT  @SIZEOF_INT@

/* The size of `long', as computed by sizeof. */
#cmakedefine SIZEOF_LONG @SIZEOF_LONG@

/* The size of `long double', as computed by sizeof. */
#cmakedefine SIZEOF_LONG_DOUBLE @SIZEOF_LONG_DOUBLE@

/* The size of a `long double', as computed by sizeof. */
#cmakedefine SIZEOF_LONG_FLOAT @SIZEOF_LONG_FLOAT@

/* The size of `long long', as computed by sizeof. */
#cmakedefine SIZEOF_LONG_LONG @SIZEOF_LONG_LONG@

/* The size of `short', as computed by sizeof. */
#cmakedefine SIZEOF_SHORT @SIZEOF_SHORT@

/* The size of `unsigned char', as computed by sizeof. */
#cmakedefine SIZEOF_UNSIGNED_CHAR @SIZEOF_UNSIGNED_CHAR@

/* The size of `unsigned int', as computed by sizeof. */
#cmakedefine SIZEOF_UNSIGNED_INT @SIZEOF_UNSIGNED_INT@

/* The size of `unsigned long', as computed by sizeof. */
#cmakedefine SIZEOF_UNSIGNED_LONG @SIZEOF_UNSIGNED_LONG@

/* The size of `unsigned long long', as computed by sizeof. */
#cmakedefine SIZEOF_UNSIGNED_LONG_LONG @SIZEOF_UNSIGNED_LONG_LONG@

/* The size of `unsigned short', as computed by sizeof. */
#cmakedefine SIZEOF_UNSIGNED_SHORT @SIZEOF_UNSIGNED_SHORT@

/* The size of `void *', as computed by sizeof. */
#cmakedefine SIZEOF_VOID_P @SIZEOF_VOID_P@
#cmakedefine GIR_SUFFIX "@GIR_SUFFIX@"

#cmakedefine GIR_DIR "@GIR_DIR@"

#cmakedefine SHLIB_SUFFIX "@SHLIB_SUFFIX@"


#ifdef USE_DL_IMPORT
#define DL_IMPORT(RTYPE) __declspec(dllimport) RTYPE
#define DL_EXPORT(RTYPE) __declspec(dllexport) RTYPE
#endif
#ifdef USE_DL_EXPORT
#define DL_IMPORT(RTYPE) __declspec(dllexport) RTYPE
#define DL_EXPORT(RTYPE) __declspec(dllexport) RTYPE
#endif