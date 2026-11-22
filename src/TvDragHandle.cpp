#include "TvDragHandle.h"

#include <QmlTui/Core/Engine/MouseEvent.h>

namespace qmltui::tvision {

TvDragHandle::TvDragHandle(QObject *parent) : qmltui::Item(parent) {
  setItemFlag(ItemFlag::IgnoresParentPadding, true);
  connect(this, &Item::visibleChanged, this, [this]() {
    if (!isEffectivelyVisible())
      cancelDrag();
  });
  connect(this, &Item::enabledChanged, this, [this]() {
    if (!isEffectivelyEnabled())
      cancelDrag();
  });
}

void TvDragHandle::cancelDrag() {
  if (!m_dragging)
    return;
  m_dragging = false;
  m_moved = false;
  emit draggingChanged();
  emit dragFinished();
}

void TvDragHandle::mousePressEvent(qmltui::MouseEvent *event) {
  if (event->button() != Qt::LeftButton)
    return;
  const QPoint abs = absolutePosition();
  m_pressScreenX = abs.x() + event->x();
  m_pressScreenY = abs.y() + event->y();
  m_lastScreenX = m_pressScreenX;
  m_lastScreenY = m_pressScreenY;
  m_moved = false;
  if (!m_dragging) {
    m_dragging = true;
    emit draggingChanged();
  }
  emit dragStarted(m_pressScreenX, m_pressScreenY);
  event->setAccepted(true);
}

void TvDragHandle::mouseMoveEvent(qmltui::MouseEvent *event) {
  if (!m_dragging)
    return;
  if (event->isMotion() && event->button() == Qt::NoButton)
    return;
  const QPoint abs = absolutePosition();
  const int sx = abs.x() + event->x();
  const int sy = abs.y() + event->y();
  if (sx == m_lastScreenX && sy == m_lastScreenY)
    return;
  m_lastScreenX = sx;
  m_lastScreenY = sy;
  m_moved = true;
  emit dragMoved(sx - m_pressScreenX, sy - m_pressScreenY, sx, sy);
  event->setAccepted(true);
}

void TvDragHandle::mouseReleaseEvent(qmltui::MouseEvent *event) {
  if (!m_dragging)
    return;
  const bool wasMoved = m_moved;
  const int lx = event->x();
  const int ly = event->y();
  m_dragging = false;
  m_moved = false;
  emit draggingChanged();
  emit dragFinished();
  if (!wasMoved && lx >= 0 && lx < width() && ly >= 0 && ly < height()) {
    emit clicked(lx, ly);
  }
  event->setAccepted(true);
}

} // namespace qmltui::tvision
