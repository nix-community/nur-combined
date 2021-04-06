{ fetchFromGitHub, fetchpatch, lib, python3Packages, e2be ? true }: with python3Packages; let
  drv = buildPythonApplication rec {
    pname = "mautrix-hangouts";
    version = "2021-03-31";

    src = fetchFromGitHub {
      owner = "tulir";
      repo = pname;
      rev = "a590e1f7eb1fcc8432205530470ae20107cc0319";
      sha256 = "073sw9x9d01cf1c4f8q7bgp3jx81vqpi1r4gb52n993mwvsxz6vy";
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
      mautrix-python
      setuptools
    ] ++ lib.optionals e2be [
      asyncpg
      olm
      pycryptodome
      unpaddedbase64
    ];

    doCheck = false;
  };
in lib.drvPassthru (drv: {
  # `alembic` (a database migration tool) is only needed for the initial setup,
  # and not needed during the actual runtime. However `alembic` requires `mautrix-telegram`
  # in its environment to create a database schema from all models.
  alembic = alembic.overrideAttrs (old: {
    propagatedBuildInputs = old.propagatedBuildInputs ++ [ drv ];
  });
}) drv
