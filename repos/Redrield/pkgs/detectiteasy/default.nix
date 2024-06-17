{ stdenv, lib, fetchurl, freetype, glib, graphite2, icu, krb5, systemdLibs, qtbase, qtscript, qtsvg, qttools, qmake, imagemagick, wrapQtAppsHook, makeWrapper }:
stdenv.mkDerivation rec {
  pname = "detectiteasy";
  version = "3.09";

  src = fetchurl {
    url = "https://github.com/horsicq/DIE-engine/releases/download/${version}/die_sourcecode_3.09.tar.gz";
    sha256 = "04mwcpmg9qkrxcprdw6281jz7z0c1l7a4b2m9kqan1ixpigqqigb";
  };

  nativeBuildInputs = [ wrapQtAppsHook qttools imagemagick makeWrapper qmake ];

  buildInputs = [ freetype glib stdenv.cc.cc.lib systemdLibs qtbase qtscript qtsvg graphite2 icu krb5 ];

  # Steps based on published PKGBUILD
  buildPhase = ''
    _subdirs=("build_libs" "gui_source" "console_source" "lite_source")
    for _subdir in "''${_subdirs[@]}"; do
      pushd "$_subdir";
      qmake PREFIX=$out/usr "$_subdir.pro"
      local flags=(
        ''${enableParallelBuilding:+-j$NIX_BUILD_CORES}
        SHELL=$SHELL
      )
      make -f Makefile clean
      make -f Makefile "''${flags[@]}"
      popd
    done

    pushd "gui_source"
    lupdate gui_source_tr.pro
    lrelease gui_source_tr.pro
    popd
  '';

  installPhase = ''
    mkdir -p $out/opt/${pname}/{lang,qss,info,db,yara_rules}
    mkdir -p $out/bin
    mkdir -p $out/share/pixmaps

    install -Dm 755 build/release/die $out/opt/${pname}/
    install -Dm 755 build/release/diec $out/opt/${pname}/
    install -Dm 755 build/release/diel $out/opt/${pname}/

    install -Dm 644 gui_source/translation/* -t $out/opt/${pname}/lang
    install -Dm 644 XStyles/qss/* -t $out/opt/${pname}/qss
    cp -r XInfoDB/info/* -t $out/opt/${pname}/info
    cp -r Detect-It-Easy/db/* -t $out/opt/${pname}/db/
    cp -r XYara/yara_rules/* -t $out/opt/${pname}/yara_rules/
    install -Dm 644 signatures/crypto.db -t $out/opt/${pname}/signatures
    cp -r images/* $out/opt/${pname}/images

    makeWrapper $out/opt/${pname}/die $out/bin/die
    makeWrapper $out/opt/${pname}/diec $out/bin/diec
    makeWrapper $out/opt/${pname}/diel $out/bin/diel

    install -Dm 644 LINUX/hicolor/48x48/apps/detect-it-easy.png $out/share/pixmaps
  '';

  meta = with lib; {
    license = licenses.mit;
    platform = platforms.all;
  };
}
