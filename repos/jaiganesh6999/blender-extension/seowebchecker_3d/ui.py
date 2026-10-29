# -*- coding: utf-8 -*-
"""
SEOWebChecker UI Panels & Operators for Blender 4.2+
Sidebar N-Panel interface under 'SEOWebChecker' tab in 3D Viewport.

Official Platform: https://seowebchecker.com/
"""

import os
import json
import bpy
from bpy.props import StringProperty, IntProperty, FloatProperty, BoolProperty, EnumProperty
from bpy.types import Panel, Operator

from .core import Web3DGeometryAuditor, Schema3DGenerator, LiveWebAuditor


class SEOWEBCHECKER_OT_audit_mesh(Operator):
    """Analyze active mesh geometry for Web3D SEO and Google 3D search performance"""
    bl_idname = "seowebchecker.audit_mesh"
    bl_label = "Audit 3D Mesh for Web SEO"
    bl_description = "Evaluates polygon count, draw calls, UV coordinates, and AR scale readiness"

    def execute(self, context):
        obj = context.active_object
        if not obj or obj.type != 'MESH':
            self.report({'WARNING'}, "Please select a 3D Mesh object to audit.")
            return {'CANCELLED'}

        mesh = obj.data
        name = obj.name
        polycount = len(mesh.polygons)
        vertcount = len(mesh.vertices)
        mat_count = len(obj.material_slots)
        has_uv = bool(mesh.uv_layers)

        # Scale check: Uniform scale (1.0, 1.0, 1.0)
        scale = obj.scale
        scale_applied = (
            abs(scale.x - 1.0) < 0.001 and
            abs(scale.y - 1.0) < 0.001 and
            abs(scale.z - 1.0) < 0.001
        )

        # Inspect textures
        textures = []
        for mat_slot in obj.material_slots:
            if mat_slot.material and mat_slot.material.use_nodes:
                for node in mat_slot.material.node_tree.nodes:
                    if node.type == 'TEX_IMAGE' and node.image:
                        img = node.image
                        textures.append({
                            "name": img.name,
                            "max_dim": max(img.size[0], img.size[1]) if len(img.size) >= 2 else 0
                        })

        auditor = Web3DGeometryAuditor(target_polycount=context.scene.seowebchecker_poly_target)
        res = auditor.audit_mesh_stats(
            name=name,
            polycount=polycount,
            vertcount=vertcount,
            material_count=mat_count,
            has_uv=has_uv,
            scale_applied=scale_applied,
            textures=textures
        )

        # Store in scene properties
        context.scene.seowebchecker_mesh_score = res["score"]
        context.scene.seowebchecker_mesh_grade = res["grade"]
        context.scene.seowebchecker_mesh_status = (
            f"Triangles: {polycount:,} | Materials: {mat_count} | UV: {'Yes' if has_uv else 'No'}"
        )

        msg = f"Audit Completed: Score {res['score']}/100 (Grade {res['grade']})"
        self.report({'INFO'}, msg)
        return {'FINISHED'}


class SEOWEBCHECKER_OT_generate_schema(Operator):
    """Generate Schema.org 3DModel and Product JSON-LD structured data"""
    bl_idname = "seowebchecker.generate_schema"
    bl_label = "Generate 3D Schema JSON-LD"
    bl_description = "Creates Google 3D search compliant JSON-LD structured data and copies to clipboard"

    def execute(self, context):
        sc = context.scene
        res = Schema3DGenerator.generate(
            name=sc.seowebchecker_model_name,
            description=sc.seowebchecker_model_desc,
            model_url=sc.seowebchecker_model_url,
            page_url=sc.seowebchecker_page_url,
            sku=sc.seowebchecker_sku,
            brand=sc.seowebchecker_brand,
            price=sc.seowebchecker_price,
            currency=sc.seowebchecker_currency,
        )

        # Copy to clipboard
        context.window_manager.clipboard = res["json_string"]
        sc.seowebchecker_generated_json = res["json_string"]

        self.report({'INFO'}, "Schema.org 3DModel JSON-LD copied to clipboard!")
        return {'FINISHED'}


class SEOWEBCHECKER_OT_audit_live_url(Operator):
    """Audit live web page for technical SEO and 3D web viewer integration"""
    bl_idname = "seowebchecker.audit_live_url"
    bl_label = "Audit Live Web Page"
    bl_description = "Inspects live webpage for <model-viewer>, meta tags, mobile viewport, and response speed"

    def execute(self, context):
        if hasattr(bpy.app, "online_access") and not bpy.app.online_access:
            self.report({'WARNING'}, "Online access is disabled in Blender Preferences > System.")
            return {'CANCELLED'}

        sc = context.scene
        url = sc.seowebchecker_live_url.strip()
        if not url:
            self.report({'WARNING'}, "Please enter a valid webpage URL.")
            return {'CANCELLED'}

        auditor = LiveWebAuditor()
        res = auditor.audit(url)

        if res.get("failed"):
            sc.seowebchecker_web_status = f"Failed: {res.get('error')}"
            self.report({'ERROR'}, f"Audit Failed: {res.get('error')}")
            return {'CANCELLED'}

        sc.seowebchecker_web_score = res["score"]
        sc.seowebchecker_web_grade = res["grade"]
        sc.seowebchecker_web_status = (
            f"Score: {res['score']}/100 ({res['grade']}) | 3D Viewer: {'Detected' if res['has_model_viewer'] else 'None'}"
        )

        self.report({'INFO'}, f"Web Page Audited: Score {res['score']}/100 ({res['grade']})")
        return {'FINISHED'}


