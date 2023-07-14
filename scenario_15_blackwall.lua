-- Name: The Black Wall
-- Description: Fight the Ghosts behind the wall
---
--- One player ship which is spawned by the scenario. Requires beam/shield frequencies
---
--- Author: Dyrian, Daid, Xansta, Muerte
-- Type: Mission
-- Setting[Reputation]: Amount of reputation to start with
-- Reputation[Unknown|Default]: Zero reputation - nobody knows anything about you
-- Reputation[Nice]: 20 reputation - you've had a small positive influence on the local community
-- Reputation[Hero]: 50 reputation - you've helped important people or lots of people

require("utils.lua")

function init()
	scenario_version = "0.0.1"
	print(string.format("     -----     Scenario: Black Wall     -----     Version %s     -----",scenario_version))
	print(_VERSION)
	constructEnvironment()
    -- Create the main ship for the players.
	Serenity=PlayerSpaceship():setFaction("Human Navy"):setTemplate("Player Cruiser"):setPosition(-30000,18500):setCallSign(_("callsign-ship","Serenity"))
	allowNewPlayerShips(false)
	local reputation_config = {
		["Unknown"] = 		0,
		["Nice"] = 			20,
		["Hero"] = 			50,
	}
	Serenity:setReputationPoints(reputation_config[getScenarioSetting("Reputation")])
	Reperaturwerft=SpaceStation():setTemplate("Medium Station"):setFaction("Human Navy"):setPosition(-30000,17000):setCallSign(_("callsign-station","Repair Station"))
	Heimatbasis=SpaceStation():setTemplate("Large Station"):setFaction("Human Navy"):setPosition(3000, 3000):setCallSign(_("callsign-station","Home Station"))
	Wurmlochbasis=SpaceStation():setTemplate("Medium Station"):setFaction("Human Navy"):setPosition(-53000,-25000):setCallSign(_("callsign-station","Wormhole Station"))
	Defend0r=CpuShip():setFaction("Human Navy"):setPosition(4000,6000):setCallSign("Defend0r II"):orderDefendTarget(Heimatbasis)
	setShipToDreadnoughtII(Defend0r)

-- savegamethings
	Save_1=Asteroid():setPosition(-37500,12500)
	Save_2=Asteroid():setPosition(-30000,7500)
	Save_3=Asteroid():setPosition(-22500,12500)
	
	mytime = 0.0
	Wurmlochmodifikation=0
	Wurmlochrange=0
	
	ghost_station_spawned = false
	battles_stations_destroyed = false
	retreat_delay = false
	defend0r_destroyed_message_sent = false
	mission_state="Reperatur"
