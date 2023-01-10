-- package name possibly should be debug
-- but this clashes with a stock lua package
errorHandling = {}

-- TODO
-- all these functions need error handling
--addCommsReply
--SpaceObject:setCommsFunction
--SpaceObject:onDestroyed
--Artifact:onCollision
--Artifact:onPlayerCollision
--Artifact:onPickUp
--Artifact:onPickup
--Mine:onDestruction
--ScanProbe:onArrival
--ScanProbe:onExpiration
--ScanProbe:onDestruction
--ShipTemplateBasedObject:onTakingDamage
--ShipTemplateBasedObject:onDestruction
--PlayerSpaceship:addCustomButton
--PlayerSpaceship:addCustomMessageWithCallback
--PlayerSpaceship:onProbeLaunch
--PlayerSpaceship:onProbeLink
--PlayerSpaceship:onProbeUnlink
--SupplyDrop:onPickUp
--WarpJammer:onTakingDamage
--WarpJammer:onDestruction
--WormHole:onTeleportation
-- note - its worth checking the gm create menu uses these functions rather than the C++ version
-- it might be good to make some of these optional
-- update and init might want a check before assuming they are present (and a warning if not?)

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

-- this almost certainly needs work, both to generalise to more function arguments
-- and the function not being in argument 1
function errorHandling:_autoWrapArg1(originalFunction)
	assert(type(originalFunction) == "function")
	return function (fun)
		assert(type(fun) == "function" or fun == nil)
		return originalFunction(self:wrapWithErrorHandling(fun))
	end
end

-- the main function here - it wraps all functions with error handling code
function errorHandling:_wrapAllFunctions()
	local tmpAddGMFunction = addGMFunction
	addGMFunction = function(msg, fun)
		assert(type(msg)=="string")
		assert(type(fun)=="function" or fun==nil)
		return tmpAddGMFunction(msg,self:wrapWithErrorHandling(fun))
	end

	onNewPlayerShip = self:_autoWrapArg1(onNewPlayerShip)
	onGMClick = self:_autoWrapArg1(onGMClick)

	-- todo should check update exists before wrapping it
	update = self:wrapWithErrorHandling(update)
	init = self:wrapWithErrorHandling(init)
end

-- this is a wrapper to allow us to catch errors in the error handling code
function errorHandling:wrapAllFunctions(onError)
	assert(type(onError) == "function")
	self.onError = onError
	self:callWithErrorHandling(self._wrapAllFunctions,self,onError)
end