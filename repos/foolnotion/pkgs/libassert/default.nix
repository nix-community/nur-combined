{ lib, pkgs, stdenv, fetchFromGitHub, cmake, cpptrace, magic-enum, zstd, libdwarf, enableTesting ? true }:
let
  magic-enum = pkgs.magic-enum.overrideAttrs (old: { cmakeFlags = old.cmakeFlags ++ (if !enableTesting then [ "-DMAGIC_ENUM_OPT_BUILD_TESTS=0" "-DMAGIC_ENUM_OPT_BUILD_EXAMPLES=0" ] else [ ]); });
in
stdenv.mkDerivation rec {
  pname = "libassert";
  version = "2.2.1";

  src = fetchFromGitHub {
    owner = "jeremy-rifkin";
    repo = "libassert";
    rev = "v${version}";
    hash = "sha256-ognudQ3NgpYxiDEucbIRWYQPs0XLRUQwg1eMxJm+aPs=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ cpptrace magic-enum zstd libdwarf ];

  cmakeFlags = [
    "-DLIBASSERT_USE_EXTERNAL_CPPTRACE=1"
    "-DLIBASSERT_USE_EXTERNAL_MAGIC_ENUM=1"
  ] ++ cpptrace.cmakeFlags;

  meta = with lib; {
    description = "C++ assertion library";
    homepage = "https://github.com/jeremy-rifkin/libassert";
    license = licenses.mit;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
