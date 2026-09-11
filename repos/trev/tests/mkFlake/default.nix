{
  pkgs,
  self,
}:

let
  fixture = self.libs.mkFlake (
    _system: fixturePkgs: {
      packages = {
        inherit (fixturePkgs) fmt hello libiconv;
        fix-hash = fixturePkgs.fix-hash;
      };
    }
  );
  packages = fixture.packages.x86_64-linux;
  target = "arm64-apple-darwin";

  checkMachO =
    name: file:
    pkgs.runCommand name
      {
        nativeBuildInputs = [ pkgs.file ];
      }
      ''
        description=$(file -L ${file})
        case "$description" in
          *"Mach-O 64-bit arm64"*) ;;
          *)
            echo "unexpected file type: $description" >&2
            exit 1
            ;;
        esac
        touch $out
      '';
in
{
  mkFlake-darwin-structure =
    assert builtins.hasAttr target packages.hello;
    pkgs.runCommand "mkFlake-darwin-structure" { } ''
      touch $out
    '';

  mkFlake-darwin-c = checkMachO "mkFlake-darwin-c" "${packages.hello.${target}}/bin/hello";

  mkFlake-darwin-install-name-tool =
    let
      libiconv = packages.libiconv.${target};
      bintools = packages.hello.${target}.stdenv.cc.bintools.bintools;
    in
    pkgs.runCommand "mkFlake-darwin-install-name-tool"
      {
        nativeBuildInputs = [ pkgs.llvmPackages_21.llvm ];
      }
      ''
        cp ${libiconv}/lib/libiconv.2.dylib libiconv.dylib
        chmod u+w libiconv.dylib
        ln -s libiconv.dylib libiconv-link.dylib

        ${bintools}/bin/${target}-install_name_tool libiconv-link.dylib \
          -add_rpath /build/source/build

        original_commands=$(llvm-otool -l libiconv.dylib)
        grep -F "path /build/source/build" <<< "$original_commands"
        grep -A 3 -F "cmd LC_REEXPORT_DYLIB" <<< "$original_commands" \
          | grep -F "name ${libiconv}/lib/libcharset.1.dylib"

        cp libiconv.dylib duplicate-rpath.dylib
        cp libiconv.dylib overlapping-rpaths.dylib

        ${bintools}/bin/${target}-install_name_tool libiconv-link.dylib \
          -delete_rpath /build/source/build \
          -id /tmp/libiconv.dylib \
          -change ${libiconv}/lib/libcharset.1.dylib /tmp/libcharset.dylib

        test -L libiconv-link.dylib
        commands=$(llvm-otool -l libiconv.dylib)
        grep -F "name /tmp/libiconv.dylib" <<< "$commands"
        grep -F "name /tmp/libcharset.dylib" <<< "$commands"
        if grep -F "/build/source/build" <<< "$commands"; then
          exit 1
        fi

        cp ${libiconv}/lib/libiconv.2.dylib missing-rpath.dylib
        chmod u+w missing-rpath.dylib
        if ${bintools}/bin/${target}-install_name_tool missing-rpath.dylib \
          -delete_rpath /missing \
          -change ${libiconv}/lib/libcharset.1.dylib /tmp/libcharset.dylib \
          2>missing-rpath.err
        then
          echo "deleting a missing rpath unexpectedly succeeded" >&2
          exit 1
        fi
        grep -F "no LC_RPATH load command with path: /missing" missing-rpath.err

        chmod u+w duplicate-rpath.dylib
        if ${bintools}/bin/${target}-install_name_tool duplicate-rpath.dylib \
          -add_rpath /build/source/build \
          -change ${libiconv}/lib/libcharset.1.dylib /tmp/libcharset.dylib \
          2>duplicate-rpath.err
        then
          echo "adding a duplicate rpath unexpectedly succeeded" >&2
          exit 1
        fi
        grep -F "LC_RPATH load command already exists: /build/source/build" duplicate-rpath.err

        chmod u+w overlapping-rpaths.dylib
        if ${bintools}/bin/${target}-install_name_tool overlapping-rpaths.dylib \
          -rpath /build/source/build /middle \
          -rpath /middle /final \
          -change ${libiconv}/lib/libcharset.1.dylib /tmp/libcharset.dylib \
          2>overlapping-rpaths.err
        then
          echo "overlapping rpath changes unexpectedly succeeded" >&2
          exit 1
        fi
        grep -F "overlapping -rpath operations" overlapping-rpaths.err

        touch $out
      '';

  mkFlake-darwin-cxx = checkMachO "mkFlake-darwin-cxx" "${packages.fmt.${target}}/lib/libfmt.dylib";
  mkFlake-darwin-rust = checkMachO "mkFlake-darwin-rust" "${packages.fix-hash.${target}}/bin/fix-hash";
}
