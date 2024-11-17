{
  lib,
  fetchFromGitHub,
  gitUpdater,
  python3,
  stdenv,
}: stdenv.mkDerivation (finalAttrs: {
  pname = "doc2dash";
  version = "3.1.0";

  src = fetchFromGitHub {
    owner = "hynek";
    repo = "doc2dash";
    rev = finalAttrs.version;
    hash = "sha256-u6K+BDc9tUxq4kCekTaqQLtNN/OLVc3rh14sVSfPtoQ=";
  };

  postFixup = ''
    wrapPythonPrograms
  '';

  nativeBuildInputs = [
    python3.pkgs.hatch-fancy-pypi-readme
    python3.pkgs.hatch-vcs
    python3.pkgs.hatchling
    python3.pkgs.pypaBuildHook
    python3.pkgs.pypaInstallHook
    python3.pkgs.wrapPython
  ];

  propagatedBuildInputs = [
    python3.pkgs.attrs
    python3.pkgs.beautifulsoup4
    python3.pkgs.click
    python3.pkgs.rich
  ];

  nativeCheckInputs = [
    python3.pkgs.pythonImportsCheckHook
    python3.pkgs.pytestCheckHook
  ];

  pythonImportsCheck = [
    "doc2dash"
    "doc2dash.convert"
    "doc2dash.docsets"
    "doc2dash.output"
    "doc2dash.parsers"
  ];

  doCheck = true;

  passthru.updateScript = gitUpdater { };

  meta = with lib; {
    homepage = "https://doc2dash.hynek.me/";
    description = "Create docsets for Dash.app-compatible API browsers";
    maintainers = with maintainers; [ colinsane ];
  };
})
