#!/usr/bin/env python3
"""Regenerate the port's stub string resources from upstream Android XML.

The Compose Desktop port has no Android resource compiler, so
``moe.rukamori.archivetune.R`` and the ``stringResource`` lookup table are plain
Kotlin files under android-stubs. Upstream adds strings constantly, so instead of
hand-editing two files per release this script derives both from
``app/src/main/res/values/*.xml``.

The ``string`` and ``drawable`` objects of R.kt, plus the ``stringResource`` and
``DrawableResources`` lookup tables, are rewritten; the raw/font/plurals objects
are left alone. Run from the package root after android-stubs has been copied
into the source tree, or pass the source root as argv[1].
"""
import glob
import os
import re
import sys

root = sys.argv[1] if len(sys.argv) > 1 else "."
values_dir = os.path.join(root, "app/src/main/res/values")
r_kt = os.path.join(
    root, "android-stubs/src/main/kotlin/moe/rukamori/archivetune/R.kt"
)
string_resource_kt = os.path.join(
    root, "android-stubs/src/main/kotlin/androidx/compose/ui/res/stringResource.kt"
)
drawable_resources_kt = os.path.join(
    root, "android-stubs/src/main/kotlin/androidx/compose/ui/res/DrawableResources.kt"
)
plural_string_resource_kt = os.path.join(
    root, "android-stubs/src/main/kotlin/androidx/compose/ui/res/pluralStringResource.kt"
)

STRING_RE = re.compile(r'<string\s+name="([^"]+)"[^>]*>(.*?)</string>', re.S)
PLURAL_RE = re.compile(
    r'<plurals\s+name="([^"]+)"\s*>(.*?)</plurals>', re.S
)
PLURAL_ITEM_RE = re.compile(
    r'<item\s+quantity="([^"]+)"[^>]*>(.*?)</item>', re.S
)

# Same order as aapt: values/ first (file name order), first definition wins.
strings = {}
for path in sorted(glob.glob(os.path.join(values_dir, "*.xml"))):
    text = open(path, encoding="utf-8").read()
    for name, value in STRING_RE.findall(text):
        strings.setdefault(name, value.strip())

ordered = sorted(strings)
ids = {name: i + 1 for i, name in enumerate(ordered)}

# Plurals: keep one/other per name from values/, first definition wins.
plurals = {}
for path in sorted(glob.glob(os.path.join(values_dir, "*.xml"))):
    text = open(path, encoding="utf-8").read()
    for name, body in PLURAL_RE.findall(text):
        if name in plurals:
            continue
        items = dict(PLURAL_ITEM_RE.findall(body))
        plurals[name] = (
            items.get("one", items.get("other", "")).strip(),
            items.get("other", items.get("one", "")).strip(),
        )
plural_names = sorted(plurals)
plural_ids = {name: i + 1 for i, name in enumerate(plural_names)}


def kotlin_string(value):
    value = (
        value.replace("\\", "\\\\")
        .replace('"', '\\"')
        .replace("$", "\\$")
        .replace("\n", "\\n")
        .replace("\t", "\\t")
    )
    return "".join(
        c if ord(c) < 128 else "\\u%04x" % ord(c) for c in value
    )


r_text = open(r_kt, encoding="utf-8").read()
body = "".join(
    "        const val %s = %d\n" % (name, ids[name]) for name in ordered
)
new_object = "    object string {\n" + body + "    }\n"
r_text, count = re.subn(
    r"    object string \{.*?\n    \}\n", new_object, r_text, count=1, flags=re.S
)
if count != 1:
    raise SystemExit("could not find the R.string object in %s" % r_kt)
open(r_kt, "w", encoding="utf-8").write(r_text)

string_entries = "".join(
    "        %d to \"%s\",\n" % (ids[name], kotlin_string(strings[name]))
    for name in ordered
)
# Drawables: every res/drawable*/ asset name, aapt-style alphabetic order, ids from 10001.
drawable_names = set()
for drawable_dir in glob.glob(os.path.join(root, "app/src/main/res/drawable*")):
    for path in glob.glob(os.path.join(drawable_dir, "*")):
        base = os.path.basename(path)
        if "." not in base:
            continue
        ext = base.rsplit(".", 1)[1].lower()
        if ext in ("xml", "png", "jpg", "jpeg", "webp", "gif"):
            drawable_names.add(base.rsplit(".", 1)[0])
