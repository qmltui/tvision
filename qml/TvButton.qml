pragma ComponentBehavior: Bound

import QtQml
import QmlTui

// Classic 2-row Borland Turbo Vision 3D beveled button:
//   Row 0: `◄ OK ►▄` (default) or `  OK  ▄`, shifting 1 cell right when pressed
//   Row 1: ` ▀▀▀▀▀▀` half-block drop shadow on parent surface color
Item {
    id: control

    property string text: "~O~K"
    property bool isDefault: false
    property color surfaceColor: TvTheme.dialogBg

    readonly property string plainText: TvMnemonic.strip(control.text)
    readonly property string mnemonic: TvMnemonic.mnemonicChar(control.text)
    readonly property bool down: mouseArea.containsPress || control.keyDown
    property bool keyDown: false

    readonly property int faceWidth: Math.max(8, control.width - 1)
    readonly property color activeFaceBg: !control.enabled ? TvTheme.barDisabledFg : (control.activeFocus || mouseArea.containsMouse) ? TvTheme.buttonFocusedBg : TvTheme.buttonBg
    readonly property color activeFaceFg: control.activeFocus ? TvTheme.buttonDefaultFg : TvTheme.buttonFg

    signal clicked

    function isEffectivelyVisible(): bool {
        let p = control;
        while (p) {
            if (!p.visible)
                return false;
            p = p.parent;
        }
        return true;
    }

    function trigger() {
        if (!control.enabled || !control.isEffectivelyVisible())
            return;
        control.clicked();
        if (control.enabled && control.isEffectivelyVisible()) {
            control.keyDown = true;
            pressTimer.restart();
        }
    }

    implicitWidth: Math.max(10, control.plainText.length + 5)
    implicitHeight: 2
    focusPolicy: Qt.StrongFocus

    Keys.onPressed: event => {
        if (!control.enabled)
            return;
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
            control.trigger();
            event.accepted = true;
        }
    }

    Timer {
        id: pressTimer

        interval: 90
        repeat: false
        onTriggered: {
            control.keyDown = false;
        }
    }

    // Face background on row 0 (shifts +1 cell right when pressed)
    Rectangle {
        x: control.down ? 1 : 0
        y: 0
        width: control.faceWidth
        height: 1
        color: control.activeFaceBg

        Text {
            anchors.centerIn: parent
            spans: {
                const leftMark = control.isDefault ? "◄ " : "  ";
                const rightMark = control.isDefault ? " ►" : "  ";
                return TvMnemonic.buildSpans(leftMark + control.text + rightMark, control.activeFaceFg, TvTheme.buttonHotkeyFg, control.activeFaceBg, control.activeFocus || control.isDefault, TvTheme.isMonochrome);
            }
        }
    }

    // Right half-block bevel (`▄`) on row 0 when unpressed
    Text {
        x: control.faceWidth
        y: 0
        visible: !control.down
        text: "▄"
        color: TvTheme.buttonShadowFg
        backgroundColor: control.surfaceColor
    }

    // Bottom half-block bevel (`▀`) on row 1 when unpressed
    Text {
        x: 1
        y: 1
        visible: !control.down
        text: "▀".repeat(Math.max(0, control.faceWidth))
        color: TvTheme.buttonShadowFg
        backgroundColor: control.surfaceColor
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        onPressed: _event => {
            if (control.enabled)
                control.forceActiveFocus();
        }
        onClicked: _event => {
            if (control.enabled)
                control.clicked();
        }
    }
}
