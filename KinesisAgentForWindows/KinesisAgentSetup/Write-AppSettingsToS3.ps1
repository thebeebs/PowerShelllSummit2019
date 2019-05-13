$appsettingsFilePath = '.\appsettings'
$s3Bucket = ''

$simpleSettings = Join-Path -Path $appsettingsFilePath -ChildPath 'simple-appsettings.json'
$fullSettings = Join-Path -Path $appsettingsFilePath -ChildPath 'detailed-appsettings.json'

Write-S3Object  -BucketName $s3Bucket -Key 'kinesis/simple-appsettings.json' -File $simpleSettings
Write-S3Object  -BucketName $s3Bucket -Key 'kinesis/detailed-appsettings.json' -File $fullSettings
