# https://nixos.wiki/wiki/Packaging/Binaries
{ pkgs, lib, stdenv, fetchurl, autoPatchelfHook, systemd }:
let
  inherit (pkgs) system;
  inherit (pkgs.stdenv) isDarwin isLinux;
  inherit (lib.lists) optional;

  pname = "velociraptor";
  name = pname;
  appname = pname;
  version = "0.6.7-5";

  meta = with lib; {
    homepage = "https://docs.velociraptor.app/";
    description = "Velociraptor";
    license = licenses.mit;
    platforms = [ "x86_64-darwin" "aarch64-darwin" "x86_64-linux" ];
  };

  hashes = {
    "x86_64-linux" = "sha256-9ORkd6WAeL1jyYKRrK0Y9SOF/XRylQb+XQvxlRL6kc8=";
    "x86_64-darwin" = lib.fakeHash;
    "aarch64-linux" = lib.fakeHash;
    "aarch64-darwin" = "sha256-L26Jm3F6wq+l8BIUdhlapPqARzDBkMXGTF4k7XUKdPM=";
  };

  archMap = {
    "x86_64" = "amd64";
    "aarch64" = "arm64";
  };

  latestVersionMap = {
    # Linux
    "linux-amd64" = "0.6.7-5";
    # Darwin
    "darwin-amd64" = "0.6.7-4";
    "darwin-arm64" = "0.6.7-4";
  };

  # https://github.com/Velocidex/velociraptor/releases/download/v0.6.7-5/velociraptor-v0.6.7-4-linux-arm64

  parts = builtins.filter builtins.isString (builtins.split "-" pkgs.system);
  kernel = builtins.head (builtins.tail parts);
  nixArch = builtins.head parts;
  arch = builtins.getAttr nixArch archMap;

  latestPatch = builtins.getAttr "${kernel}-${arch}" latestVersionMap;
  filename = "${pname}-v${latestPatch}-${kernel}-${arch}";

  src = fetchurl {
    url =
      "https://github.com/Velocidex/velociraptor/releases/download/v${version}/${filename}";
    sha256 = builtins.getAttr system hashes;
  };

  optionalPatchelfCommand = if isLinux then
    ''
      ${pkgs.patchelf}/bin/patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/bin/${pname}''
  else
    "";

in stdenv.mkDerivation {
  inherit pname version src filename meta;
  buildInputs = [ ] ++ optional isLinux [ systemd ];

  dontUnpack = true;

  nativeBuiltInputs = [ ] ++ optional isLinux [ autoPatchelfHook ];

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/${pname}
  '';

  postFixup = ''
    ${optionalPatchelfCommand}

    chmod +x $out/bin/${pname}
  '';
}
