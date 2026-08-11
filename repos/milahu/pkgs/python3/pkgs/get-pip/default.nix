# note: this package is not in pypi

# see also: https://pip.pypa.io/en/stable/installation/

{ lib
, fetchFromGitHub
, fetchPypi
, buildPythonPackage
, requests
, cachecontrol
, packaging
, pkg-metadata
, rich
, filelock
}:

buildPythonPackage rec {
  pname = "get-pip";
  version = "24.0";

  src = fetchFromGitHub {
    owner = "pypa";
    repo = "get-pip";
    rev = version;
    hash = "sha256-lf85Aw6UVBoN8qmZcRCBplKU+qxuEkUOzbxsa7kfBVA=";
  };

  pip-whl = let
    version = "24.0";
  in ((fetchPypi {
    pname = "pip";
    inherit version;
    hash = "sha256-ug0CGhZoZdImUkaWG+wBUv8STekQxcw58RVs4/p8adw=";
    format = "wheel";
    dist = "py3";
    python = "py3";
    platform = "any";
    # no. error: function 'computeWheelUrl' called with unexpected argument 'passthru'
    #passthru = { inherit version; };
  }) // { inherit version; });

  propagatedBuildInputs = [
    requests
    cachecontrol
    packaging
    pkg-metadata
    rich
    filelock # for cachecontrol
  ];

  preBuild = ''
    sed -i '1 i\#!/usr/bin/env python3' scripts/generate.py scripts/check_zipapp.py
    chmod +x scripts/generate.py scripts/check_zipapp.py

    substituteInPlace scripts/generate.py \
      --replace-fail \
        'import io' \
        'import io, os' \
      --replace-fail \
        "Path(\"" \
        "Path(\"$out/opt/get-pip/" \
      --replace-fail \
        '    data = requests.get(' \
        "$(
          echo '    if os.getenv("GET_PIP_OFFLINE") == "1":'
          echo '        return {Version("${pip-whl.version}"): ("${pip-whl}", "'$(sha256sum ${pip-whl} | cut -c1-64)'")}'
          echo '    data = requests.get('
        )" \
      --replace-fail \
        '        for variant, mapping in populated_script_constraints(SCRIPT_CONSTRAINTS):' \
        "$(
          echo '        for variant, mapping in populated_script_constraints(SCRIPT_CONSTRAINTS):'
          echo '            if os.getenv("GET_PIP_OFFLINE") == "1" and variant != "default": continue'
        )" \
      --replace-fail \
        'def download_wheel(url: str, expected_sha256: str) -> bytes:' \
        "$(
          echo 'def download_wheel(url: str, expected_sha256: str) -> bytes:'
          echo '    if os.getenv("GET_PIP_OFFLINE") == "1" and url[0] == "/":'
          echo '        with open(url, "rb") as f:'
          echo '            response_content = f.read()'
          echo '        hashobj = hashlib.sha256()'
          echo '        hashobj.update(response_content)'
          echo '        assert hashobj.hexdigest() == expected_sha256'
          echo '        return response_content'
        )" \

    mv -v scripts/generate.py get-pip-generate
    mv -v scripts/check_zipapp.py get-pip-check-zipapp

    cat > setup.py << EOF
    from setuptools import setup
    setup(
      name="${pname}",
      packages=[],
      version="${version}",
      description="${meta.description}",
      install_requires=[
        "requests",
        "cachecontrol",
        "packaging",
        "pkg-metadata",
        "rich",
        "filelock", # for cachecontrol
      ],
      scripts=[
        "get-pip-generate",
        "get-pip-check-zipapp",
      ],
    )
    EOF
  '';

  postInstall = ''
    mkdir -p $out/opt/get-pip
    cp -r * $out/opt/get-pip
    rm $out/opt/get-pip/setup.py
  '';

  meta = with lib; {
    description = "Helper scripts to install pip, in a Python installation that doesn't have it";
    longDescription = ''
      run "GET_PIP_OFFLINE=1 get-pip-generate" to generate public/get-pip.py
    '';
    homepage = "https://github.com/pypa/get-pip";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "get-pip-generate";
    platforms = platforms.all;
  };
}
