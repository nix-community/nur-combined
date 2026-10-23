{
  lib,
  python3Packages,
  fetchFromGitHub,
  nix-update-script,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "qbittorrent-dual-boot-py";
  version = "0.1.3";
  pyproject = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "HHR2020";
    repo = "qbittorrent-dual-boot-py";
    tag = "v${finalAttrs.version}";
    hash = "sha256-uJDSqAIRIA3yn9WvuN1e5zU1WCZCE0+Ck+VA4q0YsLQ=";
  };

  build-system = [
    python3Packages.setuptools
  ];

  dependencies = with python3Packages; [
    bencode-py
  ];

  pythonRelaxDeps = [ "bencode-py" ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Convert qBittorrent .fastresume save paths between Windows and Linux";
    homepage = "https://github.com/HHR2020/qbittorrent-dual-boot-py";
    license = with lib.licenses; [
      gpl3Only
      gpl3Plus
    ];
    maintainers = with lib.maintainers; [ hhr2020 ];
    mainProgram = "qbittorrent-dual-boot";
  };
})
