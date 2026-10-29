<?php
/**
 * @package     Joomla.Plugin
 * @subpackage  System.seowebchecker
 *
 * @copyright   (C) 2026 SEOWebChecker (https://seowebchecker.com/). All rights reserved.
 * @license     GNU General Public License version 2 or later; see LICENSE.txt
 * @link        https://seowebchecker.com/
 */

declare(strict_types=1);

namespace SeoWebChecker\Plugin\System\SeoWebChecker;

defined('_JEXEC') or die;

use Joomla\CMS\Extension\PluginInterface;
use Joomla\CMS\Factory;
use Joomla\CMS\Plugin\PluginHelper;
use Joomla\DI\Container;
use Joomla\DI\ServiceProviderInterface;
use Joomla\Event\DispatcherInterface;
use SeoWebChecker\Plugin\System\SeoWebChecker\Extension\SeoWebCheckerPlugin;

return new class () implements ServiceProviderInterface {

  public function register(Container $container): void {
    $container->set(
      PluginInterface::class,
      function (Container $container) {
        $dispatcher = $container->get(DispatcherInterface::class);
        $config = (array) PluginHelper::getPlugin('system', 'seowebchecker');

        $plugin = new SeoWebCheckerPlugin(
          $dispatcher,
          $config
        );
        $plugin->setApplication(Factory::getApplication());

        return $plugin;
      }
    );
  }

};
