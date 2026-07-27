{
  self,
  lib,
  path,
  system,
  script-directory-wrapper,
  dockerTools,
  cacert,
  gawk,
  gnugrep,
  gnused,
  gnutar,
  gzip,
  which,
  curl,
  vim,
  less,
  wget,
  man,
  findutils,
  bashInteractive,
  coreutils-full,
  ncurses,
  nix,
  unstable,
  callPackage,
}:

let
  containerConf =
    {
      name,
      extraCommands ? "",
      tag ? self.shortRev or self.dirtyShortRev,
      user ? "lucasew",
      contents ? [ ],
      interactive ? false,
      withNix ? false,
      ...
    }@args:
    let
      args' = builtins.removeAttrs args [
        "interactive"
        "withNix"
        "overrideDerivation"
        "override"
      ];
    in
    unstable.dockerTools.streamLayeredImage (
      args'
      // {
        inherit name tag;
        maxLayers = 2;

        contents =
          [
            dockerTools.binSh
            (dockerTools.fakeNss.override {
              extraPasswdLines =
                [ "${user}:x:1000:1000:new ${user}:/state:/bin/bash" ]
                ++ lib.optionals withNix (
                  lib.genList (
                    i:
                    "nixbld${toString (i + 1)}:x:${toString (i + 30001)}:30000::/var/empty:/run/current-system/sw/bin/nologin"
                  ) 32
                );
              extraGroupLines =
                [ "${user}:x:1000:" ]
                ++ lib.optional withNix "nixbld:x:30000:${
                  lib.concatStringsSep "," (lib.genList (i: "nixbld${toString (i + 1)}") 32)
                }";
            })
            dockerTools.usrBinEnv
            dockerTools.caCertificates
            coreutils-full
          ]
          ++ lib.optionals interactive [
            vim
            gawk
            gnutar
            gzip
            which
            curl
            less
            wget
            man
            findutils
            bashInteractive
            gnugrep
            gnused
            ncurses
          ]
          ++ lib.optionals withNix [ nix ]
          ++ contents;

        fakeRootCommands =
          ''
            mkdir -m 777 -p tmp etc dev dev/shm state code
            chmod 777 tmp etc dev dev/shm state code # single user anyway
            ln -s ${self} etc/.dotfiles
            ${extraCommands}
          ''
          + lib.optionalString withNix "chmod 755 -R nix/var && chown -R 1000:1000 nix";

        enableFakechroot = true;

        uid = 1000;
        gid = 1000;
        uname = user;
        gname = user;

        includeNixDB = withNix;

        config = {
          Entrypoint = [
            (lib.getExe script-directory-wrapper)
            "source_me"
          ];
          User = user;
          Env = [
            "SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt"
            "HOME=/state"
            "TEMPDIR=/tmp"
            "TMPDIR=/tmp"
            "LANGUAGE=en_US"
            "UID=1000"
            "GID=1000"
            "TZ=UTC"
            "NIX_PATH=nixpkgs=${self.inputs.nixpkgs}"
          ];
        };
      }
    );
in
builtins.mapAttrs (
  k: v: if v == "directory" then containerConf ({ name = k; } // (callPackage (./${k}) { })) else null
) (builtins.readDir ./.)
