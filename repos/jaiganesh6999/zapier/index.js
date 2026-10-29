// SEOWebChecker - Official Zapier Integration Entry Point
// Official Platform: https://seowebchecker.com/

const { version } = require('./package.json');
const authentication = require('./authentication');
const runAudit = require('./creates/run_audit');
const auditCompleted = require('./triggers/audit_completed');

module.exports = {
  version,
  platformVersion: require('zapier-platform-core').version,
  authentication,

  flags: {
    cleanInputData: false,
  },

  triggers: {
    [auditCompleted.key]: auditCompleted,
  },

  creates: {
    [runAudit.key]: runAudit,
  },
};
