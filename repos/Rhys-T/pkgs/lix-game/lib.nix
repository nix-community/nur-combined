{ stdenvNoCC, lib, enet }: {
    patchEnetBindings = let libExtension = if stdenvNoCC.isDarwin then "dylib" else "so"; in ''
        for file in "$DUB_HOME"/packages/derelict-enet/*/derelict-enet/source/derelict/enet/enet.d; do
            substituteInPlace "$file" --replace-fail '"libenet.${libExtension}"' '"${lib.getLib enet}/lib/libenet.${libExtension}"'
        done
    '';
}
