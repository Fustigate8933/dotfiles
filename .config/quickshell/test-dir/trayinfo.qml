import Quickshell
import Quickshell.Services.SystemTray
import QtQuick

ShellRoot {
    Component.onCompleted: {
        let items = SystemTray.items.values
        if(items.length > 0) {
            let item = items[0]
            console.log("Tray item properties:")
            for(var prop in item) {
                console.log(prop + ": " + typeof item[prop])
            }
        } else {
             console.log("No tray items found.")
        }
        Qt.quit()
    }
}
