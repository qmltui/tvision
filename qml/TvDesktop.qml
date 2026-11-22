pragma ComponentBehavior: Bound

import QtQml
import QmlTui

// Multi-Document Interface (MDI) workspace managing overlapping TvWindow items:
// z-order activation, 1..9 window numbering, F6 cycling, F5 zoom, Ctrl+F5
// keyboard move/resize, Tile, Cascade, and responsive viewport clamping.
Item {
    id: desktop

    default property alias workspaceData: windowLayer.data

    property var activeWindow: null
    property int topZCounter: 10

    signal windowClosed(var window)
    signal closeIntercepted(var window)

    function visibleWindows(): var {
        let list = [];
        const kids = windowLayer.children;
        for (let i = 0; i < kids.length; ++i) {
            const w = kids[i];
            if (w && Boolean(w["isTvWindow"]) && w.visible)
                list.push(w);
        }
        return list;
    }

    function allWindows(): var {
        let list = [];
        const kids = windowLayer.children;
        for (let i = 0; i < kids.length; ++i) {
            const w = kids[i];
            if (w && Boolean(w["isTvWindow"]))
                list.push(w);
        }
        return list;
    }

    function refreshWindowNumbers() {
        const all = desktop.allWindows();
        let num = 1;
        for (let i = 0; i < all.length; ++i) {
            const w = all[i];
            if (w.visible) {
                w.windowNumber = num <= 9 ? num : 0;
                num += 1;
            } else {
                w.windowNumber = 0;
            }
            w.active = (w === desktop.activeWindow && w.visible);
        }
    }

    function activateWindow(target: var) {
        if (!target || d.activating)
            return;
        d.activating = true;
        if (!target.visible)
            target.visible = true;
        if (desktop.activeWindow !== target) {
            desktop.topZCounter += 1;
            target.z = desktop.topZCounter;
            desktop.activeWindow = target;
        } else if (target.z < desktop.topZCounter) {
            desktop.topZCounter += 1;
            target.z = desktop.topZCounter;
        }
        desktop.refreshWindowNumbers();
        if (!target.activeFocus)
            target.focusWindow();
        d.activating = false;
    }

    function activateTopmostVisible() {
        const wins = desktop.visibleWindows();
        if (wins.length === 0) {
            desktop.activeWindow = null;
            desktop.refreshWindowNumbers();
            return;
        }
        let best = wins[0];
        for (let i = 1; i < wins.length; ++i) {
            if (wins[i].z >= best.z)
                best = wins[i];
        }
        desktop.activateWindow(best);
    }

    function forceCloseWindow(target: var) {
        if (!target || !target.closable)
            return;
        target.moveResizeMode = false;
        target.visible = false;
        desktop.windowClosed(target);
        if (desktop.activeWindow === target)
            desktop.activateTopmostVisible();
        else
            desktop.refreshWindowNumbers();
    }

    function closeWindow(target: var) {
        if (!target || !target.closable)
            return;
        if (target.interceptClose) {
            desktop.closeIntercepted(target);
            return;
        }
        desktop.forceCloseWindow(target);
    }

    function closeActive() {
        if (desktop.activeWindow)
            desktop.closeWindow(desktop.activeWindow);
    }

    function closeAll() {
        const wins = desktop.visibleWindows();
        for (let i = 0; i < wins.length; ++i) {
            if (wins[i].closable) {
                wins[i].moveResizeMode = false;
                wins[i].visible = false;
            }
        }
        desktop.activateTopmostVisible();
    }

    function cycleNext() {
        const wins = desktop.visibleWindows();
        if (wins.length === 0)
            return;
        let idx = wins.indexOf(desktop.activeWindow);
        const nextIdx = (idx + 1) % wins.length;
        desktop.activateWindow(wins[nextIdx]);
    }

    function cyclePrevious() {
        const wins = desktop.visibleWindows();
        if (wins.length === 0)
            return;
        let idx = wins.indexOf(desktop.activeWindow);
        if (idx < 0)
            idx = 0;
        const prevIdx = (idx - 1 + wins.length) % wins.length;
        desktop.activateWindow(wins[prevIdx]);
    }

    function toggleZoomActive() {
        if (desktop.activeWindow)
            desktop.activeWindow.toggleZoom();
    }

    function enterMoveResizeActive() {
        if (!desktop.activeWindow || desktop.activeWindow.zoomed)
            return;
        desktop.activeWindow.moveResizeMode = !desktop.activeWindow.moveResizeMode;
        desktop.activeWindow.forceActiveFocus();
    }

    function activateByNumber(num: int) {
        const wins = desktop.visibleWindows();
        for (let i = 0; i < wins.length; ++i) {
            if (wins[i].windowNumber === num) {
                desktop.activateWindow(wins[i]);
                return;
            }
        }
    }

    function cascade() {
        const wins = desktop.visibleWindows();
        if (wins.length === 0)
            return;
        const availW = Math.max(24, desktop.width);
        const availH = Math.max(8, desktop.height);
        const targetW = Math.max(24, Math.floor(availW * 0.68));
        const targetH = Math.max(8, Math.floor(availH * 0.70));

        for (let i = 0; i < wins.length; ++i) {
            const w = wins[i];
            const step = i % 6;
            const nw = w.zoomable ? Math.max(w.minWidth, targetW) : w.width;
            const nh = w.zoomable ? Math.max(w.minHeight, targetH) : w.height;
            const nx = Math.min(step * 3 + 1, Math.max(0, availW - nw - 2));
            const ny = Math.min(step * 2, Math.max(0, availH - nh - 1));
            w.setRestoredGeometry(nx, ny, nw, nh);
            desktop.topZCounter += 1;
            w.z = desktop.topZCounter;
        }
        desktop.activateWindow(wins[wins.length - 1]);
    }

    function tile() {
        const wins = desktop.visibleWindows();
        const count = wins.length;
        if (count === 0)
            return;

        const availW = Math.max(20, desktop.width);
        const availH = Math.max(6, desktop.height);
        const cols = Math.ceil(Math.sqrt(count));
        const rows = Math.ceil(count / cols);

        let idx = 0;
        for (let r = 0; r < rows && idx < count; ++r) {
            const remaining = count - idx;
            const colsInRow = (r === rows - 1) ? remaining : Math.min(cols, remaining);
            const y0 = Math.floor((r * availH) / rows);
            const y1 = Math.floor(((r + 1) * availH) / rows);
            const cellH = Math.max(4, y1 - y0);

            for (let c = 0; c < colsInRow && idx < count; ++c) {
                const x0 = Math.floor((c * availW) / colsInRow);
                const x1 = Math.floor(((c + 1) * availW) / colsInRow);
                const cellW = Math.max(16, x1 - x0);
                const w = wins[idx];
                w.zoomed = false;
                w.moveResizeMode = false;
                w.x = x0;
                w.y = y0;
                w.width = cellW;
                w.height = cellH;
                idx += 1;
            }
        }
        desktop.refreshWindowNumbers();
    }

    function clampAllWindows() {
        if (desktop.width <= 0 || desktop.height <= 0)
            return;
        const all = desktop.allWindows();
        for (let i = 0; i < all.length; ++i)
            all[i].clampToDesktop(desktop.width, desktop.height);
    }

    function wireOneWindow(w: var) {
        w.activated.connect(function () {
            desktop.activateWindow(w);
        });
        w.closeRequested.connect(function () {
            desktop.closeWindow(w);
        });
        w.visibleChanged.connect(function () {
            desktop.refreshWindowNumbers();
        });
    }

    function wireChildren() {
        const all = desktop.allWindows();
        for (let i = 0; i < all.length; ++i) {
            const w = all[i];
            if (d.wiredWindows.indexOf(w) >= 0)
                continue;
            d.wiredWindows.push(w);
            desktop.wireOneWindow(w);
        }
        desktop.clampAllWindows();
        if (!desktop.activeWindow || !desktop.activeWindow.visible)
            desktop.activateTopmostVisible();
        else
            desktop.refreshWindowNumbers();
    }

    clip: true

    onWidthChanged: desktop.clampAllWindows()
    onHeightChanged: desktop.clampAllWindows()
    Component.onCompleted: desktop.wireChildren()

    QtObject {
        id: d

        property bool activating: false
        property var wiredWindows: []
    }

    TvDesktopSurface {
        anchors.fill: parent
        pattern: TvTheme.desktopPattern
        foregroundColor: TvTheme.desktopFg
        backgroundColor: TvTheme.desktopBg
    }

    Item {
        id: windowLayer

        anchors.fill: parent
        onChildrenChanged: desktop.wireChildren()
    }
}
