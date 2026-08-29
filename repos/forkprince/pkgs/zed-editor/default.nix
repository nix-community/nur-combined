{
  zed-editor-fhs,
  zed-editor,
  stdenvNoCC,
  ...
}:
if stdenvNoCC.hostPlatform.isDarwin
then zed-editor
else zed-editor-fhs
