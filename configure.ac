dnl Process this file with autoconf to produce a configure script.
AC_PREREQ([2.69])
AC_INIT([seafile], [9.0.3], [info@seafile.com])
AC_CONFIG_HEADERS([config.h])
AC_CONFIG_MACRO_DIRS([m4])

AM_INIT_AUTOMAKE([-Wall foreign])

# Required by automake >= 1.13 to silence the "non-POSIX archiver" warning
# when building libtool convenience libraries (libcdc.la, libindex.la, ...).
AM_PROG_AR

# Checks for programs.
AC_PROG_CC
AC_PROG_MAKE_SET
LT_INIT

# Vala compiler check
AM_PROG_VALAC([], [], [AC_MSG_ERROR([*** Unable to find Vala compiler])])

# Checks for headers and library functions.
AC_SYS_LARGEFILE

# Checks for library functions.
AC_CHECK_FUNCS([alarm dup2 ftruncate getcwd gethostbyname gettimeofday memmove memset mkdir rmdir select setlocale socket strcasecmp strchr strdup strrchr strstr strtol uname utime strtok_r sendfile])

# Canonicalize host and build
AC_CANONICAL_HOST
AC_CANONICAL_BUILD

# Determine OS-specific settings
AC_MSG_CHECKING([for Windows (mingw32/mingw64)])
if test "$host_os" = "mingw32" -o "$host_os" = "mingw64"; then
  MINGW32=yes
  AC_MSG_RESULT([yes])
else
  MINGW32=no
  AC_MSG_RESULT([no])
fi

AC_MSG_CHECKING([for macOS])
if test "$(uname)" = "Darwin"; then
  MACOS=yes
  AC_MSG_RESULT([yes])
else
  MACOS=no
  AC_MSG_RESULT([no])
fi

AC_MSG_CHECKING([for Linux])
if test "$MACOS" != "yes" -a "$MINGW32" != "yes"; then
  LINUX=yes
  AC_MSG_RESULT([yes])
else
  LINUX=no
  AC_MSG_RESULT([no])
fi

AM_CONDITIONAL([WIN32], [test "$MINGW32" = "yes"])
AM_CONDITIONAL([MACOS], [test "$MACOS" = "yes"])
AM_CONDITIONAL([LINUX], [test "$LINUX" = "yes"])

# Library checks
AC_CHECK_LIB([c], [uuid_generate], [], [AC_CHECK_LIB([uuid], [uuid_generate], [], [AC_MSG_ERROR([*** Unable to find uuid_generate])])])
AC_CHECK_LIB([pthread], [pthread_create], [], [AC_MSG_ERROR([*** Unable to find pthread library])])
AC_CHECK_LIB([sqlite3], [sqlite3_open], [], [AC_MSG_ERROR([*** Unable to find sqlite3 library])])

# Compiler and linker flags
if test "$MINGW32" = "yes"; then
  # The daemon is a GUI-subsystem binary so no console window appears, but its
  # entry point has to stay the console CRT startup so main() still runs. That
  # symbol carries a leading underscore on i386 and none on x86_64. Getting it
  # wrong is not a link error: ld only warns ("cannot find entry symbol") and
  # then points the entry at the start of .text, so the CRT never initialises,
  # main() never runs, and the binary exits immediately with a garbage code.
  case "$host_cpu" in
    x86_64) CRT_ENTRY_SYMBOL=mainCRTStartup ;;
    *)      CRT_ENTRY_SYMBOL=_mainCRTStartup ;;
  esac
  CONSOLE="-Wl,--subsystem,windows -Wl,--entry,$CRT_ENTRY_SYMBOL"
  LIB_WS32=-lws2_32
  LIB_GDI32=-lgdi32
  LIB_INTL=-lintl
  LIB_UUID=-lRpcrt4
  LIB_IPHLPAPI=-liphlpapi
  LIB_SHELL32=-lshell32
  LIB_PSAPI=-lpsapi
  MSVC_CFLAGS="-D__MSVCRT__ -D__MSVCRT_VERSION__=0x0601"
  LIB_CRYPT32=-lcrypt32
else
  CONSOLE=""
  LIB_WS32=""
  LIB_GDI32=""
  LIB_INTL=""
  LIB_RESOLV="-lresolv"
  if test "$MACOS" = "yes"; then
    LIB_UUID=""
    LIB_IPHLPAPI=""
    LIB_SHELL32=""
    LIB_PSAPI=""
    LIB_MAC="-framework CoreServices"
    LIB_ICONV="-liconv"
    LIB_CRYPT32=""
  else
    LIB_UUID="-luuid"
    LIB_IPHLPAPI=""
    LIB_SHELL32=""
    LIB_PSAPI=""
    LIB_MAC=""
    LIB_CRYPT32=""
    LIB_RESOLV="-lresolv"
  fi
