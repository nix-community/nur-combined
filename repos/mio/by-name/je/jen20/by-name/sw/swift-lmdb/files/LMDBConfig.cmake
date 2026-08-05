add_library(LMDB::CLMDB @buildType@ IMPORTED)
set_target_properties(LMDB::CLMDB PROPERTIES
        IMPORTED_LOCATION "@lib@/lib/${CMAKE_@buildType@_LIBRARY_PREFIX}lmdb${CMAKE_@buildType@_LIBRARY_SUFFIX}"
        INTERFACE_INCLUDE_DIRECTORIES "@dev@/include"
)
