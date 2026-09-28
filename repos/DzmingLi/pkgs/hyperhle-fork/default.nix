{
  callPackage,
  lib,
  runCommand,
  coreutils,
  runtimeShell,
}:
let
  info = builtins.fromJSON (builtins.readFile ./sources.json);
  unwrapped = callPackage ./unwrapped.nix { };
  resources = runCommand "hyperhle-fork-${info.version}-resources" { } ''
    mkdir -p "$out"
    cp -r ${unwrapped.src}/touchHLE_dylibs ${unwrapped.src}/touchHLE_fonts \
      ${unwrapped.src}/touchHLE_default_options.txt "$out/"
    cp ${./rust-dependencies.txt} "$out/rust-dependencies.txt"
    chmod u+w "$out/touchHLE_default_options.txt"
    printf '\n# 三国杀－烈: use the iPhone 4 Retina framebuffer.\ncom.gameabc.SgsSingle2: --device-family=iphone-4\n' \
      >> "$out/touchHLE_default_options.txt"
  '';
in
runCommand "hyperhle-fork-${info.version}"
  {
    pname = "hyperhle-fork";
    inherit (info) version;
    passthru = {
      inherit unwrapped resources;
      src = unwrapped.src;
      updater = callPackage ./update.nix { };
      updateScript = [ (lib.getExe (callPackage ./update.nix { })) ];
    };
    meta = {
      description = "Experimental high-level emulator for 32-bit iOS apps";
      homepage = "https://github.com/KlugKlugTG/HyperHLE-Fork";
      license = lib.licenses.mpl20;
      mainProgram = "hyperhle-fork";
      platforms = [ "x86_64-linux" ];
    };
  }
  ''
    mkdir -p "$out/bin" "$out/share" "$out/libexec/hyperhle-fork"
    substitute ${./launcher.sh} "$out/bin/hyperhle-fork" \
      --subst-var-by runtimeShell ${runtimeShell} \
      --subst-var-by coreutils ${coreutils} \
      --subst-var-by resources ${resources} \
      --subst-var-by unwrapped ${unwrapped}
    chmod +x "$out/bin/hyperhle-fork"
    ln -s ${resources} "$out/share/hyperhle-fork"
    ln -s ${unwrapped}/bin/touchHLE "$out/libexec/hyperhle-fork/touchHLE"
  ''
