import QtQuick
import QtQuick.Layouts

Item {
  id: root
  anchors.left: parent.left
  anchors.verticalCenter: parent.verticalCenter
  height: parent.height
  property int leftPadding: 8
  width: leftRow.width + leftPadding
  
  Row {
    id: leftRow
    anchors.verticalCenter: parent.verticalCenter
    anchors.left: parent.left
    anchors.leftMargin: root.leftPadding
    height: parent.height
    spacing: 8

    Workspace {}
    WindowTitleWidget {}
  }
}
