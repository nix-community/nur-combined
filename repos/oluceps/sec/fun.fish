#!/usr/bin/env fish

function gpg_dec
    for file in (find . -maxdepth 1 -type f -name '*gpg')
        mkdir decrypted
        if test $status -eq 0
            gpg -d $file > ./decrypted/(string sub -e -4 $file)
        else
            echo "create dir fail"
        end
    end
end

function renc_with_age
    mkdir final
    if test $status -eq 0
        for file in (find ./decrypted -maxdepth 1 -type f -name '*')
            rage -e -i ./age-yubikey-identity-7d5d5540.txt -R /run/agenix/pub -o ./final/(string join "" "$file" ".age") $file 
        end
    else
        echo "create dir fail"
    end
end

function dec_age_file
    for file in (find . -maxdepth 1 -type f -name '*age')
        echo "
============================$file============================"
        rage -d -i /run/agenix/age $file
    end
end


dec_age_file
# gpg_dec
# renc_with_age

