import requests, re, ast, json

sources = requests.get('https://developer.ibm.com/middleware/v1/contents/static/semeru-runtime-downloads').json()
sources = sources['results'][0]['pagepost_custom_js_value']

# Find body of json value
sources = re.match(r'let sourceDataJson = ([^;]+);', sources).group(1)

# Reformat into python dict format
sources = sources.replace('\'', '"')
sources = re.sub(r'^\s+([^\s]+)\s*:', r'"\1":', sources, flags=re.MULTILINE)

# Load dict
sources = ast.literal_eval(sources)
sources = sources['downloads']

# Reformat source

def version_to_number(v):
    vs = [int(vv) for vv in v.split('.')]
    while len(vs) < 4:
        vs.append(0)
    return vs[0] * 1000000000 + vs[1] * 1000000 + vs[2] * 1000 + vs[3]

def find_tar_gz_link(v):
    for k in v:
        if v[k]['displayName'].endswith('tar.gz'):
            return v[k]
    return None

formatted_source = {}
for source in sources:
    if 'arch' not in source:
        continue

    if 'os' not in source:
        continue
    if source['os'].lower() != 'linux':
        continue

    major_revision = source['version']
    version = re.match(r'<b>(.*)</b>', source['name']).group(1)

    arch = source['arch']
    if arch == 'x64':
        arch = 'x86_64'

    jre = find_tar_gz_link(source['jre']) if 'jre' in source else None
    if jre is None:
        continue
    jdk = find_tar_gz_link(source['jdk']) if 'jdk' in source else None
    if jdk is None:
        continue
    def add_java_revision(key):
        if key not in formatted_source:
            formatted_source[key] = {
                'jre': {},
                'jdk': {},
            }
        if arch in formatted_source[key]['jdk']:
            if version_to_number(formatted_source[key]['jdk'][arch]['version']) > version_to_number(version):
                return

        formatted_source[key]['jre'][arch] = {
            'major_revision': major_revision,
            'version': version,
            'url': jre['downloadLink'],
            'sha256': jre['checksum'],
        }
        formatted_source[key]['jdk'][arch] = {
            'major_revision': major_revision,
            'version': version,
            'url': jdk['downloadLink'],
            'sha256': jdk['checksum'],
        }

    add_java_revision(major_revision)
    add_java_revision(version)

# Write as json
with open('sources.json', 'w') as f:
    f.write(json.dumps(formatted_source, indent=4))
