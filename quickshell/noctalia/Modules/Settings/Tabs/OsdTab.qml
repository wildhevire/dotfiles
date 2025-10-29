import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.Commons
import qs.Services
import qs.Widgets

ColumnLayout {
  id: root

  // Helper functions to update arrays immutably
  function addMonitor(list, name) {
    const arr = (list || []).slice()
    if (!arr.includes(name))
      arr.push(name)
    return arr
  }
  function removeMonitor(list, name) {
    return (list || []).filter(function (n) {
      return n !== name
    })
  }

  // Display
  ColumnLayout {
    spacing: Style.marginL
    Layout.fillWidth: true

    NComboBox {
      label: I18n.tr("settings.osd.location.label")
      description: I18n.tr("settings.osd.location.description")
      model: [{
          "key": "top",
          "name": I18n.tr("options.osd.position.top_center")
        }, {
          "key": "top_left",
          "name": I18n.tr("options.osd.position.top_left")
        }, {
          "key": "top_right",
          "name": I18n.tr("options.osd.position.top_right")
        }, {
          "key": "bottom",
          "name": I18n.tr("options.osd.position.bottom_center")
        }, {
          "key": "bottom_left",
          "name": I18n.tr("options.osd.position.bottom_left")
        }, {
          "key": "bottom_right",
          "name": I18n.tr("options.osd.position.bottom_right")
        }, {
          "key": "left",
          "name": I18n.tr("options.osd.position.center_left")
        }, {
          "key": "right",
          "name": I18n.tr("options.osd.position.center_right")
        }]
      currentKey: Settings.data.osd.location || "top_right"
      onSelected: key => Settings.data.osd.location = key
    }
  }

  NDivider {
    Layout.fillWidth: true
    Layout.topMargin: Style.marginXL
    Layout.bottomMargin: Style.marginXL
  }

  // General
  ColumnLayout {
    spacing: Style.marginL
    Layout.fillWidth: true

    NHeader {
      label: I18n.tr("settings.osd.section.general.label")
      description: I18n.tr("settings.osd.section.general.description")
    }

    NToggle {
      label: I18n.tr("settings.osd.enabled.label")
      description: I18n.tr("settings.osd.enabled.description")
      checked: Settings.data.osd.enabled
      onToggled: checked => Settings.data.osd.enabled = checked
    }

    NToggle {
      label: I18n.tr("settings.osd.always-on-top.label")
      description: I18n.tr("settings.osd.always-on-top.description")
      checked: Settings.data.osd.overlayLayer
      onToggled: checked => Settings.data.osd.overlayLayer = checked
    }

    NLabel {
      label: I18n.tr("settings.osd.duration.auto-hide.label")
      description: I18n.tr("settings.osd.duration.auto-hide.description")
    }

    NValueSlider {
      Layout.fillWidth: true
      from: 500
      to: 5000
      stepSize: 100
      value: Settings.data.osd.autoHideMs
      onMoved: value => Settings.data.osd.autoHideMs = value
      text: Math.round(Settings.data.osd.autoHideMs / 1000 * 10) / 10 + "s"
    }
  }

  NDivider {
    Layout.fillWidth: true
    Layout.topMargin: Style.marginXL
    Layout.bottomMargin: Style.marginXL
  }

  // Monitor Configuration
  ColumnLayout {
    spacing: Style.marginL
    Layout.fillWidth: true

    NHeader {
      label: I18n.tr("settings.osd.monitors.section.label")
      description: I18n.tr("settings.osd.monitors.section.description")
    }

    Repeater {
      model: Quickshell.screens || []
      delegate: NCheckbox {
        Layout.fillWidth: true
        label: modelData.name || I18n.tr("system.unknown")
        description: {
          const compositorScale = CompositorService.getDisplayScale(modelData.name)
          I18n.tr("system.monitor-description", {
                    "model": modelData.model,
                    "width": modelData.width * compositorScale,
                    "height": modelData.height * compositorScale,
                    "scale": compositorScale
                  })
        }
        checked: (Settings.data.osd.monitors || []).indexOf(modelData.name) !== -1
        onToggled: checked => {
                     if (checked) {
                       Settings.data.osd.monitors = addMonitor(Settings.data.osd.monitors, modelData.name)
                     } else {
                       Settings.data.osd.monitors = removeMonitor(Settings.data.osd.monitors, modelData.name)
                     }
                   }
      }
    }
  }
}
