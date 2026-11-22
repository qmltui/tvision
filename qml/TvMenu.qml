pragma ComponentBehavior: Bound

import QtQml
import QmlTui

// Pull-down cascading menu popup styled after Borland Turbo Vision, with
// single-line box frame, separator rows (`├─┤`), `~mnemonic~` hotkeys,
// right-aligned shortcut chords, and a translucent 2x1 TvDropShadow.
Popup {
    id: menuPopup

    // Array of `{ text: "~O~pen...", shortcut: "F3", action: "file.open", enabled: true }`
    // or `{ separator: true }`
    property var items: []
    property int currentIndex: 0
    property TvPalette palette: null

    readonly property TvPalette effectivePalette: menuPopup.palette ? menuPopup.palette : TvTheme.activePalette

    readonly property int computedInnerWidth: {
        let maxW = 16;
        const list = menuPopup.items || [];
        for (let i = 0; i < list.length; ++i) {
            const entry = list[i];
            if (!entry || entry.separator)
                continue;
            const labelLen = TvMnemonic.strip(entry.text || "").length;
            const scLen = entry.shortcut ? String(entry.shortcut).length + 3 : 0;
            maxW = Math.max(maxW, labelLen + scLen + 2);
        }
        return maxW;
    }

    signal actionTriggered(string actionId)
    signal requestAdjacentMenu(int delta)
    signal unmatchedMnemonicPressed(string ch)

    function isSelectable(idx: int): bool {
        const list = menuPopup.items || [];
        if (idx < 0 || idx >= list.length)
            return false;
        const entry = list[idx];
        if (!entry || entry.separator)
            return false;
        return entry.enabled !== false;
    }

    function selectFirstSelectable() {
        const list = menuPopup.items || [];
        for (let i = 0; i < list.length; ++i) {
            if (menuPopup.isSelectable(i)) {
                menuPopup.currentIndex = i;
                return;
            }
        }
        menuPopup.currentIndex = -1;
    }

    function stepSelection(delta: int) {
        const list = menuPopup.items || [];
        const n = list.length;
        if (n === 0)
            return;
        let idx = menuPopup.currentIndex;
        for (let step = 0; step < n; ++step) {
            idx = ((idx + delta) % n + n) % n;
            if (menuPopup.isSelectable(idx)) {
                menuPopup.currentIndex = idx;
                return;
            }
        }
    }

    function triggerIndex(idx: int) {
        if (!menuPopup.isSelectable(idx))
            return;
        const entry = menuPopup.items[idx];
        const act = entry.action || "";
        menuPopup.close();
        if (act !== "")
            menuPopup.actionTriggered(act);
    }

    width: menuPopup.computedInnerWidth + 2
    height: (menuPopup.items ? menuPopup.items.length : 0) + 2
    modal: false
    dimBackground: false
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnOutsideClick
    initialFocusItem: keyScope

    onOpened: {
        menuPopup.selectFirstSelectable();
    }

    TvDropShadow {
        x: 0
        y: 0
        z: -1
        width: menuPopup.width + 2
        height: menuPopup.height + 1
        horizontalOffset: 2
        verticalOffset: 1
    }

    Rectangle {
        id: menuFrame

        anchors.fill: parent
        color: menuPopup.effectivePalette.barBg
        border.style: Border.Single
        border.color: menuPopup.effectivePalette.barBorderFg

        Item {
            id: keyScope

            anchors.fill: parent
            focusPolicy: Qt.StrongFocus

            Keys.onPressed: event => {
                if (event.key === Qt.Key_Down) {
                    menuPopup.stepSelection(1);
                    event.accepted = true;
                } else if (event.key === Qt.Key_Up) {
                    menuPopup.stepSelection(-1);
                    event.accepted = true;
                } else if (event.key === Qt.Key_Home) {
                    menuPopup.selectFirstSelectable();
                    event.accepted = true;
                } else if (event.key === Qt.Key_Left) {
                    menuPopup.requestAdjacentMenu(-1);
                    event.accepted = true;
                } else if (event.key === Qt.Key_Right) {
                    menuPopup.requestAdjacentMenu(1);
                    event.accepted = true;
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                    menuPopup.triggerIndex(menuPopup.currentIndex);
                    event.accepted = true;
                } else if (event.key === Qt.Key_F10) {
                    menuPopup.close();
                    event.accepted = true;
                } else if (event.text && event.text.length === 1 && (event.modifiers & Qt.ControlModifier) === 0) {
                    const ch = event.text.toUpperCase();
                    const list = menuPopup.items || [];
                    for (let i = 0; i < list.length; ++i) {
                        if (!menuPopup.isSelectable(i))
                            continue;
                        if (TvMnemonic.mnemonicChar(list[i].text || "") === ch) {
                            menuPopup.currentIndex = i;
                            menuPopup.triggerIndex(i);
                            event.accepted = true;
                            return;
                        }
                    }
                    if ((event.modifiers & Qt.AltModifier) !== 0) {
                        menuPopup.unmatchedMnemonicPressed(ch);
                        event.accepted = true;
                    }
                }
            }

            Column {
                width: parent.width

                Repeater {
                    model: menuPopup.items

                    delegate: Item {
                        id: rowItem

                        required property var modelData
                        required property int index

                        readonly property bool isSep: Boolean(rowItem.modelData && rowItem.modelData.separator)
                        readonly property bool itemEnabled: !rowItem.isSep && (rowItem.modelData.enabled !== false)
                        readonly property bool selected: !rowItem.isSep && rowItem.itemEnabled && menuPopup.currentIndex === rowItem.index
                        readonly property string rawLabel: rowItem.isSep ? "" : String(rowItem.modelData.text || "")
                        readonly property string plainLabel: TvMnemonic.strip(rowItem.rawLabel)
                        readonly property string shortcutText: (!rowItem.isSep && rowItem.modelData.shortcut) ? String(rowItem.modelData.shortcut) : ""
                        readonly property color rowBg: rowItem.selected ? menuPopup.effectivePalette.barSelectedBg : menuPopup.effectivePalette.barBg
                        readonly property color rowFg: !rowItem.itemEnabled ? menuPopup.effectivePalette.barDisabledFg : rowItem.selected ? menuPopup.effectivePalette.barSelectedFg : menuPopup.effectivePalette.barFg
                        readonly property color rowHotkeyFg: !rowItem.itemEnabled ? menuPopup.effectivePalette.barDisabledFg : rowItem.selected ? menuPopup.effectivePalette.barSelectedHotkeyFg : menuPopup.effectivePalette.barHotkeyFg

                        width: menuPopup.computedInnerWidth
                        height: 1

                        Rectangle {
                            anchors.fill: parent
                            visible: !rowItem.isSep
                            color: rowItem.rowBg
                        }

                        Text {
                            visible: !rowItem.isSep
                            x: 1
                            y: 0
                            spans: TvMnemonic.buildSpans(rowItem.rawLabel, rowItem.rowFg, rowItem.rowHotkeyFg, rowItem.rowBg, rowItem.selected && menuPopup.effectivePalette.isMonochrome, menuPopup.effectivePalette.isMonochrome)
                        }

                        Text {
                            visible: !rowItem.isSep && rowItem.shortcutText.length > 0
                            anchors.right: parent.right
                            anchors.rightMargin: 1
                            y: 0
                            text: rowItem.shortcutText
                            color: rowItem.rowFg
                            backgroundColor: rowItem.rowBg
                        }

                        MouseArea {
                            anchors.fill: parent
                            enabled: rowItem.itemEnabled
                            hoverEnabled: true
                            onEntered: {
                                if (rowItem.itemEnabled)
                                    menuPopup.currentIndex = rowItem.index;
                            }
                            onClicked: _event => {
                                if (rowItem.itemEnabled)
                                    menuPopup.triggerIndex(rowItem.index);
                            }
                        }
                    }
                }
            }
        }

        // Connected box-drawing separators (`├────┤`) rendered over the side borders
        Repeater {
            model: menuPopup.items

            delegate: Text {
                id: sepOverlay

                required property var modelData
                required property int index

                readonly property bool isSep: Boolean(sepOverlay.modelData && sepOverlay.modelData.separator)

                visible: sepOverlay.isSep
                x: 0
                y: sepOverlay.index + 1
                z: 2
                text: "├" + "─".repeat(Math.max(0, menuPopup.width - 2)) + "┤"
                color: menuPopup.effectivePalette.barBorderFg
                backgroundColor: menuPopup.effectivePalette.barBg
            }
        }
    }
}
