{ stdenv
, lib
, fetchFromGitHub
, nix-update-script
}:
stdenv.mkDerivation {
  pname = "uassets";
  version = "0-unstable-2025-01-13";
  src = fetchFromGitHub {
    owner = "uBlockOrigin";
    repo = "uAssets";
    rev = "a4656bded116b131a5051e55fba8dc020b8737ed";
    hash = "sha256-XYkq71rYCY9jhH464m4vMgaarakTicWBW91GtmkVj+4=";
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

  passthru.updateScript = nix-update-script {
    # XXX(2024/05/26): why does `--version unstable` not work, but `--version branch` *does*??
    extraArgs = [ "--version" "branch" ];
  };

  meta = with lib; {
    homepage = "https://github.com/uBlockOrigin/uAssets";
    description = "official uBlock Origin filter lists";
    maintainers = with maintainers; [ colinsane ];
  };
}
