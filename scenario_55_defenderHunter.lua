-- Name: Defender Hunter
-- Description: Defend home station and hunt down enemies
--- 
--- Initially, you're tasked with defending your home base.  Over time, you'll discover more about the enemies harassing you and you'll be ordered to find and destroy the enemies responsible.  There may be various missions given along the way, but the enemy harassment will continue.  You must balance your two missions.
---
--- Designed for 1-8 cooperating player ships.  Randomization makes many details different for each game, but the primary goals remain the same.  Untimed variations can take an hour or longer for full mission completion.  Different sub-missions may be chosen by the players or will be chosen at random.  Achieving victory in a timed hunter variation is quite a challenge.  Like the Waves scenario, the enemies get harder over time.
---
--- Features: 
--- - Randomly selected player ship names based on type (not just the default call sign generation)
--- - Simple mix of variations based on time and difficulty
--- - Named stations with cargo type often related to name
--- - Some cargo based missions
--- - Mortal but replaceable at station repair crew
--- - Asteroids and nebulae in motion
--- - Intense pacing
--- - Player fighters may activate auto-cooling and auto-repair in engineering
---
--- Version 9 - Oct2020
-- Type: Replayable mission
-- Variation[Easy]: Easy goals and/or enemies
-- Variation[Hard]: Hard goals and/or enemies
-- Variation[Timed Defender]: Victory if home station survives after 30 minutes
-- Variation[Timed Hunter]: Victory if target enemy base destroyed in 30 minutes
-- Variation[Easy Timed Defender]: Easy goals and/or enemies, victory if home station survives after 30 minutes
-- Variation[Easy Timed Hunter]: Easy goals and/or enemies, victory if target enemy base destroyed in 30 minutes
-- Variation[Hard Timed Defender]: Hard goals and/or enemies, victory if home station survives after 30 minutes
-- Variation[Hard Timed Hunter]: Hard goals and/or enemies, victory if target enemy base destroyed in 30 minutes

-- typical colors used in ship log
-- 	"Red"			Red									Enemies spotted
--	"Blue"			Blue
--	"Yellow"		Yellow								Maria Shrivner
--	"Magenta"		Magenta								Headquarters
--	"Green"			Green
--	"Cyan"			Cyan
--	"Black"			Black
--	"#555555"		Dark gray			"55,55,55"
--	"#ff4500"		Orange red			"255,69,0"		HMS Bounty
--	"#ff7f50"		Coral				"255,127,80"
--	"#5f9ea0"		Cadet blue			"95,158,160"	Paul Straight
--	"#4169e1"		Royal blue			"65,105,225"
--	"#8a2be2"		Blue violet			"138,43,226"
--	"#ba55d3"		Medium orchid		"186,85,211"	Maria's station
--	"#a0522d"		Sienna				"160,82,45"
--	"#b29650"		Arbitrary			"178,150,80"
--	"#556b2f"		Dark olive green	"85,107,47"		Home station
--	"#228b22"		Forest green		"34,139,34"
--	"#b22222"		Firebrick			"178,34,34"

require("utils.lua")
function tableRemoveRandom(array)
--	Remove random element from array and return it.
	-- Returns nil if the array is empty,
	-- analogous to `table.remove`.
    local array_item_count = #array
    if array_item_count == 0 then
        return nil
    end
    local selected_item = math.random(array_item_count)
    array[selected_item], array[array_item_count] = array[array_item_count], array[selected_item]
    return table.remove(array)
end
-------------------------------
--	Initialization routines  --
-------------------------------
function init()
	wfv = "nowhere"		--wolf fence value - used for debugging
	plot_1_diagnostic = false
	plot_2_diagnostic = false
	setVariations()
	setMovingAsteroids()
	setMovingNebulae()
	setWormArt()
	setConstants()
	diagnostic = false		
	helpfulWarningDiagnostic = false
	GMDiagnosticOn = "Turn On Diagnostic"
	addGMFunction(GMDiagnosticOn,turnOnDiagnostic)
	default_interwave_interval = 280
	interWave = default_interwave_interval			
	GMDelayNormalToSlow = "Delay normal to slow"
	addGMFunction(GMDelayNormalToSlow,delayNormalToSlow)
	buildStations()
	wfv = "end of init"
end
function setConstants()
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
	--list of goods available to buy, sell or trade (sell still under development)
	goodsList = {	{"food",0},
					{"medicine",0},
					{"nickel",0},
					{"platinum",0},
					{"gold",0},
					{"dilithium",0},
					{"tritanium",0},
					{"luxury",0},
					{"cobalt",0},
					{"impulse",0},
					{"warp",0},
					{"shield",0},
					{"tractor",0},
					{"repulsor",0},
					{"beam",0},
					{"optic",0},
					{"robotic",0},
					{"filament",0},
					{"transporter",0},
					{"sensor",0},
					{"communication",0},
					{"autodoc",0},
					{"lifter",0},
					{"android",0},
					{"nanites",0},
					{"software",0},
					{"circuit",0},
					{"battery",0}	}
	goods = {}					--overall tracking of goods
	commonGoods = {"food","medicine","nickel","platinum","gold","dilithium","tritanium","luxury","cobalt","impulse","warp","shield","tractor","repulsor","beam","optic","robotic","filament","transporter","sensor","communication","autodoc","lifter","android","nanites","software","circuit","battery"}
	componentGoods = {"impulse","warp","shield","tractor","repulsor","beam","optic","robotic","filament","transporter","sensor","communication","autodoc","lifter","android","nanites","software","circuit","battery"}
	mineralGoods = {"nickel","platinum","gold","dilithium","tritanium","cobalt"}
	stationList = {}			--friendly and neutral stations
	friendlyStationList = {}	
	enemyStationList = {}
	tradeFood = {}				--stations that will trade food for other goods
	tradeLuxury = {}			--stations that will trade luxury for other goods
	tradeMedicine = {}			--stations that will trade medicine for other goods
	totalStations = 0
	friendlyStations = 0
	neutralStations = 0
--	setListOfStations()
	--gossip will have meaning for a future mission addition. Right now, it's just color
	gossipSnippets = {}
	table.insert(gossipSnippets,"I hear the head of operations has a thing for his administrative assistant")	--1
	table.insert(gossipSnippets,"My mining friends tell me Krak or Kruk is about to strike it rich")			--2
	table.insert(gossipSnippets,"Did you know you can usually hire replacement repair crew cheaper at friendly stations?")		--3
	table.insert(gossipSnippets,"Under their uniforms, the Kraylors have an extra appendage. I wonder what they use it for")	--4
	table.insert(gossipSnippets,"The Kraylors may be human navy enemies, but they make some mighty fine BBQ Mynock")			--5
	table.insert(gossipSnippets,"The Kraylors and the Ktlitans may be nearing a cease fire from what I hear. That'd be bad news for us")		--6
	table.insert(gossipSnippets,"Docking bay 7 has interesting mind altering substances for sale, but they're monitored between 1900 and 2300")	--7
	table.insert(gossipSnippets,"Watch the sky tonight in quadrant J around 2243. It should be spectacular")					--8
	table.insert(gossipSnippets,"I think the shuttle pilot has a tame miniature Ktlitan caged in his quarters. Sometimes I hear it at night")	--9
	table.insert(gossipSnippets,"Did you hear the screaming chase in the corridors on level 4 last night? Three Kraylors were captured and put in the brig")	--10
	table.insert(gossipSnippets,"Rumor has it that the two Lichten brothers are on the verge of a new discovery. And it's not another wine flavor either")		--11
	--Player ship name lists to supplant standard randomized call sign generation
	playerShipNamesFor = {}
	-- TODO switch to spelling with space or dash matching the type name
	playerShipNamesFor["MP52Hornet"] = {"Dragonfly","Scarab","Mantis","Yellow Jacket","Jimminy","Flik","Thorny","Buzz"}
	playerShipNamesFor["Piranha"] = {"Razor","Biter","Ripper","Voracious","Carnivorous","Characid","Vulture","Predator"}
	playerShipNamesFor["FlaviaPFalcon"] = {"Ladyhawke","Hunter","Seeker","Gyrefalcon","Kestrel","Magpie","Bandit","Buccaneer"}
	playerShipNamesFor["PhobosM3P"] = {"Blinder","Shadow","Distortion","Diemos","Ganymede","Castillo","Thebe","Retrograde"}
	playerShipNamesFor["Atlantis"] = {"Excaliber","Thrasher","Punisher","Vorpal","Protang","Drummond","Parchim","Coronado"}
	playerShipNamesFor["Cruiser"] = {"Excelsior","Velociraptor","Thunder","Kona","Encounter","Perth","Aspern","Panther"}
	playerShipNamesFor["MissileCruiser"] = {"Projectus","Hurlmeister","Flinger","Ovod","Amatola","Nakhimov","Antigone"}
	playerShipNamesFor["Fighter"] = {"Buzzer","Flitter","Zippiticus","Hopper","Molt","Stinger","Stripe"}
	playerShipNamesFor["Benedict"] = {"Elizabeth","Ford","Vikramaditya","Liaoning","Avenger","Naruebet","Washington","Lincoln","Garibaldi","Eisenhower"}
	playerShipNamesFor["Kiriya"] = {"Cavour","Reagan","Gaulle","Paulo","Truman","Stennis","Kuznetsov","Roosevelt","Vinson","Old Salt"}
	playerShipNamesFor["Striker"] = {"Sparrow","Sizzle","Squawk","Crow","Phoenix","Snowbird","Hawk"}
	playerShipNamesFor["Lindworm"] = {"Seagull","Catapult","Blowhard","Flapper","Nixie","Pixie","Tinkerbell"}
	playerShipNamesFor["Repulse"] = {"Fiddler","Brinks","Loomis","Mowag","Patria","Pandur","Terrex","Komatsu","Eitan"}
	playerShipNamesFor["Ender"] = {"Mongo","Godzilla","Leviathan","Kraken","Jupiter","Saturn"}
	playerShipNamesFor["Nautilus"] = {"October", "Abdiel", "Manxman", "Newcon", "Nusret", "Pluton", "Amiral", "Amur", "Heinkel", "Dornier"}
	playerShipNamesFor["Hathcock"] = {"Hayha", "Waldron", "Plunkett", "Mawhinney", "Furlong", "Zaytsev", "Pavlichenko", "Pegahmagabow", "Fett", "Hawkeye", "Hanzo"}
	playerShipNamesFor["Maverick"] = {"Festoon", "Earp", "Schwartz", "Tentacular", "Prickly", "Thunderbird", "Hickok", "Clifton", "Fett", "Holliday", "Sundance"}
	playerShipNamesFor["Crucible"] = {"Sling", "Stark", "Torrid", "Kicker", "Flummox"}
	playerShipNamesFor["Leftovers"] = {"Foregone","Righteous","Masher"}
	highestConcurrentPlayerCount = 0
	setConcurrentPlayerCount = 0
	primaryOrders = ""
	secondaryOrders = ""
	optionalOrders = ""
	transportList = {}
	homeDelivery = false
	infoPromised = false
	baseIntelligenceAvailable = false
	spinUpgradeAvailable = false
	hullUpgradeAvailable = false
	rotateUpgradeAvailable = false
	beamTimeUpgradeAvailable = false
	missionLength = 1
	initialOrderTimer = 3
	plot1 = initialOrders
	transportSpawnDelay = 10
	plotT = transportPlot
	plotH = healthCheck
	plotC = autoCoolant
	healthCheckTimer = 5
	healthCheckTimerInterval = 5
	healthCheckCount = 0
	plot4choices = {}
	table.insert(plot4choices,stationShieldDelay)
	table.insert(plot4choices,repairBountyDelay)
	table.insert(plot4choices,insertAgentDelay)
end
function setVariations()
--translate variations into a numeric difficulty value
	if string.find(getScenarioVariation(),"Easy") then
		difficulty = .5
	elseif string.find(getScenarioVariation(),"Hard") then
		difficulty = 2
	else
		difficulty = 1		--default (normal)
	end
	gameTimeLimit = 0
	if string.find(getScenarioVariation(),"Timed") then
		timedIntelligenceInterval = 200
		playWithTimeLimit = true
		gameTimeLimit = 30*60		
		plot6 = timedGame
	else
		timedIntelligenceInterval = 300
		playWithTimeLimit = false
	end
end
function GMSpawnsEnemies()
-- Let the GM spawn a random group of enemies to attack a player
	local gmPlayer = nil
	local gmSelect = getGMSelection()
	for _, obj in ipairs(gmSelect) do
		if obj.typeName == "PlayerSpaceship" then
			gmPlayer = obj
			break
		end
	end
	if gmPlayer == nil then
		gmPlayer = closestPlayerTo(targetEnemyStation)
	end
	local px, py = gmPlayer:getPosition()
	local sx, sy = vectorFromAngle(random(0,360),random(20000,30000))
	ntf = spawnEnemies(px+sx,py+sy,dangerValue,targetEnemyStation:getFaction())
	for _, enemy in ipairs(ntf) do
		enemy:orderAttack(gmPlayer)
	end
end
function turnOnDiagnostic()
-- Diagnostic enable/disable buttons on GM screen
	diagnostic = true
	removeGMFunction(GMDiagnosticOn)
	addGMFunction("Turn Off Diagnostic",turnOffDiagnostic)
end
function turnOffDiagnostic()
	diagnostic = false
	removeGMFunction(GMDiagnosticOff)
	addGMFunction("Turn On Diagnostic",turnOnDiagnostic)
