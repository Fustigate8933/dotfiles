import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import ".." as Root

PanelWindow {
    id: soundPopup
    visible: false
    color: "transparent"

    WlrLayershell.layer: WlrLayershell.Top
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    anchors { top: true; left: true; right: true; bottom: true }

    property var soundWidget: null
    property real originX: 0
    property real originY: 0

    function close() { visible = false; }

    function openPavucontrol() {
        pavucontrolProcess.running = true;
        close();
    }

    FontLoader {
        id: materialFont
        source: Qt.resolvedUrl("../assets/fonts/material-design-icons/variablefont/MaterialSymbolsRounded[FILL,GRAD,opsz,wght].ttf")
    }

    HyprlandFocusGrab {
        windows: [soundPopup]
        active: soundPopup.visible
        onCleared: soundPopup.close()
    }

    Process {
        id: pavucontrolProcess
        command: ["sh", "-c", "pavucontrol >/dev/null 2>&1 &"]
    }

    MouseArea {
        anchors.fill: parent
        onClicked: soundPopup.close()
    }

    Rectangle {
        id: popup
        width: 320
        height: popupColumn.implicitHeight + 32

        x: Math.min(soundPopup.width - width - 10, Math.max(10, soundPopup.originX - width / 2))
        y: soundPopup.originY + 8

        color: Root.Colors.withAlpha(Root.Colors.surfaceContainer, Root.Colors.popupOpacity)
        radius: 10
        border.color: Root.Colors.withAlpha(Root.Colors.outlineVariant, Root.Colors.separatorOpacity)
        border.width: 1

        MouseArea { anchors.fill: parent }

        Column {
            id: popupColumn
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 16
            spacing: 12

            Item {
                width: parent.width
                height: 32

                Row {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    Text {
                        text: soundPopup.soundWidget ? soundPopup.soundWidget.soundIconName : "volume_off"
                        font.family: materialFont.name
                        font.pixelSize: 26
                        font.variableAxes: { "FILL": 1, "GRAD": -25, "opsz": 24, "wght": 400 }
                        color: soundPopup.soundWidget && soundPopup.soundWidget.muted ? Root.Colors.error : Root.Colors.info
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: soundPopup.soundWidget ? (soundPopup.soundWidget.volume + "%") : "--"
                        font.pixelSize: 20
                        font.bold: true
                        color: Root.Colors.textPrimary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Rectangle {
                    width: 30
                    height: 30
                    radius: 8
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    color: pavucontrolMouse.containsMouse
                        ? Root.Colors.withAlpha(Root.Colors.surfaceContainerHigh, 0.9)
                        : Root.Colors.withAlpha(Root.Colors.surfaceContainerHigh, Root.Colors.cardOpacity)
                    border.color: Root.Colors.withAlpha(Root.Colors.outlineVariant, Root.Colors.separatorOpacity)
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "tune"
                        font.family: materialFont.name
                        font.pixelSize: 19
                        font.variableAxes: { "FILL": 0, "GRAD": -25, "opsz": 24, "wght": 450 }
                        color: Root.Colors.textPrimary
                    }

                    MouseArea {
                        id: pavucontrolMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: soundPopup.openPavucontrol()
                    }
                }
            }

            Rectangle {
                id: sliderTrack
                width: parent.width
                height: 12
                radius: 6
                color: Root.Colors.withAlpha(Root.Colors.surfaceContainerHigh, Root.Colors.cardOpacity)

                Rectangle {
                    width: soundPopup.soundWidget ? (sliderTrack.width * soundPopup.soundWidget.volume / 100.0) : 0
                    height: parent.height
                    radius: 6
                    color: soundPopup.soundWidget && soundPopup.soundWidget.muted ? Root.Colors.error : Root.Colors.info

                    Behavior on width { NumberAnimation { duration: 80 } }
                }

                Rectangle {
                    width: 18
                    height: 18
                    radius: 9
                    color: Root.Colors.textPrimary
                    border.color: Root.Colors.info
                    border.width: 1
                    anchors.verticalCenter: parent.verticalCenter
                    x: soundPopup.soundWidget ? (sliderTrack.width * soundPopup.soundWidget.volume / 100.0) - width / 2 : -width / 2
                }

                MouseArea {
                    id: sliderArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    function setFromX(mouseX) {
                        if (!soundPopup.soundWidget) return;
                        const pct = Math.max(0, Math.min(100, Math.round((mouseX / width) * 100)));
                        soundPopup.soundWidget.setVolume(pct);
                    }

                    onPressed: function(mouse) {
                        setFromX(mouse.x);
                    }

                    onPositionChanged: function(mouse) {
                        if (pressed)
                            setFromX(mouse.x);
                    }

                    onWheel: function(wheel) {
                        if (!soundPopup.soundWidget) return;
                        const step = wheel.angleDelta.y > 0 ? 5 : -5;
                        soundPopup.soundWidget.setVolume(soundPopup.soundWidget.volume + step);
                    }
                }
            }

        }
    }
}
