cmake_minimum_required(VERSION 3.24)
project(sample_minicmakedemolib)

add_executable(${PROJECT_NAME} main.cpp)

find_package(MiniCmakeDemoLib CONFIG REQUIRED)

target_link_libraries(${PROJECT_NAME} PUBLIC MiniCmakeDemoLib)

add_test(NAME ${PROJECT_NAME}
        COMMAND ${PROJECT_NAME})


