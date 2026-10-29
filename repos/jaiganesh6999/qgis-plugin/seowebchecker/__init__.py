# -*- coding: utf-8 -*-
"""
SEOWebChecker GeoSEO — QGIS Plugin
Official Platform: https://seowebchecker.com/
License: GPL-2.0-or-later
"""


def classFactory(iface):
    """Load SEOWebCheckerPlugin class from seowebchecker_plugin.

    :param iface: A QGIS interface instance.
    :type iface: QgsInterface
    """
    from .seowebchecker_plugin import SEOWebCheckerPlugin
    return SEOWebCheckerPlugin(iface)
