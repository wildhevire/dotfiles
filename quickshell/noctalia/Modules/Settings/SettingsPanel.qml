import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Modules.Settings.Tabs
import qs.Commons
import qs.Services
import qs.Widgets

NPanel {
  id: root

  preferredWidth: 820 * Style.uiScaleRatio
  preferredHeight: 940 * Style.uiScaleRatio

  panelAnchorHorizontalCenter: true
  panelAnchorVerticalCenter: true
  panelKeyboardFocus: true

  draggable: !PanelService.hasOpenedPopup

  // Tabs enumeration, order is NOT relevant
  enum Tab {
    About,
    Audio,
    Bar,
    ColorScheme,
    LockScreen,
    ControlCenter,
    OSD,
    Display,
    Dock,
    General,
    Hooks,
    Launcher,
    Location,
    Network,
    Notifications,
    ScreenRecorder,
    UserInterface,
    Wallpaper
  }

  property int requestedTab: SettingsPanel.Tab.General
  property int currentTabIndex: 0
  property var tabsModel: []
  property var activeScrollView: null

  Component.onCompleted: {
    updateTabsModel()
  }

  Component {
    id: generalTab
    GeneralTab {}
  }
  Component {
    id: launcherTab
    LauncherTab {}
  }
  Component {
    id: barTab
    BarTab {}
  }
  Component {
    id: audioTab
    AudioTab {}
  }
  Component {
    id: displayTab
    DisplayTab {}
  }
  Component {
    id: osdTab
    OsdTab {}
  }
  Component {
    id: networkTab
    NetworkTab {}
  }
  Component {
    id: locationTab
    LocationTab {}
  }
  Component {
    id: colorSchemeTab
    ColorSchemeTab {}
  }
  Component {
    id: wallpaperTab
    WallpaperTab {}
  }
  Component {
    id: screenRecorderTab
    ScreenRecorderTab {}
  }
  Component {
    id: aboutTab
    AboutTab {}
  }
  Component {
    id: hooksTab
    HooksTab {}
  }
  Component {
    id: dockTab
    DockTab {}
  }
  Component {
    id: notificationsTab
    NotificationsTab {}
  }
  Component {
    id: controlCenterTab
    ControlCenterTab {}
  }
  Component {
    id: userInterfaceTab
    UserInterfaceTab {}
  }
  Component {
    id: lockScreenTab
    LockScreenTab {}
  }

  // Order *DOES* matter
  function updateTabsModel() {
    let newTabs = [{
                     "id": SettingsPanel.Tab.General,
                     "label": "settings.general.title",
                     "icon": "settings-general",
                     "source": generalTab
                   }, {
                     "id": SettingsPanel.Tab.UserInterface,
                     "label": "settings.user-interface.title",
                     "icon": "settings-user-interface",
                     "source": userInterfaceTab
                   }, {
                     "id": SettingsPanel.Tab.Bar,
                     "label": "settings.bar.title",
                     "icon": "settings-bar",
                     "source": barTab
                   }, {
                     "id": SettingsPanel.Tab.ControlCenter,
                     "label": "settings.control-center.title",
                     "icon": "settings-control-center",
                     "source": controlCenterTab
                   }, {
                     "id": SettingsPanel.Tab.Dock,
                     "label": "settings.dock.title",
                     "icon": "settings-dock",
                     "source": dockTab
                   }, {
                     "id": SettingsPanel.Tab.Launcher,
                     "label": "settings.launcher.title",
                     "icon": "settings-launcher",
                     "source": launcherTab
                   }, {
                     "id": SettingsPanel.Tab.LockScreen,
                     "label": "settings.lock-screen.title",
                     "icon": "settings-lock-screen",
                     "source": lockScreenTab
                   }, {
                     "id": SettingsPanel.Tab.Audio,
                     "label": "settings.audio.title",
                     "icon": "settings-audio",
                     "source": audioTab
                   }, {
                     "id": SettingsPanel.Tab.Display,
                     "label": "settings.display.title",
                     "icon": "settings-display",
                     "source": displayTab
                   }, {
                     "id": SettingsPanel.Tab.OSD,
                     "label": "settings.osd.title",
                     "icon": "settings-osd",
                     "source": osdTab
                   }, {
                     "id": SettingsPanel.Tab.Notifications,
                     "label": "settings.notifications.title",
                     "icon": "settings-notifications",
                     "source": notificationsTab
                   }, {
                     "id": SettingsPanel.Tab.Network,
                     "label": "settings.network.title",
                     "icon": "settings-network",
                     "source": networkTab
                   }, {
                     "id": SettingsPanel.Tab.Location,
                     "label": "settings.location.title",
                     "icon": "settings-location",
                     "source": locationTab
                   }, {
                     "id": SettingsPanel.Tab.ColorScheme,
                     "label": "settings.color-scheme.title",
                     "icon": "settings-color-scheme",
                     "source": colorSchemeTab
                   }, {
                     "id": SettingsPanel.Tab.Wallpaper,
                     "label": "settings.wallpaper.title",
                     "icon": "settings-wallpaper",
                     "source": wallpaperTab
                   }, {
                     "id": SettingsPanel.Tab.ScreenRecorder,
                     "label": "settings.screen-recorder.title",
                     "icon": "settings-screen-recorder",
                     "source": screenRecorderTab
                   }, {
                     "id": SettingsPanel.Tab.Hooks,
                     "label": "settings.hooks.title",
                     "icon": "settings-hooks",
                     "source": hooksTab
                   }, {
                     "id": SettingsPanel.Tab.About,
                     "label": "settings.about.title",
                     "icon": "settings-about",
                     "source": aboutTab
                   }]

    root.tabsModel = newTabs // Assign the generated list to the model
  }
  // When the panel opens, choose the appropriate tab
  onOpened: {
    updateTabsModel()

    var initialIndex = SettingsPanel.Tab.General
    if (root.requestedTab !== null) {
      for (var i = 0; i < root.tabsModel.length; i++) {
        if (root.tabsModel[i].id === root.requestedTab) {
          initialIndex = i
          break
        }
      }
    }
    // Now that the UI is settled, set the current tab index.
    root.currentTabIndex = initialIndex
  }

  // Add scroll functions
  function scrollDown() {
    if (activeScrollView && activeScrollView.ScrollBar.vertical) {
      const scrollBar = activeScrollView.ScrollBar.vertical
      const stepSize = activeScrollView.height * 0.1 // Scroll 10% of viewport
      scrollBar.position = Math.min(scrollBar.position + stepSize / activeScrollView.contentHeight, 1.0 - scrollBar.size)
    }
  }

  function scrollUp() {
    if (activeScrollView && activeScrollView.ScrollBar.vertical) {
      const scrollBar = activeScrollView.ScrollBar.vertical
      const stepSize = activeScrollView.height * 0.1 // Scroll 10% of viewport
      scrollBar.position = Math.max(scrollBar.position - stepSize / activeScrollView.contentHeight, 0)
    }
  }

  function scrollPageDown() {
    if (activeScrollView && activeScrollView.ScrollBar.vertical) {
      const scrollBar = activeScrollView.ScrollBar.vertical
      const pageSize = activeScrollView.height * 0.9 // Scroll 90% of viewport
      scrollBar.position = Math.min(scrollBar.position + pageSize / activeScrollView.contentHeight, 1.0 - scrollBar.size)
    }
  }

  function scrollPageUp() {
    if (activeScrollView && activeScrollView.ScrollBar.vertical) {
      const scrollBar = activeScrollView.ScrollBar.vertical
      const pageSize = activeScrollView.height * 0.9 // Scroll 90% of viewport
      scrollBar.position = Math.max(scrollBar.position - pageSize / activeScrollView.contentHeight, 0)
    }
  }

  // Add navigation functions
  function selectNextTab() {
    if (tabsModel.length > 0) {
      currentTabIndex = (currentTabIndex + 1) % tabsModel.length
    }
  }

  function selectPreviousTab() {
    if (tabsModel.length > 0) {
      currentTabIndex = (currentTabIndex - 1 + tabsModel.length) % tabsModel.length
    }
  }

  panelContent: Rectangle {
    color: Color.transparent

    // Main layout container that fills the panel
    ColumnLayout {
      anchors.fill: parent
      anchors.margins: Style.marginL
      spacing: 0

      // Keyboard shortcuts container
      Item {
        Layout.preferredWidth: 0
        Layout.preferredHeight: 0

        // Scrolling via keyboard
        Shortcut {
          sequence: "Down"
          onActivated: root.scrollDown()
          enabled: root.opened
        }

        Shortcut {
          sequence: "Up"
          onActivated: root.scrollUp()
          enabled: root.opened
        }

        Shortcut {
          sequence: "Ctrl+J"
          onActivated: root.scrollDown()
          enabled: root.opened
        }

        Shortcut {
          sequence: "Ctrl+K"
          onActivated: root.scrollUp()
          enabled: root.opened
        }

        Shortcut {
          sequence: "PgDown"
          onActivated: root.scrollPageDown()
          enabled: root.opened
        }

        Shortcut {
          sequence: "PgUp"
          onActivated: root.scrollPageUp()
          enabled: root.opened
        }

        // Changing tab via keyboard
        Shortcut {
          sequence: "Tab"
          onActivated: root.selectNextTab()
          enabled: root.opened
        }

        Shortcut {
          sequence: "Shift+Tab"
          onActivated: root.selectPreviousTab()
          enabled: root.opened
        }
      }

      // Main content area
      RowLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: Style.marginL

        // Sidebar
        Rectangle {
          id: sidebar
          Layout.preferredWidth: 220 * Style.uiScaleRatio
          Layout.fillHeight: true
          Layout.alignment: Qt.AlignTop
          color: Color.mSurfaceVariant
          border.color: Color.mOutline
          border.width: Style.borderS
          radius: Style.radiusM

          MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton // Don't interfere with clicks
            property int wheelAccumulator: 0
            onWheel: wheel => {
                       wheelAccumulator += wheel.angleDelta.y
                       if (wheelAccumulator >= 120) {
                         root.selectPreviousTab()
                         wheelAccumulator = 0
                       } else if (wheelAccumulator <= -120) {
                         root.selectNextTab()
                         wheelAccumulator = 0
                       }
                       wheel.accepted = true
                     }
          }

          ColumnLayout {
            anchors.fill: parent
            anchors.margins: Style.marginS
            spacing: Style.marginXS

            Repeater {
              id: sections
              model: root.tabsModel
              delegate: Rectangle {
                id: tabItem
                Layout.fillWidth: true
                Layout.preferredHeight: tabEntryRow.implicitHeight + Style.marginM * 2
                radius: Style.radiusS
                color: selected ? Color.mPrimary : (tabItem.hovering ? Color.mTertiary : Color.transparent)
                readonly property bool selected: index === currentTabIndex
                property bool hovering: false
                property color tabTextColor: selected ? Color.mOnPrimary : (tabItem.hovering ? Color.mOnTertiary : Color.mOnSurface)

                Behavior on color {
                  ColorAnimation {
                    duration: Style.animationFast
                  }
                }

                Behavior on tabTextColor {
                  ColorAnimation {
                    duration: Style.animationFast
                  }
                }

                RowLayout {
                  id: tabEntryRow
                  anchors.fill: parent
                  anchors.leftMargin: Style.marginS
                  anchors.rightMargin: Style.marginS
                  spacing: Style.marginM

                  // Tab icon
                  NIcon {
                    icon: modelData.icon
                    color: tabTextColor
                    pointSize: Style.fontSizeXL
                  }

                  // Tab label
                  NText {
                    text: I18n.tr(modelData.label)
                    color: tabTextColor
                    pointSize: Style.fontSizeM
                    font.weight: Style.fontWeightBold
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                  }
                }

                MouseArea {
                  anchors.fill: parent
                  hoverEnabled: true
                  acceptedButtons: Qt.LeftButton
                  onEntered: tabItem.hovering = true
                  onExited: tabItem.hovering = false
                  onCanceled: tabItem.hovering = false
                  onClicked: currentTabIndex = index
                }
              }
            }

            Item {
              Layout.fillHeight: true
            }
          }
        }

        // Content pane
        Rectangle {
          id: contentPane
          Layout.fillWidth: true
          Layout.fillHeight: true
          Layout.alignment: Qt.AlignTop
          radius: Style.radiusM
          color: Color.mSurfaceVariant
          border.color: Color.mOutline
          border.width: Style.borderS

          ColumnLayout {
            id: contentLayout
            anchors.fill: parent
            anchors.margins: Style.marginL
            spacing: Style.marginS

            // Header row
            RowLayout {
              id: headerRow
              Layout.fillWidth: true
              spacing: Style.marginS

              // Main icon
              NIcon {
                icon: root.tabsModel[currentTabIndex]?.icon
                color: Color.mPrimary
                pointSize: Style.fontSizeXXL
              }

              // Main title
              NText {
                text: I18n.tr(root.tabsModel[currentTabIndex]?.label) || ""
                pointSize: Style.fontSizeXL
                font.weight: Style.fontWeightBold
                color: Color.mPrimary
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
              }

              // Close button
              NIconButton {
                icon: "close"
                tooltipText: I18n.tr("tooltips.close")
                Layout.alignment: Qt.AlignVCenter
                onClicked: root.close()
              }
            }

            // Divider
            NDivider {
              Layout.fillWidth: true
            }

            // Tab content area
            Rectangle {
              Layout.fillWidth: true
              Layout.fillHeight: true
              color: Color.transparent

              Repeater {
                model: root.tabsModel
                delegate: Loader {
                  anchors.fill: parent
                  active: index === root.currentTabIndex

                  onStatusChanged: {
                    if (status === Loader.Ready && item) {
                      // Find and store reference to the ScrollView
                      const scrollView = item.children[0]
                      if (scrollView && scrollView.toString().includes("ScrollView")) {
                        root.activeScrollView = scrollView
                      }
                    }
                  }

                  sourceComponent: Flickable {
                    // Using a Flickable here with a pressDelay to fix conflict between
                    // ScrollView and NTextInput. This fixes the weird text selection issue.
                    id: flickable
                    anchors.fill: parent
                    pressDelay: 200

                    NScrollView {
                      id: scrollView
                      anchors.fill: parent
                      horizontalPolicy: ScrollBar.AlwaysOff
                      verticalPolicy: ScrollBar.AsNeeded
                      padding: Style.marginL
                      Component.onCompleted: {
                        root.activeScrollView = scrollView
                      }

                      Loader {
                        active: true
                        sourceComponent: root.tabsModel[index]?.source
                        width: scrollView.availableWidth
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