end
function constructEnvironment()
	--	black holes, asteroids, nebulae, wormholes
	-- Spawne Wurmloch von D1 in das Zentrum des Nebelfeldes
	Wurmloch=WormHole():setPosition(-68123, -38987):setTargetPosition(33417, -61974)
	
	-- Die schwarze Mauer
	BlackHole():setPosition(36000, -100000)
	BlackHole():setPosition(40000, -90000)
	BlackHole():setPosition(48000, -82000)
	Portal_1=BlackHole():setPosition(57000, -74000)
	Portal_2=BlackHole():setPosition(67000, -68000)
	BlackHole():setPosition(77000, -63000)
	
	Nebula():setPosition(26700,-96400)
	Nebula():setPosition(20400,-92100)
	Nebula():setPosition(28100,-89400)
	Nebula():setPosition(20800,-86000)
	Nebula():setPosition(34700,-82000)
	Nebula():setPosition(24500,-77800)
	Nebula():setPosition(16000,-74200)
	Nebula():setPosition(21100,-69100)
	Nebula():setPosition(30500,-71300)
	Nebula():setPosition(37800,-75600)
	Nebula():setPosition(37800,-70000)
	Nebula():setPosition(42600,-71500)
	Nebula():setPosition(48500,-71200)
	Nebula():setPosition(45800,-63700)
	Nebula():setPosition(56200,-61600)
	Nebula():setPosition(42200,-55300)
	Nebula():setPosition(24500,-57900)
	Nebula():setPosition(14800,-60100)
	Nebula():setPosition(22800,-52100)
	Nebula():setPosition(25900,-45600)
	Nebula():setPosition(34400,-48700)
	Nebula():setPosition(42200,-55300)
	Nebula():setPosition(50900,-49200)
	Nebula():setPosition(54800,-55300)
	Nebula():setPosition(62700,-52400)
	Nebula():setPosition(66600,-55500)
	Nebula():setPosition(74100,-53800)
	Nebula():setPosition(66900,-46300)
	Nebula():setPosition(58400,-45100)
	Nebula():setPosition(50900,-49200)
	Nebula():setPosition(84000,-69600)
	Nebula():setPosition(83800,-77800)
	Nebula():setPosition(75500,-72800)
	Nebula():setPosition(70400,-76700)
	Nebula():setPosition(73000,-84400)
	Nebula():setPosition(80100,-87700)
	Nebula():setPosition(73000,-84400)
	Nebula():setPosition(63500,-80100)
	Nebula():setPosition(71100,-92600)
	Nebula():setPosition(65000,-89100)
	Nebula():setPosition(57600,-85800)
	Nebula():setPosition(61200,-95600)
	Nebula():setPosition(51400,-92300)
	Nebula():setPosition(48200,-101200)
	Nebula():setPosition(54400,-102000)
	Wurmlochtarget=Nebula():setPosition(34100,-59900)
	Nebula():setPosition(36900,-39000)
	Nebula():setPosition(45100,-43900)
	
	Nebula():setPosition(87200, -110100)
	Nebula():setPosition(43600, -109300)
	Nebula():setPosition(13100, -109300)
	Nebula():setPosition(-18500, -55800)
	Nebula():setPosition(-22300, -50100)
	Nebula():setPosition(-64600, -49500)
	Nebula():setPosition(-17600, -37300)
	Nebula():setPosition(-21400, -50100)
	Nebula():setPosition(-15600, -23900)
	Nebula():setPosition(7600, -17700)
	Nebula():setPosition(13600, -15900)
	Nebula():setPosition(7500, -11900)
	Nebula():setPosition(42200, -19900)
	Nebula():setPosition(34600, -13900)
	Nebula():setPosition(48800, -3700)
	Nebula():setPosition(-3000, 14300)
	Nebula():setPosition(2100, 19000)
	Nebula():setPosition(-41200, 24400)
	Nebula():setPosition(-83000, -13000)
	Nebula():setPosition(-66800, -14000)
	Nebula():setPosition(-64800, -21100)
	
	Asteroid():setPosition(59600,-95400)
	Asteroid():setPosition(51600,-45700)
	Asteroid():setPosition(42900,-56700)
	Asteroid():setPosition(41000,-53800)
	Asteroid():setPosition(34700,-49700)
	Asteroid():setPosition(33200,-47400)
	Asteroid():setPosition(33100,-40800)
	Asteroid():setPosition(46600,-40400)
	Asteroid():setPosition(51600,-45700)

    for Asteroid_spawn=1,6 do
		Asteroid():setPosition((random(-4000,4000)+26700),(random(-4000,4000)-96400))
		Asteroid():setPosition((random(-4000,4000)+20400),(random(-4000,4000)-92100))
		Asteroid():setPosition((random(-4000,4000)+28100),(random(-4000,4000)-89400))
		Asteroid():setPosition((random(-4000,4000)+20800),(random(-4000,4000)-86000))
		Asteroid():setPosition((random(-4000,4000)+34700),(random(-4000,4000)-82000))
		Asteroid():setPosition((random(-4000,4000)+24500),(random(-4000,4000)-77800))
		Asteroid():setPosition((random(-4000,4000)+16000),(random(-4000,4000)-74200))
		Asteroid():setPosition((random(-4000,4000)+21100),(random(-4000,4000)-69100))
		Asteroid():setPosition((random(-4000,4000)+30500),(random(-4000,4000)-71300))
		Asteroid():setPosition((random(-4000,4000)+37800),(random(-4000,4000)-75600))
		Asteroid():setPosition((random(-4000,4000)+37800),(random(-4000,4000)-70000))
		Asteroid():setPosition((random(-4000,4000)+42600),(random(-4000,4000)-71500))
		Asteroid():setPosition((random(-4000,4000)+48500),(random(-4000,4000)-71200))
		Asteroid():setPosition((random(-4000,4000)+45800),(random(-4000,4000)-63700))
		Asteroid():setPosition((random(-4000,4000)+24500),(random(-4000,4000)-57900))
		Asteroid():setPosition((random(-4000,4000)+14800),(random(-4000,4000)-60100))
		Asteroid():setPosition((random(-4000,4000)+22800),(random(-4000,4000)-52100))
		Asteroid():setPosition((random(-4000,4000)+25900),(random(-4000,4000)-45600))
		Asteroid():setPosition((random(-4000,4000)+62700),(random(-4000,4000)-52400))
		Asteroid():setPosition((random(-4000,4000)+66600),(random(-4000,4000)-55500))
		Asteroid():setPosition((random(-4000,4000)+74100),(random(-4000,4000)-53800))
		Asteroid():setPosition((random(-4000,4000)+66900),(random(-4000,4000)-46300))
		Asteroid():setPosition((random(-4000,4000)+58400),(random(-4000,4000)-45100))
		Asteroid():setPosition((random(-4000,4000)+84000),(random(-4000,4000)-69600))
		Asteroid():setPosition((random(-4000,4000)+83800),(random(-4000,4000)-77800))
		Asteroid():setPosition((random(-4000,4000)+75500),(random(-4000,4000)-72800))
		Asteroid():setPosition((random(-4000,4000)+70400),(random(-4000,4000)-76700))
		Asteroid():setPosition((random(-4000,4000)+73000),(random(-4000,4000)-84400))
		Asteroid():setPosition((random(-4000,4000)+80100),(random(-4000,4000)-87700))
		Asteroid():setPosition((random(-4000,4000)+73000),(random(-4000,4000)-84400))
		Asteroid():setPosition((random(-4000,4000)+57600),(random(-4000,4000)-85800))
		Asteroid():setPosition((random(-4000,4000)+51400),(random(-4000,4000)-92300))
		Asteroid():setPosition((random(-4000,4000)+48200),(random(-4000,4000)-101200))
		Asteroid():setPosition((random(-4000,4000)+54400),(random(-4000,4000)-102000))
		Asteroid():setPosition((random(-4000,4000)+34100),(random(-4000,4000)-59900))
	
		Asteroid():setPosition((random(-7000,7000)+87200),(random(-7000,7000)-110100))
		Asteroid():setPosition((random(-7000,7000)+43600),(random(-7000,7000)-117100))
		Asteroid():setPosition((random(-7000,7000)+13100),(random(-7000,7000)-109300))
		Asteroid():setPosition((random(-7000,7000)-18500),(random(-7000,7000)-55800))
		Asteroid():setPosition((random(-7000,7000)-22300),(random(-7000,7000)-55800))
		Asteroid():setPosition((random(-7000,7000)-64600),(random(-7000,7000)-49500))
		Asteroid():setPosition((random(-7000,7000)-17600),(random(-7000,7000)-37300))
		Asteroid():setPosition((random(-7000,7000)-21400),(random(-7000,7000)-30100))
		Asteroid():setPosition((random(-7000,7000)-15600),(random(-7000,7000)-23900))
		Asteroid():setPosition((random(-7000,7000)+7600),(random(-7000,7000)-17700))
		Asteroid():setPosition((random(-7000,7000)+13600),(random(-7000,7000)-15900))
		Asteroid():setPosition((random(-7000,7000)+7500),(random(-7000,7000)-11900))
		Asteroid():setPosition((random(-7000,7000)+42200),(random(-7000,7000)-19900))
		Asteroid():setPosition((random(-7000,7000)+34600),(random(-7000,7000)-13900))
		Asteroid():setPosition((random(-7000,7000)+48800),(random(-7000,7000)-3700))
		Asteroid():setPosition((random(-7000,7000)-3000),(random(-7000,7000)+14300))
		Asteroid():setPosition((random(-7000,7000)+2100),(random(-7000,7000)+19000))
		Asteroid():setPosition((random(-7000,7000)-41200),(random(-7000,7000)+24400))
		Asteroid():setPosition((random(-7000,7000)-83000),(random(-7000,7000)-13000))
		Asteroid():setPosition((random(-7000,7000)-66800),(random(-7000,7000)-14000))
		Asteroid():setPosition((random(-7000,7000)-64800),(random(-7000,7000)-21100))
	
		VisualAsteroid():setPosition((random(-4000,4000)+26700),(random(-4000,4000)-96400))
		VisualAsteroid():setPosition((random(-4000,4000)+20400),(random(-4000,4000)-92100))
		VisualAsteroid():setPosition((random(-4000,4000)+28100),(random(-4000,4000)-89400))
		VisualAsteroid():setPosition((random(-4000,4000)+20800),(random(-4000,4000)-86000))
		VisualAsteroid():setPosition((random(-4000,4000)+34700),(random(-4000,4000)-82000))
		VisualAsteroid():setPosition((random(-4000,4000)+24500),(random(-4000,4000)-77800))
		VisualAsteroid():setPosition((random(-4000,4000)+16000),(random(-4000,4000)-74200))
		VisualAsteroid():setPosition((random(-4000,4000)+21100),(random(-4000,4000)-69100))
		VisualAsteroid():setPosition((random(-4000,4000)+30500),(random(-4000,4000)-71300))
		VisualAsteroid():setPosition((random(-4000,4000)+37800),(random(-4000,4000)-75600))
		VisualAsteroid():setPosition((random(-4000,4000)+37800),(random(-4000,4000)-70000))
		VisualAsteroid():setPosition((random(-4000,4000)+42600),(random(-4000,4000)-71500))
		VisualAsteroid():setPosition((random(-4000,4000)+48500),(random(-4000,4000)-71200))
		VisualAsteroid():setPosition((random(-4000,4000)+45800),(random(-4000,4000)-63700))
		VisualAsteroid():setPosition((random(-4000,4000)+56200),(random(-4000,4000)-61600))
		VisualAsteroid():setPosition((random(-4000,4000)+42200),(random(-4000,4000)-55300))
		VisualAsteroid():setPosition((random(-4000,4000)+24500),(random(-4000,4000)-57900))
		VisualAsteroid():setPosition((random(-4000,4000)+14800),(random(-4000,4000)-60100))
		VisualAsteroid():setPosition((random(-4000,4000)+22800),(random(-4000,4000)-52100))
		VisualAsteroid():setPosition((random(-4000,4000)+25900),(random(-4000,4000)-45600))
		VisualAsteroid():setPosition((random(-4000,4000)+34400),(random(-4000,4000)-48700))
		VisualAsteroid():setPosition((random(-4000,4000)+42200),(random(-4000,4000)-55300))
		VisualAsteroid():setPosition((random(-4000,4000)+50900),(random(-4000,4000)-49200))
		VisualAsteroid():setPosition((random(-4000,4000)+54800),(random(-4000,4000)-55300))
		VisualAsteroid():setPosition((random(-4000,4000)+62700),(random(-4000,4000)-52400))
		VisualAsteroid():setPosition((random(-4000,4000)+66600),(random(-4000,4000)-55500))
		VisualAsteroid():setPosition((random(-4000,4000)+74100),(random(-4000,4000)-53800))
		VisualAsteroid():setPosition((random(-4000,4000)+66900),(random(-4000,4000)-46300))
		VisualAsteroid():setPosition((random(-4000,4000)+58400),(random(-4000,4000)-45100))
		VisualAsteroid():setPosition((random(-4000,4000)+50900),(random(-4000,4000)-49200))
		VisualAsteroid():setPosition((random(-4000,4000)+84000),(random(-4000,4000)-69600))
		VisualAsteroid():setPosition((random(-4000,4000)+83800),(random(-4000,4000)-77800))
		VisualAsteroid():setPosition((random(-4000,4000)+75500),(random(-4000,4000)-72800))
		VisualAsteroid():setPosition((random(-4000,4000)+70400),(random(-4000,4000)-76700))
		VisualAsteroid():setPosition((random(-4000,4000)+73000),(random(-4000,4000)-84400))
		VisualAsteroid():setPosition((random(-4000,4000)+80100),(random(-4000,4000)-87700))
		VisualAsteroid():setPosition((random(-4000,4000)+73000),(random(-4000,4000)-84400))
		VisualAsteroid():setPosition((random(-4000,4000)+63500),(random(-4000,4000)-80100))
		VisualAsteroid():setPosition((random(-4000,4000)+71100),(random(-4000,4000)-92600))
		VisualAsteroid():setPosition((random(-4000,4000)+65000),(random(-4000,4000)-89100))
		VisualAsteroid():setPosition((random(-4000,4000)+57600),(random(-4000,4000)-85800))
		VisualAsteroid():setPosition((random(-4000,4000)+61200),(random(-4000,4000)-95600))
		VisualAsteroid():setPosition((random(-4000,4000)+51400),(random(-4000,4000)-92300))
		VisualAsteroid():setPosition((random(-4000,4000)+48200),(random(-4000,4000)-101200))
		VisualAsteroid():setPosition((random(-4000,4000)+54400),(random(-4000,4000)-102000))
		VisualAsteroid():setPosition((random(-4000,4000)+34100),(random(-4000,4000)-59900))
		VisualAsteroid():setPosition((random(-4000,4000)+36900),(random(-4000,4000)-39000))
		VisualAsteroid():setPosition((random(-4000,4000)+45100),(random(-4000,4000)-43900))
	
		VisualAsteroid():setPosition((random(-7000,7000)+87200),(random(-7000,7000)-110100))
		VisualAsteroid():setPosition((random(-7000,7000)+43600),(random(-7000,7000)-117100))
		VisualAsteroid():setPosition((random(-7000,7000)+13100),(random(-7000,7000)-109300))
		VisualAsteroid():setPosition((random(-7000,7000)-18500),(random(-7000,7000)-55800))
		VisualAsteroid():setPosition((random(-7000,7000)-22300),(random(-7000,7000)-55800))
		VisualAsteroid():setPosition((random(-7000,7000)-64600),(random(-7000,7000)-49500))
		VisualAsteroid():setPosition((random(-7000,7000)-17600),(random(-7000,7000)-37300))
		VisualAsteroid():setPosition((random(-7000,7000)-21400),(random(-7000,7000)-30100))
		VisualAsteroid():setPosition((random(-7000,7000)-15600),(random(-7000,7000)-23900))
		VisualAsteroid():setPosition((random(-7000,7000)+7600),(random(-7000,7000)-17700))
		VisualAsteroid():setPosition((random(-7000,7000)+13600),(random(-7000,7000)-15900))
		VisualAsteroid():setPosition((random(-7000,7000)+7500),(random(-7000,7000)-11900))
		VisualAsteroid():setPosition((random(-7000,7000)+42200),(random(-7000,7000)-19900))
		VisualAsteroid():setPosition((random(-7000,7000)+34600),(random(-7000,7000)-13900))
		VisualAsteroid():setPosition((random(-7000,7000)+48800),(random(-7000,7000)-3700))
		VisualAsteroid():setPosition((random(-7000,7000)-3000),(random(-7000,7000)+14300))
		VisualAsteroid():setPosition((random(-7000,7000)+2100),(random(-7000,7000)+19000))
		VisualAsteroid():setPosition((random(-7000,7000)-41200),(random(-7000,7000)+24400))
		VisualAsteroid():setPosition((random(-7000,7000)-83000),(random(-7000,7000)-13000))
		VisualAsteroid():setPosition((random(-7000,7000)-66800),(random(-7000,7000)-14000))
		VisualAsteroid():setPosition((random(-7000,7000)-64800),(random(-7000,7000)-21100))
    end
