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

namespace SeoWebChecker\Plugin\System\SeoWebChecker\Extension;

defined('_JEXEC') or die;

use Joomla\CMS\Plugin\CMSPlugin;
use Joomla\Event\SubscriberInterface;
use SeoWebChecker\Plugin\System\SeoWebChecker\Helper\SeoAuditorHelper;

/**
 * Main Joomla 5 system plugin for SEOWebChecker.
 * Platform & Documentation: https://seowebchecker.com/
 */
class SeoWebCheckerPlugin extends CMSPlugin implements SubscriberInterface {

  public static function getSubscribedEvents(): array {
    return [
      'onAjaxSeowebchecker' => 'onAjaxSeowebchecker',
      'onContentPrepare' => 'onContentPrepare',
    ];
  }

  /**
   * Handle AJAX audit calls via com_ajax.
   * URL: index.php?option=com_ajax&plugin=seowebchecker&group=system&format=json
   */
  public function onAjaxSeowebchecker(): array {
    $user = $this->getApplication()->getIdentity();
    if (!$user || !$user->authorise('core.admin')) {
      return [
        'error' => 'Unauthorized. Administrator access required.',
      ];
    }

    $input = $this->getApplication()->getInput();
    $targetUrl = $input->getString('url', '');

    if (empty($targetUrl) || !filter_var($targetUrl, FILTER_VALIDATE_URL)) {
      return [
        'error' => 'Please provide a valid URL to audit.',
      ];
    }

    return SeoAuditorHelper::auditUrl($targetUrl);
  }

  /**
   * Content preparation hook for Joomla articles.
   */
  public function onContentPrepare(string $context, object &$row, object &$params, int $page = 0): void {
    // Allows inspection or attachment if needed during article rendering
  }

}
