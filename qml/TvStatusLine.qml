pragma ComponentBehavior: Bound

import QtQml
import QmlTui

// Bottom 1-row Turbo Vision status/command line displaying clickable hotkey
// hints (`~F1~ Help`, `~F3~ Open`, `~Alt+X~ Exit`) and right-aligned status text.
Rectangle {
    id: statusLine

    // Array of `{ key: "F1", label: "Help", action: "help.shortcuts" }`
    property var hints: []
    property string statusText: ""

    signal actionTriggered(string actionId)

    height: 1
    implicitHeight: 1
    color: TvTheme.barBg
    clip: true

    Row {
        id: hintsRow

        x: 1
        y: 0
        height: 1
        spacing: 1

        Repeater {
            model: statusLine.hints

            delegate: Item {
                id: hintDelegate

                required property var modelData
                required property int index

                readonly property string keyText: hintDelegate.modelData.key || ""
                readonly property string labelText: hintDelegate.modelData.label || ""
                readonly property string actionId: hintDelegate.modelData.action || ""
                readonly property bool highlighted: hintMouse.containsPress || hintMouse.containsMouse

                width: hintText.implicitWidth
                height: 1

                Text {
                    id: hintText

                    height: 1
                    spans: {
                        const bg = hintDelegate.highlighted ? TvTheme.barSelectedBg : TvTheme.barBg;
                        const keyFg = hintDelegate.highlighted ? TvTheme.barSelectedHotkeyFg : TvTheme.barHotkeyFg;
                        const lblFg = hintDelegate.highlighted ? TvTheme.barSelectedFg : TvTheme.barFg;
                        return [QmlTui.span(" " + hintDelegate.keyText + " ", {
                                color: keyFg,
                                backgroundColor: bg,
                                bold: true,
                                underline: TvTheme.isMonochrome
                            }), QmlTui.span(hintDelegate.labelText + " ", {
                                color: lblFg,
                                backgroundColor: bg,
                                bold: false
                            })];
                    }
                }

                MouseArea {
                    id: hintMouse

                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: _event => {
                        if (hintDelegate.actionId !== "")
                            statusLine.actionTriggered(hintDelegate.actionId);
                    }
                }
            }
        }
    }

    Text {
        visible: statusLine.statusText.length > 0 && statusLine.width > hintsRow.implicitWidth + statusLine.statusText.length + 4
        anchors.right: parent.right
        anchors.rightMargin: 1
        y: 0
        text: "│ " + statusLine.statusText
        color: TvTheme.barFg
        backgroundColor: TvTheme.barBg
    }
}
