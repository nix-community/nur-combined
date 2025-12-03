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

def get_cached_root_devices() -> list[str]:
    try:
        dev = open("/var/lib/dyn-dns/upnp.txt", "r").read()
    except IOError:
        return []
    else:
        logger.debug("loaded cached UPNP root device", dev)
        return [dev]

def get_root_devices() -> list[str]:
    listener = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
    listener.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    listener.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_TTL, 2)

    listener.bind(("", 1900))
    logger.debug("bound")

    mreq = struct.pack("4sl", socket.inet_aton(MCAST_GRP), socket.INADDR_ANY)
    listener.setsockopt(socket.IPPROTO_IP, socket.IP_ADD_MEMBERSHIP, mreq)

    root_descs = set()
    while True:
        packet, (host, src_port) = listener.recvfrom(2048)
        logger.debug(f"message from {host}")
        # if host.endswith(".1"):  # router
        try:
            msg = packet.decode("utf-8")
        except:
            logger.info("failed to decode packet to string")
        else:
            logger.debug(msg)
            resp = SsdpResponse.parse(msg)
            if resp and resp.is_rootdevice():
                root_desc = resp.location()
                if root_desc and root_desc not in root_descs:
                    root_descs.add(root_desc)
                    logger.debug(f"root desc: {root_desc}")
                    yield root_desc

def get_ips_from_location(location: str) -> tuple[str | None, str | None]:
    """
    location = URI from the Location header, e.g. http://10.78.79.1:2189/rootDesc.xml
    returns (lan, wan)
    """

    # get connection [s]tatus
    cmd = ["upnpc", "-u", location, "-s"]
    res = subprocess.run(cmd, capture_output=True)
    if res.returncode != 0:
        logger.info(f"get_wan_from_location failed: {cmd!r}\n{res.stderr}")
        return None, None

    status = res.stdout.decode("utf-8")
    logger.debug(f"got status: {status}")

    lan = None
    wan = None
    for line in [l.strip() for l in status.split("\n")]:
        wan_sentinel = "ExternalIPAddress ="
        lan_sentinel = "Local LAN ip address :"
        if line.startswith(wan_sentinel):
            wan = line[len(wan_sentinel):].strip()
            logger.info(f"got WAN = {wan} from {location}")
        if line.startswith(lan_sentinel):
            lan = line[len(lan_sentinel):].strip()
            logger.info(f"got LAN = {lan} from {location}")
    return lan, wan

def get_any_wan(cached: bool = False) -> tuple[str, str, str] | None:
    """ return (location, LAN IP, WAN IP) for the first device seen which has a WAN IP """
    sources = ([ get_cached_root_devices() ] if cached else []) \
        + [ get_root_devices() ]
    for source in sources:
        for location in source:
            lan, wan = get_ips_from_location(location)
            if lan and wan:
                return location, lan, wan

def forward_port(root_device: str, proto: str, port: int, lan_ip: str, reason: str = "", duration: int = 86400) -> None:
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
