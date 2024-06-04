cmake_minimum_required(VERSION 3.29)
project(CppNixApp)

find_package(fmt REQUIRED)

set(CMAKE_CXX_STANDARD 23)
add_subdirectory(src)
install(TARGETS cpp-nix-app DESTINATION bin)
