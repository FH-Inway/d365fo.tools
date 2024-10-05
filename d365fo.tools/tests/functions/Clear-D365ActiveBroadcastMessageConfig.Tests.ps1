Describe "Clear-D365ActiveBroadcastMessageConfig Unit Tests" -Tag "Unit" {
	BeforeAll {
		# Place here all things needed to prepare for the tests
	}
	AfterAll {
		# Here is where all the cleanup tasks go
	}
	
	Describe "Ensuring unchanged command signature" {
		It "should have the expected parameter sets" {
			(Get-Command Clear-D365ActiveBroadcastMessageConfig).ParameterSets.Name | Should -Be 
		}
		

	}
	

}