class SEOWEBCHECKER_OT_open_platform(Operator):
    """Open SEOWebChecker in default web browser"""
    bl_idname = "seowebchecker.open_platform"
    bl_label = "Visit SEOWebChecker Platform"
    bl_description = "Opens https://seowebchecker.com/ in external browser"

    url: StringProperty(
        name="URL",
        default="https://seowebchecker.com/"
    )

    def execute(self, context):
        bpy.ops.wm.url_open(url=self.url)
        return {'FINISHED'}


class SEOWEBCHECKER_PT_main_panel(Panel):
    """Main SEOWebChecker Panel in 3D Viewport Sidebar"""
    bl_label = "SEOWebChecker 3D"
    bl_idname = "SEOWEBCHECKER_PT_main_panel"
    bl_space_type = 'VIEW_3D'
    bl_region_type = 'UI'
    bl_category = 'SEOWebChecker'

    def draw(self, context):
        layout = self.layout
        box = layout.box()
        box.label(text="3D Web & SEO Optimization", icon='WORLD')
        box.label(text="Enterprise Web3D & Google Search Suite")

        row = box.row()
        op = row.operator("seowebchecker.open_platform", text="SEOWebChecker Platform", icon='URL')
        op.url = "https://seowebchecker.com/"


class SEOWEBCHECKER_PT_mesh_panel(Panel):
    """Sub-panel for Mesh Geometry and Web Performance Audit"""
    bl_label = "3D Mesh Web Performance Audit"
    bl_idname = "SEOWEBCHECKER_PT_mesh_panel"
    bl_space_type = 'VIEW_3D'
    bl_region_type = 'UI'
    bl_category = 'SEOWebChecker'
    bl_parent_id = "SEOWEBCHECKER_PT_main_panel"

    def draw(self, context):
        layout = self.layout
        sc = context.scene

        col = layout.column(align=True)
        col.prop(sc, "seowebchecker_poly_target")

        obj = context.active_object
        if obj and obj.type == 'MESH':
            col.label(text=f"Selected: {obj.name}", icon='MESH_DATA')
        else:
            col.label(text="Select a Mesh Object in 3D View", icon='INFO')

        layout.operator("seowebchecker.audit_mesh", icon='CHECKMARK')

        if sc.seowebchecker_mesh_score >= 0:
            box = layout.box()
            row = box.row()
            row.label(text=f"Web SEO Score: {sc.seowebchecker_mesh_score}/100", icon='GRAPH')
            row.label(text=f"Grade: {sc.seowebchecker_mesh_grade}")
            box.label(text=sc.seowebchecker_mesh_status)


class SEOWEBCHECKER_PT_schema_panel(Panel):
    """Sub-panel for Schema.org 3DModel JSON-LD generation"""
    bl_label = "Schema.org 3DModel Generator"
    bl_idname = "SEOWEBCHECKER_PT_schema_panel"
    bl_space_type = 'VIEW_3D'
    bl_region_type = 'UI'
    bl_category = 'SEOWebChecker'
    bl_parent_id = "SEOWEBCHECKER_PT_main_panel"
    bl_options = {'DEFAULT_CLOSED'}

    def draw(self, context):
        layout = self.layout
        sc = context.scene

        col = layout.column(align=True)
        col.prop(sc, "seowebchecker_model_name")
        col.prop(sc, "seowebchecker_model_desc")
        col.prop(sc, "seowebchecker_model_url")
        col.prop(sc, "seowebchecker_page_url")

        box = layout.box()
        box.label(text="E-Commerce & Product Properties (Optional):")
        bcol = box.column(align=True)
        bcol.prop(sc, "seowebchecker_sku")
        bcol.prop(sc, "seowebchecker_brand")
        bcol.prop(sc, "seowebchecker_price")
        bcol.prop(sc, "seowebchecker_currency")

        layout.operator("seowebchecker.generate_schema", icon='COPYDOWN')


