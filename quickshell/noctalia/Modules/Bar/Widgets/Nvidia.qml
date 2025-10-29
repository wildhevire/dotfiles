import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Services
import qs.Widgets
Rectangle {
  id: root

  // Provided by Bar.qml via NWidgetLoader
  property var screen
  property real scaling: 1.0
  property string widgetId: ""
  property string section: ""
  property int sectionWidgetIndex: -1
  property int sectionWidgetsCount: 0

  // Access your metadata and per-instance settings
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


  anchors.centerIn: parent
  implicitWidth: isVertical ? Style.capsuleHeight : Math.round(mainGrid.implicitWidth + Style.marginM * 2)
  implicitHeight: isVertical ? Math.round(mainGrid.implicitHeight + Style.marginM * 2) : Style.capsuleHeight
  radius: Style.radiusM
  color: Settings.data.bar.showCapsule ? Color.mSurfaceVariant : Color.transparent

  TextMetrics {
    id: percentMetrics
    font.family: Settings.data.ui.fontFixed
    font.weight: Style.fontWeightMedium
    font.pointSize: textSize * Settings.data.ui.fontFixedScale
    text: "99%" // Use the longest possible string for measurement
  }

  GridLayout {
    id: mainGrid
    anchors.centerIn: parent
    flow: isVertical ? GridLayout.TopToBottom : GridLayout.LeftToRight
    rows: isVertical ? -1 : 1
    columns: isVertical ? 1 : -1
    rowSpacing: isVertical ? (Style.marginM) : 0
    columnSpacing: isVertical ? 0 : (Style.marginM)

      Item {
      Layout.preferredWidth: isVertical ? root.width : iconSize + percentTextWidth + (Style.marginXXS)
      Layout.preferredHeight: Style.capsuleHeight
      Layout.alignment: isVertical ? Qt.AlignHCenter : Qt.AlignVCenter
      visible: showCpuUsage

      GridLayout {
        id: cpuUsageContent
        anchors.centerIn: parent
        flow: isVertical ? GridLayout.TopToBottom : GridLayout.LeftToRight
        rows: isVertical ? 2 : 1
        columns: isVertical ? 1 : 2
        rowSpacing: Style.marginXXS
        columnSpacing: Style.marginXXS

        NIcon {
          icon: "cpu-usage"
          pointSize: iconSize
          applyUiScale: false
          Layout.alignment: Qt.AlignCenter
          Layout.row: isVertical ? 1 : 0
          Layout.column: 0
        }

        NText {
          text: `${Math.round(SystemStatService.cpuUsage)}%`
          family: Settings.data.ui.fontFixed
          pointSize: textSize
          applyUiScale: false
          font.weight: Style.fontWeightMedium
          Layout.alignment: Qt.AlignCenter
          Layout.preferredWidth: isVertical ? -1 : percentTextWidth
          horizontalAlignment: isVertical ? Text.AlignHCenter : Text.AlignRight
          verticalAlignment: Text.AlignVCenter
          color: Color.mPrimary
          Layout.row: isVertical ? 0 : 0
          Layout.column: isVertical ? 0 : 1
          scale: isVertical ? Math.min(1.0, root.width / implicitWidth) : 1.0
        }
      }
    }
 }
}