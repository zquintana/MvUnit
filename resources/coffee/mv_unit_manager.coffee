
MvUnitManager = 
	Run_Tests: (el) ->
		@sharedInstance().runTests()

	sharedInstance: ->
		if not @instance?
			@instance = new MvUnit 

		@instance

window.MvUnitManager = MvUnitManager