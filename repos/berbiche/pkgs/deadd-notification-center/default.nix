/*
 * Copy-pasted from https://github.com/NixOS/nixpkgs/pull/89118 with my own patches
 * 
 * Original license: MIT
 */
{ stdenv, fetchFromGitHub
, autoPatchelfHook, wrapGAppsHook
, gtk3, gobject-introspection, libxml2, hicolor-icon-theme
}:

let
  rev = "a155a6b826b6380f9c712aa07e345a66d0b622a1";
  version = "2020-10-20";
in
stdenv.mkDerivation rec {
  pname = "deadd-notification-center";
  inherit version;

  src = fetchFromGitHub {
    owner = "phuhl";
    repo = "linux_notification_center";
    rev = rev;
    hash = "sha256-BHc6vFOM6s5i1DhxVCF90O/aRnebJZDhqbPcc64Zyj4=";
  };

  dontBuild = true;

  nativeBuildInputs = [
    autoPatchelfHook
    wrapGAppsHook
  ];

  buildInputs = [
    gtk3
    gobject-introspection
    libxml2
    hicolor-icon-theme
  ];

  installPhase = ''
    mkdir -p $out/bin $out/share/dbus-1/services

    # TODO: I spent too much time trying to understand the Haskell infrastructure...
    #       within nixpkgs and I couldn't find a way to fix Haskell packages...
    #       marked as broken

    cp $src/.out/deadd-notification-center $out/bin/deadd-notification-center
    chmod +x $out/bin/deadd-notification-center

    sed "s|##PREFIX##|$out|g" $src/com.ph-uhl.deadd.notification.service.in > $out/share/dbus-1/services/com.ph-uhl.deadd.notification.service
  '';

  meta = with stdenv.lib; {
    description = "A haskell-written notification center for users that like a desktop with style";
    homepage = "https://github.com/phuhl/linux_notification_center";
    license = licenses.bsd3;
    platforms = platforms.linux;
  };
}
