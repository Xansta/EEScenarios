-- package name possibly should be debug
-- but this clashes with a stock lua package
errorHandling = {}

--------------------
-- error handling --
--------------------
-- in several places it would be nice to get more errors reported
-- this is to assist with that
-- returns a function which wraps the fun function in error handling logic
-- the error handling logic for the sandbox is a popup and printing to the console
-- this is useful for callbacks and gm buttons (as both of those don't in the current
-- version display the red text with a line number that init code does
-- example addGMFunction("button",wrapWithErrorHandling(function () print("example") end))
function wrapWithErrorHandling(fun)
	assert(type(fun)=="function" or fun==nil,"expected function or nil for wrapWithErrorHandling we instead got a " .. type(fun) .. " with a value of " .. tostring(fun))
	if fun == nil then
		return nil
	end
	return function(...)
		return xpcall(fun, errorHandling.onError, ...)
	end
end

-- calls the function fun with the remaining arguments while using the common
-- error handling logic (see wrapWithErrorHandling)
function callWithErrorHandling(fun,...)
	assert(type(fun)=="function" or fun==nil)
	return wrapWithErrorHandling(fun)(...)
end

function errorHandling:_saveFunctionToSelf(originalTable,functionName,fn)
	assert(type(originalTable) == "table")
	assert(type(functionName) == "string")
	assert(type(fn) == "function")
	self[functionName] = originalTable[functionName]
	originalTable[functionName] = fn
end

function errorHandling:_autoWrapFunction1(originalTable,functionName)
	self:_saveFunctionToSelf(originalTable,functionName, function (fun)
		assert(type(fun) == "function" or fun == nil)
		return self[functionName](wrapWithErrorHandling(fun))
	end)
end

-- the main function here - it wraps all functions with error handling code
function errorHandling:_wrapAllFunctions()
	self:_saveFunctionToSelf(_ENV,"addGMFunction", function(msg, fun)
		assert(type(msg)=="string")
		assert(type(fun)=="function" or fun==nil)
		return self.addGMFunction(msg,wrapWithErrorHandling(fun))
	end)

	self:_autoWrapFunction1(_ENV,"onNewPlayerShip")
	self:_autoWrapFunction1(_ENV,"onGMClick")

	-- todo should check update exists before wrapping it
	self:_saveFunctionToSelf(_ENV,"update",wrapWithErrorHandling(update))
end

-- this is a wrapper to allow us to catch errors in the error handling code
function errorHandling:wrapAllFunctions(onError)
	assert(type(onError) == "function")
	self.onError = onError
	callWithErrorHandling(self._wrapAllFunctions,self,onError)
end