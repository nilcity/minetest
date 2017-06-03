mark_as_advanced(HIREDIS_LIBRARY HIREDIS_INCLUDE_DIR)

message(STATUS "Using bundled Hiredis library.")
set(HIREDIS_INCLUDE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/lib/hiredis)
set(HIREDIS_LIBRARY hiredis)
add_subdirectory(lib/hiredis)
