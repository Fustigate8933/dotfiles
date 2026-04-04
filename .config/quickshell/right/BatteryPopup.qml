import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick

PanelWindow {
    id: batteryPopup
    visible: false
    color: "transparent"

    WlrLayershell.layer: WlrLayershell.Top
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    anchors { top: true; left: true; right: true; bottom: true }

    property var batteryWidget: null
    property real originX: 0
    property real originY: 0

    function close() { visible = false; }

    Keys.onEscapePressed: close()

    FontLoader {
        id: materialFont
        source: Qt.resolvedUrl("../DankMaterialShell/quickshell/assets/fonts/material-design-icons/variablefont/MaterialSymbolsRounded[FILL,GRAD,opsz,wght].ttf")
    }

    HyprlandFocusGrab {
        windows: [batteryPopup]
        active: batteryPopup.visible
        onCleared: batteryPopup.close()
    }

    MouseArea {
        anchors.fill: parent
        onClicked: batteryPopup.close()
    }

    Rectangle {
        id: popup
        width: 320
        height: popupColumn.height + 32

        x: Math.min(batteryPopup.width - width - 10, Math.max(10, batteryPopup.originX - width / 2))
        y: batteryPopup.originY + 8

        color: Qt.rgba(0.08, 0.08, 0.1, 0.95)
        radius: 10
        border.color: Qt.rgba(1, 1, 1, 0.1)
        border.width: 1

        Behavior on height { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }

        MouseArea { anchors.fill: parent }

        Column {
            id: popupColumn
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 16
            spacing: 12

            // ── Header: big percentage + status ────────────────────
            Row {
                spacing: 12
                width: parent.width

                Text {
                    text: batteryWidget ? batteryWidget.batteryIconName : "battery_full"
                    font.family: materialFont.name
                    font.pixelSize: 32
                    font.variableAxes: { "FILL": 1, "GRAD": -25, "opsz": 24, "wght": 400 }
                    color: {
                        if (!batteryWidget) return "#a9b1d6";
                        if (batteryWidget.isLow) return "#f7768e";
                        if (batteryWidget.isCharging || batteryWidget.isPluggedIn) return "#7aa2f7";
                        return "#a9b1d6";
                    }
                    anchors.verticalCenter: parent.verticalCenter
                }

                Column {
                    spacing: 2
                    anchors.verticalCenter: parent.verticalCenter

                    Row {
                        spacing: 8
                        Text {
                            text: batteryWidget ? batteryWidget.batteryLevel + "%" : "—"
                            font.pixelSize: 20
                            font.bold: true
                            color: {
                                if (!batteryWidget) return "#c0caf5";
                                if (batteryWidget.isLow) return "#f7768e";
                                if (batteryWidget.isCharging) return "#7aa2f7";
                                return "#c0caf5";
                            }
                        }
                        Text {
                            text: batteryWidget ? batteryWidget.batteryStatus : ""
                            font.pixelSize: 14
                            color: {
                                if (!batteryWidget) return "#a9b1d6";
                                if (batteryWidget.isLow) return "#f7768e";
                                if (batteryWidget.isCharging) return "#7aa2f7";
                                return "#a9b1d6";
                            }
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Text {
                        property string timeStr: batteryWidget ? batteryWidget.formatTimeRemaining() : ""
                        visible: timeStr.length > 0
                        text: {
                            if (!batteryWidget) return "";
                            let rateStr = Math.abs(batteryWidget.changeRate).toFixed(1) + "W";
                            let prefix = batteryWidget.isCharging ? "+" : "-";
                            let timeLabel = batteryWidget.isCharging ? "until full" : "remaining";
                            return prefix + rateStr + "  •  " + timeStr + " " + timeLabel;
                        }
                        font.pixelSize: 11
                        color: "#565f89"
                    }
                }
            }

            // ── Stats cards ────────────────────────────────────────
            Row {
                width: parent.width
                spacing: 8

                Rectangle {
                    width: (parent.width - 8) / 2
                    height: 56
                    radius: 8
                    color: Qt.rgba(1, 1, 1, 0.04)

                    Column {
                        anchors.centerIn: parent
                        spacing: 2
                        Text {
                            text: "Health"
                            font.pixelSize: 11
                            color: "#7aa2f7"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        Text {
                            text: batteryWidget ? batteryWidget.batteryHealth : "N/A"
                            font.pixelSize: 16
                            font.bold: true
                            color: "#c0caf5"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }

                Rectangle {
                    width: (parent.width - 8) / 2
                    height: 56
                    radius: 8
                    color: Qt.rgba(1, 1, 1, 0.04)

                    Column {
                        anchors.centerIn: parent
                        spacing: 2
                        Text {
                            text: "Capacity"
                            font.pixelSize: 11
                            color: "#7aa2f7"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        Text {
                            text: batteryWidget ? batteryWidget.batteryCapacityWh.toFixed(1) + " Wh" : "N/A"
                            font.pixelSize: 16
                            font.bold: true
                            color: "#c0caf5"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
            }

            // ── Battery bar visualization ──────────────────────────
            Rectangle {
                width: parent.width
                height: 12
                radius: 6
                color: Qt.rgba(1, 1, 1, 0.06)

                Rectangle {
                    width: parent.width * (batteryWidget ? batteryWidget.batteryLevel / 100 : 0)
                    height: parent.height
                    radius: 6
                    color: {
                        if (!batteryWidget) return "#7aa2f7";
                        if (batteryWidget.isLow) return "#f7768e";
                        if (batteryWidget.isCharging) return "#7aa2f7";
                        if (batteryWidget.batteryLevel > 50) return "#9ece6a";
                        if (batteryWidget.batteryLevel > 20) return "#e0af68";
                        return "#f7768e";
                    }

                    Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                }
            }
        }
    }
}
