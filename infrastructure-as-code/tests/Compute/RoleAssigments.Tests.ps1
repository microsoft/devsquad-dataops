BeforeAll {
    $rgComputeName = $env:ACC_TEST_RESOURCE_GROUP_COMPUTE
    $rgDataName = $env:ACC_TEST_RESOURCE_GROUP_DATA
    $keyVaultName = $env:ACC_TEST_KEY_VAULT_NAME
    $dataFactoryName = $env:ACC_TEST_DATA_FACTORY_NAME
    $databricksName = $env:ACC_TEST_DATABRICKS_NAME
    $dataLakeName = $env:ACC_TEST_DATA_LAKE_NAME
}

Describe "Role Assigments" -Tag "Acceptance" {
    BeforeAll {
        $keyVault = Get-AzKeyVault -ResourceGroupName $rgComputeName -Name $keyVaultName
        $dataFactory = Get-AzDataFactoryV2 -ResourceGroupName $rgComputeName -Name $dataFactoryName
        $dataLake = Get-AzStorageAccount -ResourceGroupName $rgDataName -Name $dataLakeName
        $databricks = Get-AzDatabricksWorkspace -ResourceGroupName $rgComputeName -Name $databricksName

        # TODO: Service Principal needs permission to read AD Objects ID.
        # $dataLakeRoles = Get-AzRoleAssignment -Scope $dataLake.Id
        # $databricksRoles = Get-AzRoleAssignment -Scope $databricks.Id
    }
    Context "Key Vault" {
        It "Databricks" {
            $objectId = 'fe597bb2-377c-44f1-8515-82c8a1a62e3d'
            $policy = $keyVault.AccessPolicies | Where-Object { $_.ObjectId -eq $objectId } 
            $policy.PermissionsToSecrets | Should -Contain 'get'
            $policy.PermissionsToSecrets | Should -Contain 'list'
        }
        It "Data Factory" {
            $objectId = $dataFactory.Identity.PrincipalId
            $policy = $keyVault.AccessPolicies | Where-Object { $_.ObjectId -eq $objectId } 
            $policy.PermissionsToSecrets | Should -Contain 'get'
            $policy.PermissionsToSecrets | Should -Contain 'list'
        }
    }
    Context "Data Lake" -Skip {
        It "Data Factory" {
            $objectId = $dataFactory.Identity.PrincipalId
            $role = $dataLakeRoles | Where-Object { $_.ObjectId -eq $objectId }
            $role.RoleDefinitionName | Should -Be 'Storage Blob Data Contributor'
        }
    }
    Context "Databricks" -Skip {
        It "Data Factory" {
            $objectId = $dataFactory.Identity.PrincipalId
            $role = $databricksRoles | Where-Object { $_.ObjectId -eq $objectId }
            $role.RoleDefinitionName | Should -Be 'Contributor'
        }
    }
}
