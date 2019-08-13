# vault-aws-cloudformation

## Introduction

This repository contains code for building Amazon Machine Images (AMI) and a generic Cloudformation template. The AMI and template can be used to spin up a production-ready Vault cluster.

## What does it build?

The Cloudformation templates published by this pipeline stand up the following configuration:

- VPC with 3 public and 3 private subnets
- Operating system for Vault and Consul is Centos 7
- Operating system for the Bastion host is AWS Linux (latest)
- 3 Vault servers and 5 Consul servers distributed across the private subnets
- A bastion host for connecting to the other servers, which are not directly accessible from the Internet
- A real SSL certificate tied to your FQDN, managed by Amazon Certificate Manager
- Automatic unsealing of Vault using AWS Key Management Service to store the unseal key
- The Vault cluster will be ready in 10-15 minutes. The cluster comes up in an uninitialized state. The API listens on port 8200 and is accessible from the Internet.

## Snippets

These command line snippets are useful for quickly spinning up a new Vault cluster

``` bash
USERNAME="rpeteuil"
SSHKEY="rpeteuil"

aws cloudformation create-stack --region us-east-2 --stack-name "${USERNAME}-Vault-USE2" --capabilities CAPABILITY_IAM --template-url https://hc-cat-app.s3.amazonaws.com/aws_vault_cf.yml --tags Key=owner,Value="${USERNAME}@hashicorp.com" Key=TTL,Value=72 --parameters ParameterKey=FQDN,ParameterValue="${USERNAME}vaulteast.hashidemos.io" ParameterKey=Route53ZoneId,ParameterValue=Z2VGUC188F45PC ParameterKey=ClusterZones,ParameterValue=\"us-east-2a,us-east-2b,us-east-2c\" ParameterKey=SSHKeyName,ParameterValue="$SSHKEY"

aws cloudformation create-stack --region us-west-2 --stack-name "${USERNAME}-Vault-USW2" --capabilities CAPABILITY_IAM --template-url https://hc-cat-app.s3.amazonaws.com/aws_vault_cf.yml --tags Key=owner,Value="${USERNAME}@hashicorp.com" Key=TTL,Value=72 --parameters ParameterKey=FQDN,ParameterValue="${USERNAME}vaultwest.hashidemos.io" ParameterKey=Route53ZoneId,ParameterValue=Z2VGUC188F45PC ParameterKey=ClusterZones,ParameterValue=\"us-west-2a,us-west-2b,us-west-2c\" ParameterKey=SSHKeyName,ParameterValue="$SSHKEY"
```
