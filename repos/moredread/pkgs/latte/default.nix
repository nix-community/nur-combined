{ stdenv, lib, fetchFromGitHub, python3Packages, python3, xorg }:

python3Packages.buildPythonApplication rec {
  name = "latte-${version}";
  version = "4.0";

  src = fetchFromGitHub {
    owner = "flakas";
    repo = "Latte";
    rev = "${version}";
    sha256 = "0ld1wzn3kgv1rsjnljrfhfsqack6dsklqfqrbn06byzf0xl3lxnb";
  };

  propagatedBuildInputs = with python3Packages; [
    sqlalchemy
    xorg.libX11
    xorg.libXScrnSaver
  ];

  doCheck = false;
  doInstallCheck = false;

  postInstall = ''
    # Can we avoid double-wrapping?
    wrapProgram $out/bin/latte --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath propagatedBuildInputs}
  '';

  meta = with stdenv.lib; {
    description = "Warning: WIP, package name might change.";
    platforms = platforms.linux;
    maintainers = [ maintainers.moredread ];
  };
}
