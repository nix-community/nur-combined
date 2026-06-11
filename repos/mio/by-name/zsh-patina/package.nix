{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "zsh-patina";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "michel-kraemer";
    repo = "zsh-patina";
    rev = "efe6e7593b9b21959996f0eee03b12db988b3e13";
    hash = "sha256-hE7PFVE7CmLUALHwSfNWhwwXcy9ORiXYd4aP2Mg+c80=";
  };

  cargoHash = "sha256-CYtYvQMcn3NdQbCrFo84y97amwCpM7aa+4B3dFAFk1o=";

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
