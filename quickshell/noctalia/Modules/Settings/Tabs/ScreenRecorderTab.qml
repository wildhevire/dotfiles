import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Services
import qs.Widgets

ColumnLayout {
  id: root

  spacing: Style.marginL

  NHeader {
    label: I18n.tr("settings.screen-recorder.general.section.label")
    description: I18n.tr("settings.screen-recorder.general.section.description")
  }

  // Output Folder
  ColumnLayout {
    spacing: Style.marginS
    Layout.fillWidth: true

    NTextInputButton {
      label: I18n.tr("settings.screen-recorder.general.output-folder.label")
      description: I18n.tr("settings.screen-recorder.general.output-folder.description")
      placeholderText: Quickshell.env("HOME") + "/Videos"
      text: Settings.data.screenRecorder.directory
      buttonIcon: "folder-open"
      buttonTooltip: I18n.tr("settings.screen-recorder.general.output-folder.tooltip")
      onInputEditingFinished: Settings.data.screenRecorder.directory = text
      onButtonClicked: folderPicker.openFilePicker()
    }

    // Show Cursor
    NToggle {
      label: I18n.tr("settings.screen-recorder.general.show-cursor.label")
      description: I18n.tr("settings.screen-recorder.general.show-cursor.description")
      checked: Settings.data.screenRecorder.showCursor
      onToggled: checked => Settings.data.screenRecorder.showCursor = checked
    }
  }

  NDivider {
    Layout.fillWidth: true
    Layout.topMargin: Style.marginXL
    Layout.bottomMargin: Style.marginXL
  }

  // Video Settings
  ColumnLayout {
    spacing: Style.marginL
    Layout.fillWidth: true

    NHeader {
      label: I18n.tr("settings.screen-recorder.video.section.label")
      description: I18n.tr("settings.screen-recorder.video.section.description")
    }

    // Source
    NComboBox {
      label: I18n.tr("settings.screen-recorder.video.video-source.label")
      description: I18n.tr("settings.screen-recorder.video.video-source.description")
      model: [{
          "key": "portal",
          "name": I18n.tr("options.screen-recording.sources.portal")
        }, {
          "key": "screen",
          "name": I18n.tr("options.screen-recording.sources.screen")
        }]
      currentKey: Settings.data.screenRecorder.videoSource
      onSelected: key => Settings.data.screenRecorder.videoSource = key
    }

    // Frame Rate
    NComboBox {
      label: I18n.tr("settings.screen-recorder.video.frame-rate.label")
      description: I18n.tr("settings.screen-recorder.video.frame-rate.description")
      model: [{
          "key": "30",
          "name": I18n.tr("options.frame-rates.fps", {
                            "fps": "30"
                          })
        }, {
          "key": "60",
          "name": I18n.tr("options.frame-rates.fps", {
                            "fps": "60"
                          })
        }, {
          "key": "100",
          "name": I18n.tr("options.frame-rates.fps", {
                            "fps": "100"
                          })
        }, {
          "key": "120",
          "name": I18n.tr("options.frame-rates.fps", {
                            "fps": "120"
                          })
        }, {
          "key": "144",
          "name": I18n.tr("options.frame-rates.fps", {
                            "fps": "144"
                          })
        }, {
          "key": "165",
          "name": I18n.tr("options.frame-rates.fps", {
                            "fps": "165"
                          })
        }, {
          "key": "240",
          "name": I18n.tr("options.frame-rates.fps", {
                            "fps": "240"
                          })
        }]
      currentKey: Settings.data.screenRecorder.frameRate
      onSelected: key => Settings.data.screenRecorder.frameRate = key
    }

    // Video Quality
    NComboBox {
      label: I18n.tr("settings.screen-recorder.video.video-quality.label")
      description: I18n.tr("settings.screen-recorder.video.video-quality.description")
      model: [{
          "key": "medium",
          "name": I18n.tr("options.screen-recording.quality.medium")
        }, {
          "key": "high",
          "name": I18n.tr("options.screen-recording.quality.high")
        }, {
          "key": "very_high",
          "name": I18n.tr("options.screen-recording.quality.very-high")
        }, {
          "key": "ultra",
          "name": I18n.tr("options.screen-recording.quality.ultra")
        }]
      currentKey: Settings.data.screenRecorder.quality
      onSelected: key => Settings.data.screenRecorder.quality = key
    }

    // Video Codec
    NComboBox {
      label: I18n.tr("settings.screen-recorder.video.video-codec.label")
      description: I18n.tr("settings.screen-recorder.video.video-codec.description")
      model: [{
          "key": "h264",
          "name": "H264"
        }, {
          "key": "hevc",
          "name": "HEVC"
        }, {
          "key": "av1",
          "name": "AV1"
        }, {
          "key": "vp8",
          "name": "VP8"
        }, {
          "key": "vp9",
          "name": "VP9"
        }]
      currentKey: Settings.data.screenRecorder.videoCodec
      onSelected: key => Settings.data.screenRecorder.videoCodec = key
    }

    // Color Range
    NComboBox {
      label: I18n.tr("settings.screen-recorder.video.color-range.label")
      description: I18n.tr("settings.screen-recorder.video.color-range.description")
      model: [{
          "key": "limited",
          "name": I18n.tr("options.screen-recording.color-range.limited")
        }, {
          "key": "full",
          "name": I18n.tr("options.screen-recording.color-range.full")
        }]
      currentKey: Settings.data.screenRecorder.colorRange
      onSelected: key => Settings.data.screenRecorder.colorRange = key
    }
  }

  NDivider {
    Layout.fillWidth: true
    Layout.topMargin: Style.marginXL
    Layout.bottomMargin: Style.marginXL
  }

  // Audio Settings
  ColumnLayout {
    spacing: Style.marginL
    Layout.fillWidth: true

    NHeader {
      label: I18n.tr("settings.screen-recorder.audio.section.label")
      description: I18n.tr("settings.screen-recorder.audio.section.description")
    }

    // Audio Source
    NComboBox {
      label: I18n.tr("settings.screen-recorder.audio.audio-source.label")
      description: I18n.tr("settings.screen-recorder.audio.audio-source.description")
      model: [{
          "key": "default_output",
          "name": I18n.tr("options.screen-recording.audio-sources.system-output")
        }, {
          "key": "default_input",
          "name": I18n.tr("options.screen-recording.audio-sources.microphone-input")
        }, {
          "key": "both",
          "name": I18n.tr("options.screen-recording.audio-sources.both")
        }]
      currentKey: Settings.data.screenRecorder.audioSource
      onSelected: key => Settings.data.screenRecorder.audioSource = key
    }

    // Audio Codec
    NComboBox {
      label: I18n.tr("settings.screen-recorder.audio.audio-codec.label")
      description: I18n.tr("settings.screen-recorder.audio.audio-codec.description")
      model: [{
          "key": "opus",
          "name": "Opus"
        }, {
          "key": "aac",
          "name": "AAC"
        }]
      currentKey: Settings.data.screenRecorder.audioCodec
      onSelected: key => Settings.data.screenRecorder.audioCodec = key
    }
  }

  NFilePicker {
    id: folderPicker
    selectionMode: "folders"
    title: I18n.tr("settings.screen-recorder.general.select-output-folder")
    initialPath: Settings.data.screenRecorder.directory || Quickshell.env("HOME") + "/Videos"
    onAccepted: paths => {
                  if (paths.length > 0) {
                    Settings.data.screenRecorder.directory = paths[0] // Use first selected file
                  }
                }
  }
}
