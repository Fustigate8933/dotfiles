import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import ".." as Root

PanelWindow {
    id: powerPopup
    visible: false
    color: "transparent"

    WlrLayershell.layer: WlrLayershell.Top
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    anchors { top: true; left: true; right: true; bottom: true }

    property real originX: 0
    property real originY: 0

    // Track which action is pending confirmation (-1 = none)
    property int pendingAction: -1

    function close() {
        visible = false;
        pendingAction = -1;
    }

    function confirmAction(index) {
        if (pendingAction === index) {
            // Second tap — execute
            executeAction(index);
        } else {
            // First tap — arm
            pendingAction = index;
            confirmResetTimer.restart();
        }
    }

    function executeAction(index) {
        close();
        switch (index) {
            case 0: lockProcess.running = true; break;
            case 1: logoutProcess.running = true; break;
            case 2: rebootProcess.running = true; break;
            case 3: shutdownProcess.running = true; break;
        }
    }

    Timer {
        id: confirmResetTimer
        interval: 3000
        onTriggered: powerPopup.pendingAction = -1
    }

    Process {
        id: lockProcess
        command: ["loginctl", "lock-session"]
    }

    Process {
        id: logoutProcess
        command: ["hyprctl", "dispatch", "exit"]
    }

    Process {
        id: rebootProcess
        command: ["systemctl", "reboot"]
    }

    Process {
        id: shutdownProcess
        command: ["systemctl", "poweroff"]
    }

    FontLoader {
        id: materialFont
        source: Qt.resolvedUrl("../assets/fonts/material-design-icons/variablefont/MaterialSymbolsRounded[FILL,GRAD,opsz,wght].ttf")
    }

    HyprlandFocusGrab {
        windows: [powerPopup]
        active: powerPopup.visible
        onCleared: powerPopup.close()
    }

    // Click outside to close
    MouseArea {
        anchors.fill: parent
        onClicked: powerPopup.close()
    }

    Rectangle {
        id: popup
        width: 200
        height: popupColumn.implicitHeight + 32

        x: Math.min(powerPopup.width - width - 10, Math.max(10, powerPopup.originX - width / 2))
        y: powerPopup.originY + 8

        color: Root.Colors.withAlpha(Root.Colors.surfaceContainer, Root.Colors.popupOpacity)
        radius: 10
        border.color: Root.Colors.withAlpha(Root.Colors.outlineVariant, Root.Colors.separatorOpacity)
        border.width: 1

        // Prevent clicks inside popup from closing
        MouseArea { anchors.fill: parent }

        Column {
            id: popupColumn
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 16
            spacing: 4

            // Header
            Text {
                text: "Power"
                font.pixelSize: 13
                font.weight: Font.DemiBold
                color: Root.Colors.textSecondary
                bottomPadding: 4
            }

            Repeater {
                model: [
                    { icon: "lock",          label: "Lock",     confirmLabel: "Tap again to lock",     color: Root.Colors.powerLockColor },
                    { icon: "logout",        label: "Logout",   confirmLabel: "Tap again to logout",   color: Root.Colors.powerLogoutColor },
                    { icon: "restart_alt",   label: "Reboot",   confirmLabel: "Tap again to reboot",   color: Root.Colors.powerRebootColor },
                    { icon: "power_settings_new", label: "Shutdown", confirmLabel: "Tap again to shutdown", color: Root.Colors.powerShutdownColor }
                ]

                Rectangle {
                    id: actionBtn
                    required property var modelData
                    required property int index

                    width: popupColumn.width
                    height: 40
                    radius: 8

                    property bool isPending: powerPopup.pendingAction === index
                    property bool isHovered: btnMouse.containsMouse

                    color: {
                        if (isPending) return Root.Colors.withAlpha(modelData.color, 0.2);
                        if (isHovered) return Root.Colors.withAlpha(Root.Colors.surfaceContainerHigh, 0.9);
                        return "transparent";
                    }

                    Behavior on color { ColorAnimation { duration: 150 } }

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        spacing: 10

                        Text {
                            text: actionBtn.modelData.icon
                            font.family: materialFont.name
                            font.pixelSize: 20
                            font.variableAxes: { "FILL": actionBtn.isPending ? 1 : 0, "GRAD": -25, "opsz": 24, "wght": 400 }
                            color: actionBtn.isPending ? actionBtn.modelData.color : Root.Colors.textPrimary
                            anchors.verticalCenter: parent.verticalCenter

                            Behavior on color { ColorAnimation { duration: 150 } }
                        }

                        Text {
                            text: actionBtn.isPending ? actionBtn.modelData.confirmLabel : actionBtn.modelData.label
                            font.pixelSize: 13
                            font.weight: actionBtn.isPending ? Font.DemiBold : Font.Normal
                            color: actionBtn.isPending ? actionBtn.modelData.color : Root.Colors.textPrimary
                            anchors.verticalCenter: parent.verticalCenter

                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                    }

                    MouseArea {
                        id: btnMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: powerPopup.confirmAction(index)
                    }
                }
            }
        }
    }
}
