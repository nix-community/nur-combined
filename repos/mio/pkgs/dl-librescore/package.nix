{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  makeWrapper,
  nodejs,
}:

buildNpmPackage rec {
  pname = "dl-librescore";
  version = "0.35.40";

  src = fetchFromGitHub {
    owner = "LibreScore";
    repo = "dl-librescore";
    rev = "v${version}";
    hash = "sha256-jCwySndc3ZeEoKVA9Ne2PLStyM73hDPO1vaNeVShwQ0=";
  };

  npmDepsHash = "sha256-WloDDqxUVVA/DzJq6Q+39kU9ZiUJubmshZVAZaxCBg0=";
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
