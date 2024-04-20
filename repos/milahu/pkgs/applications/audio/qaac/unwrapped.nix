# based on https://aur.archlinux.org/packages/qaac-wine

{ lib
, stdenvNoCC
, fetchurl
, unzip
, p7zip
, wine64
, bintools
}:

stdenvNoCC.mkDerivation rec {
  pname = "qaac-unwrapped";
  version = "2.82";

  src = fetchurl {
    url = "https://github.com/nu774/qaac/releases/download/v${version}/qaac_${version}.zip";
    hash = "sha256-9Zi+HMpzB6EKHSPcjoHeXBfSkwVwPs2g/+YtZIKPobQ=";
  };

  src-itunes = fetchurl {
    name = "iTunes64Setup.exe";
    # curl -s -I https://www.apple.com/itunes/download/win64 | grep ^location
    url = "https://secure-appldnld.apple.com/itunes12/042-92440-20231213-DDE54149-6537-4DB9-97D6-69413CD6CF86/iTunes64Setup.exe";
    hash = "sha256-VBwwstcnBa/nVkn5fj2vZ3uFdubnPW949yZaDe1hAR8=";
  };

  # use cache to build faster: 30 seconds versus 150 seconds
  # TODO update
  src_itunes_dll_cache =
  #if true then "" else # uncomment this line to ignore cache
  ''
    fil84AEB850B33D669F6CF5102EB0C4C575 ASL.dll
    fil40BDB85D846A9E26183C1B4897E354B6 CoreAudioToolbox.dll
    filA069D5D000A020343C6E7AB6FF3C4039 CoreFoundation.dll
    fil501C29C9A9E8877F7F0E1684A2302DE7 icudt62.dll
    fil7C581B08BA4DCF9C9D6CE8C73004B1D3 libdispatch.dll
    fil91A06D0D13828CCF3AACE9DE43D98C10 libicuin.dll
    fil6F17A3C1846C9728E043CA9170A2DE47 libicuuc.dll
    fil31C8F76E8C290A62E9C9587D6CC5E55F objc.dll
  '';

  # note: glob pattern icudt*.dll. example: icudt62.dll
  src_itunes_dll_files = "ASL.dll CoreAudioToolbox.dll CoreFoundation.dll icudt*.dll libdispatch.dll libicuin.dll libicuuc.dll objc.dll";

  src-flac = fetchurl {
    url = "https://github.com/xiph/flac/releases/download/1.4.3/flac-1.4.3-win.zip";
    hash = "sha256-xFWM95/BNl0YIveUWiC9v1X5lkLO6VqCPUTzph+3SMY=";
  };

  nativeBuildInputs = [
    unzip
    p7zip
    bintools # objdump
  ];

  postUnpack = ''
    pushd $sourceRoot >/dev/null

    mkdir itunes
    cd itunes

    7z x ${src-itunes} -- iTunes64.msi

    if [ -n "$src_itunes_dll_cache" ]; then

      echo "using src_itunes_dll_cache:"
      echo "$src_itunes_dll_cache" | sort -k2

      src_list=""
      while read src dst; do
        [ -z "$src" ] && continue
        src_list+=" $src"
      done <<< "$src_itunes_dll_cache"

      7z x iTunes64.msi -- $src_list
      rm iTunes64.msi

      while read src dst; do
        [ -z "$src" ] && continue
        mv -v $src $dst
      done <<< "$src_itunes_dll_cache"

    else

      src_itunes_dll_cache=""

      7z x iTunes64.msi -- "fil*"
      #7z x iTunes64.msi -- fil31C8F76E8C290A62E9C9587D6CC5E55F # debug
      rm iTunes64.msi

      extract_filename() {
        if [ "$(head -c 2 "$1" | tr -d '\0')" == "MZ" ]; then
          local t=$(LC_ALL=C objdump -p "$1" 2>/dev/null | grep 'The Export Tables' -A 10 || true)
          if [ -n "$t" ]; then
            echo "$t" | awk '$1 == "Name" { print $3 }'
          fi
        fi
      }

      # convert glob pattern to regex pattern
      filename_pattern=$(echo "$src_itunes_dll_files" | sed 's/ /|/g; s/\./\\./g; s/\*/.*/g ')
      echo "filename_pattern: $filename_pattern"

      for f in fil*; do
        filename=$(extract_filename "$f")
        if echo "$filename" | grep -q -E "$filename_pattern"; then
          mv -v "$f" "$filename"
          src_itunes_dll_cache+="$f $filename"$'\n'
          continue
        fi
        rm "$f"
      done

      echo "TODO update src_itunes_dll_cache:"
      echo "$src_itunes_dll_cache" | sort -k2

    fi

    cd ..

    mkdir flac
    cd flac
    unzip ${src-flac}
    mv -v flac-*-win/Win64/libFLAC.dll .
    rm -rf flac-*-win
    cd ..

    popd >/dev/null
  '';

  installPhase = ''
    mkdir -p $out/opt
    cp -r x64 $out/opt/qaac

    cd itunes
    cp -t $out/opt/qaac $src_itunes_dll_files
    cd ..

    cd flac
    cp -t $out/opt/qaac libFLAC.dll
    cd ..

    chmod -x $out/opt/qaac/*

    # create wrappers
    mkdir -p $out/bin
    for bin in qaac refalac; do
    cat >$out/bin/$bin <<EOF
    #!/bin/sh
    # parse args
    show_help=false
    [ \$# == 0 ] && show_help=true
    for a in "\$@"; do
      case "\$a" in
        -h|--help)
          show_help=true
        ;;
      esac
    done
    if \$show_help && [ "\$QAAC_SHOW_REAL_HELP" != 1 ]; then
      # show cached help text. this is terribly slow with wine
      cat $out/share/doc/qaac/$bin.txt
      exit 1
    fi
    # disable wine error messages by default
    export WINEDEBUG="\''${WINEDEBUG:=-all}"
    # disable wine GUI
    unset DISPLAY
    # use a separate wine prefix
    export WINEPREFIX="\''${WINEPREFIX:=\$HOME/.cache/qaac/wine}"
    # make it work in bubblewrap
    # fix: wine: could not load ntdll.so
    # https://unix.stackexchange.com/a/670754/295986
    export WINEDLLPATH=${wine64}/lib/wine/x86_64-unix
    exec ${wine64}/bin/wine64 $out/opt/qaac/''${bin}64.exe "\$@"
    EOF
    chmod +x $out/bin/$bin
    done

    # cache help texts. these are terribly slow with wine
    mkdir -p $out/share/doc/qaac
    mkdir -p $TMP/.cache/qaac/wine # fix: wine: chdir: No such file or directory
    for bin in qaac refalac; do
      echo writing $out/share/doc/qaac/$bin.txt
      HOME=$TMP \
      QAAC_SHOW_REAL_HELP=1 \
      $out/bin/$bin --help >$out/share/doc/qaac/$bin.txt || true
    done
    rm -rf $TMP/.cache/qaac
  '';

  meta = with lib; {
    description = "CLI QuickTime AAC/ALAC encoder [binary build]";
    homepage = "https://github.com/nu774/qaac";
    # https://github.com/nu774/qaac/raw/master/COPYING
    license = licenses.unfree; # FIXME: nix-init did not found a license
    maintainers = with maintainers; [ ];
    mainProgram = "qaac";
    platforms = platforms.all;
  };
}