fi

AC_SUBST([CONSOLE])
AC_SUBST([LIB_WS32])
AC_SUBST([LIB_GDI32])
AC_SUBST([LIB_INTL])
AC_SUBST([LIB_RESOLV])
AC_SUBST([LIB_UUID])
AC_SUBST([LIB_IPHLPAPI])
AC_SUBST([LIB_SHELL32])
AC_SUBST([LIB_PSAPI])
AC_SUBST([LIB_MAC])
AC_SUBST([MSVC_CFLAGS])
AC_SUBST([LIB_CRYPT32])
AC_SUBST([LIB_ICONV])

# Pkg-config checks
LIBEVENT_REQUIRED=2.0
GLIB_REQUIRED=2.16.0
SEARPC_REQUIRED=1.0
JANSSON_REQUIRED=2.2.1
CURL_REQUIRED=7.17
ZLIB_REQUIRED=1.2.0
GNUTLS_REQUIRED=3.3.0

PKG_CHECK_MODULES([GLIB2], [glib-2.0 >= $GLIB_REQUIRED])
PKG_CHECK_MODULES([GOBJECT], [gobject-2.0 >= $GLIB_REQUIRED])
PKG_CHECK_MODULES([SEARPC], [libsearpc >= $SEARPC_REQUIRED])
PKG_CHECK_MODULES([JANSSON], [jansson >= $JANSSON_REQUIRED])
PKG_CHECK_MODULES([LIBEVENT], [libevent >= $LIBEVENT_REQUIRED])
PKG_CHECK_MODULES([ZLIB], [zlib >= $ZLIB_REQUIRED])
PKG_CHECK_MODULES([CURL], [libcurl >= $CURL_REQUIRED])

if test "$MINGW32" != "yes"; then
  PKG_CHECK_MODULES([LIBEVENT_PTHREADS], [libevent_pthreads >= $LIBEVENT_REQUIRED])
fi

if test "$LINUX" != "yes"; then
  PKG_CHECK_MODULES([WS], [libwebsockets])
fi

AC_ARG_WITH([python3], [AS_HELP_STRING([--with-python3], [use python3])], [with_python3="yes"], [with_python3="no"])
if test "$with_python3" = "yes"; then
  AM_PATH_PYTHON([3.5])
else
  AM_PATH_PYTHON([2.7])
fi

# Breakpad support
BPWRAPPER_REQUIRED=0.1
AC_ARG_ENABLE(breakpad, AS_HELP_STRING([--enable-breakpad], [build google breakpad support]), [compile_breakpad=$enableval], [compile_breakpad="no"])
AM_CONDITIONAL([HAVE_BREAKPAD_SUPPORT], [test "$compile_breakpad" = "yes"])
if test "$compile_breakpad" = "yes"; then
  PKG_CHECK_MODULES([BPWRAPPER], [bpwrapper])
  AC_DEFINE([HAVE_BREAKPAD_SUPPORT], 1, [Breakpad support enabled])
fi

# Crypto libraries
AC_ARG_WITH([gpl-crypto], [AS_HELP_STRING([--with-gpl-crypto=[yes|no]], [Use GPL compatible crypto libraries. Default no.])], [gpl_crypto=$withval], [gpl_crypto="no"])
if test "xyes" = "x$gpl_crypto"; then
  PKG_CHECK_MODULES([GNUTLS], [gnutls >= $GNUTLS_REQUIRED])
  PKG_CHECK_MODULES([NETTLE], [nettle])
  AC_DEFINE([USE_GPL_CRYPTO], 0, [Use GPL-compatible crypto libraries])
else
  AC_CHECK_LIB([crypto], [SHA1_Init], [], [AC_MSG_ERROR([*** Unable to find openssl crypto library])])
  PKG_CHECK_MODULES([SSL], [openssl])
fi

# Compile universal binaries
AC_ARG_ENABLE([compile-universal], [AS_HELP_STRING([--enable-compile-universal], [compile seafile universal binaries (if supported)])], [compile_universal=${enableval}], [compile_universal="no"])
AM_CONDITIONAL([COMPILE_UNIVERSAL], [test "$compile_universal" = "yes"])

# Output files
AC_CONFIG_FILES([
    Makefile
    include/Makefile
    lib/Makefile
    lib/libseafile.pc
    common/Makefile
    common/cdc/Makefile
    common/index/Makefile
    daemon/Makefile
    app/Makefile
    doc/Makefile
    python/Makefile
    python/seafile/Makefile
])

AC_OUTPUT