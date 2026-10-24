{ mkCutefishDerivation, stdenvNoCC }:

mkCutefishDerivation {
  stdenv = stdenvNoCC;
  pname = "cutefish-wallpapers";
  withPkgConfig = false;
  withGettext = false;

  postPatch = ''
    # The project only copies images. NONE skips the C/C++ compiler probe.
    substituteInPlace CMakeLists.txt \
      --replace-fail 'project(cutefish-wallpapers)' 'project(cutefish-wallpapers NONE)'
    substituteInPlace sources/CMakeLists.txt \
      --replace-fail 'project(unsplash-wallpapers)' 'project(unsplash-wallpapers NONE)' \
      --replace-fail 'DESTINATION /usr/share/backgrounds/cutefishos' \
        'DESTINATION share/backgrounds/cutefishos'
  '';

  meta = {
    description = "Default wallpapers for the Cutefish desktop";
    license = {
      fullName = "Unsplash License";
      url = "https://unsplash.com/license";
      free = true;
    };
  };
}
