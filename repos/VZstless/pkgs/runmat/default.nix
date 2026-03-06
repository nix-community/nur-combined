{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openblas,
  openssl,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "runmat";
  version = "0.2.8";

  src = fetchFromGitHub {
    owner = "runmat-org";
    repo = "runmat";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-Q+0tPTvPNvFJJ5cGm8ejj1vFo9QPzqGUNa8lI7uFQe0=";
  };

  cargoHash = "sha256-7H4BpCS2Xe5AzhtaQD81toVjzVZ59XZeqnmXZI/5jDI=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openblas openssl ];

  # crate `runmat-accelerate` needs a wgpu compatible adapter to test
  doCheck = false;

  meta = {
    description = "Fast runtime for MATLAB/Octave workloads";
    homepage = "https://runmat.com/";
    license = lib.licenses.mit;
    mainProgram = "runmat";
  };
})
