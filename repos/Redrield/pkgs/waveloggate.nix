{ buildNpmPackage, fetchFromGitHub, electron }:
buildNpmPackage rec {
  pname = "wavelog-gate";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "wavelog";
    repo = "WaveLogGate";
    rev = "v${version}";
    hash = "sha256-/qYqKgMoWV4kkSn1hZ4019j9DTt8n+7A57K60qPCkYA=";
  };

  nativeBuildInputs = [ electron ];

  makeCacheWritable = true;

  npmDepsHash = "sha256-5EeZCHy1LpT4TJD+WBpj1DTTOFjvCtDBtq5mH795Ki0=";

  /* postUnpack = ''
    substituteInPlace $src/package.json --replace-fail "wavelog-gate-by-dj7nt" "${pname}"
  ''; */

  buildPhase = ''
    npm run make
  '';

  dontNpmBuild = true;

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = 1;
  };

  postInstall = ''
    ls $out/lib
    ls $out/bin
    makeWrapper ${electron}/bin/electron $out/bin/${pname} \
      --add-flags $out/lib/node_modules/${pname}/main.js
  '';
}
