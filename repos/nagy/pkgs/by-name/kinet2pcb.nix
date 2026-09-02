{
  lib,
  pkgs,
  python3,
  kicad,
  makeWrapper,
  fetchFromGitHub,
}:

let
  # Re-import this repo to reach the packages listed under python3Packages.
  self = import ../.. { inherit pkgs; };

  # Locate `pcbnew.py` inside kicad.base (KiCad generates it against a specific
  # Python major.minor, so the directory version must be discovered).
  kicadSite =
    let
      libdirs = builtins.attrNames (builtins.readDir "${kicad.base}/lib");
      pyVers = builtins.filter (d: builtins.match "python[0-9.]+" d != null) libdirs;
    in
    "${kicad.base}/lib/${builtins.head pyVers}/site-packages";
in
python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "kinet2pcb";
  version = "1.1.4";

  pyproject = true;

  src = fetchFromGitHub {
    owner = "devbisme";
    repo = "kinet2pcb";
    tag = finalAttrs.version;
    hash = "sha256-cdacMj0sqsMj2OrUktuUKHUKu2QJYcRWNq4eXb+p5Jc=";
  };

  nativeBuildInputs = [ makeWrapper ];

  build-system = [
    python3.pkgs.setuptools
  ];

  patchPhase = ''
    runHook prePatch
    sed -i "/setup_requires\s*=.*/d" setup.py
    runHook postPatch
  '';

  dependencies = [
    python3.pkgs.simp-sexp
    self.python3Packages.hierplace
  ];

  # `pcbnew` is only importable with kicad.base's site-packages on PYTHONPATH,
  # which is not the case during the build. Skip the import check to avoid
  # dragging KiCad in as a build dependency.
  # pythonImportsCheck = [ "kinet2pcb" ];

  postFixup = ''
    wrapProgram "$out/bin/kinet2pcb" \
      --prefix PYTHONPATH : ${kicadSite} \
      --prefix LD_LIBRARY_PATH : ${kicad.base}/lib
  '';

  meta = {
    description = "Groups and arranges KiCad PCBNEW parts so they reflect the design hierarchy";
    homepage = "https://github.com/devbisme/kinet2pcb";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "kinet2pcb";
  };
})
