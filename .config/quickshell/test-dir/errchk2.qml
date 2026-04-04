import Quickshell
import Quickshell.DBusMenu
import QtQuick

ShellRoot {
    Component.onCompleted: {
        console.log("QsMenuOpener properties:")
        let props = []
        for(var prop in menuOpener) {
            props.push(prop + ":" + typeof menuOpener[prop])
        }
        console.log(props.join(", "))
        Qt.quit()
    }
    QsMenuOpener {
        id: menuOpener
    }
}
