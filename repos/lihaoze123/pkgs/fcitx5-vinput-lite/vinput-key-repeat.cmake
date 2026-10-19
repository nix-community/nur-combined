add_executable(test_vinput_key_repeat EXCLUDE_FROM_ALL
    test_vinput_key_repeat.cpp
    ${CMAKE_SOURCE_DIR}/src/addon/core/vinput.cpp
    ${CMAKE_SOURCE_DIR}/src/addon/dbus/vinput_dbus.cpp
    ${CMAKE_SOURCE_DIR}/src/addon/input/vinput_keyevent.cpp
    ${CMAKE_SOURCE_DIR}/src/addon/menu/palette_command.cpp
    ${CMAKE_SOURCE_DIR}/src/addon/menu/vinput_menu.cpp
)
target_include_directories(test_vinput_key_repeat PRIVATE
    ${CMAKE_SOURCE_DIR}/src ${CMAKE_SOURCE_DIR}/src/addon ${SDBUS_INCLUDE_DIRS})
target_compile_definitions(test_vinput_key_repeat PRIVATE
    VINPUT_FCITX5_CORE_HAVE_ADDON_FACTORY_V2 VINPUT_FCITX5_CORE_HAVE_SET_COMMENT)
target_compile_options(test_vinput_key_repeat PRIVATE -fno-access-control)
target_link_libraries(test_vinput_key_repeat PRIVATE common Fcitx5::Core
    Fcitx5::Module::DBus Fcitx5::Module::Clipboard Fcitx5::Module::Notifications ${SDBUS_LIBRARIES})
add_test(NAME vinput_key_repeat COMMAND test_vinput_key_repeat)
