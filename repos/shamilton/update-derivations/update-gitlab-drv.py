from argparse import ArgumentParser, FileType
from packaging import version
import re
import requests
import sys

parser = ArgumentParser()
parser.add_argument('derivation', type=FileType('r'),
                         default=sys.stdin)
args = parser.parse_args()
derivation = args.derivation.read()
headers = {
        'User-Agent': 'SCOTT-HAMILTON <sgn.hamilton+gitlab@protonmail.com>',
        'Accept': 'application/vnd.github.v3+json',
}
def get_attr(attr, drv_content):
    match = re.search(r"\w*"+attr+r" = \"(.*)\";", drv_content, re.MULTILINE)
    if match:
        return match.group(1)
    else:
        return None
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

api_domain = "https://invent.kde.org/api/v4"

# If owner is group : 
response = requests.get(api_domain+f"/groups?search={owner}",
                        headers=headers).json()
if len(response) != 0:
    group_id = response[0]["id"]
    # print(f"{owner}/{name} in group id {group_id}")
    # Getting repo id
    response = requests.get(
        api_domain+f"/groups/{group_id}/projects?search={name}"
    ).json()
    repo_id = response[0]["id"]
    response = requests.get(
            api_domain+f"/projects/{repo_id}/repository/tags?order_by=updated"
    ).json()
    def clean_version(v):
        match = re.search(r"v(.*)", v)
        if match:
            return match.group(1)
        else:
            return v
    latest_tag = clean_version(response[0]["name"])
    if version.parse(latest_tag) > version.parse(drv_version):
        print(f"{owner}/{name}@{drv_version} → {latest_tag}")
else:
    print(f"{owner}/{name} not in a group")
    exit(1)
