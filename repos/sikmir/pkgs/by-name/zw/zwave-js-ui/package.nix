{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodePackages,
}:

buildNpmPackage rec {
  pname = "zwave-js-ui";
  version = "9.14.6";

  src = fetchFromGitHub {
    owner = "zwave-js";
    repo = "zwave-js-ui";
    tag = "v${version}";
    hash = "sha256-WEACdu5TLo8mxhRGVH6CSFTfngUATJqKW4i1r4Wp8P0=";
  };

  npmDepsHash = "sha256-u0BamDmxrxGWBU40xFsCk33kaJHU9NWOyG3VveEARsU=";

  nativeBuildInputs = [ nodePackages.ts-node ];

  meta = {
    description = "Full featured Z-Wave Control Panel UI and MQTT gateway";
    homepage = "https://zwave-js.github.io/zwave-js-ui";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    skip.ci = true;
  };
}
