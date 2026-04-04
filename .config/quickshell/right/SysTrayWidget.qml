import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import Quickshell.Io
import QtQuick
import ".." as Root

Item {
  id: root
  width: trayRow.width + 24
  height: parent.height
  visible: SystemTray.items.values.length > 0
  
  Process {
    id: dbusProcess
  }
  
  function callContextMenuFallback(trayItemId, globalX, globalY, isRightClick) {
      const script = [
        'ITEMS=$(dbus-send --session --print-reply --dest=org.kde.StatusNotifierWatcher /StatusNotifierWatcher org.freedesktop.DBus.Properties.Get string:org.kde.StatusNotifierWatcher string:RegisteredStatusNotifierItems 2>/dev/null)',
        'TARGET_ID=$(echo "$1" | tr "[:upper:]" "[:lower:]")',
        'while IFS= read -r line; do',
        '  line="${line#*\\\"}"',
        '  line="${line%\\\"*}"',
        '  [ -z "$line" ] && continue',
        '  BUS="${line%%/*}"',
        '  OBJ="/${line#*/}"',
        '  ID=$(dbus-send --session --print-reply --dest="$BUS" "$OBJ" org.freedesktop.DBus.Properties.Get string:org.kde.StatusNotifierItem string:Id 2>/dev/null | grep -oP "(?<=\\\")(.*?)(?=\\\")" | tail -1 | tr "[:upper:]" "[:lower:]")',
        '  BUS_L=$(echo "$BUS" | tr "[:upper:]" "[:lower:]")',
        '  OBJ_L=$(echo "$OBJ" | tr "[:upper:]" "[:lower:]")',
        '  if [[ "$ID" == *"$TARGET_ID"* ]] || [[ "$TARGET_ID" == *"$ID"* ]] || [[ "$BUS_L" == *"$TARGET_ID"* ]] || [[ "$OBJ_L" == *"$TARGET_ID"* ]]; then',
        '    if [ "$4" = "true" ]; then',
        '      dbus-send --session --type=method_call --dest="$BUS" "$OBJ" org.kde.StatusNotifierItem.SecondaryActivate int32:"$2" int32:"$3" 2>/dev/null || true',
        '      dbus-send --session --type=method_call --dest="$BUS" "$OBJ" org.kde.StatusNotifierItem.ContextMenu int32:"$2" int32:"$3" 2>/dev/null || true',
        '    else',
        '      dbus-send --session --type=method_call --dest="$BUS" "$OBJ" org.kde.StatusNotifierItem.Activate int32:"$2" int32:"$3" 2>/dev/null || true',
        '    fi',
        '    exit 0',
        '  fi',
        'done <<< "$ITEMS"'
      ].join("\n");
      dbusProcess.command = ["bash", "-c", script, "_", trayItemId, String(globalX), String(globalY), String(isRightClick)];
      dbusProcess.running = true;
  }

  Rectangle {
    anchors.centerIn: parent
    width: parent.width
    height: parent.height - 12
    radius: height / 2
    color: Root.Colors.withAlpha(Root.Colors.systrayChipBackground, Root.Colors.systrayChipOpacity)
  }

  Row {
    id: trayRow
    anchors.centerIn: parent
    spacing: 8

    Repeater {
      model: SystemTray.items.values

      delegate: Item {
        width: 24
        height: 24
        anchors.verticalCenter: parent.verticalCenter

        property var trayItem: modelData

        IconImage {
          id: iconImg
          anchors.centerIn: parent
          width: 18
          height: 18
          source: {
            let icon = trayItem && trayItem.icon;
            if (typeof icon === 'string' || icon instanceof String) {
                if (icon === "") return "";
                if (icon.startsWith("/") && !icon.startsWith("file://")) return `file://${icon}`;
                return icon;
            }
            return "";
          }
        }

        MouseArea {
          id: trayMouseArea
          anchors.fill: parent
          acceptedButtons: Qt.LeftButton | Qt.RightButton
          cursorShape: Qt.PointingHandCursor
          onClicked: (mouse) => {
             const gp = trayMouseArea.mapToGlobal(mouse.x, mouse.y);
             if (mouse.button === Qt.LeftButton) {
                 if (trayItem && trayItem.activate) trayItem.activate(gp.x, gp.y);
                 root.callContextMenuFallback(trayItem.id, Math.round(gp.x), Math.round(gp.y), false);
             } else if (mouse.button === Qt.RightButton) {
                 if (trayItem && (trayItem.hasMenu || trayItem.menu)) {
                     const itemCenterGp = trayMouseArea.mapToGlobal(trayMouseArea.width / 2, trayMouseArea.height);
                     globalTrayMenu.activeTrayItem = trayItem;
                     globalTrayMenu.originX = itemCenterGp.x;
                     globalTrayMenu.originY = 45;
                     globalTrayMenu.visible = true;
                 } else {
                     if (trayItem && trayItem.secondaryActivate) trayItem.secondaryActivate();
                     root.callContextMenuFallback(trayItem.id, Math.round(gp.x), Math.round(gp.y), true);
                 }
             }
          }
        }
      }
    }
  }
}
