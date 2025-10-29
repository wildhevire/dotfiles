import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons
import qs.Services

Rectangle {
  id: root

  // Public properties
  property string text: ""
  property string icon: ""
  property string tooltipText
  property color backgroundColor: Color.mPrimary
  property color textColor: Color.mOnPrimary
  property color hoverColor: Color.mTertiary
  property bool enabled: true
  property real fontSize: Style.fontSizeM
  property int fontWeight: Style.fontWeightBold
  property real iconSize: Style.fontSizeL
  property bool outlined: false
  property int horizontalAlignment: Qt.AlignHCenter

  // Signals
  signal clicked
  signal rightClicked
  signal middleClicked
  signal entered
  signal exited

  // Internal properties
  property bool hovered: false

  // Dimensions
  implicitWidth: contentRow.implicitWidth + (Style.marginL * 2)
  implicitHeight: Math.max(Style.baseWidgetSize, contentRow.implicitHeight + (Style.marginM))

  // Appearance
  radius: Style.radiusS
  color: {
    if (!enabled)
      return outlined ? Color.transparent : Qt.lighter(Color.mSurfaceVariant, 1.2)
    if (hovered)
      return hoverColor
    return outlined ? Color.transparent : backgroundColor
  }

  border.width: outlined ? Style.borderS : 0
  border.color: {
    if (!enabled)
      return Color.mOutline
    if (hovered)
      return backgroundColor
    return outlined ? backgroundColor : Color.transparent
  }

  opacity: enabled ? 1.0 : 0.6

  Behavior on color {
    ColorAnimation {
      duration: Style.animationFast
      easing.type: Easing.OutCubic
    }
  }

  Behavior on border.color {
    ColorAnimation {
      duration: Style.animationFast
      easing.type: Easing.OutCubic
    }
  }

  // Content
  RowLayout {
    id: contentRow
    anchors.verticalCenter: parent.verticalCenter
    anchors.left: root.horizontalAlignment === Qt.AlignLeft ? parent.left : undefined
    anchors.horizontalCenter: root.horizontalAlignment === Qt.AlignHCenter ? parent.horizontalCenter : undefined
    anchors.leftMargin: root.horizontalAlignment === Qt.AlignLeft ? Style.marginL : 0
    spacing: Style.marginXS

    // Icon (optional)
    NIcon {
      Layout.alignment: Qt.AlignVCenter
      visible: root.icon !== ""
      icon: root.icon
      pointSize: root.iconSize
      color: {
        if (!root.enabled)
          return Color.mOnSurfaceVariant
        if (root.outlined) {
          if (root.hovered)
            return root.textColor
          return root.backgroundColor
        }
        return root.textColor
      }

      Behavior on color {
        ColorAnimation {
          duration: Style.animationFast
          easing.type: Easing.OutCubic
        }
      }
    }

    // Text
    NText {
      Layout.alignment: Qt.AlignVCenter
      visible: root.text !== ""
      text: root.text
      pointSize: root.fontSize
      font.weight: root.fontWeight
      color: {
        if (!root.enabled)
          return Color.mOnSurfaceVariant
        if (root.outlined) {
          if (root.hovered)
            return root.textColor
          return root.backgroundColor
        }
        return root.textColor
      }

      Behavior on color {
        ColorAnimation {
          duration: Style.animationFast
          easing.type: Easing.OutCubic
        }
      }
    }
  }

  // Mouse interaction
  MouseArea {
    id: mouseArea
    anchors.fill: parent
    enabled: root.enabled
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
    cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

    onEntered: {
      root.hovered = true
      root.entered()
      if (tooltipText) {
        TooltipService.show(Screen, root, root.tooltipText)
      }
    }
    onExited: {
      root.hovered = false
      root.exited()
      if (tooltipText) {
        TooltipService.hide()
      }
    }
    onPressed: mouse => {
                 if (tooltipText) {
                   TooltipService.hide()
                 }
                 if (mouse.button === Qt.LeftButton) {
                   root.clicked()
                 } else if (mouse.button == Qt.RightButton) {
                   root.rightClicked()
                 } else if (mouse.button == Qt.MiddleButton) {
                   root.middleClicked()
                 }
               }

    onCanceled: {
      root.hovered = false
      if (tooltipText) {
        TooltipService.hide()
      }
    }
  }
}
