vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Blosc/c-blosc
    REF "v${VERSION}"
    SHA512 f32ac9ca7dd473f32201cdf4b7bb61a89e8bc3e3d16e027d2c6dc1aa838cb47c42dfed6942c9108532b3920ed22a8c662e7451890177c9bbe6ec5b8ab65362b3
    HEAD_REF master
    PATCHES
      0001-fix-CMake-config.patch
      0002-fix-CMake-version.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BLOSC_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BLOSC_SHARED)

file(REMOVE_RECURSE "${SOURCE_PATH}/internal-complibs")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DPREFER_EXTERNAL_LZ4=ON
        -DPREFER_EXTERNAL_ZLIB=ON
        -DPREFER_EXTERNAL_ZSTD=ON
        -DBUILD_TESTS=OFF
        -DBUILD_FUZZERS=OFF
        -DBUILD_BENCHMARKS=OFF
        -DBUILD_STATIC=${BLOSC_STATIC}
        -DBUILD_SHARED=${BLOSC_SHARED}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH share/${PORT})

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/${PORT}/blosc-config.cmake"
    [[# Generated by CMake]]
    [[# Generated by CMake 
include(CMakeFindDependencyMacro)
find_dependency(lz4 CONFIG)
find_dependency(zstd CONFIG)
find_dependency(Snappy CONFIG)
find_dependency(ZLIB)
find_dependency(Threads)]]
)

# cleanup
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

vcpkg_fixup_pkgconfig()
