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
    if (strlen($_header) == 0) {
        break;
    }
    $_header_name = explode(":", $_header)[0];
    $_header_name = strtoupper($_header_name);
    $_header_name = str_replace("-", "_", $_header_name);

    $_header_value = substr($_header, strlen($_header_name)+1);
    $_header_value = trim($_header_value);

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

function content_scope_push() {
    ob_start();
}

function content_scope_pop() {
    $data = ob_get_contents();
    ob_end_clean();
    return $data;
}

function content_scope_pop_markdown() {
    content_html(); // would be always html anyway
    $lines = content_scope_pop();

    $lines = preg_replace("/\n\#/", "\n\n#", $lines);
    $lines = preg_replace("/\n+/", "\n", $lines);

    $lines = preg_replace('/\*\*(.*)\*\*/', '<b>\\1</b>', $lines);
    $lines = preg_replace('/\_\_(.*)\_\_/', '<b>\\1</b>', $lines);
    $lines = preg_replace('/\*(.*)\*/', '<em>\\1</em>', $lines);
    $lines = preg_replace('/\_(.*)\_/', '<em>\\1</em>', $lines);
    $lines = preg_replace('/\~(.*)\~/', '<del>\\1</del>', $lines);

    while (true) {
        if (!preg_match('/\!\[([^\]]*?)\]\(([a-z]*:\/\/([a-z-0-9]*\.?)+(:[0-9]+)?[^\s\)]*)\)/m', $lines, $link_found, 0)) {
            break;
        }
        $search_term = $link_found[0];
        $label = $link_found[1];
        $link = $link_found[2];
        $json = json_encode($link_found);
        content_scope_push();
        echo '<img alt="';
        echo $label;
        echo '" title="';
        echo $label;
        echo '" src="';
        echo $link;
        echo '">';
        $replace_term = content_scope_pop();
        $lines = str_replace($search_term, $replace_term, $lines);
    }
    while (true) {
        if (!preg_match('/[\(\s]([a-z]*:\/\/([a-z-0-9]*\.?)+(:[0-9]+)?[^\s\)]*)[\)\s]/m', $lines, $link_found, PREG_OFFSET_CAPTURE, 0)) {
            break;
        }
        $link = substr($link_found[0][0], 1, -1);
        $offset = $link_found[0][1] + 1;
        error_log("match: link='$link' offset='$offset'");
        if (substr($lines, $offset - 2, 2) == "](") {
            $exploded_label = explode("[", substr($lines, 0, $offset - 2));
            $label = $exploded_label[array_key_last($exploded_label)];
            $search_term = "[" . $label . "](" . $link . ")";
            content_scope_push();
            echo '<a href="';
            echo $link;
            echo '">';
            echo $label;
            echo "</a>";
            $replace_term = content_scope_pop();
            $lines = str_replace($search_term, $replace_term, $lines);
        } else {
            $search_term = $link;
            content_scope_push();
            echo '<a href="';
            echo $link;
            echo '">';
            echo $link;
            echo '</a>';
            $replace_term = content_scope_pop();
            $lines = str_replace($search_term, $replace_term, $lines);
        }
    }

    content_scope_push(); // output accumulator
    // $replaces = array()

    $lines = explode("\n", $lines);

    foreach ($lines as $i => $line) {
        $line = trim($line);
        if ($line == "") {
            continue;
        }
        $tag = 'p';
        preg_match('/^#*/', $line, $heading_level);
        $heading_level = strlen($heading_level[0]);

        if ($heading_level > 0) {
            $tag = "h$heading_level";
            $line = substr($line, $heading_level);
            $line = trim($line);
        } else {
            preg_match('/^>*/', $line, $blockquote_level);
            $blockquote_level = strlen($blockquote_level[0]);
            $line = substr($line, $blockquote_level);
            $line = trim($line);
            for ($i = 0; $i < $blockquote_level; $i++) {
                $line = "<blockquote>$line</blockquote>";
            }
        }
        $line = "<$tag>$line</$tag>";
        echo $line;
    }
    return content_scope_pop();
}

content_scope_push(); // saporra appenda os echo num buffer pq nessa fase ainda não tem nada retornado

// ==================================== ROTAS ===============================

exact_route("/phpinfo", "phpinfo.php");
exact_route("/image", "image.php");
exact_route("/scope_test", "scope_test.php");
exact_route("/markdown_teste", "markdown_teste.php");

use_route("/", "index.php");

// ==================================== Finalização =========================

$data = content_scope_pop();

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
