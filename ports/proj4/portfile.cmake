include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OSGeo/proj.4
    REF 6.1.0
    SHA512 c9703008cd1f75fe1239b180158e560b9b88ae2ffd900b72923c716908eb86d1abbc4230647af5e3131f8c34481bdc66b03826d669620161ffcfbe67801cb631
    HEAD_REF master
    PATCHES
        0001-CMake-add-detection-of-recent-visual-studio-versions.patch
        0002-CMake-fix-error-by-only-setting-properties-for-targe.patch
        0003-CMake-configurable-cmake-config-install-location.patch
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    list(APPEND CMAKE_OPTIONS "-DBUILD_LIBPROJ_SHARED=YES")
else()
    list(APPEND CMAKE_OPTIONS "-DBUILD_LIBPROJ_SHARED=NO")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS ${CMAKE_OPTIONS}
    -DPROJ_LIB_SUBDIR=lib
    -DPROJ_INCLUDE_SUBDIR=include
    -DPROJ_DATA_SUBDIR=share/proj4
    -DPROJ_CMAKE_CONFIG_SUBDIR=share/proj4
    -DBUILD_CS2CS=NO
    -DBUILD_PROJ=NO
    -DBUILD_GEOD=NO
    -DBUILD_NAD2BIN=NO
    -DPROJ4_TESTS=NO
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/proj4)

# Rename library and adapt cmake configuration
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(READ ${CURRENT_PACKAGES_DIR}/share/proj4/proj4-targets-release.cmake _contents)
    string(REPLACE "proj_4_9.lib" "proj.lib" _contents "${_contents}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/share/proj4/proj4-targets-release.cmake "${_contents}")
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(READ ${CURRENT_PACKAGES_DIR}/share/proj4/proj4-targets-debug.cmake _contents)
    string(REPLACE "proj_4_9_d.lib" "projd.lib" _contents "${_contents}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/share/proj4/proj4-targets-debug.cmake "${_contents}")
endif()

file(READ ${CURRENT_PACKAGES_DIR}/share/proj4/proj4-targets.cmake _contents)
string(REPLACE "set(_IMPORT_PREFIX \"${CURRENT_PACKAGES_DIR}\")"
    "set(_IMPORT_PREFIX \"\${CMAKE_CURRENT_LIST_DIR}\")\nget_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)\nget_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)"
    _contents "${_contents}"
)
file(WRITE ${CURRENT_PACKAGES_DIR}/share/proj4/proj4-targets.cmake "${_contents}")

if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(RENAME ${CURRENT_PACKAGES_DIR}/lib/proj_4_9.lib  ${CURRENT_PACKAGES_DIR}/lib/proj.lib)
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/proj_4_9_d.lib  ${CURRENT_PACKAGES_DIR}/debug/lib/projd.lib)
    endif()
endif()

# Remove duplicate headers installed from debug build
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
# Remove data installed from debug build
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/proj4)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/proj4/COPYING ${CURRENT_PACKAGES_DIR}/share/proj4/copyright)
