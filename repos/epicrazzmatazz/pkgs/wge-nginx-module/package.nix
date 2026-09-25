{
  lib,
  mkNginxPlugin,
  fetchFromGitHub,

  spdlog,
  fmt,
  wge,
  wge-apic,
}:

mkNginxPlugin (finalAttrs: {
  pname = "wge";
  version = "2025-11-07";
  src = fetchFromGitHub {
    owner = "stone-rhino";
    repo = "wge-connectors";
    rev = "e600a5b29c467ea981835b5cc22cccf83f89d1a5";
    hash = "sha256-PoJ0XptiZblqyuSe76F1Eqx8Sj8z8bhES3OPvevpCdA=";
  };
  sourceRoot = "${finalAttrs.src.name}/nginx";

  buildInputs = [
    spdlog
    fmt
    wge
    wge-apic
  ];

  patches = [ ./nginx_config.patch ];
  patchFlags = [ "-p2" ];
  postPatch = ''
    substituteInPlace config --replace-fail '$ngx_addon_dir/../wge-apic' '${wge-apic}/include'
  '';

  meta = {
    description = "nginx module for WGE.";
    homepage = "https://github.com/stone-rhino/wge-connectors";
    license = lib.licenses.mit;
  };
})
