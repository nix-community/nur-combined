{ version, sha256, extraPreConfigure ? "", patches ? [ ] }:
{ stdenv, lib, bison, flex, qtbase, openscenegraph, openmpi, python3, fetchurl
, xorg, xdg-utils, perl, autoPatchelfHook, wrapQtAppsHook, alsa-lib, gtk3, dconf, libsecret
, swt, gsettings-desktop-schemas, mode ? null, cppStandard ? null }:
let
  pythonWithDeps = python3.withPackages
    (pkgs: with pkgs; [ posix_ipc numpy scipy pandas matplotlib ]);
in stdenv.mkDerivation rec {
  pname = "omnetpp";
  inherit version patches;
  name = "${pname}-${version}";
  postPatch = ''
    substituteInPlace ./configure.user \
      --replace 'WITH_OSGEARTH=yes' 'WITH_OSGEARTH=no'
  '' + lib.optionalString (cppStandard != null) ''
    sed -i 's/^#CXXFLAGS=.*/CXXFLAGS=-std=${cppStandard}/' ./configure.user 
  '' + ''
    substituteInPlace ./src/utils/Makefile \
      --replace '#!/bin/sh' '#!${stdenv.shell}'
    substituteInPlace ./Makefile.inc.in \
      --replace '$(OMNETPP_ROOT)/images' "$out/images" \
      --replace '$(OMNETPP_ROOT)/lib' "$out/lib"
    patchShebangs ./src/utils/
  '';
  src = fetchurl {
    urls = [
      "https://github.com/${pname}/${pname}/releases/download/${pname}-${version}/${pname}-${version}-src-linux.tgz"
      "https://github.com/${pname}/${pname}/releases/download/${pname}-${version}/${pname}-${version}-linux-x86_64.tgz"
    ];
    inherit sha256;
  };
  preConfigure = ''
    unset AR
    export PATH=$PWD/bin:$PATH
    ${extraPreConfigure}
  '';

  preBuild = ''
    export PATH=$PWD/bin:$PATH
  '';

  installPhase = ''
    mkdir -p $out
    cp -vr Makefile.inc ide lib bin include images $out/
  '';
  preFixup = ''
    substituteInPlace $out/bin/omnetpp \
      --replace '$IDEDIR/error.log' '$HOME/.omnetpp/error.log'
    wrapProgram $out/bin/omnetpp \
      --prefix GIO_EXTRA_MODULES : "${lib.getLib dconf}/lib/gio/modules" \
      --prefix XDG_DATA_DIRS : "$GSETTINGS_SCHEMAS_PATH" \
      --add-flags "-configuration \$HOME/.omnetpp/configuration"

    # ensure omnetpp.ini does not try to use a justj jvm, as those aren't compatible with nix
    ${perl}/bin/perl -i -p0e 's|-vm\nplugins/org.eclipse.justj.*/jre/bin\n||' $out/ide/omnetpp.ini
  '';
  makeFlags = lib.optional (mode != null) "MODE=${mode}";
  enableParallelBuilding = true;
  nativeBuildInputs =
    [ perl bison flex pythonWithDeps wrapQtAppsHook autoPatchelfHook swt ];
  buildInputs = [
    openscenegraph
    openmpi
    xorg.libXtst
    alsa-lib
    gtk3
    gsettings-desktop-schemas
    xdg-utils
    libsecret
  ];
}
