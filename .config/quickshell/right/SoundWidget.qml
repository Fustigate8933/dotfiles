import Quickshell
import Quickshell.Io
import QtQuick
import ".." as Root

Item {
  id: root
  width: soundRow.width + 20
  height: parent.height

  property int volume: 0
  property bool muted: false

  function clamp(value, minValue, maxValue) {
    return Math.max(minValue, Math.min(maxValue, value));
  }

  function refreshVolume() {
    readVolumeProcess.running = true;
  }

  function setVolume(percent) {
    const clamped = clamp(Math.round(percent), 0, 150);
    volume = clamped;

    setVolumeProcess.command = [
      "sh",
      "-c",
      "if command -v wpctl >/dev/null 2>&1; then " +
        "wpctl set-volume @DEFAULT_AUDIO_SINK@ \"$1%\" >/dev/null 2>&1; " +
        "if [ \"$1\" -gt 0 ]; then wpctl set-mute @DEFAULT_AUDIO_SINK@ 0 >/dev/null 2>&1; fi; " +
      "elif command -v pactl >/dev/null 2>&1; then " +
        "pactl set-sink-volume @DEFAULT_SINK@ \"$1%\" >/dev/null 2>&1; " +
        "if [ \"$1\" -gt 0 ]; then pactl set-sink-mute @DEFAULT_SINK@ 0 >/dev/null 2>&1; fi; " +
      "fi",
      "_",
      String(clamped)
    ];
    setVolumeProcess.running = true;
    if (volume > 0 && !muted) {
      volumeFeedbackProcess.command = [
        "sh",
        "-c",
        "if command -v canberra-gtk-play >/dev/null 2>&1; then " +
          "canberra-gtk-play -i message -V -15 >/dev/null 2>&1; " +
        "elif [ -f /usr/share/sounds/freedesktop/stereo/audio-volume-change.oga ] && command -v paplay >/dev/null 2>&1; then " +
          "paplay /usr/share/sounds/freedesktop/stereo/audio-volume-change.oga >/dev/null 2>&1; " +
        "fi"
      ];
      volumeFeedbackProcess.running = true;
    }
    refreshDelay.restart();
  }

  function toggleMute() {
    toggleMuteProcess.command = [
      "sh",
      "-c",
      "if command -v wpctl >/dev/null 2>&1; then " +
        "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle >/dev/null 2>&1; " +
      "elif command -v pactl >/dev/null 2>&1; then " +
        "pactl set-sink-mute @DEFAULT_SINK@ toggle >/dev/null 2>&1; " +
      "fi"
    ];
    toggleMuteProcess.running = true;
    refreshDelay.restart();
  }

  property string soundIconName: {
    if (muted || volume === 0) return "volume_off";
    if (volume <= 30) return "volume_down";
    return "volume_up";
  }

  property color soundColor: muted ? Root.Colors.soundMuted : Root.Colors.soundNormal

  FontLoader {
    id: materialFont
    source: Qt.resolvedUrl("../DankMaterialShell/quickshell/assets/fonts/material-design-icons/variablefont/MaterialSymbolsRounded[FILL,GRAD,opsz,wght].ttf")
  }

  Process {
    id: readVolumeProcess
    running: true
    command: ["sh", "-c", "if command -v wpctl >/dev/null 2>&1; then wpctl get-volume @DEFAULT_AUDIO_SINK@; elif command -v pactl >/dev/null 2>&1; then V=$(pactl get-sink-volume @DEFAULT_SINK@ | head -1 | grep -o '[0-9]\+%' | head -1 | tr -d '%'); M=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}'); [ -z \"$V\" ] && V=0; if [ \"$M\" = yes ]; then echo \"Volume: $(awk \"BEGIN {printf %.2f, $V/100}\") [MUTED]\"; else echo \"Volume: $(awk \"BEGIN {printf %.2f, $V/100}\")\"; fi; else echo \"Volume: 0.00 [MUTED]\"; fi"]

    stdout: SplitParser {
      onRead: data => {
        const text = data.trim();
        const match = text.match(/Volume:\s*([0-9]*\.?[0-9]+)/i);
        if (match) {
          const parsed = parseFloat(match[1]);
          if (!isNaN(parsed)) root.volume = root.clamp(Math.round(parsed * 100), 0, 150);
        }
        root.muted = /MUTED/i.test(text);
      }
    }
  }

  Process { id: setVolumeProcess }
  Process { id: toggleMuteProcess }
  Process { id: volumeFeedbackProcess }

  Timer {
    interval: 2000
    running: true
    repeat: true
    onTriggered: root.refreshVolume()
  }

  Timer {
    id: refreshDelay
    interval: 120
    repeat: false
    onTriggered: root.refreshVolume()
  }

  Rectangle {
    anchors.centerIn: parent
    width: parent.width
    height: parent.height - 12
    radius: height / 2
    color: Root.Colors.soundWidgetBackground
  }

  Row {
    id: soundRow
    anchors.centerIn: parent
    spacing: 4

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: root.soundIconName
      font.family: materialFont.name
      font.pixelSize: 20
      font.variableAxes: { "FILL": 1, "GRAD": -25, "opsz": 24, "wght": 400 }
      color: root.soundColor
    }

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: root.volume + "%"
      font.pixelSize: 12
      color: Root.Colors.soundText
    }
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton | Qt.RightButton

    onClicked: (mouse) => {
      if (mouse.button === Qt.RightButton) {
        root.toggleMute();
        return;
      }

      if (globalSoundPopup.visible) {
        globalSoundPopup.close();
      } else {
        const gp = mapToGlobal(width / 2, height);
        globalSoundPopup.soundWidget = root;
        globalSoundPopup.originX = gp.x;
        globalSoundPopup.originY = 45;
        globalSoundPopup.visible = true;
      }
    }

    onWheel: wheel => {
      const step = wheel.angleDelta.y > 0 ? 5 : -5;
      root.setVolume(root.volume + step);
    }
  }

  Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

  Component.onCompleted: refreshVolume()
}
