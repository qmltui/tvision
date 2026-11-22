# `QmlTui.TVision`

Borland Turbo Vision-inspired **Multi-Document Interface (MDI)** desktop windowing, pull-down menus, tilde-mnemonics, beveled buttons, modal dialogs, per-file themes, and custom `TextGridBuffer` primitives (`TvDesktopSurface`, `TvDropShadow`, `TvDragHandle`) built natively on [QmlTui](https://github.com/qmltui/qmltui)'s retained-mode QML scene graph.

![QmlTui.TVision Minimal Example](docs/assets/casts/hello_tvision.gif)

For a full-scale application built on `QmlTui.TVision`, see [`turbo_hex`](https://github.com/qmltui/apps/tree/main/apps/turbo_hex) in [`qmltui/apps`](https://github.com/qmltui/apps).

## Provided Types (`import QmlTui.TVision`)

| Type | Kind | Summary |
| :--- | :--- | :--- |
| `TvDesktop` | QML `Item` | MDI workspace managing overlapping `TvWindow` children, `z`-order activation, `1..9` window numbering, `Tile`, `Cascade`, `F5` zoom, and `F6` cycling. |
| `TvWindow` | QML `FocusScope` | Draggable, resizable, zoomable, closable MDI window with `[■]` close box, `[↕]` zoom toggle, `Ctrl+F5` keyboard move/resize mode, and `TvDropShadow`. |
| `TvMenuBar` | QML `Rectangle` | 1-row top menu bar supporting `Alt+<Mnemonic>`, `F10` → `<Mnemonic>` bar-focus mode, plain-key fallback, and pull-down `TvMenu` popups. |
| `TvMenu` | QML `Popup` | Pull-down menu with `~mnemonic~` hotkeys, right-aligned shortcut chords, `├─┤` separators, and translucent drop shadow. |
| `TvStatusLine` | QML `Rectangle` | 1-row bottom command bar displaying clickable hotkey hints and right-aligned status telemetry. |
| `TvDialog` | QML `Popup` | Centered modal Turbo Vision dialog box with double-line chrome, `[■]` close button, button mnemonic routing, and `TvDropShadow`. |
| `TvButton` | QML `Item` | Classic 2-row 3D beveled button (`◄ OK ►▄` / `▀▀▀▀▀▀`) with pressed shift feedback and `~mnemonic~` highlighting. |
| `TvPalette` | C++ `QObject` | Declarative theme token container instantiated per theme file under [`qml/themes/`](qml/themes/) (or custom app themes via `TvTheme.customScheme`). |
| `TvTheme` | QML Singleton | Reactive theme registry (`BorlandBlueTheme`, `TurboCyanTheme`, `DarkDosTheme`, `MonochromeTheme`) and desktop stipple patterns. |
| `TvMnemonic` | QML Singleton | Parses Borland `~F~ile` tilde-mnemonics into stripped strings, hotkey characters, and styled `QmlTui.span` arrays. |
| `TvDesktopSurface` | C++ `Item` | Single-pass `BoundedSelfPaint` item filling stippled desktop backgrounds directly into `TextGridBuffer`. |
| `TvDropShadow` | C++ `Item` | Click-through (`enabled: false`) translucent shadow darkening underlying `Cell` RGB channels and setting `TextAttribute::Dim` without erasing glyphs. |
| `TvDragHandle` | C++ `Item` | Screen-space pointer drag/resize primitive avoiding local-coordinate feedback stalls when parent windows move during drags. |

## Consuming via CMake `FetchContent`

```cmake
include(FetchContent)
FetchContent_Declare(
    qmltui_tvision
    GIT_REPOSITORY https://github.com/qmltui/tvision.git
    GIT_TAG main
    GIT_SHALLOW TRUE
)
FetchContent_MakeAvailable(qmltui_tvision)

target_link_libraries(my_app PRIVATE QmlTui::Core QmlTui::Controls QmlTui::TVision)
```

In `qt_add_qml_module`, declare `DEPENDENCIES TARGET QmlTuiTVision` for `qmllint` static analysis, then import `QmlTui.TVision`:

```qml
pragma ComponentBehavior: Bound
import QmlTui
import QmlTui.TVision
```

## Standalone Build & Tests

```sh
cmake -S . -B build -G Ninja -DFETCHCONTENT_SOURCE_DIR_QMLTUI=/path/to/qmltui
cmake --build build
ctest --test-dir build --output-on-failure
./build/examples/hello_tvision/tvision_hello
```
