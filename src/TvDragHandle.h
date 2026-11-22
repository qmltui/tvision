#pragma once

#include <QmlTui/Core/Items/Item.h>
#include <QtQml/qqmlregistration.h>

namespace qmltui::tvision {

// Screen-space pointer drag handle for MDI window title bars and resize grips.
// Computes deltas from absolute terminal coordinates (`absolutePosition() +
// event`), avoiding local-origin feedback stalls when the parent window moves
// during a drag.
class TvDragHandle : public qmltui::Item {
  Q_OBJECT
  QML_ELEMENT

  Q_PROPERTY(bool dragging READ isDragging NOTIFY draggingChanged)

public:
  explicit TvDragHandle(QObject *parent = nullptr);
  ~TvDragHandle() override = default;

  bool isDragging() const { return m_dragging; }

  void mousePressEvent(class qmltui::MouseEvent *event) override;
  void mouseMoveEvent(class qmltui::MouseEvent *event) override;
  void mouseReleaseEvent(class qmltui::MouseEvent *event) override;

signals:
  void draggingChanged();
  void dragStarted(int screenX, int screenY);
  void dragMoved(int deltaX, int deltaY, int screenX, int screenY);
  void dragFinished();
  void clicked(int localX, int localY);

private:
  void cancelDrag();

  bool m_dragging = false;
  bool m_moved = false;
  int m_pressScreenX = 0;
  int m_pressScreenY = 0;
  int m_lastScreenX = 0;
  int m_lastScreenY = 0;
};

} // namespace qmltui::tvision
