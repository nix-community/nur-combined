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
  version = "0-unstable-2026-07-14";
  src = fetchFromGitHub {
    owner = "uBlockOrigin";
    repo = "uAssets";
    rev = "fa5cdd415c014913abbb3dde9a974fe398d93b36";
    hash = "sha256-/5froqO4U3oZwCiZJLqbhLvJec9ihFNIxXc27PJcrIY=";
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
