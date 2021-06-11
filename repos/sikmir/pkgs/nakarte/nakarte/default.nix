{ lib, stdenv, mkYarnPackage, fetchFromGitHub, secretsConfig ? null }:
let
  pname = "nakarte";
  version = "2021-05-26";
in
mkYarnPackage {
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    owner = "wladich";
    repo = pname;
    rev = "0ff218eac60f4d383f4634aef525331173fe1b97";
    hash = "sha256-DO02Ygyq7hlux88HlJzmA9glAOVSlo0UJ7LCbbY8E2E=";
  };

  postPatch =
    if (secretsConfig != null) then
      "cp ${builtins.toFile "secrets.js" secretsConfig} src/secrets.js"
    else
      "cp src/secrets.js{.template,}";

  buildPhase = "yarn build";

  installPhase = ''
    install -dm755 $out
    cp -r deps/nakarte/build/* $out
  '';

  distPhase = "true";

  meta = with lib; {
    homepage = "https://github.com/wladich/nakarte";
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
    broken = true; # error while evaluating 'importJSON', only on NUR CI
  };
}
