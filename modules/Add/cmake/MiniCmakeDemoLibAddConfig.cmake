include(CMakeFindDependencyMacro)
find_dependency(MiniCmakeDemoLib::Core)
include("${CMAKE_CURRENT_LIST_DIR}/MiniCmakeDemoLibAddTargets.cmake")
