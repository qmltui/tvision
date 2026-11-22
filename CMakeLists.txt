cmake_minimum_required(VERSION 3.21)
project(QmlTuiTVision VERSION 0.6.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
    set(_tvision_is_top_level ON)
else()
    set(_tvision_is_top_level OFF)
endif()

set(_tvision_default_tests ${_tvision_is_top_level})
if(EMSCRIPTEN)
    set(_tvision_default_tests OFF)
endif()

option(QMLTUI_TVISION_BUILD_TESTS "Build QmlTui.TVision unit and scenario tests" ${_tvision_default_tests})
option(QMLTUI_TVISION_BUILD_EXAMPLES "Build QmlTui.TVision example apps" ${_tvision_is_top_level})
option(QMLTUI_USE_INSTALLED "Consume an installed QmlTui 0.6 package instead of FetchContent" OFF)

if(_tvision_is_top_level)
    if(QMLTUI_TVISION_BUILD_TESTS)
        include(CTest)
    endif()
    if(NOT TARGET QmlTui::Core AND NOT TARGET qmltui::core)
        if(QMLTUI_USE_INSTALLED)
            find_package(Qt6 6.8 REQUIRED COMPONENTS Core Qml)
            qt_standard_project_setup(REQUIRES 6.8)
            find_package(QmlTui 0.6 REQUIRED)
        else()
            include(FetchContent)
            set(QMLTUI_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
            set(QMLTUI_BUILD_TESTS OFF CACHE BOOL "" FORCE)
            set(QMLTUI_BUILD_BENCHMARKS OFF CACHE BOOL "" FORCE)
            FetchContent_Declare(
                qmltui
                GIT_REPOSITORY https://github.com/qmltui/qmltui.git
                GIT_TAG main
                GIT_SHALLOW TRUE
            )
            FetchContent_MakeAvailable(qmltui)
            find_package(Qt6 6.8 REQUIRED COMPONENTS Core Qml)
            qt_standard_project_setup(REQUIRES 6.8)
        endif()
    endif()
    if(QMLTUI_TVISION_BUILD_TESTS)
        find_package(Qt6 6.8 REQUIRED COMPONENTS Test)
    endif()
endif()

if(NOT QT_QML_OUTPUT_DIRECTORY)
    set(QT_QML_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/qml" CACHE PATH
        "Build-tree location for generated QML modules")
endif()

set_source_files_properties(
    qml/TvTheme.qml
    qml/TvMnemonic.qml
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE
)

if(TARGET QmlTui::Core)
    set(_tv_core_target QmlTui::Core)
    set(_tv_controls_target QmlTui::Controls)
else()
    set(_tv_core_target qmltui::core)
    set(_tv_controls_target qmltui::controls)
endif()

set(_tvision_module_deps)
get_target_property(_qmltui_is_imported ${_tv_core_target} IMPORTED)
if(_qmltui_is_imported)
    if(QmlTui_QML_IMPORT_PATH)
        list(APPEND _tvision_module_deps IMPORT_PATH "${QmlTui_QML_IMPORT_PATH}")
    endif()
else()
    list(APPEND _tvision_module_deps
        DEPENDENCIES
            TARGET ${_tv_core_target}
            TARGET ${_tv_controls_target}
    )
endif()

qt_add_qml_module(QmlTuiTVision
    URI QmlTui.TVision
    STATIC
    OUTPUT_DIRECTORY "${QT_QML_OUTPUT_DIRECTORY}/QmlTui/TVision"
    SOURCES
        src/TvDesktopSurface.h
        src/TvDesktopSurface.cpp
        src/TvDropShadow.h
        src/TvDropShadow.cpp
        src/TvDragHandle.h
        src/TvDragHandle.cpp
        src/TvPalette.h
        src/TvPalette.cpp
    QML_FILES
        qml/TvTheme.qml
        qml/TvMnemonic.qml
        qml/TvButton.qml
        qml/TvStatusLine.qml
        qml/TvMenu.qml
        qml/TvMenuBar.qml
        qml/TvWindow.qml
        qml/TvDesktop.qml
        qml/TvDialog.qml
        qml/themes/BorlandBlueTheme.qml
        qml/themes/TurboCyanTheme.qml
        qml/themes/DarkDosTheme.qml
        qml/themes/MonochromeTheme.qml
    ${_tvision_module_deps}
)

target_include_directories(QmlTuiTVision
    PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/src"
    PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}"
)
target_link_libraries(QmlTuiTVision
    PUBLIC
        Qt6::Core
        Qt6::Qml
        ${_tv_core_target}
        ${_tv_controls_target}
    INTERFACE
        QmlTuiTVisionplugin
)

if(NOT TARGET QmlTui::TVision)
    add_library(QmlTui::TVision ALIAS QmlTuiTVision)
endif()
if(NOT TARGET qmltui::tvision)
    add_library(qmltui::tvision ALIAS QmlTuiTVision)
endif()

if(QMLTUI_TVISION_BUILD_TESTS)
    qt_add_executable(tst_tvision_primitives
        tests/tst_tvision_primitives.cpp
    )
    target_link_libraries(tst_tvision_primitives PRIVATE
        Qt6::Core
        Qt6::Qml
        Qt6::Test
        ${_tv_core_target}
        QmlTui::TVision
    )
    add_test(NAME tst_tvision_primitives COMMAND tst_tvision_primitives)
    set_tests_properties(tst_tvision_primitives PROPERTIES LABELS "Unit")
endif()

if(QMLTUI_TVISION_BUILD_EXAMPLES)
    add_subdirectory(examples/hello_tvision)
endif()

if(_tvision_is_top_level AND COMMAND qmltui_scenario_editor_support)
    qmltui_scenario_editor_support()
endif()
