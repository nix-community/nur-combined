{ lib,
  stdenv,
  fetchurl,
  gsettings-desktop-schemas,
  jdk17,
  libGL,
  unzip,
  wrapGAppsHook,
  xorg,
}:
let
  version = "unstable-2024-02-05";
  src = fetchurl {
    url = "https://kapdemo.dhsdevelopments.com/kap-jvm-build-linux.zip";
    sha256 = "sha256-9zL6KkC/9iiqCn5Sxa2ZI/cHZFuhIoNjXwuoYhQpabw=";
  };
in
stdenv.mkDerivation rec {
  pname = "kap";
  inherit src version;

  buildInputs = [
    gsettings-desktop-schemas
    jdk17
  ];

  nativeBuildInputs = [
    unzip
    wrapGAppsHook
  ];

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -r bin/ lib/ standard-lib/ $out

    runHook postInstall
  '';

  preFixup = with xorg; ''
    gappsWrapperArgs+=(
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ libGL libXtst libXxf86vm ]}"
      --prefix JAVA_HOME : "${jdk17.home}"
    )
  '';

  meta = with lib; {
    homepage = "https://kapdemo.dhsdevelopments.com/";
    description = "Kap is an array-based language that is inspired by APL";
    license = licenses.mit;
    mainProgram = "kap-jvm";
    maintainers = with maintainers; [ detegr ];
    platforms = [ "x86_64-linux" ];
  };
}
