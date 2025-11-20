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
  version = "1.1.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "anlar";
    repo = "tewi";
    rev = "v${version}";
    sha256 = "sha256-WhbSF33jHnwuC5yOJ2tiF2KD5YcgBhatRsRLtpT7E84=";
  };

  build-system = [ python.pkgs.setuptools ];

  dependencies = with python.pkgs; [
    textual
    transmission-rpc
    pyperclip
    qbittorrent-api
    geoip2fast
  ];

  nativeCheckInputs = [ python.pkgs.pytestCheckHook ];

  meta = {
    description = "Text-based interface for BitTorrent clients (Transmission & qBittorrent)";
    mainProgram = "tewi";
    homepage = "https://github.com/anlar/tewi";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ misuzu ];
    platforms = lib.platforms.unix;
  };
}
