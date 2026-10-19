#!/usr/bin/env python3
"""检查包内 wxc 的解析、运行和定时服务；仅用临时目录，不联网。"""

import argparse
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile
import unittest


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--package', type=Path, required=True)
    parser.add_argument('--wxc', type=Path, required=True)
    args = parser.parse_args()
    package = args.package.resolve()
    expected = args.wxc.resolve()
    wrapper = (package / 'bin/wetype-cloud').read_text()
    launcher = re.search(r'^exec (\S+)', wrapper, re.MULTILINE).group(1)

    class BundledWxcTest(unittest.TestCase):
        def setUp(self):
            self.temp = tempfile.TemporaryDirectory(prefix='vtype-bundled-wxc.')
            self.root = Path(self.temp.name)

        def tearDown(self):
            self.temp.cleanup()

        def run_cloud_python(self, code, override=None):
            env = dict(os.environ, HOME=str(self.root), PATH='/nonexistent',
                       XDG_DATA_HOME=str(self.root / 'data'),
                       XDG_CONFIG_HOME=str(self.root / 'config'),
                       WETYPE_STATE_DIR=str(self.root / 'account'))
            env.pop('WETYPE_WXC', None)
            if override is not None:
                env['WETYPE_WXC'] = str(override)
            prefix = 'import sys; sys.path.insert(0, ' + repr(str(package / 'share/vtype-linux/cloud')) + '); '
            output = subprocess.check_output([launcher, '-c', prefix + code], env=env, text=True)
            return json.loads(output)

        def test_default_client_with_empty_home_and_path(self):
            found = self.run_cloud_python('from 运行支持 import wxc_binary; import json; print(json.dumps(wxc_binary()))')
            self.assertEqual(Path(found), expected)
            self.assertFalse((self.root / 'data/wetype-ime/tools').exists())

        def test_cli_version(self):
            result = subprocess.check_output([str(package / 'bin/wxc'), '--version'], text=True).strip()
            self.assertEqual(result, 'wxc 0.1.0')
            result = self.run_cloud_python('from 运行支持 import wxc_binary; import json, subprocess; print(json.dumps(subprocess.check_output([wxc_binary(), "--version"], text=True).strip()))')
            self.assertEqual(result, 'wxc 0.1.0')

        def test_explicit_override_is_retained(self):
            alternative = self.root / 'alternative-wxc'
            alternative.write_text('#!' + sys.executable + '\nprint("synthetic client")\n')
            alternative.chmod(0o700)
            found = self.run_cloud_python('from 运行支持 import wxc_binary; import json; print(json.dumps(wxc_binary()))', alternative)
            self.assertEqual(Path(found), alternative)

        def test_timer_keeps_packaged_client(self):
            code = """import json
from pathlib import Path
from unittest.mock import patch
import 配置与配对 as setup
with patch.object(setup.subprocess, 'run') as run:
    setup.configure_timer(Path('unused-engine'))
body = (setup.config_path().parents[1] / 'systemd/user/wetype-sync.service').read_text()
print(json.dumps({'body': body, 'calls': run.call_count}))
"""
            result = self.run_cloud_python(code)
            self.assertIn('WETYPE_WXC=' + str(expected), result['body'])
            self.assertNotIn('ExecStart=/usr/bin/python3', result['body'])
            self.assertEqual(result['calls'], 2)

    result = unittest.TextTestRunner(verbosity=2).run(
        unittest.defaultTestLoader.loadTestsFromTestCase(BundledWxcTest))
    return 0 if result.wasSuccessful() else 1


if __name__ == '__main__':
    sys.exit(main())
