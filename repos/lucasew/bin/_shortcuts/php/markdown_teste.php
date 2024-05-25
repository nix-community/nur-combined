<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8">
    </head>
    <body>

<?php
content_scope_push();
?>

# h1
## h2
### h3
#### h4
##### h5
###### h6

A quick brown fox jumps over the crazy dog

https://github.com/lucasew/nixcfg

> Ser ou não ser, eis a questão ~ Bill Gates (Apple)

![Icone aleatório](https://google.com/favicon.ico)


Imagem com ícone: ![Icone aleatório](https://google.com/favicon.ico)

Negrito é **assim** ou __assim__

Itálico é *assim* ou _assim_
Tachado é ~assim~

Quebras de linha precisam ser
aceitas se não tiver linha em branco

***Negrito itálico***

Eoq trabson nhaa https://stackoverflow.com/questions/1273145/what-do-i-need-to-escape-inside-the-html-pre-tag

<?php
echo content_scope_pop_markdown();
?>

    </body>
</html>
