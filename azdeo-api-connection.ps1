$personalToken = "BlahBLahBLah"
$token = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($personalToken)"))
$header = @{"Authorization" = ("Basic {0}" -f $token)}