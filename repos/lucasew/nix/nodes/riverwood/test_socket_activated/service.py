import http.server
import socketserver
import logging
import os
import socket
from argparse import ArgumentParser
from json import dump
from io import StringIO

logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

parser = ArgumentParser()

parser.add_argument(
    '--timeout',
    '-t',
    type=int,
    default=10,
    help="Inactivity timeout to shutdown the server"
)

args = parser.parse_args()

class Handler(http.server.BaseHTTPRequestHandler):
    def address_string(self):
        return "unix"

    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.end_headers()
        logger.info("Receiving request")
        buf = StringIO()
        dump(dict(foi=True), buf)
        buf.seek(0)
        data = buf.read().encode('utf-8')
        print(data)
        self.wfile.write(data)

class CustomTCPServer(socketserver.TCPServer):
    def is_continue(self):
        logger.debug(f"Continue {not self._BaseServer__shutdown_request}")
        return not self._BaseServer__shutdown_request

    def handle_timeout(self):
        self._BaseServer__shutdown_request = True
        logger.debug('trigger timeout, shutdown')

httpd = CustomTCPServer(None, Handler, bind_and_activate=False)
if 'LISTEN_FDS' in os.environ:
    logger.info('LISTEN_FDS specified, using socket activation logic from systemd')
    httpd.socket = socket.fromfd(int(os.getenv("LISTEN_FDS_FIRST_FD") or 3), family=httpd.address_family, type=httpd.socket_type)
else:
    logger.info("LISTEN_FDS not specified, listening on port 4200")
    httpd.socket = socket.socket(family=httpd.address_family, type=httpd.socket_type)
    httpd.socket.bind(('127.0.0.1', 4201))
    httpd.socket.listen(0)
# httpd.socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 4)
httpd.socket.settimeout(args.timeout)
while httpd.is_continue():
    httpd.handle_request()
# httpd.socket.close()

httpd.server_close()
logger.info('Stopping server')
