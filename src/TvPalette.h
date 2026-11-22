#pragma once

#include <QObject>
#include <QString>
#include <QmlTui/Core/Primitives/Color.h>
#include <QtQml/qqmlregistration.h>

namespace qmltui::tvision {

// Declarative color-scheme token set for QmlTui.TVision themes.
// Each theme `.qml` file instantiates `TvPalette` with its own color values,
// avoiding multi-way conditional chains inside `TvTheme.qml`.
class TvPalette : public QObject {
  Q_OBJECT
  QML_ELEMENT

  Q_PROPERTY(QString schemeId MEMBER m_schemeId NOTIFY paletteChanged)
  Q_PROPERTY(QString schemeTitle MEMBER m_schemeTitle NOTIFY paletteChanged)
  Q_PROPERTY(QString description MEMBER m_description NOTIFY paletteChanged)
  Q_PROPERTY(bool isMonochrome MEMBER m_isMonochrome NOTIFY paletteChanged)

  // Desktop stipple surface
  Q_PROPERTY(qmltui::Color desktopBg MEMBER m_desktopBg NOTIFY paletteChanged)
  Q_PROPERTY(qmltui::Color desktopFg MEMBER m_desktopFg NOTIFY paletteChanged)

  // MenuBar, pull-down Menu, & StatusLine
  Q_PROPERTY(qmltui::Color barBg MEMBER m_barBg NOTIFY paletteChanged)
  Q_PROPERTY(qmltui::Color barFg MEMBER m_barFg NOTIFY paletteChanged)
  Q_PROPERTY(
      qmltui::Color barHotkeyFg MEMBER m_barHotkeyFg NOTIFY paletteChanged)
  Q_PROPERTY(
      qmltui::Color barSelectedBg MEMBER m_barSelectedBg NOTIFY paletteChanged)
  Q_PROPERTY(
      qmltui::Color barSelectedFg MEMBER m_barSelectedFg NOTIFY paletteChanged)
  Q_PROPERTY(qmltui::Color barSelectedHotkeyFg MEMBER m_barSelectedHotkeyFg
                 NOTIFY paletteChanged)
  Q_PROPERTY(
      qmltui::Color barDisabledFg MEMBER m_barDisabledFg NOTIFY paletteChanged)
  Q_PROPERTY(
      qmltui::Color barBorderFg MEMBER m_barBorderFg NOTIFY paletteChanged)

  // Editor / Document MDI Windows ("window" role)
  Q_PROPERTY(qmltui::Color winBg MEMBER m_winBg NOTIFY paletteChanged)
  Q_PROPERTY(qmltui::Color winFg MEMBER m_winFg NOTIFY paletteChanged)
  Q_PROPERTY(qmltui::Color winMutedFg MEMBER m_winMutedFg NOTIFY paletteChanged)
  Q_PROPERTY(qmltui::Color winActiveBorder MEMBER m_winActiveBorder NOTIFY
                 paletteChanged)
  Q_PROPERTY(qmltui::Color winInactiveBorder MEMBER m_winInactiveBorder NOTIFY
                 paletteChanged)
  Q_PROPERTY(
      qmltui::Color winMoveBorder MEMBER m_winMoveBorder NOTIFY paletteChanged)
  Q_PROPERTY(
      qmltui::Color winControlFg MEMBER m_winControlFg NOTIFY paletteChanged)
  Q_PROPERTY(
      qmltui::Color winScrollBg MEMBER m_winScrollBg NOTIFY paletteChanged)
  Q_PROPERTY(
      qmltui::Color winScrollFg MEMBER m_winScrollFg NOTIFY paletteChanged)

  // Tool & Dialog Windows ("dialog" role)
  Q_PROPERTY(qmltui::Color dialogBg MEMBER m_dialogBg NOTIFY paletteChanged)
  Q_PROPERTY(qmltui::Color dialogFg MEMBER m_dialogFg NOTIFY paletteChanged)
  Q_PROPERTY(
      qmltui::Color dialogMutedFg MEMBER m_dialogMutedFg NOTIFY paletteChanged)
  Q_PROPERTY(qmltui::Color dialogActiveBorder MEMBER m_dialogActiveBorder NOTIFY
                 paletteChanged)
  Q_PROPERTY(qmltui::Color dialogInactiveBorder MEMBER m_dialogInactiveBorder
                 NOTIFY paletteChanged)
  Q_PROPERTY(qmltui::Color dialogControlFg MEMBER m_dialogControlFg NOTIFY
                 paletteChanged)

  // Inputs & Lists
  Q_PROPERTY(qmltui::Color inputBg MEMBER m_inputBg NOTIFY paletteChanged)
  Q_PROPERTY(qmltui::Color inputFg MEMBER m_inputFg NOTIFY paletteChanged)
  Q_PROPERTY(qmltui::Color listBg MEMBER m_listBg NOTIFY paletteChanged)
  Q_PROPERTY(qmltui::Color listFg MEMBER m_listFg NOTIFY paletteChanged)
  Q_PROPERTY(qmltui::Color listSelectedBg MEMBER m_listSelectedBg NOTIFY
                 paletteChanged)
  Q_PROPERTY(qmltui::Color listSelectedFg MEMBER m_listSelectedFg NOTIFY
                 paletteChanged)

