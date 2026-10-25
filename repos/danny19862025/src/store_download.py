"""Download a bounded raw WASM release asset; never execute a release installer."""
import sys
import os
import urllib.parse
import urllib.request

class ReleasesOnly(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, request, response, code, message, headers, url):
        parsed = urllib.parse.urlsplit(url)
        if parsed.scheme != 'https' or parsed.port not in (None, 443) or parsed.username or parsed.password or parsed.hostname not in ('github.com', 'release-assets.githubusercontent.com', 'objects.githubusercontent.com', 'github-releases.githubusercontent.com'):
            raise ValueError('Release redirected outside GitHub asset hosts')
        return super().redirect_request(request, response, code, message, headers, url)

opener = urllib.request.build_opener(ReleasesOnly())
with opener.open(sys.argv[1], timeout=30) as response:
    data = response.read(4 * 1024 * 1024 + 1)
if len(data) > 4 * 1024 * 1024:
    raise ValueError('WASM release exceeds 4 MiB')
with os.fdopen(os.open(sys.argv[2], os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600), 'wb') as output:
    output.write(data)
