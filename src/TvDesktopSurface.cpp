#include "TvDesktopSurface.h"

#include <QmlTui/Core/Primitives/TextGridBuffer.h>
#include <algorithm>

namespace qmltui::tvision {

TvDesktopSurface::TvDesktopSurface(QObject *parent) : qmltui::Item(parent) {
  setItemFlag(ItemFlag::BoundedSelfPaint);
}

void TvDesktopSurface::setPattern(const QString &pattern) {
  const QString normalized =
      pattern.isEmpty() ? QStringLiteral(" ") : pattern.left(1);
  if (m_pattern == normalized)
    return;
  m_pattern = normalized;
  m_glyphUtf8 = m_pattern.toUtf8();
  if (m_glyphUtf8.isEmpty() ||
      m_glyphUtf8.size() > qmltui::Cell::InlineGlyphCapacity) {
    m_glyphUtf8 = QByteArrayLiteral(" ");
  }
  emit patternChanged();
  markDirty();
}

void TvDesktopSurface::setForegroundColor(qmltui::Color color) {
  if (m_foregroundColor == color)
    return;
  m_foregroundColor = color;
  m_resolvedFg =
      qmltui::Color::resolve(m_foregroundColor, qmltui::Color::DefaultTag);
  emit foregroundColorChanged();
  markDirty();
}

void TvDesktopSurface::setBackgroundColor(qmltui::Color color) {
  if (m_backgroundColor == color)
    return;
  m_backgroundColor = color;
  m_resolvedBg =
      qmltui::Color::resolve(m_backgroundColor, qmltui::Color::DefaultTag);
  emit backgroundColorChanged();
  markDirty();
}

void TvDesktopSurface::paint(qmltui::TextGridBuffer &buffer, int absX, int absY,
                             const qmltui::ClipRect &clipRect) const {
  if (!visible())
    return;

  const int w = width();
  const int h = height();
  if (w <= 0 || h <= 0)
    return;

  const int xStart = std::max({0, absX, clipRect.x});
  const int xEnd =
      std::min({buffer.width(), absX + w, clipRect.x + clipRect.width});
  const int yStart = std::max({0, absY, clipRect.y});
  const int yEnd =
      std::min({buffer.height(), absY + h, clipRect.y + clipRect.height});
  if (xEnd <= xStart || yEnd <= yStart)
    return;

  const int spanW = xEnd - xStart;
  const QByteArrayView glyphView(m_glyphUtf8);
  const uint32_t paintedFg = qmltui::Color::paintedArgb32(m_resolvedFg);
  const uint32_t paintedBg = qmltui::Color::paintedArgb32(m_resolvedBg);

  for (int cy = yStart; cy < yEnd; ++cy) {
    buffer.splitWideGlyphSpan(xStart, cy, spanW);
    for (int cx = xStart; cx < xEnd; ++cx) {
      qmltui::Cell &cell = buffer.cellAt(cx, cy);
      cell.setCharacter(glyphView);
      cell.displayWidth = 1;
      cell.continuation = false;
      cell.fgColor = paintedFg;
      cell.bgColor = paintedBg;
      cell.attributes = qmltui::TextAttribute::None;
      cell.linkId = 0;
    }
  }
}

} // namespace qmltui::tvision
