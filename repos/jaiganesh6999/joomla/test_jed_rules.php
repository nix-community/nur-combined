<?php
/**
 * JED Checker Rule Simulation for SEOWebChecker
 */

$xmlFile = __DIR__ . '/seowebchecker/seowebchecker.xml';
if (!file_exists($xmlFile)) {
    die("XML manifest not found: $xmlFile\n");
}

$xml = simplexml_load_file($xmlFile);
if (!$xml) {
    die("Failed to parse XML: $xmlFile\n");
}

echo "=========================================================\n";
echo " Simulating JED Checker Rules on SEOWebChecker Joomla Plugin\n";
echo "=========================================================\n\n";

$errors = [];
$warnings = [];

// 1. Root & Attributes
if ((string)$xml['type'] !== 'plugin') $errors[] = "type must be plugin";
if ((string)$xml['group'] !== 'system') $errors[] = "group must be system";
if ((string)$xml['method'] !== 'upgrade') $warnings[] = "method should be upgrade";

// 2. Name Checks (XmlInfoRule)
$name = (string)$xml->name;
echo "[CHECK] Extension Name: '$name'\n";
if (preg_match('/^\s*(?:mod|com|plg|tpl|pkg)_/i', $name)) {
    $errors[] = "Name contains forbidden prefix (mod_, com_, plg_, etc.): $name";
}
if (preg_match('/\b(?:module|plugin|component|template|extension|free)\b/i', $name, $m)) {
    $errors[] = "Name contains reserved keyword: " . $m[0];
}
$parts = explode(' - ', $name, 2);
$group = (string)$xml['group'];
$prefixGroup = isset($parts[1]) ? strtolower(preg_replace('/\s/', '', $parts[0])) : false;
if ($prefixGroup !== $group) {
    $warnings[] = "Plugin name format should match 'Group - Name' (e.g. 'System - SEOWebChecker'). Found '$prefixGroup' vs group '$group'";
}

// 3. Update Servers (XmlUpdateServerRule - US1)
echo "[CHECK] Update Servers (US1)...\n";
if (!isset($xml->updateservers) || !isset($xml->updateservers->server)) {
    $errors[] = "US1: <updateservers> or <server> tag is missing";
} else {
    foreach ($xml->updateservers->server as $server) {
        $serverUrl = (string)$server;
        if (stripos($serverUrl, 'http') === false) {
            $errors[] = "US1: Server URL must be http/https: $serverUrl";
        } else {
            echo "  Found update server: $serverUrl\n";
        }
    }
}

// 4. License Checks (XmlLicenseRule - PH3)
echo "[CHECK] License tag (PH3)...\n";
$lic = (string)$xml->license;
if (empty($lic)) {
    $errors[] = "PH3: <license> tag is missing";
} elseif (stripos($lic, 'gpl') === false && stripos($lic, 'general public license') === false) {
    $warnings[] = "PH3: License should state GPL: $lic";
} else {
    echo "  Valid GPL license: $lic\n";
}

// 5. File Manifest Checks (XmlFilesRule)
echo "[CHECK] Declared Files & Folders (XmlFilesRule)...\n";
$baseDir = __DIR__ . '/seowebchecker';
if (isset($xml->files)) {
    foreach ($xml->files->folder as $folder) {
        $path = $baseDir . '/' . (string)$folder;
        if (!is_dir($path)) $errors[] = "Declared folder does not exist: $folder";
        else echo "  Folder exists: $folder\n";
    }
    foreach ($xml->files->filename as $filename) {
        $path = $baseDir . '/' . (string)$filename;
        if (!file_exists($path)) $errors[] = "Declared file does not exist: $filename";
        else echo "  File exists: $filename\n";
    }
}

// 6. Language Files
echo "[CHECK] Language Files...\n";
if (isset($xml->languages)) {
    $langFolder = (string)$xml->languages['folder'] ?? '';
    foreach ($xml->languages->language as $lang) {
        $langPath = $baseDir . '/' . ($langFolder ? $langFolder . '/' : '') . (string)$lang;
        if (!file_exists($langPath)) $errors[] = "Language file does not exist: $langPath";
        else echo "  Language file exists: $lang\n";
    }
}

// 7. PHP File Headers & _JEXEC (PH1 & PH2)
echo "[CHECK] PHP Headers (PH1) & JEXEC (PH2)...\n";
$rdi = new RecursiveDirectoryIterator($baseDir);
$rii = new RecursiveIteratorIterator($rdi);
foreach ($rii as $file) {
    if ($file->isFile() && $file->getExtension() === 'php') {
        $content = file_get_contents($file->getPathname());
        $relName = substr($file->getPathname(), strlen($baseDir) + 1);
        if (stripos($content, '_JEXEC') === false) {
            $errors[] = "PH2: File missing '_JEXEC' check: $relName";
        }
        if (stripos($content, 'license') === false && stripos($content, 'gnu') === false) {
            $errors[] = "PH1: File missing license header: $relName";
        }
        echo "  PHP verified: $relName\n";
    }
}

// 8. index.html in every directory
echo "[CHECK] index.html in all directories...\n";
$allDirs = new RecursiveIteratorIterator(
    new RecursiveDirectoryIterator($baseDir, RecursiveDirectoryIterator::SKIP_DOTS),
    RecursiveIteratorIterator::SELF_FIRST
);
foreach ($allDirs as $item) {
    if ($item->isDir()) {
        $indexHtml = $item->getPathname() . '/index.html';
        if (!file_exists($indexHtml)) {
            $warnings[] = "Directory missing index.html: " . substr($item->getPathname(), strlen($baseDir) + 1);
        } else {
            echo "  Found index.html in " . substr($item->getPathname(), strlen($baseDir) + 1) . "\n";
        }
    }
}

echo "\n---------------------------------------------------------\n";
echo "SUMMARY:\n";
echo "Errors: " . count($errors) . "\n";
foreach ($errors as $e) echo "  [ERROR] $e\n";
echo "Warnings: " . count($warnings) . "\n";
foreach ($warnings as $w) echo "  [WARNING] $w\n";

if (empty($errors)) {
    echo "\n>>> ALL JED CHECKER REQUIREMENTS PASSED! <<<\n";
} else {
    echo "\n>>> FAILED: Fix the above errors. <<<\n";
    exit(1);
}
