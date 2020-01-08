{ self, ... }: let
  buildWeechatScript = self.callPackage ({ lib, stdenvNoCC, fetchurl }: {
    pname, version, sha256, ...
  }@args: stdenvNoCC.mkDerivation ({
    pname = "weechat-script-${pname}";
    src = fetchurl {
      url = "https://weechat.org/files/scripts/${pname}";
      inherit sha256;
    };
    passthru.scripts = [ pname ];

    unpackPhase = ''
      runHook preUnpack

      sourceRoot=$pname
      mkdir $sourceRoot
      cp $src $sourceRoot/${pname}

      runHook postUnpack
    '';
    installPhase = ''
      runHook preInstall

      install -D ${pname} $out/share/${pname}

      runHook postInstall
    '';
  } // builtins.removeAttrs args [ "pname" "sha256" ])) { };
in {
  inherit buildWeechatScript;
}
