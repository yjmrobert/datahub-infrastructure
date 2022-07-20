

Write-Information "[Fake] Running terraform init";
Start-Sleep -Seconds 0.5

Write-Information "[Fake] Running terraform plan";
Start-Sleep -Seconds 0.75

Write-Information "[Fake] Plan saved at apply-plan.out";
Start-Sleep -Seconds 0.25

Write-Information "[Fake] Running terraform apply";
Start-Sleep -Seconds 1

Write-Information "[Fake] Successfully applied terraform plan";
        