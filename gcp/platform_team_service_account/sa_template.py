def GenerateConfig(context):
    resources = [{
        'type': 'iam.v1.serviceAccount',
        'name': 'ServiceAccount',
        'properties': {
            'accountId': ''.join(context.properties['customerIdentifier'],'/',
                                context.properties['projectIdentifier'],'/',
                                context.properties['account_name']),
            'displayName': ''.join(context.properties['customerIdentifier'],'/',
                                context.properties['projectIdentifier'],'/',
                                context.properties['account_name'])
    }
    }]
    return {'resources': resources}
