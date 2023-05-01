
import sys
import json
from pathlib import Path

# In Firefox: Open the developer tools, go to the Network tab, and refresh the page.
# Click on a request in the Tab "Cookies", do a right click on a cookie and select "Copy all"

# In Chrome: Open the developer tools, go to console and paste in the script from export-cookies.js
# Than save your clipboard to a file.

def main() -> None:
    if len(sys.argv) != 2:
        print("Usage: python convert-cookies.py <cookies.json>")
        sys.exit(1)
    data = json.loads(Path(sys.argv[1]).read_text())
    new_format = []
    for k,v in data.get("Request Cookies", data).items():
        new_format.append(dict(name=k, value=v))
    print(json.dumps(new_format, indent=4))


if __name__ == "__main__":
    main()
