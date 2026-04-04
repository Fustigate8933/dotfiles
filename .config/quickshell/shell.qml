import Quickshell
import Quickshell.Wayland
import QtQuick

import "./left"
import "./middle"
import "./right"

ShellRoot {
  PanelWindow {
    anchors.top: true
    anchors.left: true
    anchors.right: true
    implicitHeight: 45
    color: "#1a1b26"

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

  BatteryPopup {
      id: globalBatteryPopup
  }

  CenterPopup {
      id: globalCenterPopup
  }
}
