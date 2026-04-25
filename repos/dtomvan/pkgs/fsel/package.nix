{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "fsel";
  version = "3.4.1";

  src = fetchFromGitHub {
    owner = "Mjoyufull";
    repo = "fsel";
    tag = finalAttrs.version;
    hash = "sha256-pBQMSlEUICEfmzA+oSonzH0JlAcBjsVE0gT0QwsTNFE=";
  };

  cargoHash = "sha256-hNDiVdEOT3X6YSjggZgj1ZMpy4Ttcu3H7UKe/R1pJfY=";

  postInstall = ''
    install -Dm644 fsel.1 $out/share/man/man1/fsel.1
  '';

  meta = {
    description = "Fast TUI app launcher for GNU/Linux and *BSD";
    homepage = "https://github.com/Mjoyufull/fsel";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ dtomvan ];
    platforms = with lib.platforms; linux ++ darwin;
    mainProgram = "fsel";
  };
})
