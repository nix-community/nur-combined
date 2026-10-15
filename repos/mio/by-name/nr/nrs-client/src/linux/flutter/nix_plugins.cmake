if(DEFINED ENV{PREBUILT_HUB_LIB})
  set(OUTPUT_LIB "${CMAKE_BINARY_DIR}/plugins/rinf/libhub.so")
  add_custom_command(
    OUTPUT "${OUTPUT_LIB}" "${CMAKE_BINARY_DIR}/plugins/rinf/_phony_"
    COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_BINARY_DIR}/plugins/rinf"
    COMMAND ${CMAKE_COMMAND} -E copy "$ENV{PREBUILT_HUB_LIB}" "${OUTPUT_LIB}"
    COMMAND ${CMAKE_COMMAND} -E touch "${CMAKE_BINARY_DIR}/plugins/rinf/_phony_"
    VERBATIM
  )
  set_source_files_properties("${CMAKE_BINARY_DIR}/plugins/rinf/_phony_" PROPERTIES SYMBOLIC TRUE)
  add_custom_target(rinf_cargokit ALL DEPENDS "${OUTPUT_LIB}")
  set(rinf_bundled_libraries "${OUTPUT_LIB}")
  list(APPEND PLUGIN_BUNDLED_LIBRARIES "${rinf_bundled_libraries}")
  target_link_libraries(${BINARY_NAME} PRIVATE -Wl,--no-as-needed "${OUTPUT_LIB}" -Wl,--as-needed)
endif()

