# How to setup the blueprints with policy definitions via the Powershell
1. Copy the files to somewhere where you can access them with your Azure Powershell
2. Create a new PolicySetDefinition
```
New-AzPolicySetDefinition -Name <policy-name> -PolicyDefinition ./policy-definition/policy-definition.json -Parameter ./policy-definition/policy-params.json -DisplayName "Append meshcloud tags to resource groups" -Description "This custom policy initiative is for appending tags with values to resource groups through meshcloud" -Metadata I{"category": "Tags"}'
```
3. Create a new Blueprint
```
# create a new blueprint and reference it to the $blueprint variable
$blueprint = New-AzBlueprint -Name "<Blueprint-Name>" -BlueprintFile ./blueprint.json

New-AzBlueprintArtifact -Blueprint $blueprint -Name '<Artifact-Name>' -ArtifactFile ./artifact/tags.json
```