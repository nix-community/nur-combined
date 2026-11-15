{
  stdenvNoCC,
  lib,
  fetchFromGitHub,
  nix-update-script,
  update-guard,
  updater-tools,
}:
stdenvNoCC.mkDerivation {
  pname = "uassets";
  version = "0-unstable-2026-11-13";
  src = fetchFromGitHub {
    owner = "uBlockOrigin";
    repo = "uAssets";
    rev = "9d57eba52ae604f26ec751e3919b71d0e2f37a9d";
    hash = "sha256-OLSA9ZgY2a/SYEvAYo1urPIMrqxMtlk0mrVuRCsUbfw=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/filters
    for f in $(ls filters); do
      cp "filters/$f" "$out/share/filters/ublock-$f"
    done
    cp thirdparties/easylist/* $out/share/filters
    cp thirdparties/pgl.yoyo.org/as/serverlist $out/share/filters/pgl-serverlist.txt
    cp thirdparties/urlhaus-filter/*.txt $out/share/filters
  '';

  passthru.updateScript = updater-tools.requireAll [
    update-guard.weekly
    (nix-update-script {
      # XXX(2024/05/26): why does `--version unstable` not work, but `--version branch` *does*??
      extraArgs = [ "--version" "branch" ];
    })
  ];

  meta = {
    description = "official uBlock Origin filter lists";
    homepage = "https://github.com/uBlockOrigin/uAssets";
    maintainers = with lib.maintainers; [ colinsane ];
    platforms = lib.platforms.linux;
  };
}
