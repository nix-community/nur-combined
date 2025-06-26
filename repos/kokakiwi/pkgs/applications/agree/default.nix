{ lib

, fetchFromGitHub

, rustPlatform
, installShellFiles

, pkg-config

, libsodium
}:
rustPlatform.buildRustPackage rec {
  pname = "agree";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "replicadse";
    repo = "agree";
    rev = version;
    hash = "sha256-4UW4GblEnpAOvceU+ugVbdOcMRN8Ijy1OEeuzR5RJLU=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-kfVLy3QLK92RPicWGUZXazS9eIrieMXzQc9PpQq8KHs=";

  nativeBuildInputs = [
    pkg-config
    installShellFiles
  ];

  buildInputs = [
    libsodium
  ];

  env = {
    SODIUM_USE_PKG_CONFIG = true;
  };

  postInstall = ''
    $out/bin/agree man --out dist --format manpages
    for shell in bash fish zsh; do
      $out/bin/agree autocomplete --out dist --shell $shell
    done

    sed -i -s 's/neomake/agree/' dist/_neomake dist/neomake.*

    installManPage dist/*.1
    installShellCompletion \
      --bash --name agree.bash dist/neomake.bash \
      --fish --name agree.fish dist/neomake.fish \
      --zsh --name _agree dist/_neomake
  '';

  meta = with lib; {
    broken = true;
    description = "A CLI application that implements multi-key-turn security via Shamir's Secret Sharing";
    homepage = "https://github.com/replicadse/agree";
    license = licenses.mit;
    mainProgram = "agree";
  };
}
