import Quickshell
import Quickshell.Hyprland
import QtQuick

ShellRoot {
    Component.onCompleted: {
        console.log("Checking toplevel correctly");
        if (Hyprland.toplevels && Hyprland.toplevels.values.length > 0) {
            let top = Hyprland.toplevels.values[0];
            // Since it's QVariantMap probably, let's just log what we can
            if (top.lastIpcObject) {
               console.log("lastIpc:", JSON.stringify(top.lastIpcObject));
            }
            if (top.wayland) {
               console.log("wayland keys:", Object.keys(top.wayland));
               console.log("wayland appId:", top.wayland.appId);
            }
        }
        Qt.quit()
    }
}
