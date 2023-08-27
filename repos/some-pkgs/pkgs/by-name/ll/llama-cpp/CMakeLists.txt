cmake_minimum_required(VERSION 3.14)
project(llama-find-package C CXX)

# TODO: Upstream should propagate this
find_package(Threads REQUIRED)

find_package(llama REQUIRED)

add_executable(chat main.cpp)
target_link_libraries(chat PRIVATE llama::llama)
target_compile_features(chat PRIVATE cxx_std_11)

install(TARGETS chat)
