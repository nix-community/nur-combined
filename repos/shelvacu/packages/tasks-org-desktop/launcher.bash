#!@bash@

set -euo pipefail

app_home="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
app_dir="$app_home/lib/app"
config="$app_dir/tasks-org.cfg"

declare -a classpath=()
declare -a java_options=()
main_class=""

while IFS= read -r line || [[ -n "$line" ]]; do
  case "$line" in
    app.classpath=*)
      value="${line#app.classpath=}"
      classpath+=("${value//\$APPDIR/$app_dir}")
      ;;
    app.mainclass=*)
      main_class="${line#app.mainclass=}"
      ;;
    java-options=*)
      value="${line#java-options=}"
      java_options+=("${value//\$APPDIR/$app_dir}")
      ;;
  esac
done < "$config"

if [[ -z "$main_class" || ${#classpath[@]} -eq 0 ]]; then
  echo "Invalid jpackage configuration: $config" >&2
  exit 1
fi

classpath_string="$(IFS=:; echo "${classpath[*]}")"

exec @java@ \
  "${java_options[@]}" \
  -classpath "$classpath_string" \
  "$main_class" \
  "$@"