end
function savegamefunction()
	if distance(Serenity, Save_1) < 1000 then
		globalMessage(_("msgMainscreen", "Through the wormhole ..."))
		mission_state="Durchs Wurmloch"
		Test_Drohne:destroy()
		Serenity:setPosition(-54000,-26000)
		setShipToScout(Serenity)
		Ghost_spawn=1
		Wurmlochmodifikation=1
	end
	if distance(Serenity, Save_2) < 1000 then
		globalMessage(_("msgMainscreen", "End fight"))
		Mauerbasis=SpaceStation():setTemplate("Small Station"):setFaction("Human Navy"):setCallSign(_("callsign-station","Wall Base")):setPosition(48837, -55467)
		mission_state="Boom2"
		Test_Drohne:destroy()
		Ghost_spawn=5
		Wurmlochmodifikation=1
		Defend0r:setPosition(50000,-60000)
		Serenity:setPosition(55400,-68500)
		Bombe=SupplyDrop():setFaction("Ghosts"):setPosition(Serenity:getPosition()):setCommsFunction(commsSupplyDrop)
		shipupgrade=random(0,3)
		if shipupgrade < 1 then
			setShipToBeamRS(Serenity)
		elseif shipupgrade < 2 then
			setShipToMissleBeamDType(Serenity)
		else
			setShipToSpeedShieldType(Serenity)
		end
		Serenity:setJumpDrive(false)
	end
	if distance(Serenity, Save_3) < 1000 then
		--not implemented yet
	end
end
function Delayfunction(delta)
	mytime = mytime + delta
	if mytime > 15 then
		mission_state="Victory"
	end
end
function activateDisruptor()
	string.format("")
	Bombe=Artifact():setCommsFunction(commsDisruptor):setPosition(Serenity:getPosition()):allowPickup(false):setModel("cubesat"):setSpin(3.2):setRadarTraceColor(128,0,0)
	Serenity:removeCustom(Serenity.disruptor_button_wea)
	Serenity:removeCustom(Serenity.disruptor_button_tac)
	Serenity.disruptor_button = false
	mission_state="Boom"
end
function compare(freq_min, freq_max)
	frequency = 400 + (Serenity:getShieldsFrequency() * 20)
	if Schildgenerator == 3 and (freq_min <= frequency) and (frequency <= freq_max) then
	 	Defend0r:sendCommsMessage(Serenity, _("-incCall", "Neatly done! Now you have to put your Shields' Frequency to 440, so the Shields of the Ghoststation will collapse."))
		instructions = _("msgRelay","Destroy Ghost Station. Set shield frequency to 440")
		Schildgenerator = 4
	end
	if Schildgenerator_2 == 1 and  (freq_min <= frequency) and (frequency <= freq_max) then
		Defend0r:sendCommsMessage(Serenity, _("-incCall", "Perfect. The Shields of the Ghoststation are destroyed. Now we can launch our Dropship."))
		instructions = _("msgRelay","Destroy Ghost Station")
		Ghost_Station:setShields(0,0,0)
		Schildgenerator = 5
	end
