# How to Contribute

## Making Changes to Packer or Cloudformation
The process for building a Cloudformation template is explained in the following steps. Build and test work should all be done in the us-east-1 region, as this is where AWS Cloudformation requires AMIs be built and submitted.

1. Clone this repository to your local workstation and create a new branch for your changes.

```
git clone https://github.com/hashicorp/vault-aws-cloudformation
cd vault-aws-cloudformation
git checkout -b my-feature-branch
```

2. Edit the consul.json and vault.json templates if you require new packer images. Otherwise you may use the AMI image IDs stored in the S3 bucket here. These are the latest images built by the CI/CD pipeline. Note: If you edit these packer templates be sure to bump up the version tag in the beginning of the file. This version bump is what triggers a new build in the CI/CD steps.

https://hashicorp-vault-aws-cloudformation.s3.amazonaws.com/vault_ami_id

https://hashicorp-vault-aws-cloudformation.s3.amazonaws.com/consul_ami_id

3. For local development you may edit the cloudformation template aws_cloudformation_vault.yml, adding in the AMIs you wish to use in the Mappings section of the file. You'll be replacing the lines below with AMI IDs:

```
Mappings:
  RegionMap: 
      us-east-1:
        vault: us-east-1-vault-ami
        consul: us-east-1-consul-ami
```

4. Once you have your Cloudformation template ready for development, you can deploy a dev stack using the AWS console or command line. Here's a command line example:

```
aws cloudformation create-stack --region us-east-1 --stack-name my-vault-stack --capabilities CAPABILITY_IAM --template-body file://cloudformation/aws_cloudformation_vault.yml --tags Key=owner,Value=you@hashicorp.com Key=TTL,Value=24 --parameters ParameterKey=FQDN,ParameterValue=mytestvault.hashidemos.io ParameterKey=ClusterZones,ParameterValue=\"us-east-1a,us-east-1b,us-east-1c\" ParameterKey=Route53ZoneId,ParameterValue=Z2VGUC188F45PC ParameterKey=SSHKeyName,ParameterValue="yoursshkey"
```

5. When you launch your stack everything will deploy automatically except for the DNS verification of your SSL certificate. This manual step is fairly easy if you're using Route 53 for your DNS. After you launch the cloudformation template visit this page and see the status of your SSL certificate:

https://console.aws.amazon.com/acm/home?region=us-east-1#/

If you expand the status of your certificate, you'll see the validation status, along with a blue button that says "Create Record in Route 53". Click on that button and a verification record will be created for you. *The Cloudformation stack will not finish deploying until you do this step!*

6. Wait about 10-15 minutes. Your new Vault cluster and the bastion host IP address will appear in the Outputs section of Cloudformation. Note: It can sometimes take up to 30 minutes for the DNS record to propagate, depending on your provider.

7. Load your new Vault cluster URL in a web browser and initialize your Vault. You may enter 1 and 1 for the number of key shares and recovery shares. This is because we are delegating the unseal process to AWS KMS, and there would be no benefit to having multiple keys.

8. Once you're certain that everything is working the way you like, revert these lines back to their default:

```
Mappings:
  RegionMap: 
      us-east-1:
        vault: us-east-1-vault-ami
        consul: us-east-1-consul-ami
```

9. Commit your changes and push them to the remote branch:

```
git add .
git commit -m "Make some changes."
git push origin my-feature-branch
```

10. Create a pull request via the UI or command line:

```
git request-pull master ./
```

Once you've created a PR a new CircleCI build will kick off for your PR branch.

11.  Visit CircleCI to see the status of the build. If all goes well, the CI/CD pipeline will create a brand new stack with your changes, and run functional tests against it. If all tests pass, you can go ahead and merge your pull request. Another build will run against the master branch post-merge, and if all is successful a new cloudformation template will be published to our S3 bucket for AWS Cloudformation review and approval.
