{ lib, stdenv, mkYarnPackage, fetchFromGitHub, secretsConfig ? null }:
let
  pname = "nakarte";
  version = "2021-05-10";
in
mkYarnPackage {
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    owner = "wladich";
    repo = pname;
    rev = "bf99c7ed4a2cd39af667f21b68e39619a7c38f07";
    hash = "sha256-W1lUZvff4TGxwP9+LOeJ9Sr+cGtSlDrx1iFrxkkPRfM=";
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
