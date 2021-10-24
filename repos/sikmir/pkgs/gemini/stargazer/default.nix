{ lib, stdenv, rustPlatform, fetchFromSourcehut, Security, scdoc, installShellFiles }:

rustPlatform.buildRustPackage rec {
  pname = "stargazer";
  version = "0.6.0";

  src = fetchFromSourcehut {
    owner = "~zethra";
    repo = pname;
    rev = version;
    hash = "sha256-aYFNLujOZxiylIkiODqNqoVkk/8KP2FHy0jhW9xZYPE=";
  };

  cargoHash = "sha256-kPB8msg6wT5/XqeRN51rUrrfOqBJtlb18uAFV6hOMKg=";

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