end
function populateStationPool()
	station_pool = {
		["Science"] = {
			["Asimov"] = {
		        weapon_available = 	{
		        	Homing =			true,
		        	HVLI =				random(1,13)<=(9-difficulty),
		        	Mine =				true,
		        	Nuke =				random(1,13)<=(5-difficulty),
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop = "friend",
					reinforcements = "friend",
					jumpsupplydrop = "friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 			1.0, 
		        	neutral = 			3.0,
		        },
        		goods = {	
        			tractor = {
        				quantity =	5,	
        				cost =		48,
        			},
        			repulsor = {
        				quantity =	5,
        				cost =		48,
        			},
        		},
		        trade = {	
		        	food =			false, 
		        	medicine =		false, 
		        	luxury =		false,
		        },
				description = "Training and Coordination", 
				general = "We train naval cadets in routine and specialized functions aboard space vessels and coordinate naval activity throughout the sector", 
				history = "The original station builders were fans of the late 20th century scientist and author Isaac Asimov. The station was initially named Foundation, but was later changed simply to Asimov. It started off as a stellar observatory, then became a supply stop and as it has grown has become an educational and coordination hub for the region",
			},
			["Armstrong"] =	{
		        weapon_available = {
		        	Homing = 			random(1,13)<=(8-difficulty),	
		        	HVLI = 				true,		
		        	Mine = 				random(1,13)<=(7-difficulty),	
		        	Nuke = 				random(1,13)<=(5-difficulty),	
		        	EMP = 				true
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {	
					warp = {
						quantity =	5,	
						cost =		77,
					},
					repulsor = {
						quantity =	5,	
						cost =		62,
					},
				},
				trade = {	
					food = random(1,100) <= 45, 
					medicine = false, 
					luxury = false,
				},
				buy = {
					[randomMineral()] = math.random(40,200),
				},
				description = "Warp and Impulse engine manufacturing", 
				general = "We manufacture warp, impulse and jump engines for the human navy fleet as well as other independent clients on a contract basis", 
				history = "The station is named after the late 19th century astronaut as well as the fictionlized stations that followed. The station initially constructed entire space worthy vessels. In time, it transitioned into specializeing in propulsion systems.",
			},
			["Broeck"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					warp = {
						quantity =	5,
						cost =		36,
					},
				},
				trade = {
					food = random(1,100) <= 14, 
					medicine = false, 
					luxury = random(1,100) < 62,
				},
				buy = {
					[randomMineral()] = math.random(40,200),
				},
				description = "Warp drive components", 
				general = "We provide warp drive engines and components", 
				history = "This station is named after Chris Van Den Broeck who did some initial research into the possibility of warp drive in the late 20th century on Earth",
			},
			["Coulomb"] = {
		        weapon_available = 	{
		        	Homing = random(1,13)<=(8-difficulty),	
		        	HVLI = random(1,13)<=(9-difficulty),	
		        	Mine = random(1,13)<=(7-difficulty),	
		        	Nuke = random(1,13)<=(5-difficulty),	
		        	EMP = random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
        		goods = {	
        			circuit =	{
        				quantity =	5,	
        				cost =		50,
        			},
        		},
        		trade = {	
        			food = random(1,100) <= 35, 
        			medicine = false, 
        			luxury = random(1,100) < 82,
        		},
				buy =	{
					[randomMineral()] = math.random(40,200),
				},
				description = "Shielded circuitry fabrication", 
				general = "We make a large variety of circuits for numerous ship systems shielded from sensor detection and external control interference", 
				history = "Our station is named after the law which quantifies the amount of force with which stationary electrically charged particals repel or attact each other - a fundamental principle in the design of our circuits",
			},
			["Heyes"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				true,		
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					sensor = {
						quantity =	5,
						cost =		72,
					},
				},
				trade = {
					food = random(1,100) <= 32, 
					medicine = false, 
					luxury = true,
				},
				buy = {
					[randomMineral()] = math.random(40,200),
				},
				description = "Sensor components", 
				general = "We research and manufacture sensor components and systems", 
				history = "The station is named after Tony Heyes the inventor of some of the earliest electromagnetic sensors in the mid 20th century on Earth in the United Kingdom to assist blind human mobility",
			},
			["Hossam"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					nanites = {
						quantity =	5,	
						cost =		90,
					},
				},
				trade = {
					food = random(1,100) < 24, 
					medicine = random(1,100) < 44, 
					luxury = random(1,100) < 63,
				},
				description = "Nanite supplier", 
				general = "We provide nanites for various organic and non-organic systems", 
				history = "This station is named after the nanotechnologist Hossam Haick from the early 21st century on Earth in Israel",
			},
			["Maiman"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				false,		
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					beam = {
						quantity =	5,
						cost =		70,
					},
				},
				trade = {
					food = random(1,100) <= 75, 
					medicine = true, 
					luxury = false,
				},
				buy = {
					[randomMineral()] = math.random(40,200),
				},
				description = "Energy beam components", 
				general = "We research and manufacture energy beam components and systems", 
				history = "The station is named after Theodore Maiman who researched and built the first laser in the mid 20th century on Earth",
			},
			["Malthus"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
		        goods = {},
    			trade = {
    				food = random(1,100) <= 65, 
    				medicine = false, 
    				luxury = false,
    			},
    			description = "Gambling and resupply",
		        general = "The oldest station in the quadrant",
		        history = "",
			},
			["Marconi"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					beam = {
						quantity =	5,
						cost =		80,
					},
				},
				trade = {
					food = random(1,100) <= 53, 
					medicine = false, 
					luxury = true,
				},
				description = "Energy Beam Components", 
				general = "We manufacture energy beam components", 
				history = "Station named after Guglielmo Marconi an Italian inventor from early 20th century Earth who, along with Nicolo Tesla, claimed to have invented a death ray or particle beam weapon",
			},
			["Miller"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					optic =	{
						quantity =	5,
						cost =		60,
					},
				},
				trade = {
					food = random(1,100) <= 68, 
					medicine = false, 
					luxury = false,
				},
				description = "Exobiology research", 
				general = "We study recently discovered life forms not native to Earth", 
				history = "This station was named after one of the early exobiologists from mid 20th century Earth, Dr. Stanley Miller",
			},
			["Shawyer"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					impulse = {
						quantity =	5,
						cost =		100,
					},
				},
				trade = {
					food = random(1,100) <= 42, 
					medicine = false, 
					luxury = true,
				},
				description = "Impulse engine components", 
				general = "We research and manufacture impulse engine components and systems", 
				history = "The station is named after Roger Shawyer who built the first prototype impulse engine in the early 21st century",
			},
		},
		["History"] = {
			["Archimedes"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					beam = {
						quantity =	5,
						cost =		80,
					},
				},
				trade = {
					food = true, 
					medicine = false, 
					luxury = true,
				},
				description = "Energy and particle beam components", 
				general = "We fabricate general and specialized components for ship beam systems", 
				history = "This station was named after Archimedes who, according to legend, used a series of adjustable focal length mirrors to focus sunlight on a Roman naval fleet invading Syracuse, setting fire to it",
			},
			["Chatuchak"] =	{
		        weapon_available = {
		        	Homing =				random(1,10)<=(8-difficulty),	
		        	HVLI =				random(1,10)<=(9-difficulty),	
		        	Mine =				false,		
		        	Nuke =				random(1,10)<=(5-difficulty),	
		        	EMP =				random(1,10)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		60,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Trading station", 
				general = "Only the largest market and trading location in twenty sectors. You can find your heart's desire here", 
				history = "Modeled after the early 21st century bazaar on Earth in Bangkok, Thailand. Designed and built with trade and commerce in mind",
			},
			["Grasberg"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		70,
					},
				},
				trade = {
					food = true, 
					medicine = false, 
					luxury = false,
				},
				buy = {
					[randomComponent()] = math.random(40,200),
				},
				description = "Mining", 
				general ="We mine nearby asteroids for precious minerals and process them for sale", 
				history = "This station's name is inspired by a large gold mine on Earth in Indonesia. The station builders hoped to have a similar amount of minerals found amongst these asteroids",
			},
			["Hayden"] = {
		        weapon_available = {
		        	Homing = random(1,13)<=(8-difficulty),	
		        	HVLI = random(1,13)<=(9-difficulty),	
		        	Mine = random(1,13)<=(7-difficulty),	
		        	Nuke = random(1,13)<=(5-difficulty),	
		        	EMP = random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					nanites = {
						quantity =	5,
						cost =		65,
					},
				},
				trade = {
					food = random(1,100) <= 85, 
					medicine = false, 
					luxury = false,
				},
				description = "Observatory and stellar mapping", 
				general = "We study the cosmos and map stellar phenomena. We also track moving asteroids. Look out! Just kidding", 
				history = "Station named in honor of Charles Hayden whose philanthropy continued astrophysical research and education on Earth in the early 20th century",
			},
			["Lipkin"] = {
		        weapon_available = {
		        	Homing =				random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				false,		
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					autodoc = {
						quantity =	5,
						cost =		76,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = true,
				},
				description = "Autodoc components", 
				general = "", 
				history = "The station is named after Dr. Lipkin who pioneered some of the research and application around robot assisted surgery in the area of partial nephrectomy for renal tumors in the early 21st century on Earth",
			},
			["Madison"] = {
		        weapon_available = {
		        	Homing =			false,		
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		math.random(60,70),
					},
				},
				trade = {
					food = false, 
					medicine = true, 
					luxury = false,
				},
				description = "Zero gravity sports and entertainment", 
				general = "Come take in a game or two or perhaps see a show", 
				history = "Named after Madison Square Gardens from 21st century Earth, this station was designed to serve similar purposes in space - a venue for sports and entertainment",
			},
			["Rutherford"] = {
		        weapon_available = {
		        	Homing = random(1,13)<=(8-difficulty),	
		        	HVLI = random(1,13)<=(9-difficulty),	
		        	Mine = random(1,13)<=(7-difficulty),	
		        	Nuke = random(1,13)<=(5-difficulty),	
		        	EMP = random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					shield = {
						quantity =	5,	
						cost =		90,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = random(1,100) < 43,
				},
				description = "Shield components and research", 
				general = "We research and fabricate components for ship shield systems", 
				history = "This station was named after the national research institution Rutherford Appleton Laboratory in the United Kingdom which conducted some preliminary research into the feasability of generating an energy shield in the late 20th century",
			},
			["Toohie"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					shield = {
						quantity =	5,
						cost =		90,
					},
				},
				trade = {
					food = random(1,100) <= 21, 
					medicine = false, 
					luxury = true,
				},
				description = "Shield and armor components and research", 
				general = "We research and make general and specialized components for ship shield and ship armor systems", 
				history = "This station was named after one of the earliest researchers in shield technology, Alexander Toohie back when it was considered impractical to construct shields due to the physics involved."},
		},
		["Pop Sci Fi"] = {
			["Anderson"] = {
		        weapon_available = {
		        	Homing = false,		
		        	HVLI = random(1,13)<=(9-difficulty),	
		        	Mine = random(1,13)<=(7-difficulty),	
		        	Nuke = random(1,13)<=(5-difficulty),	
		        	EMP = random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					battery = {
						quantity =	5,
						cost =		66,
					},
        			software = {
        				quantity =	5,
        				cost =		115,
        			},
        		},
				trade = {
					food = false, 
					medicine = false, 
					luxury = true,
				},
				description = "Battery and software engineering", 
				general = "We provide high quality high capacity batteries and specialized software for all shipboard systems", 
				history = "The station is named after a fictional software engineer in a late 20th century movie depicting humanity unknowingly conquered by aliens and kept docile by software generated illusion",
			},
			["Archer"] = {
		        weapon_available = {
		        	Homing = 			random(1,13)<=(8-difficulty),	
		        	HVLI = 				true,		
		        	Mine = 				random(1,13)<=(7-difficulty),	
		        	Nuke = 				random(1,13)<=(5-difficulty),	
		        	EMP = 				true
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					shield = {
						quantity =	5,
						cost =		90,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = true,
				},
				buy = {
					[randomMineral()] = math.random(40,200),
				},
				description = "Shield and Armor Research", 
				general = "The finest shield and armor manufacturer in the quadrant", 
				history = "We named this station for the pioneering spirit of the 22nd century Starfleet explorer, Captain Jonathan Archer",
			},
			["Barclay"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				false,		
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					communication =	{
						quantity =	5,
						cost =		58,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				buy = {
					[randomMineral()] = math.random(40,200),
				},
				description = "Communication components", 
				general = "We provide a range of communication equipment and software for use aboard ships", 
				history = "The station is named after Reginald Barclay who established the first transgalactic com link through the creative application of a quantum singularity. Station personnel often refer to the station as the Broccoli station",
			},
			["Calvin"] = {
		        weapon_available = {
		        	Homing =			false,		
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {	
					robotic = {
						quantity =	5,	
						cost = 		90,
					},
				},
				trade = {
					food = random(1,100) <= 35, 
					medicine = false, 
					luxury = true,
				},
				buy =	{
					[randomComponent("robotic")] = math.random(40,200)
				},
				description = "Robotic research", 
				general = "We research and provide robotic systems and components", 
				history = "This station is named after Dr. Susan Calvin who pioneered robotic behavioral research and programming",
			},
			["Cavor"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					filament = {
						quantity =	5,
						cost =		42,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Advanced Material components", 
				general = "We fabricate several different kinds of materials critical to various space industries like ship building, station construction and mineral extraction", 
				history = "We named our station after Dr. Cavor, the physicist that invented a barrier material for gravity waves - Cavorite",
			},
			["Cyrus"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					impulse = {
						quantity =	5,
						cost =		124,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = random(1,100) < 78,
				},
				description = "Impulse engine components", 
				general = "We supply high quality impulse engines and parts for use aboard ships", 
				history = "This station was named after the fictional engineer, Cyrus Smith created by 19th century author Jules Verne",
			},
			["Deckard"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					android = {
						quantity =	5,
						cost =		73,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = true,
				},
				description = "Android components", 
				general = "Supplier of android components, programming and service", 
				history = "Named for Richard Deckard who inspired many of the sophisticated safety security algorithms now required for all androids",
			},
			["Erickson"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					transporter = {
						quantity =	5,
						cost =		63,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = true,
				},
				description = "Transporter components", 
				general = "We provide transporters used aboard ships as well as the components for repair and maintenance", 
				history = "The station is named after the early 22nd century inventor of the transporter, Dr. Emory Erickson. This station is proud to have received the endorsement of Admiral Leonard McCoy",
			},
			["Jabba"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Commerce and gambling", 
				general = "Come play some games and shop. House take does not exceed 4 percent", 
				history = "",
			},			
			["Komov"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				true,	
		        	Nuke =				false,	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					filament = {
						quantity =	5,
						cost =		46,
					},
				},
 				trade = {
 					food = false, 
 					medicine = false, 
 					luxury = false,
 				},
				description = "Xenopsychology training", 
				general = "We provide classes and simulation to help train diverse species in how to relate to each other", 
				history = "A continuation of the research initially conducted by Dr. Gennady Komov in the early 22nd century on Venus, supported by the application of these principles",
			},
			["Lando"] = {
		        weapon_available = {
		        	Homing =			true,	
		        	HVLI =				true,	
		        	Mine =				true,	
		        	Nuke =				false,	
		        	EMP =				false,
		        },
				weapon_cost = {
					Homing = math.random(2,5),
					HVLI = 2,
					Mine = math.random(2,5),
				},
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					shield = {
						quantity =	5,
						cost =		90,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Casino and Gambling", 
				general = "", 
				history = "",
			},			
			["Muddville"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		60,
					},
				},
				trade = {
					food = true, 
					medicine = true, 
					luxury = false,
				},
				description = "Trading station", 
				general = "Come to Muddvile for all your trade and commerce needs and desires", 
				history = "Upon retirement, Harry Mudd started this commercial venture using his leftover inventory and extensive connections obtained while he traveled the stars as a salesman",
			},
			["Nexus-6"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				false,		
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					android = {
						quantity =	5,
						cost =		93,
					},
				},
				trade = {
					food = false, 
					medicine = true, 
					luxury = false,
				},
				buy = {
					[randomMineral()] = math.random(40,200),
					[randomComponent("android")] = math.random(40,200),
				},
				description = "Android components", 
				general = "Androids, their parts, maintenance and recylcling", 
				history = "We named the station after the ground breaking android model produced by the Tyrell corporation",
			},
			["O'Brien"] = {
		        weapon_available = {
		        	Homing = random(1,13)<=(8-difficulty),	
		        	HVLI = random(1,13)<=(9-difficulty),	
		        	Mine = random(1,13)<=(7-difficulty),	
		        	Nuke = random(1,13)<=(5-difficulty),	
		        	EMP = random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					transporter = {
						quantity =	5,
						cost =		76,
					},
				},
				trade = {
					food = random(1,100) < 13, 
					medicine = true, 
					luxury = random(1,100) < 43,
				},
				description = "Transporter components", 
				general = "We research and fabricate high quality transporters and transporter components for use aboard ships", 
				history = "Miles O'Brien started this business after his experience as a transporter chief",
			},
			["Organa"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		95,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Diplomatic training", 
				general = "The premeire academy for leadership and diplomacy training in the region", 
				history = "Established by the royal family so critical during the political upheaval era",
			},
			["Owen"] = {
		        weapon_available = {
		        	Homing =			true,			
		        	HVLI =				false,		
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					lifter = {
						quantity =	5,
						cost =		61,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = true,
				},
				description = "Load lifters and components", 
				general = "We provide load lifters and components for various ship systems", 
				history = "Owens started off in the moisture vaporator business on Tattooine then branched out into load lifters based on acquisition of proprietary software and protocols. The station name recognizes the tragic loss of our founder to Imperial violence",
			},
			["Ripley"] = {
		        weapon_available = {
		        	Homing =			false,		
		        	HVLI =				true,		
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					lifter = {
						quantity =	5,
						cost =		82,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = random(1,100) < 47,
				},
				description = "Load lifters and components", 
				general = "We provide load lifters and components", 
				history = "The station is named after Ellen Ripley who made creative and effective use of one of our load lifters when defending her ship",
			},
			["Skandar"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Routine maintenance and entertainment", 
				general = "Stop by for repairs. Take in one of our juggling shows featuring the four-armed Skandars", 
				history = "The nomadic Skandars have set up at this station to practice their entertainment and maintenance skills as well as build a community where Skandars can relax",
			},			
			["Soong"] = {
		        weapon_available = {
		        	Homing = random(1,13)<=(8-difficulty),	
		        	HVLI = random(1,13)<=(9-difficulty),	
		        	Mine = random(1,13)<=(7-difficulty),	
		        	Nuke = random(1,13)<=(5-difficulty),	
		        	EMP = random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					android = {
						quantity =	5,
						cost = 73,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = true,
				},
				description = "Android components", 
				general = "We create androids and android components", 
				history = "The station is named after Dr. Noonian Soong, the famous android researcher and builder",
			},
			["Starnet"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
		        goods = {	
		        	software =	{
		        		quantity =	5,	
		        		cost =		140,
		        	},
		        },
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Automated weapons systems", 
				general = "We research and create automated weapons systems to improve ship combat capability", 
				history = "Lost the history memory bank. Recovery efforts only brought back the phrase, 'I'll be back'",
			},			
			["Tiberius"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					food = {
						quantity =	5,
						cost =		1,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Logistics coordination", 
				general = "We support the stations and ships in the area with planning and communication services", 
				history = "We recognize the influence of Starfleet Captain James Tiberius Kirk in the 23rd century in our station name",
			},
			["Tokra"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					filament = {
						quantity =	5,
						cost =		42,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Advanced material components", 
				general = "We create multiple types of advanced material components. Our most popular products are our filaments", 
				history = "We learned several of our critical industrial processes from the Tokra race, so we honor our fortune by naming the station after them",
			},
			["Utopia Planitia"] = {
		        weapon_available = 	{
		        	Homing = 			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				true,		
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        goods = {	
		        	warp =	{
		        		quantity =	5,	
		        		cost =		167,
		        	},
		        },
		        trade = {	
		        	food = false, 
		        	medicine = false, 
		        	luxury = false 
		        },
				description = "Ship building and maintenance facility", 
				general = "We work on all aspects of naval ship building and maintenance. Many of the naval models are researched, designed and built right here on this station. Our design goals seek to make the space faring experience as simple as possible given the tremendous capabilities of the modern naval vessel", 
				history = ""
			},
			["Vaiken"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					food = {
						quantity =	10,
						cost = 		1,
					},
        			medicine = {
        				quantity =	5,
        				cost = 		5,
        			},
        			impulse = {
        				quantity =	5,
        				cost = 		math.random(65,97),
        			},
        		},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Ship building and maintenance facility", 
				general = "", 
				history = "",
			},			
			["Zefram"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
		        goods = {	
		        	warp =	{
		        		quantity =	5,	
		        		cost =		140,
		        	},
		        },
		        trade = {	
		        	food = false, 
		        	medicine = false, 
		        	luxury = true,
		        },
				description = "Warp engine components", 
				general = "We specialize in the esoteric components necessary to make warp drives function properly", 
				history = "Zefram Cochrane constructed the first warp drive in human history. We named our station after him because of the specialized warp systems work we do",
			},
		},
		["Spec Sci Fi"] = {
			["Alcaleica"] =	{
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					optic = {
						quantity =	5,
						cost =		66,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				buy = {
					[randomMineral()] = math.random(40,200),
				},
				description = "Optical Components", 
				general = "We make and supply optic components for various station and ship systems", 
				history = "This station continues the businesses from Earth based on the merging of several companies including Leica from Switzerland, the lens manufacturer and the Japanese advanced low carbon (ALCA) electronic and optic research and development company",
			},
			["Bethesda"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				reputation_cost_multipliers = {
					friend = 1.0, 
					neutral = 3.0,
				},
				goods = {	
					autodoc = {
						quantity =	5,
						cost =		36,
					},
					medicine = {
						quantity =	5,					
						cost = 		5,
					},
					food = {
						quantity =	math.random(5,10),	
						cost = 		1,
					},
				},
				trade = {	
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Medical research", 
				general = "We research and treat exotic medical conditions", 
				history = "The station is named after the United States national medical research center based in Bethesda, Maryland on earth which was established in the mid 20th century",
			},
			["Deer"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {	
					tractor = {
						quantity =	5,	
						cost =		90,
					},
        			repulsor = {
        				quantity =	5,
        				cost =		math.random(85,95),
        			},
        		},
				trade = {
					food = false, 
					medicine = false, 
					luxury = true,
				},
				description = "Repulsor and Tractor Beam Components", 
				general = "We can meet all your pushing and pulling needs with specialized equipment custom made", 
				history = "The station name comes from a short story by the 20th century author Clifford D. Simak as well as from the 19th century developer John Deere who inspired a company that makes the Earth bound equivalents of our products",
			},
			["Evondos"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				true,		
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				reputation_cost_multipliers = {
					friend = 1.0, 
					neutral = 3.0,
				},
				goods = {
					autodoc = {
						quantity =	5,
						cost =		56,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = random(1,100) < 41,
				},
				description = "Autodoc components", 
				general = "We provide components for automated medical machinery", 
				history = "The station is the evolution of the company that started automated pharmaceutical dispensing in the early 21st century on Earth in Finland",
			},
			["Feynman"] = {
		        weapon_available = 	{
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				true,		
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
        		goods = {	
        			software = {
        				quantity = 	5,	
        				cost =		115,
        			},
        			nanites = {
        				quantity =	5,	
        				cost =		79,
        			},
        		},
		        trade = {	
		        	food = false, 
		        	medicine = false, 
		        	luxury = true,
		        },
				description = "Nanotechnology research", 
				general = "We provide nanites and software for a variety of ship-board systems", 
				history = "This station's name recognizes one of the first scientific researchers into nanotechnology, physicist Richard Feynman",
			},
			["Mayo"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					autodoc = {
						quantity =	5,
						cost =		128,
					},
        			food = {
        				quantity =	5,
        				cost =		1,
        			},
        			medicine = {
        				quantity =	5,
        				cost =		5,
        			},
        		},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Medical Research", 
				general = "We research exotic diseases and other human medical conditions", 
				history = "We continue the medical work started by William Worrall Mayo in the late 19th century on Earth",
			},
			["Olympus"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					optic =	{
						quantity =	5,
						cost =		66,
					},
				},
				trade = {	
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Optical components", 
				general = "We fabricate optical lenses and related equipment as well as fiber optic cabling and components", 
				history = "This station grew out of the Olympus company based on earth in the early 21st century. It merged with Infinera, then bought several software comapnies before branching out into space based industry",
			},
			["Panduit"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					optic =	{
						quantity =	5,
						cost =		79,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = true,
				},
				description = "Optic components", 
				general = "We provide optic components for various ship systems", 
				history = "This station is an outgrowth of the Panduit corporation started in the mid 20th century on Earth in the United States",
			},
			["Shree"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {	
					tractor = {
						quantity =	5,	
						cost =		90,
					},
        			repulsor = {
        				quantity =	5,
        				cost =		math.random(85,95),
        			},
        		},
				trade = {
					food = false, 
					medicine = false, 
					luxury = true,
				},
				description = "Repulsor and tractor beam components", 
				general = "We make ship systems designed to push or pull other objects around in space", 
				history = "Our station is named Shree after one of many tugboat manufacturers in the early 21st century on Earth in India. Tugboats serve a similar purpose for ocean-going vessels on earth as tractor and repulsor beams serve for space-going vessels today",
			},
			["Vactel"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					circuit = {
						quantity =	5,
						cost =		50,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Shielded Circuitry Fabrication", 
				general = "We specialize in circuitry shielded from external hacking suitable for ship systems", 
				history = "We started as an expansion from the lunar based chip manufacturer of Earth legacy Intel electronic chips",
			},
			["Veloquan"] = {
		        weapon_available = {
		        	Homing = random(1,13)<=(8-difficulty),	
		        	HVLI = random(1,13)<=(9-difficulty),	
		        	Mine = random(1,13)<=(7-difficulty),	
		        	Nuke = random(1,13)<=(5-difficulty),	
		        	EMP = random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					sensor = {
						quantity =	5,
						cost =		68,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Sensor components", 
				general = "We research and construct components for the most powerful and accurate sensors used aboard ships along with the software to make them easy to use", 
				history = "The Veloquan company has its roots in the manufacturing of LIDAR sensors in the early 21st century on Earth in the United States for autonomous ground-based vehicles. They expanded research and manufacturing operations to include various sensors for space vehicles. Veloquan was the result of numerous mergers and acquisitions of several companies including Velodyne and Quanergy",
			},
			["Tandon"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Biotechnology research",
				general = "Merging the organic and inorganic through research", 
				history = "Continued from the Tandon school of engineering started on Earth in the early 21st century",
			},
		},
		["Generic"] = {
			["California"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {	
					gold = {
						quantity =	5,
						cost =		90,
					},
					dilithium = {
						quantity =	2,					
						cost = 		25,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Mining station", 
				general = "", 
				history = "",
			},
			["Impala"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		70,
					},
				},
				trade = {
					food = true, 
					medicine = false, 
					luxury = true,
				},
				buy = {
					[randomComponent()] = math.random(40,200),
				},
				description = "Mining", 
				general = "We mine nearby asteroids for precious minerals", 
				history = "",
			},
			["Krak"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				true,		
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					nickel = {
						quantity =	5,
						cost =		20,
					},
				},
				trade = {
					food = random(1,100) < 50, 
					medicine = true, 
					luxury = random(1,100) < 50,
				},
				buy = {
					[randomComponent()] = math.random(40,200),
				},
				description = "Mining station", 
				general = "", 
				history = "",
			},
			["Krik"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					nickel = {
						quantity =	5,
						cost =		20,
					},
				},
				trade = {
					food = true, 
					medicine = true, 
					luxury = random(1,100) < 50,
				},
				description = "Mining station", 
				general = "", 
				history = "",
			},
			["Kruk"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					nickel = {
						quantity =	5,
						cost =		20,
					},
				},
				trade = {
					food = random(1,100) < 50, 
					medicine = random(1,100) < 50, 
					luxury = true },
				buy = {
					[randomComponent()] = math.random(40,200),
				},
				description = "Mining station", 
				general = "", 
				history = "",
			},
			["Maverick"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Gambling and resupply", 
				general = "Relax and meet some interesting players", 
				history = "",
			},
			["Nefatha"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Commerce and recreation", 
				general = "", 
				history = "",
			},
			["Okun"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				false,		
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Xenopsychology research", 
				general = "", 
				history = "",
			},
			["Outpost-15"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Mining and trade", 
				general = "", 
				history = "",
			},
			["Outpost-21"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Mining and gambling", 
				general = "", 
				history = "",
			},
			["Outpost-7"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Resupply", 
				general = "", 
				history = "",
			},
			["Outpost-8"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "", 
				general = "", 
				history = "",
			},
			["Outpost-33"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Resupply", 
				general = "", 
				history = "",
			},
			["Prada"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				false,		
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Textiles and fashion", 
				general = "", 
				history = "",
			},
			["Research-11"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					medicine = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Stress Psychology Research", 
				general = "", 
				history = "",
			},
			["Research-19"] = {
		        weapon_available ={
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
		        goods = {},
		        trade = {
		        	food = false, 
		        	medicine = false, 
		        	luxury = false,
		        },
				description = "Low gravity research", 
				general = "", 
				history = "",
			},
			["Rubis"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Resupply", 
				general = "Get your energy here! Grab a drink before you go!", 
				history = "",
			},
			["Science-2"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					circuit = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Research Lab and Observatory", 
				general = "", 
				history = "",
			},
			["Science-4"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					medicine = {
						quantity =	5,
						cost =		math.random(30,80),
					},
					autodoc = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Biotech research", 
				general = "", 
				history = "",
			},
			["Science-7"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					food = {
						quantity =	2,
						cost =		1,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Observatory", 
				general = "", 
				history = "",
			},
			["Spot"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
		        goods = {},
		        trade = {
		        	food = false, 
		        	medicine = false, 
		        	luxury = false,
		        },
				description = "Observatory", 
				general = "", 
				history = "",
			},
			["Valero"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Resupply", 
				general = "", 
				history = "",
			},
		},
		["Sinister"] = {
			["Aramanth"] =	{goods = {}, description = "", general = "", history = ""},
			["Empok Nor"] =	{goods = {}, description = "", general = "", history = ""},
			["Gandala"] =	{goods = {}, description = "", general = "", history = ""},
			["Hassenstadt"] =	{goods = {}, description = "", general = "", history = ""},
			["Kaldor"] =	{goods = {}, description = "", general = "", history = ""},
			["Magenta Mesra"] =	{goods = {}, description = "", general = "", history = ""},
			["Mos Eisley"] =	{goods = {}, description = "", general = "", history = ""},
			["Questa Verde"] =	{goods = {}, description = "", general = "", history = ""},
			["R'lyeh"] =	{goods = {}, description = "", general = "", history = ""},
			["Scarlet Citadel"] =	{goods = {}, description = "", general = "", history = ""},
			["Stahlstadt"] =	{goods = {}, description = "", general = "", history = ""},
			["Ticonderoga"] =	{goods = {}, description = "", general = "", history = ""},
		},
	}
	station_priority = {}
	table.insert(station_priority,"Science")
	table.insert(station_priority,"Pop Sci Fi")
	table.insert(station_priority,"Spec Sci Fi")
	table.insert(station_priority,"History")
	table.insert(station_priority,"Generic")
	for group, list in pairs(station_pool) do
		local already_inserted = false
		for _, previous_group in ipairs(station_priority) do
			if group == previous_group then
				already_inserted = true
				break
			end
		end
		if not already_inserted and group ~= "Sinister" then
			table.insert(station_priority,group)
		end
	end
end
function placeStation(x,y,name,faction,size)
	--x and y are the position of the station
	--name should be the name of the station or the name of the station group
	--		omit name to get random station from groups in priority order
	--faction is the faction of the station
	--		omit and stationFaction will be used
	--size is the name of the station template to use
	--		omit and station template will be chosen at random via szt function
	if x == nil then return nil end
	if y == nil then return nil end
	local group, station = pickStation(name)
	if group == nil then return nil end
	station:setPosition(x,y)
	if faction ~= nil then
		station:setFaction(faction)
	else
		if stationFaction ~= nil then
			station:setFaction(stationFaction)
		else
			station:setFaction("Independent")
		end
	end
	if size == nil then
		station:setTemplate(szt())
	else
		local function Set(list)
			local set = {}
			for _, item in ipairs(list) do
				set[item] = true
			end
			return set
		end
		local station_size_templates = Set{"Small Station","Medium Station","Large Station","Huge Station"}
		if station_size_templates[size] then
			station:setTemplate(size)
		else
			station:setTemplate(szt())
		end
	end
	--specialized code for particular stations
	local station_name = station:getCallSign()
	print("station name:",station_name)
	local chosen_goods = random(1,100)
	if station_name == "Grasberg" or station_name == "Impala" or station_name == "Outpost-15" or station_name == "Outpost-21" then
		print("asteroid blob")
		placeRandomAsteroidsAroundPoint(15,1,15000,x,y)
		if chosen_goods < 20 then
			station.comms_data.goods.gold = {quantity = 5, cost = 25}
			station.comms_data.goods.cobalt = {quantity = 4, cost = 50}
		elseif chosen_goods < 40 then
			station.comms_data.goods.gold = {quantity = 5, cost = 25}
		elseif chosen_goods < 60 then
			station.comms_data.goods.cobalt = {quantity = 4, cost = 50}
		else
			if station_name == "Grasberg" then
				station.comms_data.goods.nickel = {quantity = 5, cost = math.random(40,50)}
			elseif station_name == "Outpost-15" then
				station.comms_data.goods.platinum = {quantity = 5, cost = math.random(40,50)}
			elseif station_name == "Outpost-21" then
				station.comms_data.goods.dilithium = {quantity = 5, cost = math.random(40,50)}
			else	--Impala
				station.comms_data.goods.tritanium = {quantity = 5, cost = math.random(40,50)}
			end			
		end
	elseif station_name == "Jabba" or station_name == "Lando" or station_name == "Maverick" or station_name == "Okun" or station_name == "Outpost-8" or station_name == "Prada" or station_name == "Research-11" or station_name == "Research-19" or station_name == "Science-2" or station_name == "Science-4" or station_name == "Spot" or station_name == "Starnet" or station_name == "Tandon" then
		print("one of three goods")
		if chosen_goods < 33 then
			if station_name == "Jabba" then
				station.comms_data.goods.cobalt = {quantity = 5, cost = math.random(68,81)}
			elseif station_name == "Okun" or station_name == "Spot" then
				station.comms_data.goods.optic = {quantity = 5, cost = math.random(68,81)}
			elseif station_name == "Outpost-8" then
				station.comms_data.goods.impulse = {quantity = 5, cost = math.random(68,81)}
			elseif station_name == "Research-11" then
				station.comms_data.goods.warp = {quantity = 5, cost = math.random(68,81)}
			elseif station_name == "Research-19" then
				station.comms_data.goods.transporter = {quantity = 5, cost = math.random(68,81)}
			elseif station_name == "Science-2" or station_name == "Tandon" then
				station.comms_data.goods.autodoc = {quantity = 5, cost = math.random(68,81)}
			elseif station_name == "Science-4" then
				station.comms_data.goods.software = {quantity = 5, cost = math.random(68,81)}
			elseif station_name == "Starnet" then
				station.comms_data.goods.shield = {quantity = 5, cost = math.random(68,81)}
			else
				station.comms_data.goods.luxury = {quantity = 5, cost = math.random(68,81)}
			end
		elseif chosen_goods < 66 then
			if station_name == "Okun" then
				station.comms_data.goods.filament = {quantity = 5, cost = math.random(61,77)}
			elseif station_name == "Outpost-8" then
				station.comms_data.goods.tractor = {quantity = 5, cost = math.random(61,77)}
			elseif station_name == "Prada" then
				station.comms_data.goods.cobalt = {quantity = 5, cost = math.random(61,77)}
			elseif station_name == "Research-11" then
				station.comms_data.goods.repulsor = {quantity = 5, cost = math.random(61,77)}
			elseif station_name == "Research-19" or station_name == "Spot" then
				station.comms_data.goods.sensor = {quantity = 5, cost = math.random(61,77)}
			elseif station_name == "Science-2" or station_name == "Tandon" then
				station.comms_data.goods.android = {quantity = 5, cost = math.random(61,77)}
			elseif station_name == "Science-4" then
				station.comms_data.goods.circuit = {quantity = 5, cost = math.random(61,77)}
			elseif station_name == "Starnet" then
				station.comms_data.goods.lifter = {quantity = 5, cost = math.random(61,77)}
			else
				station.comms_data.goods.gold = {quantity = 5, cost = math.random(61,77)}
			end
		else
			if station_name == "Okun" then
				station.comms_data.goods.lifter = {quantity = 5, cost = math.random(61,77)}
			elseif station_name == "Outpost-8" or station_name == "Starnet" then
				station.comms_data.goods.beam = {quantity = 5, cost = math.random(61,77)}
			elseif station_name == "Prada" then
				station.comms_data.goods.dilithium = {quantity = 5, cost = math.random(61,77)}
			elseif station_name == "Research-11" then
				station.comms_data.goods.robotic = {quantity = 5, cost = math.random(61,77)}
			elseif station_name == "Research-19" then
				station.comms_data.goods.communication = {quantity = 5, cost = math.random(61,77)}
			elseif station_name == "Science-2" then
				station.comms_data.goods.nanites = {quantity = 5, cost = math.random(61,77)}
			elseif station_name == "Science-4" then
				station.comms_data.goods.battery = {quantity = 5, cost = math.random(61,77)}
			elseif station_name == "Spot" then
				station.comms_data.goods.software = {quantity = 5, cost = math.random(61,77)}
			elseif station_name == "Tandon" then
				station.comms_data.goods.robotic = {quantity = 5, cost = math.random(61,77)}
			else
				station.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,79)}
			end
		end
	elseif station_name == "Krak" or station_name == "Kruk" or station_name == "Krik" then
		print("one of three asteroid rivers")
		if chosen_goods < 10 then
			station.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,75)}
			station.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,55)}
			station.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
		elseif chosen_goods < 20 then
			station.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,75)}
			station.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,55)}
		elseif chosen_goods < 30 then
			station.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,75)}
			station.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
		elseif chosen_goods < 40 then
			station.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,55)}
			station.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
		elseif chosen_goods < 50 then
			station.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
		elseif chosen_goods < 60 then
			station.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,75)}
		elseif chosen_goods < 70 then
			station.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,55)}
		elseif chosen_goods < 80 then
			if station_name == "Krik" then
				station.comms_data.goods.cobalt = {quantity = 5, cost = math.random(55,65)}
			else
				station.comms_data.goods.gold = {quantity = 5, cost = math.random(45,55)}
				station.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,55)}
			end
		elseif chosen_goods < 90 then
			if station_name == "Krik" then
				station.comms_data.goods.cobalt = {quantity = 5, cost = math.random(55,65)}
				station.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
			else
				station.comms_data.goods.gold = {quantity = 5, cost = math.random(45,55)}
				station.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
			end
		else
			if station_name == "Krik" then
				station.comms_data.goods.cobalt = {quantity = 5, cost = math.random(55,65)}
				station.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
			else
				station.comms_data.goods.gold = {quantity = 5, cost = math.random(45,55)}
			end
		end
		local posAxisKrak = random(0,360)
		local posKrak = random(10000,60000)
		local negKrak = random(10000,60000)
		local spreadKrak = random(4000,7000)
		local negAxisKrak = posAxisKrak + 180
		local xPosAngleKrak, yPosAngleKrak = vectorFromAngle(posAxisKrak, posKrak)
		local posKrakEnd = random(30,70)
		local negKrakEnd = random(40,80)
		if station_name == "Krik" then
			posKrak = random(30000,80000)
			negKrak = random(20000,60000)
			spreadKrak = random(5000,8000)
			posKrakEnd = random(40,90)
			negKrakEnd = random(30,60)
		end
		createRandomAsteroidAlongArc(30+posKrakEnd, x+xPosAngleKrak, y+yPosAngleKrak, posKrak, negAxisKrak, negAxisKrak+posKrakEnd, spreadKrak)
		local xNegAngleKrak, yNegAngleKrak = vectorFromAngle(negAxisKrak, negKrak)
		createRandomAsteroidAlongArc(30+negKrakEnd, x+xNegAngleKrak, y+yNegAngleKrak, negKrak, posAxisKrak, posAxisKrak+negKrakEnd, spreadKrak)
	end
	if station_name == "Tokra" or station_name == "Cavor" then
		local what_trade = random(1,100)
		if what_trade < 33 then
			station.comms_data.trade.food = true
		elseif what_trade > 66 then
			station.comms_data.trade.medicine = true
		else
			station.comms_data.trade.luxury = true
		end
	end
	return station
