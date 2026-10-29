import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

Item {
    id: fullRoot

    implicitWidth: 420
    implicitHeight: 560

    property string filterSeverity: "all" // "all", "error", "warning", "pass"

    readonly property var currentScore: root.currentReport && root.currentReport.score ? root.currentReport.score : null
    readonly property var currentStats: root.currentReport && root.currentReport.stats ? root.currentReport.stats : null
    readonly property var currentIssues: root.currentReport && root.currentReport.issues ? root.currentReport.issues : []

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        // 1. Header Area
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Kirigami.Icon {
                source: "view-web-browser-dom-tree"
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Kirigami.Heading {
                    level: 3
                    text: i18n("SEOWebChecker")
                    font.bold: true
                }

                Text {
                    text: i18n("On-Page Technical SEO & Health")
                    color: Kirigami.Theme.disabledTextColor
                    font.pixelSize: 11
                }
            }

            QQC2.ToolButton {
                icon.name: "view-refresh"
                text: i18n("Refresh")
                enabled: !root.isBusy
                onClicked: {
                    root.runAudit(urlInputField.text);
                }
            }
        }

        // 2. URL Input Bar
        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            QQC2.TextField {
                id: urlInputField
                Layout.fillWidth: true
                text: root.activeUrl
                placeholderText: "https://example.com"
                selectByMouse: true
                onAccepted: {
                    root.runAudit(text);
                }
            }

            QQC2.Button {
                id: auditBtn
                text: root.isBusy ? i18n("Auditing...") : i18n("Audit")
                icon.name: "system-search"
                enabled: !root.isBusy && urlInputField.text.trim().length > 0
                onClicked: {
                    root.runAudit(urlInputField.text);
                }
            }
        }

        // 3. Busy State / Error State
        QQC2.ProgressBar {
            Layout.fillWidth: true
            indeterminate: true
            visible: root.isBusy
        }

        Rectangle {
            Layout.fillWidth: true
            height: 36
            radius: 4
            color: "#fcf0f1"
            border.color: "#c0392b"
            visible: root.errorMessage !== "" && !root.isBusy

            RowLayout {
                anchors.fill: parent
                anchors.margins: 6
                spacing: 6

                Kirigami.Icon {
                    source: "dialog-error"
                    color: "#c0392b"
                    Layout.preferredWidth: 18
                    Layout.preferredHeight: 18
                }

                Text {
                    Layout.fillWidth: true
                    text: root.errorMessage
                    color: "#c0392b"
                    font.pixelSize: 11
                    elide: Text.ElideRight
                }
            }
        }

        // 4. Score & Stats Overview Card
        Rectangle {
            Layout.fillWidth: true
            height: 80
            radius: 6
            color: Kirigami.Theme.backgroundColor
            border.color: Kirigami.Theme.separatorColor
            border.width: 1
            visible: root.currentReport !== null

            RowLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 12

                // Score Circle
                Rectangle {
                    Layout.preferredWidth: 64
                    Layout.preferredHeight: 64
                    radius: 32
                    color: fullRoot.currentScore ? root.getGradeColor(fullRoot.currentScore.grade) : "#7f8c8d"

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 0

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: fullRoot.currentScore ? fullRoot.currentScore.overall : "--"
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 18
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: fullRoot.currentScore ? fullRoot.currentScore.grade : "-"
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 11
                        }
                    }
                }

                // Stats breakdown
                GridLayout {
                    Layout.fillWidth: true
                    columns: 3
                    rowSpacing: 4
                    columnSpacing: 8

                    ColumnLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 2
                        Text {
                            text: fullRoot.currentStats ? fullRoot.currentStats.passed : "0"
                            color: "#27ae60"
                            font.bold: true
                            font.pixelSize: 16
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Text {
                            text: i18n("Passed")
                            color: Kirigami.Theme.disabledTextColor
                            font.pixelSize: 10
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    ColumnLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 2
                        Text {
                            text: fullRoot.currentStats ? fullRoot.currentStats.warnings : "0"
                            color: "#f39c12"
                            font.bold: true
                            font.pixelSize: 16
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Text {
                            text: i18n("Warnings")
                            color: Kirigami.Theme.disabledTextColor
                            font.pixelSize: 10
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    ColumnLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 2
                        Text {
                            text: fullRoot.currentStats ? fullRoot.currentStats.errors : "0"
                            color: "#c0392b"
                            font.bold: true
                            font.pixelSize: 16
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Text {
                            text: i18n("Errors")
                            color: Kirigami.Theme.disabledTextColor
                            font.pixelSize: 10
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }
            }
        }

        // 5. Filter Row
        RowLayout {
            Layout.fillWidth: true
            spacing: 4
            visible: root.currentReport !== null

            QQC2.Button {
                text: i18n("All (%1)", fullRoot.currentStats ? fullRoot.currentStats.total : 0)
                font.pixelSize: 10
                highlighted: fullRoot.filterSeverity === "all"
                onClicked: fullRoot.filterSeverity = "all"
            }

            QQC2.Button {
                text: i18n("Errors (%1)", fullRoot.currentStats ? fullRoot.currentStats.errors : 0)
                font.pixelSize: 10
                highlighted: fullRoot.filterSeverity === "error"
                onClicked: fullRoot.filterSeverity = "error"
            }

            QQC2.Button {
                text: i18n("Warnings (%1)", fullRoot.currentStats ? fullRoot.currentStats.warnings : 0)
                font.pixelSize: 10
                highlighted: fullRoot.filterSeverity === "warning"
                onClicked: fullRoot.filterSeverity = "warning"
            }

            QQC2.Button {
                text: i18n("Passed (%1)", fullRoot.currentStats ? fullRoot.currentStats.passed : 0)
                font.pixelSize: 10
                highlighted: fullRoot.filterSeverity === "pass"
                onClicked: fullRoot.filterSeverity = "pass"
            }
        }

        // 6. Issues ScrollView & ListView
        QQC2.ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ListView {
                id: issuesListView
                model: {
                    if (!fullRoot.currentIssues || fullRoot.currentIssues.length === 0) return [];
                    if (fullRoot.filterSeverity === "all") return fullRoot.currentIssues;
                    return fullRoot.currentIssues.filter(function(i) {
                        return i.severity === fullRoot.filterSeverity;
                    });
                }
                spacing: 6

                delegate: Rectangle {
                    width: ListView.view.width
                    implicitHeight: itemCol.implicitHeight + 14
                    radius: 4
                    color: Kirigami.Theme.backgroundColor
                    border.color: Kirigami.Theme.separatorColor
                    border.width: 1

                    // Left severity accent bar
                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: 4
                        radius: 2
                        color: {
                            if (modelData.severity === 'pass') return "#27ae60";
                            if (modelData.severity === 'warning') return "#f39c12";
                            return "#c0392b";
                        }
                    }

                    ColumnLayout {
                        id: itemCol
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.leftMargin: 12
                        anchors.rightMargin: 8
                        anchors.topMargin: 7
                        spacing: 3

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                Layout.fillWidth: true
                                text: modelData.title || ""
                                font.bold: true
                                font.pixelSize: 12
                                color: Kirigami.Theme.textColor
                            }

                            Rectangle {
                                width: badgeText.contentWidth + 8
                                height: 16
                                radius: 3
                                color: {
                                    if (modelData.severity === 'pass') return "#e8f8f0";
                                    if (modelData.severity === 'warning') return "#fef5e7";
                                    return "#fadbd8";
                                }

                                Text {
                                    id: badgeText
                                    anchors.centerIn: parent
                                    text: (modelData.severity || "").toUpperCase()
                                    font.pixelSize: 9
                                    font.bold: true
                                    color: {
                                        if (modelData.severity === 'pass') return "#27ae60";
                                        if (modelData.severity === 'warning') return "#f39c12";
                                        return "#c0392b";
                                    }
                                }
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: modelData.message || ""
                            font.pixelSize: 11
                            color: Kirigami.Theme.disabledTextColor
                            wrapMode: Text.WordWrap
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: recText.implicitHeight + 8
                            radius: 3
                            color: Kirigami.Theme.alternateBackgroundColor
                            visible: modelData.recommendation !== undefined && modelData.recommendation !== ""

                            Text {
                                id: recText
                                anchors.fill: parent
                                anchors.margins: 4
                                text: i18n("Recommendation: %1", modelData.recommendation || "")
                                font.pixelSize: 10
                                color: Kirigami.Theme.textColor
                                wrapMode: Text.WordWrap
                            }
                        }
                    }
                }

                // Empty state
                Text {
                    anchors.centerIn: parent
                    visible: issuesListView.count === 0 && !root.isBusy
                    text: root.currentReport ? i18n("No checks match the selected filter.") : i18n("Enter a URL and click Audit to begin.")
                    color: Kirigami.Theme.disabledTextColor
                    font.pixelSize: 12
                }
            }
        }

        // 7. Footer Action Bar
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            QQC2.Button {
                text: i18n("Copy Report")
                icon.name: "edit-copy"
                enabled: root.currentReport !== null
                onClicked: {
                    if (!root.currentReport) return;
                    let text = "SEO Audit Report: " + root.currentReport.url + "\n";
                    text += "Overall Score: " + root.currentReport.score.overall + "/100 (" + root.currentReport.score.grade + ")\n";
                    text += "Passed: " + root.currentReport.stats.passed + " | Warnings: " + root.currentReport.stats.warnings + " | Errors: " + root.currentReport.stats.errors + "\n\n";
                    if (root.currentReport.issues) {
                        root.currentReport.issues.forEach(function(i) {
                            text += "[" + i.severity.toUpperCase() + "] " + i.title + ": " + i.message + "\n";
                        });
                    }
                    text += "\nGenerated via SEOWebChecker KDE Widget (https://seowebchecker.com/)\n";
                    // Copy to clipboard
                    clipboardHelper.copy(text);
                }
            }

            Item { Layout.fillWidth: true }

            QQC2.Button {
                text: i18n("SEOWebChecker.com")
                icon.name: "internet-web-browser"
                onClicked: {
                    Qt.openUrlExternally("https://seowebchecker.com/");
                }
            }
        }
    }

    // Hidden TextInput for clipboard copying in pure QML
    QQC2.TextField {
        id: clipboardHelper
        visible: false
        function copy(str) {
            text = str;
            selectAll();
            copy();
        }
    }
}
