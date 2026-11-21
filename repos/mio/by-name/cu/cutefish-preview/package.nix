{
  mkCutefishDerivation,
  cutefish-toolkit,
  cutefish-framework,
  libpng,
}:

mkCutefishDerivation {
  pname = "cutefish-preview";

  # Cutefish::Files and Cutefish::Pdf come from cutefish-framework; libpng
  # decodes the images.
  extraBuildInputs = [
    cutefish-toolkit
    cutefish-framework
    libpng
  ];

  meta = {
    description = "Image and PDF viewer for the Cutefish desktop";
    mainProgram = "cutefish-preview";
  };
}
