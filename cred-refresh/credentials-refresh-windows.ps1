if ($args.Count -le 1) {
    Write-Output "`r`nusage: credentials-refresh-windows.ps1 <account_id> <region>"
    Write-Output "credentials-refresh-windows.ps1: ERROR: too few arguments `r`n"
    return
}

[string]$id = $args[0]
[string]$region = $args[1]
[string]$domain = $id + ".dkr.ecr." + $region + ".amazonaws.com"
[string]$password = (Get-ECRLoginCommand -RegistryId $id -Region $region).Password

kubectl delete secret my-regcred --namespace myname
[string]$kubectlResponse = (kubectl create secret docker-registry my-regcred --save-config --dry-run=client --from-file=.dockerconfigjson=$HOME/.docker/config.json --docker-server=$domain --docker-username=AWS --docker-password=$password -n=myname -o yaml | kubectl apply -f -) 2>&1
Write-Output $kubectlResponse
if ($kubectlResponse -like "*error*")
{
    Write-Output "FAILED"
    return
}

Write-Output "`r`n!!! SUCCESS !!!"
