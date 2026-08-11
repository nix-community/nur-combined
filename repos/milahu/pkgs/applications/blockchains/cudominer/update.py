#!/usr/bin/env python3

import os, sys, re, json, hashlib, base64, urllib.request

def download_file(url):
    name = os.path.basename(url)
    if os.path.exists(name):
        os.unlink(name)
    print(f"fetching {name} from {url}")
    urllib.request.urlretrieve(url, name)

def sha256sum(file_path=None, data=None):
    # https://stackoverflow.com/questions/22058048/hashing-a-file-in-python
    if data:
        return hashlib.sha256(data).digest()
    assert file_path
    BUF_SIZE = 65536
    hash = hashlib.sha256()
    with open(file_path, 'rb') as f:
        while data := f.read(BUF_SIZE):
            hash.update(data)
    return hash.digest()
    #return hash.digest().hex()
    #return hash.hexdigest()



os.chdir(os.path.dirname(sys.argv[0]))

tempfiles = []



tenant = "135790374f46b0107c516a5f5e13069b/5e5f800fdf87209fdf8f9b61441e53a1"

platform = "linux/x64"

base_url = f"https://download.cudo.org/tenants/{tenant}/{platform}/"

install_url = base_url + "stable/install.sh"

release_base_url = base_url + "release/"



download_file(install_url)

name = os.path.basename(install_url)

with open(name) as f:
    install_sh = f.read()

tempfiles.append(name)



deb_urls = set()

for deb_url in re.finditer(r"https://.*\.deb", install_sh):
    deb_url = deb_url.group(0)
    if deb_url in deb_urls:
        continue
    deb_urls.add(deb_url)
    if not deb_url.startswith(base_url):
        print("error: deb_url does not start with release_base_url")
        print("deb_url         :", deb_url)
        print("release_base_url:", base_url)
        sys.exit(1)
    #print("deb_url", deb_url)
    download_file(deb_url)

deb_urls = list(deb_urls)
deb_urls.sort()

sources = dict(
    tenant=tenant,
    platform=platform,
    version=None,
    hashes=dict(),
)

last_version = None
last_deb_url = None

for deb_url in deb_urls:
    name = os.path.basename(deb_url)
    sha256 = sha256sum(name)
    hash = "sha256-" + base64.b64encode(sha256).decode("ascii")
    # https://download.cudo.org/tenants/135790374f46b0107c516a5f5e13069b/5e5f800fdf87209fdf8f9b61441e53a1/linux/x64/release/v1.7.7/cudo-miner-core.deb
    version = re.search(r"/release/v([0-9]+.[0-9]+.[0-9]+)/", deb_url)
    if version:
        version = version.group(1)
    else:
        print("error: deb_url has no version")
        print("deb_url         :", deb_url)
        sys.exit(1)
    if last_version:
        if version != last_version:
            print("error: deb_url has different version than last deb_url")
            print("deb_url     :", deb_url)
            print("last_deb_url:", last_deb_url)
            sys.exit(1)
    else:
        sources["version"] = version
    expected_deb_url = release_base_url + f"v{version}/{name}"
    if deb_url != expected_deb_url:
        print("error: deb_url does not have the expected format")
        print("deb_url         :", deb_url)
        print("expected_deb_url:", expected_deb_url)
        sys.exit(1)
    sources["hashes"][name] = hash
    last_deb_url = deb_url
    last_version = version
    tempfiles.append(name)

with open("sources.json", "w") as f:
    json.dump(sources, f, indent=2)

for name in tempfiles:
    os.unlink(name)
