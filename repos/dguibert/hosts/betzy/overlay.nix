final: prev:
with final; let
  tryUpstream = drv: attrs:
    builtins.trace "broken upstream ${drv.name}" (drv.overrideAttrs attrs).overrideAttrs (o: {
      isBroken = isBroken drv;
    });
  #if (builtins.tryEval (isBroken drv)).success
  #then (isBroken drv) # should fail and use our override
  #else drv.overrideAttrs attrs;
  dontCheck = drv:
    builtins.trace "don't check ${drv.name}" drv.overrideAttrs (o: {
      doCheck = false;
      doInstallCheck = false;
    });
  upstreamFails = drv:
    builtins.trace "upstream ${drv.name} fails" tryUpstream drv (o: {
      doCheck = false;
      doInstallCheck = false;
    });
in {
  nixStore = builtins.trace "nixStore=/cluster/projects/nn9560k/dguibert/nix" "/cluster/projects/nn9560k/dguibert/nix";

  nixos-option = null;
  nix_2_3 = dontCheck prev.nix_2_3;
  nixStable = dontCheck prev.nixStable;
  nix =
    /*
    tryUpstream
    */
    (dontCheck prev.nix).overrideAttrs (o: {
      patches =
        (o.patches or [])
        ++ [
          #../../pkgs/nix-dont-remove-lustre-xattr.patch
          ../../pkgs/nix-unshare.patch
          #../../pkgs/nix-sqlite-unix-dotfiles-for-nfs.patch
        ];
    });
  fish = upstreamFails prev.fish;

  # '/home_nfs/bguibertd/nix/store/qs8l94570y7mnykssscd4c32xl5ki4gz-openssh-8.8p1.drv'
  # libgpg-error> ./etc/t-argparse.conf:73: error getting current user's name: System error w/o errno
  openssh = dontCheck prev.openssh;

  libgpg-error = dontCheck prev.libgpg-error;

  libuv = dontCheck prev.libuv;
  # test-getaddrinfo
  gnutls = dontCheck prev.gnutls;

  go_bootstrap = dontCheck prev.go_bootstrap;
  # go> --- FAIL: TestCurrent (0.00s)
  # go> --- FAIL: TestLookup (0.00s)
  # go> --- FAIL: TestLookupId (0.00s)
  go_1_16 = dontCheck prev.go_1_16;
  #  prePatch = attrs.prePatch + ''
  #    sed -i '/TestChown/aif true \{ return\; \}' src/os/os_unix_test.go
  #  '';
  #});
  #go_1_15 = tryUpstream prev.go_1_15 (attrs: {
  #  prePatch = attrs.prePatch + ''
  #    sed -i '/TestChown/aif true \{ return\; \}' src/os/os_unix_test.go
  #    sed -i '/TestFileChown/aif true \{ return\; \}' src/os/os_unix_test.go
  #    sed -i '/TestLchown/aif true \{ return\; \}' src/os/os_unix_test.go
  #  '';
  #});
  p11-kit = (dontCheck prev.p11-kit).overrideAttrs (attrs: {
    enableParallelBuilding = false;
  });
  jobs = prev.jobs._override (self:
    with self; {
      #admin_scripts_dir = "/home_nfs/script/admin";
      #scheduler = prev.jobs.scheduler_slurm;
      defaultJob = sbatchJob;
    });

  fetchannex = {
    file ? builtins.baseNameOf url,
    repo ? "${builtins.getEnv "HOME"}/nur-packages/downloads",
    name ? builtins.baseNameOf url,
    recursiveHash ? false,
    sha256,
    url,
  }:
    prev.requireFile {
      inherit name sha256 url;
      hashMode =
        if recursiveHash
        then "recursive"
        else "flat";
      message = ''
        Unfortunately, we cannot download file ${name} automatically.
        either:
          - go to ${url} to download it yourself
          - get it to the git annexed repo ${repo}

        and add it to the Nix store
          nix-store --add-fixed sha256 ${repo}/${name}

      '';
    };
  #slurm = final.slurm_20_11_8;
  libmysqlclient_3_2 = final.mariadb-connector-c_3_2;
  mariadb-connector-c_3_2 = lib.upgradeOverride prev.mariadb-connector-c_3_2 (o: rec {
    version = "3.2.5";
    src = fetchurl {
      url = "https://dlm.mariadb.com/1936363/Connectors/c/connector-c-3.2.5/mariadb-connector-c-3.2.5-src.tar.gz";
      sha256 = "0w0fimdiiqrrm012iflz8l4rnafryq7y0qqijzxn7nwzxhm9jsr9";
    };
  });

  pythonOverrides = prev.lib.composeOverlays [
    (prev.pythonOverrides or (_:_: {}))
    (python-self: python-super: {
      #pyslurm = python-super.pyslurm_20_11_8.override { slurm=final.slurm_20_11_8; };
      annexremote = lib.upgradeOverride python-super.annexremote (o: rec {
        version = "1.6.0";

        # use fetchFromGitHub instead of fetchPypi because the test suite of
        # the package is not included into the PyPI tarball
        src = fetchFromGitHub {
          rev = "v${version}";
          owner = "Lykos153";
          repo = "AnnexRemote";
          sha256 = "sha256-h03gkRAMmOq35zzAq/OuctJwPAbP0Idu4Lmeu0RycDc=";
        };
      });

      #requests-toolbelt = tryUpstream python-super.requests-toolbelt (o: {
      #  doCheck = false;
      #  doInstallCheck=false;
      #});
      brotli = lib.upgradeOverride python-super.brotli (o: rec {
        version = "1.0.9";

        # PyPI doesn't contain tests so let's use GitHub
        src = fetchFromGitHub {
          owner = "google";
          repo = o.pname;
          rev = "v${version}";
          sha256 = "sha256-AnhOM1mtiMf3ryly+jiTYOAGhyDSoDvjC3Fp+F4StEU=";
          # for some reason, the test data isn't captured in releases, force a git checkout
          deepClone = true;
        };
      });

      dnspython = upstreamFails python-super.dnspython;

      trio =
        /*
        tryUpstream
        */
        python-super.trio.overrideAttrs (o: {
          doCheck = false;
          doInstallCheck = false;
        });
    })
  ];

  patchelf = prev.patchelf.overrideAttrs (attrs: {
    configureFlags =
      (attrs.configureFlags or "")
      + lib.optionalString (prev.patchelf.stdenv.hostPlatform.isAarch64) "--with-page-size=65536";
  });
}
