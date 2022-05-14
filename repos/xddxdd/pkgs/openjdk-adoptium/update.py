import requests
import re
import json


def normalize_version(version, isKey=False):
    if version.startswith('jdk-'):
        version = version[4:]
    elif version.startswith('jdk'):
        version = version[3:]
    elif version.startswith('jre-'):
        version = version[4:]
    elif version.startswith('jre'):
        version = version[3:]

    if isKey:
        version = re.sub(r'[^0-9a-zA-Z]', '_', version)
    else:
        version = re.sub(r'[^0-9a-zA-Z._-]', '_', version)

    return version


def filter_binaries(binaries, version):
    result = {}
    for b in binaries:
        if b['image_type'] not in ['jdk', 'jre']:
            continue
        if b['os'].lower() != 'linux':
            continue
        normalized_verison = normalize_version(b['scm_ref'])
        url = b['package']['link']
        sha256 = b['package']['checksum']

        arch = b['architecture']
        if arch == 'x64':
            arch = 'x86_64'
        elif arch == 'arm':
            arch = 'armv7l'

        k = b['image_type'] + '-bin-' + version
        if k not in result:
            result[k] = {}
        result[k][arch] = {
            'version': normalized_verison,
            'type': b['image_type'],
            'url': url,
            'sha256': sha256,
        }
    return result


def get_source(major_revision):
    session = requests.Session()
    session.headers.update(
        {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.67 Safari/537.36'})
    source = session.get(
        'https://api.adoptium.net/v3/assets/feature_releases/{major_revision}/ga?vendor=eclipse&page_size=100'.format(major_revision=major_revision)).json()

    result = {}
    for s in source:
        this_version = normalize_version(s['release_name'], True)
        result.update(filter_binaries(s['binaries'], this_version))

    result.update(filter_binaries(source[0]['binaries'], str(major_revision)))
    return result


result = {}
for v in [8, 11, 16, 17, 18]:
    result.update(get_source(v))

# Write as json
with open('sources.json', 'w') as f:
    f.write(json.dumps(result, indent=4))
