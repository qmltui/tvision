if(TARGET QmlTui::Core)
    set(_ex_core QmlTui::Core)
    set(_ex_controls QmlTui::Controls)
else()
    set(_ex_core qmltui::core)
    set(_ex_controls qmltui::controls)
endif()

if(TARGET QmlTui::Runner)
    set(_ex_runner QmlTui::Runner)
elseif(TARGET qmltui::runner)
    set(_ex_runner qmltui::runner)
else()
    set(_ex_runner "")
endif()

set(_hello_deps
    DEPENDENCIES
        TARGET QmlTuiTVision
)
get_target_property(_core_imported ${_ex_core} IMPORTED)
if(_core_imported)
    if(QmlTui_QML_IMPORT_PATH)
        list(APPEND _hello_deps IMPORT_PATH "${QmlTui_QML_IMPORT_PATH}")
    endif()
else()
    list(APPEND _hello_deps
        TARGET ${_ex_core}
        TARGET ${_ex_controls}
    )
endif()

qt_add_executable(tvision_hello
    main.cpp
)

qt_add_qml_module(tvision_hello
    URI TVisionHelloExample
    QML_FILES
        Main.qml
    ${_hello_deps}
)

target_link_libraries(tvision_hello PRIVATE
    Qt6::Core
    Qt6::Qml
    ${_ex_core}
    ${_ex_controls}
    QmlTui::TVision
)

if(QMLTUI_TVISION_BUILD_TESTS AND _ex_runner)
    target_link_libraries(tvision_hello PRIVATE ${_ex_runner})
    qmltui_add_scenario(
        NAME test_runner_tvision_hello
        TARGET tvision_hello
        SCRIPT "${CMAKE_CURRENT_SOURCE_DIR}/smoke.js"
        COLUMNS 90
        ROWS 26
        CLOCK VIRTUAL
    )
endif()
