import Quickshell
import Quickshell.Io
import QtQuick

Item {
    id: root
    implicitWidth: parent ? parent.width : 668
    implicitHeight: 350  // Fixed max height for scrolling

    property string wallpaperDir: "/home/fustigate/Pictures"
    property var wallpapers: []
    property string currentWallpaper: ""

    // Material Symbols font
    FontLoader {
        id: materialFont
        source: Qt.resolvedUrl("../assets/fonts/material-design-icons/variablefont/MaterialSymbolsRounded[FILL,GRAD,opsz,wght].ttf")
    }

    // Scan wallpapers directory
    Process {
        id: scanProc
        command: ["sh", "-c", "find '" + root.wallpaperDir + "' -maxdepth 1 -type f \\( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' -o -iname '*.bmp' -o -iname '*.gif' \\) -printf '%T@ %f\\n' | sort -rn | cut -d' ' -f2-"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                let trimmed = data.trim();
                if (trimmed.length > 0) {
                    let current = root.wallpapers.slice();
                    current.push(trimmed);
                    root.wallpapers = current;
                }
            }
        }
    }

    // Get current wallpaper
    Process {
        id: getCurrentProc
        command: ["sh", "-c", "swww query 2>/dev/null | head -1 | sed 's/.*image: //' | xargs basename 2>/dev/null"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                root.currentWallpaper = data.trim();
            }
        }
    }

    Column {
        width: parent.width
        spacing: 12

        // ── Header ───────────────────────────────────────────
        Row {
            width: parent.width
            height: 32
            spacing: 8

            Text {
                text: "wallpaper"
                font.family: materialFont.name
                font.pixelSize: 20
                font.variableAxes: { "FILL": 0, "GRAD": -25, "opsz": 24, "wght": 400 }
                color: "#7aa2f7"
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: root.wallpapers.length + " wallpapers in ~/Pictures"
                font.pixelSize: 13
                color: "#565f89"
                anchors.verticalCenter: parent.verticalCenter
            }

            Item { width: parent.width - 250; height: 1 }

            Rectangle {
                width: refreshLabel.width + 20
                height: 28; radius: 14
                anchors.verticalCenter: parent.verticalCenter
                color: refreshMA.containsMouse ? Qt.rgba(1,1,1,0.08) : Qt.rgba(1,1,1,0.04)

                Text {
                    id: refreshLabel; text: "Refresh"; font.pixelSize: 11; color: "#a9b1d6"
                    anchors.centerIn: parent
                }
                MouseArea {
                    id: refreshMA; anchors.fill: parent; hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.wallpapers = [];
                        scanProc.running = true;
                    }
                }
            }
        }

        // ── Grid ─────────────────────────────────────────────
        GridView {
            id: wallpaperGrid
            width: parent.width
            height: 280  // Max height - makes it scrollable
            cellWidth: width / 4
            cellHeight: 120
            clip: true
            interactive: true
            boundsBehavior: Flickable.StopAtBounds

            model: root.wallpapers

            delegate: Item {
                required property string modelData
                required property int index

                width: wallpaperGrid.cellWidth
                height: wallpaperGrid.cellHeight

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 4
                    radius: 8
                    color: Qt.rgba(1, 1, 1, 0.04)
                    clip: true
                    border.color: modelData === root.currentWallpaper ? "#bb9af7" : "transparent"
                    border.width: modelData === root.currentWallpaper ? 2 : 0

                    Image {
                        anchors.fill: parent
                        anchors.margins: modelData === root.currentWallpaper ? 2 : 0
                        source: "file://" + root.wallpaperDir + "/" + modelData
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        sourceSize.width: 320
                        sourceSize.height: 200
                        cache: true

                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            radius: 6

                            // Hover overlay
                            Rectangle {
                                anchors.fill: parent
                                radius: 6
                                color: Qt.rgba(0, 0, 0, wpMA.containsMouse ? 0.3 : 0)
                                Behavior on color { ColorAnimation { duration: 150 } }
                            }

                            // Filename label on hover
                            Rectangle {
                                anchors.bottom: parent.bottom
                                anchors.left: parent.left
                                anchors.right: parent.right
                                height: 24
                                color: Qt.rgba(0, 0, 0, 0.6)
                                visible: wpMA.containsMouse
                                radius: 6

                                // Ugly hack to round only bottom corners
                                Rectangle {
                                    anchors.top: parent.top
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    height: parent.radius
                                    color: parent.color
                                }

                                Text {
                                    text: modelData
                                    font.pixelSize: 11
                                    color: "#c0caf5"
                                    anchors.centerIn: parent
                                    elide: Text.ElideMiddle
                                    width: parent.width - 8
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }
                        }
                    }

                    MouseArea {
                        id: wpMA
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            applyProc.command = ["swww", "img", root.wallpaperDir + "/" + modelData, "--transition-type", "fade", "--transition-duration", "1"];
                            applyProc.running = true;
                            root.currentWallpaper = modelData;
                        }
                    }
                }
            }
        }
    }

    Process {
        id: applyProc
        command: []
    }
}
