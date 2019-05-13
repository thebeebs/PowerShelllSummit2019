#Requires -Modules @{ModuleName='AWSPowerShell.NetCore';ModuleVersion='3.3.498.0'}

# Uncomment to send the input event to CloudWatch Logs
Write-Host (ConvertTo-Json -InputObject $LambdaInput -Compress -Depth 5)

Write-Host 'Using the DynamoDB Table:' $env:TableName

# Set default response
$statusCode = 404
$body = 'Not Found'
$headers = @{ 'Content-Type' = 'text/plain' }

# Load DynamoDB Configurations
$regionEndpoint = [Amazon.RegionEndpoint]::GetBySystemName($env:TableRegion)
$client = [Amazon.DynamoDBv2.AmazonDynamoDBClient]::new($env:AWS_ACCESS_KEY_ID, $env:AWS_SECRET_ACCESS_KEY, $env:AWS_SESSION_TOKEN, $regionEndpoint)
$table = [Amazon.DynamoDBv2.DocumentModel.Table]::LoadTable($client, $env:TableName)

if ($LambdaInput.resource -eq '/get/{language}/{name}')
{
    $json = ConvertTo-Json -Compress -InputObject @{
        code = $LambdaInput.pathParameters.language.ToLower()
        name = $LambdaInput.pathParameters.name.ToLower()
    }
    $document = [Amazon.DynamoDBv2.DocumentModel.Document]::FromJson($json)

    $async = $table.GetItemAsync($document)
    $async.Wait()
    $record = ConvertFrom-Json -InputObject $async.Result.ToJson()

    if (-not [string]::IsNullOrWhitespace($record.Name))
    {
        $statusCode = 200
        $body = ConvertTo-Json -Compress -InputObject ([ordered]@{
                Name        = $record.ModuleName
                Description = $record.Description
                Version     = $record.Version
            })
        $headers = @{ 'Content-Type' = 'application/json' }
    }
}
elseif ($LambdaInput.resource -eq '/get/{language}')
{
    $keyValue = $LambdaInput.pathParameters.language.ToLower()
    $filter = [Amazon.DynamoDBv2.DocumentModel.QueryFilter]::new('code', 'Equal', $keyValue)

    # Create the Query object
    $search = $table.Query($filter)

    # Perform the Query
    $records = [System.Collections.ArrayList]::new()
    do
    {
        $async = $search.GetNextSetAsync()
        $async.Wait()
        $documentSet = $async.Result

        foreach ($document in $documentSet)
        {
            $properties = [ordered]@{}
            foreach ($key in $document.Keys)
            {
                $properties.Add($key, $document[$key])
            }

            $psobject = [PSCustomObject]$properties
            $null = $records.Add($psobject)
        }
    }
    while (-not $search.IsDone)

    # Craft the response object
    if ($records.Count -gt 0)
    {
        $bodyArray = [System.Collections.ArrayList]::new()
        foreach ($record in $records)
        {
            $null = $bodyArray.Add((
                    [PSCustomObject][ordered]@{
                        Name        = $record.ModuleName.Value
                        Description = $record.Description.Value
                        Version     = $record.Version.Value
                    }
                ))
        }

        $statusCode = 200
        $body = ConvertTo-Json -Compress -InputObject $bodyArray
        $headers = @{ 'Content-Type' = 'application/json' }
    }
}
elseif ($LambdaInput.resource -eq '/find/{language}/{query}')
{
    $keyValue = $LambdaInput.pathParameters.language.ToLower()
    $filter = [Amazon.DynamoDBv2.DocumentModel.QueryFilter]::new('code', 'Equal', $keyValue)

    $rangeValue = $LambdaInput.pathParameters.query.ToLower()
    $rangeValueAttribute = [Amazon.DynamoDBv2.Model.AttributeValue]::new($rangeValue)
    $operator = [Amazon.DynamoDBv2.DocumentModel.ScanOperator]::Contains
    $filter.AddCondition('Description', $operator, $rangeValueAttribute)

    # Create the Query object
    $search = $table.Query($filter)

    # Perform the Query
    $records = [System.Collections.ArrayList]::new()
    do
    {
        $async = $search.GetNextSetAsync()
        $async.Wait()
        $documentSet = $async.Result

        foreach ($document in $documentSet)
        {
            $properties = [ordered]@{}
            foreach ($key in $document.Keys)
            {
                $properties.Add($key, $document[$key])
            }

            $psobject = [PSCustomObject]$properties
            $null = $records.Add($psobject)
        }
    }
    while (-not $search.IsDone)

    # Craft the response object
    if ($records.Count -gt 0)
    {
        $bodyArray = [System.Collections.ArrayList]::new()
        foreach ($record in $records)
        {
            $null = $bodyArray.Add((
                    [PSCustomObject][ordered]@{
                        Name        = $record.ModuleName.Value
                        Description = $record.Description.Value
                        Version     = $record.Version.Value
                    }
                ))
        }

        $statusCode = 200
        $body = ConvertTo-Json -Compress -InputObject $bodyArray
        $headers = @{ 'Content-Type' = 'application/json' }
    }
}

@{
    'statusCode' = $statusCode
    'body'       = $body
    'headers'    = $headers
}