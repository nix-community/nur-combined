# -*- coding: utf-8 -*-
"""
SEOWebChecker 3D Web Optimizer & SEO Auditor
Blender Extension for Web3D SEO, Google 3D Search optimization, and Schema.org 3DModel generation.

Official Platform: https://seowebchecker.com/
"""

bl_info = {
    "name": "SEOWebChecker 3D Web Optimizer & SEO Auditor",
    "author": "SEOWebChecker",
    "version": (1, 0, 0),
    "blender": (4, 2, 0),
    "location": "View3D > Sidebar > SEOWebChecker",
    "description": "Audit 3D models for Web3D SEO, inspect Google 3D search readiness, and generate Schema.org 3DModel structured data",
    "category": "Import-Export",
    "doc_url": "https://seowebchecker.com/",
    "tracker_url": "https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk/issues",
}

from . import ui


def register():
    ui.register()


def unregister():
    ui.unregister()


if __name__ == "__main__":
    register()
