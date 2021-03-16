{ lib
, fetchFromSourcehut
, python3Packages
, desktop-file-utils
, wrapGAppsHook
, gtk3
, hicolor-icon-theme
}:

# TODO : GUI doesn't work

python3Packages.buildPythonApplication rec {
  pname = "mymcplus";
  version = "3.0.4";

  src = fetchFromSourcehut {
    owner = "~thestr4ng3r";
    repo = "mymcplus";
    rev = "v${version}";
    sha256 = "sha256-zua6NZTAXmgTZywFLjbekBx+OcVKnt3wsRgXJ0AS9wU=";
  };

  nativeBuildInputs = [ desktop-file-utils ];
  buildInputs = [ wrapGAppsHook gtk3 hicolor-icon-theme ];
  propagatedBuildInputs = with python3Packages; [ pyopengl wxPython_4_0 ];

  preFixup = ''
    # buildPythonPath "$out $pythonPkgs"
    gappsWrapperArgs+=(--prefix XDG_DATA_DIRS : "${hicolor-icon-theme}/share")
  '';

  # TODO use desktop icon docs/mc4.png
  #postPatch = ''
  #  desktop-file-edit --set-key Icon --set-value ${placeholder "out"}/share/icons/pysol01.png data/pysol.desktop
  #  desktop-file-edit --set-key Comment --set-value "${meta.description}" data/pysol.desktop
  # '';

  # No tests in archive
  #doCheck = false;

  meta = with lib; {
    description = "PlayStation 2 memory card manager";
    inherit (src.meta) homepage;
    license = licenses.gpl3;
    maintainers = with maintainers; [ genesis ];
  };
}
