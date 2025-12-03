{
  bash,
  gopass-jsonapi,
  replaceVarsWith,
  stdenvNoCC,
}:
let
  gopass-wrapper = replaceVarsWith {
    src = ./gopass-wrapper.sh;
    isExecutable = true;
    replacements = {
      inherit bash gopass-jsonapi;
    };
  };
in
stdenvNoCC.mkDerivation {
  pname = "gopass-native-messaging-host";
  version = "1.0";
  src = ./.;

  installPhase = ''
    mkdir -p $out/bin $out/lib/mozilla/native-messaging-hosts
    cp ${gopass-wrapper} $out/bin/gopass-wrapper
    # XXX: have to use `substitute` instead of the nix `replaceVars` here because of the cyclic dependency with `out`:
    substitute ${./com.justwatch.gopass.json} $out/lib/mozilla/native-messaging-hosts/com.justwatch.gopass.json \
      --replace-fail "@out@" ${placeholder "out"}
  '';
}
