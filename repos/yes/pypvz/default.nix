{ lib
, fetchzip
, copyDesktopItems
, makeDesktopItem
, python3Packages
, rp ? ""
}:

with python3Packages; buildPythonApplication rec {
  pname = "pypvz";
  version = "0.8.36.0";

  src = fetchzip {
    url = "${rp}https://github.com/wszqkzqk/pypvz/archive/refs/tags/${version}.zip";
    hash = "sha256-BRGLJ00sMmUu03c5XZVPX6gNVO7Sh3WimH0XfGknQ1I=";
  };

  nativeBuildInputs = [ copyDesktopItems ];

  propagatedBuildInputs = [ pygame ];

  doCheck = false;

  postPatch = ''
    cat > setup.py << EOF
    #!/usr/bin/env python
    from setuptools import setup, find_namespace_packages
    setup(
      name = "${pname}",
      version = "${version}",
      packages = find_namespace_packages(),
      scripts = ["pypvz.py"],
      package_data = {"": ["*.ttf", "*.png", "*.opus", "*.ogg"]}
    )
    EOF
  '';

  desktopItems = [(makeDesktopItem {
    name = "pypvz";
    exec = "pypvz.py";
    icon = "pypvz";
    desktopName = "pypvz";
    genericName = "pypvz";
    startupWMClass = "pypvz.py";
    categories = ["Game"];
  })];

  postInstall = ''
    mkdir -p $out/share/pixmaps
    cp pypvz.png $out/share/pixmaps/pypvz.png
  '';

  meta = with lib; {
    description = "A python implementation of Plants vs. Zombies";
    license = licenses.unfree;
    homepage = "https://github.com/wszqkzqk/pypvz";
  };
}