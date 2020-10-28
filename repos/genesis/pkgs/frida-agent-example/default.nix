{ pkgs , nodejs, stdenv, lib, ... }:

let

  packageName = with lib; concatStrings (map (entry: (concatStrings (mapAttrsToList (key: value: "${key}-${value}") entry))) (importJSON ./package.json));
  nodePackages = import ./node-composition.nix {
    inherit pkgs nodejs;
    inherit (stdenv.hostPlatform) system;
  };
in
nodePackages."${packageName}".override {
  nativeBuildInputs = [ pkgs.makeWrapper ];

  postInstall = ''
    makeWrapper '${nodejs}/bin/node' "$out/bin/frida-compile" \
      --add-flags "$out/lib/node_modules/frida-agent-example/node_modules/.bin/frida-compile" \
      --run "cd $out/lib/node_modules/frida-agent-example"
  '';

  meta = with lib; {
    description = "Example Frida agent written in TypeScript";
    homepage = https://github.com/oleavr/frida-agent-example/;
    maintainers = with maintainers; [ genesis ];
    license = licenses.wxWindows; # "LGPL-2.0 WITH WxWindows-exception-3.1"
    platforms = platforms.linux;
  };
}
