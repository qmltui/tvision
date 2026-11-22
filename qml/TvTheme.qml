pragma Singleton
pragma ComponentBehavior: Bound

import QtQml
import QmlTui
import "themes"

QtObject {
    id: theme

    property int schemeIndex: 0
    property int patternIndex: 0

    readonly property var patterns: ["░", "▒", "·", " "]
    readonly property string desktopPattern: theme.patterns[theme.patternIndex % theme.patterns.length]

    readonly property int schemeCount: d.schemes.length
    readonly property bool hasCustomPalette: d.customScheme !== null
    readonly property var schemeDescriptions: {
        let labels = [];
        for (let i = 0; i < d.schemes.length; ++i)
            labels.push(d.schemes[i].description);
        return labels;
    }

    // Active scheme metadata
    readonly property string schemeId: d.activeScheme.schemeId
    readonly property string schemeTitle: d.activeScheme.schemeTitle
    readonly property string schemeDescription: d.activeScheme.description
    readonly property bool isMonochrome: d.activeScheme.isMonochrome

    // Desktop stipple surface
    readonly property color desktopBg: d.activeScheme.desktopBg
    readonly property color desktopFg: d.activeScheme.desktopFg

    // MenuBar, pull-down Menu, & StatusLine
    readonly property color barBg: d.activeScheme.barBg
    readonly property color barFg: d.activeScheme.barFg
    readonly property color barHotkeyFg: d.activeScheme.barHotkeyFg
    readonly property color barSelectedBg: d.activeScheme.barSelectedBg
    readonly property color barSelectedFg: d.activeScheme.barSelectedFg
    readonly property color barSelectedHotkeyFg: d.activeScheme.barSelectedHotkeyFg
    readonly property color barDisabledFg: d.activeScheme.barDisabledFg
    readonly property color barBorderFg: d.activeScheme.barBorderFg

    // Editor / Document MDI Windows ("window" role)
    readonly property color winBg: d.activeScheme.winBg
    readonly property color winFg: d.activeScheme.winFg
    readonly property color winMutedFg: d.activeScheme.winMutedFg
    readonly property color winActiveBorder: d.activeScheme.winActiveBorder
    readonly property color winInactiveBorder: d.activeScheme.winInactiveBorder
    readonly property color winMoveBorder: d.activeScheme.winMoveBorder
    readonly property color winControlFg: d.activeScheme.winControlFg
    readonly property color winScrollBg: d.activeScheme.winScrollBg
    readonly property color winScrollFg: d.activeScheme.winScrollFg

    // Tool & Dialog Windows ("dialog" role)
    readonly property color dialogBg: d.activeScheme.dialogBg
    readonly property color dialogFg: d.activeScheme.dialogFg
    readonly property color dialogMutedFg: d.activeScheme.dialogMutedFg
    readonly property color dialogActiveBorder: d.activeScheme.dialogActiveBorder
    readonly property color dialogInactiveBorder: d.activeScheme.dialogInactiveBorder
    readonly property color dialogControlFg: d.activeScheme.dialogControlFg

    // Text inputs, lists, & selections inside dialogs/tools
    readonly property color inputBg: d.activeScheme.inputBg
    readonly property color inputFg: d.activeScheme.inputFg
    readonly property color listBg: d.activeScheme.listBg
    readonly property color listFg: d.activeScheme.listFg
    readonly property color listSelectedBg: d.activeScheme.listSelectedBg
    readonly property color listSelectedFg: d.activeScheme.listSelectedFg

    // 3D Beveled TvButton tokens
    readonly property color buttonBg: d.activeScheme.buttonBg
    readonly property color buttonFocusedBg: d.activeScheme.buttonFocusedBg
    readonly property color buttonFg: d.activeScheme.buttonFg
    readonly property color buttonDefaultFg: d.activeScheme.buttonDefaultFg
    readonly property color buttonHotkeyFg: d.activeScheme.buttonHotkeyFg
    readonly property color buttonShadowFg: d.activeScheme.buttonShadowFg

    function useCustomPalette(palette: var) {
        d.customScheme = palette as TvPalette;
    }

    function setSchemeByIndex(index: int) {
        if (theme.schemeCount <= 0)
            return;
        d.customScheme = null;
        theme.schemeIndex = ((index % theme.schemeCount) + theme.schemeCount) % theme.schemeCount;
    }

    function setScheme(name: string) {
        d.customScheme = null;
        for (let i = 0; i < d.schemes.length; ++i) {
            if (d.schemes[i].schemeId === name) {
                theme.schemeIndex = i;
                return;
            }
        }
        theme.schemeIndex = 0;
    }

    function cycleScheme() {
        theme.setSchemeByIndex(theme.schemeIndex + 1);
    }

    function cyclePattern() {
        theme.patternIndex = (theme.patternIndex + 1) % theme.patterns.length;
    }

    readonly property QtObject priv: QtObject {
        id: d

        property TvPalette customScheme: null
        readonly property list<TvPalette> schemes: [
            BorlandBlueTheme {},
            TurboCyanTheme {},
            DarkDosTheme {},
            MonochromeTheme {}
        ]
        readonly property TvPalette activeScheme: d.customScheme ? d.customScheme : d.schemes[theme.schemeIndex % d.schemes.length]
    }
}
