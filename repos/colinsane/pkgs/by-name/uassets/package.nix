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
  version = "0-unstable-2026-10-24";
  src = fetchFromGitHub {
    owner = "uBlockOrigin";
    repo = "uAssets";
    rev = "c49e3951ff2150ec2b0d0c9b6f30d3d6cbf4e780";
    hash = "sha256-+Sg0EzYXi6+FcgxipdZN8NvvaXxYHp2KW0iBLukPXII=";
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
