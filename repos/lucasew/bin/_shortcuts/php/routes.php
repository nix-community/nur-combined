<?php

// ==================================== Ingestão da request que vem do stdin =============

$_http_header = fgets(STDIN);
$_http_header = trim($_http_header);
$_http_header = explode(" ", $_http_header);

$_SERVER['REQUEST_METHOD'] = $_http_header[0];
$_SERVER['REQUEST_URI'] = $_http_header[1];
$_SERVER['QUERY_STRING'] = parse_url($_http_header[1], PHP_URL_QUERY);

$_HEADERS = array();
function header(string $header) {
    global $_HEADERS;
    array_push($_HEADERS, $header);
}

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

// ==================================== Primitiva de header pra retorno =============
set_header("Server", "GambiarraStation");
set_header("Connection", "close");

$_HEADERS_KV = array();
function set_header(string $key, string $value) {
    global $_HEADERS_KV;
    $_HEADERS_KV[$key] = $value;
}

// ==================================== Utilitários para content-type =============
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


// ==================================== Utilitários para roteamento =============
$INPUT_DATA = array_merge_recursive($_GET, $_POST);
$ROUTE = parse_url($_SERVER["REQUEST_URI"])["path"];
$IS_ROUTED = false;

function mark_routed() {
    global $IS_ROUTED;
    $orig_VALUE = $IS_ROUTED;
    $IS_ROUTED = true;
    // return false;
    return $orig_VALUE;
}


/**
 * bring required variables to scope then require the new file
 */
function execphp(string $script) {
    global $INPUT_DATA, $ROUTE;
    require $script;
}

/**
 * create a route that matches anything starting with $base_route
 */
function use_route(string $base_route, string $handler_script) {
    global $ROUTE, $IS_ROUTED;
    if (str_starts_with($ROUTE, $base_route)) {
        if ($IS_ROUTED) return;
        $ROUTE = substr($ROUTE, strlen($base_route));
        execphp($handler_script);
    }
}

/**
 * create a route that matches exactly $selected_route
 */
function exact_route(string $selected_route, string $handler_script) {
    global $ROUTE;
    if (strcmp($ROUTE, $selected_route) == 0) {
        if (mark_routed()) return;
        execphp($handler_script);
    }
}

/**
 * create a route with route params, like /users/:user/info 
 * and pass the route param with input_data
 */
function exact_with_route_param(string $selected_route, string $handler_script) {
    global $INPUT_DATA, $ROUTE;
    $preprocess = function (string $raw_route) {
        $splitted = preg_split("/\//", $raw_route);
        $splitted = array_filter($splitted, function($v, $k) {
            return !is_empty_string($v);
        }, ARRAY_FILTER_USE_BOTH);
        return array_values($splitted);
    };
    $params_parts = $preprocess($selected_route);
    $route_parts = $preprocess($ROUTE);
    // log_httpd(json_encode($params_parts));
    // log_httpd(json_encode($route_parts));

    $extra_params = [];
    if (count($params_parts) == count($route_parts)) {
        for ($i = 0; $i < count($params_parts); $i++) {
            if (str_starts_with($params_parts[$i], ":")) {
                $extra_params[substr($params_parts[$i], 1)] = $route_parts[$i];
            } else {
                if (strcmp($params_parts[$i], $route_parts[$i]) != 0) {
                    return;
                }
            }
        }
    } else {
        return;
    }
    if (mark_routed()) return;
    $INPUT_DATA = array_merge_recursive($INPUT_DATA, $extra_params);
    execphp($handler_script);
}

ob_start(); // saporra appenda os echo num buffer pq nessa fase ainda não tem nada retornado

// ==================================== ROTAS ===============================

exact_route("/phpinfo", "phpinfo.php");
exact_route("/image", "image.php");

use_route("/", "index.php");

// ==================================== Finalização =========================

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
