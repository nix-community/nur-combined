{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  boost,
  openssl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "opcua-stack";
  version = "3.8.1";

  src = fetchFromGitHub {
    owner = "ASNeG";
    repo = "OpcUaStack";
    tag = finalAttrs.version;
    hash = "sha256-czpuuT9DeZaYo2Q8Y/vW1kAsIiFhRDSKwVBUcFgb9iQ=";
  };

  sourceRoot = "${finalAttrs.src.name}/src";

  postPatch = ''
    substituteInPlace CMakeLists.txt --replace-fail "/usr" "$out"
  '';

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    boost
    openssl
  ];

  meta = {
    description = "Open Source OPC UA Application Server and OPC UA Client/Server C++ Libraries";
    homepage = "https://asneg.github.io/projects/opcuastack";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
