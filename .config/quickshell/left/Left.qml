import QtQuick
import QtQuick.Layouts

Item {
  id: root
  anchors.left: parent.left
  anchors.verticalCenter: parent.verticalCenter
  height: parent.height
  width: childrenRect.width
  
  Row {
    anchors.verticalCenter: parent.verticalCenter
    height: parent.height
    spacing: 4

    Workspace {}
    WindowTitleWidget {}
  }
}
