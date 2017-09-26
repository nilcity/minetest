set(HIREDIS_CORE_SRC
    async.c
    dict.c
    hiredis.c
    net.c
    read.c
    sds.c
)
set(HIREDIS_LIB_HEADERS
    async.h
    dict.h
    fmacros.h
    hiredis.h
    net.h
    read.h
    sds.h
    sdsalloc.h
    win32.h
)

include_directories(${CMAKE_CURRENT_SOURCE_DIR}
		${CMAKE_CURRENT_BINARY_DIR})

# Hiredis library.
add_library(hiredis STATIC ${HIREDIS_CORE_SRC})
target_link_libraries(hiredis ${LIBS})
set(HIREDIS_STATIC_LIB hiredis)
set(HIREDIS_LIBS hiredis)

