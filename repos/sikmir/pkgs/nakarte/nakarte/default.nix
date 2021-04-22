{ lib, stdenv, mkYarnPackage, fetchFromGitHub, secretsConfig ? null }:
let
  pname = "nakarte";
  version = "2021-04-16";
in
mkYarnPackage {
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    owner = "wladich";
    repo = pname;
    rev = "ddc52268bd00f656ac1d4301b580c287c84f314d";
    sha256 = "sha256-cxyxT7B12HtfQ5vx2p1DS8Ol3eZ0U7W1oy0jLw6YN+Y=";
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
