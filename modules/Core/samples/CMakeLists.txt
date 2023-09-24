project(sample_core)

add_executable(${PROJECT_NAME} main.cpp)

target_link_libraries(${PROJECT_NAME} PRIVATE ${PROJECT_MODULE_EXPORT_NAMESPACE}${LIB_CURRENT_MODULE_NAME})

add_test(NAME ${PROJECT_NAME}
        COMMAND ${PROJECT_NAME})


