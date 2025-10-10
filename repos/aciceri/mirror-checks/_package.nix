{
  writers,
  python3Packages,
  lib,
}:
let
  script = writers.writePython3Bin "mirror-checks" {
    libraries = with python3Packages; [
      requests
      pygithub
    ];
  } (builtins.readFile ./mirror-checks.py);
in
script.overrideAttrs (oldAttrs: {
  version = "1.0.0";
  meta =
    with lib;
    oldAttrs.meta or { }
    // {
      description = "Utility to synchronize CI checks from Forgejo to GitHub";
      license = licenses.gpl3Plus;
      maintainers = [ maintainers.aciceri ];
      # mainProgram is set automatically by writePython3Bin
    };
})
