# -*- coding: utf-8 -*-
"""
SEOWebChecker Core Engine for Blender 4.2+ Extensions
Audits 3D meshes for Web3D SEO, generates Schema.org 3DModel JSON-LD,
and inspects live web pages for 3D viewer integration.

Official Platform: https://seowebchecker.com/
"""

import re
import time
import ssl
import json
from datetime import datetime
from urllib.parse import urlparse
from urllib.request import Request, urlopen


class Web3DGeometryAuditor:
    """Analyzes 3D model geometry and material metrics for Web3D & Google 3D search optimization."""

    def __init__(self, target_polycount=100000, target_materials=5):
        self.target_polycount = target_polycount
        self.target_materials = target_materials

    def audit_mesh_stats(self, name, polycount, vertcount, material_count, has_uv=True, scale_applied=True, textures=None):
        """Calculates a Web3D SEO health score (0-100) based on mobile web performance standards."""
        score = 100
        passes = []
        issues = []
        textures = textures or []

        # 1. Polycount / Triangle Budget (Google 3D Search & Mobile AR recommends < 100k, ideal < 50k)
        if polycount <= 50000:
            passes.append({
                "id": "polycount-optimum",
                "title": "Optimal Polygon Count for Web & Mobile AR",
                "message": f"Geometry has {polycount:,} triangles (well within 50,000 high-performance threshold)."
            })
        elif polycount <= self.target_polycount:
            score -= 10
            passes.append({
                "id": "polycount-acceptable",
                "title": "Acceptable Polygon Count",
                "message": f"Geometry has {polycount:,} triangles (within maximum {self.target_polycount:,} budget)."
            })
        else:
            excess = polycount - self.target_polycount
            penalty = min(35, 15 + int(excess / 20000) * 5)
            score -= penalty
            issues.append({
                "id": "polycount-excessive",
                "severity": "high",
                "title": "High Polygon Count for Web Loading Speed",
                "message": f"Geometry has {polycount:,} triangles, exceeding target {self.target_polycount:,} by {excess:,}. May degrade mobile Core Web Vitals (LCP/INP)."
            })

        # 2. Material Slots & WebGL Draw Calls (Target <= 5 draw calls per model)
        if material_count <= 2:
            passes.append({
                "id": "draw-calls-ideal",
                "title": "Excellent Draw Call Efficiency",
                "message": f"Model uses {material_count} material slot(s), ensuring high WebGL framerates."
            })
        elif material_count <= self.target_materials:
            score -= 5
            passes.append({
                "id": "draw-calls-moderate",
                "title": "Moderate Draw Calls",
                "message": f"Model uses {material_count} material slots (within recommended {self.target_materials} limit)."
            })
        else:
            score -= 15
            issues.append({
                "id": "draw-calls-excessive",
                "severity": "medium",
                "title": "High Material Slot Count",
                "message": f"Model uses {material_count} materials. Each material generates separate WebGL draw calls on web browsers. Consider texture atlas baking."
            })

        # 3. UV Map Presence (Required for PBR texturing in glTF/USDZ)
        if has_uv:
            passes.append({
                "id": "uv-mapped",
                "title": "UV Coordinates Configured",
                "message": "Mesh possesses active UV mapping required for glTF 2.0 and USDZ web export."
            })
        else:
            score -= 20
            issues.append({
                "id": "uv-missing",
                "severity": "high",
                "title": "Missing UV Map Coordinates",
                "message": "Mesh has no active UV maps. Textures will not render correctly in web 3D viewers."
            })

        # 4. Transform Normalization (Scale (1.0, 1.0, 1.0) is vital for AR real-world sizing)
        if scale_applied:
            passes.append({
                "id": "scale-applied",
                "title": "Transforms Applied (Uniform 1:1 Scale)",
                "message": "Object scale is normalized to (1.0, 1.0, 1.0), essential for WebXR and Google AR quick-look accurate scaling."
            })
        else:
            score -= 10
            issues.append({
                "id": "scale-unapplied",
                "severity": "medium",
                "title": "Unapplied Object Scale",
                "message": "Object scale is not applied. In glTF export this can cause distortions or incorrect dimensions in mobile AR viewers."
            })

        # 5. Texture Diagnostics
        large_textures = [t for t in textures if t.get("max_dim", 0) > 2048]
        if large_textures:
            score -= 10
            issues.append({
                "id": "textures-oversized",
                "severity": "medium",
                "title": "Oversized Texture Maps (>2048px)",
                "message": f"{len(large_textures)} texture(s) exceed 2048px dimension. 4K textures severely impact mobile download latency and WebGL memory."
            })

        score = max(0, min(100, score))
        if score >= 95:
            grade = "A+"
        elif score >= 90:
            grade = "A"
        elif score >= 80:
            grade = "B"
        elif score >= 70:
            grade = "C"
        else:
            grade = "F"

        return {
            "name": name,
            "score": score,
            "grade": grade,
            "triangles": polycount,
            "vertices": vertcount,
            "material_count": material_count,
            "has_uv": has_uv,
            "scale_applied": scale_applied,
            "passes": passes,
            "issues": issues,
            "platform_url": "https://seowebchecker.com/",
            "timestamp": datetime.utcnow().isoformat() + "Z",
        }


