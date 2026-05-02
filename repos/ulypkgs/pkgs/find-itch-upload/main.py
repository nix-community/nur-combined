#!/usr/bin/env python3
import sys
import os
import json
import subprocess
import time
import re
import argparse
from urllib.request import urlopen, Request
from urllib.error import HTTPError

def nix_eval(attr_path):
    """Evaluates a Nix attribute and returns the parsed JSON."""
    try:
        cmd = ["nix-instantiate", "--eval", "-A", attr_path, "--json"]
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        return json.loads(result.stdout)
    except subprocess.CalledProcessError as e:
        raise Exception(f"Error evaluating Nix attribute {attr_path}: {e.stderr}")

def fetch_with_retry(url, max_retries=5, interval=5):
    """Fetches a URL with retries specifically for 429 status codes."""
    for i in range(max_retries + 1):
        try:
            with urlopen(url) as response:
                return json.loads(response.read().decode())
        except HTTPError as e:
            if e.code == 429 and i < max_retries:
                print(f"Rate limited (429). Retrying in {interval}s... ({i+1}/{max_retries})", file=sys.stderr)
                time.sleep(interval)
                continue
            raise e
    return None

def match_filter(upload, field_name, pattern):
    """Implements the custom regex matching logic."""
    val = upload.get(field_name)
    if val is None:
        return False

    regex = re.compile(pattern)

    if isinstance(val, list):
        return any(regex.search(str(item)) for item in val)

    return bool(regex.search(str(val)))

def main():
    parser = argparse.ArgumentParser(description="Update Itch.io upload IDs in Nix expressions.")
    parser.add_argument("base_attr", help="The base Nix attribute (e.g., seeds-of-destiny)")
    parser.add_argument("--url", default=None, help="Itch.io game page URL, use <base_attr>.src.gameUrl or <base_attr>.meta.homepage by default.")
    parser.add_argument("--id", default=None, help="Game ID, an integer; make --url useless if specified.")
    parser.add_argument("-m", "--match", nargs=2, action='append', metavar=('FIELD', 'REGEX'),
                        help="Match a JSON field against a regex. Can be used multiple times.")
    parser.add_argument("--update", default=True, action=argparse.BooleanOptionalAction,
                        help="Attempt to update the upload ID in the Nix file; output nothing to stdout if upload ID did not change even if an upload is found.")

    args = parser.parse_args()

    api_key = os.environ.get("ITCHIO_API_KEY")
    if not api_key:
        print("Please set the ITCHIO_API_KEY environment variable.", file=sys.stderr)
        return 1

    if args.id:
        game_id = args.id
    else:
        if args.url:
            game_url = args.url
        else:
            try:
                game_url = nix_eval(f"{args.base_attr}.src.gameUrl")
            except:
                game_url = nix_eval(f"{args.base_attr}.meta.homepage")
        data_url = f"{game_url}/data.json"
        game_data = fetch_with_retry(data_url)
        game_id = game_data.get("id")

    itch_api_url = f"https://api.itch.io/games/{game_id}/uploads?api_key={api_key}"
    with urlopen(itch_api_url) as resp:
        uploads_payload = json.loads(resp.read().decode())

    all_uploads = uploads_payload.get("uploads", [])
    matched_upload = None
    for upload in all_uploads:
        is_match = True
        if args.match:
            for field, pattern in args.match:
                if not match_filter(upload, field, pattern):
                    is_match = False
                    break
        if is_match:
            matched_upload = upload
            break

    if not matched_upload:
        print("Failed to find a matching upload.", file=sys.stderr)
        return 2

    if not args.update:
        print(json.dumps(matched_upload))
        return 0

    old_upload_id = nix_eval(f"{args.base_attr}.src.upload")
    new_upload_id = str(matched_upload.get("id"))
    if new_upload_id == old_upload_id:
        print(f"No new upload found. Current upload ID: {new_upload_id}", file=sys.stderr)
        return 0

    print(f"upload ID: {old_upload_id} -> {new_upload_id}", file=sys.stderr)
    print(json.dumps(matched_upload))
    file_path = re.search(r"(.*):\d+$", nix_eval(f"{args.base_attr}.meta.position")).group(1)
    with open(file_path, 'r') as f:
        content = f.read()
    updated_content = content.replace(f'upload = "{old_upload_id}"', f'upload = "{new_upload_id}"')
    with open(file_path, 'w') as f:
        f.write(updated_content)
    return 0

if __name__ == "__main__":
    sys.exit(main())
