{
  lib,
  rustPlatform,
  fetchFromGitHub,
  fetchpatch,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "zsh-patina";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "michel-kraemer";
    repo = "zsh-patina";
    tag = finalAttrs.version;
    hash = "sha256-sPlIT3UHtq+5+bpfrSPPfVXTdmqjEq+6k9tPShhG7h0=";
  };

  cargoPatches = [
    (fetchpatch {
      url = "https://github.com/michel-kraemer/zsh-patina/pull/61.patch";
      hash = "sha256-ofe8vmGmDSQlF8KpDi/1pRkI262EnQszCcgyYL1SLFg=";
      excludes = [ "Cargo.lock" ];
    })
    ./Cargo.lock.patch
  ];

  cargoHash = "sha256-crrbWkoNJ4LcV6Z/AZFsp9Qwb4yAXWIHlzXGuJzXSKw=";

  doCheck = false;

  postInstall = ''
    mkdir -p $out/share/zsh-patina
    echo 'eval "$('"$out/bin/zsh-patina"' activate)"' > $out/share/zsh-patina/zsh-patina.plugin.zsh
  '';

  meta = {
    description = "A blazingly fast Zsh plugin performing syntax highlighting of your command line while you type";
    homepage = "https://github.com/michel-kraemer/zsh-patina";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
})
