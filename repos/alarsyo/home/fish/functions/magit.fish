function magit
    emacsclient --tty --eval '(magit-status)' --suppress-output
end
