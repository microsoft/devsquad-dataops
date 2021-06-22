BeforeAll {
    $rgName = $env:ACC_TEST_RESOURCE_GROUP_COMPUTE
    $location = $env:ACC_TEST_LOCATION
}

Describe "Resource Group Compute" -Tag "Acceptance" {
    BeforeAll {
        $rg = Get-AzResourceGroup -Name $rgName
        $rgLocks = Get-AzResourceLock -ResourceGroupName $rgName -AtScope
    }
    Context "Resource" {
        It "Exists" {
            $rg | Should -Not -BeNullOrEmpty
        }
        It "ProvisioningState Is Succeeded" {
            $rg.ProvisioningState | Should -Be "Succeeded"
        }
        It "Is In Expected Location" {
            $rg.Location | Should -Be $location
        }
    }
}
