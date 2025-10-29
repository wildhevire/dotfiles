import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.Commons
import qs.Services

Rectangle {
  id: root

  property real baseSize: Style.baseWidgetSize
  property bool applyUiScale: true

  property string icon
  property string tooltipText
  property string tooltipDirection: "auto"
  property string density: ""
  property bool enabled: true
  property bool allowClickWhenDisabled: false
  property bool hovering: false

  property color colorBg: Color.mSurfaceVariant
  property color colorFg: Color.mPrimary
  property color colorBgHover: Color.mTertiary
  property color colorFgHover: Color.mOnTertiary
  property color colorBorder: Color.mOutline
  property color colorBorderHover: Color.mOutline

  signal entered
  signal exited
  signal clicked
  signal rightClicked
  signal middleClicked

  implicitWidth: applyUiScale ? Math.round(baseSize * Style.uiScaleRatio) : Math.round(baseSize)
  implicitHeight: applyUiScale ? Math.round(baseSize * Style.uiScaleRatio) : Math.round(baseSize)

  opacity: root.enabled ? Style.opacityFull : Style.opacityMedium
  color: root.enabled && root.hovering ? colorBgHover : colorBg
  radius: width * 0.5
  border.color: root.enabled && root.hovering ? colorBorderHover : colorBorder
  border.width: Style.borderS

  Behavior on color {
    ColorAnimation {
      duration: Style.animationNormal
      easing.type: Easing.InOutQuad
    }
  }

  NIcon {
    icon: root.icon
    pointSize: {
      switch (root.density) {
      case "compact":
        return Math.max(1, root.width * 0.65)
      default:
        return Math.max(1, root.width * 0.48)
      }
    }
    applyUiScale: root.applyUiScale
    color: root.enabled && root.hovering ? colorFgHover : colorFg
    // Center horizontally
    x: (root.width - width) / 2
    // Center vertically accounting for font metrics
    y: (root.height - height) / 2 + (height - contentHeight) / 2

    Behavior on color {
      ColorAnimation {
        duration: Style.animationFast
        easing.type: Easing.InOutQuad
      }
    }
  }

  MouseArea {
    // Always enabled to allow hover/tooltip even when the button is disabled
    enabled: true
    anchors.fill: parent
    cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
    hoverEnabled: true
    onEntered: {
      hovering = root.enabled ? true : false
      if (tooltipText) {
        TooltipService.show(Screen, parent, tooltipText, tooltipDirection)
      }
      root.entered()
    }
    onExited: {
      hovering = false
      if (tooltipText) {
        TooltipService.hide()
      }
      root.exited()
    }
    onClicked: function (mouse) {
      if (tooltipText) {
        TooltipService.hide()
      }
      if (!root.enabled && !allowClickWhenDisabled) {
        return
      }
      if (mouse.button === Qt.LeftButton) {
        root.clicked()
      } else if (mouse.button === Qt.RightButton) {
        root.rightClicked()
      } else if (mouse.button === Qt.MiddleButton) {
        root.middleClicked()
      }
    }
  }
}
