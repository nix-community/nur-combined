{ stdenv, fetchurl, mkYarnPackage, makeWrapper, nodejs }:

mkYarnPackage rec {
  name = "smloadr";
  version = "1.23.0";

  src = fetchurl {
    url = "https://git.fuwafuwa.moe/SMLoadrDev/SMLoadr/archive/v${version}.tar.gz";
    sha256 = "0k9rpk9lbfmfcdpiv7lldpk2lrg0xv9sa1a60qmjiycki9999hrc";
  };

  nativeBuildInputs = [ makeWrapper ];

  yarnNix = ./yarn.nix;
  yarnLock = ./yarn.lock;
  packageJSON = ./package.json;

  distPhase = ''
    runHook preDist
    #mkdir -p $out
    #cp -R {app.js,bin,lib,locales,node_modules,package.json,public} $out
    cat > $out/bin/smloadr <<EOF
      #!${stdenv.shell}/bin/sh
      ${nodejs}/bin/node $out/bin/SMLoadr
    EOF
    chmod +x $out/bin/smloadr
    wrapProgram $out/bin/smloadr \
      --set NODE_PATH "$out/libexec/SMLoadr/node_modules"
    runHook postDist
  '';

  meta = with stdenv.lib; {
    description = "A streaming music downloader";
    homepage = "https://git.fuwafuwa.moe/SMLoadrDev/SMLoadr";
    license = licenses.cc-by-nc-40;
    platforms = platforms.linux;
  };
}
