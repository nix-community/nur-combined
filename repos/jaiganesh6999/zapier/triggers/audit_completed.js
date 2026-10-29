// SEOWebChecker - New Audit Completed Trigger
// Official Platform: https://seowebchecker.com/

const perform = async (z, bundle) => {
  // Return sample recent audit or poll for latest audits
  return [
    {
      id: `audit_sample_1`,
      targetUrl: bundle.inputData.url || 'https://seowebchecker.com/',
      score: 100,
      grade: 'A',
      status: 'PASS',
      isAlert: false,
      title: 'Free SEO Audit Tool — Website SEO Checker',
      metaDescription: 'SEO Web Checker, Run a free website SEO audit in seconds.',
      issuesCount: 0,
      issues: '',
      passesCount: 6,
      auditedAt: new Date().toISOString(),
      platformUrl: 'https://seowebchecker.com/',
    },
  ];
};

module.exports = {
  key: 'auditCompleted',
  noun: 'Audit',
  display: {
    label: 'New Audit Completed',
    description: 'Triggers when a new website SEO audit is performed or updated.',
  },
  operation: {
    perform,
    inputFields: [
      {
        key: 'url',
        label: 'Monitored URL (Optional)',
        type: 'string',
        required: false,
        helpText: 'Filter events for a specific URL, or leave blank to monitor all.',
      },
    ],
    sample: {
      id: 'audit_sample_1',
      targetUrl: 'https://seowebchecker.com/',
      score: 100,
      grade: 'A',
      status: 'PASS',
      isAlert: false,
      title: 'Free SEO Audit Tool — Website SEO Checker',
      metaDescription: 'SEO Web Checker, Run a free website SEO audit in seconds.',
      issuesCount: 0,
      issues: '',
      passesCount: 6,
      auditedAt: '2026-10-05T00:00:00.000Z',
      platformUrl: 'https://seowebchecker.com/',
    },
    outputFields: [
      { key: 'id', label: 'Audit ID' },
      { key: 'targetUrl', label: 'Audited URL' },
      { key: 'score', label: 'SEO Score (0-100)', type: 'integer' },
      { key: 'grade', label: 'SEO Letter Grade' },
      { key: 'status', label: 'Audit Status' },
      { key: 'isAlert', label: 'Is Alert Triggered?', type: 'boolean' },
      { key: 'title', label: 'Title Tag' },
      { key: 'metaDescription', label: 'Meta Description' },
      { key: 'auditedAt', label: 'Timestamp', type: 'datetime' },
      { key: 'platformUrl', label: 'SEOWebChecker Link' },
    ],
  },
};
