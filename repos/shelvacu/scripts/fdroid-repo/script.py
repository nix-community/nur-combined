import re
from shutil import copyfile
import sys
import tempfile
from pathlib import PosixPath

from scriptipy import *

fdroid_repo = PosixPath("/home/shelvacu/fdroid")

pkgName = sys.argv[1]

tempdirobj = tempfile.TemporaryDirectory(suffix="vacu-fdroid-repo-script")
temp = PosixPath(tempdirobj.name)

out_link = temp / "result-apk"

run(
    "nix",
    "build",
    f"/home/shelvacu/dev/nix-stuff#qb.{pkgName}",
    "--out-link",
    out_link,
).must_succeed()

apk_dir = out_link / "apk"

assert apk_dir.is_dir()

apk_paths = [*apk_dir.rglob("*.apk")]

assert len(apk_paths) >= 1

for apk_path in apk_paths:
    data = run("aapt2", "dump", "badging", apk_path).must_succeed()
    prefix = "package: "
    package_lines = [x for x in data.split("\n") if x.startswith(prefix)]
    assert len(package_lines) == 1
    package_line = package_lines[0].removeprefix(prefix)
    print(f"{package_line=}")
    match = re.search(r"name='([^']*)'", package_line)
    # print(f"{match=}")
    assert match != None
    application_id = match[1]
    match = re.search(r"versionCode='([^']*)'", package_line)
    # print(f"{match=}")
    assert match != None
    version_code = match[1]

    print(f"{application_id=} {version_code=}")
    apk_name = f"{application_id}_{version_code}.apk"
    target = fdroid_repo / "unsigned" / apk_name
    metadata_file = fdroid_repo / "metadata" / f"{application_id}.yml"
    if not metadata_file.exists():
        metadata_file.write_bytes(b"")
    if target.exists() or (fdroid_repo / "repo" / apk_name).exists():
        eprint(f"warn: {target=} already exists")
        continue
    copyfile(apk_path, target)

os.chdir(fdroid_repo)

for action in ("publish", "update", "deploy"):
    run(
        "fdroid",
        action,
        "--verbose",
    ).must_succeed()
