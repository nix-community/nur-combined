import errno
import os
import secrets
import sys
import typing

import nixdata

XATTR = "user.vacuAgentsMd.deployed"


def die(msg: str) -> typing.NoReturn:
    print(f"ERR: {msg}", file=sys.stderr)
    sys.exit(1)


name = nixdata.name
dst = os.path.join(nixdata.dst_dir, name)

# dst_dir is owned by an untrusted user; every op is relative to this fd and never follows symlinks
dir_fd = os.open(nixdata.dst_dir, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW)

try:
    existing = os.open(name, os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK, dir_fd=dir_fd)
except FileNotFoundError:
    pass
except OSError as e:
    if e.errno == errno.ELOOP:
        die(f"Will not overwrite {dst}: already exists (symlink)")
    raise
else:
    try:
        os.getxattr(existing, XATTR)
    except OSError:
        die(f"Will not overwrite {dst}: already exists and not created by me")
    finally:
        os.close(existing)

tmp = f".tmp.vacuAgentsMd.{secrets.token_hex(8)}"
# setting user.* xattrs requires write permission, so create writable and chmod after
fd = os.open(
    tmp,
    os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW,
    0o600,
    dir_fd=dir_fd,
)
try:
    try:
        os.setxattr(fd, XATTR, b"")
    except OSError as e:
        die(
            f"Could not set xattr on {nixdata.dst_dir}/{tmp} (xattr not supported on fs?): {e}"
        )
    os.write(fd, nixdata.contents.encode())
    os.fchmod(fd, 0o444)
    os.fsync(fd)
    os.close(fd)
    os.rename(tmp, name, src_dir_fd=dir_fd, dst_dir_fd=dir_fd)
except BaseException:
    os.unlink(tmp, dir_fd=dir_fd)
    raise
