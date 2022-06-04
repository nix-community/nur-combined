{ rustPlatform
, fetchFromGitHub
, wireplumber ? wireplumber-0_4_4, pipewire, glib
, wireplumber-0_4_4 ? null
, stdenv, libclang
, pkg-config
, lib
}: with lib; let
in rustPlatform.buildRustPackage {
  pname = "wireplumber-scripts-arc";
  version = "0.1.0";

  buildInputs = [ wireplumber pipewire glib ];
  nativeBuildInputs = [ pkg-config ];

  src = fetchFromGitHub {
    owner = "arcnmx";
    repo = "wireplumber-scripts";
    rev = "e4d267f9b484430f05ee5d7c72245757cc6b7f7c";
    sha256 = "1pd3alxmbmrgmjb161yx5n1cjyq8cafpqh7632mymilqn4cpifz0";
  };
  cargoSha256 = "0ffzqkz7b09kwjs4yyiyxwvmdknharxhq8x7zmp8jp0b3gsgnr8c";

  pluginExt = stdenv.hostPlatform.extensions.sharedLibrary;
  wpLibDir = "${placeholder "out"}/lib/wireplumber-${versions.majorMinor wireplumber.version}";
  postInstall = ''
    install -d $wpLibDir
    for pluginName in wpscripts_static_link; do
      mv $out/lib/lib$pluginName$pluginExt $wpLibDir/
    done
  '';

  # bindgen garbage, please clean up your act pipewire-rs :(
  LIBCLANG_PATH = "${libclang.lib}/lib";
  BINDGEN_EXTRA_CLANG_ARGS = [
    "-I${stdenv.cc.cc}/lib/gcc/${stdenv.hostPlatform.config}/${stdenv.cc.cc.version}/include"
    "-I${stdenv.cc.libc.dev}/include"
  ];

  meta.broken = versionOlder rustPlatform.rust.rustc.version "1.57";
}
