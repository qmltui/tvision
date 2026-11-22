pragma ComponentBehavior: Bound

import QtQml
import QmlTui

// Centered modal Turbo Vision dialog box (`Popup`) with double-line gray frame,
// `[■]` close button, centered title, automatic `Alt+<Mnemonic>` (and unconsumed
// plain `<Mnemonic>`) routing to child TvButton controls, and translucent TvDropShadow.
Popup {
    id: dialog

    default property alias contentData: bodyHost.data

    property string title: "Dialog"
    property bool closable: true
    property TvPalette palette: null

    readonly property TvPalette effectivePalette: dialog.palette ? dialog.palette : TvTheme.activePalette

    readonly property int maxTitleLen: Math.max(0, dialog.width - 10)
    readonly property string shownTitle: dialog.title.length > dialog.maxTitleLen ? dialog.title.slice(0, dialog.maxTitleLen) : dialog.title
    readonly property int titleSpanW: dialog.shownTitle.length > 0 ? dialog.shownTitle.length + 2 : 0
    readonly property int titleX: Math.max(6, Math.floor((dialog.width - dialog.titleSpanW) / 2))

    function triggerButtonMnemonic(node: var, targetChar: string): bool {
        if (!node || !node.visible || !node.enabled)
            return false;
        if (node.mnemonic !== undefined && String(node.mnemonic) === targetChar && typeof node.trigger === "function") {
            node.trigger();
            return true;
        }
        const kids = node.children || [];
        for (let i = 0; i < kids.length; ++i) {
            if (dialog.triggerButtonMnemonic(kids[i], targetChar))
                return true;
        }
        return false;
    }

    x: dialog.parent ? Math.max(1, Math.floor((dialog.parent.width - dialog.width) / 2)) : 4
    y: dialog.parent ? Math.max(1, Math.floor((dialog.parent.height - dialog.height) / 2)) : 2
    width: 52
    height: 15
    modal: true
    dimBackground: false
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnOutsideClick

    Keys.onPressed: event => {
        if (!event.text || event.text.length !== 1 || (event.modifiers & Qt.ControlModifier) !== 0)
            return;
        // Reached when focused child inside modal did not consume printable key,
        // or when Alt+<Letter> is pressed inside the dialog.
        const ch = event.text.toUpperCase();
        if (dialog.triggerButtonMnemonic(bodyHost, ch))
            event.accepted = true;
    }

    TvDropShadow {
        x: 0
        y: 0
        z: -1
        width: dialog.width + 2
        height: dialog.height + 1
        horizontalOffset: 2
        verticalOffset: 1
    }

    Rectangle {
        anchors.fill: parent
        color: dialog.effectivePalette.dialogBg
        border.style: Border.Double
        border.color: dialog.effectivePalette.dialogActiveBorder

        Text {
            visible: dialog.closable && dialog.width >= 10
            x: 2
            y: 0
            z: 1.5
            spans: [QmlTui.span("[", {
                    color: dialog.effectivePalette.dialogActiveBorder,
                    backgroundColor: dialog.effectivePalette.dialogBg
                }), QmlTui.span("■", {
                    color: dialog.effectivePalette.dialogControlFg,
                    backgroundColor: dialog.effectivePalette.dialogBg,
                    bold: true
                }), QmlTui.span("]", {
                    color: dialog.effectivePalette.dialogActiveBorder,
                    backgroundColor: dialog.effectivePalette.dialogBg
                })]
        }

        MouseArea {
            visible: dialog.closable && dialog.width >= 10
            x: 2
            y: 0
            z: 3
            width: 3
            height: 1
            onClicked: _event => {
                dialog.reject();
            }
        }

        Text {
            visible: dialog.titleSpanW > 0
            x: dialog.titleX
            y: 0
            z: 1.5
            text: " " + dialog.shownTitle + " "
            color: dialog.effectivePalette.dialogActiveBorder
            backgroundColor: dialog.effectivePalette.dialogBg
            bold: true
        }

        Item {
            id: bodyHost

            anchors.fill: parent
            clip: true
        }
    }
}
