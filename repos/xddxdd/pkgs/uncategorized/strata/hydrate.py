import fcntl
import filecmp
import os
import shutil
import stat
import sys
import tempfile
from pathlib import Path


def directory(path):
    if path.is_symlink() or (path.exists() and not path.is_dir()):
        raise RuntimeError(f"refusing to hydrate through non-directory {path}")
    path.mkdir(parents=True, exist_ok=True)


def hydrate(source, dest):
    source, dest = Path(source), Path(dest)
    directory(dest)
    marker = dest / ".nix-store-path"
    if marker.is_symlink():
        raise RuntimeError(f"refusing symlink marker {marker}")
    lock = os.open(
        dest / ".nix-hydrate.lock", os.O_CREAT | os.O_RDWR | os.O_NOFOLLOW, 0o600
    )
    with os.fdopen(lock, "w") as handle:
        fcntl.flock(handle, fcntl.LOCK_EX)
        if marker.exists() and marker.read_text().strip() == str(source):
            return
        backup = None

        def merge(src, dst, relative, data=False):
            nonlocal backup
            exists = dst.exists() or dst.is_symlink()
            if (
                data
                and exists
                and (not src.is_dir() or dst.is_symlink() or not dst.is_dir())
            ):
                return
            if src.is_dir():
                directory(dst)
                for child in sorted(src.iterdir()):
                    merge(child, dst / child.name, relative / child.name, data)
                return
            if exists:
                if dst.is_dir() and not dst.is_symlink():
                    raise RuntimeError(f"refusing to replace directory {dst}")
                if not dst.is_symlink() and filecmp.cmp(src, dst, shallow=False):
                    return
                if backup is None:
                    backup = Path(tempfile.mkdtemp(prefix=".nix-backup-", dir=dest))
                saved = backup / relative
                directory(saved.parent)
                shutil.copy2(dst, saved, follow_symlinks=False)
            fd, name = tempfile.mkstemp(prefix=".nix-copy-", dir=dst.parent)
            os.close(fd)
            try:
                shutil.copy2(src, name)
                os.chmod(name, stat.S_IMODE(src.stat().st_mode) | stat.S_IWUSR)
                os.replace(name, dst)
            finally:
                if os.path.exists(name):
                    os.unlink(name)

        for child in sorted(source.iterdir()):
            merge(child, dest / child.name, Path(child.name), child.name == "data")
        fd, name = tempfile.mkstemp(prefix=".nix-marker-", dir=dest)
        with os.fdopen(fd, "w") as handle:
            handle.write(str(source) + "\n")
        os.replace(name, marker)
        if backup is not None:
            print(
                f"Strata: previous application files saved in {backup}", file=sys.stderr
            )


if __name__ == "__main__":
    hydrate(*sys.argv[1:])
