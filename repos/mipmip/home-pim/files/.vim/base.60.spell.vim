" Spell Check
let b:myLang=0
let g:myLangList=["nospell","nl","en"]

function! ToggleSpell()
  if !exists( "b:myLang" )
    if &spell
      let b:myLang=index(g:myLangList, &spelllang)
    else
      let b:myLang=0
    endif
  endif

  let b:myLang=b:myLang+1

  if b:myLang>=len(g:myLangList)
    let b:myLang=0
  endif

  if b:myLang==0
    setlocal nospell
  else
    execute "setlocal spell spelllang=".get(g:myLangList, b:myLang)
  endif

  echo "spell checking language:" g:myLangList[b:myLang]
endfunction

