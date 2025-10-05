{
  lib,
  stdenv,
  fetchFromGitHub,
  zig,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gurl";
  version = "0.1-unstable-2023-08-23";

  src = fetchFromGitHub {
    owner = "ikskuh";
    repo = "gurl";
    rev = "c1f2b106a73019a145c0f1548d02e0ea8d7a1a50";
    hash = "sha256-DMyON1+EAFcqnVI03bgk7iYOgGTLMEuCNbmWHp80K0k=";
  };

  nativeBuildInputs = [ zig ];

  buildPhase = ''
    export HOME=$TMPDIR
    zig build -Drelease-safe=true -Dcpu=baseline
  '';

  installPhase = ''
    install -Dm755 zig-out/bin/gurl -t $out/bin
  '';

  meta = {
    description = "A curl-like cli application to interact with Gemini sites";
    homepage = "https://github.com/ikskuh/gurl";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
    broken = true; # https://github.com/MasterQ32/gurl/issues/5
  };
})
