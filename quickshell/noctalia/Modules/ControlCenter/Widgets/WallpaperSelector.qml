import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Services
import qs.Widgets

NIconButtonHot {
  property ShellScreen screen

  enabled: Settings.data.wallpaper.enabled
  icon: "wallpaper-selector"
  tooltipText: I18n.tr("quickSettings.wallpaperSelector.tooltip.action")
  onClicked: PanelService.getPanel("wallpaperPanel")?.toggle(this)
  onRightClicked: WallpaperService.setRandomWallpaper()
}
