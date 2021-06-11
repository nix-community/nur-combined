from argparse import ArgumentParser, FileType
from packaging import version
from pprint import pprint
import re
import requests
import sys

parser = ArgumentParser()
parser.add_argument('derivation', type=FileType('r'),
                         default=sys.stdin)
args = parser.parse_args()
derivation = args.derivation.read()
headers = {
        'User-Agent': 'SCOTT-HAMILTON <sgn.hamilton+pypi@protonmail.com>',
        'Accept': 'application/json',
}
def get_attr(attr, drv_content):
    match = re.search(r"\w*"+attr+r" = \"(.*)\";", drv_content, re.MULTILINE)
    if match:
        return match.group(1)
    else:
        return None

drv_pname = get_attr("pname", derivation)
drv_version = get_attr("version", derivation)

response = requests.get(f'https://pypi.org/pypi/{drv_pname}/json', headers=headers).json()
def newest_version(versions):
    newest = None
    for v in versions:
        if not newest or version.parse(v) > version.parse(newest):
            newest = v
    return newest
latest_pypi_version = newest_version(response["releases"].keys())
if version.parse(latest_pypi_version) > version.parse(drv_version):
    print(f"{drv_pname}@{drv_version} → {latest_pypi_version}")
