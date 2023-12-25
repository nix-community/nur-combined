{ stdenv
, autoPatchelfHook
, fetchurl
, libgcc
, lib
}:
stdenv.mkDerivation rec {
  name = "atlas-cli";
  version = "1.14.0";
  src = fetchurl {
    url = "https://fastdl.mongodb.org/mongocli/mongodb-atlas-cli_${version}_linux_x86_64.tar.gz";
    sha256 = "mgQzieVAZwzxwM3kn3hU0le37YlYthKQlgFUtdrcBq4=";
  };
  buildInputs = [
    libgcc
  ];
  unpackPhase = "true";
  installPhase = ''
    mkdir -p $out/bin
    tar -zxvf $src -C $out
    mv $out/mongodb-atlas-cli_${version}_linux_x86_64/bin/atlas $out/bin/atlas
    rm -R $out/mongodb-atlas-cli_${version}_linux_x86_64
  '';
  nativeBuildInputs = [
    autoPatchelfHook
  ];
  meta = with lib; {
    homepage = "https://www.mongodb.com/docs/atlas/cli/stable/";
    description = "Interact with your Atlas database deployments and Atlas Search from the terminal";
    license = licenses.asl20;
    platforms = [ "x86_64-linux" ];
    mainProgram = "atlas";
  };
}
