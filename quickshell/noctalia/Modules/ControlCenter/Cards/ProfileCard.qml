import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.Modules.Settings
import qs.Modules.ControlCenter
import qs.Commons
import qs.Services
import qs.Widgets

// Header card with avatar, user and quick actions
NBox {
  id: root

  property string uptimeText: "--"

  RowLayout {
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    anchors.margins: Style.marginM
    spacing: Style.marginM

    NImageCircled {
      Layout.preferredWidth: Math.round(Style.baseWidgetSize * 1.25 * Style.uiScaleRatio)
      Layout.preferredHeight: Math.round(Style.baseWidgetSize * 1.25 * Style.uiScaleRatio)
      imagePath: Settings.preprocessPath(Settings.data.general.avatarImage)
      fallbackIcon: "person"
      borderColor: Color.mPrimary
      borderWidth: Style.borderM
    }

    ColumnLayout {
      Layout.fillWidth: true
      spacing: Style.marginXXS
      NText {
        text: Quickshell.env("USER") || "user"
        font.weight: Style.fontWeightBold
        font.capitalization: Font.Capitalize
      }
      NText {
        text: I18n.tr("system.uptime", {
                        "uptime": uptimeText
                      })
        pointSize: Style.fontSizeS
        color: Color.mOnSurfaceVariant
      }
    }

    RowLayout {
      spacing: Style.marginS
      Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
      Item {
        Layout.fillWidth: true
      }
      NIconButton {
        icon: "settings"
        tooltipText: I18n.tr("tooltips.open-settings")
        onClicked: {
          settingsPanel.requestedTab = SettingsPanel.Tab.General
          settingsPanel.open()
        }
      }

      NIconButton {
        icon: "power"
        tooltipText: I18n.tr("tooltips.session-menu")
        onClicked: {
          sessionMenuPanel.open()
          controlCenterPanel.close()
        }
      }

      NIconButton {
        icon: "close"
        tooltipText: I18n.tr("tooltips.close")
        onClicked: {
          controlCenterPanel.close()
        }
      }
    }
  }

  // ----------------------------------
  // Uptime
  Timer {
    interval: 60000
    repeat: true
    running: true
    onTriggered: uptimeProcess.running = true
  }

  Process {
    id: uptimeProcess
    command: ["cat", "/proc/uptime"]
    running: true

    stdout: StdioCollector {
      onStreamFinished: {
        var uptimeSeconds = parseFloat(this.text.trim().split(' ')[0])
        uptimeText = Time.formatVagueHumanReadableDuration(uptimeSeconds)
        uptimeProcess.running = false
      }
    }
  }

  function updateSystemInfo() {
    uptimeProcess.running = true
  }
}
