{
  lib,
  fetchPypi,
  buildPythonApplication,
  cattrs,
}:

buildPythonApplication rec {
  pname = "blender-asset-tracer";
  version = "2.2.0";
  format = "wheel";

  src = fetchPypi {
    pname = "blender_asset_tracer";
    inherit version;
    format = "wheel";
    dist = "py3";
    python = "py3";
    hash = "sha256-lkfWgqlPIl3ycsZjHekm8ABW6dcQqKBbLTmCw/g4cG8=";
  };

  dependencies = [ cattrs ];

  pythonRelaxDeps = [ "cattrs" ];

  pythonImportsCheck = [ "blender_asset_tracer" ];

  meta = {
    description = "Blender Asset Tracer, a.k.a. BAT, is the replacement of BAM and blender-file";
    homepage = "https://projects.blender.org/blender/blender-asset-tracer";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ nagy ];
  };
}
