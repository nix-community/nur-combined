{ art-standalone, wolfssl }:

art-standalone.overrideAttrs (old: {
  pname = "art-standalone-patched";
  patches = builtins.filter (p: baseNameOf p != "remove-wolfssljni.patch") old.patches ++ [
    ./dx-workaround.patch
    ./art-datetime-formatter-lambda-crash.patch
    ./dex2oat-path.patch
  ];
  buildInputs = old.buildInputs ++ [ (wolfssl.override { enableJni = true; }) ];
})
