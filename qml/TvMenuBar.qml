pragma ComponentBehavior: Bound

import QtQml
import QmlTui

// Top 1-row Turbo Vision menu bar supporting:
//   1. `Alt+<Mnemonic>` global shortcuts from anywhere (including inside editors)
//   2. `F10` MenuBar focus mode: highlights top bar so plain `<Mnemonic>` (`F`, `E`, `W`, `T`, `O`, `H`),
//      `Left`/`Right`, and `Enter`/`Down` work without `Alt` (bypassing terminal GUI `Alt` interception)
//   3. `tryTriggerMnemonic(text)` fallback so plain `<Mnemonic>` also opens menus whenever no text input has focus.
Rectangle {
    id: menuBar

    // Array of `{ title: "~F~ile", items: [...] }`
    property var menus: []
    property int activeMenuIndex: -1
    property bool barFocused: false
    property string rightStatusText: ""
    property TvPalette palette: null

    readonly property TvPalette effectivePalette: menuBar.palette ? menuBar.palette : TvTheme.activePalette

    readonly property bool menuOpen: pullDown.visible && menuBar.activeMenuIndex >= 0
    readonly property bool barActive: menuBar.barFocused || menuBar.menuOpen

    signal actionTriggered(string actionId)

    function findMenuByMnemonic(ch: string): int {
        if (!ch || ch.length !== 1)
            return -1;
        const upper = ch.toUpperCase();
        const list = menuBar.menus || [];
        for (let i = 0; i < list.length; ++i) {
            if (TvMnemonic.mnemonicChar(list[i].title || "") === upper)
                return i;
        }
        return -1;
    }

    function tryTriggerMnemonic(ch: string): bool {
        const idx = menuBar.findMenuByMnemonic(ch);
        if (idx < 0)
            return false;
        menuBar.openMenu(idx);
        return true;
    }

    function enterBarFocus(index: int) {
        const list = menuBar.menus || [];
        if (list.length === 0)
            return;
        if (pullDown.visible)
            pullDown.close();
        menuBar.activeMenuIndex = Math.max(0, Math.min(list.length - 1, index));
        menuBar.barFocused = true;
        barFocusPopup.open();
    }

    function openMenu(index: int) {
        const list = menuBar.menus || [];
        if (index < 0 || index >= list.length)
            return;
        if (barFocusPopup.visible)
            barFocusPopup.close();
        menuBar.barFocused = false;
        menuBar.activeMenuIndex = index;
        const xPos = menuBar.menuColumnOffset(index);
        const maxLeft = Math.max(0, menuBar.width - pullDown.computedInnerWidth - 4);
        pullDown.x = Math.min(xPos, maxLeft);
        pullDown.y = 1;
        pullDown.items = list[index].items || [];
        pullDown.open();
    }

    function closeMenu() {
        menuBar.barFocused = false;
        if (barFocusPopup.visible)
            barFocusPopup.close();
        if (pullDown.visible)
            pullDown.close();
        menuBar.activeMenuIndex = -1;
    }

    function toggleMenuBar() {
        if (menuBar.barActive)
            menuBar.closeMenu();
        else
            menuBar.enterBarFocus(0);
    }

    function menuColumnOffset(targetIndex: int): int {
        let col = 1;
        const list = menuBar.menus || [];
        for (let i = 0; i < targetIndex && i < list.length; ++i) {
            const plain = TvMnemonic.strip(list[i].title || "");
            col += plain.length + 2;
        }
        return col;
    }

    height: 1
    implicitHeight: 1
    color: menuBar.effectivePalette.barBg

    Shortcut {
        sequence: "F10"
        onActivated: menuBar.toggleMenuBar()
    }

    // Invisible Popup active while F10 MenuBar navigation mode is engaged
    // (automatically saves and restores the previously focused window/editor).
    Popup {
        id: barFocusPopup

        width: 0
        height: 0
        modal: false
        dimBackground: false
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnOutsideClick
        initialFocusItem: barKeyCatcher

        onClosed: {
            if (menuBar.barFocused) {
                menuBar.barFocused = false;
                if (!pullDown.visible)
                    menuBar.activeMenuIndex = -1;
            }
        }

        Item {
            id: barKeyCatcher

            width: 1
            height: 1
            focusPolicy: Qt.StrongFocus

            Keys.onPressed: event => {
                if (!menuBar.barFocused)
                    return;
                const list = menuBar.menus || [];
                if (list.length === 0)
                    return;

                if (event.key === Qt.Key_Left) {
                    menuBar.activeMenuIndex = ((menuBar.activeMenuIndex - 1) % list.length + list.length) % list.length;
                    event.accepted = true;
                } else if (event.key === Qt.Key_Right) {
                    menuBar.activeMenuIndex = (menuBar.activeMenuIndex + 1) % list.length;
                    event.accepted = true;
                } else if (event.key === Qt.Key_Down || event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                    menuBar.openMenu(Math.max(0, menuBar.activeMenuIndex));
                    event.accepted = true;
                } else if (event.key === Qt.Key_F10) {
                    menuBar.closeMenu();
                    event.accepted = true;
                } else if (event.text && event.text.length === 1 && (event.modifiers & Qt.ControlModifier) === 0) {
                    if (menuBar.tryTriggerMnemonic(event.text))
                        event.accepted = true;
                }
            }
        }
    }

    // Alt+<Mnemonic> (and Alt+Shift+<Mnemonic>) shortcuts for top-level menus
    Repeater {
        model: menuBar.menus

        delegate: Item {
            id: shortcutHolder

            required property var modelData
            required property int index

            readonly property string mnemonicKey: TvMnemonic.mnemonicChar(shortcutHolder.modelData.title || "")

            width: 0
            height: 0

            Shortcut {
                enabled: shortcutHolder.mnemonicKey.length === 1
                sequence: shortcutHolder.mnemonicKey.length === 1 ? ("Alt+" + shortcutHolder.mnemonicKey) : ""
                onActivated: menuBar.openMenu(shortcutHolder.index)
            }

            Shortcut {
                enabled: shortcutHolder.mnemonicKey.length === 1
                sequence: shortcutHolder.mnemonicKey.length === 1 ? ("Alt+Shift+" + shortcutHolder.mnemonicKey) : ""
                onActivated: menuBar.openMenu(shortcutHolder.index)
            }
        }
    }

    Row {
        id: titlesRow

        x: 1
        y: 0
        height: 1
        spacing: 0

        Repeater {
            model: menuBar.menus

            delegate: Item {
                id: topItem

                required property var modelData
                required property int index

                readonly property string rawTitle: String(topItem.modelData.title || "")
                readonly property string plainTitle: TvMnemonic.strip(topItem.rawTitle)
                readonly property bool selected: menuBar.barActive && menuBar.activeMenuIndex === topItem.index
                readonly property color itemBg: topItem.selected ? menuBar.effectivePalette.barSelectedBg : menuBar.effectivePalette.barBg
                readonly property color itemFg: topItem.selected ? menuBar.effectivePalette.barSelectedFg : menuBar.effectivePalette.barFg
                readonly property color itemHotkeyFg: topItem.selected ? menuBar.effectivePalette.barSelectedHotkeyFg : menuBar.effectivePalette.barHotkeyFg

                width: topItem.plainTitle.length + 2
                height: 1

                Rectangle {
                    anchors.fill: parent
                    color: topItem.itemBg
                }

                Text {
                    x: 1
                    y: 0
                    spans: TvMnemonic.buildSpans(topItem.rawTitle, topItem.itemFg, topItem.itemHotkeyFg, topItem.itemBg, topItem.selected && menuBar.effectivePalette.isMonochrome, menuBar.effectivePalette.isMonochrome)
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        if (menuBar.menuOpen && menuBar.activeMenuIndex !== topItem.index)
                            menuBar.openMenu(topItem.index);
                    }
                    onPressed: event => {
                        if (menuBar.menuOpen && menuBar.activeMenuIndex === topItem.index)
                            menuBar.closeMenu();
                        else
                            menuBar.openMenu(topItem.index);
                        event.accepted = true;
                    }
                }
            }
        }
    }

    Text {
        visible: menuBar.rightStatusText.length > 0 && menuBar.width > titlesRow.implicitWidth + menuBar.rightStatusText.length + 4
        anchors.right: parent.right
        anchors.rightMargin: 1
        y: 0
        text: menuBar.rightStatusText
        color: menuBar.effectivePalette.barFg
        backgroundColor: menuBar.effectivePalette.barBg
        bold: true
    }

    TvMenu {
        id: pullDown

        owner: menuBar
        palette: menuBar.palette
        onActionTriggered: actionId => {
            menuBar.activeMenuIndex = -1;
            menuBar.actionTriggered(actionId);
        }
        onRequestAdjacentMenu: delta => {
            const list = menuBar.menus || [];
            if (list.length === 0)
                return;
            const next = ((menuBar.activeMenuIndex + delta) % list.length + list.length) % list.length;
            menuBar.openMenu(next);
        }
        onUnmatchedMnemonicPressed: ch => {
            menuBar.tryTriggerMnemonic(ch);
        }
        onClosed: {
            if (!menuBar.barFocused)
                menuBar.activeMenuIndex = -1;
        }
    }
}
