#Requires -Modules @{ModuleName='AWSPowerShell.NetCore';ModuleVersion='3.3.498.0'}

Write-Host (ConvertTo-Json -InputObject $LambdaInput -Compress -Depth 5)

Write-Host 'Using the DynamoDB Table:' $env:TableName

# Load DynamoDB Configurations
$regionEndpoint = [Amazon.RegionEndpoint]::GetBySystemName($env:TableRegion)
$client = [Amazon.DynamoDBv2.AmazonDynamoDBClient]::new($env:AWS_ACCESS_KEY_ID, $env:AWS_SECRET_ACCESS_KEY, $env:AWS_SESSION_TOKEN, $regionEndpoint)
$table = [Amazon.DynamoDBv2.DocumentModel.Table]::LoadTable($client, $env:TableName)

foreach ($sqsRecord in $LambdaInput.Records)
{
    $snsRecord = ConvertFrom-Json -InputObject $sqsRecord.body

    # Identify the target language from the SQS Queue Arn
    # Queue Name: "<guid>-<language>"
    $targetLanguage = $sqsRecord.eventSourceARN.Split('-')[-1]

    # Read the DynamoDB Table. If the Module Name, Version and Language
    # already exist, skip the record
    $json = ConvertTo-Json -Compress -InputObject @{
        code = $targetLanguage
        name = $snsRecord.Name.ToLower()
    }
    $document = [Amazon.DynamoDBv2.DocumentModel.Document]::FromJson($json)

    # GetItem from DynamoDB
    $async = $table.GetItemAsync($document)
    $async.Wait()
    $record = ConvertFrom-Json -InputObject $async.Result.ToJson()

    if ($record.Version -eq $snsRecord.Version) { continue }

    # Perform the translation
    $splat = @{
        SourceLanguageCode = 'en'
        TargetLanguageCode = $targetLanguage
        Text               = $snsRecord.Description
        ErrorAction        = 'Stop'
    }
    $response = ConvertTo-TRNTargetLanguage @splat

    if ([String]::IsNullOrWhiteSpace($response.TranslatedText))
    {
        Write-Warning 'Unable to translate'
        continue
    }

    # Create the DynamoDB Record
    $dynamoRecord = ConvertTo-Json -Compress -InputObject @{
        code         = $targetLanguage.ToLower()
        name         = $snsRecord.Name.ToLower()
        languagecode = $targetLanguage
        ModuleName   = $snsRecord.Name
        Description  = $response.TranslatedText
        Version      = $snsRecord.Version
    }
    $document = [Amazon.DynamoDBv2.DocumentModel.Document]::FromJson($dynamoRecord)

    # Write the DynamoDB Record
    Write-Host ('Writing the Module {0} with Version {1} and Langauge {2} to the DynamoDB Table' -f $snsRecord.Name, $snsRecord.Version, $targetLanguage)
    $expression = [Amazon.DynamoDBv2.DocumentModel.Expression]::new()
    $expression.ExpressionStatement = "Version <> :evaluation"
    $expression.ExpressionAttributeValues[':evaluation'] = $snsRecord.Version

    $putItemConfiguration = [Amazon.DynamoDBv2.DocumentModel.PutItemOperationConfig]::new()
    $putItemConfiguration.ConditionalExpression = $expression

    $table.PutItemAsync($document, $putItemConfiguration).Wait()
}

# Cleanup
if ($client -and ($client | Get-Member -Name 'Dispose')) { $client.Dispose() }