end
function update(delta)
	if not areBeamShieldFrequenciesUsed() then
		reason = _("msgMainscreen","Scenario requires that the Beam/Shield Frequencies option be enabled")
		globalMessage(reason)
		setBanner(reason)
		victory("Ghosts")
	end
	if instructions ~= nil then
		if not Serenity.instructions_button then
			Serenity.instructions_button = true
			Serenity.instructions_button_rel = "instructions_button_rel"
			Serenity.instructions_message_rel = "instructions_message_rel"
			Serenity:addCustomButton("Relay",Serenity.instructions_button_rel,_("buttonRelay","Instructions"),function()
				if instructions ~= nil then
					Serenity:addCustomMessage("Relay",Serenity.instructions_message_rel,instructions)
				else
					Serenity:addCustomMessage("Relay",Serenity.instructions_message_rel,_("msgRelay","None"))
				end
				Serenity.remove_instructions_message_timer_rel = getScenarioTime() + 15
			end)
			Serenity.instructions_button_ops = "instructions_button_ops"
			Serenity.instructions_message_ops = "instructions_message_ops"
			Serenity:addCustomButton("Operations",Serenity.instructions_button_ops,_("buttonRelay","Instructions"),function()
				if instructions ~= nil then
					Serenity:addCustomMessage("Operations",Serenity.instructions_message_ops,instructions)
				else
					Serenity:addCustomMessage("Operations",Serenity.instructions_message_ops,_("msgOperations","None"))
				end
				Serenity.remove_instructions_message_timer_rel = getScenarioTime() + 15
			end)
		end
	else
		if Serenity.instructions_button then
			Serenity:removeCustom(Serenity.instructions_button_rel)
			Serenity:removeCustom(Serenity.instructions_button_ops)
			Serenity.instructions_button = false
		end
	end
	if Serenity.remove_instructions_message_timer_rel ~= nil then
		if getScenarioTime() > Serenity.remove_instructions_message_timer_rel then
			Serenity:removeCustom(Serenity.instructions_message_rel)
			Serenity.remove_instructions_message_timer_rel = nil
		end
	end
	if Serenity.remove_instructions_message_timer_ops ~= nil then
		if getScenarioTime() > Serenity.remove_instructions_message_timer_ops then
			Serenity:removeCustom(Serenity.instructions_message_ops)
			Serenity.remove_instructions_message_timer_ops = nil
		end
	end
--Siegbedingung
	if not Serenity:isValid() then
		victory("Ghosts")
		globalMessage(_("msgMainscreen", "You did not manage to avoid the Ghosts!"))
	end
	if Wurmlochmodifikation==0 then
		if distance(Serenity, Wurmloch) < 3500 and Wurmlochrange ==0 then
  			Wurmlochbasis:sendCommsMessage(Serenity, _("incCall", [[Serenity! What are you doing? Your ship is not prepared for the transit!]]))
  			Wurmlochrange=1
  		end
  		if distance(Serenity, Wurmloch) < 1500 and Wurmlochrange ==1 then
  			globalMessage(_("msgMainscreen", "Your ship is lost in the wormhole!"))
--			Serenity:destroy()
  			victory("Ghosts")
  		end
	end
	if mission_state=="Reperatur" then
		Reperaturwerft:sendCommsMessage(Serenity, _("orders-incCall", "Finally, the maintenance and repairs are complete!\nPay attention to your ship! Don't overstress your Reactor.\nBefore you receive new orders, you should do a field exercise.\nMove to Sector G3 and eliminate the hostile Drone.\nMay the stars guide you."))
		instructions = _("msgRelay","Eliminate drone in G3")
		Test_Drohne=setShipToCruiserDrone(CpuShip()):setFaction("Kraylor"):setPosition(-30000, 47000):setCallSign(_("callsign-ship","Test Drone")):orderAttack(Serenity)
		mission_state="Testlauf"
	end
	if mission_state=="Testlauf" then
		if not Test_Drohne:isValid() then
			Reperaturwerft:sendCommsMessage(Serenity, _("orders-incCall", "Yeah, well done! I see the reactor is still working. Perfect!\nNow the Serenity is fully operational.\nYou should should navigate to the Home Station to get new orders. Your long range scanner should be able to localise the Station.\nPay attention out there.\nMay the stars guide you."))
			instructions = _("msgRelay","Dock with Home Station")
			mission_state="Heimatbasis"
    	end
		savegamefunction()
	end
	if mission_state=="Heimatbasis" then
		if Serenity:isDocked(Heimatbasis) then
			Heimatbasis:sendCommsMessage(Serenity, _("orders-incCall", "Hey Serenity, good to hear that you finaly got released from the dry-dock!\nSince you are fully operational, the fleet command has a small transport quest for your ship. Make your way to the Wormhole Station.\nThe order says: 'Move to the Wormwole Station in sector D2. They need a new deep-telemetry-telescope, which has already been loaded into your cargo hold. Deliver the telescope to the Wormhole Station and wait there for new orders.'\nMay the stars guide you."))
			instructions = _("msgRelay","Dock with Wormhole Station to deliver telescope")
			mission_state="Transportmission"
		end
	end
