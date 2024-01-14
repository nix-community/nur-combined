handler # It will fail if not defined

try:
    SOCKET_TIMEOUT
except NameError:
    SOCKET_TIMEOUT = 10

try:
    PORT
except NameError:
    PORT = 4200

import http.server
import socketserver
import logging
import os
import io
import socket
import json
import traceback

logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

handler_handle = handler()

class HTTPError(Exception):
    def __init__(self, code=500, message=None):
        self.code = code
        self.message = message
        

class Handler(http.server.BaseHTTPRequestHandler):
    def address_string(self):
        return "unix"

    def handle_finish_request(self, code=200, mime_type='application/octet-stream'):
        self.send_response(code)
        self.send_header('Content-Type', mime_type)
        self.end_headers()
        self.flush_headers()

    def handle_source(self, source, code=200, mime_type='application/octet-stream'):
        # self.protocol_version = "HTTP/1.1"
        if isinstance(source, bytes):
            self.handle_finish_request(code=code, mime_type=mime_type)
            return self.wfile.write(source)
        if isinstance(source, str):
            self.handle_finish_request(code=code, mime_type=mime_type)
            return self.wfile.write(source.encode('utf-8'))
        if hasattr(source, 'getvalue'):
            self.handle_finish_request(code=code, mime_type=mime_type)
            return self.handle_source(source.getvalue(), code=code, mime_type=mime_type)
        buf = io.TextIO()
        json.dump(source, buf)
        return self.handle_source(buf.getvalue(), code=code, mime_type='application/json')

    def _handle(self):
        try:
            buf = handler_handle(self)
            print('buf', buf)
            if buf is not None:
                self.handle_source(buf)
            self.wfile.flush()
        except HTTPError as e:
            self.handle_source(dict(error=e.message), code=e.code)
        except Exception as e:
            traceback.print_exc()
            self.handle_source(dict(error=e.message), code=500)


    def do_GET(self):
        self._handle()

    def do_POST(self):
        self._handle()

    def do_PUT(self):
        self._handle()

    def do_DELETE(self):
        self._handle()


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
    logger.info(f"LISTEN_FDS not specified, listening on port {PORT}")
    httpd.socket = socket.socket(family=httpd.address_family, type=httpd.socket_type)
    httpd.socket.bind(('127.0.0.1', PORT))
    httpd.socket.listen(0)
# httpd.socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 4)
httpd.socket.settimeout(SOCKET_TIMEOUT)
while httpd.is_continue():
    httpd.handle_request()
# httpd.socket.close()

httpd.server_close()
logger.info('Stopping server')
