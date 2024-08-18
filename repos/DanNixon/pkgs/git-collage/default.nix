{
  lib,
  fetchFromGitHub,
  rustPlatform,
  installShellFiles,
  openssl,
  pkg-config,
}:
rustPlatform.buildRustPackage rec {
  pname = "git-collage";
  version = "0.4.3";

  src = fetchFromGitHub {
    owner = "DanNixon";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-7XTWmXG6iz5I11ubcc4q2iCgFyXjKUSTroocpeLqy/g=";
  };

  nativeBuildInputs = [ installShellFiles pkg-config ];
  buildInputs = [ openssl ];

  cargoHash = "sha256-4Askw9Obh5E9D/LsmwObcVKC24iagGLCper/1BtL9V4=";

  postInstall = ''
    installShellCompletion --cmd ${pname} \
      --bash <($out/bin/${pname} completions bash) \
      --fish <($out/bin/${pname} completions fish) \
      --zsh <($out/bin/${pname} completions zsh)
  '';

  meta = {
    description = "A tool for selectively mirroring Git repositories.";
    homepage = "https://github.com/DanNixon/${pname}";
    platforms = lib.platforms.unix;
    license = lib.licenses.mit;
  };
}
