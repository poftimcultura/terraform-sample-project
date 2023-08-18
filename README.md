#### Set up Azure Connection

1. Connect to Azure:

```
az login
```

2. Check current account:

```
az account show
```

#### Create Terraform Project

3. Create main.tf (name it whatever you want) and include provider configuration:

```
terraform {
	required_providers {
		azurerm = {
		source = "hashicorp/azurerm"
		version = "=3.0.0" # update version
		}
	}
}

provider "azurerm" {
	features {}
}

# add resources below
```

4. To add resources, use [Azure Provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

5. Initialise Terraform project:

```
terraform init
```

6. Format .tf files:

```
terraform fmt
```

> Before applying a new configuration, check the plan:

```
terraform plan
```

7. Create resources:

```
terraform apply
```

> Skip manual approval:

```
terraform apply -auto-approve
```

> Update the state without making changes to the infrastructure:

```
terraform apply -refresh-only
```

> Before destroying resources, check the plan:

```
terraform plan -destroy
```

8. Destroy resources

```
terraform apply -destroy
```

#### Terraform State

> Definition: \*Terraform must store state about your managed infrastructure and configuration. This state is used by Terraform to map real world resources to your configuration, keep track of metadata, and to improve performance for large infrastructures.

1. List all the resources from the current state:

```
terraform state list
```

2. Show detailed info about a resource:

```
terraform state show <resource-name>
```

> Read [Terraform State documentation](https://developer.hashicorp.com/terraform/language/state)

> Note: Provisioners are not picked up by the state, so make sure you replace the resource (ex: virtual machine) after configuring a provisioner:

```
terraform apply -replace <resource>
```

#### Filebase64 - Add custom scripts to your VM config

> Create a .tpl file, write your custom script (ex: install Docker on VM), and then import the .tpl file to the virtual machine configuration, using filebase64:

```
custom-data = filebase64("custom-data.tpl")
```

#### Data Sources

> Definition: \*Data sources allow Terraform to use information defined outside of Terraform, defined by another separate Terraform configuration, or modified by functions.

1. Create data source:

```
data "<data-type>" "<data-name>" {
	<key> = <value>
}
```

2. Update the state:

```
terraform apply -refresh-only
```

### Output Values

> Definition: \*Output values make information about your infrastructure available on the command line, and can expose information for other Terraform configurations to use. Output values are similar to return values in programming languages.

1. Create output value:

```
output "<output-name>" {
	value = "<value>"
}
```

2. Update the state:

```
terraform apply -refresh-only
```

### Variables

> Definition: \*Input variables let you customize aspects of Terraform modules without altering the module's own source code. This functionality allows you to share modules across different Terraform configurations, making your module composable and reusable.

1. Define variables in .tf file:

```
variable "<variable-name>" {
	type = <type>
	default = "<default-value>"
}
```

2. Store values in local .tfvars file:

```
<variable-name> = "<value>"
```

> .tfvars is a sensitive file - should not be included in commits.

3. Use variables Terraform resource configurationsL

```
var.<variable-name>
```

#### Conditions

> Definition: \*A *conditional expression* uses the value of a boolean expression to select one of two values.

```
condition ? true_val : false_val
```
