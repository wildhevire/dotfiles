pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

Singleton {
  id: root

  property list<var> ddcMonitors: []
  readonly property list<Monitor> monitors: variants.instances
  property bool appleDisplayPresent: false

  function getMonitorForScreen(screen: ShellScreen): var {
    return monitors.find(m => m.modelData === screen)
  }

  // Signal emitted when a specific monitor's brightness changes, includes monitor context
  signal monitorBrightnessChanged(var monitor, real newBrightness)

  function getAvailableMethods(): list<string> {
    var methods = []
    if (monitors.some(m => m.isDdc))
      methods.push("ddcutil")
    if (monitors.some(m => !m.isDdc))
      methods.push("internal")
    if (appleDisplayPresent)
      methods.push("apple")
    return methods
  }

  // Global helpers for IPC and shortcuts
  function increaseBrightness(): void {
    monitors.forEach(m => m.increaseBrightness())
  }

  function decreaseBrightness(): void {
    monitors.forEach(m => m.decreaseBrightness())
  }

  function getDetectedDisplays(): list<var> {
    return detectedDisplays
  }

  reloadableId: "brightness"

  Component.onCompleted: {
    Logger.i("Brightness", "Service started")
  }

  onMonitorsChanged: {
    ddcMonitors = []
    ddcProc.running = true
  }

  Variants {
    id: variants
    model: Quickshell.screens
    Monitor {}
  }

  // Check for Apple Display support
  Process {
    running: true
    command: ["sh", "-c", "which asdbctl >/dev/null 2>&1 && asdbctl get || echo ''"]
    stdout: StdioCollector {
      onStreamFinished: root.appleDisplayPresent = text.trim().length > 0
    }
  }

  // Detect DDC monitors
  Process {
    id: ddcProc
    property list<var> ddcMonitors: []
    command: ["ddcutil", "detect", "--sleep-multiplier=0.5"]
    stdout: StdioCollector {
      onStreamFinished: {
        var displays = text.trim().split("\n\n")
        ddcProc.ddcMonitors = displays.map(d => {

                                             var ddcModelMatch = d.match(/(This monitor does not support DDC\/CI|Invalid display)/)
                                             var modelMatch = d.match(/Model:\s*(.*)/)
                                             var busMatch = d.match(/I2C bus:[ ]*\/dev\/i2c-([0-9]+)/)
                                             var ddcModel = ddcModelMatch ? ddcModelMatch.length > 0 : false
                                             var model = modelMatch ? modelMatch[1] : "Unknown"
                                             var bus = busMatch ? busMatch[1] : "Unknown"
                                             Logger.i("Brigthness", "Detected DDC Monitor:", model, "on bus", bus, "is DDC:", !ddcModel)
                                             return {
                                               "model": model,
                                               "busNum": bus,
                                               "isDdc": !ddcModel
                                             }
                                           })
        root.ddcMonitors = ddcProc.ddcMonitors.filter(m => m.isDdc)
      }
    }
  }

  component Monitor: QtObject {
    id: monitor

    required property ShellScreen modelData
    readonly property bool isDdc: root.ddcMonitors.some(m => m.model === modelData.model)
    readonly property string busNum: root.ddcMonitors.find(m => m.model === modelData.model)?.busNum ?? ""
    readonly property bool isAppleDisplay: root.appleDisplayPresent && modelData.model.startsWith("StudioDisplay")
    readonly property string method: isAppleDisplay ? "apple" : (isDdc ? "ddcutil" : "internal")

    property real brightness
    property real lastBrightness: 0
    property real queuedBrightness: NaN

    // For internal displays - store the backlight device path
    property string backlightDevice: ""
    property string brightnessPath: ""
    property string maxBrightnessPath: ""
    property int maxBrightness: 100
    property bool ignoreNextChange: false

    // Signal for brightness changes
    signal brightnessUpdated(real newBrightness)

    // Execute a system command to get the current brightness value directly
    readonly property Process refreshProc: Process {
      stdout: StdioCollector {
        onStreamFinished: {
          var dataText = text.trim()
          if (dataText === "") {
            return
          }

          var lines = dataText.split("\n")
          if (lines.length >= 2) {
            var current = parseInt(lines[0].trim())
            var max = parseInt(lines[1].trim())
            if (!isNaN(current) && !isNaN(max) && max > 0) {
              var newBrightness = current / max
              // Only update if it's actually different (avoid feedback loops)
              if (Math.abs(newBrightness - monitor.brightness) > 0.01) {
                // Update internal value to match system state
                monitor.brightness = newBrightness
                monitor.brightnessUpdated(monitor.brightness)
                root.monitorBrightnessChanged(monitor, monitor.brightness)
                //Logger.i("Brightness", "Refreshed brightness from system:", monitor.modelData.name, monitor.brightness)
              }
            }
          }
        }
      }
    }

    // Function to actively refresh the brightness from system
    function refreshBrightnessFromSystem() {
      if (!monitor.isDdc && !monitor.isAppleDisplay) {
        // For internal displays, query the system directly
        refreshProc.command = ["sh", "-c", "cat " + monitor.brightnessPath + " && " + "cat " + monitor.maxBrightnessPath]
        refreshProc.running = true
      } else if (monitor.isDdc) {
        // For DDC displays, get the current value
        refreshProc.command = ["ddcutil", "-b", monitor.busNum, "getvcp", "10", "--brief"]
        refreshProc.running = true
      } else if (monitor.isAppleDisplay) {
        // For Apple displays, get the current value
        refreshProc.command = ["asdbctl", "get"]
        refreshProc.running = true
      }
    }

    // FileView to watch for external brightness changes (internal displays only)
    readonly property FileView brightnessWatcher: FileView {
      id: brightnessWatcher
      // Only set path for internal displays with a valid brightness path
      path: (!monitor.isDdc && !monitor.isAppleDisplay && monitor.brightnessPath !== "") ? monitor.brightnessPath : ""
      watchChanges: path !== ""
      onFileChanged: {
        // When a file change is detected, actively refresh from system
        // to ensure we get the most up-to-date value
        Qt.callLater(() => {
                       monitor.refreshBrightnessFromSystem()
                     })
      }
    }

    // Initialize brightness
    readonly property Process initProc: Process {
      stdout: StdioCollector {
        onStreamFinished: {
          var dataText = text.trim()
          if (dataText === "") {
            return
          }

          //Logger.i("Brightness", "Raw brightness data for", monitor.modelData.name + ":", dataText)
          if (monitor.isAppleDisplay) {
            var val = parseInt(dataText)
            if (!isNaN(val)) {
              monitor.brightness = val / 101
              Logger.d("Brightness", "Apple display brightness:", monitor.brightness)
            }
          } else if (monitor.isDdc) {
            var parts = dataText.split(" ")
            if (parts.length >= 4) {
              var current = parseInt(parts[3])
              var max = parseInt(parts[4])
              if (!isNaN(current) && !isNaN(max) && max > 0) {
                monitor.brightness = current / max
                Logger.d("Brightness", "DDC brightness:", current + "/" + max + " =", monitor.brightness)
              }
            }
          } else {
            // Internal backlight - parse the response which includes device path
            var lines = dataText.split("\n")
            if (lines.length >= 3) {
              monitor.backlightDevice = lines[0]
              monitor.brightnessPath = monitor.backlightDevice + "/brightness"
              monitor.maxBrightnessPath = monitor.backlightDevice + "/max_brightness"

              var current = parseInt(lines[1])
              var max = parseInt(lines[2])
              if (!isNaN(current) && !isNaN(max) && max > 0) {
                monitor.maxBrightness = max
                monitor.brightness = current / max
                Logger.d("Brightness", "Internal brightness:", current + "/" + max + " =", monitor.brightness)
                Logger.d("Brightness", "Using backlight device:", monitor.backlightDevice)
              }
            }
          }

          // Always update
          monitor.brightnessUpdated(monitor.brightness)
          root.monitorBrightnessChanged(monitor, monitor.brightness)
        }
      }
    }

    readonly property real stepSize: Settings.data.brightness.brightnessStep / 100.0

    // Timer for debouncing rapid changes
    readonly property Timer timer: Timer {
      interval: 100
      onTriggered: {
        if (!isNaN(monitor.queuedBrightness)) {
          monitor.setBrightness(monitor.queuedBrightness)
          monitor.queuedBrightness = NaN
        }
      }
    }

    function setBrightnessDebounced(value: real): void {
      monitor.queuedBrightness = value
      timer.start()
    }

    function increaseBrightness(): void {
      const value = !isNaN(monitor.queuedBrightness) ? monitor.queuedBrightness : monitor.brightness
      setBrightnessDebounced(value + stepSize)
    }

    function decreaseBrightness(): void {
      const value = !isNaN(monitor.queuedBrightness) ? monitor.queuedBrightness : monitor.brightness
      setBrightnessDebounced(value - stepSize)
    }

    function setBrightness(value: real): void {
      value = Math.max(0, Math.min(1, value))
      var rounded = Math.round(value * 100)

      if (timer.running) {
        monitor.queuedBrightness = value
        return
      }

      // Update internal value and trigger UI feedback
      monitor.brightness = value
      monitor.brightnessUpdated(value)
      root.monitorBrightnessChanged(monitor, monitor.brightness)

      if (isAppleDisplay) {
        monitor.ignoreNextChange = true
        Quickshell.execDetached(["asdbctl", "set", rounded])
      } else if (isDdc) {
        monitor.ignoreNextChange = true
        Quickshell.execDetached(["ddcutil", "-b", busNum, "setvcp", "10", rounded])
      } else {
        monitor.ignoreNextChange = true
        Quickshell.execDetached(["brightnessctl", "s", rounded + "%"])
      }

      if (isDdc) {
        timer.restart()
      }
    }

    function initBrightness(): void {
      if (isAppleDisplay) {
        initProc.command = ["asdbctl", "get"]
      } else if (isDdc) {
        initProc.command = ["ddcutil", "-b", busNum, "getvcp", "10", "--brief"]
      } else {
        // Internal backlight - find the first available backlight device and get its info
        // This now returns: device_path, current_brightness, max_brightness (on separate lines)
        initProc.command = ["sh", "-c", "for dev in /sys/class/backlight/*; do " + "  if [ -f \"$dev/brightness\" ] && [ -f \"$dev/max_brightness\" ]; then " + "    echo \"$dev\"; " + "    cat \"$dev/brightness\"; " + "    cat \"$dev/max_brightness\"; " + "    break; " + "  fi; " + "done"]
      }
      initProc.running = true
    }

    onBusNumChanged: initBrightness()
    Component.onCompleted: initBrightness()
  }
}
