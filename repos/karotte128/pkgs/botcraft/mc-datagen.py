import json
import hashlib
import base64
from urllib.request import urlopen
from pathlib import Path

def get_client_url(mc_version):
    try:
        # Fetch the JSON data from the initial URL
        url = "https://piston-meta.mojang.com/mc/game/version_manifest_v2.json"
        response = urlopen(url)

        # Check if the request was successful
        if response.getcode() != 200:
            raise Exception(f"Failed to fetch version manifest. Status code: {response.getcode()}")

        # Read the response content
        data = response.read().decode('utf-8')

        # Parse the JSON string
        parsed_json = json.loads(data)

        # Search through versions to find the matching version
        matching_version = next((version for version in parsed_json["versions"] if version["id"] == mc_version), None)

        # Extract the URL from the matching version
        version_url = matching_version.get("url") if matching_version else None

        # Fetch the version JSON data
        version_response = urlopen(version_url)

        # Check if the request was successful
        if version_response.getcode() != 200:
            raise Exception(f"Failed to fetch version data. Status code: {version_response.getcode()}")

        # Read the response content
        version_data = version_response.read().decode('utf-8')

        # Parse the version JSON
        parsed_version = json.loads(version_data)

        # Extract the downloads.server.url
        client_url = parsed_version.get("downloads", {}).get("client", {}).get("url")

        return client_url

    except Exception as e:
        print(f"Error: {str(e)}")
        return None

def generate_client_hash(client_url):
    # Initialize sha256 hash
    h = hashlib.sha256()

    # Fetch the client.jar
    client_response = urlopen(client_url)

    # Check if the request was successful
    if client_response.getcode() != 200:
        raise Exception(f"Failed to fetch version data. Status code: {client_response.getcode()}")

    # Generate the file hash
    h.update(client_response.read())
    digest = h.digest()

    # Format hash for nix
    sri = "sha256-" + base64.b64encode(digest).decode()

    return sri

def build_client_meta_dict(client_version):
    # Create client meta dict
    c_meta = {}

    # Get client URL + Hash
    c_url = get_client_url(client_version)
    c_hash = generate_client_hash(c_url)

    # Write URL + Hash to client dict
    c_meta["url"] = c_url
    c_meta["hash"] = c_hash

    return c_meta

def generate_meta(versions):
    # Create meta dict
    meta = {
        "versions": {}
    }

    # Iterate over mc versions
    for version in versions:
        meta["versions"][version] = {
            "client": build_client_meta_dict(version)
        }

    return meta

# Directory where the script itself is located
script_dir = Path(__file__).parent

# Input file in the same directory as the script
input_file = script_dir / "minecraft-versions.txt"

# convert file to list
with open(input_file, "r") as f:
    versions = [line.strip() for line in f]

# Generate the metadata
mc_meta = generate_meta(versions)

# Set the latest value
mc_meta["latest"] = versions[-1]

# Output file in the same directory as the script
output_file = script_dir / "minecraft-data.json"

# Write to it
with open(output_file, "w") as f:
    json.dump(mc_meta, f, indent=4)