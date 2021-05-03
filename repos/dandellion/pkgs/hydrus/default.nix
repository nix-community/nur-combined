{ mkDerivation, fetchFromGitHub, python3, python3Packages, wrapGAppsHook, qt5, pylzma, ffmpeg, miniupnpc }:
let
  pythonEnv = python3.withPackages (pythonPackages: with pythonPackages; [
    beautifulsoup4
    chardet
    cloudscraper
    html5lib
    lxml
    lz4
    nose
    numpy
    pillow
    psutil
    pylzma
    pyopenssl
    pyside2
    pysocks
    pyyaml
    qtpy
    requests
    send2trash
    service-identity
    six
    twisted

    opencv4
  ]);
in
  mkDerivation rec {
    pname = "hydrus";
    version = "437";

    src = fetchFromGitHub {
      owner = "hydrusnetwork";
      repo = "hydrus";
      rev = "v${version}";
      sha256 = "1c93i3n9g71z1lgw1871sbsswnr57iv4cd7n97hlf5hrzwsb3nhd";
    };

    format = "other";
    dontWrapQtApps = true;
    dontWrapGApps = true;

    
    makeWrapperArgs = [
      "\${gappsWrapperArgs[@]}"
      "\${qtWrapperArgs[@]}"
    ];

    preFixup = ''
      wrapPythonPrograms
    '';

    buildPhase = ''
      runHook preBuild

      python -OO -m compileall -f .

      runHook postBuild
    '';

    installPhase = ''
     runHook preInstall

      mkdir -p "$out/opt/hydrus"
      cp -r help hydrus static client.pyw server.py "$out/opt/hydrus/"
      chmod a+x "$out/opt/hydrus/server.py"

      mkdir -p $out/opt/hydrus/bin
      ln -s "${miniupnpc}/bin/upnpc" "$out/opt/hydrus/bin/upnpc_linux"
      ln -s "${ffmpeg}/bin/ffmpeg" "$out/opt/hydrus/bin/ffmpeg"

      mkdir -p "$out/bin"

      runHook postInstall
    '';

    nativeBuildInputs = [ qt5.wrapQtAppsHook python3Packages.wrapPython ];
    buildInputs = [ ffmpeg miniupnpc ];
    propagatedBuildInputs = [ pythonEnv ];    

    postInstall = ''
      makeQtWrapper $out/opt/hydrus/client.pyw $out/bin/hydrus-client  --prefix PYTHONPATH : $PYTHONPATH
    '';
  }
