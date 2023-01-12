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
-- TODO - mirror the class hierachy (needed for the SpaceObject callbacks)
--SpaceObject
--    Artifact
--    Asteroid
--    BeamEffect
--    BlackHole
--    ElectricExplosionEffect
--    ExplosionEffect
--    Mine
--    MissileWeapon
--        EMPMissile
--        HVLI
--        HomingMissile
--        Nuke
--    Nebula
--    Planet
--    ScanProbe
--    ShipTemplateBasedObject
--        SpaceShip
--            CpuShip
--            PlayerSpaceship
--        SpaceStation
--    SupplyDrop
--    VisualAsteroid
--    WarpJammer
--    WormHole
--    Zone
-- note - its worth checking the gm create menu (or other ways) uses these functions rather than the C++ version
-- player ship is perticullary important
-- it might be good to make some of these optional
-- update and init might want a check before assuming they are present (and a warning if not?)
-- check if objects have been created before wrapAllFunctions is called?
-- prevent wrapAllFunctions being called more than once?
-- remove the sandbox wrapped functions

function errorHandling:callWithErrorHandling(fun,...)
	assert(type(fun)=="function" or fun==nil)
	if fun ~= nil then
		return xpcall(fun, self.onError, ...)
	end
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

-- returns a function which is the originalFunction, but with argToWrap being wrapWithErrorHandling
function errorHandling:_autoWrapArgX(originalFunction, argToWrap)
	assert(type(originalFunction) == "function")
	assert(type(argToWrap) == "number")
	return function (...)
		local args = table.pack(...)
		args[argToWrap] = self:wrapWithErrorHandling(args[argToWrap])
		assert(type(fun) == "function" or fun == nil)
		return originalFunction(table.unpack(args,1,args.n))
	end
end

function errorHandling:WormHole()
	local create = WormHole
	return function()
		local worm = create()
		worm.onTeleportation = self:_autoWrapArgX(worm.onTeleportation,2)
		return worm
	end
end

function errorHandling:WarpJammer()
	local create = WarpJammer
	return function()
		local jammer = create()
		jammer.onTakingDamage = self:_autoWrapArgX(jammer.onTakingDamage,2)
		jammer.onDestruction = self:_autoWrapArgX(jammer.onDestruction,2)
		return jammer
	end
end

function errorHandling:SupplyDrop()
	local create = SupplyDrop
	return function()
		local drop = create()
		drop.onPickUp = self:_autoWrapArgX(drop.onPickUp,2)
		return drop
	end
end

-- the main function here - it wraps all functions with error handling code
function errorHandling:_wrapAllFunctions()
	addGMFunction = self:_autoWrapArgX(addGMFunction,2)

	onNewPlayerShip = self:_autoWrapArgX(onNewPlayerShip,1)
	onGMClick = self:_autoWrapArgX(onGMClick,1)

	-- todo should check update exists before wrapping it
	update = self:wrapWithErrorHandling(update)
	init = self:wrapWithErrorHandling(init)

	WormHole = self:WormHole()
	WarpJammer = self:WarpJammer()
	SupplyDrop = self:SupplyDrop()
end

-- this is a wrapper to allow us to catch errors in the error handling code
function errorHandling:wrapAllFunctions(onError)
	assert(type(onError) == "function")
	self.onError = onError
	self:callWithErrorHandling(self._wrapAllFunctions,self,onError)
end