-- Transportmission zum Wurmloch...
	if mission_state=="Transportmission" then --Transportmission
		if Serenity:isDocked(Wurmlochbasis) then
			Wurmlochbasis:sendCommsMessage(Serenity, _("incCall", "Welcome here at the Wormhole Station!\nThanks for the deep-telemetry-telescope, the cargo has just been unloaded.\nHave a good stopover here.\nMay the stars. .. krrrrtzzzrtzrrrrzrrrrtz\nkkrrrrrtrrrrzzzzr have krrrrtz Interferenkrrrrzrce\nWormholekrr krrzzzzrzrz activated   krrrrzzzrzzzrzrzrzrzrz !!\nkrrzzz Ships krzzzrzzzrzz attack krzzzzzezrzz through Wormkrzzzrzrzzhole krrzzrzz!!!\nemergencykrzzzzzrzzprotocol Omega krzzrzzzzzrzz three initiatedkkrrkrtttkrkkrkkkzzzzkkrkkkzz\nOn krzzrzzrzzrzrz battlekrzzrzzzzzzrzzrzrzrzzrzstation !!!\nkrzzzzzzrzz\nkrzzzrzztz\n..."))
			instructions = "krrrrtzzzrzzzrzrzrzrzrz"
			-- Spawne Gegner vor dem Wurmloch, die quasi aus dem Wurmloch herausgesprungen sind ..
			Ghost_Snake=setShipToFighterII(CpuShip()):setFaction("Ghosts"):setPosition(-65123, -33987):setCallSign(_("callsign-ship","Ghost Snake")):orderAttack(Serenity)
			Ghost_Wolf=setShipToGunshipII(CpuShip()):setFaction("Ghosts"):setPosition(-64123, -34987):setCallSign(_("callsign-ship","Ghost Wolf")):orderAttack(Serenity)
			Ghost_Rat=setShipToFighterII(CpuShip()):setFaction("Ghosts"):setPosition(-65123, -34987):setCallSign(_("callsign-ship","Ghost Rat")):orderAttack(Serenity)
			mission_state="Wurmlochverteidigung"
		end
	end
	if mission_state=="Wurmlochverteidigung" then
		if not Ghost_Wolf:isValid() and not Ghost_Snake:isValid() and not Ghost_Rat:isValid() then
			Wurmlochbasis:sendCommsMessage(Serenity, _("orders-incCall", "Thanks for the Support! It is good that Serenity was in range to help. Hopefully your ship didn't receive too much damage.\nThe attack of the Ghosts came unexpectedly. It seems like they found a way to move their Troops safely through the wormhole. It seems they rearmed their ships in a special way. The debris of the Ghosts ships showed us their modifications. With a bit of luck our engineers can upgrade the Serenity in the same way.\nWe need to know where the attacks come from. So we can coordinate our attack and set up a defence. You have to jump with the Serenity through the Wormhole and scout where the attacks come from.\nDock with the Wormhole Station so we can do the needed modifications on your ship..."))
			instructions = _("msgRelay","Dock with Wormhole Station for wormhole transit ship modifications")
			mission_state="Upgrade"
		end
	end
	if mission_state=="Upgrade" then
		if Serenity:isDocked(Wurmlochbasis) then
			Wurmlochbasis:sendCommsMessage(Serenity, _("orders-incCall", "... thats all. Our engineers modified the Serenity. In addition to the wormhole transit stabilizer we increased your speed and your shields. Now you should be able to avoid the enemy attacks.\nIn exchange we needed to dismount some of your weapons.\nYour order is: 'Scout where the attacks come from. Get an overview about the enemy's strength. Then come back and make a report.'\nMay the stars guide you."))
			instructions = _("msgRelay","Scout attack source through wormhole")
			setShipToScout(Serenity)
			mission_state="Durchs Wurmloch"
			Ghost_spawn=1
			Wurmlochmodifikation=1
		end
	end
	if mission_state=="Durchs Wurmloch" then
		if distance(Serenity, Wurmloch) < 7500 then
			Wurmlochbasis:sendCommsMessage(Serenity, _("incCall", "Attention Serenity!!!\nWe got some unexpected measurement values from the Wormhole! It seems the Ghosts manipulated the Wormhole with some kind of specialized interference. The firmness of the wormhole transist protectors are no longer under warranty!\nThe jump may become bumpy!"))
			instructions = _("msgRelay","Scout attack source through wormhole. Expect a bumpy ride")
			mission_state="Gestrandet"
		end
	end
	if mission_state=="Gestrandet" then
		if Ghost_spawn==1 and distance(Serenity,Wurmlochtarget) < 5000 then
			Ghost_Fly=setShipToFighterII(CpuShip()):setFaction("Ghosts"):setCallSign(_("callsign-ship","Ghost Fly")):setPosition(46382, -66891):orderAttack(Serenity)
			Ghost_Horse=setShipToFighterII(CpuShip()):setFaction("Ghosts"):setCallSign(_("callsign-ship","Ghost Horse")):setPosition(43800, -58599):orderAttack(Serenity)
			Ghost_Donkey=CpuShip():setTemplate("Fighter"):setFaction("Ghosts"):setCallSign(_("callsign-ship","Ghost Donkey")):setPosition(36137, -46657):orderAttack(Serenity)
			-- eventuell noch ne Abfrage machen ob man die Schilde anhatte, dann halt nur weniger dmg bekommen
			globalMessage(_("msgMainscreen", "Massive damage to all systems!"))
			Wurmlochbasis:sendCommsMessage(Serenity,_("incCall", "Massive damage to all systems! Jump drive fault!\nGet yourself ready for battle!. We have located other power signatures in the nebula!"))
			instructions = _("msgRelay","Scout attack source. Watch for enemy ambush")
			Serenity:setJumpDrive(false)
			Serenity:setSystemHealth("Impulse", random(-1,-.8))
			Serenity:setSystemHealth("Maneuver", random(-.5,-.7))
			Serenity:setSystemHealth("Reactor", random(-.2,-.05))
			Serenity:setSystemHealth("RearShield", random(.4,.6))
			Serenity:setSystemHealth("FrontShield", random(.7,.9))
			Serenity:setSystemHealth("BeamWeapons", random(.8,.95))
			Serenity:setSystemHeat("Impulse", random(.8,1))
			Serenity:setSystemHeat("Maneuver", random(.8,.95))
			Serenity:setSystemHeat("Reactor", random(.7,.9))
			Serenity:setSystemHeat("MissileSystem", random(.8,1))
			Serenity:setSystemHeat("RearShield", random(.4,.6))
			Serenity:setSystemHeat("FrontShield", random(.3,.5))
			Ghost_spawn=2
		end
		if Ghost_spawn==2 and not Ghost_Fly:isValid() and not Ghost_Horse:isValid() and not Ghost_Donkey:isValid() then --and not Ghost_Sheep:isValid() then
			mission_state="Überlebt"
		end
	end
	if mission_state=="Überlebt" then
		Heimatbasis:sendCommsMessage(Serenity, _("orders-incCall", "You are still alive! Good job Serenity!\nThe attacks of the Ghosts seems to come from behind the black wall. We dont know anything about the black wall and the things that lay behind it. We need to find a way to get behind the wall.\nWe constructed a small station near the wall. It provides a base and a research post for the black wall. Our scientists need probes from the wall. Scout the wall and find the probes placed near the wall.\nNew orders, Serenity: 'Gather two Probes from the black wall and get them to the 'Wall base'. Beware of the Ghosts. They might still be out in the Nebula\nMay the stars guide you."))
		instructions = _("msgRelay","Locate black wall probes and return them to Wall Base. Watch for Ghosts")
		Mauerbasis=SpaceStation():setTemplate("Small Station"):setFaction("Human Navy"):setCallSign(_("callsign-station","Wall base")):setPosition(48837, -55467)
		Defend0r:orderDefendTarget(Mauerbasis)
		Probe_1=SupplyDrop():setFaction("Human Navy"):setPosition(51744, -75433):setCommsFunction(commsBlackWallProbe):setDescriptions(_("scienceDescription-wallProbe","Black wall scan probe"),_("scienceDescription-wallProbe","Black wall scan probe: scan data stored in probe memory")):setScanningParameters(1,1)
        Probe_2=SupplyDrop():setFaction("Human Navy"):setPosition(37100, -85410):setCommsFunction(commsBlackWallProbe):setDescriptions(_("scienceDescription-wallProbe","Black wall scan probe"),_("scienceDescription-wallProbe","Black wall scan probe: scan data stored in probe memory")):setScanningParameters(1,1)
		Ghost_spawn=3
		mission_state="Schwarze Mauer"
	end
	if mission_state=="Schwarze Mauer" then
		if not Probe_1:isValid() or not Probe_2:isValid() then
			if Ghost_spawn==3 then
				Mauerbasis:sendCommsMessage(Serenity, _("orders-incCall", "Well done, we need one more Probe..."))
				instructions = _("msgRelay","Locate remaining black wall probe. Return probes to Wall Base. Watch for Ghosts")
				setShipToGunshipII(CpuShip()):setFaction("Ghosts"):setCallSign(_("callsign-ship","Ghost Bat")):setPosition(32300, -76400):orderAttack(Serenity)
				setShipToGunshipII(CpuShip()):setFaction("Ghosts"):setCallSign(_("callsign-ship","Ghost Lamb")):setPosition(32400, -75800):orderAttack(Serenity)
				Ghost_spawn=4
			end
		end
		if not Probe_1:isValid() and not Probe_2:isValid() then
			if Ghost_spawn==4 then
				Mauerbasis:sendCommsMessage(Serenity, _("orders-incCall", "Good job, Serenity!\nNow get the Probes to the 'Wall base'"))
				instructions = _("msgRelay","Return black wall probes to Wall Base. Watch for Ghosts")
				Ghost_spawn=5
			end
			if Serenity:isDocked(Mauerbasis) then
				Mauerbasis:sendCommsMessage(Serenity, _("orders-incCall", "Well done Serenity! With these Probes our scientists will find a way through the black wall.\nUntil the science report is available, we have time to upgrade our ship!\nStay docked with the base and contact our engineers via Comms."))
				instructions = _("msgRelay","Stay docked with Wall Base. Contact engineers on Wall Base")
				Mauerbasis:setCommsFunction(commsUpgradeStation)
				mission_state = "Modify"
			end
		end
	end
	if mission_state == "Modify" then
		if not Serenity:isDocked(Mauerbasis) then
			Mauerbasis:sendCommsMessage(Serenity, _("orders-incCall", "Our scientists found a way to collapse the wall, or at least a part of it. The scientists developed a disruptor. You have to place the disruptor inside the wall. Move the disruptor to the black wall in 'B7'. But don't move too deep into the wall!\nWhen Serenity is close enough to the black wall, your weapons officer can activate the disruptor.\nMay the stars guide you."))
			instructions = _("msgRelay","Enter edge of B7 black hole and activate disruptor")
			mission_state="Durchbruch"
		end
	end
	if mission_state=="Durchbruch" then
		if distance(Serenity, Portal_1) < 5000 then
			if not Serenity.disruptor_button then
				Serenity.disruptor_button_wea = "disruptor_button_wea"
				Serenity:addCustomButton("Weapons",Serenity.disruptor_button_wea,_("buttonWeapons","Activate Disruptor"),activateDisruptor)
				Serenity.disruptor_button_tac = "disruptor_button_tac"
				Serenity:addCustomButton("Tactical",Serenity.disruptor_button_tac,_("buttonWeapons","Activate Disruptor"),activateDisruptor)
				Serenity.disruptor_button = true
			end
		else
			if Serenity.disruptor_button then
				Serenity:removeCustom(Serenity.disruptor_button_wea)
				Serenity:removeCustom(Serenity.disruptor_button_tac)
				Serenity.disruptor_button = false
			end
		end
	end
	if mission_state=="Boom" then
		if distance(Bombe, Portal_1) < 1500 then
			mission_state="Boom2"
		end
	end
	if mission_state=="Boom2" then
		Portal_1:destroy()
		Bombe:explode()
		Mauerbasis:sendCommsMessage(Serenity, _("-incCall", "It worked! A big part of the wall collapsed. Now we can get an impression of the Ghost Station out in the Nebula.\nOur subspace deep scanner managed to isolate some strong energy signatures in sectors ZZ8 or ZZ9. It seems like the Ghost Attack base is out there.\nYour goal is to destroy the Ghost Station. We sent the Defend0r and some more forces to assist.\nYour order is: 'Destroy the Ghost Station'\nMay the stars guide you."))
		instructions = _("msgRelay","Find and destroy Ghost Station near ZZ8 or ZZ9")

		Ghost_Station=SpaceStation():setTemplate("Large Station"):setFaction("Ghosts"):setCallSign(_("callsign-station","Ghost Station")):setPosition(80040,-125444)
		BattleStation_Links=setShipToWeaponsPlatformII(CpuShip()):setFaction("Ghosts"):setCallSign(_("callsign-ship","BattleStation Links")):setPosition(74370,-124100):orderRoaming()
		BattleStation_Rechts=setShipToWeaponsPlatformII(CpuShip()):setFaction("Ghosts"):setCallSign(_("callsign-ship","BattleStation Rechts")):setPosition(82560,-119700):orderRoaming()
	
		Ghost_Shark=setShipToFighterII(CpuShip()):setFaction("Ghosts"):setCallSign(_("callsign-ship","Ghost Shark")):setPosition(78747, -129559):orderDefendTarget(Ghost_Station)
		Ghost_Croco=setShipToGunshipII(CpuShip()):setFaction("Ghosts"):setCallSign(_("callsign-ship","Ghost Croco")):setPosition(83593, -127820):orderDefendTarget(Ghost_Station)
		Ghost_Lion=CpuShip():setTemplate("Cruiser"):setFaction("Ghosts"):setCallSign(_("callsign-ship","Ghost Lion")):setPosition(69580, -119856):orderDefendLocation(69580, -119856)
		Ghost_Ele=setShipToGunshipII(CpuShip()):setFaction("Ghosts"):setCallSign(_("callsign-ship","Ghost Ele")):setPosition(73000,-115500):orderDefendLocation(73000,-115500)
		Ghost_Ant=setShipToFighterII(CpuShip()):setFaction("Ghosts"):setCallSign(_("callsign-ship","Ghost Ant")):setPosition(83546, -114698):orderDefendLocation(83546, -114698)
		Ghost_Ape=setShipToFighterII(CpuShip()):setFaction("Ghosts"):setCallSign(_("callsign-ship","Ghost Ape")):setPosition(77100,-113700):orderDefendLocation(77100,-113700)
	
		Ghost_Bee=setShipToFighterII(CpuShip()):setFaction("Ghosts"):setCallSign(_("callsign-ship","Ghost Bee")):setPosition(58246, -98445):orderDefendLocation(58246, -98445)
		Ghost_Cat=setShipToFighterII(CpuShip()):setFaction("Ghosts"):setCallSign(_("callsign-ship","Ghost Cat")):setPosition(64631, -92350):orderDefendLocation(64631, -92350)
		Ghost_Dog=setShipToFighterII(CpuShip()):setFaction("Ghosts"):setCallSign(_("callsign-ship","Ghost Dog")):setPosition(71139, -88665):orderDefendLocation(71139, -88665)
	
		Defend0r:orderFlyFormation(Serenity, -500, 2500)
		local defend_numbers = {}
		for i=11,99 do
			table.insert(defend_numbers,i)
		end
		setShipToFighterII(CpuShip()):setFaction("Human Navy"):setCallSign(string.format(_("callsign-ship","Defend %s"),tableRemoveRandom(defend_numbers))):setPosition(47646, -57097):orderFlyFormation(Defend0r, -750, 1000):setScanState("simplescan")
		CpuShip():setTemplate("Fighter"):setFaction("Human Navy"):setCallSign(string.format(_("callsign-ship","Defend %s"),tableRemoveRandom(defend_numbers))):setPosition(48348, -56731):orderFlyFormation(Serenity, -750, 1000):setScanState("simplescan")
		CpuShip():setTemplate("Fighter"):setFaction("Human Navy"):setCallSign(string.format(_("callsign-ship","Defend %s"),tableRemoveRandom(defend_numbers))):setPosition(49111, -56410):orderFlyFormation(Serenity, -750, -1000):setScanState("simplescan")
		setShipToFighterII(CpuShip()):setFaction("Human Navy"):setCallSign(string.format(_("callsign-ship","Defend %s"),tableRemoveRandom(defend_numbers))):setPosition(47356, -56151):orderFlyFormation(Defend0r, -750, -1000):setScanState("simplescan")
		CpuShip():setTemplate("Fighter"):setFaction("Human Navy"):setCallSign(string.format(_("callsign-ship","Defend %s"),tableRemoveRandom(defend_numbers))):setPosition(48119, -55754):orderFlyFormation(Serenity, -1000, -2000):setScanState("simplescan")
		ghost_station_spawned = true
		mission_state="Endkampf"
	end
	if mission_state=="Endkampf" then
		if distance(Serenity, Ghost_Station) < 21000 then
			Mauerbasis:sendCommsMessage(Serenity, _("-incCall", "Serenity, we received new information about the Battlestations observed by Defend0r near the Ghost Station.\nIt seems they are connected to the main Ghost Station through a c35-subspace-connection. If we manage to destroy the main Ghost Station, then the Battlestations will also explode.\nOne more thing: The Defend0r carries a special high explosive charge which she can attach to the Ghost Station with a Dropship. But the Defend0r must get very close to the Station.\nSerenity, your order is: 'Support the Defend0r in any way. Draw the fire and protect the Defend0r at all costs!'\nMay the stars guide you."))
			instructions = string.format(_("msgRelay","Destroy Ghost Station. Defend %s"),Defend0r:getCallSign())
			Defend0r:orderFlyTowardsBlind(80040,-125444)
			Schildgenerator=1
			mission_state="Defend0r"
		end
	end
	if mission_state=="Defend0r" then
		if Defend0r:isValid() then
			if Schildgenerator==1 and distance(Defend0r, Ghost_Station) < 3500 then
				Defend0r:orderIdle()
				Defend0r:sendCommsMessage(Serenity, _("-incCall", "Serenity, we are now in range for launching the Dropship, but the shields of the Ghost base are too strong. You need to help us lowering the shields. If we use our own shield generators and generate interference, we may manage to collapse the Shields of the Ghost Station.\nFirst of all overheat your front and rear-shields"))
				instructions = string.format(_("msgRelay","Destroy Ghost Station. Defend %s. Overheat shields"),Defend0r:getCallSign())
				if Ghost_Shark:isValid() then
					Ghost_Shark:orderAttack(Defend0r)
				end
				if Ghost_Croco:isValid() then
					Ghost_Croco:orderAttack(Serenity)
				end
				if Ghost_Lion:isValid() then
					Ghost_Lion:orderAttack(Defend0r)
				end
				if Ghost_Ele:isValid() then
					Ghost_Ele:orderAttack(Serenity)
				end
				if Ghost_Ant:isValid() then
					Ghost_Ant:orderAttack(Defend0r)
				end
				if Ghost_Ape:isValid() then
					Ghost_Ape:orderAttack(Defend0r)
				end
				Schildgenerator=2
			end
		else
			if not defend0r_destroyed_message_sent then
				Mauerbasis:sendCommsMessage(Serenity,string.format(_("-incCall", "%s has been destroyed. You are on your own to destroy the Ghost Station"),Defend0r:getCallSign()))
				instructions = _("msgRelay","Destroy Ghost Station")
				defend0r_destroyed_message_sent = true
			end
		end
		if Defend0r:isValid() then
			if Schildgenerator == 2 and Serenity:getSystemHeat("FrontShield") > 0.9 and Serenity:getSystemHeat("RearShield") > 0.9 and distance(Serenity, Ghost_Station) < 4000 then
				Defend0r:sendCommsMessage(Serenity, _("-incCall", [[Well done! Now set the shield frequency to 720... Fast, we need to hurry!]]))
				instructions = string.format(_("msgRelay","Destroy Ghost Station. Defend %s. Set shield frequency to 720"),Defend0r:getCallSign())
				Schildgenerator = 3
			end
			if Schildgenerator == 3 then
				compare(720,720)
			end
			if Schildgenerator == 4 then
				Schildgenerator_2 = 1
				compare (440, 440)
			end
			if Schildgenerator == 5 then
				if Schildgenerator_2 == 1 then
					Dropship=CpuShip():setTemplate("Tug"):setFaction("Human Navy"):setCallSign("Dropship"):setPosition(Defend0r:getPosition()):orderFlyTowardsBlind(Ghost_Station:getPosition())
					Schildgenerator_2 = 2
				end
				if Schildgenerator_2 == 2 and distance(Dropship, Ghost_Station) < 1000 then
					Ghost_Station:destroy()
					Dropship:destroy()
					Schildgenerator_2 = 3
				end
			end
		else
			if not defend0r_destroyed_message_sent then
				Mauerbasis:sendCommsMessage(Serenity,string.format(_("-incCall", "%s has been destroyed. You are on your own to destroy the Ghost Station"),Defend0r:getCallSign()))
				instructions = _("msgRelay","Destroy Ghost Station")
				defend0r_destroyed_message_sent = true
			end
		end
	end
	if ghost_station_spawned then
		if not Ghost_Station:isValid() then
			if BattleStation_Links:isValid() then
				ExplosionEffect():setPosition(BattleStation_Links:getPosition()):setSize(3000):setOnRadar(true)
				BattleStation_Links:destroy()
			end
			if BattleStation_Rechts:isValid() then
				ExplosionEffect():setPosition(BattleStation_Rechts:getPosition()):setSize(3000):setOnRadar(true)
				BattleStation_Rechts:destroy()
			end
			if not battles_stations_destroyed then
				Mauerbasis:sendCommsMessage(Serenity, _("-incCall", "Well done Serenity! You destroyed the ememy's main station.\nThe attack of the ghosts has been thwarted.\nThe remaining Ghosts will probably retreat now."))
				instructions = nil
				if Ghost_Shark:isValid() then
					Ghost_Shark:orderFlyTowardsBlind(60000,-145000)
				end
				if Ghost_Croco:isValid() then
					Ghost_Croco:orderFlyTowardsBlind(60000,-145000)
				end
				if Ghost_Lion:isValid() then
					Ghost_Lion:orderFlyTowardsBlind(60000,-145000)
				end
				if Ghost_Ele:isValid() then
					Ghost_Ele:orderFlyTowardsBlind(60000,-145000)
				end
				if Ghost_Ant:isValid() then
					Ghost_Ant:orderFlyTowardsBlind(60000,-145000)
				end
				if Ghost_Ape:isValid() then
					Ghost_Ape:orderFlyTowardsBlind(60000,-145000)
				end
				battles_stations_destroyed = true
				retreat_delay = true
			end
		end
	end
	if retreat_delay then
		Delayfunction(delta)
	end
	if mission_state=="Victory" then
		globalMessage(_("msgMainscreen", "The Serenity was able to defend humanity from the Invasion of the ghosts! You can be proud of your crew!"))
		victory("Human Navy")
	end
