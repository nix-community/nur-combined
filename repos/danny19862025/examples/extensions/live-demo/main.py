import json
import sys
import time

query = sys.argv[1]
print(json.dumps({"type": "result", "id": "original", "title": query or "Type a query",
                  "action": {"type": "copy", "text": query}}), flush=True)
time.sleep(0.4)
print(json.dumps({"type": "result", "id": "upper", "title": query.upper() or "Second result",
                  "subtitle": "This result arrived after the first one",
                  "action": {"type": "copy", "text": query.upper()}}), flush=True)
