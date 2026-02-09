import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    layerNamespacePlugin: "ccusage"

    // Session data (5-hour billing window)
    property bool hasData: false
    property int sessionPercent: 0
    property string sessionReset: ""

    // Weekly data
    property int weekAllPercent: 0
    property int weekSonnetPercent: 0
    property string weekReset: ""

    property string errorMessage: ""

    // Accent color based on session usage
    property color statusColor: {
        if (!hasData) return Theme.surfaceVariantText
        if (sessionPercent >= 90) return Theme.error
        if (sessionPercent >= 70) return "#FFA726"
        return Theme.primary
    }

    property string displayText: {
        if (errorMessage !== "") return "err"
        if (!hasData) return "--"
        return sessionPercent + "%"
    }

    // Refresh timer (every 2 minutes since it spawns a claude process)
    Timer {
        id: refreshTimer
        interval: 120000
        running: true
        repeat: true
        onTriggered: fetchData()
    }

    Component.onCompleted: fetchData()

    function fetchData() {
        usageProcess.running = true
    }

    Process {
        id: usageProcess
        command: ["@ccusage-usage@"]

        property string outputBuffer: ""

        stdout: SplitParser {
            onRead: line => {
                usageProcess.outputBuffer += line
            }
        }

        stderr: SplitParser {
            onRead: line => {
                if (line.trim()) {
                    console.warn("ccusage-usage stderr:", line)
                }
            }
        }

        onStarted: {
            console.info("ccusage-usage: process started")
            usageProcess.outputBuffer = ""
        }

        onExited: (exitCode, exitStatus) => {
            console.info("ccusage-usage: process exited with code " + exitCode)
            if (exitCode !== 0) {
                root.errorMessage = "exit " + exitCode
                root.hasData = false
                return
            }

            console.info("ccusage-usage: raw output: " + usageProcess.outputBuffer.trim())
            root.errorMessage = ""
            parseOutput(usageProcess.outputBuffer.trim())
        }
    }

    function parseOutput(jsonStr) {
        try {
            var data = JSON.parse(jsonStr)

            root.sessionPercent = data.session.percentUsed || 0
            root.sessionReset = data.session.resetsAt || ""

            root.weekAllPercent = data.weekAll.percentUsed || 0
            root.weekSonnetPercent = data.weekSonnet.percentUsed || 0
            root.weekReset = data.weekAll.resetsAt || ""

            root.hasData = true
            console.info("ccusage-usage: parsed session=" + root.sessionPercent + "% weekAll=" + root.weekAllPercent + "% weekSonnet=" + root.weekSonnetPercent + "%")
        } catch (e) {
            console.error("ccusage-usage JSON parse error:", e)
            root.errorMessage = "parse"
            root.hasData = false
        }
    }

    // Helper component for label-value rows
    component InfoRow: Item {
        id: infoRow
        property string label: ""
        property string value: ""
        property color valueColor: Theme.surfaceText
        property int valueFontWeight: Font.Normal

        width: parent.width
        height: Math.max(rowLabel.height, rowValue.height)

        StyledText {
            id: rowLabel
            text: infoRow.label
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.surfaceVariantText
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
        }

        StyledText {
            id: rowValue
            text: infoRow.value
            font.pixelSize: Theme.fontSizeSmall
            color: infoRow.valueColor
            font.weight: infoRow.valueFontWeight
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // Horizontal bar pill
    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingS

            DankIcon {
                name: "monitoring"
                size: root.iconSize
                color: root.statusColor
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                text: root.displayText
                font.pixelSize: Theme.fontSizeMedium
                color: root.statusColor
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    // Vertical bar pill
    verticalBarPill: Component {
        Column {
            spacing: Theme.spacingXS

            DankIcon {
                name: "monitoring"
                size: root.iconSize
                color: root.statusColor
                anchors.horizontalCenter: parent.horizontalCenter
            }

            StyledText {
                text: root.displayText
                font.pixelSize: Theme.fontSizeSmall
                color: root.statusColor
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    // Popout with detailed info
    popoutContent: Component {
        PopoutComponent {
            id: popout
            headerText: "Claude Code Usage"
            detailsText: root.hasData ? "" : "No data available"
            showCloseButton: true

            Column {
                width: parent.width
                spacing: Theme.spacingL

                // Session (5h window)
                Column {
                    width: parent.width
                    spacing: Theme.spacingXS
                    visible: root.hasData

                    StyledText {
                        text: "Current Session"
                        font.pixelSize: Theme.fontSizeSmall
                        font.weight: Font.Bold
                        color: Theme.surfaceText
                    }

                    InfoRow {
                        label: "Usage"
                        value: root.sessionPercent + "%"
                        valueColor: root.statusColor
                        valueFontWeight: Font.Medium
                    }

                    Rectangle {
                        width: parent.width
                        height: 6
                        radius: 3
                        color: Theme.surfaceContainerHighest

                        Rectangle {
                            width: Math.min(parent.width, parent.width * root.sessionPercent / 100)
                            height: parent.height
                            radius: parent.radius
                            color: root.statusColor
                        }
                    }

                    InfoRow {
                        label: "Resets at"
                        value: root.sessionReset
                    }
                }

                // Week (all models)
                Column {
                    width: parent.width
                    spacing: Theme.spacingXS
                    visible: root.hasData

                    StyledText {
                        text: "This Week (All Models)"
                        font.pixelSize: Theme.fontSizeSmall
                        font.weight: Font.Bold
                        color: Theme.surfaceText
                    }

                    InfoRow {
                        label: "Usage"
                        value: root.weekAllPercent + "%"
                        valueFontWeight: Font.Medium
                    }

                    Rectangle {
                        width: parent.width
                        height: 6
                        radius: 3
                        color: Theme.surfaceContainerHighest

                        Rectangle {
                            width: Math.min(parent.width, parent.width * root.weekAllPercent / 100)
                            height: parent.height
                            radius: parent.radius
                            color: Theme.primary
                        }
                    }
                }

                // Week (Sonnet only)
                Column {
                    width: parent.width
                    spacing: Theme.spacingXS
                    visible: root.hasData

                    StyledText {
                        text: "This Week (Sonnet)"
                        font.pixelSize: Theme.fontSizeSmall
                        font.weight: Font.Bold
                        color: Theme.surfaceText
                    }

                    InfoRow {
                        label: "Usage"
                        value: root.weekSonnetPercent + "%"
                        valueFontWeight: Font.Medium
                    }

                    Rectangle {
                        width: parent.width
                        height: 6
                        radius: 3
                        color: Theme.surfaceContainerHighest

                        Rectangle {
                            width: Math.min(parent.width, parent.width * root.weekSonnetPercent / 100)
                            height: parent.height
                            radius: parent.radius
                            color: Theme.primary
                        }
                    }

                    InfoRow {
                        label: "Resets at"
                        value: root.weekReset
                    }
                }

                // No data message
                StyledText {
                    width: parent.width
                    visible: !root.hasData
                    text: "No usage data available. Make sure Claude Code is installed."
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                    wrapMode: Text.WordWrap
                }
            }
        }
    }

    popoutWidth: 320
    popoutHeight: 380
}
