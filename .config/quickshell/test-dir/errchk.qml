import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.DBusMenu
import QtQuick

ShellRoot {
    Component.onCompleted: {
        console.log("Checking DBusMenu...")
        Qt.quit()
    }
    QsMenuOpener {}
}
