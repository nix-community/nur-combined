import sys
import json


from lxml import etree
from subprocess import run


MIN_DOWNLOADS = 100000

plugins_xml = sys.argv[1]

if plugins_xml == "qgis-plugins.xml":
    qgis_package = "qgis"
elif plugins_xml == "qgis-ltr-plugins.xml":
    qgis_package = "qgis-ltr"


def get_nix_hash(qgis_package, name, version):
    cmd = run(
        ["nix", "eval", "--raw", ".#{}-plugin-{}.version".format(qgis_package, name)],
        capture_output=True,
        text=True,
    )

    # if plugin already exists in the same version
    if cmd.stdout == version:
        cmd = run(
            ["nix", "eval", "--raw", ".#qgis-plugin-{}.src.outputHash".format(name)],
            capture_output=True,
            text=True,
        )
        return cmd.stdout

    # if plugin doesn't exist or the version is different
    else:
        cmd = run(
            ["nix", "store", "prefetch-file",
                "--option", "download-attempts", "10",
                "--json", url
            ], capture_output=True, text=True
        )
        return json.loads(cmd.stdout)["hash"]


def fix_plugin_name(name):
    replace_chars = [" ", ".", ":", "(", ")"]

    for ch in replace_chars:
        name = name.replace(ch, "-")
    return name


# generate plugins.nix code
tree = etree.parse(plugins_xml)
root = tree.getroot()

print("{")  # opening curly

for plugin in root.findall("pyqgis_plugin"):
    # get non-experimental plugins with more than MIN_DOWNLOADS
    if (
        plugin.find("experimental").text == "False"
        and plugin.find("deprecated").text == "False"
        and int(plugin.find("downloads").text) > MIN_DOWNLOADS
    ):
        name = fix_plugin_name(plugin.attrib["name"])
        url = plugin.find("download_url").text
        version = plugin.find("version").text
        hash = get_nix_hash(
            qgis_package,
            name,
            version
        )

        print(
            f"""
            {name} = {{
                version = "{version}";
                url = "{url}";
                hash = "{hash}";
            }};
        """
        )

print("}")  # closing curly
