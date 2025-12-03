import kanidm
import asyncio

kanidm_domain = "kanidm.test.example.com"
password = "thisisdefinitelyasecurepassword"

def logit(msg: str):
    print(msg)

async def main() -> None:
    # logit("Generating reset token")
    cli1 = kanidm.KanidmClient(uri=f"https://{kanidm_domain}")
    await cli1.authenticate_password(username="idm_admin", password="test-admin-password", update_internal_auth_token=True)
    token_obj = await cli1.person_account_credential_update_token("testperson")
    token = token_obj.token
    print(token)

asyncio.run(main())

