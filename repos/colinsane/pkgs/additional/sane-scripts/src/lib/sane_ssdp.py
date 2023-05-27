# based on this minimal SSDP client: <https://gist.github.com/schlamar/2428250>

import logging
import socket
import struct
import subprocess

logger = logging.getLogger(__name__)


MCAST_GRP = "239.255.255.250"

class SsdpResponse:
    def __init__(self, headers: "Dict[str, str]"):
        self.headers = headers

    @staticmethod
    def parse(msg: str) -> "Self":
        headers = {}
        for line in [m.strip() for m in msg.split("\r\n") if m.strip()]:
            if ":" not in line: continue
            sep_idx = line.find(":")
            header, content = line[:sep_idx].strip(), line[sep_idx+1:].strip()
            headers[header.upper()] = content
        if headers:
            return SsdpResponse(headers)

    def is_rootdevice(self) -> bool:
        return self.headers.get("NT", "").lower() == "upnp:rootdevice"

    def location(self) -> str:
        return self.headers.get("LOCATION")


def get_root_devices():
    listener = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
    listener.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    listener.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_TTL, 2)

    listener.bind(("", 1900))
    logger.info("bound")

    mreq = struct.pack("4sl", socket.inet_aton(MCAST_GRP), socket.INADDR_ANY)
    listener.setsockopt(socket.IPPROTO_IP, socket.IP_ADD_MEMBERSHIP, mreq)

    root_descs = set()
    while True:
        packet, (host, src_port) = listener.recvfrom(2048)
        logger.info(f"message from {host}")
        # if host.endswith(".1"):  # router
        try:
            msg = packet.decode("utf-8")
        except:
            logger.debug("failed to decode packet to string")
        else:
            logger.debug(msg)
            resp = SsdpResponse.parse(msg)
            if resp and resp.is_rootdevice():
                root_desc = resp.location()
                if root_desc and root_desc not in root_descs:
                    root_descs.add(root_desc)
                    logger.info(f"root desc: {root_desc}")
                    yield root_desc

def get_wan_from_location(location: str):
    """ location = URI from the Location header, e.g. http://10.78.79.1:2189/rootDesc.xml """

    # get connection [s]tatus
    res = subprocess.run(["upnpc", "-u", location, "-s"], capture_output=True)
    res.check_returncode()

    status = res.stdout.decode("utf-8")
    logger.info(f"got status: {status}")

    for line in [l.strip() for l in status.split("\n")]:
        sentinel = "ExternalIPAddress ="
        if line.startswith(sentinel):
            ip = line[len(sentinel):].strip()
            return ip

def get_any_wan():
    """ return (location, WAN IP) for the first device seen which has a WAN IP """
    for location in get_root_devices():
        wan = get_wan_from_location(location)
        if wan:
            return location, wan

def get_lan_ip() -> str:
    ips = subprocess.check_output(["hostname", "-i"]).decode("utf-8").strip().split(" ")
    ips = [i for i in ips if i.startswith("10.") or i.startswith("192.168.")]
    assert len(ips) == 1, ips
    return ips[0]

def forward_port(root_device: str, proto: str, port: int, reason: str, duration: int = 86400, lan_ip: str = None):
    lan_ip = lan_ip or get_lan_ip()
    args = [
        "upnpc",
        "-u", root_device,
        "-e", reason,
        "-a", lan_ip,
        str(port),
        str(port),
        proto,
        str(duration),
    ]

    logger.debug(f"running: {args!r}")
    stdout = subprocess.check_output(args).decode("utf-8")

    logger.info(stdout)
