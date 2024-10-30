#!@shell@
set -e
destDir="${XDG_DATA_HOME:-$HOME/.local/share}/drl"
oldPath="$PATH"
PATH="@coreutils@/bin"
mkdir -p "$destDir"
shopt -s extglob
for file in @out@/share/drl/!(drl); do
	baseFile="${file##*/}"
	destFile="$destDir/$baseFile"
	if [[ ! -e "$destFile" ]]; then
		if [[ "$baseFile" == @(config.lua|colors.lua|screenshot|mortem|backup) ]]; then
			cp -Lr --no-preserve=all "$file" "$destFile"
		elif [[ ! -e "$destFile" || -L "$destFile" ]]; then
			ln -sf "$file" "$destDir"
		fi
	fi
done
shopt -u extglob
PATH="$oldPath"
cd "$destDir"
exec -a drl @out@/share/drl/drl "$@"
