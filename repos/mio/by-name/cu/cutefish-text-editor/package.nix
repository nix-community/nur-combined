{
  mkCutefishDerivation,
  cutefish-toolkit,
  icu,
  pcre2,
}:

mkCutefishDerivation {
  pname = "cutefish-text-editor";

  extraBuildInputs = [
    cutefish-toolkit
    icu
    pcre2
  ];

  meta = {
    description = "Plain-text editor for the Cutefish desktop";
    mainProgram = "cutefish-text-editor";
  };
}
