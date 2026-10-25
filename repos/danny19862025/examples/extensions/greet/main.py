import json
import sys

text = f"Hello, {sys.argv[1]}!"
print(json.dumps({"type": "result", "id": "greeting", "title": text,
                  "subtitle": "Enter copies the greeting",
                  "action": {"type": "copy", "text": text}}), flush=True)
