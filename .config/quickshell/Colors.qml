pragma Singleton
import QtQuick

QtObject {
  // Helper
  function withAlpha(c, a) {
    return Qt.rgba(c.r, c.g, c.b, a);
  }

  // ── Global surface opacity ────────────────────────────────────────────────
  readonly property real panelOpacity: 0
  readonly property real popupOpacity: 0.95
  readonly property real cardOpacity: 0.28
  readonly property real separatorOpacity: 0.18

  // ── Middle bar chips (Clock / Weather) ───────────────────────────────────
  // Time (ClockWidget)
  readonly property color timeChipBackground: "#2f2626"
  readonly property real timeChipOpacity: 0.8

  // Weather (WeatherWidget)
  readonly property color weatherChipBackground: "#2f2626"
  readonly property real weatherChipOpacity: 0.8

  // ── Right bar chips ───────────────────────────────────────────────────────
  // System tray pill (SysTrayWidget)
  readonly property color systrayChipBackground: "#2f2626"
  readonly property real systrayChipOpacity: 0.8

  // CPU widget
  readonly property color cpuWidgetBackground: widgetBackground
  readonly property color cpuText: textPrimary
  readonly property color cpuLow: info
  readonly property color cpuMedium: warning
  readonly property color cpuHigh: error

  // GPU widget
  readonly property color gpuWidgetBackground: widgetBackground
  readonly property color gpuText: textPrimary
  readonly property color gpuLow: "#f28f3b"
  readonly property color gpuMedium: warning
  readonly property color gpuHigh: error

  // Sound widget
  readonly property color soundWidgetBackground: widgetBackground
  readonly property color soundText: textPrimary
  readonly property color soundNormal: "#f5cb5c"
  readonly property color soundMuted: error

  // Battery widget
  readonly property color batteryWidgetBackground: widgetBackground
  readonly property color batteryText: textPrimary
  readonly property color batteryDischarging: textSecondary
  readonly property color batteryCharging: "#74C365"
  readonly property color batteryLow: error

  // ── Workspace (left) ──────────────────────────────────────────────────────
  readonly property color workspaceBackground: "#2f2626"
  readonly property real workspaceBackgroundOpacity: 0.8
  readonly property color workspaceActive: "#6c757d"
  readonly property real workspaceActiveOpacity: 0.5
  readonly property color workspaceActiveText: "#ffffff"
  readonly property color workspaceInactive: "#444b6a"
  readonly property color workspaceDot: "#444b6a"
  readonly property color workspaceText: "#ffffff"
  readonly property real workspaceInactiveOpacity: 0

  // ── Left title (window title widget) ──────────────────────────────────────
  readonly property color titleBackground: "#2f2626"
  readonly property real titleBackgroundOpacity: 0.8
  readonly property color titleAppText: "#ffffff"
  readonly property color titleSeparator: "#e8e9f3"
  readonly property color titleWindowText: "#ffffff"

  // ── Center popup / tabs ───────────────────────────────────────────────────
  readonly property color centerPopupBackground: "#1f2335"
  readonly property color centerPopupBorder: "#414868"
  readonly property color centerTabActiveIcon: "#7eb09b"
  readonly property color centerTabInactiveIcon: "#f6c28b"
  readonly property color centerTabActiveText: "#c0caf5"
  readonly property color centerTabInactiveText: "#9aa5ce"
  readonly property color centerTabAccent: "#7eb09b"
  readonly property color centerTabMuted: "#565f89"
  readonly property color centerTabSurface: "#1a1b26"
  readonly property color centerTabSurfaceAlt: "#3b3f52"

  // Calendar tab
  readonly property color calendarNavText: "#c0caf5"
  readonly property color calendarNavHover: "#ffffff"
  readonly property color calendarHeaderText: "#565f89"
  readonly property color calendarTodayBg: "#7eb09b"
  readonly property color calendarTodayText: "#1a1b26"
  readonly property color calendarOtherMonthText: "#3b3f52"
  readonly property color calendarCurrentMonthText: "#c0caf5"
  readonly property color calendarDayHoverBg: "#7eb09b"
  readonly property real calendarDayHoverOpacity: 0.22
  readonly property color calendarTodayButtonBg: "#ffffff"
  readonly property real calendarTodayButtonOpacity: 0.06

  // Media tab
  readonly property color mediaPlaceholderIcon: "#3b3f52"
  readonly property color mediaTitleText: "#c0caf5"
  readonly property color mediaMetaText: "#a9b1d6"
  readonly property color mediaMutedText: "#565f89"
  readonly property color mediaControlText: "#c0caf5"
  readonly property color mediaProgressBg: "#ffffff"
  readonly property real mediaProgressBgOpacity: 0.08
  readonly property color mediaProgressFill: "#7eb09b"
  readonly property color mediaPlayButtonBg: "#7eb09b"
  readonly property color mediaPlayButtonText: "#1a1b26"

  // Weather tab
  readonly property color weatherSurface: "#ffffff"
  readonly property real weatherSurfaceOpacity: 0.04
  readonly property color weatherBorder: "#ffffff"
  readonly property real weatherBorderOpacity: 0.06
  readonly property color weatherAccent: "#7eb09b"
  readonly property color weatherAccent2: "#e0af68"
  readonly property color weatherTextPrimary: "#c0caf5"
  readonly property color weatherTextSecondary: "#a9b1d6"
  readonly property color weatherTextMuted: "#c0caf5"
  readonly property real weatherTextMutedOpacity: 0.45

  // Legacy shared chip tokens (kept for compatibility)
  readonly property color chipBackground: timeChipBackground
  readonly property real chipOpacity: timeChipOpacity

  // ── Base palette ──────────────────────────────────────────────────────────
  // Background colors
  readonly property color background: "#2f2626"
  readonly property color surfaceContainer: "#323031"
  readonly property color surfaceContainerHigh: "#24283b"
  readonly property color surfaceContainerHighest: "#2a2f44"
  readonly property color surfaceBright: "#32344a"
  
  // Primary colors (main accent)
  readonly property color primary: "#e2c46d"
  readonly property color primaryContainer: "#574400"
  readonly property color textOnPrimary: "#3d2f00"
  
  // Secondary colors
  readonly property color secondary: "#d5c5a1"
  readonly property color secondaryContainer: "#50462a"
  
  // Tertiary colors
  readonly property color tertiary: "#adcfae"
  readonly property color tertiaryContainer: "#2f4d34"
  
  // Text colors
  readonly property color textOnSurface: "#c0caf5"
  readonly property color textOnSurfaceVariant: "#a9b1d6"
  readonly property color textOnBackground: "#c0caf5"
  
  // Outline
  readonly property color outline: "#565f89"
  readonly property color outlineVariant: "#414868"
  
  // Error
  readonly property color error: "#ffb4ab"
  readonly property color errorContainer: "#93000a"
  
  // Semantic colors for widgets
  readonly property color textPrimary: "#ffffff"
  readonly property color textSecondary: "#a9b1d6"
  readonly property color textMuted: "#e8e9f3"
  
  // Status colors (softer, more harmonious)
  readonly property color success: "#9ece6a"
  readonly property color warning: "#e0af68"
  readonly property color danger: "#f7768e"
  readonly property color info: "#7aa2f7"
  
  // Widget backgrounds
  readonly property color widgetBackground: "#2f2626"
  readonly property color widgetBackgroundHover: "#32344a"
  
  // Overlay
  readonly property color scrim: "#000000"
  readonly property color shadow: "#000000"
}

