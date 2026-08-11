{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "libgen-uploader";
  version = "0.2.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "ftruzzi";
    repo = "libgen_uploader";
    rev = "v${version}";
    hash = "sha256-MSCGU6JsFM8MCYiHeskXEHcCbHDAKAk56Ct8P1LY0Kw=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace \
        'returns = "0.16.0"' \
        'returns = "*"'
  '';

  build-system = [
    python3.pkgs.poetry-core
  ];

  dependencies = with python3.pkgs; [
    cerberus
    filetype
    requests-toolbelt
    returns
    robobrowser
    tqdm
  ];

  pythonImportsCheck = [
    "libgen_uploader"
  ];

  meta = {
    description = "A Library Genesis ebook uploader";
    homepage = "https://github.com/ftruzzi/libgen_uploader";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    # mainProgram = "libgen-uploader";
  };
}
