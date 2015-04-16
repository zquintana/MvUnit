# MvUnit - Miva Modules Unit Testing Library/Module

MivaScript Unit Testing library and module for Miva Merchant. This test library leverages Miva's `json` feature as a entry hook for performing unit testing of Miva modules.

## Installation

Install into a Miva store and navigate to the modules admin located in Utilities -> MvUnit. The module will display all the modules installed in the store with the feature `json`. If module doesn't have tests using the define method in this doc, nothing will happen. 

To test if this module is working, select the "MvUnit" module from the select drop down and click "Run Tests" located at the top right of the page. If the module is functioning properly 2 tests will be run with 1 success and 1 fail each. Resulting in a fail status. This is expected in this case.

## How It Works

This library leverages the existing `json` feature in Miva by calling a module with 2 JSON functions, `MvUnit_Tests` and `MvUnit_Test`. `MvUnit_Tests` is used to retrieve a list of named tests defined in the module. `MvUnit_Test` is used to perform a named test. Once run agaisnt a configured module, MvUnit discovers then tests the defined tests and prints the results in the admin.

## Writing Your First Test

To begin using this module you will need to do the following:
1. Include the `mvunitlib.mv` file in your module code either by copying it's contents or by using `MvINCLUDE` tag.
2. If you module isn't using the `json` Miva feature, add it.
3. Add JSON functions for `MvUnit_Tests` and `MvUnit_Test`.

A detailed view of how this works can be found in the `mvunit.mv` file.

### Example Implementation

The following is taken from the `mvunit.mv` module file.

~~~xml
<MvFUNCTION NAME = "Module_JSON" PARAMETERS = "module var" STANDARDOUTPUTLEVEL = "">
	<MvIF EXPR = "{ g.Module_Function EQ 'MvUnit_Tests' }">
		<MvFUNCTIONRETURN VALUE = "{ Unit_Tests() }" />
	<MvELSEIF EXPR = "{ g.Module_Function EQ 'MvUnit_Test' }">
		<MvFUNCTIONRETURN VALUE = "{ Module_JSON_Test() }" />
	</MvIF>

	<MvFUNCTIONRETURN VALUE = 1 />
</MvFUNCTION>

<MvFUNCTION NAME = "Module_JSON_Test" PARAMETERS = "" STANDARDOUTPUTLEVEL = "">
	<MvIF EXPR = "{ g.MvUnit:Test EQ 'TestTrue' }">
		<MvFUNCTIONRETURN VALUE = "{ TestTrue() }" />
	<MvELSEIF EXPR = "{ g.MvUnit:Test EQ 'TestEquals' }">
		<MvFUNCTIONRETURN VALUE = "{ TestEquals() }" />
	</MvIF>

	<MvFUNCTIONRETURN VALUE = 1>
</MvFUNCTION>

<MvFUNCTION NAME = "TestTrue" PARAMETERS = "" STANDARDOUTPUTLEVEL = "">
	<MvASSIGN NAME = "l.test1" VALUE = "{ 1 }">
	<MvASSIGN NAME = "l.null" VALUE = "{ Unit_Assert_True(l.test1) }">

	<MvASSIGN NAME = "l.test2" VALUE = "{ 0 }">
	<MvASSIGN NAME = "l.null" VALUE = "{ Unit_Assert_True(l.test2) }">

	<MvASSIGN NAME = "l.null" VALUE = "{ Unit_Print('Value of test1: ' $ l.test1) }">
	<MvASSIGN NAME = "l.null" VALUE = "{ Unit_Print('Value of test2: ' $ l.test1) }">

	<MvFUNCTIONRETURN VALUE = "{ Unit_Response() }">
</MvFUNCTION>

<MvFUNCTION NAME = "TestEquals" PARAMETERS = "" STANDARDOUTPUTLEVEL = "">
	<MvASSIGN NAME = "l.test1" VALUE = "{ 10 }">
	<MvASSIGN NAME = "l.null" VALUE = "{ Unit_Assert_Equals(l.test1, 10) }">
	<MvASSIGN NAME = "l.null" VALUE = "{ Unit_Assert_Equals(l.test1, 11) }">
	<MvASSIGN NAME = "l.null" VALUE = "{ Unit_Print('Value of test1: ' $ l.test1) }">

	<MvFUNCTIONRETURN VALUE = "{ Unit_Response() }">
</MvFUNCTION>
~~~

## Rebuilding The Module

I've chosen to use Rake as my build tool. If you have rake installed on your system you can run `rake -T` while in the root of the project directory to see the commands available or explore the contents of the Rakefile.