class SEOWEBCHECKER_PT_web_panel(Panel):
    """Sub-panel for Live Web Page & 3D Viewer Audit"""
    bl_label = "Live Web Page 3D Audit"
    bl_idname = "SEOWEBCHECKER_PT_web_panel"
    bl_space_type = 'VIEW_3D'
    bl_region_type = 'UI'
    bl_category = 'SEOWebChecker'
    bl_parent_id = "SEOWEBCHECKER_PT_main_panel"
    bl_options = {'DEFAULT_CLOSED'}

    def draw(self, context):
        layout = self.layout
        sc = context.scene

        col = layout.column(align=True)
        col.prop(sc, "seowebchecker_live_url")

        layout.operator("seowebchecker.audit_live_url", icon='WEB')

        if sc.seowebchecker_web_score >= 0 or sc.seowebchecker_web_status:
            box = layout.box()
            if sc.seowebchecker_web_score >= 0:
                row = box.row()
                row.label(text=f"Health Score: {sc.seowebchecker_web_score}/100", icon='VIEW_ZOOM')
                row.label(text=f"Grade: {sc.seowebchecker_web_grade}")
            box.label(text=sc.seowebchecker_web_status)


classes = (
    SEOWEBCHECKER_OT_audit_mesh,
    SEOWEBCHECKER_OT_generate_schema,
    SEOWEBCHECKER_OT_audit_live_url,
    SEOWEBCHECKER_OT_open_platform,
    SEOWEBCHECKER_PT_main_panel,
    SEOWEBCHECKER_PT_mesh_panel,
    SEOWEBCHECKER_PT_schema_panel,
    SEOWEBCHECKER_PT_web_panel,
)


def register_properties():
    bpy.types.Scene.seowebchecker_poly_target = IntProperty(
        name="Target Triangle Limit",
        description="Recommended maximum triangle count for mobile web and Google 3D search (default: 100,000)",
        default=100000,
        min=1000,
        max=5000000
    )
    bpy.types.Scene.seowebchecker_mesh_score = IntProperty(default=-1)
    bpy.types.Scene.seowebchecker_mesh_grade = StringProperty(default="")
    bpy.types.Scene.seowebchecker_mesh_status = StringProperty(default="")

    bpy.types.Scene.seowebchecker_model_name = StringProperty(
        name="Model Name",
        description="Name of the 3D model asset",
        default="Product 3D Model"
    )
    bpy.types.Scene.seowebchecker_model_desc = StringProperty(
        name="Description",
        description="Detailed description for Schema.org structured data",
        default="Interactive 3D model optimized for web browsers and augmented reality."
    )
    bpy.types.Scene.seowebchecker_model_url = StringProperty(
        name="GLTF/GLB Asset URL",
        description="Public URL where the .glb/.gltf model is hosted",
        default="https://example.com/models/product.glb"
    )
    bpy.types.Scene.seowebchecker_page_url = StringProperty(
        name="Hosting Web Page",
        description="Canonical URL of the product or showcase page",
        default="https://seowebchecker.com/"
    )
    bpy.types.Scene.seowebchecker_sku = StringProperty(
        name="SKU / Model ID",
        description="Stock keeping unit or model identifier",
        default=""
    )
    bpy.types.Scene.seowebchecker_brand = StringProperty(
        name="Brand Name",
        description="Manufacturer or brand entity",
        default=""
    )
    bpy.types.Scene.seowebchecker_price = StringProperty(
        name="Price",
        description="Product retail price (e.g. 99.00)",
        default=""
    )
    bpy.types.Scene.seowebchecker_currency = StringProperty(
        name="Currency",
        description="ISO currency code (e.g. USD, EUR)",
        default="USD"
    )
    bpy.types.Scene.seowebchecker_generated_json = StringProperty(default="")

    bpy.types.Scene.seowebchecker_live_url = StringProperty(
        name="Live URL to Audit",
        description="Enter webpage URL to test for 3D viewer, metadata, and Core Web Vitals speed",
        default="https://seowebchecker.com/"
    )
    bpy.types.Scene.seowebchecker_web_score = IntProperty(default=-1)
    bpy.types.Scene.seowebchecker_web_grade = StringProperty(default="")
    bpy.types.Scene.seowebchecker_web_status = StringProperty(default="")


def unregister_properties():
    del bpy.types.Scene.seowebchecker_poly_target
    del bpy.types.Scene.seowebchecker_mesh_score
    del bpy.types.Scene.seowebchecker_mesh_grade
    del bpy.types.Scene.seowebchecker_mesh_status

    del bpy.types.Scene.seowebchecker_model_name
    del bpy.types.Scene.seowebchecker_model_desc
    del bpy.types.Scene.seowebchecker_model_url
    del bpy.types.Scene.seowebchecker_page_url
    del bpy.types.Scene.seowebchecker_sku
    del bpy.types.Scene.seowebchecker_brand
    del bpy.types.Scene.seowebchecker_price
    del bpy.types.Scene.seowebchecker_currency
    del bpy.types.Scene.seowebchecker_generated_json

    del bpy.types.Scene.seowebchecker_live_url
    del bpy.types.Scene.seowebchecker_web_score
    del bpy.types.Scene.seowebchecker_web_grade
    del bpy.types.Scene.seowebchecker_web_status


def register():
    register_properties()
    for cls in classes:
        bpy.utils.register_class(cls)


def unregister():
    for cls in reversed(classes):
        bpy.utils.unregister_class(cls)
    unregister_properties()
