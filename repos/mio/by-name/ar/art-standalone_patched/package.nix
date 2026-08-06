{ art-standalone, wolfssl }:

art-standalone.overrideAttrs (old: {
  pname = "art-standalone-patched";
  patches = builtins.filter (p: baseNameOf p != "remove-wolfssljni.patch") old.patches;
  buildInputs = old.buildInputs ++ [ (wolfssl.override { enableJni = true; }) ];
})
