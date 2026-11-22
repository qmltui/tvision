#include "TvDesktopSurface.h"
#include "TvDragHandle.h"
#include "TvDropShadow.h"
#include "TvPalette.h"

#include <QQmlComponent>
#include <QQmlEngine>
#include <QSignalSpy>
#include <QmlTui/Core/Engine/MouseEvent.h>
#include <QmlTui/Core/Primitives/TextGridBuffer.h>
#include <QtTest/QtTest>

using namespace qmltui;
using namespace qmltui::tvision;

class TestTVisionPrimitives : public QObject {
  Q_OBJECT

private slots:
  void desktopSurfaceFillsStippleAndHonorsClip() {
    TextGridBuffer buf;
    buf.resize(20, 8);

    TvDesktopSurface surface;
    surface.setWidth(20);
    surface.setHeight(8);
    surface.setPattern(QStringLiteral("▒"));
    surface.setForegroundColor(Color::fromArgb32(0xFF55FFFFU));
    surface.setBackgroundColor(Color::fromArgb32(0xFF000080U));

    const Item::DirtyFlags flagsBeforePaint = surface.dirtyFlags();
    surface.paint(buf, 0, 0, ClipRect{2, 1, 5, 3});

    // Outside clip rect remains untouched space
    QCOMPARE(buf.cellAt(0, 0).character(), QByteArrayView(" "));
    // Inside clip rect contains stipple glyph and exact RGB colors
    const Cell &c = buf.cellAt(3, 2);
    QCOMPARE(c.character(), QByteArrayView("▒"));
    QCOMPARE(c.fgColor, 0xFF55FFFFU);
    QCOMPARE(c.bgColor, 0xFF000080U);
    // paint() must never schedule new dirty invalidations
    QCOMPARE(surface.dirtyFlags(), flagsBeforePaint);
  }

  void dropShadowDarkensUnderlyingGlyphsWithoutErasingAndIsClickThrough() {
    TextGridBuffer buf;
    buf.resize(16, 10);

    TvDesktopSurface surface;
    surface.setWidth(16);
    surface.setHeight(10);
    surface.setPattern(QStringLiteral("░"));
    surface.setForegroundColor(Color::fromArgb32(0xFF80C0FFU));
    surface.setBackgroundColor(Color::fromArgb32(0xFF004080U));
    surface.paint(buf, 0, 0, ClipRect{0, 0, 16, 10});

    TvDropShadow shadow;
    QVERIFY(!shadow.enabled()); // Click-through invariant
    shadow.setWidth(10);        // 8x5 body + 2x1 L-shadow
    shadow.setHeight(6);
    shadow.setHorizontalOffset(2);
    shadow.setVerticalOffset(1);
    shadow.setFactor(0.5);

    shadow.paint(buf, 2, 1, ClipRect{0, 0, 16, 10});

    // Body interior (x=4, y=2) is NOT shaded by the L-band
    const Cell &unshaded = buf.cellAt(4, 2);
    QCOMPARE(unshaded.character(), QByteArrayView("░"));
    QCOMPARE(unshaded.fgColor, 0xFF80C0FFU);
    QCOMPARE(unshaded.bgColor, 0xFF004080U);

    // Right shadow band (x=10, y=3) preserves '░' glyph while darkening RGB
    // ~50% + Dim
    const Cell &rightShadow = buf.cellAt(10, 3);
    QCOMPARE(rightShadow.character(), QByteArrayView("░"));
    QVERIFY((rightShadow.fgColor & 0x00FFFFFFU) < (0xFF80C0FFU & 0x00FFFFFFU));
    QVERIFY((rightShadow.bgColor & 0x00FFFFFFU) < (0xFF004080U & 0x00FFFFFFU));
    QVERIFY((rightShadow.attributes & TextAttribute::Dim) ==
            TextAttribute::Dim);

    // Bottom shadow band (x=5, y=6) is also darkened, while top-right (x=10,
    // y=1) is unshaded
    const Cell &bottomShadow = buf.cellAt(5, 6);
    QCOMPARE(bottomShadow.character(), QByteArrayView("░"));
    QVERIFY((bottomShadow.attributes & TextAttribute::Dim) ==
            TextAttribute::Dim);

    const Cell &topRightOutside = buf.cellAt(10, 1);
    QCOMPARE(topRightOutside.fgColor, 0xFF80C0FFU);
  }

