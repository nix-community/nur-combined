cmake_minimum_required(VERSION 3.10)
project(project VERSION 0.0.0 LANGUAGES CXX)
enable_testing()

add_library(common_options INTERFACE)
target_compile_features(common_options INTERFACE
  cxx_std_20
)
target_compile_options(common_options INTERFACE
  -Wall
  -Wextra
)
target_include_directories(common_options INTERFACE
  src
)

add_subdirectory(src)
add_subdirectory(tests)
