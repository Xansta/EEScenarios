-- the package name "debug" debatably may be better than errorHandling
-- but there is a stock lua package with that name (which isnt included in Empty Epsilon)
errorHandling = {}

-- note - setCommsScript is not wrapped unlike setCommsFunction
-- I am somewhat unsure if it is possible to wrap or not

-- please note - this file is likely to become either irrelevant or in need of update when the EE ECS rework is complete
-- it would be nice if the whole walking through the class hierarchy was moved out into its own file
-- however that walking is likely to be made obsolete semi soon with the ECS system

-- note some SpaceObject are never wrapped - a good example would be missiles fired from craft
-- in general there is a fair chance anything created inside of the EE engine will not have these functions wrapped
-- there are a few soultions
-- we could run each update and find unwrapped objects
-- we could make a pull request to master for an onNewSpaceObject
-- the latter is better in my eyes
-- I am planning personally on waiting ECS changes have been implemented and I'm more sure on whats happening
-- PlayerShips created via the gm screen are ***NOT*** wrapped - this would be fairly easy to fix via wrapping on onNewPlayerShip

function errorHandling:onError(err, replacementTraceback)
	if self._onError then
		if replacementTraceback then
			self._onError(err,replacementTraceback)
		else
			-- it might be nice to suppress the first few lines of the traceback (the ones inside of errorHandling)
			self._onError(err,traceback())
		end
	end
end

function errorHandling:callWithErrorHandling(fun,...)
	assert(type(fun)=="function" or fun==nil)
	if fun ~= nil then
		return xpcall(fun, function(...)
				self:onError(...)
			end, ...)
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

function errorHandling:_WormHole()
	local create = WormHole
	return function()
		local worm = create()
		worm.onTeleportation = self:_autoWrapArgX(worm.onTeleportation,2)
		self:_AddSpaceObjectErrorHandling(worm)
		return worm
	end
end

function errorHandling:_WarpJammer()
	local create = WarpJammer
	return function()
		local jammer = create()
		jammer.onTakingDamage = self:_autoWrapArgX(jammer.onTakingDamage,2)
		jammer.onDestruction = self:_autoWrapArgX(jammer.onDestruction,2)
		self:_AddSpaceObjectErrorHandling(jammer)
		return jammer
	end
end

function errorHandling:_SupplyDrop()
	local create = SupplyDrop
	return function()
		local drop = create()
		drop.onPickUp = self:_autoWrapArgX(drop.onPickUp,2)
		self:_AddSpaceObjectErrorHandling(drop)
		return drop
	end
end

function errorHandling:_PlayerSpaceship()
	local create = PlayerSpaceship
	return function()
		local ship = create()
			self:_AddSpaceShipErrorHandling(ship)
			ship.addCustomButton = self:_autoWrapArgX(ship.addCustomButton,5)
			ship.addCustomMessageWithCallback = self:_autoWrapArgX(ship.addCustomMessageWithCallback,5)
			ship.onProbeLaunch = self:_autoWrapArgX(ship.onProbeLaunch,2)
			ship.onProbeLink = self:_autoWrapArgX(ship.onProbeLink,2)
			ship.onProbeUnlink = self:_autoWrapArgX(ship.onProbeUnlink,2)
		return ship
	end
end

function errorHandling:_CpuShip()
	local create = CpuShip
	return function()
		local ship = create()
		self:_AddSpaceShipErrorHandling(ship)
		return ship
	end
end

function errorHandling:_SpaceStation()
	local create = SpaceStation
	return function()
		local station = create()
		self:_AddShipTemplateBasedObjectErrorHandling(station)
		return station
	end
end

function errorHandling:_ScanProbe()
	local create = ScanProbe
	return function()
		local probe = create()
		probe.onArrival = self:_autoWrapArgX(probe.onArrival,2)
		probe.onExpiration = self:_autoWrapArgX(probe.onExpiration,2)
		probe.onDestruction = self:_autoWrapArgX(probe.onDestruction,2)
		self:_AddSpaceObjectErrorHandling(probe)
		return probe
	end
end

function errorHandling:_EMPMissile()
	local create = EMPMissile
	return function()
		local missile = create()
		self:_AddMissileErrorHandling(missile)
		return missile
	end
end

function errorHandling:_HVLI()
	local create = HVLI
	return function()
		local missile = create()
		self:_AddMissileErrorHandling(missile)
		return missile
	end
end

function errorHandling:_HomingMissile()
	local create = HomingMissile
	return function()
		local missile = create()
		self:_AddMissileErrorHandling(missile)
		return missile
	end
end

function errorHandling:_Nuke()
	local create = Nuke
	return function()
		local missile = create()
		self:_AddMissileErrorHandling(missile)
		return missile
	end
end

function errorHandling:_Artifact()
	local create = Artifact
	return function()
		local artifact = create()
		artifact.onCollision = self:_autoWrapArgX(artifact.onCollision,2)
		artifact.onPlayerCollision = self:_autoWrapArgX(artifact.onPlayerCollision,2)
		artifact.onPickUp = self:_autoWrapArgX(artifact.onPickUp,2)
		artifact.onPickup = self:_autoWrapArgX(artifact.onPickup,2)
		self:_AddSpaceObjectErrorHandling(artifact)
		return artifact
	end
end

function errorHandling:_Mine()
	local create = Mine
	return function()
		local mine = create()
		mine.onDestruction = self:_autoWrapArgX(mine.onDestruction,2)
		self:_AddSpaceObjectErrorHandling(mine)
		return mine
	end
