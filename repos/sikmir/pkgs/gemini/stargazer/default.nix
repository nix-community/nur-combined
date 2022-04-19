{ lib, stdenv, rustPlatform, fetchFromSourcehut, Security, scdoc, installShellFiles }:

rustPlatform.buildRustPackage rec {
  pname = "stargazer";
  version = "0.6.1";

  src = fetchFromSourcehut {
    owner = "~zethra";
    repo = pname;
    rev = version;
    hash = "sha256-8wYTqZoLiMsPWY3+tYBCbRPqs0K5+3syMSJr+iTcTrE=";
  };

  cargoHash = "sha256-G0Wu/lseT5IFWkzc8PaU51ATMqw9nHJOwT3sXNYRMw4=";

  nativeBuildInputs = [ scdoc installShellFiles ];

  buildInputs = lib.optional stdenv.isDarwin Security;

  postBuild = ''
    scdoc < doc/stargazer.scd > stargazer.1
    scdoc < doc/stargazer-ini.scd > stargazer.ini.5
  '';

  postInstall = ''
    installManPage stargazer.1
    installManPage stargazer.ini.5

    install -Dm644 config.ini -t $out/share/stargazer

    installShellCompletion --bash target/**/completions/stargazer.bash
    installShellCompletion --fish target/**/completions/stargazer.fish
    installShellCompletion --zsh target/**/completions/_stargazer
  '';

  meta = with lib; {
    description = "stargazer is a concurrent Gemini server using async io with no runtime dependencies";
    inherit (src.meta) homepage;
    license = licenses.agpl3Plus;
    maintainers = [ maintainers.sikmir ];
  };
}
