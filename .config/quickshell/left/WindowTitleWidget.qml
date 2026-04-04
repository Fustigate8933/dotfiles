import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import QtQuick

Item {
  id: root
  height: parent.height
  width: visible ? 300 : 0
  visible: titleText.text.length > 0
  clip: true

  // Find the focused toplevel on the current workspace
  property var focusedToplevel: {
    if (!Hyprland.toplevels || !Hyprland.focusedWorkspace)
      return null;
    let toplevels = Hyprland.toplevels.values;
    for (let i = 0; i < toplevels.length; i++) {
      let t = toplevels[i];
      if (t.activated && t.workspace && t.workspace.id === Hyprland.focusedWorkspace.id)
        return t;
    }
    return null;
  }

  property string appName: {
    if (!focusedToplevel) return "";
    let ipc = focusedToplevel.lastIpcObject;
    let wl = focusedToplevel.wayland;
    let cls = ipc ? (ipc.class || ipc.initialClass || "") : (wl ? (wl.appId || "") : "");
    if (cls === "") return "";
    // Capitalize first letter
    return cls.charAt(0).toUpperCase() + cls.slice(1);
  }

  property string windowTitle: {
    if (!focusedToplevel) return "";
    let title = focusedToplevel.title || "";
    // Strip app name from end of title if present
    if (title.endsWith(appName))
      title = title.substring(0, title.length - appName.length).replace(/ [-—] $/, "");
    return title;
  }

  // Poll for updates
  Timer {
    interval: 250
    running: true
    repeat: true
    onTriggered: Hyprland.refreshToplevels()
  }

  Rectangle {
    anchors.centerIn: parent
    width: parent.width
    height: parent.height - 12
    radius: height / 2
    color: Qt.rgba(1, 1, 1, 0.06)
  }

  Row {
    id: contentRow
    anchors.left: parent.left
    anchors.leftMargin: 8
    anchors.verticalCenter: parent.verticalCenter
    spacing: 6

    // App icon
    IconImage {
      id: appIcon
      width: 16
      height: 16
      anchors.verticalCenter: parent.verticalCenter
      source: {
        if (!root.focusedToplevel) return "";
        let ipc = root.focusedToplevel.lastIpcObject;
        let wl = root.focusedToplevel.wayland;
        let cls = ipc ? (ipc.class || ipc.initialClass || "") : (wl ? (wl.appId || "") : "");
        if (cls === "") return "";
        return Quickshell.iconPath(cls.toLowerCase(), "wayland");
      }
      visible: status === Image.Ready
    }

    // App name
    Text {
      id: appNameText
      anchors.verticalCenter: parent.verticalCenter
      text: root.appName
      color: "#c0caf5"
      font.pixelSize: 12
      font.bold: true
      visible: text.length > 0
    }

    // Separator
    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: "•"
      color: "#565f89"
      font.pixelSize: 12
      visible: appNameText.visible && titleText.text.length > 0
    }

    // Window title
    Text {
      id: titleText
      anchors.verticalCenter: parent.verticalCenter
      text: root.windowTitle || root.appName
      color: "#a9b1d6"
      font.pixelSize: 12
      elide: Text.ElideRight
      width: Math.min(implicitWidth, 250)
      visible: text.length > 0
    }
  }
}
