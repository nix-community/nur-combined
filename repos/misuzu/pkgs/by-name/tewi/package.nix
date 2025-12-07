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
  version = "2.0.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "anlar";
    repo = "tewi";
    rev = "v${version}";
    sha256 = "sha256-V4luvPDn+bQ5hGS4SmaIC/cZD8nqMdjwuwIMPhcU4Kw=";
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
