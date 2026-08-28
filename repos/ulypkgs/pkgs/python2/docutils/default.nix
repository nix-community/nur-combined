{
  stdenv,
  lib,
  fetchPypi,
  buildPythonPackage,
  isPy3k,
  python,
}:

buildPythonPackage (finalAttrs: {
  pname = "docutils";
  version = "0.16";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-wt46YOnn0Hvia38rAMoDCcIH4GwQD5zCqUkx/HWkePw=";
  };

  # Only Darwin needs LANG, but we could set it in general.
  # It's done here conditionally to prevent mass-rebuilds.
  checkPhase =
    lib.optionalString (isPy3k && stdenv.isDarwin) ''LANG="en_US.UTF-8" LC_ALL="en_US.UTF-8" ''
    + ''
      ${python.interpreter} test/alltests.py
    '';

  # Create symlinks lacking a ".py" suffix, many programs depend on these names
  postFixup = ''
    for f in $out/bin/*.py; do
      ln -s $(basename $f) $out/bin/$(basename $f .py)
    done
  '';

  meta = {
    description = "Docutils -- Python Documentation Utilities";
    homepage = "http://docutils.sourceforge.net/";
    maintainers = with lib.maintainers; [ AndersonTorres ];
  };
})
