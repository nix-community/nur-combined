{ stdenv, fetchurl, buildFHSUserEnv, lib }:
let tdesktop-bin = stdenv.mkDerivation {
  pname = "tdesktop-bin";
  version = "3.2.5";

  src = fetchurl {
    url = "https://github.com/telegramdesktop/tdesktop/releases/download/v3.2.5/tsetup.3.2.5.tar.xz";
    hash = "sha256-ggFYEvYzS9XI7lYgSpRs8KJzROSM6fRL/4fQ3D+E7wM=";
  };

  installPhase = "mkdir -p $out/bin/ && cp ./Telegram $out/bin/";
}; in
buildFHSUserEnv {
  name = "${tdesktop-bin.pname}";
  targetPkgs = pkgs: [ tdesktop-bin ] ++
    (with pkgs; [ glib fontconfig freetype ]) ++
    (with pkgs.xorg; [ libxcb libX11 ]) ++
    # https://wayland-devel.freedesktop.narkive.com/wtyneVJL/weston-launch-xkbcommon-error
    (with pkgs; [ dbus xkeyboard_config desktop-file-utils ]);
  runScript = "Telegram";

  meta = with lib; {
    description = "Official Telegram Desktop, packaging by using GitHub binary and buildFHSUserEnv. ";
    homepage = "https://github.com/telegramdesktop/tdesktop/tree/v${tdesktop-bin.version}";
    license = licenses.gpl3;
    maintainers = [ maintainers.vanilla ];
    platforms = [ "x86_64-linux" ];
  };
}
