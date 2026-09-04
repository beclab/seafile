# Overlay port: MSVC libsearpc for Windows ARM64.
# Upstream vcxproj has no ARM64 platform; haiwen/libsearpc is fetched here.
# Bump REF + SHA512 together to upgrade. Do not point at a moving tag.
set(LIBSEARPC_COMMIT 23d5df62815fb3b7825bf4e1a28b29af701e8cb2)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO haiwen/libsearpc
    REF "${LIBSEARPC_COMMIT}"
    SHA512 191f6d1f6c99720e23d5fa43915547b353e136f97516895ebf14621a1780bd799f21ea92d1ce4f029d37ece8c8ff3b759d4bdb6e2d5f72614288cceaefba93d5
    HEAD_REF master
)

# Upstream has no CMake; the vcxproj has no ARM64 platform.
file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/libsearpc-version.txt"
"repo: https://github.com/haiwen/libsearpc.git
commit: ${LIBSEARPC_COMMIT}
")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
