{
  stdenv,
  fetchFromGitHub,
  nodejs,
  pnpmConfigHook,
  pnpm,
  fetchPnpmDeps,
  lib,
}:
stdenv.mkDerivation rec {
  pname = "obsidian-git";
  version = "2.43.0";

  src = fetchFromGitHub {
    owner = "Vinzent03";
    repo = "obsidian-git";
    rev = version;
    sha256 = "sha256-ZSEerv8rmIPvhtkl8AKKddxG0RSFvfjFz2WYt9QAQUg=";
  };

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm
  ];

  buildPhase =
    # bash
    ''
      runHook preBuild

      pnpm run build

      runHook postBuild
    '';

  installPhase =
    # bash
    ''
      mkdir -p $out/
      cp main.js manifest.json styles.css $out/
    '';

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = 1;
  };

  patches = [
    ./supported-architectures.patch
  ];

  pnpmDeps = fetchPnpmDeps {
    fetcherVersion = 4;
    inherit pname version src patches;
    hash = "sha256-d2YnBQogvcMQtfdefkO9rTv9B2aFq4qXDr6dGrKi4c0=";
  };

  meta = {
    description = "Integrate Git version control with automatic backup and other advanced features.";
    homepage = "https://github.com/Vinzent03/obsidian-git";
    changelog = "https://github.com/Vinzent03/obsidian-git/releases/tag/${version}";
    license = lib.licenses.mit;
  };
}
