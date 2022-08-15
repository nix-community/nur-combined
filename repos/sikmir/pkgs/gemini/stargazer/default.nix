{ lib, stdenv, rustPlatform, fetchFromSourcehut, Security, scdoc }:

rustPlatform.buildRustPackage rec {
  pname = "stargazer";
  version = "1.0.3";

  src = fetchFromSourcehut {
    owner = "~zethra";
    repo = "stargazer";
    rev = version;
    hash = "sha256-Xf3nclb+qYNADzPv878DLut1PeDIAZPaiTi1yFeSz2k=";
  };

  cargoHash = "sha256-iHh5s046sZI3/KGUgvIVADzA6AceOVfe9d5RJPWy8o0=";

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
