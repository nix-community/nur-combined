{ self, ... }: let
  buildWeechatScript = self.callPackage ({ lib, stdenvNoCC, fetchurl }: {
    pname, version, sha256, ...
  }: stdenvNoCC.mkDerivation {
    inherit version;
    pname = "weechat-script-${pname}";
    src = fetchurl {
      url = "https://weechat.org/files/scripts/${pname}";
      inherit sha256;
    };
    passthru.scripts = [ pname ];

    unpackPhase = "true";
    installPhase = ''
      install -D $src $out/share/${pname}
    '';
  }) { };
in {
  inherit buildWeechatScript;
}
