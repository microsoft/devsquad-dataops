BeforeAll {
    $rgName = $env:ACC_TEST_RESOURCE_GROUP_COMPUTE
    $databricksName = $env:ACC_TEST_DATABRICKS_NAME
    $location = $env:ACC_TEST_LOCATION
}

Describe "Databricks" -Tag "Acceptance" {
    BeforeAll {
        $databricks = Get-AzDatabricksWorkspace -ResourceGroupName $rgName -Name $databricksName
    }
    Context "Resource" {
        It "Exists" {
            $databricks | Should -Not -BeNullOrEmpty
        }
        It "ProvisioningState Is Succeeded" {
            $databricks.ProvisioningState | Should -Be "Succeeded"
        }
        It "Is In Expected Location" {
            $databricks.Location | Should -Be $location
        }
    }
    Context "SKU" {
        It "Is Premium" {
            $databricks.SkuName | Should -Be "premium"
        }
    }
    Context "Network" -Skip {
        It "Does Not Enable Public IP" {
            $databricks.EnableNoPublicIPValue | Should -BeFalse
        }
        It "Lives In Custom VNET" {
            $databricks.CustomVirtualNetworkIdValue | Should -Not -BeNullOrEmpty
            $databricks.CustomPrivateSubnetNameValue | Should -Not -BeNullOrEmpty
            $databricks.CustomPublicSubnetNameValue | Should -Not -BeNullOrEmpty
        }
    }
}
