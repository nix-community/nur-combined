import importlib.util
import json
import os
import signal
import socket
import subprocess
import sys
import tempfile
import time
import unittest
from collections.abc import Iterator, Mapping
from pathlib import Path
from types import ModuleType
from typing import NotRequired, Protocol, TypedDict, cast
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[3]


class Field(TypedDict):
    kind: str
    default: str
    min: NotRequired[int | float]
    max: NotRequired[int]
    values: NotRequired[list[str]]


class Schema(TypedDict):
    fields: dict[str, Field]
    protocolVersion: int


class RpcConnection(Protocol):
    def send(self, payload: str) -> object: ...
    def settimeout(self, timeout: float) -> None: ...
    def recv(self) -> str | bytes: ...
    def close(self) -> None: ...


class Client(Protocol):
    def call(
        self, method: str, params: Mapping[str, object] | None = None
    ) -> dict[str, object]: ...


class RetryError(Protocol):
    retryable: bool


class Helper(Protocol):
    ConfigurationError: type[Exception]

    def RpcError(self, error: Mapping[str, object]) -> Exception: ...
    def RpcClient(self, connection: RpcConnection) -> Client: ...
    def load_settings(
        self,
        declared: Mapping[str, object],
        secret_file: str | Path | None,
        schema: Schema,
    ) -> dict[str, str]: ...
    def runtime_endpoint(self) -> tuple[str, str]: ...
    def apply_settings(
        self,
        url: str,
        token_file: str | Path,
        values: Mapping[str, str],
        protocol: int,
        timeout: float = 45,
    ) -> None: ...
    def connect(self, url: str, **options: object) -> RpcConnection: ...
    def object_dict(self, value: object) -> dict[str, object]: ...


class Generator(Protocol):
    def parse_fields(self, source: str) -> dict[str, dict[str, object]]: ...


def load_module(name: str, path: Path) -> ModuleType:
    spec = importlib.util.spec_from_file_location(name, path)
    if spec is None or spec.loader is None:
        raise ImportError("Cannot load test module: " + name)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


helper = cast(
    Helper,
    cast(object, load_module("configure", ROOT / "modules/fluxdown-configure.py")),
)
generator = cast(
    Generator,
    cast(
        object,
        load_module("generator", ROOT / "pkgs/fluxdown-server/update-settings.py"),
    ),
)
SCHEMA = cast(
    Schema, json.loads((ROOT / "pkgs/fluxdown-server/settings-schema.json").read_text())
)


