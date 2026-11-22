/** @param {Runner} app */
function main(app) {
    app.waitForText("Hello from QmlTui.TVision!");
    app.marker("Overlapping MDI & Drop Shadows");
    app.sleep(850);

    // Open pull-down menu and launch modal TvDialog
    app.marker("Pull-Down Menus & Beveled TvDialog");
    app.press("F");
    app.waitForText("Open Dialog...");
    app.sleep(500);
    app.press("D");
    app.waitForItem("demoDialog");
    app.sleep(750);
    app.press("O");
    app.sleep(500);

    // Tile & Cascade MDI windows
    app.marker("Tile & Cascade MDI Windows");
    app.press("W");
    app.sleep(350);
    app.press("T");
    app.sleep(800);

    app.press("W");
    app.sleep(350);
    app.press("A");
    app.sleep(700);

    // Cycle Borland / Cyan / Dark DOS / Monochrome themes
    app.marker("Per-File TvPalette Themes (F9)");
    app.press("F9");
    app.sleep(600);
    app.press("F9");
    app.sleep(600);
    app.press("F9");
    app.sleep(550);
    app.press("F9");
    app.sleep(800);

    app.stopRecording();
}
