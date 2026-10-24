{
  mkCutefishDerivation,
  cutefish-toolkit,
  icu,
  libical,
  curl,
}:

mkCutefishDerivation {
  pname = "cutefish-calendar";

  extraBuildInputs = [
    cutefish-toolkit
    icu
    libical
    curl
  ];

  meta = {
    description = "Calendar for the Cutefish desktop";
    mainProgram = "cutefish-calendar";
  };
}
