cmake_minimum_required(VERSION 3.16)

project(fcitx5-commit-string-dbus VERSION 0.1.0)

find_package(ECM REQUIRED 1.0.0)
include(GNUInstallDirs)

find_package(Fcitx5Core 5.1.13 REQUIRED)
find_package(Fcitx5Module REQUIRED COMPONENTS DBus)

include("${FCITX_INSTALL_CMAKECONFIG_DIR}/Fcitx5Utils/Fcitx5CompilerSettings.cmake")

add_fcitx5_addon(commitstringdbus commitstringdbus.cpp)
target_link_libraries(commitstringdbus
    Fcitx5::Core
    Fcitx5::Module::DBus
)

install(TARGETS commitstringdbus DESTINATION "${FCITX_INSTALL_ADDONDIR}")

configure_file(commitstringdbus.conf.in commitstringdbus.conf @ONLY)
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/commitstringdbus.conf"
        DESTINATION "${FCITX_INSTALL_PKGDATADIR}/addon")
