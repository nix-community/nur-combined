{ lib, stdenv, mkYarnPackage, fetchFromGitHub, secretsConfig ? null }:
let
  pname = "nakarte";
  version = "2022-09-02";
in
mkYarnPackage {
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    owner = "wladich";
    repo = "nakarte";
    rev = "c4392875048eeca01a50015f42d0a3d042b76989";
    hash = "sha256-VcZ/Ga8C67rWqmdeqWMHOSIa8v80LCLEqMhnHyzY3Pg=";
  };

  postPatch =
    if (secretsConfig != null) then
      "cp ${builtins.toFile "secrets.js" secretsConfig} src/secrets.js"
    else
      "cp src/secrets.js{.template,}";

  buildPhase = ''
    runHook preBuild

    yarn build

    runHook postBuild
  '';

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
