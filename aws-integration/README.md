## AWS Integration Training Setup
There are two workflows that can be run in order to create and destory AWS resources needed for AWS Integration Training:
1. `create aws resources`
2. `delete aws resources`

The `create aws resources` workflow creates an AWS Stack using a CloudFormation template that will create the following resources:
* A VPC with one public subnet
* A t2.micro EC2 instance
* An ECS Cluster
* An ECS TaskDefinition
* An ECS Service
* An AWS CloudWatch Log Group
* An S3 Bucket
* An SNS Topic

You can see exactly what the template creates by looking at the [template.yaml file](infrastructure/cloudformation/template.yaml).
The `delete aws resources` workflow will delete the AWS Stack created by the `create aws resources` workflow which will in turn clean up the AWS resources.

## Using the Workflows
In order to use these workflows, you will need to do the following:
1. Create a fork of this repository.
2. Create an IAM user in your AWS account and configure [IAM User Credentials.](https://docs.aws.amazon.com/cli/latest/userguide/cli-authentication-user.html)
    * When creating the credentials, you will need to save the secret access key id as we will need it later.
    * Note: It is important to not share these credentials with anyone as they will grant access to your AWS account. We will store them as secrets in the next step.
3. [Create a Github Environment](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment#creating-an-environment) and configure the following secrets and variable in the environment:
    * An environment secret called AWS_ACCESS_KEY_ID with the value of the access key id created in step 2.
    * An environment secret called AWS_SECRET_ACCESS_KEY with the value of the secret access key id created in step 2.
    * An environment secret called IAM_USER_PASSWORD with an alphanumeric string between 10 and 40 characters. This will be the password of the IAM User(s) that the AWS Stack will create.
    * An environment variable called AWS_REGION with the AWS Region to create the AWS Stack in.

## Running the workflows
With the Github Environment created, we can start to use the actions to deploy our AWS resources. Navigate to the `Actions` tab in your forked repository and click on the `create aws resources` workflow. Once on the `create aws resources` workflow page, select `Run workflow` and choose the Github Environment previously created. Additionally, specify the number of IAM users to create.

When you no longer need the resources in AWS, run the `delete aws resources` workflow targeting the Github Environment that was used when running the `create aws resources` workflow.

***WARNING***: The `delete aws resources` workflow is **VERY** aggressive as it tries to delete all S3 Buckets, CloudWatch Log Groups, and CloudFormation Templates in the targeted AWS account. Please be sure to examine what the workflow does before using it.