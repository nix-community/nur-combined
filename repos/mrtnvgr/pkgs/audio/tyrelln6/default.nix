{ stdenv, fetchurl }:
stdenv.mkDerivation {
  name = "Tyrell N6";
  version = "3.0-beta16976";

  src = fetchurl {
    url = "https://dl.u-he.com/releases/TyrellN6_300_public_beta_16976_Linux.tar.xz";
    hash = "sha256-c6xy/unbMjD+mgoNfqtxnYSQ+w6edcqIHmCAStLsZPI=";
  };

  patchPhase = ''
    rm TyrellN6/dialog{,.64}
  '';

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share
    cp -r TyrellN6 $out/share/TyrellN6

    mkdir -p $out/lib/vst3
    ln -s $out/share/TyrellN6/TyrellN6.64.so $out/lib/vst3/TyrellN6.64.so

    runHook postInstall
  '';
}
