{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
}:

buildDotnetModule rec {
  pname = "rofsc";
  version = "1.0.0.0";

  src = fetchFromGitHub {
    owner = "AtlasOmegaAlpha";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-0EP+mQe+HdEzjNxSr0hMEvESV8uQg3DikE+VLM4EDic=";
  };

  patches = [
    ./dont-wait-for-key-on-exit.patch
  ];

  projectFile = "rofsc/rofsc.csproj";

  meta = with lib; {
    description = "3DS ROFS packer";
    homepage = "https://github.com/AtlasOmegaAlpha/rofsc";
    platforms = platforms.all;
    mainProgram = "rofsc";
  };
}
