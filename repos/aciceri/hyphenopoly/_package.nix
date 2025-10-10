{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nix-update-script,
}:

buildNpmPackage rec {
  pname = "hyphenopoly";
  version = "6.0.0";

  src = fetchFromGitHub {
    owner = "mnater";
    repo = "Hyphenopoly";
    rev = "v${version}";
    hash = "sha256-d9q+JcGYtzgqZpMJSmieFKxtWhjRjLjMbsq8cODLBiA=";
  };

  npmDepsHash = "sha256-XzNMjHdbIhpBfLdFLGz9D64WCgPTQVNyufGYc1V4wU0=";

  buildPhase = ''
    runHook preBuild

    npm run prepare

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules/hyphenopoly
    cp -r . $out/lib/node_modules/hyphenopoly/

    mkdir -p $out/lib/node_modules/.bin
    ln -s ../hyphenopoly/hyphenopoly.module.js $out/lib/node_modules/.bin/hyphenopoly

    mkdir -p $out/share/hyphenopoly
    cp Hyphenopoly_Loader.js $out/share/hyphenopoly/
    cp Hyphenopoly.js $out/share/hyphenopoly/
    cp hyphenopoly.module.js $out/share/hyphenopoly/

    cp -r min/ $out/share/hyphenopoly/
    cp -r patterns/ $out/share/hyphenopoly/
    cp -r examples/ $out/share/hyphenopoly/

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Hyphenation for node and Polyfill for client-side hyphenation";
    homepage = "https://mnater.github.io/Hyphenopoly/";
    repository = "https://github.com/mnater/Hyphenopoly";
    license = licenses.mit;
    maintainers = with maintainers; [ aciceri ];
  };
}
