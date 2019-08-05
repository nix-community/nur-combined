{
  rust-analyzer = { fetchFromGitHub, rustPlatform, lib, darwin, hostPlatform }: rustPlatform.buildRustPackage rec {
    pname = "rust-analyzer";
    version = "4647e89defd367a92d00d3bbb11c2463408bb3ad";
    src = fetchFromGitHub {
      owner = "rust-analyzer";
      repo = pname;
      rev = version;
      sha256 = "1m3v5fwvqapd61llzbinji62s029kfwrfl24wbls59v3x816b23b";
    };
    cargoBuildFlags = ["--features" "jemalloc" "-p" "ra_lsp_server"];
    buildInputs = lib.optionals hostPlatform.isDarwin [ darwin.cf-private darwin.apple_sdk.frameworks.CoreServices ];
    # darwin undefined symbol _CFURLResourceIsReachable: https://discourse.nixos.org/t/help-with-rust-linker-error-on-darwin-cfurlresourceisreachable/2657

    cargoSha256 = "056pnnh3rx5piq95qmvv4wznf2ds1qv07c5w4724iy5i34ajmdzk";
    meta.broken = lib.versionAtLeast "1.36.0" rustPlatform.rust.rustc.version;

    doCheck = false;
  };
}
