import Quickshell
import Quickshell.Io
import QtQuick
import ".." as Root

Item {
  id: root
  width: cpuRow.width + 20
  height: parent.height

  property real cpuUsage: 0
  property string cpuColor: {
    if (cpuUsage >= 80) return Root.Colors.cpuHigh;
    if (cpuUsage >= 60) return Root.Colors.cpuMedium;
    return Root.Colors.cpuLow;
  }

  FontLoader {
    id: materialFont
    source: Qt.resolvedUrl("../assets/fonts/material-design-icons/variablefont/MaterialSymbolsRounded[FILL,GRAD,opsz,wght].ttf")
  }

  // Update CPU usage every 2 seconds
  Process {
    id: cpuProcess
    running: true
    command: ["sh", "-c", "top -bn2 -d 0.5 | grep '^%Cpu' | tail -1 | awk '{print 100-$8}'"]
    
    stdout: SplitParser {
      onRead: data => {
        const usage = parseFloat(data.trim());
        if (!isNaN(usage)) {
          root.cpuUsage = Math.round(usage);
        }
      }
    }
  }

  Timer {
    interval: 2000
    running: true
    repeat: true
    onTriggered: cpuProcess.running = true
  }

  Rectangle {
    anchors.centerIn: parent
    width: parent.width
    height: parent.height - 12
    radius: height / 2
    color: Root.Colors.cpuWidgetBackground
  }

  Row {
    id: cpuRow
    anchors.centerIn: parent
    spacing: 4

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: "memory"
      font.family: materialFont.name
      font.pixelSize: 20
      font.variableAxes: { "FILL": 1, "GRAD": -25, "opsz": 24, "wght": 400 }
      color: root.cpuColor
    }

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: root.cpuUsage + "%"
      font.pixelSize: 12
      color: Root.Colors.cpuText
    }
  }

  Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
}
