{
  description = "A very basic flake";

  nixConfig.sandbox = "relaxed";

  outputs = {
    self,
    nixpkgs,
  }: let
    #sourceDir = toString (./. + "/src");
    #outputDir = toString (./. + "/out");
    sourceDir = "/tmp/outside-store-src";
    buildDir = "/tmp/outside-store-build";
    outputDir = "/tmp/outside-store-out";
  in {
    packages.x86_64-linux.hello = with (import nixpkgs {system = "x86_64-linux";});
      stdenv.mkDerivation (finalAttrs: {
        # HACK: break the nix sandbox so we can fetch the dependencies. This
        # requires Nix to have `sandbox = relaxed` in its config.
        __noChroot = true;

        pname = "hello";
        version = "2.12.1";

        src = fetchurl {
          url = "mirror://gnu/hello/hello-${finalAttrs.version}.tar.gz";
          sha256 = "sha256-jZkUKv2SV28wsM18tCqNxoCZmLxdYH2Idh9RLibH2yA=";
        };

        preConfigure = ''
          set -x
          whoami
          #  #test -e ${sourceDir} || cp -r . ${sourceDir}
          #  #export sourceRoot=${sourceDir}
          test -d ${outputDir} || mkdir -p ${outputDir}
            ln -sf ${outputDir} $out

          #  # go to new sourceRoot
          #  #cd $sourceRoot
          #set +x
        '';

        doCheck = true;

        #buildInputs = [ autoreconfHook gperf texinfo ];
      });

    packages.x86_64-linux.default = self.packages.x86_64-linux.hello;
  };
}
