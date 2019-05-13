# Turn your logs into actionable data at any scale with AWS

As Enterprises move towards disposable infrastructure, application and platform logs can often be forgotten or lost entirely as servers are replaced. These logs can be an incredible source of information for improving the understanding of your application, troubleshooting application issues, or for triggering external processes such as auto-remediation tasks. However if not captured, this key information is lost as servers are retired or replaced. In this session you will learn how to take action as we use PowerShell and AWS to build a near real-time, serverless data processing platform.

## Deployment

To use these examples, ensure you have setup a [PowerShell Core Development Environment for AWS Lambda](https://docs.aws.amazon.com/lambda/latest/dg/lambda-powershell-setup-dev-environment.html). The [AWS CLI](https://aws.amazon.com/cli/) is also used to help setup the environment.

These code samples are taken "as is" from what was used to present the sessions. There is a base setup script in this folder, ```_setup.ps1``` that includes code to setup some initial variables used throughout the examples, and to deploy some initial infrastructure for some demos that took too long to deploy live.

The template used to deploy the EC2 Instances for this demo relies on a pre-existing VPC and EC2 KeyPair.

## Infrastructure Costs

I have not calculated what costs are associated with the example infrastructure, so be aware that your AWS Account will very likely incur costs associated with these examples.
