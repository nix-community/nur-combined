{ stdenv, lib, fetchFromGitHub, autoreconfHook, cyrus_sasl, cyrus-sasl-xoauth2
, isync }:

stdenv.mkDerivation rec {
  pname = "cyrus-sasl-xoauth2";
  version = "0.2";

  src = fetchFromGitHub {
    owner = "moriyoshi";
    repo = pname;
    rev = "a0d05939c6da485a99cb92f628194f8b4e94a19d";
    sha256 = "sha256-OlmHuME9idC0fWMzT4kY+YQ43GGch53snDq3w5v/cgk=";
  };

  nativeBuildInputs = [ autoreconfHook ];

  buildInputs = [ cyrus_sasl ];

  # needed to make autoreconfHook work
  postPatch = ''
    touch NEWS AUTHORS ChangeLog
  '';

  passthru = rec {
    cyrus_sasl_oauth = cyrus_sasl.overrideAttrs (old: rec {
      postInstall = (old.postInstall or "") + ''
        for lib in ${cyrus-sasl-xoauth2}/lib/sasl2/*; do
          ln -sf $lib $out/lib/sasl2/
        done
      '';
    });
    isync_oauth = isync.override { cyrus_sasl = cyrus_sasl_oauth; };
  };

  makeFlags = [ "CYRUS_SASL_PREFIX=${placeholder "out"}" ];

  meta = with lib; {
    inherit (src.meta) homepage;
    description = "XOAUTH2 mechanism plugin for cyrus-sasl";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
