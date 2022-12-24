import requests
import os
import sys
import ast
import re
import json
import subprocess

def get_script_path():
    return os.path.dirname(os.path.realpath(sys.argv[0]))

def get_selector(name: str):
    session = requests.Session()
    session.headers.update(
        {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.67 Safari/537.36'})
    sources = session.get(
        'https://downloads.digium.com/pub/telephony/codec_{}/selector-{}.js'.format(name, name)).text

    # Find body of json value
    sources = re.match(r'var modules = ([^;]+);', sources).group(1)

    # Reformat into python dict format
    sources = sources.replace('\'', '"')
    sources = sources.replace('{', '{\n')
    sources = sources.replace('}', '}\n')
    sources = re.sub(r'^\s+"?([^\s^"]+)"?\s*:', r'"\1":', sources, flags=re.MULTILINE)
    sources = sources.replace('true', 'True')
    sources = sources.replace('false', 'False')

    # Load dict
    sources = ast.literal_eval(sources)
    sources = sources[list(sources.keys())[0]]

    return sources

def nix_prefetch_url(url: str):
    result = subprocess.run(['nix-prefetch-url', url], stdout=subprocess.PIPE)
    if result.returncode != 0:
        raise RuntimeError('nix-prefetch-url exited with error {}'.format(result.returncode))
    return result.stdout.decode('utf-8').strip()

def get_versions(name: str):
    sources = get_selector(name)
    result = {}

    for k in sources['versions']:
        v = sources['versions'][k]
        result[k.split('.')[0]] = {}
        for bits in sources['bits']:
            url = '{download_base}/{directory}/x86-{bits}/codec_{name}-{file_version}_{version}-x86_{bits}.tar.gz'.format(
                download_base = sources['download_base'],
                name = name,
                directory = v['directory'],
                bits = bits,
                file_version = v['file_version'],
                version = sources['version'],
            )
            result[k.split('.')[0]][bits] = {
                'url': url,
                'version': sources['version'],
                'hash': nix_prefetch_url(url),
            }

    return result

result = {}
for library in ['opus', 'silk', 'siren7', 'siren14']:
    library_result = get_versions(library)
    for k in library_result:
        if k not in result:
            result[k] = {}
        result[k][library] = library_result[k]

# Write as json
with open(get_script_path() + '/sources.json', 'w') as f:
    f.write(json.dumps(result, indent=4))
