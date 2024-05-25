{
  lib,
  mkYarnPackage,
  fetchFromGitHub,
  secretsConfig ? null,
}:
let
  pname = "nakarte";
  version = "2022-12-28";
in
mkYarnPackage {
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    owner = "wladich";
    repo = "nakarte";
    rev = "4d90013d9eaf802ff25bc1d29add6ea01f2f025b";
    hash = "sha256-ksblTz+EyT6Dc3cG03QYNQYSN9TnC1Ly7t9sllpvDAM=";
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

  meta = {
    homepage = "https://github.com/wladich/nakarte";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.all;
    skip.ci = true;
    broken = true; # error while evaluating 'importJSON', only on NUR CI
  };
}
