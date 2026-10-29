import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import "../code/seoengine.js" as SeoEngine

PlasmoidItem {
    id: root

    // Widget Dimensions
    preferredRepresentation: Plasmoid.formFactor === PlasmaCore.Types.Planar ? fullRep : compactRep
    width: Plasmoid.formFactor === PlasmaCore.Types.Planar ? 420 : 48
    height: Plasmoid.formFactor === PlasmaCore.Types.Planar ? 520 : 48

    // State Variables
    property bool isBusy: false
    property var currentReport: null
    property string activeUrl: Plasmoid.configuration.targetUrl || "https://seowebchecker.com/"
    property string errorMessage: ""

    // Representations
    compactRepresentation: CompactRepresentation { id: compactRep }
    fullRepresentation: FullRepresentation { id: fullRep }

    // Auto-refresh timer
    Timer {
        id: refreshTimer
        interval: Math.max(1, Plasmoid.configuration.refreshInterval) * 60000
        running: Plasmoid.configuration.autoRefresh && !root.isBusy
        repeat: true
        onTriggered: {
            root.runAudit(root.activeUrl);
        }
    }

    Component.onCompleted: {
        // Initial audit on startup
        root.runAudit(root.activeUrl);
    }

    function runAudit(url) {
        if (!url) return;
        root.isBusy = true;
        root.errorMessage = "";

        SeoEngine.auditUrl(url, function (err, report) {
            root.isBusy = false;
            if (err) {
                root.errorMessage = err;
            } else if (report) {
                root.currentReport = report;
                root.activeUrl = report.url || url;
            }
        });
    }

    function getGradeColor(grade) {
        switch (grade) {
            case 'A+':
            case 'A':
                return "#27ae60"; // Breeze positive green
            case 'B':
                return "#2980b9"; // Breeze primary blue
            case 'C':
                return "#f39c12"; // Breeze warning orange
            case 'D':
                return "#d35400"; // Breeze danger amber
            case 'F':
            default:
                return "#c0392b"; // Breeze critical red
        }
    }
}
