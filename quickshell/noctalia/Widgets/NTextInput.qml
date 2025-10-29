import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons
import qs.Services

ColumnLayout {
  id: root

  property string label: ""
  property string description: ""
  property string inputIconName: ""
  property bool readOnly: false
  property bool enabled: true
  property color labelColor: Color.mOnSurface
  property color descriptionColor: Color.mOnSurfaceVariant
  property string fontFamily: Settings.data.ui.fontDefault
  property real fontSize: Style.fontSizeS
  property int fontWeight: Style.fontWeightRegular

  property alias text: input.text
  property alias placeholderText: input.placeholderText
  property alias inputMethodHints: input.inputMethodHints
  property alias inputItem: input

  signal editingFinished

  spacing: Style.marginS

  NLabel {
    label: root.label
    description: root.description
    labelColor: root.labelColor
    descriptionColor: root.descriptionColor
    visible: root.label !== "" || root.description !== ""
    Layout.fillWidth: true
  }

  // An active control that blocks input, to avoid events leakage and dragging stuff in the background.
  Control {
    id: frameControl

    Layout.fillWidth: true
    Layout.minimumWidth: 80 * Style.uiScaleRatio
    implicitHeight: Style.baseWidgetSize * 1.1 * Style.uiScaleRatio

    // This is important - makes the control accept focus
    focusPolicy: Qt.StrongFocus
    hoverEnabled: true

    background: Rectangle {
      id: frame

      radius: Style.radiusM
      color: Color.mSurface
      border.color: input.activeFocus ? Color.mSecondary : Color.mOutline
      border.width: Style.borderS

      Behavior on border.color {
        ColorAnimation {
          duration: Style.animationFast
        }
      }
    }

    contentItem: Item {
      // Invisible background that captures ALL mouse events
      MouseArea {
        id: backgroundCapture
        anchors.fill: parent
        z: 0
        acceptedButtons: Qt.AllButtons
        hoverEnabled: true
        preventStealing: true
        propagateComposedEvents: false

        onPressed: mouse => {
                     mouse.accepted = true
                     // Focus the input and position cursor
                     input.forceActiveFocus()
                     var inputPos = mapToItem(inputContainer, mouse.x, mouse.y)
                     if (inputPos.x >= 0 && inputPos.x <= inputContainer.width) {
                       var textPos = inputPos.x - Style.marginM
                       if (textPos >= 0 && textPos <= input.width) {
                         input.cursorPosition = input.positionAt(textPos, input.height / 2)
                       }
                     }
                   }

        onReleased: mouse => {
                      mouse.accepted = true
                    }
        onDoubleClicked: mouse => {
                           mouse.accepted = true
                           input.selectAll()
                         }
        onPositionChanged: mouse => {
                             mouse.accepted = true
                           }
        onWheel: wheel => {
                   wheel.accepted = true
                 }
      }

      // Container for the actual text field
      Item {
        id: inputContainer
        anchors.fill: parent
        anchors.leftMargin: Style.marginM
        // anchors.rightMargin: Style.marginM
        clip: true
        z: 1

        RowLayout {
          anchors.fill: parent
          spacing: 0

          NIcon {
            id: inputIcon
            icon: root.inputIconName

            visible: root.inputIconName !== ""
            enabled: false

            Layout.alignment: Qt.AlignVCenter
            Layout.rightMargin: visible ? Style.marginS : 0
          }

          TextField {
            id: input

            Layout.fillWidth: true
            Layout.fillHeight: true

            verticalAlignment: TextInput.AlignVCenter

            echoMode: TextInput.Normal
            readOnly: root.readOnly
            enabled: root.enabled
            color: Color.mOnSurface
            placeholderTextColor: Qt.alpha(Color.mOnSurfaceVariant, 0.6)

            selectByMouse: true

            topPadding: 0
            bottomPadding: 0
            leftPadding: 0
            rightPadding: 0

            background: null

            font.family: root.fontFamily
            font.pointSize: root.fontSize * Style.uiScaleRatio
            font.weight: root.fontWeight

            onEditingFinished: root.editingFinished()

            // Override mouse handling to prevent propagation
            MouseArea {
              id: textFieldMouse
              anchors.fill: parent
              acceptedButtons: Qt.AllButtons
              preventStealing: true
              propagateComposedEvents: false
              cursorShape: Qt.IBeamCursor

              property int selectionStart: 0

              onPressed: mouse => {
                           mouse.accepted = true
                           input.forceActiveFocus()
                           var pos = input.positionAt(mouse.x, mouse.y)
                           input.cursorPosition = pos
                           selectionStart = pos
                         }

              onPositionChanged: mouse => {
                                   if (mouse.buttons & Qt.LeftButton) {
                                     mouse.accepted = true
                                     var pos = input.positionAt(mouse.x, mouse.y)
                                     input.select(selectionStart, pos)
                                   }
                                 }

              onDoubleClicked: mouse => {
                                 mouse.accepted = true
                                 input.selectAll()
                               }

              onReleased: mouse => {
                            mouse.accepted = true
                          }
              onWheel: wheel => {
                         wheel.accepted = true
                       }
            }
          }
          NIconButton {
            id: clearButton
            icon: "x"
            tooltipText: I18n.tr("widgets.text-input.clear")

            Layout.alignment: Qt.AlignVCenter

            border.width: 0

            colorBg: Color.transparent
            colorBgHover: Color.transparent
            colorFg: Color.mOnSurface
            colorFgHover: Color.mError

            visible: input.text.length > 0 && !root.readOnly
            enabled: input.text.length > 0 && !root.readOnly

            onClicked: {
              input.clear()
              input.forceActiveFocus()
            }
          }
        }
      }
    }
  }
}
