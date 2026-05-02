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
    spacing: 4

    property string weatherIcon: "☁" 
    property string weatherTemp: "--°" 

    function setFallbackWeather() {
      weatherIcon = "☁";
      weatherTemp = "-°";
    }

    function iconFromWeatherCode(code) {
      if (code === 113) return "☀";
      if (code === 116) return "⛅";
      if (code === 119 || code === 122 || code === 143 || code === 248 || code === 260) return "☁";
      if ((code >= 176 && code <= 185) || (code >= 263 && code <= 284) || code === 293 || code === 296 || code === 299 || code === 302) return "🌧";
      if (code >= 200 && code <= 232) return "⛈";
      if (code >= 323 && code <= 395) return "❄";
      return "☁";
    }

    function applyWeatherOutput(rawOutput) {
      if (!rawOutput || rawOutput.trim().length === 0) {
        setFallbackWeather();
        return;
      }

      try {
        const data = JSON.parse(rawOutput);
        const current = data.current_condition && data.current_condition[0];
        if (!current) {
          setFallbackWeather();
          return;
        }

        const code = parseInt(current.weatherCode, 10);
        const tempC = parseInt(current.temp_C, 10);
        if (isNaN(tempC)) {
          setFallbackWeather();
          return;
        }

        weatherIcon = iconFromWeatherCode(code);
        weatherTemp = tempC + "°C";
      } catch (_) {
        setFallbackWeather();
      }
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
        xhr.open("GET", "https://wttr.in/?format=j1");
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
