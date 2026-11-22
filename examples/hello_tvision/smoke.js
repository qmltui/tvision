/** @param {Runner} app */
function main(app) {
    app.waitForText("Hello from QmlTui.TVision!");
    app.press("F");
    app.waitForText("Open Dialog...");
    app.press("D");
    app.waitForItem("demoDialog");
    app.press("O");
    app.press("F9");
    app.expectText("Turbo Cyan");
    app.press("X", ["Alt"]);
}
