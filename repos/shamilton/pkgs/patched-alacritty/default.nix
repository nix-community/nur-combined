{ lib
, stdenvNoCC
, fetchFromGitHub
, alacritty
, writeScriptBin
, nixosVersion
, nix-gitignore
, expat
, fontconfig
, freetype
, libGL
, wayland
, libxkbcommon
, zeromq
, libX11
, libXcursor
, libXi
, libXrandr
, libXxf86vm
, libxcb
, patched-tabbed
}:
let
  tabbed-alacritty = writeScriptBin "tabbed-alacritty"
  ''
    #!${stdenvNoCC.shell}
    ${patched-tabbed}/bin/tabbed -cr 2 -w "--working-directory" -x "--xembed-tcp-port" alacritty --embed ""
  '';
  rpathLibs = [
    expat
    fontconfig
    freetype
    libGL
    wayland
    libxkbcommon
    zeromq
    libX11
    libXcursor
    libXi
    libXrandr
    libXxf86vm
    libxcb
  ];
in
alacritty.overrideAttrs (old: rec {
  pname = "${old.pname}-patched";
  # src = nix-gitignore.gitignoreSource [ ] /home/scott/GIT/alacritty;
  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "alacritty";
    rev = "8dbc19becf9a960d2118b09c7dafdaa17448003e";
    sha256 = "sha256-qAQzRp9K1iMIkp/t+5q2A+pDlcuXEYcujy8DNnyeF3E=";
  };
  postPatch = ''
    sed -Ei 's|^Exec=alacritty|Exec=${tabbed-alacritty}/bin/tabbed-alacritty|g' "extra/linux/Alacritty.desktop"
  '';
  buildInputs = (old.buildInputs or []) ++ [ zeromq ];
  propagatedBuildInputs = (old.propagatedBuildInputs or []) ++ [ tabbed-alacritty ];
  doCheck = false;
  postFixup = ''
    patchelf --set-rpath "${lib.makeLibraryPath rpathLibs}" "$out/bin/alacritty"
  '';
  postInstall = let
    prepatched =
      builtins.replaceStrings ["install -D extra/linux/org.alacritty.Alacritty.appdata.xml -t $out/share/appdata/"] [""] old.postInstall;
    # install -D extra/linux/org.alacritty.Alacritty.appdata.xml -t $out/share/appdata/
  in lib.concatStringsSep "\n" (
    lib.filter (l: builtins.match ".*gzip -c.*extra/alacritty-msg.man.*" l == null)
    (lib.splitString "\n" prepatched)
  ) + ''
    ln -s "${tabbed-alacritty}/bin/tabbed-alacritty" "$out/bin/tabbed-alacritty"
  '';

  cargoDeps = old.cargoDeps.overrideAttrs (lib.const {
    inherit src;
    outputHash = if nixosVersion == "master"
      then ""
      else "";
    outputHashMode = "recursive";
    doCheck = false;
  });
  patches = [];
})
