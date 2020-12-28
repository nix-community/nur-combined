{ stdenv, mkYarnPackage, sources, secretsConfig ? null }:
let
  pname = "nakarte";
  version = stdenv.lib.substring 0 10 sources.nakarte.date;
in
mkYarnPackage {
  name = "${pname}-${version}";

  src = sources.nakarte;

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

  meta = with stdenv.lib; {
    inherit (sources.nakarte) description homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
    broken = true; # error while evaluating 'importJSON', only on NUR CI
  };
}
