<?php

$session = curl_init();
curl_setopt($session, CURLOPT_URL,"https://i.ytimg.com/vi/dQw4w9WgXcQ/maxresdefault.jpg");
curl_setopt($session, CURLOPT_BINARYTRANSFER, true);
curl_setopt($session, CURLOPT_RETURNTRANSFER, true);
curl_setopt($session, CURLOPT_FOLLOWLOCATION, true);
echo curl_exec($session);
curl_close($session);

set_contenttype("image/jpeg");
?>
