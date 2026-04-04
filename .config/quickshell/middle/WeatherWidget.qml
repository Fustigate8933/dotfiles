import Quickshell
import QtQuick
import QtQuick.Layouts
import ".." as Root

Item {
  id: root
  width: weatherContent.width + 24
  height: parent.height
  
  Rectangle {
    anchors.centerIn: parent
    width: parent.width
    height: parent.height - 12
    radius: height / 2
    color: Root.Colors.withAlpha(Root.Colors.weatherChipBackground, Root.Colors.weatherChipOpacity)
  }

  Row {
    id: weatherContent
    anchors.centerIn: parent
    spacing: -9

    property string weatherIcon: "☁" 
    property string weatherTemp: "--°" 
    
    Timer {
      interval: 1800000 // 30 minutes
      repeat: true
      running: true
      triggeredOnStart: true
      onTriggered: {
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
          if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status === 200) {
              let output = xhr.responseText.trim().replace(/\+/g, "");
              let parts = output.split(" ");
              if (parts.length > 1) {
                  parent.weatherIcon = parts[0];
                  parent.weatherTemp = parts.slice(1).join(" ");
              } else {
                  parent.weatherIcon = "☁";
                  parent.weatherTemp = output;
              }
            } else {
              parent.weatherIcon = "☁";
              parent.weatherTemp = "-°";
            }
          }
        }
        xhr.open("GET", "https://wttr.in/?format=%c+%t");
        xhr.send();
      }
    }

    Text {
      text: weatherContent.weatherIcon
      font.pixelSize: 21 // Scaled up icon
      color: Root.Colors.textPrimary
      anchors.verticalCenter: parent.verticalCenter
    }

    Text {
      text: weatherContent.weatherTemp
      font.pixelSize: 15
      font.weight: Font.DemiBold
      color: Root.Colors.textPrimary
      anchors.verticalCenter: parent.verticalCenter
    }
  }
}
