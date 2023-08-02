-- Name: Rescue Us!
-- Description: Rescue people off a research station near a star that is going to go nova. GM controls the spawning of enemies and starting the nova countdown on the GM screen.
---
--- May be configured to run with one to six player ships.
---
--- Version 1
-- Type: Mission
-- Author: Kilted Klingon, Xansta
-- Setting[Players]: Determine the number of player ships that will participate in this scenario. The default is 1 Atlantis
-- Players[One|Default]: One player ship Excalibur, Atlantis class
-- Players[Two]: Two player ships: Excalibur (Atlantis), Gyrefalcon (Flavia P. Falcon)
-- Players[Three]: Three player ships: Excalibur (Atlantis), Gyrefalcon (Flavia P. Falcon), Terrex (Repulse)
-- Players[Four]: Four player ships: Excalibur, Discovery (both Atlantis), Gyrefalcon, Kestrel (both Flavia P. Falcon)
-- Players[Five]: Five player ships: Excalibur, Discovery (both Atlantis), Gyrefalcon, Kestrel (both Flavia P. Falcon), Terrex (Repulse)
-- Players[Six]: Six player ships: Excalibur, Discovery (both Atlantis), Gyrefalcon, Kestrel (both Flavia P. Falcon), Terrex, Endeavor (Repulse)
-- Setting[FTL]: Are warp drives bolted on to the player ships? Default: bolt a warp drive onto each player ship
-- FTL[Warp|Default]: A warp drive will be installed on each player ship
-- FTL[Stock]: The stock drive (warp, jump, etc.) will be what's on each player ship
-- Setting[Capacity]: Determines the safe haven capacity. Default: Enough
-- Capacity[Enough|Default]: There is just enough safe haven capacity to rescue everyone
-- Capacity[Excess]: There is more than enough capacity to rescue everyone
-- Setting[Calculating]: Determines if the numbers (evacuees, capacities, etc.) are round for easy planning or not.
-- Calculating[Round|Default]: People numbers (evacuees, capacities, etc.) are evenly divisible by 5 or 10
-- Calculating[Spiky]: People numbers (evacuees, capacities, etc.) vary and may not be evenly divisible
-- Setting[Beams]: Sets the player's beam weapons characteristics
-- Beams[Normal|Default]: Player ships have normal beam capability
-- Beams[Faster]: Player ships' beam weapons recharge faster between shots
-- Beams[Stronger]: Player ships' beam weapons deliver more damage
-- Beams[Faster and Stronger]: Player ships' beam weapons recharge faster and deliver more damage

--	Version History Summary:
--	see dev notebook for details, but this is a sparse summary of the versions
--		v 1.4: fix stats that print from GM screen button
--		v 1.3: selectable number of player ships and other configuration choices
--		v 1.2: retailored to a 3 ship configuration explicitly for Orlando Exec event
--		v 1.1: tailored down to 4 ships explicitly for PdM LTS team event; included a 'dump stats' GM button/function to show in-game stats (turns out this function might have a bug that needs to be fixed):
--		v 1.0: reorganized the script for easier maintenance; completely revamped the far side "terrain" map to include lots of orbital mechanics; disabled the 'planet crash test algorithm'
--		v 0.5 was the initial playable version first used in Aug '19; no frills, just kinda bare-bones functionality
require("utils.lua")
require("place_station_scenario_utility.lua")
function init()
	scenario_version = "1.5"
	ee_version = "2023.06.17"
	print(string.format("    ----    Scenario: Rescue Us!    ----    Version %s    ----    Tested with EE version %s    ----",scenario_version,ee_version))
	print(_VERSION)
	stationList = {}			--friendly and neutral stations
	friendlyStationList = {}	
	enemyStationList = {}
	briefing_message = Artifact():setCallSign("Regional Headquarters"):setCommsScript(""):setCommsFunction(briefingComms):setPosition(-500000,-500000)
	
	-- GLOBAL VARIABLES
		-- Variables that may be modified before game start to adjust game play
			--Player ship passenger capacities
				atlantisCapacity = 30
				flaviaCapacity = 80
				repulseCapacity = 60
			--Station personnel capacities; Note: These are human navy capacities. Independent safe stations will take half of these capacities
				hugeStationCapacity = 400  -- originally 500, but decreased to 400 temporarily
				largeStationCapacity = 200
				mediumStationCapacity = 100
				smallStationCapacity = 50
			--Player ship starting coordinates:
				--player index	1	       2          3          4         5        6
				--ship type     Atlantis   Atlantis   Flavia     Flavia    Repulse  Repulse
				--names         Excalibur  Discovery  Gyrefalcon  Kestrel  Terrex  Endeavor
				playerStartX = {  45500,      24000,     43500,    22000,   43500,     22000}
				playerStartY = { -11000,     -31000,    -10000,   -30000,  -12000,    -32000}
			stevx = 9000		--stellar event locus x coordinate
			stevy = 9000		--stellar event locus y coordinate
			stevRadius = 7000	--stellar event effect radius
			auto_end = true		--game will automatically declare victory once all have been removed from planet in peril
			--Station(s) requiring evacuation due to proximity to imminent stellar event
				--stn. danger index  1     2
				-- stationDangerX = {3000, 5000}  -- original
				-- stationDangerY = {3000, 5000}  -- original
				stationDangerX = {570000}  -- wormhole variant mod
				stationDangerY = {-30000}  -- wormhole variant mod
				danger_station_is_orbiting = true   -- set this to true if you want the space station in danger to be orbiting the exploding star in the 'far side' area; set to false to not orbit and make easier
				danger_station_orbit_time = 54000 -- this is the amount of time it takes the space station to orbit the exploding star, measured in 'game tics'; approx 60 game tics/sec
			--Stations a safe distance from imminent stellar event
				--stn. safe index   1       2       3       4       5       6		7			8		9
				stationSafeX = {-55000, -52000, -50000, -47000, -148000, -144500, -130000, -110000, -68000}
				stationSafeY = { 19500,  19500,  19500,  19500,   10500,   10500,   53000,   86000, 128000}
			-- items for the exploding star 
				exploding_star_x_location = 560000
				exploding_star_y_location = 0
				exploding_star_radius = 12000
				lethal_blast_radius = exploding_star_radius * 3.0
				exploding_star_is_orbiting = true    -- set this to true if you want the exploding star to be orbiting the black hole in the 'far side' area; set to false to not orbit and make easier
				exploding_star_orbit_time = 2400  -- this is the amount of time it takes the star to orbit the black hole, measured in real-time seconds
				explosive_nebula = 250  -- this means the individual number of nebula that will be in the explosion; -- be careul here!! -- 500 seems to be about the max before server crashes; seems to handle 250 ok
				nebula_min_velocity = 20   -- for the super nova 'ejecta'
				nebula_max_velocity = 100  -- for the super nova 'ejecta'
				-- very important!  set the distance from the explosion center you'd like the nebula "chunks" to be removed from the game, otherwise they'll continue on forever and forever.... ;]
				clean_up_distance = 101000
				-- EXPLOSION OPTIONS:  CHOOSE ONLY ONE OF THE FOLLOWING TO BE 'TRUE'
					explosion_option_1 = false  -- this has the stellar ejecta continuing to expand until they go past the clean up distance and then they're removed from the map
					explosion_option_2 = true   -- this has the stellar ejecta stopping at a calculated distance from the star center and remaining on the map
			-- items for far side black hole  and accretion disc
				black_hole_location_x = 620000
				black_hole_location_y = 30000
				blackHoleAccretionDiscGassesList = {}
				black_hole_accretion_disc_gasses_are_on = true  -- set this to true if you want the far side black hole to have an orbiting accretion disc of gasses (nebulea)
				black_hole_accretion_disc_gasses_distance = 15000  -- from the location of the far side black hole; gasses will be at a uniform distance
				black_hole_accretion_disc_gasses_density = 16 -- the number of nebulea that form the accretion disc; 
				black_hole_accretion_disc_gasses_orbit_time = 3600  -- this is the amount of time it takes a single nebula to orbit the black hole, measured in 'game tics'; approx 60 game tics/sec
				
				blackHoleAccretionDiscAsteroidsList = {}
				black_hole_accretion_disc_asteroids_are_on = true  -- set this to true if you want the far side black hole to have an orbiting accretion disc of asteroids (that can travel very fast, and be very deadly....)
				black_hole_accretion_disc_asteroids_density = 100 -- the number of asteroids that help form the accretion disc... traveling at lethal velocity, of course... ;] 
				black_hole_accretion_disc_asteroids_min_distance = black_hole_accretion_disc_gasses_distance - 1500
				black_hole_accretion_disc_asteroids_max_distance = black_hole_accretion_disc_gasses_distance + 1500
				black_hole_accretion_disc_asteroids_min_velocity = black_hole_accretion_disc_gasses_orbit_time * 4
				black_hole_accretion_disc_asteroids_max_velocity = black_hole_accretion_disc_gasses_orbit_time 
		
		-- Variables and structures that *!MUST NOT!* be modified; these are necessary for managing game play
			wfv = "nowhere"		--wolf fence value - used for debugging
			playerShips = {}
			stationDangerList = {}
			stationSafeList = {}
			total_passengers_killed = 0  -- some passengers may be killed while being transported, so we keep a tally of them here
			-- items for the exploding star 
				exploding_star = Planet()
				countdown_active = false
				exploding_now = false
				remaining_number_of_nebula = 0
				explosiveNebulaList = {}
				explosion_location_x = nil
				explosion_location_y = nil
				blast_wave_radius_marker = 0
				objects_in_initial_lethal_blast_radius = {}
			-- for AI transport management (mostly provides background movement and activity)
				transportList = {}
				transportTargetStationList = {}
				spawn_delay = 0   -- for transports
			-- elements for gathering statistics; these were brought in from "Limited Resources" and "Earn Your Wings", and have not been fully implemented here yet
				friendlyTalliedKilledList = {}
				friendlyStationsDestoyedList = {}
				total_enemy_ships_spawned = 0
				total_enemy_ships_crashed_into_planets = 0
				total_enemy_ships_destroyed_by_players = 0
				total_transport_ships_spawned = 0
				total_transport_ships_crashed_into_planets = 0
				total_transport_ships_destroyed_by_enemy_ships = 0
			-- a separate list for the decoy stations; it is populated when the stations are created, but nothing actively done with it yet
				decoyStationList = {}
			-- lists for planet collision calculations
				planetList = {}  -- brought forward from EYW and Limited Resources to enable ship/planet collision management
				planetKillRadius = {}   -- brought forward from EYW and Limited Resources to enable ship/planet collision management
			-- not sure how these globals matter to the "Rescue" scenario, but keep for now because they were included (perhaps a hold-over from another variant, but now irrelevant?)
				missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
				--Ship Template Name List
					stnl = {"MT52 Hornet","MU52 Hornet","Adder MK5","Adder MK4","WX-Lindworm","Adder MK6","Phobos T3","Phobos M3","Piranha F8","Piranha F12","Ranus U","Nirvana R5A","Stalker Q7","Stalker R7","Atlantis X23","Starhammer II","Odin","Fighter","Cruiser","Missile Cruiser","Strikeship","Adv. Striker","Dreadnought","Battlestation","Blockade Runner","Ktlitan Fighter","Ktlitan Breaker","Ktlitan Worker","Ktlitan Drone","Ktlitan Feeder","Ktlitan Scout","Ktlitan Destroyer","Storm"}
				--Ship Template Score List
					stsl = {5            ,5            ,7          ,6          ,7            ,8          ,15         ,16         ,15          ,15           ,25       ,20           ,25          ,25          ,50            ,70             ,250   ,6        ,18       ,14               ,30          ,27            ,80           ,100            ,65               ,6                ,45               ,40              ,4              ,48              ,8              ,50                 ,22}
				-- square grid deployment
					fleetPosDelta1x = {0,1,0,-1, 0,1,-1, 1,-1,2,0,-2, 0,2,-2, 2,-2,2, 2,-2,-2,1,-1, 1,-1}
					fleetPosDelta1y = {0,0,1, 0,-1,1,-1,-1, 1,0,2, 0,-2,2,-2,-2, 2,1,-1, 1,-1,2, 2,-2,-2}
				-- rough hexagonal deployment
					fleetPosDelta2x = {0,2,-2,1,-1, 1, 1,4,-4,0, 0,2,-2,-2, 2,3,-3, 3,-3,6,-6,1,-1, 1,-1,3,-3, 3,-3,4,-4, 4,-4,5,-5, 5,-5}
					fleetPosDelta2y = {0,0, 0,1, 1,-1,-1,0, 0,2,-2,2,-2, 2,-2,1,-1,-1, 1,0, 0,3, 3,-3,-3,3,-3,-3, 3,2,-2,-2, 2,1,-1,-1, 1}
		

	-- functions that establish and build the scenario
		-- those written by Xansta
			setVariations()  -- this is where all the logic is called to setup the "Rescue" player ships depending on the scenario variation chosen at startup
			-- buildNonMissionStations()    -- this function is an elaborate construct to add a variable number of stations to the map in a mostly random setup; not used for this variant as I am building a specifically designed layout
		-- those written by Kilted Klingon
			createWormholes()   -- specifically for the "Rescue" variant
			createLocalAreaSpace()    -- specifically for the "Rescue" variant, sets up the spatial terrain in the "local" area on the near side of the wormhole
			createFarSideSpace() -- specifically for the "Rescue" varient, sets up the spatial terrain on the far side of the wormhole
			arrangeMissionStations()  -- this is more or less a manual re-arrangement function to place stations after they've been (somewhat randomly) generated and place into a list
			simpleAndDirectGenericStationPlacement()   -- tailored specifically for this variant to make it simple to add "clutter" / "decoy" stations in the mix without the overhead complexity of the other script code
			createGMButtons()
			debugInitDataDump() -- debug init data dump for inspection purposes; comment out when not needed

