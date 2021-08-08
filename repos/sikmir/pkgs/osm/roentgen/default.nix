{ lib, fetchFromGitHub, python3Packages, portolan }:

python3Packages.buildPythonApplication rec {
  pname = "roentgen";
  version = "2021-07-09";

  src = fetchFromGitHub {
    owner = "enzet";
    repo = "Roentgen";
    rev = "3d278a729b6037fe74a634f8329a5b5ff2de6fde";
    hash = "sha256-tb+twq/zOi92sm6tRnrP21TwnntoTnrl02kwAE9CS+w=";
  };

  postPatch = ''
    substituteInPlace roentgen.py \
      --replace "scheme/" "$out/share/roentgen/scheme/" \
      --replace "icons/" "$out/share/roentgen/icons/"
    substituteInPlace roentgen/mapper.py \
      --replace "scheme/" "$out/share/roentgen/scheme/" \
      --replace "icons/" "$out/share/roentgen/icons/"
    substituteInPlace roentgen/tile.py \
      --replace "icons/" "$out/share/roentgen/icons/"
  '';

  dontUseSetuptoolsBuild = true;
  dontUseSetuptoolsCheck = true;

  installPhase =
    let
      pythonEnv = python3Packages.python.withPackages (p: with p; [
        colour
        numpy
        portolan
        pyyaml
        svgwrite
        urllib3
      ]);
    in
    ''
      site_packages=$out/lib/${python3Packages.python.libPrefix}/site-packages
      mkdir -p $site_packages $out/share/roentgen
      cp -r roentgen roentgen.py $site_packages
      cp -r icons scheme $out/share/roentgen

      makeWrapper ${pythonEnv.interpreter} $out/bin/roentgen \
        --add-flags "$site_packages/roentgen.py"
    '';

  meta = with lib; {
    description = "A simple renderer for OpenStreetMap with custom icons intended to display as many tags as possible";
    inherit (src.meta) homepage;
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
