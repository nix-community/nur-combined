import bisect
import os
from pathlib import Path
from tempfile import TemporaryDirectory
from urllib.parse import urlparse
from xmltodict import parse
import json
import sys

def ensure_is_list(obj):
    if obj is None:
        return []
    if isinstance(obj, list):
        return obj
    return [obj]

def add_entries(sources, targets, hashes):
    for artefact in sources:
        target = None
        base_jar_name = os.path.basename(urlparse(artefact["@url"]).path)
        for candidate in targets:
            if candidate["@url"].endswith(base_jar_name + "!/"):
                target = candidate
                break
        if target is None:
            continue

        url = artefact["@url"].removeprefix("file://$MAVEN_REPOSITORY$/")
        if url == artefact["@url"]:
            continue

        path = (
            target["@url"].removeprefix("jar://$MAVEN_REPOSITORY$/").removesuffix("!/")
        )
        if path == target["@url"]:
            continue

        bisect.insort(hashes, {"url": url, "hash": artefact["sha256sum"], "path": path}, key=lambda e: e["url"])

def add_libraries(
    root_path: str, hashes: list[dict[str, str]], projects_to_process: list[str]
):
    library_paths = os.listdir(root_path + "/libraries/")
    for path in library_paths:
        file_contents = parse(open(root_path + "/libraries/" + path).read())
        if "properties" not in file_contents["component"]["library"]:
            continue
        props = file_contents["component"]["library"]["properties"]
        if "verification" not in props:
            continue
        sources = ensure_is_list(
            props["verification"]["artifact"]
        )
        if "CLASSES" not in file_contents["component"]["library"]:
            continue
        if "root" not in file_contents["component"]["library"]["CLASSES"]:
            continue
        targets = ensure_is_list(
            file_contents["component"]["library"]["CLASSES"]["root"]
        )
        add_entries(sources, targets, hashes)

    modules_xml = parse(open(root_path + "/modules.xml").read())
    for module in ensure_is_list(modules_xml["project"]["component"]["modules"]["module"]):
        projects_to_process.append(module["@filepath"])

def add_iml(path: str, hashes: list[dict[str, str]], projects_to_process: list[str]):
    try:
        contents = parse(open(path).read())
    except FileNotFoundError:
        print(
            f"Warning: path {path} does not exist (did you forget the android directory?)"
        )
        return
    for manager in ensure_is_list(contents["module"]["component"]):
        if manager["@name"] != "NewModuleRootManager":
            continue

        if "orderEntry" not in manager:
            continue

        for entry in ensure_is_list(manager["orderEntry"]):
            if (
                type(entry) != dict
                or entry.get("@type") != "module-library"
                or "properties" not in entry.get("library", {})
            ):
                continue

            props = entry["library"]["properties"]
            if "verification" not in props:
                continue
            sources = ensure_is_list(
                props["verification"]["artifact"]
            )
            if "CLASSES" not in entry["library"] or "root" not in entry["library"]["CLASSES"]:
                continue
            targets = ensure_is_list(entry["library"]["CLASSES"]["root"])
            add_entries(sources, targets, hashes)

def main():
    root_path_str = sys.argv[1]
    root_path = Path(root_path_str)
    file_hashes = []
    projects_to_process = [str(root_path / ".idea")]

    while projects_to_process:
        elem = projects_to_process.pop()
        elem = elem.replace("$PROJECT_DIR$", str(root_path))
        if elem.endswith(".iml"):
            add_iml(elem, file_hashes, projects_to_process)
        else:
            add_libraries(elem, file_hashes, projects_to_process)

    # De-duplicate by url
    unique_hashes = []
    seen_urls = set()
    for h in file_hashes:
        if h["url"] not in seen_urls:
            unique_hashes.append(h)
            seen_urls.add(h["url"])

    with open("idea_maven_artefacts.json", "w") as f:
        json.dump(unique_hashes, f, indent=4)

if __name__ == "__main__":
    main()
