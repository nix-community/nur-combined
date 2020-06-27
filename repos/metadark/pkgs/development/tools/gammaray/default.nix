{ mkDerivation, stdenv, lib, fetchFromGitHub, cmake

# recommended packages
, enableManpages ? true, perl ? null
, enableSyntaxHighlighting ? true, syntax-highlighting ? null # FIXME
# , enableStateMachineDebugging ? true, KDSME ? null

# optional packages
, enableKJobTracker ? false, kcoreaddons ? null # FIXME
, enableWayland ? stdenv.isLinux, wayland ? null
}:

assert enableManpages -> perl != null;
assert enableSyntaxHighlighting -> syntax-highlighting != null;
assert enableKJobTracker -> kcoreaddons != null;
assert enableWayland -> wayland != null;

mkDerivation rec {
  pname = "gammaray";
  version = "2.11.1";

  src = fetchFromGitHub {
    owner = "KDAB";
    repo = "GammaRay";
    rev = "v${version}";
    sha256 = "0r7nvaqn1wlri0jdbshqq527yi1gdaki56kr56rf0jc1ffzqlaw3";
  };

  nativeBuildInputs = [ cmake ]
    ++ lib.optional enableManpages [ perl ];

  buildInputs = []
    ++ lib.optional enableSyntaxHighlighting [ syntax-highlighting ]
    ++ lib.optional enableKJobTracker [ kcoreaddons ]
    ++ lib.optional enableWayland [ wayland ];

  meta = with lib; {
    homepage = "https://github.com/KDAB/GammaRay";
    description = "A software introspection tool for Qt applications";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ metadark ];
    platforms = platforms.all;
  };
}
