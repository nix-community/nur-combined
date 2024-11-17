{ stdenv
, bash
, gopass-jsonapi
, substituteAll
}:

stdenv.mkDerivation {
  pname = "gopass-native-messaging-host";
  version = "1.0";
  src = ./.;

  inherit bash;
  # substituteAll doesn't work with hyphenated vars ??
  gopassJsonapi = gopass-jsonapi;

  installPhase = ''
    mkdir -p $out/bin $out/lib/mozilla/native-messaging-hosts
    substituteAll ${./gopass-wrapper.sh} $out/bin/gopass-wrapper
    chmod +x $out/bin/gopass-wrapper
    substituteAll ${./com.justwatch.gopass.json} $out/lib/mozilla/native-messaging-hosts/com.justwatch.gopass.json
  '';
}
