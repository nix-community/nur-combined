{ stdenv, p7zip, zip, python3, qt5, lib }: let
  preExec = ''
  import os
  sfs_select_dir = os.path.expanduser('~/.local/share/Steam/sfs-select/runtime')
  os.makedirs(sfs_select_dir, exist_ok=True)
  os.chdir(sfs_select_dir)


  '';
  preExecBash = builtins.replaceStrings ["\n"] ["\\n"] preExec;
in stdenv.mkDerivation {
  pname = "sfs-select";
  version = "0.5.0";

  src = builtins.fetchurl {
    url = "https://www.unix-ag.uni-kl.de/~t_schmid/sfs-select/sfs-select-0.5.0-full.7z";
    sha256 = "sha256:130ks9vc33r9aycbbz3i8agcy7gjijmfvv94pd4ndxmwl2ndmrh2";
  };
  unpackPhase = ''
    runHook preUnpack

    ${p7zip}/bin/7z x $src -o. -y
    
    runHook postUnpack
  '';

  buildPhase = ''
    runHook preBuild

    mv ./sfs-select/python/sfs-select.py ./sfs-select/python/__main__.py


    sed -i "1i${preExecBash}" ./sfs-select/python/__main__.py
    ${zip}/bin/zip -rj sfs-select.zip ./sfs-select/python/*

    runHook postBuild
  '';

  installPhase = ''
    runHook preBuild

    mkdir -p $out/bin

    echo '#!/usr/bin/env python' | cat - sfs-select.zip > $out/bin/sfs-select

    chmod +x $out/bin/sfs-select

    makeWrapperArgs+=("''${qtWrapperArgs[@]}")
    wrapQtApp $out/bin/sfs-select $makeWrapperArgs

    runHook postBuild
  '';

  nativeBuildInputs = [ p7zip zip qt5.wrapQtAppsHook ];
  buildInputs = [
    (python3.withPackages (pythonPackages: with pythonPackages; [
      psutil
      pyqt5
    ]))
  ];
  dontWrapQtApps = true;


  meta = with lib; {
    description = "a small tool to manage Steam Family Sharing";
    longDescription = ''
      When you get the same game from multiple sources steam selects which one to
use. With often less than optimal results (i.e. chosing an much used source
over a rarely used one). This makes an manual selection method desireable.
Despite customer complaints since fall 2013 this has not yet implemented by
Valve. sfs-select tries to offer that possibility.
It allows you to temporatrily disable single sharing sources. That way you can
disable a "in use" library in favor of unused ones. Additionally it can tweak
the way steam uses to assign games to the active sources.
It has both a GUI (for casual use) and a CLI (scripting, desktop shortcuts,
...) mode. 
    '';
    homepage = "https://www.unix-ag.uni-kl.de/~t_schmid/sfs-select/";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ minion3665 ];
    broken = true; # Cannot be evaluated in restricted mode as it needs to download from unix-ag.uni-kl.de
  };
}
