<?php
echo "HTTP/1.1 404 To nem ai\r\n";
// header( 'Content-type: text/plain; charset=utf-8' );

// echo "HTTP/1.1 200\r\n\r\n";
echo "Content-Type: text/plain; charset=utf-8\n";
echo "Connection: close\n";
echo "Server: GambiarraStation\n";

echo "\r\n";

echo "Teste eoq trabson";
// sleep(1);
flush();
exit;
?>
