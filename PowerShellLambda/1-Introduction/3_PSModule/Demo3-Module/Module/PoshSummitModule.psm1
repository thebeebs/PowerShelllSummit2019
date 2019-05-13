function Invoke-ModuleFunction
{
    param
    (
        $LambdaInput,
        $LambdaContext
    )

    Write-Host 'Write-Host -> LambdaInput:' (ConvertTo-Json -InputObject $LambdaInput)

    Write-Verbose 'Write-Verbose works' -Verbose
    Write-Information 'Write-Information works too!'
    Write-Warning 'So does Write-Warning...'

    # Write-Error will work, but it will cause the
    # Lambda Function to fail with an exception
    #Write-Error -Message 'Write-Error even works'

    if ($LambdaInput.name) {
        'Hello {0}' -f $LambdaInput.name
    }
    else {
        'Hello World!'
    }
}
