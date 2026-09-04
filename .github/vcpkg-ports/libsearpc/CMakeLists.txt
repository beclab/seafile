# haiwen/libsearpc has autotools + a Win32/x64-only vcxproj, no CMake and no
# ARM64. This wrapper is copied over the extracted sources by the overlay port.
cmake_minimum_required(VERSION 3.16)
project(libsearpc C)

find_package(PkgConfig REQUIRED)
pkg_check_modules(GLIB REQUIRED IMPORTED_TARGET glib-2.0 gobject-2.0)
pkg_check_modules(JANSSON REQUIRED IMPORTED_TARGET jansson)

add_library(libsearpc SHARED
  lib/searpc-client.c
  lib/searpc-server.c
  lib/searpc-utils.c
  lib/searpc-named-pipe-transport.c
)
target_include_directories(libsearpc PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/lib>
)
target_compile_definitions(libsearpc PRIVATE LIBSEARPC_EXPORTS WIN32 _WINDOWS)
target_link_libraries(libsearpc PRIVATE PkgConfig::GLIB PkgConfig::JANSSON)
if(WIN32)
  find_library(PTHREAD_LIB NAMES pthreadVC3 pthread REQUIRED)
  target_link_libraries(libsearpc PRIVATE "${PTHREAD_LIB}" ws2_32 advapi32)
endif()

include(GNUInstallDirs)
install(TARGETS libsearpc
  RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
  LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
  ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
)
install(FILES
  lib/searpc.h
  lib/searpc-client.h
  lib/searpc-server.h
  lib/searpc-utils.h
  lib/searpc-named-pipe-transport.h
  DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
)
