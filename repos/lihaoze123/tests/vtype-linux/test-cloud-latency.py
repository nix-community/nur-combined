#!/usr/bin/env python3
"""离线核对官方引擎的云响应时限；不联网、不读取账户或个人词库。"""

import argparse
import os
from pathlib import Path
import re
import selectors
import socket
import subprocess
import sys
import tempfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, required=True)
    parser.add_argument("--package", type=Path, required=True)
    parser.add_argument("--engine-dir", type=Path,
                        default=Path.home() / ".local/lib/wetype-ime/arm64")
    args = parser.parse_args()
    sys.path.insert(0, str(args.source / "scripts"))
    from test_bionic_daemon import Engine, disable_core_dumps

    for cloud, expected in [(False, 200), (True, 1500)]:
        with tempfile.TemporaryDirectory(prefix="vtype-cloud-latency.") as directory:
            root = Path(directory)
            work = root / "dict"
            (work / "userdict/v5").mkdir(parents=True)
            (work / "userdict/user_hot_word").mkdir(parents=True)
            runtime = args.engine_dir.resolve()
            package = args.package.resolve()
            env = os.environ.copy()
            for key in ("WETYPE_CLOUD_NATIVE", "WETYPE_CLOUD_FD", "WETYPE_SYNC_FD",
                        "WETYPE_COS_FD", "WETYPE_GROUP_SYNC", "WETYPE_UIN", "QEMU_SET_ENV"):
                env.pop(key, None)
            env.update(LD_LIBRARY_PATH=str(runtime / "lib"), WETYPE_DOUBLE_PIN="0",
                       WETYPE_DICT_DIR=str(runtime / "dicts"),
                       WETYPE_ASSET_DIR=str(runtime / "dicts"), WETYPE_WORK_DIR=str(work),
                       QEMU_CPU="cortex-a72")
            # 只有本地 socketpair，没有宿主 HTTP 代理，云请求不会离开进程。
            host, guest = socket.socketpair(socket.AF_UNIX, socket.SOCK_SEQPACKET)
            try:
                if cloud:
                    env.update(WETYPE_CLOUD_NATIVE="1", WETYPE_CLOUD_FD=str(guest.fileno()),
                               QEMU_SET_ENV="LD_PRELOAD=" + str(runtime / "libwetype-cloud.so"))
                with (root / "engine.log").open("wb") as log:
                    engine = Engine.__new__(Engine)
                    engine.process = subprocess.Popen(
                        [str(package / "libexec/qemu-aarch64-static"), "-L",
                         str(runtime / "sysroot"), str(package / "libexec/wetype-harness"),
                         str(runtime / "lib/libwxhld_jni.so"), "--daemon"],
                        stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=log, env=env,
                        pass_fds=(guest.fileno(),) if cloud else (), bufsize=0,
                        preexec_fn=disable_core_dumps)
                    engine.selector = selectors.DefaultSelector()
                    engine.selector.register(engine.process.stdout, selectors.EVENT_READ)
                    engine.buffer = b""
                    engine.log = log
                    try:
                        engine.wait_for("READY", 30)
                        engine.command("C", "OK")
                        engine.command("OPT spans", "OK")
                        assert engine.candidates("nihao")[0] == (5, "你好")
                    finally:
                        engine.close()
                values = [int(x) for x in re.findall(
                    rb"\[CloudTimeOutMs\] max_timeout_ms_: (\d+)",
                    (root / "engine.log").read_bytes())]
                assert len(values) >= 2 and set(values) == {expected}, values
                print(f"PASS cloud={cloud}: 原生时限 {expected}ms，重建会话及本地候选")
            finally:
                host.close()
                guest.close()


if __name__ == "__main__":
    main()
