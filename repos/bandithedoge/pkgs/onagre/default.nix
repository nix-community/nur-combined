{
  pkgs,
  sources,
  ...
}: let
  unwrapped = pkgs.rustPlatform.buildRustPackage {
    inherit (sources.onagre) src;
    version = sources.onagre.date;
    pname = "onagre-unwrapped";
    cargoLock = sources.onagre.cargoLock."Cargo.lock";
  };
in
  pkgs.stdenv.mkDerivation rec {
    inherit (unwrapped) pname version src;

    nativeBuildInputs = with pkgs; [
      makeWrapper
    ];

    buildInputs = with pkgs; [
      wayland
      libxkbcommon
      libGL
      vulkan-loader
    ];

    buildPhase = ''
      mkdir -p $out/bin

      makeWrapper ${unwrapped}/bin/onagre $out/bin/onagre \
        --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath buildInputs}
    '';

    passthru = {inherit unwrapped;};

    meta = with pkgs.lib; {
      description = "A general purpose application launcher for X and wayland inspired by rofi/wofi and alfred";
      homepage = "https://github.com/onagre-launcher/onagre";
      license = licenses.mit;
      platforms = ["x86_64-linux"];
    };
  }
