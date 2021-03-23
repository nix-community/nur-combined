# Still broken

{dart, flutterPackages}:
with builtins;
let
  pname = "flutter2";
  version = "2.0.3";
  src = fetchTarball {
    url = "https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_${version}-stable.tar.xz";
    sha256 = "sha256:1iqgl0v4z470ydjsppcsyd8fjds5r43rpnwbilw1ancqmakb9pcc";
  };
  drv = flutterPackages.mkFlutter rec {
    inherit dart version pname src;
    patches = flutterPackages.stable.passthru.unwrapped.patches;
  };
  # drv = pkgs.stdenv.mkDerivation {
  #   inherit name version src;
  #   installPhase = ''
  #     mkdir -p $out/opt/flutter2/bin
  #     mkdir -p $out/bin
  #     cp -r $src/* $out/opt/flutter2
  #     chown $USER:$USER -R $out/opt
  #     rm $out/opt/flutter2/bin/cache -rf
  #     ln -s /tmp/flutter-cache $out/opt/flutter2/bin/cache
  #     echo "mkdir -p /tmp/flutter-cache && $out/opt/flutter2/bin/flutter \"$@\"" > $out/bin/flutter
  #     chmod +x $out/bin/flutter
  #   '';
  # };
in drv

