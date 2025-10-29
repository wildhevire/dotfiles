import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Services
import qs.Widgets
import qs.Modules.Settings
import qs.Modules.Bar.Extras

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

  // Use settings or defaults from BarWidgetRegistry
  readonly property string customIcon: widgetSettings.icon || widgetMetadata.icon
  readonly property string leftClickExec: widgetSettings.leftClickExec || widgetMetadata.leftClickExec
  readonly property string rightClickExec: widgetSettings.rightClickExec || widgetMetadata.rightClickExec
  readonly property string middleClickExec: widgetSettings.middleClickExec || widgetMetadata.middleClickExec
  readonly property string textCommand: widgetSettings.textCommand !== undefined ? widgetSettings.textCommand : (widgetMetadata.textCommand || "")
  readonly property int textIntervalMs: widgetSettings.textIntervalMs !== undefined ? widgetSettings.textIntervalMs : (widgetMetadata.textIntervalMs || 3000)
  readonly property bool hasExec: (leftClickExec || rightClickExec || middleClickExec)

  implicitWidth: pill.width
  implicitHeight: pill.height

  BarPill {
    id: pill

    oppositeDirection: BarService.getPillDirection(root)
    icon: customIcon
    text: _dynamicText
    density: Settings.data.bar.density
    autoHide: false
    forceOpen: _dynamicText !== ""
    forceClose: true
    tooltipText: {
      if (!hasExec) {
        return "Custom button, configure in settings."
      } else {
        var lines = []
        if (leftClickExec !== "") {
          lines.push(`Left click: ${leftClickExec}.`)
        }
        if (rightClickExec !== "") {
          lines.push(`Right click: ${rightClickExec}.`)
        }
        if (middleClickExec !== "") {
          lines.push(`Middle click: ${middleClickExec}.`)
        }
        return lines.join("\n")
      }
    }

    onClicked: root.onClicked()
    onRightClicked: root.onRightClicked()
    onMiddleClicked: root.onMiddleClicked()
  }

  // Internal state for dynamic text
  property string _dynamicText: ""

  // Periodically run the text command (if set)
  Timer {
    id: refreshTimer
    interval: Math.max(250, textIntervalMs)
    repeat: true
    running: (textCommand && textCommand.length > 0)
    triggeredOnStart: true
    onTriggered: {
      if (!textCommand || textCommand.length === 0)
        return
      if (textProc.running)
        return
      textProc.command = ["sh", "-lc", textCommand]
      textProc.running = true
    }
  }

  Process {
    id: textProc
    stdout: StdioCollector {}
    stderr: StdioCollector {}
    onExited: (exitCode, exitStatus) => {
                var out = String(stdout.text || "").trim()
                if (out.indexOf("\n") !== -1) {
                  out = out.split("\n")[0]
                }
                _dynamicText = out
              }
  }

  function onClicked() {
    if (leftClickExec) {
      Quickshell.execDetached(["sh", "-c", leftClickExec])
      Logger.i("CustomButton", `Executing command: ${leftClickExec}`)
    } else if (!hasExec) {
      // No script was defined, open settings
      var settingsPanel = PanelService.getPanel("settingsPanel")
      settingsPanel.requestedTab = SettingsPanel.Tab.Bar
      settingsPanel.open()
    }
  }

  function onRightClicked() {
    if (rightClickExec) {
      Quickshell.execDetached(["sh", "-c", rightClickExec])
      Logger.i("CustomButton", `Executing command: ${rightClickExec}`)
    }
  }

  function onMiddleClicked() {
    if (middleClickExec) {
      Quickshell.execDetached(["sh", "-c", middleClickExec])
      Logger.i("CustomButton", `Executing command: ${middleClickExec}`)
    }
  }
}
