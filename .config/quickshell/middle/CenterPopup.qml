import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick

PanelWindow {
    id: centerPopup
    visible: false
    color: "transparent"

    WlrLayershell.layer: WlrLayershell.Top
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    anchors { top: true; left: true; right: true; bottom: true }

    property int currentTab: 0

    function close() { visible = false; }
    function toggle() { visible = !visible; }

    Keys.onEscapePressed: close()

    HyprlandFocusGrab {
        windows: [centerPopup]
        active: centerPopup.visible
        onCleared: centerPopup.close()
    }

    // Material Symbols font
    FontLoader {
        id: materialFont
        source: Qt.resolvedUrl("../DankMaterialShell/quickshell/assets/fonts/material-design-icons/variablefont/MaterialSymbolsRounded[FILL,GRAD,opsz,wght].ttf")
    }

    // Click outside to close
    MouseArea {
        anchors.fill: parent
        onClicked: centerPopup.close()
    }

    Rectangle {
        id: popup
        width: 700
        height: tabBar.height + tabContent.height + 48  // 16 top + 32 bottom
        anchors.horizontalCenter: parent.horizontalCenter
        y: 53 // below the bar (45) + gap

        color: Qt.rgba(0.08, 0.08, 0.1, 0.95)
        radius: 12
        border.color: Qt.rgba(1, 1, 1, 0.08)
        border.width: 1

        Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

        // Prevent clicks inside popup from closing
        MouseArea { anchors.fill: parent }

        Column {
            id: popupLayout
            anchors.fill: parent
            anchors.topMargin: 16
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            anchors.bottomMargin: 32
            spacing: 8

            // ── Tab Bar ──────────────────────────────────────────
            Row {
                id: tabBar
                width: parent.width
                height: 56
                spacing: 0

                property var tabs: [
                    { icon: "calendar_month", label: "Calendar" },
                    { icon: "music_note", label: "Media" },
                    { icon: "wallpaper", label: "Wallpapers" },
                    { icon: "wb_sunny", label: "Weather" }
                ]

                Repeater {
                    model: tabBar.tabs

                    Rectangle {
                        required property var modelData
                        required property int index

                        width: tabBar.width / 4
                        height: 56
                        color: "transparent"

                        Column {
                            anchors.centerIn: parent
                            spacing: 4

                            Text {
                                text: modelData.icon
                                font.family: materialFont.name
                                font.pixelSize: 26
                                font.variableAxes: { "FILL": centerPopup.currentTab === index ? 1 : 0, "GRAD": -25, "opsz": 24, "wght": 400 }
                                color: centerPopup.currentTab === index ? "#bb9af7" : "#7aa2f7"
                                anchors.horizontalCenter: parent.horizontalCenter

                                Behavior on color { ColorAnimation { duration: 150 } }
                            }

                            Text {
                                text: modelData.label
                                font.pixelSize: 12
                                color: centerPopup.currentTab === index ? "#c0caf5" : "#9aa5ce"
                                anchors.horizontalCenter: parent.horizontalCenter

                                Behavior on color { ColorAnimation { duration: 150 } }
                            }
                        }

                        // Active indicator line
                        Rectangle {
                            width: parent.width * 0.6
                            height: 2
                            radius: 1
                            anchors.bottom: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: "#bb9af7"
                            visible: false  // Removed - color highlighting is enough
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: centerPopup.currentTab = index
                        }
                    }
                }
            }

            // ── Separator ────────────────────────────────────────
            Rectangle {
                width: parent.width
                height: 1
                color: Qt.rgba(1, 1, 1, 0.06)
            }

            // ── Tab Content ──────────────────────────────────────
            Item {
                id: tabContent
                width: parent.width
                height: {
                    if (centerPopup.currentTab === 0 && calendarLoader.item) return calendarLoader.item.implicitHeight;
                    if (centerPopup.currentTab === 1 && mediaLoader.item) return mediaLoader.item.implicitHeight;
                    if (centerPopup.currentTab === 2 && wallpaperLoader.item) return wallpaperLoader.item.implicitHeight;
                    if (centerPopup.currentTab === 3 && weatherLoader.item) return weatherLoader.item.implicitHeight;
                    return 400;
                }

                Loader {
                    id: calendarLoader
                    anchors.fill: parent
                    active: centerPopup.currentTab === 0
                    visible: active
                    source: "CalendarTab.qml"
                }

                Loader {
                    id: mediaLoader
                    anchors.fill: parent
                    active: centerPopup.currentTab === 1
                    visible: active
                    source: "MediaTab.qml"
                }

                Loader {
                    id: wallpaperLoader
                    anchors.fill: parent
                    active: centerPopup.currentTab === 2
                    visible: active
                    source: "WallpaperTab.qml"
                }

                Loader {
                    id: weatherLoader
                    anchors.fill: parent
                    active: true  // Always active to prefetch weather
                    visible: centerPopup.currentTab === 3
                    source: "WeatherTab.qml"
                }
            }
        }
    }
}
