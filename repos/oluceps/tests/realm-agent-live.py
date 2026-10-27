#!/usr/bin/env python3
"""Authorized remote root probe in an existing application's netns and cgroup.

Run only on test/deployment hosts. The short-lived child drops to the actual
application UID before opening sockets. It does not read application secrets.
"""
import argparse
import http.client
import json
import os
from pathlib import Path
import socket
import struct
import subprocess
import sys
import urllib.request


def child(args):
    uid, gid = map(int, args.identity.split(':'))
    assert uid != 0
    Path('/sys/fs/cgroup' + args.cgroup + '/cgroup.procs').write_text(str(os.getpid()))
    if args.mount_pid:
        mount = os.open(f'/proc/{args.mount_pid}/ns/mnt', os.O_RDONLY)
        os.setns(mount, os.CLONE_NEWNS)
        os.close(mount)
    os.setgroups([])
    os.setgid(gid)
    os.setuid(uid)
    checks = []
    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as dns:
        dns.settimeout(10)
        question = struct.pack('!6H', 197, 0x100, 1, 0, 0, 0) + b'\x07example\x03com\0\0\1\0\1'
        dns.sendto(question, ('8.8.8.8', 53))
        response, source = dns.recvfrom(4096)
        assert source == ('8.8.8.8', 53), source
        assert struct.unpack('!H', response[:2])[0] == 197
        rcode = response[3] & 15
        assert rcode == (0 if args.internet else 5), rcode
        checks.append('DNS answer' if args.internet else 'external DNS REFUSED')
    opener = urllib.request.build_opener(urllib.request.ProxyHandler({}))
    if args.internet:
        with opener.open('https://example.com/', timeout=20) as response:
            assert response.status == 200
            response.read()
        checks.append('public HTTPS 200 without proxy environment')
    else:
        with socket.create_connection(('1.1.1.1', 443), timeout=5) as connection:
            connection.settimeout(5)
            try:
                connection.sendall(b'undeclared-target')
                assert connection.recv(1) == b''
            except (ConnectionResetError, BrokenPipeError):
                pass
        checks.append('public TCP denied')
    if args.http:
        with opener.open(args.http, timeout=10) as response:
            assert response.status == 200
            response.read()
        checks.append('application HTTP health 200')
    if args.unix:
        connection = http.client.HTTPConnection('localhost', timeout=10)
        connection.sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        connection.sock.connect(args.unix)
        connection.request('GET', args.path)
        response = connection.getresponse()
        assert response.status == 200, response.status
        response.read()
        connection.close()
        checks.append('application Unix HTTP health 200')
    interfaces = [name for _, name in socket.if_nameindex()]
    assert {'lo', 'realm0'}.issubset(interfaces), interfaces
    assert set(interfaces).issubset({'lo', 'realm0', 'ip6tnl0', 'gre0', 'gretap0', 'erspan0'}), interfaces
    print(json.dumps({'unit': args.unit, 'uid': os.getuid(), 'interfaces': interfaces, 'checks': checks}), flush=True)


parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('unit')
parser.add_argument('--internet', action='store_true')
parser.add_argument('--unix')
parser.add_argument('--http')
parser.add_argument('--path', default='/v1/health')
parser.add_argument('--child', action='store_true')
parser.add_argument('--identity')
parser.add_argument('--cgroup')
parser.add_argument('--mount-pid', type=int)
args = parser.parse_args()
if args.child:
    child(args)
else:
    assert os.geteuid() == 0
    pid = int(subprocess.check_output(['systemctl', 'show', args.unit, '-p', 'MainPID', '--value'], text=True))
    assert pid > 0
    status = dict(line.split(':', 1) for line in Path(f'/proc/{pid}/status').read_text().splitlines() if ':' in line)
    uid, gid = int(status['Uid'].split()[1]), int(status['Gid'].split()[1])
    cgroup = next(line[3:] for line in Path(f'/proc/{pid}/cgroup').read_text().splitlines() if line.startswith('0::'))
    assert cgroup.startswith('/') and cgroup != '/'
    environment = Path(f'/proc/{pid}/environ').read_bytes().split(b'\0')
    proxies = [entry.split(b'=')[0].decode() for entry in environment if entry.split(b'=')[0].lower() in (b'http_proxy', b'https_proxy', b'all_proxy')]
    assert proxies == [], proxies
    subprocess.run(['nsenter', f'--net=/proc/{pid}/ns/net', '--', sys.executable,
                    str(Path(__file__).resolve()), *sys.argv[1:], '--child',
                    '--identity', f'{uid}:{gid}', '--cgroup', cgroup, '--mount-pid', str(pid)], check=True)
