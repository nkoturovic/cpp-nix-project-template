cmake_minimum_required(VERSION 3.20)
project(cpp-nix-app)

find_package(fmt REQUIRED)

set(CMAKE_CXX_STANDARD 20)
add_subdirectory(src)
install(TARGETS cpp-nix-app DESTINATION bin)
