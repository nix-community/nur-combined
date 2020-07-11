{
lib, stdenv, fetchFromGitLab, makeWrapper,
bash, ffmpeg, libaom, libvmaf, curl, jq, coreutils,
cacert, shipCACerts ? false
}:

stdenv.mkDerivation {
  pname = "av1client";
  version = "0.13.0";

  src = fetchFromGitLab {
    domain = "git.dodsorf.as";
    owner = "dandellion";
    repo = "av1master";
    rev = "ecf32d4045e90a524917eaad202ddb6f249f7d28";
    sha256 = "1wzx4mfhhd309a2gdkmqmnmj47g9ncv40d0ynj1hnpimjsw29510";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ bash ffmpeg libaom libvmaf curl jq coreutils cacert ];

  installPhase = ''
    mkdir -p $out/bin
    cp src/static/client.sh $out/bin/av1client
    chmod +x $out/bin/av1client

    ${if shipCACerts == true
      then 
        "sed -i \'s,curl,curl --cacert " + cacert + "/etc/ssl/certs/ca-bundle.crt" + ",\' $out/bin/av1client"
      else
        ""
    }

    wrapProgram $out/bin/av1client \
      --prefix PATH : ${lib.makeBinPath [ffmpeg libaom curl jq coreutils]}
  '';

}
