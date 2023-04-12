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
    version = "2023-04-04";
    rev = "12e07798df6b96167bcd4ed6b433dc26be701f0d";
    changelog = "https://github.com/jart/cosmopolitan/commits/${rev}";
  };

  cosmoMeta = {
    mode = buildMode;

    outputs =
      # add new apps here. Each top-level attribute name
      # becomes a new package output.
      with lib.licenses; {
      # NOTE(ProducerMatt): Cosmo embeds relevant licenses near the top of the
      # executable. You can manually inspect by viewing the binary with `less`.
      # Grep for "Copyright".
        pledge = {
          coms = [
            "tool/build/pledge.com"
            "tool/build/unveil.com"
          ];
          licenses = [ asl20 bsd3 zlib ];
        };
        pkzip = {
          coms = [
            "third_party/zip/zip.com"
            "third_party/unzip/unzip.com"
          ];
          licenses = [ asl20 bsd3 mit zlib isc ];
        };
        printimage = {
          coms = [
            "tool/viz/printimage.com"
          ];
          licenses = [ asl20 bsd3 mit zlib isc ];
        };
        printvideo = {
          coms = [
            "tool/viz/printvideo.com"
          ];
          licenses = [ asl20 bsd3 mit zlib isc ];
        };
        lambda = {
          coms = [
            "tool/lambda/asc2bin.com"
            "tool/lambda/blcdump.com"
            "tool/lambda/bru2bin.com"
            "tool/lambda/lam2bin.com"
            "tool/lambda/lambda.com"
            "tool/lambda/tromp.com"
          ];
          licenses = [ asl20 bsd3 isc mit ];
        };
        blinkenlights = {
          coms = [
            "tool/build/blinkenlights.com"
          ];
          licenses = [ asl20 bsd3 mit zlib isc ];
          # Using "MIT" license in place of fdlibm license
          # https://lists.fedoraproject.org/pipermail/legal/2013-December/002346.html
        };
        ttyinfo = {
          coms = [
            "examples/ttyinfo.com"
          ];
          licenses = [ asl20 bsd3 mit zlib isc ];
          # Using "MIT" license in place of fdlibm license
        };
        life = {
          coms = [
            "examples/life.com"
          ];
          licenses = [ asl20 bsd3 mit zlib isc ];
          # Using "MIT" license in place of fdlibm license
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
    hash = "sha256-ZX3MJTz7HX70ZAVBGRBs/0Kw8fPzjye25VcC09ER3eA=";
  };
  wantedOutputs =
    # make attrs of all outputs to build. If given a bad name in
    # limitOutputs this should fail at getAttr.
    # If it doesn't send flamemail to ProducerMatt
    (if limitOutputs
     then builtins.listToAttrs
       (map (name: lib.nameValuePair
         name (builtins.getAttr name cosmoMeta.outputs))
         limitOutputs)
     else cosmoMeta.outputs);
    # TODO: find a less awkward way to structure outputs.
  wantedOutputNames =
    builtins.attrNames wantedOutputs;
  wantedComs =
    # wanted outputs but just a list of com files.
    builtins.concatLists
      (lib.catAttrs "coms" (builtins.attrValues wantedOutputs));
  buildTargets =
    (lib.concatMapStringsSep " "
        (target: "o/${cosmoMeta.mode}/${target}")
        wantedComs);
  relevantLicenses =
    builtins.concatMap (o: o.licenses) (builtins.attrValues wantedOutputs);
  buildStuff = ''
      ${cosmoMeta.make} MODE=${cosmoMeta.mode} -j$NIX_BUILD_CORES \
          ${cosmoMeta.platformFlag} V=0 \
      ''
    + buildTargets + "\n";
  installStuff =
    (lib.concatStringsSep "\n"
      (lib.flatten [
        (map (name: "mkdir -p ${"$" + name}/bin")
          wantedOutputNames)
        (lib.mapAttrsToList (name: value:
          (map (target:
            ## strip APE header. Only used if building cross-platform
            ## but only using on ELF (may solve execution issues)
            #"o/${cosmoMeta.mode}/${target} --assimilate" + "\n" +
            "cp o/${cosmoMeta.mode}/${target} ${"$" + name}/bin/")
            value.coms))
          wantedOutputs)
        "mkdir -p $out/bin \n"
      ]));
  symlinkStuff = lib.concatMapStringsSep "\n"
    (name: "ls -1N --zero ${"$" + name}/bin | xargs -0 -I'{}' realpath -sez ${"$" + name}/bin/'{}' | xargs -0 -I'{}' ln -s '{}' $out/bin/")
    wantedOutputNames;
    #spot the mistake!
    #(name: "ls -1N --zero ${"$" + name}/bin | xargs -0 -I'{}' realpath -smz '{}' | xargs -0 -I'{}' ln -s '{}' $out/bin/")
in
stdenv.mkDerivation {
    pname = commonMeta.name;
    version = commonMeta.version;
    phases = [ "unpackPhase" "buildPhase" "installPhase" ];

    outputs = [ "out" ] ++ wantedOutputNames;

    src = cosmoSrc;
    buildPhase = ''
      sh ./build/bootstrap/compile.com --assimilate
      sh ./build/bootstrap/cocmd.com --assimilate
      sh ./build/bootstrap/echo.com --assimilate
      sh ./build/bootstrap/rm.com --assimilate
      '' + buildStuff + ''
      echo "" # workaround for nix's "malformed json" errors
    '';
    installPhase = installStuff
                 + "\n" + symlinkStuff;

    meta = {
      homepage = "https://github.com/jart/cosmopolitan";
      description = "Selected programs from the CosmopolitanC monorepo";
      platforms = [ "x86_64-linux" ];
      changelog = commonMeta.changelog;

      # All Cosmo original code under ISC license.
      license = with lib.licenses; lib.unique ([ isc ] ++ relevantLicenses);
      maintainers = [ lib.maintainers.ProducerMatt ];
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
