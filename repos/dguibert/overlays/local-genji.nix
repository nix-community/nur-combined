self: super:
let
  overlay = (super.lib.composeOverlays [
   (import ./default.nix).nix-home-nfs-robin-ib-bguibertd
   (self: super: {
     _toolchain = builtins.trace "toolchain: ${super._toolchain}.genji" ("${super._toolchain}.genji");
     go_bootstrap = super.go_bootstrap.overrideAttrs (attrs: {
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
     slurm = super.slurm_17_11_5;

     python = super.python.override {
       packageOverrides = python-self: python-super: {
         pyslurm = python-super.pyslurm.overrideAttrs (oldAttrs: rec {
           name = "${oldAttrs.pname}-${version}";
           version = "17.11.12";

           patches = [];

           src = super.fetchFromGitHub {
             repo = "pyslurm";
             owner = "PySlurm";
             # The release tags use - instead of .
             rev = "${builtins.replaceStrings ["."] ["-"] version}";
             sha256 = "01xdx2v3w8i3bilyfkk50f786fq60938ikqp2ls2kf3j218xyxmz";
           };

         });
       };
     };
     jobs = super.jobs.override {
       admin_scripts_dir = "/home_nfs/script/admin";
       scheduler = super.jobs.scheduler_slurm;
     };
  })
  ]);
in overlay self super
