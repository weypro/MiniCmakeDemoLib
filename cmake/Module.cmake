## Setup
# set(MODULE somename)                        - set module (target) name
# set(MODULE_INCLUDE ...)                     - set include (by default see below include_directories)
# set(MODULE_DEF ...)                         - set definitions
# set(MODULE_SRC ...)                         - set sources and headers files
# set(MODULE_LINK ...)                        - set libraries for link
# set(MODULE_NOT_LINK_GLOBAL ON)              - set for not link global lib
# set(PROJECT_ROOT_DIR ${PROJECT_SOURCE_DIR}) - set root dir for module
# set(MODULE_IS_STUB ON)                      - set a mark that the module is stub

# After all the settings you need to do:
# include(${PROJECT_SOURCE_DIR}/cmake/Module.cmake)

if (MODULE_IS_STUB)
    message(STATUS "Configuring " ${MODULE} " [stub]")
else()
    message(STATUS "Configuring " ${MODULE})
endif()

if (NOT PROJECT_ROOT_DIR)
    set(PROJECT_ROOT_DIR ${PROJECT_SOURCE_DIR})
endif()

if (CC_IS_EMSCRIPTEN)
    add_library(${MODULE} OBJECT)
else()
    add_library(${MODULE})
endif()

if (BUILD_SHARED_LIBS)
    install(TARGETS ${MODULE} DESTINATION ${SHARED_LIBS_INSTALL_DESTINATION})

    if (NOT MSVC)
        set_target_properties(${MODULE} PROPERTIES COMPILE_FLAGS "-fPIC")
    endif (NOT MSVC)
endif()


target_sources(${MODULE} PRIVATE
        ${MODULE_SRC}
)

target_include_directories(${MODULE} PUBLIC
        ${PROJECT_BINARY_DIR}
        ${CMAKE_CURRENT_BINARY_DIR}
        ${PROJECT_ROOT_DIR}
        ${PROJECT_ROOT_DIR}/src
        ${MODULE_INCLUDE}
)

target_compile_definitions(${MODULE} PUBLIC
        ${MODULE_DEF}
        PROJECT_ROOT_DIR="${PROJECT_ROOT_DIR}"
        ${MODULE}_QML_IMPORT="${MODULE_QML_IMPORT}"
)

if (NOT ${MODULE} MATCHES global)
    if (NOT MODULE_NOT_LINK_GLOBAL)
        set(MODULE_LINK global ${MODULE_LINK})
    endif()
endif()


set(MODULE_LINK ${CMAKE_DL_LIBS} ${MODULE_LINK})

target_link_libraries(${MODULE} PRIVATE ${MODULE_LINK} )
