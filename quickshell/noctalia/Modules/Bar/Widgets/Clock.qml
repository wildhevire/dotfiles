import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Services
import qs.Widgets

Rectangle {
  id: root

  property ShellScreen screen

  // Widget properties passed from Bar.qml for per-instance settings
  property string widgetId: ""
  property string section: ""
  property int sectionWidgetIndex: -1
  property int sectionWidgetsCount: 0
  property real scaling: 1.0

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

  readonly property string barPosition: Settings.data.bar.position
  readonly property bool isBarVertical: barPosition === "left" || barPosition === "right"
  readonly property bool density: Settings.data.bar.density

  readonly property var now: Time.date

  // Resolve settings: try user settings or defaults from BarWidgetRegistry
  readonly property bool usePrimaryColor: widgetSettings.usePrimaryColor !== undefined ? widgetSettings.usePrimaryColor : widgetMetadata.usePrimaryColor
  readonly property bool useCustomFont: widgetSettings.useCustomFont !== undefined ? widgetSettings.useCustomFont : widgetMetadata.useCustomFont
  readonly property string customFont: widgetSettings.customFont !== undefined ? widgetSettings.customFont : widgetMetadata.customFont
  readonly property string formatHorizontal: widgetSettings.formatHorizontal !== undefined ? widgetSettings.formatHorizontal : widgetMetadata.formatHorizontal
  readonly property string formatVertical: widgetSettings.formatVertical !== undefined ? widgetSettings.formatVertical : widgetMetadata.formatVertical

  implicitWidth: isBarVertical ? Style.capsuleHeight : Math.round((isBarVertical ? verticalLoader.implicitWidth : horizontalLoader.implicitWidth) + Style.marginM * 2)

  implicitHeight: isBarVertical ? Math.round(verticalLoader.implicitHeight + Style.marginS * 2) : Style.capsuleHeight

  radius: Style.radiusS
  color: Settings.data.bar.showCapsule ? Color.mSurfaceVariant : Color.transparent

  Item {
    id: clockContainer
    anchors.centerIn: parent

    // Horizontal
    Loader {
      id: horizontalLoader
      active: !isBarVertical
      anchors.centerIn: parent
      sourceComponent: ColumnLayout {
        anchors.centerIn: parent
        spacing: Settings.data.bar.showCapsule ? -4 : -2
        Repeater {
          id: repeater
          model: Qt.locale().toString(now, formatHorizontal.trim()).split("\\n")
          NText {
            visible: text !== ""
            text: modelData
            family: useCustomFont && customFont ? customFont : Settings.data.ui.fontDefault
            Binding on pointSize {
              value: {
                if (repeater.model.length == 1) {
                  return Style.fontSizeS * scaling
                } else {
                  return (index == 0) ? Style.fontSizeXS * scaling : Style.fontSizeXXS * scaling
                }
              }
            }
            applyUiScale: false
            font.weight: Style.fontWeightBold
            color: usePrimaryColor ? Color.mPrimary : Color.mOnSurface
            wrapMode: Text.WordWrap
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
          }
        }
      }
    }

    // Vertical
    Loader {
      id: verticalLoader
      active: isBarVertical
      anchors.centerIn: parent // Now this works without layout conflicts
      sourceComponent: ColumnLayout {
        anchors.centerIn: parent
        spacing: -2
        Repeater {
          model: Qt.locale().toString(now, formatVertical.trim()).split(" ")
          delegate: NText {
            visible: text !== ""
            text: modelData
            family: useCustomFont && customFont ? customFont : Settings.data.ui.fontDefault
            Binding on pointSize {
              value: Style.fontSizeS * scaling
            }
            applyUiScale: false

            font.weight: Style.fontWeightBold
            color: usePrimaryColor ? Color.mPrimary : Color.mOnSurface
            wrapMode: Text.WordWrap
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
          }
        }
      }
    }
  }

  MouseArea {
    id: clockMouseArea
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    hoverEnabled: true
    onEntered: {
      if (!PanelService.getPanel("calendarPanel")?.active) {
        TooltipService.show(Screen, root, I18n.tr("clock.tooltip"), BarService.getTooltipDirection())
      }
    }
    onExited: {
      TooltipService.hide()
    }
    onClicked: {
      TooltipService.hide()
      PanelService.getPanel("calendarPanel")?.toggle(this)
    }
  }
}
