pragma Singleton
pragma ComponentBehavior: Bound

import QtQml
import QmlTui
import "themes"

QtObject {
    id: theme

    property int schemeIndex: 0
    property int patternIndex: 0
    property TvPalette customPalette: null
    property alias customScheme: theme.customPalette
    property var customSchemes: []
    property bool includeBuiltInSchemes: true

    readonly property var patterns: ["░", "▒", "·", " "]
    readonly property string desktopPattern: theme.patterns[theme.patternIndex % theme.patterns.length]

    readonly property TvPalette activePalette: d.activeScheme
    readonly property int schemeCount: d.effectiveSchemes.length
    readonly property bool hasCustomPalette: theme.customPalette !== null
    readonly property var schemeIds: {
        let ids = [];
        const list = d.effectiveSchemes;
        for (let i = 0; i < list.length; ++i) {
            const pal = list[i] as TvPalette;
            if (pal)
                ids.push(pal.schemeId);
        }
        return ids;
    }
    readonly property var schemeTitles: {
        let titles = [];
        const list = d.effectiveSchemes;
        for (let i = 0; i < list.length; ++i) {
            const pal = list[i] as TvPalette;
            if (pal)
                titles.push(pal.schemeTitle);
        }
        return titles;
    }
    readonly property var schemeDescriptions: {
        let labels = [];
        const list = d.effectiveSchemes;
        for (let i = 0; i < list.length; ++i) {
            const pal = list[i] as TvPalette;
            if (pal)
                labels.push(pal.description);
        }
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
        theme.customPalette = palette as TvPalette;
    }

    function clearCustomPalette() {
        theme.customPalette = null;
    }

    function builtInScheme(name: string): TvPalette {
        for (let i = 0; i < d.builtInSchemes.length; ++i) {
            if (d.builtInSchemes[i].schemeId === name)
                return d.builtInSchemes[i];
        }
        return d.builtInSchemes[0];
    }

    function findScheme(name: string): TvPalette {
        const list = d.effectiveSchemes;
        for (let i = 0; i < list.length; ++i) {
            const pal = list[i] as TvPalette;
            if (pal && pal.schemeId === name)
                return pal;
        }
        for (let i = 0; i < d.builtInSchemes.length; ++i) {
            if (d.builtInSchemes[i].schemeId === name)
                return d.builtInSchemes[i];
        }
        return null;
    }

    function schemeAt(index: int): TvPalette {
        const list = d.effectiveSchemes;
        if (index < 0 || index >= list.length)
            return null;
        return list[index] as TvPalette;
    }

    function createPalette(tokens: var): TvPalette {
        const created = d.paletteFactory.createObject(d) as TvPalette;
        if (!created)
            return null;
        const baseName = (tokens && tokens.baseScheme) ? String(tokens.baseScheme) : "borland_blue";
        const base = theme.findScheme(baseName);
        created.copyFrom(base ? base : theme.builtInScheme(baseName));
        if (tokens)
            created.applyMap(tokens);
        return created;
    }

    function applyCustomTheme(tokens: var): TvPalette {
        const created = theme.createPalette(tokens);
        if (!created)
            return null;
        d.ownedOverridePalette = created;
        theme.customPalette = created;
        return created;
    }

    function registerScheme(palette: TvPalette): int {
        if (!palette)
            return -1;
        let next = [];
        const cur = theme.customSchemes || [];
        let replaced = false;
        for (let i = 0; i < cur.length; ++i) {
            const existing = cur[i] as TvPalette;
            if (!existing)
                continue;
            if (existing === palette || (palette.schemeId !== "" && existing.schemeId === palette.schemeId)) {
                if (existing !== palette)
                    d.releaseOwnedScheme(existing);
                if (!replaced) {
                    next.push(palette);
                    replaced = true;
                }
            } else {
                next.push(existing);
            }
        }
        if (!replaced)
            next.push(palette);
        theme.customSchemes = next;
        const all = d.effectiveSchemes;
        for (let i = 0; i < all.length; ++i) {
            if ((all[i] as TvPalette) === palette)
                return i;
        }
        return -1;
    }

    function registerThemeObject(tokens: var): TvPalette {
        const created = theme.createPalette(tokens);
        if (!created)
            return null;
        d.ownedSchemes.push(created);
        theme.registerScheme(created);
        return created;
    }

    function unregisterScheme(schemeOrId: var): bool {
        const cur = theme.customSchemes || [];
        let next = [];
        let removed = false;
        const targetPal = schemeOrId as TvPalette;
        const targetId = targetPal ? "" : String(schemeOrId || "");
        for (let i = 0; i < cur.length; ++i) {
            const existing = cur[i] as TvPalette;
            if (!existing)
                continue;
            const match = targetPal ? (existing === targetPal) : (targetId !== "" && existing.schemeId === targetId);
            if (match) {
                removed = true;
                d.releaseOwnedScheme(existing);
            } else {
                next.push(existing);
            }
        }
        if (removed) {
            theme.customSchemes = next;
            if (theme.schemeCount > 0)
                theme.schemeIndex = theme.schemeIndex % theme.schemeCount;
        }
        return removed;
    }

    function clearCustomSchemes() {
        const cur = theme.customSchemes || [];
        theme.customSchemes = [];
        for (let i = 0; i < cur.length; ++i) {
            const existing = cur[i] as TvPalette;
            if (existing)
                d.releaseOwnedScheme(existing);
        }
        if (theme.schemeCount > 0)
            theme.schemeIndex = theme.schemeIndex % theme.schemeCount;
    }

    function setSchemeByIndex(index: int) {
        if (theme.schemeCount <= 0)
            return;
        theme.customPalette = null;
        theme.schemeIndex = ((index % theme.schemeCount) + theme.schemeCount) % theme.schemeCount;
    }

    function setScheme(name: string) {
        theme.customPalette = null;
        const list = d.effectiveSchemes;
        for (let i = 0; i < list.length; ++i) {
            const pal = list[i] as TvPalette;
            if (pal && pal.schemeId === name) {
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

    onCustomPaletteChanged: {
        if (d.ownedOverridePalette && d.ownedOverridePalette !== theme.customPalette) {
            const stale = d.ownedOverridePalette;
            d.ownedOverridePalette = null;
            stale.destroy();
        }
    }

    readonly property QtObject priv: QtObject {
        id: d

        property TvPalette ownedOverridePalette: null
        property var ownedSchemes: []

        readonly property Component paletteFactory: Component {
            TvPalette {}
        }

        readonly property list<TvPalette> builtInSchemes: [
            BorlandBlueTheme {},
            TurboCyanTheme {},
            DarkDosTheme {},
            MonochromeTheme {}
        ]

        readonly property var effectiveSchemes: {
            let list = [];
            if (theme.includeBuiltInSchemes) {
                for (let i = 0; i < d.builtInSchemes.length; ++i)
                    list.push(d.builtInSchemes[i]);
            }
            const extras = theme.customSchemes || [];
            for (let i = 0; i < extras.length; ++i) {
                const pal = extras[i] as TvPalette;
                if (pal)
                    list.push(pal);
            }
            if (list.length === 0)
                list.push(d.builtInSchemes[0]);
            return list;
        }

        readonly property TvPalette activeScheme: {
            if (theme.customPalette)
                return theme.customPalette;
            const list = d.effectiveSchemes;
            const count = list.length;
            const idx = ((theme.schemeIndex % count) + count) % count;
            const chosen = list[idx] as TvPalette;
            return chosen ? chosen : d.builtInSchemes[0];
        }

        function releaseOwnedScheme(pal: TvPalette) {
            const idx = d.ownedSchemes.indexOf(pal);
            if (idx < 0)
                return;
            d.ownedSchemes.splice(idx, 1);
            if (theme.customPalette !== pal)
                pal.destroy();
        }
    }
}
