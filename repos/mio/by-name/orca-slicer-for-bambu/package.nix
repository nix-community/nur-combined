{
  orca-slicer,
  fetchgit,
}:
orca-slicer.overrideAttrs (old: {
  pname = "orca-slicer-for-bambu";
  version = "0-unstable-2026-04-22";

  src = fetchgit {
    url = "https://f.sfconservancy.org/baltobu/orca-slicer-for-bambu.git";
    rev = "640e1856fdf1b7894b926e3fcb57c7a15b10ce16";
    fetchSubmodules = true;
    hash = "sha256-pk4dtihDAK0FSYDcW+AftQbnEgPTfhVz9n02c+2K3Go=";
  };

  patches = (old.patches or [ ]) ++ [
    ./patches/remove-avcodec-copy.patch
  ];

  meta = old.meta // {
    description = "OrcaSlicer fork with full BambuNetwork support restored for Bambu Lab printers";
    homepage = "https://f.sfconservancy.org/baltobu/orca-slicer-for-bambu";
    changelog = "https://f.sfconservancy.org/baltobu/orca-slicer-for-bambu/commits/branch/main";
    maintainers = [ ];
  };
})
