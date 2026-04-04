import Quickshell
import QtQuick
import ".." as Root

Item {
  id: root
  width: stopwatchRow.width + 20
  height: parent.height

  property bool running: false
  property int elapsedSeconds: 0

  function formatTime(totalSeconds) {
    const hours = Math.floor(totalSeconds / 3600);
    const minutes = Math.floor((totalSeconds % 3600) / 60);
    const seconds = totalSeconds % 60;
    const mm = String(minutes).padStart(2, "0");
    const ss = String(seconds).padStart(2, "0");
    if (hours > 0) return `${hours}:${mm}:${ss}`;
    return `${mm}:${ss}`;
  }

  FontLoader {
    id: materialFont
    source: Qt.resolvedUrl("../assets/fonts/material-design-icons/variablefont/MaterialSymbolsRounded[FILL,GRAD,opsz,wght].ttf")
  }

  Timer {
    interval: 1000
    running: root.running
    repeat: true
    onTriggered: root.elapsedSeconds += 1
  }

  Rectangle {
    anchors.centerIn: parent
    width: parent.width
    height: parent.height - 12
    radius: height / 2
    color: Root.Colors.withAlpha(Root.Colors.systrayChipBackground, Root.Colors.systrayChipOpacity)
  }

  Row {
    id: stopwatchRow
    anchors.centerIn: parent
    spacing: 4

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: root.running ? "timer" : "timer_off"
      font.family: materialFont.name
      font.pixelSize: 20
      font.variableAxes: { "FILL": 1, "GRAD": -25, "opsz": 24, "wght": 400 }
      color: root.running ? Root.Colors.info : Root.Colors.textSecondary
    }

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: root.formatTime(root.elapsedSeconds)
      font.pixelSize: 12
      color: Root.Colors.textPrimary
    }
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: (mouse) => {
      if (mouse.button === Qt.LeftButton) {
        root.running = !root.running;
      } else if (mouse.button === Qt.RightButton) {
        root.running = false;
        root.elapsedSeconds = 0;
      }
    }
  }

  Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
}