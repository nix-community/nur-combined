import React from 'react';
import { SeoAuditBadge } from './seo-audit-badge';

/** Default preview testing seowebchecker.com */
export const DefaultTargetAudit = () => {
  return (
    <SeoAuditBadge url="https://seowebchecker.com/" initialScore={98} />
  );
};

/** Interactive sandbox where developers can type any URL to test */
export const InteractiveUrlTester = () => {
  return (
    <SeoAuditBadge
      url="https://example.com/"
      allowCustomUrl={true}
      showDetails={true}
    />
  );
};

/** Pre-configured for client website */
export const CustomClientAudit = () => {
  return (
    <SeoAuditBadge
      url="https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk/"
      initialScore={95}
      showDetails={true}
      allowCustomUrl={false}
    />
  );
};
