<?php

$_http_header = fgets(STDIN);
$_http_header = trim($_http_header);
$_http_header = explode(" ", $_http_header);

$_SERVER['REQUEST_METHOD'] = $_http_header[0];
$_SERVER['REQUEST_URI'] = $_http_header[1];
$_SERVER['QUERY_STRING'] = parse_url($_http_header[1], PHP_URL_QUERY);

while (true) {
    $_header = fgets(STDIN);
    $_header = trim($_header);
    // echo "header: " . '"' . $_header . '"' . "\n";
    if (strlen($_header) == 0) {
        break;
    }
    $_header_name = explode(":", $_header)[0];
    $_header_name = strtoupper($_header_name);
    $_header_name = str_replace("-", "_", $_header_name);

    $_header_value = substr($_header, strlen($_header_name)+1);
    $_header_value = trim($_header_value);

    // var_dump($_header);
    // echo "NAME: '" . $_header_name . "' VALUE: '" . $_header_value . "'\n";
    $_SERVER['HTTP_' . $_header_name] = $_header_value;
}

$_HEADERS_KV = array();
function set_header(string $key, string $value) {
    global $_HEADERS_KV;
    $_HEADERS_KV[$key] = $value;
}

function set_contenttype(string $content_type) {
    set_header("Content-Type", $content_type);
}

set_contenttype("auto"); // default

function content_text() {
    set_contenttype("text/plain; charset=utf-8");
}

function content_html() {
    set_contenttype("text/html");
}

function mime_from_buffer($buffer) {
    $finfo = new finfo(FILEINFO_MIME_TYPE);
    return $finfo->buffer($buffer);
}


$_HEADERS = array();
function header(string $header) {
    global $_HEADERS;
    array_push($_HEADERS, $header);
}

set_header("Server", "GambiarraStation");
set_header("Connection", "close");

ob_start();

?>

<h1>Hello, world</h1>
<?php
content_html();
?>

<pre>

<?php
phpinfo();
?>

</pre>

<?php
$data = ob_get_contents();
ob_end_clean();

if (!http_response_code()) {
    http_response_code(200); // default response code
}

echo "HTTP/1.0 ";
echo http_response_code();
echo "\r\n";

foreach ($_HEADERS as $header) {
    echo "$header\r\n";
}

if ($_HEADERS_KV['Content-Type'] == 'auto') {
    set_contenttype(mime_from_buffer($data));
}

foreach ($_HEADERS_KV as $key => $value) {
    echo "$key: $value\r\n";
}

echo "\r\n";

echo $data;

?>
