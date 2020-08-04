# How to setup the default blueprint via the CLI
1. Copy the files to somewhere where you can access them with your az cli
2. execute the followind command with your az cli
´´´bash
az blueprint create --name <blueprint-name> --parameters blueprintparams.json -m <management-group>
3. Each artifact needs to be added to the blueprint
´´´bash
az blueprint artifact policy create --blueprint-name <blueprint-name> --artifact-name "tagCustomerIdentifier" --policy-definition-id '/providers/Microsoft.Authorization/policyDefinitions/49c88fc8-6fd1-46fd-a676-f12d1d3a4c71' --display-name "Apply customerIdentifier Tag and its default value to resource groups" --description "Apply customerIdentifier Tag and its default value to resource groups" --parameters customerIdentifier.json --management-group=<management-group>
´´´bash
az blueprint artifact policy create --blueprint-name <blueprint-name> --artifact-name "tagProjectIdentifier" --policy-definition-id '/providers/Microsoft.Authorization/policyDefinitions/49c88fc8-6fd1-46fd-a676-f12d1d3a4c71' --display-name "Apply projectIdentifier Tag and its default value to resource groups" --description "Apply projectIdentifier Tag and its default value to resource groups" --parameters projectIdentifier.json --management-group=<management-group>
´´´bash
az blueprint artifact policy create --blueprint-name <blueprint-name> --artifact-name "tagCostCenter" --policy-definition-id '/providers/Microsoft.Authorization/policyDefinitions/49c88fc8-6fd1-46fd-a676-f12d1d3a4c71' --display-name "Apply tagCostCenter Tag and its default value to resource groups" --description "Apply tagCostCenter Tag and its default value to resource groups" --parameters tagCostCenter.json --management-group=<management-group>

# How to setup the default blueprint via the Powershell
