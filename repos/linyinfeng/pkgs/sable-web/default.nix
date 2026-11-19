{
  lib,
  stdenvNoCC,
  fetchurl,
  nix-update-script,
}:

stdenvNoCC.mkDerivation rec {
  pname = "sable-web";
  version = "26.11.4";

  src = fetchurl {
    url = "https://git.sable.moe/SableClient/sable-next/releases/download/v${version}/sable-${version}-web.tar.gz";
    hash = "sha256-jTgpYI/ZY3cuXc+zE4Wv2P5t6f7gie+c4HY1L6LJ1hI=";
  };

  unpackPhase = ''
    runHook preUnpack
    mkdir source
    tar -xzf $src -C source
    cd source
    runHook postUnpack
  '';
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r . $out/
    runHook postInstall
  '';

  passthru = {
    updateScriptEnabled = true;
    updateScript = nix-update-script { attrPath = pname; };
  };

  meta = {
    description = "Matrix web client written in Rust and Svelte";
    homepage = "https://git.sable.moe/SableClient/sable-next";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ yinfeng ];
    platforms = lib.platforms.all;
  };
}
