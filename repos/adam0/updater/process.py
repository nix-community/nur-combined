from __future__ import annotations

import json
import logging
import subprocess
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
logger = logging.getLogger(__name__)


class CommandError(RuntimeError):
    def __init__(self, command: list[str], result: subprocess.CompletedProcess[str]) -> None:
        self.command = command
        self.result = result
        self.details = result.stderr.strip() or result.stdout.strip() or "command failed"
        super().__init__(_summarize_error(self.details))


def run(
    command: list[str],
    *,
    check: bool = True,
    timeout: str | None = None,
    cwd: Path = ROOT,
) -> subprocess.CompletedProcess[str]:
    actual = command
    if timeout and timeout != "0":
        actual = ["timeout", "--foreground", timeout, *command]

    logger.info("running: %s", " ".join(actual))
    result = subprocess.run(
        actual,
        cwd=cwd,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    logger.info("command exited %d: %s", result.returncode, " ".join(actual))
    if check and result.returncode != 0:
        raise CommandError(actual, result)
    return result


def run_json(command: list[str], **kwargs: Any) -> Any:
    return json.loads(run(command, **kwargs).stdout)


def _summarize_error(details: str) -> str:
    lines = [line.strip() for line in details.splitlines() if line.strip()]
    if not lines:
        return "command failed"

    for line in reversed(lines):
        if "Error:" in line:
            return line
    return lines[-1]
