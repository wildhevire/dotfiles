import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import qs.Commons
import qs.Services

Rectangle {
  id: root

  // Public properties
  property real baseSize: Style.baseWidgetSize
  property bool applyUiScale: true
  property string icon: ""
  property string tooltipText: ""
  property string tooltipDirection: "auto"
  property string density: ""
  property bool enabled: true
  property bool allowClickWhenDisabled: false
  property bool hot: false

  // Internal properties
  property bool hovering: false
  property bool pressed: false

  // Color properties
  property color colorBg: Color.mSurfaceVariant
  property color colorFg: Color.mPrimary
  property color colorBgHover: Color.mTertiary
  property color colorFgHover: Color.mOnTertiary
  property color colorBorder: Color.mOutline
  property color colorBorderHover: Color.mOutline

  // Hot state colors
  property color colorBgHot: Color.mPrimary
  property color colorFgHot: Color.mOnPrimary

  // Signals
  signal entered
  signal exited
  signal clicked
  signal rightClicked
  signal middleClicked

  // Dimensions
  implicitWidth: applyUiScale ? Math.round(baseSize * Style.uiScaleRatio) : Math.round(baseSize)
  implicitHeight: applyUiScale ? Math.round(baseSize * Style.uiScaleRatio) : Math.round(baseSize)

  // Appearance
  opacity: root.enabled ? Style.opacityFull : Style.opacityMedium
  color: {
    if (pressed) {
      return colorBgHover
    }
    if (hot) {
      return colorBgHot
    }
    if (root.enabled && root.hovering) {
      return colorBgHover
    }
    return colorBg
  }
  radius: width * 0.5
  border.color: root.enabled && root.hovering ? colorBorderHover : colorBorder
  border.width: Style.borderS

  Behavior on color {
    ColorAnimation {
      duration: Style.animationNormal
      easing.type: Easing.InOutQuad
    }
  }

  Behavior on scale {
    NumberAnimation {
      duration: Style.animationFast
      easing.type: Easing.OutCubic
    }
  }

  // Icon
  NIcon {
    icon: root.icon
    pointSize: Math.max(1, Math.round(root.width * 0.48))
    applyUiScale: root.applyUiScale
    color: {
      if (pressed) {
        return colorFgHover
      }
      if (hot) {
        return colorFgHot
      }
      if (root.enabled && root.hovering) {
        return colorFgHover
      }
      return colorFg
    }
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

    onPressed: function (mouse) {
      if (root.enabled) {
        root.pressed = true
        root.scale = 0.92
      }
      if (tooltipText) {
        TooltipService.hide()
      }
    }

    onReleased: function (mouse) {
      root.scale = 1.0
      root.pressed = false

      if (!root.enabled && !allowClickWhenDisabled) {
        return
      }

      // Only trigger actions if released while hovering
      if (root.hovering) {
        if (mouse.button === Qt.LeftButton) {
          root.clicked()
        } else if (mouse.button === Qt.RightButton) {
          root.rightClicked()
        } else if (mouse.button === Qt.MiddleButton) {
          root.middleClicked()
        }
      }
    }

    onCanceled: {
      root.hovering = false
      root.pressed = false
      root.scale = 1.0
      if (tooltipText) {
        TooltipService.hide()
      }
    }
  }
}
