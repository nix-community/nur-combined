{ lib
, buildGoModule
, fetchFromGitea
, templ
, esbuild
}:

buildGoModule (finalAttrs: {
  pname = "phantom";
  version = "0-unstable-2026-02-07";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "phantom-org";
    repo = "phantom";
    rev = "31304fbbc66ea48cce6f30be282230ad51ef9ad4";
    hash = "sha256-B9rOD6kLcttG6ltEqY8tX2jBOA62vlwBLlJ7FEFZ4Ek=";
  };

  vendorHash = "sha256-KweclllQ+X4pZgHmbqMnnjmr+ve34jykAC84RxP+lAQ=";

  #ldflags = [ "-s" ];
  ldflags = [
    "-s" "-w"
    "-X codeberg.org/kuu7o/phantom/internal/data.Version=${builtins.substring 0 7 finalAttrs.src.rev}"
  ];

  subPackages = [ "cmd/phantom" ];


  nativeBuildInputs = [ templ esbuild ];

  preBuild = ''
    templ generate

    mkdir -p ./web/static
    esbuild ./web/style/style.css --minify --outfile=./web/static/style.css
    esbuild ./web/style/main.css  --minify --outfile=./web/static/main.css
  '';


  meta = {
    description = "An alternative frontend for fandom.com";
    homepage = "https://codeberg.org/phantom-org/phantom";
    license = lib.licenses.gpl3Only;
    maintainers =  with lib.maintainers; [
      szanko
    ];
    mainProgram = "phantom";
  };
})
