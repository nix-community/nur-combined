{ stdenv
, lib
, fetchFromGitHub
, cmake
, nix-update-script
}:

stdenv.mkDerivation {
  pname = "asmjit";
  version = "git";

  nativeBuildInputs = [ cmake ];

  src = fetchFromGitHub {
    repo   = "asmjit";
    owner  = "asmjit";
    rev    = "0bd5787b54b575ed94bf32ac452153b34385c514";
    sha256 = "sha256-mBnpoTG2c6RrTjOYSIeIANQKE6Uvd3/dnBGDnw3AfSA=";
  };

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "AsmJit is a lightweight library for machine code generation written in C++ language.";
    license = licenses.zlib;
    platforms = platforms.unix;
    #maintainers = with maintainers; [ xxx ];
  };
}
