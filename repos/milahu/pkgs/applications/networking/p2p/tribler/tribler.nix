/*
fix: TypeError: setPixelSize(self, int): argument 1 has unexpected type 'float'
https://github.com/NixOS/nixpkgs/issues/194601#issuecomment-1383236083
https://github.com/NixOS/nixpkgs/pull/184096
*/

{ lib
, stdenv
, fetchFromGitHub
, python3
, buildPythonPackage
, toPythonModule
, wrapPython
, fetchPypi
, cryptography
, libnacl
, netifaces
, aiohttp
, aiohttp-apispec
, pyopenssl
, pyasn1
, asynctest
, marshmallow
, makeWrapper
, libtorrent-rasterbar-1_2_x
, qt5
, setuptools
, text-unidecode
, defusedxml
, markupsafe

, anyio
, chardet
#, cherrypy
, configobj
#, cryptography
, decorator
, faker
#, feedparser
, lz4
#, m2crypto
#, netifaces
, networkx
, pony
, psutil
, pydantic
, pyyaml
, sentry-sdk
, service-identity
, yappi
, yarl # keep this dependency higher than 1.6.3. See: https://github.com/aio-libs/yarl/issues/517
, bitarray
, file-read-backwards
# https://github.com/Tribler/tribler/blob/main/requirements.txt
, pillow
#pycrypto
, pyqt5
, pyqt5_sip
, pyqtgraph
, pyqtwebengine
}:

let

  libtorrent = (toPythonModule (libtorrent-rasterbar-1_2_x)).python;

  pyipv8 = buildPythonPackage rec {
    # https://pypi.org/project/pyipv8/
    pname = "pyipv8";
    version = "2.10";
    src = fetchFromGitHub {
      owner = "Tribler";
      repo = "py-ipv8";
      rev = version;
      sha256 = "sha256-BIrjChj6xhTkrYUFX0byNIrGgMli5HJm9Zu5f2igtFg=";
    };
    propagatedBuildInputs = [
      cryptography
      libnacl
      netifaces
      aiohttp
      aiohttp-apispec
      pyopenssl
      pyasn1
      asynctest
      marshmallow
    ];
    checkPhase = ''
      runHook preCheck
      ${python3.interpreter} -m unittest
      runHook postCheck
    '';
    # tests take too long (2 minutes)
    doCheck = false;
  };

  human-readable = buildPythonPackage rec {
    # https://pypi.org/project/human-readable/
    pname = "human_readable";
    version = "1.3.2";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-WSkGxjWj3XRBcGzfbhN0TD2antuhU3XTRK9Wdf3rDhI=";
    };
/*
    propagatedBuildInputs = [
      cryptography
      libnacl
      netifaces
      aiohttp
      aiohttp-apispec
      pyopenssl
      pyasn1
      asynctest
      marshmallow
    ];
    checkPhase = ''
      runHook preCheck
      ${python3.interpreter} -m unittest
      runHook postCheck
    '';
    # tests take too long (2 minutes)
    doCheck = false;
*/
  };

in

stdenv.mkDerivation rec {
  pname = "tribler";
  version = "7.12.1-unstable-2023-06-15";

  src = fetchFromGitHub {
    owner = "Tribler";
    repo = "tribler";
    rev = "889eb2c85024cfdd9d80b7346fb8d7443df1215c";
    sha256 = "sha256-Q8CpqIs5YNHJQGseFsPj4td+4FbCYvmaAAvn96GJeUA=";
  };

  nativeBuildInputs = [
    wrapPython
    makeWrapper
  ];

  buildInputs = [
    # https://github.com/Tribler/tribler/blob/main/requirements-build.txt
    python3
    setuptools
    text-unidecode
    defusedxml
    markupsafe
    #requests
  ];

  # TODO rename?
  #propagatedBuildInputs = [
  pythonPath = [
    libtorrent
  ] ++ ([
    # https://github.com/Tribler/tribler/blob/main/requirements-core.txt
    aiohttp
    aiohttp-apispec
    asynctest
    anyio
    chardet
    #cherrypy
    configobj
    cryptography
    decorator
    faker
    #feedparser
    libnacl
    lz4
    marshmallow
    #m2crypto
    netifaces
    networkx
    pony
    psutil
    pyasn1
    pydantic
    pyopenssl
    pyyaml
    sentry-sdk
    service-identity
    yappi
    yarl # keep this dependency higher than 1.6.3. See: https://github.com/aio-libs/yarl/issues/517
    bitarray
    pyipv8
    file-read-backwards
    # https://github.com/Tribler/tribler/blob/main/requirements.txt
    pillow
    #pycrypto
    pyqt5
    pyqt5_sip
    pyqtgraph
    pyqtwebengine
    human-readable
  ]);

  /*
  checkInputs = [
    # https://github.com/Tribler/tribler/blob/main/requirements-test.txt
    pytest-asyncio
    pytest-timeout
  ];
  */

  installPhase = ''
    mkdir -pv $out
    # Nasty hack; call wrapPythonPrograms to set program_PYTHONPATH.
    wrapPythonPrograms
    cp -prvd ./* $out/
    makeWrapper ${python3}/bin/python3 $out/bin/tribler \
        --set QT_QPA_PLATFORM_PLUGIN_PATH ${qt5.qtbase.bin}/lib/qt-*/plugins/platforms \
        --set QT_PLUGIN_PATH "${qt5.qtsvg.bin}/${qt5.qtbase.qtPluginPrefix}" \
        --set _TRIBLERPATH "$out/src" \
        --set PYTHONPATH $out/src/tribler-core:$out/src/tribler-common:$out/src/tribler-gui:$program_PYTHONPATH \
        --set NO_AT_BRIDGE 1 \
        --chdir "$out/src" \
        --add-flags "-O $out/src/run_tribler.py"

    mkdir -p $out/share/applications $out/share/icons
    cp $out/build/debian/tribler/usr/share/applications/org.tribler.Tribler.desktop $out/share/applications/
    cp $out/build/debian/tribler/usr/share/pixmaps/tribler_big.xpm $out/share/icons/tribler.xpm

    # patch version: add git revision
    sed -i -E 's/^(version_id = "[0-9]+\.[0-9]+\.[0-9]+)-GIT"$/\1-GIT-${builtins.substring 0 7 src.rev}"/' $out/src/tribler/core/version.py
  '';

  shellHook = ''
    wrapPythonPrograms || true
    export QT_QPA_PLATFORM_PLUGIN_PATH=$(echo ${qt5.qtbase.bin}/lib/qt-*/plugins/platforms)
    export PYTHONPATH=./tribler-core:./tribler-common:./tribler-gui:$program_PYTHONPATH
    export QT_PLUGIN_PATH="${qt5.qtsvg.bin}/${qt5.qtbase.qtPluginPrefix}"
  '';

  meta = with lib; {
    description = "Decentralised P2P filesharing client based on the Bittorrent protocol";
    homepage = "https://www.tribler.org/";
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [ xvapx viric ];
    platforms = platforms.linux;
  };
}
