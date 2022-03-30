-------------------------
-- 2020-06-06
-- for this sandbox there are several related changes
-- change 1
-- a new update function
-- this could be integrated into the sandbox fairly easily
-- the main thing that wants to be done is to allow chaining of update function
-- and have the linear update removed from the time to live update functions
function addlinearUpdate(obj,x1,y1,x2,y2,t)
	obj.time=0
	obj.update = function (self,delta)
		self.time=self.time+delta
		local x=starryUtil.math.lerp(x1,x2,self.time/t)
		local y=starryUtil.math.lerp(y1,y2,self.time/t)
		self:setPosition(x,y)
		if self.time>t then
			self:destroy() -- not good in generic code
		end
	end
	addUpdate(obj)
end

-------------------------
-- change 2
-- a timer mechanism as follows
-- globals
autoChargeSpeed=36
autoCharge=false
autoChargeCharge=0
-- gm buttons in custom menu
	addGMFunction("charge++",function()
		updateChargeStationSpeed(chargeSpeed)
		chargeSpeed=chargeSpeed+1
	end)
	local txt="auto"
	if autoCharge then
		txt="auto*"
	end
	addGMFunction(txt, function ()
		autoCharge=not autoCharge
		customButtons()
	end)
	addGMFunction("spd"..autoChargeSpeed.."+",function()
		autoChargeSpeed=autoChargeSpeed+1
		customButtons()
	end)
	addGMFunction("spd"..autoChargeSpeed.."-",function()
		autoChargeSpeed=autoChargeSpeed-1
		customButtons()
	end)
--call within updateInner
autoChargeUpdate(delta)
-- the main charge function
function autoChargeUpdate(delta)
	if autoCharge then
		autoChargeCharge=autoChargeCharge+delta
		if autoChargeSpeed<autoChargeCharge then
			autoChargeCharge=0
			updateChargeStationSpeed(chargeSpeed)
			chargeSpeed=chargeSpeed+1
		end
	end
end

--------------------------
-- change 3
-- the charge artifacts are as follows
-- within addOrbitUpdate - needed for updateChargeStationSpeed
self.orbit_pos=orbit_pos
-- globals
chargeSpeed=0
chargeStations={
	SpaceStation():setTemplate("Small Station"):setFaction("Human Navy"):setCallSign("charging station 1"),
	SpaceStation():setTemplate("Small Station"):setFaction("Human Navy"):setCallSign("charging station 2"),
	SpaceStation():setTemplate("Small Station"):setFaction("Human Navy"):setCallSign("charging station 3")
}
hasChargeRun=false
chargeArtifact=Artifact():setCallSign("rift device"):setPosition(217500,177500)
-- 
	addGMFunction("charge ripple",chargeRipple)
-- misc functions
function chargeRipple()
	for i = 1,#chargeStations do
		if chargeStations[i]:isValid() then
			local x1,y1=chargeStations[i]:getPosition()
			local x3,y3=chargeArtifact:getPosition()
			local dx=x1-x3
			local dy=y1-y3
			local x2=x1+dx
			local y2=y1+dy
			addchargeUpdate1(Artifact(),x1,y1,x2,y2,3,true)
		end
	end
end
function addchargeUpdate1(obj,x1,y1,x2,y2,t,primary)
	obj.time=0
	obj.primary=primary
	obj.update = function (self,delta)
		local orig_time=self.time
		self.time=self.time+delta
		local x=starryUtil.math.lerp(x1,x2,self.time/t)
		local y=starryUtil.math.lerp(y1,y2,self.time/t)
		self:setPosition(x,y)
		local orig_frac=orig_time/t
		local self_frac=self.time/t
		local primary_size=0
		if primary then
			primary_size=200
		end
		if orig_frac<0.5 and self_frac>0.5 then
			ElectricExplosionEffect():setPosition(x,y):setOnRadar(true):setSize(primary_size+300)-- setOnRadar is not currently exported
			local x,y=self:getPosition()
			self:damageAreaStarry(x,y,primary_size+300,15,80, "emp",0,0,0,0,0) --this needs exporting from the engine properly
		end
		if orig_frac<0.75 and self_frac>0.75 then
			ElectricExplosionEffect():setPosition(x,y):setOnRadar(true):setSize(primary_size+400)-- setOnRadar is not currently exported
			local x,y=self:getPosition()
			self:damageAreaStarry(x,y,primary_size+400,15,80, "emp",0,0,0,0,0) --this needs exporting from the engine properly
		end
		if self.time>t then
			local x,y=self:getPosition()
			self:damageAreaStarry(x,y,primary_size+500,7.5,40, "kinetic",0,0,0,0,0) --this needs exporting from the engine properly
			ExplosionEffect():setPosition(x,y):setOnRadar(true):setSize(primary_size+500)-- setOnRadar is not currently exported
			local dx=x1-x2
			local dy=y1-y2
			self:destroy() -- not good in generic code
			if primary and chargeSpeed > 50 then
				addchargeUpdate1(Artifact(),x2,y2,x2-dx,y2-dy,3,false)
				if chargeSpeed > 75 then
					addchargeUpdate1(Artifact(),x2,y2,x2-dy,y2+dx,3,false)
					addchargeUpdate1(Artifact(),x2,y2,x2+dy,y2-dx,3,false)
				end
			end
		end
	end
	addUpdate(obj)
end
function updateChargeStationSpeed(speed)
	for i = 1,#chargeStations do
		if chargeStations[i]:isValid() then
			local cur=chargeStations[i].orbit_pos or 0
			cur=cur/(math.pi*2)*360
			if not hasChargeRun then
				cur=cur+120*i
			end
			addOrbitUpdate(chargeStations[i],217500,177500,2000,0.5*(1.1^(100-speed)),cur)
			local x1,y1=chargeStations[i]:getPosition()
			local x2,y2=chargeArtifact:getPosition()
			addlinearUpdate(Artifact(),x1,y1,x2,y2,3)
		end
	end
	local msg=speed.."% charged"
	chargeArtifact:setDescription(msg)
	for pidx=1,32 do
		local p = getPlayerShip(pidx)
		if p ~= nil then
			if p:isValid() then
				p:addCustomInfo("Engineering+","charge0",msg)
				p:addCustomInfo("Engineering","charge1",msg)
				p:addCustomInfo("Helms","charge2",msg)
				p:addCustomInfo("Weapons","charge3",msg)
				p:addCustomInfo("Tactical","charge4",msg)
				p:addCustomInfo("Science","charge5",msg)
				p:addCustomInfo("Relay","charge6",msg)
				p:addCustomInfo("Operations","charge7",msg)
			end
		end
	end
	hasChargeRun=true
	if chargeSpeed > 25 then
		chargeRipple()
	end
end