import sys
import json

from lxml import etree


plugins_xml = sys.argv[1]

DISABLED_PLUGINS = [
    "i.vi.mpi",  # can't build
    "r.estimap.recreation",  # can't build
    "r.le.setup",  # can't build
    "v.in.redwg",  # can't build
    "i.fusion.hpf",  # can't build
    "v.area.stats",  # can't build
    "i.segment.hierarchical",  # can't build
    "r.in.ogc",  # can't build
    "r.pi",  # can't build
    "v.civil",  # can't build
    "v.class.ml",  # can't build
    "v.in.ogc",  # can't build
    "r.sun.mp",  # can't build
    "r.le.trace",  # can't build
    "r.le.patch",  # can't build
    "v.stats",  # can't build
    "i.pr",  # can't build
    "wx.mwprecip",  # can't build
    "i.sentinel",  # missing pystac in geonix
    "t.stac",  # missing pystac in geonix
]

def fix_plugin_name(name):
    replace_chars = [".",]

    for ch in replace_chars:
        name = name.replace(ch, "-")
    return name


# generate plugins.nix code
tree = etree.parse(plugins_xml)
root = tree.getroot()

print("{")  # opening curly

for plugin in root.findall("task"):

    if plugin.attrib["name"] not in DISABLED_PLUGINS:
        package_name = fix_plugin_name(plugin.attrib["name"])
        plugin_name = plugin.attrib["name"]
        description = plugin.find("description").text

        print(
            f"""
            {package_name} = {{
                name = "{plugin_name}";
                description = ''{description}'';
            }};
        """
        )

print("}")  # closing curly
