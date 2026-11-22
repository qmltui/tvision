#pragma once

#include <QmlTui/Core/Items/Item.h>
#include <QtQml/qqmlregistration.h>

namespace qmltui::tvision {

// Translucent Turbo Vision drop shadow that darkens the foreground and
// background colors of underlying TextGridBuffer cells without erasing glyphs.
// Disabled for input (`enabled == false`) so clicks pass through to underlying
// windows.
class TvDropShadow : public qmltui::Item {
  Q_OBJECT
  QML_ELEMENT

  Q_PROPERTY(qreal factor READ factor WRITE setFactor NOTIFY factorChanged)
  Q_PROPERTY(int horizontalOffset READ horizontalOffset WRITE
                 setHorizontalOffset NOTIFY horizontalOffsetChanged)
  Q_PROPERTY(int verticalOffset READ verticalOffset WRITE setVerticalOffset
                 NOTIFY verticalOffsetChanged)

public:
  explicit TvDropShadow(QObject *parent = nullptr);
  ~TvDropShadow() override = default;

  qreal factor() const { return m_factor; }
  void setFactor(qreal factor);

  int horizontalOffset() const { return m_horizontalOffset; }
  void setHorizontalOffset(int offset);

  int verticalOffset() const { return m_verticalOffset; }
  void setVerticalOffset(int offset);

  void
  paint(qmltui::TextGridBuffer &buffer, int absX, int absY,
        const qmltui::ClipRect &clipRect = qmltui::ClipRect()) const override;

signals:
  void factorChanged();
  void horizontalOffsetChanged();
  void verticalOffsetChanged();

private:
  static uint32_t darkenColor(uint32_t rawColor, int scale256,
                              uint32_t defaultFallback);
  static void shadeSpan(qmltui::TextGridBuffer &buffer, int xStart, int xEnd,
                        int cy, int scale256);

  qreal m_factor = 0.40;
  int m_horizontalOffset = 2;
  int m_verticalOffset = 1;
};

} // namespace qmltui::tvision
