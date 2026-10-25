"""Read bounded editor metadata without changing the editors' databases."""
import json
import os
from pathlib import Path
import sqlite3
import sys
import xml.etree.ElementTree as ET

home = Path(sys.argv[1])
config = Path(sys.argv[2])
rows = []

def code_entries(value, editor):
    if isinstance(value, dict):
        for key in ('entries', 'workspaces3', 'workspaces', 'folders'):
            if isinstance(value.get(key), list):
                code_entries(value[key], editor)
        uri = value.get('folderUri') or value.get('workspaceUri')
        workspace = value.get('workspace')
        if isinstance(workspace, dict):
            uri = uri or workspace.get('configPath')
        if isinstance(uri, str):
            rows.append(dict(editor=editor, path=uri))
    elif isinstance(value, list):
        for item in value[:1000]:
            if isinstance(item, str):
                rows.append(dict(editor=editor, path=item))
            else:
                code_entries(item, editor)

for directory, editor in [('Code', 'code'), ('Code - Insiders', 'code-insiders'),
                          ('VSCodium', 'codium'), ('Code - OSS', 'code-oss')]:
    storage = config / directory / 'User/globalStorage'
    for filename in ('storage.json', 'state.vscdb'):
        path = storage / filename
        try:
            if filename.endswith('.json'):
                if path.stat().st_size > 2 * 1024 * 1024:
                    continue
                data = json.loads(path.read_text())
                for key in ('openedPathsList', 'history.recentlyOpenedPathsList'):
                    code_entries(data.get(key), editor)
            elif path.is_file():
                connection = sqlite3.connect(path.resolve().as_uri() + '?mode=ro', uri=True, timeout=0.2)
                try:
                    for (value,) in connection.execute(
                        "SELECT value FROM ItemTable WHERE key IN (?, ?) AND length(value) <= 2097152",
                        ('history.recentlyOpenedPathsList', 'openedPathsList')):
                        code_entries(json.loads(value), editor)
                finally:
                    connection.close()
        except (OSError, ValueError, sqlite3.Error):
            continue

products = [('IntelliJIdea', 'idea'), ('IdeaIC', 'idea'), ('PyCharm', 'pycharm'),
            ('WebStorm', 'webstorm'), ('RustRover', 'rustrover'), ('CLion', 'clion'),
            ('GoLand', 'goland'), ('PhpStorm', 'phpstorm'), ('Rider', 'rider'),
            ('RubyMine', 'rubymine'), ('DataGrip', 'datagrip')]
roots = [config / 'JetBrains']
roots += [p for p in home.glob('.*') if any(p.name[1:].startswith(n) for n, _ in products)][:40]
files = []
for root in roots:
    if root.name == 'JetBrains':
        files += list(root.glob('*/options/recentProjects.xml'))[:80]
        files += list(root.glob('*/options/recentSolutions.xml'))[:20]
    else:
        files += list(root.glob('config/options/recentProjects.xml'))[:1]
for path in files:
    product = path.parents[1].name
    if product == 'config':
        product = path.parents[2].name.lstrip('.')
    editor = next((command for name, command in products if product.startswith(name)), None)
    if not editor:
        continue
    try:
        if path.stat().st_size > 2 * 1024 * 1024:
            continue
        tree = ET.fromstring(path.read_text())
        candidates = []
        for option in tree.iter('option'):
            if option.get('name') == 'recentPaths':
                candidates += [node.get('value') for node in option.iter('option') if node.get('value')]
            elif option.get('name') == 'additionalInfo':
                candidates += [node.get('key') for node in option.iter('entry') if node.get('key')]
        for value in candidates[:1000]:
            rows.append(dict(editor=editor, path=value.replace('$USER_HOME$', str(home))))
    except (OSError, ValueError, ET.ParseError):
        continue
print(json.dumps(rows[:4000]))
