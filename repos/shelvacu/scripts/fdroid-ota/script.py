from pathlib import PosixPath
from scriptipy import *
import shutil
import nixdata
import tempfile

privileged_src = PosixPath(nixdata.privileged_src)

outzip = PosixPath(sys.argv[1]).resolve()

tempobj = tempfile.TemporaryDirectory(suffix="-fdroid-ota")
tempdir = PosixPath(tempobj.name)

(tempdir / "META-INF/com/google/android").mkdir(parents=True)

shutil.copy(
    privileged_src / "app/src/main/scripts/update-binary",
    tempdir / "META-INF/com/google/android",
)
shutil.copy(
    privileged_src / "app/src/main/scripts/80-fdroid.sh",
    tempdir,
)
shutil.copy(
    privileged_src / "app/src/main/permissions_org.fdroid.fdroid.privileged.xml",
    tempdir,
)
fdroid_repo = PosixPath("/var/lib/fdroid-repo/fdroid/repo")


def get_apk(application_id: str) -> PosixPath:
    files = sorted(fdroid_repo.glob(f"{application_id}_*.apk"))
    assert len(files) >= 1
    return files[-1]


shutil.copyfile(
    get_apk("org.fdroid.fdroid.privileged"),
    tempdir / "F-DroidPrivilegedExtension.apk",
)
shutil.copyfile(
    get_apk("org.fdroid.fdroid"),
    tempdir / "F-Droid.apk",
)

os.chdir(tempdir)
run("zip", "-r", outzip, ".").must_succeed()
