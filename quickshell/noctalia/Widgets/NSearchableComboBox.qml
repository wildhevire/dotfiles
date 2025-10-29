import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons
import qs.Services
import qs.Widgets
import "../Helpers/FuzzySort.js" as Fuzzysort

RowLayout {
  id: root

  property real minimumWidth: 280 * Style.uiScaleRatio
  property real popupHeight: 180 * Style.uiScaleRatio

  property string label: ""
  property string description: ""
  property ListModel model: {

  }
  property string currentKey: ""
  property string placeholder: ""
  property string searchPlaceholder: I18n.tr("placeholders.search")
  property Component delegate: null

  readonly property real preferredHeight: Style.baseWidgetSize * 1.1

  signal selected(string key)

  spacing: Style.marginL
  Layout.fillWidth: true

  // Filtered model for search results
  property ListModel filteredModel: ListModel {}
  property string searchText: ""

  function findIndexByKey(key) {
    for (var i = 0; i < root.model.count; i++) {
      if (root.model.get(i).key === key) {
        return i
      }
    }
    return -1
  }

  function findIndexByKeyInFiltered(key) {
    for (var i = 0; i < root.filteredModel.count; i++) {
      if (root.filteredModel.get(i).key === key) {
        return i
      }
    }
    return -1
  }

  function filterModel() {
    filteredModel.clear()

    // Check if model exists and has items
    if (!root.model || root.model.count === undefined || root.model.count === 0) {
      return
    }

    if (searchText.trim() === "") {
      // If no search text, show all items
      for (var i = 0; i < root.model.count; i++) {
        filteredModel.append(root.model.get(i))
      }
    } else {
      // Convert ListModel to array for fuzzy search
      var items = []
      for (var i = 0; i < root.model.count; i++) {
        items.push(root.model.get(i))
      }

      // Use fuzzy search if available, fallback to simple search
      if (typeof Fuzzysort !== 'undefined') {
        var fuzzyResults = Fuzzysort.go(searchText, items, {
                                          "key": "name",
                                          "threshold": -1000,
                                          "limit": 50
                                        })

        // Add results in order of relevance
        for (var j = 0; j < fuzzyResults.length; j++) {
          filteredModel.append(fuzzyResults[j].obj)
        }
      } else {
        // Fallback to simple search
        var searchLower = searchText.toLowerCase()
        for (var i = 0; i < items.length; i++) {
          var item = items[i]
          if (item.name.toLowerCase().includes(searchLower)) {
            filteredModel.append(item)
          }
        }
      }
    }
  }

  onSearchTextChanged: filterModel()
  onModelChanged: filterModel()

  NLabel {
    label: root.label
    description: root.description
  }

  Item {
    Layout.fillWidth: true
  }

  ComboBox {
    id: combo

    Layout.minimumWidth: root.minimumWidth
    Layout.preferredHeight: root.preferredHeight
    model: filteredModel
    currentIndex: findIndexByKeyInFiltered(currentKey)
    onActivated: {
      if (combo.currentIndex >= 0 && combo.currentIndex < filteredModel.count) {
        root.selected(filteredModel.get(combo.currentIndex).key)
      }
    }

    background: Rectangle {
      implicitWidth: Style.baseWidgetSize * 3.75 * Style.uiScaleRatio
      implicitHeight: preferredHeight
      color: Color.mSurface
      border.color: combo.activeFocus ? Color.mSecondary : Color.mOutline
      border.width: Style.borderS
      radius: Style.radiusM

      Behavior on border.color {
        ColorAnimation {
          duration: Style.animationFast
        }
      }
    }

    contentItem: NText {
      leftPadding: Style.marginL
      rightPadding: combo.indicator.width + Style.marginL
      pointSize: Style.fontSizeM
      verticalAlignment: Text.AlignVCenter
      elide: Text.ElideRight
      color: (combo.currentIndex >= 0 && combo.currentIndex < filteredModel.count) ? Color.mOnSurface : Color.mOnSurfaceVariant
      text: (combo.currentIndex >= 0 && combo.currentIndex < filteredModel.count) ? filteredModel.get(combo.currentIndex).name : root.placeholder
    }

    indicator: NIcon {
      x: combo.width - width - Style.marginM
      y: combo.topPadding + (combo.availableHeight - height) / 2
      icon: "caret-down"
      pointSize: Style.fontSizeL
    }

    popup: Popup {
      y: combo.height
      width: combo.width
      height: root.popupHeight + 60
      padding: Style.marginM

      onOpened: {
        PanelService.willOpenPopup(root)
      }

      onClosed: {
        PanelService.willClosePopup(root)
      }

      contentItem: ColumnLayout {
        spacing: Style.marginS

        // Search input
        NTextInput {
          id: searchInput
          inputIconName: "search"
          Layout.fillWidth: true
          placeholderText: root.searchPlaceholder
          text: root.searchText
          onTextChanged: root.searchText = text
          fontSize: Style.fontSizeS
        }

        NListView {
          id: listView
          Layout.fillWidth: true
          Layout.fillHeight: true
          model: combo.popup.visible ? filteredModel : null
          horizontalPolicy: ScrollBar.AlwaysOff
          verticalPolicy: ScrollBar.AsNeeded

          delegate: root.delegate ? root.delegate : defaultDelegate

          Component {
            id: defaultDelegate
            ItemDelegate {
              id: delegateRoot
              width: listView.width
              hoverEnabled: true
              highlighted: ListView.view.currentIndex === index

              onHoveredChanged: {
                if (hovered) {
                  ListView.view.currentIndex = index
                }
              }

              onClicked: {
                root.selected(filteredModel.get(index).key)
                combo.currentIndex = root.findIndexByKeyInFiltered(filteredModel.get(index).key)
                combo.popup.close()
              }

              contentItem: RowLayout {
                width: parent.width
                spacing: Style.marginM

                NText {
                  text: name
                  pointSize: Style.fontSizeM
                  color: highlighted ? Color.mOnTertiary : Color.mOnSurface
                  verticalAlignment: Text.AlignVCenter
                  elide: Text.ElideRight
                  Layout.fillWidth: true
                  Behavior on color {
                    ColorAnimation {
                      duration: Style.animationFast
                    }
                  }
                }

                RowLayout {
                  spacing: Style.marginS
                  Layout.alignment: Qt.AlignRight

                  Repeater {
                    model: typeof badgeLocations !== 'undefined' ? badgeLocations : []

                    delegate: NBox {
                      width: Style.baseWidgetSize * 0.7
                      height: Style.baseWidgetSize * 0.7
                      color: "transparent"
                      radius: Style.radiusS
                      border.width: 0

                      NText {
                        anchors.centerIn: parent
                        text: modelData
                        pointSize: Style.fontSizeXXS
                        font.weight: Style.fontWeightBold
                        color: highlighted ? Color.mOnTertiary : Color.mOnSurface
                      }
                    }
                  }
                }
              }
              background: Rectangle {
                width: listView.width
                color: highlighted ? Color.mTertiary : Color.transparent
                radius: Style.radiusS
                Behavior on color {
                  ColorAnimation {
                    duration: Style.animationFast
                  }
                }
              }
            }
          }
        }
      }

      background: Rectangle {
        color: Color.mSurfaceVariant
        border.color: Color.mOutline
        border.width: Style.borderS
        radius: Style.radiusM
      }
    }

    // Update the currentIndex if the currentKey is changed externally
    Connections {
      target: root
      function onCurrentKeyChanged() {
        combo.currentIndex = root.findIndexByKeyInFiltered(currentKey)
      }
    }

    // Focus search input when popup opens and ensure model is filtered
    Connections {
      target: combo.popup
      function onVisibleChanged() {
        if (combo.popup.visible) {
          // Ensure the model is filtered when popup opens
          filterModel()
          // Small delay to ensure the popup is fully rendered
          Qt.callLater(() => {
                         if (searchInput && searchInput.inputItem) {
                           searchInput.inputItem.forceActiveFocus()
                         }
                       })
        }
      }
    }
  }
}
