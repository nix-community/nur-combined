{ lib, bundlerApp }:

bundlerApp {
  pname = "oneaws";
  gemdir = ./.;
  exes = [ "oneaws" ];
  postBuild = ''
    sed -i '2i ENV["GEM_PATH"] = ""' $out/bin/oneaws
  '';

  meta = {
    description = "CLI tool for AWS authentication via OneLogin";
    homepage = "https://github.com/pepabo/oneaws";
    license = lib.licenses.unfree;
    mainProgram = "oneaws";
  };
}
