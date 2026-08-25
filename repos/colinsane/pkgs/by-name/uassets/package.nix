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
  version = "0-unstable-2026-08-24";
  src = fetchFromGitHub {
    owner = "uBlockOrigin";
    repo = "uAssets";
    rev = "424b3a670b66f89ec204176e3ee683042ae3ee8a";
    hash = "sha256-rD0MIFwi+A1Z/l1s6lPyjaTYl8PKeCiSsHD1/JRAIx0=";
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
    homepage = "https://github.com/uBlockOrigin/uAssets";
    description = "official uBlock Origin filter lists";
    maintainers = with lib.maintainers; [ colinsane ];
  };
}
