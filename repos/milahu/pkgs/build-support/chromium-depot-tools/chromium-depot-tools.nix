{ lib
, fetchgit
, buildPythonPackage
, ansi2html
, dateutil
, httplib2
, pylint
, keyring
, requests
, six
, some
}:

buildPythonPackage rec {
  pname = "depot-tools";
  version = "2023.08.21";

  src = fetchgit {
    url = "https://chromium.googlesource.com/chromium/tools/depot_tools";
    rev = "2d5c673fdb0072bb7b0c7463e6e7e18d0170b288";
    sha256 = "sha256-5JKENV//U2L2X+9Q+e0U5R7uY0hkPBeIXZpE9WhVzuQ=";
  };

  # fix: AttributeError: module 'collections' has no attribute 'MutableSet'
  postPatch = ''
    substituteInPlace testing_support/git_test_utils.py \
      --replace \
        'class OrderedSet(collections.MutableSet):' \
        'class OrderedSet(collections.abc.MutableSet):'
  '';

  # fix: nix_run_setup: error: Internal error
  doCheck = false;

  propagatedBuildInputs = [
    ansi2html
    dateutil
    httplib2
    pylint
    keyring
    requests
    six
    some
  ];

  preBuild = ''
    sed_script=""

    # transform imports to module imports
    local_modules=$(find . -name "*.py" -type f -printf "%P\n" | sed 's/\.py$//' | tr '/' '.' | sed 's/\.__init__$//' | sort -u)
    for local_module in $local_modules; do
      local_module_esc=$(echo $local_module | sed 's/\./\\./g')
      sed_script+="s/^(\s*)from\s+($local_module_esc)\s+import/\1from .\2 import/;"$'\n'
      sed_script+="s/^(\s*)import\s+($local_module_esc)/\1from . import \2/;"$'\n'
    done

    added_main_fns=""
    while read py_file; do
      sed -i -E "$sed_script" $py_file
      # fix: TypeError: main() missing 1 required positional argument: 'argv'
      if grep -q -E "^if __name__ == ['\"]__main__['\"]:" $py_file; then
        sed -i -E "s/^if __name__ == ['\"]__main__['\"]:/def main__noargs__():/;" $py_file
        echo "if __name__ == '__main__': main__noargs__()" >>$py_file
        added_main_fns+=" $py_file"
        continue
      fi
      if grep -q -F 'main(sys.argv)' $py_file; then
        sed -i -E "s/^def main\(((args|argv)(:\s*List\[str\])?)/def main(\1 = sys.argv/;" $py_file
      elif grep -q -F 'main(sys.argv[1:])' $py_file; then
        sed -i -E "s/^def main\(((args|argv)(:\s*List\[str\])?)/def main(\1 = sys.argv[1:]/;" $py_file
      elif grep -q -F 'main(sys.argv[2:])' $py_file; then
        # git_retry.py
        sed -i -E "s/^def main\(((args|argv)(:\s*List\[str\])?)/def main(\1 = sys.argv[2:]/;" $py_file
      fi
    done < <(find . -name "*.py" -type f -printf "%P\n")

    touch __init__.py

    # fix: [Errno 30] Read-only file system
    substituteInPlace metrics.py \
      --replace \
        "CONFIG_FILE = os.path.join(DEPOT_TOOLS, 'metrics.cfg')" \
        "CONFIG_FILE = os.path.join(os.environ.get('DEPOT_TOOLS_METRICS_DIR', DEPOT_TOOLS), 'metrics.cfg')" \
      --replace \
        "UPLOAD_SCRIPT = os.path.join(DEPOT_TOOLS, 'upload_metrics.py')" \
        "UPLOAD_SCRIPT = os.path.join(os.environ.get('DEPOT_TOOLS_METRICS_DIR', DEPOT_TOOLS), 'upload_metrics.py')" \
      --replace \
        "'Metrics collection will be disabled.'" \
        "'Metrics collection will be disabled.\nTo enable metrics, set DEPOT_TOOLS_METRICS_DIR to a writable path.\n'" \

    # fix: [Errno 30] Read-only file system
    substituteInPlace reclient_metrics.py \
      --replace \
        "CONFIG = os.path.join(THIS_DIR, 'reclient_metrics.cfg')" \
        "CONFIG = os.path.join(os.environ['DEPOT_TOOLS_METRICS_DIR'], 'reclient_metrics.cfg')" \

    # fix: [Errno 30] Read-only file system
    substituteInPlace gsutil.py \
      --replace \
        "bin_dir = os.environ.get('DEPOT_TOOLS_GSUTIL_BIN_DIR', DEFAULT_BIN_DIR)" \
        "bin_dir = os.environ['DEPOT_TOOLS_GSUTIL_BIN_DIR']" \

    # fix: ModuleNotFoundError: No module named 'third_party'
    substituteInPlace ninjalog_uploader.py \
      --replace \
        "from third_party.six.moves.urllib import request" \
        "from .third_party.six.moves.urllib import request" \

    setup_py_console_scripts=$(
      grep -l "^def main(" *.py |
      while read f; do
        echo "setup_py_console_scripts: f: $f" >&2
        n=''${f%.*}
        m=$(echo "$n" | tr '-' '_')
        if [[ " $added_main_fns " =~ " $f " ]]; then
          echo "setup_py_console_scripts: main__noargs__" >&2
          echo "      '$n=depot_tools.$m:main__noargs__',"
        else
          echo "setup_py_console_scripts: main" >&2
          echo "      '$n=depot_tools.$m:main',"
        fi
      done
    )

    # fix: ModuleNotFoundError: No module named 'depot_tools.gclient_new_workdir'
    ln -s gclient-new-workdir.py gclient_new_workdir.py

    mkdir depot_tools
    mv * depot_tools || true

    # required by bin/fetch
    touch depot_tools/fetch_configs/__init__.py

    setup_py_packages=$(find . -name __init__.py -printf "%P\n" | xargs dirname | tr / . | sed 's/^.*$/  "&",/')

    cat >setup.py <<EOF
    from setuptools import setup
    setup(
      name='${pname}',
      packages=[
    $setup_py_packages
      ],
      version='${version}',
      description='Tools for working with Chromium development',
      install_requires=[
        'ansi2html',
        'python-dateutil',
        'httplib2',
        'pylint',
        'keyring',
        'requests',
        'six',
        'some',
      ],
      entry_points={
        'console_scripts': [
    $setup_py_console_scripts
        ]
      },
    )
    EOF
  '';

  meta = with lib; {
    description = "Tools for working with Chromium development";
    homepage = "https://chromium.googlesource.com/chromium/tools/depot_tools";
    license = licenses.bsd3;
    maintainers = with maintainers; [ ];
  };
}
