#!/usr/bin/env python3

import os
import sys
import re

index_path_list = [
  "default.nix",
]

nixpkgs_path = "~/src/nixos/nixpkgs/"

nixpkgs_pkgs = {
  "all-packages": {
    "index_path": "pkgs/top-level/all-packages.nix",
    "pkgs": [],
    "pkgs_by_name": {},
  },
}

ignore_path_suffixes = (
  "/package.nix",
  "/default.nix",
  "/unwrapped.nix",
  "/bin.nix",
  "/stable.nix",
  "/unstable.nix",
  "/mainline.nix",
)

def get_path(path):
  return path
  if path.endswith(ignore_path_suffixes):
    return os.path.dirname(path)
  return path

def get_names(attr, path):
  names = set([attr])
  if path.endswith(ignore_path_suffixes):
    path = os.path.dirname(path)
  basename = os.path.basename(path)
  if re.match(r"[0-9.]+\.nix", basename):
    # basename is f"{version}.nix"
    version = basename.rsplit(".", 1)[0]
    names.add(os.path.basename(os.path.dirname(path)) + "_" + version.replace(".", "_"))
    names.add(os.path.basename(os.path.dirname(path)) + version.replace(".", "_"))
  elif basename.endswith(".nix"):
    names.add(basename.rsplit(".", 1)[0])
  else:
    names.add(basename)
  if path.endswith(".nix"):
    names.add(os.path.basename(os.path.dirname(path)))
  return list(names)

class Package(object):
  names = []
  callpackage = None
  path = None
  def __repr__(self):
    return self.path

def parse_packages(index_path):
  pkgs = []
  with open(index_path) as f:
    index_lines = f.readlines()
  for line in index_lines:
    line = line.strip()
    if line == "": continue
    if line[0] == "#": continue
    if not "callPackage " in line: continue
    # print("line", repr(line))
    callpackage_regex = r"([a-zA-Z0-9_-]+) = ((?:[a-zA-Z0-9_.-]+\.)?callPackage) (\.\.?/[a-zA-Z0-9_./-]+) \{.*"
    m = re.match(callpackage_regex, line)
    if not m: continue
    attr, callpackage, path = m.groups()
    # TODO more levels, based on index_path
    if path.startswith("../../"): path = path[4:]
    if path.startswith("../"): path = "./pkgs/" + path[3:]
    names = get_names(attr, path)
    # print(names, path)
    pkg = Package()
    pkg.names = names
    pkg.callpackage = callpackage
    pkg.path = get_path(path)
    pkgs.append(pkg)
  return pkgs

for key in nixpkgs_pkgs:
  index_path = os.path.expanduser(nixpkgs_path) + "/" + nixpkgs_pkgs[key]["index_path"]
  pkgs = nixpkgs_pkgs[key]["pkgs"] = parse_packages(index_path)
  for pkg in pkgs:
    for name in pkg.names:
      if not name in nixpkgs_pkgs[key]["pkgs_by_name"]:
        nixpkgs_pkgs[key]["pkgs_by_name"][name] = []
      nixpkgs_pkgs[key]["pkgs_by_name"][name].append(pkg)

for index_path in index_path_list:
  for pkg in parse_packages(index_path):
    found = False
    for by_name_path in map(lambda n: f"pkgs/by-name/{n[0:2]}/{n}", pkg.names):
      # print(f"trying by-name path {by_name_path}")
      p = os.path.expanduser(nixpkgs_path) + "/" + by_name_path
      if not os.path.exists(p): continue
      print(f"TODO found by-name path {by_name_path}")
      found = True
    if found: continue
    for key in nixpkgs_pkgs:
      # matches = []
      for name in pkg.names:
        pkgs = nixpkgs_pkgs[key]["pkgs_by_name"].get(name)
        if not pkgs: continue
        print(f"TODO found name match between {name} and {pkgs}")
        # matches.append(pkgs)
