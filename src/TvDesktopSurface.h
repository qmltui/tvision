#pragma once

#include <QByteArray>
#include <QString>
#include <QmlTui/Core/Items/Item.h>
#include <QmlTui/Core/Primitives/Color.h>
#include <QtQml/qqmlregistration.h>

namespace qmltui::tvision {

// Full-bleed stippled MDI desktop background item (`░`, `▒`, `·`, or space)
// painted directly into TextGridBuffer without child QML item allocations.
class TvDesktopSurface : public qmltui::Item {
  Q_OBJECT
  QML_ELEMENT

  Q_PROPERTY(
      QString pattern READ pattern WRITE setPattern NOTIFY patternChanged)
  Q_PROPERTY(qmltui::Color foregroundColor READ foregroundColor WRITE
                 setForegroundColor NOTIFY foregroundColorChanged)
  Q_PROPERTY(qmltui::Color backgroundColor READ backgroundColor WRITE
                 setBackgroundColor NOTIFY backgroundColorChanged)

public:
  explicit TvDesktopSurface(QObject *parent = nullptr);
  ~TvDesktopSurface() override = default;

  QString pattern() const { return m_pattern; }
  void setPattern(const QString &pattern);

  qmltui::Color foregroundColor() const { return m_foregroundColor; }
  void setForegroundColor(qmltui::Color color);

  qmltui::Color backgroundColor() const { return m_backgroundColor; }
  void setBackgroundColor(qmltui::Color color);

  void
  paint(qmltui::TextGridBuffer &buffer, int absX, int absY,
        const qmltui::ClipRect &clipRect = qmltui::ClipRect()) const override;

signals:
  void patternChanged();
  void foregroundColorChanged();
  void backgroundColorChanged();

private:
  QString m_pattern = QStringLiteral("░");
  QByteArray m_glyphUtf8 = QByteArrayLiteral("\xE2\x96\x91");
  qmltui::Color m_foregroundColor = qmltui::Color::fromArgb32(0xFF55FFFF);
  qmltui::Color m_backgroundColor = qmltui::Color::fromArgb32(0xFF0000AA);
  uint32_t m_resolvedFg = 0xFF55FFFF;
  uint32_t m_resolvedBg = 0xFF0000AA;
};

} // namespace qmltui::tvision
