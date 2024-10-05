Describe "Set-D365AzCopyPath Unit Tests" -Tag "Unit" {
	BeforeAll {
		# Place here all things needed to prepare for the tests
	}
	AfterAll {
		# Here is where all the cleanup tasks go
	}
	
	Describe "Ensuring unchanged command signature" {
		It "should have the expected parameter sets" {
			(Get-Command Set-D365AzCopyPath).ParameterSets.Name | Should -Be 
		}
		

	}
	

}