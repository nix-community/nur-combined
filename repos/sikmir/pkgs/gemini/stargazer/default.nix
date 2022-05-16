{ lib, stdenv, rustPlatform, fetchFromSourcehut, Security, scdoc }:

rustPlatform.buildRustPackage rec {
  pname = "stargazer";
  version = "1.0.2";

  src = fetchFromSourcehut {
    owner = "~zethra";
    repo = pname;
    rev = version;
    hash = "sha256-uTGLqgf0BLeZXf6msn7teZEmhgvtvzcjmcHDU1mlSjo=";
  };

  cargoHash = "sha256-6VPvrGfcBRFGmUMMLPQXbCKqQmGjGbyG4Ogh0ZuEti0=";

  nativeBuildInputs = [ scdoc ];

  buildInputs = lib.optional stdenv.isDarwin Security;

  postBuild = ''
    scdoc < doc/stargazer.scd > stargazer.1
    scdoc < doc/stargazer-ini.scd > stargazer.ini.5
  '';

  postInstall = ''
    sh scripts/install \
      --prefix=$out \
      --bashdir=$out/share/bash-completion/completions \
      --zshdir=$out/share/zsh/site-functions \
      --fishdir=$out/share/fish/vendor_completions.d
  '';

  meta = with lib; {
    description = "stargazer is a concurrent Gemini server using async io with no runtime dependencies";
    inherit (src.meta) homepage;
    license = licenses.agpl3Plus;
    maintainers = [ maintainers.sikmir ];
  };
}
