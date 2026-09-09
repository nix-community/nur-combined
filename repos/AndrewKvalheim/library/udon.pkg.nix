{ expect
, fetchFromGitHub
, gitUpdater
, lib
, python3Packages
, testers
, writeScriptBin

  # Dependencies
, openssl
}:

let
  inherit (builtins) toFile;
  inherit (lib) getExe licenses;
  inherit (python3Packages.python) sitePackages;
in
python3Packages.buildPythonApplication (udon: {
  pname = "udon";
  version = "0.01";
  meta = {
    description = "Network messaging library and tools";
    homepage = "https://github.com/treedavies/udon";
    license = licenses.gpl2Only;
    mainProgram = "udon";
  };

  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  src = fetchFromGitHub {
    owner = "treedavies";
    repo = "udon";
    rev = "refs/tags/v${udon.version}";
    hash = "sha256-6/bcwbuNHX7Fiy1vle3v+nWJFkEGLMFWFrpiSJcXGKk=";
  };

  patches = [
    (toFile "modules-path.patch" ''
      Allow configuration of path of user-provided modules

      --- a/src/libudon.py
      +++ b/src/libudon.py
      @@ -1027 +1027 @@
      -		self.modules_path = f"/usr/bin/udon.d/modules/"
      +		self.modules_path = os.environ.get("UDON_MODULES_PATH", "/usr/bin/udon.d/modules/")
    '')
    (toFile "process-name.patch" ''
      Stabilize identity of process for detection by self test

      --- a/src/udon
      +++ b/src/udon
      @@ -463,2 +463,4 @@
       if __name__ == '__main__':
      +	import setproctitle
      +	setproctitle.setproctitle("udon") # Referenced by `is_udon_server_running`
       
    '')
  ];

  dependencies = with python3Packages; [
    config
    cryptography
    grpcio
    psutil
    python-daemon
    setproctitle
  ];

  format = "other";
  nativeBuildInputs = with python3Packages; [
    grpcio-tools
  ];
  propagatedBuildInputs = [
    openssl
  ];
  buildPhase = ''
    runHook preBuild

    python-grpc-tools-protoc \
      --proto_path='src' \
      --python_out='src' \
      --grpc_python_out='src' \
      'src/udon.proto'

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -D --target-directory "$out/bin" \
      'src/udon'
    install -D --target-directory "$out/${sitePackages}" --mode '644' \
      'src/'*'.py'
    cp --recursive --target-directory "$out/${sitePackages}" \
      'src/modules/'*

    runHook postInstall
  '';

  pythonImportsCheck = [ "hello" "libudon" "udon_init" "test_libudon" ];

  passthru.tests = {
    libudon = testers.nixosTest {
      name = "udon";
      nodes.a = {
        imports = [ <nixpkgs/nixos/tests/common/user-account.nix> ];

        environment.systemPackages = [
          udon.finalPackage
          (writeScriptBin "udon-init-noninteractive" ''
            #!${getExe expect} -f
            spawn udon --init
            expect "Create new TLS Certs? (y/n): "; send "y\r"
            expect "Use this hostname for cert? (y/n): "; send "y\r"
            expect "Create TEST keys A and B? (y/n): "; send "y\r"
            expect "Create a user key? (y/n): "; send "y\r"
            expect "Name of key: "; send "Example\r"
            expect "Desired Key size? (default=4096): "; send "512\r"
          '')
        ];
      };

      testScript = ''
        a.wait_for_unit("multi-user.target")
        a.succeed("su - alice -c 'udon-init-noninteractive'")
        a.execute("su - alice -c 'udon --daemon'")
        a.wait_for_open_port(50051)
        a.succeed("su - alice -c 'udon --test'")
      '';
    };
  };
})
