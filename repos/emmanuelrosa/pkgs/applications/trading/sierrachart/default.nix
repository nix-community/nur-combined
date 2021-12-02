{ stdenv, lib, wine, wrapWine, fetchurl, makeDesktopItem, copyDesktopItems, unzip, writeShellScript, writeShellScriptBin, rsync, gnugrep, imagemagick }:
let
  pname = "sierrachart";
  version = "2332";

  src = fetchurl {
    url = "https://www.sierrachart.com/downloads/ZipFiles/SierraChart${version}.zip";
    sha256 = "sha256-hZPIeNLd3OqnkQqNEWw4koHl+GInvvk6bd5nwpd64Vw=";
  };

  icons = stdenv.mkDerivation {
    name = "${pname}-icons";

    src = fetchurl {
      url = "https://www.sierrachart.com/favicon/favicon-192x192.png";
      sha256 = "06wdklj01i0h6c6b09288k3qzvpq1zvjk7fsjc26an20yp2lf21f";
    };

    dontUnpack = true;
    nativeBuildInputs = [ imagemagick ];

    installPhase = ''
      for n in 16 24 32 48 64 96 128 256; do
        size=$n"x"$n
        mkdir -p $out/hicolor/$size/apps
        convert $src -resize $size $out/hicolor/$size/apps/sierrachart.png
      done;
    '';
  };

  installer = writeShellScript "${pname}-${version}-installer" ''
    s=$(mktemp -d)
    d=$HOME/.wine-nix/${pname}/drive_c/SierraChart
    mkdir -p $d

    ${unzip}/bin/unzip ${src} -d $s
    echo Installing ${pname}-${version}...
    ${rsync}/bin/rsync -av $s/ $d
  '';

  launcher = writeShellScript "${pname}-${version}-launcher" ''
    h=$HOME/.wine-nix/${pname}

    if [ -d "$h" ]
    then
      # Run the installer if the version number is different from what's installed.
      ${gnugrep}/bin/grep ${version} $h/drive_c/SierraChart/VersionNumber.txt || ${installer}
    fi

    ${app}/bin/${pname}
  '';

  app = wrapWine {
    inherit wine;

    name = pname;
    firstrunScript = installer;
    executable = "$WINEPREFIX/drive_c/SierraChart/SierraChart.exe";
    wineArch = "win64";
  };
in stdenv.mkDerivation {
  inherit pname version src;

  sourceRoot = ".";

  unpackCmd = ''
    mkdir src
    unzip $curSrc -d src
  '';

  nativeBuildInputs = [ unzip copyDesktopItems ];

  desktopItems = [
    (makeDesktopItem {
      name = "sierrachart";
      exec = pname;
      icon = "sierrachart";
      desktopName = "Sierra Chart";
      genericName = "Trading and charting software";
      categories = "Network;Finance;";
    })
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/share/icons
    ln -s ${launcher} $out/bin/${pname}
    ln -s ${icons}/hicolor $out/share/icons
    runHook postInstall
  '';

  meta = with lib; {
    description = "A professional desktop Trading and Charting platform for the financial markets, supporting connectivity to various exchanges and backend trading platform services.";
    homepage = "https://www.sierrachart.com";
    license = licenses.unfree;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
  };
}