class SettingsTests(unittest.TestCase):
    def test_all_defaults(self):
        values: dict[str, object] = {}
        for name, field in SCHEMA["fields"].items():
            if field["kind"] != "ReadOnly":
                values[name] = (
                    cast(object, json.loads(field["default"]))
                    if field["kind"] in ("Bool", "Integer", "Float")
                    else field["default"]
                )
        self.assertEqual(helper.load_settings(values, None, SCHEMA).keys(), values.keys())

    def test_invalid_values(self):
        for settings in [
            {"upload_limit_bytes": -1},
            {"upload_limit_bytes": True},
            {"max_concurrent_tasks": 1025},
            {"bt_enable_upnp": "false"},
            {"bt_enabled": "false"},
            {"file_exists_behavior": "unknown"},
            {"bt_mse_mode": "unknown"},
            {"bt_seed_ratio_limit": float("nan")},
            {"bt_seed_ratio_limit": float("inf")},
            {"domain_conn_caps": "x"},
            {"unknown": 1},
        ]:
            with (
                self.subTest(settings=settings),
                self.assertRaises(helper.ConfigurationError),
            ):
                _ = helper.load_settings(settings, None, SCHEMA)

    def test_secret_file(self):
        with tempfile.TemporaryDirectory() as folder:
            path = Path(folder) / "settings.json"
            _ = path.write_text(json.dumps({"proxy_password": "private-test-value"}))
            self.assertEqual(
                helper.load_settings({}, path, SCHEMA),
                {"proxy_password": "private-test-value"},
            )
            with self.assertRaises(helper.ConfigurationError):
                _ = helper.load_settings({"proxy_password": "duplicate"}, path, SCHEMA)

    def test_null_and_endpoints(self):
        self.assertEqual(
            helper.load_settings({"upload_limit_bytes": None}, None, SCHEMA), {}
        )
        for bind, expected in [
            ("0.0.0.0:17800", "127.0.0.1:17800"),
            ("[::]:17800", "[::1]:17800"),
            ("192.168.42.42:17800", "192.168.42.42:17800"),
        ]:
            with patch.dict(os.environ, {"FLUXDOWN_BIND": bind}, clear=True):
                self.assertEqual(
                    helper.runtime_endpoint(),
                    (f"ws://{expected}/rpc", "/var/lib/fluxdown/agent/agent.token"),
                )

    def test_parser_fails_closed(self):
        prefix = "pub const DAEMON_CONFIG_FIELDS: &[DaemonConfigField] = &["
        self.assertEqual(
            generator.parse_fields(
                prefix + 'field("enabled", DaemonConfigKind::Bool, "false"),];'
            )["enabled"]["kind"],
            "Bool",
        )
        for entry in [
            "",
            'new_field("x"),',
            'field("x", DaemonConfigKind::NewType, ""),',
        ]:
            with self.assertRaises(ValueError):
                _ = generator.parse_fields(prefix + entry + "];")

    def test_rpc_events_and_error_redaction(self):
        class Connection:
            responses: Iterator[str] = iter(())

            def send(self, payload: str) -> None:
                _ = payload

            def settimeout(self, timeout: float) -> None:
                _ = timeout

            def recv(self) -> str:
                return next(self.responses)

            def close(self) -> None:
                pass

        connection = Connection()
        connection.responses = iter(
            [
                json.dumps({"method": "event"}),
                json.dumps({"id": 1, "result": {"ok": True}}),
            ]
        )
        self.assertEqual(helper.RpcClient(connection).call("test"), {"ok": True})
        error = helper.RpcError({"message": "secret", "data": {"code": "conflict"}})
        self.assertTrue(cast(RetryError, cast(object, error)).retryable)
        self.assertNotIn("secret", str(error))

    def test_conflict_retry_and_timeout(self):
        with tempfile.TemporaryDirectory() as folder:
            token_file = Path(folder) / "agent.token"
            _ = token_file.write_text("private-test-token")
            conflict = helper.RpcError({"data": {"code": "conflict"}})
            with (
                patch.object(helper, "connect"),
                patch.object(
                    helper.RpcClient,
                    "call",
                    side_effect=[
                        {},
                        {"revision": 1, "values": {}},
                        conflict,
                        {},
                        {"revision": 2, "values": {}},
                        {},
                    ],
                ) as calls,
                patch.object(time, "sleep"),
            ):
                helper.apply_settings(
                    "ws://127.0.0.1:1/rpc", token_file, {"upload_limit_bytes": "1"}, 6
                )
                self.assertEqual(calls.call_count, 6)
                assert calls.call_args is not None
                self.assertEqual(
                    cast(dict[str, object], calls.call_args.args[1])[
                        "expectedRevision"
                    ],
                    2,
                )
            with self.assertRaises(helper.ConfigurationError):
                helper.apply_settings(
                    "ws://127.0.0.1:1/rpc", token_file, {}, 6, timeout=0
                )

    def test_resume_all_after_configuration(self):
        cases: list[tuple[dict[str, str], dict[str, str], bool, bool]] = [
            ({"auto_resume_on_start": "true"}, {}, True, True),
            (
                {"auto_resume_on_start": "true"},
                {"auto_resume_on_start": "true"},
                False,
                True,
            ),
            ({"upload_limit_bytes": "1"}, {"auto_resume_on_start": "true"}, True, True),
            (
                {"auto_resume_on_start": "false"},
                {"auto_resume_on_start": "true"},
                True,
                False,
            ),
            ({"upload_limit_bytes": "1"}, {}, True, False),
        ]
        with tempfile.TemporaryDirectory() as folder:
            token_file = Path(folder) / "agent.token"
            _ = token_file.write_text("private-test-token")
            for declared, stored, changes, resume in cases:
                responses: list[dict[str, object]] = [
                    {},
                    {"revision": 1, "values": stored},
                ]
                responses += [{}] * (int(changes) + int(resume))
                with (
                    self.subTest(declared=declared, stored=stored),
                    patch.object(helper, "connect"),
                    patch.object(
                        helper.RpcClient, "call", side_effect=responses
                    ) as calls,
                ):
                    helper.apply_settings(
                        "ws://127.0.0.1:1/rpc", token_file, declared, 6
                    )
                    methods = [cast(str, item.args[0]) for item in calls.call_args_list]
                    expected = ["system.hello", "daemon.config.get"]
                    if changes:
                        expected.append("daemon.config.patch")
                    if resume:
                        expected.append("daemon.task.resumeAll")
                    self.assertEqual(methods, expected)

    def test_failed_patch_does_not_resume(self):
        with tempfile.TemporaryDirectory() as folder:
            token_file = Path(folder) / "agent.token"
            _ = token_file.write_text("private-test-token")
            with (
                patch.object(helper, "connect"),
                patch.object(
                    helper.RpcClient,
                    "call",
                    side_effect=[
                        {},
                        {"revision": 1, "values": {}},
                        helper.RpcError({"data": {"code": "invalidArgument"}}),
                    ],
                ) as calls,
            ):
                with self.assertRaises(helper.ConfigurationError):
                    helper.apply_settings(
                        "ws://127.0.0.1:1/rpc",
                        token_file,
                        {"auto_resume_on_start": "true"},
                        6,
                    )
                self.assertNotIn(
                    "daemon.task.resumeAll",
                    [cast(str, item.args[0]) for item in calls.call_args_list],
                )

    @unittest.skipUnless(
        os.environ.get("FLUXDOWN_TEST_PACKAGE"),
        "Set FLUXDOWN_TEST_PACKAGE for isolated integration tests",
    )
    def test_live_server(self):
        with tempfile.TemporaryDirectory(prefix="fluxdown-settings-test-") as folder:
            reservations = [socket.socket(), socket.socket()]
            for reservation in reservations:
                reservation.bind(("127.0.0.1", 0))
            port, daemon_port = [
                cast(tuple[str, int], reservation.getsockname())[1]
                for reservation in reservations
            ]
            for reservation in reservations:
                reservation.close()
            env = os.environ | {
                "FLUXDOWN_BIND": f"127.0.0.1:{port}",
                "FLUXDOWN_DAEMON_BIND": f"127.0.0.1:{daemon_port}",
                "FLUXDOWN_DAEMON_URL": f"ws://127.0.0.1:{daemon_port}/rpc",
                "FLUXDOWN_DATA_DIR": folder,
                "FLUXDOWN_SAVE_DIR": folder + "/downloads",
                "FLUXDOWN_MDNS": "false",
                "FLUXDOWN_ANALYTICS": "false",
            }
            url = f"ws://127.0.0.1:{port}/rpc"
            token_file = Path(folder) / "agent/agent.token"
            for iteration in range(2):
                with open(Path(folder) / "test.log", "w") as log:
                    process = subprocess.Popen(
                        [
                            os.environ["FLUXDOWN_TEST_PACKAGE"] + "/bin/fluxdown-agent",
                            "--server",
                        ],
                        env=env,
                        stdout=log,
                        stderr=log,
                        start_new_session=True,
                    )
                    try:
                        values = (
                            {
                                "upload_limit_bytes": "1048576",
                                "max_concurrent_tasks": "3",
                                "bt_enable_upnp": "false",
                                "bt_enabled": "false",
                                "file_exists_behavior": "ask",
                                "auto_resume_on_start": "true",
                            }
                            if iteration == 0
                            else {}
                        )
                        helper.apply_settings(
                            url, token_file, values, SCHEMA["protocolVersion"]
                        )
                        connection = helper.connect(
                            url,
                            header={
                                "Authorization": "Bearer "
                                + token_file.read_text().strip()
                            },
                            suppress_origin=True,
                            timeout=5,
                            http_no_proxy=["*"],
                        )
                        try:
                            client = helper.RpcClient(connection)
                            _ = client.call(
                                "system.hello",
                                {
                                    "clientName": "test",
                                    "clientVersion": "1",
                                    "minProtocolVersion": SCHEMA["protocolVersion"],
                                    "maxProtocolVersion": SCHEMA["protocolVersion"],
                                    "requestedRole": "agent",
                                    "capabilities": [],
                                },
                            )
                            snapshot = client.call("daemon.config.get")
                            self.assertEqual(
                                helper.object_dict(snapshot["values"])[
                                    "upload_limit_bytes"
                                ],
                                "1048576",
                            )
                            self.assertEqual(
                                helper.object_dict(snapshot["values"])[
                                    "max_concurrent_tasks"
                                ],
                                "3",
                            )
                            for name, expected in {
                                "bt_enabled": "false",
                                "file_exists_behavior": "ask",
                            }.items():
                                self.assertEqual(
                                    helper.object_dict(snapshot["values"])[name], expected
                                )
                            revision = snapshot["revision"]
                            helper.apply_settings(
                                url,
                                token_file,
                                {"upload_limit_bytes": "1048576"},
                                SCHEMA["protocolVersion"],
                            )
                            self.assertEqual(
                                client.call("daemon.config.get")["revision"], revision
                            )
                            if iteration == 0:
                                path = Path(folder) / "declared.json"
                                _ = path.write_text(
                                    json.dumps({"speed_limit_bytes": 2097152})
                                )
                                _ = subprocess.run(
                                    [
                                        sys.executable,
                                        str(ROOT / "modules/fluxdown-configure.py"),
                                        str(path),
                                        str(
                                            ROOT
                                            / "pkgs/fluxdown-server/settings-schema.json"
                                        ),
                                    ],
                                    env=env,
                                    check=True,
                                )
                            self.assertEqual(
                                helper.object_dict(
                                    client.call("daemon.config.get")["values"]
                                )["speed_limit_bytes"],
                                "2097152",
                            )
                            with self.assertRaises(helper.ConfigurationError):
                                helper.apply_settings(
                                    url,
                                    token_file,
                                    {"component_mirror_base": "http://invalid.test"},
                                    SCHEMA["protocolVersion"],
                                )
                        finally:
                            connection.close()
                    finally:
                        process.send_signal(signal.SIGTERM)
                        try:
                            _ = process.wait(timeout=15)
                        except subprocess.TimeoutExpired:
                            os.killpg(process.pid, signal.SIGKILL)
                            _ = process.wait()
                        self.assertEqual(process.returncode, 0)


if __name__ == "__main__":
    _ = unittest.main()