end
--Communication function for supply drop ships. Does not allow for much interaction.
function commsSupplyDrop()
	if comms_source:isFriendly(comms_target) then
		setCommsMessage(_("-comms", "Scan here ..."));
		return true
	end
	if comms_source:isEnemy(comms_target) then
		return false
	end
	setCommsMessage(_("-comms", "Tick, Tick, Tick, Tick, ... Boooom!"));
end
function commsBlackWallProbe()
    setCommsMessage(_("-comms", "Scan here ..."));
    return true
end
function commsDisruptor()
    setCommsMessage(_("-comms", "Tick, Tick, Tick, Tick, ... Boooom!"));
end
--Communication function for the upgrade station. Allow you to upgrade your ship once.
function commsUpgradeStation()
	if comms_source:isEnemy(comms_target) then
		return false
	end
	if comms_source:isFriendly(comms_target) then
		if not comms_source:isDocked(comms_target) then
			setCommsMessage(_("station-comms", "Good day officer,\nIf you want to upgrade the ship, you have to dock with us first."))
			return
		end
		if comms_source:isDocked(comms_target) then
			if comms_source:getTypeName() == "Player Cruiser" or comms_source:getTypeName() == "Serenity_Scout" then
				setCommsMessage(_("station-comms", "Hey Serenity,\nWe can upgrade your ship in different ways. Please choose your way."))
				addCommsReply(_("station-comms", "Upgrade our speed and shields please!"),
				function()
					setShipToSpeedShieldType(comms_source)
					setCommsMessage(_("station-comms", "A wise choice!\nYou can undock now."))
				end)
				addCommsReply(_("station-comms", "Upgrade our missile storage and beam damage!"),
				function()
					setShipToMissleBeamDType(comms_source)
					setCommsMessage(_("station-comms", "A wise choice!\nYou can undock now."))
				end)
				addCommsReply(_("station-comms", "Upgrade our beam range and the speed of fire!"),
				function()
					setShipToBeamRS(comms_source)
					setCommsMessage(_("station-comms", "A wise choice!\nYou can undock now."))
				end)
			else
				setCommsMessage(_("station-comms", "Do you like your upgrades?"))
				Mauerbasis:setCommsFunction(nil)
				Mauerbasis:setCommsScript("comms_station.lua")
			end
		end
	end
