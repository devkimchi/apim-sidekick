targetScope = 'subscription'

param name string
param location string = 'Korea Central'

param apiManagementPublisherName string = 'APIM Sidekick Demo'
param apiManagementPublisherEmail string = 'apim@contoso.com'

@secure()
param gitHubUsername string
param gitHubRepositoryName string
param gitHubBranchName string = 'main'

var apps = [
    {
        isFunctionApp: true
        suffix: 'maps'
        apiName: 'MAPS'
        apiPath: 'maps'
        apiBackendUrl: 'https://fncapp-{{AZURE_ENV_NAME}}-maps.azurewebsites.net/api'
        apiFormat: 'openapi-link'
        apiExtension: 'yaml'
        apiOperations: []
    }
    {
        isFunctionApp: false
        suffix: 'kakao'
        apiName: 'KAKAO'
        apiPath: 'kakao'
        apiBackendUrl: 'https://kapi.kakao.com'
        apiFormat: 'openapi-link'
        apiExtension: 'yaml'
        apiOperations: [
            {
                name: 'AccessToken'
                policy: {
                    format: 'xml-link'
                    value: 'https://raw.githubusercontent.com/${gitHubUsername}/${gitHubRepositoryName}/${gitHubBranchName}/infra/apim-policy-api-kakao-op-accesstoken.xml'
                }
            }            
            {
                name: 'Profile'
                policy: {
                    format: 'xml-link'
                    value: 'https://raw.githubusercontent.com/${gitHubUsername}/${gitHubRepositoryName}/${gitHubBranchName}/infra/apim-policy-api-kakao-op-profile.xml'
                }
            }            
        ]
    }
]
var storageContainerName = 'openapis'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
    name: 'rg-${name}'
    location: location
}

module sttapp './staticWebApp.bicep' = {
    name: 'StaticWebApp'
    scope: rg
    params: {
        name: name
        location: 'eastasia'
    }
}

module apim './provision-apiManagement.bicep' = {
    name: 'ApiManagement'
    scope: rg
    params: {
        name: name
        location: location
        storageContainerName: storageContainerName
        gitHubUsername: gitHubUsername
        gitHubRepositoryName: gitHubRepositoryName
        apiMgmtPublisherName: apiManagementPublisherName
        apiMgmtPublisherEmail: apiManagementPublisherEmail
        apiMgmtPolicyFormat: 'xml-link'
        apiMgmtPolicyValue: 'https://raw.githubusercontent.com/${gitHubUsername}/${gitHubRepositoryName}/${gitHubBranchName}/infra/apim-policy-global.xml'
        staticWebAppHostname: sttapp.outputs.hostname
    }
}

module fncapps './provision-functionApp.bicep' = [for (app, index) in apps: if(app.isFunctionApp == true) {
    name: 'FunctionApp_${app.suffix}'
    scope: rg
    dependsOn: [
        apim
    ]
    params: {
        name: name
        suffix: app.suffix
        location: location
        storageContainerName: storageContainerName
        apimApiPath: app.apiPath
    }
}]

module apis './provision-apiManagementApi.bicep' = [for (app, index) in apps: {
    name: 'ApiManagementApi_${app.suffix}'
    scope: rg
    dependsOn: [
        apim
        fncapps
    ]
    params: {
        name: name
        location: location
        apiMgmtNameValueName: 'X_FUNCTIONS_KEY_${replace(toUpper(app.apiName), '-', '_')}'
        apiMgmtNameValueDisplayName: 'X_FUNCTIONS_KEY_${replace(toUpper(app.apiName), '-', '_')}'
        apiMgmtNameValueValue: 'to_be_replaced'
        apiMgmtApiName: app.apiName
        apiMgmtApiDisplayName: app.apiName
        apiMgmtApiDescription: app.apiName
        apiMgmtApiServiceUrl: app.apiBackendUrl
        apiMgmtApiPath: app.apiPath
        apiMgmtApiFormat: app.apiFormat
        apiMgmtApiValue: 'https://raw.githubusercontent.com/${gitHubUsername}/${gitHubRepositoryName}/${gitHubBranchName}/infra/openapi-${replace(toLower(app.apiName), '-', '')}.${app.apiExtension}'
        apiMgmtApiPolicyFormat: 'xml-link'
        apiMgmtApiPolicyValue: 'https://raw.githubusercontent.com/${gitHubUsername}/${gitHubRepositoryName}/${gitHubBranchName}/infra/apim-policy-api-${replace(toLower(app.apiName), '-', '')}.xml'
        apiMgmtProvisionOpenApiOperations: app.isFunctionApp
        apiManagementApiOperations: app.apiOperations
    }
}]
