{ lib, stdenv, fetchFromGitHub, cmake
, nix-update-script
}:
stdenv.mkDerivation rec {
  pname = "libdwarf";
  version = "2.3.1";

  src = fetchFromGitHub {
    owner = "davea42";
    repo = "libdwarf-code";
    rev = "v${version}";
    hash = "sha256-azVCzQt9oA40YACa9PkdNt0D8vWRNHXXGoSFOYNJxgA=";
  };

  nativeBuildInputs = [ cmake ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Library for reading DWARF2 and DWARF formats";
    homepage = "https://github.com/davea42/libdwarf-code";
    platforms = lib.platforms.unix;
    license = lib.licenses.lgpl21Plus;
    maintainers = [ lib.maintainers.atry ];
  };
}
