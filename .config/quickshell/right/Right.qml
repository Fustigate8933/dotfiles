import QtQuick
import QtQuick.Layouts

Row {
  id: root
  anchors.right: parent.right
  anchors.verticalCenter: parent.verticalCenter
  height: parent.height
  anchors.rightMargin: 8
  spacing: 8

  CpuWidget {}
  GpuWidget {}
  BrightnessWidget {}
  SoundWidget {}
  BatteryWidget {}
  StopwatchWidget {}
  SysTrayWidget {}
}
