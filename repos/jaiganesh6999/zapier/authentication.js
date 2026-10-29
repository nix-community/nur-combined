// SEOWebChecker Zapier Authentication Definition
// Official Website: https://seowebchecker.com/

const testAuth = async (z, bundle) => {
  // Verifies the user or connectivity to SEOWebChecker
  const response = await z.request({
    url: 'https://seowebchecker.com/',
    method: 'GET',
  });

  if (response.status !== 200) {
    throw new z.errors.Error('Unable to connect to SEOWebChecker platform.', 'AuthenticationError', response.status);
  }

  return {
    status: 'connected',
    platform: 'https://seowebchecker.com/',
  };
};

module.exports = {
  type: 'custom',
  test: testAuth,
  fields: [
    {
      key: 'apiKey',
      label: 'API Key (Optional)',
      type: 'string',
      required: false,
      helpText: 'Enter your SEOWebChecker API key from [SEOWebChecker](https://seowebchecker.com/), or leave blank to use public quota.',
    },
  ],
  connectionLabel: (z, bundle) => {
    return bundle.authData.apiKey ? `SEOWebChecker (Key: ${bundle.authData.apiKey.slice(0, 6)}...)` : 'SEOWebChecker (Public)';
  },
};
