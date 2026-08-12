{
  lib,
  python3,
  fetchFromRadicle,
  versionCheckHook,
}:
python3.pkgs.buildPythonPackage (finalAttrs: {
  pname = "vmdb2";
  version = "0.41";
  pyproject = true;

  build-system = with python3.pkgs; [ setuptools ];
  dependencies = with python3.pkgs; [
    jinja2
    pyaml
  ];

  src = fetchFromRadicle {
    seed = "radicle.liw.fi";
    repo = "z2kxCtBwDQMPcaf9vGTNH5nYkp9qk"; # vmdb2
    node = "z6MkgEMYod7Hxfy9qCvDv5hYHkZ4ciWmLFgfvm3Wn1b2w2FV"; # liw
    tag = "vmdb2-${finalAttrs.version}";
    hash = "sha256-XHcOKsKEIxHzm66iVfK0QoVYqIo79Je1Kq/tqyzdWEE=";
  };

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  # buildPythonPackage sets a default passthru.updateScript, but it's hosted on radicle.
  passthru.updateScript = null;

  meta = {
    description = "Debian virtual machine image builder";
    longDescription = ''
      vmdb2 is a program for producing a disk image with Debian installed.
    '';
    mainProgram = "vmdb2";
    homepage = "https://vmdb2.liw.fi/";
    downloadPage = "https://radicle.network/nodes/${finalAttrs.src.seed}/rad%3A${finalAttrs.src.repo}";
    changelog = "${finalAttrs.meta.downloadPage}/remotes/${finalAttrs.src.node}/tree/${finalAttrs.src.tag}/NEWS";
    platforms = lib.platforms.linux;
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.skyesoss ];
  };
})
