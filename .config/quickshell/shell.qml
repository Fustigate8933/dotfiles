import Quickshell
import Quickshell.Wayland
import QtQuick

import "./left"
import "./middle"
import "./right"
import "." as Root

ShellRoot {
  PanelWindow {
    id: topBar
    anchors.top: true
    anchors.left: true
    anchors.right: true
    WlrLayershell.layer: WlrLayershell.Top
    WlrLayershell.exclusiveZone: topBar.implicitHeight - 6
    implicitHeight: 50
    color: Root.Colors.withAlpha(Root.Colors.background, Root.Colors.panelOpacity)

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
  }

  SoundPopup {
    id: globalSoundPopup
  }

  BatteryPopup {
    id: globalBatteryPopup
  }

  CenterPopup {
    id: globalCenterPopup
  }
}
