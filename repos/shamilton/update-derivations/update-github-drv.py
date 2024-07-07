from argparse import ArgumentParser, FileType
from dateutil.parser import parse
from packaging import version
from pprint import pprint
from urllib.parse import unquote
import re
import requests
import sys
import time

parser = ArgumentParser()
parser.add_argument('config', type=FileType('r'))
parser.add_argument('derivation', type=FileType('r'),
                         default=sys.stdin)
args = parser.parse_args()
config = args.config.read().strip()
derivation = args.derivation.read()
access_token = config
headers = {
        'User-Agent': 'SCOTT-HAMILTON <sgn.hamilton+github@protonmail.com>',
        'Accept': 'application/vnd.github.v3+json',
        'Authorization': f'token {access_token}',
}
def get_attr(attr, drv_content):
    match = re.search(r"\w*"+attr+r" = \"(.*)\";", drv_content, re.MULTILINE)
    if match:
        return match.group(1)
    else:
        return None

# print("Derivation : ",derivation)
drv_pname = get_attr("pname", derivation)
drv_version = get_attr("version", derivation)
drv_rev = get_attr("rev", derivation) or \
          re.search(r"\w*rev = (.*);", derivation, re.MULTILINE).group(1)
owner = get_attr("owner", derivation)
repo = get_attr("repo", derivation)
if drv_pname:
    # Use repo if pname contains some nix string format
    if re.search(r".*\$\{.*\}.*", drv_pname):
        name = repo
    else:
        name = drv_pname
else:
    name = repo
# if revision is a sha, we treat that as unstable derivations
if not drv_rev:
    print(f"Invalid, {name}, {drv_version}")
    exit(1)
if re.match(r'[0-9-a-z]{40}', drv_rev):
    drv_version = "unstable"
elif not drv_version:
    drv_version = drv_rev

if drv_version == "unstable":
    owner = re.search(r'\w*owner = "(.*)";', derivation, re.MULTILINE).group(1)
    repo = re.search(r'\w*repo = "(.*)";', derivation, re.MULTILINE).group(1)
    response = requests.get(f'https://api.github.com/repos/{owner}/{repo}/commits?per_page=1',
                                headers=headers).json()
    date = parse(response[0]['commit']['author']['date']).strftime("%Y-%m-%d")
    latest_rev = response[0]['sha']
    if latest_rev != drv_rev:
        print(f"unstable {name}@{drv_rev} -> {latest_rev} from {date}")

else:
    response = requests.get(
            f'https://api.github.com/repos/{owner}/{repo}/tags?per_page=1',
            headers=headers).json()
    def clean_version(v):
        match = re.search(r"v\.?(.*)", v)
        if match:
            return match.group(1)
        else:
            return v
    if type(response) is dict and response["message"] == "Not Found":
        print(f"Repository {owner}/{repo} doesn't seem to exist anymore")
        exit(1)
    if len(response) == 0:
        print(f"Invalid response asking tags of {name}/{drv_version}")
        exit(1)
    try:
        latest_tag = clean_version(response[0]['name'])
    except KeyError as e:
        print(f"Error with response `{response}` from github repo {owner}/{repo}: {e}")
    try:
        v_drv_version = version.parse(drv_version)
    except version.InvalidVersion as e:
        v_drv_version = None
        print(f"unclear version   {name}@{drv_version} -> {latest_tag}")
    if v_drv_version != None and v_drv_version < version.parse(latest_tag):
        print(f"stable   {name}@{drv_version} -> {latest_tag}")
