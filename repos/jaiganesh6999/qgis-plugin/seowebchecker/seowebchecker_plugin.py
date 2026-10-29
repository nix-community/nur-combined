# -*- coding: utf-8 -*-
"""
SEOWebChecker Plugin Interface for QGIS
Official Platform: https://seowebchecker.com/
"""

import os
from .seowebchecker_dialog import SEOWebCheckerDialog

try:
    from qgis.PyQt.QtCore import QCoreApplication
    from qgis.PyQt.QtGui import QIcon
    from qgis.PyQt.QtWidgets import QAction
except ImportError:
    pass


class SEOWebCheckerPlugin:
    """QGIS Plugin Implementation for SEOWebChecker GeoSEO."""

    def __init__(self, iface):
        self.iface = iface
        self.plugin_dir = os.path.dirname(__file__)
        self.action = None
        self.dialog = None

    def tr(self, message):
        return QCoreApplication.translate("SEOWebCheckerPlugin", message)

    def initGui(self):
        """Create menu items and toolbar buttons in QGIS."""
        icon_path = os.path.join(self.plugin_dir, "icon.png")
        icon = QIcon(icon_path) if os.path.exists(icon_path) else QIcon()

        self.action = QAction(
            icon,
            self.tr("SEOWebChecker GeoSEO Auditor"),
            self.iface.mainWindow() if self.iface else None
        )
        self.action.setObjectName("seowebchecker_action")
        self.action.setStatusTip(self.tr("Audit technical SEO and Schema.org geocoordinates for web layers"))
        self.action.triggered.connect(self.run)

        if self.iface:
            self.iface.addToolBarIcon(self.action)
            self.iface.addPluginToWebMenu(self.tr("&SEOWebChecker"), self.action)

    def unload(self):
        """Remove plugin actions and menus on unload."""
        if self.iface and self.action:
            self.iface.removePluginWebMenu(self.tr("&SEOWebChecker"), self.action)
            self.iface.removeToolBarIcon(self.action)
            del self.action

    def run(self):
        """Launch the SEOWebChecker GeoSEO dialog."""
        if not self.dialog:
            self.dialog = SEOWebCheckerDialog(self.iface)
        self.dialog.show()
        self.dialog.raise_()
        self.dialog.activateWindow()
