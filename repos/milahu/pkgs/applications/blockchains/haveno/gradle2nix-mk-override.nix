{
  lib,
  stdenvNoCC,
  autoPatchelfHook,
  jdk,
}:

let
  mkOverride = src: args: stdenvNoCC.mkDerivation ({
    name = src.name;
    nativeBuildInputs = [
      autoPatchelfHook
      #zip
      jdk
    ];
    dontAutoPatchelf = true;
    unpackPhase = ''
      ext=''${name##*.}
      runHook preUnpack
      sourceRoot=source
      mkdir $sourceRoot
      cd $sourceRoot
      libs=(${if (args.libs or []) == false then "" else lib.escapeShellArgs (args.libs or [])})
      doLibs=${if (args.libs or []) == false then "false" else "true"}
      bins=(${if (args.bins or []) == false then "" else lib.escapeShellArgs (args.bins or [])})
      archives=(${if (args.archives or []) == false then "" else lib.escapeShellArgs (args.archives or [])})
      doArchives=${if (args.archives or []) == false then "false" else "true"}
      archive_libs=()
      archive_bins=()
      if [ "$ext" = jar ]; then
        #echo name $name; echo src ${src}; echo src_nix ${src}; exit 1
        #unzip ${src}
        echo "unpacking ${src}"
        if $doLibs && [ ''${#libs[@]} == 0 ]; then
          while IFS= read -r lib; do
            libs+=("$lib")
          done < <(jar tf ${src} | grep '\.so$')
        fi
        if $doArchives && [ ''${#archives[@]} == 0 ]; then
          while IFS= read -r archive; do
            archives+=("$archive")
          # TODO more archive types
          done < <(jar tf ${src} | grep -E '\.(tar(\.(xz|gz|bz|bz2))?|zip)$')
        fi
        jar xf ${src} ''${libs[@]} ''${bins[@]} ''${archives[@]}
        idx=0
        for archive in ''${archives[@]}; do
          echo "unpacking $archive"
          archive_file="''${archive##*/}"
          archive_file="$TMP/temp_''${archive_file: -100}"
          mv "$archive" "$archive_file"
          archive_dir="$archive"
          mkdir "$archive_dir"
          # TODO more archive types
          # TODO generic unpack: zip, 7z, ...
          tar xf "$archive_file" -C "$archive_dir"
          rm "$archive_file"
          while IFS= read -r lib; do
            archive_libs+=("$lib")
          done < <(find "$archive_dir" -name '*.so*' -not -type d)
          while IFS= read -r bin; do
            archive_bins+=("$bin")
          done < <(find "$archive_dir" -executable -not -type d -not -name '*.so*')
        done
      elif [ "$ext" = exe ]; then
        cp ${src} $name
        chmod +w $name
      fi
      cd $NIX_BUILD_TOP
      runHook postUnpack
    '';
    buildPhase = ''
      runHook preBuild
      unpinLibs=$(
        for lib_out in ${lib.escapeShellArgs (args.unpinLibs or [])}; do
          #echo "lib_out $lib_out" >&2 # debug
          for lib in $lib_out/lib/*.so*; do
            # echo "lib_out lib $lib" >&2 # debug
            lib=''${lib##*/}
            lib=''${lib%.so*}.so
            echo "$lib"
          done
        done | sort -u
      )
      # echo unpinLibs: $unpinLibs # debug
      if [ "$ext" = jar ]; then
        # unpin libs
        echo "unpinning libs"
        for lib in "''${libs[@]}" "''${archive_libs[@]}"; do
          echo "$lib: unpinning"
          args=(patchelf)
          for dep in $(patchelf --print-needed $lib); do
            unp=''${dep%.so*}.so
            if echo "$unpinLibs" | grep -q -m1 -x -F "$unp"; then
              args+=(--replace-needed "$dep" "$unp")
              echo "$lib: unpinning $dep to $unp"
            fi
          done
          "''${args[@]}" "$lib"
        done
        # "autoPatchelf ." also adds rpaths under /build/source (bundled libraries)
        # but /build/source is not available on runtime
        # "autoPatchelf $f" uses only rpaths from /nix/store
        autoPatchelf .
        # use relative rpaths for bundled libraries
        while read -r f; do
          #echo "debug: rpath f = $f"
          #ldd "$f"
          #autoPatchelf "$f"
          rp="$(patchelf --print-rpath "$f")"
          [ -z "$rp" ] && continue
          fdir="$(realpath "$(dirname "$f")")"
          #echo "debug: rpath fdir = $fdir"
          rp2=""
          while read -r p; do
            #echo "debug: rpath p = $p"
            prel="$(realpath --relative-base="$fdir" "$p")"
            echo "debug: rpath prel = $prel"
            # '$ORIGIN' is the binary's dirname
            if [ "$p" = "$prel" ]; then
              rp2+="$p:"
            elif [ "$prel" = "." ]; then
              rp2+="\$ORIGIN:"
            else
              rp2+="\$ORIGIN/$prel:"
            fi
          done < <(echo "$rp" | tr : $'\n')
          rp2="''${rp2:0: -1}" # remove trailing :
          if [ "$rp" != "$rp2" ]; then
            echo "$f: setting relative rpath $rp2"
            #echo "  rpath 1 = $rp"
            #echo "  rpath 2 = $rp2"
            patchelf --set-rpath "$rp2" "$f"
          fi
          #ldd "$f"
        done < <(find . -type f -executable)
      elif [ "$ext" = exe ]; then
        chmod +x $name
        autoPatchelf $name
      fi
      runHook postBuild
    '';
    installPhase = ''
      runHook preInstall
      if [ "$ext" = jar ]; then
        cp ${src} $out
        chmod +w $out
        for archive in ''${archives[@]}; do
          echo "packing $archive"
          archive_dir="$archive"
          archive_file="$TMP/temp.tar"
          pushd "$archive_dir" >/dev/null
          case "$archive" in
            *.tar.gz|*.tar.xz|*.tar.bz|*.tar.bz2)
              tar cf "$archive_file" .
            ;;
            *)
              echo "FIXME internal error: unhandled archive type $archive"
              exit 1
            ;;
          esac
          popd >/dev/null
          # dont use "tar cJf" as that is slooow
          # use minimal compression to make this fast
          case "$archive" in
            *.tar.gz) gzip -1 "$archive_file"; archive_file+=".gz";;
            *.tar.xz) xz -1 "$archive_file"; archive_file+=".xz";;
            *.tar.bz2) bzip2 -1 "$archive_file"; archive_file+=".bz2";;
            # TODO more archive types
            *)
              echo "FIXME internal error: unhandled archive type $archive"
              exit 1
            ;;
          esac
          stat "$archive_file" || true
          stat "$archive_dir" || true
          rm -rf "$archive_dir"
          # FIXME mv: cannot move '/build/temp.tar.xz' to 'native/linux/x64/tor.tar.xz': No such file or directory
          mv "$archive_file" "$archive"
        done
        jar uf $out ''${libs[@]} ''${bins[@]} ''${archives[@]}
      elif [ "$ext" = exe ]; then
        cp $name $out
      fi
      runHook postInstall
    '';
  } // (builtins.removeAttrs args [ "libs" "bins" "unpinLibs" "archives" ]));
in
mkOverride
