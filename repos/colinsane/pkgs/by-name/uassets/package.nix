{ stdenv
, lib
, fetchFromGitHub
, nix-update-script
}:
stdenv.mkDerivation {
  pname = "uassets";
  version = "0-unstable-2025-02-07";
  src = fetchFromGitHub {
    owner = "uBlockOrigin";
    repo = "uAssets";
    rev = "3768d8c8bcc3f7e02cea0a33769247a46a1de35c";
    hash = "sha256-GDfRfR5ql6HLEm9t2WW1uRVpaa3obIOv5Gn9di2fA8w=";
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
