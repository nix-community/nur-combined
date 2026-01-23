{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  makeWrapper,
  nodejs,
}:

buildNpmPackage rec {
  pname = "dl-librescore";
  version = "0.35.34";

  src = fetchFromGitHub {
    owner = "LibreScore";
    repo = "dl-librescore";
    rev = "040f23db5855e8db9c497abd1e6a5ba83c044e19";
    hash = "sha256-IuHX4wFhilSK09WWNopHtkAfd9Mm2oo5M2m4KcRkCBE=";
  };

  npmDepsHash = "sha256-qnWCvf5bNcYazsgop1Zza/8p/36W2QU8XIX6I9eSE/8=";
  forceGitDeps = true;
  makeCacheWritable = true;

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    rm -f $out/bin/dl-librescore
    makeWrapper ${lib.getExe nodejs} $out/bin/dl-librescore \
      --add-flags $out/lib/node_modules/${pname}/dist/cli.js
  '';

  meta = {
    description = "Command-line tool to download sheet music from MuseScore";
    homepage = "https://github.com/LibreScore/dl-librescore";
    license = lib.licenses.mit;
    mainProgram = "dl-librescore";
    platforms = lib.platforms.all;
  };
}
