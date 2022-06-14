resource "google_service_account" "artimanhas_do_lucaum" {
  account_id   = "artimanhas-do-lucaum"
  display_name = "App Engine default service account"
  project      = "artimanhas-do-lucaum"
}
# terraform import google_service_account.artimanhas_do_lucaum projects/artimanhas-do-lucaum/serviceAccounts/artimanhas-do-lucaum@artimanhas-do-lucaum.iam.gserviceaccount.com
