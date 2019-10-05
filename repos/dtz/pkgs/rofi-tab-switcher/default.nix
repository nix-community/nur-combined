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
    version = "unstable-2019-10-04";

    src = fetchFromGitHub {
      owner = "dtzWill"; # "blackhole89";
      repo = pname;
      rev = "e7ea4db0e7d38d7e607b8d8a4bbad7440f9725b6";
      sha256 = "0f7clns873l3jm95hkrbd7sj9l2dp4pm5i5yvrw78m3qararxr4s";
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
