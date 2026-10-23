# TODO cleanup

{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  # pkgs.python3.pkgs.playwright
  playwright,
  setuptools,
  toml,
  auditwheel,
  python,
  # playwright-driver,
  patchright-driver,
}:

let
  # driver = playwright-driver;
  driver = patchright-driver;

  patchrightPythonSrcHashByVersion = {
    "1.61.0" = "sha256-2CiN1yxX0Bn+codnzb5DOVR4Dq4ZCICiUItXJjSP4n0=";
    "1.62.0" = "sha256-zgRk0bnzQy/xFJqoU98xmQEmBS2fq3QUOIaw14WXpFc=";
    # TODO add more hashes
    # https://github.com/Kaliiiiiiiiii-Vinyzu/patchright-python/tags
  };
in

playwright.overridePythonAttrs (oldAttrs: rec {

  # TODO? keep version and src
  # pname = "patchright-${patchright-version}-playwright";

  pname = "patchright";

  # version = "1.62.0";
  # patchright version must equal playwright version
  version = oldAttrs.version;

  /*
  playwrightVersion =
    # patchright version must equal playwright version
    # if version != oldAttrs.version then throw "patchright.version != playwright.version. patchright.version = ${version}. playwright.version = ${oldAttrs.version}" else
    oldAttrs.version;
  */

  playwrightSrc = oldAttrs.src;

  # fix: evaluation warning: python3.14-playwright-1.61.0 was overridden with `version` but not `src`
  src = fetchFromGitHub {
    owner = "Kaliiiiiiiiii-Vinyzu";
    repo = "patchright-python";
    # tag = "v${finalAttrs.version}";
    tag = "v${version}";
    hash = patchrightPythonSrcHashByVersion.${version} or (
      builtins.trace ''
        patchright-python: TODO add hash to patchrightPythonSrcHashByVersion:
          patchrightPythonSrcHashByVersion = {
            "${version}" = "TODO_hash";
          };
      ''
      "" # empty hash
    );
  };

  postUnpack = ''
    mv $sourceRoot patchright-python
    cp -r --no-preserve=owner,mode ${playwrightSrc} $sourceRoot
    mv patchright-python $sourceRoot
    ln -s .. $sourceRoot/patchright-python/playwright-python
  '';

  build-system = oldAttrs.build-system ++ [
    toml
  ];

  dependencies = oldAttrs.dependencies ++ [
    auditwheel
  ];

  postPatch = ''
    if false; then
    echo unpinning dependencies
    # requires = ["setuptools==83.0.0", "setuptools-scm==10.3.4", "wheel==0.48.0", "auditwheel==6.7.0"]
    sed -i '/^requires = /s/==[^", ]*//g' pyproject.toml
    fi

    pushd patchright-python >/dev/null

    # cp -v playwright-python/setup.py{,.bak}
    cp -v playwright-python/scripts/build_driver.py{,.bak}

    echo "running patch_python_package.py ..."
    python patch_python_package.py
    echo "running patch_python_package.py done"

    # diff -u --color=always playwright-python/setup.py{.bak,} || true
    diff -u --color=always playwright-python/scripts/build_driver.py{.bak,} || true

    popd >/dev/null

    # exit 1

    # set -x

    # unpin dependencies in pyproject.toml
    # remove setup.py
    # no, this fails at
    #   grep -q 'requires = \["setuptools==.*", "setuptools-scm==.*", "wheel==.*", "auditwheel==.*"\]' pyproject.toml
    ${if true then "" else oldAttrs.postPatch}

    echo unpinning dependencies
    # requires = ["setuptools==83.0.0", "setuptools-scm==10.3.4", "wheel==0.48.0", "auditwheel==6.7.0"]
    sed -i '/^requires = /s/==[^", ]*//g' pyproject.toml

    echo removing setup.py
    # setup.py downloads and extracts the driver.
    # This is done manually in postInstall instead.
    rm setup.py
  '';

  postInstall = ''
    ln -s ${driver} $out/${python.sitePackages}/patchright/driver
  '';

  pythonImportsCheck = [ "patchright" ];
})
