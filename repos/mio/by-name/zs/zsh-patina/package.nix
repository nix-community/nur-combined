{
  lib,
  rustPlatform,
  fetchFromGitHub,
  fetchpatch,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "zsh-patina";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "michel-kraemer";
    repo = "zsh-patina";
    tag = finalAttrs.version;
    hash = "sha256-M14IeK+Nsst+6RK6ayhq37YSoFPVptNqE9blVHDI1YM=";
  };

  cargoHash = "sha256-4Meb4BDV/Um8/YMA5DkeNDcgCMS5cA8olKhOIq9coIU=";

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