ordered_drawables = sorted(drawable_names)
drawable_ids = {name: 10001 + i for i, name in enumerate(ordered_drawables)}

r_text = open(r_kt, encoding="utf-8").read()
body = "".join(
    "        const val %s = %d\n" % (name, drawable_ids[name])
    for name in ordered_drawables
)
new_object = "    object drawable {\n" + body + "    }\n"
r_text, count = re.subn(
    r"    object drawable \{.*?\n    \}\n", new_object, r_text, count=1, flags=re.S
)
if count != 1:
    raise SystemExit("could not find the R.drawable object in %s" % r_kt)
open(r_kt, "w", encoding="utf-8").write(r_text)

drawable_entries = "".join(
    "        %d to \"%s\",\n" % (drawable_ids[name], name)
    for name in ordered_drawables
)
r_text = open(r_kt, encoding="utf-8").read()
body = "".join(
    "        const val %s = %d\n" % (name, plural_ids[name])
    for name in plural_names
)
new_object = "    object plurals {\n" + body + "    }\n"
r_text, count = re.subn(
    r"    object plurals \{.*?\n    \}\n", new_object, r_text, count=1, flags=re.S
)
if count != 1:
    raise SystemExit("could not find the R.plurals object in %s" % r_kt)
open(r_kt, "w", encoding="utf-8").write(r_text)

plural_entries = "".join(
    "        %d to (\"%s\" to \"%s\"),\n"
    % (
        plural_ids[name],
        kotlin_string(plurals[name][0]),
        kotlin_string(plurals[name][1]),
    )
    for name in plural_names
)
open(plural_string_resource_kt, "w", encoding="utf-8").write(
    "package androidx.compose.ui.res\n"
    "\n"
    "import androidx.compose.runtime.Composable\n"
    "\n"
    "object PluralResources {\n"
    "    val pluralMap = mapOf<Int, Pair<String, String>>(\n"
    + plural_entries
    + "    )\n"
    "}\n"
    "\n"
    "@Composable\n"
    "fun pluralStringResource(id: Int, count: Int): String {\n"
    "    val (one, other) = PluralResources.pluralMap[id] ?: (\"\" to \"\")\n"
    "    val template = if (count == 1) one else other\n"
    "    return try { String.format(template, count) } catch (e: Exception) { template }\n"
    "}\n"
    "\n"
    "@Composable\n"
    "fun pluralStringResource(id: Int, count: Int, vararg formatArgs: Any): String {\n"
    "    val (one, other) = PluralResources.pluralMap[id] ?: (\"\" to \"\")\n"
    "    val template = if (count == 1) one else other\n"
    "    return try { String.format(template, *formatArgs) } catch (e: Exception) { template }\n"
    "}\n"
)
print("gen_string_resources: wrote %d plurals" % len(plural_names))

open(drawable_resources_kt, "w", encoding="utf-8").write(
    "package androidx.compose.ui.res\n"
    "\n"
    "object DrawableResources {\n"
    "    val drawableMap: Map<Int, String> = mapOf(\n"
    + drawable_entries
    + "    )\n"
    "\n"
    "    val nameToIdMap: Map<String, Int> = drawableMap.entries.associate { (k, v) -> v to k }\n"
    "\n"
    "    fun getName(id: Int): String? = drawableMap[id]\n"
    "    fun getId(name: String): Int? = nameToIdMap[name]\n"
    "}\n"
)
print("gen_string_resources: wrote %d drawables" % len(ordered_drawables))

open(string_resource_kt, "w", encoding="utf-8").write(
    "package androidx.compose.ui.res\n"
    "\n"
    "import androidx.compose.runtime.Composable\n"
    "\n"
    "object StringResources {\n"
    "    val stringMap = mapOf<Int, String>(\n"
    + string_entries
    + "    )\n"
    "}\n"
    "\n"
    "@Composable\n"
    "fun stringResource(id: Int): String {\n"
    '    return StringResources.stringMap[id] ?: "Stub String Resource ($id)"\n'
    "}\n"
    "\n"
    "@Composable\n"
    "fun stringResource(id: Int, vararg formatArgs: Any): String {\n"
    '    val str = StringResources.stringMap[id] ?: "Stub String Resource ($id)"\n'
    "    return try { String.format(str, *formatArgs) } catch (e: Exception) { str }\n"
    "}\n"
)
print("gen_string_resources: wrote %d strings" % len(ordered))
