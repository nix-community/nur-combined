{ stdenv, python3, fetchurl }:


with python3.pkgs;

buildPythonPackage rec {
  pname = "frida";
  version = "11.0.13";

  # building is somewhat complicated, described in https://nixos.wiki/wiki/Frida

  # Your glibc version must with one used for building, otherwise you get:

  # Frida:ERROR:../../../frida-core/src/linux/frida-helper-service-glue.c:2987:frida_resolve_library_function: assertion failed (local_library_path == remote_library_path): ("/nix/store/pr73kx0cdszbv9iw49g8dzi0nqxfjbFailed to attach: the connection is closed                           yvhi473xp6-glibc-2.27/lib/libc-2.27.so")

  # Therefore I patched frida-core, so it will not complain about different libc versions:

  #diff --git a/src/linux/frida-helper-service-glue.c b/src/linux/frida-helper-service-glue.c
  #index 39f84be..71d7b78 100644
  #--- a/src/linux/frida-helper-service-glue.c
  #+++ b/src/linux/frida-helper-service-glue.c
  #@@ -2984,7 +2984,7 @@ frida_resolve_library_function (pid_t pid, const gchar * library_name, const gch
  #   if (remote_base == 0)
  #     return 0;
  #-  g_assert_cmpstr (local_library_path, ==, remote_library_path);
  #+  //g_assert_cmpstr (local_library_path, ==, remote_library_path);
  #   canonical_library_name = g_path_get_basename (local_library_path);
  
  src = fetchurl {
    url = "https://dl.thalheim.io/0wWmCbPcE3RJ2-C-o3pLuw/frida-${version}-py3.6-linux-x86_64.egg";
    sha256 = "058pf9pw0jzi3950v8xav24hp55662jnlnp8a93gyhlfzfj5bx7v";
  };

  unpackPhase = ":";

  format = "other";

  propagatedBuildInputs = [ pygments prompt_toolkit colorama ];

  installPhase = ''
    dest=$out/lib/${python3.libPrefix}/site-packages
    export PYTHONPATH=$PYTHONPATH:$dest
    mkdir -p $dest
    easy_install --prefix $out $src
  '';

  meta = with stdenv.lib; {
    description = "Dynamic instrumentation toolkit for developers, reverse-engineers, and security researchers";
    homepage = https://www.frida.re/;
    license = licenses.wxWindows;
  };
}


