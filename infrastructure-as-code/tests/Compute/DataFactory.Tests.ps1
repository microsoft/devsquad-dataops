BeforeAll {
    $rgName = $env:ACC_TEST_RESOURCE_GROUP_COMPUTE
    $dataFactoryName = $env:ACC_TEST_DATA_FACTORY_NAME
    $location = $env:ACC_TEST_LOCATION
}

Describe "Data Factory" -Tag "Acceptance" {
    BeforeAll {
        $dataFactory = Get-AzDataFactoryV2 -ResourceGroupName $rgName -Name $dataFactoryName
    }
    Context "Resource" {
        It "Exists" {
            $dataFactory | Should -Not -BeNullOrEmpty
        }
        It "ProvisioningState Is Succeeded" {
            $dataFactory.ProvisioningState | Should -Be "Succeeded"
        }
        It "Is In Expected Location" {
            $dataFactory.Location | Should -Be $location
        }
    }
    Context "Source Control" {
        It "Is Using Repo Configuration" -Tag "dev" {
            $dataFactory.RepoConfiguration | Should -Not -BeNullOrEmpty
            $dataFactory.RepoConfiguration | Should -BeOfType  Microsoft.Azure.Management.DataFactory.Models.FactoryVSTSConfiguration
            $dataFactory.RepoConfiguration.TenantId | Should -Not -BeNullOrEmpty
            $dataFactory.RepoConfiguration.AccountName | Should -Not -BeNullOrEmpty
            $dataFactory.RepoConfiguration.ProjectName | Should -Not -BeNullOrEmpty
            $dataFactory.RepoConfiguration.RepositoryName | Should -Not -BeNullOrEmpty
            $dataFactory.RepoConfiguration.CollaborationBranch | Should -Not -BeNullOrEmpty
            $dataFactory.RepoConfiguration.RootFolder | Should -Not -BeNullOrEmpty
        }
        It "Is Not Using Repo Configuration" -Tag "prod" {
            $dataFactory.RepoConfiguration | Should -BeNullOrEmpty
        }
    }
}
