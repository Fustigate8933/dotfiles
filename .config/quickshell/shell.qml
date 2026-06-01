import Quickshell
import Quickshell.Wayland
import QtQuick

import "./left"
import "./middle"
import "./right"
import "." as Root

ShellRoot {
  readonly property var preferredScreen: {
    for (let i = 0; i < Quickshell.screens.length; i++) {
      if (Quickshell.screens[i].name === "HDMI-A-3")
        return Quickshell.screens[i];
    }

    return Quickshell.screens[0] ?? null;
  }

  PanelWindow {
    id: topBar
    screen: preferredScreen
    anchors.top: true
    anchors.left: true
    anchors.right: true
    WlrLayershell.layer: WlrLayershell.Top
    WlrLayershell.exclusiveZone: topBar.implicitHeight
    implicitHeight: 50
    color: "transparent"

    Rectangle {
      anchors.fill: parent
      color: Root.Colors.withAlpha(Root.Colors.background, Root.Colors.panelOpacity)
    }

    // Dismiss tray popup when clicking anywhere on the bar
    MouseArea {
      anchors.fill: parent
      z: -1
      acceptedButtons: Qt.AllButtons
      onClicked: if (globalTrayMenu.visible) globalTrayMenu.close()
    }

    Left {}
    Middle {}
    Right {}
  }

  TrayMenuWindow {
    id: globalTrayMenu
    screen: preferredScreen
  }

  SoundPopup {
    id: globalSoundPopup
    screen: preferredScreen
  }

  BatteryPopup {
    id: globalBatteryPopup
    screen: preferredScreen
  }

  CenterPopup {
    id: globalCenterPopup
    screen: preferredScreen
  }
}
