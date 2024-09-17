# luca.dobson.pw

This is everything needed for Luca's WordPress website. This project includes the Terraform scripts to handle building the infrastructure, the WordPress theme that the website uses, GitHub actions to handle the deployment of the theme and a local Docker setup to allow modifications to the theme.

## Setting up the infrastructure with Terraform

This section covers how to create the infrastructure for the website using Terraform. This only has to be done once, because at that point your infrastructure will be deployed. Using Terraform is convienient because it also allows easy destruction of the insfrastructure should you ever want to get rid of it quickly.

### Prerequisites

- [Terraform CLI](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [AWS Account](https://aws.amazon.com/free) and [associated credentials](https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html) that allow you to create resources
- [Create and download a key pair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/create-key-pairs.html) to use with your EC2 instance

For the AWS credentials, I use the Access Key from an IAM user assigned to a group with the permissions found below:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:Describe*",
                "ec2:RunInstances",
                "ec2:TerminateInstances",
                "ec2:StopInstances",
                "ec2:StartInstances",
                "ec2:CreateSecurityGroup",
                "ec2:DeleteSecurityGroup",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:RevokeSecurityGroupIngress",
                "ec2:AuthorizeSecurityGroupEgress",
                "ec2:RevokeSecurityGroupEgress",
                "ec2:CreateKeyPair",
                "ec2:DeleteKeyPair",
                "ec2:CreateTags",
                "ec2:DeleteTags",
                "ec2:AllocateAddress",
                "ec2:ReleaseAddress",
                "ec2:AssociateAddress",
                "ec2:DisassociateAddress",
                "ec2:CreateVolume",
                "ec2:DeleteVolume",
                "ec2:AttachVolume",
                "ec2:DetachVolume",
                "ec2:DescribeVolumes"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::your-bucket-name",
                "arn:aws:s3:::your-bucket-name/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:GetPolicy",
                "iam:GetPolicyVersion",
                "iam:GetUser",
                "iam:ListAttachedUserPolicies",
                "iam:ListAttachedGroupPolicies",
                "iam:ListAttachedRolePolicies",
                "iam:ListAttachedRolePolicies",
                "iam:ListGroupPolicies",
                "iam:ListRolePolicies",
                "iam:ListUserPolicies",
                "iam:GetUserPolicy",
                "iam:GetRolePolicy",
                "iam:GetGroupPolicy",
                "iam:ListAttachedRolePolicies",
                "iam:ListAttachedUserPolicies",
                "iam:ListAttachedGroupPolicies",
                "iam:ListAttachedUserPolicies",
                "iam:ListAttachedGroupPolicies"
            ],
            "Resource": "*"
        }
    ]
}
```

To use your IAM credentials to authenticate the Terraform AWS provider, set the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables:

```bash
export AWS_ACCESS_KEY_ID=<ACCESS_KEY_HERE>
export AWS_SECRET_ACCESS_KEY=<SECRET_ACCESS_KEY_HERE>
```

### Create the infrastructure

First, `cd` into the `terraform/` folder. Next, initialize the directory:

```bash
terraform init
```

This will download and install the AWS provider. Terraform downloads the `aws` provider and installs it in a hidden subdirectory of your current working directory, named `.terraform`. The `terraform init` command prints out which version of the provider was installed. Terraform also creates a lock file named `.terraform.lock.hcl` which specifies the exact provider versions used, so that you can control when you want to update the providers used for your project.

Next, we want to validate our configuration using:

```bash
terraform validate
```

This will ensure that our configuration is syntactically valid and internally consistent.

Finally, apply the configuration (create the EC2 instance) with:

```bash
terraform apply
```

Before it applies any changes, Terraform prints out the execution plan which describes the actions Terraform will take in order to change your infrastructure to match the configuration.

Terraform will now pause and wait for your approval before proceeding. If anything in the plan seems incorrect or dangerous, it is safe to abort here before Terraform modifies your infrastructure.

When you are ready to proceed, simply type `yes` at the confirmation prompt. Executing the plan will take a few minutes since Terraform waits for the EC2 instance to become available.

At this point you will have deployed your infrastructure to AWS.

### Troubleshooting

To view the logs from when your Terraform script executed on the startup of the EC2 instance (specifically the logs from the `user_data` script), you should look at the `cloud-init` logs on the instance. These logs capture the output from the `user_data` script and other initialization activities.

First, SSH into your instance using the `.pem` key that you created during the prerequisites stage of this process. Replace `/path/to/your-key.pem` and `your-instance-public-ip` with your actual key path and IP:

```bash
ssh -i /path/to/your-key.pem ec2-user@your_instance_public_ip
```

To check the `cloud-init` output logs, run the following command:

```bash
sudo cat /var/log/cloud-init-output.log
```

You can also check the main `cloud-init` log, which provides more detailed information about the initialization process, with the following command:

```bash
sudo cat /var/log/cloud-init.log
```

To further troubleshoot, you may want to check the `messages` log file as well:

```bash
sudo cat /var/log/messages
```