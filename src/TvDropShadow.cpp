#include "TvDropShadow.h"

#include <QmlTui/Core/Primitives/Color.h>
#include <QmlTui/Core/Primitives/TextGridBuffer.h>
#include <QtGlobal>
#include <algorithm>

namespace qmltui::tvision {

TvDropShadow::TvDropShadow(QObject *parent) : qmltui::Item(parent) {
  setItemFlag(ItemFlag::BoundedSelfPaint);
  setItemFlag(ItemFlag::IgnoresParentPadding, true);
  // Keep shadow non-interactive so mouse presses pass through to windows
  // underneath.
  setEnabled(false);
}

void TvDropShadow::setFactor(qreal factor) {
  const qreal clamped = std::clamp(factor, 0.0, 1.0);
  if (qFuzzyCompare(m_factor, clamped))
    return;
  m_factor = clamped;
  emit factorChanged();
  markDirty();
}

void TvDropShadow::setHorizontalOffset(int offset) {
  const int clamped = std::max(0, offset);
  if (m_horizontalOffset == clamped)
    return;
  m_horizontalOffset = clamped;
  emit horizontalOffsetChanged();
  markDirty();
}

void TvDropShadow::setVerticalOffset(int offset) {
  const int clamped = std::max(0, offset);
  if (m_verticalOffset == clamped)
    return;
  m_verticalOffset = clamped;
  emit verticalOffsetChanged();
  markDirty();
}

uint32_t TvDropShadow::darkenColor(uint32_t rawColor, int scale256,
                                   uint32_t defaultFallback) {
  if (qmltui::Color::isDefault(rawColor) ||
      qmltui::Color::isTransparent(rawColor)) {
    return defaultFallback;
  }
  const uint32_t rgb = qmltui::Color::toArgb(rawColor);
  const uint32_t r =
      (((rgb >> 16) & 0xFFU) * static_cast<uint32_t>(scale256)) >> 8;
  const uint32_t g =
      (((rgb >> 8) & 0xFFU) * static_cast<uint32_t>(scale256)) >> 8;
  const uint32_t b = ((rgb & 0xFFU) * static_cast<uint32_t>(scale256)) >> 8;
  return 0xFF000000U | (r << 16) | (g << 8) | b;
}

void TvDropShadow::shadeSpan(qmltui::TextGridBuffer &buffer, int xStart,
                             int xEnd, int cy, int scale256) {
  if (xEnd <= xStart)
    return;
  buffer.splitWideGlyphSpan(xStart, cy, xEnd - xStart);
  for (int cx = xStart; cx < xEnd; ++cx) {
    qmltui::Cell &cell = buffer.cellAt(cx, cy);
    cell.fgColor = darkenColor(cell.fgColor, scale256, 0xFF585858U);
    cell.bgColor = darkenColor(cell.bgColor, scale256, 0xFF080808U);
    cell.attributes = cell.attributes | qmltui::TextAttribute::Dim;
  }
}

void TvDropShadow::paint(qmltui::TextGridBuffer &buffer, int absX, int absY,
                         const qmltui::ClipRect &clipRect) const {
  if (!visible())
    return;

  const int w = width();
  const int h = height();
  if (w <= 0 || h <= 0)
    return;

  const int clipLeft = std::max(0, clipRect.x);
  const int clipRight = std::min(buffer.width(), clipRect.x + clipRect.width);
  const int clipTop = std::max(0, clipRect.y);
  const int clipBottom =
      std::min(buffer.height(), clipRect.y + clipRect.height);
  if (clipRight <= clipLeft || clipBottom <= clipTop)
    return;

  const int scale256 =
      std::clamp(static_cast<int>(m_factor * 256.0 + 0.5), 0, 256);

  if (m_horizontalOffset <= 0 && m_verticalOffset <= 0) {
    const int xStart = std::max(absX, clipLeft);
    const int xEnd = std::min(absX + w, clipRight);
    const int yStart = std::max(absY, clipTop);
    const int yEnd = std::min(absY + h, clipBottom);
    for (int cy = yStart; cy < yEnd; ++cy) {
      shadeSpan(buffer, xStart, xEnd, cy, scale256);
    }
    return;
  }

  const int bodyRight = absX + std::max(0, w - m_horizontalOffset);
  const int bodyBottom = absY + std::max(0, h - m_verticalOffset);

  // Right vertical shadow band: [w - horizontalOffset, w) x [verticalOffset, h)
  if (m_horizontalOffset > 0 && w > m_horizontalOffset &&
      h > m_verticalOffset) {
    const int rxStart = std::max(bodyRight, clipLeft);
    const int rxEnd = std::min(absX + w, clipRight);
    const int ryStart = std::max(absY + m_verticalOffset, clipTop);
    const int ryEnd = std::min(absY + h, clipBottom);
    for (int cy = ryStart; cy < ryEnd; ++cy) {
      shadeSpan(buffer, rxStart, rxEnd, cy, scale256);
    }
  }

  // Bottom horizontal shadow band (excluding the corner already shaded above):
  // [horizontalOffset, w - horizontalOffset) x [h - verticalOffset, h)
  if (m_verticalOffset > 0 && h > m_verticalOffset &&
      bodyRight > absX + m_horizontalOffset) {
    const int bxStart = std::max(absX + m_horizontalOffset, clipLeft);
    const int bxEnd = std::min(bodyRight, clipRight);
    const int byStart = std::max(bodyBottom, clipTop);
    const int byEnd = std::min(absY + h, clipBottom);
    for (int cy = byStart; cy < byEnd; ++cy) {
      shadeSpan(buffer, bxStart, bxEnd, cy, scale256);
    }
  }
}

} // namespace qmltui::tvision
