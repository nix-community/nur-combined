{
  picom,
  pcre2,
  fetchFromGitHub,
  unstableGitUpdater,
}:
picom.overrideAttrs (old: {
  pname = "picom-ft-labs";
  version = "unstable-2024-02-17";

  src = fetchFromGitHub {
    owner = "FT-Labs";
    repo = "picom";
    rev = "df4c6a3d9b11e14ed7f3142540babea4c775ddb1";
    sha256 = "sha256-FmORxY7SLFnAmtQyC82sK36RoUBa94rJ7BsDXjXUCXk=";
  };

  buildInputs = old.buildInputs ++ [pcre2];

  passthru.updateScript = unstableGitUpdater {};

  meta =
    old.meta
    // {
      description = "A fork of Picom with more than 10 unique animation supported picom fork (open window, tag change, fading ...)";
      homepage = "https://github.com/FT-Labs/picom";
    };
})