end
function pickStation(name)
	if station_pool == nil then
		populateStationPool()
	end
	local selected_station_name = nil
	local station_selection_list = {}
	local selected_station = nil
	local station = nil
	if name == nil then
		--default to random in priority order
		for _, group in ipairs(station_priority) do
			if station_pool[group] ~= nil then
				for station, details in pairs(station_pool[group]) do
					table.insert(station_selection_list,station)
				end
				if #station_selection_list > 0 then
					if selected_station_name == nil then
						selected_station_name = station_selection_list[math.random(1,#station_selection_list)]
						station = SpaceStation():setCommsScript(""):setCommsFunction(commsStation):setCallSign(selected_station_name):setDescription(station_pool[group][selected_station_name].description)
						station.comms_data = station_pool[group][selected_station_name]
						station_pool[group][selected_station_name] = nil
						return group, station
					end
				end
			end
		end
	else
		if name == "Random" then
			--random across all groups
			for group, list in pairs(station_pool) do
				for station_name, station_details in pairs(list) do
					table.insert(station_selection_list,{group = group, station_name = station_name, station_details = station_details})
				end
			end
			if #station_selection_list > 0 then
				selected_station = station_selection_list[math.random(1,#station_selection_list)]
				station = SpaceStation():setCommsScript(""):setCommsFunction(commsStation):setCallSign(selected_station.station_name):setDescription(selected_station.station_details.description)
				station.comms_data = selected_station.station_details
				station_pool[selected_station.group][selected_station.station_name] = nil
				return selected_station.group, station
			end
		elseif name == "RandomHumanNeutral" then
			for group, list in pairs(station_pool) do
				if group ~= "Generic" and group ~= "Sinister" then
					for station_name, station_details in pairs(list) do
						table.insert(station_selection_list,{group = group, station_name = station_name, station_details = station_details})
					end
				end
			end
			if #station_selection_list > 0 then
				selected_station = station_selection_list[math.random(1,#station_selection_list)]
				station = SpaceStation():setCommsScript(""):setCommsFunction(commsStation):setCallSign(selected_station.station_name):setDescription(selected_station.station_details.description)
				station.comms_data = selected_station.station_details
				station_pool[selected_station.group][selected_station.station_name] = nil
				return selected_station.group, station
			end
		elseif name == "RandomGenericSinister" then
			for group, list in pairs(station_pool) do
				if group == "Generic" or group == "Sinister" then
					for station_name, station_details in pairs(list) do
						table.insert(station_selection_list,{group = group, station_name = station_name, station_details = station_details})
					end
				end
			end
			if #station_selection_list > 0 then
				selected_station = station_selection_list[math.random(1,#station_selection_list)]
				station = SpaceStation():setCommsScript(""):setCommsFunction(commsStation):setCallSign(selected_station.station_name):setDescription(selected_station.station_details.description)
				station.comms_data = selected_station.station_details
				station_pool[selected_station.group][selected_station.station_name] = nil
				return selected_station.group, station
			end
		else
			if station_pool[name] ~= nil then
				--name is a group name
				for station_name, station_details in pairs(station_pool[name]) do
					table.insert(station_selection_list,{station_name = station_name, station_details = station_details})
				end
				if #station_selection_list > 0 then
					selected_station = station_selection_list[math.random(1,#station_selection_list)]
					station = SpaceStation():setCommsScript(""):setCommsFunction(commsStation):setCallSign(selected_station.station_name):setDescription(selected_station.station_details.description)
					station.comms_data = selected_station.station_details
					station_pool[name][selected_station.station_name] = nil
					return name, station
				end
			else
				for group, list in pairs(station_pool) do
					if station_pool[group][name] ~= nil then
						station = SpaceStation():setCommsScript(""):setCommsFunction(commsStation):setCallSign(name):setDescription(station_pool[group][name].description)
						station.comms_data = station_pool[group][name]
						station_pool[group][name] = nil
						return group, station
					end
				end
				--name not found in any group
				print("Name provided not found in groups or stations, nor is it an accepted specialized name, like Random, RandomHumanNeutral or RandomGenericSinister")
				return nil
			end
		end
	end
	return nil
end
------- In game GM buttons to change the delay between waves -------
-- Default is normal, so the fist button switches from a normal delay to a slow delay.
-- The slow delay is used for typical mission testing when the tester does not wish to
-- spend all their time fighting off enemies.
-- The second button switches from slow to fast. This facilitates testing the enemy
-- spawning routines. The third button goes from fast to normal. 
function delayNormalToSlow()
	interWave = 600
	removeGMFunction(GMDelayNormalToSlow)
	addGMFunction("Delay slow to fast",delaySlowToFast)
end
function delaySlowToFast()
	interwave = 20
	removeGMFunction(GMDelaySlowToFast)
	addGMFunction("Delay fast to normal",delayFastToNormal)
end
function delayFastToNormal()
	interwave = default_interwave_interval
	removeGMFunction(GMDelayFastToNormal)
	addGMFunction("Delay normal to slow",delayNormalToSlow)
end
-- dynamic universe functions: asteroids and nebulae in motion
function setMovingNebulae()
	movingNebulae = {}
	local upperNeb = math.random(5,10)
	for nidx=1,upperNeb do
		local xNeb = random(-100000,100000)
		local yNeb = random(-100000,100000)
		local mNeb = Nebula():setPosition(xNeb, yNeb)
		mNeb.angle = random(0,360)
		mNeb.travel = random(1,100)
		table.insert(movingNebulae,mNeb)
	end
	plotN = moveNebulae
end
function moveNebulae(delta)
	for nidx=1,#movingNebulae do
		local mnx, mny = movingNebulae[nidx]:getPosition()
		if mnx ~= nil and mny ~= nil then
			local angleChange = false
			if mnx < -100000 then
				angleChange = true
				movingNebulae[nidx].angle = random(0,180) + 270
			end
			if mnx > 100000 then
				angleChange = true
				movingNebulae[nidx].angle = random(90,270)
			end
			if mny < -100000 then
				angleChange = true
				movingNebulae[nidx].angle = random(0,180)
			end
			if mny > 100000 then
				angleChange = true
				movingNebulae[nidx].angle = random(180,360)
			end
			local deltaNebx, deltaNeby = vectorFromAngle(movingNebulae[nidx].angle, movingNebulae[nidx].travel/10)
			if angleChange then
				deltaNebx, deltaNeby = vectorFromAngle(movingNebulae[nidx].angle, movingNebulae[nidx].travel/10+20)
				movingNebulae.travel = random(1,100)
			end
			movingNebulae[nidx]:setPosition(mnx+deltaNebx, mny+deltaNeby)
		end
	end
end
function setMovingAsteroids()
	movingAsteroidList = {}
	for aidx=1,30 do
		local xAst = random(-100000,100000)
		local yAst = random(-100000,100000)
		local outRange = true
		for p2idx=1,8 do
			local p2obj = getPlayerShip(p2idx)
			if p2obj ~= nil and p2obj:isValid() then
				if distance(p2obj,xAst,yAst) < 30000 then
					outRange = false
				end
			end
		end
		if outRange then
	        local asteroid_size = random(1,75) + random(1,50) + random(1,50) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20)
			local mAst = Asteroid():setPosition(xAst,yAst):setSize(asteroid_size)
			mAst.angle = random(0,360)
			mAst.travel = random(40,220)
			if random(1,100) < 50 then
				mAst.curve = 0
			else
				mAst.curve = math.random()*.16 - .08
			end
			table.insert(movingAsteroidList,mAst)
		end
	end
	plotA = moveAsteroids
end
function moveAsteroids(delta)
	local movingAsteroidCount = 0
	for aidx, aObj in ipairs(movingAsteroidList) do
		if aObj:isValid() then
			movingAsteroidCount = movingAsteroidCount + 1
			local mAstx, mAsty = aObj:getPosition()
			if mAstx < -150000 or mAstx > 150000 or mAsty < -150000 or mAsty > 150000 then
				aObj.angle = random(0,360)
				if random(1,100) < 50 then
					curve = 0
				else
					curve = math.random()*.08
				end
				if aObj.angle < 90 then
					aObj:setPosition(random(-150000,-100000),random(-150000,-100000))
					if aObj.angle < 45 then
						aObj.curve = curve
					else
						aObj.curve = -curve
					end
				elseif aObj.angle < 180 then
					aObj:setPosition(random(100000,150000),random(-150000,-100000))
					if aObj.angle < 135 then
						aObj.curve = curve
					else
						aObj.curve = -curve
					end
				elseif aObj.angle < 270 then
					aObj:setPosition(random(100000,150000),random(100000,150000))
					if aObj.angle < 225 then
						aObj.curve = curve
					else
						aObj.curve = -curve
					end
				else
					aObj:setPosition(random(-150000,-100000),random(100000,150000))
					if aObj.angle < 315 then
						aObj.curve = curve
					else
						aObj.curve = -curve
					end
				end
			else
				local deltaAstx, deltaAsty = vectorFromAngle(aObj.angle,aObj.travel)
				aObj:setPosition(mAstx+deltaAstx,mAsty+deltaAsty)
				aObj.angle = aObj.angle + aObj.curve
			end
		end
	end
	if movingAsteroidCount < 1 then
		setMovingAsteroids()
	end
end
-- Organically (simulated asymetrically) grow stations from a central grid location
-- Order of creation: friendlies, planet, neutrals, black hole, generic enemies, leading enemies
-- Statistically, the enemy stations typically end up on the edge, a fair distance away, but not always
function buildStations()
	gbLow = 1		--grid boundary low
	gbHigh = 500	--grid boundary high
	grid = {}		--grid - positional model
	for i=gbLow,gbHigh do
		grid[i] = {}
	end
	gx = gbHigh/2	--grid coordinate x
	gy = gbHigh/2	--grid coordinate y
	gp = 1			--grid position list index
	gSize = random(6000,8000)	--grid cell size in positional units
--	sPool = #placeStation		--starting station pool size (friendly and neutral)
	adjList = {}				--adjacent space on grid location list
	--place friendly stations
	stationFaction = "Human Navy"
	for j=1,12 do
		tSize = math.random(2,5)	--tack on to region size (3-6 since first is outside loop)
		grid[gx][gy] = gp			--set current grid location to grid position list index
		gRegion = {}				--grow region
		table.insert(gRegion,{gx,gy})
		for i=1,tSize do
			adjList = getAdjacentGridLocations(gx,gy)
			if #adjList < 1 then	--exit loop if there are no more adjacent spaces available
				break
			end
			rd = math.random(1,#adjList)	--random direction to grow from adjacent list
			grid[adjList[rd][1]][adjList[rd][2]] = gp
			table.insert(gRegion,{adjList[rd][1],adjList[rd][2]})
		end
		--get adjacent list after done growing region
		adjList = getAdjacentGridLocations(gx,gy)
		if #adjList < 1 then
			adjList = getAllAdjacentGridLocations(gx,gy)	
		else
			if random(1,5) >= 2 then
				adjList = getAllAdjacentGridLocations(gx,gy)
			end
		end
		sri = math.random(1,#gRegion)				--select station random region index
		psx = (gRegion[sri][1] - (gbHigh/2))*gSize + random(-gSize/2*.95,gSize/2*.95)	--place station x coordinate
		psy = (gRegion[sri][2] - (gbHigh/2))*gSize + random(-gSize/2*.95,gSize/2*.95)	--place station y coordinate
		pStation = placeStation(psx,psy,"RandomHumanNeutral","Human Navy")
		pStation.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,10) <= 9 then pStation.comms_data.goods.medicine = {quantity = math.random(5,10), cost = 5} end
--		si = math.random(1,#placeStation)			--station index
--		pStation = placeStation[si]()				--place selected station
--		table.remove(placeStation,si)				--remove station from placement list
		table.insert(stationList,pStation)			--save station in general station list
		table.insert(friendlyStationList,pStation)	--save station in friendly station list
		if j == 1 then								--identify first station as home station
			homeStation = pStation
		end
		if #gossipSnippets > 0 then
			if gp % 2 == 0 then
				ni = math.random(1,#gossipSnippets)
				pStation.gossip = gossipSnippets[ni]
				table.remove(gossipSnippets,ni)
			end
		end
		gp = gp + 1						--set next station number
		rn = math.random(1,#adjList)	--random next station start location
		gx = adjList[rn][1]
		gy = adjList[rn][2]
	end
	--insert a planet
	tSize = 7
	grid[gx][gy] = gp
	gRegion = {}
	table.insert(gRegion,{gx,gy})
	for i=1,tSize do
		adjList = getAdjacentGridLocations(gx,gy)
		if #adjList < 1 then
			break
		end
		rd = math.random(1,#adjList)
		grid[adjList[rd][1]][adjList[rd][2]] = gp
		table.insert(gRegion,{adjList[rd][1],adjList[rd][2]})
	end
	adjList = getAdjacentGridLocations(gx,gy)
	if #adjList < 1 then
		adjList = getAllAdjacentGridLocations(gx,gy)	
	else
		if random(1,5) >= 2 then
			adjList = getAllAdjacentGridLocations(gx,gy)
		end
	end
	sri = math.random(1,#gRegion)
	aldx = (gRegion[sri][1] - (gbHigh/2))*gSize
	aldy = (gRegion[sri][2] - (gbHigh/2))*gSize
	alderaan= Planet():setPosition(aldx,aldy):setPlanetRadius(3000):setDistanceFromMovementPlane(-2000):setCallSign("Alderaan")
	alderaan:setPlanetSurfaceTexture("planets/planet-1.png"):setPlanetCloudTexture("planets/clouds-1.png")
	alderaan:setPlanetAtmosphereTexture("planets/atmosphere.png"):setPlanetAtmosphereColor(0.2,0.2,1.0)
	alderaan:setAxialRotationTime(400.0):setDescription("Lush planet with only mild seasonal variations")
	stationAnet = SpaceStation():setTemplate("Small Station"):setFaction("Independent")
	stationAnet:setPosition(aldx,aldy+3000):setCallSign("ANet"):setDescription("Alderaan communications network hub")
	stationAnet.angle = 90
	gp = gp + 1
	rn = math.random(1,#adjList)
	gx = adjList[rn][1]
	gy = adjList[rn][2]
	--place independent stations
	stationFaction = "Independent"
	fb = gp	--set faction boundary (between friendly and neutral)
	for j=1,30 do
		tSize = math.random(2,5)	--tack on to region size
		grid[gx][gy] = gp
		gRegion = {}				--grow region
		table.insert(gRegion,{gx,gy})
		for i=1,tSize do
			adjList = getAdjacentGridLocations(gx,gy)
			if #adjList < 1 then
				break
			end
			rd = math.random(1,#adjList)	--random direction to grow from adjacent list
			grid[adjList[rd][1]][adjList[rd][2]] = gp
			table.insert(gRegion,{adjList[rd][1],adjList[rd][2]})
		end
		--get list after done growing region
		adjList = getAdjacentGridLocations(gx,gy)
		if #adjList < 1 then
			adjList = getFactionAdjacentGridLocations(gx,gy)	
			if #adjList < 1 then
				adjList = getAllAdjacentGridLocations(gx,gy)
			end
		else
			nextStationChoice = random(1,5)
			if nextStationChoice >= 3 then
				adjList = getFactionAdjacentGridLocations(gx,gy)
				if #adjList < 1 then
					adjList = getAllAdjacentGridLocations(gx,gy)
				end
			elseif nextStationChoice <= 2 then
				adjList = getAllAdjacentGridLocations(gx,gy)
			end
		end
		sri = math.random(1,#gRegion)				--select station random region index
		psx = (gRegion[sri][1] - (gbHigh/2))*gSize + random(-gSize/2*.95,gSize/2*.95)	--place station x coordinate
		psy = (gRegion[sri][2] - (gbHigh/2))*gSize + random(-gSize/2*.95,gSize/2*.95)	--place station y coordinate
		pStation = placeStation(psx,psy,"RandomHumanNeutral","Independent")
--		si = math.random(1,#placeStation)			--station index
--		pStation = placeStation[si]()
--		table.remove(placeStation,si)
		table.insert(stationList,pStation)
		gp = gp + 1						--set next station number
		rn = math.random(1,#adjList)	--random next station start location
		gx = adjList[rn][1]
		gy = adjList[rn][2]
	end
	--insert a black hole
	tSize = 7
	grid[gx][gy] = gp
	gRegion = {}
	table.insert(gRegion,{gx,gy})
	for i=1,tSize do
		adjList = getAdjacentGridLocations(gx,gy)
		if #adjList < 1 then
			break
		end
		rd = math.random(1,#adjList)
		grid[adjList[rd][1]][adjList[rd][2]] = gp
		table.insert(gRegion,{adjList[rd][1],adjList[rd][2]})
	end
	adjList = getAdjacentGridLocations(gx,gy)
	if #adjList < 1 then
		adjList = getAllAdjacentGridLocations(gx,gy)	
	else
		if random(1,5) >= 2 then
			adjList = getAllAdjacentGridLocations(gx,gy)
		end
	end
	sri = math.random(1,#gRegion)
	bhx = (gRegion[sri][1] - (gbHigh/2))*gSize
	bhy = (gRegion[sri][2] - (gbHigh/2))*gSize
	BlackHole():setPosition(bhx,bhy)
	gp = gp + 1
	rn = math.random(1,#adjList)
	gx = adjList[rn][1]
	gy = adjList[rn][2]
	--place enemy stations (from generic pool)
	stationFaction = "Kraylor"
	fb = gp	--set faction boundary (between neutral and enemy)
	for j=1,5 do
		tSize = math.random(3,6)	--tack on to region size
		grid[gx][gy] = gp
		gRegion = {}				--grow region
		table.insert(gRegion,{gx,gy})
		for i=1,tSize do
			adjList = getAdjacentGridLocations(gx,gy)
			if #adjList < 1 then
				break
			end
			rd = math.random(1,#adjList)	--random direction to grow from adjacent list
			grid[adjList[rd][1]][adjList[rd][2]] = gp
			table.insert(gRegion,{adjList[rd][1],adjList[rd][2]})
		end
		--get list after done growing region
		adjList = getAdjacentGridLocations(gx,gy)
		if #adjList < 1 then
			adjList = getFactionAdjacentGridLocations(gx,gy)	
			if #adjList < 1 then
				adjList = getAllAdjacentGridLocations(gx,gy)
			end
		else
			if random(1,5) >= 3 then
				adjList = getFactionAdjacentGridLocations(gx,gy)
				if #adjList < 1 then
					adjList = getAllAdjacentGridLocations(gx,gy)
				end
			end
		end
		sri = math.random(1,#gRegion)				--select station random region index
		psx = (gRegion[sri][1] - (gbHigh/2))*gSize + random(-gSize/2*.95,gSize/2*.95)	--place station x coordinate
		psy = (gRegion[sri][2] - (gbHigh/2))*gSize + random(-gSize/2*.95,gSize/2*.95)	--place station y coordinate
		pStation = placeStation(psx,psy,"RandomGenericSinister","Kraylor")
--		si = math.random(1,#placeGenericStation)			--station index
--		pStation = placeGenericStation[si]()
		if diagnostic then
			pStation:setCallSign(pStation:getCallSign() .. string.format(" %i",j))
		end
--		table.remove(placeGenericStation,si)
		table.insert(enemyStationList,pStation)
		gp = gp + 1						--set next station number
		rn = math.random(1,#adjList)	--random next station start location
		gx = adjList[rn][1]
		gy = adjList[rn][2]
	end
	--place enemy stations (from enemy pool)
	stationFaction = "Kraylor"
	fb = gp	--set faction boundary (between enemy and enemy leadership)
	for j=1,2 do
		tSize = math.random(4,6)	--tack on to region size
		grid[gx][gy] = gp
		gRegion = {}				--grow region
		table.insert(gRegion,{gx,gy})
		for i=1,tSize do
			adjList = getAdjacentGridLocations(gx,gy)
			if #adjList < 1 then
				break
			end
			rd = math.random(1,#adjList)	--random direction to grow from adjacent list
			grid[adjList[rd][1]][adjList[rd][2]] = gp
			table.insert(gRegion,{adjList[rd][1],adjList[rd][2]})
		end
		--get list after done growing region
		adjList = getAdjacentGridLocations(gx,gy)
		if #adjList < 1 then
			adjList = getFactionAdjacentGridLocations(gx,gy)	
			if #adjList < 1 then
				adjList = getAllAdjacentGridLocations(gx,gy)
			end
		else
			if random(1,5) >= 3 then
				adjList = getFactionAdjacentGridLocations(gx,gy)
				if #adjList < 1 then
					adjList = getAllAdjacentGridLocations(gx,gy)
				end
			end
		end
		sri = math.random(1,#gRegion)				--select station random region index
		psx = (gRegion[sri][1] - (gbHigh/2))*gSize + random(-gSize/2*.95,gSize/2*.95)	--place station x coordinate
		psy = (gRegion[sri][2] - (gbHigh/2))*gSize + random(-gSize/2*.95,gSize/2*.95)	--place station y coordinate
		pStation = placeStation(psx,psy,"Sinister","Kraylor")
--		si = math.random(1,#placeEnemyStation)			--station index
--		pStation = placeEnemyStation[si]()
--		table.remove(placeEnemyStation,si)
		table.insert(enemyStationList,pStation)
		if j == 2 then					--identify last placed enemy station as target enemy station
			targetEnemyStation = pStation
			if diagnostic then
				pStation:setCallSign(pStation:getCallSign() .. " Target")
			end
		end
		gp = gp + 1						--set next station number
		rn = math.random(1,#adjList)	--random next station start location
		gx = adjList[rn][1]
		gy = adjList[rn][2]
	end
	--show adjacent list with a bunch of small stations for testing result purposes
	--[[--
	if #adjList >= 1 then
		for i=1,#adjList do
			tsix = adjList[i][1]
			tsiy = adjList[i][2]
			tsx = (tsix - 250)*gSize
			tsy = (tsiy - 250)*gSize
			SpaceStation():setTemplate("Small Station"):setCallSign(string.format("%i i:%i x:%i y:%i",sPool,i,tsix,tsiy)):setPosition(tsx,tsy)
		end
	end
	--]]--
	if not diagnostic then
		placeRandomAroundPoint(Nebula,math.random(10,30),1,150000,0,0)
	end
	fx, fy = homeStation:getPosition()
	ex, ey = targetEnemyStation:getPosition()
	mnx = (fx+ex)/2
	mny = (fy+ey)/2
	Nebula():setPosition(mnx,mny)
	startingFriendlyStations = #friendlyStationList
	startingNeutralStations = #stationList - #friendlyStationList
	startingEnemyStations = #enemyStationList
	originalStationList = stationList	--save for statistics
end
function getFactionAdjacentGridLocations(lx,ly)
--adjacent empty grid locations around the grid locations of the currently building faction
	tempGrid = {}
	for i=gbLow,gbHigh do
		tempGrid[i] = {}
	end
	tempGrid[lx][ly] = 1
	ol = {}
	-- check left
	if lx-1 >= gbLow then
		if tempGrid[lx-1][ly] == nil then
			tempGrid[lx-1][ly] = 1
			if grid[lx-1][ly] == nil then
				table.insert(ol,{lx-1,ly})
			elseif grid[lx-1][ly] >= fb then
				--case 1: traveling left, skip right check
				getFactionAdjacentGridLocationsSkip(1,lx-1,ly)
			end
		end
	end
	--check up
	if ly-1 >= gbLow then
		if tempGrid[lx][ly-1] == nil then
			tempGrid[lx][ly-1] = 1
			if grid[lx][ly-1] == nil then
				table.insert(ol,{lx,ly-1})
			elseif grid[lx][ly-1] >= fb then		
				--case 2: traveling up, skip down check
				getFactionAdjacentGridLocationsSkip(2,lx,ly-1)
			end
		end
	end
	--check right
	if lx+1 <= gbHigh then
		if tempGrid[lx+1][ly] == nil then
			tempGrid[lx+1][ly] = 1
			if grid[lx+1][ly] == nil then
				table.insert(ol,{lx+1,ly})
			elseif grid[lx+1][ly] >= fb then
				--case 3: traveling right, skip left check
				getFactionAdjacentGridLocationsSkip(3,lx+1,ly)
			end
		end
	end
	--check down
	if ly+1 <= gbHigh then
		if tempGrid[lx][ly+1] == nil then
			tempGrid[lx][ly+1] = 1
			if grid[lx][ly+1] == nil then
				table.insert(ol,{lx,ly+1})
			elseif grid[lx][ly+1] >= fb then
				--case 4: traveling down, skip up check
				getFactionAdjacentGridLocationsSkip(4,lx,ly+1)
			end
		end
	end
	return ol
end
function getFactionAdjacentGridLocationsSkip(dSkip,lx,ly)
--adjacent empty grid locations around the grid locations of the currently building faction, skip check as requested
	tempGrid[lx][ly] = 1
	if dSkip ~= 3 then
		--check left
		if lx-1 >= gbLow then
			if tempGrid[lx-1][ly] == nil then
				tempGrid[lx-1][ly] = 1
				if grid[lx-1][ly] == nil then
					table.insert(ol,{lx-1,ly})
				elseif grid[lx-1][ly] >= fb then
					--case 1: traveling left, skip right check
					getFactionAdjacentGridLocationsSkip(1,lx-1,ly)
				end
			end
		end
	end
	if dSkip ~= 4 then
		--check up
		if ly-1 >= gbLow then
			if tempGrid[lx][ly-1] == nil then
				tempGrid[lx][ly-1] = 1
				if grid[lx][ly-1] == nil then
					table.insert(ol,{lx,ly-1})
				elseif grid[lx][ly-1] >= gp then
					--case 2: traveling up, skip down check
					getFactionAdjacentGridLocationsSkip(2,lx,ly-1)
				end
			end
		end
	end
	if dSkip ~= 1 then
		--check right
		if lx+1 <= gbHigh then
			if tempGrid[lx+1][ly] == nil then
				tempGrid[lx+1][ly] = 1
				if grid[lx+1][ly] == nil then
					table.insert(ol,{lx+1,ly})
				elseif grid[lx+1][ly] >= fb then
					--case 3: traveling right, skip left check
					getFactionAdjacentGridLocationsSkip(3,lx+1,ly)
				end
			end
		end
	end
	if dSkip ~= 2 then
		--check down
		if ly+1 <= gbHigh then
			if tempGrid[lx][ly+1] == nil then
				tempGrid[lx][ly+1] = 1
				if grid[lx][ly+1] == nil then
					table.insert(ol,{lx,ly+1})
				elseif grid[lx][ly+1] >= fb then
					--case 4: traveling down, skip up check
					getFactionAdjacentGridLocationsSkip(4,lx,ly+1)
				end
			end
		end
	end
end
function getAllAdjacentGridLocations(lx,ly)
--adjacent empty grid locations around all occupied locations
	tempGrid = {}
	for i=gbLow,gbHigh do
		tempGrid[i] = {}
	end
	tempGrid[lx][ly] = 1
	ol = {}
	-- check left
	if lx-1 >= gbLow then
		if tempGrid[lx-1][ly] == nil then
			tempGrid[lx-1][ly] = 1
			if grid[lx-1][ly] == nil then
				table.insert(ol,{lx-1,ly})
			else
				--case 1: traveling left, skip right check
				getAllAdjacentGridLocationsSkip(1,lx-1,ly)
			end
		end
	end
	--check up
	if ly-1 >= gbLow then
		if tempGrid[lx][ly-1] == nil then
			tempGrid[lx][ly-1] = 1
			if grid[lx][ly-1] == nil then
				table.insert(ol,{lx,ly-1})
			else		
				--case 2: traveling up, skip down check
				getAllAdjacentGridLocationsSkip(2,lx,ly-1)
			end
		end
	end
	--check right
	if lx+1 <= gbHigh then
		if tempGrid[lx+1][ly] == nil then
			tempGrid[lx+1][ly] = 1
			if grid[lx+1][ly] == nil then
				table.insert(ol,{lx+1,ly})
			else
				--case 3: traveling right, skip left check
				getAllAdjacentGridLocationsSkip(3,lx+1,ly)
			end
		end
	end
	--check down
	if ly+1 <= gbHigh then
		if tempGrid[lx][ly+1] == nil then
			tempGrid[lx][ly+1] = 1
			if grid[lx][ly+1] == nil then
				table.insert(ol,{lx,ly+1})
			else
				--case 4: traveling down, skip up check
				getAllAdjacentGridLocationsSkip(4,lx,ly+1)
			end
		end
	end
	return ol
end
function getAllAdjacentGridLocationsSkip(dSkip,lx,ly)
--adjacent empty grid locations around all occupied locations, skip as requested
	tempGrid[lx][ly] = 1
	if dSkip ~= 3 then
		--check left
		if lx-1 >= gbLow then
			if tempGrid[lx-1][ly] == nil then
				tempGrid[lx-1][ly] = 1
				if grid[lx-1][ly] == nil then
					table.insert(ol,{lx-1,ly})
				else
					--case 1: traveling left, skip right check
					getAllAdjacentGridLocationsSkip(1,lx-1,ly)
				end
			end
		end
	end
	if dSkip ~= 4 then
		--check up
		if ly-1 >= gbLow then
			if tempGrid[lx][ly-1] == nil then
				tempGrid[lx][ly-1] = 1
				if grid[lx][ly-1] == nil then
					table.insert(ol,{lx,ly-1})
				else
					--case 2: traveling up, skip down check
					getAllAdjacentGridLocationsSkip(2,lx,ly-1)
				end
			end
		end
	end
	if dSkip ~= 1 then
		--check right
		if lx+1 <= gbHigh then
			if tempGrid[lx+1][ly] == nil then
				tempGrid[lx+1][ly] = 1
				if grid[lx+1][ly] == nil then
					table.insert(ol,{lx+1,ly})
				else
					--case 3: traveling right, skip left check
					getAllAdjacentGridLocationsSkip(3,lx+1,ly)
				end
			end
		end
	end
	if dSkip ~= 2 then
		--check down
		if ly+1 <= gbHigh then
			if tempGrid[lx][ly+1] == nil then
				tempGrid[lx][ly+1] = 1
				if grid[lx][ly+1] == nil then
					table.insert(ol,{lx,ly+1})
				else
					--case 4: traveling down, skip up check
					getAllAdjacentGridLocationsSkip(4,lx,ly+1)
				end
			end
		end
	end
end
function getAdjacentGridLocations(lx,ly)
--adjacent empty grid locations around the most recently placed item
	tempGrid = {}
	for i=gbLow,gbHigh do
		tempGrid[i] = {}
	end
	tempGrid[lx][ly] = 1
	ol = {}
	-- check left
	if lx-1 >= gbLow then
		if tempGrid[lx-1][ly] == nil then
			tempGrid[lx-1][ly] = 1
			if grid[lx-1][ly] == nil then
				table.insert(ol,{lx-1,ly})
			elseif grid[lx-1][ly] == gp then
				--case 1: traveling left, skip right check
				getAdjacentGridLocationsSkip(1,lx-1,ly)
			end
		end
	end
	--check up
	if ly-1 >= gbLow then
		if tempGrid[lx][ly-1] == nil then
			tempGrid[lx][ly-1] = 1
			if grid[lx][ly-1] == nil then
				table.insert(ol,{lx,ly-1})
			elseif grid[lx][ly-1] == gp then		
				--case 2: traveling up, skip down check
				getAdjacentGridLocationsSkip(2,lx,ly-1)
			end
		end
	end
	--check right
	if lx+1 <= gbHigh then
		if tempGrid[lx+1][ly] == nil then
			tempGrid[lx+1][ly] = 1
			if grid[lx+1][ly] == nil then
				table.insert(ol,{lx+1,ly})
			elseif grid[lx+1][ly] == gp then
				--case 3: traveling right, skip left check
				getAdjacentGridLocationsSkip(3,lx+1,ly)
			end
		end
	end
	--check down
	if ly+1 <= gbHigh then
		if tempGrid[lx][ly+1] == nil then
			tempGrid[lx][ly+1] = 1
			if grid[lx][ly+1] == nil then
				table.insert(ol,{lx,ly+1})
			elseif grid[lx][ly+1] == gp then
				--case 4: traveling down, skip up check
				getAdjacentGridLocationsSkip(4,lx,ly+1)
			end
		end
	end
	return ol
end
function getAdjacentGridLocationsSkip(dSkip,lx,ly)
--adjacent empty grid locations around the most recently placed item, skip as requested
	tempGrid[lx][ly] = 1
	if dSkip ~= 3 then
		--check left
		if lx-1 >= gbLow then
			if tempGrid[lx-1][ly] == nil then
				tempGrid[lx-1][ly] = 1
				if grid[lx-1][ly] == nil then
					table.insert(ol,{lx-1,ly})
				elseif grid[lx-1][ly] == gp then
					--case 1: traveling left, skip right check
					getAdjacentGridLocationsSkip(1,lx-1,ly)
				end
			end
		end
	end
	if dSkip ~= 4 then
		--check up
		if ly-1 >= gbLow then
			if tempGrid[lx][ly-1] == nil then
				tempGrid[lx][ly-1] = 1
				if grid[lx][ly-1] == nil then
					table.insert(ol,{lx,ly-1})
				elseif grid[lx][ly-1] == gp then
					--case 2: traveling up, skip down check
					getAdjacentGridLocationsSkip(2,lx,ly-1)
				end
			end
		end
	end
	if dSkip ~= 1 then
		--check right
		if lx+1 <= gbHigh then
			if tempGrid[lx+1][ly] == nil then
				tempGrid[lx+1][ly] = 1
				if grid[lx+1][ly] == nil then
					table.insert(ol,{lx+1,ly})
				elseif grid[lx+1][ly] == gp then
					--case 3: traveling right, skip left check
					getAdjacentGridLocationsSkip(3,lx+1,ly)
				end
			end
		end
	end
	if dSkip ~= 2 then
		--check down
		if ly+1 <= gbHigh then
			if tempGrid[lx][ly+1] == nil then
				tempGrid[lx][ly+1] = 1
				if grid[lx][ly+1] == nil then
					table.insert(ol,{lx,ly+1})
				elseif grid[lx][ly+1] == gp then
					--case 4: traveling down, skip up check
					getAdjacentGridLocationsSkip(4,lx,ly+1)
				end
			end
		end
	end
end
function setListOfStations()
	--array of functions to facilitate randomized station placement (friendly and neutral)
	placeStation = {placeAlcaleica,			-- 1
					placeAnderson,			-- 2
					placeArcher,			-- 3
					placeArchimedes,		-- 4
					placeArmstrong,			-- 5
					placeAsimov,			-- 6
					placeBarclay,			-- 7
					placeBethesda,			-- 8
					placeBroeck,			-- 9
					placeCalifornia,		--10
					placeCalvin,			--11
					placeCavor,				--12
					placeChatuchak,			--13
					placeCoulomb,			--14
					placeCyrus,				--15
					placeDeckard,			--16
					placeDeer,				--17
					placeErickson,			--18
					placeEvondos,			--19
					placeFeynman,			--20
					placeGrasberg,			--21
					placeHayden,			--22
					placeHeyes,				--23
					placeHossam,			--24
					placeImpala,			--25
					placeKomov,				--26
					placeKrak,				--27
					placeKruk,				--28
					placeLipkin,			--29
					placeMadison,			--30
					placeMaiman,			--31
					placeMarconi,			--32
					placeMayo,				--33
					placeMiller,			--34
					placeMuddville,			--35
					placeNexus6,			--36
					placeOBrien,			--37
					placeOlympus,			--38
					placeOrgana,			--39
					placeOutpost15,			--40
					placeOutpost21,			--41
					placeOwen,				--42
					placePanduit,			--43
					placeRipley,			--44
					placeRutherford,		--45
					placeScience7,			--46
					placeShawyer,			--47
					placeShree,				--48
					placeSoong,				--49
					placeTiberius,			--50
					placeTokra,				--51
					placeToohie,			--52
					placeUtopiaPlanitia,	--53
					placeVactel,			--54
					placeVeloquan,			--55
					placeZefram}			--56
	--array of functions to facilitate randomized station placement (friendly, neutral or enemy)
	placeGenericStation = {placeJabba,		-- 1
					placeKrik,				-- 2
					placeLando,				-- 3
					placeMaverick,			-- 4
					placeNefatha,			-- 5
					placeOkun,				-- 6
					placeOutpost7,			-- 7
					placeOutpost8,			-- 8
					placeOutpost33,			-- 9
					placePrada,				--10
					placeResearch11,		--11
					placeResearch19,		--12
					placeRubis,				--13
					placeScience2,			--14
					placeScience4,			--15
					placeSkandar,			--16
					placeSpot,				--17
					placeStarnet,			--18
					placeTandon,			--19
					placeVaiken,			--20
					placeValero}			--21
	--array of functions to facilitate randomized station placement (enemy)
	placeEnemyStation = {placeAramanth,		-- 1
					placeEmpok,				-- 2
					placeGandala,			-- 3
					placeHassenstadt,		-- 4
					placeKaldor,			-- 5
					placeMagMesra,			-- 6
					placeMosEisley,			-- 7
					placeQuestaVerde,		-- 8
					placeRlyeh,				-- 9
					placeScarletCit,		--10
					placeStahlstadt,		--11
					placeTic}				--12
end
function szt()
--Randomly choose station size template
	stationSizeRandom = random(1,100)
	if stationSizeRandom <= 8 then
		sizeTemplate = "Huge Station"		-- 8 percent huge
	elseif stationSizeRandom <= 24 then
		sizeTemplate = "Large Station"		--16 percent large
	elseif stationSizeRandom <= 50 then
		sizeTemplate = "Medium Station"		--26 percent medium
	else
		sizeTemplate = "Small Station"		--50 percent small
	end
	return sizeTemplate
end
function randomMineral(exclude)
	local good = mineralGoods[math.random(1,#mineralGoods)]
	if exclude == nil then
		return good
	else
		repeat
			good = mineralGoods[math.random(1,#mineralGoods)]
		until(good ~= exclude)
		return good
	end
end
function randomComponent(exclude)
	local good = componentGoods[math.random(1,#componentGoods)]
	if exclude == nil then
		return good
	else
		repeat
			good = componentGoods[math.random(1,#componentGoods)]
		until(good ~= exclude)
		return good
	end
end
----------------------------------------------
--	Transport ship generation and handling  --
----------------------------------------------
function randomStation()
	stationCount = 0
	for sidx, obj in ipairs(stationList) do
		if obj:isValid() then
			stationCount = stationCount + 1
		else
			table.remove(stationList,sidx)
		end
	end
	sidx = math.floor(random(1, #stationList + 0.99))
	return stationList[sidx]
end

function nearStations(station, compareStationList)
	remainingStations = {}
	if compareStationList[1]:isValid() then
		if station:getCallSign() ~= compareStationList[1]:getCallSign() then
			closest = compareStationList[1]
		else
			if compareStationList[2]:isValid() then
				closest = compareStationList[2]
			end
		end
	end
	for ri, obj in ipairs(compareStationList) do
		if obj:isValid() then
			if station:getCallSign() ~= obj:getCallSign() then
				table.insert(remainingStations,obj)
				if distance(station,obj) < distance(station,closest) then
					closest = obj
				end
			end
		else
			table.remove(compareStationList,ri)
		end
	end
	for ri, obj in ipairs(remainingStations) do
		if obj:getCallSign() == closest:getCallSign() then
			table.remove(remainingStations,ri)
		end
	end
	return closest, remainingStations
end

function randomNearStation5(nobj)
	distanceStations = {}
	cs, rs1 = nearStations(nobj,stationList)
	table.insert(distanceStations,cs)
	cs, rs2 = nearStations(nobj,rs1)
	table.insert(distanceStations,cs)
	cs, rs3 = nearStations(nobj,rs2)
	table.insert(distanceStations,cs)
	cs, rs4 = nearStations(nobj,rs3)
	table.insert(distanceStations,cs)
	cs, rs5 = nearStations(nobj,rs4)
	table.insert(distanceStations,cs)
	return distanceStations[irandom(1,5)]
end

function transportPlot(delta)
	if transportSpawnDelay > 0 then
		transportSpawnDelay = transportSpawnDelay - delta
	end
	if transportSpawnDelay < 0 then
		transportSpawnDelay = delta + random(5,15) + missionLength
		transportCount = 0
		for tidx, obj in ipairs(transportList) do
			if obj:isValid() then
				if obj:isDocked(obj.target) then
					if obj.undock_delay > 0 then
						obj.undock_delay = obj.undock_delay - 1
					else
						obj.target = randomNearStation5(obj)
						obj.undock_delay = irandom(1,4)
						obj:orderDock(obj.target)
					end
				end
				transportCount = transportCount + 1
			end
		end
		lastTransportCount = transportCount
		if transportCount < #transportList then
			tempTransportList = {}
			for _, obj in ipairs(transportList) do
				if obj:isValid() then
					table.insert(tempTransportList,obj)
				end
			end
			transportList = tempTransportList
		end
		if #transportList < #stationList then
			repeat
				target = randomStation()				
			until(target ~= nil)
			rnd = irandom(1,5)
			if rnd == 1 then
				name = "Personnel"
			elseif rnd == 2 then
				name = "Goods"
			elseif rnd == 3 then
				name = "Garbage"
			elseif rnd == 4 then
				name = "Equipment"
			else
				name = "Fuel"
			end
			if irandom(1,100) < 30 then
				name = name .. " Jump Freighter " .. irandom(3, 5)
			else
				name = name .. " Freighter " .. irandom(1, 5)
			end
			obj = CpuShip():setTemplate(name):setFaction('Independent'):setCommsScript(""):setCommsFunction(commsShip)
			obj.target = target
			obj.undock_delay = irandom(1,4)
			rifl = math.floor(random(1,#goodsList))	-- random item from list
			goodsType = goodsList[rifl][1]
			if goodsType == nil then
				goodsType = "nickel"
			end
			rcoi = math.floor(random(30,90))	-- random cost of item
			goods[obj] = {{goodsType,1,rcoi}}
			obj:orderDock(obj.target)
			x, y = obj.target:getPosition()
			xd, yd = vectorFromAngle(random(0, 360), random(25000, 40000))
			obj:setPosition(x + xd, y + yd)
			table.insert(transportList, obj)
		end
	end
end
-----------------------------
--  Station communication  --
-----------------------------
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
            preorder = "friend"
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
    comms_data = comms_target.comms_data
	setPlayers()
    if comms_source:isEnemy(comms_target) then
        return false
    end
    if comms_target:areEnemiesInRange(5000) then
        setCommsMessage("We are under attack! No time for chatting!");
        return true
    end
    if not comms_source:isDocked(comms_target) then
        handleUndockedState()
    else
        handleDockedState()
    end
    return true
end
function handleDockedState()
    if comms_source:isFriendly(comms_target) then
		oMsg = "Good day, officer!\nWhat can we do for you today?\n"
    else
		oMsg = "Welcome to our lovely station.\n"
    end
    if comms_target:areEnemiesInRange(20000) then
		oMsg = oMsg .. "Forgive us if we seem a little distracted. We are carefully monitoring the enemies nearby."
	end
	setCommsMessage(oMsg)
	missilePresence = 0
	local missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
	for _, missile_type in ipairs(missile_types) do
		missilePresence = missilePresence + comms_source:getWeaponStorageMax(missile_type)
	end
	if missilePresence > 0 then
		if comms_target.nukeAvail == nil then
			if math.random(1,10) <= (4 - difficulty) then
				comms_target.nukeAvail = true
			else
				comms_target.nukeAvail = false
			end
			if math.random(1,10) <= (5 - difficulty) then
				comms_target.empAvail = true
			else
				comms_target.empAvail = false
			end
			if math.random(1,10) <= (6 - difficulty) then
				comms_target.homeAvail = true
			else
				comms_target.homeAvail = false
			end
			if math.random(1,10) <= (7 - difficulty) then
				comms_target.mineAvail = true
			else
				comms_target.mineAvail = false
			end
			if math.random(1,10) <= (9 - difficulty) then
				comms_target.hvliAvail = true
			else
				comms_target.hvliAvail = false
			end
		end
		if comms_target.nukeAvail or comms_target.empAvail or comms_target.homeAvail or comms_target.mineAvail or comms_target.hvliAvail then
			addCommsReply("I need ordnance restocked", function()
				setCommsMessage("What type of ordnance?")
				if comms_source:getWeaponStorageMax("Nuke") > 0 then
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
				if comms_source:getWeaponStorageMax("EMP") > 0 then
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
				if comms_source:getWeaponStorageMax("Homing") > 0 then
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
				if comms_source:getWeaponStorageMax("Mine") > 0 then
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
				if comms_source:getWeaponStorageMax("HVLI") > 0 then
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
	if comms_source:isFriendly(comms_target) then
		addCommsReply("What are my current orders?", function()
			setOptionalOrders()
			ordMsg = primaryOrders .. "\n" .. secondaryOrders .. optionalOrders
			if playWithTimeLimit then
				ordMsg = ordMsg .. string.format("\n   %i Minutes remain in game",math.floor(gameTimeLimit/60))
			end
			setCommsMessage(ordMsg)
			addCommsReply("Back", commsStation)
		end)
		if math.random(1,5) <= (3 - difficulty) then
			if comms_source:getRepairCrewCount() < comms_source.maxRepairCrew then
				hireCost = math.random(30,60)
			else
				hireCost = math.random(45,90)
			end
			addCommsReply(string.format("Recruit repair crew member for %i reputation",hireCost), function()
				if not comms_source:takeReputationPoints(hireCost) then
					setCommsMessage("Insufficient reputation")
				else
					comms_source:setRepairCrewCount(comms_source:getRepairCrewCount() + 1)
					setCommsMessage("Repair crew member hired")
				end
			end)
		end
		if comms_source.initialCoolant ~= nil then
			if math.random(1,5) <= (3 - difficulty) then
				local coolantCost = math.random(45,90)
				if comms_source:getMaxCoolant() < comms_source.initialCoolant then
					coolantCost = math.random(30,60)
				end
				addCommsReply(string.format("Purchase coolant for %i reputation",coolantCost), function()
					if not comms_source:takeReputationPoints(coolantCost) then
						setCommsMessage("Insufficient reputation")
					else
						comms_source:setMaxCoolant(comms_source:getMaxCoolant() + 2)
						setCommsMessage("Additional coolant purchased")
					end
					addCommsReply("Back", commsStation)
				end)
			end
		end
	else
		if math.random(1,5) <= (3 - difficulty) then
			if comms_source:getRepairCrewCount() < comms_source.maxRepairCrew then
				hireCost = math.random(45,90)
			else
				hireCost = math.random(60,120)
			end
			addCommsReply(string.format("Recruit repair crew member for %i reputation",hireCost), function()
				if not comms_source:takeReputationPoints(hireCost) then
					setCommsMessage("Insufficient reputation")
				else
					comms_source:setRepairCrewCount(comms_source:getRepairCrewCount() + 1)
					setCommsMessage("Repair crew member hired")
				end
				addCommsReply("Back", commsStation)
			end)
		end
	end
	if comms_target == homeStation then
		if homeStation.telemetry == nil then
			if math.random(1,10) <= (5 - difficulty) then
				addCommsReply(string.format("Establish defensive system telemetry (%i rep)",difficulty*10), function()
					if comms_source:takeReputationPoints(difficulty*10) then
						setCommsMessage(string.format("Defensive telemetry established with station %s.\nDamage should show on Relay when it occurs",homeStation:getCallSign()))
						homeStation.telemetry = true
					else
						setCommsMessage("Insufficient reputation")
					end
					addCommsReply("Back", commsStation)
				end)
			end
		end
		if homeDelivery then
			if plot2name == "easyDelivery" or plot4name == "randomDelivery" then
				local easyCargoAboard = false
				local randomCargoAboard = false
				if comms_source.goods ~= nil and comms_source.goods[easyDeliverGood] ~= nil and comms_source.goods[easyDeliverGood] > 0 then
					easyCargoAboard = true
				end
				if comms_source.goods ~= nil and comms_source.goods[randomDeliverGood] ~= nil and comms_source.goods[randomDeliverGood] > 0 then
					randomCargoAboard = true
				end
				if easyCargoAboard or randomCargoAboard then
					addCommsReply("Provide cargo", function()
						setCommsMessage("Do you have something for us?")
						if easyCargoAboard then
							homeStationEasyDelivery()					
						end
						if randomCargoAboard then
							homeStationRandomDelivery()
						end
					end)
				end
			end
		end
		if infoPromised then
			if spinUpgradeAvailable or beamTimeUpgradeAvailable or rotateUpgradeAvailable or baseIntelligenceAvailable or hullUpgradeAvailable then
				addCommsReply("Request promised information", function()
					setCommsMessage("Remind me what information I promised")
					if spinUpgradeAvailable then
						homeStationSpinUpgrade()
					end
					if beamTimeUpgradeAvailable then
						homeStationBeamTimeUpgrade()
					end
					if rotateUpgradeAvailable then
						homeStationRotateUpgrade()
					end
					if baseIntelligenceAvailable then
						homeStationBaseIntelligence()
					end
					if hullUpgradeAvailable then
						homeStationHullUpgrade()
					end
					addCommsReply("Back", commsStation)
				end)
			end
		end
	end
	if comms_target == spinBase then
		spinStation()
	end
	if comms_target == beamTimeBase then
		beamTimeStation()
	end
	if comms_target == rotateBase then
		rotateStation()
	end
	if comms_target == baseInt1 then
		intelligenceStation()
	end
	if comms_target == baseInt2 then
		secondIntelligenceStation()
	end
	if comms_target == hullBase then
		hullStation()
	end
	if comms_target == shieldExpertStation then
		shieldExpertBase()
	end
	if comms_target.comms_data.public_relations then
		addCommsReply("Tell me more about your station", function()
			setCommsMessage("What would you like to know?")
			addCommsReply("General information", function()
				setCommsMessage(comms_target.comms_data.general_information)
				addCommsReply("Back", commsStation)
			end)
			if comms_target.comms_data.history ~= nil then
				addCommsReply("Station history", function()
					setCommsMessage(comms_target.comms_data.history)
					addCommsReply("Back", commsStation)
				end)
			end
			if comms_source:isFriendly(comms_target) then
				if comms_target.comms_data.gossip ~= nil then
					if random(1,100) < 50 then
						addCommsReply("Gossip", function()
							setCommsMessage(comms_target.comms_data.gossip)
							addCommsReply("Back", commsStation)
						end)
					end
				end
			end
		end)
	end
	local goodCount = 0
	for good, goodData in pairs(comms_target.comms_data.goods) do
		goodCount = goodCount + 1
	end
	if goodCount > 0 then
		addCommsReply("Buy, sell, trade", function()
			local goodsReport = string.format("Station %s:\nGoods or components available for sale: quantity, cost in reputation\n",comms_target:getCallSign())
			for good, goodData in pairs(comms_target.comms_data.goods) do
				goodsReport = goodsReport .. string.format("     %s: %i, %i\n",good,goodData["quantity"],goodData["cost"])
			end
			if comms_target.comms_data.buy ~= nil then
				goodsReport = goodsReport .. "Goods or components station will buy: price in reputation\n"
				for good, price in pairs(comms_target.comms_data.buy) do
					goodsReport = goodsReport .. string.format("     %s: %i\n",good,price)
				end
			end
			goodsReport = goodsReport .. string.format("Current cargo aboard %s:\n",comms_source:getCallSign())
			local cargoHoldEmpty = true
			local player_good_count = 0
			if comms_source.goods ~= nil then
				for good, goodQuantity in pairs(comms_source.goods) do
					player_good_count = player_good_count + 1
					goodsReport = goodsReport .. string.format("     %s: %i\n",good,goodQuantity)
				end
			end
			if player_good_count < 1 then
				goodsReport = goodsReport .. "     Empty\n"
			end
			goodsReport = goodsReport .. string.format("Available Space: %i, Available Reputation: %i\n",comms_source.cargo,math.floor(comms_source:getReputationPoints()))
			setCommsMessage(goodsReport)
			for good, goodData in pairs(comms_target.comms_data.goods) do
				addCommsReply(string.format("Buy one %s for %i reputation",good,goodData["cost"]), function()
					local goodTransactionMessage = string.format("Type: %s, Quantity: %i, Rep: %i",good,goodData["quantity"],goodData["cost"])
					if comms_source.cargo < 1 then
						goodTransactionMessage = goodTransactionMessage .. "\nInsufficient cargo space for purchase"
					elseif goodData["cost"] > math.floor(comms_source:getReputationPoints()) then
						goodTransactionMessage = goodTransactionMessage .. "\nInsufficient reputation for purchase"
					elseif goodData["quantity"] < 1 then
						goodTransactionMessage = goodTransactionMessage .. "\nInsufficient station inventory"
					else
						if comms_source:takeReputationPoints(goodData["cost"]) then
							comms_source.cargo = comms_source.cargo - 1
							goodData["quantity"] = goodData["quantity"] - 1
							if comms_source.goods == nil then
								comms_source.goods = {}
							end
							if comms_source.goods[good] == nil then
								comms_source.goods[good] = 0
							end
							comms_source.goods[good] = comms_source.goods[good] + 1
							goodTransactionMessage = goodTransactionMessage .. "\npurchased"
						else
							goodTransactionMessage = goodTransactionMessage .. "\nInsufficient reputation for purchase"
						end
					end
					setCommsMessage(goodTransactionMessage)
					addCommsReply("Back", commsStation)
				end)
			end
			if comms_target.comms_data.buy ~= nil then
				for good, price in pairs(comms_target.comms_data.buy) do
					if comms_source.goods ~= nil and comms_source.goods[good] ~= nil and comms_source.goods[good] > 0 then
						addCommsReply(string.format("Sell one %s for %i reputation",good,price), function()
							local goodTransactionMessage = string.format("Type: %s,  Reputation price: %i",good,price)
							comms_source.goods[good] = comms_source.goods[good] - 1
							comms_source:addReputationPoints(price)
							goodTransactionMessage = goodTransactionMessage .. "\nOne sold"
							comms_source.cargo = comms_source.cargo + 1
							setCommsMessage(goodTransactionMessage)
							addCommsReply("Back", commsStation)
						end)
					end
				end
			end
			if comms_target.comms_data.trade ~= nil and
				comms_target.comms_data.trade.food ~= nil and
				comms_target.comms_data.trade.food and 
				comms_source.goods ~= nil and 
				comms_source.goods.food ~= nil and 
				comms_source.goods.food > 0 then
				for good, goodData in pairs(comms_target.comms_data.goods) do
					addCommsReply(string.format("Trade food for %s",good), function()
						local goodTransactionMessage = string.format("Type: %s,  Quantity: %i",good,goodData["quantity"])
						if goodData["quantity"] < 1 then
							goodTransactionMessage = goodTransactionMessage .. "\nInsufficient station inventory"
						else
							goodData["quantity"] = goodData["quantity"] - 1
							if comms_source.goods == nil then
								comms_source.goods = {}
							end
							if comms_source.goods[good] == nil then
								comms_source.goods[good] = 0
							end
							comms_source.goods[good] = comms_source.goods[good] + 1
							comms_source.goods["food"] = comms_source.goods["food"] - 1
							goodTransactionMessage = goodTransactionMessage .. "\nTraded"
						end
						setCommsMessage(goodTransactionMessage)
						addCommsReply("Back", commsStation)
					end)
				end
			end
			if comms_target.comms_data.trade ~= nil and 
				comms_target.comms_data.trade.medicine ~= nil and 
				comms_target.comms_data.trade.medicine and 
				comms_source.goods ~= nil and 
				comms_source.goods.medicine ~= nil and 
				comms_source.goods.medicine > 0 then
				for good, goodData in pairs(comms_target.comms_data.goods) do
					addCommsReply(string.format("Trade medicine for %s",good), function()
						local goodTransactionMessage = string.format("Type: %s,  Quantity: %i",good,goodData["quantity"])
						if goodData["quantity"] < 1 then
							goodTransactionMessage = goodTransactionMessage .. "\nInsufficient station inventory"
						else
							goodData["quantity"] = goodData["quantity"] - 1
							if comms_source.goods == nil then
								comms_source.goods = {}
							end
							if comms_source.goods[good] == nil then
								comms_source.goods[good] = 0
							end
							comms_source.goods[good] = comms_source.goods[good] + 1
							comms_source.goods["medicine"] = comms_source.goods["medicine"] - 1
							goodTransactionMessage = goodTransactionMessage .. "\nTraded"
						end
						setCommsMessage(goodTransactionMessage)
						addCommsReply("Back", commsStation)
					end)
				end
			end
			if comms_target.comms_data.trade ~= nil and
				comms_target.comms_data.trade.luxury ~= nil and
				comms_target.comms_data.trade.luxury and 
				comms_source.goods ~= nil and 
				comms_source.goods.luxury ~= nil and 
				comms_source.goods.luxury > 0 then
				for good, goodData in pairs(comms_target.comms_data.goods) do
					addCommsReply(string.format("Trade luxury for %s",good), function()
						local goodTransactionMessage = string.format("Type: %s,  Quantity: %i",good,goodData["quantity"])
						if goodData[quantity] < 1 then
							goodTransactionMessage = goodTransactionMessage .. "\nInsufficient station inventory"
						else
							goodData["quantity"] = goodData["quantity"] - 1
							if comms_source.goods == nil then
								comms_source.goods = {}
							end
							if comms_source.goods[good] == nil then
								comms_source.goods[good] = 0
							end
							comms_source.goods[good] = comms_source.goods[good] + 1
							comms_source.goods["luxury"] = comms_source.goods["luxury"] - 1
							goodTransactionMessage = goodTransactionMessage .. "\nTraded"
						end
						setCommsMessage(goodTransactionMessage)
						addCommsReply("Back", commsStation)
					end)
				end
			end
			addCommsReply("Back", commsStation)
		end)
		local player_good_count = 0
		if comms_source.goods ~= nil then
			for good, goodQuantity in pairs(comms_source.goods) do
				player_good_count = player_good_count + 1
			end
		end
		if player_good_count > 0 then
			addCommsReply("Jettison cargo", function()
				setCommsMessage(string.format("Available space: %i\nWhat would you like to jettison?",comms_source.cargo))
				for good, good_quantity in pairs(comms_source.goods) do
					if good_quantity > 0 then
						addCommsReply(good, function()
							comms_source.goods[good] = comms_source.goods[good] - 1
							comms_source.cargo = comms_source.cargo + 1
							setCommsMessage(string.format("One %s jettisoned",good))
							addCommsReply("Back", commsStation)
						end)
					end
				end
				addCommsReply("Back", commsStation)
			end)
		end
		addCommsReply("No tutorial covered goods or cargo. Explain", function()
			setCommsMessage("Different types of cargo or goods may be obtained from stations, freighters or other sources. They go by one word descriptions such as dilithium, optic, warp, etc. Certain mission goals may require a particular type or types of cargo. Each player ship differs in cargo carrying capacity. Goods may be obtained by spending reputation points or by trading other types of cargo (typically food, medicine or luxury)")
			addCommsReply("Back", commsStation)
		end)
	end
end
function homeStationEasyDelivery()
	addCommsReply(string.format("Provide %s as requested",easyDeliverGood), function()
		comms_source.goods[easyDeliverGood] = comms_source.goods[easyDeliverGood] - 1
		comms_source.cargo = comms_source.cargo + 1
		comms_source:addReputationPoints(30)
		setCommsMessage("Thanks, we really needed that.\n\nI have some information for you. Decide which one you want")
		addCommsReply("Ship maneuver upgrade", function()
			plot2 = spinUpgradeStart
			setCommsMessage("Check back shortly and I'll tell you all about it")
		end)
		addCommsReply("Intelligence", function()
			plot2 = enemyBaseInfoStart
			setCommsMessage("Check back shortly and I'll tell you all about it")
		end)
	end)
end

function homeStationRandomDelivery()
	addCommsReply(string.format("Give %s as requested",randomDeliverGood), function()
		comms_source.goods[randomDeliverGood] = comms_source.goods[randomDeliverGood] - 1
		comms_source.cargo = comms_source.cargo + 1
		comms_source:addReputationPoints(35)
		setCommsMessage(string.format("Thanks, we needed that %s.\n\nI have information for you. Decide which one you want",randomDeliverGood))
		addCommsReply(string.format("Upgrade %s to auto-rotate",homeStation:getCallSign()), function()
			plot4 = rotateUpgradeStart
			setCommsMessage("Check back in a bit and I'll tell you all about it")
		end)
		addCommsReply("Upgrade beam weapon cycle time", function()
			plot4 = beamTimeUpgradeStart
			setCommsMessage("Check back in a bit and I'll tell you all about it")
		end)
		addCommsReply("Upgrade hull damage capacity", function()
			plot4 = hullUpgradeStart
			setCommsMessage("Check back in a bit and I'll tell you all about it")
		end)
	end)
end

function homeStationSpinUpgrade()
	addCommsReply("What about that maneuver upgrade information you promised?", function()
		setCommsMessage(string.format("I hear %s can upgrade your maneuverability, but they need %s to do the job",spinBase:getCallSign(),spinGood))
		if spinReveal < 1 then spinReveal = 1 end
		addCommsReply(string.format("Where is %s?",spinBase:getCallSign()), function()
			setCommsMessage(string.format("%s is in sector %s",spinBase:getCallSign(),spinBase:getSectorName()))
			if spinReveal < 2 then spinReveal = 2 end
			addCommsReply("Back", commsStation)
		end)
		addCommsReply(string.format("Where might I find some %s?",spinGood), function()
			setCommsMessage(string.format("I think %s might have some",spinGoodBase:getCallSign()))
			if spinReveal < 3 then spinReveal = 3 end
			if difficulty < 2 then
				addCommsReply(string.format("And where the heck is %s?",spinGoodBase:getCallSign()), function()
					setCommsMessage(string.format("My, my, you're quite inquisitive.\n%s is in sector %s",spinGoodBase:getCallSign(),spinGoodBase:getSectorName()))
					if spinReveal < 4 then spinReveal = 4 end
					addCommsReply("Back", commsStation)
				end)
			end
			addCommsReply("Back", commsStation)
		end)
		addCommsReply("Back", commsStation)
	end)
end

function homeStationBeamTimeUpgrade()
	addCommsReply("You mentioned a beam weapon cycle time upgrade...", function()
		setCommsMessage(string.format("Station %s can do that for %s",beamTimeBase:getCallSign(),beamTimeGood))
		if beamTimeReveal < 1 then beamTimeReveal = 1 end
		addCommsReply(string.format("I've never heard of %s. Where is %s?",beamTimeBase:getCallSign(),beamTimeBase:getCallSign()), function()
			setCommsMessage(string.format("You haven't? I'm surprised. %s is in %s",beamTimeBase:getCallSign(),beamTimeBase:getSectorName()))
			if beamTimeReveal < 2 then beamTimeReveal = 2 end
			addCommsReply("Back", commsStation)
		end)
		addCommsReply(string.format("Can you direct me to a station with %s?",beamTimeGood), function()
			setCommsMessage(string.format("%s has %s *and* they have the best indigenous Kraylor honey you've ever tasted",beamTimeGoodBase:getCallSign(),beamTimeGood))
			if beamTimeReveal < 3 then beamTimeReveal = 3 end
			if difficulty < 2 then
				addCommsReply(string.format("Sounds tasty. Where is %s?",beamTimeGoodBase:getCallSign()), function()
					setCommsMessage(string.format("It's in %s",beamTimeGoodBase:getSectorName()))
					if beamTimeReveal < 4 then beamTimeReveal = 4 end
					addCommsReply("Back", commsStation)
				end)
			end
			addCommsReply("Back", commsStation)
		end)
		addCommsReply("Back", commsStation)
	end)
end

function homeStationRotateUpgrade()
	addCommsReply("Where's that station rotation upgrade information?", function()
		setCommsMessage(string.format("station %s has the technical knowledge but lacks the %s",rotateBase:getCallSign(),rotateGood))
		if rotateReveal < 1 then rotateReveal = 1 end
		addCommsReply(string.format("Where is station %s?",rotateBase:getCallSign()), function()
			setCommsMessage(string.format("%s is in %s",rotateBase:getCallSign(),rotateBase:getSectorName()))
			if rotateReveal < 2 then rotateReveal = 2 end
			addCommsReply("Back", commsStation)
		end)
		if difficulty < 2 then
			addCommsReply(string.format("Where could I get %s?",rotateGood), function()
				setCommsMessage(string.format("%s should have %s",rotateGoodBase:getCallSign(),rotateGood))
				if rotateReveal < 3 then rotateReveal = 3 end
				if difficulty < 1 then
					addCommsReply(string.format("Do you know where %s is located?",rotateGoodBase:getCallSign()), function()
						setCommsMessage(string.format("Yes, it's in %s",rotateGoodBase:getSectorName()))
						if rotateReveal < 4 then rotateReveal = 4 end
						addCommsReply("Back", commsStation)
					end)
				end
				addCommsReply("Back", commsStation)
			end)
		end
		addCommsReply("Back", commsStation)
	end)
end

function homeStationBaseIntelligence()
	addCommsReply("What about that intelligence information you promised?", function()
		setCommsMessage(string.format("I hear Marcy Sorenson just got back from an enemy scouting expedition. She was talking about enemy bases. She can probably tell you where some of these bases are located. She's based on %s",baseInt1:getCallSign()))
		plot2reminder = string.format("Talk with Marcy Sorenson on %s",baseInt1:getCallSign())
		addCommsReply("Back", commsStation)
	end)
end

function homeStationHullUpgrade()
	addCommsReply("Remember, you promised some ship hull upgrade information?", function()
		setCommsMessage(string.format("Oh yes, %s can upgrade your hull, but they want %s to do the job",hullBase:getCallSign(),hullGood))
		if hullReveal < 1 then hullReveal = 1 end
		addCommsReply(string.format("So, where is %s?",hullBase:getCallSign()), function()
			setCommsMessage(string.format("%s is in sector %s",hullBase:getCallSign(),hullBase:getSectorName()))
			if hullReveal < 2 then hullReveal = 2 end
			addCommsReply("Back", commsStation)
		end)
		addCommsReply(string.format("Where could I find some %s?",hullGood), function()
			setCommsMessage(string.format("I think %s may have some",hullGoodBase:getCallSign()))
			if hullReveal < 3 then hullReveal = 3 end
			if difficulty < 2 then
				addCommsReply(string.format("And just where is %s?",hullGoodBase:getCallSign()), function()
					setCommsMessage(string.format("If you must know, %s is in sector %s",hullGoodBase:getCallSign(),hullGoodBase:getSectorName()))
					if hullReveal < 4 then hullReveal = 4 end
					addCommsReply("Back", commsStation)
				end)
			end
			addCommsReply("Back", commsStation)
		end)
		addCommsReply("Back", commsStation)
	end)
end

function spinStation()
	if spinUpgradeAvailable then
		if not comms_source.spinUpgrade then
			addCommsReply("Upgrade maneuverability", function()
				local spinUpgradePartQuantity = 0
				if comms_source.goods ~= nil and comms_source.goods[spinGood] ~= nil and comms_source.goods[spinGood] > 0 then
					spinUpgradePartQuantity = comms_source.goods[spinGood]
				end
				if spinUpgradePartQuantity > 0 then
					comms_source.spinUpgrade = true
					comms_source.goods[spinGood] = comms_source.goods[spinGood] - 1
					comms_source.cargo = comms_source.cargo + 1
					comms_source:setRotationMaxSpeed(comms_source:getRotationMaxSpeed()*1.5)
					setCommsMessage("Upgraded maneuverability")
				else
					setCommsMessage(string.format("You need to bring some %s for the upgrade",spinGood))
				end
				addCommsReply("Back", commsStation)
			end)
		end
	end
end

function beamTimeStation()
	if beamTimeUpgradeAvailable then
		if not comms_source.beamTimeUpgrade then
			addCommsReply("Upgrade beam cycle time", function()
				if comms_source:getBeamWeaponRange(0) < 1 then
					setCommsMessage("Your ship type does not support a beam weapon upgrade.")
				else
					local beamTimeUpgradePartQuantity = 0
					if comms_source.goods ~= nil and comms_source.goods[beamTimeGood] ~= nil and comms_source.goods[beamTimeGood] > 0 then
						beamTimeUpgradePartQuantity = comms_source.goods[beamTimeGood]
					end
					if beamTimeUpgradePartQuantity > 0 then
						comms_source.beamTimeUpgrade = true
						comms_source.goods[beamTimeGood] = comms_source.goods[beamTimeGood] - 1
						comms_source.cargo = comms_source.cargo + 1
						local bi = 0
						repeat
							local tempArc = comms_source:getBeamWeaponArc(bi)
							local tempDir = comms_source:getBeamWeaponDirection(bi)
							local tempRng = comms_source:getBeamWeaponRange(bi)
							local tempCyc = comms_source:getBeamWeaponCycleTime(bi)
							local tempDmg = comms_source:getBeamWeaponDamage(bi)
							comms_source:setBeamWeapon(bi,tempArc,tempDir,tempRng,tempCyc * .8,tempDmg)
							bi = bi + 1
						until(comms_source:getBeamWeaponRange(bi) < 1)
						setCommsMessage("Beam cycle time reduced by 20%")
					else
						setCommsMessage(string.format("We require %s before we can upgrade your beam weapons",beamTimeGood))
					end
				end
			end)
		end
	end
end

function rotateStation()
	if rotateUpgradeAvailable then
		if not homeStationRotationEnabled then
			addCommsReply(string.format("Upgrade %s to auto-rotate",homeStation:getCallSign()), function()
				local rotateUpgradePartQuantity = 0
				if comms_source.goods ~= nil and comms_source.goods[rotateGood] ~= nil and comms_source.goods[rotateGood] > 0 then
					rotateUpgradePartQuantity = comms_source.goods[rotateGood]
				end
				if rotateUpgradePartQuantity > 0 then
					homeStationRotationEnabled = true
					comms_source.goods[rotateGood] = comms_source.goods[rotateGood] - 1
					comms_source.cargo = comms_source.cargo + 1
					setCommsMessage(string.format("%s was just what we needed. The technical details have been transmitted to %s. The auto-rotation has begun",rotateGood,homeStation:getCallSign()))
				else
					setCommsMessage(string.format("You need to bring some %s for the upgrade",rotateGood))
				end
				addCommsReply("Back", commsStation)
			end)
		end
	end
end

function intelligenceStation()
	addCommsReply("May I speak with Marcy Sorenson?", function()
		baseInt1Visit = true
		if baseInt2 ~= nil then
			setCommsMessage(string.format("She transferred to %s",baseInt2:getCallSign()))
			plot2reminder = string.format("Talk with Marcy Sorenson on %s",baseInt2:getCallSign())
			addCommsReply(string.format("Where exactly is %s?",baseInt2:getCallSign()), function()
				setCommsMessage(string.format("%s is in %s",baseInt2:getCallSign(),baseInt2:getSectorName()))
				plot2reminder = string.format("Talk with Marcy Sorenson on %s in %s",baseInt2:getCallSign(),baseInt2:getSectorName())
				addCommsReply("Back", commsStation)
			end)
			addCommsReply("Back", commsStation)
		else
			setCommsMessage("This is Marcy. Whatcha want?")
			addCommsReply("Please tell me about the enemy bases found", function()
				for i=1,#enemyStationList do
					if enemyStationList[i]:isValid() then
						if enemyInt1 == nil then
							enemyInt1 = enemyStationList[i]
						elseif enemyInt2 == nil then
							enemyInt2 = enemyStationList[i]
							break
						end
					end
				end
				setCommsMessage(string.format("Sure. We found a couple of enemy stations in %s and %s",enemyInt1:getSectorName(),enemyInt2:getSectorName()))
				plot2reminder = string.format("Investigate enemy bases in %s and %s",enemyInt1:getSectorName(),enemyInt2:getSectorName())
				addCommsReply("Back", commsStation)
			end)
			addCommsReply("Back", commsStation)
		end
	end)
end

function secondIntelligenceStation()
	if baseInt1Visit then
		addCommsReply("May I speak with Marcy Sorenson, please?", function()
			setCommsMessage("This is Marcy. Whatcha want?")
			addCommsReply("Please tell me about the enemy bases found", function()
				for i=1,#enemyStationList do
					if enemyStationList[i]:isValid() then
						if enemyInt1 == nil then
							enemyInt1 = enemyStationList[i]
						elseif enemyInt2 == nil then
							enemyInt2 = enemyStationList[i]
						elseif enemyInt3 == nil then
							enemyInt3 = enemyStationList[i]
						end
					end
				end
				setCommsMessage(string.format("Sure. We found some enemy stations in %s, %s and %s",enemyInt1:getSectorName(),enemyInt2:getSectorName(),enemyInt3:getSectorName()))
				plot2reminder = string.format("Investigate enemy bases in %s, %s and %s",enemyInt1:getSectorName(),enemyInt2:getSectorName(),enemyInt3:getSectorName())
				addCommsReply("Back", commsStation)
			end)
			addCommsReply("Back", commsStation)				
		end)
	end
end

function hullStation()
	if hullUpgradeAvailable then
		if not comms_source.hullUpgrade then
			addCommsReply("Upgrade hull damage capacity", function()
				local hullUpgradePartQuantity = 0
				if comms_source.goods ~= nil and comms_source.goods[hullGood] ~= nil and comms_source.goods[hullGood] > 0 then
					hullUpgradePartQuantity = comms_source.goods[hullGood]
				end
				if hullUpgradePartQuantity > 0 then
					comms_source.hullUpgrade = true
					comms_source.goods[hullGood] = comms_source.goods[hullGood] - 1
					comms_source.cargo = comms_source.cargo + 1
					comms_source:setHullMax(comms_source:getHullMax() * 1.2)
					setCommsMessage("Upgraded hull capacity for damage by 20%")
				else
					setCommsMessage(string.format("We won't upgrade your hull until we have %s",hullGood))
				end
				addCommsReply("Back", commsStation)
			end)
		end
	end
end

function shieldExpertBase()
	if plot4 == giftForBeau then
		addCommsReply("Offer gift on behalf of Maria Shrivner", function()
			local giftQuantity = 0
			local giftList = {}
			if comms_source.goods ~= nil then
				if comms_source.goods["gold"] ~= nil and comms_source.goods["gold"] > 0 then
					giftQuantity = giftQuantity + comms_source.goods["gold"]
					table.insert(giftList,"gold")
				end
				if comms_source.goods["platinum"] ~= nil and comms_source.goods["platinum"] > 0 then
					giftQuantity = giftQuantity + comms_source.goods["platinum"]
					table.insert(giftList,"platinum")
				end
				if comms_source.goods["dilithium"] ~= nil and comms_source.goods["dilithium"] > 0 then
					giftQuantity = giftQuantity + comms_source.goods["dilithium"]
					table.insert(giftList,"dilithium")
				end
				if comms_source.goods["tritanium"] ~= nil and comms_source.goods["tritanium"] > 0 then
					giftQuantity = giftQuantity + comms_source.goods["tritanium"]
					table.insert(giftList,"tritanium")
				end
				if comms_source.goods["cobalt"] ~= nil and comms_source.goods["cobalt"] > 0 then
					giftQuantity = giftQuantity + comms_source.goods["cobalt"]
					table.insert(giftList,"cobalt")
				end
			end
			if giftQuantity > 0 then
				beauGift = true
				local gifti = math.random(1,#giftList)
				comms_source.goods[giftList[gifti]] = comms_source.goods[giftList[gifti]] - 1
				comms_source.cargo = comms_source.cargo + 1
				setCommsMessage("Thanks. He's impressed with the gift to such a degree that he's speechless")
			else
				setCommsMessage("I know this couple (or former couple). Only gold, platinum, dilithium, tritanium or cobolt will work as a gift")
			end
			addCommsReply("Back", commsStation)
		end)
	end
end

function setOptionalOrders()
	optionalOrders = ""
	optionalOrdersPresent = false
	if plot2reminder ~= nil then
		if plot2reminder == "Get ship maneuver upgrade" then
			if spinReveal == 0 then
				optionalOrders = "\nOptional:\n" .. plot2reminder
			elseif spinReveal == 1 then
				optionalOrders = string.format("\nOptional:\nGet ship maneuver upgrade from %s for %s",spinBase:getCallSign(),spinGood)
			elseif spinReveal == 2 then
				optionalOrders = string.format("\nOptional:\nGet ship maneuver upgrade from %s in sector %s for %s",spinBase:getCallSign(),spinBase:getSectorName(),spinGood)
			elseif spinReveal == 3 then
				optionalOrders = string.format("\nOptional:\nGet ship maneuver upgrade from %s in sector %s for %s.\n    You might find %s at %s",spinBase:getCallSign(),spinBase:getSectorName(),spinGood,spinGood,spinGoodBase:getCallSign())
			else
				optionalOrders = string.format("\nOptional:\nGet ship maneuver upgrade from %s in sector %s for %s.\n    You might find %s at %s in sector %s",spinBase:getCallSign(),spinBase:getSectorName(),spinGood,spinGood,spinGoodBase:getCallSign(),spinGoodBase:getSectorName())
			end
		else
			optionalOrders = "\nOptional:\n" .. plot2reminder
		end
		optionalOrdersPresent = true
	end
	if plot4reminder ~= nil then
		if optionalOrdersPresent then
			ifs = "\n"
		else
			ifs = "\nOptional:\n"
			optionalOrdersPresent = true
		end
		if plot4reminder == string.format("Upgrade %s to rotate",homeStation:getCallSign()) then
			if rotateReveal == 0 then
				optionalOrders = optionalOrders .. ifs .. plot4reminder
			elseif rotateReveal == 1 then
				optionalOrders = optionalOrders .. ifs .. string.format("Upgrade %s to auto-rotate by taking %s to %s",homeStation:getCallSign(),rotateGood,rotateBase:getCallSign())
			elseif rotateReveal == 2 then
				optionalOrders = optionalOrders .. ifs .. string.format("Upgrade %s to auto-rotate by taking %s to %s in %s",homeStation:getCallSign(),rotateGood,rotateBase:getCallSign(),rotateBase:getSectorName()) 
			elseif rotateReveal == 3 then
				optionalOrders = optionalOrders .. ifs .. string.format("Upgrade %s to auto-rotate by taking %s to %s in %s.\n    %s may bave %s",homeStation:getCallSign(),rotateGood,rotateBase:getCallSign(),rotateBase:getSectorName(),rotateGoodBase:getCallSign(),rotateGood)
			else
				optionalOrders = optionalOrders .. ifs .. string.format("Upgrade %s to auto-rotate by taking %s to %s in %s.\n    %s in %s may bave %s",homeStation:getCallSign(),rotateGood,rotateBase:getCallSign(),rotateBase:getSectorName(),rotateGoodBase:getCallSign(),rotateGoodBase:getSectorName(),rotateGood)
			end
		elseif plot4reminder == "Get beam cycle time upgrade" then
			if beamTimeReveal == 0 then
				optionalOrders = optionalOrders .. ifs .. plot4reminder
			elseif beamTimeReveal == 1 then
				optionalOrders = optionalOrders .. ifs .. string.format("Get beam cycle time upgrade from %s for %s",beamTimeBase:getCallSign(),beamTimeGood)
			elseif beamTimeReveal == 2 then
				optionalOrders = optionalOrders .. ifs .. string.format("Get beam cycle time upgrade from %s in %s for %s",beamTimeBase:getCallSign(),beamTimeBase:getSectorName(),beamTimeGood)
			elseif beamTimeReveal == 3 then
				optionalOrders = optionalOrders .. ifs .. string.format("Get beam cycle time upgrade from %s in %s for %s\n    You might find %s at %s",beamTimeBase:getCallSign(),beamTimeBase:getSectorName(),beamTimeGood,beamTimeGood,beamTimeGoodBase:getCallSign())
			else
				optionalOrders = optionalOrders .. ifs .. string.format("Get beam cycle time upgrade from %s in %s for %s\n    You might find %s at %s in %s",beamTimeBase:getCallSign(),beamTimeBase:getSectorName(),beamTimeGood,beamTimeGood,beamTimeGoodBase:getCallSign(),beamTimeGoodBase:getSectorName())
			end
		elseif plot4reminder == "Get hull upgrade" then
			if hullReveal == 0 then
				optionalOrders = optionalOrders .. ifs .. plot4reminder
			elseif hullReveal == 1 then
				optionalOrders = optionalOrders .. ifs .. string.format("Get %s to upgrade hull for %s",hullBase:getCallSign(),hullGood)
			elseif hullReveal == 2 then
				optionalOrders = optionalOrders .. ifs .. string.format("Get %s in %s to upgrade hull for %s",hullBase:getCallSign(),hullBase:getSectorName(),hullGood)
			elseif hullReveal == 3 then
				optionalOrders = optionalOrders .. ifs .. string.format("Get %s in %s to upgrade hull for %s\n    %s might have %s",hullBase:getCallSign(),hullBase:getSectorName(),hullGood,hullGoodBase:getCallSign(),hullGood)
			else
				optionalOrders = optionalOrders .. ifs .. string.format("Get %s in %s to upgrade hull for %s\n    %s in %s might have %s",hullBase:getCallSign(),hullBase:getSectorName(),hullGood,hullGoodBase:getCallSign(),hullGoodBase:getSectorName(),hullGood)
			end
		else
			optionalOrders = optionalOrders .. ifs .. plot4reminder
		end
	end
end

function isAllowedTo(state)
    if state == "friend" and comms_source:isFriendly(comms_target) then
        return true
    end
    if state == "neutral" and not comms_source:isEnemy(comms_target) then
        return true
    end
    return false
end

function handleWeaponRestock(weapon)
    if not comms_source:isDocked(comms_target) then 
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
    local item_amount = math.floor(comms_source:getWeaponStorageMax(weapon) * comms_data.max_weapon_refill_amount[getFriendStatus()]) - comms_source:getWeaponStorage(weapon)
    if item_amount <= 0 then
        if weapon == "Nuke" then
            setCommsMessage("All nukes are charged and primed for destruction.");
        else
            setCommsMessage("Sorry, sir, but you are as fully stocked as I can allow.");
        end
        addCommsReply("Back", commsStation)
    else
        if not comms_source:takeReputationPoints(points_per_item * item_amount) then
            setCommsMessage("Not enough reputation.")
            return
        end
        comms_source:setWeaponStorage(weapon, comms_source:getWeaponStorage(weapon) + item_amount)
        if comms_source:getWeaponStorage(weapon) == comms_source:getWeaponStorageMax(weapon) then
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
    if comms_source:isFriendly(comms_target) then
        oMsg = "Good day, officer.\nIf you need supplies, please dock with us first."
    else
        oMsg = "Greetings.\nIf you want to do business, please dock with us first."
    end
    if comms_target:areEnemiesInRange(20000) then
		oMsg = oMsg .. "\nBe aware that if enemies in the area get much closer, we will be too busy to conduct business with you."
	end
	if comms_target.nukeAvail == nil then
		if math.random(1,10) <= (4 - difficulty) then
			comms_target.nukeAvail = true
		else
			comms_target.nukeAvail = false
		end
		if math.random(1,10) <= (5 - difficulty) then
			comms_target.empAvail = true
		else
			comms_target.empAvail = false
		end
		if math.random(1,10) <= (6 - difficulty) then
			comms_target.homeAvail = true
		else
			comms_target.homeAvail = false
		end
		if math.random(1,10) <= (7 - difficulty) then
			comms_target.mineAvail = true
		else
			comms_target.mineAvail = false
		end
		if math.random(1,10) <= (9 - difficulty) then
			comms_target.hvliAvail = true
		else
			comms_target.hvliAvail = false
		end
	end
	setCommsMessage(oMsg)
 	addCommsReply("I need information", function()
		setCommsMessage("What kind of information do you need?")
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
		local goodsAvailable = false
		if comms_target.comms_data.goods ~= nil then
			for good, goodData in pairs(comms_target.comms_data.goods) do
				if goodData["quantity"] > 0 then
					goodsAvailable = true
				end
			end
		end
		if goodsAvailable then
			addCommsReply("What goods do you have available for sale or trade?", function()
				local goodsAvailableMsg = string.format("Station %s:\nGoods or components available: quantity, cost in reputation",comms_target:getCallSign())
				for good, goodData in pairs(comms_target.comms_data.goods) do
					goodsAvailableMsg = goodsAvailableMsg .. string.format("\n   %14s: %2i, %3i",good,goodData["quantity"],goodData["cost"])
				end
				setCommsMessage(goodsAvailableMsg)
				addCommsReply("Back", commsStation)
			end)
		end
		addCommsReply("See any enemies in your area?", function()
			if comms_source:isFriendly(comms_target) then
				enemiesInRange = 0
				for _, obj in ipairs(comms_target:getObjectsInRange(30000)) do
					if obj:isEnemy(comms_source) then
						enemiesInRange = enemiesInRange + 1
					end
				end
				if enemiesInRange > 0 then
					if enemiesInRange > 1 then
						setCommsMessage(string.format("Yes, we see %i enemies within 30U",enemiesInRange))
					else
						setCommsMessage("Yes, we see one enemy within 30U")						
					end
					comms_source:addReputationPoints(2.0)					
				else
					setCommsMessage("No enemies within 30U")
					comms_source:addReputationPoints(1.0)
				end
				addCommsReply("Back", commsStation)
			else
				setCommsMessage("Not really")
				comms_source:addReputationPoints(1.0)
				addCommsReply("Back", commsStation)
			end
		end)
		addCommsReply("Where can I find particular goods?", function()
			gkMsg = "Friendly stations often have food or medicine or both. Neutral stations may trade their goods for food, medicine or luxury."
			if comms_target.comms_data.goodsKnowledge == nil then
				comms_target.comms_data.goodsKnowledge = {}
				local knowledgeCount = 0
				local knowledgeMax = 10
				for i=1,#stationList do
					local station = stationList[i]
					if station ~= nil and station:isValid() then
						local brainCheckChance = 60
						if distance(comms_target,station) > 75000 then
							brainCheckChance = 20
						end
						for good, goodData in pairs(station.comms_data.goods) do
							if random(1,100) <= brainCheckChance then
								local stationCallSign = station:getCallSign()
								local stationSector = station:getSectorName()
								comms_target.comms_data.goodsKnowledge[good] =	{	station = stationCallSign,
																sector = stationSector,
																cost = goodData["cost"] }
								knowledgeCount = knowledgeCount + 1
								if knowledgeCount >= knowledgeMax then
									break
								end
							end
						end
					end
					if knowledgeCount >= knowledgeMax then
						break
					end
				end
			end
			local goodsKnowledgeCount = 0
			for good, goodKnowledge in pairs(comms_target.comms_data.goodsKnowledge) do
				goodsKnowledgeCount = goodsKnowledgeCount + 1
				addCommsReply(good, function()
					local stationName = comms_target.comms_data.goodsKnowledge[good]["station"]
					local sectorName = comms_target.comms_data.goodsKnowledge[good]["sector"]
					local goodName = good
					local goodCost = comms_target.comms_data.goodsKnowledge[good]["cost"]
					setCommsMessage(string.format("Station %s in sector %s has %s for %i reputation",stationName,sectorName,goodName,goodCost))
					addCommsReply("Back", commsStation)
				end)
			end
			if goodsKnowledgeCount > 0 then
				gkMsg = gkMsg .. "\n\nWhat goods are you interested in?\nI've heard about these:"
			else
				gkMsg = gkMsg .. " Beyond that, I have no knowledge of specific stations"
			end
			setCommsMessage(gkMsg)
			addCommsReply("Back", commsStation)
		end)
		if comms_target.comms_data.public_relations then
			addCommsReply("General station information", function()
				setCommsMessage(comms_target.comms_data.general_information)
				addCommsReply("Back", commsStation)
			end)
		end
	end)
	if comms_source:isFriendly(comms_target) then
		addCommsReply("What are my current orders?", function()
			setOptionalOrders()
			ordMsg = primaryOrders .. "\n" .. secondaryOrders .. optionalOrders
			if playWithTimeLimit then
				ordMsg = ordMsg .. string.format("\n   %i Minutes remain in game",math.floor(gameTimeLimit/60))
			end
			setCommsMessage(ordMsg)
			addCommsReply("Back", commsStation)
		end)
	end
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
				oMsg = oMsg .. string.format(" wavetimer: %.2f danger value: %.1f",waveTimer,dangerValue)
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
				oMsg = oMsg .. string.format(" helpful warning timer: %.2f",helpfulWarningTimer)
			end
			if plotWname == nil or plotW == nil then
				oMsg = oMsg .. ""
			else
				oMsg = oMsg .. "\nplotw: " .. plotWname
			end
			if infoPromised then
				oMsg = oMsg .. "\nInfo promised"
				if spinUpgradeAvailable then
					oMsg = oMsg .. ", spin upgrade available"
				end
				if baseIntelligenceAvailable then
					oMsg = oMsg .. ", base intelligence available"
				end
				if hullUpgradeAvailable then
					oMsg = oMsg .. ", hull upgrade available"
				end
				if rotateUpgradeAvailable then
					oMsg = oMsg .. ", rotate upgrade available"
				end
				if beamTimeUpgradeAvailable then
					oMsg = oMsg .. ", beam time upgrade available"
				end
			end
			oMsg = oMsg .. "\nwfv: " .. wfv
			oMsg = oMsg .. string.format("\nSupply drop: %s",comms_target.comms_data.services.supplydrop)
			setCommsMessage(oMsg)
			addCommsReply("Back", commsStation)
		end)
	end
	if isAllowedTo(comms_target.comms_data.services.supplydrop) then
        addCommsReply("Can you send a supply drop? ("..getServiceCost("supplydrop").."rep)", function()
            if comms_source:getWaypointCount() < 1 then
                setCommsMessage("You need to set a waypoint before you can request backup.");
            else
                setCommsMessage("To which waypoint should we deliver your supplies?");
                for n=1,comms_source:getWaypointCount() do
                    addCommsReply("WP" .. n, function()
                        if comms_source:takeReputationPoints(getServiceCost("supplydrop")) then
                            local position_x, position_y = comms_target:getPosition()
                            local target_x, target_y = comms_source:getWaypoint(n)
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
            if comms_source:getWaypointCount() < 1 then
                setCommsMessage("You need to set a waypoint before you can request reinforcements.");
            else
                setCommsMessage("To which waypoint should we dispatch the reinforcements?");
                for n=1,comms_source:getWaypointCount() do
                    addCommsReply("WP" .. n, function()
                        if comms_source:takeReputationPoints(getServiceCost("reinforcements")) then
                            ship = CpuShip():setFactionId(comms_target:getFactionId()):setPosition(comms_target:getPosition()):setTemplate("Adder MK5"):setScanned(true):orderDefendLocation(comms_source:getWaypoint(n))
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

function getServiceCost(service)
-- Return the number of reputation points that a specified service costs for
-- the current player.
    return math.ceil(comms_data.service_cost[service])
end
function getFriendStatus()
    if comms_source:isFriendly(comms_target) then
        return "friend"
    else
        return "neutral"
    end
end
--------------------------
--  Ship communication  --
--------------------------
function commsShip()
	if comms_target.comms_data == nil then
		comms_target.comms_data = {friendlyness = random(0.0, 100.0)}
	end
	if goods[comms_target] == nil then
		goods[comms_target] = {goodsList[irandom(1,#goodsList)][1], 1, random(20,80)}
	end
	comms_data = comms_target.comms_data
	setPlayers()
	if comms_source:isFriendly(comms_target) then
		return friendlyComms(comms_data)
	end
	if comms_source:isEnemy(comms_target) and comms_target:isFriendOrFoeIdentifiedBy(comms_source) then
		return enemyComms(comms_data)
	end
	return neutralComms(comms_data)
end

function friendlyComms(comms_data)
	if comms_data.friendlyness < 20 then
		setCommsMessage("What do you want?");
	else
		setCommsMessage("Sir, how can we assist?");
	end
	addCommsReply("Defend a waypoint", function()
		if comms_source:getWaypointCount() == 0 then
			setCommsMessage("No waypoints set. Please set a waypoint first.");
			addCommsReply("Back", commsShip)
		else
			setCommsMessage("Which waypoint should we defend?");
			for n=1,comms_source:getWaypointCount() do
				addCommsReply("Defend WP" .. n, function()
					comms_target:orderDefendLocation(comms_source:getWaypoint(n))
					setCommsMessage("We are heading to assist at WP" .. n ..".");
					addCommsReply("Back", commsShip)
				end)
			end
		end
	end)
	if comms_data.friendlyness > 0.2 then
		addCommsReply("Assist me", function()
			setCommsMessage("Heading toward you to assist.");
			comms_target:orderDefendTarget(comms_source)
			addCommsReply("Back", commsShip)
		end)
	end
	addCommsReply("Report status", function()
		msg = "Hull: " .. math.floor(comms_target:getHull() / comms_target:getHullMax() * 100) .. "%\n"
		shields = comms_target:getShieldCount()
		if shields == 1 then
			msg = msg .. "Shield: " .. math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100) .. "%\n"
		elseif shields == 2 then
			msg = msg .. "Front Shield: " .. math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100) .. "%\n"
			msg = msg .. "Rear Shield: " .. math.floor(comms_target:getShieldLevel(1) / comms_target:getShieldMax(1) * 100) .. "%\n"
		else
			for n=0,shields-1 do
				msg = msg .. "Shield " .. n .. ": " .. math.floor(comms_target:getShieldLevel(n) / comms_target:getShieldMax(n) * 100) .. "%\n"
			end
		end
		local missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
		for i, missile_type in ipairs(missile_types) do
			if comms_target:getWeaponStorageMax(missile_type) > 0 then
					msg = msg .. missile_type .. " Missiles: " .. math.floor(comms_target:getWeaponStorage(missile_type)) .. "/" .. math.floor(comms_target:getWeaponStorageMax(missile_type)) .. "\n"
			end
		end
		
		setCommsMessage(msg);
		addCommsReply("Back", commsShip)
	end)
	for _, obj in ipairs(comms_target:getObjectsInRange(5000)) do
		if obj.typeName == "SpaceStation" and not comms_target:isEnemy(obj) then
			addCommsReply("Dock at " .. obj:getCallSign(), function()
				setCommsMessage("Docking at " .. obj:getCallSign() .. ".");
				comms_target:orderDock(obj)
				addCommsReply("Back", commsShip)
			end)
		end
	end
	return true
end

function enemyComms(comms_data)
	if comms_data.friendlyness > 50 then
		faction = comms_target:getFaction()
		taunt_option = "We will see to your destruction!"
		taunt_success_reply = "Your bloodline will end here!"
		taunt_failed_reply = "Your feeble threats are meaningless."
		if faction == "Kraylor" then
			setCommsMessage("Ktzzzsss.\nYou will DIEEee weaklingsss!");
		elseif faction == "Arlenians" then
			setCommsMessage("We wish you no harm, but will harm you if we must.\nEnd of transmission.");
		elseif faction == "Exuari" then
			setCommsMessage("Stay out of our way, or your death will amuse us extremely!");
		elseif faction == "Ghosts" then
			setCommsMessage("One zero one.\nNo binary communication detected.\nSwitching to universal speech.\nGenerating appropriate response for target from human language archives.\n:Do not cross us:\nCommunication halted.");
			taunt_option = "EXECUTE: SELFDESTRUCT"
			taunt_success_reply = "Rogue command received. Targeting source."
			taunt_failed_reply = "External command ignored."
		elseif faction == "Ktlitans" then
			setCommsMessage("The hive suffers no threats. Opposition to any of us is opposition to us all.\nStand down or prepare to donate your corpses toward our nutrition.");
			taunt_option = "<Transmit 'The Itsy-Bitsy Spider' on all wavelengths>"
			taunt_success_reply = "We do not need permission to pluck apart such an insignificant threat."
			taunt_failed_reply = "The hive has greater priorities than exterminating pests."
		else
			setCommsMessage("Mind your own business!");
		end
		comms_data.friendlyness = comms_data.friendlyness - random(0, 10)
		addCommsReply(taunt_option, function()
			if random(0, 100) < 30 then
				comms_target:orderAttack(comms_source)
				setCommsMessage(taunt_success_reply);
			else
				setCommsMessage(taunt_failed_reply);
			end
		end)
		return true
	end
	return false
end

function neutralComms(comms_data)
	shipType = comms_target:getTypeName()
	if shipType:find("Freighter") ~= nil then
		if comms_data.friendlyness > 66 then
			setCommsMessage("Yes?")
			-- Offer destination information
			addCommsReply("Where are you headed?", function()
				setCommsMessage(comms_target.target:getCallSign())
				addCommsReply("Back", commsShip)
			end)
			-- Offer to trade goods if goods or equipment freighter
			if distance(comms_source,comms_target) < 5000 then
				if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
					gi = 1
					luxuryQuantity = 0
					repeat
						if goods[comms_source][gi][1] == "luxury" then
							luxuryQuantity = goods[comms_source][gi][2]
						end
						gi = gi + 1
					until(gi > #goods[comms_source])
					if luxuryQuantity > 0 then
						gi = 1
						repeat
							local goodsType = goods[comms_target][gi][1]
							local goodsQuantity = goods[comms_target][gi][2]
							addCommsReply(string.format("Trade luxury for %s",goods[comms_target][gi][1]), function()
								if goodsQuantity < 1 then
									setCommsMessage("Insufficient inventory on freighter for trade")
								else
									decrementShipGoods(goodsType)
									incrementPlayerGoods(goodsType)
									decrementPlayerGoods("luxury")
									setCommsMessage("Traded")
								end
								addCommsReply("Back", commsShip)
							end)
							gi = gi + 1
						until(gi > #goods[comms_target])
					else
						setCommsMessage("Insufficient luxury to trade")
					end
					addCommsReply("Back", commsShip)
				else
					-- Offer to sell goods
					gi = 1
					repeat
						local goodsType = goods[comms_target][gi][1]
						local goodsQuantity = goods[comms_target][gi][2]
						local goodsRep = goods[comms_target][gi][3]
						addCommsReply(string.format("Buy one %s for %i reputation",goods[comms_target][gi][1],goods[comms_target][gi][3]), function()
							if comms_source.cargo < 1 then
								setCommsMessage("Insufficient cargo space for purchase")
							elseif goodsQuantity < 1 then
								setCommsMessage("Insufficient inventory on freighter")
							else
								if not comms_source:takeReputationPoints(goodsRep) then
									setCommsMessage("Insufficient reputation for purchase")
								else
									comms_source.cargo = comms_source.cargo - 1
									decrementShipGoods(goodsType)
									incrementPlayerGoods(goodsType)
									setCommsMessage("Purchased")
								end
							end
							addCommsReply("Back", commsShip)
						end)
						gi = gi + 1
					until(gi > #goods[comms_target])
				end
			end
		elseif comms_data.friendlyness > 33 then
			setCommsMessage("What do you want?")
			-- Offer to sell destination information
			destRep = random(1,5)
			addCommsReply(string.format("Where are you headed? (cost: %f reputation)",destRep), function()
				if not comms_source:takeReputationPoints(destRep) then
					setCommsMessage("Insufficient reputation")
				else
					setCommsMessage(comms_target.target:getCallSign())
				end
				addCommsReply("Back", commsShip)
			end)
			-- Offer to sell goods if goods or equipment freighter
			if distance(comms_source,comms_target) < 5000 then
				if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
					gi = 1
					repeat
						local goodsType = goods[comms_target][gi][1]
						local goodsQuantity = goods[comms_target][gi][2]
						local goodsRep = goods[comms_target][gi][3]
						addCommsReply(string.format("Buy one %s for %i reputation",goods[comms_target][gi][1],goods[comms_target][gi][3]), function()
							if comms_source.cargo < 1 then
								setCommsMessage("Insufficient cargo space for purchase")
							elseif goodsQuantity < 1 then
								setCommsMessage("Insufficient inventory on freighter")
							else
								if not comms_source:takeReputationPoints(goodsRep) then
									setCommsMessage("Insufficient reputation for purchase")
								else
									comms_source.cargo = comms_source.cargo - 1
									decrementShipGoods(goodsType)
									incrementPlayerGoods(goodsType)
									setCommsMessage("Purchased")
								end
							end
							addCommsReply("Back", commsShip)
						end)
						gi = gi + 1
					until(gi > #goods[comms_target])
				else
					-- Offer to sell goods double price
					gi = 1
					repeat
						local goodsType = goods[comms_target][gi][1]
						local goodsQuantity = goods[comms_target][gi][2]
						local goodsRep = goods[comms_target][gi][3]*2
						addCommsReply(string.format("Buy one %s for %i reputation",goods[comms_target][gi][1],goods[comms_target][gi][3]*2), function()
							if comms_source.cargo < 1 then
								setCommsMessage("Insufficient cargo space for purchase")
							elseif goodsQuantity < 1 then
								setCommsMessage("Insufficient inventory on freighter")
							else
								if not comms_source:takeReputationPoints(goodsRep) then
									setCommsMessage("Insufficient reputation for purchase")
								else
									comms_source.cargo = comms_source.cargo - 1
									decrementShipGoods(goodsType)
									incrementPlayerGoods(goodsType)
									setCommsMessage("Purchased")
								end
							end
							addCommsReply("Back", commsShip)
						end)
						gi = gi + 1
					until(gi > #goods[comms_target])
				end
			end
		else
			setCommsMessage("Why are you bothering me?")
			-- Offer to sell goods if goods or equipment freighter double price
			if distance(comms_source,comms_target) < 5000 then
				if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
					gi = 1
					repeat
						local goodsType = goods[comms_target][gi][1]
						local goodsQuantity = goods[comms_target][gi][2]
						local goodsRep = goods[comms_target][gi][3]*2
						addCommsReply(string.format("Buy one %s for %i reputation",goods[comms_target][gi][1],goods[comms_target][gi][3]*2), function()
							if comms_source.cargo < 1 then
								setCommsMessage("Insufficient cargo space for purchase")
							elseif goodsQuantity < 1 then
								setCommsMessage("Insufficient inventory on freighter")
							else
								if not comms_source:takeReputationPoints(goodsRep) then
									setCommsMessage("Insufficient reputation for purchase")
								else
									comms_source.cargo = comms_source.cargo - 1
									decrementShipGoods(goodsType)
									incrementPlayerGoods(goodsType)
									setCommsMessage("Purchased")
								end
							end
							addCommsReply("Back", commsShip)
						end)
						gi = gi + 1
					until(gi > #goods[comms_target])
				end
			end
		end
	else
		if comms_data.friendlyness > 50 then
			setCommsMessage("Sorry, we have no time to chat with you.\nWe are on an important mission.");
		else
			setCommsMessage("We have nothing for you.\nGood day.");
		end
	end
	return true
end
------------------------
--  Cargo management  --
------------------------
function incrementPlayerGoods(goodsType)
	local gi = 1
	repeat
		if goods[comms_source][gi][1] == goodsType then
			goods[comms_source][gi][2] = goods[comms_source][gi][2] + 1
		end
		gi = gi + 1
	until(gi > #goods[comms_source])
end

function decrementPlayerGoods(goodsType)
	local gi = 1
	repeat
		if goods[comms_source][gi][1] == goodsType then
			goods[comms_source][gi][2] = goods[comms_source][gi][2] - 1
		end
		gi = gi + 1
	until(gi > #goods[comms_source])
end

function decrementStationGoods(goodsType)
	local gi = 1
	repeat
		if goods[comms_target][gi][1] == goodsType then
			goods[comms_target][gi][2] = goods[comms_target][gi][2] - 1
		end
		gi = gi + 1
	until(gi > #goods[comms_target])
end

function decrementShipGoods(goodsType)
	local gi = 1
	repeat
		if goods[comms_target][gi][1] == goodsType then
			goods[comms_target][gi][2] = goods[comms_target][gi][2] - 1
		end
		gi = gi + 1
	until(gi > #goods[comms_target])
end
-----------------------
--  First plot line  --
-----------------------
function initialOrders(delta)
	plot1name = "initialOrders"
	if plot_1_diagnostic then print("plot 1 initial orders") end
	initialOrderTimer = initialOrderTimer - delta
	if initialOrderTimer < 0 then
		if initialOrdersMsg == nil then
			local foundPlayer = false
			for pidx=1,8 do
				local p = getPlayerShip(pidx)
				if p ~= nil and p:isValid() then
					foundPlayer = true
					p:addToShipLog(string.format("You are to protect your home base, %s, against enemy attack. Respond to other requests as you see fit",homeStation:getCallSign()),"Magenta")
					primaryOrders = string.format("Protect %s",homeStation:getCallSign())
					playSoundFile("sa_55_Commander1.wav")
				end
			end
			if foundPlayer then
				initialOrdersMsg = "sent"
				plot1 = setEnemyDefenseFleet
			end
		end
	end
end

function setEnemyDefenseFleet(delta)
	plot1name = "setEnemyDefenseFleet"
	if plot_1_diagnostic then print("plot 1 set enemy defense fleet") end
	if enemyDefenseFleets == nil then
		enemyDefenseFleets = "set"
		for i=1,#enemyStationList do
			local defx, defy = enemyStationList[i]:getPosition()
			local ntf = spawnEnemies(defx,defy,1.5,enemyStationList[i]:getFaction())
			for _, enemy in ipairs(ntf) do
				enemy:orderDefendTarget(enemyStationList[i])
			end
		end
		plot1 = threadedPursuit
	end
end

function threadedPursuit(delta)
	plot1name = "threadedPursuit"
	if plot_1_diagnostic then print("plot 1 threaded pursuit") end
	local p = closestPlayerTo(targetEnemyStation)
	if ef2 == nil then
		if p == nil then
			return
		end
		local scx, scy = p:getPosition()
		local cpx, cpy = vectorFromAngle(random(0,360),random(20000,30000))
		ef2 = spawnEnemies(scx+cpx,scy+cpy,.8)
		for _, enemy in ipairs(ef2) do
			if diagnostic then
				enemy:setCallSign(enemy:getCallSign() .. "ef2")
			end
			enemy:orderFlyTowards(scx,scy)
		end
		plot2 = destroyef2
	end
	if ef3 == nil then
		scx, scy = homeStation:getPosition()
		cpx, cpy = vectorFromAngle(random(0,360),random(30000,40000))
		ef3 = spawnEnemies(scx+cpx,scy+cpy,.8)
		for _, enemy in ipairs(ef3) do
			if diagnostic then
				enemy:setCallSign(enemy:getCallSign() .. "ef3")
			end
			enemy:orderFlyTowards(scx,scy)
		end
		plot3 = destroyef3
	end
	if ef4 == nil then
		if p == nil then
			return
		end
		scx, scy = p:getPosition()
		cpx, cpy = vectorFromAngle(random(0,360),random(40000,50000))
		ef4 = spawnEnemies(scx+cpx,scy+cpy,1)
		for _, enemy in ipairs(ef4) do
			enemy:orderAttack(p)
		end
		plot4 = destroyef4
	end
	helpfulWarningTimer = 90
	plot5 = helpfulWarning
	waveTimer = interWave
	if difficulty < 1 then
		dangerValue = .5
		dangerIncrement = .1
	elseif difficulty > 1 then
		dangerValue = 1
		dangerIncrement = .5
	else
		dangerValue = .8
		dangerIncrement = .2
	end
	plot1 = pressureWaves
end

function pressureWaves(delta)
	plot1name = "pressureWaves"
	if plot_1_diagnostic then print("plot 1 pressure waves") end
	if not homeStation:isValid() then
		missionVictory = false
		endStatistics()
		victory("Kraylor")
		return
	end
	if not targetEnemyStation:isValid() then
		missionVictory = true
		endStatistics()
		victory("Human Navy")
		return
	end
	waveTimer = waveTimer - delta
	if waveTimer < 0 then
		local esx = nil
		local esy = nil
		local ntf = nil
		local p = nil
		local px = nil
		local py = nil
		local spx = nil
		local spy = nil
		local hsx = nil
		local hsy = nil
		waveSpawned = false
		dangerValue = dangerValue + dangerIncrement
		for i=1,#enemyStationList do
			if enemyStationList[i]:isValid() then
				if random(1,5) <= 2 then
					esx, esy = enemyStationList[i]:getPosition()
					ntf = spawnEnemies(esx,esy,dangerValue,enemyStationList[i]:getFaction())
					waveSpawned = true
					if random(1,5) <= 3 then
						p = closestPlayerTo(enemyStationList[i])
						if p ~= nil then
							for _, enemy in ipairs(ntf) do
								enemy:orderAttack(p)
							end
						end
					else
						for _, enemy in ipairs(ntf) do
							enemy:orderDefendTarget(enemyStationList[i])
						end
					end
				end
			end
		end
		if random(1,5) <= 2 then
			ntf = spawnEnemies(mnx,mny,dangerValue,targetEnemyStation:getFaction())
			waveSpawned = true
			if random(1,5) >= 4 then
				for _, enemy in ipairs(ntf) do
					enemy:orderAttack(homeStation)
				end
			end
		end
		if random(1,5) <= 3 then
			p = closestPlayerTo(targetEnemyStation)
			esx, esy = targetEnemyStation:getPosition()
			px, py = p:getPosition()
			ntf = spawnEnemies((esx+px)/2,(esy+py)/2,dangerValue/2,targetEnemyStation:getFaction())
			waveSpawned = true
			if random(1,5) <= 2 then
				for _, enemy in ipairs(ntf) do
					enemy:orderAttack(p)
				end
			end
		end
		if random(1,5) <= 2 then
			p = closestPlayerTo(targetEnemyStation)
			px, py = p:getPosition()
			spx, spy = vectorFromAngle(random(0,360), random(30000, 40000))
			ntf = spawnEnemies(px+spx, py+spy, dangerValue/2, targetEnemyStation:getFaction())
			waveSpawned = true
			for _, enemy in ipairs(ntf) do
				enemy:orderAttack(p)
			end
		end
		if random(1,5) <= 1 then
			hsx, hsy = homeStation:getPosition()
			spx, spy = vectorFromAngle(random(0,360),random(30000,40000))
			ntf = spawnEnemies(hsx+spx,hsy+spy,dangerValue,targetEnemyStation:getFaction())
			waveSpawned = true
			if random(1,5) <= 3 then
				for _, enemy in ipairs(ntf) do
					enemy:orderFlyTowards(hsx,hsy)
				end
			end
		end
		if random(1,5) <= 1 then
			p = closestPlayerTo(targetEnemyStation)
			px, py = p:getPosition()
			local nol = getObjectsInRadius(px, py, 30000)
			local nearbyNebulae = {}
			for _, obj in ipairs(nol) do
				if string.find(obj:getTypeName(),"Nebula") then
					table.insert(nearbyNebulae,obj)
				end
			end
			if #nearbyNebulae > 0 then
				local nx, ny = nearbyNebulae[math.random(1,#nearbyNebulae)]:getPosition()
				ntf = spawnEnemies(nx,ny,dangerValue,targetEnemyStation:getFaction())
				waveSpawned = true
				for _, enemy in ipairs(ntf) do
					enemy:orderAttack(p)
				end
			end
		end
		if not waveSpawned then
			p = closestPlayerTo(targetEnemyStation)
			px, py = p:getPosition()
			local spawnAngle = random(0,360)
			spx, spy = vectorFromAngle(spawnAngle, random(15000,20000))
			ntf = spawnEnemies(px+spx, py+spy, dangerValue, targetEnemyStation:getFaction())
			spawnAngle = spawnAngle + random(60,180)
			spx, spy = vectorFromAngle(spawnAngle, random(20000,25000))
			ntf = spawnEnemies(px+spx, py+spy, dangerValue, targetEnemyStation:getFaction())
			for _, enemy in ipairs(ntf) do
				enemy:orderFlyTowards(px, py)
			end
			spawnAngle = spawnAngle + random(60,120)
			spx, spy = vectorFromAngle(spawnAngle, random(25000,30000))
			ntf = spawnEnemies(px+spx, py+spy, dangerValue, targetEnemyStation:getFaction())
			for _, enemy in ipairs(ntf) do
				enemy:orderAttack(p)
			end
		end
		waveTimer = delta + interWave + dangerValue*10 + random(1,60)
	end
end
-----------------------------------------------------------------------------
--  Plot 2 Easy delivery, improve maneuverability or get base intelligence --
-----------------------------------------------------------------------------
function destroyef2(delta)
	plot2name = "destroyef2"
	local ef2Count = 0
	for _, enemy in ipairs(ef2) do
		if enemy:isValid() then
			ef2Count = ef2Count + 1
		end
	end
	if plot_2_diagnostic then print(string.format("plot 2 destroy enemy fleet (ef) 2. Count: %i",ef2Count)) end
	if ef2Count == 0 then
		easyDeliveryTimer = 15
		plot2 = easyDelivery
		homeDelivery = true
		local p = closestPlayerTo(targetEnemyStation)
		p:addReputationPoints(20)
	end
end

function easyDelivery(delta)
	--required cargo should be easy to find, if expensive in reputation to get
	plot2name = "easyDelivery"
	if plot_2_diagnostic then print("plot 2 easy delivery") end
	easyDeliveryTimer = easyDeliveryTimer - delta
	if easyDeliveryTimer < 0 then
		if easyDeliveryMsg == nil then
			local p = closestPlayerTo(homeStation)
			local home_station_goods_type_count = 0
			for home_good, home_good_details in pairs(homeStation.comms_data.goods) do
				home_station_goods_type_count = home_station_goods_type_count + 1
			end
			for i=2,#stationList do
				easyStation = stationList[i]
				for good, details in pairs(easyStation.comms_data.goods) do
					if good ~= "food" and good ~= "medicine" and good ~= "luxury" then
						if home_station_goods_type_count > 0 then
							if homeStation.comms_data.goods[good] == nil then
								easyDeliverGood = good
								break
							end
						else
							easyDeliverGood = good
							break
						end
					end
				end
				if easyDeliverGood ~= nil then
					break
				end
			end
			if easyDeliverGood == nil then
				plot2 = nil
				plot2reminder = nil
			else
				p:addToShipLog(string.format("[%s] We need some goods of type %s. Can you help? I hear %s has some",homeStation:getCallSign(),easyDeliverGood,easyStation:getCallSign()),"85,107,47")
				plot2reminder = string.format("Bring %s to %s. Possible source: %s",easyDeliverGood,homeStation:getCallSign(),easyStation:getCallSign())
				playSoundFile("sa_55_Manager1.wav")
			end
			easyDeliveryMsg = "sent"
		end
	end
end

function spinUpgradeStart(delta)
	plot2name = "spinUpgradeStart"
	if plot_2_diagnostic then print("plot 2 spin upgrade start") end
	infoPromised = true
	spinUpgradeAvailable = false
	plot2reminder = "Get ship maneuver upgrade"
	local candidate = nil
	if pickSpinBase == nil then
		p = closestPlayerTo(homeStation)
		for i=13,#stationList do
			candidate = stationList[i]
			if candidate ~= nil and candidate:isValid() and candidate.comms_data.goods ~= nil then
				for good, good_details in pairs(candidate.comms_data.goods) do
					if good ~= "food" and good ~= "medicine" then
						spinBase = candidate	--last valid station in list without food or medicine
					end
				end
			end
		end
		if diagnostic then
			p:addToShipLog(string.format("Final choice: %s previous: %s",spinBase:getCallSign(),candidate:getCallSign()),"Blue")
		end
		pickSpinBase = "done"
		plot2 = pickSpinGood
	end
end

function pickSpinGood(delta)
	plot2name = "pickSpinGood"
	if pickSpinGoodBase == nil then
		p = closestPlayerTo(homeStation)
		local candidate = nil
		for i=13,#stationList do
			candidate = stationList[i]
			if candidate ~= nil and candidate:isValid() and candidate.comms_data.goods ~= nil then
				for good, good_details in pairs(candidate.comms_data.goods) do
					if good ~= "food" and good ~= "medicine" then
						local match_away = false
						for spin_good, spin_good_details in pairs(spinBase.comms_data.goods) do
							if spin_good ~= "food" and spin_good ~= "medicine" then
								if spin_good == good then
									match_away = true
									break
								end
							end
						end
						if not match_away then
							spinGood = good
							spinGoodBase = candidate
							break
						end
					end
				end
			end
		end
		if diagnostic then
			p:addToShipLog(string.format("spin base: %s spin good base: %s spin good: %s",spinBase:getCallSign(),spinGoodBase:getCallSign(),spinGood),"Blue")
		end
		plot2 = cleanupSpinners
		spinReveal = 0
		spinUpgradeAvailable = true
		pickSpinGoodBase = "done"
	end
end

function cleanupSpinners(delta)
	plot2name = "cleanupSpinners"
	noSpinCount = 0
	for pidx=1,8 do
		pc = getPlayerShip(pidx)
		if pc ~= nil and pc:isValid() then
			if not pc.spinUpgrade then
				noSpinCount = noSpinCount + 1
			end
		end
	end
	if noSpinCount == 0 then
		plot2reminder = nil
		plot2 = warpJamLineStart
		warpJamLineTimer = 300
		p = closestPlayerTo(targetEnemyStation)
		p:addReputationPoints(20)
	end
end

function enemyBaseInfoStart(delta)
	plot2name = "enemyBaseInfoStart"
	baseIntelligenceAvailable = true
	infoPromised = true
	rvfCount = 0
	rvnCount = 0
	baseInt1Visit = false
	for i=4,12 do
		if stationList[i]:isValid() then
			rvfCount = rvfCount + 1
		end
	end
	for i=13,30 do
		if stationList[i]:isValid() then
			rvnCount = rvnCount + 1
		end
	end
	if rvfCount > 0 then
		repeat
			baseInt1 = stationList[math.random(4,12)]
		until(baseInt1:isValid())
		if rvnCount > 1 then
			repeat
				baseInt2 = stationList[math.random(13,30)]
			until(baseInt2:isValid())
		end
	end
	plot2reminder = nil
	plot2 = warpJamLineStart
	warpJamLineTimer = 300
end

function warpJamLineStart(delta)
	plot2name = "warpJamLineStart"
	warpJamLineTimer = warpJamLineTimer - delta
	if warpJamLineTimer < 0 then
		p = closestPlayerTo(targetEnemyStation)
		esx, esy = targetEnemyStation:getPosition()
		cpx, cpy = p:getPosition()
		wjCenter = CpuShip():setFaction("Kraylor"):setTemplate("Phobos M3"):setPosition((esx+cpx)/2,(esy+cpy)/2):orderFlyTowardsBlind(cpx,cpy)
		wjP1 = CpuShip():setFaction("Kraylor"):setTemplate("Phobos M3"):setPosition((esx+cpx)/2+20000,(esy+cpy)/2+20000):orderFlyTowardsBlind(cpx+20000,cpy+20000)
		wjP2 = CpuShip():setFaction("Kraylor"):setTemplate("Phobos M3"):setPosition((esx+cpx)/2-20000,(esy+cpy)/2-20000):orderFlyTowardsBlind(cpx-20000,cpy-20000)
		wjP3 = CpuShip():setFaction("Kraylor"):setTemplate("Phobos M3"):setPosition((esx+cpx)/2+20000,(esy+cpy)/2-20000):orderFlyTowardsBlind(cpx+20000,cpy-20000)
		wjP4 = CpuShip():setFaction("Kraylor"):setTemplate("Phobos M3"):setPosition((esx+cpx)/2-20000,(esy+cpy)/2+20000):orderFlyTowardsBlind(cpx-20000,cpy+20000)
		wjCenterE1 = CpuShip():setFaction("Kraylor"):setTemplate("MT52 Hornet"):setPosition((esx+cpx)/2,(esy+cpy)/2):orderDefendTarget(wjCenter)
		wjCenterE2 = CpuShip():setFaction("Kraylor"):setTemplate("MU52 Hornet"):setPosition((esx+cpx)/2,(esy+cpy)/2):orderDefendTarget(wjCenter)
		wjCenterE3 = CpuShip():setFaction("Kraylor"):setTemplate("Fighter"):setPosition((esx+cpx)/2,(esy+cpy)/2):orderDefendTarget(wjCenter)
		wjCenterE4 = CpuShip():setFaction("Kraylor"):setTemplate("Ktlitan Fighter"):setPosition((esx+cpx)/2,(esy+cpy)/2):orderDefendTarget(wjCenter)
		wjP1E1 = CpuShip():setFaction("Kraylor"):setTemplate("MT52 Hornet"):setPosition((esx+cpx)/2+20000,(esy+cpy)/2+20000):orderDefendTarget(wjP1)
		wjP1E2 = CpuShip():setFaction("Kraylor"):setTemplate("MU52 Hornet"):setPosition((esx+cpx)/2+20000,(esy+cpy)/2+20000):orderDefendTarget(wjP1)
		wjP1E3 = CpuShip():setFaction("Kraylor"):setTemplate("Fighter"):setPosition((esx+cpx)/2+20000,(esy+cpy)/2+20000):orderDefendTarget(wjP1)
		wjP1E4 = CpuShip():setFaction("Kraylor"):setTemplate("Ktlitan Fighter"):setPosition((esx+cpx)/2+20000,(esy+cpy)/2+20000):orderDefendTarget(wjP1)
		wjP2E1 = CpuShip():setFaction("Kraylor"):setTemplate("MT52 Hornet"):setPosition((esx+cpx)/2-20000,(esy+cpy)/2-20000):orderDefendTarget(wjP2)
		wjP2E2 = CpuShip():setFaction("Kraylor"):setTemplate("MU52 Hornet"):setPosition((esx+cpx)/2-20000,(esy+cpy)/2-20000):orderDefendTarget(wjP2)
		wjP2E3 = CpuShip():setFaction("Kraylor"):setTemplate("Fighter"):setPosition((esx+cpx)/2-20000,(esy+cpy)/2-20000):orderDefendTarget(wjP2)
		wjP2E4 = CpuShip():setFaction("Kraylor"):setTemplate("Ktlitan Fighter"):setPosition((esx+cpx)/2-20000,(esy+cpy)/2-20000):orderDefendTarget(wjP2)
		wjP3E1 = CpuShip():setFaction("Kraylor"):setTemplate("MT52 Hornet"):setPosition((esx+cpx)/2+20000,(esy+cpy)/2-20000):orderDefendTarget(wjP3)
		wjP3E2 = CpuShip():setFaction("Kraylor"):setTemplate("MU52 Hornet"):setPosition((esx+cpx)/2+20000,(esy+cpy)/2-20000):orderDefendTarget(wjP3)
		wjP3E3 = CpuShip():setFaction("Kraylor"):setTemplate("Fighter"):setPosition((esx+cpx)/2+20000,(esy+cpy)/2-20000):orderDefendTarget(wjP3)
		wjP3E4 = CpuShip():setFaction("Kraylor"):setTemplate("Ktlitan Fighter"):setPosition((esx+cpx)/2+20000,(esy+cpy)/2-20000):orderDefendTarget(wjP3)
		wjP4E1 = CpuShip():setFaction("Kraylor"):setTemplate("MT52 Hornet"):setPosition((esx+cpx)/2-20000,(esy+cpy)/2+20000):orderDefendTarget(wjP4)
		wjP4E2 = CpuShip():setFaction("Kraylor"):setTemplate("MU52 Hornet"):setPosition((esx+cpx)/2-20000,(esy+cpy)/2+20000):orderDefendTarget(wjP4)
		wjP4E3 = CpuShip():setFaction("Kraylor"):setTemplate("Fighter"):setPosition((esx+cpx)/2-20000,(esy+cpy)/2+20000):orderDefendTarget(wjP4)
		wjP4E4 = CpuShip():setFaction("Kraylor"):setTemplate("Ktlitan Fighter"):setPosition((esx+cpx)/2-20000,(esy+cpy)/2+20000):orderDefendTarget(wjP4)
		plot2 = warpJamLineSpring
	end
end

function warpJamLineSpring(delta)
	plot2name = "warpJamLineSpring"
	for pidx=1,8 do
		p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() and wjCenter:isValid() then
			if distance(p,wjCenter) < 10000 then
				plot2 = warpJamLineRelease
				break
			end
		end
	end
	if wjCenter:isValid() then
		if distance(wjCenter,homeStation) < 10000 then
			plot2 = warpJamLineRelease
		end
	else
		plot2 = warpJamLineRelease
	end
end

function warpJamLineRelease(delta)
	plot2name = "warpJamLineRelease"
	if wjCenter:isValid() then
		wx, wy = wjCenter:getPosition()
		WarpJammer():setFaction("Kraylor"):setRange(20000):setPosition(wx,wy)
		wjCenter:orderStandGround()
	end
	if wjP1:isValid() then
		wx, wy = wjP1:getPosition()
		WarpJammer():setFaction("Kraylor"):setRange(20000):setPosition(wx,wy)
		wjP1:orderStandGround()
	end
	if wjP2:isValid() then
		wx, wy = wjP2:getPosition()
		WarpJammer():setFaction("Kraylor"):setRange(20000):setPosition(wx,wy)
		wjP2:orderStandGround()
	end
	if wjP3:isValid() then
		wx, wy = wjP3:getPosition()
		WarpJammer():setFaction("Kraylor"):setRange(20000):setPosition(wx,wy)
		wjP3:orderStandGround()
	end
	if wjP4:isValid() then
		wx, wy = wjP4:getPosition()
		WarpJammer():setFaction("Kraylor"):setRange(20000):setPosition(wx,wy)
		wjP4:orderStandGround()
	end
	startAngle = random(0,360)
	hsx, hsy = homeStation:getPosition()
	wjAdvx, wjAdvy = vectorFromAngle(startAngle,random(25000,30000))
	wjAdv1ef = spawnEnemies(hsx+wjAdvx,hsy+wjAdvy,1)
	angle2 = startAngle + random(60,120)
	wjAdvx, wjAdvy = vectorFromAngle(angle2,random(30000,35000))
	wjAdv2ef = spawnEnemies(hsx+wjAdvx,hsy+wjAdvy,1)
	angle3 = angle2 + random(60,120)
	wjAdvx, wjAdvy = vectorFromAngle(angle3,random(35000,40000))
	wjAdv3ef = spawnEnemies(hsx+wjAdvx,hsy+wjAdvy,1)
	for _, enemy in ipairs(wjAdv2ef) do
		enemy:orderAttack(homeStation)
	end
	for _, enemy in ipairs(wjAdv3ef) do
		enemy:orderFlyTowards(hsx, hsy)
	end
	plot2name = nil
	plot2 = nil
end
----------------------------------------------------
--  Plot 3 Development of intelligence over time  --
----------------------------------------------------
function destroyef3(delta)
	plot3name = "destroyef3"
	ef3Count = 0
	for _, enemy in ipairs(ef3) do
		if enemy:isValid() then
			ef3Count = ef3Count + 1
		end
	end
	if ef3Count == 0 then
		hunterTransition1Timer = timedIntelligenceInterval
		plot3 = hunterTransition1
		p = closestPlayerTo(targetEnemyStation)
		p:addReputationPoints(20)
	end
end

function hunterTransition1(delta)
	plot3name = "hunterTransition1"
	hunterTransition1Timer = hunterTransition1Timer - delta
	if hunterTransition1Timer < 0 then
		iuMsg = string.format("The enemy activity has been traced back to enemy bases nearby. Find these bases and stop these incursions. Threat Assessment: %.1f",dangerValue)
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				p:addToShipLog(iuMsg,"Magenta")
			end
		end
		secondaryOrders = string.format("Find enemy bases. Stop enemy incursions. TA:%.1f",dangerValue)
		scx, scy = homeStation:getPosition()
		cpx, cpy = vectorFromAngle(random(0,360),random(30000,40000))
		ef3 = spawnEnemies(scx+cpx,scy+cpy,1)
		for _, enemy in ipairs(ef3) do
			enemy:orderFlyTowards(scx,scy)
		end
		plot3 = destroyef3v2
	end
end

function destroyef3v2(delta)
	plot3name = "destroyef3v2"
	ef3Count = 0
	for _, enemy in ipairs(ef3) do
		if enemy:isValid() then
			ef3Count = ef3Count + 1
		end
	end
	if ef3Count == 0 then
		hunterTransition2Timer = timedIntelligenceInterval
		plot3 = hunterTransition2
		p = closestPlayerTo(targetEnemyStation)
		p:addReputationPoints(20)
	end
end

function hunterTransition2(delta)
	plot3name = "hunterTransition2"
	hunterTransition2Timer = hunterTransition2Timer - delta
	if hunterTransition2Timer < 0 then
		iuMsg = string.format("Kraylor prefect Ghalontor has moved to one of the enemy stations. Destroy that station and the Kraylor incursion will crumble. Threat Assessment: %.1f",dangerValue)
		playSoundFile("sa_55_Commander2.wav")
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				p:addToShipLog(iuMsg,"Magenta")
			end
		end
		secondaryOrders = string.format("Destroy enemy base with Prefect Ghalontor aboard. TA:%.1f",dangerValue)
		scx, scy = homeStation:getPosition()
		cpx, cpy = vectorFromAngle(random(0,360),random(30000,40000))
		ef3 = spawnEnemies(scx+cpx,scy+cpy,1)
		for _, enemy in ipairs(ef3) do
			enemy:orderFlyTowards(scx,scy)
		end
		plot3 = destroyef3v3
	end
end

function destroyef3v3(delta)
	plot3name = "destroyef3v3"
	ef3Count = 0
	for _, enemy in ipairs(ef3) do
		if enemy:isValid() then
			ef3Count = ef3Count + 1
		end
	end
	if ef3Count == 0 then
		hunterTransition3Timer = timedIntelligenceInterval
		plot3 = hunterTransition3
	end
end

function hunterTransition3(delta)
	plot3name = "hunterTransition3"
	hunterTransition3Timer = hunterTransition3Timer - delta
	if hunterTransition3Timer < 0 then
		for i=4,#enemyStationList do
			if enemyStationList[i]:isValid() then
				if enemyInt4 == nil then
					enemyInt4 = enemyStationList[i]
					break
				end
			end
		end
		if enemyInt4 == nil then
			enemyInt4 = targetEnemyStation
		end
		iuMsg = string.format("Enemy base located in %s. Others expected nearby. Threat Assessment: %.1f",enemyInt4:getSectorName(),dangerValue)
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				p:addToShipLog(iuMsg,"Magenta")
			end
		end
		secondaryOrders = string.format("Destroy enemy base possibly near %s with Prefect Ghalontor aboard. TA:%.1f",enemyInt4:getSectorName(),dangerValue)
		scx, scy = homeStation:getPosition()
		cpx, cpy = vectorFromAngle(random(0,360),random(30000,40000))
		ef3 = spawnEnemies(scx+cpx,scy+cpy,1)
		for _, enemy in ipairs(ef3) do
			enemy:orderFlyTowards(scx,scy)
		end
		plot3 = destroyef3v4
	end
end

function destroyef3v4(delta)
	plot3name = "destroyef3v4"
	ef3Count = 0
	for _, enemy in ipairs(ef3) do
		if enemy:isValid() then
			ef3Count = ef3Count + 1
		end
	end
	if ef3Count == 0 then
		hunterTransition4Timer = timedIntelligenceInterval
		plot3 = hunterTransition4
	end
end

function hunterTransition4(delta)
	plot3name = "hunterTransition4"
	hunterTransition4Timer = hunterTransition4Timer - delta
	if hunterTransition4Timer < 0 then
		for i=5,#enemyStationList do
			if enemyStationList[i]:isValid() then
				if enemyInt5 == nil then
					enemyInt5 = enemyStationList[i]
					break
				end
			end
		end
		if enemyInt5 == nil then
			enemyInt5 = targetEnemyStation
		end
		iuMsg = string.format("Another enemy base located in %s. Others expected nearby. Threat Assessment: %.1f",enemyInt5:getSectorName(),dangerValue)
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				p:addToShipLog(iuMsg,"Magenta")
			end
		end
		secondaryOrders = string.format("Destroy enemy base possibly near %s or %s with Prefect Ghalontor aboard. TA:%.1f",enemyInt4:getSectorName(),enemyInt5:getSectorName(),dangerValue)
		scx, scy = homeStation:getPosition()
		cpx, cpy = vectorFromAngle(random(0,360),random(30000,40000))
		ef3 = spawnEnemies(scx+cpx,scy+cpy,1)
		for _, enemy in ipairs(ef3) do
			enemy:orderFlyTowards(scx,scy)
		end
		plot3 = destroyef3v5
	end
end

function destroyef3v5(delta)
	plot3name = "destroyef3v5"
	ef3Count = 0
	for _, enemy in ipairs(ef3) do
		if enemy:isValid() then
			ef3Count = ef3Count + 1
		end
	end
	if ef3Count == 0 then
		hunterTransition5Timer = timedIntelligenceInterval
		plot3 = hunterTransition5
	end
end

function hunterTransition5(delta)
	plot3name = "hunterTransition5"
	hunterTransition5Timer = hunterTransition5Timer - delta
	if hunterTransition5Timer < 0 then
		for i=6,#enemyStationList do
			if enemyStationList[i]:isValid() then
				if enemyInt6 == nil then
					enemyInt6 = enemyStationList[i]
					break
				end
			end
		end
		if enemyInt6 == nil then
			enemyInt6 = targetEnemyStation
		end
		iuMsg = string.format("Another enemy base located in %s. Others expected nearby. Threat Assessment: %.1f",enemyInt6:getSectorName(),dangerValue)
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				p:addToShipLog(iuMsg,"Magenta")
			end
		end
		secondaryOrders = string.format("Destroy enemy base possibly near %s, %s or %s with Prefect Ghalontor aboard. TA:%.1f",enemyInt4:getSectorName(),enemyInt5:getSectorName(),enemyInt6:getSectorName(),dangerValue)
		scx, scy = homeStation:getPosition()
		cpx, cpy = vectorFromAngle(random(0,360),random(30000,40000))
		ef3 = spawnEnemies(scx+cpx,scy+cpy,1)
		for _, enemy in ipairs(ef3) do
			enemy:orderFlyTowards(scx,scy)
		end
		plot3 = destroyef3v6
	end
end

function destroyef3v6(delta)
	plot3name = "destroyef3v6"
	ef3Count = 0
	for _, enemy in ipairs(ef3) do
		if enemy:isValid() then
			ef3Count = ef3Count + 1
		end
	end
	if ef3Count == 0 then
		hunterTransition6Timer = timedIntelligenceInterval
		plot3 = hunterTransition6
	end
end

function hunterTransition6(delta)
	plot3name = "hunterTransition6"
	hunterTransition6Timer = hunterTransition6Timer - delta
	if hunterTransition6Timer < 0 then
		iuMsg = string.format("Another enemy base located in %s. Others expected nearby: Threat Assessment: %.1f",targetEnemyStation:getSectorName(),dangerValue)
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				p:addToShipLog(iuMsg,"Magenta")
			end
		end
		secondaryOrders = string.format("Destroy enemy base possibly near %s, %s, %s or %s with Prefect Ghalontor aboard. TA:%.1f",targetEnemyStation:getSectorName(),enemyInt4:getSectorName(),enemyInt5:getSectorName(),enemyInt6:getSectorName(),dangerValue)
		scx, scy = homeStation:getPosition()
		cpx, cpy = vectorFromAngle(random(0,360),random(30000,40000))
		ef3 = spawnEnemies(scx+cpx,scy+cpy,1)
		for _, enemy in ipairs(ef3) do
			enemy:orderFlyTowards(scx,scy)
		end
		plot3 = destroyef3v7
	end
end

function destroyef3v7(delta)
	plot3name = "destroyef3v7"
	ef3Count = 0
	for _, enemy in ipairs(ef3) do
		if enemy:isValid() then
			ef3Count = ef3Count + 1
		end
	end
	if ef3Count == 0 then
		hunterTransition7Timer = timedIntelligenceInterval
		plot3 = hunterTransition7
	end
end

function hunterTransition7(delta)
	plot3name = "hunterTransition7"
	hunterTransition7Timer = hunterTransition7Timer - delta
	if hunterTransition7Timer < 0 then
		iuMsg = string.format("We confirmed Prefect Ghalontor is aboard enemy station %s in %s. Threat Assessment: %.1f",targetEnemyStation:getCallSign(),targetEnemyStation:getSectorName(),dangerValue)
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				p:addToShipLog(iuMsg,"Magenta")
			end
		end
		secondaryOrders = string.format("Destroy enemy base %s in %s. TA:%.1f",targetEnemyStation:getCallSign(),targetEnemyStation:getSectorName(),dangerValue)
		scx, scy = homeStation:getPosition()
		cpx, cpy = vectorFromAngle(random(0,360),random(30000,40000))
		ef3 = spawnEnemies(scx+cpx,scy+cpy,1)
		for _, enemy in ipairs(ef3) do
			enemy:orderFlyTowards(scx,scy)
		end
		plot3 = destroyef3v8
	end
end

function destroyef3v8(delta)
	plot3namename = "destroyef3v8"
	ef3Count = 0
	for _, enemy in ipairs(ef3) do
		if enemy:isValid() then
			ef3Count = ef3Count + 1
		end
	end
	if ef3Count == 0 then
		plot3 = nil
	end
end
--------------------------------------------------------------------------
--  Plot 4 station rotate upgrade or beam time upgrade or hull upgrade  --
--------------------------------------------------------------------------
function destroyef4(delta)
	plot4name = "destroyef4"
	ef4Count = 0
	for _, enemy in ipairs(ef4) do
		if enemy:isValid() then
			ef4Count = ef4Count + 1
		end
	end
	if ef4Count == 0 then
		randomDeliveryTimer = 45
		plot4 = randomDelivery
		homeDelivery = true
		p = closestPlayerTo(targetEnemyStation)
		p:addReputationPoints(20)
	end
end

function randomDelivery(delta)
	plot4name = "randomDelivery"
	randomDeliveryTimer = randomDeliveryTimer - delta
	if randomDeliveryTimer < 0 then
		if randomDeliveryMsg == nil then
			p = closestPlayerTo(homeStation)
			local home_station_good_count = 0
			if homeStation.comms_data.goods ~= nil then
				for good, good_detail in pairs(homeStation.comms_data.goods) do
					home_station_good_count = home_station_good_count + 1
				end
			end
			if home_station_good_count > 0 then
				local attempt_count = 0
				repeat
					attempt_count = attempt_count + 1
					randomDeliverStation = stationList[math.random(6,#stationList)]
					if randomDeliverStation ~= nil and randomDeliverStation:isValid() and randomDeliverStation.comms_data.goods ~= nil then
						for good, good_detail in pairs(randomDeliverStation.comms_data.goods) do
							if good ~= "food" and good ~= "medicine" and good ~= "luxury" then
								local match_away = false
								for home_good, home_good_detail in pairs(homeStation.comms_data.goods) do
									if home_good ~= "food" and home_good ~= "medicine" and home_good ~= "luxury" then
										if home_good == good then
											match_away = true
											break
										end
									end
								end
								if not match_away then
									randomDeliverGood = good
									break
								end
							end
						end
					end 
				until(randomDeliverGood ~= nil or attempt_count > 50)
			end
			if randomDeliverGood == nil then
				plot4reminder = nil
				plot4delay = 100
				plot4 = delayef4v2
			else
				p:addToShipLog(string.format("[%s] We are running low on goods of type %s. Can you help? %s in %s should have some",homeStation:getCallSign(),randomDeliverGood,randomDeliverStation:getCallSign(),randomDeliverStation:getSectorName()),"85,107,47")
				plot4reminder = string.format("Bring %s to %s. Possible source: %s in %s",randomDeliverGood,homeStation:getCallSign(),randomDeliverStation:getCallSign(),randomDeliverStation:getSectorName())
				playSoundFile("sa_55_Manager2.wav")
			end
			randomDeliveryMsg = "sent"
		end
	end
end

function rotateUpgradeStart(delta)
	plot4name = "rotateUpgradeStart"
	infoPromised = true
	homeStationRotationEnabled = false
	rotateUpgradeAvailable = false
	plot4reminder = string.format("Upgrade %s to rotate",homeStation:getCallSign())
	if pickRotateBase == nil then
		repeat
			local candidate = stationList[math.random(13,#stationList)]
			if candidate ~= nil and candidate:isValid() then
				if candidate.comms_data.goods ~= nil then
					for good, good_detail in pairs(candidate.comms_data.goods) do
						if good ~= "food" and good ~= "medicine" then
							rotateBase = candidate
						end
					end
				end
			end
		until(rotateBase ~= nil)
		pickRotateBase = "done"
		plot4 = pickRotateGood
	end
end

function pickRotateGood(delta)
	plot4name = "pickRotateGood"
	if pickRotateGoodBase == nil then
		repeat
			local candidate = stationList[math.random(13,#stationList)]
			if candidate ~= nil and candidate:isValid() and candidate ~= rotateBase and candidate.comms_data.goods ~= nil then
				for good, good_detail in pairs(candidate.comms_data.goods) do
					if good ~= "food" and good ~= "medicine" and good ~= "luxury" then
						local match_away = false
						for good_rotate, good_rotate_detail in pairs(rotateBase.comms_data.goods) do
							if good_rotate ~= "food" and good_rotate ~= "medicine" and good_rotate ~= "luxury" then
								if good_rotate == good then
									match_away = true
									break
								end
							end
						end
						if not match_away then
							rotateGood = good
							rotateGoodBase = candidate
							break
						end
					end
				end
			end
		until(rotateGood ~= nil)
		plot4delay = 100
		plot4 = delayef4v2
		rotateReveal = 0
		rotateUpgradeAvailable = true
		pickRotateGoodBase = "done"
	end
end

function beamTimeUpgradeStart(delta)
	plot4name = "beamTimeUpgradeStart"
	infoPromised = true
	beamTimeUpgradeAvailable = false
	plot4reminder = "Get beam cycle time upgrade"
	if pickBeamTimeBase == nil then
		repeat
			candidate = stationList[math.random(13,#stationList)]
			if candidate ~= nil and candidate:isValid() and candidate.comms_data.goods ~= nil then
				for good, good_detail in pairs(candidate.comms_data.goods) do
					if good ~= "food" and good ~= "medicine" and good ~= "luxury" then
						beamTimeBase = candidate
					end
				end		
			end
		until(beamTimeBase ~= nil)
		pickBeamTimeBase = "done"
		plot4 = pickBeamTimeGood
	end
end

function pickBeamTimeGood(delta)
	plot4name = "pickBeamTimeGood"
	if pickBeamTimeGoodBase == nil then
		repeat
			candidate = stationList[math.random(13,#stationList)]
			if candidate ~= nil and candidate:isValid() and candidate ~= beamTimeBase and candidate.comms_data.goods ~= nil then
				for good, good_detail in pairs(candidate.comms_data.goods) do
					if good ~= "food" and good ~= "medicine" and good ~= "luxury" then
						local match_away = false
						for good_beam, good_beam_detail in pairs(beamTimeBase.comms_data.goods) do
							if good_beam ~= "food" and good_beam ~= "medicine" and good_beam ~= "luxury" then
								if good == good_beam then
									match_away = true
									break
								end
							end
						end
						if not match_away then
							beamTimeGood = good
							beamTimeGoodBase = candidate
							break
						end
					end
				end
			end
		until(beamTimeGood ~= nil)
		plot4 = cleanUpBeamTimers
		beamTimeReveal = 0
		beamTimeUpgradeAvailable = true
		pickBeamTimeGoodBase = "done"
	end
end

function cleanUpBeamTimers(delta)
	plot4name = "cleanUpBeamTimers"
	noBeamTimeCount = 0
	for pidx=1,8 do
		pc = getPlayerShip(pidx)
		if pc ~= nil and pc:isValid() then
			if not pc.beamTimeUpgrade then
				noBeamTimeCount = noBeamTimeCount + 1
			end
		end
	end
	if noBeamTimeCount == 0 then
		plot4reminder = nil
		plot4name = nil
		plot4delay = 100
		plot4 = delayef4v2
		p = closestPlayerTo(targetEnemyStation)
		p:addReputationPoints(20)
	end	
end

function hullUpgradeStart(delta)
	plot4name = "hullUpgradeStart"
	infoPromised = true
	hullUpgradeAvailable = false
	plot4reminder = "Get hull upgrade"
	if pickHullBase == nil then
		repeat
			candidate = stationList[math.random(13,#stationList)]
			if candidate ~= nil and candidate:isValid() and candidate.comms_data.goods ~= nil then
				for good, good_detail in pairs(candidate.comms_data.goods) do
					if good ~= "food" and good ~= "medicine" and good ~= "luxury" then
						hullBase = candidate
					end
				end
			end
		until(hullBase ~= nil)
		pickHullBase = "done"
		plot4 = pickHullGood
	end
end

function pickHullGood(delta)
	plot4name = "pickHullGood"
	if pickHullGoodBase == nil then
		repeat
			candidate = stationList[math.random(13,#stationList)]
			if candidate ~= nil and candidate:isValid() and candidate ~= hullBase and candidate.comms_data.goods ~= nil then
				for good, good_detail in pairs(candidate.comms_data.goods) do
					if good ~= "food" and good ~= "medicine" and good ~= "luxury" then
						local match_away = false
						for good_hull, good_hull_detail in pairs(hullBase.comms_data.goods) do
							if good_hull ~= "food" and good_hull ~= "medicine" and good_hull ~= "luxury" then
								if good == good_hull then
									match_away = true
									break
								end
							end
						end
						if not match_away then
							hullGood = good
							hullGoodBase = candidate
							break
						end
					end
				end
			end
		until(hullGood ~= nill)
		plot4 = cleanUpHullers
		hullReveal = 0
		hullUpgradeAvailable = true
		pickhullGoodBase = "done"
	end
end

function cleanUpHullers(delta)
	plot4name = "cleanUpHullers"
	noHullCount = 0
	for pidx=1,8 do
		pc = getPlayerShip(pidx)
		if pc ~= nil and pc:isValid() then
			if not pc.hullUpgrade then
				noHullCount = noHullCount + 1
			end
		end
	end
	if noHullCount == 0 then
		plot4reminder = nil
		plot4delay = 100
		plot4 = delayef4v2
		p = closestPlayerTo(targetEnemyStation)
		p:addReputationPoints(20)
	end	
end

function delayef4v2(delta)
	plot4name = "delayef4v2"
	plot4delay = plot4delay - delta
	if plot4delay < 0 then
		p = closestPlayerTo(targetEnemyStation)
		px, py = p:getPosition()
		ambushAngle = random(0,360)
		a1x, a1y = vectorFromAngle(ambushAngle,random(30000,40000))
		ef4v2 = spawnEnemies(px+a1x,py+a1y,dangerValue/2,targetEnemyStation:getFaction())
		for _, enemy in ipairs(ef4v2) do
			enemy:orderAttack(p)
		end
		a1x, a1y = vectorFromAngle(ambushAngle+random(60,120),random(30000,40000))
		ntf = spawnEnemies(px+a1x,py+a1y,dangerValue/2,targetEnemyStation:getFaction())
		for _, enemy in ipairs(ntf) do
			enemy:orderAttack(p)
			table.insert(ef4v2,enemy)
		end
		a1x, a1y = vectorFromAngle(ambushAngle+random(180,300),random(30000,40000))
		ntf = spawnEnemies(px+a1x,py+a1y,dangerValue/2,targetEnemyStation:getFaction())
		for _, enemy in ipairs(ntf) do
			enemy:orderAttack(p)
			table.insert(ef4v2,enemy)
		end
		plot4 = destroyef4v2
	end
end
-- random plot 4 development after enemy fleet for plot 4 version 2 is destroyed
function destroyef4v2(delta)
	plot4name = "destroyef4v2"
	ef4Count = 0
	for _, enemy in ipairs(ef4v2) do
		if enemy:isValid() then
			ef4Count = ef4Count + 1
		end
	end
	if ef4Count == 0 then
		choooseNextPlot4line()
	end
end

function choooseNextPlot4line()
	plot4reminder = nil
	if #plot4choices > 0 then
		p4c = math.random(1,#plot4choices)
		plot4 = plot4choices[p4c]
		table.remove(plot4choices,p4c)
		plot4delayTimer = random(40,120)
	else
		plot4 = nil
	end
end

function insertAgentDelay(delta)
	plot4name = "insertAgentDelay"
	plot4delayTimer = plot4delayTimer - delta
	if plot4delayTimer < 0 then
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				p:addToShipLog(string.format("Agent Paul Straight has information on enemies in the area and a proposal. Pick him and his equipment up at station %s",homeStation:getCallSign()),"Magenta")
				plot4reminder = string.format("Get Paul Straight at station %s",homeStation:getCallSign())
			end
		end
		plot4 = getAgentStraight
	end
end

function getAgentStraight(delta)
	plot4name = "getAgentStraight"
	for pidx=1,8 do
		p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() and p:isDocked(homeStation) then
			p.straight = true
			if #enemyStationList > 0 then
				for eidx=1,#enemyStationList do
					if enemyStationList[eidx]:isValid() then
						insertEnemyStation = enemyStationList[eidx]
						break
					end
				end
			end
			p:addToShipLog(string.format("[Paul Straight] I've been studying enemy station %s in %s: traffic patterns, communication traffic, energy signature, etc. I've built a specialized short range transporter that should be able to beam me onto the station through their shields. I need to get refined readings from 20 units or closer for final calibration. Please take me to within 20 units of %s",insertEnemyStation:getCallSign(),insertEnemyStation:getSectorName(),insertEnemyStation:getCallSign()),"95,158,160")
			plot4reminder = string.format("Take Paul Straight to within 20U of %s in %s",insertEnemyStation:getCallSign(),insertEnemyStation:getSectorName())
			plot4 = scanEnemyStation
			break
		end
	end
end

function scanEnemyStation(delta)
	plot4name = "scanEnemyStation"
	if insertEnemyStation:isValid() then
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() and p.straight then
				if distance(p,insertEnemyStation) <= 20000 then
					insertRunDelayTimer = 15
					p:addToShipLog("[Paul Straight] I've got my readings. Let me calibrate the transporter","95,158,160")
					if p:hasPlayerAtPosition("Helms") then
						inRangeMsg = "inRangeMsg"
						p:addCustomMessage("Helms",inRangeMsg,"[Paul Straight] The ship is in range. I completed my scans. Thank you")
					end
					if p:hasPlayerAtPosition("Tactical") then
						inRangeMsgTactical = "inRangeMsgTactical"
						p:addCustomMessage("Tactical",inRangeMsgTactical,"[Paul Straight] The ship is in range. I completed my scans. Thank you")
					end
					plot4 = insertRunDelay
				end
			end
		end
	else
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() and p.straight then
				p:addToShipLog("[Paul Straight] It's too bad the station was destroyed","95,158,160")
				choooseNextPlot4line()
				break
			end
		end
	end
end

function insertRunDelay(delta)
	plot4name = "insertRunDelay"
	insertRunDelayTimer = insertRunDelayTimer - delta
	if insertRunDelayTimer < 0 then
		if insertEnemyStation:isValid() then
			for pidx=1,8 do
				p = getPlayerShip(pidx)
				if p ~= nil and p:isValid() and p.straight then
					p:addToShipLog(string.format("[Paul Straight] My transporter is ready. I've disguised myself as a Kraylor technician. I need you to take the ship within 2.5U of %s. You don't need to defeat any patrols, but there might be some enemy interest in your ship flying so close to the station. After I am aboard %s, I will gether intelligence and transmit it back. I'm ready to proceed",insertEnemyStation:getCallSign(),insertEnemyStation:getCallSign()),"95,158,160")
					plot4reminder = string.format("Get ship within 2.5U of %s in %s to secretly transport Paul Straight",insertEnemyStation:getCallSign(),insertEnemyStation:getSectorName())
					plot4 = insertRun
					break
				end
			end
		else
			for pidx=1,8 do
				p = getPlayerShip(pidx)
				if p ~= nil and p:isValid() and p.straight then
					p:addToShipLog("[Paul Straight] It's too bad the station was destroyed","95,158,160")
					choooseNextPlot4line()
					break
				end
			end
		end
	end
end

function insertRun(delta)
	plot4name = "insertRun"
	if insertEnemyStation:isValid() then
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() and p.straight then
				if distance(p,insertEnemyStation) <= 2500 then
					if p:hasPlayerAtPosition("Science") then
						straightTransportedMsg = "straightTransportedMsg"
						p:addCustomMessage("Science",straightTransportedMsg,string.format("Paul Straight has transported aboard %s",insertEnemyStation:getCallSign()))
					end
					if p:hasPlayerAtPosition("Operations") then
						straightTransportedMsgOps = "straightTransportedMsgOps"
						p:addCustomMessage("Operations",straightTransportedMsgOps,string.format("Paul Straight has transported aboard %s",insertEnemyStation:getCallSign()))
					end
					plot4 = resultDelay
					plot4reminder = string.format("Await intelligence results from Paul Straight on %s",insertEnemyStation:getCallSign())
					resultDelayTimer = random(30,60)
				end
			end
		end
	else
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() and p.straight then
				p:addToShipLog("[Paul Straight] It's too bad the station was destroyed","95,158,160")
				choooseNextPlot4line()
				break
			end
		end
	end
end

function resultDelay(delta)
	plot4name = "resultDelay"
	if insertEnemyStation:isValid() then
		resultDelayTimer = resultDelayTimer - delta
		if resultDelayTimer < 0 then
			locationResultMsg = "[Paul Straight] I discovered the location of the enemy bases in the area:"
			for eidx=1,#enemyStationList do
				if enemyStationList[eidx]:isValid() then
					locationResultMsg = locationResultMsg .. string.format("\n%s in %s",enemyStationList[eidx]:getCallSign(),enemyStationList[eidx]:getSectorName())
				end
			end
			p = closestPlayerTo(insertEnemyStation)
			p:addToShipLog(locationResultMsg,"95,158,160")
			resultDelay2Timer = random(120,240)
			plot4 = resultDelay2
		end
	else
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() and p.straight then
				if p:hasPlayerAtPosition("Science") then
					fatalMsg = "fatalMsg"
					p:addCustomMessage("Science",fatalMsg,"Lifesign telemetry from Paul Straight's equipment has ceased")
				end
				if p:hasPlayerAtPosition("Operations") then
					fatalMsgOps = "fatalMsgOps"
					p:addCustomMessage("Operations",fatalMsgOps,"Lifesign telemetry from Paul Straight's equipment has ceased")
				end
			end
		end
		choooseNextPlot4line()
	end
end

function resultDelay2(delta)
	plot4name = "resultDelay2"
	if insertEnemyStation:isValid() then
		resultDelay2Timer = resultDelay2Timer - delta
		if resultDelay2Timer < 0 then
			p = closestPlayerTo(insertEnemyStation)
			p:addToShipLog(string.format("[Paul Straight] Prefect Ghalantor is on station %s. Wait, someone is coming...",targetEnemyStation:getCallSign()),"95,158,160")
			straightExecutionTimer = random(40,80)
			plot4 = straightExecution
		end
	else
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() and p.straight then
				if p:hasPlayerAtPosition("Science") then
					fatalMsg = "fatalMsg"
					p:addCustomMessage("Science",fatalMsg,"Lifesign telemetry from Paul Straight's equipment has ceased")
				end
				if p:hasPlayerAtPosition("Operations") then
					fatalMsgOps = "fatalMsgOps"
					p:addCustomMessage("Operations",fatalMsgOps,"Lifesign telemetry from Paul Straight's equipment has ceased")
				end
			end
		end
		choooseNextPlot4line()
	end
end

function straightExecution(delta)
	plot4name = "straightExecution"
	if insertEnemyStation:isValid() then
		straightExecutionTimer = straightExecutionTimer - delta
		if straightExecutionTimer < 0 then
			p = closestPlayerTo(insertEnemyStation)
			insertEnemyStation:sendCommsMessage(p,"We discovered your perfidious spy aboard our station. He will be executed for his treasonous activities")
			plot4 = agentDemise
			agentDemiseTimer = random (40,80)
		end
	else
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() and p.straight then
				if p:hasPlayerAtPosition("Science") then
					fatalMsg = "fatalMsg"
					p:addCustomMessage("Science",fatalMsg,"Lifesign telemetry from Paul Straight's equipment has ceased")
				end
				if p:hasPlayerAtPosition("Operations") then
					fatalMsgOps = "fatalMsgOps"
					p:addCustomMessage("Operations",fatalMsgOps,"Lifesign telemetry from Paul Straight's equipment has ceased")
				end
			end
		end
		choooseNextPlot4line()
	end
end

function agentDemise(delta)
	plot4name = "agentDemise"
	if insertEnemyStation:isValid() then
		agentDemiseTimer = agentDemiseTimer - delta
		if agentDemiseTimer < 0 then
			for pidx=1,8 do
				p = getPlayerShip(pidx)
				if p ~= nil and p:isValid() and p.straight then
					if p:hasPlayerAtPosition("Science") then
						fatalMsg = "fatalMsg"
						p:addCustomMessage("Science",fatalMsg,"Lifesign telemetry from Paul Straight's equipment has ceased")
					end
					if p:hasPlayerAtPosition("Operations") then
						fatalMsgOps = "fatalMsgOps"
						p:addCustomMessage("Operations",fatalMsgOps,"Lifesign telemetry from Paul Straight's equipment has ceased")
					end
				end
			end
			choooseNextPlot4line()
		end
	else
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() and p.straight then
				if p:hasPlayerAtPosition("Science") then
					fatalMsg = "fatalMsg"
					p:addCustomMessage("Science",fatalMsg,"Lifesign telemetry from Paul Straight's equipment has ceased")
				end
				if p:hasPlayerAtPosition("Operations") then
					fatalMsgOps = "fatalMsgOps"
					p:addCustomMessage("Operations",fatalMsgOps,"Lifesign telemetry from Paul Straight's equipment has ceased")
				end
			end
		end
		choooseNextPlot4line()
	end
end

function repairBountyDelay(delta)
	plot4name = "repairBountyDelay"
	plot4delayTimer = plot4delayTimer - delta
	if plot4delayTimer < 0 then
		hx, hy = homeStation:getPosition()
		ex, ey = targetEnemyStation:getPosition()
		bx, by = vectorFromAngle(random(0,360),6000)
		hmsBounty = CpuShip():setFaction("Human Navy"):setTemplate("Stalker Q7"):setScanned(true)
		hmsBounty:setSystemHealth("warp", -0.5):setCommsScript(""):setCommsFunction(commsShip)
		hmsBounty:setSystemHealth("impulse", 0.5):setCallSign("HMS Bounty"):orderStandGround()
		hmsBounty:setSystemHealth("jumpdrive", -0.5):setPosition(((hx+ex)/2)+bx,((hy+ey)/2)+by)
		hmsBounty.repaired = false
		p = closestPlayerTo(hmsBounty)
		p:addToShipLog(string.format("[HMS Bounty] We stole a Kraylor ship, but were damaged during the escape. Can you help? We are in %s",hmsBounty:getSectorName()),"#ff4500")
		plot4reminder = string.format("Help HMS Bounty in %s",hmsBounty:getSectorName())
		ntf = spawnEnemies((hx+ex)/2,(hy+ey)/2,dangerValue,targetEnemyStation:getFaction())
		for _, enemy in ipairs(ntf) do
			enemy:orderAttack(hmsBounty)
		end
		plot4 = repairBounty
	end
end

function repairBounty(delta)
	p = closestPlayerTo(hmsBounty)
	if hmsBounty:isValid() then
		if distance(p,hmsBounty) < 2500 then
			p:addToShipLog("[HMS Bounty] Please ask your engineer to transport a spare repair technician to help with repairs","#ff4500")
			if p:hasPlayerAtPosition("Engineering") then
				transportRepairTechnicianButton = "transportRepairTechnicianButton"
				p:addCustomButton("Engineering",transportRepairTechnicianButton,"Transport technician",transportRepairTechnician)
			end
			if p:hasPlayerAtPosition("Engineering+") then
				transportRepairTechnicianButtonPlus = "transportRepairTechnicianButtonPlus"
				p:addCustomButton("Engineering+",transportRepairTechnicianButtonPlus,"Transport technician",transportRepairTechnician)
			end
			p.transportButton = true
			plot4 = nil
		end
	else
		p:addToShipLog("HMS Bounty has been destroyed","Magenta")
		plot4 = nil
		plot4reminder = nil
	end
end

function transportRepairTechnician()
	hmsBounty:setSystemHealth("warp",1)
	hmsBounty:setSystemHealth("impulse",1)
	for pidx=1,8 do
		p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			if p.transportButton then
				if transportRepairTechnicianButton ~= nil then
					p:removeCustom(transportRepairTechnicianButton)
				end
				if transportRepairTechnicianButtonPlus ~= nil then
					p:removeCustom(transportRepairTechnicianButtonPlus)
				end
				p:addToShipLog("[HMS Bounty] Our engines have been repaired. We stand ready to assist","#ff4500")
			end
		end
	end
	choooseNextPlot4line()
end

function stationShieldDelay(delta)
	plot4name = "stationShieldDelay"
	plot4delayTimer = plot4delayTimer - delta
	if plot4delayTimer < 0 then
		repeat
			candidate = stationList[math.random(13,#stationList)]
			if candidate ~= nil and candidate:isValid() then
				shieldExpertStation = candidate
			end
		until(shieldExpertStation ~= nil)
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				p:addToShipLog(string.format("Intelligence analysis shows research on the network that could double the shield strength of station %s. The analysis shows that the technical expert can be found on station %s in sector %s",homeStation:getCallSign(),shieldExpertStation:getCallSign(),shieldExpertStation:getSectorName()),"Magenta")
			end
		end
		playSoundFile("sa_55_Commander3.wav")
		plot4reminder = string.format("Find shield expert at station %s in %s",shieldExpertStation:getCallSign(),shieldExpertStation:getSectorName())
		plot4 = visitShieldExpertStation
	end
end

function visitShieldExpertStation(delta)
	plot4name = "visitShieldExpertStation"
	if shieldExpertTransport == nil then
		repeat
			candidate = transportList[math.random(1,#transportList)]
			if candidate ~= nil and candidate:isValid() then
				shieldExpertTransport = candidate
			end
		until(shieldExpertTransport ~= nil)
	end
	if shieldExpertStation:isValid() then
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				if p:isDocked(shieldExpertStation) then
					p:addToShipLog(string.format("We heard you were looking for our former shield maintenance technician, Maria Shrivner who's been publishing hints about advances in shield technology. We've been looking for her. We only just found out that she left the station after a severe romantic breakup with her supervisor. She took a job on a freighter %s which was last reported in %s",shieldExpertTransport:getCallSign(),shieldExpertTransport:getSectorName()),"#ba55d3")
					plot4 = meetShieldExportTransportHeartbroken
					plot4reminder = string.format("Meet transport %s last reported in %s to find Maria Shrivner",shieldExpertTransport:getCallSign(),shieldExpertTransport:getSectorName())
					playSoundFile("sa_55_BaseChief.wav")
				end
			end
		end
	else
		if shieldExpertTransport:isValid() then
			for pidx=1,8 do
				p = getPlayerShip(pidx)
				if p ~= nil and p:isValid() then
					p:addToShipLog(string.format("We received word that station %s has been destroyed. However, in some of their final records we see that Maria Shrivner left the station to take a job on freighter %s which was last reported in %s",shieldExpertTransport:getCallSign(),shieldExpertTransport:getSectorName()),"Magenta")
					plot4 = meetShieldExportTransport
					plot4reminder = stringFormat("Meet transport %s last reported in %s to find Maria Shrivner",shieldExpertTransport:getCallSign(),shieldExpertTransport:getSectorName())
				end
			end
		else
			for pidx=1,8 do
				p = getPlayerShip(pidx)
				if p ~= nil and p:isValid() then
					p:addToShipLog("Station %s has been destroyed leaving no hints for shield upgrade followup","Magenta")
				end
			end
			choooseNextPlot4line()
		end
	end
end

function meetShieldExportTransport(delta)
	plot4name = "meetShieldExportTransport"
	for pidx=1,8 do
		p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			if distance(p,shieldExpertTransport) < 500 then
				p.shieldExpert = true
				p:addToShipLog(string.format("[Maria Shrivner] It was tragic that %s was destroyed. Bring me to %s and I'll double %s's shield effectiveness",shieldExpertStation:getCallSign(),homeStation:getCallSign(),homeStation:getCallSign()),"Yellow")
				playSoundFile("sa_55_Maria1.wav")
				plot4 = returnHomeForShields
				plot4reminder = "Return to home base with Maria Shrivner to double shield capacity"
				break
			end
		end
	end
end

function meetShieldExportTransportHeartbroken(delta)
	plot4name = "meetShieldExportTransportHeartbroken"
	for pidx=1,8 do
		p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			if distance(p,shieldExpertTransport) < 500 then
				p.shieldExpert = true
				p:addToShipLog(string.format("[Maria Shrivner] I should not have broken up with him, it was all a misunderstanding. Help me get him some rare material as a gift and I'll double %s's shield effectiveness",homeStation:getCallSign()),"Yellow")
				playSoundFile("sa_55_Maria2.wav")
				plot4 = giftForBeau
				beauGift = false
				plot4reminder = string.format("Get gold, platinum, dilithium, tritanium or cobalt and bring it and Maria Shrivner to %s",shieldExpertStation:getCallSign())
				break
			end
		end
	end
end

function giftForBeau(delta)
	plot4name = "giftForBeau"
	if shieldExpertStation:isValid() then
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				if p:isDocked(shieldExpertStation) then
					if p.shieldExpert then
						if beauGift then
							p:addToShipLog(string.format("[Maria Shrivner] Well, he's at least thinking about it. He liked the gift. Take me to %s and let's get those shields upgraded",homeStation:getCallSign()),"Yellow")
							playSoundFile("sa_55_Maria3.wav")
							plot4 = returnHomeForShields
							plot4reminder = "Return to home base with Maria Shrivner to double shield capacity"
						end
					end
				end
			end
		end
	else
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				p:addToShipLog(string.format("We were just notified that station %s has been destroyed",shieldExpertStation:getCallSign()),"Magenta")
				if p.shieldExpert then
					p:addToShipLog(string.format("[Maria Shrivner] Oh no! I'm too late! Now we'll never be reconciled. *sniff* Well, the least I can do is upgrade %s's shields. Take me there and I'll double %s's shield capacity",homeStation:getCallSign(),homeStation:getCallSign()),"Yellow")
					playSoundFile("sa_55_Maria4.wav")
					plot4 = returnHomeForShields
					plot4reminder = "Return to home base with Maria Shrivner to double shield capacity"
				end
			end
		end
	end
end

function returnHomeForShields(delta)
	plot4name = "returnHomeForShields"
	for pidx=1,8 do
		p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			if p:isDocked(homeStation) then
				if homeStation.shieldUpgrade == nil then
					if p.shieldExpert then
						newMax = homeStation:getShieldMax(0)*2
						if homeStation:getShieldCount() == 1 then
							homeStation:setShieldsMax(newMax)
						end
						if homeStation:getShieldCount() == 3 then
							homeStation:setShieldsMax(newMax,newMax,newMax)
						end
						if homeStation:getShieldCount() == 4 then
							homeStation:setShieldsMax(newMax,newMax,newMax,newMax)
						end
					end
					p:addToShipLog(string.format("[Maria Shrivner] %s's shield capacity has been doubled. They should charge up to their new capacity eventually",homeStation:getCallSign()),"Yellow")
					playSoundFile("sa_55_Maria5.wav")
					choooseNextPlot4line()
					homeStation.shieldUpgrade = true
				end
			end
		end
	end
end
-------------------------------
--  Plot 5 Helpful warnings  --
-------------------------------
function helpfulWarning(delta)
	plot5name = "helpfulWarning"
	helpfulWarningTimer = helpfulWarningTimer - delta
	if helpfulWarningTimer < 0 then
		warningProvided = false
		for i=1,#stationList do
			if stationList[i]:isValid() then
				p = closestPlayerTo(stationList[i])
				if p ~= nil then
					for _, obj in ipairs(stationList[i]:getObjectsInRange(30000)) do
						if obj:isEnemy(p) then
							local detected_enemy_ship = false
							local obj_type_name = obj.typeName
							if obj_type_name ~= nil then
								if string.find(obj_type_name,"CpuShip") then
									detected_enemy_ship = true
								end
							end
							--tempObjType = obj:getTypeName()
							--if not string.find(tempObjType,"Station") then
							if detected_enemy_ship then
								wMsg = string.format("[%s] Our sensors detect enemies nearby",stationList[i]:getCallSign())
								if diagnostic or difficulty < 1 then
									wMsg = wMsg .. string.format(" - Type: %s",obj:getTypeName())
								end
								p:addToShipLog(wMsg,"Red")
								if i == 1 then
									if helpfulWarningDiagnostic then print("home station warning details") end
									local stationShields = homeStation:getShieldCount()
									if helpfulWarningDiagnostic then print("number of shields around home station: " .. stationShields) end
									local shieldsDamaged = false
									if stationShields == 1 then
										if helpfulWarningDiagnostic then print("station has only one shield") end
										local sLevel = homeStation:getShieldLevel(0)
										if helpfulWarningDiagnostic then print("shield level for the one shield: " .. sLevel) end
										local sMax = homeStation:getShieldMax(0)
										if helpfulWarningDiagnostic then print("shield maximum for the one shield: " .. sMax) end
										if sLevel < sMax then
											if helpfulWarningDiagnostic then print("shield not fully charged") end
											sLine = string.format("   Shield: %.1f%% (%.1f/%.1f) ",sLevel/sMax*100,sLevel,sMax)
											shieldsDamaged = true
										end
									else
										if helpfulWarningDiagnostic then print("station has multiple shields") end
										sdMsg = string.format("   Shield count: %i ",stationShields)
										if helpfulWarningDiagnostic then print("about to start shield loop") end
										shieldStatusLines = {}
										for j=1,stationShields do
											if helpfulWarningDiagnostic then print(string.format("loop index: %i, shield number: %i",j,j-1)) end
											sLevel = homeStation:getShieldLevel(j-1)
											if helpfulWarningDiagnostic then print("shield level: " .. sLevel) end
											sMax = homeStation:getShieldMax(j-1)
											if helpfulWarningDiagnostic then print("max: " .. sMax) end
											if sLevel < sMax then
												if helpfulWarningDiagnostic then print("shield not fully charged") end
												sLine = string.format("      Shield %i: %i%% (%.1f/%i) ",j,math.floor(sLevel/sMax*100),sLevel,sMax)
												table.insert(shieldStatusLines,sLine)
												shieldsDamaged = true
											end
										end
									end
									if shieldsDamaged then
										p:addToShipLog("Station Status:","Red")
										if stationShields == 1 then
											p:addToShipLog(sLine,"Red")
										else
											for k=1,#shieldStatusLines do
												p:addToShipLog(shieldStatusLines[k],"Red")
											end
										end
									end
									if helpfulWarningDiagnostic then print("Done with shield status, check hull status") end
									hl = homeStation:getHull()
									if helpfulWarningDiagnostic then print("current hull: " .. hl) end
									hm = homeStation:getHullMax()
									if helpfulWarningDiagnostic then print("max hull: " .. hm) end
									if hl < hm then
										if helpfulWarningDiagnostic then print("hull not fully repaired") end
										if not shieldsDamaged then
											p:addToShipLog("Station Status:","Red")										
										end
										local hLine = string.format("   Hull: %i%% (%.1f/%i)",math.floor(hl/hm*100),hl,hm)
										p:addToShipLog(hLine,"Red")
									end
								end
								warningProvided = true
								break
							end
						end
					end
				end
			end
			if warningProvided then
				break
			end
		end
		helpfulWarningTimer = delta + random(90,200)
	end
end
-------------------------
--  Plot 6 Timed Game  --
-------------------------
function timedGame(delta)
	gameTimeLimit = gameTimeLimit - delta
	if gameTimeLimit < 0 then
		if string.find(getScenarioVariation(),"Defender") then
			missionVictory = true
			endStatistics()
			victory("Human Navy")
		else
			missionVictory = false
			endStatistics()
			victory("Kraylor")
		end
	end
end
-----------------------------------------------------------------
--  Plot W - wormhole starts as an artifact in unusual motion  --
-----------------------------------------------------------------
function setWormArt()
	wormArt = Artifact():setPosition(random(-90000,90000),random(-90000,90000)):setModel("artifact4"):allowPickup(false):setScanningParameters(2,5)
	wormArt:setDescriptions("sprightly unassuming object","Object shows rapidly building energy"):setRadarSignatureInfo(50,10,5)
	wormArt.travelAngle = random(0,360)
	wormArt.tempAngle = -90
	wormArt.travel = 5
	plotW = moveWormArt
end

function moveWormArt(delta)
	plotWname = "moveWormArt"
	if wormArt:isScannedByFaction("Human Navy") then
		wormDelayTimer = 5
		plotW = wormBirth
	end
	p = closestPlayerTo(wormArt)
	if p ~= nil then
		if distance(p,wormArt) > 5000 then
			wax, way = wormArt:getPosition()
			angleChange = false
			if wax < -100000 then
				angleChange = true
				wormArt.travelAngle = random(0,180) + 270
			end
			if wax > 100000 then
				angleChange = true
				wormArt.travelAngle = random(90,270)
			end
			if way < -100000 then
				angleChange = true
				wormArt.travelAngle = random(0,180)
			end
			if way > 100000 then
				angleChange = true
				wormArt.travelAngle = random(180,360)
			end
			if angleChange then
				wadx, wady = vectorFromAngle(wormArt.travelAngle,wormArt.travel+20)
				wormArt:setPosition(wax+wadx,way+wady)
			else
				wadx, wady = vectorFromAngle(wormArt.travelAngle + wormArt.tempAngle,wormArt.travel)
				wormArt:setPosition(wax+wadx,way+wady)
				wormArt.tempAngle = wormArt.tempAngle + 1
				if wormArt.tempAngle > 90 then
					wormArt.tempAngle = -90
				end
			end
		end
	end
end

function wormBirth(delta)
	plotWname = "wormBirth"
	wormDelayTimer = wormDelayTimer - delta
	if wormDelayTimer < 0 then
		wax, way = wormArt:getPosition()
		wormArt:explode()
		plotW = wormBirth2
		wormDelayTimer2 = 5
	end
end

function wormBirth2(delta)
	plotWname = "wormBirth2"
	wormDelayTimer2 = wormDelayTimer2 - delta
	if wormDelayTimer2 < 0 then
		ElectricExplosionEffect():setPosition(wax,way):setSize(5000)
		wormDelayTimer3 = 5
		plotW = wormBirth3
	end
end

function wormBirth3(delta)
	plotWname = "wormBirth3"
	wormDelayTimer3 = wormDelayTimer3 - delta
	if wormDelayTimer3 < 0 then
		wdx, wdy = vectorFromAngle(random(0,360),random(200000,300000))
		WormHole():setPosition(wax,way):setTargetPosition(wax+wdx,way+wdy)
		plotW = nil
	end
end

------------------------------------
--	Generic or utility functions  --
------------------------------------
function spawnEnemies(xOrigin, yOrigin, danger, enemyFaction)
	if enemyFaction == nil then
		enemyFaction = "Kraylor"
	end
	if danger == nil then 
		danger = 1
	end
	enemyStrength = math.max(danger * difficulty * playerPower(),5)
	enemyPosition = 0
	sp = irandom(300,500)			--random spacing of spawned group
	deployConfig = random(1,100)	--randomly choose between squarish formation and hexagonish formation
	enemyList = {}
	-- Reminder: stsl and stnl are ship template score and name list
	while enemyStrength > 0 do
		shipTemplateType = irandom(1,#stsl)
		while stsl[shipTemplateType] > enemyStrength * 1.1 + 5 do
			shipTemplateType = irandom(1,#stsl)
		end		
		ship = CpuShip():setFaction(enemyFaction):setTemplate(stnl[shipTemplateType]):orderRoaming()
		enemyPosition = enemyPosition + 1
		if deployConfig < 50 then
			ship:setPosition(xOrigin+fleetPosDelta1x[enemyPosition]*sp,yOrigin+fleetPosDelta1y[enemyPosition]*sp)
		else
			ship:setPosition(xOrigin+fleetPosDelta2x[enemyPosition]*sp,yOrigin+fleetPosDelta2y[enemyPosition]*sp)
		end
		table.insert(enemyList, ship)
		enemyStrength = enemyStrength - stsl[shipTemplateType]
	end
	return enemyList
end
--evaluate the players for enemy strength and size spawning purposes
function playerPower()
	playerShipScore = 0
	for p5idx=1,8 do
		p5obj = getPlayerShip(p5idx)
		if p5obj ~= nil and p5obj:isValid() then
			if p5obj.shipScore == nil then
				playerShipScore = playerShipScore + 24
			else
				playerShipScore = playerShipScore + p5obj.shipScore
			end
		end
	end
	return playerShipScore
end
-- Create amount of objects of type object_type along arc
-- Center defined by x and y
-- Radius defined by distance
-- Start of arc between 0 and 360 (startArc), end arc: endArcClockwise
-- Use randomize to vary the distance from the center point. Omit to keep distance constant
-- Example:
--   createRandomAlongArc(Asteroid, 100, 500, 3000, 65, 120, 450)
function createRandomAlongArc(object_type, amount, x, y, distance, startArc, endArcClockwise, randomize)
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
function placeRandomAsteroidsAroundPoint(amount, dist_min, dist_max, x0, y0)
-- create amount of asteroid, at a distance between dist_min and dist_max around the point (x0, y0)
    for n=1,amount do
        local r = random(0, 360)
        local distance = random(dist_min, dist_max)
        x = x0 + math.cos(r / 180 * math.pi) * distance
        y = y0 + math.sin(r / 180 * math.pi) * distance
        local asteroid_size = random(1,100) + random(1,75) + random(1,75) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20)
        Asteroid():setPosition(x, y):setSize(asteroid_size)
    end
end
function createRandomAsteroidAlongArc(amount, x, y, distance, startArc, endArcClockwise, randomize)
-- Create amount of asteroids along arc
-- Center defined by x and y
-- Radius defined by distance
-- Start of arc between 0 and 360 (startArc), end arc: endArcClockwise
-- Use randomize to vary the distance from the center point. Omit to keep distance constant
-- Example:
--   createRandomAsteroidAlongArc(100, 500, 3000, 65, 120, 450)
	if randomize == nil then randomize = 0 end
	if amount == nil then amount = 1 end
	local arcLen = endArcClockwise - startArc
	if startArc > endArcClockwise then
		endArcClockwise = endArcClockwise + 360
		arcLen = arcLen + 360
	end
    local asteroid_size = random(1,100) + random(1,75) + random(1,75) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20)
	if amount > arcLen then
		for ndex=1,arcLen do
			local radialPoint = startArc+ndex
			local pointDist = distance + random(-randomize,randomize)
		    asteroid_size = random(1,100) + random(1,75) + random(1,75) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20)
			Asteroid():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist):setSize(asteroid_size)
		end
		for ndex=1,amount-arcLen do
			radialPoint = random(startArc,endArcClockwise)
			pointDist = distance + random(-randomize,randomize)
		    asteroid_size = random(1,100) + random(1,75) + random(1,75) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20)
			Asteroid():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist):setSize(asteroid_size)
		end
	else
		for ndex=1,amount do
			radialPoint = random(startArc,endArcClockwise)
			pointDist = distance + random(-randomize,randomize)
		    asteroid_size = random(1,100) + random(1,75) + random(1,75) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20)
			Asteroid():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist):setSize(asteroid_size)
		end
	end
end
-- Return the player ship closest to passed object parameter
-- Return nil if no valid result
-- Assumes a maximum of 8 player ships
function closestPlayerTo(obj)
	if obj ~= nil and obj:isValid() then
		local closestDistance = 9999999
		closestPlayer = nil
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				local currentDistance = distance(p,obj)
				if currentDistance < closestDistance then
					closestPlayer = p
					closestDistance = currentDistance
				end
			end
		end
		return closestPlayer
	else
		return nil
	end
end
-- Return the player ship farthest from the passed object parameter
function farthestPlayerFrom(obj)
	if obj ~= nil and obj:isValid() then
		local farthestDistance = 0
		farthestPlayer = nil
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				local currentDistance = distance(p,obj)
				if currentDistance > farthestDistance then
					farthestPlayer = p
					farthestDistance = currentDistance
				end
			end
		end
		return farthestPlayer
	else
		return nil
	end
end
-- Return station closest to object
function closestStationTo(obj)
	if obj ~= nil and obj :isValid() then
		local closestDistance = 9999999
		closestStation = nil
		for sidx=1,#stationList do
			s = stationList[sidx]
			if s ~= nil and s:isValid() and s ~= obj then
				local currentDistance = distance(s,obj)
				if currentDistance < closestDistance then
					closestStation = s
					closestDistance = currentDistance
				end
			end
		end
		return closestStation
	else
		return nil
	end
end
-- Return the station farthest from object
function farthestStationTo(obj)
	if obj ~= nil and obj :isValid() then
		local farthestDistance = 0
		farthestStation = nil
		for sidx=1,#stationList do
			s = stationList[sidx]
			if s ~= nil and s:isValid() and s ~= obj then
				local currentDistance = distance(s,obj)
				if currentDistance > farthestDistance then
					farthestStation = s
					farthestDistance = currentDistance
				end
			end
		end
		return farthestStation
	else
		return nil
	end
end
--set up players with name, goods, cargo space, reputation and either a warp drive or a jump drive if applicable
function setPlayers()
	concurrentPlayerCount = 0
	for p1idx=1,8 do
		pobj = getPlayerShip(p1idx)
		if pobj ~= nil and pobj:isValid() then
			concurrentPlayerCount = concurrentPlayerCount + 1
			if goods[pobj] == nil then
				goods[pobj] = goodsList
			end
			if pobj.initialRep == nil then
				pobj:addReputationPoints(180-(difficulty*6))
				pobj.initialRep = true
			end
			if not pobj.nameAssigned then
				pobj.nameAssigned = true
				pobj.spinUpgrade = false
				pobj.beamTimeUpgrade = false
				pobj.hullUpgrade = false
				tempPlayerType = pobj:getTypeName()
				if tempPlayerType == "MP52 Hornet" then
					if #playerShipNamesFor["MP52Hornet"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["MP52Hornet"]))
					end
					pobj.shipScore = 7
					pobj.maxCargo = 3
					pobj.autoCoolant = false
					pobj:setWarpDrive(true)
				elseif tempPlayerType == "Piranha" then
					if #playerShipNamesFor["Piranha"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["Piranha"]))
					end
					pobj.shipScore = 16
					pobj.maxCargo = 8
				elseif tempPlayerType == "Flavia P.Falcon" then
					if #playerShipNamesFor["FlaviaPFalcon"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["FlaviaPFalcon"]))
					end
					pobj.shipScore = 13
					pobj.maxCargo = 15
				elseif tempPlayerType == "Phobos M3P" then
					if #playerShipNamesFor["PhobosM3P"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["PhobosM3P"]))
					end
					pobj.shipScore = 19
					pobj.maxCargo = 10
					pobj:setWarpDrive(true)
				elseif tempPlayerType == "Atlantis" then
					if #playerShipNamesFor["Atlantis"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["Atlantis"]))
					end
					pobj.shipScore = 52
					pobj.maxCargo = 6
				elseif tempPlayerType == "Player Cruiser" then
					if #playerShipNamesFor["Cruiser"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["Cruiser"]))
					end
					pobj.shipScore = 40
					pobj.maxCargo = 6
				elseif tempPlayerType == "Player Missile Cr." then
					if #playerShipNamesFor["MissileCruiser"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["MissileCruiser"]))
					end
					pobj.shipScore = 45
					pobj.maxCargo = 8
				elseif tempPlayerType == "Player Fighter" then
					if #playerShipNamesFor["Fighter"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["Fighter"]))
					end
					pobj.shipScore = 7
					pobj.maxCargo = 3
					pobj.autoCoolant = false
					pobj:setJumpDrive(true)
					pobj:setJumpDriveRange(3000,40000)
				elseif tempPlayerType == "Benedict" then
					if #playerShipNamesFor["Benedict"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["Benedict"]))
					end
					pobj.shipScore = 10
					pobj.maxCargo = 9
				elseif tempPlayerType == "Kiriya" then
					if #playerShipNamesFor["Kiriya"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["Kiriya"]))
					end
					pobj.shipScore = 10
					pobj.maxCargo = 9
				elseif tempPlayerType == "Striker" then
					if #playerShipNamesFor["Striker"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["Striker"]))
					end
					pobj.shipScore = 8
					pobj.maxCargo = 4
					pobj:setJumpDrive(true)
					pobj:setJumpDriveRange(3000,40000)
				elseif tempPlayerType == "ZX-Lindworm" then
					if #playerShipNamesFor["Lindworm"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["Lindworm"]))
					end
					pobj.shipScore = 8
					pobj.maxCargo = 3
					pobj.autoCoolant = false
					pobj:setWarpDrive(true)
				elseif tempPlayerType == "Repulse" then
					if #playerShipNamesFor["Repulse"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["Repulse"]))
					end
					pobj.shipScore = 14
					pobj.maxCargo = 12
				elseif tempPlayerType == "Ender" then
					if #playerShipNamesFor["Ender"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["Ender"]))
					end
					pobj.shipScore = 100
					pobj.maxCargo = 20
				elseif tempPlayerType == "Nautilus" then
					if #playerShipNamesFor["Nautilus"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["Nautilus"]))
					end
					pobj.shipScore = 12
					pobj.maxCargo = 7
				elseif tempPlayerType == "Hathcock" then
					if #playerShipNamesFor["Hathcock"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["Hathcock"]))
					end
					pobj.shipScore = 30
					pobj.maxCargo = 6
				elseif tempPlayerType == "Maverick" then
					if #playerShipNamesFor["Maverick"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["Maverick"]))
					end
					pobj.shipScore = 45
					pobj.maxCargo = 5
				elseif tempPlayerType == "Crucible" then
					if #playerShipNamesFor["Crucible"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["Crucible"]))
					end
					pobj.shipScore = 45
					pobj.maxCargo = 5
				else
					if #playerShipNamesFor["Leftovers"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["Leftovers"]))
					end
					pobj.shipScore = 24
					pobj.maxCargo = 5
					pobj:setWarpDrive(true)
				end
				if pobj.cargo == nil then
					pobj.cargo = pobj.maxCargo
					pobj.maxRepairCrew = pobj:getRepairCrewCount()
					pobj.healthyShield = 1.0
					pobj.prevShield = 1.0
					pobj.healthyReactor = 1.0
					pobj.prevReactor = 1.0
					pobj.healthyManeuver = 1.0
					pobj.prevManeuver = 1.0
					pobj.healthyImpulse = 1.0
					pobj.prevImpulse = 1.0
					if pobj:getBeamWeaponRange(0) > 0 then
						pobj.healthyBeam = 1.0
						pobj.prevBeam = 1.0
					end
					if pobj:getWeaponTubeCount() > 0 then
						pobj.healthyMissile = 1.0
						pobj.prevMissile = 1.0
					end
					if pobj:hasWarpDrive() then
						pobj.healthyWarp = 1.0
						pobj.prevWarp = 1.0
					end
					if pobj:hasJumpDrive() then
						pobj.healthyJump = 1.0
						pobj.prevJump = 1.0
					end
				end
			end
		end
	end
	setConcurrenetPlayerCount = concurrentPlayerCount
end

function healthCheck(delta)
	healthCheckTimer = healthCheckTimer - delta
	if healthCheckTimer < 0 then
		healthCheckCount = healthCheckCount + 1
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				if p:getRepairCrewCount() > 0 then
					fatalityChance = 0
					if p:getShieldCount() > 1 then
						cShield = (p:getSystemHealth("frontshield") + p:getSystemHealth("rearshield"))/2
					else
						cShield = p:getSystemHealth("frontshield")
					end
					fatalityChance = fatalityChance + (p.prevShield - cShield)
					p.prevShield = cShield
					fatalityChance = fatalityChance + (p.prevReactor - p:getSystemHealth("reactor"))
					p.prevReactor = p:getSystemHealth("reactor")
					fatalityChance = fatalityChance + (p.prevManeuver - p:getSystemHealth("maneuver"))
					p.prevManeuver = p:getSystemHealth("maneuver")
					fatalityChance = fatalityChance + (p.prevImpulse - p:getSystemHealth("impulse"))
					p.prevImpulse = p:getSystemHealth("impulse")
					if p:getBeamWeaponRange(0) > 0 then
						if p.healthyBeam == nil then
							p.healthyBeam = 1.0
							p.prevBeam = 1.0
						end
						fatalityChance = fatalityChance + (p.prevBeam - p:getSystemHealth("beamweapons"))
						p.prevBeam = p:getSystemHealth("beamweapons")
					end
					if p:getWeaponTubeCount() > 0 then
						if p.healthyMissile == nil then
							p.healthyMissile = 1.0
							p.prevMissile = 1.0
						end
						fatalityChance = fatalityChance + (p.prevMissile - p:getSystemHealth("missilesystem"))
						p.prevMissile = p:getSystemHealth("missilesystem")
					end
					if p:hasWarpDrive() then
						if p.healthyWarp == nil then
							p.healthyWarp = 1.0
							p.prevWarp = 1.0
						end
						fatalityChance = fatalityChance + (p.prevWarp - p:getSystemHealth("warp"))
						p.prevWarp = p:getSystemHealth("warp")
					end
					if p:hasJumpDrive() then
						if p.healthyJump == nil then
							p.healthyJump = 1.0
							p.prevJump = 1.0
						end
						fatalityChance = fatalityChance + (p.prevJump - p:getSystemHealth("jumpdrive"))
						p.prevJump = p:getSystemHealth("jumpdrive")
					end
					if p:getRepairCrewCount() == 1 then
						fatalityChance = fatalityChance/2	-- increase chances of last repair crew standing
					end
					if fatalityChance > 0 then
						crewFate(p,fatalityChance)
					end
				else
					if random(1,100) <= (4 - difficulty) then
						p:setRepairCrewCount(1)
						if p:hasPlayerAtPosition("Engineering") then
							local repairCrewRecovery = "repairCrewRecovery"
							p:addCustomMessage("Engineering",repairCrewRecovery,"Medical team has revived one of your repair crew")
						end
						if p:hasPlayerAtPosition("Engineering+") then
							local repairCrewRecoveryPlus = "repairCrewRecoveryPlus"
							p:addCustomMessage("Engineering+",repairCrewRecoveryPlus,"Medical team has revived one of your repair crew")
						end
						resetPreviousSystemHealth(p)
					end
				end
				if p.initialCoolant ~= nil then
					local current_coolant = p:getMaxCoolant()
					if current_coolant < 10 then
						if random(1,100) <= 4 then
							p:setMaxCoolant(current_coolant + ((current_coolant + 10)/2))
							if p:hasPlayerAtPosition("Engineering") then
								local coolant_recovery = "coolant_recovery"
								p:addCustomMessage("Engineering",coolant_recovery,"Automated systems have recovered some coolant")
							end
							if p:hasPlayerAtPosition("Engineering+") then
								local coolant_recovery_plus = "coolant_recovery_plus"
								p:addCustomMessage("Engineering+",coolant_recovery_plus,"Automated systems have recovered some coolant")
							end
							resetPreviousSystemHealth(p)
						end
					end
				end
			end
		end
		healthCheckTimer = delta + healthCheckTimerInterval
	end
end
function resetPreviousSystemHealth(p)
	if p:getShieldCount() > 1 then
		p.prevShield = (p:getSystemHealth("frontshield") + p:getSystemHealth("rearshield"))/2
	else
		p.prevShield = p:getSystemHealth("frontshield")
	end
	p.prevReactor = p:getSystemHealth("reactor")
	p.prevManeuver = p:getSystemHealth("maneuver")
	p.prevImpulse = p:getSystemHealth("impulse")
	if p:getBeamWeaponRange(0) > 0 then
		p.prevBeam = p:getSystemHealth("beamweapons")
	end
	if p:getWeaponTubeCount() > 0 then
		p.prevMissile = p:getSystemHealth("missilesystem")
	end
	if p:hasWarpDrive() then
		p.prevWarp = p:getSystemHealth("warp")
	end
	if p:hasJumpDrive() then
		p.prevJump = p:getSystemHealth("jumpdrive")
	end
end
function crewFate(p, fatalityChance)
	if math.random() < (fatalityChance) then
		p:setRepairCrewCount(p:getRepairCrewCount() - 1)
		if p:hasPlayerAtPosition("Engineering") then
			repairCrewFatality = "repairCrewFatality"
			p:addCustomMessage("Engineering",repairCrewFatality,"One of your repair crew has perished")
		end
		if p:hasPlayerAtPosition("Engineering+") then
			repairCrewFatalityPlus = "repairCrewFatalityPlus"
			p:addCustomMessage("Engineering+",repairCrewFatalityPlus,"One of your repair crew has perished")
		end
	end
end

function autoCoolant(delta)
	if enableAutoCoolFunctionList == nil then
		enableAutoCoolFunctionList = {}
		table.insert(enableAutoCoolFunctionList,enableAutoCool1)
		table.insert(enableAutoCoolFunctionList,enableAutoCool2)
		table.insert(enableAutoCoolFunctionList,enableAutoCool3)
		table.insert(enableAutoCoolFunctionList,enableAutoCool4)
		table.insert(enableAutoCoolFunctionList,enableAutoCool5)
		table.insert(enableAutoCoolFunctionList,enableAutoCool6)
		table.insert(enableAutoCoolFunctionList,enableAutoCool7)
		table.insert(enableAutoCoolFunctionList,enableAutoCool8)
	end
	if disableAutoCoolFunctionList == nil then
		disableAutoCoolFunctionList = {}
		table.insert(disableAutoCoolFunctionList,disableAutoCool1)
		table.insert(disableAutoCoolFunctionList,disableAutoCool2)
		table.insert(disableAutoCoolFunctionList,disableAutoCool3)
		table.insert(disableAutoCoolFunctionList,disableAutoCool4)
		table.insert(disableAutoCoolFunctionList,disableAutoCool5)
		table.insert(disableAutoCoolFunctionList,disableAutoCool6)
		table.insert(disableAutoCoolFunctionList,disableAutoCool7)
		table.insert(disableAutoCoolFunctionList,disableAutoCool8)
	end
	for pidx=1,8 do
		p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			if p.autoCoolant ~= nil then
				if p:hasPlayerAtPosition("Engineering") then
					if p.autoCoolButton == nil then
						tbi = "enableAutoCool" .. p:getCallSign()
						p:addCustomButton("Engineering",tbi,"Auto cool",enableAutoCoolFunctionList[pidx])
						tbi = "disableAutoCool" .. p:getCallSign()
						p:addCustomButton("Engineering",tbi,"Manual cool",disableAutoCoolFunctionList[pidx])
						p.autoCoolButton = true
					end
				end
				if p:hasPlayerAtPosition("Engineering+") then
					if p.autoCoolButton == nil then
						tbi = "enableAutoCoolPlus" .. p:getCallSign()
						p:addCustomButton("Engineering+",tbi,"Auto cool",enableAutoCoolFunctionList[pidx])
						tbi = "disableAutoCoolPlus" .. p:getCallSign()
						p:addCustomButton("Engineering+",tbi,"Manual cool",disableAutoCoolFunctionList[pidx])
						p.autoCoolButton = true
					end
				end
			end
		end
	end
end

function enableAutoCool1()
	p = getPlayerShip(1)
	p:setAutoCoolant(true)
	p:commandSetAutoRepair(true)
	p.autoCoolant = true
end
function disableAutoCool1()
	p = getPlayerShip(1)
	p:setAutoCoolant(false)
	p:commandSetAutoRepair(false)
	p.autoCoolant = false
end
function enableAutoCool2()
	p = getPlayerShip(2)
	p:setAutoCoolant(true)
	p:commandSetAutoRepair(true)
	p.autoCoolant = true
end
function disableAutoCool2()
	p = getPlayerShip(2)
	p:setAutoCoolant(false)
	p:commandSetAutoRepair(false)
	p.autoCoolant = false
end
function enableAutoCool3()
	p = getPlayerShip(3)
	p:setAutoCoolant(true)
	p:commandSetAutoRepair(true)
	p.autoCoolant = true
end
function disableAutoCool3()
	p = getPlayerShip(3)
	p:setAutoCoolant(false)
	p:commandSetAutoRepair(false)
	p.autoCoolant = false
end
function enableAutoCool4()
	p = getPlayerShip(4)
	p:setAutoCoolant(true)
	p:commandSetAutoRepair(true)
	p.autoCoolant = true
end
function disableAutoCool4()
	p = getPlayerShip(4)
	p:setAutoCoolant(false)
	p:commandSetAutoRepair(false)
	p.autoCoolant = false
end
function enableAutoCool5()
	p = getPlayerShip(5)
	p:setAutoCoolant(true)
	p:commandSetAutoRepair(true)
	p.autoCoolant = true
end
function disableAutoCool5()
	p = getPlayerShip(5)
	p:setAutoCoolant(false)
	p:commandSetAutoRepair(false)
	p.autoCoolant = false
end
function enableAutoCool6()
	p = getPlayerShip(6)
	p:setAutoCoolant(true)
	p:commandSetAutoRepair(true)
	p.autoCoolant = true
end
function disableAutoCool6()
	p = getPlayerShip(6)
	p:setAutoCoolant(false)
	p:commandSetAutoRepair(false)
	p.autoCoolant = false
end
function enableAutoCool7()
	p = getPlayerShip(7)
	p:setAutoCoolant(true)
	p:commandSetAutoRepair(true)
	p.autoCoolant = true
end
function disableAutoCool7()
	p = getPlayerShip(7)
	p:setAutoCoolant(false)
	p:commandSetAutoRepair(false)
	p.autoCoolant = false
end
function enableAutoCool8()
	p = getPlayerShip(8)
	p:setAutoCoolant(true)
	p:commandSetAutoRepair(true)
	p.autoCoolant = true
end
function disableAutoCool8()
	p = getPlayerShip(8)
	p:setAutoCoolant(false)
	p:commandSetAutoRepair(false)
	p.autoCoolant = false
end
--final page for victory or defeat on main streen. Station stats only for now
function endStatistics()
	destroyedStations = 0
	survivedStations = 0
	destroyedFriendlyStations = 0
	survivedFriendlyStations = 0
	destroyedNeutralStations = 0
	survivedNeutralStations = 0
	for _, station in pairs(originalStationList) do
		tp = getPlayerShip(-1)
		if tp ~= nil and tp:isValid() then
			if station:isFriendly(tp) then
				if station:isValid() then
					survivedStations = survivedStations + 1
					survivedFriendlyStations = survivedFriendlyStations + 1
				end
			else
				if station:isValid() then
					survivedStations = survivedStations + 1
					survivedNeutralStations = survivedNeutralStations + 1
				end
			end
		end
	end
	destroyedStations = (startingFriendlyStations + startingNeutralStations) - survivedStations
	destroyedFriendlyStations = startingFriendlyStations - survivedFriendlyStations
	destroyedNeutralStations = startingNeutralStations - survivedNeutralStations
	enemyStationsSurvived = 0
	for _, station in pairs(enemyStationList) do
		if station:isValid() then
			enemyStationsSurvived = enemyStationsSurvived + 1
		end
	end
	destroyedEnemyStations = startingEnemyStations - enemyStationsSurvived
	gMsg = string.format("Stations: %i\t survived: %i\t destroyed: %i",(startingFriendlyStations + startingNeutralStations),survivedStations,destroyedStations)
	gMsg = gMsg .. string.format("\nFriendly Stations: %i\t survived: %i\t destroyed: %i",startingFriendlyStations,survivedFriendlyStations,destroyedFriendlyStations)
	gMsg = gMsg .. string.format("\nNeutral Stations: %i\t survived: %i\t destroyed: %i",startingNeutralStations,survivedNeutralStations,destroyedNeutralStations)
	gMsg = gMsg .. string.format("\n\n\n\nEnemy Stations: %i\t survived: %i\t destroyed: %i",startingEnemyStations,enemyStationsSurvived,enemyStationsSurvived)
--	gMsg = gMsg .. string.format("\n\n\n\nRequired missions completed: %i",requiredMissionCount)
	rankVal = survivedFriendlyStations/startingFriendlyStations*.6 + survivedNeutralStations/startingNeutralStations*.2 + (1-enemyStationsSurvived/startingEnemyStations)*.2
	if missionVictory then
		if rankVal < .7 then
			rank = "Ensign"
		elseif rankVal < .8 then
			rank = "Lieutenant"
		elseif rankVal < .9 then
			rank = "Commander"
		elseif rankVal < .95 then
			rank = "Captain"
		else
			rank = "Admiral"
		end
		gMsg = gMsg .. "\nEarned rank: " .. rank
	else
		if rankVal < .6 then
			rank = "Ensign"
		elseif rankVal < .7 then
			rank = "Lieutenant"
		elseif rankVal < .8 then
			rank = "Commander"
		elseif rankVal < .9 then
			rank = "Captain"
		else
			rank = "Admiral"
		end
		if string.find(getScenarioVariation(),"Hunter") then
			gMsg = gMsg .. "\nPost Target Enemy Base Survival Rank: ".. rank
		else
			gMsg = gMsg .. "\nPost Home Base Destruction Rank: " .. rank
		end
		-- Yes, the ranking is more forgiving when defeated for these reasons:
		-- 1) With so many deaths on the station, leadership roles have opened up
		--    1a) Reciprocal: Harder to get promoted when you succeed with so many surviving competing officers
		-- 2) Simulation of whacky military promotion politics
		-- 3) Incentive to play the mission again
	end
	globalMessage(gMsg)
end

function update(delta)
	concurrentPlayerCount = 0
	if homeStation ~= nil and homeStation:isValid() and homeStation.telemetry ~= nil and homeStation.telemetry then
		local shield_count = homeStation:getShieldCount()
		local shield_index = 0
		local shield_max = homeStation:getShieldMax(0)
		local lowest_shield = shield_max
		repeat
			local current_shield_level = homeStation:getShieldLevel(shield_index)
			if current_shield_level < lowest_shield then
				lowest_shield = current_shield_level
			end
			shield_index = shield_index + 1
		until(shield_index >= shield_count)
		if lowest_shield < shield_max then
			local shield_label = "S"
			if shield_count > 1 then
				shield_label = "WS"
			end
			home_station_health = string.format("%s %s:%i%% H:%i%%",homeStation:getCallSign(),shield_label,math.floor(lowest_shield/shield_max*100),math.floor(homeStation:getHull()/homeStation:getHullMax()*100))
		else
			home_station_health = nil
		end
	end
	for pidx=1,8 do
		p = getPlayerShip(pidx)
		if p ~= nil then
			concurrentPlayerCount = concurrentPlayerCount + 1
			if p:isValid() then
				if home_station_health ~= nil then
					if p:hasPlayerAtPosition("Relay") then
						p.home_station_status = "home_station_status"
						p:addCustomInfo("Relay",p.home_station_status,home_station_health)
					end
					if p:hasPlayerAtPosition("Operations") then
						p.home_station_status_ops = "home_station_status_ops"
						p:addCustomInfo("Operations",p.home_station_status_ops,home_station_health)
					end
				else
					if p.home_station_status ~= nil then
						p:removeCustom(p.home_station_status)
						p.home_station_status = nil
					end
					if p.home_station_status_ops ~= nil then
						p:removeCustom(p.home_station_status_ops)
						p.home_station_status_ops = nil
					end
				end
			end
		end
	end
	if concurrentPlayerCount > highestConcurrentPlayerCount then
		highestConcurrentPlayerCount = concurrentPlayerCount
	end
	if setConcurrentPlayerCount ~= highestConcurrentPlayerCount then
		setPlayers()
	end
	if delta == 0 then
		--game paused
		setPlayers()
		return
	end
	if GMSpawnEnemyGroup == nil then
		GMSpawnEnemyGroup = "Spawn Enemies"
		addGMFunction(GMSpawnEnemyGroup,GMSpawnsEnemies)
	end
	if difficultySpecificSetup == nil then
		difficultySpecificSetup = "done"
		if difficulty >= 1 then
			tesx, tesy = targetEnemyStation:getPosition()
			wpRadius = 3000
			wpAngle = random(0,360)
			rx, ry = vectorFromAngle(wpAngle,wpRadius)
			wp9 = CpuShip():setCallSign("WP-9"):setFaction(stationFaction):setPosition(tesx+rx,tesy+ry):setTemplate("Defense platform"):orderRoaming()
			wpAngle = wpAngle + 90
			rx, ry = vectorFromAngle(wpAngle,wpRadius)
			wp15 = CpuShip():setCallSign("WP-15"):setFaction(stationFaction):setPosition(tesx+rx,tesy+ry):setTemplate("Defense platform"):orderRoaming()
			wpAngle = wpAngle + 90
			rx, ry = vectorFromAngle(wpAngle,wpRadius)
			wp46 = CpuShip():setCallSign("WP-46"):setFaction(stationFaction):setPosition(tesx+rx,tesy+ry):setTemplate("Defense platform"):orderRoaming()
			wpAngle = wpAngle + 90
			rx, ry = vectorFromAngle(wpAngle,wpRadius)
			wp20 = CpuShip():setCallSign("WP-20"):setFaction(stationFaction):setPosition(tesx+rx,tesy+ry):setTemplate("Defense platform"):orderRoaming()
		end
		if difficulty > 1 then
			tesx, tesy = targetEnemyStation:getPosition()
			wp66cpos = 0
			rx, ry = vectorFromAngle(wp66cpos,6000)
			wp66 = CpuShip():setCallSign("WP-66"):setFaction(stationFaction):setPosition(tesx+rx,tesy+ry):setTemplate("Defense platform"):orderRoaming()
		end		
	end
	if difficulty > 1 then
		if wp66:isValid() then
			wp66cpos = wp66cpos + .1
			if wp66cpos >= 360 then
				wp66cpos = 0
			end
			rx, ry = vectorFromAngle(wp66cpos, 6000)
			wp66:setPosition(tesx+rx,tesy+ry)
		end
	end
	if homeStation:isValid() then
		if homeStationRotationEnabled then
			homeStation:setRotation(homeStation:getRotation()+.1)
			if homeStation:getRotation() >= 360 then
				homeStation:setRotation(0)
			end
		end
	end
	anetx, anety = vectorFromAngle(stationAnet.angle,3000)
	stationAnet:setPosition(aldx+anetx,aldy+anety):setRotation(stationAnet.angle)
	stationAnet.angle = stationAnet.angle + .05
	if stationAnet.angle >= 360 then
		stationAnet.angle = 0
	end
	if plot6 ~= nil then	--timed game
		plot6(delta)
	end
	if plot1 ~= nil then	--initial and primary plot
		plot1(delta)
	end
	if plot2 ~= nil then	--delivery, spin upgrade, base intelligence, warp jam
		plot2(delta)
	end
	if plot4 ~= nil then	--deliver, base rotate, beam time/hull upgrades
		plot4(delta)
	end
	if plotH ~= nil then	--health
		plotH(delta)
	end
	if plotA ~= nil then	--asteroids in motion
		plotA(delta)
	end
	if plotN ~= nil then	--nebulae in motion
		plotN(delta)
	end
	if plotT ~= nil then	--transports
		plotT(delta)
	end
	if plot3 ~= nil then	--intelligence over time
		plot3(delta)
	end
	if plotW ~= nil then	--worm artifact
		plotW(delta)
	end
	if plotC ~= nil then	--coolant automation for fighters
		plotC(delta)
	end
	if plot5 ~= nil then	--helpful warning
		plot5(delta)
	end
end