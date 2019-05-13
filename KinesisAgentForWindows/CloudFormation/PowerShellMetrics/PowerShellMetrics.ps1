#Requires -Modules @{ModuleName='AWSPowerShell.NetCore';ModuleVersion='3.3.498.0'}

# A Kinesis Stream processor will receive multiple records per execution
foreach ($record in $LambdaInput.Records) {

    # A Kinesis Stream Record is UTF8 Base64 encoded
    $bytes = [System.Convert]::FromBase64String($record.kinesis.data)
    $data = [System.Text.Encoding]::UTF8.GetString($bytes)

    $eventRecord = ConvertFrom-Json -InputObject $data
    Write-Host 'Found an Event Record with EventId:' $eventRecord.EventId

    if ($eventRecord.EventId -ne '4104') { continue }

    # Find the scriptblock in the EventLog Record
    $scriptblock = $eventRecord.Description -split ('\r\n') | Select-Object -Skip 1 | Select-Object -SkipLast 2

    $errors = $null
    $tokens = [System.Management.Automation.PSParser]::Tokenize($scriptblock, [ref]$errors)

    if ($errors.Count -gt 0) {
        Write-Host 'Error found in the scriptblock. Skipping...'
        continue
    }

    # Hashtable to hold a list of commands and their execution counts
    $commandHash = @{}

    # Count the number of executions for each "Command"
    $tokens.Where( {$_.Type -eq 'Command'} ).foreach({

            # $_.Content is the name of the PowerShell Command that was invoked
            $commandName = $_.Content.ToLower()
            Write-Host "Processing the command $commandName"

            if ($commandHash.ContainsKey($commandName)) {
                $commandHash[$commandName]++
            }
            else {
                $commandHash[$commandName] = 1
            }
        })

    if ($commandHash.Keys.Count -gt 0) {
        Write-Host (ConvertTo-Json -InputObject $commandHash)
    }

    # Post CloudWatch Metrics
    $counter = 0
    $commandHash.Keys.ForEach( {
            $dimension = [Amazon.CloudWatch.Model.Dimension]::new()
            $dimension.Name = 'Command'
            $dimension.Value = $_

            $metric = [Amazon.CloudWatch.Model.MetricDatum]::new()
            $metric.Timestamp = $eventRecord.TimeCreated
            $metric.Dimensions = $dimension
            $metric.MetricName = 'NumberOfExecutions'
            $metric.Value = $commandHash[$_]

            try {
                Write-CWMetricData -Namespace 'PowerShellExecutionStats' -MetricData $metric
                $counter++
            }
            catch {
                Write-Warning -Message ('Exception caught: {0}' -f $_.Exception.Message)
            }
        })

    Write-Host ('Posted {0} metrics to CloudWatch.' -f $counter.ToString())
}
