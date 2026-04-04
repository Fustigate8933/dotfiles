import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

Item {
  id: root
  anchors.verticalCenter: parent.verticalCenter
  anchors.verticalCenterOffset: -2
  height: parent.height

  // Dynamic width based on contents, since icons can expand a workspace.
  // Instead of static width, we put a RowLayout and let it size root.
  width: rowGroup.width

  // Configuration
  property int workspaceCount: 8
  property int baseButtonWidth: 45
  property int activeWorkspaceMargin: 3
  property int iconSize: 24

  // Find the current active index (0 to 8)
  property int activeIndex: Math.max(0, (Hyprland.focusedWorkspace?.id || 1) - 1)

  // Stretchy highlight
  Rectangle {
    id: activeHighlight
    color: "#7aa2f7" // TokyoNight primary color (Ambxst default-ish)

    // We animate position based on layout
    // We can use a script to find the target x and width from the Repeater's children
    property real targetX: 0
    property real targetWidth: 0

    width: targetWidth
    height: root.height - root.activeWorkspaceMargin * 2
    radius: height / 2

    anchors.verticalCenter: parent.verticalCenter
    x: targetX

    Behavior on x {
      NumberAnimation { duration: 250; easing.type: Easing.OutQuint }
    }
    Behavior on width {
      NumberAnimation { duration: 250; easing.type: Easing.OutQuint }
    }
  }

  // Timer to update highlight geometry smoothly when active workspace changes
  Timer {
    id: highlightUpdater
    interval: 50
    repeat: true
    running: true
    onTriggered: {
      let child = rowGroup.children[root.activeIndex]
      if (child) {
        activeHighlight.targetX = child.x + root.activeWorkspaceMargin
        activeHighlight.targetWidth = child.width - root.activeWorkspaceMargin * 2
      }
    }
  }

  Row {
    id: rowGroup
    anchors.verticalCenter: parent.verticalCenter
    height: parent.height
    spacing: 0

    Repeater {
      model: root.workspaceCount

      Item {
        id: wsBtn
        height: rowGroup.height
        // Width adapts to icons:
        width: Math.max(root.baseButtonWidth, iconRow.width + 24)

        property int wsId: index + 1
        property bool isActive: index === root.activeIndex

        // Clients currently in this workspace
        property var clients: Hyprland.toplevels ? Hyprland.toplevels.values.filter(c => c.workspace && c.workspace.id === wsId) : []
        property bool isOccupied: clients.length > 0

        // Passive background highlight for inactive but occupied workspaces
        Rectangle {
          id: passiveHighlight
          anchors.centerIn: parent
          width: parent.width - root.activeWorkspaceMargin * 2
          height: parent.height - root.activeWorkspaceMargin * 2
          radius: height / 2
          color: "#444b6a"
          opacity: (wsBtn.isOccupied && !wsBtn.isActive) ? 0.7 : 0
        }

        Row {
          id: iconRow
          anchors.centerIn: parent
          spacing: 8

          Repeater {
            model: wsBtn.clients

            Item {
              width: root.iconSize
              height: root.iconSize

              property string appClass: ""

              Timer {
                interval: 100
                running: parent.appClass === ""
                repeat: true
                onTriggered: {
                  // Official Quickshell Docs: "lastIpcObject is not updated automatically. You may need to call Hyprland.refreshToplevels() to ensure the data is current."
                  Hyprland.refreshToplevels();
                  
                  let ipc = modelData.lastIpcObject;
                  let wl = modelData.wayland;
                  let cls = ipc ? (ipc.class || ipc.initialClass || "") : (wl ? (wl.appId || "") : (modelData.title || ""));
                  if (cls !== "") {
                    parent.appClass = cls;
                  }
                }
              }

              Loader {
                anchors.fill: parent
                active: parent.appClass !== "" && parent.appClass !== "wayland"
                
                sourceComponent: Component {
                  Item {
                    anchors.fill: parent

                    IconImage {
                      id: sourceImg
                      anchors.fill: parent
                      source: Quickshell.iconPath(appClass.toLowerCase(), "wayland")
                      visible: false
                    }

                    Item {
                      id: iconMask
                      anchors.fill: parent
                      visible: false
                      layer.enabled: true
                      Rectangle {
                        anchors.fill: parent
                        radius: width / 2
                        color: "white"
                      }
                    }

                    MultiEffect {
                      anchors.fill: parent
                      source: sourceImg
                      maskEnabled: true
                      maskSource: iconMask
                      opacity: wsBtn.isActive ? 1 : 0.8
                    }
                  }
                }
              }
            }
          }
        }

        // Small dot for unoccupied (empty workspaces don't have clients)
        Rectangle {
          anchors.centerIn: parent
          width: 6
          height: 6
          radius: 3
          color: "#444b6a"
          opacity: (wsBtn.isActive || wsBtn.isOccupied) ? 0 : 1
          Behavior on opacity { NumberAnimation { duration: 150 } }
        }

        MouseArea {
          anchors.fill: parent
          onClicked: Hyprland.dispatch("workspace " + wsId)
        }
      }
    }
  }
}
