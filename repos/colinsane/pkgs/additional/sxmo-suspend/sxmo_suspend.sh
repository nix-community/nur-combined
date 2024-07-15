#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python3 -p rtl8723cs-wowlan -p util-linux
"""
replacement `sxmo_suspend.sh` hook for the [SXMO](https://sxmo.org) desktop
which integrates with [ntfy](https://ntfy.sh) in order to stay in deep sleep
until actively woken by a notification.
"""

# yeah, this isn't technically a hook, but the hook infrastructure isn't actually
# restricted to stuff that starts with sxmo_hook_ ...
#
# this script is only called by sxmo_autosuspend, which is small, so if i wanted to
# be more proper i could instead re-implement autosuspend + integrations.
#
# N.B.: if any wake locks are acquired between invocation of this script and the
# rtcwake call below, suspend will fail -- even if those locks are released during
# the same period.
#
# this is because the caller of this script writes /sys/power/wakeup_count, and the
# kernel checks consistency with that during the actual suspend request.
# see: <https://www.kernel.org/doc/Documentation/ABI/testing/sysfs-power>
#
# for this reason, keep this script as short as possible.
#
# common sources of wakelocks (which one may wish to reduce) include:
# - `sxmo_led.sh blink` (every 2s, by default)

import argparse
import logging
import socket
import subprocess
import time

logger = logging.getLogger(__name__)

NTFY_HOST = 'uninsane.org'
NTFY_PORT_BASE = 5550

# duration in seconds to sleep for
SUSPEND_TIME = 300
# take care that WOWLAN_DELAY might include more than you think (e.g. time spent configuring wowlan pattern rules)
WOWLAN_DELAY = 6

# SXMO LED blink frequency to set on resume
BLINK_FREQ = 5

class Executor:
    def __init__(self, dry_run: bool = False):
        self.dry_run = dry_run

    def exec(self, cmd: list[str], sudo: bool = False, check: bool = True, wait: bool = True):
        if check: assert wait, "can't check_output without first waiting for process completion"

        if sudo:
            cmd = [ 'doas' ] + cmd

        logger.debug(" ".join(cmd))
        if self.dry_run:
            return

        if wait:
            try:
                res = subprocess.run(cmd, capture_output=True)
            except Exception as e:
                if check: raise
                logger.warning(f"error invoking subprocess: {e}")
                return

            logger.debug(res.stdout)
            if res.stderr:
                logger.warning(res.stderr)
            if check:
                res.check_returncode()

        else:
            res = subprocess.Popen(cmd)

        return res

    def try_connect(self, dest, delay):
        logger.debug(f"opening socket to {dest} with timeout {delay}")
        if self.dry_run:
            return None

        try:
            return socket.create_connection(dest, delay)
        except Exception as e:
            logger.warning(f"failed to connect: {e}")


class Suspender:
    def __init__(self, executor: Executor, wowlan_delay: float):
        self.executor = executor
        self.wowlan_delay = wowlan_delay
        self.ntfy_socket = None

    def ntfy_addr(self) -> (int, int|None, str|None):
        ''' returns (remote port, local port, local ip) '''
        remote_port = NTFY_PORT_BASE + self.wowlan_delay
        local_ip, local_port = self.ntfy_socket.getsockname() if self.ntfy_socket is not None else (None, None)
        return remote_port, local_port, local_ip

    def open_ntfy_stream(self):
        self.ntfy_socket = self.executor.try_connect((NTFY_HOST, self.ntfy_addr()[0]), 0.5*self.wowlan_delay)

    def close_ntfy_stream(self):
        ''' call before exit to ensure socket is cleanly shut down and not leaked '''
        try:
            self.ntfy_socket.shutdown(socket.SHUT_RDWR)
            self.ntfy_socket.close()
        except:
            pass  # shutdown can error if the socket was already terminated (by the remote)

    def configure_wowlan(self):
        # TODO: don't do this wowlan stuff every single time.
        # - it's costly (can take like 1sec)
        # alternative is to introduce some layer of cache:
        # - do so in a way such that WiFi connection state changes invalidate the cache
        #   - because wowlan enable w/o connection may well behave differently than w/ connection
        # - calculating IP addr from link, and then caching on the args we call our helper with may well suffice
        # and no need to invoke a subprocess here, when it's just python code calling other python code!

        self.executor.exec(['rtl8723cs-wowlan', 'enable-clean'], sudo=True, check=False)

        # wake on ssh
        self.executor.exec(['rtl8723cs-wowlan', 'tcp', '--dest-port', '22', '--dest-ip', 'SELF'], sudo=True, check=False)

        # wake on notification (ntfy/Universal Push)
        remote_port, local_port, local_ip = self.ntfy_addr()
        dest_port_args = ['--dest-port', str(local_port)] if local_port is not None else []
        dest_ip_args = ['--dest-ip', local_ip] if local_ip is not None else ['--dest-ip', 'SELF']
        self.executor.exec(['rtl8723cs-wowlan', 'tcp', '--source-port', str(remote_port)] + dest_port_args + dest_ip_args, sudo=True, check=False)

        # wake if someone doesn't know how to route to us, because that could obstruct the above
        # self.executor.exec(['rtl8723cs-wowlan', 'arp', '--dest-ip', 'SELF'], sudo=True, check=False)
        # specifically wake upon ARP request via the broadcast address.
        # peers don't usually go straight for broadcast, but rather try ARPing the mac they knew us on.
        # hence, waking on broadcast makes this a bit less racy (less likely to see broadcast ARP immediately upon suspend enter).
        # N.B.: wowlan also offloads arp, so this rule shouldn't be exercised except when things glitch.
        self.executor.exec(['rtl8723cs-wowlan', 'arp', '--dest-ip', 'SELF', '--dest-mac', 'ff:ff:ff:ff:ff:ff'], sudo=True, check=False)

    def suspend(self, duration: int, mode: str):
        logger.info(f"calling suspend for duration: {duration}")
        if mode == 'rtcwake':
            self.executor.exec(['rtcwake', '-m', 'mem', '-s', str(duration)], sudo=True, check=False)
        elif mode == 'sleep':
            time.sleep(duration)
        else:
            assert False, f"unknown suspend mode: {mode}"


