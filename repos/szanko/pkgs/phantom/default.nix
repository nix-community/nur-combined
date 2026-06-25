{ lib
, buildGoModule
, fetchFromGitea
, templ
, esbuild
}:

buildGoModule (finalAttrs: {
  pname = "phantom";
  version = "0-unstable-2026-04-17";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "phantom-org";
    repo = "phantom";
    rev = "37c3ffe408319ca2a36ba7de93ec2df87fe939ac";
    hash = "sha256-h18Bp0wZBGKTCP7HZnlYyOsN6XRCubHcueqpQmgQ8uo=";
  };

  vendorHash = "sha256-0Khknendus50ysBiwfiJyfvVI9t123PHq9+qe9y8exI=";

  #ldflags = [ "-s" ];
  ldflags = [
    "-s" "-w"
    "-X codeberg.org/kuu7o/phantom/internal/data.Version=${builtins.substring 0 7 finalAttrs.src.rev}"
  ];

  subPackages = [ "cmd/phantom" ];


  nativeBuildInputs = [ 
    templ 
    esbuild 
  ];

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
