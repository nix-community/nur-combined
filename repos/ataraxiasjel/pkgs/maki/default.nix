{
  lib,
  rustPlatform,
  fetchFromGitHub,
  makeWrapper,
  perl,
  python3,
  rtk,
  nix-update-script,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "maki";
  version = "0.5.3";

  src = fetchFromGitHub {
    owner = "tontinton";
    repo = "maki";
    rev = "v${finalAttrs.version}";
    hash = "sha256-mJFvNpbtYPb0wSsHvKYGFnk48tK5L9vVGg9elzEgXRA=";
  };

  cargoHash = "sha256-l8Lu+7hQzZ9D5Vhs0R+0J6EtgO07UM/9IeAy/224zaU=";

  nativeBuildInputs = [
    makeWrapper
    perl
  ];

  postFixup = ''
    wrapProgram $out/bin/maki \
      --prefix PATH : ${
        lib.makeBinPath [
          python3 # code_execution default tool uses python
          rtk # maki can use rtk by default
        ]
      }
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "An efficient AI coding agent extendable by neovim like Lua plugins";
    homepage = "https://github.com/tontinton/maki";
    license = with lib.licenses; [ mit ];
    mainProgram = "maki";
    maintainers = with lib.maintainers; [ ataraxiasjel ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  };
})