class SxmoApi:
    def __init__(self, executor: Executor):
        self.executor = executor

    def halt_services(self) -> None:
        res = self.executor.exec(['sxmo_jobs.sh', 'running', 'periodic_blink'], check=False)
        self.was_blinking = res and res.returncode == 0
        if self.was_blinking:
            self.executor.exec(['sxmo_jobs.sh', 'stop', 'periodic_blink'], check=False)

    def resume_services(self) -> None:
        if self.was_blinking:
            # XXX: sxmo_jobs.sh is supposed to run the job in the background, but somehow it fails (blocks), only when invoked from Python.
            #      oh well, just call it asynchronously (wait=False)
            self.executor.exec(['sxmo_jobs.sh', 'start', 'periodic_blink', 'sxmo_run_periodically.sh', str(BLINK_FREQ), 'sxmo_led.sh', 'blink', 'red', 'blue'], check=False, wait=False)

    def call_postwake_hook(self) -> None:
        self.executor.exec(['sxmo_hook_postwake.sh'], check=False)


def main():
    logging.basicConfig()
    logging.getLogger().setLevel(logging.INFO)

    parser = argparse.ArgumentParser(description="suspend the pinephone to RAM, and configure wake triggers to make that appear more transparent")
    parser.add_argument("--dry-run", action='store_true', help="print commands instead of executing them")
    parser.add_argument("--verbose", action='store_true', help="log each command before executing")
    parser.add_argument("--duration", type=int, default=SUSPEND_TIME, help="maximum duration to sleep for, in seconds")
    parser.add_argument("--wowlan-delay", type=int, default=WOWLAN_DELAY, help="minimum number of seconds after entering sleep during which wowlan is racy")
    parser.add_argument("--suspend-mode", choices=['rtcwake', 'sleep'], default='rtcwake', help="how to sleep")

    args = parser.parse_args()

    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)

    suspend_time = args.duration
    wowlan_delay = args.wowlan_delay
    suspend_mode = args.suspend_mode
    executor = Executor(dry_run=args.dry_run)
    suspender = Suspender(executor, wowlan_delay=wowlan_delay)
    sxmo_api = SxmoApi(executor)

    sxmo_api.halt_services()
    suspender.open_ntfy_stream()
    suspender.configure_wowlan()

    time_start = time.time()
    # irq_start="$(cat /proc/interrupts | grep 'rtw_wifi_gpio_wakeup' | tr -s ' ' | xargs echo | cut -d' ' -f 2)"
    suspender.suspend(suspend_time, mode=suspend_mode)
    # irq_end="$(cat /proc/interrupts | grep 'rtw_wifi_gpio_wakeup' | tr -s ' ' | xargs echo | cut -d' ' -f 2)"
    time_spent = time.time() - time_start

    logger.info(f"suspended for {time_spent:.0f} seconds")

    suspender.close_ntfy_stream()
    sxmo_api.resume_services()
    sxmo_api.call_postwake_hook()

if __name__ == '__main__':
    main()
