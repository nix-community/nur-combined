{ fetchFromGitHub, lib, python3Packages }: with python3Packages; let
  drv = buildPythonApplication rec {
    pname = "mautrix-hangouts";
    version = "2019-09-02";

    src = fetchFromGitHub {
      owner = "tulir";
      repo = pname;
      rev = "a592e7de5f1cae3ffd7ebf1c4ee276df019310cb";
      sha256 = "14cbxs975zyz4cixirdnqlans738ykas56n6chm95lil8x6kvjr0";
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
