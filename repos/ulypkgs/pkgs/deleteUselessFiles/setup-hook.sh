deleteUselessFiles() {
  [ -z "${deleteUselessFilesHasRun-}" ] || return
  deleteUselessFilesHasRun=1

  echo Executing deleteUselessFilesPhase
  runHook preDeleteUselessFiles

  if [[ -z "${uselessFiles-}" ]]; then
    uselessFiles=('desktop.ini' '__MACOSX' '.DS_Store')
  fi

  for pattern in "${uselessFiles[@]}"; do
    while IFS= read -r -d '' file; do
      echo "deleteUselessFiles: Deleting $file"
      rm -rf "$file"
    done < <(find "$out" -name "$pattern" -print0)
  done

  runHook postDeleteUselessFiles
  echo Finished deleteUselessFilesPhase
}

deleteEmptyDirectories() {
  [ -z "${deleteEmptyDirectoriesHasRun-}" ] || return
  deleteEmptyDirectoriesHasRun=1

  echo Executing deleteEmptyDirectoriesPhase
  runHook preDeleteEmptyDirectories

  find "$out" -type d -empty -delete

  runHook postDeleteEmptyDirectories
  echo Finished deleteEmptyDirectoriesPhase
}

if [[ -z "${dontDeleteUselessFiles-}" ]]; then
  preFixupHooks+=(deleteUselessFiles)
fi

if [[ -z "${dontDeleteEmptyDirectories-}" ]]; then
  postFixupHooks+=(deleteEmptyDirectories)
fi
