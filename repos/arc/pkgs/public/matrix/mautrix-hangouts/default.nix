{ fetchFromGitHub, lib, python3Packages }: with python3Packages; let
  drv = buildPythonApplication rec {
    pname = "mautrix-hangouts";
    version = "2019-10-24";

    src = fetchFromGitHub {
      owner = "tulir";
      repo = pname;
      rev = "b0c0a99ef3b49911eb360df075f5f7a21149dc2c";
      sha256 = "1n1jghz9waz5zrd7xwij18jw7qal42p593kpz5qi90mnygf614xl";
    };

    postPatch = ''
      sed -i -e '/alembic>/d' setup.py
    '';

    propagatedBuildInputs = [
      aiohttp
      sqlalchemy
      ruamel_yaml
      python_magic
      hangups
      mautrix-python
      setuptools
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
