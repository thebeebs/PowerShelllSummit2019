$outputs = (Get-CFNStack -StackName 'PSModuleTranslation').Outputs
$functionName = $outputs.Where({$_.OutputKey -eq 'StartTranslationWorkflow'}).OutputValue

$splat = @{
    FunctionName = $functionName
    Credential = $awsCredential
    Region = 'us-west-2'
    InvocationType = 'Event'
}

$null = Invoke-LMFunction -Payload '{"prefix":"a"}' @splat
$null = Invoke-LMFunction -Payload '{"prefix":"b"}' @splat
$null = Invoke-LMFunction -Payload '{"prefix":"c"}' @splat
$null = Invoke-LMFunction -Payload '{"prefix":"d"}' @splat
$null = Invoke-LMFunction -Payload '{"prefix":"e"}' @splat
$null = Invoke-LMFunction -Payload '{"prefix":"f"}' @splat
$null = Invoke-LMFunction -Payload '{"prefix":"g"}' @splat
$null = Invoke-LMFunction -Payload '{"prefix":"h"}' @splat
$null = Invoke-LMFunction -Payload '{"prefix":"i"}' @splat
$null = Invoke-LMFunction -Payload '{"prefix":"j"}' @splat
$null = Invoke-LMFunction -Payload '{"prefix":"k"}' @splat
$null = Invoke-LMFunction -Payload '{"prefix":"l"}' @splat
$null = Invoke-LMFunction -Payload '{"prefix":"m"}' @splat
$null = Invoke-LMFunction -Payload '{"prefix":"n"}' @splat
$null = Invoke-LMFunction -Payload '{"prefix":"o"}' @splat
$null = Invoke-LMFunction -Payload '{"prefix":"p"}' @splat
$null = Invoke-LMFunction -Payload '{"prefix":"q"}' @splat
$null = Invoke-LMFunction -Payload '{"prefix":"r"}' @splat
$null = Invoke-LMFunction -Payload '{"prefix":"s"}' @splat
$null = Invoke-LMFunction -Payload '{"prefix":"t"}' @splat
$null = Invoke-LMFunction -Payload '{"prefix":"u"}' @splat
$null = Invoke-LMFunction -Payload '{"prefix":"v"}' @splat
$null = Invoke-LMFunction -Payload '{"prefix":"w"}' @splat
$null = Invoke-LMFunction -Payload '{"prefix":"y"}' @splat
$null = Invoke-LMFunction -Payload '{"prefix":"x"}' @splat
$null = Invoke-LMFunction -Payload '{"prefix":"z"}' @splat

$null = Invoke-LMFunction -Payload '{"prefix":"0"}' @splat
$null = Invoke-LMFunction -Payload '{"prefix":"1"}' @splat
$null = Invoke-LMFunction -Payload '{"prefix":"2"}' @splat
$null = Invoke-LMFunction -Payload '{"prefix":"3"}' @splat
$null = Invoke-LMFunction -Payload '{"prefix":"4"}' @splat
$null = Invoke-LMFunction -Payload '{"prefix":"5"}' @splat
$null = Invoke-LMFunction -Payload '{"prefix":"6"}' @splat
$null = Invoke-LMFunction -Payload '{"prefix":"7"}' @splat
$null = Invoke-LMFunction -Payload '{"prefix":"8"}' @splat
$null = Invoke-LMFunction -Payload '{"prefix":"9"}' @splat
