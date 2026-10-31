"""Exercise the real socket transport, including descriptors in both directions."""
import array
import importlib.util
import os
import socket
import sys
import tempfile

spec = importlib.util.spec_from_file_location("socket_proxy", sys.argv[1])
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


def receive(connection, expected, expected_device):
    data, ancillary, flags, _ = connection.recvmsg(1024, socket.CMSG_SPACE(4))
    assert data == expected and not flags & socket.MSG_CTRUNC
    descriptors = array.array("i")
    descriptors.frombytes(ancillary[0][2])
    try:
        assert len(descriptors) == 1
        assert os.fstat(descriptors[0]).st_rdev == expected_device
    finally:
        for descriptor in descriptors:
            os.close(descriptor)


with tempfile.TemporaryDirectory() as directory:
    server = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    server.settimeout(5)
    server.bind(directory + "/original")
    os.chmod(directory + "/original", 0o600)
    server.listen()
    proxy = module.Proxy(directory + "/original", directory + "/proxy")
    client = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    client.settimeout(5)
    client.connect(directory + "/proxy")
    upstream, _ = server.accept()
    upstream.settimeout(5)
    descriptor = os.open("/dev/null", os.O_RDONLY)
    try:
        ancillary = [(socket.SOL_SOCKET, socket.SCM_RIGHTS, array.array("i", [descriptor]))]
        client.sendmsg([b"Wayland buffer"], ancillary)
        receive(upstream, b"Wayland buffer", os.fstat(descriptor).st_rdev)
        upstream.sendmsg([b"PulseAudio memory"], ancillary)
        receive(client, b"PulseAudio memory", os.fstat(descriptor).st_rdev)
        assert os.stat(directory + "/original").st_mode & 0o777 == 0o600
        client.shutdown(socket.SHUT_WR)
        assert upstream.recv(1) == b""
    finally:
        os.close(descriptor)
        client.close()
        upstream.close()
        proxy.close()
        server.close()
print("Desktop socket data, SCM_RIGHTS, disconnect and permissions passed")
