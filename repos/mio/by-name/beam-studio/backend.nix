{
  pkgs,
  lib,
  fetchFromGitHub,
  fetchurl,
  appimageTools,
  autoPatchelfHook,
}:
let
  # We use NixOS 23.05 to access Python 3.8 and pre-compiled numpy/scipy versions.
  oldPkgs =
    import
      (builtins.fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/nixos-23.05.tar.gz";
        sha256 = "sha256-LWvKHp7kGxk/GEtlrGYV68qIvPHkU9iToomNFGagixU=";
      })
      {
        inherit (pkgs) system;
        config.allowUnfree = true;
      };

  # OpenCV takes hours to build from source, so we use the pre-compiled wheel.
  opencv-python-wheel = oldPkgs.python38Packages.buildPythonPackage rec {
    pname = "opencv_python";
    version = "4.10.0.84";
    format = "wheel";
    src = pkgs.fetchurl {
      url = "https://files.pythonhosted.org/packages/3f/a4/d2537f47fd7fcfba966bd806e3ec18e7ee1681056d4b0a9c8d983983e4d5/opencv_python-4.10.0.84-cp37-abi3-manylinux_2_17_x86_64.manylinux2014_x86_64.whl";
      hash = "sha256-ms4UD8bWR/vhxpK8sqvOdolzSRIiwGfBMdgJV8WVtx8=";
    };
    buildInputs = with oldPkgs; [
      zlib
      libGL
      glib
      xorg.libSM
      xorg.libICE
      xorg.libX11
      xorg.libXext
    ];
    nativeBuildInputs = [ oldPkgs.autoPatchelfHook ];
    pipInstallFlags = [ "--no-deps" ];
  };

  # Complete Python 3.8 environment for fluxghost
  pythonEnv = oldPkgs.python38.withPackages (p: [
    p.numpy
    p.scipy
    p.pillow
    p.pyusb
    p.cffi
    p.cairocffi
    p.lxml
    p.msgpack
    p.pyserial
    p.pycryptodome
    p.ecdsa
    p.cssselect2
    p.defusedxml
    p.pyasn1
    p.tinycss2
    p.setuptools
    opencv-python-wheel
  ]);

  # Fetch fluxghost from source
  fluxghost-src = fetchFromGitHub {
    owner = "flux3dp";
    repo = "fluxghost";
    rev = "4c13e0d7371c79c19db45826786b71c9855b6c45";
    hash = "sha256-KxkCFhB20O+2bPzzOZXPSb+HYfB16M9g1sR2OZPUMAM=";
  };

  # Script to extract .pyc from PyInstaller
  pyinstxtractor = fetchurl {
    url = "https://raw.githubusercontent.com/extremecoders-re/pyinstxtractor/master/pyinstxtractor.py";
    hash = "sha256-lOC2ydUVG77vx+dFLpbiSzlsLb/LA0jl8SxMCGX+/lg=";
  };

  # The original AppImage to extract proprietary blobs from
  backendAppImage = fetchurl {
    url = "https://beamstudio.s3.amazonaws.com/linux-22.04/Beam%20Studio-2.6.8.AppImage";
    hash = "sha256-+NNeAThprCd+1WE7aVqlkCEk4rLmKN0aD5RykRkHOa8=";
  };
  backendContents = appimageTools.extractType2 {
    pname = "beam-studio-backend-contents";
    version = "2.6.8";
    src = backendAppImage;
  };
in
pkgs.stdenv.mkDerivation {
  name = "flux-backend";
  version = "2.6.8";

  src = fluxghost-src;

  nativeBuildInputs = [
    oldPkgs.python38
    pkgs.makeWrapper
    oldPkgs.autoPatchelfHook
  ];
  buildInputs = [
    oldPkgs.stdenv.cc.cc.lib
    pkgs.zlib
  ];

  installPhase = ''
    mkdir -p $out/lib/python3.8/site-packages
    mkdir -p $out/bin

    # 1. Extract pyinstxtractor against backendContents/resources/backend/flux_api
    cp ${backendContents}/resources/backend/flux_api/flux_api ./flux_api_blob
    python ${pyinstxtractor} ./flux_api_blob

    # 2. Extract beamify and fluxclient .pyc files into site-packages
    # PyInstaller extracts to flux_api_blob_extracted
    # PYZ-00.pyz_extracted contains the user modules
    cp -r flux_api_blob_extracted/PYZ-00.pyz_extracted/beamify $out/lib/python3.8/site-packages/
    cp -r flux_api_blob_extracted/PYZ-00.pyz_extracted/fluxclient $out/lib/python3.8/site-packages/
    cp -r flux_api_blob_extracted/PYZ-00.pyz_extracted/fluxsvg $out/lib/python3.8/site-packages/

    # Copy native C extensions and assets for proprietary blobs
    cp -r ${backendContents}/resources/backend/flux_api/beamify/* $out/lib/python3.8/site-packages/beamify/ 2>/dev/null || true
    cp -r ${backendContents}/resources/backend/flux_api/fluxclient/* $out/lib/python3.8/site-packages/fluxclient/ 2>/dev/null || true
    cp -r ${backendContents}/resources/backend/flux_api/fluxsvg/* $out/lib/python3.8/site-packages/fluxsvg/ 2>/dev/null || true

    # 3. Copy our open-source fluxghost source into site-packages
    cp -r * $out/lib/python3.8/site-packages/
    rm -rf $out/lib/python3.8/site-packages/flux_api_blob*

    # 4. Create the flux_api executable wrapper using our custom Python environment
    makeWrapper ${pythonEnv}/bin/python $out/bin/flux_api \
      --set PYTHONPATH "$out/lib/python3.8/site-packages" \
      --add-flags "-m ghost"
  '';
}