class Schema3DGenerator:
    """Generates Google 3D Search & Schema.org compliant 3DModel and Product JSON-LD markup."""

    @staticmethod
    def generate(name, description, model_url, page_url=None, sku="", brand="", author="SEOWebChecker", encoding_format="model/gltf-binary", price="", currency="USD"):
        data = {
            "@context": "https://schema.org",
            "@type": "3DModel",
            "name": name.strip() or "3D Asset",
            "description": description.strip() or "Interactive 3D model asset optimized for web browsers and augmented reality.",
            "encoding": [
                {
                    "@type": "MediaObject",
                    "contentUrl": model_url.strip() or "https://example.com/assets/model.glb",
                    "encodingFormat": encoding_format,
                }
            ],
            "creator": {
                "@type": "Organization",
                "name": author.strip() or "SEOWebChecker",
                "url": "https://seowebchecker.com/",
            }
        }

        # If SKU or Brand provided, wrap into or reference Product entity
        if sku or brand or price:
            product_wrapper = {
                "@context": "https://schema.org",
                "@type": "Product",
                "name": name.strip() or "3D Product",
                "description": description.strip() or "Interactive 3D product viewable in WebGL and mobile AR.",
                "subjectOf": data,
            }
            if sku:
                product_wrapper["sku"] = sku.strip()
            if brand:
                product_wrapper["brand"] = {
                    "@type": "Brand",
                    "name": brand.strip(),
                }
            if price:
                try:
                    num_price = float(price.replace("$", "").replace(",", "").strip())
                    product_wrapper["offers"] = {
                        "@type": "Offer",
                        "price": str(num_price),
                        "priceCurrency": currency.strip() or "USD",
                        "availability": "https://schema.org/InStock",
                        "url": page_url.strip() if page_url else "https://seowebchecker.com/",
                    }
                except (ValueError, AttributeError):
                    pass
            json_output = json.dumps(product_wrapper, indent=2)
        else:
            json_output = json.dumps(data, indent=2)

        html_snippet = f'<script type="application/ld+json">\n{json_output}\n</script>'
        return {
            "json_data": json.loads(json_output),
            "json_string": json_output,
            "html_snippet": html_snippet,
            "platform_url": "https://seowebchecker.com/",
        }


