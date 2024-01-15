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

    def handle_finish_request(self, code=200, mime_type=None):
        # logger.info(f'finish request code={code} mime_type={mime_type}')
        self.send_response(code)
        if mime_type is not None:
            self.send_header('Content-Type', mime_type)
        self.end_headers()
        # self.wfile.write(b'diggy diggy hole')

    def handle_response(self, response, code=200, mime_type=None):
        # logger.info(f'response {response}')
        if response is None:
            self.handle_finish_request(code=code, mime_type=mime_type)
            return
            
        if isinstance(response, bytes):
            self.handle_finish_request(code=code, mime_type=mime_type)
            return self.wfile.write(response)
        if isinstance(response, str):
            self.handle_finish_request(code=code, mime_type=mime_type)
            return self.wfile.write(response.encode('utf-8'))
        if hasattr(response, 'getvalue'):
            # self.handle_finish_request(code=code, mime_type=mime_type)
            response.seek(0)
            data = response.getvalue()
            return self.handle_response(data, code=code, mime_type=mime_type)
        buf = io.StringIO()
        json.dump(response, buf)
        return self.handle_response(buf, code=code, mime_type='application/json')

    def _handle_some_request(self):
        try:
            buf = handler_handle(self)
            if buf is not None:
                self.handle_response(buf)
        except HTTPError as e:
            self.handle_response(dict(error=e.message), code=e.code)
        except Exception as e:
            traceback.print_exc()
            self.handle_response(dict(error=str(e)), code=500)
        self.wfile.flush()

    def do_GET(self):
        self._handle_some_request()

    def do_POST(self):
        self._handle_some_request()

    def do_PUT(self):
        self._handle_some_request()

    def do_DELETE(self):
        self._handle_some_request()


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
