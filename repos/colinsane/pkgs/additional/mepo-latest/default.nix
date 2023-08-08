{ mepo
, fetchFromSourcehut
# to make it easier for consumers to `.override`
, stdenv
, zigHook
}:
(mepo.override {
  inherit stdenv zigHook;
}).overrideAttrs (upstream: {
  pname = "mepo-latest";
  version = "1.1.2";
  src = fetchFromSourcehut {
    owner = "~mil";
    repo = "mepo";
    rev = "1.1.2";
    hash = "sha256-rKIyhr0sxG1moFsapylJWoAoHi9FSRdugIHr/TqY71s=";
   };
})
