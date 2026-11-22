pragma ComponentBehavior: Bound

import QtQml
import QmlTui
import QmlTui.TVision

// Minimal self-contained example demonstrating TvMenuBar, TvDesktop, TvWindow,
// TvDialog, TvButton, TvStatusLine, and built-in + custom TvPalette themes.
Terminal {
    id: root

    function dispatch(action: string) {
        if (action === "dialog")
            demoDialog.open();
        else if (action === "tile")
            desktop.tile();
        else if (action === "cascade")
            desktop.cascade();
        else if (action === "theme")
            TvTheme.cycleScheme();
        else if (action === "amber")
            TvTheme.setScheme("amber_crt");
        else if (action === "quit")
            Qt.quit();
    }

    Component.onCompleted: TvTheme.registerScheme(amberTheme)

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
            if (menuBar.barActive)
                menuBar.closeMenu();
            else
                Qt.quit();
            event.accepted = true;
            return;
        }
        if ((event.modifiers & (Qt.ControlModifier | Qt.AltModifier)) === 0 && event.text && event.text.length === 1) {
            if (menuBar.tryTriggerMnemonic(event.text)) {
                event.accepted = true;
                return;
            }
            if (event.key === Qt.Key_Q) {
                Qt.quit();
                event.accepted = true;
            }
        }
    }

    Shortcut {
        sequence: "Alt+X"
        onActivated: Qt.quit()
    }
    Shortcut {
        sequence: "F9"
        onActivated: TvTheme.cycleScheme()
    }
    Shortcut {
        sequence: "F6"
        onActivated: desktop.cycleNext()
    }

    TvMenuBar {
        id: menuBar

        width: root.width
        rightStatusText: "QmlTui.TVision · " + TvTheme.schemeTitle
        menus: [
            {
                title: "~F~ile",
                items: [
                    {
                        text: "Open ~D~ialog...",
                        shortcut: "",
                        action: "dialog"
                    },
                    {
                        separator: true
                    },
                    {
                        text: "E~x~it",
                        shortcut: "Alt+X",
                        action: "quit"
                    }
                ]
            },
            {
                title: "~W~indow",
                items: [
                    {
                        text: "~T~ile",
                        shortcut: "",
                        action: "tile"
                    },
                    {
                        text: "C~a~scade",
                        shortcut: "",
                        action: "cascade"
                    }
                ]
            },
            {
                title: "~O~ptions",
                items: [
                    {
                        text: "Cycle ~T~heme",
                        shortcut: "F9",
                        action: "theme"
                    },
                    {
                        text: "~A~mber CRT (Custom)",
                        shortcut: "",
                        action: "amber"
                    }
                ]
            }
        ]
        onActionTriggered: actionId => root.dispatch(actionId)
    }

    DarkDosTheme {
        id: amberTheme

        schemeId: "amber_crt"
        schemeTitle: "Amber CRT"
        description: "Amber CRT (Custom Phosphor)"
        desktopBg: "#120900"
        desktopFg: "#5c3300"
        barBg: "#2b1800"
        barFg: "#ffd080"
        barHotkeyFg: "#ff9000"
        barSelectedBg: "#cc7a00"
        barSelectedFg: "#120900"
        barSelectedHotkeyFg: "#120900"
        barBorderFg: "#cc7a00"
        winBg: "#1a0d00"
        winFg: "#ffb000"
        winMutedFg: "#cc8400"
        winActiveBorder: "#ffd866"
        winInactiveBorder: "#7a4b00"
        winControlFg: "#ffd866"
        dialogBg: "#241300"
        dialogFg: "#ffd080"
        dialogMutedFg: "#b37400"
        dialogActiveBorder: "#ffd866"
        dialogControlFg: "#ffb000"
        buttonBg: "#cc7a00"
        buttonFocusedBg: "#ffb000"
        buttonFg: "#120900"
        buttonDefaultFg: "#120900"
        buttonHotkeyFg: "#ffffff"
    }

    TvDesktop {
        id: desktop

        y: 1
        width: root.width
        height: Math.max(1, root.height - 2)

        TvWindow {
            title: "Welcome"
            windowId: "1"
            x: 2
            y: 1
            width: 44
            height: 12

            Column {
                anchors.fill: parent
                anchors.margins: 1
                spacing: 1

                Text {
                    text: "Hello from QmlTui.TVision!"
                    color: TvTheme.winFg
                    backgroundColor: TvTheme.winBg
                    bold: true
                }

                Text {
                    text: "Drag title bars, resize ─┘ corners, or press F9."
                    color: TvTheme.winMutedFg
                    backgroundColor: TvTheme.winBg
                }

                TvButton {
                    width: 18
                    text: "Open ~D~ialog"
                    isDefault: true
                    surfaceColor: TvTheme.winBg
                    onClicked: demoDialog.open()
                }
            }
        }

        TvWindow {
            title: "Second Window"
            windowId: "2"
            x: 34
            y: 6
            width: 42
            height: 11

            Column {
                anchors.fill: parent
                anchors.margins: 1
                spacing: 1

                Text {
                    text: "Overlapping MDI + Translucent Shadow"
                    color: TvTheme.winFg
                    backgroundColor: TvTheme.winBg
                    bold: true
                }

                Text {
                    text: "Press W -> T to Tile or F6 to cycle focus."
                    color: TvTheme.winMutedFg
                    backgroundColor: TvTheme.winBg
                }
            }
        }
    }

    TvStatusLine {
        y: Math.max(0, root.height - 1)
        width: root.width
        hints: [
            {
                key: "F6",
                label: "Next",
                action: ""
            },
            {
                key: "F9",
                label: "Theme",
                action: "theme"
            },
            {
                key: "Alt+X",
                label: "Exit",
                action: "quit"
            }
        ]
        statusText: TvTheme.schemeTitle
        onActionTriggered: actionId => root.dispatch(actionId)
    }

    TvDialog {
        id: demoDialog

        objectName: "demoDialog"
        title: "Sample TvDialog"
        width: 44
        height: 9
        initialFocusItem: okBtn

        Column {
            anchors.fill: parent
            anchors.margins: 1
            spacing: 1

            Text {
                width: parent.width
                horizontalAlignment: Qt.AlignHCenter
                text: "3D Beveled TvButton & Mnemonics Ready"
                color: TvTheme.dialogFg
                backgroundColor: TvTheme.dialogBg
                bold: true
            }

            TvButton {
                id: okBtn

                anchors.horizontalCenter: parent.horizontalCenter
                width: 14
                text: "~O~K"
                isDefault: true
                surfaceColor: TvTheme.dialogBg
                onClicked: demoDialog.accept()
            }
        }
    }
}
