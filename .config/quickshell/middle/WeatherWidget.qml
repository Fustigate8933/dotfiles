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

    function setFallbackWeather() {
      weatherIcon = "☁";
      weatherTemp = "-°";
    }

    function applyWeatherOutput(rawOutput) {
      let output = (rawOutput || "").trim();
      if (output.length === 0) {
        setFallbackWeather();
        return;
      }

      // wttr.in occasionally responds with its full HTML/CSS page.
      // Never render that directly in the bar.
      if (output.indexOf("<") !== -1 || output.indexOf("{") !== -1 || output.indexOf("}") !== -1
          || output.indexOf(".term-fg") !== -1 || output.indexOf("color: #") !== -1) {
        setFallbackWeather();
        return;
      }

      output = output.replace(/\+/g, "").replace(/\s+/g, " ").trim();

      const directMatch = output.match(/^(\S+)\s+(-?\d+°[CF]?)/);
      if (directMatch) {
        weatherIcon = directMatch[1];
        weatherTemp = directMatch[2];
        return;
      }

      const tempMatch = output.match(/-?\d+°[CF]?/);
      if (tempMatch) {
        weatherIcon = "☁";
        weatherTemp = tempMatch[0];
        return;
      }

      setFallbackWeather();
    }
    
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
              parent.applyWeatherOutput(xhr.responseText);
            } else {
              parent.setFallbackWeather();
            }
          }
        }
        xhr.open("GET", "https://wttr.in/?format=%c+%t");
        xhr.setRequestHeader("Accept", "text/plain");
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
      width: 56
      elide: Text.ElideRight
    }
  }
}
