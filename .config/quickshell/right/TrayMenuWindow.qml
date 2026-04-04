import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.DBusMenu
import QtQuick
import ".." as Root

PanelWindow {
    id: trayMenuWindow
    visible: false
    color: "transparent"

    WlrLayershell.layer: WlrLayershell.Top
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    anchors { top: true; left: true; right: true; bottom: true }

    property var activeTrayItem: null
    property real originX: 0
    property real originY: 0

    // Navigation stack: list of menu handle objects we've drilled into
    property var navStack: []

    function close() {
        navStack = [];
        visible = false;
    }

    function pushMenu(entry) {
        var h = entry.menu || entry;
        if (subHydrator) {
            subHydrator.menu = h;
            subHydrator.open();
            // close the hydrator so it doesn't hold a ref, the opener will hold it
            Qt.callLater(function() { subHydrator.menu = null; });
        }
        navStack = navStack.concat([entry]);
    }

    function popMenu() {
        if (navStack.length === 0) return;
        navStack = navStack.slice(0, navStack.length - 1);
    }

    // Grab all input while open — fires onCleared when clicking outside (including bar)
    HyprlandFocusGrab {
        windows: [trayMenuWindow]
        active: trayMenuWindow.visible
        onCleared: trayMenuWindow.close()
    }

    // Dismiss on background click
    MouseArea {
        anchors.fill: parent
        onClicked: trayMenuWindow.close()
    }

    // Keep root menu alive
    QsMenuAnchor {
        id: rootAnchor
        anchor.window: trayMenuWindow
    }

    QsMenuOpener {
        id: rootOpener
        menu: activeTrayItem && trayMenuWindow.visible ? activeTrayItem.menu : null
    }

    // Hydrate submenu entries on drill-in
    QsMenuAnchor {
        id: subHydrator
        anchor.window: trayMenuWindow
    }

    QsMenuOpener {
        id: subOpener
        menu: {
            if (trayMenuWindow.navStack.length === 0) return null;
            var top = trayMenuWindow.navStack[trayMenuWindow.navStack.length - 1];
            return top.menu || top;
        }
    }

    Rectangle {
        id: menuBg
        width: 300
        height: menuColumn.height + 16

        x: Math.min(trayMenuWindow.width - width - 10, Math.max(10, trayMenuWindow.originX - width / 2))
        y: { console.log("MENU Y:", trayMenuWindow.originY, "final:", trayMenuWindow.originY + 8); return trayMenuWindow.originY + 8; }

        color: Root.Colors.withAlpha(Root.Colors.surfaceContainer, Root.Colors.popupOpacity)
        radius: 8
        border.color: Root.Colors.withAlpha(Root.Colors.outlineVariant, Root.Colors.separatorOpacity)
        border.width: 1

        Behavior on height { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }

        // Absorb clicks so background dismissal doesn't fire
        MouseArea { anchors.fill: parent }

        Column {
            id: menuColumn
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 8
            spacing: 2

            // ── Back button (visible when drilled in) ──────────────────────────
            Rectangle {
                visible: trayMenuWindow.navStack.length > 0
                width: menuColumn.width
                height: 28
                radius: 4
                color: backArea.containsMouse ? Qt.rgba(1, 1, 1, 0.1) : "transparent"

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 6

                    Text {
                        text: "←"
                        color: "#aaaaaa"
                        font.pixelSize: 13
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "Back"
                        color: "#aaaaaa"
                        font.pixelSize: 13
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: backArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: trayMenuWindow.popMenu()
                }
            }

            // Divider after Back button
            Rectangle {
                visible: trayMenuWindow.navStack.length > 0
                width: menuColumn.width
                height: 1
                color: Qt.rgba(1, 1, 1, 0.08)
            }

            // ── Menu entries ───────────────────────────────────────────────────
            Repeater {
                model: trayMenuWindow.navStack.length > 0 ? subOpener.children : rootOpener.children

                delegate: Rectangle {
                    property var menuEntry: modelData
                    width: menuColumn.width
                    height: menuEntry && menuEntry.isSeparator ? 9 : 28
                    radius: 4
                    color: !menuEntry || menuEntry.isSeparator ? "transparent"
                         : itemArea.containsMouse ? Qt.rgba(1, 1, 1, 0.1) : "transparent"

                    // Separator line
                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width - 8
                        height: 1
                        visible: menuEntry && menuEntry.isSeparator
                        color: Qt.rgba(1, 1, 1, 0.08)
                    }

                    // Label
                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 8
                        anchors.right: arrow.left
                        anchors.rightMargin: 4
                        anchors.verticalCenter: parent.verticalCenter
                        visible: menuEntry && !menuEntry.isSeparator
                        text: {
                            if (!menuEntry) return "";
                            return (menuEntry.text || menuEntry.label || "").replace(/&/g, "");
                        }
                        color: (menuEntry && menuEntry.enabled !== false) ? "#e0e0e0" : "#555555"
                        font.pixelSize: 13
                        elide: Text.ElideRight
                    }

                    // Chevron for items with children
                    Text {
                        id: arrow
                        anchors.right: parent.right
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        visible: menuEntry && menuEntry.hasChildren
                        text: "›"
                        color: "#888888"
                        font.pixelSize: 16
                    }

                    MouseArea {
                        id: itemArea
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: menuEntry && !menuEntry.isSeparator && menuEntry.enabled !== false
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (!menuEntry) return;
                            if (menuEntry.hasChildren) {
                                trayMenuWindow.pushMenu(menuEntry);
                                return;
                            }
                            if (typeof menuEntry.activate === "function") menuEntry.activate();
                            else if (typeof menuEntry.triggered === "function") menuEntry.triggered();
                            trayMenuWindow.close();
                        }
                    }
                }
            }
        }
    }
}
