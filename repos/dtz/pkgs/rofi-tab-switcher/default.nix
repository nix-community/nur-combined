{ stdenv, fetchFromGitHub, runCommand, writeText
, rofi, python3 }:

let
  manifest = {
    name = "rofi_interface";
    description = "Native backend for rofi tab switcher.";
    type = "stdio";
    allowed_extensions = [ "@rofi.tab.switcher" ];
    path = "${native_helper}/bin/rofiface";
  };
  native_helper = stdenv.mkDerivation rec {
    pname = "rofi-tab-switcher";
    version = "unstable-2019-09-07";

    src = fetchFromGitHub {
      owner = "blackhole89";
      repo = pname;
      rev = "92fbd93114a9058d6ae7c7cd339e299fd6c6d0b9";
      sha256 = "19lh4jgqc3lmakwnqknsac1iq2dg8f5i8xl783vfm5aw57gvp48c";
    };

    buildInputs = [ python3 ];

    dontBuild = true;

    postPatch = ''
      substituteInPlace rofiface.py \
      --replace 'Popen("rofi ' \
                'Popen("${rofi}/bin/rofi '
    '';

    # XXX: Maybe put into libexec instead, since not meant for PATH
    installPhase = ''
      install -Dm755 rofiface.py $out/bin/rofiface
      patchShebangs $out/bin/rofiface
    '';
  };

  plugin = runCommand "rofi-tab-switcher" {} ''
    install -DT \
      ${writeText "rofi_interface.json" (builtins.toJSON manifest)} \
      $out/lib/mozilla/native-messaging-hosts/rofi_interface.json
  '';
in { inherit native_helper plugin; }
