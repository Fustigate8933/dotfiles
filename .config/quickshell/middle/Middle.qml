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
        globalCenterPopup.currentTab = 0; // Calendar
        globalCenterPopup.toggle();
      }
    }
  }

  WeatherWidget {
    MouseArea {
      anchors.fill: parent
      cursorShape: Qt.PointingHandCursor
      onClicked: {
        globalCenterPopup.currentTab = 3; // Weather
        globalCenterPopup.toggle();
      }
    }
  }
}
