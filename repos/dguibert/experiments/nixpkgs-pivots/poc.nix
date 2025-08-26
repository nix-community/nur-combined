let
  pkgs = import <nixpkgs> {};
  someBinary = pkgs.runCommandNoCC "binary" {} ''
    mkdir -p $out/bin $out/nix-support/pivots
    hash=$(basename ${placeholder "out"})
    cat << EOF > $out/bin/binary
      echo "I'm looking at \''${NIXPKGS_PIVOT_DIRS:-nothing}/$hash/something"
    EOF
    chmod +x $out/bin/binary
    touch $out/nix-support/pivots/something
    #echo something > $out/nix-support/pivot
  '';
  system = pkgs.writeScript "system" ''
    echo "Calling binary"
    ${someBinary}/bin/binary
  '';

  /*
     Takes an attribute set of the form
  {
    <pivot type> = <path>;
  }

  and a derivation

  Returns a pivot directory mapping all hashes of the derivation's closure that are pivotable with the given types to their paths
  */
  createPivots = pivots: drv:
    pkgs.stdenvNoCC.mkDerivation {
      name = "pivot-dir";
      __structuredAttrs = true;

      exportReferencesGraph.closure = [drv];

      inherit pivots;

      PATH = pkgs.lib.makeBinPath [pkgs.buildPackages.coreutils pkgs.buildPackages.jq];

      builder = builtins.toFile "builder" ''
        . .attrs.sh

        out=''${outputs[out]}

        mkdir $out

        readarray -t paths < <(jq -r '.closure[].path' .attrs.json)

        shopt -s nullglob
        for path in ''${paths[@]}; do

          for pivot in "$path"/nix-support/pivots/*; do
            pivot=$(basename "$pivot")
            echo "Detected pivot $pivot in $path"
            target=$(jq -r --arg pivot "$pivot" '.pivots."\($pivot)"' .attrs.json)
            mkdir "$out/$(basename "$path")"
            ln -s "$target" "$out/$(basename "$path")/$pivot"
          done

          #if [[ -f "$path"/nix-support/pivot ]]; then
          #  pivot=$(cat "$path"/nix-support/pivot)
          #  echo "Detected pivot $pivot in $path"
          #  target=$(jq -r --arg pivot "$pivot" '.pivots."\($pivot)"' .attrs.json)
          #  ln -s "$target" "$out/$(basename "$path")"
          #fi
        done

        cp .attrs.json $out/attrs.json
      '';
    };

  pivotDir =
    createPivots {
      something = "/etc/ca-bundle.crt";
    }
    system;

  pivotedSystem = pkgs.writeScript "pivot-shell" ''
    NIXPKGS_PIVOT_DIRS="${pivotDir}''${NIXPKGS_PIVOT_DIRS:+:}$NIXPKGS_PIVOT_DIRS" ${system}
  '';
in
  pivotedSystem
