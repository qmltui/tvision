pragma Singleton
pragma ComponentBehavior: Bound

import QtQml
import QmlTui

QtObject {
    // Strips `~mnemonic~` markers: "~F~ile" -> "File"
    function strip(label: string): string {
        if (!label)
            return "";
        return label.replace(/~([^~])~/g, "$1");
    }

    // Extracts uppercased mnemonic character: "E~x~it" -> "X", or "" if absent
    function mnemonicChar(label: string): string {
        if (!label)
            return "";
        const match = /~([^~])~/.exec(label);
        return match ? match[1].toUpperCase() : "";
    }

    // Builds QmlTui.span runs coloring `~X~` with `hotkeyFg` (and underlining when `underlineHotkey` is true)
    function buildSpans(label: string, normalFg: color, hotkeyFg: color, bg: color, boldText: bool, underlineHotkey: bool): var {
        let out = [];
        if (!label)
            return out;

        let idx = 0;
        const re = /~([^~])~/g;
        let match = re.exec(label);
        while (match !== null) {
            if (match.index > idx) {
                out.push(QmlTui.span(label.slice(idx, match.index), {
                    color: normalFg,
                    backgroundColor: bg,
                    bold: boldText
                }));
            }
            out.push(QmlTui.span(match[1], {
                color: hotkeyFg,
                backgroundColor: bg,
                bold: true,
                underline: underlineHotkey
            }));
            idx = match.index + match[0].length;
            match = re.exec(label);
        }
        if (idx < label.length) {
            out.push(QmlTui.span(label.slice(idx), {
                color: normalFg,
                backgroundColor: bg,
                bold: boldText
            }));
        }
        return out;
    }
}