end
function tableRemoveRandom(array)
--	Remove random element from array and return it.
	-- Returns nil if the array is empty,
	-- analogous to `table.remove`.
    local array_item_count = #array
    if array_item_count == 0 then
        return nil
    end
    local selected_item = math.random(array_item_count)
    local temp = array[selected_item]
    array[selected_item] = array[array_item_count]
    array[array_item_count] = temp
    return table.remove(array)
end
--Ship changing functions, to apply different ship updates to the player
function setShipToScout(ship)
	ship:setTypeName("Serenity_Scout")
	ship:setWeaponTubeCount(2)
	ship:setWeaponTubeDirection(0,0)
	ship:setWeaponTubeDirection(1,180)
	ship:setWeaponTubeExclusiveFor(0,"Homing")
	ship:setWeaponTubeExclusiveFor(1,"Mine")
	ship:commandUnloadTube(1)
	ship:setShieldsMax(150, 150)
	ship:setImpulseMaxSpeed(120)
	ship:setRotationMaxSpeed(20)
	ship:setWeaponStorageMax("Homing", 8)
	ship:setWeaponStorageMax("Mine", 1)
	ship:setWeaponStorageMax("Nuke", 0)
	ship:setWeaponStorageMax("EMP", 0)
end
function setShipToSpeedShieldType(ship)
	ship:setTypeName("Serenity_Speed_Shield")
	ship:setWeaponTubeCount(2)
	ship:setWeaponTubeDirection(0,0)
	ship:setWeaponTubeDirection(1,180)
	ship:setWeaponTubeExclusiveFor(0,"Homing")
	ship:setWeaponTubeExclusiveFor(1,"Mine")
	ship:weaponTubeAllowMissle(0,"Nuke")
	ship:weaponTubeAllowMissle(0,"EMP")
	ship:setShieldsMax(150, 150)
	ship:setShields(150, 150)
	ship:setImpulseMaxSpeed(105)
	ship:setRotationMaxSpeed(15)
	ship:setWeaponStorageMax("Homing", 12)
	ship:setWeaponStorageMax("Mine", 8)
	ship:setWeaponStorageMax("Nuke", 4)
	ship:setWeaponStorageMax("EMP", 6)
