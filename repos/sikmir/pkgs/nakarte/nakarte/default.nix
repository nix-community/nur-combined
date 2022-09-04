{ lib, stdenv, mkYarnPackage, fetchFromGitHub, secretsConfig ? null }:
let
  pname = "nakarte";
  version = "2021-07-17";
in
mkYarnPackage {
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    owner = "wladich";
    repo = "nakarte";
    rev = "4163b36921d867f314de5351e079bd3d8ce6e444";
    hash = "sha256-9klRyrnpdL0RJ8FupICbViG/oa3IFwqDcA6xoP9CvIs=";
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
