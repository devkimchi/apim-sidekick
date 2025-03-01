param name string
param location string = resourceGroup().location

param apiMgmtNameValueName string
param apiMgmtNameValueDisplayName string
@secure()
param apiMgmtNameValueValue string
param apiMgmtApiName string
param apiMgmtApiDisplayName string
param apiMgmtApiDescription string
param apiMgmtApiServiceUrl string
param apiMgmtApiPath string
@allowed([
    'swagger-json'
    'swagger-link-json'
    'openapi'
    'openapi+json'
    'openapi+json-link'
    'openapi-link'
    'wadl-link-json'
    'wadl-xml'
    'wsdl'
    'wsdl-link'
    'graphql-link'
])
param apiMgmtApiFormat string = 'openapi+json-link'
param apiMgmtApiValue string
@allowed([
    'rawxml'
    'rawxml-link'
    'xml'
    'xml-link'
])
param apiMgmtApiPolicyFormat string = 'xml'
param apiMgmtApiPolicyValue string = '<!--\r\n  IMPORTANT:\r\n  - Policy elements can appear only within the <inbound>, <outbound>, <backend> section elements.\r\n  - To apply a policy to the incoming request (before it is forwarded to the backend service), place a corresponding policy element within the <inbound> section element.\r\n  - To apply a policy to the outgoing response (before it is sent back to the caller), place a corresponding policy element within the <outbound> section element.\r\n  - To add a policy, place the cursor at the desired insertion point and select a policy from the sidebar.\r\n  - To remove a policy, delete the corresponding policy statement from the policy document.\r\n  - Position the <base> element within a section element to inherit all policies from the corresponding section element in the enclosing scope.\r\n  - Remove the <base> element to prevent inheriting policies from the corresponding section element in the enclosing scope.\r\n  - Policies are applied in the order of their appearance, from the top down.\r\n  - Comments within policy elements are not supported and may disappear. Place your comments between policy elements or at a higher level scope.\r\n-->\r\n<policies>\r\n  <inbound>\r\n  <base />\r\n  </inbound>\r\n  <backend>\r\n  <base />\r\n  </backend>\r\n  <outbound>\r\n  <base />\r\n  </outbound>\r\n  <on-error>\r\n  <base />\r\n  </on-error>\r\n</policies>'
param apiMgmtProvisionOpenApiOperations bool = false
param apiManagementApiOperations array = [
    {
        name: ''
        policy: {
            format: ''
            value: ''
        }
    }
]

var apiManagement = {
    groupName: 'rg-${name}'
    name: 'apim-${name}'
    location: location
    type: 'http'
    nvName: apiMgmtNameValueName
    nvDisplayName: apiMgmtNameValueDisplayName
    nvValue: apiMgmtNameValueValue
    apiName: apiMgmtApiName
    displayName: apiMgmtApiDisplayName
    description: apiMgmtApiDescription
    serviceUrl: apiMgmtApiServiceUrl
    path: apiMgmtApiPath
    subscriptionRequired: false
    format: apiMgmtApiFormat
    value: apiMgmtApiValue
    policyFormat: apiMgmtApiPolicyFormat
    policyValue: apiMgmtApiPolicyValue
    api: {
        operations: apiManagementApiOperations
    }
    productName: 'default'
}

resource apim 'Microsoft.ApiManagement/service@2021-08-01' existing = {
    name: apiManagement.name
    scope: resourceGroup(apiManagement.groupName)
}

resource apimNamedValue 'Microsoft.ApiManagement/service/namedValues@2021-08-01' = {
    name: '${apim.name}/${apiManagement.nvName}'
    properties: {
        displayName: apiManagement.nvDisplayName
        secret: true
        value: apiManagement.nvValue
    }
}

resource apimapi 'Microsoft.ApiManagement/service/apis@2021-08-01' = {
    name: '${apim.name}/${apiManagement.apiName}'
    properties: {
        type: apiManagement.type
        displayName: apiManagement.displayName
        description: apiManagement.description
        serviceUrl: apiManagement.serviceUrl
        path: apiManagement.path
        subscriptionRequired: apiManagement.subscriptionRequired
        format: apiManagement.format
        value: apiManagement.value
    }
}

resource apimapipolicy 'Microsoft.ApiManagement/service/apis/policies@2021-08-01' = {
    name: '${apimapi.name}/policy'
    properties: {
        format: apiManagement.policyFormat
        value: apiManagement.policyValue
    }
}

resource apimproduct 'Microsoft.ApiManagement/service/products@2021-08-01' existing = {
    name: '${apim.name}/${apiManagement.productName}'
    scope: resourceGroup(apiManagement.groupName)
}

resource apimproductapi 'Microsoft.ApiManagement/service/products/apis@2021-08-01' = {
    name: '${apimproduct.name}/${apiManagement.apiName}'
    dependsOn: [
        apimapi
    ]
}

var operations = [
    {
        provision: apiMgmtProvisionOpenApiOperations
        name: 'openapi-v2-json'
        displayName: 'openapi/v2.json'
        method: 'GET'
        urlTemplate: '/openapi/v2.json'
    }
    {
        provision: apiMgmtProvisionOpenApiOperations
        name: 'openapi-v3-json'
        displayName: 'openapi/v3.json'
        method: 'GET'
        urlTemplate: '/openapi/v3.json'
    }
    {
        provision: apiMgmtProvisionOpenApiOperations
        name: 'swagger-json'
        displayName: 'swagger.json'
        method: 'GET'
        urlTemplate: '/swagger.json'
    }
    {
        provision: apiMgmtProvisionOpenApiOperations
        name: 'swagger-ui'
        displayName: 'swagger/ui'
        method: 'GET'
        urlTemplate: '/swagger/ui'
    }
]

resource apimapioperations 'Microsoft.ApiManagement/service/apis/operations@2021-08-01' = [for op in operations: if(op.provision == true) {
    name: '${apimapi.name}/${op.name}'
    properties: {
        displayName: op.displayName
        method: op.method
        urlTemplate: op.urlTemplate
        templateParameters: []
        responses: []
    }
}]

resource apimapioperationpolicies 'Microsoft.ApiManagement/service/apis/operations/policies@2022-08-01' = [for op in apiManagement.api.operations : {
    name: '${apimapi.name}/${op.name}/policy'
    properties: {
        format: op.policy.format
        value: op.policy.value
    }
}]

output id string = apimapi.id
output name string = apimapi.name
output path string = reference(apimapi.id).path
