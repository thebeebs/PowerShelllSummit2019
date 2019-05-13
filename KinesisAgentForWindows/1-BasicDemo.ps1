<#
    Demonstrate the installation of Kinesis Agent for Windows.

    1. Overview of the configuration file
    2. Overview of the installation script
    3. Deploy the script using AWS Systems Manager
    4. Restart the Windows Update service to generate sample data
    5. Configure AWS Glue to crawl the data source
    6. Query with Amazon Athena
#>

# Look at the appsettings content
code '.\KinesisAgentSetup\appsettings\simple-appsettings.json'

# Run the install using AWS Session Manager
code '.\KinesisAgentSetup\Install-KinesisWithSimple.ps1'

# Create an AWS Glue Crawler using the AWS Console

# Query the Athena Database
#    SELECT * FROM "eventlogs"."systemlog" WHERE eventid = 7036
#    SELECT * FROM "eventlogs"."systemlog" WHERE eventid = 7036 AND description LIKE '%Windows Update%'
