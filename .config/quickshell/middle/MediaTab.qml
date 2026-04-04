import Quickshell
import Quickshell.Services.Mpris
import QtQuick

Item {
    id: root
    implicitWidth: parent ? parent.width : 668
    implicitHeight: 410

    // Material Symbols font
    FontLoader {
        id: materialFont
        source: Qt.resolvedUrl("../DankMaterialShell/quickshell/assets/fonts/material-design-icons/variablefont/MaterialSymbolsRounded[FILL,GRAD,opsz,wght].ttf")
    }

    property var players: Mpris.players.values
    property MprisPlayer activePlayer: players.length > 0 ? players[0] : null

    // Position tracking timer
    Timer {
        interval: 1000
        running: activePlayer && activePlayer.playbackState === MprisPlaybackState.Playing
        repeat: true
        onTriggered: if (activePlayer) activePlayer.positionChanged()
    }

    function formatTime(sec) {
        if (!sec || sec < 0) return "0:00";
        let m = Math.floor(sec / 60);
        let s = Math.floor(sec % 60);
        return m + ":" + (s < 10 ? "0" : "") + s;
    }

    // ── No player placeholder ────────────────────────────────
    Column {
        anchors.centerIn: parent
        spacing: 12
        visible: !activePlayer

        Text {
            text: "music_off"
            font.family: materialFont.name
            font.pixelSize: 64
            font.variableAxes: { "FILL": 0, "GRAD": -25, "opsz": 24, "wght": 400 }
            color: "#3b3f52"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            text: "No Active Players"
            font.pixelSize: 16
            color: "#565f89"
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    // ── Player content ───────────────────────────────────────
    Column {
        anchors.fill: parent
        spacing: 12
        visible: !!activePlayer

        // Album art
        Rectangle {
            width: 200
            height: 200
            radius: 12
            anchors.horizontalCenter: parent.horizontalCenter
            color: Qt.rgba(1, 1, 1, 0.04)
            clip: true

            Image {
                anchors.fill: parent
                source: activePlayer ? activePlayer.trackArtUrl : ""
                fillMode: Image.PreserveAspectCrop
                visible: status === Image.Ready
            }

            Text {
                anchors.centerIn: parent
                text: "album"
                font.family: materialFont.name
                font.pixelSize: 64
                font.variableAxes: { "FILL": 0, "GRAD": -25, "opsz": 24, "wght": 400 }
                color: "#3b3f52"
                visible: !activePlayer || !activePlayer.trackArtUrl
            }
        }

        // Track info
        Column {
            width: parent.width
            spacing: 2

            Text {
                width: parent.width
                text: activePlayer ? (activePlayer.trackTitle || "Unknown Track") : ""
                font.pixelSize: 18
                font.bold: true
                color: "#c0caf5"
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            Text {
                width: parent.width
                text: {
                    if (!activePlayer) return "";
                    let parts = [];
                    if (activePlayer.trackArtist) parts.push(activePlayer.trackArtist);
                    if (activePlayer.trackAlbum) parts.push(activePlayer.trackAlbum);
                    return parts.join(" • ");
                }
                font.pixelSize: 13
                color: "#a9b1d6"
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                maximumLineCount: 1
            }
        }

        // Seek bar
        Column {
            width: parent.width * 0.7
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 2

            Rectangle {
                width: parent.width
                height: 6
                radius: 3
                color: Qt.rgba(1, 1, 1, 0.08)

                Rectangle {
                    width: {
                        if (!activePlayer || !activePlayer.length || activePlayer.length <= 0) return 0;
                        let pos = activePlayer.position || 0;
                        return parent.width * Math.min(1, Math.max(0, pos / activePlayer.length));
                    }
                    height: parent.height
                    radius: 3
                    color: "#bb9af7"

                    Behavior on width { NumberAnimation { duration: 200 } }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: function(mouse) {
                        if (activePlayer && activePlayer.canSeek && activePlayer.length > 0) {
                            let ratio = mouse.x / parent.width;
                            activePlayer.position = ratio * activePlayer.length;
                        }
                    }
                }
            }

            Row {
                width: parent.width
                Text {
                    text: activePlayer ? root.formatTime(activePlayer.position) : "0:00"
                    font.pixelSize: 10
                    color: "#565f89"
                }
                Item { width: parent.width - 60; height: 1 }
                Text {
                    text: activePlayer ? root.formatTime(activePlayer.length) : "0:00"
                    font.pixelSize: 10
                    color: "#565f89"
                    horizontalAlignment: Text.AlignRight
                }
            }
        }

        // Playback controls
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 16
            height: 50

            // Previous
            Rectangle {
                width: 44; height: 44; radius: 22
                anchors.verticalCenter: parent.verticalCenter
                color: prevArea.containsMouse ? Qt.rgba(1,1,1,0.08) : "transparent"

                Text {
                    text: "skip_previous"
                    font.family: materialFont.name; font.pixelSize: 26
                    font.variableAxes: { "FILL": 1, "GRAD": -25, "opsz": 24, "wght": 400 }
                    color: "#c0caf5"; anchors.centerIn: parent
                }
                MouseArea {
                    id: prevArea; anchors.fill: parent; hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if (activePlayer) activePlayer.previous()
                }
            }

            // Play/Pause
            Rectangle {
                width: 56; height: 56; radius: 28
                anchors.verticalCenter: parent.verticalCenter
                color: "#bb9af7"

                Text {
                    text: activePlayer && activePlayer.playbackState === MprisPlaybackState.Playing ? "pause" : "play_arrow"
                    font.family: materialFont.name; font.pixelSize: 32
                    font.variableAxes: { "FILL": 1, "GRAD": -25, "opsz": 24, "wght": 500 }
                    color: "#1a1b26"; anchors.centerIn: parent
                }
                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: if (activePlayer) activePlayer.togglePlaying()
                }
            }

            // Next
            Rectangle {
                width: 44; height: 44; radius: 22
                anchors.verticalCenter: parent.verticalCenter
                color: nextArea.containsMouse ? Qt.rgba(1,1,1,0.08) : "transparent"

                Text {
                    text: "skip_next"
                    font.family: materialFont.name; font.pixelSize: 26
                    font.variableAxes: { "FILL": 1, "GRAD": -25, "opsz": 24, "wght": 400 }
                    color: "#c0caf5"; anchors.centerIn: parent
                }
                MouseArea {
                    id: nextArea; anchors.fill: parent; hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if (activePlayer) activePlayer.next()
                }
            }
        }
    }
}
