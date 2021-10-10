{ stdenv, lib, fetchurl, makeDesktopItem, makeWrapper, electron, libsecret }:

stdenv.mkDerivation rec {
  pname = "tutanota-desktop";
  version = "3.88.4";

  src = fetchurl {
    url = "https://github.com/tutao/tutanota/releases/download/tutanota-release-${version}/${pname}-${version}-unpacked-linux.tar.gz";
    name = "${pname}-${version}.tar.gz";
    sha256 = "sha256-UOb63+NfW6mHKaj3PDEzvz5hcmJBIISq02rtwgSZMjo=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  dontConfigure = true;
  dontBuild = true;

  desktopItem = makeDesktopItem {
    name = pname;
    exec = "tutanota-desktop";
    icon = "tutanota-desktop";
    comment = meta.description;
    desktopName = "Tutanota Desktop";
    genericName = "Email Reader";
  };


  installPhase = let
    libPath = lib.makeLibraryPath [ libsecret ];
  in ''
    runHook preInstall

    mkdir -p $out/bin $out/opt/tutanota-desktop \
             $out/share/${pname}

    cp -r ./ $out/opt/tutanota-desktop
    cp -r $out/opt/tutanota-desktop/{locales,resources} $out/share/${pname}
    install -Dm444 ${desktopItem}/share/applications/${pname}.desktop -t "$out/share/applications/"

    for icon_size in 64 512; do
      icon=resources/icons/icon/$icon_size.png
      path=$out/share/icons/hicolor/$icon_size'x'$icon_size/apps/${pname}.png
      install -Dm644 $icon $path
    done

    makeWrapper ${electron}/bin/electron \
      $out/bin/tutanota-desktop \
      --add-flags $out/share/${pname}/resources/app.asar \
      --run "mkdir /tmp/tutanota" \
      --prefix LD_LIBRARY_PATH : ${libPath}

    runHook postInstall
  '';

  meta = with lib; {
    description = "Tutanota official desktop client";
    homepage = "https://tutanota.com/";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ wolfangaukang ];
    platforms = [ "x86_64-linux" ];
  };
}
