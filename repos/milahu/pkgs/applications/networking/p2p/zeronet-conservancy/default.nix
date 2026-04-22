# based on https://github.com/NixOS/nixpkgs/pull/245091

# FIXME
# [07:44:13] TorManager Tor controller connect error: ConnectionRefusedError: [Errno 111] Connection refused in TorManager.py line 143 > <gevent>/_socketcommon.py line 586 > 630
# [07:44:13] TorManager Disabling Tor, because error while accessing Tor proxy at port 127.0.0.1:9050: Error ([Errno 111] Connection refused)
#
# src/Tor/TorManager.py: startTor should start a tor proxy on linux
# if the system tor proxy does not allow connections to ControlPort at 127.0.0.1:9051
#
# src/Config.py
# 463:        self.parser.add_argument('--tor-controller', help='Tor controller address', metavar='ip:port', default='127.0.0.1:9051')
# 851:            return 'localhost', 9051
#
# TODO does tor use meek-client in $PATH?
# TODO use absolute path of meek-client
# https://github.com/SuperSandro2000/nixpkgs/blob/87a3ea0e6d22f1f591e0de220da9a6b415b4e3ab/pkgs/applications/networking/onionshare/fix-paths.patch

{
  lib,
  fetchFromGitHub,
  nixosTests,
  buildPythonApplication,
  python,
  gevent,
  msgpack,
  base58,
  merkletools,
  rsa,
  pysocks,
  pyasn1,
  websocket-client,
  gevent-websocket,
  rencode,
  python-bitcoinlib,
  maxminddb,
  pyopenssl,
  rich,
  defusedxml,
  pyaes,
  coincurve,
  requests,
  asyncio-gevent,
  aio-btdht,
  tor,
  meek,
  openssl,
}:

buildPythonApplication rec {
  pname = "zeronet-conservancy";
  version = "0.7.11-c7c0a9e";
  format = "other";

  src = fetchFromGitHub {
    owner = "zeronet-conservancy";
    repo = "zeronet-conservancy";
    # rev = "v${version}";
    # https://github.com/zeronet-conservancy/zeronet-conservancy/pull/335
    # NOTE this disables validation of messages
    rev = "c7c0a9ea8f67ec7932bb2aa76c44d215e154513f";
    hash = "sha256-ERomoKFYcC62YS+GOr2x55gfusuhTd7965LTnVR5oDI=";
  };

  # not working?
  # zeroid.bit: POST https://zeroid.qc.to/ZeroID/request.php net::ERR_NAME_NOT_RESOLVED
  # kxoid.bit: Uncaught (in promise) TypeError: this[(e + "Callback")] is not a function
  /*
  # needed for zeroid.bit kxoid.bit ...
  # https://github.com/zeronet-conservancy/zeronet-conservancy/issues/29
  src-peer-message-plugin = fetchFromGitHub {
    # https://github.com/HelloZeroNet/Plugin-PeerMessage
    owner = "HelloZeroNet";
    repo = "Plugin-PeerMessage";
    rev = "a9b93b5e97134283f5bf97e044ba57b4eb179193";
    hash = "sha256-CH9G3/PxMteDmZjiaahysi0HmF3hmosw8HCyQhdmehk=";
  };
  */

  postPatch = ''
    # TODO what file extension has error_log_path
    # https://github.com/zeronet-conservancy/zeronet-conservancy/issues/334
    substituteInPlace zeronet.py \
      --replace-fail \
        "subprocess.Popen(['notepad.exe', error_log_path])" \
        "subprocess.Popen(['xdg-open', error_log_path])"

    substituteInPlace src/Crypt/CryptConnection.py \
      --replace-fail \
        'self.openssl_bin = ' \
        'self.openssl_bin = "${openssl}/bin/openssl" # '

    substituteInPlace src/Tor/TorManager.py \
      --replace-fail \
        'self.tor_exe = "tools/tor/tor.exe"' \
        'self.tor_exe = "${tor}/bin/tor"' \
      --replace-fail \
        'self.has_meek_bridges = os.path.isfile' \
        'self.has_meek_bridges = True # os.path.isfile' \

    substituteInPlace plugins/Zeroname/updater/zeroname_updater.py \
      --replace-fail \
        '[sys.executable, "zeronet.py", "siteSign"' \
        '["$out/share/zeronet.py", "siteSign"'
  '';

  propagatedBuildInputs = [
    gevent
    msgpack
    base58
    merkletools
    rsa
    pysocks
    pyasn1
    websocket-client
    gevent-websocket
    rencode
    python-bitcoinlib
    maxminddb
    pyopenssl
    rich
    defusedxml
    pyaes
    coincurve
    requests
    asyncio-gevent
    aio-btdht
  ];

  buildPhase = ''
    runHook preBuild
    python -O -m compileall .
    runHook postBuild
  '';

  #   ln -s ${src-peer-message-plugin} $out/share/plugins/PeerMessage
  installPhase = ''
    runHook preInstall
    mkdir -p $out/share
    cp -r plugins src *.py $out/share/
    runHook postInstall
  '';

  postFixup = ''
    makeWrapper "$out/share/zeronet.py" "$out/bin/zeronet" \
      --set PYTHONPATH "$PYTHONPATH" \
      --set PATH ${lib.makeBinPath [
        python
        meek # meek-client: tor transport
      ]}
  '';

  passthru.tests = {
    nixos-test = nixosTests.zeronet-conservancy;
  };

  meta = with lib; {
    description = "A fork/continuation of the ZeroNet project";
    longDescription = ''
      zeronet-conservancy is a fork/continuation of ZeroNet project (that has
      been abandoned by its creator) that is dedicated to sustaining existing
      p2p network and developing its values of decentralization and freedom,
      while gradually switching to a better designed network.
    '';
    homepage = "https://github.com/zeronet-conservancy/zeronet-conservancy";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ fgaz ];
  };
}
