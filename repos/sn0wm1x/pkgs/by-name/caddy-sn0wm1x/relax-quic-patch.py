import re
import sys
from pathlib import Path

patch = Path(sys.argv[1]).read_text()
# Caddy 2.11.9 adds an import after zapcore. Update only that context line;
# leave strict matching enabled elsewhere.
pattern = r'(@@ -\d+,)(\d+)( \+\d+,)(\d+)( @@[^\n]*\n(?:(?!@@|diff --git).)*?\+\s*bbr "github\.com/sagernet/sing-quic/congestion_meta2"\n(?:(?!@@|diff --git).)*?\s"go\.uber\.org/zap/zapcore"\n) \n'

def trim(match):
    return (match[1] + match[2] + match[3] + match[4] + match[5]
            + ' \t"golang.org/x/net/http/httpguts"\n')

patch, count = re.subn(pattern, trim, patch, count=1, flags=re.DOTALL)
if count != 1:
    raise SystemExit("could not find expected QUIC import hunk")
Path(sys.argv[2]).write_text(patch)