class LiveWebAuditor:
    """Audits live web pages hosting 3D models for technical SEO and 3D web viewer integration."""

    def __init__(self, user_agent="SEOWebChecker-Blender/1.0 (+https://seowebchecker.com/)", timeout=15):
        self.user_agent = user_agent
        self.timeout = timeout

    def audit(self, target_url):
        """Fetches and inspects target web page for SEO and 3D web elements."""
        url = target_url.strip()
        parsed_url = urlparse(url)
        if parsed_url.scheme:
            if parsed_url.scheme.lower() not in ("http", "https"):
                return {
                    "failed": True,
                    "url": url,
                    "error": "Permitted URL schemes are strictly http:// and https://",
                    "platform_url": "https://seowebchecker.com/",
                }
        else:
            url = "https://" + url
            parsed_url = urlparse(url)

        req = Request(url, headers={"User-Agent": self.user_agent})
        ctx = ssl.create_default_context()
        ctx.check_hostname = False
        ctx.verify_mode = ssl.CERT_NONE

        start_time = time.time()
        try:
            with urlopen(req, timeout=self.timeout, context=ctx) as resp:  # nosec B310
                raw_bytes = resp.read()
                html = raw_bytes.decode("utf-8", errors="ignore")
        except (IOError, OSError, TimeoutError, ValueError) as e:
            return {
                "failed": True,
                "url": url,
                "error": str(e),
                "platform_url": "https://seowebchecker.com/",
            }

        elapsed_ms = round((time.time() - start_time) * 1000.0, 2)
        return self.audit_html(html, url=url, response_time_ms=elapsed_ms)

    def audit_html(self, html, url="https://seowebchecker.com/", response_time_ms=150.0):
        """Performs comprehensive in-memory audit of HTML document."""
        score = 100
        passes = []
        issues = []

        # 1. Title Tag
        m_title = re.search(r'(?i)<title[^>]*>(.*?)</title>', html)
        if m_title:
            title_text = m_title.group(1).strip()
            title_len = len(title_text)
            if 30 <= title_len <= 65:
                passes.append({
                    "id": "title-optimal",
                    "title": "Optimal Title Tag Length",
                    "message": f"Title ({title_len} chars): '{title_text[:40]}...'"
                })
            elif title_len > 0:
                score -= 5
                issues.append({
                    "id": "title-length",
                    "severity": "low",
                    "title": "Suboptimal Title Length",
                    "message": f"Title has {title_len} characters. Target 30-65 chars for Google search snippet display."
                })
        else:
            score -= 15
            issues.append({
                "id": "title-missing",
                "severity": "high",
                "title": "Missing <title> Tag",
                "message": "Document lacks a title tag, crucial for search indexing."
            })

        # 2. Meta Description
        m_desc = re.search(r'(?i)<meta\s+[^>]*name=["\']description["\'][^>]*content=["\']([^"\']*)["\']', html)
        if m_desc:
            desc_len = len(m_desc.group(1).strip())
            if 120 <= desc_len <= 165:
                passes.append({
                    "id": "desc-optimal",
                    "title": "Optimal Meta Description",
                    "message": f"Description has {desc_len} characters."
                })
            elif desc_len > 0:
                score -= 5
                issues.append({
                    "id": "desc-length",
                    "severity": "low",
                    "title": "Suboptimal Meta Description Length",
                    "message": f"Description is {desc_len} characters (recommended: 120-165 chars)."
                })
        else:
            score -= 10
            issues.append({
                "id": "desc-missing",
                "severity": "medium",
                "title": "Missing Meta Description",
                "message": "Meta description missing, impacting click-through rates from search results."
            })

        # 3. Viewport (Crucial for mobile Web3D / AR quick look)
        m_vp = re.search(r'(?i)<meta\s+[^>]*name=["\']viewport["\']', html)
        if m_vp:
            passes.append({
                "id": "viewport-pass",
                "title": "Mobile Viewport Meta Tag Detected",
                "message": "Viewport tag configured for mobile devices and responsive 3D canvas scaling."
            })
        else:
            score -= 15
            issues.append({
                "id": "viewport-missing",
                "severity": "high",
                "title": "Missing Mobile Viewport Tag",
                "message": "Without a viewport meta tag, mobile browsers will not size 3D canvas and AR properly."
            })

        # 4. Canonical URL
        m_can = re.search(r'(?i)<link\s+[^>]*rel=["\']canonical["\'][^>]*href=["\']([^"\']*)["\']', html)
        if m_can:
            passes.append({
                "id": "canonical-pass",
                "title": "Canonical Link Tag Present",
                "message": f"Canonical URL set to: {m_can.group(1)}"
            })
        else:
            score -= 5
            issues.append({
                "id": "canonical-missing",
                "severity": "low",
                "title": "Missing Canonical Tag",
                "message": "Define a canonical link element to prevent duplicate content indexing."
            })

        # 5. 3D Web Viewer & Schema Detection
        has_model_viewer = bool(re.search(r'(?i)<model-viewer\b', html))
        has_canvas = bool(re.search(r'(?i)<canvas\b', html))
        has_3d_schema = bool(re.search(r'(?i)["\']@type["\']\s*:\s*["\']3DModel["\']', html))
        has_gltf_ref = bool(re.search(r'(?i)\.(glb|gltf|usdz)\b', html))

        if has_model_viewer:
            passes.append({
                "id": "model-viewer-pass",
                "title": "Google <model-viewer> Detected",
                "message": "Native Web Component <model-viewer> detected, ready for interactive 3D and AR quick look."
            })
        elif has_canvas or has_gltf_ref:
            passes.append({
                "id": "web3d-canvas-pass",
                "title": "WebGL 3D Canvas / Model Asset Detected",
                "message": "3D Canvas or glTF/USDZ asset reference found in HTML markup."
            })
        else:
            score -= 10
            issues.append({
                "id": "web3d-missing",
                "severity": "medium",
                "title": "No 3D Web Component Detected",
                "message": "Neither <model-viewer> nor 3D canvas container was found. Ensure 3D assets are properly embedded."
            })

        if has_3d_schema:
            passes.append({
                "id": "schema-3d-pass",
                "title": "Schema.org 3DModel Structured Data Present",
                "message": "Rich structured data detected for search engine 3D indexing."
            })
        else:
            score -= 10
            issues.append({
                "id": "schema-3d-missing",
                "severity": "medium",
                "title": "Missing Schema.org 3DModel Markup",
                "message": "Include Schema.org 3DModel JSON-LD to qualify for Google 3D rich search results."
            })

        # 6. Response Time
        if response_time_ms <= 300.0:
            passes.append({
                "id": "speed-fast",
                "title": "Fast Server Response Time",
                "message": f"Server responded in {response_time_ms} ms."
            })
        elif response_time_ms > 1200.0:
            score -= 10
            issues.append({
                "id": "speed-slow",
                "severity": "medium",
                "title": "Slow Response Time",
                "message": f"Response took {response_time_ms} ms, which may harm Core Web Vitals (LCP)."
            })

        score = max(0, min(100, score))
        if score >= 95:
            grade = "A+"
        elif score >= 90:
            grade = "A"
        elif score >= 80:
            grade = "B"
        elif score >= 70:
            grade = "C"
        else:
            grade = "F"

        return {
            "url": url,
            "score": score,
            "grade": grade,
            "response_time_ms": response_time_ms,
            "has_model_viewer": has_model_viewer,
            "has_3d_schema": has_3d_schema,
            "passes": passes,
            "issues": issues,
            "platform_url": "https://seowebchecker.com/",
            "timestamp": datetime.utcnow().isoformat() + "Z",
        }
