final: prev:
with final; let
in
  builtins.trace "spartan overlay" {
    #nixStore = builtins.trace "nixStore=/home_nfs_robin_ib/bguibertd/nix" "/home_nfs_robin_ib/bguibertd/nix";
    #nixStore = builtins.trace "nixStore=/home_nfs/bguibertd/nix" "/home_nfs/bguibertd/nix";
    nixStore = builtins.trace "nixStore=/scratch_na/users/bguibertd/nix" "/scratch_na/users/bguibertd/nix";

    pythonOverrides = prev.lib.composeOverlays [
      (prev.pythonOverrides or (_:_: {}))
      (python-self: python-super: {
        flask-limiter = lib.upgradeOverride python-super.flask-limiter (o: rec {
          version = "2.6.2";

          src = fetchFromGitHub {
            owner = "alisaifee";
            repo = "flask-limiter";
            rev = version;
            sha256 = "sha256-eWOdJ7m3cY08ASN/X+7ILJK99iLJJwCY8294fwJiDew=";
          };
        });
        annexremote = lib.narHash python-super.annexremote "1.6.0" "sha256-h03gkRAMmOq35zzAq/OuctJwPAbP0Idu4Lmeu0RycDc";
        #annexremote = lib.upgradeOverride python-super.annexremote (o: rec {
        #  version = "1.6.0";

        #  # use fetchFromGitHub instead of fetchPypi because the test suite of
        #  # the package is not included into the PyPI tarball
        #  src = fetchFromGitHub {
        #    rev = "v${version}";
        #    owner = "Lykos153";
        #    repo = "AnnexRemote";
        #    sha256 = "sha256-h03gkRAMmOq35zzAq/OuctJwPAbP0Idu4Lmeu0RycDc=";
        #  };

        #});
      })
    ];

    #datalad = lib.upgradeOverride prev.datalad (o: rec {
    #  version = "0.16.5";
    #  src = fetchFromGitHub {
    #    owner = "datalad";
    #    repo = "datalad";
    #    rev = "refs/tags/${version}";
    #    sha256 = "sha256-F5UFW0/XqntrHclpj3TqoAwuHJbiiv5a7/4MnFoJ1dE=";
    #  };
    #});
  }
