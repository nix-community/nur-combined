{ lib
, fetchFromGitHub
, jdk8 # jmxterm needs a JDK to run
, makeWrapper
, maven
, ...
}:

maven.buildMavenPackage rec {
  pname = "jmxterm";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "jiaqi";
    repo = "jmxterm";
    rev = "v${version}";
    hash = "sha256-sArh0+bz5RUKeo0VejfhJqt7r5Tc2jSp48e8G69tKyM=";
  };

  mvnParameters = "-DskipTests";

  mvnHash = "sha256-1Sn8nVI4A5iEFZv1+kuk8ka2V3jvKDSxjeAu2K22bGA=";

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,share/java}

    cp target/jmxterm-${version}-uber.jar $out/share/java

    makeWrapper ${jdk8}/bin/java $out/bin/jmxterm \
      --add-flags "-jar \"$out/share/java/jmxterm-${version}-uber.jar\""

    runHook postInstall
  '';

  meta = with lib; {
    description = "JMXTerm is an open source command line based interactive JMX client written in Java";
    homepage = "https://docs.cyclopsgroup.org/jmxterm";
    license = licenses.asl20;
    maintainers = with maintainers; [ fooker ];
  };
}

