import type { Plugin } from 'vite';

export interface SeoWebCheckerPluginOptions {
  /**
   * Fail the Vite build process if critical SEO errors are detected.
   * @default false
   */
  failOnError?: boolean;

  /**
   * Minimum overall SEO score (0-100) required to pass the build.
   * @default 0
   */
  minScore?: number;

  /**
   * Print detailed diagnostic reports to the terminal console during build.
   * @default true
   */
  verbose?: boolean;

  /**
   * Paths or patterns to exclude from SEO auditing.
   * @default []
   */
  ignorePaths?: Array<string | RegExp>;
}

/**
 * Vite plugin for automated on-page technical SEO audits powered by SEOWebChecker.
 * Official tool: https://seowebchecker.com/
 */
export default function seoWebCheckerPlugin(options?: SeoWebCheckerPluginOptions): Plugin;
export { seoWebCheckerPlugin };