  void dragHandleComputesScreenSpaceDeltasAcrossParentMovement() {
    Item window;
    window.setX(10);
    window.setY(5);
    window.setWidth(30);
    window.setHeight(10);

    TvDragHandle handle(&window);
    handle.setParentItem(&window);
    handle.setX(0);
    handle.setY(0);
    handle.setWidth(30);
    handle.setHeight(1);

    QList<QPoint> deltas;
    QObject::connect(
        &handle, &TvDragHandle::dragMoved,
        [&](int dx, int dy, int, int) { deltas.append(QPoint(dx, dy)); });

    // Press at local (5, 0) -> screen (15, 5)
    MouseEvent pressEv(MouseEvent::Type::Press, 5, 0, 0);
    handle.mousePressEvent(&pressEv);
    QVERIFY(pressEv.isAccepted());
    QVERIFY(handle.isDragging());

    // Move +1 cell right to screen (16, 5) -> local (6, 0), then simulate
    // window moving to x=11
    MouseEvent move1(MouseEvent::Type::Move, 6, 0, 0);
    handle.mouseMoveEvent(&move1);
    window.setX(11);

    // Next 1-cell move to screen (17, 5) arrives with the SAME local x=6
    // because window moved! TvDragHandle must still emit delta (2, 0) without
    // stalling.
    MouseEvent move2(MouseEvent::Type::Move, 6, 0, 0);
    handle.mouseMoveEvent(&move2);
    window.setX(12);

    MouseEvent relEv(MouseEvent::Type::Release, 5, 0, 0);
    handle.mouseReleaseEvent(&relEv);
    QVERIFY(!handle.isDragging());

    QCOMPARE(deltas.size(), 2);
    QCOMPARE(deltas[0], QPoint(1, 0));
    QCOMPARE(deltas[1], QPoint(2, 0));
  }

  void tvPaletteApplyMapCopyFromAndRoundTrip() {
    TvPalette pal;
    QSignalSpy spy(&pal, &TvPalette::paletteChanged);

    QVariantMap tokens;
    tokens.insert(QStringLiteral("schemeId"), QStringLiteral("amber_crt"));
    tokens.insert(QStringLiteral("schemeTitle"), QStringLiteral("Amber CRT"));
    tokens.insert(QStringLiteral("description"),
                  QStringLiteral("Amber Phosphor"));
    tokens.insert(QStringLiteral("isMonochrome"), true);
    tokens.insert(QStringLiteral("winBg"), QStringLiteral("#1a0d00"));
    tokens.insert(QStringLiteral("winFg"), QStringLiteral("ansi:brightyellow"));
    tokens.insert(QStringLiteral("dialogBg"), QStringLiteral("default"));

    QVERIFY(pal.applyMap(tokens));
    // Batch update emits paletteChanged() exactly once
    QCOMPARE(spy.count(), 1);

    // Re-applying identical values does not emit redundant notifications
    QVERIFY(pal.applyMap(tokens));
    QCOMPARE(spy.count(), 1);

    const QVariantMap exported = pal.toMap();
    QCOMPARE(exported.value(QStringLiteral("schemeId")).toString(),
             QStringLiteral("amber_crt"));
    QCOMPARE(exported.value(QStringLiteral("schemeTitle")).toString(),
             QStringLiteral("Amber CRT"));
    QCOMPARE(exported.value(QStringLiteral("isMonochrome")).toBool(), true);
    QCOMPARE(exported.value(QStringLiteral("winBg")).toString(),
             QStringLiteral("#1a0d00"));
    QCOMPARE(exported.value(QStringLiteral("winFg")).toString(),
             QStringLiteral("ansi:brightyellow"));
    QCOMPARE(exported.value(QStringLiteral("dialogBg")).toString(),
             QStringLiteral("default"));

    TvPalette cloned;
    QSignalSpy cloneSpy(&cloned, &TvPalette::paletteChanged);
    cloned.copyFrom(&pal);
    QCOMPARE(cloneSpy.count(), 1);
    QCOMPARE(cloned.toMap(), exported);

    cloned.reset();
    QCOMPARE(cloned.property("schemeId").toString(),
             QStringLiteral("borland_blue"));
    QCOMPARE(cloned.property("isMonochrome").toBool(), false);
  }

