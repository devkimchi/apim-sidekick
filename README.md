# Demo for APIM as a Sidekick #

This is the sample app repository to demo APIM as a Sidekick.


## Prerequisites ##

* [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli?WT.mc_id=dotnet-91703-juyoo)
* [Bicep CLI](https://learn.microsoft.com/azure/azure-resource-manager/bicep/install?WT.mc_id=dotnet-91703-juyoo)
* [GitHub CLI](https://cli.github.com/manual/installation)
* [Azure Developer CLI](https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd?WT.mc_id=dotnet-91703-juyoo)
* [Azure Functions Core Tools](https://learn.microsoft.com/azure/azure-functions/functions-run-local?WT.mc_id=dotnet-91703-juyoo)
* [Static Web App CLI](https://azure.github.io/static-web-apps-cli/docs/use/install)
* [PowerShell](https://learn.microsoft.com/powershell/scripting/install/installing-powershell?WT.mc_id=dotnet-91703-juyoo)


## Getting Started ##

1. Fork this repository to your account

2. Prepare the following secrets:

   * [Google Maps API Key](https://developers.google.com/maps/documentation/maps-static) ➡️ `MAPS_GOOGLE_API_KEY`
   * [Kakao API Client ID](https://developers.kakao.com/) ➡️ `KAKAO_CLIENTID`
   * [Kakao API Client Secret](https://developers.kakao.com/) ➡️ `KAKAO_CLIENTSECRET`

3. Run the following commands step-by-step:

   1. `azd login`
   2. `azd init`
   3. `gh auth login`
   4. `azd pipeline config`
   5. `azd up`
   6. `gh workflow run "Azure Dev" --repo $GITHUB_USERNAME/apim-sidekick` ⬅️ `$GITHUB_USERNAME` is your GitHub username

4. Access to your API Management console: `https://apim-{{AZURE_ENV_NAME}}.azure-api.net` ⬅️ Check your `.env` file to get `AZURE_ENV_NAME`


## GitHub Codespaces ##

If you want to run this repository, run the following command to configure your Swagger UI working.

```bash
# Update local.settings.json
pwsh -c "Invoke-RestMethod https://aka.ms/azfunc-openapi/add-codespaces.ps1 | Invoke-Expression"
```
