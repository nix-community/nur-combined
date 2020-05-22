all: publish

publish.el: publish.org
	emacs --batch --eval "(require 'ob-tangle)" --eval '(org-babel-tangle-file "publish.org")'

publish: publish.el
	emacs -batch --load publish.el --eval '(clean-and-publish)'
