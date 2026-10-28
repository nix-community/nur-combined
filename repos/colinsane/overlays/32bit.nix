# XXX(2026-10-18): this largely exists to support the x86_86 `steam` package.
# steam requires OS-supplied 32-bit libraries (in addition to 64-bit libs).
#
# a large number of pkgsi686Linux failures are attributable to /nix/var/nix/b having inodes > 2**32; an impurity not reproducible for cache.nixos.org.
# - see: <https://github.com/NixOS/nixpkgs/pull/578642>
#   - previously: <https://github.com/NixOS/nixpkgs/pull/420063>
# - see: <https://github.com/NixOS/nixpkgs/issues/24016>
self: super: {
  stdenv = super.overrideMkDerivationArgs
    (args: {
      env = (args.env or { }) // {
        # -D_FILE_OFFSET_BITS=64 is the important one here.
        # -D_LARGEFILE_SOURCE may or may not make any difference.
        NIX_CFLAGS_COMPILE_BEFORE = (args.env.NIX_CFLAGS_COMPILE_BEFORE or "")
          # + " -D_LARGEFILE_SOURCE"
          + " -D_FILE_OFFSET_BITS=64"
          ;
      };
    })
    super.stdenv;
  # stdenv = super.withCFlags [ "-D_FILE_OFFSET_BITS=64" ] super.stdenv;

  # git = super.git.overrideAttrs {
  #   doCheck = false;
  # };
  git = super.git.override {
    doInstallCheck = false;
  };

  # gitMinimal = super.gitMinimal.overrideAttrs {
  #   doCheck = false;
  # };

  # glibc = super.glibc.override { inherit (super) stdenv; };

  ispc = super.ispc.overrideAttrs {
    doCheck = false;
  };

  # libcap_ng = super.libcap_ng.overrideAttrs {
  #   doCheck = false;
  # };

  # libxml2 = super.libxml2.overrideAttrs {
  #   doCheck = false;
  # };

  # openssl = super.openssl.overrideAttrs {
  #   doCheck = false;
  # };

  pythonPackagesExtensions = super.pythonPackagesExtensions ++ [
    (pyself: pysuper: {
      mypy = pysuper.mypy.overrideAttrs {
        doInstallCheck = false;
      };

      psutil = pysuper.psutil.overrideAttrs {
        doInstallCheck = false;
      };

      pytest-xdist = pysuper.pytest-xdist.overridePythonAttrs {
        doCheck = false;
      };

      requests = pysuper.requests.overrideAttrs {
        doInstallCheck = false;
      };

      sphinx = pysuper.sphinx.overrideAttrs {
        doInstallCheck = false;
      };
    })
  ];

  # rhash = super.rhash.overrideAttrs {
  #   doCheck = false;
  # };

  # sqlite = super.sqlite.overrideAttrs (prevAttrs: {
  #   # doCheck = false;
  #   env = prevAttrs.env // {
  #     NIX_CFLAGS_COMPILE = prevAttrs.env.NIX_CFLAGS_COMPILE + " -D_FILE_OFFSET_BITS=64";
  #   };
  #   # preCheck = (prevAttrs.preCheck or "") + ''
  #   #   substituteInPlace test/testrunner.tcl --replace-fail \
  #   #     'return "testdir$ii"' \
  #   #     'return "'"$(mktemp -d /dev/shm/sqlite-tests.XXXXXXXXXX)"'testdir$ii"'
  #   # '';
  #   doCheck = self.stdenv.buildPlatform.is32bit;
  # });

  tcl = super.tcl.overrideAttrs (prevAttrs: {
    # required for pkgsi686Linux.sqlite to pass checkPhase
    configureFlags = (prevAttrs.configureFlags or []) ++ [
      "tcl_cv_api_fts=no"
    ];
  });

  util-linux = super.util-linux.override {
    translateManpages = false;
  };

  w3m = super.w3m.overrideAttrs (prevAttrs: {
    env = (prevAttrs.env or {}) // {
      # Prevent gettext's msgmerge from exhausting the 32-bit address space.
      OMP_NUM_THREADS = "1";
    };
  });
}
