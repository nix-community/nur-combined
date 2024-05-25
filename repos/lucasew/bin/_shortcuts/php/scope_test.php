<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8">
        <title>Teste de escopo</title>
    </head>
    <body>

<?php
content_html();
?>

<h1>Teste de escopo</h1>

<p>Objetivo aqui é ver se o ob_start e o ob_end_clean tem comportamento de pilha</p> 

<?php
ob_start();
?>

<p>Isso deve aparecer</p>

skibidi bop

<?php
$aparecido = ob_get_contents();
ob_end_clean();
echo '<pre>';
echo htmlspecialchars($aparecido);
echo '</pre>';
?>

    </body>
</html>

