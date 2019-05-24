<?php // /!\ Important: There must be no blank space before &lt;?php or after ?&gt;
// This file was inspired from the spip contrib website
// http://www.spip.net/fr_article3811.html

$config_dir = getenv('SPIP_CONFIG_DIR') . '/';
$var_dir = getenv('SPIP_VAR_DIR') . '/';

$cookie_prefix = str_replace('.', '_', getenv("SPIP_SITE"));
$table_prefix = 'spip';

spip_initialisation(
        $config_dir,
        _DIR_RACINE . _NOM_PERMANENTS_ACCESSIBLES,
        $var_dir . _NOM_TEMPORAIRES_INACCESSIBLES,
        _DIR_RACINE . _NOM_TEMPORAIRES_ACCESSIBLES
);

?>
