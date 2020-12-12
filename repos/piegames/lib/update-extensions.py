#!python
import urllib.request, json, types

# We don't want all those deprecated legacy extensions
supported_versions = {
    "3.36", "3.36.0", "3.36.1", "3.36.2", "3.36.3", "3.36.4", "3.36.5", "3.36.6",
    "3.38", "3.38.0", "3.38.1"
}

def process_extension(extension) -> bool:
    # Yeah, there are some extensions without any releases
    if not extension["shell_version_map"]:
        return False
    # Throw away that 'pk' key. What is it for?
    extension["shell_version_map"] = {k: v["version"] for k, v in extension["shell_version_map"].items()}
    # Extract newest extension version
    extension["version"] = max (ver for ver in extension["shell_version_map"].values())
    # Extract matching shell versions. We only provide those compatible with the latest extension release
    extension["shell-versions"] = list(k for k,v in extension["shell_version_map"].items() if (v is extension["version"] and k in supported_versions))
    if not extension["shell-versions"]:
        return False

    print("Processing " + extension["uuid"])

    # Parse something like "/extension/1475/battery-time/" and output "battery-time-1475"
    def pname_from_url(url: str) -> str:
        url = url.split("/")
        return url[3] + "-" + url[2]

    extension["pname"] = pname_from_url(extension["link"])
    extension["link"] = "https://extensions.gnome.org" + extension["link"]

    # Download the extension and hash it
    def fetch_sha256sum(uuid: str, version: str) -> str:
        import hashlib, base64
        remote = urllib.request.urlopen(
            "https://extensions.gnome.org/extension-data/" + uuid.replace("@", "") + ".v" + version + ".shell-extension.zip"
        )
        hasher = hashlib.sha256()

        while True:
            data = remote.read(4096)
            if not data:
                break
            hasher.update(data)
        return hasher.hexdigest()

    extension["sha256"] = fetch_sha256sum(extension["uuid"], str(extension["version"]))

    # Replace \u0123 in strings
    # TODO remove that unicode un-escaping once <https://github.com/NixOS/nix/pull/3305> made it into a release
    extension["name"] = extension["name"].encode('unicode-escape').decode()
    extension["description"] = extension["description"].encode('unicode-escape').decode()

    # Remove unused keys
    del extension["shell_version_map"]
    del extension["screenshot"]
    del extension["icon"]
    del extension["creator"]
    del extension["creator_url"]
    del extension["pk"]
    return True

# Fetching extensions
page = 0
extensions = []
while True:
    page += 1
    print("Scraping page " + str(page))
    try:
        with urllib.request.urlopen("https://extensions.gnome.org/extension-query/?n_per_page=25&page=" + str(page)) as url:
            data = json.loads(url.read().decode())["extensions"]
            responseLength = len(data)
            print("Found " + str(responseLength) + " extensions")
            data = list(filter(process_extension, data))

            extensions += data
            if responseLength < 25:
                break
    except urllib.error.HTTPError as e:
        print("Got error. We're done. (This should be a 404)\n" + str(e))
        break

# The most pythonic way to do things is to copy pre-made solutions from StackOverflow, I guess?
def lookahead(iterable):
    """Pass through all values from the given iterable, augmented by the
    information if there are more values to come after the current one
    (True), or if it is the last value (False).
    """
    # Get an iterator and pull the first value.
    it = iter(iterable)
    last = next(it)
    # Run the iterator to exhaustion (starting from the second value).
    for val in it:
        # Report the *previous* value (more to come).
        yield last, True
        last = val
    # Report the last value.
    yield last, False

print("Writing results (" + str(len(extensions)) + " extensions in total)")
with open('extensions.json', 'w') as out:
    # Manually pretty-print the outer level, but then do one compact line per extension
    out.write("[\n")
    for extension, is_not_last in lookahead(extensions):
        out.write("    ")
        json.dump(extension, out)
        if is_not_last:
            out.write(",\n")
        else:
            out.write("\n")
    out.write("]\n")
