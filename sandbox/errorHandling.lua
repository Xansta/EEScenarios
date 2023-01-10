-- package name possibly should be debug
-- but this clashes with a stock lua package
errorHandling = {}

function errorHandling:callWithErrorHandling(fun,...)
	assert(type(fun)=="function" or fun==nil)
	return xpcall(fun, self.onError, ...)
end

-- returns a function which wraps the fun function in error handling logic
-- we have to handle nil due to the somewhat common idiom of for instance onGMClick(nil)
function errorHandling:wrapWithErrorHandling(fun)
	assert(type(fun)=="function" or fun==nil,"expected function or nil for wrapWithErrorHandling we instead got a " .. type(fun) .. " with a value of " .. tostring(fun))
	if fun == nil then
		return nil
	end
	return function(...)
		return errorHandling:callWithErrorHandling(fun, ...)
	end
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
		return self[functionName](self:wrapWithErrorHandling(fun))
	end)
end

-- the main function here - it wraps all functions with error handling code
function errorHandling:_wrapAllFunctions()
	self:_saveFunctionToSelf(_ENV,"addGMFunction", function(msg, fun)
		assert(type(msg)=="string")
		assert(type(fun)=="function" or fun==nil)
		return self.addGMFunction(msg,self:wrapWithErrorHandling(fun))
	end)

	self:_autoWrapFunction1(_ENV,"onNewPlayerShip")
	self:_autoWrapFunction1(_ENV,"onGMClick")

	-- todo should check update exists before wrapping it
	self:_saveFunctionToSelf(_ENV,"update",self:wrapWithErrorHandling(update))
end

-- this is a wrapper to allow us to catch errors in the error handling code
function errorHandling:wrapAllFunctions(onError)
	assert(type(onError) == "function")
	self.onError = onError
	self:callWithErrorHandling(self._wrapAllFunctions,self,onError)
end