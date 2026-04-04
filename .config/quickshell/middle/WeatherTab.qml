import Quickshell
import QtQuick
import "../assets/suncalc.js" as SunCalc
import ".." as Root

Item {
  id: root
  implicitWidth: parent ? parent.width : 668
  implicitHeight: weatherColumn.height

  Component.onCompleted: {
    console.log("WeatherTab loaded successfully");
  }

  // Material Symbols font
  FontLoader {
    id: materialFont
    source: Qt.resolvedUrl("../assets/fonts/material-design-icons/variablefont/MaterialSymbolsRounded[FILL,GRAD,opsz,wght].ttf")
  }

  // NerdFont for moon phases
  FontLoader {
    id: nerdFont
    source: Qt.resolvedUrl("../assets/fonts/nerd-fonts/FiraCodeNerdFont-Regular.ttf")
  }

  // Weather data
  property bool available: false
  property int weatherCode: 0
  property string temp: "--"
  property string condition: "Loading..."
  property string feelsLike: "--"
  property string city: ""
  property string humidity: "--%"
  property string wind: "-- km/h"
  property string pressure: "-- hPa"
  property string precipitation: "--%"
  property string sunrise: "--:--"
  property string sunset: "--:--"
  property real sunriseHour: 6.5   // decimal hours
  property real sunsetHour: 19.5

  // Location for astronomical calculations
  property var location: null

  // Forecast data
  property var forecast: []        // 7-day daily
  property var hourlyForecast: []  // 24-hour hourly
  property bool showHourly: true
  property bool dense: true        // 10 items if true, 5 if false
  property bool syncing: false

  // Fetch weather data
  Timer {
    interval: 1800000
    repeat: true
    running: true
    triggeredOnStart: true
    onTriggered: { fetchWeather(); }
  }

  function fetchWeather() {
    var self = root;
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
      if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
        try {
          let data = JSON.parse(xhr.responseText);
          let cur = data.current_condition[0];
          let nearest = data.nearest_area[0];
          let astro = data.weather[0].astronomy[0];

          self.weatherCode = parseInt(cur.weatherCode);
          self.temp = cur.temp_C;
          self.feelsLike = cur.FeelsLikeC;
          self.condition = cur.weatherDesc[0].value;
          self.humidity = cur.humidity + "%";
          self.wind = cur.windspeedKmph + " km/h";
          self.pressure = cur.pressure + " hPa";
          self.precipitation = cur.precipMM + " mm";
          self.city = nearest.areaName[0].value;
          self.sunrise = astro.sunrise;
          self.sunset = astro.sunset;
          self.sunriseHour = self.parseTimeToHour(astro.sunrise);
          self.sunsetHour = self.parseTimeToHour(astro.sunset);

          // Store location for astronomical calculations
          let lat = parseFloat(nearest.latitude);
          let lon = parseFloat(nearest.longitude);
          self.location = { latitude: lat, longitude: lon };

          // Fetch 7-day and 24-h hourly from Open-Meteo
          self.fetchDetailedForecast(lat, lon);
          self.available = true;
        } catch(e) {
          console.warn("Weather parse error:", e);
        }
      }
    }
    xhr.open("GET", "https://wttr.in/?format=j1");
    xhr.send();
  }

  property int currentHourIndex: 0  // index of "now" in hourlyForecast

  function fetchDetailedForecast(lat, lon) {
    var self = root;
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
      if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
        try {
          let data = JSON.parse(xhr.responseText);

          // 7-Day Daily
          let daily = data.daily;
          let days = [];
          let dayNames = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"];
          for (let i = 0; i < daily.time.length && i < 7; i++) {
            let d = new Date(daily.time[i] + "T00:00:00");
            days.push({
              day: i === 0 ? "Today" : (i === 1 ? "Tomorrow" : dayNames[d.getDay()]),
              code: daily.weather_code[i],
              low: Math.round(daily.temperature_2m_min[i]),
              high: Math.round(daily.temperature_2m_max[i]),
              isWmo: true
            });
          }
          self.forecast = days;

          // Hourly (48 hours) — find current hour index
          let hourly = data.hourly;
          let hours = [];
          let nowMs = Date.now();
          let bestIdx = 0;
          for (let h = 0; h < hourly.time.length; h++) {
            let d = new Date(hourly.time[h]);
            if (d.getTime() <= nowMs) bestIdx = h;
            hours.push({
              time: (d.getHours() < 10 ? "0" : "") + d.getHours() + ":00",
              code: hourly.weather_code[h],
              temp: Math.round(hourly.temperature_2m[h]),
              isWmo: true,
              hourIndex: h
            });
          }
          self.currentHourIndex = bestIdx;
          self.hourlyForecast = hours;

        } catch(e) {
          console.warn("Open-Meteo parse error:", e);
        }
      }
    }
    // 48 hours of hourly + 7 days daily
    xhr.open("GET", "https://api.open-meteo.com/v1/forecast?latitude=" + lat + "&longitude=" + lon + "&hourly=temperature_2m,weather_code&daily=weather_code,temperature_2m_max,temperature_2m_min&timezone=auto&forecast_days=7&forecast_hours=48");
    xhr.send();
  }

  function getWeatherIcon(code) {
    if (code === 113) return isNight() ? "bedtime" : "clear_day";
    if (code === 116) return isNight() ? "nights_stay" : "partly_cloudy_day";
    if (code === 119 || code === 122) return "cloud";
    if (code >= 176 && code <= 185) return "rainy";
    if (code >= 200 && code <= 232) return "thunderstorm";
    if (code >= 248 && code <= 260) return "foggy";
    if (code >= 263 && code <= 321) return "rainy";
    if (code >= 323 && code <= 395) return "weather_snowy";
    return "cloud";
  }

  function wmoToIcon(wmo) {
    if (wmo === 0) return "clear_day";
    if (wmo <= 3) return "partly_cloudy_day";
    if (wmo >= 45 && wmo <= 48) return "foggy";
    if (wmo >= 51 && wmo <= 67) return "rainy";
    if (wmo >= 71 && wmo <= 77) return "weather_snowy";
    if (wmo >= 80 && wmo <= 82) return "rainy";
    if (wmo >= 85 && wmo <= 86) return "weather_snowy";
    if (wmo >= 95) return "thunderstorm";
    return "cloud";
  }

  function isNight() {
    let h = new Date().getHours();
    return h < 6 || h >= 19;
  }

  // Parse "06:35 AM" or "19:22" to decimal hours
  function parseTimeToHour(timeStr) {
    if (!timeStr || timeStr === "--:--") return 6;
    let clean = timeStr.trim().toUpperCase();
    let isPM = clean.indexOf("PM") >= 0;
    let isAM = clean.indexOf("AM") >= 0;
    clean = clean.replace(/[AP]M/gi, "").trim();
    let parts = clean.split(":");
    let h = parseInt(parts[0]) || 0;
    let m = parseInt(parts[1]) || 0;
    if (isAM && h === 12) h = 0;
    if (isPM && h !== 12) h += 12;
    return h + m / 60.0;
  }

  // Get sun position as fraction (0=sunrise, 1=sunset)
  function getSunFraction() {
    let now = new Date();
    let currentHour = now.getHours() + now.getMinutes() / 60.0;
    if (currentHour < sunriseHour) return -0.1;
    if (currentHour > sunsetHour) return 1.1;
    return (currentHour - sunriseHour) / (sunsetHour - sunriseHour);
  }

  // DMS-style astronomical position calculation
  function getSkyArcPosition(date, isSun) {
    if (!location) {
      return null;
    }
    const lat = location.latitude;
    const lon = location.longitude;

    const pos = isSun ? SunCalc.getPosition(date, lat, lon) : SunCalc.getMoonPosition(date, lat, lon);

    const sunIsNorth = getSunDeclination(date) > lat;
    const transitAzimuth = sunIsNorth ? 0 : Math.PI;

    let h = (((pos.azimuth - transitAzimuth) / (2 * Math.PI)) + 1) % 1;
    h = Math.max(0, Math.min(1, h));
    let v = Math.sin(pos.altitude);
    v = Math.max(-1, Math.min(1, v));

    return { h, v };
  }

  function getSunDeclination(date) {
    const dayOfYear = Math.floor((date - new Date(date.getFullYear(), 0, 0)) / 86400000);
    return -23.44 * Math.cos((2 * Math.PI / 365) * (dayOfYear + 10)) * (Math.PI / 180);
  }

  // Get ecliptic arc points (sun's path over 24 hours)
  function getEcliptic(date, points = 60) {
    if (!location) {
      return null;
    }
    const lat = location.latitude;
    const lon = location.longitude;
    const times = SunCalc.getTimes(date, lat, lon);
    const solarNoon = times.solarNoon;

    const eclipticPoints = [];

    const sunIsNorth = getSunDeclination(date) > lat;
    const transitAzimuth = sunIsNorth ? 0 : Math.PI;

    for (let i = 0; i <= points; i++) {
      const t = new Date(solarNoon.getTime() + (i / points) * 24 * 60 * 60 * 1000);
      const pos = SunCalc.getPosition(t, lat, lon);

      let h = (((pos.azimuth - transitAzimuth) / (2 * Math.PI)) + 1) % 1;
      h = Math.max(0, Math.min(1, h));
      let v = Math.sin(pos.altitude);
      v = Math.max(-1, Math.min(1, v));

      eclipticPoints.push({ h, v });
    }

    const sortedEntries = eclipticPoints.sort((a, b) => a.h - b.h);
    return sortedEntries;
  }

  // Arc Y position (fraction along arc → height as sine curve)
  function arcY(fraction) {
    return Math.sin(fraction * Math.PI);
  }

  // ── Main weather content ─────────────────────────────────
  Column {
    id: weatherColumn
    width: parent.width
    spacing: 12
    visible: root.available

    // ══════════════════════════════════════════════════════
    // HERO CARD - current conditions
    // ══════════════════════════════════════════════════════
    Rectangle {
      width: parent.width
      height: heroContent.height + 28
      radius: 12
      color: Qt.rgba(1, 1, 1, 0.04)
      border.color: Qt.rgba(1, 1, 1, 0.06)
      border.width: 1

      Item {
        id: heroContent
        x: 20; y: 14
        width: parent.width - 40
        height: Math.max(heroLeft.height, heroMetrics.height)

        Row {
          id: heroLeft
          spacing: 14
          anchors.verticalCenter: parent.verticalCenter

          Text {
            text: getWeatherIcon(root.weatherCode)
            font.family: materialFont.name; font.pixelSize: 48
            font.variableAxes: { "FILL": 0, "GRAD": -25, "opsz": 48, "wght": 300 }
            color: Root.Colors.weatherAccent
          }

          Column {
            spacing: 2
            anchors.verticalCenter: parent.verticalCenter
            Row {
              spacing: 2
              Text { text: root.temp + "°"; font.pixelSize: 36; font.weight: Font.Light; color: Root.Colors.weatherTextPrimary }
              Text { text: "C"; font.pixelSize: 13; color: Root.Colors.withAlpha(Root.Colors.weatherTextSecondary, 0.6); y: 8 }
            }
            Text { text: root.condition; font.pixelSize: 13; color: Root.Colors.withAlpha(Root.Colors.weatherTextSecondary, 0.7) }
            Text { text: "Feels Like " + root.feelsLike + "°"; font.pixelSize: 11; color: Root.Colors.withAlpha(Root.Colors.weatherTextMuted, Root.Colors.weatherTextMutedOpacity) }
            Text { text: root.city; font.pixelSize: 11; color: Root.Colors.withAlpha(Root.Colors.weatherTextMuted, Root.Colors.weatherTextMutedOpacity); visible: text.length > 0 }
          }
        }

        Grid {
          id: heroMetrics
          columns: 3; columnSpacing: 16; rowSpacing: 10
          anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
          MetricItem { iconName: "humidity_low"; label: "Humidity"; value: root.humidity }
          MetricItem { iconName: "air"; label: "Wind"; value: root.wind }
          MetricItem { iconName: "speed"; label: "Pressure"; value: root.pressure }
          MetricItem { iconName: "rainy"; label: "Precipitation"; value: root.precipitation }
          MetricItem { iconName: "wb_twilight"; label: "Sunrise"; value: root.sunrise }
          MetricItem { iconName: "bedtime"; label: "Sunset"; value: root.sunset }
        }
      }
    }

    // ══════════════════════════════════════════════════════
    // SKY ARC + DATE/TIME
    // ══════════════════════════════════════════════════════
    Item {
      width: parent.width
      height: skyArcBox.height   // ← no more dependency on dateRow

      // ── Sky arc visualization ─────────────────────────
      Rectangle {
        id: skyArcBox
        width: parent.width
        height: 90
        color: "transparent"

        // Time-of-day label
        Text {
          anchors.horizontalCenter: parent.horizontalCenter
          y: 2
          text: {
            let h = new Date().getHours();
            if (h >= 5 && h < 7) return "Dawn";
            if (h >= 7 && h < 12) return "Morning";
            if (h >= 12 && h < 17) return "Afternoon";
            if (h >= 17 && h < 19) return "Dusk";
            return "Night";
          }
          font.pixelSize: 11
          color: Qt.rgba(0.75, 0.79, 0.96, 0.45)
        }

        // Sky gradient background (above horizon)
        Rectangle {
          anchors.left: parent.left
          anchors.right: parent.right
          y: 0
          height: parent.height / 2
          gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop {
              position: 1.0
              color: {
                let f = getSunFraction();
                if (f < 0 || f > 1) return Qt.rgba(0.1, 0.1, 0.15, 0.15);
                if (f < 0.15 || f > 0.85) return Qt.rgba(0.5, 0.2, 0.3, 0.12);
                return Qt.rgba(0.3, 0.4, 0.7, 0.12);
              }
            }
          }
        }

        // Canvas: ecliptic arc + horizon
        Canvas {
          id: skyCanvas
          anchors.fill: parent
          property real margin: 30
          property real arcHeight: height * 0.45
          property real horizonY: height / 2
          property real effectiveWidth: width - 2 * margin
          property real effectiveHeight: height - 2 * margin
          property real verticalScale: 2
          property var eclipticPoints: null

          Component.onCompleted: requestPaint()

          Connections {
            target: root
            function onLocationChanged() {
              if (root.location) {
                skyCanvas.eclipticPoints = getEcliptic(new Date());
                skyCanvas.requestPaint();
              }
            }
          }

          Timer {
            interval: 3600000
            repeat: true
            running: true
            triggeredOnStart: true
            onTriggered: {
              if (root.location) {
                skyCanvas.eclipticPoints = getEcliptic(new Date());
                skyCanvas.requestPaint();
              }
            }
          }

          function getX(index) {
            if (!eclipticPoints || index >= eclipticPoints.length) return 0;
            return eclipticPoints[index].h * effectiveWidth + margin;
          }

          function getY(index) {
            if (!eclipticPoints || index >= eclipticPoints.length) return horizonY;
            return eclipticPoints[index].v * -(effectiveHeight * verticalScale / 2) + effectiveHeight / 2 + margin;
          }

          onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);

            // Horizon
            ctx.strokeStyle = Qt.rgba(0.75, 0.79, 0.96, 0.15);
            ctx.lineWidth = 1;
            ctx.beginPath();
            ctx.moveTo(margin, horizonY);
            ctx.lineTo(width - margin, horizonY);
            ctx.stroke();

            // Ecliptic arc
            if (eclipticPoints && eclipticPoints.length > 0) {
              ctx.strokeStyle = Qt.rgba(0.75, 0.79, 0.96, 0.2);
              ctx.lineWidth = 1;
              ctx.setLineDash([4, 4]);
              ctx.beginPath();
              ctx.moveTo(getX(0), getY(0));
              for (var i = 1; i < eclipticPoints.length; i++) {
                ctx.lineTo(getX(i), getY(i));
              }
              ctx.stroke();
              ctx.setLineDash([]);
            }
          }
        }

        // Cardinal directions
        Text {
          text: "E"; font.pixelSize: 11; font.bold: true
          color: Root.Colors.weatherAccent
          x: skyCanvas.margin + (skyCanvas.width - skyCanvas.margin * 2) * 0.15 - width / 2
          y: skyCanvas.horizonY - height / 2
        }
        Text {
          text: "S"; font.pixelSize: 11; font.bold: true
          color: Root.Colors.weatherAccent
          x: skyCanvas.width / 2 - width / 2
          y: skyCanvas.horizonY - height / 2
        }
        Text {
          text: "W"; font.pixelSize: 11; font.bold: true
          color: Root.Colors.weatherAccent
          x: skyCanvas.margin + (skyCanvas.width - skyCanvas.margin * 2) * 0.85 - width / 2
          y: skyCanvas.horizonY - height / 2
        }

        // Sun
        Text {
          id: sunIcon
          text: "light_mode"
          font.family: materialFont.name
          font.pixelSize: 20
          color: Root.Colors.weatherAccent2
          z: 100

          property var currentDate: new Date()
          property var pos: getSkyArcPosition(currentDate, true)

          visible: !!pos
          x: pos ? ((pos.h ?? 0) * (skyCanvas.width - 2 * skyCanvas.margin) + skyCanvas.margin - width / 2) : 0
          y: pos ? ((pos.v ?? 0) * -( (skyCanvas.height - 2 * skyCanvas.margin) * skyCanvas.verticalScale / 2)
          + (skyCanvas.height - 2 * skyCanvas.margin) / 2 + skyCanvas.margin - height / 2) : 0

          Timer {
            interval: 60000
            repeat: true
            running: true
            onTriggered: currentDate = new Date()
          }
        }

        // Moon
        Text {
          id: moonIcon
          text: "dark_mode"
          font.family: materialFont.name
          font.pixelSize: 18
          color: Root.Colors.withAlpha(Root.Colors.weatherTextSecondary, 0.9)
          z: 100

          property var currentDate: new Date()
          property var pos: getSkyArcPosition(currentDate, false)

          visible: !!pos
          x: pos ? ((pos.h ?? 0) * (skyCanvas.width - 2 * skyCanvas.margin) + skyCanvas.margin - width / 2) : 0
          y: pos ? ((pos.v ?? 0) * -( (skyCanvas.height - 2 * skyCanvas.margin) * skyCanvas.verticalScale / 2)
          + (skyCanvas.height - 2 * skyCanvas.margin) / 2 + skyCanvas.margin - height / 2) : 0

          Timer {
            interval: 60000
            repeat: true
            running: true
            onTriggered: currentDate = new Date()
          }
        }
      }
    }
    // ══════════════════════════════════════════════════════
    // CONTROLS ROW (Tabs + Detailed Toggle)
    // ══════════════════════════════════════════════════════
    Item {
      width: parent.width; height: 32
      Row {
        spacing: 6
        anchors.left: parent.left
        TabToggle { label: "Daily"; active: !root.showHourly; onClicked: root.showHourly = false }
        TabToggle { label: "Hourly"; active: root.showHourly; onClicked: root.showHourly = true }
      }

      // Detailed toggle matching DMS
      Rectangle {
        anchors.right: parent.right
        width: 32; height: 32; radius: 10
        color: root.dense ? Root.Colors.withAlpha(Root.Colors.weatherSurface, Root.Colors.weatherSurfaceOpacity) : Root.Colors.withAlpha(Root.Colors.weatherAccent, 0.15)
        border.color: root.dense ? "transparent" : Root.Colors.withAlpha(Root.Colors.weatherAccent, 0.4)
        border.width: root.dense ? 0 : 1
        visible: root.showHourly

        Text {
          text: root.dense ? "grid_view" : "view_list"
          font.family: materialFont.name; font.pixelSize: 18
          anchors.centerIn: parent
          color: root.dense ? Root.Colors.calendarHeaderText : Root.Colors.weatherAccent
        }

        MouseArea {
          anchors.fill: parent; cursorShape: Qt.PointingHandCursor
          onClicked: root.dense = !root.dense
        }
      }
    }

    // ══════════════════════════════════════════════════════
    // FORECAST LISTS (ListView for horizontal scrolling)
    // ══════════════════════════════════════════════════════
    Item {
      width: parent.width; height: 110
      clip: true

      // Hourly List
      ListView {
        id: hourlyList
        anchors.fill: parent
        visible: root.showHourly
        orientation: ListView.Horizontal
        spacing: 6
        clip: true
        model: root.hourlyForecast
        snapMode: ListView.SnapToItem
        interactive: true
        highlightMoveDuration: 200

        property int visibleCount: root.dense ? 10 : 5
        property real itemWidth: (width - (visibleCount - 1) * spacing) / visibleCount

        // Position at current hour when data arrives
        onCountChanged: {
          if (count > 0 && root.currentHourIndex >= 0 && root.currentHourIndex < count) {
            positionViewAtIndex(root.currentHourIndex, ListView.Beginning);
          }
        }

        delegate: ForecastCard {
          width: hourlyList.itemWidth; height: 100
          time: modelData.time
          icon: modelData.isWmo ? wmoToIcon(modelData.code) : getWeatherIcon(modelData.code)
          temp: modelData.temp + "°"
          isCurrent: index === root.currentHourIndex
        }

        Behavior on visibleCount {
          NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }
      }

      // Daily List
      ListView {
        id: dailyList
        anchors.fill: parent
        visible: !root.showHourly
        orientation: ListView.Horizontal
        spacing: 6
        clip: true
        model: root.forecast
        snapMode: ListView.SnapToItem
        interactive: true
        highlightMoveDuration: 200

        property int visibleCount: 7
        property real itemWidth: (width - (visibleCount - 1) * spacing) / visibleCount

        delegate: ForecastCard {
          width: dailyList.itemWidth; height: 100
          time: modelData.day
          icon: modelData.isWmo ? wmoToIcon(modelData.code) : getWeatherIcon(modelData.code)
          temp: modelData.low + "°/" + modelData.high + "°"
          isCurrent: index === 0  // Today is always first
        }
      }
    }
  }

  // ── Components ──────────────────────────────────────────
  component ForecastCard: Rectangle {
    property string time: ""
    property string icon: ""
    property string temp: ""
    property bool isCurrent: false
    radius: 10
    color: isCurrent ? Root.Colors.withAlpha(Root.Colors.weatherAccent, 0.1) : Root.Colors.withAlpha(Root.Colors.weatherSurface, Root.Colors.weatherSurfaceOpacity)
    border.color: isCurrent ? Root.Colors.withAlpha(Root.Colors.weatherAccent, 0.25) : Root.Colors.withAlpha(Root.Colors.weatherBorder, Root.Colors.weatherSurfaceOpacity)
    border.width: 1

    Column {
      anchors.centerIn: parent; spacing: 6
      Text { text: time; font.pixelSize: 13; font.weight: Font.DemiBold; color: isCurrent ? Root.Colors.weatherAccent : Root.Colors.weatherTextPrimary; anchors.horizontalCenter: parent.horizontalCenter }
      Text {
        text: icon; font.family: materialFont.name; font.pixelSize: 26
        color: Root.Colors.withAlpha(Root.Colors.weatherTextSecondary, 0.7); anchors.horizontalCenter: parent.horizontalCenter
      }
      Text { text: temp; font.pixelSize: 13; color: Root.Colors.withAlpha(Root.Colors.weatherTextSecondary, 0.6); anchors.horizontalCenter: parent.horizontalCenter }
    }
  }

  component TabToggle: Rectangle {
    property string label: ""
    property bool active: false
    signal clicked()
    width: toggleText.width + 24; height: 28; radius: 14
    color: active ? Root.Colors.withAlpha(Root.Colors.weatherAccent, 0.15) : Root.Colors.withAlpha(Root.Colors.weatherSurface, Root.Colors.weatherSurfaceOpacity)
    border.color: active ? Root.Colors.withAlpha(Root.Colors.weatherAccent, 0.4) : "transparent"
    border.width: active ? 1 : 0
    Text { id: toggleText; text: label; font.pixelSize: 12; anchors.centerIn: parent; color: active ? Root.Colors.weatherAccent : Root.Colors.calendarHeaderText }
    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: parent.clicked() }
  }

  component MetricItem: Row {
    property string iconName: ""; property string label: ""; property string value: ""; spacing: 5
    Text {
      text: iconName; font.family: materialFont.name; font.pixelSize: 13
      color: Qt.rgba(0.75, 0.79, 0.96, 0.45); anchors.verticalCenter: parent.verticalCenter
    }
    Column {
      spacing: 1
      Text { text: label; font.pixelSize: 10; color: Qt.rgba(0.75, 0.79, 0.96, 0.45) }
      Text { text: value; font.pixelSize: 12; font.weight: Font.DemiBold; color: "#c0caf5" }
    }
  }
}
