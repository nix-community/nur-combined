{ lib, stdenv, fetchurl, jdk8_headless, makeWrapper, nixosTests, bash, coreutils }:
let
  # Latest supported LTS JDK for Zookeeper 3.6:
  # https://zookeeper.apache.org/doc/r3.6.3/zookeeperAdmin.html#sc_requiredSoftware
  jre = jdk8_headless;
in
stdenv.mkDerivation rec {
  pname = "zookeeper";
  version = "3.4.14";

  src = fetchurl {
    url = "https://archive.apache.org/dist/${pname}/${pname}-${version}/${pname}-${version}.tar.gz";
    sha256 = "sha256-sU96D+zovTTH//pGA55WOsU2dgfGElF6p703MGr70c0=";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ jre ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -R conf lib $out
    cp ${pname}-${version}.jar $out/lib
    # Without this, zkCli.sh tries creating a log file in the Nix store.
    substituteInPlace $out/conf/log4j.properties \
        --replace 'INFO, RFAAUDIT' 'INFO, CONSOLE'
    mkdir -p $out/bin
    cp -R bin/{zkCli,zkCleanup,zkEnv,zkServer,zkTxnLogToolkit}.sh $out/bin
    patchShebangs $out/bin
    substituteInPlace $out/bin/zkServer.sh \
        --replace /bin/echo ${coreutils}/bin/echo
    for i in $out/bin/{zkCli,zkCleanup,zkServer,zkTxnLogToolkit}.sh; do
      wrapProgram $i \
        --set JAVA_HOME "${jre}" \
        --prefix PATH : "${bash}/bin"
    done
    chmod -x $out/bin/zkEnv.sh
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://zookeeper.apache.org";
    description = "Apache Zookeeper";
    license = licenses.asl20;
    maintainers = with maintainers; [ nathan-gs cstrahan pradeepchhetri ztzg ];
    platforms = platforms.unix;
  };
}
