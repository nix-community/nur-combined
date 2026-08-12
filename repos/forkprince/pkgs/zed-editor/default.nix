{
  zed-editor-fhs,
  zed-editor,
  stdenvNoCC,
  ...
}:
if stdenvNoCC.isDarwin
then zed-editor
else zed-editor-fhs
