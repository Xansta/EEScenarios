function onError(error)
	local err = "script error : - \n" .. error .. "\n\ntraceback :-\n" .. traceback()
	print(err)
	addGMMessage(err)
end
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
		return xpcall(fun, onError, ...)
	end
end
-- calls the function fun with the remaining arguments while using the common
-- error handling logic (see wrapWithErrorHandling)
function callWithErrorHandling(fun,...)
	assert(type(fun)=="function" or fun==nil)
	return wrapWithErrorHandling(fun)(...)
end
-- currently EE doesn't make it easy to see if there are errors in GMbuttons
-- this saves the old addGMFunction, and makes it so all calls to addGMFunction
-- are wrapped with the common error handling logic
addGMFunctionReal=addGMFunction
function addGMFunction(msg, fun)
	assert(type(msg)=="string")
	assert(type(fun)=="function" or fun==nil)
	return addGMFunctionReal(msg,wrapWithErrorHandling(fun))
end

onNewPlayerShipReal=onNewPlayerShip
function onNewPlayerShip(fun)
	assert(type(fun)=="function" or fun==nil)
	return onNewPlayerShipReal(wrapWithErrorHandling(fun))
end

onGMClickReal=onGMClick
function onGMClick(fun)
	assert(type(fun)=="function" or fun==nil)
	return onGMClickReal(wrapWithErrorHandling(fun))
end