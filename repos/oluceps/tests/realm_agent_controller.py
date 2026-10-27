"""Disposable delegated systemd controller for authorized integration fixtures."""
import subprocess
import time

class TestController:
    unit = "realm-agent-integration-controller.service"

    def __init__(self, agent, config, unit="realm-agent-integration-controller.service"):
        self.unit = unit
        subprocess.run([
            "systemd-run", "--quiet", "--collect", "--unit=" + self.unit,
            "--property=Type=exec", "--property=Delegate=cpu memory pids",
            "--property=DelegateSubgroup=supervisor", "--property=OOMPolicy=continue",
            "--property=RuntimeMaxSec=180", agent, "serve", "--config", str(config),
        ], check=True)
        self.pid = int(subprocess.check_output(["systemctl", "show", self.unit, "-p", "MainPID", "--value"], text=True))

    def poll(self):
        r = subprocess.run(["systemctl", "is-active", "--quiet", self.unit])
        return None if r.returncode == 0 else 1

    def terminate(self):
        subprocess.run(["systemctl", "stop", self.unit], check=False)

    def wait(self, timeout=10):
        deadline = time.monotonic() + timeout
        while self.poll() is None:
            if time.monotonic() >= deadline:
                raise subprocess.TimeoutExpired(self.unit, timeout)
            time.sleep(.1)
        return 0

    def kill(self):
        subprocess.run(["systemctl", "kill", "--signal=KILL", self.unit], check=False)
