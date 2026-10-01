import argparse
import json
import math
import os
import sys
import time
from collections.abc import Mapping
from pathlib import Path
from typing import NotRequired, Protocol, TypedDict, cast

import websocket


class Field(TypedDict):
    kind: str
    default: str
    min: NotRequired[int | float]
    max: NotRequired[int]
    values: NotRequired[list[str]]


class Schema(TypedDict):
    fields: dict[str, Field]
    protocolVersion: int


class Connection(Protocol):
    def send(self, payload: str) -> object: ...
    def settimeout(self, timeout: float) -> None: ...
    def recv(self) -> str | bytes: ...
    def close(self) -> None: ...


class ConnectionFactory(Protocol):
    def __call__(self, url: str, **options: object) -> Connection: ...


def connect(url: str, **options: object) -> Connection:
    factory = cast(ConnectionFactory, websocket.create_connection)
    return factory(url, **options)


class ConfigurationError(Exception):
    pass


def object_dict(value: object) -> dict[str, object]:
    if not isinstance(value, dict):
        raise ConfigurationError("Expected a JSON object")
    return cast(dict[str, object], value)


def read_object(path: str | Path) -> dict[str, object]:
    return object_dict(cast(object, json.loads(Path(path).read_text())))


class RpcError(Exception):
    retryable: bool

    def __init__(self, error: Mapping[str, object]) -> None:
        data = object_dict(error.get("data", {}))
        self.retryable = data.get("retryable") is True or data.get("code") in (
            "conflict",
            "unavailable",
            "timeout",
        )
        super().__init__("FluxDown rejected the settings RPC")


def load_settings(
    declared: Mapping[str, object], secret_file: str | Path | None, schema: Schema
) -> dict[str, str]:
    values = dict(declared)
    if secret_file:
        private = read_object(secret_file)
        if values.keys() & private.keys():
            raise ConfigurationError(
                "settings and settingsFile must not contain duplicate keys"
            )
        values.update(private)
    result: dict[str, str] = {}
    for name, value in values.items():
        field = schema["fields"].get(name)
        if field is None or field["kind"] == "ReadOnly":
            raise ConfigurationError("Unknown or read-only daemon setting")
        if value is None:
            continue
        kind = field["kind"]
        if kind == "Bool":
            valid = type(value) is bool
        elif kind == "Integer":
            valid = type(value) is int and field.get("min", 0) <= value <= field.get(
                "max", 9223372036854775807
            )
        elif kind == "Float":
            valid = (
                type(value) in (int, float)
                and math.isfinite(cast(int | float, value))
                and cast(int | float, value) >= field.get("min", 0)
            )
        elif kind == "Enum":
            valid = isinstance(value, str) and value in field.get("values", [])
        else:
            valid = isinstance(value, str)
        if not valid:
            raise ConfigurationError("Invalid daemon setting type or range")
        result[name] = ("true" if value else "false") if kind == "Bool" else str(value)
    return result


class RpcClient:
    connection: Connection
    sequence: int

    def __init__(self, connection: Connection) -> None:
        self.connection = connection
        self.sequence = 0

    def call(
        self, method: str, params: Mapping[str, object] | None = None
    ) -> dict[str, object]:
        self.sequence += 1
        request: dict[str, object] = {
            "jsonrpc": "2.0",
            "id": self.sequence,
            "method": method,
        }
        if params is not None:
            request["params"] = params
        _ = self.connection.send(json.dumps(request))
        deadline = time.monotonic() + 5
        while time.monotonic() < deadline:
            self.connection.settimeout(max(0.01, deadline - time.monotonic()))
            response = object_dict(cast(object, json.loads(self.connection.recv())))
            if response.get("id") != self.sequence:
                continue
            if "error" in response:
                raise RpcError(object_dict(response["error"]))
            return object_dict(response["result"])
        raise TimeoutError("RPC response timed out")


def apply_settings(
    url: str,
    token_file: str | Path,
    values: Mapping[str, str],
    protocol: int,
    timeout: float = 45,
) -> None:
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        connection: Connection | None = None
        try:
            token = Path(token_file).read_text().strip()
            if not token:
                raise OSError("Agent token is not ready")
            connection = connect(
                url,
                header={"Authorization": "Bearer " + token},
                suppress_origin=True,
                timeout=5,
                http_no_proxy=["*"],
            )
            client = RpcClient(connection)
            _ = client.call(
                "system.hello",
                {
                    "clientName": "nixos-settings",
                    "clientVersion": "1",
                    "minProtocolVersion": protocol,
                    "maxProtocolVersion": protocol,
                    "requestedRole": "agent",
                    "capabilities": [],
                },
            )
            snapshot = client.call("daemon.config.get")
            stored = object_dict(snapshot["values"])
            changes = {
                name: value
                for name, value in values.items()
                if stored.get(name) != value
            }
            if changes:
                _ = client.call(
                    "daemon.config.patch",
                    {"expectedRevision": snapshot["revision"], "values": changes},
                )
            auto_resume = values.get(
                "auto_resume_on_start", str(stored.get("auto_resume_on_start", "false"))
            )
            if auto_resume in ("true", "1"):
                _ = client.call("daemon.task.resumeAll")
            return
        except RpcError as error:
            if not error.retryable:
                raise ConfigurationError(
                    "FluxDown rejected declared settings; check the pinned upstream contract"
                ) from None
        except (OSError, websocket.WebSocketException):
            pass
        finally:
            if connection is not None:
                connection.close()
        time.sleep(0.2)
    raise ConfigurationError("Timed out applying settings to FluxDown")


def runtime_endpoint() -> tuple[str, str]:
    bind = os.environ.get("FLUXDOWN_BIND", "127.0.0.1:17800")
    host, port = bind.rsplit(":", 1)
    host = {"0.0.0.0": "127.0.0.1", "[::]": "[::1]"}.get(host, host)
    root = Path(os.environ.get("FLUXDOWN_DATA_DIR", "/var/lib/fluxdown"))
    agent_dir = Path(os.environ.get("FLUXDOWN_AGENT_DATA_DIR", str(root / "agent")))
    token_file = os.environ.get(
        "FLUXDOWN_AGENT_TOKEN_FILE", str(agent_dir / "agent.token")
    )
    return f"ws://{host}:{port}/rpc", token_file


class Arguments(argparse.Namespace):
    settings: str = ""
    schema: str = ""
    settings_file: str | None = None


def main() -> int:
    parser = argparse.ArgumentParser()
    _ = parser.add_argument("settings")
    _ = parser.add_argument("schema")
    _ = parser.add_argument("--settings-file")
    args = parser.parse_args(namespace=Arguments())
    try:
        schema = cast(Schema, cast(object, read_object(args.schema)))
        values = load_settings(read_object(args.settings), args.settings_file, schema)
        if values:
            url, token_file = runtime_endpoint()
            apply_settings(url, token_file, values, schema["protocolVersion"])
    except ConfigurationError as error:
        print(str(error), file=sys.stderr)
        return 1
    except (OSError, ValueError, KeyError, TypeError, websocket.WebSocketException):
        print(
            "Failed to apply FluxDown settings; check file permissions and configuration",
            file=sys.stderr,
        )
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
