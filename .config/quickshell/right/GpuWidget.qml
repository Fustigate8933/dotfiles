import Quickshell
import Quickshell.Io
import QtQuick
import ".." as Root

Item {
  id: root
  width: visible ? gpuRow.width + 20 : 0
  height: parent.height
  visible: gpuUsage >= 0

  property real gpuUsage: -1
  property string gpuColor: {
    if (gpuUsage >= 80) return Root.Colors.gpuHigh;
    if (gpuUsage >= 60) return Root.Colors.gpuMedium;
    return Root.Colors.gpuLow;
  }

  FontLoader {
    id: materialFont
    source: Qt.resolvedUrl("../assets/fonts/material-design-icons/variablefont/MaterialSymbolsRounded[FILL,GRAD,opsz,wght].ttf")
  }

  // Try nvidia-smi first, fall back to radeontop or intel_gpu_top
  Process {
    id: gpuProcess
    running: true
    // Check for nvidia GPU
    command: ["sh", "-c", "if command -v nvidia-smi >/dev/null 2>&1; then nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | head -1; else echo '-1'; fi"]
    
    stdout: SplitParser {
      onRead: data => {
        const usage = parseFloat(data.trim());
        if (!isNaN(usage) && usage >= 0) {
          root.gpuUsage = Math.round(usage);
        } else {
          root.gpuUsage = -1;
        }
      }
    }
  }

  Timer {
    interval: 2000
    running: true
    repeat: true
    onTriggered: gpuProcess.running = true
  }

  Rectangle {
    anchors.centerIn: parent
    width: parent.width
    height: parent.height - 12
    radius: height / 2
    color: Root.Colors.gpuWidgetBackground
  }

  Row {
    id: gpuRow
    anchors.centerIn: parent
    spacing: 4

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: "developer_board"
      font.family: materialFont.name
      font.pixelSize: 20
      font.variableAxes: { "FILL": 1, "GRAD": -25, "opsz": 24, "wght": 400 }
      color: root.gpuColor
    }

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: root.gpuUsage + "%"
      font.pixelSize: 12
      color: Root.Colors.gpuText
    }
  }

  Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
}
