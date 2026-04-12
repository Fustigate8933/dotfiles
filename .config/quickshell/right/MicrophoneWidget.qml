import Quickshell
import Quickshell.Io
import QtQuick
import ".." as Root

Item {
  id: root
  width: micRow.width + 20
  height: parent.height

  property bool muted: true

  function refreshMuteState() {
    readMuteProcess.running = true;
  }

  function toggleMute() {
    toggleMuteProcess.command = [
      "sh",
      "-c",
      "if command -v wpctl >/dev/null 2>&1; then " +
        "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle >/dev/null 2>&1; " +
      "elif command -v pactl >/dev/null 2>&1; then " +
        "pactl set-source-mute @DEFAULT_SOURCE@ toggle >/dev/null 2>&1; " +
      "fi"
    ];
    toggleMuteProcess.running = true;
    refreshDelay.restart();
  }

  property string micIconName: muted ? "mic_off" : "mic"
  property color micColor: muted ? Root.Colors.soundMuted : Root.Colors.soundNormal

  FontLoader {
    id: materialFont
    source: Qt.resolvedUrl("../assets/fonts/material-design-icons/variablefont/MaterialSymbolsRounded[FILL,GRAD,opsz,wght].ttf")
  }

  Process {
    id: readMuteProcess
    running: true
    command: ["sh", "-c", "if command -v wpctl >/dev/null 2>&1; then wpctl get-volume @DEFAULT_AUDIO_SOURCE@; elif command -v pactl >/dev/null 2>&1; then M=$(pactl get-source-mute @DEFAULT_SOURCE@ | awk '{print $2}'); [ \"$M\" = yes ] && echo \"MUTED\" || echo \"UNMUTED\"; else echo \"MUTED\"; fi"]

    stdout: SplitParser {
      onRead: data => {
        const text = data.trim();
        root.muted = /MUTED/i.test(text);
      }
    }
  }

  Process { id: toggleMuteProcess }

  Timer {
    interval: 2000
    running: true
    repeat: true
    onTriggered: root.refreshMuteState()
  }

  Timer {
    id: refreshDelay
    interval: 120
    repeat: false
    onTriggered: root.refreshMuteState()
  }

  Rectangle {
    anchors.centerIn: parent
    width: parent.width
    height: parent.height - 12
    radius: height / 2
    color: Root.Colors.soundWidgetBackground
  }

  Row {
    id: micRow
    anchors.centerIn: parent
    spacing: 4

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: root.micIconName
      font.family: materialFont.name
      font.pixelSize: 20
      font.variableAxes: { "FILL": 1, "GRAD": -25, "opsz": 24, "wght": 400 }
      color: root.micColor
    }
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton

    onClicked: {
      root.toggleMute();
    }
  }

  Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

  Component.onCompleted: refreshMuteState()
}
