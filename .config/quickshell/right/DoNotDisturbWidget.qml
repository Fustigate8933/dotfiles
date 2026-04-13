import Quickshell
import Quickshell.Io
import QtQuick
import ".." as Root

Item {
  id: root
  width: dndRow.width + 20
  height: parent.height

  property bool dndEnabled: false
  property bool inhibited: false
  property bool active: dndEnabled || inhibited

  function refreshState() {
    readStateProcess.running = true;
  }

  function toggleDnd() {
    const enable = !root.active;

    setDndProcess.command = [
      "sh",
      "-c",
      enable
        ? "if command -v swaync-client >/dev/null 2>&1; then " +
            "swaync-client -dn >/dev/null 2>&1; " +
            "swaync-client -Ia quickshell-dnd >/dev/null 2>&1 || true; " +
          "fi; " +
          "if command -v gsettings >/dev/null 2>&1; then " +
            "gsettings set org.gnome.desktop.sound event-sounds false >/dev/null 2>&1; " +
          "fi; " +
          "if command -v kwriteconfig6 >/dev/null 2>&1; then " +
            "kwriteconfig6 --file \"$HOME/.config/gtk-3.0/settings.ini\" --group Settings --key gtk-enable-event-sounds 0 >/dev/null 2>&1; " +
            "kwriteconfig6 --file \"$HOME/.config/gtk-4.0/settings.ini\" --group Settings --key gtk-enable-event-sounds 0 >/dev/null 2>&1; " +
            "kwriteconfig6 --file \"$HOME/.config/kdeglobals\" --group Sounds --key Enable false >/dev/null 2>&1; " +
          "fi"
        : "if command -v swaync-client >/dev/null 2>&1; then " +
            "swaync-client -df >/dev/null 2>&1; " +
            "swaync-client -Ir quickshell-dnd >/dev/null 2>&1 || true; " +
          "fi; " +
          "if command -v gsettings >/dev/null 2>&1; then " +
            "gsettings set org.gnome.desktop.sound event-sounds true >/dev/null 2>&1; " +
          "fi; " +
          "if command -v kwriteconfig6 >/dev/null 2>&1; then " +
            "kwriteconfig6 --file \"$HOME/.config/gtk-3.0/settings.ini\" --group Settings --key gtk-enable-event-sounds 1 >/dev/null 2>&1; " +
            "kwriteconfig6 --file \"$HOME/.config/gtk-4.0/settings.ini\" --group Settings --key gtk-enable-event-sounds 1 >/dev/null 2>&1; " +
            "kwriteconfig6 --file \"$HOME/.config/kdeglobals\" --group Sounds --key Enable true >/dev/null 2>&1; " +
          "fi"
    ];
    setDndProcess.running = true;
    refreshDelay.restart();
  }

  property string dndIconName: active ? "do_not_disturb_on" : "notifications"
  property color dndColor: active ? Root.Colors.soundMuted : Root.Colors.soundNormal

  FontLoader {
    id: materialFont
    source: Qt.resolvedUrl("../assets/fonts/material-design-icons/variablefont/MaterialSymbolsRounded[FILL,GRAD,opsz,wght].ttf")
  }

  Process {
    id: readStateProcess
    running: true
    command: [
      "sh",
      "-c",
      "if command -v swaync-client >/dev/null 2>&1; then " +
        "printf \"dnd=%s\\n\" \"$(swaync-client -D)\"; " +
        "printf \"inhibited=%s\\n\" \"$(swaync-client -I)\"; " +
      "else " +
        "printf \"dnd=false\\n\"; " +
        "printf \"inhibited=false\\n\"; " +
      "fi"
    ]

    stdout: SplitParser {
      onRead: data => {
        const text = data.trim().toLowerCase();
        if (text.startsWith("dnd=")) {
          root.dndEnabled = /true/.test(text);
          return;
        }
        if (text.startsWith("inhibited=")) {
          root.inhibited = /true/.test(text);
        }
      }
    }
  }

  Process { id: setDndProcess }

  Timer {
    interval: 2000
    running: true
    repeat: true
    onTriggered: root.refreshState()
  }

  Timer {
    id: refreshDelay
    interval: 120
    repeat: false
    onTriggered: root.refreshState()
  }

  Rectangle {
    anchors.centerIn: parent
    width: parent.width
    height: parent.height - 12
    radius: height / 2
    color: Root.Colors.soundWidgetBackground
  }

  Row {
    id: dndRow
    anchors.centerIn: parent
    spacing: 4

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: root.dndIconName
      font.family: materialFont.name
      font.pixelSize: 20
      font.variableAxes: { "FILL": 1, "GRAD": -25, "opsz": 24, "wght": 400 }
      color: root.dndColor
    }
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton

    onClicked: root.toggleDnd()
  }

  Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

  Component.onCompleted: refreshState()
}
