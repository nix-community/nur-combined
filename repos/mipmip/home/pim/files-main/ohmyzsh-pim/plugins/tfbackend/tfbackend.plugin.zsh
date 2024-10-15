function tfbackend_prompt_info () {
  if [ -f .terraform/tfbackend.state ]; then
    tmp=":$(cat .terraform/tfbackend.state)"
      echo $tmp
  fi
}
