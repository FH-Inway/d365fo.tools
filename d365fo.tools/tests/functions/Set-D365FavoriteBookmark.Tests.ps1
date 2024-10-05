Describe "Set-D365FavoriteBookmark Unit Tests" -Tag "Unit" {
	BeforeAll {
		# Place here all things needed to prepare for the tests
	}
	AfterAll {
		# Here is where all the cleanup tasks go
	}
	
	Describe "Ensuring unchanged command signature" {
		It "should have the expected parameter sets" {
			(Get-Command Set-D365FavoriteBookmark).ParameterSets.Name | Should -Be 
		}
		

	}
	

}