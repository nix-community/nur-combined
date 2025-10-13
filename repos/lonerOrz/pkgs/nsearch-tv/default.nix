{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  fzf,
  gnused,
  gawk,
  xdg-utils,
  nix-search-tv,
  bash,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nix-search-tv";
  version = "2.2.3";

  src = fetchFromGitHub {
    owner = "3timeslazy";
    repo = "nix-search-tv";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-fhXbkH1iqLugr5zkuSgxUYziq5Q4f+QnV5eSag9La8g=";
  };

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [ bash ];

  propagatedBuildInputs = [
    fzf
    gnused
    gawk
    xdg-utils
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp nixpkgs.sh "$out/bin/nsearch-tv"
    chmod +x $out/bin/nsearch-tv
    wrapProgram $out/bin/nsearch-tv \
      --prefix PATH : ${
        lib.makeBinPath [
          fzf
          gnused
          gawk
          nix-search-tv
          xdg-utils
        ]
      }

    runHook postInstall
  '';

  meta = {
    description = "Interactive Nix package search with fzf";
    homepage = "https://github.com/3timeslazy/nix-search-tv";
    mainProgram = "nsearch-tv";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    binaryNativeCode = true;
  };
})
