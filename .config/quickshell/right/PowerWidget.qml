import Quickshell
import Quickshell.Io
import QtQuick
import ".." as Root

Item {
  id: root
  width: powerIcon.width + 20
  height: parent.height

  FontLoader {
    id: materialFont
    source: Qt.resolvedUrl("../assets/fonts/material-design-icons/variablefont/MaterialSymbolsRounded[FILL,GRAD,opsz,wght].ttf")
  }

  Rectangle {
    anchors.centerIn: parent
    width: parent.width
    height: parent.height - 12
    radius: height / 2
    color: Root.Colors.powerWidgetBackground
  }

  Text {
    id: powerIcon
    anchors.centerIn: parent
    text: "power_settings_new"
    font.family: materialFont.name
    font.pixelSize: 20
    font.variableAxes: { "FILL": 1, "GRAD": -25, "opsz": 24, "wght": 400 }
    color: Root.Colors.powerIconColor
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: {
      if (globalPowerPopup.visible) {
        globalPowerPopup.close();
      } else {
        const gp = mapToGlobal(width / 2, height);
        globalPowerPopup.originX = gp.x - globalPowerPopup.screen.x;
        globalPowerPopup.originY = 45;
        globalPowerPopup.visible = true;
      }
    }
  }
}
