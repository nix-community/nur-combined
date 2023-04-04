add_executable(project main.cc)
target_link_libraries(project PRIVATE common_options)

install(TARGETS project)
