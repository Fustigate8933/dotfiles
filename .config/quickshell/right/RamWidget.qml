import Quickshell
import Quickshell.Io
import QtQuick
import ".." as Root

Item {
  id: root
  width: ramRow.width + 20
  height: parent.height

  property real ramUsage: 0
  property color ramColor: {
    if (ramUsage >= 80) return Root.Colors.ramHigh;
    if (ramUsage >= 60) return Root.Colors.ramMedium;
    return Root.Colors.ramLow;
  }

  FontLoader {
    id: materialFont
    source: Qt.resolvedUrl("../assets/fonts/material-design-icons/variablefont/MaterialSymbolsRounded[FILL,GRAD,opsz,wght].ttf")
  }

  Process {
    id: ramProcess
    running: true
    command: [
      "sh",
      "-c",
      "awk '/MemTotal:/ { total=$2 } /MemAvailable:/ { available=$2 } END { if (total > 0) printf \"%.0f\\n\", ((total - available) / total) * 100; else print 0 }' /proc/meminfo"
    ]

    stdout: SplitParser {
      onRead: data => {
        const usage = parseFloat(data.trim());
        if (!isNaN(usage)) {
          root.ramUsage = Math.round(usage);
        }
      }
    }
  }

  Timer {
    interval: 2000
    running: true
    repeat: true
    onTriggered: ramProcess.running = true
  }

  Rectangle {
    anchors.centerIn: parent
    width: parent.width
    height: parent.height - 12
    radius: height / 2
    color: Root.Colors.ramWidgetBackground
  }

  Row {
    id: ramRow
    anchors.centerIn: parent
    spacing: 4

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: "memory_alt"
      font.family: materialFont.name
      font.pixelSize: 20
      font.variableAxes: { "FILL": 1, "GRAD": -25, "opsz": 24, "wght": 400 }
      color: root.ramColor
    }

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: root.ramUsage + "%"
      font.pixelSize: 12
      color: Root.Colors.ramText
    }
  }

  Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
}
