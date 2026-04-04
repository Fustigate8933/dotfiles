import Quickshell
import Quickshell.Services.SystemTray
import QtQuick

ShellRoot {
    Component.onCompleted: {
        let items = SystemTray.items.values
        let target = null
        for (let i = 0; i < items.length; i++) {
            if (items[i].id.indexOf("nm-applet") !== -1 || items[i].id.indexOf("blueman") !== -1) {
                target = items[i];
                break;
            }
        }
        if (target) {
            console.log("Found target: " + target.id)
            if (target.menu) {
                 console.log("Menu object properties:")
                 let mProps = []
                 for (let p in target.menu) {
                     mProps.push(p + ":" + typeof target.menu[p])
                 }
                 console.log(mProps.join(", "))
            } else {
                 console.log("Target has no menu property!")
            }
        } else {
             console.log("No nm-applet or blueman found. Items are:")
             items.forEach(it => console.log(it.id))
        }
        Qt.quit()
    }
}
