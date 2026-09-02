{ stdenv, fetchurl, lib }:

stdenv.mkDerivation (finalAttrs: {
  pname = "qoder-cli";
  version = "1.1.6";

  src = fetchurl {
    url = "https://static.qoder.com.cn/qoder-cli-cn/releases/${finalAttrs.version}/qoderclicn-linux-x64.tar.gz";
    hash = "sha256-qSifJp/I7wFM+RTi3vtrRwUoA0tS9T9rweRno8In10s=";
  };

  sourceRoot = ".";

  dontStrip = true;

  installPhase = ''
    mkdir -p $out/bin
    cp qoderclicn $out/bin/
    chmod +x $out/bin/qoderclicn
  '';

  meta = {
    description = "Qoder CLI CN - Terminal-based AI assistant for code development (Chinese version)";
    homepage = "https://qoder.com.cn";
    platforms = [ "x86_64-linux" ];
    license = lib.licenses.unfreeRedistributable;
    mainProgram = "qoderclicn";
  };
})
