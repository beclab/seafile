# Stock arm64-windows, release-only. Skip the debug half so CI does not
# compile every port twice. Install prefix is `installed/arm64-windows`.
set(VCPKG_TARGET_ARCHITECTURE arm64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE dynamic)
set(VCPKG_BUILD_TYPE release)