  // 3D Beveled TvButton tokens
  Q_PROPERTY(qmltui::Color buttonBg MEMBER m_buttonBg NOTIFY paletteChanged)
  Q_PROPERTY(qmltui::Color buttonFocusedBg MEMBER m_buttonFocusedBg NOTIFY
                 paletteChanged)
  Q_PROPERTY(qmltui::Color buttonFg MEMBER m_buttonFg NOTIFY paletteChanged)
  Q_PROPERTY(qmltui::Color buttonDefaultFg MEMBER m_buttonDefaultFg NOTIFY
                 paletteChanged)
  Q_PROPERTY(qmltui::Color buttonHotkeyFg MEMBER m_buttonHotkeyFg NOTIFY
                 paletteChanged)
  Q_PROPERTY(qmltui::Color buttonShadowFg MEMBER m_buttonShadowFg NOTIFY
                 paletteChanged)

public:
  explicit TvPalette(QObject *parent = nullptr);
  ~TvPalette() override = default;

signals:
  void paletteChanged();

private:
  QString m_schemeId = QStringLiteral("borland_blue");
  QString m_schemeTitle = QStringLiteral("Borland Blue");
  QString m_description = QStringLiteral("Borland Blue (Classic C++ IDE)");
  bool m_isMonochrome = false;

  qmltui::Color m_desktopBg = qmltui::Color::fromArgb32(0xFF000080U);
  qmltui::Color m_desktopFg = qmltui::Color::fromArgb32(0xFF5588CCU);

  qmltui::Color m_barBg = qmltui::Color::fromArgb32(0xFFC0C0C0U);
  qmltui::Color m_barFg = qmltui::Color::fromArgb32(0xFF000000U);
  qmltui::Color m_barHotkeyFg = qmltui::Color::fromArgb32(0xFFAA0000U);
  qmltui::Color m_barSelectedBg = qmltui::Color::fromArgb32(0xFF00AA00U);
  qmltui::Color m_barSelectedFg = qmltui::Color::fromArgb32(0xFF000000U);
  qmltui::Color m_barSelectedHotkeyFg = qmltui::Color::fromArgb32(0xFFAA0000U);
  qmltui::Color m_barDisabledFg = qmltui::Color::fromArgb32(0xFF6C6C6CU);
  qmltui::Color m_barBorderFg = qmltui::Color::fromArgb32(0xFF000000U);

  qmltui::Color m_winBg = qmltui::Color::fromArgb32(0xFF0000AAU);
  qmltui::Color m_winFg = qmltui::Color::fromArgb32(0xFFFFFF55U);
  qmltui::Color m_winMutedFg = qmltui::Color::fromArgb32(0xFF55FFFFU);
  qmltui::Color m_winActiveBorder = qmltui::Color::fromArgb32(0xFFFFFFFFU);
  qmltui::Color m_winInactiveBorder = qmltui::Color::fromArgb32(0xFF9E9E9EU);
  qmltui::Color m_winMoveBorder = qmltui::Color::fromArgb32(0xFF55FF55U);
  qmltui::Color m_winControlFg = qmltui::Color::fromArgb32(0xFF55FF55U);
  qmltui::Color m_winScrollBg = qmltui::Color::fromArgb32(0xFF00AAAAU);
  qmltui::Color m_winScrollFg = qmltui::Color::fromArgb32(0xFF0000AAU);

  qmltui::Color m_dialogBg = qmltui::Color::fromArgb32(0xFFB8B8B8U);
  qmltui::Color m_dialogFg = qmltui::Color::fromArgb32(0xFF000000U);
  qmltui::Color m_dialogMutedFg = qmltui::Color::fromArgb32(0xFF3A3A3AU);
  qmltui::Color m_dialogActiveBorder = qmltui::Color::fromArgb32(0xFFFFFFFFU);
  qmltui::Color m_dialogInactiveBorder = qmltui::Color::fromArgb32(0xFF6C6C6CU);
  qmltui::Color m_dialogControlFg = qmltui::Color::fromArgb32(0xFFFFFF55U);

  qmltui::Color m_inputBg = qmltui::Color::fromArgb32(0xFF000080U);
  qmltui::Color m_inputFg = qmltui::Color::fromArgb32(0xFFFFFFFFU);
  qmltui::Color m_listBg = qmltui::Color::fromArgb32(0xFF008080U);
  qmltui::Color m_listFg = qmltui::Color::fromArgb32(0xFFFFFFFFU);
  qmltui::Color m_listSelectedBg = qmltui::Color::fromArgb32(0xFF00AA00U);
  qmltui::Color m_listSelectedFg = qmltui::Color::fromArgb32(0xFF000000U);

  qmltui::Color m_buttonBg = qmltui::Color::fromArgb32(0xFF00AA00U);
  qmltui::Color m_buttonFocusedBg = qmltui::Color::fromArgb32(0xFF22CC44U);
  qmltui::Color m_buttonFg = qmltui::Color::fromArgb32(0xFF000000U);
  qmltui::Color m_buttonDefaultFg = qmltui::Color::fromArgb32(0xFFFFFFFFU);
  qmltui::Color m_buttonHotkeyFg = qmltui::Color::fromArgb32(0xFFFFFF55U);
  qmltui::Color m_buttonShadowFg = qmltui::Color::fromArgb32(0xFF000000U);
};

} // namespace qmltui::tvision