end
--	MISC UTILITIES SECTION
function createRandomAlongArc(object_type, amount, x, y, distance, startArc, endArcClockwise, randomize)
	-- Create amount of objects of type object_type along arc
	-- Center defined by x and y
	-- Radius defined by distance
	-- Start of arc between 0 and 360 (startArc), end arc: endArcClockwise
	-- Use randomize to vary the distance from the center point. Omit to keep distance constant
	-- Example:
	--   createRandomAlongArc(Asteroid, 100, 500, 3000, 65, 120, 450)
	if randomize == nil then randomize = 0 end
	if amount == nil then amount = 1 end
	arcLen = endArcClockwise - startArc
	if startArc > endArcClockwise then
		endArcClockwise = endArcClockwise + 360
		arcLen = arcLen + 360
	end
	if amount > arcLen then
		for ndex=1,arcLen do
			radialPoint = startArc+ndex
			pointDist = distance + random(-randomize,randomize)
			object_type():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist)			
		end
		for ndex=1,amount-arcLen do
			radialPoint = random(startArc,endArcClockwise)
			pointDist = distance + random(-randomize,randomize)
			object_type():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist)			
		end
	else
		for ndex=1,amount do
			radialPoint = random(startArc,endArcClockwise)
			pointDist = distance + random(-randomize,randomize)
			object_type():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist)
		end
	end
end
function availableForComms(p)
	if not p:isCommsInactive() then
		return false
	end
	if p:isCommsOpening() then
		return false
	end
	if p:isCommsBeingHailed() then
		return false
	end
	if p:isCommsBeingHailedByGM() then
		return false
	end
	if p:isCommsChatOpen() then
		return false
	end
	if p:isCommsChatOpenToGM() then
		return false
	end
	if p:isCommsChatOpenToPlayer() then
		return
	end
	if p:isCommsScriptOpen() then
		return false
	end
	return true
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
function showStats()
	local statistic_object = {
		atlantis_capacity = atlantisCapacity,
		flavia_capacity = flaviaCapacity,
		repulse_capacity = repulseCapacity
	}
	return statistic_object
