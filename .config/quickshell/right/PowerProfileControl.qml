pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick
import ".." as Root

// Reads/writes ~/.asus_profile. The ~/.set_asus_profile.sh daemon
// (started by Hyprland) picks up changes within ~2s and applies them
// via asusctl + powerprofilesctl. This component is just the UI + file I/O.
Item {
    id: control

    // One of: "Quiet", "Balanced", "Performance" (empty until first read)
    property string activeProfile: ""
    readonly property var profiles: ["Quiet", "Balanced", "Performance"]

    implicitWidth: parent ? parent.width : 0
    implicitHeight: row.implicitHeight

    // Reactive read of the profile file; reflects external changes too.
    FileView {
        id: profileFile
        path: Qt.resolvedUrl(Quickshell.env("HOME") + "/.asus_profile")
        watchChanges: true
        onFileChanged: reload()
        onLoaded: control.activeProfile = text().trim()
        onTextChanged: control.activeProfile = text().trim()
    }

    // Write the desired profile; the daemon applies it.
    function setProfile(name) {
        if (name === control.activeProfile)
            return;
        // Optimistic UI; FileView will confirm on reload.
        control.activeProfile = name;
        writeProc.command = ["sh", "-c",
            "printf '%s\\n' " + JSON.stringify(name) + " > \"$HOME/.asus_profile\""];
        writeProc.running = true;
    }

    Process {
        id: writeProc
        running: false
    }

    Row {
        id: row
        width: parent ? parent.width : implicitWidth
        spacing: 6

        Repeater {
            model: control.profiles

            Rectangle {
                required property string modelData
                readonly property bool isActive: modelData === control.activeProfile

                width: (row.width - row.spacing * (control.profiles.length - 1)) / control.profiles.length
                height: 34
                radius: 8
                color: isActive
                    ? Root.Colors.withAlpha(Root.Colors.primary, 0.22)
                    : Root.Colors.withAlpha(Root.Colors.surfaceContainerHigh, Root.Colors.cardOpacity)
                border.width: isActive ? 1 : 0
                border.color: Root.Colors.withAlpha(Root.Colors.primary, 0.6)

                Behavior on color { ColorAnimation { duration: 120 } }

                Text {
                    anchors.centerIn: parent
                    text: parent.modelData
                    font.pixelSize: 12
                    font.bold: parent.isActive
                    color: parent.isActive ? Root.Colors.primary : "#a9b1d6"
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: control.setProfile(parent.modelData)
                }
            }
        }
    }
}
