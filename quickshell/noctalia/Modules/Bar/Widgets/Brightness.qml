import QtQuick
import Quickshell
import qs.Commons
import qs.Modules.Bar.Extras
import qs.Modules.Settings
import qs.Services
import qs.Widgets

Item {
  id: root

  property ShellScreen screen

  // Widget properties passed from Bar.qml for per-instance settings
  property string widgetId: ""
  property string section: ""
  property int sectionWidgetIndex: -1
  property int sectionWidgetsCount: 0

  property var widgetMetadata: BarWidgetRegistry.widgetMetadata[widgetId]
  property var widgetSettings: {
    if (section && sectionWidgetIndex >= 0) {
      var widgets = Settings.data.bar.widgets[section]
      if (widgets && sectionWidgetIndex < widgets.length) {
        return widgets[sectionWidgetIndex]
      }
    }
    return {}
  }

  readonly property bool isBarVertical: Settings.data.bar.position === "left" || Settings.data.bar.position === "right"
  readonly property string displayMode: (widgetSettings.displayMode !== undefined) ? widgetSettings.displayMode : widgetMetadata.displayMode

  // Used to avoid opening the pill on Quickshell startup
  property bool firstBrightnessReceived: false

  implicitWidth: pill.width
  implicitHeight: pill.height
  visible: getMonitor() !== null

  function getMonitor() {
    return BrightnessService.getMonitorForScreen(screen) || null
  }

  function getIcon() {
    var monitor = getMonitor()
    var brightness = monitor ? monitor.brightness : 0
    return brightness <= 0.5 ? "brightness-low" : "brightness-high"
  }

  // Connection used to open the pill when brightness changes
  Connections {
    target: getMonitor()
    ignoreUnknownSignals: true
    function onBrightnessUpdated() {
      // Ignore if this is the first time we receive an update.
      // Most likely service just kicked off.
      if (!firstBrightnessReceived) {
        firstBrightnessReceived = true
        return
      }

      pill.show()
      hideTimerAfterChange.restart()
    }
  }

  Timer {
    id: hideTimerAfterChange
    interval: 2500
    running: false
    repeat: false
    onTriggered: pill.hide()
  }

  BarPill {
    id: pill

    density: Settings.data.bar.density
    oppositeDirection: BarService.getPillDirection(root)
    icon: getIcon()
    autoHide: false // Important to be false so we can hover as long as we want
    text: {
      var monitor = getMonitor()
      return monitor ? Math.round(monitor.brightness * 100) : ""
    }
    suffix: text.length > 0 ? "%" : "-"
    forceOpen: displayMode === "alwaysShow"
    forceClose: displayMode === "alwaysHide"
    tooltipText: {
      var monitor = getMonitor()
      if (!monitor)
        return ""
      return "Brightness: " + Math.round(monitor.brightness * 100) + "%\nRight click for settings.\nScroll to modify brightness."
    }

    onWheel: function (angle) {
      var monitor = getMonitor()
      if (!monitor)
        return
      if (angle > 0) {
        monitor.increaseBrightness()
      } else if (angle < 0) {
        monitor.decreaseBrightness()
      }
    }

    onClicked: {
      var settingsPanel = PanelService.getPanel("settingsPanel")
      settingsPanel.requestedTab = SettingsPanel.Tab.Display
      settingsPanel.open()
    }

    onRightClicked: {
      var settingsPanel = PanelService.getPanel("settingsPanel")
      settingsPanel.requestedTab = SettingsPanel.Tab.Display
      settingsPanel.open()
    }
  }
}
