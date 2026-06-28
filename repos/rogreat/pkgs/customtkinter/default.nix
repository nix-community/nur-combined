{
  buildPythonPackage,
  customtkinter,
  fetchFromGitHub,
  fetchpatch2,
}:

buildPythonPackage (finalAttrs: {
  inherit (customtkinter)
    pname
    pyproject
    build-system
    dependencies
    pythonImportsCheck
    meta
    ;

  version = "6.0.0";

  src = fetchFromGitHub {
    inherit (customtkinter.src) owner repo;
    tag = "v${finalAttrs.version}";
    hash = "sha256-rRkqyyWxWmJqXS9dT/T5K99+AGY6xDjtrKLRG/Yo7tc=";
  };

  patches = customtkinter.patches ++ [
    (fetchpatch2 {
      name = "fonts-fix.patch";
      url = "https://github.com/RoGreat/CustomTkinter/commit/067f6067366c5b86a8019ed463873ebece8f6163.patch?full_index=1";
      hash = "sha256-WPwm4pG0mi3nLPgPu4awcrJwa2AMCbfNVWBQ+3vAKwE=";
    })
  ];
})
