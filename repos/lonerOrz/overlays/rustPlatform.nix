self: super: let
  rustBin = self.rust-bin.selectLatestNightlyWith (toolchain:
    toolchain.default.override {
      extensions = ["rust-src"];
      targets = ["arm-unknown-linux-gnueabihf"];
    });

  rustPlatform = super.makeRustPlatform {
    cargo = rustBin;
    rustc = rustBin;
  };

  cargoAuditable = rustPlatform.buildRustPackage (final: {
    pname = "cargo-auditable";
    version = "0.6.6";

    src = super.fetchFromGitHub {
      owner = "Aaronepower";
      repo = "cargo-auditable";
      rev = "v${final.version}";
      sha256 = "";
    };

    useFetchCargoVendor = true;
    cargoHash = "";

    meta = with super.lib; {
      description = "Tool to make production Rust binaries auditable";
      homepage = "https://github.com/rust-secure-code/cargo-auditable";
      license = licenses.mit;
    };
  });
in {
  rustPlatform =
    super.makeRustPlatform {
      cargo = rustBin;
      rustc = rustBin;
    }
    // {
      cargo-auditable = cargoAuditable;
    };
}
