{ lib, fetchPypi, buildPythonApplication, requests }:

buildPythonApplication rec {
  pname = "blender-asset-tracer";
  version = "1.12";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-lvecN4a652I/aGu8i4xiyP1ocrxgj3Z+EWL3cMKyUEo=";
  };

  buildInputs = [ requests ];

  pythonImportsCheck = [ "blender_asset_tracer" ];

  meta = with lib; {
    description =
      "Blender Asset Tracer, a.k.a. BAT, is the replacement of BAM and blender-file";
    homepage = "https://developer.blender.org/project/profile/79/";
    license = licenses.gpl2Plus;
    platforms = platforms.unix;
  };
}
