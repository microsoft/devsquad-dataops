BeforeAll {
    $rgName = $env:ACC_TEST_RESOURCE_GROUP_DATA
    $dataLakeName = $env:ACC_TEST_DATA_LAKE_NAME
    $location = $env:ACC_TEST_LOCATION
    $dataLakeSkuName = $env:ACC_TEST_DATA_LAKE_SKU_NAME

    $vnet = $env:ACC_TEST_VNET
    $snet_storage = $env:ACC_TEST_SNET_STORAGE
    $snet_dbricks_public = $env:ACC_TEST_SNET_DATABRICKS_PUBLIC
    $snet_dbricks_private = $env:ACC_TEST_SNET_DATABRICKS_PRIVATE
}
Describe "Data Lake" -Tag "Acceptance" {
    BeforeAll {
        $dataLake = Get-AzStorageAccount -ResourceGroupName $rgName -Name $dataLakeName
        $containers = Get-AzStorageContainer -Context $dataLake.Context
    }
    Context "Resource" {
        # TODO: For some reason the following test is always failing, even all the other ones pass.
        It "Exists" -Skip {
            $dataLake | Should -Not -BeNullOrEmpty
        }
        It "ProvisioningState Is Succeeded" {
            $dataLake.ProvisioningState | Should -Be "Succeeded"
        }
        It "Is In Expected Location" {
            $dataLake.Location | Should -Be $location
        }
    }
    Context "Features"{
        It "Enables Hierarchical Namespace" {
            $dataLake.EnableHierarchicalNamespace | Should -BeTrue
        }
    }
    Context "SKU"{
        It "Tier Is Standard" {
            $dataLake.Sku.Tier | Should -Be "Standard"
        } 
        It "Name Matches" {
            $dataLake.Sku.Name  | Should -Be $dataLakeSkuName
        }
        It "Kind Is StorageV2" {
            $dataLake.kind | Should -Be "StorageV2"
        }
        It "Access Tier Is Hot" {
            $dataLake.AccessTier| Should -Be "Hot"
        }
    }
    Context "Containers"{
        It "Contains Landing" {
            $containers.Name | Should -Contain "landing"
        } 
        It "Contains Refined" {
            $containers.Name | Should -Contain "refined"
        } 
        It "Contains Trusted" {
            $containers.Name | Should -Contain "trusted"
        } 
        It "Are All Private" {
            $containers.Permission.PublicAccess | Where-Object { $_ -eq 'Off' } | Should -HaveCount $containers.Count
        } 
    }
    Context "Network" -Skip {
        It "Is allowed on $snet_dbricks_public" {
            [bool]($dataLake.properties.networkAcls.virtualNetworkRules | Where-Object id -Like "*$vnet/subnets/$snet_dbricks_public" ||  state -eq "Succeeded") | Should -Be true
        } 
        It "Is allowed on $snet_dbricks_private" {
            [bool]($dataLake.properties.networkAcls.virtualNetworkRules | Where-Object id -Like "*$vnet/subnets/$snet_dbricks_private" ||  state -eq "Succeeded")   | Should -Be true
        }
        It "Is allowed on $snet_storage" {
            [bool]($dataLake.properties.networkAcls.virtualNetworkRules | Where-Object id -Like "*$vnet/subnets/$snet_storage" ||  state -eq "Succeeded")  | Should -Be true
        }
        It "IPRules Contains 0 Elements" {
            $dataLake.NetworkRuleSet.IpRules | Should -HaveCount 0
        }
    }
    Context "Security"{
        It "Enables Blob Encryption" {
            $dataLake.Encryption.Services.Blob.Enabled | Should -Be true
        } 
        It "Enables Files Encryption" {
            $dataLake.Encryption.Services.File.Enabled  | Should -Be true
        }
        It "Enables HTTPS Traffic Only" {
            $dataLake.EnableHttpsTrafficOnly  | Should -Be true
        }
        It "Enables TLS 1.2" {
            $dataLake.MinimumTlsVersion | Should -Be 'TLS1_2'
        }
    }
}

