{ lib, buildPythonPackage, fetchgit, pytest }:

buildPythonPackage rec {
  pname = "blender-file";
  version = "1.0";

  src = fetchgit {
    url = "git://git.blender.org/blender-file.git";
    rev = "v${version}";
    sha256 = "1vbsscyj9lkrjd2dj2dnscf15i83jm91rakgc1bfacsrm9n165br";
  };

  propagatedBuildInputs = [ pytest ];

  meta = with lib; {
    homepage = "https://developer.blender.org/source/blender-file";
    description = "Module to inspect a .blend file from Python";
    license = licenses.gpl2;
  };
}
