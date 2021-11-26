{ lib, stdenv, fetchurl, dpkg, autoPatchelfHook, makeWrapper, electron,
alsa-lib, gtk3, libxshmfence, mesa, nss, openssl }:

stdenv.mkDerivation rec {
  pname = "freezer";
  version = "1.1.24";

  src = fetchurl {
    url = "https://files.freezer.life/0:/PC/${version}/${pname}_${version}_amd64.deb";
    sha256 = "sha256-d2mhUh0khmJ0231z9v4xFYVx9v1At2QoV5HrZJIUyEg=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    alsa-lib gtk3 libxshmfence mesa nss openssl
  ];

  libPath = lib.makeLibraryPath buildInputs;

  dontBuild = true;
  dontConfigure = true;

  unpackPhase = ''
    dpkg-deb -x ${src} ./
  '';

  installPhase = ''
    runHook preInstall

    mv usr $out
    mv opt $out

    substituteInPlace $out/share/applications/freezer.desktop --replace '/opt/Freezer' $out/bin
    makeWrapper ${electron}/bin/electron \
      $out/bin/freezer \
      --add-flags $out/opt/Freezer/resources/app.asar \
      --prefix LD_LIBRARY_PATH : ${libPath}

    runHook postInstall
  '';

  meta = with lib; {
    description = "Free music streaming client for Deezer based on the Deezloader/Deemix \"bug\"";
    homepage = "https://freezer.life/";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ wolfangaukang ];
  };
}
