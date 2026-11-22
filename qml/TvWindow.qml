pragma ComponentBehavior: Bound

import QtQml
import QmlTui

// Movable, resizable, zoomable, closable Turbo Vision MDI window with double/single
// active borders, `[■]` close button, window number, `[↕]` zoom toggle, bottom-right
// resize grip, `Ctrl+F5` keyboard move/resize mode, and translucent TvDropShadow.
FocusScope {
    id: win

    default property alias contentData: contentHost.data

    property string windowId: ""
    property string title: "Window"
    property string footerText: ""
    property string paletteRole: "window" // "window" (blue editor) or "dialog" (gray tool)
    property int windowNumber: 0
    property bool active: false
    property bool closable: true
    property bool interceptClose: false
    property bool zoomable: true
    property bool resizable: true
    property bool zoomed: false
    property bool moveResizeMode: false
    property int minWidth: 22
    property int minHeight: 6
    property Item preferredFocusItem: null

    property int savedX: 2
    property int savedY: 1
    property int savedWidth: 44
    property int savedHeight: 14
    property int dragStartX: 0
    property int dragStartY: 0
    property int dragStartW: 0
    property int dragStartH: 0

    readonly property bool isTvWindow: true
    readonly property int hostWidth: win.parent ? win.parent.width : 80
    readonly property int hostHeight: win.parent ? win.parent.height : 22
    readonly property bool isDialogRole: win.paletteRole === "dialog"

    readonly property color surfaceBg: win.isDialogRole ? TvTheme.dialogBg : TvTheme.winBg
    readonly property color surfaceFg: win.isDialogRole ? TvTheme.dialogFg : TvTheme.winFg
    readonly property color frameColor: {
        if (win.moveResizeMode)
            return TvTheme.winMoveBorder;
        if (win.active)
            return win.isDialogRole ? TvTheme.dialogActiveBorder : TvTheme.winActiveBorder;
        return win.isDialogRole ? TvTheme.dialogInactiveBorder : TvTheme.winInactiveBorder;
    }
    readonly property color controlGlyphFg: win.isDialogRole ? TvTheme.dialogControlFg : TvTheme.winControlFg

    readonly property string rightBadgeText: {
        let parts = [];
        if (win.windowNumber >= 1 && win.windowNumber <= 9)
            parts.push(String(win.windowNumber));
        if (win.zoomable)
            parts.push(win.zoomed ? "[◊]" : "[↕]");
        return parts.join(" ");
    }

    readonly property int leftReserve: win.closable ? 6 : 2
    readonly property int rightReserve: win.rightBadgeText.length > 0 ? win.rightBadgeText.length + 3 : 2
    readonly property int maxTitleChars: Math.max(0, win.width - win.leftReserve - win.rightReserve - 2)
    readonly property string clippedTitle: {
        if (win.maxTitleChars <= 0)
            return "";
        const raw = win.moveResizeMode ? (win.title + " [MOVE/SIZE]") : win.title;
        return raw.length > win.maxTitleChars ? raw.slice(0, win.maxTitleChars) : raw;
    }
    readonly property int titleSpanWidth: win.clippedTitle.length > 0 ? win.clippedTitle.length + 2 : 0
    readonly property int titleX: Math.max(win.leftReserve, Math.floor((win.width - win.titleSpanWidth) / 2))

    signal activated
    signal closeRequested

    function focusWindow() {
        if (win.preferredFocusItem && win.preferredFocusItem.visible && win.preferredFocusItem.enabled)
            win.preferredFocusItem.forceActiveFocus();
        else
            win.forceActiveFocus();
    }

    function requestActivate() {
        if (!win.active)
            win.activated();
        win.focusWindow();
    }

    function toggleZoom() {
        if (!win.zoomable)
            return;
        if (!win.zoomed) {
            win.savedX = win.x;
            win.savedY = win.y;
            win.savedWidth = win.width;
            win.savedHeight = win.height;
            win.x = 0;
            win.y = 0;
            win.width = Math.max(win.minWidth, win.hostWidth);
            win.height = Math.max(win.minHeight, win.hostHeight);
            win.zoomed = true;
        } else {
            win.zoomed = false;
            win.setRestoredGeometry(win.savedX, win.savedY, win.savedWidth, win.savedHeight);
        }
    }

    function setRestoredGeometry(nx: int, ny: int, nw: int, nh: int) {
        win.zoomed = false;
        win.moveResizeMode = false;
        const maxW = Math.max(win.minWidth, win.hostWidth);
        const maxH = Math.max(win.minHeight, win.hostHeight);
        const clampedW = Math.max(win.minWidth, Math.min(nw, maxW));
        const clampedH = Math.max(win.minHeight, Math.min(nh, maxH));
        const clampedX = Math.max(0, Math.min(nx, Math.max(0, win.hostWidth - Math.min(clampedW, 8))));
        const clampedY = Math.max(0, Math.min(ny, Math.max(0, win.hostHeight - 2)));
        win.x = clampedX;
        win.y = clampedY;
        win.width = clampedW;
        win.height = clampedH;
    }

    function clampToDesktop(availW: int, availH: int) {
        if (availW <= 0 || availH <= 0)
            return;
        if (win.zoomed) {
            win.x = 0;
            win.y = 0;
            win.width = Math.max(Math.min(win.minWidth, availW), availW);
            win.height = Math.max(Math.min(win.minHeight, availH), availH);
            return;
        }
        const effMinW = Math.min(win.minWidth, availW);
        const effMinH = Math.min(win.minHeight, availH);
        if (win.width > availW)
            win.width = Math.max(effMinW, availW);
        if (win.height > availH)
            win.height = Math.max(effMinH, availH);
        if (win.x + win.width > availW)
            win.x = Math.max(0, availW - win.width);
        if (win.y + win.height > availH)
            win.y = Math.max(0, availH - win.height);
    }

    width: 44
    height: 14
    focusPolicy: Qt.StrongFocus

    onActiveFocusChanged: {
        if (win.activeFocus) {
            if (!win.active)
                win.activated();
        } else {
            win.moveResizeMode = false;
        }
    }

    Keys.priority: Keys.BeforeItem
    Keys.onPressed: event => {
        if (!win.moveResizeMode)
            return;
        const shift = (event.modifiers & Qt.ShiftModifier) !== 0;
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Escape) {
            win.moveResizeMode = false;
            event.accepted = true;
            return;
        }
        if (win.zoomed) {
            event.accepted = true;
            return;
        }
        if (shift && win.resizable) {
            if (event.key === Qt.Key_Right) {
                win.width = Math.min(win.hostWidth - win.x, win.width + 1);
                event.accepted = true;
            } else if (event.key === Qt.Key_Left) {
                win.width = Math.max(win.minWidth, win.width - 1);
                event.accepted = true;
            } else if (event.key === Qt.Key_Down) {
                win.height = Math.min(win.hostHeight - win.y, win.height + 1);
                event.accepted = true;
            } else if (event.key === Qt.Key_Up) {
                win.height = Math.max(win.minHeight, win.height - 1);
                event.accepted = true;
            }
        } else {
            if (event.key === Qt.Key_Right) {
                win.x = Math.min(Math.max(0, win.hostWidth - 6), win.x + 1);
                event.accepted = true;
            } else if (event.key === Qt.Key_Left) {
                win.x = Math.max(0, win.x - 1);
                event.accepted = true;
            } else if (event.key === Qt.Key_Down) {
                win.y = Math.min(Math.max(0, win.hostHeight - 2), win.y + 1);
                event.accepted = true;
            } else if (event.key === Qt.Key_Up) {
                win.y = Math.max(0, win.y - 1);
                event.accepted = true;
            }
        }
    }

    TvDropShadow {
        visible: !win.zoomed
        x: 0
        y: 0
        z: -1
        width: win.width + 2
        height: win.height + 1
        horizontalOffset: 2
        verticalOffset: 1
    }

    Rectangle {
        id: frameRect

        anchors.fill: parent
        color: win.surfaceBg
        border.style: win.moveResizeMode ? Border.Single : (win.active ? Border.Double : Border.Single)
        border.color: win.frameColor

        // Catch clicks on non-focusable labels or empty client space to raise window
        MouseArea {
            anchors.fill: parent
            z: -0.5
            onPressed: _event => {
                win.requestActivate();
            }
        }

        // Top-left `[■]` close box
        Text {
            visible: win.closable && win.width >= 10
            x: 2
            y: 0
            z: 1.5
            spans: [QmlTui.span("[", {
                    color: win.frameColor,
                    backgroundColor: win.surfaceBg
                }), QmlTui.span("■", {
                    color: win.controlGlyphFg,
                    backgroundColor: win.surfaceBg,
                    bold: true
                }), QmlTui.span("]", {
                    color: win.frameColor,
                    backgroundColor: win.surfaceBg
                })]
        }

        MouseArea {
            visible: win.closable && win.width >= 10
            x: 2
            y: 0
            z: 3
            width: 3
            height: 1
            onClicked: _event => {
                win.closeRequested();
            }
        }

        // Centered window title
        Text {
            visible: win.titleSpanWidth > 0
            x: win.titleX
            y: 0
            z: 1.5
            text: " " + win.clippedTitle + " "
            color: win.frameColor
            backgroundColor: win.surfaceBg
            bold: win.active
        }

        // Top-right window number & `[↕]` zoom box
        Text {
            id: rightBadge

            visible: win.rightBadgeText.length > 0 && win.width >= 14
            x: Math.max(win.leftReserve, win.width - win.rightBadgeText.length - 2)
            y: 0
            z: 1.5
            spans: {
                let out = [];
                if (win.windowNumber >= 1 && win.windowNumber <= 9) {
                    out.push(QmlTui.span(String(win.windowNumber) + (win.zoomable ? " " : ""), {
                        color: win.frameColor,
                        backgroundColor: win.surfaceBg
                    }));
                }
                if (win.zoomable) {
                    out.push(QmlTui.span("[", {
                        color: win.frameColor,
                        backgroundColor: win.surfaceBg
                    }));
                    out.push(QmlTui.span(win.zoomed ? "◊" : "↕", {
                        color: win.controlGlyphFg,
                        backgroundColor: win.surfaceBg,
                        bold: true
                    }));
                    out.push(QmlTui.span("]", {
                        color: win.frameColor,
                        backgroundColor: win.surfaceBg
                    }));
                }
                return out;
            }
        }

        MouseArea {
            visible: win.zoomable && win.width >= 14
            x: Math.max(0, win.width - 5)
            y: 0
            z: 3
            width: 3
            height: 1
            onClicked: _event => {
                win.requestActivate();
                win.toggleZoom();
            }
        }

        // Title-bar drag handle (screen-space deltas via TvDragHandle)
        TvDragHandle {
            x: 0
            y: 0
            z: 2
            width: win.width
            height: 1
            onDragStarted: (_sx, _sy) => {
                win.requestActivate();
                win.dragStartX = win.x;
                win.dragStartY = win.y;
            }
            onDragMoved: (dx, dy, _sx, _sy) => {
                if (win.zoomed)
                    return;
                const maxX = Math.max(0, win.hostWidth - Math.min(win.width, 8));
                const maxY = Math.max(0, win.hostHeight - 2);
                win.x = Math.max(0, Math.min(maxX, win.dragStartX + dx));
                win.y = Math.max(0, Math.min(maxY, win.dragStartY + dy));
            }
        }

        // Bottom-left status/footer slot
        Text {
            visible: win.footerText.length > 0 && win.width > win.footerText.length + 8
            x: 2
            y: Math.max(0, win.height - 1)
            z: 1.5
            text: " " + win.footerText + " "
            color: win.frameColor
            backgroundColor: win.surfaceBg
        }

        // Bottom-right Borland single-line green resize corner (`─┘`)
        Text {
            visible: win.resizable && !win.zoomed && win.width >= 6 && win.height >= 3
            x: Math.max(0, win.width - 2)
            y: Math.max(0, win.height - 1)
            z: 1.5
            text: "─┘"
            color: win.controlGlyphFg
            backgroundColor: win.surfaceBg
            bold: true
        }

        TvDragHandle {
            visible: win.resizable && !win.zoomed
            x: Math.max(0, win.width - 2)
            y: Math.max(0, win.height - 1)
            z: 3
            width: 2
            height: 1
            onDragStarted: (_sx, _sy) => {
                win.requestActivate();
                win.dragStartW = win.width;
                win.dragStartH = win.height;
            }
            onDragMoved: (dx, dy, _sx, _sy) => {
                if (win.zoomed || !win.resizable)
                    return;
                const maxW = Math.max(win.minWidth, win.hostWidth - win.x);
                const maxH = Math.max(win.minHeight, win.hostHeight - win.y);
                win.width = Math.max(Math.min(win.minWidth, maxW), Math.min(maxW, win.dragStartW + dx));
                win.height = Math.max(Math.min(win.minHeight, maxH), Math.min(maxH, win.dragStartH + dy));
            }
        }

        // Clipped client content area (automatically inset 1 cell inside border)
        Item {
            id: contentHost

            anchors.fill: parent
            clip: true
        }
    }
}
