{ lib
, fetchFromGitHub
, chromium
#, python3
# python3.pkgs
, buildPythonApplication
# moved from src to separate package
# rm -rf src/undetected_chromedriver
, undetected-chromedriver
#, webtest
, bottle
, waitress
, func-timeout
, prometheus-client
# only required for linux
, xvfbwrapper
# only required for windows
#, pefile
}:

/*
  chromium forks:
    chromium
    ungoogled-chromium
    google-chrome
    ...
  note: chromedriver is always based on chromium
*/

if (
  (lib.versions.major undetected-chromedriver.bin.version) !=
  (lib.versions.major chromium.version)
)
then throw ''
  chromedriver and chromium must have the same major version.

  actual versions:
    chromedriver: ${undetected-chromedriver.bin.version}
    chromium    : ${chromium.version}
''
else

buildPythonApplication rec {
  pname = "flaresolverr";
  version = "3.3.10";

  # TODO why do we need both chromium and chromedriver?
  # == both FLARESOLVERR_CHROME_EXE_PATH and FLARESOLVERR_PATCHED_DRIVER_PATH

  src = fetchFromGitHub {
    /*
    owner = "FlareSolverr";
    repo = "FlareSolverr";
    rev = "v${version}";
    hash = "sha256-GN6CIy0Q0uFYYEyIiz5GcvG95W1oB1DsBGwZK/ZTQ78=";
    */
    # add some config envs
    # https://github.com/FlareSolverr/FlareSolverr/pull/992
    owner = "milahu";
    repo = "FlareSolverr";
    rev = "1466958442e4bd4b144ebaa86ea5c49a09ed2022";
    hash = "sha256-+DMBcNUGWmSjJm0Gk53FlGkIebm0sZi652/izH4UrKU=";
  };

  # tests require network access
  doCheck = false;

  /*
  checkInputs = [
    webtest
  ];
  */

  propagatedBuildInputs = [
    bottle
    waitress
    func-timeout
    prometheus-client
    # moved from src to separate package
    # rm -rf src/undetected_chromedriver
    undetected-chromedriver
    # only required for linux
    xvfbwrapper
    # only required for windows
    #pefile
  ];

  # TODO refactor with pkgs/build-support/chromium-depot-tools/chromium-depot-tools.nix
  # config for chromium depot_tools
  /*
    main_module=depot_tools
    main_module_path=.
  */

  # src/build_package.py does nothing special
  # except fetch chromium and run pyinstaller

  # FIXME SetuptoolsDeprecationWarning: setup.py install is deprecated.

  preBuild = ''
    echo "transforming python scripts to python modules"

    rm src/build_package.py

    # moved to separate package: undetected-chromedriver
    rm -rf src/undetected_chromedriver

    # add shebang line
    sed -i '1 i\#!/usr/bin/env python3' src/flaresolverr.py

    # move non-python files to the main_module_path
    # so they are installed as package_data in setup.py
    mv package.json src
    mv README.md src
    mv LICENSE src

    # python modules require a __init__.py file
    touch src/__init__.py

    # fix the module name
    mv src flaresolverr

    # config
    debug=false
    #debug=true
    main_module=flaresolverr
    main_module_path=flaresolverr

    sed_script=""

    # transform imports to module imports
    local_modules=$(
      pushd "$main_module_path" >/dev/null
      find . -name "*.py" -type f -printf "%P\n" |
      sed 's/\.py$//' |
      tr '/' '.' |
      sed 's/\.__init__$//' |
      sort -u |
      grep -vEx '(__init__|__main__)'
      popd >/dev/null
    )
    if $debug; then
      echo "local modules:"
      echo "$local_modules" | sed 's/^/  /'
    fi
    for local_module in $local_modules; do
      # FIXME handle more complex imports: import a, b as bb
      local_module_esc=$(echo $local_module | sed 's/\./\\./g')
      sed_script+="s/^(\s*)from\s+($local_module_esc)\s+import/\1from $main_module.\2 import/;"$'\n'
      sed_script+="s/^(\s*)import\s+($local_module_esc)\s+as/\1import $main_module.\2 as/;"$'\n'
      # rename import, because the script still expects the import name "\2"
      sed_script+="s/^(\s*)import\s+($local_module_esc)\b/\1import $main_module.\2 as \2/;"$'\n'
    done

    if $debug; then
      echo "------------ sed script to transform imports --------------"
      echo "$sed_script"
      echo "-----------------------------------------------------------"
    fi

    $debug && echo "adding missing main functions to scripts"
    added_main_fns=""
    while read py_file; do
      $debug && echo "f: $py_file"
      # transform imports
      sed -i -E "$sed_script" $py_file
      # maybe add a main() function
      # note: must take no arguments, so main(argv) would not work
      # fix: TypeError: main() missing 1 required positional argument: 'argv'
      # FIXME handle the noop case: if __name__ == "__main__": main()
      if grep -q -E "^def\s+main\s*\(\s*\)\s*:" $py_file; then
        $debug && echo "f: $py_file: already has a main() function"
        continue
      fi
      if grep -q -E "^if\s+__name__\s*==\s*['\"]__main__['\"]\s*:" $py_file; then
        $debug && echo "f: $py_file: case 1"
        # TODO why "main__noargs__"? why not just "main"?
        if false; then
          # TODO when adding "main__noargs__" then also use that name for console_scripts
          sed -i -E "s/^if\s+__name__\s*==\s*['\"]__main__['\"]\s*:/def main__noargs__():/;" $py_file
          echo -e "\nif __name__ == '__main__': main__noargs__()" >>$py_file
        else
          sed -i -E "s/^if\s+__name__\s*==\s*['\"]__main__['\"]\s*:/def main():/;" $py_file
          echo -e "\nif __name__ == '__main__': main()" >>$py_file
        fi
        added_main_fns+=" $py_file"
        continue
      fi
      if grep -q -F 'main(sys.argv)' $py_file; then
        sed -i -E "s/^def main\s*\(\s*((args|argv)(\s*:\s*List\[str\])?)/def main(\1 = sys.argv/;" $py_file
      elif grep -q -F 'main(sys.argv[1:])' $py_file; then
        sed -i -E "s/^def main\s*\(\s*((args|argv)(\s*:\s*List\[str\])?)/def main(\1 = sys.argv[1:]/;" $py_file
      elif grep -q -F 'main(sys.argv[2:])' $py_file; then
        # git_retry.py
        sed -i -E "s/^def main\s*\(\s*((args|argv)(\s*:\s*List\[str\])?)/def main(\1 = sys.argv[2:]/;" $py_file
      fi
    done < <(find . -name "*.py" -type f -printf "%P\n")

    if $debug; then
      for f in $added_main_fns; do
        echo "added main function to $f"
        echo -----------------------
        grep -C3 -w -E 'def\s+(main|main__noargs__)' "$f" || true
        echo -----------------------
      done
    fi

    setup_py_console_scripts=$(
      pushd "$main_module_path" >/dev/null
      while read f; do
        case "$(basename "$f")" in
          tests.py|tests_sites.py)
            # dont add to console_scripts
            continue
            ;;
          *)
            ;;
        esac
        if ! grep -q -E "^def\s+(main|main__noargs__)\s*\(" "$f"; then
          $debug && echo "setup_py_console_scripts: noo $f" >&2
          continue
        fi
        $debug && echo "setup_py_console_scripts: yes $f" >&2
        n=''${f%.py}
        n="$(basename "$n")" # FIXME handle filename collisions
        m=$(echo "$n" | tr '-' '_' | tr / .)
        if [[ " $added_main_fns " =~ " $f " ]]; then
          $debug && echo "setup_py_console_scripts: main__noargs__ $f" >&2
          echo "      '$n=$main_module.$m:main__noargs__',"
        else
          $debug && echo "setup_py_console_scripts: main $f" >&2
          echo "      '$n=$main_module.$m:main',"
        fi
      done < <(find . -name "*.py" -type f -printf "%P\n")
      popd >/dev/null
    )
    $debug && echo "setup_py_console_scripts: $setup_py_console_scripts"

    setup_py_packages=$(find . -name __init__.py -printf "%P\n" | xargs dirname | tr / . | sed 's/^.*$/    "&",/')
    $debug && echo "setup_py_packages: $setup_py_packages"

    cat >setup.py <<EOF
    from setuptools import setup
    setup(
      name='${pname}',
      packages=[
    $setup_py_packages
      ],
      version='${version}',
      install_requires=[
      ],
      entry_points={
        'console_scripts': [
    $setup_py_console_scripts
        ]
      },
      # also install all non-python files
      package_data = {
        "": [
          "*",
        ],
      },
    )
    EOF

    if $debug; then
      echo ----------- setup.py --------------
      cat setup.py
      echo -----------------------------------
    fi
  '';

  # set default env vars for flaresolverr
  makeWrapperArgs = [
    "--set-default" "CHROME_EXE_PATH" "${chromium}/bin/${chromium.meta.mainProgram}"
    "--set-default" "PATCHED_DRIVER_PATH" "${undetected-chromedriver.bin}/bin/chromedriver"
    "--set-default" "PATCHED_DRIVER_IS_PATCHED" "1"
  ];

  /*
  # fix: Testing via this command is deprecated
  checkPhase = ''
    runHook preCheck
    ${python3.interpreter} -m unittest
    runHook postCheck
  '';
  */

  pythonImportsCheck = [ "flaresolverr" ];

  meta = with lib; {
    description = "Proxy server to bypass Cloudflare protection";
    homepage = "https://github.com/FlareSolverr/FlareSolverr";
    changelog = "https://github.com/FlareSolverr/FlareSolverr/blob/${src.rev}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "flaresolverr";
    platforms = platforms.all;
  };
}
