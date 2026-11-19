{
  fetchFromGitHub,
  lib,
  makeWrapper,
  python-libzim_3,
  python3,
  stdenv,
  unstableGitUpdater,
}:
stdenv.mkDerivation {
  pname = "kiwix-mcp";
  version = "0-unstable-2026-10-25";

  src = fetchFromGitHub {
    owner = "roanpy";
    repo = "kiwix-mcp";
    rev = "280675d5e9d9c1e8b442c8787ef84d2b2caddc1f";
    hash = "sha256-VuAf2J+RCoxd7mDyPeHiAkBjxY+DNklaoYALMY8V5Q4=";
  };

  nativeBuildInputs = [
    makeWrapper
    python3.pkgs.setuptools
    python3.pkgs.pypaBuildHook
    python3.pkgs.pypaInstallHook
    python3.pkgs.wrapPython
  ];

  propagatedBuildInputs = [
    python3.pkgs.beautifulsoup4
    python3.pkgs.mcp
    # kiwix-mcp specifies `libzim>=3.12,<4`.
    # the 4.x libzim renamed everything from camelCase to snake case, so we can't trivially relax that version requirement.
    python-libzim_3
  ];

  postPatch = ''
    cat >kiwix-mcp <<EOF
    #!/usr/bin/env python3
    import runpy
    # re-exec into `server.py` in a way that triggers its `if __name__ == '__main__'` block.
    # `alter_sys=True` makes `sys.argv[0]` and `sys.modules['__main__']` behave the same as for a direct exec.
    # better, would be to wrap server.py directly, but that would make it not `import`able from other Python libraries.
    runpy.run_module("server", run_name="__main__", alter_sys=True)
    EOF
    chmod +x kiwix-mcp
  '';

  postInstall = ''
    mkdir -p $out/bin
    cp -a kiwix-mcp $out/bin
  '';

  postFixup = ''
    wrapPythonPrograms
  '';

  strictDeps = true;
  __structuredAttrs = true;

  passthru = {
    pythonModule = python3;
    updateScript = unstableGitUpdater { };
  };

  meta = {
    description = "MCP server for local Kiwix ZIM archives";
    homepage = "https://github.com/roanpy/kiwix-mcp";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ colinsane ];
    mainProgram = "kiwix-mcp";
    platforms = lib.platforms.linux;
  };
}
