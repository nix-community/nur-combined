{ stdenv, fetchFromGitHub, python3Packages, desktop-file-utils
  , wrapGAppsHook, gtk3, hicolor-icon-theme }:

python3Packages.buildPythonApplication rec {
  pname = "mymcplus";
  version = "3.0.3";

  src = fetchFromGitHub{
    owner = "thestr4ng3r";
    repo = "mymcplus";
    rev = "v${version}";
    sha256 = "07r78v3hp3mcdxqf6j2vaqxc4pr08mwphchac71n79pvdqzj5j2i";
  };

  propagatedBuildInputs = with python3Packages; [ pyopengl wxPython_4_0 ];

  nativeBuildInputs = [ desktop-file-utils ];
  postPatch = ''
  #  desktop-file-edit --set-key Icon --set-value ${placeholder "out"}/share/icons/pysol01.png data/pysol.desktop
  #  desktop-file-edit --set-key Comment --set-value "${meta.description}" data/pysol.desktop
  '';

  buildInputs = [ wrapGAppsHook gtk3 hicolor-icon-theme ];
  # No tests in archive
  doCheck = false;

  meta = with stdenv.lib; {
    broken = true; #need to fix the wrapper
    description = "PlayStation 2 memory card manager";
    homepage = https://github.com/thestr4ng3r/mymcplus;
    license = licenses.gpl3;
    maintainers = with maintainers; [ genesis ];
  };
}
