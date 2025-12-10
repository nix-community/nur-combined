#!/usr/bin/env python
from urllib.request import urlopen
import subprocess
import codecs
import sys

amd_repo = "https://repo.radeon.com/amdgpu/"

def readPackages(packageString, packages,version):
    for line in packageString.splitlines():
        x = line.split(":",1)
        if x[0] == "Package":
            packages.append({"name": None, "url": None, "sha256": None})
            packages[len(packages) - 1]["name"] = x[1].strip()
        elif x[0] == "Filename":
            packages[len(packages) - 1]["url"] = amd_repo + version + "/ubuntu/" + x[1].strip()
        elif x[0] == "SHA256":
            packages[len(packages) - 1]["sha256"] = x[1].strip()

def generateFetchurl(version = "6.4.4", ubuntu_code = "noble"):

    packages = []
    packages32 = []
        
    data_main = urlopen(amd_repo + version + "/ubuntu/dists/" + ubuntu_code + "/main/binary-amd64/Packages" ).read().decode('utf-8')
    data_proprietary = urlopen(amd_repo + version + "/ubuntu/dists/" + ubuntu_code + "/proprietary/binary-amd64/Packages" ).read().decode('utf-8')

    data_main32 = urlopen(amd_repo + version + "/ubuntu/dists/" + ubuntu_code + "/main/binary-i386/Packages" ).read().decode('utf-8')
    data_proprietary32 = urlopen(amd_repo + version + "/ubuntu/dists/" + ubuntu_code + "/proprietary/binary-i386/Packages" ).read().decode('utf-8')

    readPackages(data_main,packages,version)
    readPackages(data_proprietary,packages,version)

    readPackages(data_main32,packages32,version)
    readPackages(data_proprietary32,packages32,version)
    _all = "["
    final = "{ fetchurl }:\n{\nversion=\""+version+"\";\nbit64 = rec { "
    for p in packages: 
        _all += " " + p["name"].replace(".","_") + " "
        final += """\n{name} = ( fetchurl {{
            url = "{url}";
            name = "{name}";
            sha256 = "{sha_hash}";
            }});
        """.format(url=p["url"], name= p["name"].replace(".","_"),sha_hash=p["sha256"])
    _all += "];"
    final+= "\nall = "+ _all+"\n};\nbit32 = rec { "
    _all = "["
    for p in packages32: 
        _all += " " + p["name"].replace(".","_") + " "
        final += """\n{name} = ( fetchurl {{
            url = "{url}";
            name = "{name}";
            sha256 = "{sha_hash}";
            }});
        """.format(url=p["url"].strip(), name= p["name"].replace(".","_"),sha_hash=p["sha256"])
    _all += "];"
    final+= "\nall = "+ _all+"\n};}"

    f = open("amdgpu-src.nix", "w")
    f.write(final)
    subprocess.run(["nixfmt" , "amdgpu-src.nix"])

if len(sys.argv) == 1:
    generateFetchurl()
elif len(sys.argv) == 2:
    generateFetchurl(sys.argv[1])
elif len(sys.argv) == 2:
    generateFetchurl(sys.argv[1],sys.argv[2])
else:
    print("Too much args: arg1 = version, arg2 = ubuntu codename")
