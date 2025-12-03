{
  docsets,
  jq,
  nix,
  runCommand,
  stdenvNoCC,
}:
let
  # nix has logic to build an attrset of all the items which make it into `nix.doc`
  # this is a json dictionary with each entry like:
  #   "abort": { "args": [ "s" ], "doc": "Abort Nix expression evaluation and print the error message *s*." }

  builtins-locations = runCommand "nix-locations.json" {
    preferLocalBuild = true;
    nativeBuildInputs = [ jq nix ];
  } ''
    mkdir $out
    nix __dump-language | jq . > $out/locations.json
  '';

  docset = stdenvNoCC.mkDerivation {
    pname = "nix-builtins";
    version = nix.version;

    nativeBuildInputs = [ docsets.make-docset-index ];

    unpackPhase = ''
      cp ${./Info.plist} Info.plist
      cp ${builtins-locations}/locations.json locations.json
      cp -R ${nix.doc}/share/doc/nix/manual nix-manual
    '';

    buildPhase = ''
      runHook preBuild

      mkdir -p nix-builtins.docset/Contents/Resources/
      cp Info.plist nix-builtins.docset/Contents/
      cp -R nix-manual nix-builtins.docset/Contents/Resources/Documents

      make-docset-index --verbose locations.json --output nix-builtins.docset/Contents/Resources/docSet.dsidx

      runHook postBuild
    '';

    # docsets are usually distributed as .tgz, but compression is actually optional at least for tools like `dasht`
    installPhase = ''
      mkdir -p $out/share/docsets
      cp -R *.docset $out/share/docsets/
    '';

    passthru = {
      inherit builtins-locations;
    };
  };
in
  docset
