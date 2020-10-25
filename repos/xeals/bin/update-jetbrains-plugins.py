#! /usr/bin/env nix-shell
#! nix-shell -i python3 -p python3Packages.lxml python3Packages.requests

import argparse
import os
import re
import requests
import subprocess as sp
import sys
import urllib

from lxml import etree

# https://plugins.jetbrains.com/docs/marketplace/product-codes.html
PRODUCT_CODE = {
    "clion": "CL",
    "datagrip": "DB",
    "goland": "GO",
    "idea-community": "IC",
    "idea-ultimate": "IU",
    "phpstorm": "PS",
    "pycharm-community": "PC",
    "pycharm-professional": "PY",
    "rider": "RD",
    "ruby-mine": "RM",
    "webstorm": "WS",
}


def to_slug(name):
    slug = name.replace(" ", "-").lstrip(".")
    for char in ",/;'\\<>:\"|!@#$%^&*()":
        slug = slug.replace(char, "")
    return slug


class Build:
    """
    Transforms a Nixpkgs derivation name into a Jetbrains product code. For
    example:

    idea-community-2019.3.2 -> IC-193.2
    """

    def __init__(self, name):
        m = re.search("([0-9]+\.?)+$", name)
        version = m.group(0)
        code = PRODUCT_CODE[name.replace("-" + version, "")]
        vparts = version.split(".")
        version = vparts[0][-2:] + vparts[1] + "." + vparts[2]
        self.code = code
        self.version = version
        self.package = name.split("-")[0]

    def builder(self):
        return self.package + "Build"

    def __repr__(self):
        return self.code + "-" + self.version


PACKAGE_RE = re.compile("[^0-9A-Za-z._-]")
HTML_RE = re.compile("<[^>]+/?>")


class Plugin:
    def __init__(self, data, category=None):
        self.category = category
        self.name = data.find("name").text
        self.id = data.find("id").text
        self._description = data.find("description").text
        self.url = data.get("url") or data.find("vendor").get("url")
        self.version = data.find("version").text
        self.slug = to_slug(self.name)
        self.orig_slug = self.slug

        self.depends = []
        for depend in data.findall("depends"):
            self.depends.append(depend.text)

    def __repr__(self):
        return f"<Plugin '{self.name}' {self.version}>"

    def description(self):
        return re.sub(HTML_RE, "", self._description or "").strip()

    def download_url(self, build, deref=True):
        """
        Provides the ZIP download URL for this plugin.

        The trivial URL fetches the latest version through a redirect for some
        build code and provides no locking to a version for the URL. To fetch
        a stable URL that can be used as a package source, deref must be set
        (which it is by default). However, this comes at the cost of requiring
        an HTTP request.
        """
        id = urllib.parse.quote(self.id)
        url = f"https://plugins.jetbrains.com/pluginManager?action=download&id={id}&build={build}"
        if deref:
            res = requests.get(url, allow_redirects=not deref)
            url = "https://plugins.jetbrains.com" + re.sub(
                "\?.*$", "", res.headers["location"]
            )
            if url.endswith("external"):
                res = requests.get(url, allow_redirects=not deref)
                url = res.headers["location"]
        return url

    def packagename(self):
        slug = re.sub(PACKAGE_RE, "", self.slug.lower()).replace(".", "-")
        if slug[0] in "1234567890":
            return "_" + slug
        else:
            return slug

    def filename(self):
        """
        Returns this plugin's filename without an extension. Rely on the
        download URL to know the extension.
        """
        return f"{self.slug}-{self.version}"


def list_plugins(build):
    """
    Lists all plugins for the specified build code.

    https://plugins.jetbrains.com/docs/marketplace/plugins-list.html
    """
    resp = requests.get(f"https://plugins.jetbrains.com/plugins/list/?build={build}")
    return parse_repository(resp.content)


def parse_repository(content):
    tree = etree.XML(content)
    plugins = []
    for cat in tree.findall("category"):
        cat_name = cat.get("name")
        for plugin in cat.findall("idea-plugin"):
            plugins.append(Plugin(plugin, cat_name))
    return plugins


def deduplicate(plugins):
    """
    Ensures that the plugin list has unique slugs. Modifies the list in-place.
    """
    prev = plugins[0]
    for plugin in plugins[1:]:
        if plugin.orig_slug == prev.orig_slug:
            prev.slug = prev.orig_slug + "-" + prev.version.replace(".", "_")
            plugin.slug = plugin.orig_slug + "-" + plugin.version.replace(".", "_")
        prev = plugin


def prefetch(plugin, build, url=None):
    if not url:
        url = plugin.download_url(build)
    res = sp.run(
        ["nix-prefetch-url", "--name", plugin.filename(), url], capture_output=True,
    )
    if not res.stdout:
        raise IOError(f"nix-prefetch-url {plugin} failed: {res.stderr.decode('utf-8')}")
    return res.stdout.decode("utf-8").strip()


def write_packages(outfile, plugins, build):
    builder = build.builder()
    outfile.write("{callPackage}:\n{")

    for plugin in plugins:
        src_url = plugin.download_url(build, deref=True)
        src_ext = os.path.splitext(src_url)[-1]

        try:
            sha = prefetch(plugin, build, src_url)
        except IOError as e:
            print(e, file=sys.stderr)
            continue

        build_inputs = []
        if src_ext == ".zip":
            build_inputs.append("unzip")

        # TODO: Dependencies are provided as package IDs but refer to both
        # internal and external plugins; need to find some way to resolve them
        requires = []
        # TODO: Licenses are actually on the website, but aren't provided in the API
        license = "lib.licenses.free"

        call_args = [str(builder), "fetchurl", "lib"]
        for binput in build_inputs:
            call_args.append(binput)

        outfile.write(
            f"""
  {plugin.packagename()} = callPackage ({{ {", ".join(sorted(call_args))} }}: {builder} {{
    pname = "{plugin.slug}";
    plugname = "{plugin.name}";
    plugid = "{plugin.id}";
    version = "{plugin.version}";
    src = fetchurl {{
      url = "{src_url}";
      sha256 = "{sha}";
      name = "{plugin.filename()}{src_ext}";
    }};
    buildInputs = [ {" ".join(build_inputs)} ];
    packageRequires = [ {" ".join(requires)} ];
    meta = {{
      homepage = "{plugin.url or ""}";
      license = {license};
      description = ''
        {plugin.description()}
      '';
    }};
  }}) {{}};
"""
        )
    outfile.write("}\n")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-n", "--number", type=int, help="Limit the number of packages to write",
    )
    parser.add_argument(
        "-o", "--out", type=str, help="File to write plugins to",
    )
    parser.add_argument(
        "package",
        metavar="PACKAGE",
        type=str,
        help="The Nixpkgs package name (inc. version)",
    )

    args = parser.parse_args()

    build = Build(args.package)
    plugins = list_plugins(build)
    plugins.sort(key=lambda p: p.slug)
    deduplicate(plugins)

    if args.number:
        plugins = plugins[: args.number]

    print(f"Generating packages for {len(plugins)} plugins", file=sys.stderr)
    if not args.out:
        write_packages(sys.stdout, plugins, build)
    else:
        with open(args.out, "w") as f:
            write_packages(f, plugins, build)


main()