end

function errorHandling:_AddShipTemplateBasedObjectErrorHandling(ship)
	ship.onTakingDamage = self:_autoWrapArgX(ship.onTakingDamage,2)
	ship.onDestruction = self:_autoWrapArgX(ship.onDestruction,2)
	self:_AddSpaceObjectErrorHandling(ship)
	return ship
end

function errorHandling:_AddSpaceShipErrorHandling(ship)
	self:_AddShipTemplateBasedObjectErrorHandling(ship)
	return ship
end

function errorHandling:_AddMissileErrorHandling(missile)
	self:_AddSpaceObjectErrorHandling(missile)
	return missile
end

-- this will call function fn
-- if during the call of fn setCommsMessage is not called then we will call onError if myTraceback has been sent
-- this is due to needing to call this during the setCommsFunction callback (where no setCommsMessage is sometimes useful)
-- and within addCommsReply (where it is not useful)
function errorHandling:_checkRelayMessageSent(fn,myTraceback)
	return function ()
		local _setCommsMessage = setCommsMessage
		local _addCommsReply = addCommsReply
		-- the reversed boolean is annoying, but I am unsure (and am not sure how to confirm)
		-- if a local is set to nil will it be a local or a global (also does it change while its an upvalue?)
		local messageUnset = true
		setCommsMessage = function(msg)
			messageUnset = nil
			_setCommsMessage(msg)
		end
		addCommsReply = function (text, fn)
			return _addCommsReply(text,self:_checkRelayMessageSent(fn,traceback()))
		end
		local ret = fn()
		if messageUnset and myTraceback then
			self:onError("A function set via addCommsReply has been called, but setCommsMessage wasn't called. This will result in relay seeing \"?\"\n Traceback of the function setting the callback is as follows \n\n",myTraceback)
		end
		setCommsMessage = _setCommsMessage
		addCommsReply = _addCommsReply
		return ret
	end
end

function errorHandling:_wrapSetCommsFunction(object, _setCommsFunction)
	return function (object,fn)
		return _setCommsFunction(object,self:_checkRelayMessageSent(fn,nil))
	end
end

function errorHandling:_AddSpaceObjectErrorHandling(object)
	-- we deal with setCommsFunction in two parts
	-- first we are trapping errors happening inside of the call
	object.setCommsFunction = self:_autoWrapArgX(object.setCommsFunction,2)
	-- secondly we are ensuring that setCommsMessage is called at some point
	object.setCommsFunction = self:_wrapSetCommsFunction(object,object.setCommsFunction)
	object.onDestroyed = self:_autoWrapArgX(object.onDestroyed,2)
	return object
end

function errorHandling:_SpaceObjectWrapper(create)
	return function()
		local obj = create()
		self:_AddSpaceObjectErrorHandling(obj)
		return obj
	end
end

-- the main function here - it wraps all functions with error handling code
function errorHandling:_wrapAllFunctions()
	if self.alreadyWrapped then
		addGMMessage("wrapAllFunctions is being called for a second time. While this should work it isnt advised, there will be a performance hit on object creation for no reason")
	end
	self.alreadyWrapped = true

	if #getAllObjects() ~= 0 then
		addGMMessage("some SpaceObject's were created before errorHandling:wrapAllFunctions() was called, this will result in them not having error handling in their functions, consider putting errorHandling:wrapAllFunctions outside of any functions and before the creation of any SpaceObjects")
	end

	addGMFunction = self:_autoWrapArgX(addGMFunction,2)

	onNewPlayerShip = self:_autoWrapArgX(onNewPlayerShip,1)
	onGMClick = self:_autoWrapArgX(onGMClick,1)

	addCommsReply = self:_autoWrapArgX(addCommsReply,2)

	update = self:wrapWithErrorHandling(update)
	init = self:wrapWithErrorHandling(init)

	WormHole = self:_WormHole()
	WarpJammer = self:_WarpJammer()
	SupplyDrop = self:_SupplyDrop()
	PlayerSpaceship = self:_PlayerSpaceship()
	CpuShip = self:_CpuShip()
	SpaceStation = self:_SpaceStation()
	ScanProbe = self:_ScanProbe()

	EMPMissile = self:_EMPMissile()
	HVLI = self:_HVLI()
	HomingMissile = self:_HomingMissile()
	Nuke = self:_Nuke()
	Artifact = self:_Artifact()
	Mine = self:_Mine()

	Asteroid = self:_SpaceObjectWrapper(Asteroid)
	BeamEffect = self:_SpaceObjectWrapper(BeamEffect)
	BlackHole = self:_SpaceObjectWrapper(BlackHole)
	ElectricExplosionEffect = self:_SpaceObjectWrapper(ElectricExplosionEffect)
	ExplosionEffect = self:_SpaceObjectWrapper(ExplosionEffect)
	Nebula = self:_SpaceObjectWrapper(Nebula)
	Planet = self:_SpaceObjectWrapper(Planet)
	VisualAsteroid = self:_SpaceObjectWrapper(VisualAsteroid)
	Zone = self:_SpaceObjectWrapper(Zone)
end

-- this is a wrapper to allow us to catch errors in the error handling code
-- I expect this to be run from a function not inside of init
-- that way it can catch all errors, it also needs to be after init and update are defined
-- a natural location IMO is as the last line of the main script
function errorHandling:wrapAllFunctions(onError)
	assert(type(onError) == "function")
	self._onError = onError
	self:callWithErrorHandling(self._wrapAllFunctions,self,onError)
end