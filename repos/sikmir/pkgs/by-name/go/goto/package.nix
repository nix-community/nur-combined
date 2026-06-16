{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "goto";
  version = "1.6.1";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "grafviktor";
    repo = "goto";
    tag = "v${finalAttrs.version}";
    hash = "sha256-SG9WhTKlnROwLCa63c2TYm4rnhCpr0hEkl1jJNDqxWk=";
  };

  vendorHash = "sha256-vED3QySeVRtk0ZeFSXpnQuCThsiNkVW6sNpJbrE8JV4=";

  ldflags = [
    "-s"
    "-w"
    "-X main.buildVersion=${finalAttrs.version}"
  ];

  meta = {
    description = "A simple SSH manager";
    homepage = "https://github.com/grafviktor/goto";
    license = lib.licenses.mit;
    mainProgram = "goto";
    maintainers = [ lib.maintainers.sikmir ];
  };
})
