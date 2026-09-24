{
  lib,
  python3Packages,
  fetchPypi,
  nix-update,
  writeShellScript,
}:
python3Packages.buildPythonApplication rec {
  pname = "mcp-for-blender";
  version = "2.0.3";
  pyproject = true;

  src = fetchPypi {
    pname = "mcp_for_blender";
    inherit version;
    hash = "sha256-+SucfR9US67ErwLmaKQ6HwyuBMKJU1x/bwDKONsmibg=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    mcp
    httpx
  ];

  # The PyPI sdist ships tests/ but not tests/conftest.py, so every test
  # module fails at collection on `import conftest`. Upstream publishes no
  # git tags, so there is no equivalent tagged source to build from instead.
  doCheck = false;

  pythonImportsCheck = [ "blender_mcp.server" ];

  # The Blender side is a plain add-on file that must live in Blender's own
  # scripts/addons directory. Exposing the copy bundled with *this* version
  # keeps the socket protocol version of add-on and server in lockstep, which
  # `mcp-for-blender install-addon` cannot guarantee (it writes into $HOME).
  postInstall = ''
    install -Dm444 src/blender_mcp/bundled/addon.py $out/share/blender-mcp/addon.py
  '';

  passthru.updateScript = writeShellScript "update-script.sh" "${lib.getExe nix-update} --flake blender-mcp";

  meta = {
    description = "MCP server driving Blender through a socket add-on";
    longDescription = ''
      Third-party MCP server that lets any MCP client inspect and edit a running
      Blender scene. It talks JSON over TCP (default port 9876) to the companion
      Blender add-on, shipped here as `share/blender-mcp/addon.py`.
    '';
    homepage = "https://github.com/ahujasid/mcp-for-blender";
    license = lib.licenses.mit;
    mainProgram = "mcp-for-blender";
    platforms = lib.platforms.all;
  };
}
