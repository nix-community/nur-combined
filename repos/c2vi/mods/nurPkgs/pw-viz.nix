{ pkgs
, fetchFromGitHub
, lib
, clang
, cmake
, pkg-config
, libclang
, fontconfig
, xorg
, pipewire
, glibc
, llvmPackages
}:

pkgs.rustPlatform.buildRustPackage rec {
	pname = "pw-viz";
	version = "0.3.0";

	src = fetchFromGitHub {
		owner = "Ax9D";
		repo = "pw-viz";
    rev = "v${version}";
    sha256 = "sha256-fB7PnWWahCMKhGREg6neLmOZjh2OWLu61Vpmfsl03wA=";
	};

  cargoHash = "sha256-jsaWrdJRKfu75Gw8qGHxx0FHK7rOEK8IEDiQ6ktZsM0=";
  useFetchCargoVendor = true;

  nativeBuildInputs = [
    cmake
    pkg-config
  ];
  
  buildInputs =  [
    fontconfig
    xorg.libxcb
    pipewire
    clang
    glibc.dev
    llvmPackages.libcxx.dev
  ];

  LD_LIBRARY_PATH = lib.makeLibraryPath [
    fontconfig
  ];

  LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";

  BINDGEN_EXTRA_CLANG_ARGS = "-I${libclang.lib}/lib/clang/19/include -I${glibc.dev}/include";

  meta = with lib; {
    description = "Pipewire graph editor written in Rust. WIP⚠️";
    longDescription = ''
      A simple and elegant, pipewire graph editor
    '';
    homepage = "https://github.com/Ax9D/pw-viz";
    license = licenses.gpl2Only;
    #maintainers = [ ];
    platforms = platforms.all;
  };
}

/*
let
  # We pin to a specific nixpkgs commit for reproducibility.
  # Last updated: 2024-04-29. Check for new commits at https://status.nixos.org.
  #pkgs = import <(fetchTarball "https://github.com/NixOS/nixpkgs/archive/cf8cc1201be8bc71b7cbbbdaf349b22f4f99c7ae.tar.gz")> {};
  pkgs = import <nixpkgs> {};
in pkgs.mkShell {
  packages = with pkgs; [
  ];
  shellHook = ''
  '';
}
*/
