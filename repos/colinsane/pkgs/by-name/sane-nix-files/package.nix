{ stdenvNoCC ? null }:
let
  src = builtins.filterSource
    (path: type:
      let name = builtins.baseNameOf path;
    in !(
      # mimic .gitignore
      (name == ".working")
      || (name == "result")
      || (builtins.match "^result-.*" name != null)
    ))
    ../../../.
  ;

  fakeDeriv = {
    # in the bootstrap path, we don't have enough available to actually
    # link these files into a derivation.
    # but that's ok, because the caller immediately `import`s it anyway,
    # so just yield something importable.
    outPath = src;
  };
  realDeriv = stdenvNoCC.mkDerivation {
    name = "sane-nix-files";
    inherit src;
    installPhase = ''
      ln -s "$src" "$out"
    '';
    dontFixup = true;
  };

  # alternative implementation which always returns a real derivation,
  # but requires a pre-compiled statically-linked `sln` or `cp` implementation.
  # self = derivation {
  #   name = "sane-nix-files";
  #   system = "x86_64-linux";

  #   # builder = "${./sln}";
  #   # args = [
  #   #   src
  #   #   self.outPath
  #   # ];

  #   builder = "/bin/sh";
  #   args = [
  #     "-c"
  #     "${./sln} ${src} $out"
  #   ];
  # };
in
  if stdenvNoCC == null then
    fakeDeriv
  else
    realDeriv