end
function setShipToMissleBeamDType(ship)
	ship:setTypeName("Serenity_Missile_BeamD")
	ship:setBeamWeapon(0, 90, -15, 1000.0, 6.0, 15)
	ship:setBeamWeapon(1, 90,  15, 1000.0, 6.0, 15)
	ship:setWeaponTubeCount(2)
	ship:setWeaponTubeDirection(0,0)
	ship:setWeaponTubeDirection(1,180)
	ship:setWeaponTubeExclusiveFor(0,"Homing")
	ship:setWeaponTubeExclusiveFor(1,"Mine")
	ship:weaponTubeAllowMissle(0,"Nuke")
	ship:weaponTubeAllowMissle(0,"EMP")
	ship:setShieldsMax(80, 80)
	ship:setImpulseMaxSpeed(90)
	ship:setRotationMaxSpeed(10)
	ship:setWeaponStorageMax("Homing", 15)
	ship:setWeaponStorageMax("Mine", 10)
	ship:setWeaponStorageMax("Nuke", 6)
	ship:setWeaponStorageMax("EMP", 6)
	ship:setWeaponStorage("Homing", 15)
	ship:setWeaponStorage("Mine", 10)
	ship:setWeaponStorage("Nuke", 6)
	ship:setWeaponStorage("EMP", 6)
end
function setShipToBeamRS(ship)
	ship:setTypeName("Serenity_BeamRS")
	ship:setBeamWeapon(0, 90, -15, 1500.0, 4.0, 15)
	ship:setBeamWeapon(1, 90,  15, 1500.0, 4.0, 15)
	ship:setWeaponTubeCount(2)
	ship:setWeaponTubeDirection(0,0)
	ship:setWeaponTubeDirection(1,180)
	ship:setWeaponTubeExclusiveFor(0,"Homing")
	ship:setWeaponTubeExclusiveFor(1,"Mine")
	ship:weaponTubeAllowMissle(0,"Nuke")
	ship:weaponTubeAllowMissle(0,"EMP")
	ship:setShieldsMax(80, 80)
	ship:setImpulseMaxSpeed(90)
	ship:setRotationMaxSpeed(10)
	ship:setWeaponStorageMax("Homing", 12)
	ship:setWeaponStorageMax("Mine", 8)
	ship:setWeaponStorageMax("Nuke", 4)
	ship:setWeaponStorageMax("EMP", 6)
end
--Conversion function to convert a CpuShip into a different version specially for this scenario
function setShipToDreadnoughtII(ship)
	ship:setTemplate("Dreadnought")
	ship:setTypeName("Dreadnought II")
	ship:setHullMax(200):setHull(200)				--stronger (vs 70)
	ship:setShieldsMax(100, 100, 100, 100, 100)		--weaker (vs 300x5)
	ship:setImpulseMaxSpeed(90)						--faster (vs 30)
	ship:setRotationMaxSpeed(4)						--faster (vs 1.5)
	ship:setWeaponTubeCount(1)						--more (vs 0)
	ship:setTubeLoadTime(0, 15)
	ship:setWeaponStorageMax("Homing", 8):setWeaponStorage("Homing", 8)
	return ship
end
function setShipToWeaponsPlatformII(ship)
	ship:setTemplate("Weapons platform")
	ship:setTypeName("Weapons platform II")
	ship:setBeamWeapon(0, 30,   0, 4000.0, 3.5, 10)	--slower cycle (vs 1.5), less damage (vs 20)
	ship:setBeamWeapon(1, 30,  60, 4000.0, 3.5, 10)
	ship:setBeamWeapon(2, 30, 120, 4000.0, 3.5, 10)
	ship:setBeamWeapon(3, 30, 180, 4000.0, 3.5, 10)
	ship:setBeamWeapon(4, 30, 240, 4000.0, 3.5, 10)
	ship:setBeamWeapon(5, 30, 300, 4000.0, 3.5, 10)
	ship:setHullMax(170):setHull(170)				--stronger hull (vs 70)
	return ship
end
function setShipToDreadnoughtIII(ship)
	ship:setTemplate("Dreadnought")
	ship:setTypeName("Dreadnought III")
	ship:setHullMax(100):setHull(100)			--stronger (vs 70)
	ship:setShieldsMax(100, 100, 100, 100, 100)	--weaker (vs 300x5)
	ship:setImpulseMaxSpeed(40)					--faster (vs 30)
	ship:setRotationMaxSpeed(3)					--faster (vs 1.5)
	ship:setWeaponTubeCount(1)					--more (vs 0)
	ship:setTubeLoadTime(0, 15)
	ship:setWeaponStorageMax("Homing", 8):setWeaponStorage("Homing", 8)
	return ship
end
function setShipToGunshipII(ship)
	ship:setTemplate("Adv. Gunship")
	ship:setTypeName("Gunship II")
	ship:setBeamWeapon(0, 50,-15, 1000.0, 6.0, 10)	--more damage (vs 8)
	ship:setBeamWeapon(1, 50, 15, 1000.0, 6.0, 10)
	ship:setHullMax(90):setHull(90)					--weaker hull (vs 100)
	return ship
end
function setShipToFighterII(ship)
	ship:setTemplate("Fighter")
	ship:setTypeName("Fighter II")
	ship:setBeamWeapon(0, 60, 0, 1000.0, 4.0, 6)	--more damage (vs 4)
	ship:setHullMax(60):setHull(60)					--stronger hull (vs 30)
	ship:setShieldsMax(50):setShields(50)			--stronger shields (vs 30)
	ship:setImpulseMaxSpeed(100)					--slower impulse (vs 120)
	ship:setWeaponTubeCount(1)						--more tubes (vs 0)
	ship:setTubeLoadTime(0, 8)
	ship:setWeaponStorageMax("Homing", 2):setWeaponStorage("Homing", 2)
	return ship
end
function setShipToCruiserDrone(ship)
	ship:setTemplate("Cruiser")
	ship:setTypeName("Cruiser_Drone")
	ship:setHullMax(80):setHull(80)
	ship:setShieldsMax(60, 60):setShields(60, 60)
	ship:setImpulseMaxSpeed(70)
	ship:setRotationMaxSpeed(15)
	return ship
end