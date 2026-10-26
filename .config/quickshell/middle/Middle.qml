import QtQuick

Row {
  id: root
  anchors.centerIn: parent
  height: parent.height
  spacing: 8

  ClockWidget {
    MouseArea {
      anchors.fill: parent
      cursorShape: Qt.PointingHandCursor
      onClicked: {
        globalCenterPopup.toggle(); // reopen on last-viewed tab
      }
    }
  }

  WeatherWidget {
    MouseArea {
      anchors.fill: parent
      cursorShape: Qt.PointingHandCursor
      onClicked: {
        globalCenterPopup.toggle(); // reopen on last-viewed tab
      }
    }
  }
}
