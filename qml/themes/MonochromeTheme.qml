pragma ComponentBehavior: Bound

import QmlTui.TVision

// Classic IBM MDA / Hercules monochrome black-and-white scheme (pairs color
// contrast with underlined hotkeys and bold selection cues).
TvPalette {
    schemeId: "monochrome"
    schemeTitle: "Monochrome"
    description: "Monochrome (Hercules / MDA)"
    isMonochrome: true

    desktopBg: "#000000"
    desktopFg: "#767676"

    barBg: "#b8b8b8"
    barFg: "#000000"
    barHotkeyFg: "#000000"
    barSelectedBg: "#000000"
    barSelectedFg: "#ffffff"
    barSelectedHotkeyFg: "#ffffff"
    barDisabledFg: "#6c6c6c"
    barBorderFg: "#000000"

    winBg: "#000000"
    winFg: "#d0d0d0"
    winMutedFg: "#8a8a8a"
    winActiveBorder: "#ffffff"
    winInactiveBorder: "#9e9e9e"
    winMoveBorder: "#ffffff"
    winControlFg: "#ffffff"
    winScrollBg: "#262626"
    winScrollFg: "#d0d0d0"

    dialogBg: "#000000"
    dialogFg: "#e0e0e0"
    dialogMutedFg: "#9e9e9e"
    dialogActiveBorder: "#ffffff"
    dialogInactiveBorder: "#6c6c6c"
    dialogControlFg: "#ffffff"

    inputBg: "#262626"
    inputFg: "#ffffff"
    listBg: "#000000"
    listFg: "#d0d0d0"
    listSelectedBg: "#ffffff"
    listSelectedFg: "#000000"

    buttonBg: "#d0d0d0"
    buttonFocusedBg: "#ffffff"
    buttonFg: "#000000"
    buttonDefaultFg: "#000000"
    buttonHotkeyFg: "#000000"
    buttonShadowFg: "#000000"
}
