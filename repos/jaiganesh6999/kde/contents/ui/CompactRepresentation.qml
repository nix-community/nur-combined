import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

Item {
    id: compactRoot

    readonly property string grade: root.currentReport && root.currentReport.score ? root.currentReport.score.grade : "-"
    readonly property int score: root.currentReport && root.currentReport.score ? root.currentReport.score.overall : 0
    readonly property color gradeColor: root.getGradeColor(grade)

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            Plasmoid.expanded = !Plasmoid.expanded;
        }
    }

    Item {
        anchors.centerIn: parent
        width: Math.min(parent.width, parent.height) - 4
        height: width

        Kirigami.Icon {
            id: mainIcon
            anchors.fill: parent
            source: "view-web-browser-dom-tree"
            active: mouseArea.containsMouse || root.isBusy
        }

        // Busy Spinner
        Rectangle {
            id: busyOverlay
            anchors.fill: parent
            color: "transparent"
            visible: root.isBusy

            RotationAnimator {
                target: mainIcon
                from: 0
                to: 360
                duration: 1200
                loops: Animation.Infinite
                running: root.isBusy
            }
        }

        // Letter Grade Badge
        Rectangle {
            id: badge
            visible: Plasmoid.configuration.showCompactGrade && !root.isBusy && root.currentReport !== null
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            width: Math.max(16, gradeText.contentWidth + 6)
            height: 14
            radius: 7
            color: compactRoot.gradeColor
            border.width: 1
            border.color: "#ffffff"

            Text {
                id: gradeText
                anchors.centerIn: parent
                text: compactRoot.grade
                color: "#ffffff"
                font.bold: true
                font.pixelSize: 9
            }
        }
    }

    // Plasma ToolTip
    Plasmoid.toolTipMainText: i18n("SEOWebChecker: %1", root.activeUrl)
    Plasmoid.toolTipSubText: root.currentReport
        ? i18n("Score: %1/100 (Grade: %2)\nPassed: %3 | Warnings: %4 | Errors: %5",
               root.currentReport.score.overall,
               root.currentReport.score.grade,
               root.currentReport.stats.passed,
               root.currentReport.stats.warnings,
               root.currentReport.stats.errors)
        : (root.isBusy ? i18n("Analyzing on-page SEO factors...") : i18n("Click to run SEO diagnostics"))
}
