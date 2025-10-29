import QtQuick
import QtQuick.Layouts
import qs.Commons

ColumnLayout {
  id: root
  property string label: ""
  property string description: ""
  property bool expanded: false
  property bool defaultExpanded: false
  property real contentSpacing: Style.marginM
  signal toggled(bool expanded)

  Layout.fillWidth: true
  spacing: 0

  // Default property to accept children
  default property alias content: contentLayout.children

  // Header with clickable area
  Rectangle {
    id: headerContainer
    Layout.fillWidth: true
    Layout.preferredHeight: headerContent.implicitHeight + (Style.marginM * 2)

    // Material 3 style background
    color: root.expanded ? Color.mSecondary : Color.mSurfaceVariant
    radius: Style.radiusL

    // Subtle border
    border.color: root.expanded ? Color.mOnSecondary : Color.mOutline
    border.width: Style.borderS

    // Smooth color transitions
    Behavior on color {
      ColorAnimation {
        duration: Style.animationNormal
        easing.type: Easing.OutCubic
      }
    }

    Behavior on border.color {
      ColorAnimation {
        duration: Style.animationNormal
        easing.type: Easing.OutCubic
      }
    }

    MouseArea {
      id: headerArea
      anchors.fill: parent
      cursorShape: Qt.PointingHandCursor
      hoverEnabled: true

      onClicked: {
        root.expanded = !root.expanded
        root.toggled(root.expanded)
      }

      // Hover effect overlay
      Rectangle {
        anchors.fill: parent
        color: headerArea.containsMouse ? Color.mOnSurface : Color.transparent
        opacity: headerArea.containsMouse ? 0.08 : 0
        radius: headerContainer.radius // Reference the container's radius directly

        Behavior on opacity {
          NumberAnimation {
            duration: Style.animationFast
          }
        }
      }
    }

    RowLayout {
      id: headerContent
      anchors.fill: parent
      anchors.margins: Style.marginM
      spacing: Style.marginM

      // Expand/collapse icon with rotation animation
      NIcon {
        id: chevronIcon
        icon: "chevron-right"
        pointSize: Style.fontSizeL
        color: root.expanded ? Color.mOnSecondary : Color.mOnSurfaceVariant
        Layout.alignment: Qt.AlignVCenter

        rotation: root.expanded ? 90 : 0
        Behavior on rotation {
          NumberAnimation {
            duration: Style.animationNormal
            easing.type: Easing.OutCubic
          }
        }

        Behavior on color {
          ColorAnimation {
            duration: Style.animationNormal
          }
        }
      }

      // Header text content - properly contained
      RowLayout {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignVCenter
        spacing: Style.marginL

        NText {
          text: root.label
          pointSize: Style.fontSizeL
          font.weight: Style.fontWeightSemiBold
          color: root.expanded ? Color.mOnSecondary : Color.mOnSurface
          wrapMode: Text.WordWrap

          Behavior on color {
            ColorAnimation {
              duration: Style.animationNormal
            }
          }
        }

        NText {
          text: root.description
          pointSize: Style.fontSizeS
          font.weight: Style.fontWeightRegular
          color: root.expanded ? Color.mOnSecondary : Color.mOnSurfaceVariant
          Layout.fillWidth: true
          wrapMode: Text.WordWrap
          visible: root.description !== ""
          opacity: 0.87

          Behavior on color {
            ColorAnimation {
              duration: Style.animationNormal
            }
          }
        }
      }
    }
  }

  // Collapsible content with Material 3 styling
  Rectangle {
    id: contentContainer
    Layout.fillWidth: true
    Layout.topMargin: Style.marginS

    visible: root.expanded
    color: Color.mSurface
    radius: Style.radiusL
    border.color: Color.mOutline
    border.width: Style.borderS

    // Dynamic height based on content
    Layout.preferredHeight: visible ? contentLayout.implicitHeight + (Style.marginL * 2) : 0

    // Smooth height animation
    Behavior on Layout.preferredHeight {
      NumberAnimation {
        duration: Style.animationNormal
        easing.type: Easing.OutCubic
      }
    }

    // Content layout
    ColumnLayout {
      id: contentLayout
      anchors.fill: parent
      anchors.margins: Style.marginL
      spacing: root.contentSpacing
    }

    // Fade in animation for content
    opacity: root.expanded ? 1.0 : 0.0
    Behavior on opacity {
      NumberAnimation {
        duration: Style.animationNormal
        easing.type: Easing.OutCubic
      }
    }
  }

  // Initialize expanded state
  Component.onCompleted: {
    root.expanded = root.defaultExpanded
  }
}
