{
  stdenvNoCC,
  vscode-fhs,
  vscode,
  ...
}:
if stdenvNoCC.isDarwin
then vscode
else vscode-fhs
