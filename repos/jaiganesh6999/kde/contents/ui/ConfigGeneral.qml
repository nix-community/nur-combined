import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: configPage

    property alias cfg_targetUrl: targetUrlField.text
    property alias cfg_autoRefresh: autoRefreshBox.checked
    property alias cfg_refreshInterval: refreshIntervalSpin.value
    property alias cfg_showCompactGrade: showGradeBox.checked

    QQC2.TextField {
        id: targetUrlField
        Kirigami.FormData.label: i18n("Default Target URL:")
        placeholderText: "https://seowebchecker.com/"
        Layout.fillWidth: true
    }

    QQC2.CheckBox {
        id: autoRefreshBox
        Kirigami.FormData.label: i18n("Automatic Refresh:")
        text: i18n("Periodically re-audit target webpage")
    }

    QQC2.SpinBox {
        id: refreshIntervalSpin
        Kirigami.FormData.label: i18n("Refresh Interval:")
        from: 5
        to: 1440
        stepSize: 15
        enabled: autoRefreshBox.checked
        textFromValue: function(value, locale) {
            return i18n("%1 minutes", value);
        }
    }

    QQC2.CheckBox {
        id: showGradeBox
        Kirigami.FormData.label: i18n("Panel Display:")
        text: i18n("Show letter grade badge in compact panel view")
    }
}
