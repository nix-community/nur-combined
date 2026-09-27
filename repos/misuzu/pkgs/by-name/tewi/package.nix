{
  lib,
  fetchPypi,
  fetchFromGitHub,
  python3,
}:

let
  python = python3.override {
    self = python;
    packageOverrides = self: super: {
      geoip2fast = self.callPackage ./geoip2fast.nix { };
    };
  };
in
python.pkgs.buildPythonApplication rec {
  pname = "tewi";
  version = "2.6.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "anlar";
    repo = "tewi";
    rev = "v${version}";
    sha256 = "sha256-VOITB8YN+TXkG3Wpqv/twwbPuxPkVa8F1Su/914kPE8=";
  };

  build-system = [ python.pkgs.setuptools ];

  dependencies = with python.pkgs; [
    textual
    transmission-rpc
    pyperclip
    qbittorrent-api
    geoip2fast
    platformdirs
    shtab
  ];

  nativeCheckInputs = [ python.pkgs.pytestCheckHook ];

  disabledTestPaths = [
    "tests/tewi/torrent/clients/test_transmission.py"
    "tests/tewi/torrent/test_factory.py"
  ];

  pythonRelaxDeps = [
    "shtab"
  ];

  preBuild = ''
    mkdir -p completions/bash
    touch completions/bash/tewi
  '';

  meta = {
    description = "Text-based interface for BitTorrent clients (Transmission & qBittorrent)";
    mainProgram = "tewi";
    homepage = "https://github.com/anlar/tewi";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ misuzu ];
    platforms = lib.platforms.unix;
  };
}