end
function createGMButtons()
	clearGMFunctions()
	-- this button activates the star explosion countdown and builds the array with all the nebula that will explode
	addGMFunction("Countdown!", 
		function()
			-- populate the nebula list (priming the exposion)
			for i=1,explosive_nebula do
				explosiveNebulaList[i] = Nebula()  --:setPosition(exploding_star_x_location, exploding_star_y_location)
				explosiveNebulaList[i].explosion_heading_direction = math.random(1, 360)
				explosiveNebulaList[i].velocity = math.random(nebula_min_velocity, nebula_max_velocity)
				explosiveNebulaList[i].stopping_distance = explosiveNebulaList[i].velocity * 1000 
			end
			countdown_active = true
			if countdown_trigger == nil then
				countdown_trigger = getScenarioTime() + 5
			end
			remaining_number_of_nebula = explosive_nebula
			
			objects_in_initial_lethal_blast_radius = exploding_star:getObjectsInRange(lethal_blast_radius)
				print("    number of objects within initial lethal blast radius:  " .. #objects_in_initial_lethal_blast_radius)

			print(">>>>> Explosion matrix initiated with " .. #explosiveNebulaList .. " nebula!")
			print(">>>>> Five second countdown underway....")
			print(">>>>> We're in trouble now!!")
	end)
	addGMFunction("Print Stats", 
		function()
			print("  ")
			print(">>>>>>>>>>>>>> CURRENT PAX EVAC STATS <<<<<<<<<<<<<< ")
			local remaining_to_evacuate = 0
			-- check status of table:  stationDangerList
			local danger_list_count = string.format("   The stationDangerList (table) has:  %i stations. Details:",#stationDangerList)
			local out = string.format("Current Statistics:\n%s",danger_list_count)
			print(danger_list_count)
			for i, station in ipairs(stationDangerList) do
				local danger_station_stats = string.format("      %s in %s: %i",stationDangerList[i]:getCallSign(),stationDangerList[i]:getSectorName(),stationDangerList[i].people)
				print(danger_station_stats)
				out = string.format("%s\n%s",out,danger_station_stats)
				remaining_to_evacuate = remaining_to_evacuate + station.people
			end 
			local people_remaining = string.format("   People remaining to evacuate:  %i",remaining_to_evacuate)
			print(people_remaining)
			out = string.format("%s\n%s\n   Stations accepting refugees and the space each has available:",out,people_remaining)
			for i=1,#stationSafeList do
				local safe_station_stats = string.format("      %s %s in %s: %i",stationSafeList[i]:getFaction(),stationSafeList[i]:getCallSign(),stationSafeList[i]:getSectorName(),stationSafeList[i].maxPeople - stationSafeList[i].people)
				print(safe_station_stats)
				out = string.format("%s\n%s",out,safe_station_stats)
			end
			-- go through playerShips table and print passengers enroute
			local start_players = string.format("   There were %i player ships at the start",#playerShips)
			print(start_players)
			out = string.format("%s\n%s",out,start_players)
			print("   Current # of passengers in transit on remaining ships:")
			out = string.format("%s\n   Current # of passengers in transit on remaining ships:",out)
			for idx, player_ship in ipairs(playerShips) do
				local ship_line = ""
				if player_ship:isValid() then
					ship_line = string.format("      %s:  %s   - passengers currently on board: %s",idx,player_ship:getCallSign(),player_ship.passenger)
				else
					ship_line = string.format("      %s:  (ship destroyed)",idx)
				end
				print(ship_line)
				out = string.format("%s\n%s",out,ship_line)
			end
			local killed_line = string.format("   Passengers killed while in transit: %i",total_passengers_killed)
			print(killed_line)
			out = string.format("%s\n%s",out,killed_line)
			addGMMessage(out)
			print(">>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<< ")
	end)
	addGMFunction("Main Screen Stats",function()
		local out = mainScreenStats()
		addGMMessage(string.format("This message was sent to the players' main screens:\n%s",out))
	end)
	local button_label = "Auto end N->Y"
	if auto_end then
		button_label = "Auto end Y->N"
	end
	addGMFunction(button_label,function()
		if auto_end then
			auto_end = false
			addGMMessage("Auto end is now set to No. When all the people in danger have been removed from the stations in peril, the game will not automatically declare victory. This gives you the GM the opportunity to make it go supernova so everyone can watch.")
		else
			auto_end = true
			addGMMessage("Auto end is now set to Yes. When all the people in danger have been removed from the stations in peril, the game will put up the victory screen and end.")
		end
		createGMButtons()
	end)
end
function mainScreenStats()
	local remaining_to_evacuate = 0
	for idx, station in ipairs(stationDangerList) do
		remaining_to_evacuate = remaining_to_evacuate + station.people
	end
	local out = string.format("Endangered:%s",remaining_to_evacuate)
	local in_transit = 0
	for i,p in ipairs(getActivePlayerShips()) do
		if p.passenger ~= nil then
			in_transit = in_transit + p.passenger
		end
	end
	if in_transit > 0 then
		out = string.format("%s In Transit:%s",out,in_transit)
	end
	local rescued_people = 0
	for i, station in ipairs(stationSafeList) do
		if station ~= nil and station:isValid() then
			if station.people ~= nil then
				rescued_people = rescued_people + station.people
			end
		end
	end
	if rescued_people > 0 then
		out = string.format("%s\nRescued:%s",out,math.floor(rescued_people))
	end
	if total_passengers_killed > 0 then
		out = string.format("%s Perished:%s",out,total_passengers_killed)
	end
	globalMessage(out)
	setBanner(out)
	return out
end
--	FOUNDATIONAL OPTIONS INIT SECTION
--	The set of functions below elaborates and directly supports the init() funciton
function setVariations()
	player_ship_start_stats = {
		["Excalibur"] =		{template = "Atlantis",			x = 45500, y = -11000, capacity = 30,	warp = 300,	lrs = 30000},
		["Discovery"] =		{template = "Atlantis",			x = 24000, y = -31000, capacity = 30,	warp = 300,	lrs = 35000},
		["Gyrefalcon"] =	{template = "Flavia P.Falcon",	x = 43500, y = -10000, capacity = 80,	warp = 500,	lrs = 20000},
		["Kestrel"] =		{template = "Flavia P.Falcon",	x = 22000, y = -30000, capacity = 80,	warp = 500,	lrs = 25000},
		["Terrex"] =		{template = "Repulse",			x = 43500, y = -12000, capacity = 60,	warp = 400,	lrs = 40000},
		["Endeavor"] =		{template = "Repulse",			x = 22000, y = -32000, capacity = 60,	warp = 400,	lrs = 45000},
	}
	local player_ship_config = {
		["Six"] =	{"Excalibur","Discovery", "Gyrefalcon","Kestrel","Terrex","Endeavor"},
		["Five"] =	{"Excalibur","Discovery", "Gyrefalcon","Kestrel","Terrex"},
		["Four"] =	{"Excalibur","Discovery", "Gyrefalcon","Kestrel"},
		["Three"] =	{"Excalibur","Gyrefalcon","Terrex"},
		["Two"] =	{"Excalibur","Gyrefalcon"},
		["One"] =	{"Excalibur"},
	}
	local mission_station_config = {
		["Six"] =	{
						{status = "danger",	size = "Huge",		faction = "Human Navy"},	--500	total 500
						{status = "safe",	size = "Large",		faction = "Human Navy"},	--200	total 500
						{status = "safe",	size = "Medium",	faction = "Human Navy"},	--100
						{status = "safe",	size = "Small",		faction = "Human Navy"},	-- 50
						{status = "safe",	size = "Medium",	faction = "Independent"},	-- 50
						{status = "safe",	size = "Small",		faction = "Independent"},	-- 25
						{status = "safe",	size = "Small",		faction = "Independent"},	-- 25
						{status = "safe",	size = "Small",		faction = "Independent"},	-- 25
						{status = "safe",	size = "Small",		faction = "Independent"},	-- 25
					},
		["Five"] =	{
						{status = "danger",	size = "Huge",		faction = "Human Navy"},	--500	total 500
						{status = "safe",	size = "Large",		faction = "Human Navy"},	--200	total 500
						{status = "safe",	size = "Medium",	faction = "Human Navy"},	--100
						{status = "safe",	size = "Small",		faction = "Human Navy"},	-- 50
						{status = "safe",	size = "Small",		faction = "Human Navy"},	-- 50
						{status = "safe",	size = "Medium",	faction = "Independent"},	-- 50
						{status = "safe",	size = "Small",		faction = "Independent"},	-- 25
						{status = "safe",	size = "Small",		faction = "Independent"},	-- 25
					},
		["Four"] =	{
						{status = "danger",	size = "Huge",		faction = "Human Navy"},	--500	total 500
						{status = "safe",	size = "Large",		faction = "Human Navy"},	--200	total 500
						{status = "safe",	size = "Medium",	faction = "Human Navy"},	--100
						{status = "safe",	size = "Small",		faction = "Human Navy"},	-- 50
						{status = "safe",	size = "Small",		faction = "Human Navy"},	-- 50
						{status = "safe",	size = "Medium",	faction = "Independent"},	-- 50
						{status = "safe",	size = "Medium",	faction = "Independent"},	-- 50
					},
		["Three"] =	{
						{status = "danger",	size = "Huge",		faction = "Human Navy"},	--500	total 500
						{status = "safe",	size = "Large",		faction = "Human Navy"},	--200	total 500
						{status = "safe",	size = "Medium",	faction = "Human Navy"},	--100
						{status = "safe",	size = "Small",		faction = "Human Navy"},	-- 50
						{status = "safe",	size = "Large",		faction = "Independent"},	--100
						{status = "safe",	size = "Medium",	faction = "Independent"},	-- 50
					},
		["Two"] =	{
						{status = "danger",	size = "Large",		faction = "Human Navy"},	--200	total 200
						{status = "safe",	size = "Medium",	faction = "Human Navy"},	--100	total 200
						{status = "safe",	size = "Small",		faction = "Human Navy"},	-- 50
						{status = "safe",	size = "Small",		faction = "Independent"},	-- 25
						{status = "safe",	size = "Small",		faction = "Independent"},	-- 25
					},
		["One"] =	{
						{status = "danger",	size = "Large",		faction = "Human Navy"},	--200	total 200
						{status = "safe",	size = "Medium",	faction = "Human Navy"},	--100	total 200
						{status = "safe",	size = "Small",		faction = "Human Navy"},	-- 50
						{status = "safe",	size = "Medium",	faction = "Independent"},	-- 50				
					},
	}
	station_capacity = {	--Human Navy capacity. Independent is half of the value
		["Huge"] =		500,
		["Large"] = 	200,
		["Medium"] =	100,
		["Small"] =		50	
	}
	local player_ship_config_ship_names = player_ship_config[getScenarioSetting("Players")]
	local warp_me = getScenarioSetting("FTL")
	rescue_capacity = getScenarioSetting("Capacity")
	calc_round = true
	if getScenarioSetting("Calculating") == "Spiky" then
		calc_round = false
	end
	local player_beams = getScenarioSetting("Beams")
	for i,name in ipairs(player_ship_config_ship_names) do
		local p = PlayerSpaceship():setTemplate(player_ship_start_stats[name].template):setCallSign(name):setFaction("Human Navy"):setPosition(player_ship_start_stats[name].x,player_ship_start_stats[name].y)
		p.passenger = 0
		p.maxPassenger = player_ship_start_stats[name].capacity
		if not calc_round then
			p.maxPassenger = p.maxPassenger + math.random(1,9)
		end
		if warp_me == "Warp" then
			p:setWarpDrive(true)
			p:setWarpSpeed(player_ship_start_stats[name].warp)
		end
		p:addReputationPoints(40):onDestruction(playerDestroyed)
		if player_ship_start_stats[name].template == "Atlantis" then
			p:setWeaponTubeDirection(1,90):setWeaponTubeDirection(2,0):setWeaponTubeDirection(3,0)
			p:setTubeSize(2,"small"):setTubeSize(3,"small")
			p:setTubeLoadTime(2,4):setTubeLoadTime(3,4):setTubeLoadTime(4,12)
			p:setBeamWeapon(2,60,-90,1500,6,8):setBeamWeapon(3,60,90,1500,6,8)
		end
		if player_ship_start_stats[name].template == "Flavia P.Falcon" then
			p:setImpulseMaxSpeed(70)
		end
		if player_ship_start_stats[name].template == "Repulse" then
			p:setImpulseMaxSpeed(80)
		end
		if player_beams ~= "Normal" then
			if string.find("Faster",player_beams) then
				for i=0,15 do
					local rng = p:getBeamWeaponRange(i)
					if rng > 1 then
						local arc = p:getBeamWeaponArc(i)
						local dir = p:getBeamWeaponDirection(i)
						local cyc = p:getBeamWeaponCycleTime(i)
						local dmg = p:getBeamWeaponDamage(i)
						p:setBeamWeapon(i,arc,dir,rng,cyc/2,dmg)
					end
				end
			end
			if string.find("Stronger",player_beams) then
				for i=0,15 do
					local rng = p:getBeamWeaponRange(i)
					if rng > 1 then
						local arc = p:getBeamWeaponArc(i)
						local dir = p:getBeamWeaponDirection(i)
						local cyc = p:getBeamWeaponCycleTime(i)
						local dmg = p:getBeamWeaponDamage(i)
						p:setBeamWeapon(i,arc,dir,rng,cyc,dmg*2)
					end
				end
			end
		end
		p:setLongRangeRadarRange(player_ship_start_stats[name].lrs)
		p.initialized = true
		table.insert(playerShips,p)
	end
	onNewPlayerShip(setNewlySpawnedPlayerShipStats)
	local mission_stations = mission_station_config[getScenarioSetting("Players")]
	for i,mission_station in ipairs(mission_stations) do
		placeMissionStation(mission_station.status,mission_station.size,mission_station.faction)
	end
	if not calc_round then
		local additional_people = 0
		for i,station in ipairs(stationDangerList) do
			local bonus = #stationSafeList + math.random(1,30)
			station.people = station.people + bonus
			additional_people = additional_people + bonus
		end
		for i=1,additional_people do
			local station = stationSafeList[math.random(1,#stationSafeList)]
			station.maxPeople = station.maxPeople + 1
		end
	end
end
function debugInitDataDump()
	-- just as the name implies, this function is to produce a data dump after the init() function to see what the initial state of the important data/tracking structures before execution updates begin
	print("  ")
	print("   -------------- Debug Initial Data Dump -------------------")
	
	-- check status of table:  planetList
	print("   The planetList (table) has:  " .. #planetList .. " elements")
	--[[ for idx, planet in ipairs(planetList) do
		print("      " .. idx .. ":  " .. planetList:getCallSign())
	end --]]

	-- check status of table:  stationDangerList
	print("   The stationDangerList (table) has:  " .. #stationDangerList .. " elements")
	for idx, station in ipairs(stationDangerList) do
		print("      " .. idx .. ":  " .. station:getCallSign())
	end 

	-- check status of table:  stationSafeList
	print("   The stationSafeList (table) has:  " .. #stationSafeList .. " elements")
	for idx, station in ipairs(stationSafeList) do
		print("      " .. idx .. ":  " .. station:getCallSign() .. "   Type:  " .. station:getTypeName())
	end 

	-- check status of table:  playerShips
	print("   The playerShips list (table) has:  " .. #playerShips .. " elements")
	for idx, player_ship in ipairs(playerShips) do
		print("      " .. idx .. ":  " .. player_ship:getCallSign())
	end

	--[[ check exploding star flags
	print("   Exploding star flags:")
	if countdown_active then 
		print("      countdown_active:  true")
	else
		print("      countdown_active:  false")
	end
	if explosion_in_progress then 
		print("      explosion_in_progress:  true")
	else
		print("      explosion_in_progress:  false")
	end  --]]

	-- check exploding star flags
	print("   Exploding star flags:")
	if countdown_active then 
		print("      countdown_active:  true")
	else
		print("      countdown_active:  false")
	end
	if exploding_now then 
		print("      exploding_now:  true")
	else
		print("      exploding_now:  false")
	end  --]]




	print("   ------------------------ end -----------------------------")

end
--	Player ship respawn creation and player ship destruction functions
function setNewlySpawnedPlayerShipStats(p)
	if not p.initialized then
		local player_ship_template = p:getTypeName()
		local start_stats = {
			["Atlantis"] =			{x = 45500, y = -11000, capacity = 30, warp = 300, lrs = 30000},
			["Flavia P.Falcon"] =	{x = 43500, y = -10000, capacity = 80, warp = 500, lrs = 20000},
			["Repulse"] =			{x = 43500, y = -12000, capacity = 60, warp = 400, lrs = 40000},
		}
		if start_stats[player_ship_template].x ~= nil then
			p:setPosition(start_stats[player_ship_template].x,start_stats[player_ship_template].y)
		else
			p:setPosition(44500,-10500)
		end
		if ship_names == nil or #ship_names < 1 then
			ship_names = {"Substitute","Replacement","Latecomer","Expendable","Newbie","Fresh Meat"}
		end
		p:setCallSign(tableRemoveRandom(ship_names))
		p.passenger = 0
		if start_stats[player_ship_template].capacity ~= nil then
			p.maxPassenger = start_stats[player_ship_template].capacity
		else
			p.maxPassenger = 20
		end
		if getScenarioSetting("FTL") == "Warp" then
			p:setWarpDrive(true)
			if start_stats[player_ship_template].warp ~= nil then
				p:setWarpSpeed(start_stats[player_ship_template].warp)
			else
				p:setWarpSpeed(250)
			end
		end
		p:onDestruction(playerDestroyed)
		if player_ship_template == "Atlantis" then
			p:setWeaponTubeDirection(1,90):setWeaponTubeDirection(2,0):setWeaponTubeDirection(3,0)
			p:setTubeSize(2,"small"):setTubeSize(3,"small")
			p:setTubeLoadTime(2,4):setTubeLoadTime(3,4):setTubeLoadTime(4,12)
			p:setBeamWeapon(2,60,-90,1500,6,8):setBeamWeapon(3,60,90,1500,6,8)
		end
		if player_ship_template == "Flavia P.Falcon" then
			p:setImpulseMaxSpeed(70)
		end
		if player_ship_template == "Repulse" then
			p:setImpulseMaxSpeed(80)
		end
		if start_stats[player_ship_template].lrs ~= nil then
			p:setLongRangeRadarRange(start_stats[player_ship_template].lrs)
		else
			p:setLongRangeRadarRange(20000)
		end
		p.initialized = true
		table.insert(playerShips,p)
	end
end
function playerDestroyed(victim, attacker)
	print("  ")
	print("   !!! Player ship " .. victim:getCallSign() .. " has been destroyed!!")
	if victim.passenger ==  0 then
		print("   Thankfully no passengers were on board at the time.")
	else
		print("   !!! " .. victim.passenger .. " Passengers killed in transit!!")
	end
	total_passengers_killed = total_passengers_killed + victim.passenger	
end
--	TERRAIN SECTION
--	The set of functions below establishes the different terrains
function createLocalAreaSpace()
	-- this function draws out all the spatial bodies for the local "home" area that will also contain all the target stations for evacuees

	-- first, general variables
	no_atmosphere_padding = 250  -- current estimate is extra 250 distance is necessary for planet with NO atmosphere; don't think the size of the planet matters
	atmosphere_padding = 500  -- current estimate is extra 500 distance is necessary for planet WITH atmosphere; don't think the size of the planet matters
	medium_planet_padding = 750
	jumbo_planet_padding = 1250 -- trial and error amount for extra distance necessary for jumbo planets
	
	-- the center object:
	origin_X = 0
	origin_Y = 0
 
 	-- set up big central star
	central_star_radius = 10000   -- set via variable so to use calculation elsewhere
	central_star = Planet():setPosition(origin_X, origin_Y)
		:setPlanetRadius(central_star_radius)
		:setDistanceFromMovementPlane(0)
		-- :setPlanetSurfaceTexture("planets/planet-2.png")
		:setPlanetAtmosphereTexture("planets/star-1.png")
		:setPlanetAtmosphereColor(1,0.6,0.6)
	table.insert(planetList, central_star)
	table.insert(planetKillRadius, 10000 + jumbo_planet_padding)   -- why is the extra needed?  not sure, just is
	
	-- set up ring of asteroids with variable distance and speed around the central star, inbetween the orbits of the two space stations
	central_star_asteroid_ring_1 = {}  
	cs_ring1_min_radius = 24000   -- from the center of the star being orbited
	cs_ring1_max_radius = 29000   -- from the center of the star being orbited
	number_of_asteroids_in_ring = 300
	asteroid_min_orbit_speed = 360/(60 * 360) -- this equates to the number of degrees traversed for each update call if one complete orbit takes 240 seconds
	asteroid_max_orbit_speed = 360/(60 * 240) -- this equates to the number of degrees traversed for each update call if one complete orbit takes 120 seconds
	
	for i=1,number_of_asteroids_in_ring do
		-- the ring will be a nested table (multi-dimensional array)
			  -- 1st position on the inner array will be the asteroid object
			  -- 2nd position on the inner array will be the current angle of the asteroid in relation to the blackhole center
			  -- 3rd position on the inner array will be the radius distance from the blackhole center, randomly generated in a band range
			  -- 4th position on the inner array will be the orbital speed of the asteroid, expressed as a delta of angle change per update cycle, randomly generated
		central_star_asteroid_ring_1[i] = {}
		central_star_asteroid_ring_1[i][1] = Asteroid()
		central_star_asteroid_ring_1[i][2] = math.random(1, 360)
		central_star_asteroid_ring_1[i][3] = math.random(cs_ring1_min_radius, cs_ring1_max_radius)
		central_star_asteroid_ring_1[i][4] = random(asteroid_min_orbit_speed, asteroid_max_orbit_speed)
		setCirclePos(central_star_asteroid_ring_1[i][1], origin_X, origin_Y, central_star_asteroid_ring_1[i][2], central_star_asteroid_ring_1[i][3])
	end

	-- planetary orbital sub-system, to the 'north' of the center star
		cs_main_planet1 = Planet():setPosition(origin_X, origin_Y-80000)
			:setPlanetRadius(5000)
			:setDistanceFromMovementPlane(0)
			:setAxialRotationTime(30)
			:setPlanetSurfaceTexture("planets/gas-1.png")
			:setPlanetAtmosphereColor(0.0,0.7,0.5)
		table.insert(planetList, cs_main_planet1)
		table.insert(planetKillRadius, 5000 + medium_planet_padding)   
		setCirclePos(cs_main_planet1, origin_X, origin_Y, 225, 80000)   -- used for testing purposes
		cs_main_planet1:setOrbit(central_star, 7200)  -- orbit rate of 7200 secs ~= 2 hrs

	-- build a boundary ring of nebula
	for i=1,360,5 do
		new_nebula = Nebula()
		setCirclePos(new_nebula, origin_X, origin_Y, i, math.random(95000, 105000))
	end

	-- throw in a bunch of random asteroids in a band that doesn't have orbitals, but these are stationary
	for i=1,500 do
		new_asteroid = Asteroid()
		setCirclePos(new_asteroid, origin_X, origin_Y, math.random(1, 360), math.random(45000, 65000))
	end


end
function createFarSideSpace()
	-- this is on the far side of the wormhole; note this is for planets, stars, nebula, blackholes, etc, and not stations; they go in a separate function

	far_side_blackhole = BlackHole():setPosition(black_hole_location_x, black_hole_location_y):setCallSign("Nemesis")
	
	exploding_star:setPosition(exploding_star_x_location, exploding_star_y_location)
		:setPlanetRadius(exploding_star_radius)
		:setDistanceFromMovementPlane(0)
		:setPlanetAtmosphereTexture("planets/star-1.png")
		:setPlanetAtmosphereColor(1,1,1)
		:setCallSign("Pandora")
		
	if exploding_star_is_orbiting then
		exploding_star:setOrbit(far_side_blackhole, exploding_star_orbit_time)
	end
	table.insert(planetList, exploding_star)
	table.insert(planetKillRadius, 12000 + jumbo_planet_padding)   -- why is the extra needed?  not sure, just is

	-- it's really ugly, but just for now, cram this in here; the initial setup if the station in danger is orbiting the (to be) exploding star
	if danger_station_is_orbiting then
		stationDangerList[1].orbit_distance = distance(exploding_star, stationDangerList[1])
		stationDangerList[1].orbit_velocity = 360/danger_station_orbit_time  -- the amount of circumference arc to travel each game tic in order to complete one orbit in the given orbit time
		stationDangerList[1].current_angle_from_origin = 180  -- 325  -- an initial angle placement 
	end
	
	-- if selected, create the accretion disc gasses (nebulea)
	if black_hole_accretion_disc_gasses_are_on then
		for i=1,black_hole_accretion_disc_gasses_density do
			blackHoleAccretionDiscGassesList[i] = Nebula()
			blackHoleAccretionDiscGassesList[i].orbit_distance = black_hole_accretion_disc_gasses_distance
			blackHoleAccretionDiscGassesList[i].current_angle_from_origin = (i-1)*(360/black_hole_accretion_disc_gasses_density)
			blackHoleAccretionDiscGassesList[i].orbit_velocity = 360/black_hole_accretion_disc_gasses_orbit_time
			setCirclePos(blackHoleAccretionDiscGassesList[i], black_hole_location_x, black_hole_location_y, blackHoleAccretionDiscGassesList[i].current_angle_from_origin, blackHoleAccretionDiscGassesList[i].orbit_distance)
		end
	end
	
	-- if selected, create the accretion disc asteroids
	if black_hole_accretion_disc_asteroids_are_on then
		for i=1,black_hole_accretion_disc_asteroids_density do
			blackHoleAccretionDiscAsteroidsList[i] = Asteroid()
			blackHoleAccretionDiscAsteroidsList[i].orbit_distance = math.random(black_hole_accretion_disc_asteroids_min_distance, black_hole_accretion_disc_asteroids_max_distance)
			blackHoleAccretionDiscAsteroidsList[i].current_angle_from_origin = math.random(1, 360)
			blackHoleAccretionDiscAsteroidsList[i].orbit_velocity = 360/(math.random(black_hole_accretion_disc_asteroids_max_velocity, black_hole_accretion_disc_asteroids_min_velocity))
			setCirclePos(blackHoleAccretionDiscAsteroidsList[i], black_hole_location_x, black_hole_location_y, blackHoleAccretionDiscAsteroidsList[1].current_angle_from_origin, blackHoleAccretionDiscAsteroidsList[1].orbit_distance)
		end
	end 
	
	-- build a boundary ring of nebula
	for i=1,360,3 do
		local new_nebula = Nebula()
		setCirclePos(new_nebula, black_hole_location_x, black_hole_location_y, i, math.random(95000, 105000))
	end
	
	
end
function createWormholes()

--local area "entry"
    WormHole():setPosition(50000, -30000):setTargetPosition(598181, 6855)

-- distant area "exit"
    WormHole():setPosition(597284, 11066):setTargetPosition(46000, -30000)

end
--	STATION CREATION/PLACEMENT SECTION
--	The set of functions below creates and places the different stations
function arrangeMissionStations()
	local arranged_stations = {
		{orbit_object = central_star, 		angle_from_origin = 90,					orbit_radius = 36500, 	orbit_speed = 360/(60*3000),	transport = false},
		{orbit_object = cs_main_planet1,	angle_from_origin = 330,				orbit_radius = 10000, 	orbit_speed = 360/(60*500),		transport = false},
		{orbit_object = central_star,		angle_from_origin = 330,				orbit_radius = 17500, 	orbit_speed = 360/(60*1200),	transport = false},
		{orbit_object = central_star,		angle_from_origin = 150,				orbit_radius = 50000, 	orbit_speed = 0,				transport = true},
		{orbit_object = central_star,		angle_from_origin = 225,				orbit_radius = 32000, 	orbit_speed = 0,				transport = true},
		{orbit_object = central_star,		angle_from_origin = 45,					orbit_radius = 50000, 	orbit_speed = 0,				transport = true},
		{orbit_object = central_star,		angle_from_origin = random(0,360),		orbit_radius = 150000,	orbit_speed = 0,				transport = true},
		{orbit_object = central_star,		angle_from_origin = random(0,360),		orbit_radius = 145000,	orbit_speed = 0,				transport = true},
	}
	for i,station in ipairs(stationSafeList) do
		if arranged_stations[i] ~= nil then
			local a_station = arranged_stations[i]
			local center_x, center_y = a_station.orbit_object:getPosition()
			station.current_angle_from_origin = a_station.angle_from_origin
			station.orbit_radius = a_station.orbit_radius
			station.orbit_speed = a_station.orbit_speed
			setCirclePos(station,center_x,center_y,station.current_angle_from_origin,station.orbit_radius)
			if a_station.transport then
				table.insert(transportTargetStationList,station)
			end
		else
			table.insert(transportTargetStationList,station)
		end
	end
end
function simpleAndDirectGenericStationPlacement()
	-- note that this first station is explicitly placed next to the wormhole on the near side so that Human Navy forces have automatic scanning of the wormhold area 
	station_wormhole_near = placeStation(46650,-31900,"RandomHumanNeutral","Human Navy","Small Station")
	station_wormhole_near:setDescription("Wormhole Gateway")
	station_wormhole_near.general = "Monitoring gateway station for the wormhole to the Delta Quadrant"
	table.insert(friendlyStationList,station_wormhole_near)
	-- note that this second station is explicitly placed next to the wormhole on the far side so that Human Navy forces have automatic scanning of the wormhold area 
	station_wormhole_far = placeStation(600886, 9062,"RandomHumanNeutral","Human Navy","Small Station")
	station_wormhole_far:setDescription("Wormhole Gateway")
	station_wormhole_far.general = "Monitoring gateway station for the wormhole back to the Alpha Quadrant"
	table.insert(friendlyStationList,station_wormhole_far)
	local decoy_stations = {
		{lo = 45000, hi = 65000, name = "Research Station Zulu",		desc = "Classified Research",		general = "Sorry, nothing to see here.  Move along."},
		{lo = 45000, hi = 65000, name = "Mrs. Gillerlain's Apothacary",	desc = "Medicines",					general = "If you're feelin' blue, we're sure to have something for you!"},
		{lo = 45000, hi = 65000, name = "Mr. Evans' Parts",				desc = "Spaceship Parts",			general = "If it's busted -- we've got your parts!"},
		{lo = 94000, hi = 95000, name = "Deep Space 4",					desc = "Monitoring Station",		general = "Shhhhh.... we're listening for little green men... "},
		{lo = 94000, hi = 95000, name = "Urapentay",					desc = "Maximum Security Prison",	general = "Please present 8 valid forms of identification"},
		{lo = 45000, hi = 65000, name = "Joe's Pizza",					desc = "Pizza Parlor",				general = "18 decks of the best pizza in the galaxy!"},
	}
	for i,decoy in ipairs(decoy_stations) do
		local station = placeStation(-300000,-300000,"RandomHumanNeutral","Human Navy")
		station:setCallSign(decoy.name):setDescription(decoy.desc)
		setCirclePos(station, origin_X, origin_Y, random(0,360), random(decoy.lo,decoy.hi))
		station.general = decoy.general
		table.insert(transportTargetStationList,station)
		table.insert(decoyStationList,station)
	end	
end
function placeMissionStation(typeStation, sizeStation, factionStation)
	if typeStation == nil then
		print("No value for typeStation. Valid values are 'safe' and 'danger' Assuming safe")
		typeStation = "safe"
	end
	if typeStation ~= "danger" and typeStation ~= "safe" then
		print("Invalid value for typeStation. Valid values are 'safe' and 'danger' Assuming safe")
		typeStation = "safe"
	end
	if typeStation == "danger" then
		stationChoice = math.random(1,#stationDangerX)
		psx = stationDangerX[stationChoice]
		psy = stationDangerY[stationChoice]
		table.remove(stationDangerX,stationChoice)
		table.remove(stationDangerY,stationChoice)
	else
		stationChoice = math.random(1,#stationSafeX)
		psx = stationSafeX[stationChoice]
		psy = stationSafeY[stationChoice]
		table.remove(stationSafeX,stationChoice)
		table.remove(stationSafeY,stationChoice)
	end
	if sizeStation == nil then
		print("No value for sizeStation. Valid values are 'Huge' 'Large' 'Medium' and 'Small' Assuming Medium")
		sizeStation = "Medium"
	end
	if sizeStation ~= "Huge" and sizeStation ~= "Large" and sizeStation ~= "Medium" and sizeStation ~= "Small" then
		print("Invalid value for sizeStation. Valid values are 'Huge' 'Large' 'Medium' and 'Small' Assuming Medium")
		sizeStation = "Medium"
	end
	if sizeStation == "Small" then
		stationSize = "Small Station"
	elseif sizeStation == "Medium" then
		stationSize = "Medium Station"
	elseif sizeStation == "Large" then
		stationSize = "Large Station"
	else
		stationSize = "Huge Station"
	end
	if factionStation == nil then
		print("No value for factionStation. Valid values are 'Human Navy and 'Independent' Assuming Independent")
		factionStation = "Independent"
	end
	if factionStation ~= "Human Navy" and factionStation ~= "Independent" then
		print("Invalid value for factionStation. Valid values are 'Human Navy and 'Independent' Assuming Independent")
		factionStation = "Independent"
	end
	if factionStation == "Human Navy" then
		stationFaction = "Human Navy"
	else
		stationFaction = "Independent"
	end
	local pStation = placeStation(psx,psy,"RandomHumanNeutral",stationFaction,stationSize)
	table.insert(stationList,pStation)			--save station in general station list
	if stationFaction == "Human Navy" then
		table.insert(friendlyStationList,pStation)	--save station in friendly station list
	end
	if typeStation == "danger" then
		table.insert(stationDangerList,pStation)
		pStation.evacuate = true
		pStation.people = station_capacity[sizeStation]
	else	--safe station
		table.insert(stationSafeList,pStation)
		pStation.evacuees = true
		pStation.people = 0
		if stationFaction == "Human Navy" then
			if rescue_capacity == "Enough" then
				pStation.maxPeople = station_capacity[sizeStation]
			else
				pStation.maxPeople = station_capacity[sizeStation] * 1.2
			end
		else	--independent
			if rescue_capacity == "Enough" then
				pStation.maxPeople = station_capacity[sizeStation]/2
			else
				pStation.maxPeople = station_capacity[sizeStation]/2*1.2
			end
		end
	end
end
function randomStation()
	idx = math.floor(random(1, #transportTargetStationList + 0.99))
	return transportTargetStationList[idx]
end
function buildNonMissionStations()
	stationFaction = "Human Navy"
	stationSize = nil
	local pStation = nil
	for i=1,10 do
		repeat
			candidateQualify = true
			bandChoice = random(1,100)
			if bandChoice < 50 then
				outerRange = 25000
			elseif bandChoice < 70 then
				outerRange = 50000
			elseif bandChoice < 90 then
				outerRange = 100000
			else
				outerRange = 150000
			end
			ivx, ivy = vectorFromAngle(random(0,360),random(stevRadius,outerRange))
			psx = stevx+ivx
			psy = stevy+ivy
			for j=1,#stationList do
				if distance(stationList[j],psx,psy) < 4500 then
					candidateQualify = false
					break
				end
			end
		until(candidateQualify)
		pStation = placeStation(psx,psy,"RandomHumanNeutral",stationFaction)
		table.insert(stationList,pStation)			--save station in general station list
		table.insert(friendlyStationList,pStation)
	end
	stationFaction = "Independent"
	for i=1,25 do
		repeat
			candidateQualify = true
			bandChoice = random(1,100)
			if bandChoice < 50 then
				outerRange = 25000
			elseif bandChoice < 70 then
				outerRange = 50000
			elseif bandChoice < 90 then
				outerRange = 100000
			else
				outerRange = 150000
			end
			ivx, ivy = vectorFromAngle(random(0,360),random(stevRadius,outerRange))
			psx = stevx+ivx
			psy = stevy+ivy
			for j=1,#stationList do
				if distance(stationList[j],psx,psy) < 4500 then
					candidateQualify = false
					break
				end
			end
		until(candidateQualify)
		pStation = placeStation(psx,psy,"RandomHumanNeutral",stationFaction)
		table.insert(stationList,pStation)			--save station in general station list
	end
end
--	Station communication 
function commsStation()
    if comms_target.comms_data == nil then
        comms_target.comms_data = {}
    end
    mergeTables(comms_target.comms_data, {
        friendlyness = random(0.0, 100.0),
        weapons = {
            Homing = "neutral",
            HVLI = "neutral",
            Mine = "neutral",
            Nuke = "friend",
            EMP = "friend"
        },
        weapon_cost = {
            Homing = math.random(1,4),
            HVLI = math.random(1,3),
            Mine = math.random(2,5),
            Nuke = math.random(12,18),
            EMP = math.random(7,13)
        },
        services = {
            supplydrop = "friend",
            reinforcements = "friend",
        },
        service_cost = {
            supplydrop = math.random(80,120),
            reinforcements = math.random(125,175)
        },
        reputation_cost_multipliers = {
            friend = 1.0,
            neutral = 3.0
        },
        max_weapon_refill_amount = {
            friend = 1.0,
            neutral = 0.5
        }
    })
	-- print("midway through station comm")
    comms_data = comms_target.comms_data
	for p3idx=1,#playerShips do
		p3obj = getPlayerShip(p3idx)
		if p3obj ~= nil and p3obj:isValid() then
			if p3obj:isCommsOpening() then
				player = p3obj
			end
		end
	end
	-- print("past player determination")
    if player:isEnemy(comms_target) then
        return false
    end
    if comms_target:areEnemiesInRange(5000) then
        setCommsMessage("We are under attack! No time for chatting!");
        return true
    end
    if not player:isDocked(comms_target) then
        handleUndockedState()
    else
        handleDockedState()
    end
    return true
end
function handleDockedState()
    if player:isFriendly(comms_target) then
		oMsg = "Good day, officer!\nWhat can we do for you today?\n"
    else
		oMsg = "Welcome to our lovely station.\n"
    end
    if comms_target:areEnemiesInRange(20000) then
		oMsg = oMsg .. "Forgive us if we seem a little distracted. We are carefully monitoring the enemies nearby."
	end
	setCommsMessage(oMsg)
	missilePresence = 0
	for _, missile_type in ipairs(missile_types) do
		missilePresence = missilePresence + player:getWeaponStorageMax(missile_type)
	end
	if missilePresence > 0 then
		if comms_target.nukeAvail == nil then
			if comms_target.nukeAvail == nil then
				if math.random(1,100) <= 25 then
					comms_target.nukeAvail = true
				else
					comms_target.nukeAvail = false
				end
				if math.random(1,100) <= 40 then
					comms_target.empAvail = true
				else
					comms_target.empAvail = false
				end
				if math.random(1,100) <= 60 then
					comms_target.homeAvail = true
				else
					comms_target.homeAvail = false
				end
				if math.random(1,100) <= 80 then
					comms_target.mineAvail = true
				else
					comms_target.mineAvail = false
				end
				if math.random(1,100) <= 90 then
					comms_target.hvliAvail = true
				else
					comms_target.hvliAvail = false
				end
			end
		end
		if comms_target.nukeAvail or comms_target.empAvail or comms_target.homeAvail or comms_target.mineAvail or comms_target.hvliAvail then
			addCommsReply("I need ordnance restocked", function()
				setCommsMessage("What type of ordnance?")
				if player:getWeaponStorageMax("Nuke") > 0 then
					if comms_target.nukeAvail then
						if math.random(1,10) <= 5 then
							nukePrompt = "Can you supply us with some nukes? ("
						else
							nukePrompt = "We really need some nukes ("
						end
						addCommsReply(nukePrompt .. getWeaponCost("Nuke") .. " rep each)", function()
							handleWeaponRestock("Nuke")
						end)
					end
				end
				if player:getWeaponStorageMax("EMP") > 0 then
					if comms_target.empAvail then
						if math.random(1,10) <= 5 then
							empPrompt = "Please re-stock our EMP missiles. ("
						else
							empPrompt = "Got any EMPs? ("
						end
						addCommsReply(empPrompt .. getWeaponCost("EMP") .. " rep each)", function()
							handleWeaponRestock("EMP")
						end)
					end
				end
				if player:getWeaponStorageMax("Homing") > 0 then
					if comms_target.homeAvail then
						if math.random(1,10) <= 5 then
							homePrompt = "Do you have spare homing missiles for us? ("
						else
							homePrompt = "Do you have extra homing missiles? ("
						end
						addCommsReply(homePrompt .. getWeaponCost("Homing") .. " rep each)", function()
							handleWeaponRestock("Homing")
						end)
					end
				end
				if player:getWeaponStorageMax("Mine") > 0 then
					if comms_target.mineAvail then
						if math.random(1,10) <= 5 then
							minePrompt = "We could use some mines. ("
						else
							minePrompt = "How about mines? ("
						end
						addCommsReply(minePrompt .. getWeaponCost("Mine") .. " rep each)", function()
							handleWeaponRestock("Mine")
						end)
					end
				end
				if player:getWeaponStorageMax("HVLI") > 0 then
					if comms_target.hvliAvail then
						if math.random(1,10) <= 5 then
							hvliPrompt = "What about HVLI? ("
						else
							hvliPrompt = "Could you provide HVLI? ("
						end
						addCommsReply(hvliPrompt .. getWeaponCost("HVLI") .. " rep each)", function()
							handleWeaponRestock("HVLI")
						end)
					end
				end
			end)
		end
	end
	if comms_target.general ~= nil or comms_target.history ~= nil then
		addCommsReply("Tell me more about your station", function()
			setCommsMessage("What would you like to know?")
			addCommsReply("General information", function()
				setCommsMessage(comms_target.general)
				addCommsReply("Back", commsStation)
			end)
			if comms_target.history ~= nil then
				addCommsReply("Station history", function()
					setCommsMessage(comms_target.history)
					addCommsReply("Back", commsStation)
				end)
			end
			if player:isFriendly(comms_target) then
				if comms_target.gossip ~= nil then
					if random(1,100) < 50 then
						addCommsReply("Gossip", function()
							setCommsMessage(comms_target.gossip)
							addCommsReply("Back", commsStation)
						end)
					end
				end
			end
		end)
	end
	if comms_target.evacuate then
		if comms_target.people > 0 then
			addCommsReply("Evacuate people from station to ship", function()
				if player.passenger == player.maxPassenger then
					setCommsMessage(string.format("You are already carrying your maximum of %i passengers",player.maxPassenger))
				else
					availableSeats = player.maxPassenger - player.passenger
					if availableSeats >= comms_target.people then
						player.passenger = player.passenger + comms_target.people
						player:addReputationPoints(comms_target.people/2)
						setCommsMessage(string.format("All %i people transferred to your ship",comms_target.people))
						comms_target.people = 0
					else
						player.passenger = player.maxPassenger
						player:addReputationPoints(availableSeats/2)
						setCommsMessage(string.format("%i people transferred to your ship",availableSeats))
						comms_target.people = comms_target.people - availableSeats
					end
					printMissionStatus()
				end
				addCommsReply("Back", commsStation)
			end)
		end
	end
	if comms_target.evacuees then
		if player.passenger > 0 then
			addCommsReply("Evacuate passengers from ship to station", function()
				if comms_target.people == comms_target.maxPeople then
					setCommsMessage(string.format("This station is at full capacity of %i people",comms_target.maxPeople))
				else
					availableSlots = comms_target.maxPeople - comms_target.people
					if availableSlots >= player.passenger then
						comms_target.people = comms_target.people + player.passenger
						player:addReputationPoints(player.passenger/2)
						setCommsMessage(string.format("All %i passengers transferred to station",player.passenger))
						player.passenger = 0
					else
						comms_target.people = comms_target.maxPeople
						player:addReputationPoints(availableSlots/2)
						setCommsMessage(string.format("%i passengers transferred to station",availableSlots))
						player.passenger = player.passenger - availableSlots
					end
					printMissionStatus()
				end
				addCommsReply("Back", commsStation)
			end)
		end
	end
end
function isAllowedTo(state)
    if state == "friend" and player:isFriendly(comms_target) then
        return true
    end
    if state == "neutral" and not player:isEnemy(comms_target) then
        return true
    end
    return false
end
function handleWeaponRestock(weapon)
    if not player:isDocked(comms_target) then 
		setCommsMessage("You need to stay docked for that action.")
		return
	end
    if not isAllowedTo(comms_data.weapons[weapon]) then
        if weapon == "Nuke" then setCommsMessage("We do not deal in weapons of mass destruction.")
        elseif weapon == "EMP" then setCommsMessage("We do not deal in weapons of mass disruption.")
        else setCommsMessage("We do not deal in those weapons.") end
        return
    end
    local points_per_item = getWeaponCost(weapon)
    local item_amount = math.floor(player:getWeaponStorageMax(weapon) * comms_data.max_weapon_refill_amount[getFriendStatus()]) - player:getWeaponStorage(weapon)
    if item_amount <= 0 then
        if weapon == "Nuke" then
            setCommsMessage("All nukes are charged and primed for destruction.");
        else
            setCommsMessage("Sorry, sir, but you are as fully stocked as I can allow.");
        end
        addCommsReply("Back", commsStation)
    else
        if not player:takeReputationPoints(points_per_item * item_amount) then
            setCommsMessage("Not enough reputation.")
            return
        end
        player:setWeaponStorage(weapon, player:getWeaponStorage(weapon) + item_amount)
        if player:getWeaponStorage(weapon) == player:getWeaponStorageMax(weapon) then
            setCommsMessage("You are fully loaded and ready to explode things.")
        else
            setCommsMessage("We generously resupplied you with some weapon charges.\nPut them to good use.")
        end
        addCommsReply("Back", commsStation)
    end
end
function getWeaponCost(weapon)
    return math.ceil(comms_data.weapon_cost[weapon] * comms_data.reputation_cost_multipliers[getFriendStatus()])
end
function handleUndockedState()
    --Handle communications when we are not docked with the station.
    if player:isFriendly(comms_target) then
        oMsg = "Good day, officer.\nIf you need supplies, please dock with us first."
    else
        oMsg = "Greetings.\nIf you want to do business, please dock with us first."
    end
    if comms_target:areEnemiesInRange(20000) then
		oMsg = oMsg .. "\nBe aware that if enemies in the area get much closer, we will be too busy to conduct business with you."
	end
	if comms_target.nukeAvail == nil then
		if math.random(1,100) <= 25 then
			comms_target.nukeAvail = true
		else
			comms_target.nukeAvail = false
		end
		if math.random(1,100) <= 40 then
			comms_target.empAvail = true
		else
			comms_target.empAvail = false
		end
		if math.random(1,100) <= 60 then
			comms_target.homeAvail = true
		else
			comms_target.homeAvail = false
		end
		if math.random(1,100) <= 80 then
			comms_target.mineAvail = true
		else
			comms_target.mineAvail = false
		end
		if math.random(1,100) <= 90 then
			comms_target.hvliAvail = true
		else
			comms_target.hvliAvail = false
		end
	end
	setCommsMessage(oMsg)
 	addCommsReply("I need information", function()
		setCommsMessage("What kind of information do you need?")
		addCommsReply("How many personnel can you accept?", function()
			if comms_target.evacuees then
				if comms_target.people == comms_target.maxPeople then
					setCommsMessage(string.format("This station is at full capacity of %i people",comms_target.maxPeople))
				else
					availableSlots = comms_target.maxPeople - comms_target.people
					setCommsMessage(string.format("We can accept %i people",availableSlots))
				end
			else
				setCommsMessage("We do not accept any personnel")
			end
			addCommsReply("Back", commsStation)
		end)
		if player:isFriendly(comms_target) then
			addCommsReply("What stations accept evacuees?", function()
				oMsg = "These stations accept evacuees:"
				for i=1,#stationSafeList do
					if stationSafeList[i] ~= nil and stationSafeList[i]:isValid() then
						oMsg = oMsg .. string.format("\n%s (%s) in %s",stationSafeList[i]:getCallSign(),stationSafeList[i]:getFaction(),stationSafeList[i]:getSectorName())
					end
				end
				setCommsMessage(oMsg)
				addCommsReply("Why can't I see Independent stations on the Relay map?",function()
					setCommsMessage("Independent stations are not connected to the Human Navy communications network. As such, we don't get automated location telemetry from them like we do for Human Navy and other friendly stations.")
					addCommsReply("Back", commsStation)
				end)
				addCommsReply("Back", commsStation)
			end)
			addCommsReply("What stations require evacuation?", function()
				oMsg = "These stations require evacuation:"
				for i=1,#stationDangerList do
					if stationDangerList[i] ~= nil and stationDangerList[i]:isValid() then
						oMsg = oMsg .. string.format("\n%s in %s, %i people need evacuation",stationDangerList[i]:getCallSign(),stationDangerList[i]:getSectorName(),stationDangerList[i].people)
					end
				end
				setCommsMessage(oMsg)
				addCommsReply("Back", commsStation)
			end)
		end
		addCommsReply("What ordnance do you have available for restock?", function()
			missileTypeAvailableCount = 0
			oMsg = ""
			if comms_target.nukeAvail then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				oMsg = oMsg .. "\n   Nuke"
			end
			if comms_target.empAvail then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				oMsg = oMsg .. "\n   EMP"
			end
			if comms_target.homeAvail then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				oMsg = oMsg .. "\n   Homing"
			end
			if comms_target.mineAvail then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				oMsg = oMsg .. "\n   Mine"
			end
			if comms_target.hvliAvail then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				oMsg = oMsg .. "\n   HVLI"
			end
			if missileTypeAvailableCount == 0 then
				oMsg = "We have no ordnance available for restock"
			elseif missileTypeAvailableCount == 1 then
				oMsg = "We have the following type of ordnance available for restock:" .. oMsg
			else
				oMsg = "We have the following types of ordnance available for restock:" .. oMsg
			end
			setCommsMessage(oMsg)
			addCommsReply("Back", commsStation)
		end)
		if comms_target.general ~= nil then
			addCommsReply("General station information", function()
				setCommsMessage(comms_target.general)
				addCommsReply("Back", commsStation)
			end)
		end
	end)
	--Diagnostic data is used to help test and debug the script while it is under construction
	if diagnostic then
		addCommsReply("Diagnostic data", function()
			oMsg = string.format("Difficulty: %.1f",difficulty)
			if playWithTimeLimit then
				oMsg = oMsg .. string.format(" Time remaining: %.2f",gameTimeLimit)
			else
				oMsg = oMsg .. " no time limit"
			end
			if plot1name == nil or plot1 == nil then
				oMsg = oMsg .. ""
			else
				oMsg = oMsg .. "\nplot1: " .. plot1name
			end
			if plot2name == nil or plot2 == nil then
				oMsg = oMsg .. ""
			else
				oMsg = oMsg .. "\nplot2: " .. plot2name
			end
			if plot3name == nil or plot3 == nil then
				oMsg = oMsg .. ""
			else
				oMsg = oMsg .. "\nplot3: " .. plot3name
			end
			if plot4name == nil or plot4 == nil then
				oMsg = oMsg .. ""
			else
				oMsg = oMsg .. "\nplot4: " .. plot4name
			end
			if plot5name == nil or plot5 == nil then
				oMsg = oMsg .. ""
			else
				oMsg = oMsg .. "\nplot5: " .. plot5name
			end
			oMsg = oMsg .. "\nwfv: " .. wfv
			setCommsMessage(oMsg)
			addCommsReply("Back", commsStation)
		end)
	end
	if isAllowedTo(comms_target.comms_data.services.supplydrop) then
        addCommsReply("Can you send a supply drop? ("..getServiceCost("supplydrop").."rep)", function()
            if player:getWaypointCount() < 1 then
                setCommsMessage("You need to set a waypoint before you can request backup.");
            else
                setCommsMessage("To which waypoint should we deliver your supplies?");
                for n=1,player:getWaypointCount() do
                    addCommsReply("WP" .. n, function()
                        if player:takeReputationPoints(getServiceCost("supplydrop")) then
                            local position_x, position_y = comms_target:getPosition()
                            local target_x, target_y = player:getWaypoint(n)
                            local script = Script()
                            script:setVariable("position_x", position_x):setVariable("position_y", position_y)
                            script:setVariable("target_x", target_x):setVariable("target_y", target_y)
                            script:setVariable("faction_id", comms_target:getFactionId()):run("supply_drop.lua")
                            setCommsMessage("We have dispatched a supply ship toward WP" .. n);
                        else
                            setCommsMessage("Not enough reputation!");
                        end
                        addCommsReply("Back", commsStation)
                    end)
                end
            end
            addCommsReply("Back", commsStation)
        end)
    end
    if isAllowedTo(comms_target.comms_data.services.reinforcements) then
        addCommsReply("Please send reinforcements! ("..getServiceCost("reinforcements").."rep)", function()
            if player:getWaypointCount() < 1 then
                setCommsMessage("You need to set a waypoint before you can request reinforcements.");
            else
                setCommsMessage("To which waypoint should we dispatch the reinforcements?");
                for n=1,player:getWaypointCount() do
                    addCommsReply("WP" .. n, function()
                        if player:takeReputationPoints(getServiceCost("reinforcements")) then
                            ship = CpuShip():setFactionId(comms_target:getFactionId()):setPosition(comms_target:getPosition()):setTemplate("Adder MK5"):setScanned(true):orderDefendLocation(player:getWaypoint(n))
                            setCommsMessage("We have dispatched " .. ship:getCallSign() .. " to assist at WP" .. n);
                        else
                            setCommsMessage("Not enough reputation!");
                        end
                        addCommsReply("Back", commsStation)
                    end)
                end
            end
            addCommsReply("Back", commsStation)
        end)
    end
end
function printMissionStatus()
	print("  ")
	print("Mission Status Update:")
	print("   Stations requiring evacuation:")
	for i=1,#stationDangerList do
		print(string.format("      %s in %s: %i",stationDangerList[i]:getCallSign(),stationDangerList[i]:getSectorName(),stationDangerList[i].people))
	end
	print("   Stations accepting evacuees (space available):")
	for i=1,#stationSafeList do
		print(string.format("      %s in %s: %i",stationSafeList[i]:getCallSign(),stationSafeList[i]:getSectorName(),stationSafeList[i].maxPeople - stationSafeList[i].people))
	end
	print("   Passengers aboard player ships:")
	for idx, player_ship in ipairs(playerShips) do
		if player_ship:isValid() then
			print(string.format("      %s: %i",player_ship:getCallSign(),player_ship.passenger))
		else
			print("      ship destroyed")
		end
	end
	print("   Passengers killed while in transit: " .. total_passengers_killed)
	print("  ")
end
function getServiceCost(service)
	-- Return the number of reputation points that a specified service costs for the current player.
   return math.ceil(comms_data.service_cost[service])
end
function fillStationBrains()
	comms_target.goodsKnowledge = {}
	comms_target.goodsKnowledgeSector = {}
	comms_target.goodsKnowledgeType = {}
	comms_target.goodsKnowledgeTrade = {}
	knowledgeCount = 0
	knowledgeMax = 10
	for sti=1,#stationList do
		if stationList[sti] ~= nil and stationList[sti]:isValid() then
			if distance(comms_target,stationList[sti]) < 75000 then
				brainCheck = 3
			else
				brainCheck = 1
			end
			for gi=1,#goods[stationList[sti]] do
				if random(1,10) <= brainCheck then
					table.insert(comms_target.goodsKnowledge,stationList[sti]:getCallSign())
					table.insert(comms_target.goodsKnowledgeSector,stationList[sti]:getSectorName())
					table.insert(comms_target.goodsKnowledgeType,goods[stationList[sti]][gi][1])
					tradeString = ""
					stationTrades = false
					if tradeMedicine[stationList[sti]] ~= nil then
						tradeString = " and will trade it for medicine"
						stationTrades = true
					end
					if tradeFood[stationList[sti]] ~= nil then
						if stationTrades then
							tradeString = tradeString .. " or food"
						else
							tradeString = tradeString .. " and will trade it for food"
							stationTrades = true
						end
					end
					if tradeLuxury[stationList[sti]] ~= nil then
						if stationTrades then
							tradeString = tradeString .. " or luxury"
						else
							tradeString = tradeString .. " and will trade it for luxury"
						end
					end
					table.insert(comms_target.goodsKnowledgeTrade,tradeString)
					knowledgeCount = knowledgeCount + 1
					if knowledgeCount >= knowledgeMax then
						return
					end
				end
			end
		end
	end
end
function getFriendStatus()
    if player:isFriendly(comms_target) then
        return "friend"
    else
        return "neutral"
    end
end
--	Briefing communications
function briefing(p)
--	invoked from player ship loop in update function
	if getScenarioTime() > 8 then
		if p.briefing_message == nil then
			if availableForComms(p) then
				briefing_message:openCommsTo(p)
				p.briefing_message = "sent"
			end
		end
	end
end
function briefingComms()
	setCommsMessage(string.format("Greetings %s,\nWe received a distress call from the scientists on station %s studying %s in the delta quadrant.",comms_source:getCallSign(),stationDangerList[1]:getCallSign(),exploding_star:getCallSign()))
	addCommsReply("What kind of distress are they in?",function()
		setCommsMessage(string.format("Their most recent readings show that %s is about to go nova.",exploding_star:getCallSign()))
		addCommsReply("On a galactic scale, 'about to' could be centuries, right?",function()
			setCommsMessage(string.format("That's what the scientists thought, too. However, they updated their estimates and called in a panic. It seems that %s is about to go nova 'right now.' I asked for a better time estimate and they said they were not sure. When I finally nailed them down, they said it would go nova in anywhere from 30 minutes to four hours from now.",exploding_star:getCallSign()))
			addCommsReply("How many people are endangered?",function()
				local total_endangered = 0
				local out = ""
				for idx, station in ipairs(stationDangerList) do
					total_endangered = total_endangered + station.people
				end
				if #stationDangerList > 1 then
					out = string.format("There are %s people (scientists, staff, support, etc.) on %s stations.",total_endangered,#stationDangerList)
					for i, station in ipairs(stationDangerList) do
						if i == 1 then
							out = string.format("%s: %s",out,station:getCallSign())
						else
							out = string.format("%s, %s",out,station:getCallSign())
						end
					end
				else
					out = string.format("There are %s people (scientists, staff, support, etc.) on station %s.",total_endangered,stationDangerList[1]:getCallSign())
				end
				setCommsMessage(out)
				addCommsReply("How are we supposed to get way over to the delta quadrant to save them?",function()
					setCommsMessage(string.format("Use the stable wormhole. Station %s monitors it here in the alpha quadrant and station %s monitors it on the delta quadrant side.",station_wormhole_near:getCallSign(),station_wormhole_far:getCallSign()))
					addCommsReply(string.format("%s is more people than we can carry.",total_endangered),function()
						local player_list = getActivePlayerShips()
						local out = ""
						if #player_list > 1 then
							if #player_list > 2 then
								out = "You and your fellow fleet members"
								local first_already_displayed = false
								for i,p in ipairs(player_list) do
									if p ~= comms_source then
										if first_already_displayed then
											out = string.format("%s, %s",out,p:getCallSign())
										else
											out = string.format("%s (%s",out,p:getCallSign())
											first_already_displayed = true
										end
									end
								end
								out = string.format("%s) will need to make multiple trips to rescue them.",out)
							else
								local other_player = nil
								for i,p in ipairs(player_list) do
									if p ~= comms_source then
										other_player = p
									end
								end
								out = string.format("You and %s will need to make multiple trips to rescue them.",other_player:getCallSign())
							end
						else
							out = "You will need to make multiple trips to rescue them."
						end
						setCommsMessage(out)
						addCommsReply("Anything else we need to know?",function()
							setCommsMessage("There are too many people to fit on just one station around here. You'll need to unload passengers on multiple stations. Independent stations don't have as much room as Human Navy stations and are not connected to our communication network.\n\nWhat are you waiting for? There are lives at stake! Get moving!")
						end)
					end)
				end)
			end)
		end)
	end)
end
--	UPDATE FUNCTION SECTION
--	The update() function is at the very bottom
--	The functions inbetween this section header and the update() function are called by update().
function manageTransports(delta)
	-- this code was brought in from the "util_random_transports.lua" file essentially so that I could manage planet collision detections from within the same file
	cnt = 0
	for idx, obj in ipairs(transportList) do
		if not obj:isValid() then
			--Transport destroyed, remove it from the list
			table.remove(transportList, idx)
		else
			if obj:isDocked(obj.target) then   -- first major transport state:  it is docked at a station
				if obj.target:areEnemiesInRange(20000) then  -- highest priority check -- if there are enemies within a certain distance of the station we're docked at, then choose somewhere else to go!
					obj.target = randomStation()
					obj.undock_delay = random(5, 30)
					obj:orderDock(obj.target)
				elseif obj.undock_delay > 0 then -- if no enemies near and the transport isn't done with its business, then just stay docked
					obj.undock_delay = obj.undock_delay - delta
				else  -- otherwise the transport is done with it's business, and it's time to go to the next station
					obj.target = randomStation()
					obj.undock_delay = random(5, 30)
					obj:orderDock(obj.target)
				end
			elseif (distance(obj, obj.target) < 30000) then     -- second major transport state:  it is enroute to a station, and while enroute, when the transport gets to within 30000 of the target...
				if obj.target:areEnemiesInRange(20000) then   -- the transport "checks with the station" and sees enemies within range of the target, then choose somewhere else to go! 
					obj.target = randomStation()
					obj.undock_delay = random(5, 30)
					obj:orderDock(obj.target)			
				end
			end
			cnt = cnt + 1
		end
	end

	if spawn_delay >= 0 then
		spawn_delay = spawn_delay - delta
	end

	if cnt < #transportTargetStationList then
		if spawn_delay < 0 then
			target = randomStation()
			if target:isValid() then
				spawn_delay = random(30, 50)
				
                rnd = irandom(1, 5)
                if rnd == 1 then
                    name = "Personnel"
                elseif rnd == 2 then
                    name = "Goods"
                elseif rnd == 2 then
                    name = "Garbage"
                elseif rnd == 2 then
                    name = "Equipment"
                else
                    name = "Fuel"
                end
                
                if irandom(1, 100) < 15 then
                    name = name .. " Jump Freighter " .. irandom(3, 5)
                else
                    name = name .. " Freighter " .. irandom(1, 5)
                end
                
				obj = CpuShip():setTemplate(name)
					:setFaction('Human Navy')
					:setWarpDrive(true)
					--:onTakingDamage(transportTakingDamageManagement)
					--:onDestruction(transportDestructionManagement)
				obj.distress_signal_delay = 0
				obj.target = target
				obj.undock_delay = random(5, 30)
				obj:orderDock(obj.target)
				--x, y = obj.target:getPosition()                                   --original code
				--xd, yd = vectorFromAngle(random(0, 360), random(25000, 40000))    --original code
				--obj:setPosition(x + xd, y + yd)                                   --original code
				xd, yd = vectorFromAngle(random(0, 360), 95000)
				obj:setPosition(origin_X + xd, origin_Y + yd)    -- remember origin_X and origin_Y are created as part of the environment variable
				table.insert(transportList, obj)
				total_transport_ships_spawned = total_transport_ships_spawned + 1
			end
		end
	end
end
function planetCollisionDetection()
	-- for every planet in the planetList, first go through the friendlyList, the enemyList, and the transportList to see if any craft are within the kill radius of the planet, and if so, blow it up!
	for p, planet in ipairs(planetList) do
		for _, player_ship in ipairs(playerShips) do
			if player_ship:isValid() then
				if distance(planet, player_ship) < planetKillRadius[p] then
					print("**!BOOM!** Player ship " .. player_ship:getCallSign() .. " just crashed into a planet!")
					ExplosionEffect():setPosition(player_ship:getPosition()):setSize(2000)
					globalMessage("BOOM! "..player_ship:getCallSign().." crew just crashed into a planet!")
					-- increment the friendlyDestroyedCountList for the ship destroyed
					-- friendlyDestroyedCountList[player_ship:getCallSign()] = friendlyDestroyedCountList[player_ship:getCallSign()] + 1
					-- put the player ship on the list of ships that need to be respawned
					-- table.insert(friendlyShipsWaitingForRespawnList, player_ship:getCallSign())
					-- go through all existing player ships and add a log entry
					for _, player_ship2 in ipairs(playerShips) do
						if player_ship2:isValid() then
							player_ship2:addToShipLog(player_ship:getCallSign() .. " ship has crashed into a planet and has been destroyed.  All crew lost.  RIP", "Red")
						end
					end
					player_ship:destroy()
				end
			end
		end 
		--[[ for _, enemy_ship in ipairs(enemyList) do
			if enemy_ship:isValid() then
				if distance(planet, enemy_ship) < planetKillRadius[p] then
					print("Boom!  Enemy ship " .. enemy_ship:getCallSign() .. " just crashed into a planet!")
					ExplosionEffect():setPosition(enemy_ship:getPosition()):setSize(2000)
					-- increment the enemy crashed count for the stats
					total_enemy_ships_crashed_into_planets = total_enemy_ships_crashed_into_planets + 1
					-- go through all existing player ships and add a log entry
					for _, player_ship2 in ipairs(friendlyList) do
						if player_ship2:isValid() then
							player_ship2:addToShipLog("Enemy vessel " .. enemy_ship:getCallSign() .. " has crashed into a planet and has been destroyed.", "Red")
						end
					end
					enemy_ship:destroy()
				end
			end
		end --]] 
		for _, transport_ship in ipairs(transportList) do
			if transport_ship:isValid() then
				if distance(planet, transport_ship) < planetKillRadius[p] then
					print("Boom!  Transport ship " .. transport_ship:getCallSign() .. " just crashed into a planet!")
					ExplosionEffect():setPosition(transport_ship:getPosition()):setSize(2000)
					-- increment the overall counter of transport ship crashes
					total_transport_ships_crashed_into_planets = total_transport_ships_crashed_into_planets + 1
					-- go through all existing player ships and add a log entry
					for _, player_ship2 in ipairs(friendlyList) do
						if player_ship2:isValid() then
							player_ship2:addToShipLog("Transport vessel " .. transport_ship:getCallSign() .. " has crashed into a planet and has been destroyed.  All crew and cargo lost.", "Red")
						end
					end
					transport_ship:destroy()
				end
			end
		end 
	end
	
	--print(" ")
end
function updateNearSideOrbitPositions()
	-- this function does the calculations to update the orbit positions for elements on the "near side" 

	-- calculations rely on origin globals set in 'createLocalAreaSpace()'
	-- origin_X = 0
	-- origin_X = 0
	
	-- asteroid ring around the star
	for i,asteroid_table in ipairs(central_star_asteroid_ring_1) do
		asteroid_table[2] = asteroid_table[2] + asteroid_table[4]
		if asteroid_table[2] > 360 then
			asteroid_table[2] = asteroid_table[2] - 360
		end
		setCirclePos(central_star_asteroid_ring_1[i][1], origin_X, origin_Y, central_star_asteroid_ring_1[i][2], central_star_asteroid_ring_1[i][3])
	end

	-- stationSafeList[1] is a large station in orbit around the star
		-- copied from 'arrangeMissionStations()' for easy reference
		-- stationSafeList[1].current_angle_from_origin 
		-- stationSafeList[1].orbit_radius 
		-- stationSafeList[1].orbit_speed    -- this equates to the amount of change in degrees the station is moved along the radius arc for every update() call
		-- new_angle as follows:
		stationSafeList[1].current_angle_from_origin = stationSafeList[1].current_angle_from_origin + stationSafeList[1].orbit_speed
		if stationSafeList[1].current_angle_from_origin > 360 then
			stationSafeList[1].current_angle_from_origin = stationSafeList[1].current_angle_from_origin - 360
		end
		setCirclePos(stationSafeList[1], origin_X, origin_Y, stationSafeList[1].current_angle_from_origin, stationSafeList[1].orbit_radius)

	-- stationSafeList[2] is a medium station in orbit around the gas planet that is orbiting the star
		-- copied from 'arrangeMissionStations()' for easy reference
		-- stationSafeList[2].orbit_center_X, stationSafeList[2].orbit_center_Y = cs_main_planet1:getPosition()
		-- stationSafeList[2].current_angle_from_origin 
		-- stationSafeList[2].orbit_radius 
		-- stationSafeList[2].orbit_speed   -- this equates to the amount of change in degrees the station is moved along the radius arc for every update() call
		-- new_angle as follows:
		stationSafeList[2].current_angle_from_origin = stationSafeList[2].current_angle_from_origin + stationSafeList[2].orbit_speed
		if stationSafeList[2].current_angle_from_origin > 360 then
			stationSafeList[2].current_angle_from_origin = stationSafeList[2].current_angle_from_origin - 360
		end
		stationSafeList[2].orbit_center_X, stationSafeList[2].orbit_center_Y = cs_main_planet1:getPosition()
		setCirclePos(stationSafeList[2], stationSafeList[2].orbit_center_X, stationSafeList[2].orbit_center_Y, stationSafeList[2].current_angle_from_origin, stationSafeList[2].orbit_radius)
	

	-- stationSafeList[3] is a small station in orbit around the star
		-- copied from 'arrangeMissionStations()' for easy reference
		-- stationSafeList[3].current_angle_from_origin 
		-- stationSafeList[3].orbit_radius 
		-- stationSafeList[3].orbit_speed    -- this equates to the amount of change in degrees the station is moved along the radius arc for every update() call
		-- new_angle as follows:
		stationSafeList[3].current_angle_from_origin = stationSafeList[3].current_angle_from_origin + stationSafeList[3].orbit_speed
		if stationSafeList[3].current_angle_from_origin > 360 then
			stationSafeList[3].current_angle_from_origin = stationSafeList[3].current_angle_from_origin - 360
		end
		setCirclePos(stationSafeList[3], origin_X, origin_Y, stationSafeList[3].current_angle_from_origin, stationSafeList[3].orbit_radius)

	-- stationSafeList[4] is stationary and does not move

end
function updateFarSideOrbitPositions()
	-- this function does the calculations to update the orbit positions for elements on the "far side" 
	if danger_station_is_orbiting then
		stationDangerList[1].current_angle_from_origin = stationDangerList[1].current_angle_from_origin + stationDangerList[1].orbit_velocity
		if stationDangerList[1].current_angle_from_origin > 360 then
			stationDangerList[1].current_angle_from_origin = stationDangerList[1].current_angle_from_origin - 360
		end
		local exploding_star_x, exploding_star_y = exploding_star:getPosition()
		setCirclePos(stationDangerList[1], exploding_star_x, exploding_star_y, stationDangerList[1].current_angle_from_origin, stationDangerList[1].orbit_distance)
	end
	
	if black_hole_accretion_disc_gasses_are_on then
		for i=1,black_hole_accretion_disc_gasses_density do
			blackHoleAccretionDiscGassesList[i].current_angle_from_origin = blackHoleAccretionDiscGassesList[i].current_angle_from_origin + blackHoleAccretionDiscGassesList[i].orbit_velocity
			if blackHoleAccretionDiscGassesList[i].current_angle_from_origin > 360 then
				blackHoleAccretionDiscGassesList[i].current_angle_from_origin = blackHoleAccretionDiscGassesList[i].current_angle_from_origin - 360
			end
			setCirclePos(blackHoleAccretionDiscGassesList[i], black_hole_location_x, black_hole_location_y, blackHoleAccretionDiscGassesList[i].current_angle_from_origin, blackHoleAccretionDiscGassesList[i].orbit_distance)
		end
	end
	
	if black_hole_accretion_disc_asteroids_are_on then
		for i=1,black_hole_accretion_disc_asteroids_density do
			blackHoleAccretionDiscAsteroidsList[i].current_angle_from_origin = blackHoleAccretionDiscAsteroidsList[i].current_angle_from_origin + blackHoleAccretionDiscAsteroidsList[i].orbit_velocity
			if blackHoleAccretionDiscAsteroidsList[i].current_angle_from_origin > 360 then
				blackHoleAccretionDiscAsteroidsList[i].current_angle_from_origin = blackHoleAccretionDiscAsteroidsList[i].current_angle_from_origin - 360
			end
			setCirclePos(blackHoleAccretionDiscAsteroidsList[i], black_hole_location_x, black_hole_location_y, blackHoleAccretionDiscAsteroidsList[i].current_angle_from_origin, blackHoleAccretionDiscAsteroidsList[i].orbit_distance)
		end
	end

end
function manageExplodingStar()
	-- this function manages the countdown and the explosion of the star

	if countdown_active then
		if getScenarioTime() > countdown_trigger then
			exploding_now = true
			countdown_active = false
			print(">>>>> SUPER NOVA!! <<<<<")
			explosion_location_x, explosion_location_y = exploding_star:getPosition()
			-- kill off the planet object
			exploding_star:destroy()
			-- remove the star from the planet list, otherwise code stops in the collision detection function
			for p, planet in ipairs(planetList) do
				if not planet:isValid() then
					--planet destroyed, remove it from the list
					table.remove(planetList, p)
				end
			end
			-- replace the planet with an explosion effect:  
			ExplosionEffect()
				--:setPosition(exploding_star_x_location, exploding_star_y_location)
				:setPosition(explosion_location_x, explosion_location_y)
				:setSize(exploding_star_radius + 2000)
			-- set the position of the exploding star material (nebulea) to the current position of the exploding star
			for i, neb in ipairs(explosiveNebulaList) do
				neb:setPosition(explosion_location_x, explosion_location_y)
			end
			danger_station_is_orbiting = false  -- stop the danger station from orbiting because the star just went nova... 
		end
	end
	
	if exploding_now then
		if explosion_option_1 then
			-- iterate through the explosiveNebulaList and move nebula according to previously randomized heading and speed
			for i, neb in ipairs(explosiveNebulaList) do
				if neb:isValid() then
					neb_pos_x, neb_pos_y = neb:getPosition()
					setCirclePos(explosiveNebulaList[i], neb_pos_x, neb_pos_y, explosiveNebulaList[i].explosion_heading_direction, explosiveNebulaList[i].velocity)
					-- check to see if the nebula has gone beyond the established "clean_up_distance", and if so, remove from game and clean up the array
					if distance(explosiveNebulaList[i], explosion_location_x, explosion_location_y) > clean_up_distance then
						explosiveNebulaList[i]:destroy()
						remaining_number_of_nebula = remaining_number_of_nebula - 1
						-- print("Remaining number of nebula = ", remaining_number_of_nebula)    -- for debug
						if remaining_number_of_nebula == 0 then 
							exploding_now = false
						end 
					end
				end
			end
		end
		
		if explosion_option_2 then
			remaining_number_of_nebula = #explosiveNebulaList
			for i, neb in ipairs(explosiveNebulaList) do
				if neb:isValid() then
					neb_pos_x, neb_pos_y = neb:getPosition()
					-- print("flag 1")
					if distance(neb, explosion_location_x, explosion_location_y) < neb.stopping_distance then
						-- print("flag 2")
						setCirclePos(neb, neb_pos_x, neb_pos_y, neb.explosion_heading_direction, neb.velocity)
					else
						-- print("flag 3")
						remaining_number_of_nebula = remaining_number_of_nebula - 1
						-- print("Remaining number of nebula = ", remaining_number_of_nebula)    -- for debug
						if remaining_number_of_nebula == 0 then 
							print("explosion complete")
							exploding_now = false
						end 
					end
				end
			end
		end
		
	end
	

end
function updatePassengerBanner(p)
	local passenger_banner = string.format("Passengers:%s/%s",math.floor(p.passenger),p.maxPassenger)
	p.passenger_banner_rel = "passenger_banner_rel"
	p.passenger_banner_ops = "passenger_banner_ops"
	p:addCustomInfo("Relay",p.passenger_banner_rel,passenger_banner,5)
	p:addCustomInfo("Operations",p.passenger_banner_ops,passenger_banner,5)
end
function updateNameSectorBanner(p)
	local name_sector_banner = string.format("%s in %s",p:getCallSign(),p:getSectorName())
	p.name_sector_banner_hlm = "name_sector_banner_hlm"
	p.name_sector_banner_tac = "name_sector_banner_tac"
	p.name_sector_banner_rel = "name_sector_banner_rel"
	p.name_sector_banner_ops = "name_sector_banner_ops"
	p:addCustomInfo("Helms",p.name_sector_banner_hlm,name_sector_banner,4)
	p:addCustomInfo("Tactical",p.name_sector_banner_tac,name_sector_banner,4)
	p:addCustomInfo("Relay",p.name_sector_banner_rel,name_sector_banner,4)
	p:addCustomInfo("Operations",p.name_sector_banner_ops,name_sector_banner,4)
end
function update(delta)
	if delta ~= 0 then -- NOT paused
		for pi,p in ipairs(getActivePlayerShips()) do
			briefing(p)
			updatePassengerBanner(p)
			updateNameSectorBanner(p)
		end
		manageTransports(delta)
		-- planetCollisionDetection()  -- this function isn't completely implemented yet so comment out for now
		updateNearSideOrbitPositions()
		updateFarSideOrbitPositions()
		manageExplodingStar()
		remainingPersonnel = 0
		for dsi=1,#stationDangerList do
			remainingPersonnel = remainingPersonnel + stationDangerList[dsi].people
		end
		if remainingPersonnel == 0 then
			if auto_end then
				mainScreenStats()
				victory("Human Navy")
			else
				if told_gm == nil then
					addGMMessage("All personnel rescued. If you want to show off the explosion, now is the time.")
					told_gm = "sent"
				end
			end
		end
	end
end
