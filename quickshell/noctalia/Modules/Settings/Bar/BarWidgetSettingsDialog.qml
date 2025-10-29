import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import qs.Commons
import qs.Widgets
import qs.Services

// Widget Settings Dialog Component
Popup {
  // Don't replace by root!
  id: widgetSettings

  property int widgetIndex: -1
  property var widgetData: null
  property string widgetId: ""

  // Center popup in parent
  x: (parent.width - width) * 0.5
  y: (parent.height - height) * 0.5

  width: Math.max(content.implicitWidth + padding * 2, 500)
  height: content.implicitHeight + padding * 2
  padding: Style.marginXL
  modal: true

  onOpened: {
    // Mark this popup has opened in the PanelService
    PanelService.willOpenPopup(widgetSettings)

    // Load settings when popup opens with data
    if (widgetData && widgetId) {
      loadWidgetSettings()
    }
  }

  onClosed: {
    PanelService.willClosePopup(widgetSettings)
  }

  background: Rectangle {
    id: bgRect

    color: Color.mSurface
    radius: Style.radiusL
    border.color: Color.mPrimary
    border.width: Style.borderM
  }

  contentItem: ColumnLayout {
    id: content

    width: parent.width
    spacing: Style.marginM

    // Title
    RowLayout {
      Layout.fillWidth: true

      NText {
        text: I18n.tr("system.widget-settings-title", {
                        "widget": widgetSettings.widgetId
                      })
        pointSize: Style.fontSizeL
        font.weight: Style.fontWeightBold
        color: Color.mPrimary
        Layout.fillWidth: true
      }

      NIconButton {
        icon: "close"
        tooltipText: I18n.tr("tooltips.close")
        onClicked: widgetSettings.close()
      }
    }

    // Separator
    Rectangle {
      Layout.fillWidth: true
      Layout.preferredHeight: 1
      color: Color.mOutline
    }

    // Settings based on widget type
    // Will be triggered via settingsLoader.setSource()
    Loader {
      id: settingsLoader
      Layout.fillWidth: true
    }

    // Action buttons
    RowLayout {
      Layout.fillWidth: true
      Layout.topMargin: Style.marginM
      spacing: Style.marginM

      Item {
        Layout.fillWidth: true
      }

      NButton {
        text: I18n.tr("bar.widget-settings.dialog.cancel")
        outlined: true
        onClicked: widgetSettings.close()
      }

      NButton {
        text: I18n.tr("bar.widget-settings.dialog.apply")
        icon: "check"
        onClicked: {
          if (settingsLoader.item && settingsLoader.item.saveSettings) {
            var newSettings = settingsLoader.item.saveSettings()
            root.updateWidgetSettings(sectionId, widgetSettings.widgetIndex, newSettings)
            widgetSettings.close()
          }
        }
      }
    }
  }

  function loadWidgetSettings() {
    const widgetSettingsMap = {
      "ActiveWindow": "WidgetSettings/ActiveWindowSettings.qml",
      "Battery": "WidgetSettings/BatterySettings.qml",
      "Bluetooth": "WidgetSettings/BluetoothSettings.qml",
      "Brightness": "WidgetSettings/BrightnessSettings.qml",
      "Clock": "WidgetSettings/ClockSettings.qml",
      "ControlCenter": "WidgetSettings/ControlCenterSettings.qml",
      "CustomButton": "WidgetSettings/CustomButtonSettings.qml",
      "KeyboardLayout": "WidgetSettings/KeyboardLayoutSettings.qml",
      "MediaMini": "WidgetSettings/MediaMiniSettings.qml",
      "Microphone": "WidgetSettings/MicrophoneSettings.qml",
      "NotificationHistory": "WidgetSettings/NotificationHistorySettings.qml",
      "Spacer": "WidgetSettings/SpacerSettings.qml",
      "SystemMonitor": "WidgetSettings/SystemMonitorSettings.qml",
      "Volume": "WidgetSettings/VolumeSettings.qml",
      "WiFi": "WidgetSettings/WiFiSettings.qml",
      "Workspace": "WidgetSettings/WorkspaceSettings.qml",
      "Taskbar": "WidgetSettings/TaskbarSettings.qml",
      "Tray": "WidgetSettings/TraySettings.qml"
    }

    const source = widgetSettingsMap[widgetId]
    if (source) {
      // Use setSource to pass properties at creation time
      settingsLoader.setSource(source, {
                                 "widgetData": widgetData,
                                 "widgetMetadata": BarWidgetRegistry.widgetMetadata[widgetId]
                               })
    }
  }
}
