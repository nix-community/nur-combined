# -*- coding: utf-8 -*-
"""
SEOWebChecker GeoSEO Dialog Window for QGIS
Official Platform: https://seowebchecker.com/
"""

import json
from .seowebchecker_core import GeoSeoAuditor

try:
    from qgis.PyQt.QtCore import Qt, QVariant
    from qgis.PyQt.QtWidgets import (
        QDialog, QVBoxLayout, QHBoxLayout, QLabel, QLineEdit,
        QPushButton, QTextEdit, QTabWidget, QWidget, QComboBox,
        QSpinBox, QProgressBar, QMessageBox, QGroupBox, QFormLayout
    )
    from qgis.PyQt.QtGui import QColor, QFont
    from qgis.core import (
        QgsProject, QgsVectorLayer, QgsField, QgsFeature,
        QgsGeometry, QgsPointXY
    )
except ImportError:
    # Standalone mock fallback for unit testing outside QGIS environment
    QDialog = object


class SEOWebCheckerDialog(QDialog):
    """Interactive GUI dialog for single-URL and batch layer GeoSEO audits."""

    def __init__(self, iface=None, parent=None):
        super(SEOWebCheckerDialog, self).__init__(parent)
        self.iface = iface
        self.auditor = GeoSeoAuditor()
        self.current_result = None

        self.setWindowTitle("SEOWebChecker — GeoSEO & Spatial Web Auditor")
        self.resize(650, 520)
        self.setup_ui()

    def setup_ui(self):
        main_layout = QVBoxLayout(self)

        # Header Banner
        header = QLabel("<h2>SEOWebChecker GeoSEO Auditor</h2>")
        header.setAlignment(Qt.AlignCenter)
        main_layout.addWidget(header)

        sub_header = QLabel('<p align="center">Technical SEO audits, Schema.org GeoCoordinates, and spatial layer mapping • <a href="https://seowebchecker.com/">seowebchecker.com</a></p>')
        sub_header.setOpenExternalLinks(True)
        main_layout.addWidget(sub_header)

        # Tab Widget
        self.tabs = QTabWidget()
        main_layout.addWidget(self.tabs)

        # --- Tab 1: Single URL Audit ---
        tab_single = QWidget()
        single_layout = QVBoxLayout(tab_single)

        input_group = QGroupBox("Target Website")
        input_form = QFormLayout(input_group)
        self.url_input = QLineEdit("https://seowebchecker.com/")
        input_form.addRow("URL:", self.url_input)

        self.btn_audit = QPushButton("🔍 Run SEO Audit")
        self.btn_audit.clicked.connect(self.on_audit_clicked)
        input_form.addRow("", self.btn_audit)
        single_layout.addWidget(input_group)

        # Results Display
        self.results_group = QGroupBox("Audit Diagnostics & Geo Coordinates")
        res_layout = QVBoxLayout(self.results_group)
        self.result_display = QTextEdit()
        self.result_display.setReadOnly(True)
        self.result_display.setPlaceholderText("Audit results, on-page score, and Schema.org GeoCoordinates will appear here...")
        res_layout.addWidget(self.result_display)

        # Action Buttons
        btn_box = QHBoxLayout()
        self.btn_add_layer = QPushButton("📍 Add Spatial Point to QGIS Map")
        self.btn_add_layer.setEnabled(False)
        self.btn_add_layer.clicked.connect(self.on_add_to_map)
        btn_box.addWidget(self.btn_add_layer)

        single_layout.addWidget(self.results_group)
        single_layout.addLayout(btn_box)
        self.tabs.addTab(tab_single, "Single URL Audit")

        # --- Tab 2: Batch Layer Audit ---
        tab_batch = QWidget()
        batch_layout = QVBoxLayout(tab_batch)

        batch_group = QGroupBox("Spatial Layer Batch Audit")
        batch_form = QFormLayout(batch_group)

        self.layer_combo = QComboBox()
        self.populate_layers()
        batch_form.addRow("Select Vector Layer:", self.layer_combo)

        self.url_field_combo = QComboBox()
        self.layer_combo.currentIndexChanged.connect(self.populate_fields)
        self.populate_fields()
        batch_form.addRow("URL Attribute Field:", self.url_field_combo)

        self.threshold_spin = QSpinBox()
        self.threshold_spin.setRange(50, 100)
        self.threshold_spin.setValue(85)
        batch_form.addRow("Alert Threshold:", self.threshold_spin)

        self.btn_batch = QPushButton("⚡ Audit Layer Features & Enrich Table")
        self.btn_batch.clicked.connect(self.on_batch_audit)
        batch_form.addRow("", self.btn_batch)
        batch_layout.addWidget(batch_group)

        self.progress_bar = QProgressBar()
        self.progress_bar.setValue(0)
        batch_layout.addWidget(self.progress_bar)

        self.batch_log = QTextEdit()
        self.batch_log.setReadOnly(True)
        batch_layout.addWidget(self.batch_log)

        self.tabs.addTab(tab_batch, "Batch Layer Audit")

        # Footer
        footer = QLabel('<small>Powered by <a href="https://seowebchecker.com/">SEOWebChecker</a> • Enterprise Technical SEO Platform</small>')
        footer.setAlignment(Qt.AlignCenter)
        footer.setOpenExternalLinks(True)
        main_layout.addWidget(footer)

    def populate_layers(self):
        self.layer_combo.clear()
        try:
            for layer in QgsProject.instance().mapLayers().values():
                if isinstance(layer, QgsVectorLayer):
                    self.layer_combo.addItem(layer.name(), layer)
        except (AttributeError, RuntimeError, TypeError):
            pass

    def populate_fields(self):
        self.url_field_combo.clear()
        layer = self.layer_combo.currentData()
        if layer and hasattr(layer, "fields"):
            for field in layer.fields():
                self.url_field_combo.addItem(field.name())

    def on_audit_clicked(self):
        url = self.url_input.text().strip()
        if not url:
            QMessageBox.warning(self, "Input Error", "Please provide a valid website URL.")
            return

        self.btn_audit.setEnabled(False)
        self.btn_audit.setText("Auditing...")
        self.result_display.setPlainText("Fetching and auditing %s..." % url)

        try:
            res = self.auditor.audit(url)
            self.current_result = res

            if res.get("failed"):
                self.result_display.setPlainText("Audit Failed: %s" % res.get("error"))
                self.btn_add_layer.setEnabled(False)
                return

            text = []
            text.append("==================================================")
            text.append("  SEOWebChecker Technical SEO Audit Report")
            text.append("  Official Site: https://seowebchecker.com/")
            text.append("==================================================")
            text.append(f"Target URL   : {res['url']}")
            text.append(f"Health Score : {res['score']} / 100 ({res['grade']}) — Status: {res['status']}")
            text.append(f"Title Tag    : {res['title'] or '[Missing]'} ({res['title_length']} chars)")
            text.append(f"Meta Desc    : {res['meta_description'] or '[Missing]'} ({res['meta_description_length']} chars)")
            text.append(f"Viewport     : {'Configured' if res['has_viewport'] else 'Missing'}")
            text.append(f"Canonical    : {res['canonical_url'] if res['has_canonical'] else 'Missing'}")
            text.append(f"HTTPS        : {'Secure' if res['is_https'] else 'Insecure'}")
            text.append(f"Word Count   : {res['word_count']} words")
            text.append(f"Response     : {res['response_time_ms']} ms")
            text.append("--------------------------------------------------")
            if res.get("has_geo"):
                text.append(f"Spatial Coordinates : Latitude {res['latitude']}, Longitude {res['longitude']}")
                if res.get("business_name"):
                    text.append(f"Schema Business Name: {res['business_name']}")
                if res.get("address"):
                    text.append(f"Schema Address      : {res['address']}")
                self.btn_add_layer.setEnabled(True)
            else:
                text.append("Spatial Coordinates : No Schema.org GeoCoordinates detected.")
                self.btn_add_layer.setEnabled(False)

            text.append(f"Passed Checks: {res['passes_count']} checks")
            text.append(f"Issues Found : {res['issues_count']} items")
            if res["issues"]:
                text.append("\nIssues to Fix:")
                for i in res["issues"]:
                    tag = "[ERROR]" if i["severity"] == "error" else "[WARN] "
                    text.append(f"  {tag} {i['title']}: {i['message']}")
                    text.append(f"         Fix: {i['recommendation']}")

            self.result_display.setPlainText("\n".join(text))
        finally:
            self.btn_audit.setEnabled(True)
            self.btn_audit.setText("🔍 Run SEO Audit")

    def on_add_to_map(self):
        if not self.current_result or not self.current_result.get("has_geo"):
            QMessageBox.information(self, "No Coordinates", "Audit result does not contain geographic coordinates.")
            return

        lat = self.current_result["latitude"]
        lon = self.current_result["longitude"]

        layer_name = "SEOWebChecker_Audits"
        project = QgsProject.instance()
        target_layer = None

        for layer in project.mapLayers().values():
            if layer.name() == layer_name and isinstance(layer, QgsVectorLayer):
                target_layer = layer
                break

        if not target_layer:
            target_layer = QgsVectorLayer("Point?crs=EPSG:4326", layer_name, "memory")
            prov = target_layer.dataProvider()
            prov.addAttributes([
                QgsField("URL", QVariant.String),
                QgsField("SEO_Score", QVariant.Int),
                QgsField("SEO_Grade", QVariant.String),
                QgsField("SEO_Status", QVariant.String),
                QgsField("Title", QVariant.String),
                QgsField("Address", QVariant.String),
                QgsField("Platform", QVariant.String),
            ])
            target_layer.updateFields()
            project.addMapLayer(target_layer)

        feat = QgsFeature(target_layer.fields())
        feat.setGeometry(QgsGeometry.fromPointXY(QgsPointXY(lon, lat)))
        feat.setAttributes([
            self.current_result["url"],
            self.current_result["score"],
            self.current_result["grade"],
            self.current_result["status"],
            self.current_result["title"],
            self.current_result.get("address", ""),
            "https://seowebchecker.com/",
        ])

        target_layer.dataProvider().addFeatures([feat])
        target_layer.updateExtents()
        if self.iface:
            self.iface.mapCanvas().refresh()

        QMessageBox.information(self, "Success", f"Point added to layer '{layer_name}' at ({lat}, {lon})!")

    def on_batch_audit(self):
        layer = self.layer_combo.currentData()
        url_field = self.url_field_combo.currentText()

        if not layer or not url_field:
            QMessageBox.warning(self, "Selection Error", "Please select a vector layer and URL field.")
            return

        field_names = [f.name() for f in layer.fields()]
        new_fields = []
        if "SEO_Score" not in field_names: new_fields.append(QgsField("SEO_Score", QVariant.Int))
        if "SEO_Grade" not in field_names: new_fields.append(QgsField("SEO_Grade", QVariant.String))
        if "SEO_Status" not in field_names: new_fields.append(QgsField("SEO_Status", QVariant.String))

        if new_fields:
            layer.dataProvider().addAttributes(new_fields)
            layer.updateFields()

        features = list(layer.getFeatures())
        total = len(features)
        if total == 0:
            QMessageBox.information(self, "Empty Layer", "No features found in the selected layer.")
            return

        self.btn_batch.setEnabled(False)
        self.progress_bar.setMaximum(total)
        self.progress_bar.setValue(0)
        self.batch_log.clear()

        updates = {}
        fields = layer.fields()
        score_idx = fields.indexFromName("SEO_Score")
        grade_idx = fields.indexFromName("SEO_Grade")
        status_idx = fields.indexFromName("SEO_Status")

        for idx, feat in enumerate(features):
            url_val = feat[url_field]
            if url_val:
                res = self.auditor.audit(str(url_val))
                if not res.get("failed"):
                    updates[feat.id()] = {
                        score_idx: res["score"],
                        grade_idx: res["grade"],
                        status_idx: res["status"],
                    }
                    self.batch_log.append(f"Feature {feat.id()} ({url_val}): Score {res['score']}/100 ({res['grade']})")
                else:
                    self.batch_log.append(f"Feature {feat.id()} ({url_val}): Failed ({res.get('error')})")

            self.progress_bar.setValue(idx + 1)

        layer.dataProvider().changeAttributeValues(updates)
        self.btn_batch.setEnabled(True)
        QMessageBox.information(self, "Batch Audit Complete", f"Successfully audited {len(updates)} of {total} features!")
