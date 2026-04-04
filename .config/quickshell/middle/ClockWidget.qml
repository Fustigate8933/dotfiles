import Quickshell
import QtQuick
import QtQuick.Layouts

Item {
  id: root
  width: clockContent.width + 24
  height: parent.height
  
  Rectangle {
    anchors.centerIn: parent
    width: parent.width
    height: parent.height - 12
    radius: height / 2
    color: Qt.rgba(1, 1, 1, 0.06) // Very subtle translucent background
  }

  Row {
    id: clockContent
    anchors.centerIn: parent
    spacing: 8

    // Local Native Clock
    property var currentTime: new Date()
    Timer {
      interval: 1000
      running: true
      repeat: true
      onTriggered: parent.currentTime = new Date()
    }

    Text {
      text: {
        const date = clockContent.currentTime;
        if (!date) return "--:--:--";
        const h = date.getHours();
        const m = String(date.getMinutes()).padStart(2, '0');
        const s = String(date.getSeconds()).padStart(2, '0');
        const ampm = h >= 12 ? "PM" : "AM";
        const displayH = h % 12 || 12;
        return `${displayH}:${m}:${s} ${ampm}`;
      }
      font.pixelSize: 15
      font.weight: Font.DemiBold
      color: "#c0caf5"
      anchors.verticalCenter: parent.verticalCenter
    }

    Text {
      text: "•"
      font.pixelSize: 12
      color: "#565f89" // Dimmed separator
      anchors.verticalCenter: parent.verticalCenter
    }

    Text {
      text: {
        const date = clockContent.currentTime;
        if (!date) return "--";
        const days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
        const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
        return `${days[date.getDay()]} ${months[date.getMonth()]} ${date.getDate()}`;
      }
      font.pixelSize: 15
      font.weight: Font.DemiBold
      color: "#c0caf5" 
      anchors.verticalCenter: parent.verticalCenter
    }
  }
}
