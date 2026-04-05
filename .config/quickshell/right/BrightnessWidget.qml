import Quickshell
import Quickshell.Io
import QtQuick
import ".." as Root

Item {
  id: root
  width: brightnessRow.width + 20
  height: parent.height

  property int brightness: 0

  function clamp(value, minValue, maxValue) {
    return Math.max(minValue, Math.min(maxValue, value));
  }

  function refreshBrightness() {
    readBrightnessProcess.running = true;
  }

  function setBrightness(percent) {
    const clamped = clamp(Math.round(percent), 1, 100);
    brightness = clamped;

    setBrightnessProcess.command = [
      "sh",
      "-c",
      "if command -v brightnessctl >/dev/null 2>&1; then " +
        "brightnessctl set \"$1%\" >/dev/null 2>&1; " +
      "elif command -v light >/dev/null 2>&1; then " +
        "light -S \"$1\" >/dev/null 2>&1; " +
      "fi",
      "_",
      String(clamped)
    ];
    setBrightnessProcess.running = true;
    refreshDelay.restart();
  }

  property string brightnessIconName: {
    if (brightness <= 30) return "brightness_low";
    if (brightness <= 70) return "brightness_medium";
    return "brightness_high";
  }

  property color brightnessColor: Root.Colors.soundNormal

  FontLoader {
    id: materialFont
    source: Qt.resolvedUrl("../assets/fonts/material-design-icons/variablefont/MaterialSymbolsRounded[FILL,GRAD,opsz,wght].ttf")
  }

  Process {
    id: readBrightnessProcess
    running: true
    command: ["sh", "-c", "if command -v brightnessctl >/dev/null 2>&1; then B=$(brightnessctl get); M=$(brightnessctl max); awk \"BEGIN {printf \\\"%.0f\\\", ($B/$M)*100}\"; elif command -v light >/dev/null 2>&1; then light -G | awk '{printf \"%.0f\", $1}'; else echo \"50\"; fi"]

    stdout: SplitParser {
      onRead: data => {
        const text = data.trim();
        const parsed = parseInt(text);
        if (!isNaN(parsed)) root.brightness = root.clamp(parsed, 1, 100);
      }
    }
  }

  Process { id: setBrightnessProcess }

  Timer {
    interval: 2000
    running: true
    repeat: true
    onTriggered: root.refreshBrightness()
  }

  Timer {
    id: refreshDelay
    interval: 120
    repeat: false
    onTriggered: root.refreshBrightness()
  }

  Rectangle {
    anchors.centerIn: parent
    width: parent.width
    height: parent.height - 12
    radius: height / 2
    color: Root.Colors.soundWidgetBackground
  }

  Row {
    id: brightnessRow
    anchors.centerIn: parent
    spacing: 4

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: root.brightnessIconName
      font.family: materialFont.name
      font.pixelSize: 20
      font.variableAxes: { "FILL": 1, "GRAD": -25, "opsz": 24, "wght": 400 }
      color: root.brightnessColor
    }

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: root.brightness + "%"
      font.pixelSize: 12
      color: Root.Colors.soundText
    }
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor

    onWheel: wheel => {
      const step = wheel.angleDelta.y > 0 ? 5 : -5;
      root.setBrightness(root.brightness + step);
    }
  }

  Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

  Component.onCompleted: refreshBrightness()
}
