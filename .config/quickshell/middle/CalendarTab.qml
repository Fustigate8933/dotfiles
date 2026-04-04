import QtQuick

Item {
    id: root
    implicitWidth: parent ? parent.width : 668
    implicitHeight: calendarColumn.height

    property var currentDate: new Date()
    property int displayMonth: currentDate.getMonth()
    property int displayYear: currentDate.getFullYear()

    function daysInMonth(month, year) {
        return new Date(year, month + 1, 0).getDate();
    }

    function firstDayOfWeek(month, year) {
        let d = new Date(year, month, 1).getDay();
        return d === 0 ? 6 : d - 1; // Monday = 0
    }

    function prevMonth() {
        if (displayMonth === 0) { displayMonth = 11; displayYear--; }
        else displayMonth--;
    }

    function nextMonth() {
        if (displayMonth === 11) { displayMonth = 0; displayYear++; }
        else displayMonth++;
    }

    // Update current date every minute
    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: root.currentDate = new Date()
    }

    Column {
        id: calendarColumn
        width: parent.width
        spacing: 12

        // ── Month/Year header with navigation ────────────────
        Row {
            width: parent.width
            height: 40

            Rectangle {
                width: 36; height: 36; radius: 18
                anchors.verticalCenter: parent.verticalCenter
                color: prevMA.containsMouse ? Qt.rgba(1,1,1,0.08) : "transparent"
                Text {
                    text: "‹"; font.pixelSize: 20; color: "#c0caf5"
                    anchors.centerIn: parent
                }
                MouseArea {
                    id: prevMA; anchors.fill: parent; hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor; onClicked: root.prevMonth()
                }
            }

            Item { width: parent.width - 72; height: parent.height
                Text {
                    anchors.centerIn: parent
                    text: {
                        const months = ["January","February","March","April","May","June",
                                        "July","August","September","October","November","December"];
                        return months[root.displayMonth] + " " + root.displayYear;
                    }
                    font.pixelSize: 16; font.bold: true; color: "#c0caf5"
                }
            }

            Rectangle {
                width: 36; height: 36; radius: 18
                anchors.verticalCenter: parent.verticalCenter
                color: nextMA.containsMouse ? Qt.rgba(1,1,1,0.08) : "transparent"
                Text {
                    text: "›"; font.pixelSize: 20; color: "#c0caf5"
                    anchors.centerIn: parent
                }
                MouseArea {
                    id: nextMA; anchors.fill: parent; hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor; onClicked: root.nextMonth()
                }
            }
        }

        // ── Day-of-week headers ──────────────────────────────
        Row {
            width: parent.width
            height: 28
            Repeater {
                model: ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
                Text {
                    width: root.width / 7
                    text: modelData
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                    color: "#565f89"
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        // ── Calendar grid ────────────────────────────────────
        Grid {
            id: calGrid
            width: parent.width
            columns: 7
            rowSpacing: 4
            columnSpacing: 0

            property int totalDays: root.daysInMonth(root.displayMonth, root.displayYear)
            property int startOffset: root.firstDayOfWeek(root.displayMonth, root.displayYear)
            property int prevMonthDays: root.daysInMonth(root.displayMonth === 0 ? 11 : root.displayMonth - 1, root.displayMonth === 0 ? root.displayYear - 1 : root.displayYear)
            property int totalCells: 42
            property int todayDate: root.currentDate.getDate()
            property int todayMonth: root.currentDate.getMonth()
            property int todayYear: root.currentDate.getFullYear()

            Repeater {
                model: calGrid.totalCells

                Rectangle {
                    required property int index

                    property int dayNum: {
                        if (index < calGrid.startOffset)
                            return calGrid.prevMonthDays - calGrid.startOffset + index + 1;
                        if (index < calGrid.startOffset + calGrid.totalDays)
                            return index - calGrid.startOffset + 1;
                        return index - calGrid.startOffset - calGrid.totalDays + 1;
                    }

                    property bool isCurrentMonth: index >= calGrid.startOffset && index < calGrid.startOffset + calGrid.totalDays
                    property bool isToday: isCurrentMonth && dayNum === calGrid.todayDate && root.displayMonth === calGrid.todayMonth && root.displayYear === calGrid.todayYear

                    width: root.width / 7
                    height: 36
                    radius: 18
                    color: isToday ? "#bb9af7" : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: parent.dayNum
                        font.pixelSize: 13
                        font.bold: parent.isToday
                        color: {
                            if (parent.isToday) return "#1a1b26";
                            if (!parent.isCurrentMonth) return "#3b3f52";
                            return "#c0caf5";
                        }
                    }
                }
            }
        }

        // ── Today shortcut ───────────────────────────────────
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8
            visible: root.displayMonth !== root.currentDate.getMonth() || root.displayYear !== root.currentDate.getFullYear()

            Rectangle {
                width: todayLabel.width + 20
                height: 28
                radius: 14
                color: Qt.rgba(1, 1, 1, 0.06)

                Text {
                    id: todayLabel
                    text: "Today"
                    font.pixelSize: 12
                    color: "#bb9af7"
                    anchors.centerIn: parent
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.displayMonth = root.currentDate.getMonth();
                        root.displayYear = root.currentDate.getFullYear();
                    }
                }
            }
        }
    }
}
