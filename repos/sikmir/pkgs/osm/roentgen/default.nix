{ lib, fetchFromGitHub, python3Packages, portolan, inkscape }:

python3Packages.buildPythonApplication rec {
  pname = "roentgen";
  version = "2021-08-19";
  disabled = python3Packages.pythonOlder "3.9";

  src = fetchFromGitHub {
    owner = "enzet";
    repo = "Roentgen";
    rev = "62d1a5e6dc4dceb4599209fe504e0c0240f13171";
    hash = "sha256-AsbRYeJxGxwI55YcrBRPpDVD+rYwNXjocRmkO4ruz/U=";
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
    substituteInPlace roentgen/workspace.py \
      --replace "scheme" "$out/share/roentgen/scheme" \
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
        pycairo
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
        --add-flags "$site_packages/roentgen.py" \
        --set INKSCAPE_BIN ${inkscape}/bin/inkscape
    '';

  meta = with lib; {
    description = "A simple renderer for OpenStreetMap with custom icons intended to display as many tags as possible";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
