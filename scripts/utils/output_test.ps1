

Write-Output "[Fake] Running terraform init";
Start-Sleep -Seconds 1.5

Write-Output "[Fake] Running terraform plan";
Start-Sleep -Seconds 1.5

Write-Output "[Fake] Plan saved at apply-plan.out";
Start-Sleep -Seconds 1.5

Write-Output "[Fake] Running terraform apply";
Start-Sleep -Seconds 1.5

Write-Output "[Fake] Successfully applied terraform plan";
        