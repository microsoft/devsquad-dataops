BeforeAll {
    $rgName = $env:ACC_TEST_RESOURCE_GROUP_COMPUTE
    $keyVaultName = $env:ACC_TEST_KEY_VAULT_NAME
    $location = $env:ACC_TEST_LOCATION
}

Describe "Key Vault" -Tag "Acceptance" {
    BeforeAll {
        $keyVault = Get-AzKeyVault -ResourceGroupName $rgName -Name $keyVaultName
    }
    Context "Resource" {
        It "Exists" {
            $keyVault | Should -Not -BeNullOrEmpty
        }
        It "Is In Expected Location" {
            $keyVault.Location | Should -Be $location
        }
    }
    Context "SKU" {
        It "Is Standard" {
            $keyVault.Sku | Should -Be "Standard"
        }
    }
    Context "Delete Protection" {
        It "Enables Purge Protection" {
            $keyVault.EnablePurgeProtection | Should -BeTrue
        }
        It "Enables Soft Delete" {
            $keyVault.EnableSoftDelete | Should -BeFalse
        }
    }
    Context "Usage Flags" {
        It "Is Not Enabled For Disk Encryption" {
            $keyVault.EnabledForDiskEncryption | Should -BeFalse
        }
        It "Is Not Enabled For Deployment" {
            $keyVault.EnabledForDeployment | Should -BeFalse
        }
        It "Is Not Enabled For Template Deployment" {
            $keyVault.EnabledForTemplateDeployment | Should -BeFalse
        }
    }
    Context "Authorization" {
        It "Uses Access Policy Authorization Model" {
            $keyVault.EnableRbacAuthorization | Should -BeFalse
        }
    }
}
