import { Template } from 'meteor/templating';
import { Meteor } from 'meteor/meteor';
import './main.html';

Template.dashboard.events({
  'submit #auditForm'(event) {
    event.preventDefault();
    const url = document.getElementById('targetUrl').value.trim();
    const btn = document.getElementById('auditBtn');
    const resultsCard = document.getElementById('resultsCard');
    const resultsPre = document.getElementById('resultsPre');

    btn.disabled = true;
    btn.innerHTML = '<i class="fa-solid fa-spinner animate-spin"></i> Auditing...';
    resultsCard.classList.remove('hidden');
    resultsPre.textContent = 'Auditing ' + url + ' via Meteor Server on Galaxy Cloud...';

    Meteor.call('seoaudit.audit', url, (err, res) => {
      btn.disabled = false;
      btn.innerHTML = '<i class="fa-solid fa-magnifying-glass"></i> Run SEO Audit';
      if (err) {
        resultsPre.textContent = 'Error: ' + err.message;
      } else {
        resultsPre.textContent = JSON.stringify(res, null, 2);
      }
    });
  },
});
