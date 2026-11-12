{
  fetchFromGitHub,
  gitUpdater,
  lib,
  python3,
  stdenv,
  tree-sitter-grammars,
  writeText,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "semble-grammars";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "MinishLab";
    repo = "semble-grammars";
    tag = "v${finalAttrs.version}";
    hash = "sha256-kqOfUQTHQIKmASqRhIvBUhrTGFvSG4qtmYAQg4ceyxE=";
  };

  postPatch = let
    # e.g. `linux-x86_64` or `linux-aarch64`
    # lowercase form of `python -c 'import platform; print(f"{platform.system()}-{platform.machine()}")'
    platform = "${stdenv.hostPlatform.parsed.kernel.name}-${stdenv.hostPlatform.parsed.cpu.name}";
    manifest = writeText "manifest.json" (builtins.toJSON {
      inherit platform;
      archive = "";
      languages = lib.listToAttrs (map (pkg:
        let language = lib.replaceStrings [ "-" ] [ "_" ] (lib.removePrefix "tree-sitter-" pkg.pname);
        in {
          name = language;
          value = {
            file = "${pkg}/parser";
            symbol = "tree_sitter_${language}";
            sha256 = "";
          };
        }
      ) tree-sitter-grammars.allGrammars);
    });
  in ''
    mkdir -p src/semble_grammars/grammars/${platform}
    ln -s ${manifest} src/semble_grammars/grammars/${platform}/manifest.json
  '';

  nativeBuildInputs = [
    python3.pkgs.pypaBuildHook
    python3.pkgs.pypaInstallHook
    python3.pkgs.setuptools
    python3.pkgs.setuptools-scm
  ];

  propagatedBuildInputs = [
    python3.pkgs.tree-sitter
  ];

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
  };
})
