# MSVC ARM64 seaf-daemon. Links the vcpkg overlay libsearpc
# (.github/vcpkg-ports/libsearpc). SEAFILE_ROOT defaults to this repo;
# override with -DSEAFILE_ROOT= if the sources live elsewhere.

cmake_minimum_required(VERSION 3.16)
project(seaf-daemon C)

if(NOT SEAFILE_ROOT)
  get_filename_component(SEAFILE_ROOT "${CMAKE_CURRENT_LIST_DIR}/../../.." ABSOLUTE)
endif()

if(MSVC)
  set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreadedDLL")
endif()

find_package(PkgConfig REQUIRED)
pkg_check_modules(GLIB REQUIRED IMPORTED_TARGET glib-2.0 gobject-2.0)
pkg_check_modules(JANSSON REQUIRED IMPORTED_TARGET jansson)
pkg_check_modules(SQLITE REQUIRED IMPORTED_TARGET sqlite3)
pkg_check_modules(CURL REQUIRED IMPORTED_TARGET libcurl)
pkg_check_modules(OPENSSL REQUIRED IMPORTED_TARGET openssl)
pkg_check_modules(ZLIB REQUIRED IMPORTED_TARGET zlib)

# MSVC libwebsockets does not install a .pc (only UNIX/MINGW). vcpkg's
# arm64-windows triplet is shared, so the imported target is websockets_shared.
find_package(libwebsockets CONFIG REQUIRED)

pkg_check_modules(LIBEVENT IMPORTED_TARGET libevent)
if(NOT LIBEVENT_FOUND)
  pkg_check_modules(LIBEVENT IMPORTED_TARGET libevent_core)
endif()
if(NOT LIBEVENT_FOUND)
  find_package(Libevent CONFIG REQUIRED)
endif()

find_path(SEARPC_INCLUDE_DIR NAMES searpc.h REQUIRED)
find_library(SEARPC_LIBRARY NAMES searpc libsearpc REQUIRED)
find_path(GETOPT_INCLUDE_DIR NAMES getopt.h REQUIRED)
find_library(GETOPT_LIBRARY NAMES getopt REQUIRED)
find_path(PTHREAD_INCLUDE_DIR NAMES pthread.h REQUIRED)
find_library(PTHREAD_LIBRARY NAMES pthreadVC3 pthread REQUIRED)

configure_file(
  "${CMAKE_CURRENT_LIST_DIR}/config.windows.h"
  "${CMAKE_CURRENT_BINARY_DIR}/config.h"
  COPYONLY
)

set(SEAF_DAEMON_SOURCES
  "${SEAFILE_ROOT}/daemon/seaf-daemon.c"
  "${SEAFILE_ROOT}/daemon/job-mgr.c"
  "${SEAFILE_ROOT}/daemon/timer.c"
  "${SEAFILE_ROOT}/daemon/cevent.c"
  "${SEAFILE_ROOT}/daemon/http-tx-mgr.c"
  "${SEAFILE_ROOT}/daemon/vc-utils.c"
  "${SEAFILE_ROOT}/daemon/sync-mgr.c"
  "${SEAFILE_ROOT}/daemon/seafile-session.c"
  "${SEAFILE_ROOT}/daemon/wt-monitor.c"
  "${SEAFILE_ROOT}/daemon/wt-monitor-win32.c"
  "${SEAFILE_ROOT}/daemon/wt-monitor-structs.c"
  "${SEAFILE_ROOT}/daemon/clone-mgr.c"
  "${SEAFILE_ROOT}/daemon/seafile-config.c"
  "${SEAFILE_ROOT}/daemon/seafile-error.c"
  "${SEAFILE_ROOT}/daemon/repo-mgr.c"
  "${SEAFILE_ROOT}/daemon/sync-status-tree.c"
  "${SEAFILE_ROOT}/daemon/filelock-mgr.c"
  "${SEAFILE_ROOT}/daemon/set-perm.c"
  "${SEAFILE_ROOT}/daemon/change-set.c"
  "${SEAFILE_ROOT}/daemon/notif-mgr.c"
  "${SEAFILE_ROOT}/common/seafile-crypt.c"
  "${SEAFILE_ROOT}/common/diff-simple.c"
  "${SEAFILE_ROOT}/common/branch-mgr.c"
  "${SEAFILE_ROOT}/common/fs-mgr.c"
  "${SEAFILE_ROOT}/common/commit-mgr.c"
  "${SEAFILE_ROOT}/common/log.c"
  "${SEAFILE_ROOT}/common/rpc-service.c"
  "${SEAFILE_ROOT}/common/vc-common.c"
  "${SEAFILE_ROOT}/common/obj-store.c"
  "${SEAFILE_ROOT}/common/obj-backend-fs.c"
  "${SEAFILE_ROOT}/common/block-mgr.c"
  "${SEAFILE_ROOT}/common/block-backend.c"
  "${SEAFILE_ROOT}/common/block-backend-fs.c"
  "${SEAFILE_ROOT}/common/mq-mgr.c"
  "${SEAFILE_ROOT}/common/curl-init.c"
  "${SEAFILE_ROOT}/common/cdc/cdc.c"
  "${SEAFILE_ROOT}/common/cdc/rabin-checksum.c"
  "${SEAFILE_ROOT}/common/index/index.c"
  "${SEAFILE_ROOT}/common/index/cache-tree.c"
  "${SEAFILE_ROOT}/lib/repo.c"
  "${SEAFILE_ROOT}/lib/task.c"
  "${SEAFILE_ROOT}/lib/net.c"
  "${SEAFILE_ROOT}/lib/utils.c"
  "${SEAFILE_ROOT}/lib/db.c"
)

