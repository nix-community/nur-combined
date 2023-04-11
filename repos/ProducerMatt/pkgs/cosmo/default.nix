{ lib,
  fetchFromGitHub,
  stdenv,
  linuxOnly ? true,
  buildMode ? "rel",
  limitOutputs ? false # defaults to all
}:

# TODO(ProducerMatt): verify executable's license block against a checksum for
# automated CYA. One possible route:
#
# $ readelf -a o//tool/build/pledge.com.dbg |\
#    grep kLegalNotices |\
#    awk '{print $2}'
#
# Gets the hex address of where the licenses start. From there it's a double-nul
# terminated list of strings.


let
  commonMeta = rec {
    name = "cosmopolitan";
    version = "2023-03-19";
    rev = "893703a07b1590c02c84a5b02bb4968e4f03522a";
    changelog = "https://github.com/jart/cosmopolitan/commits/${rev}";
  };

  cosmoMeta = {
    mode = buildMode;
    outputs =
      {
        pledge = {
          coms = [
            "tool/build/pledge.com"
            "tool/build/unveil.com"
          ];
        };
        pkzip = {
          coms = [
            "third_party/zip/zip.com"
          ];
        };
      };
    make = "make";
    #make = "./build/bootstrap/make.com";
    platformFlag =
      if linuxOnly
        then "CPPFLAGS=-DSUPPORT_VECTOR=1"
        else "";
    # NOTE(ProducerMatt): since Nix builds will all be on Linux,
    # might as well target Linux exclusively.
  };
  cosmoSrc = fetchFromGitHub {
    owner = "jart";
    repo = "cosmopolitan";
    rev = commonMeta.rev;
    hash = "sha256-QvS3g6vPhJPWwBSNbvGMGKL7kaXQqZlnZrW2W3kv27M=";
  };
  wantedOutputs =
    # make list of all outputs to build. If given a bad name in
    # limitOutputs this should fail at getAttr.
    # If it doesn't send flamemail to ProducerMatt
    (if limitOutputs
     then builtins.listToAttrs
       (map (name: lib.nameValuePair
         name (builtins.getAttr name cosmoMeta.outputs))
         limitOutputs)
     else cosmoMeta.outputs);
    # TODO: find a less awkward way to structure outputs.
  wantedComs =
    # wanted outputs but just a list of com files.
    builtins.concatLists
      (lib.catAttrs "coms" (builtins.attrValues wantedOutputs));
  buildTargets =
    (lib.concatMapStringsSep " "
        (target: "o/${cosmoMeta.mode}/${target}")
        wantedComs);
  buildStuff = ''
      ${cosmoMeta.make} MODE=${cosmoMeta.mode} -j$NIX_BUILD_CORES \
          ${cosmoMeta.platformFlag} V=0 \
      ''
    + buildTargets + "; echo ${buildTargets}";
  installStuff =
    (lib.concatStringsSep "\n"
      (lib.flatten [
        (map (name: "mkdir -p ${"$" + name}/bin")
          (builtins.attrNames wantedOutputs))
        (lib.mapAttrsToList (name: value:
          (map (target:
            ## strip APE header. Only used if building cross-platform
            ## but only using on ELF (may solve execution issues)
            #"o/${cosmoMeta.mode}/${target} --assimilate" + "\n" +
            "echo ${target}; cp o/${cosmoMeta.mode}/${target} ${"$" + name}/bin/")
            value.coms))
          wantedOutputs)
        "mkdir -p $out/bin \n"
      ]));
  symlinkStuff = lib.concatMapStringsSep "\n"
    (name: "echo ${name}; ls -1N --zero ${"$" + name}/bin/ | xargs -0 -I'{}' realpath -smz '{}' | xargs -0 -I'{}' ln -s '{}' $out/bin/")
    (builtins.attrNames wantedOutputs);
in
stdenv.mkDerivation {
    pname = commonMeta.name;
    version = commonMeta.version;
    phases = [ "unpackPhase" "buildPhase" "installPhase" ];

    outputs = [ "out" ] ++ (builtins.attrNames cosmoMeta.outputs);

    src = cosmoSrc;
    buildPhase = ''
      sh ./build/bootstrap/compile.com --assimilate
      sh ./build/bootstrap/cocmd.com --assimilate
      sh ./build/bootstrap/echo.com --assimilate
      sh ./build/bootstrap/rm.com --assimilate
      '' + buildStuff + ''
      echo "" # workaround for nix's "malformed json" errors
    '';
    installPhase = installStuff + "\n" + symlinkStuff;

    meta = {
      homepage = "https://github.com/jart/cosmopolitan";
      description = "Selected programs from the CosmopolitanC monorepo";
      platforms = [ "x86_64-linux" ];
      changelog = commonMeta.changelog;

      # NOTE(ProducerMatt): Cosmo embeds relevant licenses near the top of the
      # executable. You can manually inspect by viewing the binary with `less`.
      # Grep for "Copyright".
      #
      # At the time of this writing in MODE=rel: ISC for Cosmo, BSD3 for getopt,
      # zlib for puff, Apache-2.0 for Google's NSYNC.
      license = with lib.licenses; [ isc asl20 bsd3 zlib ];

      maintainers = [ lib.maintainers.ProducerMatt ];
      broken = true; #FIXME
    };
}

# NOTE(ProducerMatt): Landlock Make is currently unhappy with the Nix build
# environment. For this reason we use the stdenv make, which is slower and
# theoretically less secure. When landlock is working add this back to the
# build And set $cosmoMeta.make to "o/optlinux/third_party/make/make.com"
#
#      ./build/bootstrap/make.com --assimilate
#
#      # build ape headers
#      ./build/bootstrap/make.com -j$NIX_BUILD_CORES \
#         ${cosmoMeta.platformFlag} o//ape o//libc
#
#      # build optimized make
#      ./build/bootstrap/make.com -j$NIX_BUILD_CORES \
#          ${cosmoMeta.platformFlag} V=0 \
#          MODE=optlinux ${cosmoMeta.make}
