{
  rustPlatform,
  protobuf,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "pandoc-to-anki";
  version = "0.1.0";
  src = fetchFromGitHub {
    owner = "wrvsrx";
    repo = "pandoc-to-anki";
    tag = finalAttrs.version;
    fetchSubmodules = true;
    hash = "sha256-rt4AvwV21ip44zx6v6VwxyTBx/0S8VKWIZ/XuCcHN7c=";
  };
  nativeBuildInputs = [ protobuf ];
  cargoHash = "sha256-JPzGLJelFqS9EboOh0JTJ2h4MWHQ/sGR2LFq5pE1D/c=";
})
