cmake_minimum_required(VERSION 3.20)

project(sway_autorotate)
add_executable(sway-autorotate ./autorotate.cpp)

install(TARGETS sway-autorotate)
