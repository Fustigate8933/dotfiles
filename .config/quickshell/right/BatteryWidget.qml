import Quickshell
import Quickshell.Services.UPower
import QtQuick
import ".." as Root

Item {
  id: root
  width: visible ? batteryRow.width + 20 : 0
  height: parent.height
  visible: batteries.length > 0

  // UPower battery data
  property var batteries: UPower.devices.values.filter(dev => dev.isLaptopBattery)
  property var device: batteries.length > 0 ? batteries[0] : null

  property int batteryLevel: {
    if (!device || !device.ready) return 0;
    return Math.round(device.percentage * 100);
  }

  property bool isCharging: batteries.some(b => b.state === UPowerDeviceState.Charging)
  property bool isPluggedIn: !UPower.onBattery
  property bool isLow: batteryLevel <= 20 && !isCharging

  property string batteryIconName: {
    if (isCharging || isPluggedIn) {
      if (batteryLevel >= 90) return "battery_charging_full";
      if (batteryLevel >= 80) return "battery_charging_90";
      if (batteryLevel >= 60) return "battery_charging_80";
      if (batteryLevel >= 50) return "battery_charging_60";
      if (batteryLevel >= 30) return "battery_charging_50";
      if (batteryLevel >= 20) return "battery_charging_30";
      return "battery_charging_20";
    }
    if (batteryLevel >= 95) return "battery_full";
    if (batteryLevel >= 85) return "battery_6_bar";
    if (batteryLevel >= 70) return "battery_5_bar";
    if (batteryLevel >= 55) return "battery_4_bar";
    if (batteryLevel >= 40) return "battery_3_bar";
    if (batteryLevel >= 25) return "battery_2_bar";
    return "battery_1_bar";
  }

  property string batteryStatus: {
    if (isCharging) return "Charging";
    if (isPluggedIn) return "Plugged In";
    return "Discharging";
  }

  property real changeRate: {
    if (!device || !device.ready) return 0;
    return device.changeRate;
  }

  property real batteryCapacityWh: {
    if (!device || !device.ready) return 0;
    return device.energyCapacity;
  }

  property real batteryEnergyWh: {
    if (!device || !device.ready) return 0;
    return device.energy;
  }

  property string batteryHealth: {
    if (!device || !device.ready || !device.healthSupported) return "N/A";
    return Math.round(device.healthPercentage) + "%";
  }

  function formatTimeRemaining() {
    if (!device || !device.ready || changeRate <= 0) return "";
    let totalSec;
    if (isCharging) {
      totalSec = Math.abs(((batteryCapacityWh - batteryEnergyWh) / changeRate) * 3600);
    } else {
      totalSec = Math.abs((batteryEnergyWh / changeRate) * 3600);
    }
    if (totalSec <= 0 || totalSec > 86400) return "";
    let h = Math.floor(totalSec / 3600);
    let m = Math.floor((totalSec % 3600) / 60);
    return h > 0 ? h + "h " + m + "m" : m + "m";
  }

  // Material Symbols font
  FontLoader {
    id: materialFont
    source: Qt.resolvedUrl("../DankMaterialShell/quickshell/assets/fonts/material-design-icons/variablefont/MaterialSymbolsRounded[FILL,GRAD,opsz,wght].ttf")
  }

  Rectangle {
    anchors.centerIn: parent
    width: parent.width
    height: parent.height - 12
    radius: height / 2
    color: Root.Colors.batteryWidgetBackground
  }

  Row {
    id: batteryRow
    anchors.centerIn: parent
    spacing: 4

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: root.batteryIconName
      font.family: materialFont.name
      font.pixelSize: 20
      font.variableAxes: { "FILL": 1, "GRAD": -25, "opsz": 24, "wght": 400 }
      color: {
        if (root.isLow) return Root.Colors.batteryLow;
        if (root.isCharging || root.isPluggedIn) return Root.Colors.batteryCharging;
        return Root.Colors.batteryDischarging;
      }
    }

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: root.batteryLevel + "%"
      font.pixelSize: 12
      color: {
        if (root.isLow) return Root.Colors.batteryLow;
        if (root.isCharging || root.isPluggedIn) return Root.Colors.batteryCharging;
        return Root.Colors.batteryText;
      }
    }
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: {
      if (globalBatteryPopup.visible) {
        globalBatteryPopup.close();
      } else {
        const gp = mapToGlobal(width / 2, height);
        globalBatteryPopup.batteryWidget = root;
        globalBatteryPopup.originX = gp.x;
        globalBatteryPopup.originY = 45;
        globalBatteryPopup.visible = true;
      }
    }
  }

  Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
}