add_executable(seaf-daemon ${SEAF_DAEMON_SOURCES})

target_include_directories(seaf-daemon PRIVATE
  "${CMAKE_CURRENT_BINARY_DIR}"
  "${SEAFILE_ROOT}"
  "${SEAFILE_ROOT}/include"
  "${SEAFILE_ROOT}/lib"
  "${SEAFILE_ROOT}/common"
  "${SEAFILE_ROOT}/daemon"
  "${SEARPC_INCLUDE_DIR}"
  "${GETOPT_INCLUDE_DIR}"
  "${PTHREAD_INCLUDE_DIR}"
)

target_compile_definitions(seaf-daemon PRIVATE
  WIN32
  _WINDOWS
  WIN32_LEAN_AND_MEAN
  SEAFILE_CLIENT
  HAVE_CONFIG_H
  PACKAGE_VERSION="9.0.3"
  _CRT_SECURE_NO_WARNINGS
  _WINSOCK_DEPRECATED_NO_WARNINGS
  HAVE_STRUCT_TIMESPEC
  VALA_EXTERN=extern
)

if(MSVC)
  target_compile_options(seaf-daemon PRIVATE /utf-8 /W1 /wd4996 /wd4244 /wd4267)
endif()

set(_seaf_event_lib)
if(TARGET PkgConfig::LIBEVENT)
  set(_seaf_event_lib PkgConfig::LIBEVENT)
elseif(TARGET libevent::core)
  set(_seaf_event_lib libevent::core)
elseif(TARGET unofficial::libevent::libevent)
  set(_seaf_event_lib unofficial::libevent::libevent)
else()
  message(FATAL_ERROR "libevent not found (pkg-config or CMake config)")
endif()

target_link_libraries(seaf-daemon PRIVATE
  "${SEARPC_LIBRARY}"
  PkgConfig::GLIB
  PkgConfig::JANSSON
  PkgConfig::SQLITE
  PkgConfig::CURL
  PkgConfig::OPENSSL
  PkgConfig::ZLIB
  websockets_shared
  ${_seaf_event_lib}
  "${GETOPT_LIBRARY}"
  "${PTHREAD_LIBRARY}"
  ws2_32
  crypt32
  rpcrt4
  psapi
  shell32
  advapi32
  shlwapi
)

set_target_properties(seaf-daemon PROPERTIES
  OUTPUT_NAME seaf-daemon
  RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
  RUNTIME_OUTPUT_DIRECTORY_RELEASE "${CMAKE_BINARY_DIR}/bin"
  RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO "${CMAKE_BINARY_DIR}/bin"
  RUNTIME_OUTPUT_DIRECTORY_DEBUG "${CMAKE_BINARY_DIR}/bin"
)
