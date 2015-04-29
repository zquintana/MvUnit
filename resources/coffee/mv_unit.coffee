
# AJAX_Call_Module( callback, session_type, module_code, func, parameters, delegator )

class MvUnit

	###*
	 * Results foot dom ID
	 * 
	 * @type string
	###
	TABLE_RESULTS_FOOT_ID = "mvunit_result_table_foot"

	###*
	 * Results body dom ID
	 * 
	 * @type string
	###
	TABLE_RESULTS_BODY_ID = "mvunit_result_table_results"

	###*
	 * Module selector dom ID
	 * 
	 * @type string
	###
	MODULE_SELECTED_ID = "mv_unit_test_modules"

	###*
	 * Output textarea selector dom ID
	 * 
	 * @type string
	###
	OUTPUT_TEXT_ID = "mvunit_output_text"

	###*
	 * Miva JSON function to retrieve MvUnit tests
	 * 
	 * @type string
	###
	FUNCTION_TESTS = "MvUnit_Tests"

	###*
	 * Miva JSON function to run MvUnit test
	 * 
	 * @type string
	###
	FUNCTION_TEST = "MvUnit_Test"

	###*
	 * No module selected error message
	 * 
	 * @type string
	###
	ERROR_NO_MODCODE_SELECTED = 'Please select a module to attempt to test'

	###*
	 * Constructor
	 * 
	 * @return this
	###
	constructor: ->

	###*
	 * Outputs error message
	 * 
	 * @param  string msg
	 * @return bool false
	###
	error: (msg) ->
		alert "Error: #{msg}"
		false

	###*
	 * Starts running tests
	 * 
	 * @return null
	###
	runTests: ->
		selectedMod = @getModuleOptionSelected()

		if not selectedMod?
			return @error(ERROR_NO_MODCODE_SELECTED)

		@clear().load(selectedMod.value)


	###*
	 * Getter for module code
	 * 
	 * @return string
	###
	getModuleCode: -> @moduleCode

	###*
	 * Module code setter
	 * 
	 * @param this
	###
	setModuleCode: (moduleCode) ->
		@moduleCode = moduleCode
		return this

	###*
	 * Get current time in seconds
	 * 
	 * @return int
	###
	now: ->
		d = new Date()
		d.getTime()

	###*
	 * Runs test request
	 * 
	 * @param  {[type]}
	 * @return {[type]}
	###
	execute: (test) ->
		me = this

		@startTime 	= @now()
		@currentReq = AJAX_Call_Module(
			(response) -> me.handleTestResponse(response),
			'admin',
			@getModuleCode(),
			FUNCTION_TEST,
			"MvUnit:Test=#{encodeURIComponent(test)}"
			)

	###*
	 * Get tests for module
	 * 
	 * @param  string moduleCode
	 * @return XMLHttpRequest
	###
	load: (moduleCode) ->
		me 	= this
		@setModuleCode(moduleCode)
		@currentReq = AJAX_Call_Module(
			(response) -> me.handleTestsResponse(response), 
			'admin', 
			@getModuleCode(), 
			FUNCTION_TESTS)

	###*
	 * Current name of test
	 * 
	 * @return string
	###
	getCurrentName: -> if @currentData.name? then @currentData.name else @currentTest


	###*
	 * Output the result to the table
	 * 
	 * @param  object result
	 * @return null
	###
	outputResult: (result, appendEl, id) ->
		row = document.createElement('tr')
		if id?
			row.setAttribute('id', id)

		nameCell = document.createElement('td')
		nameCell.appendChild(document.createTextNode(@getCurrentName()))
		row.appendChild(nameCell)

		assertCell = document.createElement('td')
		assertCell.appendChild(document.createTextNode(result.assertions))
		row.appendChild(assertCell)

		resultCell = document.createElement('td')
		if result.failures > 0
			failSpan = document.createElement('span')
			failSpan.className = 'mvunit-fails'
			failSpan.appendChild(document.createTextNode(result.failures))
			resultCell.appendChild(failSpan)

		if result.successes > 0
			if result.failures > 0
				resultCell.appendChild(document.createTextNode('/'))
			
			successSpan = document.createElement('span')
			successSpan.className = 'mvunit-success'
			successSpan.appendChild(document.createTextNode(result.successes))
			resultCell.appendChild(successSpan)
		row.appendChild(resultCell)

		timeCell = document.createElement('td')
		timeCell.appendChild(document.createTextNode("#{result.executionTime}ms"))
		row.appendChild(timeCell)
		
		appendEl.appendChild(row)
		@outputText(result.output)

	###*
	 * Render foot content
	 * 
	 * @return null
	###
	renderFoot: ->
		row = document.createElement('tr')
		labelCell = document.createElement('th')
		labelCell.setAttribute('colspan', 3)
		labelCell.appendChild(document.createTextNode('Result'))
		row.appendChild(labelCell)

		resultCell = document.createElement('th')
		resultCell.appendChild(document.createTextNode(if @totals.failures > 0 then "Fail" else "Pass"))
		row.appendChild(resultCell)
		@getResultsFoot().appendChild(row)



	###*
	 * Results body getter
	 * 
	 * @return object element
	###
	getResultsBody: -> $(TABLE_RESULTS_BODY_ID)

	###*
	 * Results foot getter
	 * 
	 * @return object element
	###
	getResultsFoot: -> $(TABLE_RESULTS_FOOT_ID)

	###*
	 * Getter for output textarea
	 * 
	 * @return object element
	###
	getOutputText: -> $(OUTPUT_TEXT_ID)

	###*
	 * Output text to output display
	 * 
	 * @param  string txt
	 * @return null
	###
	outputText: (txt) -> 
		if not txt?
			return

		@getOutputText().value += "#{@getCurrentName()}:\n#{txt}\n\r"

	###*
	 * Clear results table
	 * 
	 * @return this
	###
	clear: ->
		tbody = @getResultsBody()
		while tbody.firstChild
			tbody.removeChild(tbody.firstChild)

		tfoot = @getResultsFoot()
		while tfoot.firstChild
			tfoot.removeChild(tfoot.firstChild)

		@totals = null
		@currentData = null
		@currentTest = null
		@getOutputText().value = ""

		return this


	###*
	 * Update totals
	 * 
	 * @param  object data
	 * @return null
	###
	updateTotals: (data) ->
		if not @totals?
			@totals = 
				assertions: 0
				failures: 0
				successes: 0
				executionTime: 0

		@totals.assertions 	+= data.assertions
		@totals.failures 	+= data.failures
		@totals.successes 	+= data.successes
		@totals.executionTime += data.executionTime

		return null

	###*
	 * Handles execute test request
	 * 
	 * @param  object response
	 * @return null
	###
	handleTestResponse: (response) ->
		if response.success == 0
			return @handleError(response)

		@currentData = data = response.data
		data.executionTime = @now() - @startTime
		@outputResult(data, @getResultsBody())

		@updateTotals(data)

		if @hasTests()
			@execute(@nextTest())
			return

		@totals.name = "Totals"
		@currentData = @totals
		@outputResult(@totals, @getResultsFoot(), 'mvunit_result_table_results_total')
		@renderFoot()

	handleError: (response) ->
		alert "#{response.error_code}: #{response.error_message}"

	###*
	 * Handles response from load
	 * 
	 * @param  object response
	 * @return null
	###
	handleTestsResponse: (response) ->
		@setTests(response.data)

		if !@hasTests()
			return

		@execute(@nextTest())

	###*
	 * Returns next test name from queue
	 * 
	 * @return string
	###
	nextTest: ->
		if !@hasTests()
			@currentTest = null
			return

		@currentTest = @getTests().shift()
		@currentTest


	###*
	 * Tests setter
	 *
	 * @param array tests
	 ###
	setTests: (tests) ->
		@moduleTests = tests
		this

	###*
	 * Ensures that tests are available
	 * 
	 * @return bool
	###
	hasTests: -> @moduleTests? and @moduleTests.length > 0

	###*
	 * Module tests getter
	 * 
	 * @return array
	###
	getTests: -> @moduleTests


	###*
	 * Gets the module select DOM Element
	 * 
	 * @return DOMElement
	###
	getModuleSelect: -> $(MODULE_SELECTED_ID)


	###*
	 * Gets options from module select element
	 * 
	 * @return array DOMElements
	###
	getModuleOptions: -> @getModuleSelect().options

	###*
	 * Getter selector option from module select element
	 * 
	 * @return DOMElement 
	###
	getModuleOptionSelected: ->
		selected = null
		each @getModuleOptions(), (el) ->
			if el.selected == true
				selected = el

		if selected and selected.value? and selected.value.length > 0 then selected else null

	

window.MvUnit = MvUnit