self: super:
let
  overlay = (super.lib.composeOverlays [
   (import ./default.nix).nix-ccc-guibertd
   (self: super: {
     _toolchain = builtins.trace "toolchain: ${super._toolchain}.genji" ("${super._toolchain}.inti");
     aws-sdk-cpp = super.aws-sdk-cpp.overrideAttrs (attrs: {
       doCheck = false;
     });
     boehmgc = super.boehmgc.overrideAttrs (attrs: {
       doCheck = false;
     });
     go_1_10 = super.go_1_10.overrideAttrs (attrs: {
       doCheck = false;
       installPhase = ''
         mkdir -p "$out/bin"
         export GOROOT="$(pwd)/"
         export GOBIN="$out/bin"
         export PATH="$GOBIN:$PATH"
         cd ./src
         ./make.bash
       '';
     });
     go_1_11 = super.go_1_11.overrideAttrs (attrs: {
       doCheck = false;
     });
     jemalloc = super.jemalloc.overrideAttrs (attrs: {
       doCheck = false;
     });
     jemalloc450 = super.jemalloc450.overrideAttrs (attrs: {
       doCheck = false;
     });
     libjpeg_turbo = super.libjpeg_turbo.overrideAttrs (attrs: {
       doCheck = false;
     });
     libuv = super.libuv.overrideAttrs (attrs: {
       doCheck = false;
     });
   })
 ]);
in overlay self super
