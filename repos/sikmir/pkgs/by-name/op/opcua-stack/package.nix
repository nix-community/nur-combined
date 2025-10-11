{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  boost179,
  openssl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "opcua-stack";
  version = "4.0.0";

  src = fetchFromGitHub {
    owner = "ASNeG";
    repo = "OpcUaStack";
    tag = finalAttrs.version;
    hash = "sha256-/PiawQ3kXK4wB/PxQ5EJJsuOOFZdkr/BeQ3zbl7N7fs=";
  };

  sourceRoot = "${finalAttrs.src.name}/src";

  postPatch = ''
    substituteInPlace CMakeLists.txt --replace-fail "/usr" "$out"
    substituteInPlace OpcUaClient/CMakeLists.txt \
      --replace-fail "/etc" "$out/etc" \
      --replace-fail "/var/log" "$out/var/log"
    substituteInPlace OpcUaCtrl/CMakeLists.txt --replace-fail "/etc" "$out/etc"
    substituteInPlace OpcUaStackCore/CMakeLists.txt --replace-fail "/usr" "$out"
    substituteInPlace OpcUaStackServer/CMakeLists.txt --replace-fail "/usr" "$out"
    substituteInPlace OpcUaGenerator/CMakeLists.txt --replace-fail "/usr" "$out"
  '';

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    boost179
    openssl
  ];

  installFlags = [ "INSTALL_PREFIX=$(out)" ];

  meta = {
    description = "Open Source OPC UA Application Server and OPC UA Client/Server C++ Libraries";
    homepage = "https://asneg.github.io/projects/opcuastack";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
    skip.ci = true;
  };
})
