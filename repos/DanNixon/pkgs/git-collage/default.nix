{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  installShellFiles,
  openssl,
  pkg-config,
}:
rustPlatform.buildRustPackage rec {
  pname = "git-collage";
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "DanNixon";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-lLcfodG3xsKkmV75G8oCi+vii4XZOt+MOzLIqguyDQc=";
  };

  nativeBuildInputs = [ installShellFiles pkg-config ];
  buildInputs = [ openssl ];

  cargoHash = "sha256-zcU342oyouEmisAgiCnUtcJMxaZr8K0+/ujB1tx/LZI=";

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
