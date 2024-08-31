# govtech-assessment2

## Terraform AWS Lambda API

This repository contains Terraform configuration files to deploy an AWS Lambda function and expose it via API Gateway. The Lambda function returns a list of users in JSON format.

## Prerequisites

- Terraform installed
- AWS account with appropriate permissions
- AWS CLI configured with your credentials

### Getting Started

#### Initialise Terraform
```terraform init```

#### Apply the deployment
```terraform apply```

#### Access the API URL that is generated in your terminal or access it via this URL: https://yt8dlhsezf.execute-api.ap-southeast-1.amazonaws.com/users

#### Clean up your resources
```terraform destroy```