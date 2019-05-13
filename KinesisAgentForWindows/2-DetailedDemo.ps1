<#
    Demonstrate the installation of Kinesis Agent for Windows.

    1. Update the Kinesis Agent configuration file
    2. Enable PowerShell ScriptBlock Logging
    3. Validate the Kinesis Agent configuration was auto-loaded
    4. Demonstrate processing with AWS Lambda posting CloudWatch Metrics
#>

# Look at the appsettings content
code '.\KinesisAgentSetup\appsettings\detailed-appsettings.json'

# Configure ScriptBlock Logging and restart
code '.\KinesisAgentSetup\Enable-PowerShellLogging.ps1'

# Show the CloudWatch Dashboard

# Install the updated configuration using AWS Session Manager
code '.\KinesisAgentSetup\Install-UpdatedKinesisConfiguration.ps1'

# Show the Lambda Function
code '.\CloudFormation\PowerShellMetrics\PowerShellMetrics.ps1'

# Use AWS Session Manager to run some PowerShell commands

# Evaluate CloudWatch metrics
