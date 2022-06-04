{ fetchFromGitHub, fetchpatch, lib, python3Packages, e2be ? true }: with python3Packages; let
  sqlalchemy_1_3 = python3Packages.sqlalchemy.overrideAttrs (old: rec {
    version = "1.3.24";
    src = fetchPypi {
      inherit version;
      pname = "SQLAlchemy";
      sha256 = "06bmxzssc66cblk1hamskyv5q3xf1nh1py3vi6dka4lkpxy7gfzb";
    };
    doInstallCheck = false; # takes forever :<
  });
  sqlalchemy = if lib.versionAtLeast python3Packages.sqlalchemy.version "1.4"
    then sqlalchemy_1_3
    else python3Packages.sqlalchemy;
  mautrix = (python3Packages.mautrix.override {
    inherit sqlalchemy;
  }).overrideAttrs (old: rec {
    version = "0.10.11";
    src = fetchPypi {
      inherit version;
      pname = "mautrix";
      sha256 = "b3905fbd1381031b4c54258fdef9e99dd342c3a211abe0b827b2c480db4b1771";
    };
  });
  hangups = python3Packages.hangups or null;
  drv = buildPythonApplication rec {
    pname = "mautrix-hangouts";
    version = "2021-08-11";

    src = fetchFromGitHub {
      owner = "tulir";
      repo = pname;
      rev = "feeae94f544e535e1fe6240bfad4e326a504739b";
      sha256 = "169xpigw4rnczz67088ciifwhbq9s93gfnp9lpawv1b3y799ds5z";
    };

    patches = [ ./entrypoint.patch ];
    postPatch = ''
      sed -i -e '/alembic>/d' requirements.txt
    '';

    propagatedBuildInputs = [
      aiohttp
      sqlalchemy
      ruamel_yaml
      CommonMark
      python_magic
      hangups
      mautrix
      setuptools
    ] ++ lib.optionals e2be [
      asyncpg
      python-olm
      pycryptodome
      unpaddedbase64
    ];

    meta.broken = hangups == null;
    passthru = {
      pythonModule = python;
      pythonPackage = "mautrix_hangouts";
    };

    doCheck = false;
  };
in lib.drvPassthru (drv: {
  # `alembic` (a database migration tool) is only needed for the initial setup,
  # and not needed during the actual runtime. However `alembic` requires `mautrix-hangouts`
  # in its environment to create a database schema from all models.
  alembic = (alembic.override { inherit sqlalchemy; }).overrideAttrs (old: {
    propagatedBuildInputs = old.propagatedBuildInputs ++ [ drv ];
  });
}) drv
