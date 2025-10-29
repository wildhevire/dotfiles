pragma Singleton

import Quickshell
import qs.Commons

Singleton {
  id: root

  // A ref. to the lockScreen, so it's accessible from anywhere
  // This is not a panel...
  property var lockScreen: null

  // Panels
  property var registeredPanels: ({})
  property var openedPanel: null
  signal willOpen

  // Currently opened popups, can have more than one.
  // ex: when opening an NIconPicker from a widget setting.
  property var openedPopups: []
  property bool hasOpenedPopup: false
  signal popupChanged

  // Register this panel
  function registerPanel(panel) {
    registeredPanels[panel.objectName] = panel
    Logger.d("PanelService", "Registered:", panel.objectName)
  }

  // Returns a panel
  function getPanel(name) {
    return registeredPanels[name] || null
  }

  // Check if a panel exists
  function hasPanel(name) {
    return name in registeredPanels
  }

  // Helper to keep only one panel open at any time
  function willOpenPanel(panel) {
    if (openedPanel && openedPanel !== panel) {
      openedPanel.close()
    }
    openedPanel = panel

    // emit signal
    willOpen()
  }

  function closedPanel(panel) {
    if (openedPanel && openedPanel === panel) {
      openedPanel = null
    }
  }

  // Popups
  function willOpenPopup(popup) {
    openedPopups.push(popup)
    hasOpenedPopup = (openedPopups.length !== 0)
    popupChanged()
  }

  function willClosePopup(popup) {
    openedPopups = openedPopups.filter(p => p !== popup)
    hasOpenedPopup = (openedPopups.length !== 0)
    popupChanged()
  }
}
