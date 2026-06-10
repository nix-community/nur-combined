{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "ggufmeta";
  version = "0-unstable-2023-12-28";

  src = fetchFromGitHub {
    owner = "abrander";
    repo = "gguf";
    rev = "3d15a052a17f0ce9e8a410ffdcda795f94bd1506";
    hash = "sha256-PmIkVEkyX8DU+4gp3EgqHDsSR4tRNgs0vKy+zEwrAk4=";
  };

  vendorHash = null;

  subPackages = [
    "."
    "ggufmeta"
  ];

  ldflags = [
    "-s"
    "-w"
  ];

  meta = with lib; {
    description = "Go package for reading GGUF files";
    longDescription = ''
      A Go package for reading GGUF (GPT-Generated Unified Format) files.
      It is concerned with reading the metadata and the tensor bytes,
      and does not interpret the data in any way.
      GGUF versions 1, 2 and 3 are supported.
    '';
    homepage = "https://github.com/abrander/gguf";
    license = licenses.mit;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "ggufmeta";
  };
})
