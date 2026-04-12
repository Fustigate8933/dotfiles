import QtQuick
import QtQuick.Layouts

Row {
  id: root
  anchors.right: parent.right
  anchors.verticalCenter: parent.verticalCenter
  height: parent.height
  anchors.rightMargin: 8
  spacing: 8

  StopwatchWidget {}
  CpuWidget {}
  GpuWidget {}
  BrightnessWidget {}
  BatteryWidget {}
  SoundWidget {}
  MicrophoneWidget {}
  SysTrayWidget {}
}
