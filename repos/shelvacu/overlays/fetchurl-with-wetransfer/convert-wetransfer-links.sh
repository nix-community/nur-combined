# shellcheck shell=bash
translateWetransferLinks() {
  local old_urlsArray=("${urls[*]}")
  local new_urlsArray=()
  for this_url in "${old_urlsArray[@]}"; do
    if [[ $this_url == https://we.tl/* ]] || [[ $this_url == https://wetransfer.com/downloads/* ]]; then
      local new_url
      new_url="$("${transferweeBin:?}" -v -g download "$this_url")"
      new_urlsArray+=("$new_url")
    else
      new_urlsArray+=("$this_url")
    fi
  done
  urls="${new_urlsArray[*]}"
}

translateWetransferLinks
