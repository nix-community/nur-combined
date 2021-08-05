{ lib
, stdenvNoCC
, fetchFromGitHub
, alacritty
, writeScriptBin
, nixosVersion
}:
let
  tabbed-alacritty = writeScriptBin "tabbed-alacritty"
  ''
    #!${stdenvNoCC.shell}
    tabbed -cr 2 -w "--working-directory" -x "--xembed-tcp-port" alacritty --embed ""
  '';
in
alacritty.overrideAttrs (old: rec {
  pname = "${old.pname}-patched";
  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "alacritty";
    rev = "49cd691555463305668fd5fcd57151bda2f389d8";
    sha256 = "01w0qcq2dqhk7hyfv6aav5j5zh76p0pid407h1plcb59bgwk7ix5";
  };
  postPatch = ''
    sed -Ei 's|^Exec=alacritty|Exec=${tabbed-alacritty}/bin/tabbed-alacritty|g' "extra/linux/Alacritty.desktop"
  '';
  propagatedBuildInputs = (old.propagatedBuildInputs or []) ++ [ tabbed-alacritty ];
  doCheck = false;
  cargoDeps = old.cargoDeps.overrideAttrs (lib.const {
    inherit src;
    outputHash = if nixosVersion == "nixpkgs-unstable"
      then "02v0nd68y2gy4jqhc7n663h9b3v808wddd3biqs4xznzbczz9al7"
      else "1dd06mhk3fp67wjyfp5b3pwvxz2lw4vim14q61s2i9icvrdnh6hh";
    doCheck = false;
  });
})
