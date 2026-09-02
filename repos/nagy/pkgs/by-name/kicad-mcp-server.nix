{
  lib,
  pkgs,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_22,
  makeWrapper,
  python3,
  kicad,
}:

let
  self = import ../.. { inherit pkgs; };

  # Locate `pcbnew` inside kicad.base (KiCad installs it under
  # lib/pythonX.Y/site-packages; the version dir must be discovered).
  kicadSite =
    let
      libdirs = builtins.attrNames (builtins.readDir "${kicad.base}/lib");
      pyVers = builtins.filter (d: builtins.match "python[0-9.]+" d != null) libdirs;
    in
    "${kicad.base}/lib/${builtins.head pyVers}/site-packages";

  # Python interpreter carrying this server's non-pcbnew dependencies.
  # python3 is the interpreter KiCad's `pcbnew` bindings were built against.
  # `skip` (kicad-skip) and `kipy` (kicad-python) come from this repo's
  # python3Packages scope; the rest from nixpkgs.
  pythonEnv = python3.withPackages (ps: [
    ps.sexpdata
    ps.cairosvg
    ps.pymupdf
    ps.pillow
    ps.colorlog
    ps.python-dotenv
    ps.requests
    ps.pydantic
    ps.typing-extensions
    ps.kicad-python
    self.python3Packages.kicad-skip
  ]);
in

buildNpmPackage (finalAttrs: {
  pname = "kicad-mcp-server";
  version = "2.7.0";

  src = fetchFromGitHub {
    owner = "mixelpixx";
    repo = "KiCAD-MCP-Server";
    tag = "v${finalAttrs.version}";
    hash = "sha256-faCTkstk6LEm9qctoRObtlATUOW8JNQ645LepAFsgMI=";
  };

  npmDepsHash = "sha256-LBUZmYzYnaVyuU0/fwy6t3yoIIb8Qbve/mF/Fv6Y6qg=";

  nodejs = nodejs_22;

  nativeBuildInputs = [ makeWrapper ];

  # `npm pack` honors .gitignore, so the built `dist/` (and the Python /
  # config trees it lives alongside) are excluded from the npm install. Copy
  # them into the package root so `dist/index.js` can find them at runtime.
  postInstall = ''
    installDir=$out/lib/node_modules/kicad-mcp
    cp -r dist "$installDir"
    cp -r python "$installDir"
    cp -r config "$installDir"

    makeWrapper ${nodejs_22}/bin/node $out/bin/kicad-mcp-server \
      --set KICAD_PYTHON ${pythonEnv}/bin/python \
      --set KICAD_CLI ${kicad.base}/bin/kicad-cli \
      --prefix PATH : ${kicad.base}/bin \
      --prefix PYTHONPATH : ${kicadSite} \
      --prefix LD_LIBRARY_PATH : ${kicad.base}/lib \
      --set-default KICAD10_SYMBOL_DIR ${kicad.libraries.symbols}/share/kicad/symbols \
      --set-default KICAD10_FOOTPRINT_DIR ${kicad.libraries.footprints}/share/kicad/footprints \
      --set-default KICAD10_3DMODEL_DIR ${kicad.libraries.packages3d}/share/kicad/3dmodels \
      --set-default KICAD10_TEMPLATE_DIR ${kicad.libraries.templates}/share/kicad/template \
      --add-flags "$installDir/dist/index.js"
  '';

  meta = {
    description = "Model Context Protocol server that connects AI assistants to KiCAD for PCB design automation";
    homepage = "https://github.com/mixelpixx/KiCAD-MCP-Server";
    changelog = "https://github.com/mixelpixx/KiCAD-MCP-Server/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "kicad-mcp-server";
  };
})