  void tvThemeCustomSchemesOverridesAndScopedControlPalettes() {
    QQmlEngine engine;
    QQmlComponent comp(&engine);
    comp.setData(
        R"qml(
            pragma ComponentBehavior: Bound
            import QtQml
            import QmlTui
            import QmlTui.TVision

            Item {
                id: root

                property alias winSurfaceBg: mainWin.surfaceBg
                property alias alertWinSurfaceBg: alertWin.surfaceBg
                property string activeId: TvTheme.schemeId
                property color activeWinBg: TvTheme.winBg
                property int totalSchemes: TvTheme.schemeCount

                DarkDosTheme {
                    id: draculaTheme
                    schemeId: "dracula"
                    schemeTitle: "Dracula"
                    description: "Dracula Dark"
                    winBg: "#282a36"
                    winFg: "#f8f8f2"
                }

                TvPalette {
                    id: crimsonAlert
                    schemeId: "crimson_alert"
                    winBg: "#550000"
                    dialogBg: "#660000"
                }

                TvWindow {
                    id: mainWin
                }

                TvWindow {
                    id: alertWin
                    palette: crimsonAlert
                }

                function registerDracula(): int {
                    return TvTheme.registerScheme(draculaTheme);
                }

                function selectDracula() {
                    TvTheme.setScheme("dracula");
                }

                function registerJsonTheme() {
                    TvTheme.registerThemeObject({
                        baseScheme: "dark_dos",
                        schemeId: "gruvbox",
                        schemeTitle: "Gruvbox",
                        winBg: "#282828"
                    });
                    TvTheme.setScheme("gruvbox");
                }

                function applyLiveOverride() {
                    TvTheme.applyCustomTheme({
                        baseScheme: "borland_blue",
                        schemeId: "ephemeral",
                        winBg: "#112233"
                    });
                }

                function customOnlyMode() {
                    TvTheme.clearCustomPalette();
                    TvTheme.includeBuiltInSchemes = false;
                    TvTheme.setSchemeByIndex(0);
                }
            }
        )qml",
        QUrl(QStringLiteral("qrc:/test_custom_theme.qml")));

    QVERIFY2(comp.isReady(), qPrintable(comp.errorString()));
    std::unique_ptr<QObject> root(comp.create());
    QVERIFY(root != nullptr);

    // Default global theme is Borland Blue, while alertWin uses its scoped
    // crimsonAlert palette independently.
    QCOMPARE(root->property("activeId").toString(),
             QStringLiteral("borland_blue"));
    QCOMPARE(root->property("totalSchemes").toInt(), 4);
    QCOMPARE(root->property("winSurfaceBg").value<Color>(),
             Color::fromString(QStringLiteral("#0000aa")));
    QCOMPARE(root->property("alertWinSurfaceBg").value<Color>(),
             Color::fromString(QStringLiteral("#550000")));

    // Register declarative DarkDosTheme subclass into TvTheme
    int idx = -1;
    QVERIFY(QMetaObject::invokeMethod(root.get(), "registerDracula",
                                      Q_RETURN_ARG(int, idx)));
    QCOMPARE(idx, 4);
    QCOMPARE(root->property("totalSchemes").toInt(), 5);

    QVERIFY(QMetaObject::invokeMethod(root.get(), "selectDracula"));
    QCOMPARE(root->property("activeId").toString(), QStringLiteral("dracula"));
    QCOMPARE(root->property("winSurfaceBg").value<Color>(),
             Color::fromString(QStringLiteral("#282a36")));
    // Scoped alertWin remains unaffected by global TvTheme switch
    QCOMPARE(root->property("alertWinSurfaceBg").value<Color>(),
             Color::fromString(QStringLiteral("#550000")));

    // Register a JS/JSON object theme inheriting from dark_dos
    QVERIFY(QMetaObject::invokeMethod(root.get(), "registerJsonTheme"));
    QCOMPARE(root->property("totalSchemes").toInt(), 6);
    QCOMPARE(root->property("activeId").toString(), QStringLiteral("gruvbox"));
    QCOMPARE(root->property("activeWinBg").value<Color>(),
             Color::fromString(QStringLiteral("#282828")));

    // Ephemeral one-shot override via applyCustomTheme()
    QVERIFY(QMetaObject::invokeMethod(root.get(), "applyLiveOverride"));
    QCOMPARE(root->property("activeId").toString(),
             QStringLiteral("ephemeral"));
    QCOMPARE(root->property("winSurfaceBg").value<Color>(),
             Color::fromString(QStringLiteral("#112233")));

    // Custom-only mode (includeBuiltInSchemes = false) restricts list to the 2
    // registered custom themes ("dracula" and "gruvbox")
    QVERIFY(QMetaObject::invokeMethod(root.get(), "customOnlyMode"));
    QCOMPARE(root->property("totalSchemes").toInt(), 2);
    QCOMPARE(root->property("activeId").toString(), QStringLiteral("dracula"));
  }
};

QTEST_MAIN(TestTVisionPrimitives)
#include "tst_tvision_primitives.moc"
