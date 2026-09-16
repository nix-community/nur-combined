{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "nix-easy-search";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "Sh0rtRound-wq";
    repo = "NixEasySearch";
    tag = "v${finalAttrs.version}";
    hash = "sha256-v5Jc5FCTgYDfkSqqDYoxJmr0thF8ECzB3QD/vYAHzqs=";
  };

  vendorHash = "sha256-hN1s+fMfmnpNGrh8/XrljJEkCMfzGFNHAnh2OqeaVek=";

  strictDeps = true;
  __structuredAttrs = true;

  postInstall = ''
    mv $out/bin/nix-easy-search $out/bin/nes
  '';

  meta = {
    description = "Fast NixOS package search CLI with clean output";
    homepage = "https://github.com/Sh0rtRound-wq/NixEasySearch";
    license = lib.licenses.mit;
    mainProgram = "nes";
    platforms = lib.platforms.unix;
  };
})
