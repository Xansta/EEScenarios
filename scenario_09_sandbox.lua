-- Name: Sandbox
-- Description: GM controlled missions
--- Version 0
-- Type: GM Controlled missions
-- Variation[Easy]: Easy goals and/or enemies
-- Variation[Hard]: Hard goals and/or enemies

require("utils.lua")

function init()
	updateDiagnostic = false
	healthDiagnostic = false
	change_enemy_order_diagnostic = true
	setConstants()
	initialGMFunctions()
	createSkeletonUniverse()
--	testObject = Artifact():setPosition(100,100):setScanningParameters(1,1):setRadarSignatureInfo(1,.5,0):setModel("SensorArrayMKI"):setDescriptions("sensor","good sensor")
end
--Human navy stations that may always be reached by long range communication
--Fixed stellar features (black holes, worm holes, nebulae)
function createSkeletonUniverse()
	local icx = 11756
	local icy = 1254
	local nukeAvail = true
	local empAvail = true
	local mineAvail = true
	local homeAvail = true
	local hvliAvail = true
	local tradeFood = true
	local tradeMedicine = true
	local tradeLuxury = true
	stationIcarus = SpaceStation():setTemplate("Large Station"):setFaction("Human Navy"):setPosition(icx,icy):setCallSign("Icarus"):setDescription("Shipyard, Naval Regional Headquarters"):setCommsScript(""):setCommsFunction(commsStation)
    stationIcarus.comms_data = {
    	friendlyness = 75,
        weapons = 			{Homing = "neutral",HVLI = "neutral", 		Mine = "neutral",		Nuke = "friend", 			EMP = "friend"},
        weapon_cost =		{Homing = 2, 		HVLI = 1,				Mine = math.random(2,4),Nuke = 15,					EMP = 10 },
        weapon_available = 	{Homing = homeAvail,HVLI = hvliAvail,		Mine = mineAvail,		Nuke = nukeAvail,			EMP = empAvail},
        service_cost = 		{supplydrop = math.random(90,110), reinforcements = math.random(140,160)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 2.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	food = 		{quantity = 10,		cost = 1},
        			medicine =	{quantity = 10,		cost = 5}	},
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "Shipyard for human navy ships. Regional headquarters. Development site for the Atlantis model ship",
    	history = "As humans ran up against more and more unfriendly races, this station became the nexus for research and development of new space ship building technologies. After a few experimental accidents involving militarily driven scientists and fabrication specialists, the station was renamed from Research-37 to Icarus referencing the mythical figure that flew too close to the sun"
	}
	stationKentar = SpaceStation():setTemplate("Large Station"):setFaction("Human Navy"):setPosition(246000,247000):setCallSign("Kentar"):setDescription("Naval Regional Headquarters"):setCommsScript(""):setCommsFunction(commsStation)
    stationKentar.comms_data = {
    	friendlyness = 68,
        weapons = 			{Homing = "neutral",HVLI = "neutral", 		Mine = "neutral",		Nuke = "friend", 			EMP = "friend"},
        weapon_cost =		{Homing = 2, 		HVLI = 1,				Mine = math.random(3,7),Nuke = 13,					EMP = 9 },
        weapon_available = 	{Homing = homeAvail,HVLI = hvliAvail,		Mine = mineAvail,		Nuke = nukeAvail,			EMP = empAvail},
        service_cost = 		{supplydrop = math.random(90,110), reinforcements = math.random(140,160)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 2.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	food = 		{quantity = 10,		cost = 1},
        			medicine =	{quantity = 10,		cost = 5},
        			luxury =	{quantity = 10,		cost = math.random(80,120)}	},
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "Regional headquarters. Jumping off point for actions against Kraylor activity",
    	history = "This used to be a scientific observation and research station. As the Kraylors have grown more agressive, it's been built up and serves as a strategic cornerstone for actions against the Kraylors. The name Kentar derives from Kentauros or Centaurus, after the nearby star's prominent position in the constellation Centaurus"
	}
	createFleurNebula()
	BlackHole():setPosition(-12443,-23245)
    BlackHole():setPosition(87747, -3384)
    BlackHole():setPosition(80429, -10486)
    BlackHole():setPosition(75695, 2427)
    wormholeIcarus = WormHole():setPosition(-46716, 17958):setTargetPosition(19080, -19780)
    wormholeIcarus.exit = "default"
    wormholeIcarus.default_exit_point_x = 19080
    wormholeIcarus.default_exit_point_y = -19780
    wormholeIcarus.kentar_exit_point_x = 251000
    wormholeIcarus.kentar_exit_point_y = 250000
end
function createFleurNebula()
    Nebula():setPosition(22028, 25793):setCallSign("Fleur")
    Nebula():setPosition(13381, 37572)
    Nebula():setPosition(20835, 35783)
    Nebula():setPosition(15319, 24601)
    Nebula():setPosition(16363, 30415)
    Nebula():setPosition(22923, 17295)
    Nebula():setPosition(27843, 19680)
    Nebula():setPosition(31123, 16997)
    --Borlan area nebula
    Nebula():setPosition(88464, 45469)
    Nebula():setPosition(77847, 35928)
    Nebula():setPosition(79353, 42959)
    Nebula():setPosition(75264, 47622)
    Nebula():setPosition(86671, 36861)
    Nebula():setPosition(96857, 44322)
end
function setConstants()
	playerSpawnX = 0
	playerSpawnY = 0
	startRegion = "Default"
	fleetSpawnFaction = "Kraylor"
	fleetStrengthFixed = false
	fleetStrengthFixedValue = 250
	fleetStrengthByPlayerStrength = 1
	fleetComposition = "Random"
	fleetOrders = "Roaming"
	fleetSpawnLocation = "At Selection"
	fleetSpawnRelativeDirection = "Random Direction"
	fleetSpawnAwayDirection = "Random"
	fleetSpawnAwayDistance = 30
	createDirection = 90
	createDistance = 30
	fleetAmbushDistance = 5
	fleetChange = "unmodified"
	fleetChangeChance = 20
	fleetList = {}
	existing_fleet_order = "Roaming"
	enemy_reverts = {}
	revert_timer_interval = 7
	revert_timer = revert_timer_interval
	plotRevert = revertWait
	
	--stnl: Ship Template Name List
	--stsl: Ship Template Score List
	--stbl: Ship Template Boolean List
	--nsfl: Non Standard Function List
	stnl = {"Adder MK9","K2 Fighter","K3 Fighter","Fiend G3","Fiend G4","Fiend G5","Fiend G6","Nirvana R3","MV52 Hornet","Phobos R2","Adder MK8","Adder MK7","Adder MK3","MT52 Hornet","MU52 Hornet","Adder MK5","Adder MK4","WX-Lindworm","Adder MK6","Phobos T3","Phobos M3","Piranha F8","Piranha F12","Piranha F12.M","Ranus U","Nirvana R5","Nirvana R5A","Stalker Q7","Stalker R7","Atlantis X23","Starhammer II","Odin","Fighter","Karnack","Cruiser","Missile Cruiser","Gunship","Adv. Gunship","Strikeship","Adv. Striker","Dreadnought","Battlestation","Blockade Runner","Ktlitan Fighter","Ktlitan Breaker","Ktlitan Worker","Ktlitan Drone","Ktlitan Feeder","Ktlitan Scout","Ktlitan Destroyer","Storm"}
	stsl = {11          ,7           ,8           ,33        ,35        ,37        ,39        ,12          ,6            ,13         ,10         ,9          ,5          ,5            ,5            ,7          ,6          ,7            ,8          ,15         ,16         ,15          ,15           ,16             ,25       ,19          ,20           ,25          ,25          ,50            ,70             ,250   ,6        ,17       ,18       ,14               ,17       ,20            ,30          ,27            ,80           ,100            ,65               ,6                ,45               ,40              ,4              ,48              ,8              ,50                 ,22}
	stbl = {false       ,false       ,false       ,false     ,false     ,false     ,false     ,false       ,false        ,false      ,false      ,false      ,false      ,true         ,true         ,true       ,true       ,true         ,true       ,true       ,true       ,true        ,true         ,true           ,true     ,true        ,true         ,true        ,true        ,true          ,true           ,true  ,true     ,true     ,true     ,true             ,true     ,true          ,true        ,true          ,true         ,true           ,true             ,true             ,true             ,true            ,true           ,true            ,true           ,true               ,true}
	nsfl = {}
	table.insert(nsfl,adderMk9)
	table.insert(nsfl,k2fighter)
	table.insert(nsfl,k3fighter)
	table.insert(nsfl,fiendG3)
	table.insert(nsfl,fiendG4)
	table.insert(nsfl,fiendG5)
	table.insert(nsfl,fiendG6)
	table.insert(nsfl,nirvanaR3)
	table.insert(nsfl,hornetMV52)
	table.insert(nsfl,phobosR2)
	table.insert(nsfl,adderMk8)
	table.insert(nsfl,adderMk7)
	table.insert(nsfl,adderMk3)
	
	--Adder Ship Template Name List, Score List and Boolean List
	stnlAdder = {"Adder MK9","Adder MK8","Adder MK7","Adder MK3","Adder MK5","Adder MK4","Adder MK6","Cruiser"}
	stslAdder = {11         ,10         ,9          ,5          ,7          ,6          ,8          ,18       }
	stblAdder = {false      ,false      ,false      ,false      ,true       ,true       ,true       ,true     }
	--Missiler Ship Template Name List, Score List and Boolean List
	stnlMissiler = {"WX-Lindworm","Piranha F8","Piranha F12","Ranus U","Missile Cruiser","Storm"}
	stslMissiler = {7            ,15          ,15           ,25       ,14               ,22     }
	stblMissiler = {true         ,true        ,true         ,true     ,true             ,true   }
	--Beamer Ship Template Name List, Score List and Boolean List
	stnlBeamer = {"K2 Fighter","K3 Fighter","Nirvana R3","MV52 Hornet","MT52 Hornet","MU52 Hornet","Nirvana R5","Nirvana R5A","Stalker Q7","Stalker R7","Fighter","Cruiser","Strikeship","Adv. Striker","Dreadnought","Battlestation","Blockade Runner","Ktlitan Fighter","Ktlitan Worker","Ktlitan Drone","Ktlitan Feeder","Ktlitan Scout"}
	stslBeamer = {7           ,8           ,12          ,6            ,5            ,5            ,19          ,20           ,25          ,25          ,6        ,18       ,30          ,27            ,80           ,100            ,65               ,6                ,40              ,4              ,48              ,8              }
	stblBeamer = {false       ,false       ,false       ,false        ,true         ,true         ,true        ,true         ,true        ,true        ,true     ,true     ,true        ,true          ,true         ,true           ,true             ,true             ,true            ,true           ,true            ,true           }
	--Frigates Ship Template Name List, Score List and Boolean List
	stnlFrigate = {"Fiend G3","Fiend G4","Fiend G5","Fiend G6","Phobos R2","Phobos T3","Phobos M3","Piranha F8","Piranha F12","Piranha F12.M","Ranus U","Nirvana R5A","Stalker Q7","Stalker R7","Karnack","Cruiser","Missile Cruiser","Gunship","Adv. Gunship","Strikeship","Adv. Striker","Storm"}
	stslFrigate = {33        ,35        ,37        ,39        ,13         ,15         ,16         ,15          ,15           ,16             ,25       ,20           ,25          ,25          ,17       ,18       ,14               ,17       ,20            ,30          ,27            ,22     }
	stblFrigate = {false     ,false     ,false     ,false     ,false      ,true       ,true       ,true        ,true         ,true           ,true     ,true         ,true        ,true        ,true     ,true     ,true             ,true     ,true          ,true        ,true          ,true   }
	--Chaser Ship Template Name List, Score List and Boolean List
	stnlChaser = {"Fiend G3","Fiend G4","Fiend G5","Fiend G6","Stalker Q7","Stalker R7","Atlantis X23","Starhammer II","Odin","Strikeship","Adv. Striker","Battlestation"}
	stslChaser = {33        ,35        ,37        ,39        ,25          ,25          ,50            ,70             ,250   ,30          ,27            ,100            }
	stblChaser = {false     ,false     ,false     ,false     ,true        ,true        ,true          ,true           ,true  ,true        ,true          ,true           }
	--Fighter Ship Template Name List, Score List and Boolean List
	stnlFighter = {"K2 Fighter","K3 Fighter","MV52 Hornet","MT52 Hornet","MU52 Hornet","WX-Lindworm","Fighter","Ktlitan Fighter","Ktlitan Drone"}
	stslFighter = {7           ,8           ,6            ,5            ,5            ,7            ,6        ,6                ,4              }
	stblFighter = {false       ,false       ,false        ,true         ,true         ,true         ,true     ,true             ,true           }
	--Non database Ship Template Name List, Score List and Boolean List
	stnlNonDB = {"Adder MK9","K2 Fighter","K3 Fighter","Fiend G3","Fiend G4","Fiend G5","Fiend G6","Nirvana R3","MV52 Hornet","Phobos R2","Adder MK8","Adder MK7","Adder MK3"}
	stslNonDB = {11         ,7           ,8           ,33        ,35        ,37        ,39        ,12          ,6            ,13         ,10         ,9          ,5          }
	stblNonDB = {false      ,false       ,false       ,false     ,false     ,false     ,false     ,false       ,false        ,false      ,false      ,false      ,false      }

	-- square grid deployment	
	fleetPosDelta1x = {0,1,0,-1, 0,1,-1, 1,-1,2,0,-2, 0,2,-2, 2,-2,2, 2,-2,-2,1,-1, 1,-1,0, 0,3,-3,1, 1,3,-3,-1,-1, 3,-3,2, 2,3,-3,-2,-2, 3,-3,3, 3,-3,-3,4,0,-4, 0,4,-4, 4,-4,-4,-4,-4,-4,-4,-4,4, 4,4, 4,4, 4, 1,-1, 2,-2, 3,-3,1,-1,2,-2,3,-3,5,-5,0, 0,5, 5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,5, 5,5, 5,5, 5,5, 5, 1,-1, 2,-2, 3,-3, 4,-4,1,-1,2,-2,3,-3,4,-4}
	fleetPosDelta1y = {0,0,1, 0,-1,1,-1,-1, 1,0,2, 0,-2,2,-2,-2, 2,1,-1, 1,-1,2, 2,-2,-2,3,-3,0, 0,3,-3,1, 1, 3,-3,-1,-1,3,-3,2, 2, 3,-3,-2,-2,3,-3, 3,-3,0,4, 0,-4,4,-4,-4, 4, 1,-1, 2,-2, 3,-3,1,-1,2,-2,3,-3,-4,-4,-4,-4,-4,-4,4, 4,4, 4,4, 4,0, 0,5,-5,5,-5, 5,-5, 1,-1, 2,-2, 3,-3, 4,-4,1,-1,2,-2,3,-3,4,-4,-5,-5,-5,-5,-5,-5,-5,-5,5, 5,5, 5,5, 5,5, 5}
	-- rough hexagonal deployment
	fleetPosDelta2x = {0,2,-2,1,-1, 1,-1,4,-4,0, 0,2,-2,-2, 2,3,-3, 3,-3,6,-6,1,-1, 1,-1,3,-3, 3,-3,4,-4, 4,-4,5,-5, 5,-5,8,-8,4,-4, 4,-4,5,5 ,-5,-5,2, 2,-2,-2,0, 0,6, 6,-6,-6,7, 7,-7,-7,10,-10,5, 5,-5,-5,6, 6,-6,-6,7, 7,-7,-7,8, 8,-8,-8,9, 9,-9,-9,3, 3,-3,-3,1, 1,-1,-1,12,-12,6,-6, 6,-6,7,-7, 7,-7,8,-8, 8,-8,9,-9, 9,-9,10,-10,10,-10,11,-11,11,-11,4,-4, 4,-4,2,-2, 2,-2,0, 0}
	fleetPosDelta2y = {0,0, 0,1, 1,-1,-1,0, 0,2,-2,2,-2, 2,-2,1,-1,-1, 1,0, 0,3, 3,-3,-3,3,-3,-3, 3,2,-2,-2, 2,1,-1,-1, 1,0, 0,4,-4,-4, 4,3,-3, 3,-3,4,-4, 4,-4,4,-4,2,-2, 2,-2,1,-1, 1,-1, 0,  0,5,-5, 5,-5,4,-4, 4,-4,3,-3, 3,-7,2,-2, 2,-2,1,-1, 1,-1,5,-5, 5,-5,5,-5, 5,-5, 0,  0,6, 6,-6,-6,5, 5,-5,-5,4, 4,-4,-4,3, 3,-3,-3, 2,  2,-2, -2, 1,  1,-1, -1,6, 6,-6,-6,6, 6,-6,-6,6,-6}

	--						Template, 		strength
	playerShipStrength = {	["MP52 Hornet"] =			7,
							["Piranha"] = 				16,
							["Flavia P.Falcon"] =		13,
							["Phobos M3P"] =			19,
							["Atlantis"] =				52,
							["Player Cruiser"] =		40,
							["Player Missile Cr."] =	45,
							["Player Fighter"] =		7,
							["Benedict"] =				10,
							["Kiriya"] =				10,
							["Striker"] =				8,
							["ZX-Lindworm"] =			8,
							["Repulse"] =				14,
							["Ender"] =					100,
							["Nautilus"] =				12,
							["Hathcock"] =				30,
							["Maverick"] =				45,
							["Crucible"] =				45,
							["Proto-Atlantis"] =		40,
							["Surkov"] =				35,
							["Redhook"] =				11,
							["Pacu"] =					18,
							["Phobos T2"] =				19,
							["Wombat"] =				13,
							["Holmes"] =				35,
							["Focus"] =					35,
							["Flavia 2C"] = 			25,
							["Destroyer IV"] = 			25,
							["Destroyer III"] = 		25,
							["Atlantis II"] =			60	}
	playerShipCargo = 	{	["MP52 Hornet"] =			3,
							["Piranha"] = 				8,
							["Flavia P.Falcon"] =		15,
							["Phobos M3P"] =			10,
							["Atlantis"] =				6,
							["Player Cruiser"] =		6,
							["Player Missile Cr."] =	8,
							["Player Fighter"] =		3,
							["Benedict"] =				9,
							["Kiriya"] =				9,
							["Striker"] =				4,
							["ZX-Lindworm"] =			3,
							["Repulse"] =				12,
							["Ender"] =					20,
							["Nautilus"] =				7,
							["Hathcock"] =				6,
							["Maverick"] =				5,
							["Crucible"] =				5,
							["Proto-Atlantis"] =		4,
							["Surkov"] =				6,
							["Redhook"] =				8,
							["Pacu"] =					7,
							["Phobos T2"] =				9,
							["Wombat"] =				3,
							["Holmes"] =				6,
							["Focus"] =					4,
							["Flavia 2C"] = 			12,
							["Destroyer IV"] = 			5,
							["Destroyer III"] = 		7,
							["Atlantis II"] =			6	}
	--goodsList = {	{"food",0}, {"medicine",0},	{"nickel",0}, {"platinum",0}, {"gold",0}, {"dilithium",0}, {"tritanium",0}, {"luxury",0}, {"cobalt",0}, {"impulse",0}, {"warp",0}, {"shield",0}, {"tractor",0}, {"repulsor",0}, {"beam",0}, {"optic",0}, {"robotic",0}, {"filament",0}, {"transporter",0}, {"sensor",0}, {"communication",0}, {"autodoc",0}, {"lifter",0}, {"android",0}, {"nanites",0}, {"software",0}, {"circuit",0}, {"battery",0}	}
	idleFleetFunction = {orderFleetIdle1,orderFleetIdle2,orderFleetIdle3,orderFleetIdle4,orderFleetIdle5,orderFleetIdle6,orderFleetIdle7,orderFleetIdle8}
	roamingFleetFunction = {orderFleetRoaming1,orderFleetRoaming2,orderFleetRoaming3,orderFleetRoaming4,orderFleetRoaming5,orderFleetRoaming6,orderFleetRoaming7,orderFleetRoaming8}
	standGroundFleetFunction = {orderFleetStandGround1,orderFleetStandGround2,orderFleetStandGround3,orderFleetStandGround4,orderFleetStandGround5,orderFleetStandGround6,orderFleetStandGround7,orderFleetStandGround8}
	attackFleetFunction = {orderFleetAttack1,orderFleetAttack2,orderFleetAttack3,orderFleetAttack4,orderFleetAttack5,orderFleetAttack6,orderFleetAttack7,orderFleetAttack8}
	defendFleetFunction = {orderFleetDefend1,orderFleetDefend2,orderFleetDefend3,orderFleetDefend4,orderFleetDefend5,orderFleetDefend6,orderFleetDefend7,orderFleetDefend8}
	flyFleetFunction = {orderFleetFly1,orderFleetFly2,orderFleetFly3,orderFleetFly4,orderFleetFly5,orderFleetFly6,orderFleetFly7,orderFleetFly8}
	flyBlindFleetFunction = {orderFleetFlyBlind1,orderFleetFlyBlind2,orderFleetFlyBlind3,orderFleetFlyBlind4,orderFleetFlyBlind5,orderFleetFlyBlind6,orderFleetFlyBlind7,orderFleetFlyBlind8}
	dockFleetFunction = {orderFleetDock1,orderFleetDock2,orderFleetDock3,orderFleetDock4,orderFleetDock5,orderFleetDock6,orderFleetDock7,orderFleetDock8}
	associatedTypeDistance = {	["PlayerSpaceship"] = 2000,
								["SpaceStation"] = 2000,
								["SupplyDrop"] = 50,
								["WarpJammer"] = 200,
								["Mine"] = 200,
								["Asteroid"] = 200,
								["BlackHole"] = 5200,
								["Nebula"] = 200, 
								["Artifact"] = 200, 
								["ScanProbe"] = 200, 
								["VisualAsteroid"] = 200, 
								["WormHole"] = 2625,
								["CpuShip"] = 2000}
	playerShipDistance = {	["MP52 Hornet"] =			100,
							["Piranha"] = 				200,
							["Flavia P.Falcon"] =		200,
							["Phobos M3P"] =			200,
							["Atlantis"] =				400,
							["Player Cruiser"] =		400,
							["Player Missile Cr."] =	200,
							["Player Fighter"] =		100,
							["Benedict"] =				400,
							["Kiriya"] =				400,
							["Striker"] =				200,
							["ZX-Lindworm"] =			100,
							["Repulse"] =				200,
							["Ender"] =					2000,
							["Nautilus"] =				200,
							["Hathcock"] =				200,
							["Maverick"] =				200,
							["Crucible"] =				200,
							["Proto-Atlantis"] =		400,
							["Surkov"] =				200,
							["Redhook"] =				200,
							["Pacu"] =					200,
							["Phobos T2"] =				200,
							["Wombat"] =				100,
							["Holmes"] =				200,
							["Focus"] =					200,
							["Flavia 2C"] = 			200,
							["Destroyer IV"] = 			400,
							["Destroyer III"] = 		200,
							["Atlantis II"] =			400	}
	spaceStationDistance = {["Small Station"] = 400, ["Medium Station"] = 1200, ["Large Station"] = 1400, ["Huge Station"] = 2000}
	commonGoods = {"food","medicine","nickel","platinum","gold","dilithium","tritanium","luxury","cobalt","impulse","warp","shield","tractor","repulsor","beam","optic","robotic","filament","transporter","sensor","communication","autodoc","lifter","android","nanites","software","circuit","battery"}
	componentGoods = {"impulse","warp","shield","tractor","repulsor","beam","optic","robotic","filament","transporter","sensor","communication","autodoc","lifter","android","nanites","software","circuit","battery"}
	mineralGoods = {"nickel","platinum","gold","dilithium","tritanium","cobalt"}
	goods = {}					--overall tracking of goods
	tradeFood = {}				--stations that will trade food for other goods
	tradeLuxury = {}			--stations that will trade luxury for other goods
	tradeMedicine = {}			--stations that will trade medicine for other goods
	cargoInventoryList = {}		--for inventory button function
	table.insert(cargoInventoryList,cargoInventory1)
	table.insert(cargoInventoryList,cargoInventory2)
	table.insert(cargoInventoryList,cargoInventory3)
	table.insert(cargoInventoryList,cargoInventory4)
	table.insert(cargoInventoryList,cargoInventory5)
	table.insert(cargoInventoryList,cargoInventory6)
	table.insert(cargoInventoryList,cargoInventory7)
	table.insert(cargoInventoryList,cargoInventory8)
	healthCheckTimerInterval = 10
	healthCheckTimer = healthCheckTimerInterval
	rendezvousPoints = {}
	escapePodList = {}
	artifactCounter = 0
	artifactNumber = 0
	dropOrExtractAction = "Drop"
	marinePointList = {}
	engineerPointList = {}
	medicPointList = {}
	scanClueList = {}
	scanComplexity = 1
	scanDepth = 1
	--Default GM supply drop gives:
	--500 energy
	--4 Homing
	--1 Nuke
	--2 Mines
	--1 EMP
	supplyEnergy = 500
	supplyHoming = 4
	supplyNuke = 1
	supplyMine = 2
	supplyEMP = 1
	supplyHVLI = 0
	supplyRepairCrew = 0
	supplyCoolant = 0
	shipTemplateDistance = {	["MT52 Hornet"] =					100,
								["MU52 Hornet"] =					100,
								["Adder MK5"] =						100,
								["Adder MK4"] =						100,
								["Adder MK6"] =						100,
								["WX-Lindworm"] =					100,
								["Phobos T3"] =						200,
								["Phobos M3"] =						200,
								["Nirvana R5"] =					200,
								["Nirvana R5A"] =					200,
								["Storm"] =							200,
								["Piranha F12"] =					200,
								["Piranha F12.M"] =					200,
								["Piranha F8"] =					200,
								["Stalker Q7"] =					200,
								["Stalker R7"] =					200,
								["Ranus U"] =						200,
								["Flavia"] =						200,
								["Flavia Falcon"] =					200,
								["Tug"] =							200,
								["Fighter"] =						100,
								["Karnack"] =						200,
								["Cruiser"] =						200,
								["Missile Cruiser"] =				200,
								["Gunship"] =						400,
								["Adv. Gunship"] =					400,
								["Strikeship"] = 					200,
								["Adv. Striker"] = 					300,
								["Dreadnought"] =					400,
								["Battlestation"] =					2000,
								["Weapons platform"] =				200,
								["Blockade Runner"] =				400,
								["Ktlitan Fighter"] =				300,
								["Ktlitan Breaker"] =				300,
								["Ktlitan Worker"] =				300,
								["Ktlitan Drone"] =					300,
								["Ktlitan Feeder"] =				300,
								["Ktlitan Scout"] =					300,
								["Ktlitan Destroyer"] = 			500,
								["Ktlitan Queen"] =					500,
								["Transport1x1"] =					600,
								["Transport1x2"] =					600,
								["Transport1x3"] =					600,
								["Transport1x4"] =					800,
								["Transport1x5"] =					800,
								["Transport2x1"] =					600,
								["Transport2x2"] =					600,
								["Transport2x3"] =					600,
								["Transport2x4"] =					800,
								["Transport2x5"] =					800,
								["Transport3x1"] =					600,
								["Transport3x2"] =					600,
								["Transport3x3"] =					600,
								["Transport3x4"] =					800,
								["Transport3x5"] =					800,
								["Transport4x1"] =					600,
								["Transport4x2"] =					600,
								["Transport4x3"] =					600,
								["Transport4x4"] =					800,
								["Transport4x5"] =					800,
								["Transport5x1"] =					600,
								["Transport5x2"] =					600,
								["Transport5x3"] =					600,
								["Transport5x4"] =					800,
								["Transport5x5"] =					800,
								["Odin"] = 							1500,
								["Atlantis X23"] =					400,
								["Starhammer II"] =					400,
								["Defense platform"] =				800,
								["Personnel Freighter 1"] =			600,
								["Personnel Freighter 2"] =			600,
								["Personnel Freighter 3"] =			600,
								["Personnel Freighter 4"] =			800,
								["Personnel Freighter 5"] =			800,
								["Personnel Jump Freighter 3"] =	600,
								["Personnel Jump Freighter 4"] =	800,
								["Personnel Jump Freighter 5"] =	800,
								["Goods Freighter 1"] =				600,
								["Goods Freighter 2"] =				600,
								["Goods Freighter 3"] =				600,
								["Goods Freighter 4"] =				800,
								["Goods Freighter 5"] =				800,
								["Goods Jump Freighter 3"] =		600,
								["Goods Jump Freighter 4"] =		800,
								["Goods Jump Freighter 5"] =		800,
								["Garbage Freighter 1"] =			600,
								["Garbage Freighter 2"] =			600,
								["Garbage Freighter 3"] =			600,
								["Garbage Freighter 4"] =			800,
								["Garbage Freighter 5"] =			800,
								["Garbage Jump Freighter 3"] =		600,
								["Garbage Jump Freighter 4"] =		800,
								["Garbage Jump Freighter 5"] =		800,
								["Equipment Freighter 1"] =			600,
								["Equipment Freighter 2"] =			600,
								["Equipment Freighter 3"] =			600,
								["Equipment Freighter 4"] =			800,
								["Equipment Freighter 5"] =			800,
								["Equipment Jump Freighter 3"] =	600,
								["Equipment Jump Freighter 4"] =	800,
								["Equipment Jump Freighter 5"] =	800,
								["Fuel Freighter 1"] =				600,
								["Fuel Freighter 2"] =				600,
								["Fuel Freighter 3"] =				600,
								["Fuel Freighter 4"] =				800,
								["Fuel Freighter 5"] =				800,
								["Fuel Jump Freighter 3"] =			600,
								["Fuel Jump Freighter 4"] =			800,
								["Fuel Jump Freighter 5"] =			800,
								["Adder MK3"] =						100,
								["Adder MK7"] =						100,
								["Adder MK8"] =						100,
								["Adder MK9"] =						100,
								["Phobos R2"] =						200,
								["MV52 Hornet"] =					100,
								["Nirvana R3"] =					200,
								["Fiend G3"] =						400,
								["Fiend G4"] =						400,
								["Fiend G5"] =						400,
								["Fiend G6"] =						400,
								["K2 Fighter"] =					300,
								["K3 Fighter"] =					300,
								["Jump Carrier"] =					800		}
	unscannedClues = {	["Energy Signature"] = "Energy signature",
						["Trace Elements"] = "Trace elements",
						["Warp Residue"] = "Warp residue",
						["STC Distortion"] = "Space time continuum distortion",
						["Jump Drive Ind"] = "Jump drive usage indicators",
						["Gas Anomaly"] = "Gaseous anomaly",
						["Chroniton Parts"] = "Chroniton particles",
						["Impulse Trail"] = "Impulse drive trail",
						["Ion Particles"] = "Ion particle trail",
						["Space Debris"] = "Space debris",
						["Energy Source"] = "Energy source",
						["Shielded Object"] = "Shielded object",
						["Unidentifiable Obj"] = "Unidentifiable object",
						["Container"] = "Container",
						["Sensor Reflect"] = "Sensor reflection" }
	unscannedClueKey = "Energy Signature"
	unscannedClueValue = unscannedClues[unscannedClueKey]
	scannedClues1 = {	["None"] = "None",
						["Kraylor"] = "Kraylor",
						["Independent"] = "Independent",
						["Ghosts"] = "Ghosts in the machine",
						["Arlenian"] = "Arlenian",
						["Human"] = "Human Navy",
						["Exuari"] = "Exuari",
						["Ktlitan"] = "Ktlitan",
						["Unknown"] = "Unknown",
						["Unusual"] = "Unusual",
						["Irregular"] = "Irregular",
						["Contains"] = "Contains",
						["Significant"] = "Significant" }
	scannedClueKey1 = "None"
	scannedClueValue1 = scannedClues1[scannedClueKey1]
	scannedClues2 = {	["None"] = "None",
						["Vessel"] = "Vessel",
						["Space Debris"] = "Space debris",
						["Ambassador"] = "Ambassador",
						["Pirate"] = "Pirate",
						["Delegate"] = "Delegate",
						["Officer"] = "Officer",
						["Spy"] = "Spy",
						["Agent"] = "Agent",
						["Scientist"] = "Scientist",
						["Miner"] = "Miner",
						["Adjunct"] = "Adjunct",
						["Minerals"] = "Minerals",
						["Components"] = "Components",
						["Contraband"] = "Contraband",
						["Food"] = "food",
						["medicine"] = "medicine",
						["luxury"] = "luxury",
						["gold"] = "gold",
						["platinum"] = "platinum",
						["dilithium"] = "dilithium",
						["tritanium"] = "tritanium",
						["nickel"] = "nickel",
						["cobalt"] = "cobalt",
						["impulse"] = "impulse",
						["warp"] = "warp",
						["shield"] = "shield",
						["tractor"] = "tractor",
						["repulsor"] = "repulsor",
						["beam"] = "beam",
						["optic"] = "optic",
						["robotic"] = "robotic",
						["filament"] = "filament",
						["transporter"] = "transporter",
						["sensor"] = "sensor",
						["communication"] = "communication",
						["autodoc"] = "autodoc",
						["lifter"] = "lifter",
						["android"] = "android",
						["nanites"] = "nanites",
						["software"] = "software",
						["circuit"] = "circuit",
						["battery"] = "battery",
						["amounts of"] = "amounts of" }
	scannedClueKey2 = "None"
	scannedClueValue2 = scannedClues2[scannedClueKey2]
	scannedClues3 = {	["None"] = "None",
						["Frigate"] = "Class Frigate",
						["Fighter"] = "Class Fighter",
						["Freighter"] = "Type Freighter",
						["Starhammer II"] = "Type Starhammer II",
						["Atlantis X23"] = "Type Atlantis X23",
						["Blockade Runner"] = "Type Blockade Runner",
						["Battlestation"] = "Type Battlestation",
						["Dreadnought"] = "Type Dreadnought",
						["Adv. Striker"] = "Type Advanced Striker",
						["Strikeship"] = "Type Strikeship",
						["Adv. Gunship"] = "Type Advanced Gunship",
						["Gunship"] = "Type Gunship",
						["Missile Cruiser"] = "Type Missile Cruiser",
						["Cruiser"] = "Type Cruiser",
						["Karnack"] = "Type Karnack",
						["Tug"] = "Type Tug",
						["Flavia Falcon"] = "Type Flavia Falcon",
						["Flavia"] = "Type Flavia",
						["Ranus U"] = "Type Ranus U",
						["Stalker R7"] = "Type Stalker R7",
						["Stalker Q7"] = "Type Stalker Q7",
						["Piranha"] = "Type Piranha",
						["Storm"] = "Type Storm",
						["Nirvana"] = "Type Nirvana",
						["Phobos"] = "Type Phobos",
						["Lindworm"] = "Type Lindworm",
						["Adder"] = "Type Adder",
						["Hornet"] = "Type Hornet",
						["Obsidian"] = "Of the Obsidian Order",
						["Council"] = "Of the High Council",
						["Kentar"] = "From Kentar",
						["Gold"] = "gold",
						["Platinum"] = "platinum",
						["Nickel"] = "nickel",
						["Dilithium"] = "dilithium",
						["Tritanium"] = "tritanium",
						["Cobalt"] = "cobalt"	}
	scannedClueKey3 = "None"
	scannedClueValue3 = scannedClues3[scannedClueKey3]
	scannedClues4 = {	["None"] = "None",
						["Was Here"] = "was here",
						["Destroyed"] = "was destroyed here",
						["Flew Thru"] = "flew through here",
						["Hid"] = "Hid here",
						["Chg course"] = "changed course here",
						["Disappeared"] = "disappeared here",
						["Lingered"] = "Lingered here",
						["Abducted"] = "was abducted here",
						["Detected"] = "detected",
						["Discovered"] = "discovered",
						["Observed"] = "observed"	}
	scannedClueKey4 = "None"
	scannedClueValue4 = scannedClues4[scannedClueKey4]
	scannedClues5 = {	["None"] = "None",
						["0"] = "Now heading ~0",
						["45"] = "Now heading ~45",
						["90"] = "Now heading ~90",
						["135"] = "Now heading ~135",
						["180"] = "Now heading ~180",
						["225"] = "Now heading ~225",
						["270"] = "Now heading ~270",
						["315"] = "Now heading ~315"	}
	scannedClueKey5 = "None"
	scannedClueValue5 = scannedClues5[scannedClueKey5]
	scan_clue_retrievable = false
	timer_display_helm = false
	timer_display_weapons = false
	timer_display_engineer = false
	timer_display_science = false
	timer_display_relay = false
	timer_start_length = 5
	timer_started = false
	timer_purpose = "Timer"
	coolant_amount = 1
	jammer_range = 10000
end
function initialGMFunctions()
	clearGMFunctions()
	addGMFunction("+Initial Set Up",initialSetUp)
	addGMFunction("+Spawn Fleet",spawnGMFleet)
	addGMFunction("+Order Fleet",orderFleet)
	addGMFunction("+Order Ship",orderShip)
	addGMFunction("+Drop Point",dropPoint)
	addGMFunction("+Scan Clue",scanClue)
	addGMFunction("+Tweak Terrain",tweakTerrain)
	addGMFunction("+Countdown Timer",countdownTimer)
	addGMFunction("+End Mission",endMission)
end
---------------------
--  Initial set up --
---------------------
function initialSetUp()
	clearGMFunctions()
	addGMFunction("-Main from Initial",initialGMFunctions)
	addGMFunction("+Start Region",setStartRegion)
	local playerShipCount = 0
	local highestPlayerIndex = 0
	for pidx=1,8 do
		local p = getPlayerShip(pidx)
		if p ~= nil then
			if p:isValid() then
				playerShipCount = playerShipCount + 1
			end
			highestPlayerIndex = pidx
		end
	end
	addGMFunction(string.format("+Player ships %i/%i",playerShipCount,highestPlayerIndex),playerShip)
	addGMFunction("+Wormholes",setWormholes)
	addGMFunction("+Zones",changeZones)
end
--------------------------
--	Player Ship set up  --
--------------------------
function playerShip()
	clearGMFunctions()
	addGMFunction("-Main",initialGMFunctions)
	addGMFunction("-Setup",initialSetUp)
	addGMFunction("+Tweak player",tweakPlayerShip)
	if playerHalberd == nil then
		addGMFunction("Halberd",createPlayerShipHalberd)
	end
	if playerHolmes == nil then
		addGMFunction("Holmes",createPlayerShipHolmes)
	end
	if playerOsprey == nil then
		addGMFunction("Osprey",createPlayerShipOsprey)
	end
	if playerRattler == nil then
		addGMFunction("Rattler",createPlayerShipRattler)
	end
	if playerSimian == nil then
		addGMFunction("Simian",createPlayerShipSimian)
	end
	if playerSpyder == nil then
		addGMFunction("Spyder",createPlayerShipSpyder)
	end
	if playerThunderbird == nil then
		addGMFunction("Thunderbird",createPlayerShipThunderbird)
	end
--[[	
	if playerAmbition == nil then
		addGMFunction("Ambition",createPlayerShipAmbition)
	end
	if playerArwine == nil then
		addGMFunction("Arwine",createPlayerShipArwine)
	end
	if playerBlazon == nil then
		addGMFunction("Blazon",createPlayerShipBlazon)
	end
	if playerHeadhunter == nil then
		addGMFunction("Headhunter",createPlayerShipHeadhunter)
	end
	if playerMagnum == nil then
		addGMFunction("Magnum",createPlayerShipMagnum)
	end
	if playerNarsil == nil then
		addGMFunction("Narsil",createPlayerShipNarsil)
	end
	if playerSpike == nil then
		addGMFunction("Spike",createPlayerShipSpike)
	end
	if playerSting == nil then
		addGMFunction("Sting",createPlayerShipSting)
	end
	if playerWombat == nil then
		addGMFunction("Wombat",createPlayerShipWombat)
	end
--]]
end
function createPlayerShipHalberd()
	playerHalberd = PlayerSpaceship():setTemplate("Atlantis"):setFaction("Human Navy"):setCallSign("Halberd")
	playerHalberd:setTypeName("Proto-Atlantis")
	playerHalberd:setRepairCrewCount(4)					--more repair crew (vs 3)
	playerHalberd:setImpulseMaxSpeed(70)				--slower impulse max (vs 90)
	playerHalberd:setRotationMaxSpeed(14)				--faster spin (vs 10)
	playerHalberd:setJumpDriveRange(3000,30000)			--shorter jump drive range (vs 5-50)
	playerHalberd:setHullMax(200)						--weaker hull (vs 250)
	playerHalberd:setHull(200)							
	playerHalberd:setShieldsMax(150,150)				--weaker shields (vs 200)
	playerHalberd:setShields(150,150)
	
--                 				 Arc, Dir, Range, CycleTime, Dmg
	playerHalberd:setBeamWeapon(0, 5, -10,  1500,       6.0, 8)		--narrower turreted beams
	playerHalberd:setBeamWeapon(1, 5,  10,  1500,       6.0, 8)		--vs arc:100, dir:-20
--									    Arc, Dir, Rotate speed
	playerHalberd:setBeamWeaponTurret(0, 70, -10, .25)
	playerHalberd:setBeamWeaponTurret(1, 70,  10, .25)

	playerHalberd:setWeaponTubeDirection(0,-90)			--front left facing (vs left)
	playerHalberd:setWeaponTubeDirection(1,-60)			--front left facing (vs left)
	playerHalberd:setWeaponTubeDirection(2, 60)			--front right facing (vs right)
	playerHalberd:setWeaponTubeDirection(3, 90)			--front right facing (vs right)
	playerHalberd:setWeaponTubeExclusiveFor(0,"Nuke")	--HVLI only (vs all but Mine)
	playerHalberd:setWeaponTubeExclusiveFor(1,"HVLI")	--Nuke only (vs all but Mine)
	playerHalberd:setWeaponTubeExclusiveFor(2,"Homing")	--Homing only (vs all but Mine)
	playerHalberd:setWeaponTubeExclusiveFor(3,"EMP")	--EMP only (vs all but Mine)
	playerHalberd:addReputationPoints(50)
	playerShip()
end
function createPlayerShipOsprey()
	playerOsprey = PlayerSpaceship():setTemplate("Flavia P.Falcon"):setFaction("Human Navy"):setCallSign("Osprey")
	playerOsprey:setTypeName("Flavia 2C")
	playerOsprey:setRotationMaxSpeed(20)					--faster spin (vs 10)
	playerOsprey:setImpulseMaxSpeed(70)						--faster (vs 60)
	playerOsprey:setShieldsMax(100, 100)					--stronger shields (vs 70, 70)
	playerOsprey:setShields(100, 100)
	playerOsprey:setBeamWeapon(0, 40, -10, 1200.0, 5.5, 6.5)	--two forward (vs rear)
	playerOsprey:setBeamWeapon(1, 40,  10, 1200.0, 5.5, 6.5)	--faster (vs 6.0) and stronger (vs 6.0)
	playerOsprey:setWeaponTubeCount(3)						--more (vs 1)
	playerOsprey:setWeaponTubeDirection(0,-90)				--left facing (vs none)
	playerOsprey:setWeaponTubeDirection(1, 90)				--right facing (vs none)
	playerOsprey:setWeaponTubeDirection(2, 180)				--rear facing
	playerOsprey:setWeaponTubeExclusiveFor(0,"Homing")		
	playerOsprey:setWeaponTubeExclusiveFor(1,"Homing")
	playerOsprey:setWeaponStorageMax("EMP",2)				--more (vs 0)
	playerOsprey:setWeaponStorage("EMP", 2)				
	playerOsprey:setWeaponStorageMax("Nuke",2)				--more (vs 1)
	playerOsprey:setWeaponStorage("Nuke", 2)				
	playerOsprey:setWeaponStorageMax("Mine",2)				--more (vs 1)
	playerOsprey:setWeaponStorage("Mine", 2)				
	playerOsprey:setWeaponStorageMax("Homing",4)			--more (vs 3)
	playerOsprey:setWeaponStorage("Homing", 4)				
	playerOsprey:addReputationPoints(50)
	playerShip()
end
function createPlayerShipSimian()
	playerSimian = PlayerSpaceship():setTemplate("Player Missile Cr."):setFaction("Human Navy"):setCallSign("Simian")
	playerSimian:setTypeName("Destroyer III")
	playerSimian:setWarpDrive(false)
	playerSimian:setJumpDrive(true)
	playerSimian:setJumpDriveRange(2000,20000)						--shorter than typical jump drive range (vs 5-50)
	playerSimian:setHullMax(100)									--weaker hull (vs 200)
	playerSimian:setHull(100)
--                 				 Arc, Dir, Range, CycleTime, Damage
	playerSimian:setBeamWeapon(0,  8,   0, 800.0,         5, 6)		--turreted beam (vs none)
--									    Arc, Dir, Rotate speed
	playerSimian:setBeamWeaponTurret(0, 270,   0, .2)				--slow turret
	playerSimian:setWeaponTubeCount(5)								--fewer (vs 7)
	playerSimian:setWeaponTubeDirection(2, -90)						--left (vs right)
	playerSimian:setWeaponTubeDirection(4, 180)						--rear (vs left)
	playerSimian:setWeaponTubeExclusiveFor(4,"Mine")
	playerSimian:setWeaponStorageMax("Homing",10)					--less (vs 30)
	playerSimian:setWeaponStorage("Homing", 10)				
	playerSimian:setWeaponStorageMax("Nuke",4)						--less (vs 8)
	playerSimian:setWeaponStorage("Nuke", 4)				
	playerSimian:setWeaponStorageMax("EMP",5)						--less (vs 10)
	playerSimian:setWeaponStorage("EMP", 5)				
	playerSimian:setWeaponStorageMax("Mine",6)						--less (vs 12)
	playerSimian:setWeaponStorage("Mine", 6)				
	playerSimian:setWeaponStorageMax("HVLI",10)						--more (vs 0)
	playerSimian:setWeaponStorage("HVLI", 10)				
end
function createPlayerShipThunderbird()
	playerThunderbird = PlayerSpaceship():setTemplate("Player Cruiser"):setFaction("Human Navy"):setCallSign("Thunderbird")
	playerThunderbird:setTypeName("Destroyer IV")
	playerThunderbird:setJumpDriveRange(2000,20000)				--shorter jump drive range (vs 5-50)
	playerThunderbird:setShieldsMax(100, 100)					--stronger shields (vs 80, 80)
	playerThunderbird:setShields(100, 100)
	playerThunderbird:setHullMax(100)							--weaker hull (vs 200)
	playerThunderbird:setHull(100)
	playerThunderbird:setBeamWeapon(0, 40, -10, 1000.0, 5, 6)	--narrower (40 vs 90), faster (5 vs 6), weaker (6 vs 10)
	playerThunderbird:setBeamWeapon(1, 40,  10, 1000.0, 5, 6)
	playerThunderbird:setWeaponTubeDirection(0,-60)				--left -60 (vs -5)
	playerThunderbird:setWeaponTubeDirection(1, 60)				--right 60 (vs 5)
	playerThunderbird:setWeaponStorageMax("Homing",6)			--less (vs 12)
	playerThunderbird:setWeaponStorage("Homing", 6)				
	playerThunderbird:setWeaponStorageMax("Nuke",2)				--fewer (vs 4)
	playerThunderbird:setWeaponStorage("Nuke", 2)				
	playerThunderbird:setWeaponStorageMax("EMP",3)				--fewer (vs 6)
	playerThunderbird:setWeaponStorage("EMP", 3)				
	playerThunderbird:setWeaponStorageMax("Mine",4)				--fewer (vs 8)
	playerThunderbird:setWeaponStorage("Mine", 4)				
	playerThunderbird:setWeaponStorageMax("HVLI",6)				--more (vs 0)
	playerThunderbird:setWeaponStorage("HVLI", 6)				
end
function createPlayerShipHolmes()
	playerHolmes = PlayerSpaceship():setTemplate("Crucible"):setFaction("Human Navy"):setCallSign("Watson")
	playerHolmes:setTypeName("Holmes")
	playerHolmes:setImpulseMaxSpeed(70)						--slower (vs 80)
--                  			 Arc, Dir,  Range, CycleTime, Dmg
	playerHolmes:setBeamWeapon(0, 60, -85, 1000.0, 6.0, 5)	--broadside beams, narrower (vs 70)
	playerHolmes:setBeamWeapon(1, 60, -95, 1000.0, 6.0, 5)	
	playerHolmes:setBeamWeapon(2, 60,  85, 1000.0, 6.0, 5)	
	playerHolmes:setBeamWeapon(3, 60,  95, 1000.0, 6.0, 5)	
	playerHolmes:setWeaponTubeCount(4)						--fewer (vs 6)
	playerHolmes:setWeaponTubeExclusiveFor(0,"Homing")		--tubes only shoot homing missiles (vs more options)
	playerHolmes:setWeaponTubeExclusiveFor(1,"Homing")
	playerHolmes:setWeaponTubeExclusiveFor(2,"Homing")
	playerHolmes:setWeaponTubeExclusiveFor(3,"Mine")
	playerHolmes:setWeaponTubeDirection(3, 180)
	playerHolmes:setWeaponStorageMax("Homing",12)			--more (vs 8)
	playerHolmes:setWeaponStorage("Homing", 12)				
	playerHolmes:setWeaponStorageMax("HVLI",0)				--fewer
	playerHolmes:setWeaponStorage("HVLI", 0)				
	playerHolmes:setWeaponStorageMax("EMP",0)				--fewer
	playerHolmes:setWeaponStorage("EMP", 0)				
	playerHolmes:setWeaponStorageMax("Nuke",0)				--fewer
	playerHolmes:setWeaponStorage("Nuke", 0)	
	playerHolmes:addReputationPoints(50)
	playerShip()			
end
function createPlayerShipRattler()
	playerRattler = PlayerSpaceship():setTemplate("ZX-Lindworm"):setFaction("Human Navy"):setCallSign("Rattler")
	playerRattler:setTypeName("MX-Lindworm")
	playerRattler:setRepairCrewCount(2)
	playerRattler:setJumpDrive(true)
	playerRattler:setJumpDriveRange(3000,20000)
	playerRattler:setImpulseMaxSpeed(85)
	playerRattler:setBeamWeaponTurret( 0, 270, 180, 1)
	playerShip()
end
function createPlayerShipSpyder()
	playerSpyder = PlayerSpaceship():setTemplate("Atlantis"):setFaction("Human Navy"):setCallSign("Spyder")
	playerSpyder:setTypeName("Atlantis II")
	playerSpyder:setRepairCrewCount(4)					--more repair crew (vs 3)
	playerSpyder:setImpulseMaxSpeed(80)					--slower impulse max (vs 90)
	playerSpyder:setWeaponTubeCount(6)					--one more tube
	playerSpyder:setWeaponTubeDirection(5,0)			--front facing
	playerSpyder:weaponTubeDisallowMissle(5,"Mine")		--no Mine
	playerSpyder:weaponTubeDisallowMissle(5,"EMP")		--no EMP
	playerSpyder:weaponTubeDisallowMissle(5,"Nuke")		--no Nuke
	playerSpyder:setWeaponTubeDirection(0,-60)			--left front facing
	playerSpyder:setWeaponTubeDirection(1,-120)			--left rear facing
	playerSpyder:setWeaponTubeDirection(2,60)			--right front facing
	playerSpyder:setWeaponTubeDirection(3,120)			--right rear facing
	playerSpyder:addReputationPoints(50)
	playerShip()
end
function createPlayerShipNarsil()
	playerNarsil = PlayerSpaceship():setTemplate("Atlantis"):setFaction("Human Navy"):setCallSign("Narsil")
	playerNarsil:setTypeName("Proto-Atlantis")
	playerNarsil:setRepairCrewCount(4)					--more repair crew (vs 3)
	playerNarsil:setImpulseMaxSpeed(70)					--slower impulse max (vs 90)
	playerNarsil:setRotationMaxSpeed(14)				--faster spin (vs 10)
	playerNarsil:setJumpDrive(false)					--no Jump
	playerNarsil:setWarpDrive(true)						--add warp
	playerNarsil:setHullMax(200)						--weaker hull (vs 250)
	playerNarsil:setHull(200)							
	playerNarsil:setShieldsMax(150,150)					--weaker shields (vs 200)
	playerNarsil:setShields(150,150)
	playerNarsil:setWeaponTubeCount(6)					--one more forward tube, less flexible ordnance
	playerNarsil:setWeaponTubeDirection(0,0)			--front facing
	playerNarsil:setWeaponTubeExclusiveFor(0,"HVLI")	--HVLI only
	playerNarsil:setWeaponTubeDirection(1,-90)			--left facing
	playerNarsil:weaponTubeDisallowMissle(1,"Mine")		--all but mine
	playerNarsil:setWeaponTubeDirection(2,-90)			--left facing
	playerNarsil:setWeaponTubeExclusiveFor(2,"HVLI")	--HVLI only
	playerNarsil:setWeaponTubeDirection(3,90)			--right facing
	playerNarsil:weaponTubeDisallowMissle(3,"Mine")		--all but mine
	playerNarsil:setWeaponTubeDirection(4,90)			--right facing
	playerNarsil:setWeaponTubeExclusiveFor(4,"HVLI")	--HVLI only
	playerNarsil:setWeaponTubeDirection(5,180)			--rear facing
	playerNarsil:setWeaponTubeExclusiveFor(5,"Mine")	--Mine only
	playerNarsil:addReputationPoints(50)
	playerShip()
end
--[[ destroyed 1Feb2020
function createPlayerShipAmbition()
	playerAmbition = PlayerSpaceship():setTemplate("Phobos M3P"):setFaction("Human Navy"):setCallSign("Ambition")
	playerAmbition:setTypeName("Phobos T2")
	playerAmbition:setRepairCrewCount(5)					--more repair crew (vs 3)
	playerAmbition:setJumpDrive(true)						--jump drive (vs none)
	playerAmbition:setJumpDriveRange(2000,25000)			--shorter than typical jump drive range (vs 5-50)
	playerAmbition:setRotationMaxSpeed(20)					--faster spin (vs 10)
--                 				   Arc, Dir, Range, CycleTime, Dmg
	playerAmbition:setBeamWeapon(0, 10, -15,  1200,         8, 6)
	playerAmbition:setBeamWeapon(1, 10,  15,  1200,        16, 6)
--										 Arc, Dir, Rotate speed
	playerAmbition:setBeamWeaponTurret(0, 90, -15, .2)		--slow turret beams
	playerAmbition:setBeamWeaponTurret(1, 90,  15, .2)
	playerAmbition:setWeaponTubeCount(2)					--one fewer tube (1 forward, 1 rear vs 2 forward, 1 rear)
	playerAmbition:setWeaponTubeDirection(0,0)				--first tube points straight forward
	playerAmbition:setWeaponTubeDirection(1,180)			--second tube points straight back
	playerAmbition:setWeaponTubeExclusiveFor(1,"Mine")
	playerAmbition:setWeaponStorageMax("Homing",6)			--reduce homing storage (vs 10)
	playerAmbition:setWeaponStorage("Homing",6)
	playerAmbition:setWeaponStorageMax("HVLI",10)			--reduce HVLI storage (vs 20)
	playerAmbition:setWeaponStorage("HVLI",10)
	playerAmbition:addReputationPoints(50)
	playerShip()
end
--]]
--[[  destroyed 14Dec2019
function createPlayerShipArwine()
	playerArwine = PlayerSpaceship():setTemplate("Piranha"):setFaction("Human Navy"):setCallSign("Arwine")
	playerArwine:setTypeName("Pacu")
	playerArwine:setRepairCrewCount(5)						--more repair crew (vs 2)
	playerArwine:setJumpDriveRange(2000,25000)				--shorter jump drive range (vs 5-50)
	playerArwine:setImpulseMaxSpeed(70)						--faster impulse max (vs 40)
	playerArwine:setHullMax(150)							--stronger hull (vs 120)
	playerArwine:setHull(150)
	playerArwine:setShieldsMax(100,100)						--stronger shields (vs 70, 70)
	playerArwine:setShields(100,100)
	playerArwine:setBeamWeapon(0, 10, 0, 1200.0, 4.0, 4)	--one beam (vs 0)
	playerArwine:setBeamWeaponTurret(0, 80, 0, .2)			--slow turret
	playerArwine:setWeaponTubeCount(7)						--one fewer mine tube, but EMPs added
	playerArwine:setWeaponTubeDirection(6, 180)				--mine tube points straight back
	playerArwine:setWeaponTubeExclusiveFor(0,"HVLI")
	playerArwine:setWeaponTubeExclusiveFor(1,"HVLI")
	playerArwine:setWeaponTubeExclusiveFor(2,"HVLI")
	playerArwine:setWeaponTubeExclusiveFor(3,"HVLI")
	playerArwine:setWeaponTubeExclusiveFor(4,"HVLI")
	playerArwine:setWeaponTubeExclusiveFor(5,"HVLI")
	playerArwine:setWeaponTubeExclusiveFor(6,"Mine")
	playerArwine:weaponTubeAllowMissle(1,"Homing")
	playerArwine:weaponTubeAllowMissle(1,"EMP")
	playerArwine:weaponTubeAllowMissle(1,"Nuke")
	playerArwine:weaponTubeAllowMissle(4,"Homing")
	playerArwine:weaponTubeAllowMissle(4,"EMP")
	playerArwine:weaponTubeAllowMissle(4,"Nuke")
	playerArwine:setWeaponStorageMax("Mine",4)				--fewer mines (vs 8)
	playerArwine:setWeaponStorage("Mine", 4)				
	playerArwine:setWeaponStorageMax("EMP",4)				--more EMPs (vs 0)
	playerArwine:setWeaponStorage("EMP", 4)					
	playerArwine:setWeaponStorageMax("Nuke",4)				--fewer Nukes (vs 6)
	playerArwine:setWeaponStorage("Nuke", 4)				
	playerArwine:addReputationPoints(50)
	playerShip()
end
--]]
--[[ destroyed 8feb2020
function createPlayerShipBarracuda()
	--clone of Headhunter
	playerBarracuda = PlayerSpaceship():setTemplate("Piranha"):setFaction("Human Navy"):setCallSign("Barracuda")
	playerBarracuda:setTypeName("Redhook")
	playerBarracuda:setRepairCrewCount(4)						--more repair crew (vs 2)
	playerBarracuda:setJumpDriveRange(2000,25000)				--shorter jump drive range (vs 5-50)
	playerBarracuda:setHullMax(140)								--stronger hull (vs 120)
	playerBarracuda:setHull(140)
	playerBarracuda:setShieldsMax(100, 100)						--stronger shields (vs 70, 70)
	playerBarracuda:setShields(100, 100)
	playerBarracuda:setBeamWeapon(0, 10, 0, 1200.0, 4.0, 4)		--one beam (vs 0)
	playerBarracuda:setBeamWeaponTurret(0, 80, 0, 1)			--slow turret 
	playerBarracuda:setWeaponTubeCount(7)						--one fewer mine tube, but EMPs added
	playerBarracuda:setWeaponTubeDirection(6, 180)				--mine tube points straight back
	playerBarracuda:setWeaponTubeExclusiveFor(0,"HVLI")
	playerBarracuda:setWeaponTubeExclusiveFor(1,"HVLI")
	playerBarracuda:setWeaponTubeExclusiveFor(2,"HVLI")
	playerBarracuda:setWeaponTubeExclusiveFor(3,"HVLI")
	playerBarracuda:setWeaponTubeExclusiveFor(4,"HVLI")
	playerBarracuda:setWeaponTubeExclusiveFor(5,"HVLI")
	playerBarracuda:setWeaponTubeExclusiveFor(6,"Mine")
	playerBarracuda:weaponTubeAllowMissle(1,"Homing")
	playerBarracuda:weaponTubeAllowMissle(1,"EMP")
	playerBarracuda:weaponTubeAllowMissle(1,"Nuke")
	playerBarracuda:weaponTubeAllowMissle(4,"Homing")
	playerBarracuda:weaponTubeAllowMissle(4,"EMP")
	playerBarracuda:weaponTubeAllowMissle(4,"Nuke")
	playerBarracuda:setWeaponStorageMax("Mine",4)				--fewer mines (vs 8)
	playerBarracuda:setWeaponStorage("Mine", 4)				
	playerBarracuda:setWeaponStorageMax("EMP",4)				--more EMPs (vs 0)
	playerBarracuda:setWeaponStorage("EMP", 4)					
	playerBarracuda:setWeaponStorageMax("Nuke",4)				--fewer Nukes (vs 6)
	playerBarracuda:setWeaponStorage("Nuke", 4)				
	playerBarracuda:addReputationPoints(50)
	playerShip()
end
--]]
--[[	ship destroyed 24Aug2019
function createPlayerShipBlazon()
	playerBlazon = PlayerSpaceship():setTemplate("Striker"):setFaction("Human Navy"):setCallSign("Blazon")
	playerBlazon:setTypeName("Stricken")
	playerBlazon:setRepairCrewCount(2)
	playerBlazon:setImpulseMaxSpeed(105)					-- up from default of 45
	playerBlazon:setRotationMaxSpeed(35)					-- up from default of 15
	playerBlazon:setShieldsMax(80,50)						-- up from 50, 30
	playerBlazon:setShields(80,50)							-- up from 50, 30
	playerBlazon:setBeamWeaponTurret(0,60,-15,2)			-- 60: narrower than default 100, 
	playerBlazon:setBeamWeaponTurret(1,60, 15,2)			-- 2: slower than default 6
	playerBlazon:setBeamWeapon(2,20,0,1200,6,5)				-- add forward facing beam
	playerBlazon:setWeaponTubeCount(3)						-- add tubes
	playerBlazon:setWeaponTubeDirection(0,-60)
	playerBlazon:setWeaponTubeDirection(1,60)
	playerBlazon:setWeaponTubeDirection(2,180)
	playerBlazon:weaponTubeDisallowMissle(0,"Mine")
	playerBlazon:weaponTubeDisallowMissle(1,"Mine")
	playerBlazon:setWeaponTubeExclusiveFor(2,"Mine")
	playerBlazon:setWeaponStorageMax("Homing",6)
	playerBlazon:setWeaponStorage("Homing",6)
	playerBlazon:setWeaponStorageMax("EMP",2)
	playerBlazon:setWeaponStorage("EMP",2)
	playerBlazon:setWeaponStorageMax("Nuke",2)
	playerBlazon:setWeaponStorage("Nuke",2)
	playerBlazon:setWeaponStorageMax("Mine",4)
	playerBlazon:setWeaponStorage("Mine",4)
	playerBlazon:addReputationPoints(50)
	playerShip()
end
--]]
--[[
function createPlayerShipHeadhunter()
	playerHeadhunter = PlayerSpaceship():setTemplate("Piranha"):setFaction("Human Navy"):setCallSign("Headhunter")
	playerHeadhunter:setTypeName("Redhook")
	playerHeadhunter:setRepairCrewCount(4)						--more repair crew (vs 2)
	playerHeadhunter:setJumpDriveRange(2000,25000)				--shorter jump drive range (vs 5-50)
	playerHeadhunter:setHullMax(140)							--stronger hull (vs 120)
	playerHeadhunter:setHull(140)
	playerHeadhunter:setShieldsMax(100, 100)					--stronger shields (vs 70, 70)
	playerHeadhunter:setShields(100, 100)
	playerHeadhunter:setBeamWeapon(0, 10, 0, 1200.0, 4.0, 4)	--one beam (vs 0)
	playerHeadhunter:setBeamWeaponTurret(0, 80, 0, 1)			--slow turret 
	playerHeadhunter:setWeaponTubeCount(7)						--one fewer mine tube, but EMPs added
	playerHeadhunter:setWeaponTubeDirection(6, 180)				--mine tube points straight back
	playerHeadhunter:setWeaponTubeExclusiveFor(0,"HVLI")
	playerHeadhunter:setWeaponTubeExclusiveFor(1,"HVLI")
	playerHeadhunter:setWeaponTubeExclusiveFor(2,"HVLI")
	playerHeadhunter:setWeaponTubeExclusiveFor(3,"HVLI")
	playerHeadhunter:setWeaponTubeExclusiveFor(4,"HVLI")
	playerHeadhunter:setWeaponTubeExclusiveFor(5,"HVLI")
	playerHeadhunter:setWeaponTubeExclusiveFor(6,"Mine")
	playerHeadhunter:weaponTubeAllowMissle(1,"Homing")
	playerHeadhunter:weaponTubeAllowMissle(1,"EMP")
	playerHeadhunter:weaponTubeAllowMissle(1,"Nuke")
	playerHeadhunter:weaponTubeAllowMissle(4,"Homing")
	playerHeadhunter:weaponTubeAllowMissle(4,"EMP")
	playerHeadhunter:weaponTubeAllowMissle(4,"Nuke")
	playerHeadhunter:setWeaponStorageMax("Mine",4)				--fewer mines (vs 8)
	playerHeadhunter:setWeaponStorage("Mine", 4)				
	playerHeadhunter:setWeaponStorageMax("EMP",4)				--more EMPs (vs 0)
	playerHeadhunter:setWeaponStorage("EMP", 4)					
	playerHeadhunter:setWeaponStorageMax("Nuke",4)				--fewer Nukes (vs 6)
	playerHeadhunter:setWeaponStorage("Nuke", 4)				
	playerHeadhunter:addReputationPoints(50)
	playerShip()
end
--]]
--[[
function createPlayerShipMagnum()
	playerMagnum = PlayerSpaceship():setTemplate("Crucible"):setFaction("Human Navy"):setCallSign("Magnum")
	playerMagnum:setTypeName("Focus")
	playerMagnum:setImpulseMaxSpeed(70)						--slower (vs 80)
	playerMagnum:setRotationMaxSpeed(20)					--faster spin (vs 15)
	playerMagnum:setWarpDrive(false)						--no warp
	playerMagnum:setJumpDrive(true)							--jump drive
	playerMagnum:setJumpDriveRange(2500,25000)				--shorter jump drive range (vs 5-50)
	playerMagnum:setHullMax(100)							--weaker hull (vs 160)
	playerMagnum:setHull(100)
	playerMagnum:setShieldsMax(100, 100)					--weaker shields (vs 160, 160)
	playerMagnum:setShields(100, 100)
	playerMagnum:setBeamWeapon(0, 60, -20, 1000.0, 6.0, 5)	--narrower (vs 70)
	playerMagnum:setBeamWeapon(1, 60,  20, 1000.0, 6.0, 5)	
	playerMagnum:setWeaponTubeCount(4)						--fewer (vs 6)
	playerMagnum:weaponTubeAllowMissle(2,"Homing")
	playerMagnum:weaponTubeAllowMissle(2,"EMP")
	playerMagnum:weaponTubeAllowMissle(2,"Nuke")
	playerMagnum:setWeaponTubeExclusiveFor(3,"Mine")
	playerMagnum:setWeaponTubeDirection(3, 180)
	playerMagnum:setWeaponStorageMax("EMP",2)				--fewer (vs 6)
	playerMagnum:setWeaponStorage("EMP", 2)				
	playerMagnum:setWeaponStorageMax("Nuke",1)				--fewer (vs 4)
	playerMagnum:setWeaponStorage("Nuke", 1)	
	playerMagnum:addReputationPoints(50)
	playerShip()
end
--]]
--[[
function createPlayerShipSpike()
	playerSpike = PlayerSpaceship():setTemplate("Phobos M3P"):setFaction("Human Navy"):setCallSign("Spike")
	playerSpike:setTypeName("Phobos T2")
	playerSpike:setRepairCrewCount(4)					--more repair crew (vs 3)
	playerSpike:setJumpDrive(true)						--jump drive (vs none)
	playerSpike:setJumpDriveRange(2000,25000)			--shorter than typical jump drive range (vs 5-50)
	playerSpike:setRotationMaxSpeed(20)					--faster spin (vs 10)
	playerSpike:setShieldsMax(120,80)					--stronger front, weaker rear (vs 100,100)
	playerSpike:setShields(120,80)
	playerSpike:setMaxEnergy(800)						--less maximum energy (vs 1000)
	playerSpike:setEnergy(800)
--                 				Arc, Dir, Range, CycleTime, Dmg
	playerSpike:setBeamWeapon(0, 10, -30,  1200,         4, 6)	--split direction (30 vs 15)
	playerSpike:setBeamWeapon(1, 10,  30,  1200,         4, 6)	--reduced cycle time (4 vs 8)
--										 Arc, Dir, Rotate speed
	playerSpike:setBeamWeaponTurret(0, 40, -30, .2)		--slow turret beams
	playerSpike:setBeamWeaponTurret(1, 40,  30, .2)
	playerSpike:setWeaponTubeCount(2)					--one fewer tube (1 forward, 1 rear vs 2 forward, 1 rear)
	playerSpike:setWeaponTubeDirection(0,0)				--first tube points straight forward
	playerSpike:setWeaponTubeDirection(1,180)			--second tube points straight back
	playerSpike:setWeaponTubeExclusiveFor(1,"Mine")
	playerSpike:setWeaponStorageMax("Homing",8)			--reduce homing storage (vs 10)
	playerSpike:setWeaponStorage("Homing",8)
	playerSpike:setWeaponStorageMax("HVLI",16)			--reduce HVLI storage (vs 20)
	playerSpike:setWeaponStorage("HVLI",16)
	playerSpike:addReputationPoints(50)
	playerShip()
end
--]]
--[[	sent to Kraylor war front. May return later
function createPlayerShipSting()
	playerSting = PlayerSpaceship():setTemplate("Hathcock"):setFaction("Human Navy"):setCallSign("Sting")
	playerSting:setTypeName("Surkov")
	playerSting:setRepairCrewCount(3)	--more repair crew (vs 2)
	playerSting:setImpulseMaxSpeed(60)	--faster impulse max (vs 50)
	playerSting:setJumpDrive(false)		--no jump
	playerSting:setWarpDrive(true)		--add warp
	playerSting:setWeaponTubeCount(3)	--one more tube for mines, no other splash ordnance
	playerSting:setWeaponTubeDirection(0, -90)
	playerSting:weaponTubeDisallowMissle(0,"Mine")
	playerSting:weaponTubeDisallowMissle(0,"Nuke")
	playerSting:weaponTubeDisallowMissle(0,"EMP")
	playerSting:setWeaponStorageMax("Mine",3)
	playerSting:setWeaponStorage("Mine",3)
	playerSting:setWeaponStorageMax("Nuke",0)
	playerSting:setWeaponStorage("Nuke",0)
	playerSting:setWeaponStorageMax("EMP",0)
	playerSting:setWeaponStorage("EMP",0)
	playerSting:setWeaponTubeDirection(1, 90)
	playerSting:weaponTubeDisallowMissle(1,"Mine")
	playerSting:weaponTubeDisallowMissle(1,"Nuke")
	playerSting:weaponTubeDisallowMissle(1,"EMP")
	playerSting:setWeaponTubeDirection(2,180)
	playerSting:setWeaponTubeExclusiveFor(2,"Mine")
	playerSting:addReputationPoints(50)
	playerShip()
end
--]]
--[[ destroyed 1Feb2020
function createPlayerShipWombat()
	playerWombat = PlayerSpaceship():setTemplate("ZX-Lindworm"):setFaction("Human Navy"):setCallSign("Devon")
	playerWombat:setTypeName("Wombat")
	playerWombat:setRepairCrewCount(4)						--more repair crew (vs 1)
	playerWombat:setJumpDrive(true)							--jump drive (vs none)
	playerWombat:setJumpDriveRange(3000,20000)
	playerWombat:setImpulseMaxSpeed(85)						--faster (vs 70)
	playerWombat:setBeamWeapon(0, 10, 0, 600.0, 4.0, 3)		--extra beam (vs 1@ 700 6.0, 2)
	playerWombat:setBeamWeapon(1, 10, 0, 900.0, 4.0, 3)	
	playerWombat:setBeamWeaponTurret( 0, 80, -20, .3)
	playerWombat:setBeamWeaponTurret( 1, 80,  20, .3)
	playerWombat:setWeaponTubeCount(5)						--more (vs 3)
	playerWombat:setWeaponTubeDirection(0, 180)				
	playerWombat:setWeaponTubeDirection(1, 180)				
	playerWombat:setWeaponTubeDirection(2, 180)				
	playerWombat:setWeaponTubeDirection(3, 180)
	playerWombat:setWeaponTubeDirection(4, 180)
	playerWombat:setWeaponTubeExclusiveFor(0,"HVLI")
	playerWombat:setWeaponTubeExclusiveFor(1,"HVLI")
	playerWombat:weaponTubeAllowMissle(1,"Homing")
	playerWombat:setWeaponTubeExclusiveFor(2,"HVLI")
	playerWombat:weaponTubeAllowMissle(2,"Homing")
	playerWombat:setWeaponTubeExclusiveFor(3,"HVLI")
	playerWombat:weaponTubeAllowMissle(3,"EMP")
	playerWombat:weaponTubeAllowMissle(3,"Nuke")
	playerWombat:setWeaponTubeExclusiveFor(4,"Mine")
	playerWombat:setWeaponStorageMax("Mine",2)				--more (vs 0)
	playerWombat:setWeaponStorage("Mine", 2)				
	playerWombat:setWeaponStorageMax("EMP",2)				--more (vs 0)
	playerWombat:setWeaponStorage("EMP", 2)				
	playerWombat:setWeaponStorageMax("Nuke",1)				--more (vs 0)
	playerWombat:setWeaponStorage("Nuke", 1)				
	playerWombat:setWeaponStorageMax("HVLI",15)				--more (vs 12)	
	playerWombat:setWeaponStorage("HVLI", 15)				
	playerWombat:setWeaponStorageMax("Homing",8)			--more (vs 3)
	playerWombat:setWeaponStorage("Homing", 8)				
	playerShip()
end
--]]

--[[
function toggleBlazonAutoCool()
	if playerBlazon.autoCoolant then
		playerBlazon.autoCoolant = false
		playerBlazon:setAutoCoolant(false)
	else
		playerBlazon.autoCoolant = true
		playerBlazon:setAutoCoolant(true)
	end
	autoCool()
end
--]]
--[[
function toggleHeadhunterAutoCool()
	if playerHeadhunter.autoCoolant then
		playerHeadhunter.autoCoolant = false
		playerHeadhunter:setAutoCoolant(false)
	else
		playerHeadhunter.autoCoolant = true
		playerHeadhunter:setAutoCoolant(true)
	end
	autoCool()
end
--]]
--[[
function toggleMagnumAutoCool()
	if playerMagnum.autoCoolant then
		playerMagnum.autoCoolant = false
		playerMagnum:setAutoCoolant(false)
	else
		playerMagnum.autoCoolant = true
		playerMagnum:setAutoCoolant(true)
	end
	autoCool()
end
--]]
--[[
function toggleSpikeAutoCool()
	if playerSpike.autoCoolant then
		playerSpike.autoCoolant = false
		playerSpike:setAutoCoolant(false)
	else
		playerSpike.autoCoolant = true
		playerSpike:setAutoCoolant(true)
	end
	autoCool()
end
--]]
--[[
function toggleStingAutoCool()
	if playerSting.autoCoolant then
		playerSting.autoCoolant = false
		playerSting:setAutoCoolant(false)
	else
		playerSting.autoCoolant = true
		playerSting:setAutoCoolant(true)
	end
	autoCool()
end
--]]
function toggleHalberdAutoCool()
	if playerHalberd.autoCoolant then
		playerHalberd.autoCoolant = false
		playerHalberd:setAutoCoolant(false)
	else
		playerHalberd.autoCoolant = true
		playerHalberd:setAutoCoolant(true)
	end
	autoCool()
end
function toggleHolmesAutoCool()
	if playerHolmes.autoCoolant then
		playerHolmes.autoCoolant = false
		playerHolmes:setAutoCoolant(false)
	else
		playerHolmes.autoCoolant = true
		playerHolmes:setAutoCoolant(true)
	end
	autoCool()
end
function toggleRattlerAutoCool()
	if playerRattler.autoCoolant then
		playerRattler.autoCoolant = false
		playerRattler:setAutoCoolant(false)
	else
		playerRattler.autoCoolant = true
		playerRattler:setAutoCoolant(true)
	end
	autoCool()
end
function toggleSpyderAutoCool()
	if playerSpyder.autoCoolant then
		playerSpyder.autoCoolant = false
		playerSpyder:setAutoCoolant(false)
	else
		playerSpyder.autoCoolant = true
		playerSpyder:setAutoCoolant(true)
	end
	autoCool()
end
function toggleNarsilAutoCool()
	if playerNarsil.autoCoolant then
		playerNarsil.autoCoolant = false
		playerNarsil:setAutoCoolant(false)
	else
		playerNarsil.autoCoolant = true
		playerNarsil:setAutoCoolant(true)
	end
	autoCool()
end

-------------------------
--	Tweak player ship  --
-------------------------
function tweakPlayerShip()
	clearGMFunctions()
	addGMFunction("-Main",initialGMFunctions)
	addGMFunction("-Setup",initialSetUp)
	addGMFunction("-Player Ship",playerShip)
	addGMFunction("+Auto Cool",autoCool)
	addGMFunction("+Coolant",changePlayerCoolant)
	addGMFunction("+Repair Crew",changePlayerRepairCrew)
	addGMFunction("+Cargo",changePlayerCargo)
	addGMFunction("+Reputation",changePlayerReputation)
end
function autoCool()
	clearGMFunctions()
	addGMFunction("-Main",initialGMFunctions)
	addGMFunction("-Setup",initialSetUp)
	addGMFunction("-From Auto Cool",tweakPlayerShip)
	if playerBlazon ~= nil then
		if playerBlazon.autoCoolant == nil then
			playerBlazon.autoCoolant = false
		end
		local playerBlazonAutoCoolant = "Blazon"
		if playerBlazon.autoCoolant then
			playerBlazonAutoCoolant = "Blazon*"
		end
		addGMFunction(playerBlazonAutoCoolant,toggleBlazonAutoCool)
	end
	if playerHalberd ~= nil then
		if playerHalberd.autoCoolant == nil then
			playerHalberd.autoCoolant = false
		end
		local playerHalberdAutoCoolant = "Halberd"
		if playerHalberd.autoCoolant then
			playerHalberdAutoCoolant = "Halberd*"
		end
		addGMFunction(playerHalberdAutoCoolant,toggleHalberdAutoCool)
	end
	if playerHolmes ~= nil then
		if playerHolmes.autoCoolant == nil then
			playerHolmes.autoCoolant = false
		end
		local playerHolmesAutoCoolant = "Holmes"
		if playerHolmes.autoCoolant then
			playerHolmesAutoCoolant = "Holmes*"
		end
		addGMFunction(playerHolmesAutoCoolant,toggleHolmesAutoCool)
	end
	if playerMagnum ~= nil then
		if playerMagnum.autoCoolant == nil then
			playerMagnum.autoCoolant = false
		end
		local playerMagnumAutoCoolant = "Magnum"
		if playerMagnum.autoCoolant then
			playerMagnumAutoCoolant = "Magnum*"
		end
		addGMFunction(playerMagnumAutoCoolant,toggleMagnumAutoCool)
	end
	if playerNarsil ~= nil then
		if playerNarsil.autoCoolant == nil then
			playerNarsil.autoCoolant = false
		end
		local playerNarsilAutoCoolant = "Narsil"
		if playerNarsil.autoCoolant then
			playerNarsilAutoCoolant = "Narsil*"
		end
		addGMFunction(playerNarsilAutoCoolant,toggleNarsilAutoCool)
	end
	if playerRattler ~= nil then
		if playerRattler.autoCoolant == nil then
			playerRattler.autoCoolant = false
		end
		local playerRattlerAutoCoolant = "Rattler"
		if playerRattler.autoCoolant then
			playerRattlerAutoCoolant = "Rattler*"
		end
		addGMFunction(playerRattlerAutoCoolant,toggleRattlerAutoCool)
	end
	if playerSpike ~= nil then
		if playerSpike.autoCoolant == nil then
			playerSpike.autoCoolant = false
		end
		local playerSpikeAutoCoolant = "Spike"
		if playerSpike.autoCoolant then
			playerSpikeAutoCoolant = "Spike*"
		end
		addGMFunction(playerSpikeAutoCoolant,toggleSpikeAutoCool)
	end
	if playerSpyder ~= nil then
		if playerSpyder.autoCoolant == nil then
			playerSpyder.autoCoolant = false
		end
		local playerSpyderAutoCoolant = "Spyder"
		if playerSpyder.autoCoolant then
			playerSpyderAutoCoolant = "Spyder*"
		end
		addGMFunction(playerSpyderAutoCoolant,toggleSpyderAutoCool)
	end
	if playerSting ~= nil then
		if playerSting.autoCoolant == nil then
			playerSting.autoCoolant = false
		end
		local playerStingAutoCoolant = "Sting"
		if playerSting.autoCoolant then
			playerStingAutoCoolant = "Sting*"
		end
		addGMFunction(playerStingAutoCoolant,toggleStingAutoCool)
	end
	--[[
	if playerHeadhunter ~= nil then
		if playerHeadhunter.autoCoolant == nil then
			playerHeadhunter.autoCoolant = false
		end
		local playerHeadhunterAutoCoolant = "Headhunter"
		if playerHeadhunter.autoCoolant then
			playerHeadhunterAutoCoolant = "*Headhunter"
		end
		addGMFunction(playerHeadhunterAutoCoolant,toggleHeadhunterAutoCool)
	end
	--]]
end
function changePlayerCoolant()
	clearGMFunctions()
	addGMFunction("-Main",initialGMFunctions)
	addGMFunction("-Setup",initialSetUp)
	addGMFunction("-Tweak Player",tweakPlayerShip)
	addGMFunction(string.format("Add %.1f coolant",coolant_amount), function()
		local p = getPlayerShip(-1)
		local object_list = getGMSelection()
		local selected_matches_player = false
		for i=1,#object_list do
			local current_selected_object = object_list[i]
			for pidx=1,8 do
				p = getPlayerShip(pidx)
				if p ~= nil and p:isValid() then
					if p == current_selected_object then
						selected_matches_player = true
						break
					end
				end
			end
			if selected_matches_player then
				break
			end
		end
		if selected_matches_player then
			local coolant_reason_given = false
			p:setMaxCoolant(p:getMaxCoolant() + coolant_amount)
			addGMMessage(string.format("%.1f coolant added to %s for a new total of %.1f coolant",coolant_amount,p:getCallSign(),p:getMaxCoolant()))
			for i=1,#regionStations do
				if p:isDocked(regionStations[i]) then
					if p:hasPlayerAtPosition("Engineering") then
						p:addCustomMessage("Engineering","coolant_bonus_message",string.format("A kind-hearted quartermaster on %s donated some coolant to your coolant supply",regionStations[i]:getCallSign()))
						coolant_reason_given = true
						break
					end
				end
			end
			if not coolant_reason_given then
				if p:hasPlayerAtPosition("Engineering") then
					p:addCustomMessage("Engineering","coolant_bonus_message","Additional coolant was added. It was missed during the last inventory cycle")
				end
			end
		else
			addGMMessage("No player selected. No action taken")
		end
		changePlayerCoolant()
	end)
	addGMFunction(string.format("Remove %.1f coolant",coolant_amount), function()
		local p = getPlayerShip(-1)
		local object_list = getGMSelection()
		local selected_matches_player = false
		for i=1,#object_list do
			local current_selected_object = object_list[i]
			for pidx=1,8 do
				p = getPlayerShip(pidx)
				if p ~= nil and p:isValid() then
					if p == current_selected_object then
						selected_matches_player = true
						break
					end
				end
			end
			if selected_matches_player then
				break
			end
		end
		if selected_matches_player then
			local coolant_reason_given = false
			p:setMaxCoolant(p:getMaxCoolant() - coolant_amount)
			addGMMessage(string.format("%.1f coolant removed from %s for a new total of %.1f coolant",coolant_amount,p:getCallSign(),p:getMaxCoolant()))
			for i=1,#regionStations do
				if p:isDocked(regionStations[i]) then
					if p:hasPlayerAtPosition("Engineering") then
						p:addCustomMessage("Engineering","coolant_loss_message",string.format("Station docking fees for %s were paid for in coolant",regionStations[i]:getCallSign()))
						coolant_reason_given = true
						break
					end
				end
			end
			if not coolant_reason_given then
				if p:hasPlayerAtPosition("Engineering") then
					p:addCustomMessage("Engineering","coolant_loss_message","Coolant was lost due to a malfunctioning system. You corrected the problem before it got any worse")
				end
			end
		else
			addGMMessage("No player selected. No action taken")
		end
		changePlayerCoolant()
	end)
	if coolant_amount > .5 then
		addGMFunction(string.format("%.1f - %.1f = %.1f",coolant_amount,.5,coolant_amount-.5),function()
			coolant_amount = coolant_amount - .5
			changePlayerCoolant()
		end)
	end
	if coolant_amount < 10 then
		addGMFunction(string.format("%.1f + %.1f = %.1f",coolant_amount,.5,coolant_amount+.5),function()
			coolant_amount = coolant_amount + .5
			changePlayerCoolant()
		end)
	end
end
function changePlayerRepairCrew()
	clearGMFunctions()
	addGMFunction("-Main",initialGMFunctions)
	addGMFunction("-Setup",initialSetUp)
	addGMFunction("-Tweak Player",tweakPlayerShip)
	addGMFunction("Add repair crew", function()
		local p = getPlayerShip(-1)
		local object_list = getGMSelection()
		local selected_matches_player = false
		for i=1,#object_list do
			local current_selected_object = object_list[i]
			for pidx=1,8 do
				p = getPlayerShip(pidx)
				if p ~= nil and p:isValid() then
					if p == current_selected_object then
						selected_matches_player = true
						break
					end
				end
			end
			if selected_matches_player then
				break
			end
		end
		if selected_matches_player then
			local crew_reason_given = false
			p:setRepairCrewCount(p:getRepairCrewCount()+1)
			addGMMessage(string.format("1 repair crew added to %s for a new total of %i repair crew",p:getCallSign(),p:getRepairCrewCount()))
			for i=1,#regionStations do
				if p:isDocked(regionStations[i]) then
					if p:hasPlayerAtPosition("Engineering") then
						p:addCustomMessage("Engineering","added_repair_crew_message",string.format("A volunteer from station %s has boarded to work as one of your repair crew",regionStations[i]:getCallSign()))
						crew_reason_given = true
						break
					end
				end
			end
			if not crew_reason_given then
				if p:hasPlayerAtPosition("Engineering") then
					p:addCustomMessage("Engineering","added_repair_crew_message","A crew member from a different department has completed training and has transferred to your repair crew")
				end
			end
		else
			addGMMessage("No player selected. No action taken")
		end
		changePlayerRepairCrew()
	end)
	addGMFunction("Remove repair crew", function()
		local p = getPlayerShip(-1)
		local object_list = getGMSelection()
		local selected_matches_player = false
		for i=1,#object_list do
			local current_selected_object = object_list[i]
			for pidx=1,8 do
				p = getPlayerShip(pidx)
				if p ~= nil and p:isValid() then
					if p == current_selected_object then
						selected_matches_player = true
						break
					end
				end
			end
			if selected_matches_player then
				break
			end
		end
		if selected_matches_player then
			local crew_reason_given = false
			if p:getRepairCrewCount() > 0 then
				p:setRepairCrewCount(p:getRepairCrewCount()-1)
				addGMMessage(string.format("1 repair crew removed from %s for a new total of %i repair crew",p:getCallSign(),p:getRepairCrewCount()))
				for i=1,#regionStations do
					if p:isDocked(regionStations[i]) then
						if p:hasPlayerAtPosition("Engineering") then
							p:addCustomMessage("Engineering","removed_repair_crew_message",string.format("One of your repair crew has disembarked on to station %s claiming his work contract has been fulfilled",regionStations[i]:getCallSign()))
							crew_reason_given = true
							break
						end
					end
				end
				if not crew_reason_given then
					if p:hasPlayerAtPosition("Engineering") then
						p:addCustomMessage("Engineering","removed_repair_crew_message","One of your repair crew has become debilitatingly ill and can no longer conduct any repairs")
					end
				end
			end
		else
			addGMMessage("No player selected. No action taken")
		end
		changePlayerRepairCrew()
	end)
end
function changePlayerCargo()
	clearGMFunctions()
	addGMFunction("-Main from Cargo",initialGMFunctions)
	addGMFunction("-Setup",initialSetUp)
	addGMFunction("-Tweak Player",tweakPlayerShip)
	addGMFunction("+Remove Cargo",removeCargo)
	addGMFunction("+Add Mineral",addMineralCargo)
	addGMFunction("+Add Component",addComponentCargo)
end
function removeCargo()
	clearGMFunctions()
	addGMFunction("-Cargo From Del",changePlayerCargo)
	local p = getPlayerShip(-1)
	local object_list = getGMSelection()
	local selected_matches_player = false
	for i=1,#object_list do
		local current_selected_object = object_list[i]
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				if p == current_selected_object then
					selected_matches_player = true
					break
				end
			end
		end
		if selected_matches_player then
			break
		end
	end
	if selected_matches_player then
		if p.goods ~= nil then
			local cargo_found = false
			for good, good_quantity in pairs(p.goods) do
				if good_quantity > 0 then
					cargo_found = true
					addGMFunction(good,function()
						p.goods[good] = p.goods[good] - 1
						p.cargo = p.cargo + 1
						addGMMessage(string.format("one %s removed",good))
						removeCargo()
					end)
				end
			end
			if not cargo_found then
				addGMMessage("selected player has no cargo to delete")
				changePlayerCargo()
			end
		else
			addGMMessage("selected player has no cargo to delete")
			changePlayerCargo()
		end
	else
		addGMMessage("No player selected. No action taken")
		changePlayerCargo()
	end
end
function addMineralCargo()
	clearGMFunctions()
	addGMFunction("-Cargo From Add",changePlayerCargo)
	local p = getPlayerShip(-1)
	local object_list = getGMSelection()
	local selected_matches_player = false
	for i=1,#object_list do
		local current_selected_object = object_list[i]
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				if p == current_selected_object then
					selected_matches_player = true
					break
				end
			end
		end
		if selected_matches_player then
			break
		end
	end
	if selected_matches_player then
		for _, good in pairs(mineralGoods) do
			addGMFunction(good,function()
				if p.cargo > 0 then
					if p.goods == nil then
						p.goods = {}
					end
					if p.goods[good] == nil then
						p.goods[good] = 0
					end
					p.goods[good] = p.goods[good] + 1
					p.cargo = p.cargo - 1
					addGMMessage(string.format("one %s added",good))
				else
					addGMMessage("Insufficient cargo space")
					changePlayerCargo()
					return
				end
				addMineralCargo()			
			end)
		end
	else
		addGMMessage("No player selected. No action taken")
		changePlayerCargo()
	end
end
function addComponentCargo()
	clearGMFunctions()
	addGMFunction("-Cargo From Add",changePlayerCargo)
	local p = getPlayerShip(-1)
	local object_list = getGMSelection()
	local selected_matches_player = false
	for i=1,#object_list do
		local current_selected_object = object_list[i]
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				if p == current_selected_object then
					selected_matches_player = true
					break
				end
			end
		end
		if selected_matches_player then
			break
		end
	end
	if selected_matches_player then
		for _, good in pairs(componentGoods) do
			addGMFunction(good,function()
				if p.cargo > 0 then
					if p.goods == nil then
						p.goods = {}
					end
					if p.goods[good] == nil then
						p.goods[good] = 0
					end
					p.goods[good] = p.goods[good] + 1
					p.cargo = p.cargo - 1
					addGMMessage(string.format("one %s added",good))
				else
					addGMMessage("Insufficient cargo space")
				end
				addComponentCargo()			
			end)
		end
	else
		addGMMessage("No player selected. No action taken")
	end
end
function changePlayerReputation()
	clearGMFunctions()
	addGMFunction("-Main From Rep",initialGMFunctions)
	addGMFunction("-Setup",initialSetUp)
	addGMFunction("-Tweak Player",tweakPlayerShip)
	local p = getPlayerShip(-1)
	local object_list = getGMSelection()
	local selected_matches_player = false
	for i=1,#object_list do
		local current_selected_object = object_list[i]
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				if p == current_selected_object then
					selected_matches_player = true
					break
				end
			end
		end
		if selected_matches_player then
			break
		end
	end
	if selected_matches_player then
		local current_rep = math.floor(p:getReputationPoints())
		addGMFunction(string.format("Add one rep %i",current_rep),function()
			p:addReputationPoints(1)
			changePlayerReputation()
		end)
		addGMFunction(string.format("Add five rep %i",current_rep),function()
			p:addReputationPoints(5)
			changePlayerReputation()
		end)
		addGMFunction(string.format("Add ten rep %i",current_rep),function()
			p:addReputationPoints(10)
			changePlayerReputation()
		end)
		if current_rep > 0 then
			addGMFunction(string.format("Del one rep %i",current_rep),function()
				p:takeReputationPoints(1)
				changePlayerReputation()
			end)
		end
		if current_rep > 5 then
			addGMFunction(string.format("Del five rep %i",current_rep),function()
				p:takeReputationPoints(5)
				changePlayerReputation()
			end)
		end
		if current_rep > 10 then
			addGMFunction(string.format("Del ten rep %i",current_rep),function()
				p:takeReputationPoints(10)
				changePlayerReputation()
			end)
		end
	else
		addGMMessage("No player selected. No action taken. No reputation options presented")
		tweakPlayerShip()
	end
end
-----------------
--	Wormholes  --
-----------------
function setWormholes()
	clearGMFunctions()
	addGMFunction("-Main From Wormhole",initialGMFunctions)
	addGMFunction("-Setup",initialSetUp)
	addGMFunction("+Icarus to " .. wormholeIcarus.exit,setIcarusWormholeExit)
end
function setIcarusWormholeExit()
	clearGMFunctions()
	addGMFunction("-Wormhole",setWormholes)
	local icarus_label = "Default"
	if wormholeIcarus.exit == "default" then
		icarus_label = "Default*"
	end
	addGMFunction(icarus_label, function()
		wormholeIcarus.exit = "default"
		wormholeIcarus:setTargetPosition(wormholeIcarus.default_exit_point_x,wormholeIcarus.default_exit_point_y)
		setIcarusWormholeExit()
	end)
	icarus_label = "Kentar"
	if wormholeIcarus.exit == "kentar" then
		icarus_label = "Kentar*"
	end
	addGMFunction(icarus_label, function()
		wormholeIcarus.exit = "kentar"
		wormholeIcarus:setTargetPosition(wormholeIcarus.kentar_exit_point_x,wormholeIcarus.kentar_exit_point_y)
		setIcarusWormholeExit()
	end)
end
function throughWormhole(worm_hole,transportee)
	if worm_hole == wormholeIcarus then
		if worm_hole.exit == "default" then
			--exited near Icarus, near station Macassa
		end
		if worm_hole.exit == "kentar" then
			--exited near station Kentar
		end
	end
end
-------------
--	Zones  --
-------------
function changeZones()
	clearGMFunctions()
	addGMFunction("-Main From Zones",initialGMFunctions)
	addGMFunction("-Setup",initialSetUp)
	addGMFunction("+Add Zone",addZone)
	if zone_list ~= nil and #zone_list > 0 then
		addGMFunction("+Delete Zone",deleteZone)
	end
end
function addZone()
	clearGMFunctions()
	addGMFunction("-Main",initialGMFunctions)
	addGMFunction("-Setup",initialSetUp)
	addGMFunction("-Zones from add",changeZones)
	addGMFunction("Sector", function()
		local object_list = getGMSelection()
		if #object_list ~= nil and #object_list == 1 then
			local ox, oy = object_list[1]:getPosition()
			ox = math.floor(ox / 20000)
			ox = ox * 20000
			oy = math.floor(oy / 20000)
			oy = oy * 20000
			local zone = Zone():setPoints(ox,oy,ox+20000,oy,ox+20000,oy+20000,ox,oy+20000)
			zone:setColor(64,64,64)
			zone.name = object_list[1]:getSectorName()
			if zone_list == nil then
				zone_list = {}
			end
			table.insert(zone_list,zone)
		else
			addGMMessage("You must select an object in the sector where you want the zone to appear. No action taken")
		end
	end)
	addGMFunction("Small Square",function()
		local object_list = getGMSelection()
		if #object_list ~= nil and #object_list == 1 then
			local ox, oy = object_list[1]:getPosition()
			local zone = Zone():setPoints(ox+500,oy+500,ox-500,oy+500,ox-500,oy-500,ox+500,oy-500)
			zone:setColor(255,255,128)
			if square_zone_char_val == nil then
				square_zone_char_val = 65
			end
			zone.name = string.char(square_zone_char_val)
			square_zone_char_val = square_zone_char_val + 1
			zone.sector_name = object_list[1]:getSectorName()
			if zone_list == nil then
				zone_list = {}
			end
			table.insert(zone_list,zone)
			addGMMessage(string.format("Added small square zone %s in %s",zone.name,zone.sector_name))
		else
			addGMMessage("You must select an object in the sector where you want the zone to appear. No action taken")
		end
	end)
end
function deleteZone()
	clearGMFunctions()
	addGMFunction("-Main",initialGMFunctions)
	addGMFunction("-Setup",initialSetUp)
	addGMFunction("-Zones from delete",changeZones)
	if selected_zone_index == nil then
		selected_zone_index = 1
	end
	if #zone_list > 0 then
		local zone_delete_label = string.format("Del %s",zone_list[selected_zone_index].name)
		if zone_list[selected_zone_index].sector_name ~= nil then
			zone_delete_label = string.format("%s in %s",zone_delete_label,zone_list[selected_zone_index].sector_name)
		end
		addGMFunction(zone_delete_label,function()
			local zone_to_delete = zone_list[selected_zone_index]
			table.remove(zone_list,selected_zone_index)
			zone_to_delete:destroy()
			selected_zone_index = nil
			deleteZone()
		end)
		addGMFunction("Select Next Zone",function()
			selected_zone_index = selected_zone_index + 1
			if selected_zone_index > #zone_list then
				selected_zone_index = 1
			end
			deleteZone()
		end)
	else
		changeZones()
	end
end
--------------
--	Region  --
--------------
function setStartRegion()
	clearGMFunctions()
	addGMFunction("-Main From Region",initialGMFunctions)
	addGMFunction("-Setup",initialSetUp)
	local GMSetDefaultRegion = "Default"
	if startRegion == "Default" then
		GMSetDefaultRegion = "Default*"
	end
	addGMFunction(GMSetDefaultRegion,setDefaultRegion)
	local GMSetKentarRegion = "Kentar (R17)"
	if startRegion == "Kentar" then
		GMSetKentarRegion = "Kentar* (R17)"
	end	
	addGMFunction(GMSetKentarRegion,setKentarRegion)
end
-- Icarus area stations, asteroids, mines, etc. 
function setDefaultRegion()	
	playerSpawnX = 0
	playerSpawnY = 0
	startRegion = "Default"
	createIcarusColor()
	setStartRegion()
end
function createIcarusColor()
	icarusDefensePlatforms = {}
	icarusMines = {}
	macassaAsteroids = createMacassaAsteroids()
	aquariusAsteroids = createAquariusAsteroids()
	cindyFollyAsteroids = createCindyFollyAsteroids()
	H0_to_K2_asteroids = createH0toK2asteroids()
	H1_to_I2_mines = createH1toI2mines()
	J0_to_K0_nebulae = createJ0toK0nebulae()
	J4_to_L8_asteroids = createJ4toL8asteroids()
	J4_to_L8_nebulae = createJ4toL8nebulae()
	borlanFeatures = createBorlanFeatures()
	finneganFeatures = createFinneganFeatures()
	icarusStations = createIcarusStations()
	regionStations = icarusStations
	local icx, icy = stationIcarus:getPosition()
	local startAngle = 23
	for i=1,6 do
		local dpx, dpy = vectorFromAngle(startAngle,8000)
		local dp = CpuShip():setTemplate("Defense platform"):setFaction("Human Navy"):setPosition(icx+dpx,icy+dpy):setScannedByFaction("Human Navy",true):setCallSign(string.format("DP%i",i)):setDescription(string.format("Icarus defense platform %i",i)):orderRoaming()
		table.insert(icarusDefensePlatforms,dp)
		for j=1,5 do
			dpx, dpy = vectorFromAngle(startAngle+17+j*4,8000)
			local dm = Mine():setPosition(icx+dpx,icy+dpy)
			table.insert(icarusMines,dm)
		end
		startAngle = startAngle + 60
	end
	--planetBespin = Planet():setPosition(40000,5000):setPlanetRadius(3000):setDistanceFromMovementPlane(-2000):setCallSign("Donflist")
	--planetBespin:setPlanetSurfaceTexture("planets/gas-1.png"):setAxialRotationTime(300):setDescription("Mining and Gambling")
end
function removeIcarusColor()
	if icarusDefensePlatforms ~= nil then
		for _,dp in pairs(icarusDefensePlatforms) do
			dp:destroy()
		end
	end
	icarusDefensePlatforms = nil
	if icarusMines ~= nil then
		for _,m in pairs(icarusMines) do
			m:destroy()
		end
	end
	icarusMines = nil
	if macassaAsteroids ~= nil then
		for _,a in pairs(macassaAsteroids) do
			a:destroy()
		end
	end
	macassaAsteroids = nil
	if aquariusAsteroids ~= nil then
		for _,a in pairs(aquariusAsteroids) do
			a:destroy()
		end
	end
	aquariusAsteroids = nil
	if cindyFollyAsteroids ~= nil then
		for _,a in pairs(cindyFollyAsteroids) do
			a:destroy()
		end
	end
	cindyFollyAsteroids = nil
	if H0_to_K2_asteroids ~= nil then
		for _,a in pairs(H0_to_K2_asteroids) do
			a:destroy()
		end
	end
	H0_to_K2_asteroids = nil
	if J4_to_L8_asteroids ~= nil then
		for _,a in pairs(J4_to_L8_asteroids) do
			a:destroy()
		end
	end
	J4_to_L8_asteroids = nil
	if H1_to_I2_mines ~= nil then
		for _,a in pairs(H1_to_I2_mines) do
			a:destroy()
		end
	end
	H1_to_I2_mines = nil
	if J0_to_K0_nebulae ~= nil then
		for _,a in pairs(J0_to_K0_nebulae) do
			a:destroy()
		end
	end
	J0_to_K0_nebulae = nil
	if J4_to_L8_nebulae ~= nil then
		for _,a in pairs(J4_to_L8_nebulae) do
			a:destroy()
		end
	end
	J4_to_L8_nebulae = nil
	if borlanFeatures ~= nil then
		for _,a in pairs(borlanFeatures) do
			a:destroy()
		end
	end
	borlanFeatures = nil
	if finneganFeatures ~= nil then
		for _,a in pairs(finneganFeatures) do
			a:destroy()
		end
	end
	finneganFeatures = nil
	if icarusStations ~= nil then
		for _,s in pairs(icarusStations) do
			s:destroy()
		end
	end
	icarusStations = nil
end
function squareZone(x,y,name)
	local zone = Zone():setPoints(x+500,y+500,x-500,y+500,x-500,y-500,x+500,y-500)
	zone.name = name
	if zone_list == nil then
		zone_list = {}
	end
	table.insert(zone_list,zone)
	return zone
end
function createIcarusStations()
	local stations = {}
	local nukeAvail = true
	local empAvail = true
	local mineAvail = true
	local homeAvail = true
	local hvliAvail = true
	local tradeFood = true
	local tradeMedicine = true
	local tradeLuxury = true
	--Mermaid
    stationMermaid = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setPosition(28889, -4417):setCallSign("Mermaid 2"):setDescription("Tavern and hotel"):setCommsScript(""):setCommsFunction(commsStation)
    if random(1,100) <= 30 then nukeAvail = true else nukeAvail = false end
    if random(1,100) <= 40 then empAvail = true else empAvail = false end
    if random(1,100) <= 50 then mineAvail = true else mineAvail = false end
    if random(1,100) <= 60 then homeAvail = true else homeAvail = false end
    if random(1,100) <= 80 then hvliAvail = true else hvliAvail = false end
    if random(1,100) <= 17 then tradeLuxury = true else tradeLuxury = false end
    stationMermaid.comms_data = {
    	friendlyness = 75,
        weapons = 			{Homing = "neutral",HVLI = "neutral", 		Mine = "friend",		Nuke = "friend", 			EMP = "friend"},
        weapon_cost =		{Homing = 3, 		HVLI = math.random(1,2),Mine = math.random(2,5),Nuke = math.random(12,18),	EMP = 10 },
        weapon_available = 	{Homing = homeAvail,HVLI = hvliAvail,		Mine = mineAvail,		Nuke = nukeAvail,			EMP = empAvail},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 2.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	luxury = 	{quantity = math.random(5,10),	cost = math.random(60,70)},
        			gold = 		{quantity = 5,					cost = math.random(75,90)}	},
        trade = {	food = true, medicine = false, luxury = tradeLuxury },
        public_relations = true,
        general_information = "Rest stop, refueling and convenience shopping",
    	history = "In the tradition of taverns at crossroads on olde Earth in Kingston where the Millstone river and the Assunpink trail crossed and The Sign of the Mermaid tavern was built in the 1600s, the builders of this station speculated that this would be a good spot for space travelers to stop"
	}
	table.insert(stations,stationMermaid)
	--Pistil
    stationPistil = SpaceStation():setTemplate("Small Station"):setFaction("Human Navy"):setPosition(24834, 20416):setCallSign("Pistil"):setDescription("Fleur nebula research"):setCommsScript(""):setCommsFunction(commsStation)
    if random(1,100) <= 30 then nukeAvail = true else nukeAvail = false end
    if random(1,100) <= 40 then empAvail = true else empAvail = false end
    if random(1,100) <= 60 then homeAvail = true else homeAvail = false end
    if random(1,100) <= 37 then tradeLuxury = true else tradeLuxury = false end
    stationPistil.comms_data = {
    	friendlyness = 55,
        weapons = 			{Homing = "neutral",		HVLI = "neutral", 		Mine = "friend",		Nuke = "friend", 			EMP = "friend"},
        weapon_cost =		{Homing = math.random(2,5), HVLI = math.random(1,3),Mine = math.random(2,3),Nuke = math.random(14,18),	EMP = math.random(9,13) },
        weapon_available = 	{Homing = homeAvail,		HVLI = true,			Mine = true,			Nuke = nukeAvail,			EMP = empAvail},
        service_cost = 		{supplydrop = math.random(95,120), reinforcements = math.random(145,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 2.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	sensor = 	{quantity = math.random(4,8),	cost = math.random(60,70)}	},
        trade = {	food = false, medicine = true, luxury = tradeLuxury },
        buy =	{	robotic = math.random(40,200),
        			dilithium = math.random(40,200)	},
        public_relations = true,
        general_information = "Studying, observing, measuring the Fleur nebula",
    	history = "The station naming continued in the vein of the nebula which we study"
	}
	table.insert(stations,stationPistil)
	--Macassa
    stationMacassa = SpaceStation():setTemplate("Small Station"):setFaction("Human Navy"):setPosition(16335, -18034):setCallSign("Macassa 4"):setDescription("Mining"):setCommsScript(""):setCommsFunction(commsStation)
    if random(1,100) <= 30 then nukeAvail = true else nukeAvail = false end
    if random(1,100) <= 40 then empAvail = true else empAvail = false end
    if random(1,100) <= 60 then homeAvail = true else homeAvail = false end
    if random(1,100) <= 80 then hvliAvail = true else hvliAvail = false end
    if random(1,100) <= 37 then tradeLuxury = true else tradeLuxury = false end
    if random(1,100) <= 12 then tradeFood = true else tradeFood = false end
    stationMacassa.comms_data = {
    	friendlyness = 55,
        weapons = 			{Homing = "neutral",		HVLI = "neutral", 		Mine = "friend",		Nuke = "friend", 			EMP = "friend"},
        weapon_cost =		{Homing = math.random(2,5), HVLI = math.random(1,3),Mine = math.random(2,3),Nuke = math.random(13,18),	EMP = math.random(9,13) },
        weapon_available = 	{Homing = homeAvail,		HVLI = hvliAvail,		Mine = true,			Nuke = nukeAvail,			EMP = empAvail},
        service_cost = 		{supplydrop = math.random(95,120), reinforcements = math.random(145,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 2.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	gold = 	{quantity = math.random(4,8),	cost = math.random(60,70)},
        			dilithium = {quantity = math.random(2,11),	cost = math.random(55,85)}	},
        trade = {	food = tradeFood, medicine = false, luxury = tradeLuxury },
        public_relations = true,
        general_information = "Station location facilitates mining the nearby asteroids",
    	history = "The station was named in the hopes that the asteroids will be as productive as the Macassa mine was on Earth in the mid to late 1900s"
	}
	table.insert(stations,stationMacassa)
	--Maximilian
    stationMaximilian = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("Maximilian Mark 3"):setPosition(-16565, -16446):setDescription("Black Hole Research"):setCommsScript(""):setCommsFunction(commsStation)
    if random(1,100) <= 30 then nukeAvail = true else nukeAvail = false end
    if random(1,100) <= 40 then empAvail = true else empAvail = false end
    if random(1,100) <= 50 then mineAvail = true else mineAvail = false end
    if random(1,100) <= 80 then hvliAvail = true else hvliAvail = false end
    if random(1,100) <= 39 then tradeMedicine = true else tradeMedicine = false end
    if random(1,100) <= 62 then tradeFood = true else tradeFood = false end
    stationMaximilian.comms_data = {
    	friendlyness = 43,
        weapons = 			{Homing = "neutral",		HVLI = "neutral", 		Mine = "friend",		Nuke = "friend", 			EMP = "friend"},
        weapon_cost =		{Homing = 2,				HVLI = math.random(2,3),Mine = math.random(2,3),Nuke = math.random(14,18),	EMP = math.random(9,13) },
        weapon_available = 	{Homing = true,				HVLI = hvliAvail,		Mine = mineAvail,		Nuke = nukeAvail,			EMP = empAvail},
        service_cost = 		{supplydrop = math.random(95,120), reinforcements = math.random(145,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 2.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	filament = 	{quantity = math.random(4,8),	cost = math.random(50,80)}	},
        trade = {	food = tradeFood, medicine = tradeMedicine, luxury = true },
        public_relations = true,
        general_information = "Observe and measure black hole for scientific understanding purposes",
    	history = "One of the researchers also develops software and watches ancient films. He was put in charge of naming the station so he named it after a mute evil robot depicted in an old movie about a black hole from the late 1970s"
	}
	table.insert(stations,stationMaximilian)
	--Aquarius F4m9
    stationAquarius = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("Aquarius III"):setPosition(-4295, 14159):setDescription("Mining"):setCommsScript(""):setCommsFunction(commsStation)
    if random(1,100) <= 30 then nukeAvail = true else nukeAvail = false end
    if random(1,100) <= 50 then mineAvail = true else mineAvail = false end
    if random(1,100) <= 60 then homeAvail = true else homeAvail = false end
    if random(1,100) <= 39 then tradeMedicine = true else tradeMedicine = false end
    if random(1,100) <= 82 then tradeFood = true else tradeFood = false end
    stationAquarius.comms_data = {
    	friendlyness = 67,
        weapons = 			{Homing = "neutral",		HVLI = "neutral", 		Mine = "friend",		Nuke = "friend", 			EMP = "friend"},
        weapon_cost =		{Homing = 5,				HVLI = math.random(2,5),Mine = math.random(3,7),Nuke = math.random(12,18),	EMP = math.random(9,13) },
        weapon_available = 	{Homing = homeAvail,		HVLI = true,		Mine = mineAvail,		Nuke = nukeAvail,			EMP = true},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(123,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 2.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	platinum = 	{quantity = math.random(4,8),	cost = math.random(50,80)},
        			nickel =	{quantity = math.random(6,12),	cost = math.random(45,65)}	},
        trade = {	food = tradeFood, medicine = tradeMedicine, luxury = false },
        public_relations = true,
        general_information = "Facilitate mining the nearby asteroids",
    	history = "Station named after the platinum mine on ancient Earth on the African continent"
	}
	table.insert(stations,stationAquarius)
	--Wookie F4m5 (ookie suffix indicates that this is the second version of this station)
    stationWookie = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("Wookie-ookie"):setPosition(-11280, 7425):setDescription("Esoteric Xenolinguistic Research"):setCommsScript(""):setCommsFunction(commsStation)
    if random(1,100) <= 30 then nukeAvail = true else nukeAvail = false end
    if random(1,100) <= 50 then mineAvail = true else mineAvail = false end
    if random(1,100) <= 60 then homeAvail = true else homeAvail = false end
    if random(1,100) <= 80 then hvliAvail = true else hvliAvail = false end
    if random(1,100) <= 39 then tradeMedicine = true else tradeMedicine = false end
    stationWookie.comms_data = {
    	friendlyness = 76,
        weapons = 			{Homing = "neutral",		HVLI = "neutral", 		Mine = "neutral",		Nuke = "friend", 			EMP = "friend"},
        weapon_cost =		{Homing = math.random(3,7),	HVLI = math.random(2,5),Mine = math.random(3,7),Nuke = math.random(12,18),	EMP = math.random(9,13) },
        weapon_available = 	{Homing = true,				HVLI = hvliAvail,		Mine = mineAvail,		Nuke = nukeAvail,			EMP = true},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(123,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 2.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	software = 	{quantity = math.random(4,8),	cost = math.random(80,90)}	},
        trade = {	food = false, medicine = tradeMedicine, luxury = false },
        public_relations = true,
        general_information = "Researchers here study the Wookie language as well as several other languages of intelligent species",
    	history = "The first language studied when the station was founded was Wookie. Wookie language and culture is still a major focus of study"
	}
	table.insert(stations,stationWookie)
	--Elysium F4m2.5
    stationElysium = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("Elysium"):setPosition(-7504, 1384):setDescription("Commerce and luxury accomodations"):setCommsScript(""):setCommsFunction(commsStation)
    if random(1,100) <= 30 then nukeAvail = true else nukeAvail = false end
    if random(1,100) <= 40 then empAvail = true else empAvail = false end
    if random(1,100) <= 50 then mineAvail = true else mineAvail = false end
    if random(1,100) <= 13 then tradeLuxury = true else tradeLuxury = false end
    stationElysium.comms_data = {
    	friendlyness = 29,
        weapons = 			{Homing = "neutral",		HVLI = "neutral", 		Mine = "neutral",		Nuke = "friend", 			EMP = "neutral"},
        weapon_cost =		{Homing = math.random(3,7),	HVLI = math.random(2,5),Mine = math.random(3,7),Nuke = math.random(12,18),	EMP = math.random(9,13) },
        weapon_available = 	{Homing = true,				HVLI = true,			Mine = mineAvail,		Nuke = nukeAvail,			EMP = empAvail},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(123,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 2.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	warp = 	{quantity = math.random(2,4),	cost = math.random(80,120)}	},
        trade = {	food = false, medicine = false, luxury = tradeLuxury },
        public_relations = true,
        general_information = "This is where all the wealthy species shop and stay when traveling",
    	history = "Named after a fictional station from early 21st century literature as a reminder of what can happen if people don't pay attention to what goes on in all levels of the society in which they live"
	}
	table.insert(stations,stationElysium)
	--Nerva E4m8
    stationNerva = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("Nerva"):setPosition(-9203, -2077):setDescription("Observatory"):setCommsScript(""):setCommsFunction(commsStation)
    if random(1,100) <= 30 then nukeAvail = true else nukeAvail = false end
    if random(1,100) <= 40 then empAvail = true else empAvail = false end
    if random(1,100) <= 50 then mineAvail = true else mineAvail = false end
    if random(1,100) <= 60 then homeAvail = true else homeAvail = false end
    if random(1,100) <= 80 then hvliAvail = true else hvliAvail = false end
    if random(1,100) <= 17 then tradeLuxury = true else tradeLuxury = false end
    if random(1,100) <= 69 then tradeMedicine = true else tradeMedicine = false end
    stationNerva.comms_data = {
    	friendlyness = 75,
        weapons = 			{Homing = "neutral",HVLI = "neutral", 		Mine = "neutral",		Nuke = "friend", 			EMP = "friend"},
        weapon_cost =		{Homing = 3, 		HVLI = math.random(1,2),Mine = math.random(2,5),Nuke = math.random(12,18),	EMP = 10 },
        weapon_available = 	{Homing = homeAvail,HVLI = hvliAvail,		Mine = mineAvail,		Nuke = nukeAvail,			EMP = empAvail},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 2.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	optic = 	{quantity = math.random(5,10),	cost = math.random(60,70)}	},
        trade = {	food = false, medicine = tradeMedicine, luxury = tradeLuxury },
        public_relations = true,
        general_information = "Observatory of stellar phenomena and space ship traffic",
    	history = "A combination of science and military staff share the various delicate instruments on this station. Originally designed to watch for incoming Kraylor and Exuari ships, other stations now share the early warning military purpose and these sensors double as research resources"
	}
	table.insert(stations,stationNerva)
	--Cindy's Folly
    stationCindyFolly = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("Cindy's Folly 2"):setPosition(81075, -1304):setDescription("Mining"):setCommsScript(""):setCommsFunction(commsStation)
    if random(1,100) <= 37 then homeAvail = true else homeAvail = false end
    if random(1,100) <= 44 then hvliAvail = true else hvliAvail = false end
    if random(1,100) <= 23 then mineAvail = true else mineAvail = false end
    if random(1,100) <= 13 then tradeLuxury = true else tradeLuxury = false end
    if random(1,100) <= 27 then tradeMedicine = true else tradeMedicine = false end
    stationCindyFolly.comms_data = {
    	friendlyness = 64,
        weapons = 			{Homing = "neutral",HVLI = "neutral", 		Mine = "neutral",		Nuke = "friend", 			EMP = "friend"},
        weapon_cost =		{Homing = 3, 		HVLI = math.random(1,4),Mine = math.random(2,7),Nuke = 30,					EMP = 20 },
        weapon_available = 	{Homing = homeAvail,HVLI = hvliAvail,		Mine = mineAvail,		Nuke = false,				EMP = false},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 2.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	dilithium = {quantity = math.random(4,8),	cost = math.random(50,80)},
        			tritanium =	{quantity = math.random(6,12),	cost = math.random(45,65)},
        			platinum =	{quantity = math.random(6,12),	cost = math.random(45,65)}	},
        trade = {	food = false, medicine = tradeMedicine, luxury = tradeLuxury },
        public_relations = true,
        general_information = "Mine nearby asteroids",
    	history = "A mining operation often on the brink of failure due to the loss of spacecraft in the nearby black holes"
	}
	table.insert(stations,stationCindyFolly)
	--Borlan
    stationBorlan = SpaceStation():setTemplate("Medium Station"):setFaction("Independent"):setCallSign("Borlan"):setPosition(68808, 39300):setDescription("Mining and Supply"):setCommsScript(""):setCommsFunction(commsStation)
    if random(1,100) <= 30 then nukeAvail = true else nukeAvail = false end
    if random(1,100) <= 40 then empAvail = true else empAvail = false end
    if random(1,100) <= 50 then mineAvail = true else mineAvail = false end
    if random(1,100) <= 80 then hvliAvail = true else hvliAvail = false end
    if random(1,100) <= 13 then tradeMedicine = true else tradeMedicine = false end
    stationBorlan.comms_data = {
    	friendlyness = 75,
        weapons = 			{Homing = "neutral",HVLI = "neutral", 		Mine = "neutral",		Nuke = "friend", 			EMP = "friend"},
        weapon_cost =		{Homing = 3, 		HVLI = math.random(1,2),Mine = math.random(2,5),Nuke = math.random(12,18),	EMP = math.random(9,21) },
        weapon_available = 	{Homing = true,		HVLI = hvliAvail,		Mine = mineAvail,		Nuke = nukeAvail,			EMP = empAvail},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 1.0 },
        goods = {	gold = 	{quantity = math.random(1,10),	cost = math.random(60,70)},	
        			cobalt ={quantity = math.random(6,12),	cost = math.random(75,95)},
        			luxury ={quantity = math.random(2,8),	cost = math.random(55,95)} },
        trade = {	food = false, medicine = tradeMedicine, luxury = false },
        public_relations = true,
        general_information = "Mining and resupply",
    	history = "Station success based on location and ingenuity of original builder to provide supplies for all the miners wanting to strike it rich"
	}
	table.insert(stations,stationBorlan)
	--Slurry
    stationSlurry = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("Slurry 2"):setPosition(100342, 27871):setDescription("Mining Research"):setCommsScript(""):setCommsFunction(commsStation)
    if random(1,100) <= 30 then nukeAvail = true else nukeAvail = false end
    if random(1,100) <= 40 then empAvail = true else empAvail = false end
    if random(1,100) <= 50 then mineAvail = true else mineAvail = false end
    if random(1,100) <= 60 then homeAvail = true else homeAvail = false end
    if random(1,100) <= 80 then hvliAvail = true else hvliAvail = false end
    if random(1,100) <= 17 then tradeLuxury = true else tradeLuxury = false end
    if random(1,100) <= 57 then tradeMedicine = true else tradeMedicine = false end
    stationSlurry.comms_data = {
    	friendlyness = 75,
        weapons = 			{Homing = "neutral",		HVLI = "neutral", 		Mine = "neutral",		Nuke = "friend", 			EMP = "friend"},
        weapon_cost =		{Homing = math.random(1,5),	HVLI = math.random(1,2),Mine = math.random(2,5),Nuke = math.random(12,18),	EMP = math.random(11,17) },
        weapon_available = 	{Homing = homeAvail,		HVLI = hvliAvail,		Mine = mineAvail,		Nuke = nukeAvail,			EMP = empAvail},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 2.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	tractor = 	{quantity = math.random(5,10),	cost = math.random(60,70)}	},
        trade = {	food = false, medicine = tradeMedicine, luxury = tradeLuxury },
        public_relations = true,
        general_information = "Mining and research of neaby stellar phenomena",
    	history = "Joint effort between miners and scientists to establish station to research and to provide resources to support research"
	}
	table.insert(stations,stationSlurry)
	--Relay-13
    stationRelay13 = SpaceStation():setTemplate("Small Station"):setFaction("Human Navy"):setCallSign("Relay-13"):setPosition(77918, 23876):setDescription("Communications Relay"):setCommsScript(""):setCommsFunction(commsStation)
    if random(1,100) <= 69 then tradeMedicine = true else tradeMedicine = false end
    stationRelay13.comms_data = {
    	friendlyness = 75,
        weapons = 			{Homing = "neutral",HVLI = "neutral", 		Mine = "neutral",		Nuke = "friend", 			EMP = "friend"},
        weapon_cost =		{Homing = 3, 		HVLI = math.random(1,5),Mine = math.random(2,5),Nuke = math.random(12,18),	EMP = 10 },
        weapon_available = 	{Homing = false,	HVLI = true,		Mine = false,			Nuke = false,				EMP = false},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 2.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	communication = {quantity = math.random(5,10),	cost = math.random(40,70)}	},
        trade = {	food = false, medicine = tradeMedicine, luxury = false },
        public_relations = true,
        general_information = "Communication traffic relay and coordination"
	}
	table.insert(stations,stationRelay13)
	--Stromboli
    stationStromboli = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("Stromboli"):setPosition(109555, 12685):setDescription("Vacation getaway for Stromboli family"):setCommsScript(""):setCommsFunction(commsStation)
    if random(1,100) <= 30 then nukeAvail = true else nukeAvail = false end
    if random(1,100) <= 40 then empAvail = true else empAvail = false end
    if random(1,100) <= 50 then mineAvail = true else mineAvail = false end
    if random(1,100) <= 60 then homeAvail = true else homeAvail = false end
    if random(1,100) <= 80 then hvliAvail = true else hvliAvail = false end
    if random(1,100) <= 23 then tradeMedicine = true else tradeMedicine = false end
    stationStromboli.comms_data = {
    	friendlyness = 35,
        weapons = 			{Homing = "neutral",HVLI = "neutral", 		Mine = "neutral",		Nuke = "friend", 			EMP = "friend"},
        weapon_cost =		{Homing = 3, 		HVLI = math.random(1,2),Mine = math.random(2,5),Nuke = math.random(12,18),	EMP = 10 },
        weapon_available = 	{Homing = homeAvail,HVLI = hvliAvail,		Mine = mineAvail,		Nuke = nukeAvail,			EMP = empAvail},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 2.0, neutral = 4.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	luxury = 	{quantity = math.random(5,10),	cost = math.random(60,70)}	},
        trade = {	food = false, medicine = tradeMedicine, luxury = false },
        public_relations = true,
        general_information = "A remote station location for the Stromboli family and gusts to get away from the pressures of modern life",
    	history = "The Stromboli family picked this station up cheap from the Human Navy when this sector was practically empty. Now it serves as a nice place for the family to escape to when they are stressed out"
	}
	table.insert(stations,stationStromboli)
	--Gagarin
	stationGagarin = SpaceStation():setTemplate("Small Station"):setFaction("Human Navy"):setCallSign("Gagarin"):setPosition(-60000, 62193):setDescription("Mining and exploring"):setCommsScript(""):setCommsFunction(commsStation)
    if random(1,100) <= 30 then nukeAvail = true else nukeAvail = false end
    if random(1,100) <= 40 then empAvail = true else empAvail = false end
    if random(1,100) <= 50 then mineAvail = true else mineAvail = false end
    if random(1,100) <= 60 then homeAvail = true else homeAvail = false end
    if random(1,100) <= 80 then hvliAvail = true else hvliAvail = false end
    if random(1,100) <= 23 then tradeMedicine = true else tradeMedicine = false end
    stationGagarin.comms_data = {
    	friendlyness = 82,
        weapons = 			{Homing = "neutral",		HVLI = "neutral", 		Mine = "friend",		Nuke = "friend", 			EMP = "friend"},
        weapon_cost =		{Homing = math.random(2,6),	HVLI = math.random(2,5),Mine = math.random(3,7),Nuke = math.random(12,18),	EMP = math.random(9,13) },
        weapon_available = 	{Homing = true,				HVLI = hvliAvail,		Mine = mineAvail,		Nuke = nukeAvail,			EMP = true},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(123,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 2.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	platinum = 	{quantity = math.random(4,8),	cost = math.random(50,80)},
        			nickel =	{quantity = math.random(6,12),	cost = math.random(45,65)}	},
        trade = {	food = true, medicine = tradeMedicine, luxury = false },
        public_relations = true,
        general_information = "Facilitate mining the nearby asteroids",
    	history = "Station named after the Cosmonaut from 20th century Earth"
	}
	table.insert(stations,stationGagarin)
	--Finnegan
	stationFinnegan = SpaceStation():setTemplate("Medium Station"):setFaction("Independent"):setCallSign("Finnegan"):setPosition(114460, 95868):setDescription("Trading, mining and manufacturing"):setCommsScript(""):setCommsFunction(commsStation)
    if random(1,100) <= 30 then nukeAvail = true else nukeAvail = false end
    if random(1,100) <= 40 then empAvail = true else empAvail = false end
    if random(1,100) <= 80 then hvliAvail = true else hvliAvail = false end
    if random(1,100) <= 63 then tradeMedicine = true else tradeMedicine = false end
    stationFinnegan.comms_data = {
    	friendlyness = 52,
        weapons = 			{Homing = "neutral",		HVLI = "neutral", 		Mine = "neutral",		Nuke = "friend", 			EMP = "friend"},
        weapon_cost =		{Homing = math.random(3,6),	HVLI = math.random(1,4),Mine = math.random(5,9),Nuke = math.random(12,18),	EMP = math.random(9,13) },
        weapon_available = 	{Homing = true,				HVLI = hvliAvail,		Mine = true,			Nuke = nukeAvail,			EMP = empAvail},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(123,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 2.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	circuit = 	{quantity = math.random(4,8),	cost = math.random(40,80)},
        			nickel =	{quantity = math.random(6,12),	cost = math.random(45,65)}	},
        trade = {	food = true, medicine = tradeMedicine, luxury = false },
        public_relations = true,
        general_information = "We mine the asteroids and the nebula and use these to manufacture various specialized circuits",
    	history = "The Finnegan family set up this station here to take advantage of the readily available resources"
	}
	table.insert(stations,stationFinnegan)
	--Sovinec
	stationSovinec = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("Sovinec"):setPosition(134167, 104690):setDescription("Beam component research and manufacturing"):setCommsScript(""):setCommsFunction(commsStation)
    if random(1,100) <= 30 then nukeAvail = true else nukeAvail = false end
    if random(1,100) <= 60 then homeAvail = true else homeAvail = false end
    if random(1,100) <= 50 then mineAvail = true else mineAvail = false end
    if random(1,100) <= 40 then empAvail = true else empAvail = false end
    if random(1,100) <= 37 then tradeMedicine = true else tradeMedicine = false end
    if random(1,100) <= 37 then tradeLuxury = true else tradeLuxury = false end
    stationSovinec.comms_data = {
    	friendlyness = 62,
        weapons = 			{Homing = "neutral",		HVLI = "neutral", 		Mine = "friend",		Nuke = "friend", 			EMP = "friend"},
        weapon_cost =		{Homing = math.random(2,6),	HVLI = math.random(1,4),Mine = math.random(2,7),Nuke = math.random(12,18),	EMP = math.random(9,13) },
        weapon_available = 	{Homing = homeAvail,		HVLI = true,			Mine = mineAvail,		Nuke = nukeAvail,			EMP = empAvail},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(123,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 2.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	beam =	 	{quantity = math.random(4,8),	cost = math.random(40,80)},
        			tritanium =	{quantity = math.random(6,12),	cost = math.random(45,65)}	},
        trade = {	food = false, medicine = tradeMedicine, luxury = tradeLuxury },
        public_relations = true,
        general_information = "We manufacture beam components from the resources gathered from teh nearby asteroids. We specialize in plasma based beam systems",
    	history = "Our station recognizes Sovinec, an early computer simulation researcher in plasma based weaponry in the late 20th century on Earth"
	}
	table.insert(stations,stationSovinec)	
	return stations
end
function createAquariusAsteroids()
	local asteroidList = {}
	local asteroidCoordinates = {
    {-645, 12145, 120},
    {-79, 13907, 50},
    {-1274, 14914, 20},
    {-2722, 13026, 160},
    {-2848, 14536, 230},
    {-1778, 19256, 13},
    {-834, 16487, 34},
    {-3414, 16676, 65},
    {-5176, 15480, 176},
    {-10588, 4342, 310},
    {-11846, 2391, 450},
    {-8196, 7929, 23},
    {-8700, 5789, 65},
    {-5805, 9817, 87},
    {-5931, 6481, 150},
    {-9833, 2391, 240},
    {-3540, 11704, 140},
    {-4735, 8181, 120},
    {-7064, 10509, 25},
    {-5428, 12711, 18},
    {1494, 16424, 43},
    {1809, 13403, 98} }
    for i=1,#asteroidCoordinates do
    	local staticAsteroid = Asteroid():setPosition(asteroidCoordinates[i][1],asteroidCoordinates[i][2]):setSize(asteroidCoordinates[i][3])
    	table.insert(asteroidList,staticAsteroid)
    end
    return asteroidList
end
function createMacassaAsteroids()
	local asteroidList = {}
	local asteroidCoordinates = {
    {15070, -15621, 120},
    {14714, -16096, 87},
    {13923, -16175, 165},
    {14239, -18864, 109},
    {14833, -16610, 78},
    {16612, -18745, 12},
    {17245, -18508, 14},
    {17878, -17717, 44},
    {16850, -17361, 54},
    {9296,  -20011, 187},
    {11194, -19932, 177},
    {10997, -24005, 56},
    {13330, -23135, 77},
    {13448, -21870, 154},
    {8268,  -22819, 210},
    {10838, -22107, 165},
    {12302, -21118, 254},
    {13844, -17322, 143},
    {12381, -16926, 286},
    {14319, -15384, 23},
    {12658, -15582, 97},
    {14714, -20762, 144},
    {13607, -20248, 244},
    {12737, -19536, 344},
    {11432, -18310, 187},
    {12934, -18231, 266},
    {17087, -19615, 43},
    {15703, -19892, 32},
    {16019, -20723, 15},
    {14912, -19101, 33},
    {15505, -17954, 78},
    {15900, -16926, 88},
    {15980, -16373, 117},
    {16652, -16254, 376},
    {19776, -16214, 243},
    {19578, -17045, 333},
    {18629, -16728, 129},
    {17370, -16617, 32},
    {6844,  -19813, 44},
    {8070,  -17757, 23},
    {11590, -16214, 70},
    {16177, -14237, 188},
    {18352, -13406, 255},
    {10759, -17045, 123},
    {9494,  -17875, 438},
    {18036, -16056, 181},
    {17296, -15873, 65},
    {18985, -9293, 134},
    {19737, -10440, 223},
    {18273, -12418, 267},
    {18511, -11825, 312},
    {26737, -9768, 289},
    {27172, -10875, 165},
    {25076, -10084, 32},
    {25194, -8463, 43},
    {25392, -11825, 132},
    {25827, -13644, 412},
    {23968, -12892, 357},
    {24482, -14514, 120},
    {21991, -11666, 178},
    {23454, -14791, 31},
    {22544, -13486, 87},
    {23731, -10757, 98},
    {22979, -12022, 213},
    {19222, -12497, 27},
    {19776, -13367, 89},
    {20092, -15621, 278},
    {19737, -14276, 178},
    {23019, -8740, 112},
    {22070, -8898, 159},
    {20528, -8858, 329},
    {20923, -10164, 398},
    {21872, -10638, 12},
    {20607, -11825, 17},
    {21081, -13130, 24},
    {22149, -15265, 42},
    {21239, -14514, 32},
    {20923, -15582, 78},
    {17364, -14000, 31},
    {17799, -14632, 42},
    {17957, -15107, 67},
    {17047, -15265, 43},
    {18787, -15582, 158},
    {19104, -15107, 228},
    {17601, -12932, 143},
    {18867, -13802, 210},
    {17364, -15067, 132},
    {16929, -14791, 166},
    {16494, -14870, 187},
    {16254, -15724, 188},
    {15821, -15067, 32},
    {15584, -15948, 332}	}
    for i=1,#asteroidCoordinates do
    	local staticAsteroid = Asteroid():setPosition(asteroidCoordinates[i][1],asteroidCoordinates[i][2]):setSize(asteroidCoordinates[i][3])
    	table.insert(asteroidList,staticAsteroid)
    end
    return asteroidList
end
function createCindyFollyAsteroids()
	local asteroidList = {}
	local asteroidCoordinates = {
    {81362, 1207, 120},
    {83658, 2211, 32},
    {83801, 1351, 254},
    {81003, -3528, 160},
    {79497, -4604, 12},
    {82725, -586, 44},
    {81434, -371, 87},
    {82438, 1566, 378},
    {83012, 705, 221},
    {79999, -3026, 109},
    {78349, -3815, 387},
    {82008, -1806, 32},
    {80501, -2021, 21},
    {78851, -2380, 38},
    {77416, -3241, 23} }
    for i=1,#asteroidCoordinates do
    	local staticAsteroid = Asteroid():setPosition(asteroidCoordinates[i][1],asteroidCoordinates[i][2]):setSize(asteroidCoordinates[i][3])
    	table.insert(asteroidList,staticAsteroid)
    end
    return asteroidList
end
function createH0toK2asteroids()
	local asteroidList = {}
	local asteroidCoordinates = {
    {-55790, 57467, 120},
    {-55506, 51890, 220},
    {-58720, 50095, 160},
    {-57585, 53875, 110},
    {-45676, 57183, 180},
    {-49362, 52363, 20},
    {-51064, 45747, 40},
    {-53994, 41871, 270},
    {-57869, 44896, 190},
    {-52481, 49149, 140},
    {-55979, 47164, 180},
    {-47188, 49433, 260},
    {-44447, 53214, 60},
    {-51820, 58129, 335},
    {-53805, 58696, 25},
    {-53805, 56238, 165},
    {-48984, 56805, 185},
    {-50024, 59546, 195},
    {-48890, 61815, 115},
    {-51253, 60870, 45},
    {-41423, 61909, 55},
    {-42557, 64461, 95},
    {-42084, 69093, 15},
    {-42273, 58412, 245},
    {-53143, 54253, 355},
    {-55033, 54631, 155},
    {-51158, 55766, 165},
    {-57207, 55388, 45},
    {-47566, 59924, 75},
    {-45582, 61626, 25},
    {-47945, 64461, 35},
    {-45676, 66824, 85},
    {-48039, 67297, 145},
    {-50024, 65690, 175},
    {-59665, 57372, 225},
    {-61366, 57467, 325},
    {-52670, 63422, 425},
    {-51253, 63989, 225},
    {-61461, 40359, 175},
    {-65241, 41777, 165},
    {-62028, 44802, 145},
    {-66943, 45936, 15},
    {-73559, 41871, 45},
    {-69778, 43006, 25},
    {-69022, 40832, 45},
    {-64674, 49244, 35},
    {-62028, 48866, 175},
    {-65336, 51890, 175},
    {-63067, 52363, 185},
    {-61555, 58507, 185},
    {-55317, 59641, 220},
    {-53332, 60302, 230},
    {-52387, 65690, 270},
    {-57680, 58696, 260},
    {-59570, 54159, 270},
    {-60893, 52646, 210},
    {-61461, 55766, 200},
    {-61933, 53592, 250},
    {-62973, 54442, 263},
    {-58814, 56522, 323},
    {-62595, 57278, 123},
    {-71763, 68904, 283},
    {-71952, 65595, 293},
    {-69211, 65690, 133},
    {-67510, 67202, 183},
    {-69022, 67675, 263},
    {-67037, 64745, 233},
    {-65147, 65595, 153},
    {-64107, 63233, 23},
    {-62784, 63327, 53},
    {-69022, 58223, 63},
    {-68644, 60491, 323},
    {-69211, 63233, 83},
    {-66470, 62665, 23},
    {-61461, 64272, 43},
    {-63162, 60491, 93},
    {-60515, 58790, 223},
    {-71385, 62382, 363},
    {-71574, 59452, 43},
    {-73559, 53970, 83},
    {-72519, 56616, 173},
    {-66565, 55766, 153},
    {-70251, 56144, 133},
    {-68549, 55577, 193},
    {-66659, 57750, 283},
    {-67132, 60208, 313},
    {-65052, 54631, 383},
    {-63635, 57089, 123},
    {-63635, 58601, 143},
    {-65336, 62193, 173},
    {-64013, 61909, 73},
    {-64863, 57940, 43},
    {-64580, 56427, 23},
    {-65052, 60681, 53},
    {-78285, 50284, 283},
    {-75166, 46881, 13},
    {-72141, 47070, 13},
    {-70818, 50473, 12},
    {-74126, 50662, 23},
    {-68171, 50756, 20},
    {-69589, 53592, 50},
    {-67793, 53119, 320},
    {-53489, 115865, 158},
    {-49845, 116259, 248},
    {-47089, 112517, 258},
    {-53390, 111927, 228},
    {-51322, 108087, 248},
    {-58116, 110745, 158},
    {-56246, 106610, 58},
    {-62252, 104148, 318},
    {-49268, 78922, 167},
    {-47283, 83365, 137},
    {-46716, 79584, 127},
    {-46054, 75992, 197},
    {-40572, 73535, 67},
    {-44353, 73913, 47},
    {-48959, 88099, 16},
    {-50929, 91939, 137},
    {-53616, 86200, 267},
    {-48565, 99225, 237},
    {-53685, 102474, 32},
    {-52012, 97945, 212},
    {-46892, 94991, 112},
    {-53981, 93711, 12},
    {-53616, 80813, 312},
    {-51158, 81853, 262},
    {-43347, 101588, 137},
    {-44725, 108284, 37},
    {-47975, 104837, 237},
    {-57526, 97354, 146},
    {-60282, 93317, 46},
    {-57132, 89280, 246},
    {-58720, 85539, 136},
    {-58436, 81380, 166},
    {-56168, 81474, 186},
    {-61562, 99324, 126},
    {-66486, 98142, 136},
    {-69341, 92530, 46},
    {-64910, 93022, 56},
    {-64221, 88788, 16},
    {-66943, 85255, 146},
    {-69144, 87311, 166},
    {-62406, 85633, 148},
    {-63824, 81191, 14},
    {-61933, 81947, 166},
    {-68833, 76087, 186},
    {-69873, 82798, 196},
    {-66470, 79017, 246},
    {-66659, 81285, 346},
    {-73476, 88493, 246},
    {-72141, 84310, 216},
    {-76962, 81380, 336},
    {-74882, 78828, 106},
    {-70818, 78733, 116},
    {-46054, 71645, 246},
    {-48795, 73819, 216},
    {-48134, 76087, 326},
    {-51253, 75236, 446},
    {-59192, 70510, 346},
    {-58058, 72117, 446},
    {-54466, 70794, 136},
    {-51158, 72779, 46},
    {-61272, 71739, 16},
    {-60421, 72873, 14},
    {-56073, 72401, 46},
    {-55884, 69660, 446},
    {-49268, 68904, 46},
    {-49079, 70699, 66},
    {-52387, 69849, 86},
    {-59381, 65974, 36},
    {-58909, 64745, 56},
    {-60515, 65028, 136},
    {-60232, 64461, 176},
    {-60421, 63138, 196},
    {-51347, 68336, 246},
    {-54183, 67580, 346},
    {-55979, 68053, 46},
    {-58909, 68147, 146},
    {-54844, 65312, 246},
    {-55884, 66257, 246},
    {-56924, 67108, 156},
    {-58247, 66730, 166},
    {-53805, 73913, 176},
    {-57113, 74197, 186},
    {-59192, 74669, 196},
    {-55884, 78355, 246},
    {-60893, 76181, 246},
    {-60515, 79017, 226},
    {-58342, 77505, 216},
    {-52954, 77316, 266},
    {-55600, 76276, 266},
    {-63351, 78450, 646},
    {-66281, 77032, 246},
    {-64107, 75331, 16},
    {-65903, 73819, 46},
    {-64863, 72023, 66},
    {-62500, 73440, 46},
    {-58720, 62193, 76},
    {-58625, 63705, 26},
    {-61177, 60113, 26},
    {-61272, 63422, 46},
    {-61366, 62382, 76},
    {-61839, 60870, 246},
    {-62500, 64745, 246},
    {-62500, 62193, 346},
    {-54088, 62854, 446},
    {-53899, 64272, 446},
    {-82633, 53781, 16},
    {-84334, 58507, 14},
    {-80364, 56711, 46},
    {-85090, 69282, 146},
    {-85657, 65028, 146},
    {-81404, 59830, 146},
    {-81593, 65974, 346},
    {-77623, 53970, 246},
    {-76300, 58318, 176},
    {-74221, 59168, 276},
    {-78663, 65028, 376},
    {-75260, 65406, 76},
    {-76772, 61720, 76},
    {-73937, 62382, 76},
    {-79041, 68336, 17},
    {-75638, 68053, 17},
    {-74504, 70605, 17},
    {-80837, 76654, 276},
    {-81687, 71550, 276},
    {-77907, 70983, 376},
    {-71574, 73062, 376},
    {-76867, 74858, 176},
    {-73559, 74669, 176},
    {-68266, 74291, 33},
    {-69117, 71550, 133},
    {-67037, 70510, 153},
    {-65619, 67864, 163},
    {-64107, 69093, 233},
    {-62595, 70416, 333},
    {-57869, 69376, 233},
    {-61177, 69093, 433},
    {-63540, 65595, 153},
    {-60704, 66352, 163},
    {-56168, 60964, 173},
    {-57963, 60870, 13},
    {-59287, 60208, 13},
    {-60137, 61248, 33},
    {-62689, 67958, 33},
    {-61083, 67864, 153},
    {-61839, 66446, 183},
    {-59948, 67013, 113},
    {-57585, 65406, 123},
    {-56640, 64556, 183},
    {-55695, 63422, 233},
    {-55695, 61909, 433},
    {-57207, 62854, 33}
    }
    for i=1,#asteroidCoordinates do
    	local staticAsteroid = Asteroid():setPosition(asteroidCoordinates[i][1],asteroidCoordinates[i][2]):setSize(asteroidCoordinates[i][3])
    	table.insert(asteroidList,staticAsteroid)
    end
    return asteroidList
end
function createH1toI2mines()
	local mine_list = {}
	local mine_coordinates = {
    {-69684, 69565},
    {-63162, 50378},
    {-57396, 57089},
    {-52859, 61720},
    {-52765, 67486},
    {-71385, 54253},
    {-72992, 63894},
    {-65808, 59263},
    {-64296, 67202},
    {-60736, 54671},
    {-57869, 75898}
    }
    for i=1,#mine_coordinates do
    	local static_mine = Mine():setPosition(mine_coordinates[i][1],mine_coordinates[i][2])
    	table.insert(mine_list,static_mine)
    end
    return mine_list
end
function createJ0toK0nebulae()
	local nebula_list = {}
	local nebula_coordinates = {
		{-89306, 81682},
		{-89049, 90014},
		{-85717, 97192},
		{-86999, 109498},
		{-83409, 101294}
    }
    for i=1,#nebula_coordinates do
    	local static_nebula = Nebula():setPosition(nebula_coordinates[i][1],nebula_coordinates[i][2])
    	table.insert(nebula_list,static_nebula)
    end
    return nebula_list
end
function createJ4toL8nebulae()
	local nebula_list = {}
	local nebula_coordinates = {
    	{11830, 121981},
    	{49516, 123627},
    	{36680, 94663}
    }
    for i=1,#nebula_coordinates do
    	local static_nebula = Nebula():setPosition(nebula_coordinates[i][1],nebula_coordinates[i][2])
    	table.insert(nebula_list,static_nebula)
    end
    local neb_x = random(-5000,75000)
    local neb_y = random(80000,140000)
    icarus_mobile_nebula_1 = Nebula():setPosition(neb_x,neb_y)
    icarus_mobile_nebula_1.angle = random(0,360)
    icarus_mobile_nebula_1.increment = random(0,10)
	plotMobile = movingObjects
	table.insert(nebula_list,icarus_mobile_nebula_1)
    return nebula_list
end
function createJ4toL8asteroids()
	local asteroidList = {}
	local asteroidCoordinates = {
		{30127, 87524, 20},
		{37878, 91210, 160},
		{42982, 96692, 150},
		{61413, 84121, 12},
		{43832, 84972, 220},
		{52434, 86011, 320},
		{47897, 91777, 220},
		{25874, 92155, 420},
		{32301, 97543, 520},
		{34192, 106333, 10},
		{14815, 103592, 60},
		{22944, 102268, 90},
		{49882, 99338, 125},
		{49409, 107845, 160},
		{45534, 105198, 180},
		{39957, 110491, 250},
		{68596, 93573, 330},
		{61224, 93478, 30},
		{56025, 106522, 20},
		{63681, 107561, 60},
		{71999, 102363, 520},
		{56309, 98677, 40},
		{59900, 114178, 50},
		{51488, 115879, 160},
		{45817, 115406, 130},
		{37689, 115312, 100},
		{27764, 114650, 110},
		{13870, 115501, 220},
		{14343, 94140, 320},
		{11507, 108318, 220},
		{18691, 109641, 130},
		{26347, 106616, 140},
		{6592, 105860, 125},
		{2339, 106049, 17},
		{5458, 112004, 180},
		{21432, 128639, 320},
		{6687, 117486, 520},
		{30127, 129584, 620},
		{26536, 123062, 420},
		{51677, 131191, 320},
		{25496, 133743, 220},
		{61318, 127410, 12},
		{70676, 116730, 12},
		{-3143, 117675, 12},
		{-2765, 123724, 150},
		{24551, 128355, 60},
		{26158, 138847, 190},
		{33341, 132703, 220},
		{2623, 128450, 320},
		{11885, 135444, 420},
		{17651, 133176, 480},
		{31640, 124764, 160},
		{19825, 119282, 180},
		{12263, 125803, 260},
		{42226, 125803, 380},
		{43360, 134877, 470},
		{53662, 121267, 120}
	}
    for i=1,#asteroidCoordinates do
    	local staticAsteroid = Asteroid():setPosition(asteroidCoordinates[i][1],asteroidCoordinates[i][2]):setSize(asteroidCoordinates[i][3])
    	staticAsteroid.original_size = asteroidCoordinates[i][3]
    	table.insert(asteroidList,staticAsteroid)
    end
    return asteroidList
end
function createBorlanFeatures()
	local asteroidList = {}
	local asteroidCoordinates = {
		{94849, 47119, 120},
		{97216, 46689, 220},
		{97001, 47837, 320},
		{95710, 46689, 220},
		{95996, 46043, 320},
		{96212, 48841, 10},
		{97646, 49487, 12},
		{98436, 48698, 20},
		{98149, 47478, 220},
		{85523, 47909, 250},
		{85523, 49415, 30},
		{86671, 44896, 380},
		{82366, 44824, 420},
		{92338, 46187, 520},
		{91907, 44824, 120},
		{90903, 43676, 80},
		{90975, 46689, 60},
		{90616, 47550, 220},
		{94131, 45900, 320},
		{93270, 47550, 220},
		{95925, 47550, 70},
		{94275, 48267, 50},
		{88464, 47550, 20},
		{80071, 49056, 12},
		{83227, 47693, 280},
		{86742, 46402, 370},
		{84877, 47048, 120},
		{84590, 45685, 460},
		{88392, 45613, 40},
		{89038, 44680, 12},
		{89755, 45900, 60},
		{82151, 45828, 80},
		{79497, 45398, 20},
		{80358, 44250, 20},
		{73040, 35067, 12},
		{79712, 42887, 90},
		{83873, 50563, 110},
		{83514, 49272, 150},
		{82008, 48985, 170},
		{80716, 46904, 320},
		{76484, 50132, 370},
		{78636, 47191, 450},
		{76340, 48482, 320},
		{78062, 48482, 520},
		{77058, 45541, 70},
		{76555, 46474, 40},
		{75336, 40807, 12},
		{75695, 43676, 12},
		{75766, 45900, 12},
		{76699, 44967, 12},
		{74332, 47980, 12},
		{73614, 47478, 20},
		{74403, 46474, 20},
		{75336, 47550, 20},
		{73471, 45541, 20},
		{74619, 42959, 20},
		{74762, 41739, 70},
		{74690, 44680, 20},
		{73614, 44106, 20},
		{74762, 38080, 90},
		{73973, 39372, 220},
		{74403, 40663, 220},
		{74834, 39946, 320},
		{73542, 40376, 320},
		{72610, 39443, 420},
		{73829, 42170, 420},
		{72969, 41524, 120},
		{72108, 38224, 10},
		{72395, 37291, 160},
		{73327, 38511, 50},
		{74045, 37363, 40},
		{77345, 43030, 220},
		{78349, 43963, 70},
		{77201, 39443, 90},
		{78277, 40304, 160},
		{78492, 42241, 520},
		{76771, 40663, 10},
		{76197, 42026, 10},
		{75264, 39157, 12},
		{73040, 36215, 320},
		{71749, 35713, 120},
		{71677, 34350, 470}
    }
    for i=1,#asteroidCoordinates do
    	local staticAsteroid = Asteroid():setPosition(asteroidCoordinates[i][1],asteroidCoordinates[i][2])
    	staticAsteroid:setSize(asteroidCoordinates[i][3])
    	staticAsteroid.original_size = asteroidCoordinates[i][3]
    	table.insert(asteroidList,staticAsteroid)
    end
    return asteroidList
end
function createFinneganFeatures()
	local feature_list = {}
	local asteroidCoordinates = {
		{121621, 76465, 120},
		{117556, 76465, 15},
		{120581, 76654, 50},
		{121337, 77505, 320},
		{114532, 74953, 65},
		{116139, 76087, 12},
		{116328, 77505, 460},
		{116706, 79584, 120},
		{117651, 79962, 160},
		{118785, 79112, 195},
		{119636, 77694, 270},
		{117178, 80813, 333},
		{116611, 82231, 120},
		{118785, 77127, 10},
		{117178, 77694, 220},
		{117934, 78639, 250},
	
		{133814, 79206, 620},
		{133530, 77599, 20},
		{132112, 80246, 120},
		{137594, 81380, 12},
		{135326, 80435, 12},
		{136838, 80246, 12},
		{135893, 79206, 220},
		{135137, 78072, 320},
		{142415, 85728, 70},
		{138350, 82420, 80},
		{139012, 82798, 70},
		{137216, 82798, 80},
		{138256, 80624, 180},
		{140808, 85161, 190},
		{140241, 84216, 220},
		{139296, 81569, 20},
	
		{130694, 105009, 580},
		{130316, 103403, 12},
		{129088, 102363, 12},
		{128899, 101323, 20},
		{132963, 106238, 320},
		{130600, 109263, 220},
		{130883, 107467, 470},
		{133908, 107372, 80},
		{129655, 108034, 20},
		{132207, 104726, 12},
		{131356, 104348, 90},
		{133246, 103403, 220},
		{131545, 106144, 320},
		{134475, 101796, 270},
	
		{109995, 96597, 120},
		{107916, 92911, 220},
		{108483, 92250, 320},
		{106781, 90359, 420},
		{108766, 93478, 12},
		{108672, 94329, 20},
		{109239, 98015, 60},
		{108955, 95936, 70},
		{104513, 88280, 80},
		{103284, 89792, 90},
		{101961, 91777, 320},
		{105175, 89509, 380},
		{107727, 91021, 25},
		{106876, 89319, 70},
		{102055, 90548, 65},
		{102717, 88752, 120}
    }
    for i=1,#asteroidCoordinates do
    	local staticAsteroid = Asteroid():setPosition(asteroidCoordinates[i][1],asteroidCoordinates[i][2]):setSize(asteroidCoordinates[i][3])
    	staticAsteroid.original_size = asteroidCoordinates[i][3]
    	table.insert(feature_list,staticAsteroid)
    end
    local neb = Nebula():setPosition(108483, 93100)
    table.insert(feature_list,neb)
    local strat_x = 138000
    local strat_y = 138000
    local planet_strat = Planet():setPosition(strat_x,strat_y):setPlanetRadius(750):setDistanceFromMovementPlane(-1500):setPlanetAtmosphereTexture("planets/star-1.png"):setPlanetAtmosphereColor(1.0,.9,.9):setCallSign("Stratbik")
    table.insert(feature_list,planet_strat)
    local primus_angle = random(0,360)
    local primus_distance = 45000
    local primus_x, primus_y = vectorFromAngle(primus_angle,primus_distance)
    local planet_primus = Planet():setPosition(strat_x+primus_x,strat_y+primus_y):setPlanetRadius(1800):setDistanceFromMovementPlane(-600)
    planet_primus:setPlanetSurfaceTexture("planets/planet-2.png"):setPlanetAtmosphereTexture("planets/atmosphere.png"):setPlanetAtmosphereColor(0.1,0.6,0.1)
    planet_primus:setCallSign("Pillory"):setOrbit(planet_strat,2500)
    table.insert(feature_list,planet_primus)
    return feature_list
end
-- Kentar area stations, asteroids, mines, etc. 
function setKentarRegion()
	playerSpawnX = 250000
	playerSpawnY = 250000
	startRegion = "Kentar"
	removeIcarusColor()
	createKentarColor()
	setStartRegion()
end
function createKentarColor()
	kentar_planets = createKentarPlanets()
	kentar_asteroids = createKentarAsteroids()
	kentar_nebula = createKentarNebula()
	kentar_stations = createKentarStations()
	regionStations = kentar_stations
end
function createKentarStations()
	local stations = {}
	local nukeAvail = true
	local empAvail = true
	local mineAvail = true
	local homeAvail = true
	local hvliAvail = true
	local tradeFood = true
	local tradeMedicine = true
	local tradeLuxury = true
	--Katanga
    stationKatanga = SpaceStation():setTemplate("Small Station"):setFaction("Human Navy"):setPosition(229513, 224048):setCallSign("Katanga"):setDescription("Mining station for cobalt, gold and other minerals"):setCommsScript(""):setCommsFunction(commsStation)
    if random(1,100) <= 30 then nukeAvail = true else nukeAvail = false end
    if random(1,100) <= 40 then empAvail = true else empAvail = false end
    if random(1,100) <= 50 then mineAvail = true else mineAvail = false end
    if random(1,100) <= 60 then homeAvail = true else homeAvail = false end
    if random(1,100) <= 80 then hvliAvail = true else hvliAvail = false end
    if random(1,100) <= 67 then tradeLuxury = true else tradeLuxury = false end
    stationKatanga.comms_data = {
    	friendlyness = 75,
        weapons = 			{Homing = "neutral",HVLI = "neutral", 		Mine = "friend",		Nuke = "friend", 			EMP = "friend"},
        weapon_cost =		{Homing = 3, 		HVLI = math.random(2,4),Mine = math.random(2,5),Nuke = math.random(12,18),	EMP = 10 },
        weapon_available = 	{Homing = homeAvail,HVLI = hvliAvail,		Mine = mineAvail,		Nuke = nukeAvail,			EMP = empAvail},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 2.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	cobalt = 	{quantity = math.random(5,10),	cost = math.random(60,70)},
        			gold = 		{quantity = math.random(5,10),	cost = math.random(55,90)}	},
        trade = {	food = true, medicine = false, luxury = tradeLuxury },
        public_relations = true,
        general_information = "Extracting minerals from these asteroids is our job",
    	history = "Based on the scans showing cobalt in many of these asteroids, we named this station after an ancient earth mining operation that was part of the Glencore Public Limited Comany"
	}
	table.insert(stations,stationKatanga)
	return stations
end
function createKentarPlanets()
	local planet_list = {}
	rigil_x = 408742
	rigil_y = 169754
	planet_rigil = Planet():setPosition(rigil_x,rigil_y):setPlanetRadius(1000):setDistanceFromMovementPlane(-2000):setPlanetAtmosphereTexture("planets/star-1.png"):setPlanetAtmosphereColor(1.0,.9,.9):setCallSign("Rigil")
	table.insert(planet_list,planet_rigil)
	primus_angle = random(0,360)
	primus_distance = 60000
	primus_x, primus_y = vectorFromAngle(primus_angle,primus_distance)
	planet_primus = Planet():setPosition(rigil_x+primus_x,rigil_y+primus_y):setPlanetRadius(1000):setDistanceFromMovementPlane(-500)
	planet_primus:setPlanetSurfaceTexture("planets/planet-2.png"):setPlanetAtmosphereTexture("planets/atmosphere.png"):setPlanetAtmosphereColor(0.3,0.15,0.1)
	planet_primus:setCallSign("Ergot"):setOrbit(planet_rigil,3000)
	table.insert(planet_list,planet_primus)
	black_hole_k1 = BlackHole():setPosition(290000,210000)
	table.insert(planet_list,black_hole_k1)
	black_hole_k2 = BlackHole():setPosition(210000,290000)
	table.insert(planet_list,black_hole_k2)
	return planet_list
end
function createKentarAsteroids()
	local asteroid_list = {}
	local asteroid_coordinates = {
    {223576, 220378, 20},
    {228043, 213831, 120},
    {231509, 219223, 220},
    {229352, 216758, 320},
    {222882, 239095, 180},
    {236054, 227079, 160},
    {232741, 219300, 190},
    {233897, 219300, 12},
    {227427, 220995, 20},
    {231432, 220840, 220},
    {225501, 231239, 320},
    {227966, 227465, 420},
    {230200, 227542, 520},
    {226425, 224461, 620},
    {221881, 227002, 320},
    {216720, 230854, 220},
    {224423, 216527, 170},
    {236439, 224615, 180},
    {238518, 222689, 20},
    {228813, 232317, 12},
    {224962, 234474, 50},
    {232664, 230931, 70},
    {235514, 228928, 80},
    {237594, 219146, 15},
    {232048, 223690, 25},
    {236747, 229698, 325},
    {240059, 230391, 725},
    {234051, 226925, 225},
    {234282, 232471, 225},
    {237671, 227465, 165},
    {240521, 226232, 165},
    {238826, 231470, 175},
    {239366, 228312, 195},
    {240752, 228389, 325},
    {241907, 228235, 425} }
    for i=1,#asteroid_coordinates do
    	local static_asteroid = Asteroid():setPosition(asteroid_coordinates[i][1],asteroid_coordinates[i][2]):setSize(asteroid_coordinates[i][3])
    	table.insert(asteroid_list,static_asteroid)
    end
    return asteroid_list
end
function createKentarNebula()
	local nebula_list = {}
	local nebula_coordinates = {
		{214130, 197543},
		{225472, 200000},
		{228118, 191115},
		{219234, 192628},
		{194659, 189792},
		{201842, 190737},
		{209404, 193384},
		{235680, 188091}
	}
	for i=1,#nebula_coordinates do
    	local static_nebula = Nebula():setPosition(nebula_coordinates[i][1],nebula_coordinates[i][2])
    	table.insert(nebula_list,static_nebula)
	end
	local mobile_neb_dist = 56568.542495
	local nebula_start_angle = random(0,360)
	local snpx,snpy = vectorFromAngle(nebula_start_angle,mobile_neb_dist)
	kentar_mobile_nebula_1 = Nebula():setPosition(210000+snpx,290000+snpy)
	kentar_mobile_nebula_1.angle = nebula_start_angle
	kentar_mobile_nebula_1.mobile_neb_dist = mobile_neb_dist
	kentar_mobile_nebula_1.center_x = 210000
	kentar_mobile_nebula_1.center_y = 290000
	if kentar_mobile_nebula_1.angle >= 45 then
		kentar_mobile_nebula_1.ready = false
	else
		kentar_mobile_nebula_1.ready = true
	end
	kentar_mobile_nebula_1.lower_black_hole = true
	kentar_mobile_nebula_1.increment = .05
	plotMobile = movingObjects
	table.insert(nebula_list,kentar_mobile_nebula_1)
    return nebula_list
end
function removeKentarColor()
	if kentar_planets ~= nil then
		for _,kp in pairs(kentar_planets) do
			kp:destroy()
		end
	end
	kentar_planets = nil
	
	if kentar_asteroids ~= nil then
		for _,ka in pairs(kentar_asteroids) do
			ka:destroy()
		end
	end
	kentar_asteroids = nil
	
	if kentar_nebula ~= nil then
		for _,kn in pairs(kentar_nebula) do
			kn:destroy()
		end
	end
	kentar_nebula = nil
	
	if kentar_stations ~= nil then
		for _,ks in pairs(kentar_stations) do
			ks:destroy()
		end
	end
	kentar_stations = nil
end
-------------------
--	Spawn fleet  --
-------------------
--General use functions for spawning fleets
function playerPower()
	local playerShipScore = 0
	for pidx=1,8 do
		local p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			if p.shipScore == nil then
				assignPlayerShipScore(p)
			end
			playerShipScore = playerShipScore + p.shipScore
		end
	end
	return playerShipScore
end
function assignPlayerShipScore(p)
	local tempTypeName = p:getTypeName()
	if tempTypeName ~= nil then
		local shipScore = playerShipStrength[tempTypeName]
		if shipScore ~= nil and shipScore > 0 then
			p.shipScore = shipScore
			p.maxCargo = playerShipCargo[tempTypeName]
			p.cargo = p.maxCargo
		else
			p.shipScore = 24
			p.maxCargo = 5
			p.cargo = p.maxCargo
		end
	else
		p.shipScore = 24
		p.maxCargo = 5
		p.cargo = p.maxCargo
	end
	p.maxRepairCrew = p:getRepairCrewCount()
	p.healthyShield = 1.0
	p.prevShield = 1.0
	p.healthyReactor = 1.0
	p.prevReactor = 1.0
	p.healthyManeuver = 1.0
	p.prevManeuver = 1.0
	p.healthyImpulse = 1.0
	p.prevImpulse = 1.0
	if p:getBeamWeaponRange(0) > 0 then
		p.healthyBeam = 1.0
		p.prevBeam = 1.0
	end
	if p:getWeaponTubeCount() > 0 then
		p.healthyMissile = 1.0
		p.prevMissile = 1.0
	end
	if p:hasWarpDrive() then
		p.healthyWarp = 1.0
		p.prevWarp = 1.0
	end
	if p:hasJumpDrive() then
		p.healthyJump = 1.0
		p.prevJump = 1.0
	end
	p.initialCoolant = p:getMaxCoolant()
end
function spawnGMFleet()
	clearGMFunctions()
	addGMFunction("-Main From Flt Spwn",initialGMFunctions)
	addGMFunction(string.format("+%s",fleetSpawnFaction),setGMFleetFaction)
	if fleetStrengthFixed then
		addGMFunction("+Set Relative Strength",setGMFleetStrength)
		addGMFunction(string.format("+Strength %i*",fleetStrengthFixedValue),setFixedFleetStrength)
	else
		local calcStr = math.floor(playerPower()*fleetStrengthByPlayerStrength)
		local GMSetGMFleetStrength = fleetStrengthByPlayerStrength .. " player strength: " .. calcStr
		addGMFunction("+" .. GMSetGMFleetStrength .. "*",setGMFleetStrength)
		addGMFunction("+Set Fixed Strength",setFixedFleetStrength)
	end
	addGMFunction(string.format("+%s",fleetComposition),setFleetComposition)
	addGMFunction(string.format("+%s",fleetChange),setFleetChange)
	addGMFunction(string.format("+%s",fleetOrders),setFleetOrders)
	addGMFunction(string.format("+%s",fleetSpawnLocation),setFleetSpawnLocation)
	addGMFunction("Spawn",parmSpawnFleet)
end
--Fleet faction
function setGMFleetFaction()
	clearGMFunctions()
	--addGMFunction("-Main from Flt Fctn",initialGMFunctions)
	--addGMFunction("-Fleet Spawn",spawnGMFleet)
	local GMSetFleetFactionArlenians = "Arlenians"
	if fleetSpawnFaction == "Arlenians" then
		GMSetFleetFactionArlenians = "Arlenians*"
	end
	addGMFunction(GMSetFleetFactionArlenians,function()
		fleetSpawnFaction = "Arlenians"
		spawnGMFleet()
	end)
	local GMSetFleetFactionExuari = "Exuari"
	if fleetSpawnFaction == "Exuari" then
		GMSetFleetFactionExuari = "Exuari*"
	end
	addGMFunction(GMSetFleetFactionExuari,function()
		fleetSpawnFaction = "Exuari"
		spawnGMFleet()
	end)
	local GMSetFleetFactionGhosts = "Ghosts"
	if fleetSpawnFaction == "Ghosts" then
		GMSetFleetFactionGhosts = "Ghosts*"
	end
	addGMFunction(GMSetFleetFactionGhosts,function()
		fleetSpawnFaction = "Ghosts"
		spawnGMFleet()
	end)
	local GMSetFleetFactionHuman = "Human Navy"
	if fleetSpawnFaction == "Human Navy" then
		GMSetFleetFactionHuman = "Human Navy*"
	end
	addGMFunction(GMSetFleetFactionHuman,function()
		fleetSpawnFaction = "Human Navy"
		spawnGMFleet()
	end)
	local GMSetFleetFactionKraylor = "Kraylor"
	if fleetSpawnFaction == "Kraylor" then
		GMSetFleetFactionKraylor = "Kraylor*"
	end
	addGMFunction(GMSetFleetFactionKraylor,function()
		fleetSpawnFaction = "Kraylor"
		spawnGMFleet()
	end)
	local GMSetFleetFactionKtlitans = "Ktlitans"
	if fleetSpawnFaction == "Ktlitans" then
		GMSetFleetFactionKtlitans = "Ktlitans*"
	end
	addGMFunction(GMSetFleetFactionKtlitans,function()
		fleetSpawnFaction = "Ktlitans"
		spawnGMFleet()
	end)
	local GMSetFleetFactionIndependent = "Independent"
	if fleetSpawnFaction == "Independent" then
		GMSetFleetFactionIndependent = "Independent*"
	end
	addGMFunction(GMSetFleetFactionIndependent,function()
		fleetSpawnFaction = "Independent"
		spawnGMFleet()
	end)
	local GMSetFleetFactionTSN = "TSN"
	if fleetSpawnFaction == "TSN" then
		GMSetFleetFactionTSN = "TSN*"
	end
	addGMFunction(GMSetFleetFactionTSN,function()
		fleetSpawnFaction = "TSN"
		spawnGMFleet()
	end)
	local GMSetFleetFactionUSN = "USN"
	if fleetSpawnFaction == "USN" then
		GMSetFleetFactionUSN = "USN*"
	end
	addGMFunction(GMSetFleetFactionUSN,function()
		fleetSpawnFaction = "USN"
		spawnGMFleet()
	end)
	local GMSetFleetFactionCUF = "CUF"
	if fleetSpawnFaction == "CUF" then
		GMSetFleetFactionCUF = "CUF*"
	end
	addGMFunction(GMSetFleetFactionCUF,function()
		fleetSpawnFaction = "CUF"
		spawnGMFleet()
	end)
end
--Fleet strength
function setGMFleetStrength()
	clearGMFunctions()
	addGMFunction("-Main from Rel Str",initialGMFunctions)
	addGMFunction("-Fleet Spawn",spawnGMFleet)
	local GMSetFleetStrengthByPlayerStrengthHalf = ".5"
	if fleetStrengthByPlayerStrength == .5 then
		GMSetFleetStrengthByPlayerStrengthHalf = ".5*"
	end
	addGMFunction(GMSetFleetStrengthByPlayerStrengthHalf,function()
		fleetStrengthByPlayerStrength = .5
		setGMFleetStrength()
	end)
	local GMSetFleetStrengthByPlayerStrength1 = "1"
	if fleetStrengthByPlayerStrength == 1 then
		GMSetFleetStrengthByPlayerStrength1 = "1*"
	end
	addGMFunction(GMSetFleetStrengthByPlayerStrength1,function()
		fleetStrengthByPlayerStrength = 1
		setGMFleetStrength()
	end)
	local GMSetFleetStrengthByPlayerStrength2 = "2"
	if fleetStrengthByPlayerStrength == 2 then
		GMSetFleetStrengthByPlayerStrength2 = "2*"
	end
	addGMFunction(GMSetFleetStrengthByPlayerStrength2,function()
		fleetStrengthByPlayerStrength = 2
		setGMFleetStrength()
	end)
	local GMSetFleetStrengthByPlayerStrength3 = "3"
	if fleetStrengthByPlayerStrength == 3 then
		GMSetFleetStrengthByPlayerStrength3 = "3*"
	end
	addGMFunction(GMSetFleetStrengthByPlayerStrength3,function()
		fleetStrengthByPlayerStrength = 3
		setGMFleetStrength()
	end)
	local GMSetFleetStrengthByPlayerStrength4 = "4"
	if fleetStrengthByPlayerStrength == 4 then
		GMSetFleetStrengthByPlayerStrength4 = "4*"
	end
	addGMFunction(GMSetFleetStrengthByPlayerStrength4,function()
		fleetStrengthByPlayerStrength = 4
		setGMFleetStrength()
	end)
	local GMSetFleetStrengthByPlayerStrength5 = "5"
	if fleetStrengthByPlayerStrength == 5 then
		GMSetFleetStrengthByPlayerStrength5 = "5*"
	end
	addGMFunction(GMSetFleetStrengthByPlayerStrength5,function()
		fleetStrengthByPlayerStrength = 5
		setGMFleetStrength()
	end)
	fleetStrengthFixed = false
end
function setFixedFleetStrength()
	clearGMFunctions()
	addGMFunction("-Main from Fix Str",initialGMFunctions)
	addGMFunction("-Fleet Spawn",spawnGMFleet)
	addGMFunction("-Fixed Strength " .. fleetStrengthFixedValue,spawnGMFleet)
	if fleetStrengthFixedValue > 50 then
		addGMFunction(string.format("%i - %i = %i",fleetStrengthFixedValue,50,fleetStrengthFixedValue-50),function()
			fleetStrengthFixedValue = fleetStrengthFixedValue - 50
			setFixedFleetStrength()
		end)
	end
	if fleetStrengthFixedValue < 2000 then
		addGMFunction(string.format("%i + %i = %i",fleetStrengthFixedValue,50,fleetStrengthFixedValue+50),function()
			fleetStrengthFixedValue = fleetStrengthFixedValue + 50
			setFixedFleetStrength()
		end)
	end	
	fleetStrengthFixed = true
end
--Fleet Composition
function setFleetComposition()
	clearGMFunctions()
	addGMFunction("-Main from Flt Comp",initialGMFunctions)
	addGMFunction("-Fleet Spawn",spawnGMFleet)
	local GMSetFleetCompositionRandom = "Random"
	if fleetComposition == "Random" then
		GMSetFleetCompositionRandom = "Random*"
	end
	addGMFunction(GMSetFleetCompositionRandom,function()
		fleetComposition = "Random"
		setFleetComposition()
	end)
	local GMSetFleetCompositionFighters = "Fighters"
	if fleetComposition == "Fighters" then
		GMSetFleetCompositionFighters = "Fighters*"
	end
	addGMFunction(GMSetFleetCompositionFighters,function()
		fleetComposition = "Fighters"
		setFleetComposition()
	end)
	local GMSetFleetCompositionChasers = "Chasers"
	if fleetComposition == "Chasers" then
		GMSetFleetCompositionChasers = "Chasers*"
	end
	addGMFunction(GMSetFleetCompositionChasers,function()
		fleetComposition = "Chasers"
		setFleetComposition()
	end)
	local GMSetFleetCompositionFrigates = "Frigates"
	if fleetComposition == "Frigates" then
		GMSetFleetCompositionFrigates = "Frigates*"
	end
	addGMFunction(GMSetFleetCompositionFrigates,function()
		fleetComposition = "Frigates"
		setFleetComposition()
	end)
	local GMSetFleetCompositionBeamers = "Beamers"
	if fleetComposition == "Beamers" then
		GMSetFleetCompositionBeamers = "Beamers*"
	end
	addGMFunction(GMSetFleetCompositionBeamers,function()
		fleetComposition = "Beamers"
		setFleetComposition()
	end)
	local GMSetFleetCompositionMissilers = "Missilers"
	if fleetComposition == "Missilers" then
		GMSetFleetCompositionMissilers = "Missilers*"
	end
	addGMFunction(GMSetFleetCompositionMissilers,function()
		fleetComposition = "Missilers"
		setFleetComposition()
	end)
	local GMSetFleetCompositionAdders = "Adders"
	if fleetComposition == "Adders" then
		GMSetFleetCompositionAdders = "Adders*"
	end
	addGMFunction(GMSetFleetCompositionAdders,function()
		fleetComposition = "Adders"
		setFleetComposition()
	end)		
	local GMSetFleetCompositionNonDB = "Non-DB"
	if fleetComposition == "Non-DB" then
		GMSetFleetCompositionNonDB = "Non-DB*"
	end
	addGMFunction(GMSetFleetCompositionNonDB,function()
		fleetComposition = "Non-DB"
		setFleetComposition()
	end)		
end
--Fleet change
function setFleetChange()
	clearGMFunctions()
	addGMFunction("-Main from Flt Chng",initialGMFunctions)
	addGMFunction("-Fleet Spawn",spawnGMFleet)
	local GMSetFleetChangeUnmodified = "Unmodified"
	if fleetChange == "unmodified" then
		GMSetFleetChangeUnmodified = "Unmodified*"
	end
	addGMFunction(GMSetFleetChangeUnmodified,function()
		fleetChange = "unmodified"
		setFleetChange()
	end)
	local GMSetFleetChangeImproved = "Improved"
	if fleetChange == "improved" then
		GMSetFleetChangeImproved = "Improved*"
	end
	addGMFunction(GMSetFleetChangeImproved,function()
		fleetChange = "improved"
		setFleetChange()
	end)
	local GMSetFleetChangeDegraded = "Degraded"
	if fleetChange == "degraded" then
		GMSetFleetChangeDegraded = "Degraded*"
	end
	addGMFunction(GMSetFleetChangeDegraded,function()
		fleetChange = "degraded"
		setFleetChange()
	end)
	local GMSetFleetChangeTinkered = "Tinkered"
	if fleetChange == "tinkered" then
		GMSetFleetChangeTinkered = "Tinkered*"
	end
	addGMFunction(GMSetFleetChangeTinkered,function()
		fleetChange = "tinkered"
		setFleetChange()
	end)
	if fleetChange ~= "unmodified" then
		addGMFunction("Change Chance: " .. fleetChangeChance,setFleetChange)
		if fleetChangeChance == 10 then
			addGMFunction("Set to 20",function()
				fleetChangeChance = 20
				setFleetChange()
			end)
		end
		if fleetChangeChance == 20 then
			addGMFunction("Set to 10", function()
				fleetChangeChance = 10
				setFleetChange()
			end)
			addGMFunction("Set to 30", function()
				fleetChangeChance = 30
				setFleetChange()
			end)
		end
		if fleetChangeChance == 30 then
			addGMFunction("Set to 20", function()
				fleetChangeChance = 20
				setFleetChange()
			end)
			addGMFunction("Set to 50", function()
				fleetChangeChance = 50
				setFleetChange()
			end)
		end
		if fleetChangeChance == 50 then
			addGMFunction("Set to 30", function()
				fleetChangeChance = 30
				setFleetChange()
			end)
			addGMFunction("Set to 70", function()
				fleetChangeChance = 70
				setFleetChange()
			end)
		end
		if fleetChangeChance == 70 then
			addGMFunction("Set to 50", function()
				fleetChangeChance = 50
				setFleetChange()
			end)
			addGMFunction("Set to 80", function()
				fleetChangeChance = 80
				setFleetChange()
			end)
		end
		if fleetChangeChance == 80 then
			addGMFunction("Set to 70", function()
				fleetChangeChance = 70
				setFleetChange()
			end)
			addGMFunction("Set to 90", function()
				fleetChangeChance = 90
				setFleetChange()
			end)
		end
		if fleetChangeChance == 90 then
			addGMFunction("Set to 80", function()
				fleetChangeChance = 80
				setFleetChange()
			end)
			addGMFunction("Set to 100", function()
				fleetChangeChance = 100
				setFleetChange()
			end)
		end
		if fleetChangeChance == 100 then
			addGMFunction("Set to 90",function()
				fleetChangeChance = 90
				setFleetChange()
			end)
		end
	end
end
--Fleet orders when spawned
function setFleetOrders()
	clearGMFunctions()
	addGMFunction("-Main from Flt Ord",initialGMFunctions)
	addGMFunction("-Fleet Spawn",spawnGMFleet)
	local GMSetFleetOrdersRoaming = "Roaming"
	if fleetOrders == "Roaming" then
		GMSetFleetOrdersRoaming = "Roaming*"
	end
	addGMFunction(GMSetFleetOrdersRoaming,function()
		fleetOrders = "Roaming"
		setFleetOrders()
	end)
	local GMSetFleetOrdersIdle = "Idle"
	if fleetOrders == "Idle" then
		GMSetFleetOrdersIdle = "Idle*"
	end
	addGMFunction(GMSetFleetOrdersIdle,function()
		fleetOrders = "Idle"
		setFleetOrders()
	end)
	local GMSetFleetOrdersStandGround = "Stand Ground"
	if fleetOrders == "Stand Ground" then
		GMSetFleetOrdersStandGround = "Stand Ground*"
	end
	addGMFunction(GMSetFleetOrdersStandGround,function()
		fleetOrders = "Stand Ground"
		setFleetOrders()
	end)
end
--Fleet spawn location
function setFleetSpawnLocation()
	clearGMFunctions()
	addGMFunction("-Main from Flt Loctn",initialGMFunctions)
	addGMFunction("-Fleet Spawn",spawnGMFleet)
	local GMSetSpawnLocationAtSelection = "At Selection"
	if fleetSpawnLocation == "At Selection" then
		GMSetSpawnLocationAtSelection = "At Selection*"
	end
	addGMFunction(GMSetSpawnLocationAtSelection,function()
		fleetSpawnLocation = "At Selection"
		setFleetSpawnLocation()
	end)
	local GMSetSpawnLocationSensorEdge = "Sensor Edge"
	if fleetSpawnLocation == "Sensor Edge" then
		GMSetSpawnLocationSensorEdge = "Sensor Edge*"
	end
	addGMFunction(GMSetSpawnLocationSensorEdge,function()
		fleetSpawnLocation = "Sensor Edge"
		setFleetSpawnLocation()
	end)
	local GMSetSpawnLocationBeyondSensors = "Beyond Sensors"
	if fleetSpawnLocation == "Beyond Sensors" then
		GMSetSpawnLocationBeyondSensors = "Beyond Sensors*"
	end
	addGMFunction(GMSetSpawnLocationBeyondSensors,function()
		fleetSpawnLocation = "Beyond Sensors"
		setFleetSpawnLocation()
	end)
	local GMSetSpawnLocationAmbush = string.format("Ambush %i",fleetAmbushDistance) 
	if fleetSpawnLocation == "Ambush" then
		GMSetSpawnLocationAmbush = string.format("Ambush* %i",fleetAmbushDistance)
	end
	addGMFunction(string.format("+%s",GMSetSpawnLocationAmbush),function()
		fleetSpawnLocation = "Ambush"
		setFleetAmbushDistance()
	end)
	if fleetSpawnLocation == "Sensor Edge" or fleetSpawnLocation == "Beyond Sensors" then
		addGMFunction(string.format("+%s",fleetSpawnRelativeDirection),setFleetSpawnRelativeDirection)
	end
	local GMSetSpawnLocationAway = "Away"
	if string.find(fleetSpawnLocation,"Away") then
		GMSetSpawnLocationAway = fleetSpawnLocation .. "*"
	end
	addGMFunction(string.format("+%s",GMSetSpawnLocationAway),setSpawnLocationAway)
end
function setFleetAmbushDistance()
	clearGMFunctions()
	addGMFunction("-From Ambush Dist",setFleetSpawnLocation)
	local GMSetFleetAmbushDistance3 = "3"
	if fleetAmbushDistance == 3 then
		GMSetFleetAmbushDistance3 = "3*"
	end
	addGMFunction(GMSetFleetAmbushDistance3,function()
		fleetAmbushDistance = 3
		setFleetAmbushDistance()
	end)
	local GMSetFleetAmbushDistance4 = "4"
	if fleetAmbushDistance == 4 then
		GMSetFleetAmbushDistance4 = "4*"
	end
	addGMFunction(GMSetFleetAmbushDistance4,function()
		fleetAmbushDistance = 4
		setFleetAmbushDistance()
	end)
	local GMSetFleetAmbushDistance5 = "5"
	if fleetAmbushDistance == 5 then
		GMSetFleetAmbushDistance5 = "5*"
	end
	addGMFunction(GMSetFleetAmbushDistance5,function()
		fleetAmbushDistance = 5
		setFleetAmbushDistance()
	end)
	local GMSetFleetAmbushDistance6 = "6"
	if fleetAmbushDistance == 6 then
		GMSetFleetAmbushDistance6 = "6*"
	end
	addGMFunction(GMSetFleetAmbushDistance6,function()
		fleetAmbushDistance = 6
		setFleetAmbushDistance()
	end)
	local GMSetFleetAmbushDistance7 = "7"
	if fleetAmbushDistance == 7 then
		GMSetFleetAmbushDistance7 = "7*"
	end
	addGMFunction(GMSetFleetAmbushDistance7,function()
		fleetAmbushDistance = 7
		setFleetAmbushDistance()
	end)
end
--Fleet spawn relative direction from player
function setFleetSpawnRelativeDirection()
	clearGMFunctions()
	addGMFunction("-From Spwn Direction",setFleetSpawnLocation)
	local GMSetFleetSpawnRelativeDirectionRandom = "Random Direction"
	if fleetSpawnRelativeDirection == "Random Direction" then
		GMSetFleetSpawnRelativeDirectionRandom = "Random Direction*"
	end
	addGMFunction(GMSetFleetSpawnRelativeDirectionRandom,function()
		fleetSpawnRelativeDirection = "Random Direction"
		setFleetSpawnRelativeDirection()
	end)
	local GMSetFleetSpawnRelativeDirection0 = "0"
	if fleetSpawnRelativeDirection == 0 then
		GMSetFleetSpawnRelativeDirection0 = "0*"
	end
	addGMFunction(GMSetFleetSpawnRelativeDirection0,function()
		fleetSpawnRelativeDirection = 0
		setFleetSpawnRelativeDirection()
	end)
	local GMSetFleetSpawnRelativeDirection45 = "45"
	if fleetSpawnRelativeDirection == 45 then
		GMSetFleetSpawnRelativeDirection45 = "45*"
	end
	addGMFunction(GMSetFleetSpawnRelativeDirection45,function()
		fleetSpawnRelativeDirection = 45
		setFleetSpawnRelativeDirection()
	end)
	local GMSetFleetSpawnRelativeDirection90 = "90"
	if fleetSpawnRelativeDirection == 90 then
		GMSetFleetSpawnRelativeDirection90 = "90*"
	end
	addGMFunction(GMSetFleetSpawnRelativeDirection90,function()
		fleetSpawnRelativeDirection = 90
		setFleetSpawnRelativeDirection()
	end)
	local GMSetFleetSpawnRelativeDirection135 = "135"
	if fleetSpawnRelativeDirection == 135 then
		GMSetFleetSpawnRelativeDirection135 = "135*"
	end
	addGMFunction(GMSetFleetSpawnRelativeDirection135,function()
		fleetSpawnRelativeDirection = 135
		setFleetSpawnRelativeDirection()
	end)
	local GMSetFleetSpawnRelativeDirection180 = "180"
	if fleetSpawnRelativeDirection == 180 then
		GMSetFleetSpawnRelativeDirection180 = "180*"
	end
	addGMFunction(GMSetFleetSpawnRelativeDirection180,function()
		fleetSpawnRelativeDirection = 180
		setFleetSpawnRelativeDirection()
	end)
	local GMSetFleetSpawnRelativeDirection225 = "225"
	if fleetSpawnRelativeDirection == 225 then
		GMSetFleetSpawnRelativeDirection225 = "225*"
	end
	addGMFunction(GMSetFleetSpawnRelativeDirection225,function()
		fleetSpawnRelativeDirection = 225
		setFleetSpawnRelativeDirection()
	end)
	local GMSetFleetSpawnRelativeDirection270 = "270"
	if fleetSpawnRelativeDirection == 270 then
		GMSetFleetSpawnRelativeDirection270 = "270*"
	end
	addGMFunction(GMSetFleetSpawnRelativeDirection270,function()
		fleetSpawnRelativeDirection = 270
		setFleetSpawnRelativeDirection()
	end)
	local GMSetFleetSpawnRelativeDirection315 = "315"
	if fleetSpawnRelativeDirection == 315 then
		GMSetFleetSpawnRelativeDirection315 = "315*"
	end
	addGMFunction(GMSetFleetSpawnRelativeDirection315,function()
		fleetSpawnRelativeDirection = 315
		setFleetSpawnRelativeDirection()
	end)
end
--Fleet spawn at a location away from GM selection
function setSpawnLocationAway()
	clearGMFunctions()
	addGMFunction("-Main from Spwn Awy",initialGMFunctions)
	addGMFunction("-Fleet Spawn",spawnGMFleet)
	addGMFunction("-From Spawn Away",setFleetSpawnLocation)
	local GMSetFleetSpawnAwayDirection = fleetSpawnAwayDirection .. " Degrees"
	addGMFunction(string.format("+%s",GMSetFleetSpawnAwayDirection),setFleetSpawnAwayDirection)
	local GMSetFleetSpawnAwayDistance = fleetSpawnAwayDistance .. "U"
	addGMFunction(string.format("+%s",GMSetFleetSpawnAwayDistance),setFleetSpawnAwayDistance)
	fleetSpawnLocation = string.format("%s Deg Away %iU",fleetSpawnAwayDirection,fleetSpawnAwayDistance)
end
function setFleetSpawnAwayDirection()
	clearGMFunctions()
	addGMFunction("-Spawn Away",setSpawnLocationAway)
	local GMSetFleetSpawnLocationAwayDirectionRandom = "Random"
	if fleetSpawnAwayDirection == "Random" then
		GMSetFleetSpawnLocationAwayDirectionRandom = "Random*"
	end
	addGMFunction(GMSetFleetSpawnLocationAwayDirectionRandom,function()
		fleetSpawnAwayDirection = "Random"
		setFleetSpawnAwayDirection()
	end)
	local GMSetFleetSpawnLocationAwayDirection0 = "0"
	if fleetSpawnAwayDirection == 0 then
		GMSetFleetSpawnLocationAwayDirection0 = "0*"
	end
	addGMFunction(GMSetFleetSpawnLocationAwayDirection0,function()
		fleetSpawnAwayDirection = 0
		setFleetSpawnAwayDirection()
	end)
	local GMSetFleetSpawnLocationAwayDirection45 = "45"
	if fleetSpawnAwayDirection == 45 then
		GMSetFleetSpawnLocationAwayDirection45 = "45*"
	end
	addGMFunction(GMSetFleetSpawnLocationAwayDirection45,function()
		fleetSpawnAwayDirection = 45
		setFleetSpawnAwayDirection()
	end)
	local GMSetFleetSpawnLocationAwayDirection90 = "90"
	if fleetSpawnAwayDirection == 90 then
		GMSetFleetSpawnLocationAwayDirection90 = "90*"
	end
	addGMFunction(GMSetFleetSpawnLocationAwayDirection90,function()
		fleetSpawnAwayDirection = 90
		setFleetSpawnAwayDirection()
	end)
	local GMSetFleetSpawnLocationAwayDirection135 = "135"
	if fleetSpawnAwayDirection == 135 then
		GMSetFleetSpawnLocationAwayDirection135 = "135*"
	end
	addGMFunction(GMSetFleetSpawnLocationAwayDirection135,function()
		fleetSpawnAwayDirection = 135
		setFleetSpawnAwayDirection()
	end)
	local GMSetFleetSpawnLocationAwayDirection180 = "180"
	if fleetSpawnAwayDirection == 180 then
		GMSetFleetSpawnLocationAwayDirection180 = "180*"
	end
	addGMFunction(GMSetFleetSpawnLocationAwayDirection180,function()
		fleetSpawnAwayDirection = 180
		setFleetSpawnAwayDirection()
	end)
	local GMSetFleetSpawnLocationAwayDirection225 = "225"
	if fleetSpawnAwayDirection == 225 then
		GMSetFleetSpawnLocationAwayDirection225 = "225*"
	end
	addGMFunction(GMSetFleetSpawnLocationAwayDirection225,function()
		fleetSpawnAwayDirection = 225
		setFleetSpawnAwayDirection()
	end)
	local GMSetFleetSpawnLocationAwayDirection270 = "270"
	if fleetSpawnAwayDirection == 270 then
		GMSetFleetSpawnLocationAwayDirection270 = "270*"
	end
	addGMFunction(GMSetFleetSpawnLocationAwayDirection270,function()
		fleetSpawnAwayDirection = 270
		setFleetSpawnAwayDirection()
	end)
	local GMSetFleetSpawnLocationAwayDirection315 = "315"
	if fleetSpawnAwayDirection == 315 then
		GMSetFleetSpawnLocationAwayDirection315 = "315*"
	end
	addGMFunction(GMSetFleetSpawnLocationAwayDirection315,function()
		fleetSpawnAwayDirection = 315
		setFleetSpawnAwayDirection()
	end)
end
function setFleetSpawnAwayDistance()
	clearGMFunctions()
	addGMFunction("-Spawn Away",setSpawnLocationAway)
	local GMSetFleetSpawnLocationAwayDistance5 = "5U"
	if fleetSpawnAwayDistance == 5 then
		GMSetFleetSpawnLocationAwayDistance5 = "5U*"
	end
	addGMFunction(GMSetFleetSpawnLocationAwayDistance5,function()
		fleetSpawnAwayDistance = 5
		setFleetSpawnAwayDistance()
	end)
	local GMSetFleetSpawnLocationAwayDistance10 = "10U"
	if fleetSpawnAwayDistance == 10 then
		GMSetFleetSpawnLocationAwayDistance10 = "10U*"
	end
	addGMFunction(GMSetFleetSpawnLocationAwayDistance10,function()
		fleetSpawnAwayDistance = 10
		setFleetSpawnAwayDistance()
	end)
	local GMSetFleetSpawnLocationAwayDistance20 = "20U"
	if fleetSpawnAwayDistance == 20 then
		GMSetFleetSpawnLocationAwayDistance20 = "20U*"
	end
	addGMFunction(GMSetFleetSpawnLocationAwayDistance20,function()
		fleetSpawnAwayDistance = 20
		setFleetSpawnAwayDistance()
	end)
	local GMSetFleetSpawnLocationAwayDistance30 = "30U"
	if fleetSpawnAwayDistance == 30 then
		GMSetFleetSpawnLocationAwayDistance30 = "30U*"
	end
	addGMFunction(GMSetFleetSpawnLocationAwayDistance30,function()
		fleetSpawnAwayDistance = 30
		setFleetSpawnAwayDistance()
	end)
	local GMSetFleetSpawnLocationAwayDistance40 = "40U"
	if fleetSpawnAwayDistance == 40 then
		GMSetFleetSpawnLocationAwayDistance40 = "40U*"
	end
	addGMFunction(GMSetFleetSpawnLocationAwayDistance40,function()
		fleetSpawnAwayDistance = 40
		setFleetSpawnAwayDistance()
	end)
	local GMSetFleetSpawnLocationAwayDistance50 = "50U"
	if fleetSpawnAwayDistance == 50 then
		GMSetFleetSpawnLocationAwayDistance50 = "50U*"
	end
	addGMFunction(GMSetFleetSpawnLocationAwayDistance50,function()
		fleetSpawnAwayDistance = 50
		setFleetSpawnAwayDistance()
	end)
	local GMSetFleetSpawnLocationAwayDistance60 = "60U"
	if fleetSpawnAwayDistance == 60 then
		GMSetFleetSpawnLocationAwayDistance60 = "60U*"
	end
	addGMFunction(GMSetFleetSpawnLocationAwayDistance60,function()
		fleetSpawnAwayDistance = 60
		setFleetSpawnAwayDistance()
	end)
end
--Spawn fleet based on parameters
function centerOfSelected(objectList)
	local xSum = 0
	local ySum = 0
	for i=1,#objectList do
		local x, y = objectList[i]:getPosition()
		xSum = xSum + x
		ySum = ySum + y
	end
	local fsx = xSum/#objectList
	local fsy = ySum/#objectList
	return fsx, fsy
end
function parmSpawnFleet()
	local fsx = 0
	local fsy = 0
	local objectList = getGMSelection()
	if #objectList < 1 then
		addGMMessage("Fleet spawn failed: nothing selected for spawn location determination")
		return
	end
	if fleetSpawnLocation == "At Selection" then
		fsx, fsy = centerOfSelected(objectList)
	elseif fleetSpawnLocation == "Sensor Edge" or fleetSpawnLocation == "Beyond Sensors" or fleetSpawnLocation == "Ambush" then
		local selectedMatchesPlayer = false
		for i=1,#objectList do
			local curSelObj = objectList[i]
			for pidx=1,8 do
				local p = getPlayerShip(pidx)
				if p ~= nil and p:isValid() then
					if p == curSelObj then
						selectedMatchesPlayer = true
						fsx, fsy = p:getPosition()
						break
					end
				end
			end
			if selectedMatchesPlayer then
				break
			end
		end
		if selectedMatchesPlayer then
			local spawnAngle = fleetSpawnRelativeDirection
			if fleetSpawnRelativeDirection == "Random Direction" then
				spawnAngle = random(0,360)
			else
				spawnAngle = spawnAngle + 270
				if spawnAngle > 360 then 
					spawnAngle = spawnAngle - 360
				end
			end
			if fleetSpawnLocation ~= "Ambush" then
				local tvx = 0
				local tvy = 0
				if fleetSpawnLocation == "Sensor Edge" then
					tvx, tvy = vectorFromAngle(spawnAngle,getLongRangeRadarRange())
				else	--beyond sensors
					tvx, tvy = vectorFromAngle(spawnAngle,getLongRangeRadarRange() + 10000)
				end
				fsx = fsx + tvx
				fsy = fsy + tvy
			end
		else
			addGMMessage("Fleet spawn failed: no valid player ship found amongst selected items")
			return
		end
	elseif string.find(fleetSpawnLocation,"Away") then
		fsx, fsy = centerOfSelected(objectList)
		spawnAngle = fleetSpawnAwayDirection
		if fleetSpawnAwayDirection == "Random" then
			spawnAngle = random(0,360)
		else
			spawnAngle = spawnAngle + 270
			if spawnAngle > 360 then 
				spawnAngle = spawnAngle - 360
			end
		end
		tvx, tvy = vectorFromAngle(spawnAngle,fleetSpawnAwayDistance*1000)
		fsx = fsx + tvx
		fsy = fsy + tvy
	end
	local sl = stsl	--default to full lists (Random)
	local nl = stnl	
	local bl = stbl
	if fleetComposition == "Frigates" then
		sl = stslFrigate
		nl = stnlFrigate
		bl = stblFrigate
	elseif fleetComposition == "Chasers" then
		sl = stslChaser
		nl = stnlChaser
		bl = stblChaser
	elseif fleetComposition == "Fighters" then
		sl = stslFighter
		nl = stnlFighter
		bl = stblFighter
	elseif fleetComposition == "Beamers" then
		sl = stslBeamer
		nl = stnlBeamer
		bl = stblBeamer
	elseif fleetComposition == "Missilers" then
		sl = stslMissiler
		nl = stnlMissiler
		bl = stblMissiler
	elseif fleetComposition == "Adders" then
		sl = stslAdder
		nl = stnlAdder
		bl = stblAdder
	elseif fleetComposition == "Non-DB" then
		sl = stslNonDB
		nl = stnlNonDB
		bl = stblNonDB
	end
	local fleet = nil
	if fleetSpawnLocation == "Ambush" then
		fleet = spawnRandomArmed(fsx, fsy, #fleetList + 1, sl, nl, bl, fleetAmbushDistance, spawnAngle)
	else
		fleet = spawnRandomArmed(fsx, fsy, #fleetList + 1, sl, nl, bl)
	end
	table.insert(fleetList,fleet)
end
function spawnRandomArmed(x, y, fleetIndex, sl, nl, bl, ambush_distance, spawn_angle)
--x and y are central spawn coordinates
--fleetIndex is the number of the fleet to be spawned
--sl is the score list, nl is the name list
--ambush_distance optional - used for ambush
--spawn_angle optional - used for ambush
	local weakestEnemy = 500
	for i=1,#sl do
		local weakCandidate = sl[i]
		if weakCandidate < weakestEnemy then
			weakestEnemy = weakCandidate
		end
	end
	if weakestEnemy > playerPower()*fleetStrengthByPlayerStrength then
		return
	end
	local enemyStrength = math.max(fleetStrengthByPlayerStrength * playerPower(),5)
	if fleetStrengthFixed then
		enemyStrength = fleetStrengthFixedValue
	end
	local enemyPosition = 0
	local sp = irandom(500,1000)			--random spacing of spawned group
	local deployConfig = random(1,100)	--randomly choose between squarish formation and hexagonish formation
	local enemyList = {}
	while enemyStrength > 0 do
		local shipTemplateType = math.random(1,#sl)
		local loopLimit = 100
		local loopCount = 0
		local shipScore = sl[shipTemplateType]
		while sl[shipTemplateType] > enemyStrength * 1.1 + 5 and loopCount < loopLimit do
			shipTemplateType = math.random(1,#sl)
			loopCount = loopCount + 1
		end
		local shipName = nl[shipTemplateType]
		--print(string.format("ship name: %s, ship template type: %s",shipName,shipTemplateType))
		local ship = nil
		if bl[shipTemplateType] then
			ship = CpuShip():setFaction(fleetSpawnFaction):setTemplate(shipName)
		else
			local nsfl_index = 0
			for i=1,#nsfl do
				if stnl[i] == shipName then
					nsfl_index = i
					break
				end
			end
			if nsfl_index > 0 then
				ship = nsfl[nsfl_index](fleetSpawnFaction)
			end
			--ship = nsfl[shipTemplateType](fleetSpawnFaction)
		end
		ship:setCommsScript(""):setCommsFunction(commsShip):orderRoaming()
		if fleetOrders == "Roaming" then
			ship:orderRoaming()
		elseif fleetOrders == "Idle" then
			ship:orderIdle()
		elseif fleetOrders == "Stand Ground" then
			ship:orderStandGround()
		end
		enemyPosition = enemyPosition + 1
		if deployConfig < 50 then
			ship:setPosition(x+fleetPosDelta1x[enemyPosition]*sp,y+fleetPosDelta1y[enemyPosition]*sp)
		else
			ship:setPosition(x+fleetPosDelta2x[enemyPosition]*sp,y+fleetPosDelta2y[enemyPosition]*sp)
		end
		ship.fleetIndex = fleetIndex
		if fleetChange ~= "unmodified" then
			local modVal = modifiedValue()
			if modVal ~= 1 then
				ship:setHullMax(ship:getHullMax()*modVal)
				ship:setHull(ship:getHullMax())
			end
			modVal = modifiedValue()
			if modVal ~= 1 then
				local shieldCount = ship:getShieldCount()
				if shieldCount > 0 then
					if shieldCount == 1 then
						ship:setShieldsMax(ship:getShieldMax(0)*modVal)
						ship:setShields(ship:getShieldMax(0))
					elseif shieldCount == 2 then
						ship:setShieldsMax(ship:getShieldMax(0)*modVal,ship:getShieldMax(1)*modVal)
						ship:setShields(ship:getShieldMax(0),ship:getShieldMax(1))
					elseif shieldCount == 3 then
						ship:setShieldsMax(ship:getShieldMax(0)*modVal,ship:getShieldMax(1)*modVal,ship:getShieldMax(2)*modVal)
						ship:setShields(ship:getShieldMax(0),ship:getShieldMax(1),ship:getShieldMax(2))
					elseif shieldCount == 4 then
						ship:setShieldsMax(ship:getShieldMax(0)*modVal,ship:getShieldMax(1)*modVal,ship:getShieldMax(2)*modVal,ship:getShieldMax(3)*modVal)
						ship:setShields(ship:getShieldMax(0),ship:getShieldMax(1),ship:getShieldMax(2),ship:getShieldMax(3))
					elseif shieldCount == 5 then
						ship:setShieldsMax(ship:getShieldMax(0)*modVal,ship:getShieldMax(1)*modVal,ship:getShieldMax(2)*modVal,ship:getShieldMax(3)*modVal,ship:getShieldMax(4)*modVal)
						ship:setShields(ship:getShieldMax(0),ship:getShieldMax(1),ship:getShieldMax(2),ship:getShieldMax(3),ship:getShieldMax(4))
					elseif shieldCount == 6 then
						ship:setShieldsMax(ship:getShieldMax(0)*modVal,ship:getShieldMax(1)*modVal,ship:getShieldMax(2)*modVal,ship:getShieldMax(3)*modVal,ship:getShieldMax(4)*modVal,ship:getShieldMax(5)*modVal)
						ship:setShields(ship:getShieldMax(0),ship:getShieldMax(1),ship:getShieldMax(2),ship:getShieldMax(3),ship:getShieldMax(4),ship:getShieldMax(5))
					elseif shieldCount == 7 then
						ship:setShieldsMax(ship:getShieldMax(0)*modVal,ship:getShieldMax(1)*modVal,ship:getShieldMax(2)*modVal,ship:getShieldMax(3)*modVal,ship:getShieldMax(4)*modVal,ship:getShieldMax(5)*modVal,ship:getShieldMax(6)*modVal)
						ship:setShields(ship:getShieldMax(0),ship:getShieldMax(1),ship:getShieldMax(2),ship:getShieldMax(3),ship:getShieldMax(4),ship:getShieldMax(5),ship:getShieldMax(6))
					elseif shieldCount == 8 then
						ship:setShieldsMax(ship:getShieldMax(0)*modVal,ship:getShieldMax(1)*modVal,ship:getShieldMax(2)*modVal,ship:getShieldMax(3)*modVal,ship:getShieldMax(4)*modVal,ship:getShieldMax(5)*modVal,ship:getShieldMax(6)*modVal,ship:getShieldMax(7)*modVal)
						ship:setShields(ship:getShieldMax(0),ship:getShieldMax(1),ship:getShieldMax(2),ship:getShieldMax(3),ship:getShieldMax(4),ship:getShieldMax(5),ship:getShieldMax(6),ship:getShieldMax(7))
					end
				end
			end
			local maxNuke = ship:getWeaponStorageMax("Nuke")
			if maxNuke > 0 then
				modVal = modifiedValue()
				if modVal ~= 1 then
					if modVal > 1 then
						ship:setWeaponStorageMax("Nuke",math.ceil(maxNuke*modVal))
					else
						ship:setWeaponStorageMax("Nuke",math.floor(maxNuke*modVal))
					end
					ship:setWeaponStorage("Nuke",ship:getWeaponStorageMax("Nuke"))
				end
			end
			local maxEMP = ship:getWeaponStorageMax("EMP")
			if maxEMP > 0 then
				modVal = modifiedValue()
				if modVal ~= 1 then
					if modVal > 1 then
						ship:setWeaponStorageMax("EMP",math.ceil(maxEMP*modVal))
					else
						ship:setWeaponStorageMax("EMP",math.floor(maxEMP*modVal))
					end
					ship:setWeaponStorage("EMP",ship:getWeaponStorageMax("EMP"))
				end
			end
			local maxMine = ship:getWeaponStorageMax("Mine")
			if maxMine > 0 then
				modVal = modifiedValue()
				if modVal ~= 1 then
					if modVal > 1 then
						ship:setWeaponStorageMax("Mine",math.ceil(maxMine*modVal))
					else
						ship:setWeaponStorageMax("Mine",math.floor(maxMine*modVal))
					end
					ship:setWeaponStorage("Mine",ship:getWeaponStorageMax("Mine"))
				end
			end
			local maxHoming = ship:getWeaponStorageMax("Homing")
			if maxHoming > 0 then
				modVal = modifiedValue()
				if modVal ~= 1 then
					if modVal > 1 then
						ship:setWeaponStorageMax("Homing",math.ceil(maxHoming*modVal))
					else
						ship:setWeaponStorageMax("Homing",math.floor(maxHoming*modVal))
					end
					ship:setWeaponStorage("Homing",ship:getWeaponStorageMax("Homing"))
				end
			end
			local maxHVLI = ship:getWeaponStorageMax("HVLI")
			if maxHVLI > 0 then
				modVal = modifiedValue()
				if modVal ~= 1 then
					if modVal > 1 then
						maxHVLI = math.ceil(maxHVLI*modVal)
					else
						maxHVLI = math.floor(maxHVLI*modVal)
					end
					ship:setWeaponStorageMax("HVLI",maxHVLI)
					ship:setWeaponStorage("HVLI",maxHVLI)
				end
			end
			modVal = modifiedValue()
			if modVal ~= 1 then
				ship:setImpulseMaxSpeed(ship:getImpulseMaxSpeed()*modVal)
			end
			modVal = modifiedValue()
			if modVal ~= 1 then
				ship:setRotationMaxSpeed(ship:getRotationMaxSpeed()*modVal)
			end
			if ship:getBeamWeaponRange(0) > 0 then
				local beamIndex = 0
				local modArc = modifiedValue()
				local modDirection = modifiedValue()
				local modRange = modifiedValue()
				local modCycle = 1/modifiedValue()
				local modDamage = modifiedValue()
				local modEnergy = 1/modifiedValue()
				local modHeat = 1/modifiedValue()
				repeat
					local beamArc = ship:getBeamWeaponArc(beamIndex)
					local beamDirection = ship:getBeamWeaponDirection(beamIndex)
					local beamRange = ship:getBeamWeaponRange(beamIndex)
					local beamCycle = ship:getBeamWeaponCycleTime(beamIndex)
					local beamDamage = ship:getBeamWeaponDamage(beamIndex)
					ship:setBeamWeapon(beamIndex,beamArc*modArc,beamDirection*modDirection,beamRange*modRange,beamCycle*modCycle,beamDamage*modDamage)
					ship:setBeamWeaponEnergyPerFire(beamIndex,ship:getBeamWeaponEnergyPerFire(beamIndex)*modEnergy)
					ship:setBeamWeaponHeatPerFire(beamIndex,ship:getBeamWeaponHeatPerFire(beamIndex)*modHeat)
					beamIndex = beamIndex + 1
				until(ship:getBeamWeaponRange(beamIndex) < 1)
			end
		end
		table.insert(enemyList, ship)
		enemyStrength = enemyStrength - sl[shipTemplateType]
	end
	if ambush_distance ~= nil then
		if spawn_angle == nil then
			spawn_angle = random(0,360)
		end
		local circle_increment = 360/#enemyList
		for _, enemy in ipairs(enemyList) do
			local dex, dey = vectorFromAngle(spawn_angle,ambush_distance*1000)
			enemy:setPosition(x+dex,y+dey)
			spawn_angle = spawn_angle + circle_increment
		end
	end
	return enemyList
end
function modifiedValue()
	local modChance = random(1,100)
	local modValue = 1
	if fleetChange == "improved" then
		if modChance <= fleetChangeChance then
			modValue = modValue + random(10,25)/100
		end
	elseif fleetChange == "degraded" then
		if modChance <= fleetChangeChance then
			modValue = modValue - random(10,25)/100
		end
	else	--tinkered
		if modChance <= fleetChangeChance then
			if random(1,100) <= 50 then
				modValue = modValue + random(10,25)/100
			else
				modValue = modValue - random(10,25)/100
			end
		end
	end
	return modValue
end
--additional enemy ships with some modifications from the original template parameters
function adderMk3(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Adder MK4"):orderRoaming()
	ship:setTypeName("Adder MK3")
	ship:setHullMax(35)		--weaker hull (vs 40)
	ship:setHull(35)
	ship:setShieldsMax(15)	--weaker shield (vs 20)
	ship:setShields(15)
	ship:setRotationMaxSpeed(35)	--faster maneuver (vs 20)
	return ship
end
function adderMk7(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Adder MK6"):orderRoaming()
	ship:setTypeName("Adder MK7")
	ship:setShieldsMax(40)	--stronger shields (vs 30)
	ship:setShields(40)
	ship:setBeamWeapon(0,30,0,900,5.0,2.0)	--narrower (30 vs 35) but longer (900 vs 800) beam
	return ship
end
function adderMk8(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Adder MK5"):orderRoaming()
	ship:setTypeName("Adder MK8")
	ship:setShieldsMax(50)					--stronger shields (vs 30)
	ship:setShields(50)
	ship:setBeamWeapon(0,30,0,900,5.0,2.3)	--narrower (30 vs 35) but longer (900 vs 800) and stronger (2.3 vs 2.0) beam
	ship:setRotationMaxSpeed(30)			--faster maneuver (vs 25)
	return ship
end
function adderMk9(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Adder MK5"):orderRoaming()
	ship:setTypeName("Adder MK9")
	ship:setShieldsMax(50)					--stronger shields (vs 30)
	ship:setShields(50)
	ship:setBeamWeapon(0,30,0,900,4.5,2.5)	--narrower (30 vs 35) but longer (900 vs 800), faster (4.5 vs 5.0) and stronger (2.5 vs 2.0) beam
	ship:setRotationMaxSpeed(30)			--faster maneuver (vs 25)
	ship:setWeaponStorageMax("Nuke",2)		--more nukes (vs 0)
	ship:setWeaponStorage("Nuke",2)
	return ship
end
function phobosR2(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Phobos T3"):orderRoaming()
	ship:setTypeName("Phobos R2")
	ship:setWeaponTubeCount(1)			--one tube (vs 2)
	ship:setWeaponTubeDirection(0,0)	
	ship:setImpulseMaxSpeed(55)			--slower impulse (vs 60)
	ship:setRotationMaxSpeed(15)		--faster maneuver (vs 10)
	return ship
end
function hornetMV52(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("MT52 Hornet"):orderRoaming()
	ship:setTypeName("MV52 Hornet")
	ship:setBeamWeapon(0, 30, 0, 1000.0, 4.0, 3.0)	--longer and stronger beam (vs 700 & 3)
	ship:setRotationMaxSpeed(30)					--faster maneuver (vs 25)
	ship:setImpulseMaxSpeed(130)					--faster impulse (vs 120)
	return ship
end
function nirvanaR3(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Nirvana R5"):orderRoaming()
	ship:setTypeName("Nirvana R3")
	ship:setBeamWeapon(0, 90, -15, 1000.0, 3, 1)	--shorter beams (vs 1200)
	ship:setBeamWeapon(1, 90,  15, 1000.0, 3, 1)	--shorter beams
	ship:setBeamWeapon(2, 90, -50, 1000.0, 3, 1)	--shorter beams
	ship:setBeamWeapon(3, 90,  50, 1000.0, 3, 1)	--shorter beams
	ship:setHullMax(60)								--weaker hull (vs 70)
	ship:setHull(60)
	ship:setShields(40,30)							--weaker shields (vs 50,40)
	ship:setImpulseMaxSpeed(65)						--slower impulse (vs 70)
	return ship
end
function fiendG3(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Gunship"):orderRoaming()
	ship:setTypeName("Fiend G3")
	ship:setJumpDrive(true)
	ship:setJumpDriveRange(5000,35000)			
	return ship
end
function fiendG4(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Gunship"):orderRoaming()
	ship:setTypeName("Fiend G4")
	ship:setWarpDrive(true)
	return ship
end
function fiendG5(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Adv. Gunship"):orderRoaming()
	ship:setTypeName("Fiend G5")
	ship:setJumpDrive(true)
	ship:setJumpDriveRange(5000,35000)			
	return ship
end
function fiendG6(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Adv. Gunship"):orderRoaming()
	ship:setTypeName("Fiend G6")
	ship:setWarpDrive(true)
	return ship
end
function k2fighter(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Ktlitan Fighter"):orderRoaming()
	ship:setTypeName("K2 Fighter")
	ship:setBeamWeapon(0, 60, 0, 1200.0, 2.5, 6)	--beams cycle faster (vs 4.0)
	ship:setHullMax(65)								--weaker hull (vs 70)
	ship:setHull(65)
	return ship
end	
function k3fighter(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Ktlitan Fighter"):orderRoaming()
	ship:setTypeName("K3 Fighter")
	ship:setBeamWeapon(0, 60, 0, 1200.0, 2.5, 9)	--beams cycle faster and damage more (vs 4.0 & 6)
	ship:setHullMax(60)								--weaker hull (vs 70)
	ship:setHull(60)
	return ship
end	
-------------------
--	Order fleet  --
-------------------
function orderFleet()
	clearGMFunctions()
	addGMFunction("-Main from Order Flt",initialGMFunctions)
	addGMFunction(string.format("+%s",existing_fleet_order),changeFleetOrder)
	local select_fleet_label = "Select Fleet"
	if selected_fleet_representative ~= nil and selected_fleet_representative:isValid() then
		if selected_fleet_index ~= nil and fleetList[selected_fleet_index] ~= nil then
			local fl = fleetList[selected_fleet_index]
			if fl ~= nil then
				if selected_fleet_representative_index ~= nil then
					if selected_fleet_representative == fl[selected_fleet_representative_index] then
						select_fleet_label = string.format("%i %s",selected_fleet_index,selected_fleet_representative:getCallSign())
					end
				end
			end
		end
	end
	addGMFunction(string.format("+%s",select_fleet_label),selectOrderFleet)
	if select_fleet_label ~= "Select Fleet" then
		addGMFunction("Give Order To Fleet",function()
			if existing_fleet_order == "Idle" then
				for _, fm in pairs(fleetList[selected_fleet_index]) do
					if fm ~= nil and fm:isValid() then
						fm:orderIdle()
					end
				end
				addGMMessage(string.format("Fleet %i which includes %s has been ordered to go idle",selected_fleet_index,selected_fleet_representative:getCallSign()))
			end
			if existing_fleet_order == "Roaming" then
				for _, fm in pairs(fleetList[selected_fleet_index]) do
					if fm ~= nil and fm:isValid() then
						fm:orderRoaming()
					end
				end	
				addGMMessage(string.format("Fleet %i which includes %s has been ordered to roam",selected_fleet_index,selected_fleet_representative:getCallSign()))
			end			
			if existing_fleet_order == "Stand Ground" then
				for _, fm in pairs(fleetList[selected_fleet_index]) do
					if fm ~= nil and fm:isValid() then
						fm:orderStandGround()
					end
				end	
			end			
			if existing_fleet_order == "Attack" then
				local objectList = getGMSelection()
				if #objectList ~= 1 then
					addGMMessage("Need to select a target for fleet to attack")
				else
					local fto = fleetList[selected_fleet_index]
					for _, fm in pairs(fto) do
						if fm ~= nil and fm:isValid() then
							fm:orderAttack(objectList[1])
						end
					end
					addGMMessage(string.format("Fleet %i which includes %s has been ordered to attack",selected_fleet_index,selected_fleet_representative:getCallSign()))		
				end
			end			
			if existing_fleet_order == "Defend" then
				local objectList = getGMSelection()
				if #objectList ~= 1 then
					addGMMessage("Need to select a target for fleet to defend")
				else
					local fto = fleetList[selected_fleet_index]
					for _, fm in pairs(fto) do
						if fm ~= nil and fm:isValid() then
							fm:orderDefendTarget(objectList[1])
						end
					end
					addGMMessage(string.format("Fleet %i which includes %s has been ordered to defend",selected_fleet_index,selected_fleet_representative:getCallSign()))
				end
			end			
			if existing_fleet_order == "Fly To" then
				local flyx = 0
				local flyy = 0
				local objectList = getGMSelection()
				if #objectList < 1 then
					addGMMessage("Need to select a target for fleet to fly to")
				else
					if #objectList == 1 then
						flyx, flyy = objectList[1]:getPosition()
					else
						flyx, flyy = centerOfSelected(objectList)
					end
					local fto = fleetList[selected_fleet_index]
					for _, fm in pairs(fto) do
						if fm ~= nil and fm:isValid() then
							fm:orderFlyTowards(flyx,flyy)
						end
					end
					addGMMessage(string.format("Fleet %i which includes %s has been ordered to fly towards %.1f, %.1f",selected_fleet_index,selected_fleet_representative:getCallSign(),flyx,flyy))
				end
			end			
			if existing_fleet_order == "Fly Blindly To" then
				local flyx = 0
				local flyy = 0
				local objectList = getGMSelection()
				if #objectList < 1 then
					addGMMessage("Need to select a target for fleet to fly blindly to")
				else
					if #objectList == 1 then
						flyx, flyy = objectList[1]:getPosition()
					else
						flyx, flyy = centerOfSelected(objectList)
					end
					local fto = fleetList[selected_fleet_index]
					for _, fm in pairs(fto) do
						if fm ~= nil and fm:isValid() then
							fm:orderFlyTowardsBlind(flyx,flyy)
						end
					end
					addGMMessage(string.format("Fleet %i which includes %s has been ordered to fly blindly towards %.1f, %.1f",selected_fleet_index,selected_fleet_representative:getCallSign(),flyx,flyy))
				end
			end
			if existing_fleet_order == "Dock" then
				local objectList = getGMSelection()
				if #objectList ~= 1 then
					addGMMessage("Need to select a target for fleet to dock")
				else
					local fto = fleetList[selected_fleet_index]
					for _, fm in pairs(fto) do
						if fm ~= nil and fm:isValid() then
							fm:orderDock(objectList[1])
						end
					end
					addGMMessage(string.format("Fleet %i which includes %s has been ordered to dock",selected_fleet_index,selected_fleet_representative:getCallSign()))
				end
			end
			if existing_fleet_order == "Fly Formation" then
				addGMMessage("Fly Formation has not yet been implemented. Choose a different order. No action taken")
			end
		end)
	end
	
--	addGMFunction("Idle",orderFleetIdle)
--	addGMFunction("Roaming",orderFleetRoaming)
--	addGMFunction("Stand Ground",orderFleetStandGround)
--	addGMFunction("Attack",orderFleetAttack)
--	addGMFunction("Defend",orderFleetDefend)
--	addGMFunction("Fly To",orderFleetFly)
--	addGMFunction("Fly Blindly To",orderFleetFlyBlind)
--	addGMFunction("Dock",orderFleetDock)
--	addGMFunction("Fly Formation",orderFleetFlyFormation)
	addGMFunction("+Reorganize Fleet",orderFleetChange)
end
function selectOrderFleet()
	clearGMFunctions()
	addGMFunction("-Order Fleet",orderFleet)
	for i=1,8 do
		local fl = fleetList[i]
		if fl ~= nil then
			local sample_name = ""
			local fleet_member = nil
			local member_index = 0
			for j=1,#fl do
				fleet_member = fl[j]
				member_index = j
				if fleet_member ~= nil and fleet_member:isValid() then
					sample_name = fleet_member:getCallSign()
					break
				end
			end
			addGMFunction(string.format("%i %s",i,sample_name),function()
				selected_fleet_representative = fleet_member
				selected_fleet_index = i
				selected_fleet_representative_index = member_index
				orderFleet()
			end)
		end
	end
end
function changeFleetOrder()
	clearGMFunctions()
	--addGMFunction("-Order Fleet",orderFleet)
	local order_roaming = "Roaming"
	if existing_fleet_order == "Roaming" then
		order_roaming = "Roaming*"
	end
	addGMFunction(order_roaming,function()
		existing_fleet_order = "Roaming"
		orderFleet()
	end)
	local order_idle = "Idle"
	if existing_fleet_order == "Idle" then
		order_idle = "Idle*"
	end
	addGMFunction(order_idle,function()
		existing_fleet_order = "Idle"
		orderFleet()
	end)
	local order_stand_ground = "Stand Ground"
	if existing_fleet_order == "Stand Ground" then
		order_stand_ground = "Stand Ground*"
	end
	addGMFunction(order_stand_ground,function()
		existing_fleet_order = "Stand Ground"
		orderFleet()
	end)
	local order_attack = "Attack"
	if existing_fleet_order == "Attack" then
		order_attack = "Attack*"
	end
	addGMFunction(order_attack,function()
		existing_fleet_order = "Attack"
		orderFleet()
	end)
	local order_defend = "Defend"
	if existing_fleet_order == "Defend" then
		order_defend = "Defend*"
	end
	addGMFunction(order_defend,function()
		existing_fleet_order = "Defend"
		orderFleet()
	end)
	local order_fly_to = "Fly To"
	if existing_fleet_order == "Fly To" then
		order_fly_to = "Fly To*"
	end
	addGMFunction(order_fly_to,function()
		existing_fleet_order = "Fly To"
		orderFleet()
	end)
	local order_fly_blindly_to = "Fly Blindly To"
	if existing_fleet_order == "Fly Blindly To" then
		order_fly_blindly_to = "Fly Blindly To*"
	end
	addGMFunction(order_fly_blindly_to,function()
		existing_fleet_order = "Fly Blindly To"
		orderFleet()
	end)
	local order_dock = "Dock"
	if existing_fleet_order == "Dock" then
		order_dock = "Dock*"
	end
	addGMFunction(order_dock,function()
		existing_fleet_order = "Dock"
		orderFleet()
	end)
	--[[
	local order_fly_formation = "Fly Formation"
	if existing_fleet_order == "Fly Formation" then
		order_fly_formation = "Fly Formation*"
	end
	addGMFunction(string.format("+%s",order_fly_formation),flyFormationParameters)
	--]]
end
function flyFormationParameters()
	existing_fleet_order = "Fly Formation"
	if formation_type == nil then
		formation_type = "V"
	end
	if formation_lead == nil then
		formation_lead = selected_fleet_representative
		formation_lead_index = selected_fleet_representative_index
	end
	clearGMFunctions()
	addGMFunction("-Main",initialGMFunctions)
	addGMFunction("-Order Fleet",orderFleet)
	addGMFunction(string.format("Formation %s",formation_type),changeFormation)
	addGMFunction(string.format("Lead %s",formation_lead:getCallSign()),changeFormationLead)
end
function changeFormation()
	clearGMFunctions()
	local formation_v = "V"
	if formation_type == "V" then
		formation_v = "V*"
	end
	addGMFunction(string.format("Formation %s",formation_v),function()
		formation_type = "V"
		flyFormationParameters()
	end)
	local formation_a = "A"
	if formation_type == "A" then
		formation_a = "A*"
	end
	addGMFunction(string.format("Formation %s",formation_a),function()
		formation_type = "A"
		flyFormationParameters()
	end)
	local formation_circle = "circle"
	if formation_type == "circle" then
		formation_circle = "circle*"
	end
	addGMFunction(string.format("Formation %s",formation_circle),function()
		formation_type = "circle"
		flyFormationParameters()
	end)
	local formation_square = "square"
	if formation_type == "square" then
		formation_square = "square*"
	end
	addGMFunction(string.format("Formation %s",formation_square),function()
		formation_type = "square"
		flyFormationParameters()
	end)
end
function changeFormationLead()
	clearGMFunctions()
	if fleetList ~= nil and #fleetList > 0 then
		if selected_fleet_index ~= nil and selected_fleet_index > 0 then
			local fl = fleetList[selected_fleet_index]
			if fl ~= nil then
				local fleet_member = nil
				local fleet_member_count = 0
				--local member_index = 0
				for j=1,#fl do
					fleet_member = fl[j]
					--member_index = j
					if fleet_member ~= nil and fleet_member:isValid() then
						fleet_member_count = fleet_member_count + 1
						addGMFunction(fleet_member:getCallSign(),function()
							formation_lead = fleet_member
							flyFormationParameters()
						end)
					end
				end
				if fleet_member_count < 1 then
					addGMMessage("No valid members in selected fleet")
				end
			else
				addGMMessage("selected fleet is nil")
			end
		else
			addGMMessage("No selected fleet")
		end
	else
		addGMMessage("No fleets spawned")
	end
end
function orderFleetFlyFormation()
	clearGMFunctions()
	addGMFunction("-Main",initialGMFunctions)
	addGMFunction("-Order Fleet",orderFleet)
	addGMMessage("incomplete function. Need to complete later")
end
--New Fleet
function orderFleetChange()
	clearGMFunctions()
	addGMFunction("-Main",initialGMFunctions)
	addGMFunction("-From Reorg Flt",orderFleet)
	local object_list = getGMSelection()
	local cpu_ship_count = 0
	local cpu_ship_faction = nil
	local factions_match = true
	local new_fleet = {}
	for i=1,#object_list do
		local current_selected_object = object_list[i]
		if current_selected_object.typeName == "CpuShip" then
			cpu_ship_count = cpu_ship_count + 1
			local current_faction = current_selected_object:getFaction()
			if cpu_ship_faction == nil then
				cpu_ship_faction = current_faction
			else
				if current_faction ~= cpu_ship_faction then
					factions_match = false
				end
			end
			table.insert(new_fleet,current_selected_object)
		end
	end
	if cpu_ship_count < 1 then
		addGMMessage("no ships selected")
	elseif not factions_match then
		addGMMessage("Ships selected are not all the same faction")
	end
	addGMMessage("incomplete function. Need to complete later")
end
--Order fleet to be idle - do nothing
function orderFleetIdle()
	clearGMFunctions()
	addGMFunction("-Main from Ord Idle",initialGMFunctions)
	addGMFunction("-Order Fleet",orderFleet)
	for i=1,8 do
		local fl = fleetList[i]
		if fl ~= nil then
			local sampleName = ""
			for j=1,#fl do
				local fm = fl[j]
				if fm ~= nil and fm:isValid() then
					sampleName = fm:getCallSign()
					break
				end
			end
			local GMOrderFleetIdle = string.format("%i %s",i,sampleName)
			addGMFunction(GMOrderFleetIdle,idleFleetFunction[i])
		else
			break
		end
	end
end
function orderFleetIdleGivenFleet(fto)
	for _, fm in pairs(fto) do
		if fm ~= nil and fm:isValid() then
			fm:orderIdle()
		end
	end	
end
function orderFleetIdle1()
	local fto = fleetList[1]
	orderFleetIdleGivenFleet(fto)
end
function orderFleetIdle2()
	local fto = fleetList[2]
	orderFleetIdleGivenFleet(fto)
end
function orderFleetIdle3()
	local fto = fleetList[3]
	orderFleetIdleGivenFleet(fto)
end
function orderFleetIdle4()
	local fto = fleetList[4]
	orderFleetIdleGivenFleet(fto)
end
function orderFleetIdle5()
	local fto = fleetList[5]
	orderFleetIdleGivenFleet(fto)
end
function orderFleetIdle6()
	local fto = fleetList[6]
	orderFleetIdleGivenFleet(fto)
end
function orderFleetIdle7()
	local fto = fleetList[7]
	orderFleetIdleGivenFleet(fto)
end
function orderFleetIdle8()
	local fto = fleetList[8]
	orderFleetIdleGivenFleet(fto)
end
--Order fleet to roam, attack any and all enemies
function orderFleetRoaming()
	clearGMFunctions()
	addGMFunction("-Main from Ord Roam",initialGMFunctions)
	addGMFunction("-Order Fleet",orderFleet)
	for i=1,8 do
		local fl = fleetList[i]
		if fl ~= nil then
			local sampleName = ""
			for j=1,#fl do
				local fm = fl[j]
				if fm ~= nil and fm:isValid() then
					sampleName = fm:getCallSign()
					break
				end
			end
			GMOrderFleetRoaming = string.format("%i %s",i,sampleName)
			addGMFunction(GMOrderFleetRoaming,roamingFleetFunction[i])
		else
			break
		end
	end
end
function orderFleetRoamingGivenFleet(fto)
	for _, fm in pairs(fto) do
		if fm ~= nil and fm:isValid() then
			fm:orderRoaming()	--set fleet member order
		end
	end
end
function orderFleetRoaming1()
	local fto = fleetList[1]	--get fleet to order
	orderFleetRoamingGivenFleet(fto)
end
function orderFleetRoaming2()
	local fto = fleetList[2]	--get fleet to order
	orderFleetRoamingGivenFleet(fto)
end
function orderFleetRoaming3()
	local fto = fleetList[3]	--get fleet to order
	orderFleetRoamingGivenFleet(fto)
end
function orderFleetRoaming4()
	local fto = fleetList[4]	--get fleet to order
	orderFleetRoamingGivenFleet(fto)
end
function orderFleetRoaming5()
	local fto = fleetList[5]	--get fleet to order
	orderFleetRoamingGivenFleet(fto)
end
function orderFleetRoaming6()
	local fto = fleetList[6]	--get fleet to order
	orderFleetRoamingGivenFleet(fto)
end
function orderFleetRoaming7()
	local fto = fleetList[7]	--get fleet to order
	orderFleetRoamingGivenFleet(fto)
end
function orderFleetRoaming8()
	local fto = fleetList[8]	--get fleet to order
	orderFleetRoamingGivenFleet(fto)
end
--Order fleet to stand ground, attacking nearby enemies
function orderFleetStandGround()
	clearGMFunctions()
	addGMFunction("-Main from Ord Stnd",initialGMFunctions)
	addGMFunction("-Order Fleet",orderFleet)
	for i=1,8 do
		local fl = fleetList[i]
		if fl ~= nil then
			local sampleName = ""
			for j=1,#fl do
				local fm = fl[j]
				if fm ~= nil and fm:isValid() then
					sampleName = fm:getCallSign()
					break
				end
			end
			GMOrderFleetStandGround = string.format("%i %s",i,sampleName)
			addGMFunction(GMOrderFleetStandGround,standGroundFleetFunction[i])
		else
			break
		end
	end
end
function orderFleetStandGroundGivenFleet(fto)
	for _, fm in pairs(fto) do
		if fm ~= nil and fm:isValid() then
			fm:orderStandGround()
		end
	end	
end
function orderFleetStandGround1()
	local fto = fleetList[1]
	orderFleetStandGroundGivenFleet(fto)
end
function orderFleetStandGround2()
	local fto = fleetList[2]
	orderFleetStandGroundGivenFleet(fto)
end
function orderFleetStandGround3()
	local fto = fleetList[3]
	orderFleetStandGroundGivenFleet(fto)
end
function orderFleetStandGround4()
	local fto = fleetList[4]
	orderFleetStandGroundGivenFleet(fto)
end
function orderFleetStandGround5()
	local fto = fleetList[5]
	orderFleetStandGroundGivenFleet(fto)
end
function orderFleetStandGround6()
	local fto = fleetList[6]
	orderFleetStandGroundGivenFleet(fto)
end
function orderFleetStandGround7()
	local fto = fleetList[7]
	orderFleetStandGroundGivenFleet(fto)
end
function orderFleetStandGround8()
	local fto = fleetList[8]
	orderFleetStandGroundGivenFleet(fto)
end
--Order fleet to attack GM selected object
function orderFleetAttack()
	clearGMFunctions()
	addGMFunction("-Main from Ord Attk",initialGMFunctions)
	addGMFunction("-Order Fleet",orderFleet)
	for i=1,8 do
		local fl = fleetList[i]
		if fl ~= nil then
			local sampleName = ""
			for j=1,#fl do
				local fm = fl[j]
				if fm ~= nil and fm:isValid() then
					sampleName = fm:getCallSign()
					break
				end
			end
			GMOrderFleetAttack = string.format("%i %s",i,sampleName)
			addGMFunction(GMOrderFleetAttack,attackFleetFunction[i])
		else
			break
		end
	end
end
function orderFleetAttack1()
	local objectList = getGMSelection()
	if #objectList ~= 1 then
		print("Need to select a target for fleet to attack")
		return
	end
	local fto = fleetList[1]
	for _, fm in pairs(fto) do
		if fm ~= nil and fm:isValid() then
			fm:orderAttack(objectList[1])
		end
	end
end
function orderFleetAttack2()
	local objectList = getGMSelection()
	if #objectList ~= 1 then
		print("Need to select a target for fleet to attack")
		return
	end
	local fto = fleetList[2]
	for _, fm in pairs(fto) do
		if fm ~= nil and fm:isValid() then
			fm:orderAttack(objectList[1])
		end
	end
end
function orderFleetAttack3()
	local objectList = getGMSelection()
	if #objectList ~= 1 then
		print("Need to select a target for fleet to attack")
		return
	end
	local fto = fleetList[3]
	for _, fm in pairs(fto) do
		if fm ~= nil and fm:isValid() then
			fm:orderAttack(objectList[1])
		end
	end
end
function orderFleetAttack4()
	local objectList = getGMSelection()
	if #objectList ~= 1 then
		print("Need to select a target for fleet to attack")
		return
	end
	local fto = fleetList[4]
	for _, fm in pairs(fto) do
		if fm ~= nil and fm:isValid() then
			fm:orderAttack(objectList[1])
		end
	end
end
function orderFleetAttack5()
	local objectList = getGMSelection()
	if #objectList ~= 1 then
		print("Need to select a target for fleet to attack")
		return
	end
	local fto = fleetList[5]
	for _, fm in pairs(fto) do
		if fm ~= nil and fm:isValid() then
			fm:orderAttack(objectList[1])
		end
	end
end
function orderFleetAttack6()
	local objectList = getGMSelection()
	if #objectList ~= 1 then
		print("Need to select a target for fleet to attack")
		return
	end
	local fto = fleetList[6]
	for _, fm in pairs(fto) do
		if fm ~= nil and fm:isValid() then
			fm:orderAttack(objectList[1])
		end
	end
end
function orderFleetAttack7()
	local objectList = getGMSelection()
	if #objectList ~= 1 then
		print("Need to select a target for fleet to attack")
		return
	end
	local fto = fleetList[7]
	for _, fm in pairs(fto) do
		if fm ~= nil and fm:isValid() then
			fm:orderAttack(objectList[1])
		end
	end
end
function orderFleetAttack8()
	local objectList = getGMSelection()
	if #objectList ~= 1 then
		print("Need to select a target for fleet to attack")
		return
	end
	local fto = fleetList[8]
	for _, fm in pairs(fto) do
		if fm ~= nil and fm:isValid() then
			fm:orderAttack(objectList[1])
		end
	end
end
--Order fleet to defend GM selected object
function orderFleetDefend()
	clearGMFunctions()
	addGMFunction("Bk2Main from Order Flt",initialGMFunctions)
	addGMFunction("Back to Order Fleet",orderFleet)
	for i=1,8 do
		local fl = fleetList[i]
		if fl ~= nil then
			local sampleName = ""
			for j=1,#fl do
				local fm = fl[j]
				if fm ~= nil and fm:isValid() then
					sampleName = fm:getCallSign()
					break
				end
			end
			GMOrderFleetDefend = string.format("%i %s",i,sampleName)
			addGMFunction(GMOrderFleetDefend,defendFleetFunction[i])
		else
			break
		end
	end
end
function orderFleetDefend1()
	local objectList = getGMSelection()
	if #objectList ~= 1 then
		print("Need to select a target for fleet to defend")
		return
	end
	local fto = fleetList[1]
	for _, fm in pairs(fto) do
		if fm ~= nil and fm:isValid() then
			fm:orderDefendTarget(objectList[1])
		end
	end
end
function orderFleetDefend2()
	local objectList = getGMSelection()
	if #objectList ~= 1 then
		print("Need to select a target for fleet to defend")
		return
	end
	local fto = fleetList[2]
	for _, fm in pairs(fto) do
		if fm ~= nil and fm:isValid() then
			fm:orderDefendTarget(objectList[1])
		end
	end
end
function orderFleetDefend3()
	local objectList = getGMSelection()
	if #objectList ~= 1 then
		print("Need to select a target for fleet to defend")
		return
	end
	local fto = fleetList[3]
	for _, fm in pairs(fto) do
		if fm ~= nil and fm:isValid() then
			fm:orderDefendTarget(objectList[1])
		end
	end
end
function orderFleetDefend4()
	local objectList = getGMSelection()
	if #objectList ~= 1 then
		print("Need to select a target for fleet to defend")
		return
	end
	local fto = fleetList[4]
	for _, fm in pairs(fto) do
		if fm ~= nil and fm:isValid() then
			fm:orderDefendTarget(objectList[1])
		end
	end
end
function orderFleetDefend5()
	local objectList = getGMSelection()
	if #objectList ~= 1 then
		print("Need to select a target for fleet to defend")
		return
	end
	local fto = fleetList[5]
	for _, fm in pairs(fto) do
		if fm ~= nil and fm:isValid() then
			fm:orderDefendTarget(objectList[1])
		end
	end
end
function orderFleetDefend6()
	local objectList = getGMSelection()
	if #objectList ~= 1 then
		print("Need to select a target for fleet to defend")
		return
	end
	local fto = fleetList[6]
	for _, fm in pairs(fto) do
		if fm ~= nil and fm:isValid() then
			fm:orderDefendTarget(objectList[1])
		end
	end
end
function orderFleetDefend7()
	local objectList = getGMSelection()
	if #objectList ~= 1 then
		print("Need to select a target for fleet to defend")
		return
	end
	local fto = fleetList[7]
	for _, fm in pairs(fto) do
		if fm ~= nil and fm:isValid() then
			fm:orderDefendTarget(objectList[1])
		end
	end
end
function orderFleetDefend8()
	local objectList = getGMSelection()
	if #objectList ~= 1 then
		print("Need to select a target for fleet to defend")
		return
	end
	local fto = fleetList[8]
	for _, fm in pairs(fto) do
		if fm ~= nil and fm:isValid() then
			fm:orderDefendTarget(objectList[1])
		end
	end
end
--Order fleet to fly to selected object(s)
function orderFleetFly()
	clearGMFunctions()
	addGMFunction("Bk2Main from Order Flt",initialGMFunctions)
	addGMFunction("Back to Order Fleet",orderFleet)
	for i=1,8 do
		local fl = fleetList[i]
		if fl ~= nil then
			local sampleName = ""
			for j=1,#fl do
				local fm = fl[j]
				if fm ~= nil and fm:isValid() then
					sampleName = fm:getCallSign()
					break
				end
			end
			GMOrderFleetFly = string.format("%i %s",i,sampleName)
			addGMFunction(GMOrderFleetFly,flyFleetFunction[i])
		else
			break
		end
	end
end
function orderGivenFleetToFly(fto)
	local flyx = 0
	local flyy = 0
	local objectList = getGMSelection()
	if #objectList == 1 then
		flyx, flyy = objectList[1]:getPosition()
	else
		flyx, flyy = centerOfSelected(objectList)
	end
	for _, fm in pairs(fto) do
		if fm ~= nil and fm:isValid() then
			fm:orderFlyTowards(flyx,flyy)
		end
	end
end
function orderFleetFly1()
	local objectList = getGMSelection()
	if #objectList < 1 then
		print("Need to select something for fleet to fly to")
		return
	end
	local fto = fleetList[1]
	orderGivenFleetToFly(fto)
end
function orderFleetFly2()
	local objectList = getGMSelection()
	if #objectList ~= 1 then
		print("Need to select something for fleet to fly to")
		return
	end
	local fto = fleetList[2]
	orderGivenFleetToFly(fto)
end
function orderFleetFly3()
	local objectList = getGMSelection()
	if #objectList ~= 1 then
		print("Need to select something for fleet to fly to")
		return
	end
	local fto = fleetList[3]
	orderGivenFleetToFly(fto)
end
function orderFleetFly4()
	local objectList = getGMSelection()
	if #objectList ~= 1 then
		print("Need to select something for fleet to fly to")
		return
	end
	local fto = fleetList[4]
	orderGivenFleetToFly(fto)
end
function orderFleetFly5()
	local objectList = getGMSelection()
	if #objectList ~= 1 then
		print("Need to select something for fleet to fly to")
		return
	end
	local fto = fleetList[5]
	orderGivenFleetToFly(fto)
end
function orderFleetFly6()
	local objectList = getGMSelection()
	if #objectList ~= 1 then
		print("Need to select something for fleet to fly to")
		return
	end
	local fto = fleetList[6]
	orderGivenFleetToFly(fto)
end
function orderFleetFly7()
	local objectList = getGMSelection()
	if #objectList ~= 1 then
		print("Need to select something for fleet to fly to")
		return
	end
	local fto = fleetList[7]
	orderGivenFleetToFly(fto)
end
function orderFleetFly8()
	local objectList = getGMSelection()
	if #objectList ~= 1 then
		print("Need to select something for fleet to fly to")
		return
	end
	local fto = fleetList[8]
	orderGivenFleetToFly(fto)
end
--Order fleet to fly blind to selected object(s)
function orderFleetFlyBlind()
	clearGMFunctions()
	addGMFunction("Bk2Main from Order Flt",initialGMFunctions)
	addGMFunction("Back to Order Fleet",orderFleet)
	for i=1,8 do
		local fl = fleetList[i]
		if fl ~= nil then
			local sampleName = ""
			for j=1,#fl do
				local fm = fl[j]
				if fm ~= nil and fm:isValid() then
					sampleName = fm:getCallSign()
					break
				end
			end
			GMOrderFleetFlyBlind = string.format("%i %s",i,sampleName)
			addGMFunction(GMOrderFleetFlyBlind,flyBlindFleetFunction[i])
		else
			break
		end
	end
end
function orderGivenFleetToFlyBlind(fto)
	local flyx = 0
	local flyy = 0
	local objectList = getGMSelection()
	if #objectList == 1 then
		flyx, flyy = objectList[1]:getPosition()
	else
		flyx, flyy = centerOfSelected(objectList)
	end
	for _, fm in pairs(fto) do
		if fm ~= nil and fm:isValid() then
			fm:orderFlyTowardsBlind(flyx,flyy)
		end
	end
end
function orderFleetFlyBlind1()
	local objectList = getGMSelection()
	if #objectList < 1 then
		print("Need to select something for fleet to fly blind to")
		return
	end
	local fto = fleetList[1]
	orderGivenFleetToFlyBlind(fto)
end
function orderFleetFlyBlind2()
	local objectList = getGMSelection()
	if #objectList < 1 then
		print("Need to select something for fleet to fly blind to")
		return
	end
	local fto = fleetList[2]
	orderGivenFleetToFlyBlind(fto)
end
function orderFleetFlyBlind3()
	local objectList = getGMSelection()
	if #objectList < 1 then
		print("Need to select something for fleet to fly blind to")
		return
	end
	local fto = fleetList[3]
	orderGivenFleetToFlyBlind(fto)
end
function orderFleetFlyBlind4()
	local objectList = getGMSelection()
	if #objectList < 1 then
		print("Need to select something for fleet to fly blind to")
		return
	end
	local fto = fleetList[4]
	orderGivenFleetToFlyBlind(fto)
end
function orderFleetFlyBlind5()
	local objectList = getGMSelection()
	if #objectList < 1 then
		print("Need to select something for fleet to fly blind to")
		return
	end
	local fto = fleetList[5]
	orderGivenFleetToFlyBlind(fto)
end
function orderFleetFlyBlind6()
	local objectList = getGMSelection()
	if #objectList < 1 then
		print("Need to select something for fleet to fly blind to")
		return
	end
	local fto = fleetList[6]
	orderGivenFleetToFlyBlind(fto)
end
function orderFleetFlyBlind7()
	local objectList = getGMSelection()
	if #objectList < 1 then
		print("Need to select something for fleet to fly blind to")
		return
	end
	local fto = fleetList[7]
	orderGivenFleetToFlyBlind(fto)
end
function orderFleetFlyBlind8()
	local objectList = getGMSelection()
	if #objectList < 1 then
		print("Need to select something for fleet to fly blind to")
		return
	end
	local fto = fleetList[8]
	orderGivenFleetToFlyBlind(fto)
end
--Order fleet to dock at selected object
function orderFleetDock()
	clearGMFunctions()
	addGMFunction("Bk2Main from Order Flt",initialGMFunctions)
	addGMFunction("Back to Order Fleet",orderFleet)
	for i=1,8 do
		local fl = fleetList[i]
		if fl ~= nil then
			local sampleName = ""
			for j=1,#fl do
				local fm = fl[j]
				if fm ~= nil and fm:isValid() then
					sampleName = fm:getCallSign()
					break
				end
			end
			GMOrderFleetDock = string.format("%i %s",i,sampleName)
			addGMFunction(GMOrderFleetDock,dockFleetFunction[i])
		else
			break
		end
	end
end
function orderFleetDock1()
	local objectList = getGMSelection()
	if #objectList ~= 1 then
		print("Need to select a docking target for fleet")
		return
	end
	local fto = fleetList[1]
	for _, fm in pairs(fto) do
		if fm ~= nil and fm:isValid() then
			fm:orderDock(objectList[1])
		end
	end
end
function orderFleetDock2()
	local objectList = getGMSelection()
	if #objectList ~= 1 then
		print("Need to select a docking target for fleet")
		return
	end
	local fto = fleetList[2]
	for _, fm in pairs(fto) do
		if fm ~= nil and fm:isValid() then
			fm:orderDock(objectList[1])
		end
	end
end
function orderFleetDock3()
	local objectList = getGMSelection()
	if #objectList ~= 1 then
		print("Need to select a docking target for fleet")
		return
	end
	local fto = fleetList[3]
	for _, fm in pairs(fto) do
		if fm ~= nil and fm:isValid() then
			fm:orderDock(objectList[1])
		end
	end
end
function orderFleetDock4()
	local objectList = getGMSelection()
	if #objectList ~= 1 then
		print("Need to select a docking target for fleet")
		return
	end
	local fto = fleetList[4]
	for _, fm in pairs(fto) do
		if fm ~= nil and fm:isValid() then
			fm:orderDock(objectList[1])
		end
	end
end
function orderFleetDock5()
	local objectList = getGMSelection()
	if #objectList ~= 1 then
		print("Need to select a docking target for fleet")
		return
	end
	local fto = fleetList[5]
	for _, fm in pairs(fto) do
		if fm ~= nil and fm:isValid() then
			fm:orderDock(objectList[1])
		end
	end
end
function orderFleetDock6()
	local objectList = getGMSelection()
	if #objectList ~= 1 then
		print("Need to select a docking target for fleet")
		return
	end
	local fto = fleetList[6]
	for _, fm in pairs(fto) do
		if fm ~= nil and fm:isValid() then
			fm:orderDock(objectList[1])
		end
	end
end
function orderFleetDock7()
	local objectList = getGMSelection()
	if #objectList ~= 1 then
		print("Need to select a docking target for fleet")
		return
	end
	local fto = fleetList[7]
	for _, fm in pairs(fto) do
		if fm ~= nil and fm:isValid() then
			fm:orderDock(objectList[1])
		end
	end
end
function orderFleetDock8()
	local objectList = getGMSelection()
	if #objectList ~= 1 then
		print("Need to select a docking target for fleet")
		return
	end
	local fto = fleetList[8]
	for _, fm in pairs(fto) do
		if fm ~= nil and fm:isValid() then
			fm:orderDock(objectList[1])
		end
	end
end
------------------
--	Order Ship  --
------------------
function orderShip()
	clearGMFunctions()
	addGMFunction("-Main from order ship",initialGMFunctions)
	if jammer_range > 5000 then
		addGMFunction(string.format("Jam range %i - %i = %iU",jammer_range/1000,5,(jammer_range-5000)/1000),function()
			jammer_range = jammer_range - 5000
			orderShip()
		end)
	end
	if jammer_range < 50000 then
		addGMFunction(string.format("Jam range %i + %i = %iU",jammer_range/1000,5,(jammer_range+5000)/1000),function()
			jammer_range = jammer_range + 5000
			orderShip()
		end)
	end
	addGMFunction(string.format("Drop Jammer %iU",jammer_range/1000),dropJammer)
end
function dropJammer()
	local object_list = getGMSelection()
	if #object_list < 1 then
		addGMMessage("Jammer drop failed - nothing selected for location determination") 
		return
	end
	local selected_matches_npc_ship = false
	for i=1,#object_list do
		local current_selected_object = object_list[i]
		if current_selected_object.typeName == "CpuShip" then
			local csox, csoy = current_selected_object:getPosition()
			local vx, vy = vectorFromAngle(current_selected_object:getHeading()+90,500)
			WarpJammer():setRange(jammer_range):setPosition(csox+vx,csoy+vy):setFaction(current_selected_object:getFaction())
		end
	end
end
-------------------
--	Drop Points  --
-------------------
function dropPoint()
	clearGMFunctions()
	addGMFunction("-Main from Drop Pnt",initialGMFunctions)
	addGMFunction("+Escape Pod",setEscapePod)
	addGMFunction("+Marine Point",setMarinePoint)
	addGMFunction("+Engineer Point",setEngineerPoint)
	addGMFunction("+Medical Team Point",setMedicPoint)
	addGMFunction("+Custom Supply",setCustomSupply)
	--Default supply drop gives:
	--500 energy
	--4 Homing
	--1 Nuke
	--2 Mines
	--1 EMP
end
--   ***   Escape Pod   ***
function setEscapePod()
	clearGMFunctions()
	addGMFunction("-Main from Esc Pod",initialGMFunctions)
	addGMFunction("-From Escape Pod",dropPoint)
	addGMFunction("Associated",podAssociatedTo)
	addGMFunction("+Near to",podNearTo)
end
--Create escape pod associated to selected object
function podAssociatedTo()
	local objectList = getGMSelection()
	if #objectList ~= 1 then
		addGMMessage("No action taken. Selct one object for association")
		return
	end
	local tempObject = objectList[1]
	local tempType = tempObject.typeName
	local podDistance = associatedTypeDistance[tempType]
	if podDistance == nil then
		addGMMessage(tempType .. ": not type which can be associated")
		--print(tempType .. ": not type which can be associated")
		return
	end
	local aox, aoy = tempObject:getPosition()
	--size of player spaceships vary, so use the values set in setConstants to determine
	if tempType == "PlayerSpaceship" then
		local tempShipType = tempObject:getTypeName()
		local psd = playerShipDistance[tempShipType]
		if psd ~= nil then
			podDistance = psd
		end
	end
	--size of space stations vary so use the values set in setConstants to determine
	if tempType == "SpaceStation" then
		local tempStationType = tempObject:getTypeName()
		local sd = spaceStationDistance[tempStationType]
		if sd ~= nil then
			podDistance = sd
		end
	end
	if tempType == "BlackHole" then
		addGMFunction("Near radius but safe",nearButSafe)
		addGMFunction("Edge but in danger",edgeButDanger)
		--podDistance = 5000
	elseif tempType == "WormHole" then
		addGMFunction("Near radius but outside",nearButOutside)
		addGMFunction("Edge but inside",edgeButInside)
	else
		local sox, soy = vectorFromAngle(random(0,360),podDistance)
		podCreation(aox, aoy, sox, soy)
	end
end
--Black hole special cases
function nearButSafe()
	local objectList = getGMSelection()
	local podDistance = associatedTypeDistance["BlackHole"]
	local sox, soy = vectorFromAngle(random(0,360),podDistance)
	local aox, aoy = objectList[1]:getPosition()
	podCreation(aox, aoy, sox, soy)
end
function edgeButDanger()
	local objectList = getGMSelection()
	local podDistance = 5100
	local sox, soy = vectorFromAngle(random(0,360),podDistance)
	local aox, aoy = objectList[1]:getPosition()
	podCreation(aox, aoy, sox, soy)
end
--Worm hole special cases
function nearButOutside()
	local objectList = getGMSelection()
	local podDistance = associatedTypeDistance["WormHole"]
	local sox, soy = vectorFromAngle(random(0,360),podDistance)
	local aox, aoy = objectList[1]:getPosition()
	podCreation(aox, aoy, sox, soy)
end
function edgeButInside()
	local objectList = getGMSelection()
	local podDistance = 2600
	local sox, soy = vectorFromAngle(random(0,360),podDistance)
	local aox, aoy = objectList[1]:getPosition()
	podCreation(aox, aoy, sox, soy)
end
function podPickupProcess(self,retriever)
	local podCallSign = self:getCallSign()
	local podPrepped = false
	for epCallSign, ep in pairs(escapePodList) do
		if epCallSign == podCallSign then
			escapePodList[epCallSign] = nil
		end
	end
	for rpi, rp in pairs(rendezvousPoints) do
		if rp:getCallSign() == podCallSign then
			table.remove(rendezvousPoints,rpi)
		end
	end
	for pidx=1,8 do
		p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			for pb, enabled in pairs(p.podButton) do
				if pb == podCallSign then
					if not enabled then
						podPrepped = true
						break
					end
				end
			end
			if podPrepped then
				p:removeCustom(podCallSign)
				if p == retriever then
					retriever:addToShipLog(string.format("escape pod %s retrieved",podCallSign),"Green")
					if retriever:getEnergy() > 50 then
						retriever:setEnergy(retriever:getEnergy() - 50)
					else
						retriever:setEnergy(0)
					end
				end
			else
				local rpx, rpy = self:getPosition()
				if escapePodList[podCallSign] == nil then
					local redoPod = Artifact():setPosition(rpx,rpy):setScanningParameters(1,1):setRadarSignatureInfo(1,.5,0):setModel("ammo_box"):setDescriptions("Escape Pod",string.format("Escape Pod %s, life forms detected",podCallSign)):setCallSign(podCallSign)
					redoPod:onPickUp(podPickupProcess)
					escapePodList[podCallSign] = redoPod
					table.insert(rendezvousPoints,redoPod)
				end
			end
		end
	end
end
--Create escape pod near to selected object(s)
function podNearTo()
	clearGMFunctions()
	addGMFunction("-Main from Near To",initialGMFunctions)
	addGMFunction("-Drop Point",dropPoint)
	addGMFunction("-Set Escape Pod",setEscapePod)
	local objectList = getGMSelection()
	if #objectList < 1 then
		addGMMessage("Select an object. No action taken")
		return
	end
	--print("got something in selection list")
	nearx = 0
	neary = 0
	if #objectList > 1 then
		nearx, neary = centerOfSelected(objectList)
	else
		nearx, neary = objectList[1]:getPosition()	
	end
	print(string.format("nearx: %.1f, neary: %.1f",nearx,neary))
	local nearbyObjects = getObjectsInRadius(nearx, neary, 20000)
	cpuShipList = {}
	for i=1,#nearbyObjects do
		local tempObject = nearbyObjects[i]
		local tempType = tempObject.typeName
		if tempType == "CpuShip" then
			table.insert(cpuShipList,tempObject)
		end
		if #cpuShipList >= 3 then
			break
		end
	end
	if #cpuShipList > 0 then
		if #cpuShipList >= 1 then
			local GMPodAssociatedToCpuShip1 = string.format("Associate to %s",cpuShipList[1]:getCallSign())
			addGMFunction(GMPodAssociatedToCpuShip1,podAssociatedToCpuShip1)
		end
		if #cpuShipList >= 2 then
			local GMPodAssociatedToCpuShip2 = string.format("Associate to %s",cpuShipList[2]:getCallSign())
			addGMFunction(GMPodAssociatedToCpuShip2,podAssociatedToCpuShip2)
		end
		if #cpuShipList >= 3 then
			local GMPodAssociatedToCpuShip3 = string.format("Associate to %s",cpuShipList[3]:getCallSign())
			addGMFunction(GMPodAssociatedToCpuShip3,podAssociatedToCpuShip3)
		end
	end
	callingNearTo = podNearTo
	local GMSetCreateDirection = createDirection .. " Degrees"
	addGMFunction(string.format("+%s",GMSetCreateDirection),setCreateDirection)
	local GMSetCreateDistance = createDistance .. " Units"
	addGMFunction(string.format("+%s",GMSetCreateDistance),setCreateDistance)
	local GMCreatePodAway = "Create at " .. createDirection .. " Deg, " .. createDistance .. "U"
	addGMFunction(GMCreatePodAway,createPodAway)
end
--Near to distance
function setCreateDistance()
	clearGMFunctions()
	addGMFunction("-From Create Dist",callingNearTo)
	if createDistance == .5 then
		GMSetCreateDistanceHalf = ".5U*"
	else
		GMSetCreateDistanceHalf = ".5U"
	end
	addGMFunction(GMSetCreateDistanceHalf,setCreateDistanceHalf)
	if createDistance == 1 then
		GMSetCreateDistance1 = "1U*"
	else
		GMSetCreateDistance1 = "1U"
	end
	addGMFunction(GMSetCreateDistance1,setCreateDistance1)
	if createDistance == 2 then
		GMSetCreateDistance2 = "2U*"
	else
		GMSetCreateDistance2 = "2U"
	end
	addGMFunction(GMSetCreateDistance2,setCreateDistance2)
	if createDistance == 3 then
		GMSetCreateDistance3 = "3U*"
	else
		GMSetCreateDistance3 = "3U"
	end
	addGMFunction(GMSetCreateDistance3,setCreateDistance3)
	if createDistance == 5 then
		GMSetCreateDistance5 = "5U*"
	else
		GMSetCreateDistance5 = "5U"
	end
	addGMFunction(GMSetCreateDistance5,setCreateDistance5)
	if createDistance == 10 then
		GMSetCreateDistance10 = "10U*"
	else
		GMSetCreateDistance10 = "10U"
	end
	addGMFunction(GMSetCreateDistance10,setCreateDistance10)
	if createDistance == 20 then
		GMSetCreateDistance20 = "20U*"
	else
		GMSetCreateDistance20 = "20U"
	end
	addGMFunction(GMSetCreateDistance20,setCreateDistance20)
	if createDistance == 30 then
		GMSetCreateDistance30 = "30U*"
	else
		GMSetCreateDistance30 = "30U"
	end
	addGMFunction(GMSetCreateDistance30,setCreateDistance30)
end
function setCreateDistanceHalf()
	createDistance = .5
	setCreateDistance()
end
function setCreateDistance1()
	createDistance = 1
	setCreateDistance()
end
function setCreateDistance2()
	createDistance = 2
	setCreateDistance()
end
function setCreateDistance3()
	createDistance = 3
	setCreateDistance()
end
function setCreateDistance5()
	createDistance = 5
	setCreateDistance()
end
function setCreateDistance10()
	createDistance = 10
	setCreateDistance()
end
function setCreateDistance20()
	createDistance = 20
	setCreateDistance()
end
function setCreateDistance30()
	createDistance = 30
	setCreateDistance()
end
--Near to direction
function setCreateDirection()
	clearGMFunctions()
	addGMFunction("-From Create Dir",callingNearTo)
	local GMSetCreateDirection0 = "0"
	if createDirection == 0 then
		GMSetCreateDirection0 = "0*"
	end
	addGMFunction(GMSetCreateDirection0,setCreateDirection0)
	local GMSetCreateDirection45 = "45"
	if createDirection == 45 then
		GMSetCreateDirection45 = "45*"
	end
	addGMFunction(GMSetCreateDirection45,setCreateDirection45)
	local GMSetCreateDirection90 = "90"
	if createDirection == 90 then
		GMSetCreateDirection90 = "90*"
	end
	addGMFunction(GMSetCreateDirection90,setCreateDirection90)
	local GMSetCreateDirection135 = "135"
	if createDirection == 135 then
		GMSetCreateDirection135 = "135*"
	end
	addGMFunction(GMSetCreateDirection135,setCreateDirection135)
	local GMSetCreateDirection180 = "180"
	if createDirection == 180 then
		GMSetCreateDirection180 = "180*"
	end
	addGMFunction(GMSetCreateDirection180,setCreateDirection180)
	local GMSetCreateDirection225 = "225"
	if createDirection == 225 then
		GMSetCreateDirection225 = "225*"
	end
	addGMFunction(GMSetCreateDirection225,setCreateDirection225)
	local GMSetCreateDirection270 = "270"
	if createDirection == 270 then
		GMSetCreateDirection270 = "270*"
	end
	addGMFunction(GMSetCreateDirection270,setCreateDirection270)
	local GMSetCreateDirection315 = "315"
	if createDirection == 315 then
		GMSetCreateDirection315 = "315*"
	end
	addGMFunction(GMSetCreateDirection315,setCreateDirection315)
end
function setCreateDirection0()
	createDirection = 0
	setCreateDirection()
end
function setCreateDirection45()
	createDirection = 45
	setCreateDirection()
end
function setCreateDirection90()
	createDirection = 90
	setCreateDirection()
end
function setCreateDirection135()
	createDirection = 135
	setCreateDirection()
end
function setCreateDirection180()
	createDirection = 180
	setCreateDirection()
end
function setCreateDirection225()
	createDirection = 225
	setCreateDirection()
end
function setCreateDirection270()
	createDirection = 270
	setCreateDirection()
end
function setCreateDirection315()
	createDirection = 315
	setCreateDirection()
end
--Associate to CpuShip since they cannot be part of GM selection in this context
function podAssociatedToCpuShip1()
	podAssociatedToGivenCpuShip(cpuShipList[1])
end
function podAssociatedToCpuShip2()
	podAssociatedToGivenCpuShip(cpuShipList[2])
end
function podAssociatedToCpuShip3()
	podAssociatedToGivenCpuShip(cpuShipList[3])
end
function podAssociatedToGivenCpuShip(tempObject)
	local podDistance = associatedTypeDistance["CpuShip"]
	local aox, aoy = tempObject:getPosition()
	local tempShipType = tempObject:getTypeName()
	local csd = shipTemplateDistance[tempShipType]
	if csd ~= nil then
		podDistance = csd
	end
	local sox, soy = vectorFromAngle(random(0,360),podDistance)
	podCreation(aox, aoy, sox, soy)
end
--Pod creation after distance and direction parameters set
function createPodAway()
	local angle = createDirection + 270
	if angle > 360 then 
		angle = angle - 360
	end
	local sox, soy = vectorFromAngle(angle,createDistance*1000)
	podCreation(nearx, neary, sox, soy)
end
function podCreation(originx, originy, vectorx, vectory)
	artifactCounter = artifactCounter + 1
	artifactNumber = artifactNumber + math.random(1,4)
	local randomPrefix = string.char(math.random(65,90))
	local podCallSign = string.format("%s%i",randomPrefix,artifactNumber)
	local pod = Artifact():setPosition(originx+vectorx,originy+vectory):setScanningParameters(1,1):setRadarSignatureInfo(1,.5,0):setModel("ammo_box"):setDescriptions("Escape Pod",string.format("Escape Pod %s, life forms detected",podCallSign)):setCallSign(podCallSign)
	pod:onPickUp(podPickupProcess)
	escapePodList[podCallSign] = pod
	table.insert(rendezvousPoints,pod)
	for pidx=1,8 do
		p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			if p.podButton == nil then
				p.podButton = {}
			end
			p.podButton[podCallSign] = true
			local tempButton = podCallSign
			p:addCustomButton("Engineering",tempButton,string.format("Prepare to get %s",podCallSign),function()
				for pidx=1,8 do
					p = getPlayerShip(pidx)
					if p ~= nil and p:isValid() then
						for pb, enabled in pairs(p.podButton) do
							if enabled then
								p:removeCustom(pb)
								p:addCustomMessage("Engineering","pbgone",string.format("Transporters ready for pickup of %s",pb))
								p.podButton[pb] = false
							end
						end
					end
				end
			end)
		end
	end
end
--   ***   Marine point   ***
function setMarinePoint()
	clearGMFunctions()
	addGMFunction("-Main",initialGMFunctions)
	addGMFunction("-From Marine Point",dropPoint)
	dropExtractActionReturn = setMarinePoint	--tell callback function to return to this function
	local GMMarineDrop = "Drop marines"
	if dropOrExtractAction == "Drop" then
		GMMarineDrop = "Drop marines*"
	end
	addGMFunction(GMMarineDrop,setDropAction)
	local GMMarineExtract = "Extract marines"
	if dropOrExtractAction == "Extract" then
		GMMarineExtract = "Extract marines*"
	end
	addGMFunction(GMMarineExtract,setExtractAction)
	addGMFunction("Associated",marineAssociatedTo)
	addGMFunction("+Near to",marineNearTo)
end
function setDropAction()
	dropOrExtractAction = "Drop"
	dropExtractActionReturn()
end
function setExtractAction()
	dropOrExtractAction = "Extract"
	dropExtractActionReturn()
end
--Create marine point associated to selected object
function marineAssociatedTo()
	local objectList = getGMSelection()
	if #objectList ~= 1 then
		addGMMessage("Select one object. No action taken")
		return
	end
	local tempObject = objectList[1]
	local tempType = tempObject.typeName
	local marineDistance = associatedTypeDistance[tempType]
	if marineDistance == nil then
		addGMMessage(tempType .. ": not type which can be associated. No action taken.")
		--print(tempType .. ": not type which can be associated")
		return
	end
	local aox, aoy = tempObject:getPosition()
	--size of player spaceships vary, so use the values set in setConstants to determine
	if tempType == "PlayerSpaceship" then
		local tempShipType = tempObject:getTypeName()
		local psd = playerShipDistance[tempShipType]
		if psd ~= nil then
			marineDistance = psd
		end
	end
	--size of space stations vary so use the values set in setConstants to determine
	if tempType == "SpaceStation" then
		local tempStationType = tempObject:getTypeName()
		local sd = spaceStationDistance[tempStationType]
		if sd ~= nil then
			marineDistance = sd
		end
	end
	local sox, soy = vectorFromAngle(random(0,360),marineDistance)
	local associatedObjectName = tempObject:getCallSign()
	marineCreation(aox, aoy, sox, soy, associatedObjectName)
end
function marineCreation(originx, originy, vectorx, vectory, associatedObjectName)
	artifactCounter = artifactCounter + 1
	artifactNumber = artifactNumber + math.random(1,5)
	local randomPrefix = string.char(math.random(65,90))
	local marineCallSign = string.format("%s%i",randomPrefix,artifactNumber)
	local unscannedDescription = string.format("Marine %s Point",dropOrExtractAction)
	local scannedDescription = string.format("Marine %s Point %s, standing by for marine transport",dropOrExtractAction,marineCallSign)
	if associatedObjectName ~= nil then
		scannedDescription = scannedDescription .. ": " .. associatedObjectName
	end
	local marinePoint = Artifact():setPosition(originx+vectorx,originy+vectory):setScanningParameters(1,1):setRadarSignatureInfo(1,.5,0):setModel("SensorBuoyMKI"):setDescriptions(unscannedDescription,scannedDescription):setCallSign(marineCallSign)
	marinePoint:onPickUp(marinePointPickupProcess)
	marinePoint.action = dropOrExtractAction
	marinePoint.associatedObjectName = associatedObjectName
	marinePointList[marineCallSign] = marinePoint
	--table.insert(marinePointList,marinePoint)
	table.insert(rendezvousPoints,marinePoint)
	for pidx=1,8 do
		p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			if p.marinePointButton == nil then
				p.marinePointButton = {}
			end
			p.marinePointButton[marineCallSign] = true
			p:addCustomButton("Engineering",marineCallSign,string.format("Prep to %s via %s",dropOrExtractAction,marineCallSign),function()
				for pidx=1,8 do
					p = getPlayerShip(pidx)
					if p ~= nil and p:isValid() then
						for mpb, enabled in pairs(p.marinePointButton) do
							if enabled then
								p:removeCustom(mpb)
								p:addCustomMessage("Engineering","mpbgone",string.format("Transporters ready for marines via %s",mpb))
								p.marinePointButton[mpb] = false
							end
						end
					end
				end
			end)
		end
	end
end
function marinePointPickupProcess(self,retriever)
	local marineCallSign = self:getCallSign()
	local marinePointPrepped = false
	for mpCallSign, mp in pairs(marinePointList) do
		if mpCallSign == marineCallSign then
			marinePointList[mpCallSign] = nil
		end
	end
	for rpi, rp in pairs(rendezvousPoints) do
		if rp:getCallSign() == marineCallSign then
			table.remove(rendezvousPoints,rpi)
		end
	end
	for pidx=1,8 do
		p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			for mpb, enabled in pairs(p.marinePointButton) do
				if mpb == marineCallSign then
					if not enabled then
						marinePointPrepped = true
						break
					end
				end
			end
			if marinePointPrepped then
				p:removeCustom(marineCallSign)
				if p == retriever then
					local completionMessage = string.format("Marine %s action successful via %s",self.action,marineCallSign)
					if self.associatedObjectName ~= nil then
						if self.action == "Drop" then
							completionMessage = string.format("Marine drop action on %s successful via %s",self.associatedObjectName,marineCallSign)
						else
							completionMessage = string.format("Marine extract action from %s successful via %s",self.associatedObjectName,marineCallSign)
						end
					end
					retriever:addToShipLog(completionMessage,"Green")
					if retriever:getEnergy() > 50 then
						retriever:setEnergy(retriever:getEnergy() - 50)
					else
						retriever:setEnergy(0)
					end
				end
			else
				local rpx, rpy = self:getPosition()
				local unscannedDescription = string.format("Marine %s Point",self.action)
				local scannedDescription = string.format("Marine %s Point %s, standing by for marine transport",self.action,marineCallSign)
				if self.associatedObjectName ~= nil then
					scannedDescription = scannedDescription .. ": " .. self.associatedObjectName
				end
				if marinePointList[marineCallSign] == nil then
					local redoMarinePoint = Artifact():setPosition(rpx,rpy):setScanningParameters(1,1):setRadarSignatureInfo(1,.5,0):setModel("SensorBuoyMKI"):setDescriptions(unscannedDescription,scannedDescription):setCallSign(marineCallSign)
					redoMarinePoint:onPickUp(marinePointPickupProcess)
					redoMarinePoint.action = self.action
					redoMarinePoint.associatedObjectName = self.associatedObjectName
					marinePointList[marineCallSign] = redoMarinePoint
					--table.insert(marinePointList,redoMarinePoint)
					table.insert(rendezvousPoints,redoMarinePoint)
				end
			end
		end
	end
end
--Create marine point near to selected object(s)
function marineNearTo()
	clearGMFunctions()
	addGMFunction("-Main",initialGMFunctions)
	addGMFunction("-Drop Point",dropPoint)
	addGMFunction("-From Near To",setMarinePoint)
	local objectList = getGMSelection()
	if #objectList < 1 then
		addGMMessage("Select object. No action taken")
		return
	end
	--print("got something in selection list")
	nearx = 0
	neary = 0
	if #objectList > 1 then
		nearx, neary = centerOfSelected(objectList)
	else
		nearx, neary = objectList[1]:getPosition()	
	end
	print(string.format("nearx: %.1f, neary: %.1f",nearx,neary))
	local nearbyObjects = getObjectsInRadius(nearx, neary, 20000)
	cpuShipList = {}
	for i=1,#nearbyObjects do
		local tempObject = nearbyObjects[i]
		local tempType = tempObject.typeName
		if tempType == "CpuShip" then
			table.insert(cpuShipList,tempObject)
		end
		if #cpuShipList >= 3 then
			break
		end
	end
	if #cpuShipList > 0 then
		if #cpuShipList >= 1 then
			GMMarineAssociatedToCpuShip1 = string.format("Associate to %s",cpuShipList[1]:getCallSign())
			addGMFunction(GMMarineAssociatedToCpuShip1,marineAssociatedToCpuShip1)
		end
		if #cpuShipList >= 2 then
			GMMarineAssociatedToCpuShip2 = string.format("Associate to %s",cpuShipList[2]:getCallSign())
			addGMFunction(GMMarineAssociatedToCpuShip2,marineAssociatedToCpuShip2)
		end
		if #cpuShipList >= 3 then
			GMMarineAssociatedToCpuShip3 = string.format("Associate to %s",cpuShipList[3]:getCallSign())
			addGMFunction(GMMarineAssociatedToCpuShip3,marineAssociatedToCpuShip3)
		end
	end
	callingNearTo = marineNearTo
	GMSetCreateDirection = createDirection .. " Degrees"
	addGMFunction(GMSetCreateDirection,setCreateDirection)
	GMSetCreateDistance = createDistance .. " Units"
	addGMFunction(GMSetCreateDistance,setCreateDistance)
	GMCreateMarineAway = "Create at " .. createDirection .. " Deg, " .. createDistance .. "U"
	addGMFunction(GMCreateMarineAway,createMarineAway)
end
function marineAssociatedToCpuShip1()
	marineAssociatedToGivenCpuShip(cpuShipList[1])
end
function marineAssociatedToCpuShip2()
	marineAssociatedToGivenCpuShip(cpuShipList[2])
end
function marineAssociatedToCpuShip3()
	marineAssociatedToGivenCpuShip(cpuShipList[3])
end
function marineAssociatedToGivenCpuShip(tempObject)
	local marineDistance = associatedTypeDistance["CpuShip"]
	local aox, aoy = tempObject:getPosition()
	local tempShipType = tempObject:getTypeName()
	local csd = shipTemplateDistance[tempShipType]
	if csd ~= nil then
		marineDistance = csd
	end
	local sox, soy = vectorFromAngle(random(0,360),marineDistance)
	marineCreation(aox, aoy, sox, soy)
end
--Marine point creation after distance and direction parameters set
function createMarineAway()
	local angle = createDirection + 270
	if angle > 360 then 
		angle = angle - 360
	end
	local sox, soy = vectorFromAngle(angle,createDistance*1000)
	marineCreation(nearx, neary, sox, soy)
end
--   ***   Engineer point   ***
function setEngineerPoint()
	clearGMFunctions()
	addGMFunction("-Main",initialGMFunctions)
	addGMFunction("-From Engineer Point",dropPoint)
	dropExtractActionReturn = setEngineerPoint
	local GMEngineerDrop = "Drop engineers"
	if dropOrExtractAction == "Drop" then
		GMEngineerDrop = "Drop engineers*"
	end
	addGMFunction(GMEngineerDrop,setDropAction)
	local GMEngineerExtract = "Extract engineers"
	if dropOrExtractAction == "Extract" then
		GMEngineerExtract = "Extract engineers*"
	end
	addGMFunction(GMEngineerExtract,setExtractAction)
	addGMFunction("Associated",engineerAssociatedTo)
	addGMFunction("+Near to",engineerNearTo)
end
--Create engineer point associated to selected object(s)
function engineerAssociatedTo()
	local objectList = getGMSelection()
	if #objectList ~= 1 then
		addGMMessage("You need to select an object. No action taken")
		return
	end
	local tempObject = objectList[1]
	local tempType = tempObject.typeName
	local engineerDistance = associatedTypeDistance[tempType]
	if engineerDistance == nil then
		addGMMessage(string.format("The type of the object selected (%s) is not a type that can be associate. No action taken",tempType))
		--print(tempType .. ": not type which can be associated")
		return
	end
	local aox, aoy = tempObject:getPosition()
	--size of player spaceships vary, so use the values set in setConstants to determine
	if tempType == "PlayerSpaceship" then
		local tempShipType = tempObject:getTypeName()
		local psd = playerShipDistance[tempShipType]
		if psd ~= nil then
			engineerDistance = psd
		end
	end
	--size of space stations vary so use the values set in setConstants to determine
	if tempType == "SpaceStation" then
		local tempStationType = tempObject:getTypeName()
		local sd = spaceStationDistance[tempStationType]
		if sd ~= nil then
			engineerDistance = sd
		end
	end
	local sox, soy = vectorFromAngle(random(0,360),engineerDistance)
	local associatedObjectName = tempObject:getCallSign()
	engineerCreation(aox, aoy, sox, soy, associatedObjectName)
end
function engineerCreation(originx, originy, vectorx, vectory, associatedObjectName)
	artifactCounter = artifactCounter + 1
	artifactNumber = artifactNumber + math.random(1,5)
	local randomPrefix = string.char(math.random(65,90))
	local engineerCallSign = string.format("%s%i",randomPrefix,artifactNumber)
	local unscannedDescription = string.format("Engineer %s Point",dropOrExtractAction)
	local scannedDescription = string.format("Engineer %s Point %s, standing by for engineer transport",dropOrExtractAction,engineerCallSign)
	if associatedObjectName ~= nil then
		scannedDescription = scannedDescription .. ": " .. associatedObjectName
	end
	local engineerPoint = Artifact():setPosition(originx+vectorx,originy+vectory):setScanningParameters(1,1):setRadarSignatureInfo(1,.5,0):setModel("SensorBuoyMKI"):setDescriptions(unscannedDescription,scannedDescription):setCallSign(engineerCallSign)
	engineerPoint:onPickUp(engineerPointPickupProcess)
	engineerPoint.action = dropOrExtractAction
	engineerPoint.associatedObjectName = associatedObjectName
	engineerPointList[engineerCallSign] = engineerPoint
	table.insert(rendezvousPoints,engineerPoint)
	for pidx=1,8 do
		p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			if p.engineerPointButton == nil then
				p.engineerPointButton = {}
			end
			p.engineerPointButton[engineerCallSign] = true
			local tempButton = engineerCallSign
			p:addCustomButton("Engineering",tempButton,string.format("Prep to %s via %s",dropOrExtractAction,engineerCallSign),function()
				for pidx=1,8 do
					p = getPlayerShip(pidx)
					if p ~= nil and p:isValid() then
						for epb, enabled in pairs(p.engineerPointButton) do
							if enabled then
								p:removeCustom(epb)
								p:addCustomMessage("Engineering","epbgone",string.format("Transporters ready for engineers via %s",epb))
								p.engineerPointButton[epb] = false
							end
						end
					end
				end
			end)
		end
	end
end
function engineerPointPickupProcess(self,retriever)
	local engineerCallSign = self:getCallSign()
	local engineerPointPrepped = false
	for epCallSign, ep in pairs(engineerPointList) do
		if epCallSign == engineerCallSign then
			engineerPointList[epCallSign] = nil
		end
	end
	for rpi, rp in pairs(rendezvousPoints) do
		if rp:getCallSign() == engineerCallSign then
			table.remove(rendezvousPoints,rpi)
		end
	end
	for pidx=1,8 do
		p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			for epb, enabled in pairs(p.engineerPointButton) do
				if epb == engineerCallSign then
					if not enabled then
						engineerPointPrepped = true
						break
					end
				end
			end
			if engineerPointPrepped then
				p:removeCustom(engineerCallSign)
				if p == retriever then
					local completionMessage = string.format("Engineer %s action successful via %s",self.action,engineerCallSign)
					if self.associatedObjectName ~= nil then
						if self.action == "Drop" then
							completionMessage = string.format("Engineer drop action on %s successful via %s",self.associatedObjectName,engineerCallSign)
						else
							completionMessage = string.format("Engineer extract action from %s successful via %s",self.associatedObjectName,engineerCallSign)
						end
					end
					retriever:addToShipLog(completionMessage,"Green")
					if retriever:getEnergy() > 50 then
						retriever:setEnergy(retriever:getEnergy() - 50)
					else
						retriever:setEnergy(0)
					end
				end
			else
				local rpx, rpy = self:getPosition()
				local unscannedDescription = string.format("Engineer %s Point",self.action)
				local scannedDescription = string.format("Engineer %s Point %s, standing by for engineer transport",self.action,engineerCallSign)
				if self.associatedObjectName ~= nil then
					scannedDescription = scannedDescription .. ": " .. self.associatedObjectName
				end
				if engineerPointList[engineerCallSign] == nil then
					local redoEngineerPoint = Artifact():setPosition(rpx,rpy):setScanningParameters(1,1):setRadarSignatureInfo(1,.5,0):setModel("SensorBuoyMKI"):setDescriptions(unscannedDescription,scannedDescription):setCallSign(engineerCallSign)
					redoEngineerPoint:onPickUp(engineerPointPickupProcess)
					redoEngineerPoint.action = self.action
					redoEngineerPoint.associatedObjectName = self.associatedObjectName
					engineerPointList[engineerCallSign] = redoEngineerPoint
					table.insert(rendezvousPoints,redoEngineerPoint)
				end
			end
		end
	end
end
--Create engineer point near to selected object(s)
function engineerNearTo()
	clearGMFunctions()
	addGMFunction("-Main",initialGMFunctions)
	addGMFunction("-Drop Point",dropPoint)
	addGMFunction("-From Eng Near To",setEngineerPoint)
	local objectList = getGMSelection()
	if #objectList < 1 then
		addGMMessage("You need to select something. No action taken")
		return
	end
	nearx = 0
	neary = 0
	if #objectList > 1 then
		nearx, neary = centerOfSelected(objectList)
	else
		nearx, neary = objectList[1]:getPosition()	
	end
	print(string.format("nearx: %.1f, neary: %.1f",nearx,neary))
	local nearbyObjects = getObjectsInRadius(nearx, neary, 20000)
	cpuShipList = {}
	for i=1,#nearbyObjects do
		local tempObject = nearbyObjects[i]
		local tempType = tempObject.typeName
		if tempType == "CpuShip" then
			table.insert(cpuShipList,tempObject)
		end
		if #cpuShipList >= 3 then
			break
		end
	end
	if #cpuShipList > 0 then
		if #cpuShipList >= 1 then
			GMEngineerAssociatedToCpuShip1 = string.format("Associate to %s",cpuShipList[1]:getCallSign())
			addGMFunction(GMEngineerAssociatedToCpuShip1,engineerAssociatedToCpuShip1)
		end
		if #cpuShipList >= 2 then
			GMEngineerAssociatedToCpuShip2 = string.format("Associate to %s",cpuShipList[2]:getCallSign())
			addGMFunction(GMEngineerAssociatedToCpuShip2,engineerAssociatedToCpuShip2)
		end
		if #cpuShipList >= 3 then
			GMEngineerAssociatedToCpuShip3 = string.format("Associate to %s",cpuShipList[3]:getCallSign())
			addGMFunction(GMEngineerAssociatedToCpuShip3,engineerAssociatedToCpuShip3)
		end
	end
	callingNearTo = engineerNearTo
	GMSetCreateDirection = createDirection .. " Degrees"
	addGMFunction(string.format("+%s",GMSetCreateDirection),setCreateDirection)
	GMSetCreateDistance = createDistance .. " Units"
	addGMFunction(string.format("+%s",GMSetCreateDistance),setCreateDistance)
	GMCreateEngineerAway = "Create at " .. createDirection .. " Deg, " .. createDistance .. "U"
	addGMFunction(GMCreateEngineerAway,createEngineerAway)
end
function engineerAssociatedToCpuShip1()
	engineerAssociatedToGivenCpuShip(cpuShipList[1])
end
function engineerAssociatedToCpuShip2()
	engineerAssociatedToGivenCpuShip(cpuShipList[2])
end
function engineerAssociatedToCpuShip3()
	engineerAssociatedToGivenCpuShip(cpuShipList[3])
end
function engineerAssociatedToGivenCpuShip(tempObject)
	local engineerDistance = associatedTypeDistance["CpuShip"]
	local aox, aoy = tempObject:getPosition()
	local tempShipType = tempObject:getTypeName()
	local csd = shipTemplateDistance[tempShipType]
	if csd ~= nil then
		engineerDistance = csd
	end
	local sox, soy = vectorFromAngle(random(0,360),engineerDistance)
	engineerCreation(aox, aoy, sox, soy)
end
--Engineer point creation after distance and direction parameters set
function createEngineerAway()
	local angle = createDirection + 270
	if angle > 360 then 
		angle = angle - 360
	end
	local sox, soy = vectorFromAngle(angle,createDistance*1000)
	engineerCreation(nearx, neary, sox, soy)
end
--   ***   Medical Team Point   ***
function setMedicPoint()
	clearGMFunctions()
	addGMFunction("-Main",initialGMFunctions)
	addGMFunction("-From Medic Point",dropPoint)
	dropExtractActionReturn = setMedicPoint
	local GMMedicDrop = "Drop Medical Team"
	if dropOrExtractAction == "Drop" then
		GMMedicDrop = "Drop Medical Team*"
	end
	addGMFunction(GMMedicDrop,setDropAction)
	local GMMedicExtract = "Extract medical team"
	if dropOrExtractAction == "Extract" then
		GMMedicExtract = "Extract medical team*"
	end
	addGMFunction(GMMedicExtract,setExtractAction)
	addGMFunction("Associated",medicAssociatedTo)
	addGMFunction("+Near to",medicNearTo)
end
--Create medical team point associated to selected object(s)
function medicAssociatedTo()
	local objectList = getGMSelection()
	if #objectList ~= 1 then
		addGMMessage("You need to select an object. No action taken")
		return
	end
	local tempObject = objectList[1]
	local tempType = tempObject.typeName
	local medicDistance = associatedTypeDistance[tempType]
	if medicDistance == nil then
		addGMMessage(string.format("Type of object selected (%s) cannot be associated. No action taken",tempType))
		--print(tempType .. ": not type which can be associated")
		return
	end
	local aox, aoy = tempObject:getPosition()
	--size of player spaceships vary, so use the values set in setConstants to determine
	if tempType == "PlayerSpaceship" then
		local tempShipType = tempObject:getTypeName()
		local psd = playerShipDistance[tempShipType]
		if psd ~= nil then
			medicDistance = psd
		end
	end
	--size of space stations vary so use the values set in setConstants to determine
	if tempType == "SpaceStation" then
		local tempStationType = tempObject:getTypeName()
		local sd = spaceStationDistance[tempStationType]
		if sd ~= nil then
			medicDistance = sd
		end
	end
	local sox, soy = vectorFromAngle(random(0,360),medicDistance)
	local associatedObjectName = tempObject:getCallSign()
	medicCreation(aox, aoy, sox, soy, associatedObjectName)
end
function medicCreation(originx, originy, vectorx, vectory, associatedObjectName)
	artifactCounter = artifactCounter + 1
	artifactNumber = artifactNumber + math.random(1,5)
	local randomPrefix = string.char(math.random(65,90))
	local medicCallSign = string.format("%s%i",randomPrefix,artifactNumber)
	local unscannedDescription = string.format("Medical Team %s Point",dropOrExtractAction)
	local scannedDescription = string.format("Medical Team %s Point %s, standing by for medical team transport",dropOrExtractAction,medicCallSign)
	if associatedObjectName ~= nil then
		scannedDescription = scannedDescription .. ": " .. associatedObjectName
	end
	local medicPoint = Artifact():setPosition(originx+vectorx,originy+vectory):setScanningParameters(1,1):setRadarSignatureInfo(1,.5,0):setModel("SensorBuoyMKI"):setDescriptions(unscannedDescription,scannedDescription):setCallSign(medicCallSign)
	medicPoint:onPickUp(medicPointPickupProcess)
	medicPoint.action = dropOrExtractAction
	medicPoint.associatedObjectName = associatedObjectName
	medicPointList[medicCallSign] = medicPoint
	table.insert(rendezvousPoints,medicPoint)
	for pidx=1,8 do
		p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			if p.medicPointButton == nil then
				p.medicPointButton = {}
			end
			p.medicPointButton[medicCallSign] = true
			local tempButton = medicCallSign
			p:addCustomButton("Engineering",tempButton,string.format("Prep to %s via %s",dropOrExtractAction,medicCallSign),function()
				for pidx=1,8 do
					p = getPlayerShip(pidx)
					if p ~= nil and p:isValid() then
						for mpb, enabled in pairs(p.medicPointButton) do
							if enabled then
								p:removeCustom(mpb)
								p:addCustomMessage("Engineering","mtpbgone",string.format("Transporters ready for medical team via %s",mpb))
								p.medicPointButton[mpb] = false
							end
						end
					end
				end
			end)
		end
	end
end
function medicPointPickupProcess(self,retriever)
	local medicCallSign = self:getCallSign()
	local medicPointPrepped = false
	for mpCallSign, mp in pairs(medicPointList) do
		if mpCallSign == medicCallSign then
			medicPointList[medicCallSign] = nil
		end
	end
	for rpi, rp in pairs(rendezvousPoints) do
		if rp:getCallSign() == medicCallSign then
			table.remove(rendezvousPoints,rpi)
		end
	end
	for pidx=1,8 do
		p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			for mpb, enabled in pairs(p.medicPointButton) do
				if mpb == medicCallSign then
					if not enabled then
						medicPointPrepped = true
						break
					end
				end
			end
			if medicPointPrepped then
				p:removeCustom(medicCallSign)
				if p == retriever then
					local completionMessage = string.format("Medical team %s action successful via %s",self.action,medicCallSign)
					if self.associatedObjectName ~= nil then
						if self.action == "Drop" then
							completionMessage = string.format("Medical team drop action on %s successful via %s",self.associatedObjectName,medicCallSign)
						else
							completionMessage = string.format("Medical team extract action from %s successful via %s",self.associatedObjectName,medicCallSign)
						end
					end
					retriever:addToShipLog(completionMessage,"Green")
					if retriever:getEnergy() > 50 then
						retriever:setEnergy(retriever:getEnergy() - 50)
					else
						retriever:setEnergy(0)
					end
				end
			else
				local rpx, rpy = self:getPosition()
				local unscannedDescription = string.format("Medical team %s Point",self.action)
				local scannedDescription = string.format("Medical team %s Point %s, standing by for medical team transport",self.action,medicCallSign)
				if self.associatedObjectName ~= nil then
					scannedDescription = scannedDescription .. ": " .. self.associatedObjectName
				end
				if medicPointList[medicCallSign] == nil then
					local redoMedicalPoint = Artifact():setPosition(rpx,rpy):setScanningParameters(1,1):setRadarSignatureInfo(1,.5,0):setModel("SensorBuoyMKI"):setDescriptions(unscannedDescription,scannedDescription):setCallSign(medicCallSign)
					redoMedicalPoint:onPickUp(medicPointPickupProcess)
					redoMedicalPoint.action = self.action
					redoMedicalPoint.associatedObjectName = self.associatedObjectName
					medicPointList[medicCallSign] = redoMedicalPoint
					table.insert(rendezvousPoints,redoMedicalPoint)
				end
			end
		end
	end
end
--Create medical team point near to selected object(s)
function medicNearTo()
	clearGMFunctions()
	addGMFunction("-Main",initialGMFunctions)
	addGMFunction("-Drop Point",dropPoint)
	addGMFunction("-From Medic Near To",setMedicPoint)
	local objectList = getGMSelection()
	if #objectList < 1 then
		addGMMessage("Nothing selected. No action taken.")
		return
	end
	--print("got something in selection list")
	nearx = 0
	neary = 0
	if #objectList > 1 then
		nearx, neary = centerOfSelected(objectList)
	else
		nearx, neary = objectList[1]:getPosition()	
	end
	--print(string.format("nearx: %.1f, neary: %.1f",nearx,neary))
	local nearbyObjects = getObjectsInRadius(nearx, neary, 20000)
	cpuShipList = {}
	for i=1,#nearbyObjects do
		local tempObject = nearbyObjects[i]
		local tempType = tempObject.typeName
		if tempType == "CpuShip" then
			table.insert(cpuShipList,tempObject)
		end
		if #cpuShipList >= 3 then
			break
		end
	end
	if #cpuShipList > 0 then
		if #cpuShipList >= 1 then
			GMMedicAssociatedToCpuShip1 = string.format("Associate to %s",cpuShipList[1]:getCallSign())
			addGMFunction(GMMedicAssociatedToCpuShip1,medicAssociatedToCpuShip1)
		end
		if #cpuShipList >= 2 then
			GMMedicAssociatedToCpuShip2 = string.format("Associate to %s",cpuShipList[2]:getCallSign())
			addGMFunction(GMMedicAssociatedToCpuShip2,medicAssociatedToCpuShip2)
		end
		if #cpuShipList >= 3 then
			GMMedicAssociatedToCpuShip3 = string.format("Associate to %s",cpuShipList[3]:getCallSign())
			addGMFunction(GMMedicAssociatedToCpuShip3,medicAssociatedToCpuShip3)
		end
	end
	callingNearTo = medicNearTo
	GMSetCreateDirection = createDirection .. " Degrees"
	addGMFunction(string.format("+%s",GMSetCreateDirection),setCreateDirection)
	GMSetCreateDistance = createDistance .. " Units"
	addGMFunction(string.format("+%s",GMSetCreateDistance),setCreateDistance)
	GMCreateMedicAway = "Create at " .. createDirection .. " Deg, " .. createDistance .. "U"
	addGMFunction(GMCreateMedicAway,createMedicAway)
end
function medicAssociatedToCpuShip1()
	medicAssociatedToGivenCpuShip(cpuShipList[1])
end
function medicAssociatedToCpuShip2()
	medicAssociatedToGivenCpuShip(cpuShipList[2])
end
function medicAssociatedToCpuShip3()
	medicAssociatedToGivenCpuShip(cpuShipList[3])
end
function medicAssociatedToGivenCpuShip(tempObject)
	local medicDistance = associatedTypeDistance["CpuShip"]
	local aox, aoy = tempObject:getPosition()
	local tempShipType = tempObject:getTypeName()
	local csd = shipTemplateDistance[tempShipType]
	if csd ~= nil then
		medicDistance = csd
	end
	local sox, soy = vectorFromAngle(random(0,360),medicDistance)
	medicCreation(aox, aoy, sox, soy)
end
--Medical team point creation after distance and direction parameters set
function createMedicAway()
	local angle = createDirection + 270
	if angle > 360 then 
		angle = angle - 360
	end
	local sox, soy = vectorFromAngle(angle,createDistance*1000)
	medicCreation(nearx, neary, sox, soy)
end
--   ***   Custom supply point
function setCustomSupply()
	clearGMFunctions()
	addGMFunction("-From Supply",dropPoint)
	local GMSetSupplyEnergy = "+Energy " .. supplyEnergy
	addGMFunction(GMSetSupplyEnergy,setSupplyEnergy)
	local GMSetSupplyNuke = "+Nuke " .. supplyNuke
	addGMFunction(GMSetSupplyNuke,setSupplyNuke)
	local GMSetSupplyEMP = "+EMP " .. supplyEMP
	addGMFunction(GMSetSupplyEMP,setSupplyEMP)
	local GMSetSupplyMine = "+Mine " .. supplyMine
	addGMFunction(GMSetSupplyMine,setSupplyMine)
	local GMSetSupplyHoming = "+Homing " .. supplyHoming
	addGMFunction(GMSetSupplyHoming,setSupplyHoming)
	local GMSetSupplyHVLI = "+HVLI " .. supplyHVLI
	addGMFunction(GMSetSupplyHVLI,setSupplyHVLI)
	local GMSetSupplyRepairCrew = "+Repair Crew " .. supplyRepairCrew
	addGMFunction(GMSetSupplyRepairCrew,setSupplyRepairCrew)
	local GMSetSupplyCoolant = "+Coolant " .. supplyCoolant
	addGMFunction(GMSetSupplyCoolant,setSupplyCoolant)
	addGMFunction("+Near to",supplyNearTo)	
end
--Set supply drop energy
function setSupplyEnergy()
	clearGMFunctions()
	addGMFunction("-Main",initialGMFunctions)
	addGMFunction("-Drop Point",dropPoint)
	addGMFunction("-From Energy",setCustomSupply)
	if supplyEnergy > 0 then
		local GMSubtract100Energy = string.format("%i-100=%i",supplyEnergy,supplyEnergy - 100)
		addGMFunction(GMSubtract100Energy,subtract100Energy)
	end
	if supplyEnergy < 1000 then
		local GMAdd100Energy = string.format("%i+100=%i",supplyEnergy,supplyEnergy + 100)
		addGMFunction(GMAdd100Energy,add100Energy)
	end
end
function subtract100Energy()
	supplyEnergy = supplyEnergy - 100
	setSupplyEnergy()
end
function add100Energy()
	supplyEnergy = supplyEnergy + 100
	setSupplyEnergy()
end
--Set supply drop nukes
function setSupplyNuke()
	clearGMFunctions()
	addGMFunction("-Main",initialGMFunctions)
	addGMFunction("-Drop Point",dropPoint)
	addGMFunction("-From Nuke",setCustomSupply)
	if supplyNuke > 0 then
		local GMSubtractANuke = string.format("%i-1=%i",supplyNuke,supplyNuke - 1)
		addGMFunction(GMSubtractANuke,subtractANuke)
	end
	if supplyNuke < 20 then
		local GMAddANuke = string.format("%i+1=%i",supplyNuke,supplyNuke + 1)
		addGMFunction(GMAddANuke,addANuke)
	end
end
function subtractANuke()
	supplyNuke = supplyNuke - 1
	setSupplyNuke()
end
function addANuke()
	supplyNuke = supplyNuke + 1
	setSupplyNuke()
end
--Set supply drop EMPs
function setSupplyEMP()
	clearGMFunctions()
	addGMFunction("-Main",initialGMFunctions)
	addGMFunction("-Drop Point",dropPoint)
	addGMFunction("-From EMP",setCustomSupply)
	if supplyEMP > 0 then
		local GMSubtractAnEMP = string.format("%i-1=%i",supplyEMP,supplyEMP - 1)
		addGMFunction(GMSubtractAnEMP,subtractAnEMP)
	end
	if supplyEMP < 20 then
		local GMAddAnEMP = string.format("%i+1=%i",supplyEMP,supplyEMP + 1)
		addGMFunction(GMAddAnEMP,addAnEMP)
	end
end
function subtractAnEMP()
	supplyEMP = supplyEMP - 1
	setSupplyEMP()
end
function addAnEMP()
	supplyEMP = supplyEMP + 1
	setSupplyEMP()
end
--Set supply drop Mines
function setSupplyMine()
	clearGMFunctions()
	addGMFunction("-Main",initialGMFunctions)
	addGMFunction("-Drop Point",dropPoint)
	addGMFunction("-From Mine",setCustomSupply)
	if supplyMine > 0 then
		local GMSubtractAMine = string.format("%i-1=%i",supplyMine,supplyMine - 1)
		addGMFunction(GMSubtractAMine,subtractAMine)
	end
	if supplyMine < 20 then
		local GMAddAMine = string.format("%i+1=%i",supplyMine,supplyMine + 1)
		addGMFunction(GMAddAMine,addAMine)
	end
end
function subtractAMine()
	supplyMine = supplyMine - 1
	setSupplyMine()
end
function addAMine()
	supplyMine = supplyMine + 1
	setSupplyMine()
end
--set supply drop Homings
function setSupplyHoming()
	clearGMFunctions()
	addGMFunction("-Main",initialGMFunctions)
	addGMFunction("-Drop Point",dropPoint)
	addGMFunction("-From Homing",setCustomSupply)
	if supplyHoming > 0 then
		local GMSubtractAHoming = string.format("%i-1=%i",supplyHoming,supplyHoming - 1)
		addGMFunction(GMSubtractAHoming,subtractAHoming)
	end
	if supplyHoming < 20 then
		local GMAddAHoming = string.format("%i+1=%i",supplyHoming,supplyHoming + 1)
		addGMFunction(GMAddAHoming,addAHoming)
	end
end
function subtractAHoming()
	supplyHoming = supplyHoming - 1
	setSupplyHoming()
end
function addAHoming()
	supplyHoming = supplyHoming + 1
	setSupplyHoming()
end
--Set supply drop HVLIs
function setSupplyHVLI()
	clearGMFunctions()
	addGMFunction("-Main",initialGMFunctions)
	addGMFunction("-Drop Point",dropPoint)
	addGMFunction("-From HVLI",setCustomSupply)
	if supplyHVLI > 0 then
		local GMSubtractAnHVLI = string.format("%i-1=%i",supplyHVLI,supplyHVLI - 1)
		addGMFunction(GMSubtractAnHVLI,subtractAnHVLI)
	end
	if supplyHVLI < 20 then
		local GMAddAnHVLI = string.format("%i+1=%i",supplyHVLI,supplyHVLI + 1)
		addGMFunction(GMAddAnHVLI,addAnHVLI)
	end
end
function subtractAnHVLI()
	supplyHVLI = supplyHVLI - 1
	setSupplyHVLI()
end
function addAnHVLI()
	supplyHVLI = supplyHVLI + 1
	setSupplyHVLI()
end
--Set supply drop repair crew
function setSupplyRepairCrew()
	clearGMFunctions()
	addGMFunction("-Main",initialGMFunctions)
	addGMFunction("-Drop Point",dropPoint)
	addGMFunction("-From Repair Crew",setCustomSupply)
	if supplyRepairCrew > 0 then
		local GMSubtractARepairCrew = string.format("%i-1=%i",supplyRepairCrew,supplyRepairCrew - 1)
		addGMFunction(GMSubtractARepairCrew,subtractARepairCrew)
	end
	if supplyRepairCrew < 3 then
		local GMAddARepairCrew = string.format("%i+1=%i",supplyRepairCrew,supplyRepairCrew + 1)
		addGMFunction(GMAddARepairCrew,addARepairCrew)
	end
end
function subtractARepairCrew()
	supplyRepairCrew = supplyRepairCrew - 1
	setSupplyRepairCrew()
end
function addARepairCrew()
	supplyRepairCrew = supplyRepairCrew + 1
	setSupplyRepairCrew()
end
--Set supply drop coolant
function setSupplyCoolant()
	clearGMFunctions()
	addGMFunction("-Main",initialGMFunctions)
	addGMFunction("-Drop Point",dropPoint)
	addGMFunction("-From Coolant",setCustomSupply)
	if supplyCoolant > 0 then
		local GMSubtractCoolant = string.format("%i-1=%i",supplyCoolant,supplyCoolant - 1)
		addGMFunction(GMSubtractCoolant,subtractCoolant)
	end
	if supplyCoolant < 5 then
		local GMAddCoolant = string.format("%i+1=%i",supplyCoolant,supplyCoolant + 1)
		addGMFunction(GMAddCoolant,addCoolant)
	end
end
function subtractCoolant()
	supplyCoolant = supplyCoolant - 1
	setSupplyCoolant()
end
function addCoolant()
	supplyCoolant = supplyCoolant + 1
	setSupplyCoolant()
end
--Create supply drop near to selected object(s)
function supplyNearTo()
	clearGMFunctions()
	addGMFunction("-Main",initialGMFunctions)
	addGMFunction("-Drop Point",dropPoint)
	addGMFunction("-From Supply Near To",setCustomSupply)
	local objectList = getGMSelection()
	if #objectList < 1 then
		addGMMessage("Nothing selected to relate to supply drop. No action taken")
		return
	end
	nearx = 0
	neary = 0
	if #objectList > 1 then
		nearx, neary = centerOfSelected(objectList)
	else
		nearx, neary = objectList[1]:getPosition()	
	end
	local nearbyObjects = getObjectsInRadius(nearx, neary, 20000)
	callingNearTo = supplyNearTo
	GMSetCreateDirection = createDirection .. " Degrees"
	addGMFunction(string.format("+%s",GMSetCreateDirection),setCreateDirection)
	GMSetCreateDistance = createDistance .. " Units"
	addGMFunction(string.format("+%s",GMSetCreateDistance),setCreateDistance)
	GMCreateSupplyAway = "Create at " .. createDirection .. " Deg, " .. createDistance .. "U"
	addGMFunction(GMCreateSupplyAway,createSupplyAway)
end
function createSupplyAway()
	local angle = createDirection + 270
	if angle > 360 then 
		angle = angle - 360
	end
	local sox, soy = vectorFromAngle(angle,createDistance*1000)
	supplyCreation(nearx, neary, sox, soy)
end
function supplyCreation(originx, originy, vectorx, vectory)
	local customSupplyDrop = SupplyDrop():setEnergy(supplyEnergy):setFaction("Human Navy"):setPosition(originx+vectorx,originy+vectory)
	customSupplyDrop:setWeaponStorage("Nuke",supplyNuke)
	customSupplyDrop:setWeaponStorage("EMP",supplyEMP)
	customSupplyDrop:setWeaponStorage("Homing",supplyHoming)
	customSupplyDrop:setWeaponStorage("Mine",supplyMine)
	customSupplyDrop:setWeaponStorage("HVLI",supplyHVLI)
	if supplyRepairCrew > 0 then
		customSupplyDrop.repairCrew = supplyRepairCrew
	end
	if supplyCoolant > 0 then
		customSupplyDrop.coolant = supplyCoolant
	end
	local supplyLabel = ""
	if supplyEnergy > 0 then
		supplyLabel = supplyLabel .. string.format("B%i ",supplyEnergy)
	end
	if supplyNuke > 0 then
		supplyLabel = supplyLabel .. string.format("N%i ",supplyNuke)
	end
	if supplyEMP > 0 then
		supplyLabel = supplyLabel .. string.format("E%i ",supplyEMP)
	end
	if supplyMine > 0 then
		supplyLabel = supplyLabel .. string.format("M%i ",supplyMine)
	end
	if supplyHoming > 0 then
		supplyLabel = supplyLabel .. string.format("H%i ",supplyHoming)
	end
	if supplyHVLI > 0 then
		supplyLabel = supplyLabel .. string.format("L%i ",supplyHVLI)
	end
	if supplyRepairCrew > 0 then
		supplyLabel = supplyLabel .. string.format("R%i ",supplyRepairCrew)
	end
	if supplyCoolant > 0 then
		supplyLabel = supplyLabel .. string.format("C%i ",supplyCoolant)
	end
	customSupplyDrop:setCallSign(supplyLabel)
	customSupplyDrop:onPickUp(supplyPickupProcess)
end
function supplyPickupProcess(self, player)
	string.format("")	--necessary to have global reference for Serious Proton engine
	if self.repairCrew ~= nil then
		player:setRepairCrewCount(player:getRepairCrewCount() + self.repairCrew)
	end
	if self.coolant ~= nil then
		player:setMaxCoolant(player:getMaxCoolant() + self.coolant)
	end
end
-----------------
--	Scan Clue  --
-----------------
function scanClue()
	clearGMFunctions()
	addGMFunction("-Main from Scan Clue",initialGMFunctions)
	addGMFunction("+Unscanned Desc",setUnscannedDescription)
	addGMFunction("+Scanned Desc",setScannedDescription)
	local GMSetScanComplexity = "+Scan Complex: " .. scanComplexity
	addGMFunction(GMSetScanComplexity,setScanComplexity)
	local GMSetScanDepth = "+Scan Depth: " .. scanDepth
	addGMFunction(GMSetScanDepth,setScanDepth)
	if scan_clue_retrievable then
		addGMFunction("Retrievable",function()
			scan_clue_retrievable = false
			scanClue()
		end)
	else
		addGMFunction("Unretrievable",function()
			scan_clue_retrievable = true
			scanClue()
		end)
	end
	addGMFunction("+Near To",scanClueNearTo)
end
function setUnscannedDescription()
	clearGMFunctions()
	addGMFunction("-Main",initialGMFunctions)
	addGMFunction("-From Unscan Desc",scanClue)
	for uck, ucv in pairs(unscannedClues) do
		local GMShortUnscannedClue = uck
		if uck == unscannedClueKey then
			GMShortUnscannedClue = uck .. "*"
		end
		addGMFunction(GMShortUnscannedClue,function()
			unscannedClueKey = uck
			setUnscannedDescription()
		end)
	end
end
function setScannedDescription()
	clearGMFunctions()
	addGMFunction("-Main",initialGMFunctions)
	addGMFunction("-From Scan Desc",scanClue)
	addGMFunction(scannedClueKey1,scannedClue1)
	addGMFunction(scannedClueKey2,scannedClue2)
	addGMFunction(scannedClueKey3,scannedClue3)
	addGMFunction(scannedClueKey4,scannedClue4)
	addGMFunction(scannedClueKey5,scannedClue5)
end
function scannedClue1()
	clearGMFunctions()
	addGMFunction("-Main",initialGMFunctions)
	addGMFunction("-Scan",scanClue)
	addGMFunction("-From Desc 1",setScannedDescription)
	for sck, scv in pairs(scannedClues1) do
		local GMShortScannedClue = sck
		if sck == scannedClueKey1 then
			GMShortScannedClue = sck .. "*"
		end
		addGMFunction(GMShortScannedClue, function()
			scannedClueKey1 = sck
			scannedClue1()
		end)
	end
end
function scannedClue2()
	clearGMFunctions()
	addGMFunction("-Main",initialGMFunctions)
	addGMFunction("-Scan",scanClue)
	addGMFunction("-From Desc 2",setScannedDescription)
	for sck, scv in pairs(scannedClues2) do
		local GMShortScannedClue = sck
		if sck == scannedClueKey2 then
			GMShortScannedClue = sck .. "*"
		end
		addGMFunction(GMShortScannedClue, function()
			scannedClueKey2 = sck
			scannedClue2()
		end)
	end
end
function scannedClue3()
	clearGMFunctions()
	addGMFunction("-Main",initialGMFunctions)
	addGMFunction("-Scan",scanClue)
	addGMFunction("-From Desc 3",setScannedDescription)
	for sck, scv in pairs(scannedClues3) do
		local GMShortScannedClue = sck
		if sck == scannedClueKey3 then
			GMShortScannedClue = sck .. "*"
		end
		addGMFunction(GMShortScannedClue, function()
			scannedClueKey3 = sck
			scannedClue3()
		end)
	end
end
function scannedClue4()
	clearGMFunctions()
	addGMFunction("-Main",initialGMFunctions)
	addGMFunction("-Scan",scanClue)
	addGMFunction("-From Desc 4",setScannedDescription)
	for sck, scv in pairs(scannedClues4) do
		local GMShortScannedClue = sck
		if sck == scannedClueKey4 then
			GMShortScannedClue = sck .. "*"
		end
		addGMFunction(GMShortScannedClue, function()
			scannedClueKey4 = sck
			scannedClue4()
		end)
	end
end
function scannedClue5()
	clearGMFunctions()
	addGMFunction("-Main",initialGMFunctions)
	addGMFunction("-Scan",scanClue)
	addGMFunction("-From Desc 5",setScannedDescription)
	for sck, scv in pairs(scannedClues5) do
		local GMShortScannedClue = sck
		if sck == scannedClueKey5 then
			GMShortScannedClue = sck .. "*"
		end
		addGMFunction(GMShortScannedClue, function()
			scannedClueKey5 = sck
			scannedClue5()
		end)
	end
end
function setScanComplexity()
	clearGMFunctions()
	addGMFunction("-Main",initialGMFunctions)
	addGMFunction("-Scan",scanClue)
	for i=1,4 do
		local GMSetScanComplexityIndex = "Complexity: " .. i
		if scanComplexity == i then
			GMSetScanComplexityIndex = "Complexity: " .. i .. "*"
		end
		addGMFunction(GMSetScanComplexityIndex, function()
			scanComplexity = i
			setScanComplexity()
		end)
	end
end
function setScanDepth()
	clearGMFunctions()
	addGMFunction("-Main",initialGMFunctions)
	addGMFunction("-Scan",scanClue)
	for i=1,8 do
		local GMSetScanDepthIndex = "Depth: " .. i
		if scanDepth == i then
			GMSetScanDepthIndex = "Depth: " .. i .. "*"
		end
		addGMFunction(GMSetScanDepthIndex, function()
			scanDepth = i
			setScanDepth()
		end)
	end
end
function scanClueNearTo()
	clearGMFunctions()
	addGMFunction("-Main",initialGMFunctions)
	addGMFunction("-From Scan Near To",scanClue)
	local objectList = getGMSelection()
	if #objectList < 1 then
		addGMMessage("You need to select something. No action taken")
		return
	end
	nearx = 0
	neary = 0
	if #objectList > 1 then
		nearx, neary = centerOfSelected(objectList)
	else
		nearx, neary = objectList[1]:getPosition()	
	end
	--print(string.format("nearx: %.1f, neary: %.1f",nearx,neary))
	callingNearTo = scanClueNearTo
	GMSetCreateDirection = createDirection .. " Degrees"
	addGMFunction(string.format("+%s",GMSetCreateDirection),setCreateDirection)
	GMSetCreateDistance = createDistance .. " Units"
	addGMFunction(string.format("+%s",GMSetCreateDistance),setCreateDistance)
	GMCreateScanClueAway = "Create at " .. createDirection .. " Deg, " .. createDistance .. "U"
	addGMFunction(GMCreateScanClueAway,createScanClueAway)
end
function createScanClueAway()
	local angle = createDirection + 270
	if angle > 360 then 
		angle = angle - 360
	end
	local sox, soy = vectorFromAngle(angle,createDistance*1000)
	scanClueCreation(nearx, neary, sox, soy)
end
function scanClueCreation(originx, originy, vectorx, vectory, associatedObjectName)
	artifactCounter = artifactCounter + 1
	artifactNumber = artifactNumber + math.random(1,5)
	local randomPrefix = string.char(math.random(65,90))
	local medicCallSign = string.format("%s%i",randomPrefix,artifactNumber)
	local unscannedDescription = unscannedClues[unscannedClueKey]
	local scannedDescription = ""
	if scannedClues1[scannedClueKey1] ~= nil and scannedClues1[scannedClueKey1] ~= "None" then
		scannedDescription = scannedDescription .. scannedClues1[scannedClueKey1] .. " "
	end
	if scannedClues2[scannedClueKey2] ~= nil and scannedClues2[scannedClueKey2] ~= "None" then
		scannedDescription = scannedDescription .. scannedClues2[scannedClueKey2] .. " "
	end
	if scannedClues3[scannedClueKey3] ~= nil and scannedClues3[scannedClueKey3] ~= "None" then
		scannedDescription = scannedDescription .. scannedClues3[scannedClueKey3] .. " "
	end
	if scannedClues4[scannedClueKey4] ~= nil and scannedClues4[scannedClueKey4] ~= "None" then
		scannedDescription = scannedDescription .. scannedClues4[scannedClueKey4] .. " "
	end
	if scannedClues5[scannedClueKey5] ~= nil and scannedClues5[scannedClueKey5] ~= "None" then
		scannedDescription = scannedDescription .. scannedClues5[scannedClueKey5] .. " "
	end
	local scanCluePoint = Artifact():setPosition(originx+vectorx,originy+vectory):setScanningParameters(scanComplexity,scanDepth):setRadarSignatureInfo(random(0,1),random(0,1),random(0,1)):setDescriptions(unscannedDescription,scannedDescription)
	if scan_clue_retrievable then
		scanCluePoint:allowPickup(true)
	else
		scanCluePoint:allowPickup(false)
	end
	table.insert(scanClueList,scanCluePoint)
end
---------------------
--	Tweak Terrain  --
---------------------
function tweakTerrain()
	clearGMFunctions()
	addGMFunction("-Main",initialGMFunctions)
	addGMFunction("Explode Sel Art",explodeSelectedArtifact)
	addGMFunction("Pulse Asteroid",pulseAsteroid)
end
function explodeSelectedArtifact()
	local objectList = getGMSelection()
	if #objectList ~= 1 then
		addGMMessage("You need to select an object. No action taken.")
		return
	end
	local tempObject = objectList[1]
	local tempType = tempObject.typeName
	if tempType ~= "Artifact" then
		addGMMessage("Only select an artifact since only artifacts explode. No action taken.")
		return
	end
	tempObject:explode()
end
function pulseAsteroid()
	local objectList = getGMSelection()
	if #objectList ~= 1 then
		addGMMessage("You need to select an object. No action taken.")
		return
	end
	local tempObject = objectList[1]
	local tempType = tempObject.typeName
	if tempType ~= "Asteroid" then
		addGMMessage("Only select an asteroid. No action taken.")
		return
	end
	local selected_in_list = false
	for i=1,#J4_to_L8_asteroids do
		if tempObject == J4_to_L8_asteroids[i] then
			selected_in_list = true
			break
		end
	end
	if selected_in_list then
		if tempObject.original_size == nil then
			addGMMessage("selected has a nil value where it should have an original_size. No action taken")
			return
		end
		if tempObject.original_size < 120 then
			tempObject.grow = true
			tempObject.max_size = 300
			tempObject.increment = (300 - tempObject.original_size)/10
			plotPulse = growAsteroid
		else
			tempObject.shrink = true
			tempObject.min_size = tempObject.original_size/2
			tempObject.increment = (tempObject.original_size - (tempObject.original_size/2))/10
			plotPulse = shrinkAsteroid
		end
		if pulse_asteroid_list == nil then
			pulse_asteroid_list = {}
		end
		table.insert(pulse_asteroid_list,tempObject)
	else
		addGMMessage("Only asteroids in J4 to L8 can pulse. No action taken")
		return
	end
end
function growAsteroid(delta)
	if pulse_asteroid_list ~= nil then
		if #pulse_asteroid_list > 0 then
			for i=1,#pulse_asteroid_list do
				local ta = pulse_asteroid_list[i]
				if ta ~= nil and ta:isValid() then
					if ta.grow_size == nil then
						ta.grow_size = ta.original_size
					end
					ta.grow_size = ta.grow_size + ta.increment
					ta:setSize(ta.grow_size)
					print(string.format("grow_size: %.1f, max_size: %.1f",ta.grow_size,ta.max_size))
					if ta.grow_size >= ta.max_size then
						--end of growth
						print("end of growth")
						resetPulsingAsteroid(ta)
					end
				end
			end
		end
	end
end
function resetPulsingAsteroid(ta)
	ta.grow = nil
	ta.shrink = nil
	ta.max_size = nil
	ta.min_size = nil
	ta.grow_size = nil
	ta.shrink_size = nil
	ta:setSize(ta.original_size)
	for i=1,#pulse_asteroid_list do
		if ta == pulse_asteroid_list[i] then
			table.remove(pulse_asteroid_list,i)
			break
		end
	end
	print("done resetting")
end
function shrinkAsteroid(delta)
	if pulse_asteroid_list ~= nil then
		if #pulse_asteroid_list > 0 then
			for i=1,#pulse_asteroid_list do
				local ta = pulse_asteroid_list[i]
				if ta ~= nil and ta:isValid() then
					if ta.shrink_size == nil then
						ta.shrink_size = ta.original_size
					end
					ta.shrink_size = ta.shrink_size - ta.increment
					ta:setSize(ta.shrink_size)
					print(string.format("shrink_size: %.1f, min_size: %.1f",ta.shrink_size,ta.min_size))
					if ta.shrink_size <= ta.min_size then
						--end of shrink
						print("end of shrink")
						resetPulsingAsteroid(ta)
					end
				end
			end
		end
	end
end
-----------------------
--	Countdown Timer  --
-----------------------
function countdownTimer()
	clearGMFunctions()
	addGMFunction("-Main from Timer",initialGMFunctions)
	local timer_display = "+Display: GM"
	if timer_display_helm then
		timer_display = timer_display .. ",H"
	end
	if timer_display_weapons then
		timer_display = timer_display .. ",W"
	end
	if timer_display_engineer then
		timer_display = timer_display .. ",E"
	end
	if timer_display_science then
		timer_display = timer_display .. ",S"
	end
	if timer_display_relay then
		timer_display = timer_display .. ",R"
	end
	addGMFunction(timer_display,GMTimerDisplay)
	addGMFunction(string.format("+Length: %i",timer_start_length),GMTimerLength)
	addGMFunction(string.format("+Purpose: %s",timer_purpose),GMTimerPurpose)
	if timer_started then
		addGMFunction("Stop Timer", function()
			timer_started = false
			countdownTimer()
		end)
	else
		addGMFunction("Start Timer", function()
			timer_started = true
			countdownTimer()
		end)
	end
end
function GMTimerPurpose()
	clearGMFunctions()
	addGMFunction("-Main from Timer",initialGMFunctions)
	addGMFunction("-From Purpose",countdownTimer)
	local purpose_label = ""
	if timer_purpose == "Timer" then
		purpose_label = "Timer*"
	else
		purpose_label = "Timer"
	end
	addGMFunction(purpose_label, function()
		timer_purpose = "Timer"
		GMTimerPurpose()
	end)
	if timer_purpose == "Death" then
		purpose_label = "Death*"
	else
		purpose_label = "Death"
	end
	addGMFunction(purpose_label, function()
		timer_purpose = "Death"
		GMTimerPurpose()
	end)
	if timer_purpose == "Breakdown" then
		purpose_label = "Breakdown*"
	else
		purpose_label = "Breakdown"
	end
	addGMFunction(purpose_label, function()
		timer_purpose = "Breakdown"
		GMTimerPurpose()
	end)
	if timer_purpose == "Mission" then
		purpose_label = "Mission*"
	else
		purpose_label = "Mission"
	end
	addGMFunction(purpose_label, function()
		timer_purpose = "Mission"
		GMTimerPurpose()
	end)
	if timer_purpose == "Departure" then
		purpose_label = "Departure*"
	else
		purpose_label = "Departure"
	end
	addGMFunction(purpose_label, function()
		timer_purpose = "Departure"
		GMTimerPurpose()
	end)
	if timer_purpose == "Destruction" then
		purpose_label = "Destruction*"
	else
		purpose_label = "Destruction"
	end
	addGMFunction(purpose_label, function()
		timer_purpose = "Destruction"
		GMTimerPurpose()
	end)
	if timer_purpose == "Discovery" then
		purpose_label = "Discovery*"
	else
		purpose_label = "Discovery"
	end
	addGMFunction(purpose_label, function()
		timer_purpose = "Discovery"
		GMTimerPurpose()
	end)
end
function GMTimerLength()
	clearGMFunctions()
	addGMFunction("-Main from Timer",initialGMFunctions)
	addGMFunction("-From Length",countdownTimer)
	local length_label = ""
	if timer_start_length == 1 then
		length_label = "1 Minute*"
	else
		length_label = "1 Minute"
	end
	addGMFunction(length_label, function()
		timer_start_length = 1
		GMTimerLength()
	end)
	if timer_start_length == 3 then
		length_label = "3 Minutes*"
	else
		length_label = "3 Minutes"
	end
	addGMFunction(length_label, function()
		timer_start_length = 3
		GMTimerLength()
	end)
	if timer_start_length == 5 then
		length_label = "5 Minutes*"
	else
		length_label = "5 Minutes"
	end
	addGMFunction(length_label, function()
		timer_start_length = 5
		GMTimerLength()
	end)
	if timer_start_length == 10 then
		length_label = "10 Minutes*"
	else
		length_label = "10 Minutes"
	end
	addGMFunction(length_label, function()
		timer_start_length = 10
		GMTimerLength()
	end)
	if timer_start_length == 15 then
		length_label = "15 Minutes*"
	else
		length_label = "15 Minutes"
	end
	addGMFunction(length_label, function()
		timer_start_length = 15
		GMTimerLength()
	end)
	if timer_start_length == 20 then
		length_label = "20 Minutes*"
	else
		length_label = "20 Minutes"
	end
	addGMFunction(length_label, function()
		timer_start_length = 20
		GMTimerLength()
	end)
	if timer_start_length == 30 then
		length_label = "30 Minutes*"
	else
		length_label = "30 Minutes"
	end
	addGMFunction(length_label, function()
		timer_start_length = 30
		GMTimerLength()
	end)
	if timer_start_length == 45 then
		length_label = "45 Minutes*"
	else
		length_label = "45 Minutes"
	end
	addGMFunction(length_label, function()
		timer_start_length = 45
		GMTimerLength()
	end)
end
function GMTimerDisplay()
	clearGMFunctions()
	addGMFunction("-Main from Timer",initialGMFunctions)
	addGMFunction("-From Display",countdownTimer)
	local timer_label = "Helm"
	if timer_display_helm then
		timer_label = timer_label .. "*"
	end
	addGMFunction(timer_label, function()
		if timer_display_helm then
			timer_display_helm = false
		else
			timer_display_helm = true
		end
		GMTimerDisplay()
	end)
	timer_label = "Weapons"
	if timer_display_weapons then
		timer_label = timer_label .. "*"
	end
	addGMFunction(timer_label, function()
		if timer_display_weapons then
			timer_display_weapons = false
		else
			timer_display_weapons = true
		end
		GMTimerDisplay()
	end)
	timer_label = "Engineer"
	if timer_display_engineer then
		timer_label = timer_label .. "*"
	end
	addGMFunction(timer_label, function()
		if timer_display_engineer then
			timer_display_engineer = false
		else
			timer_display_engineer = true
		end
		GMTimerDisplay()
	end)
	timer_label = "Science"
	if timer_display_science then
		timer_label = timer_label .. "*"
	end
	addGMFunction(timer_label, function()
		if timer_display_science then
			timer_display_science = false
		else
			timer_display_science = true
		end
		GMTimerDisplay()
	end)
	timer_label = "Relay"
	if timer_display_relay then
		timer_label = timer_label .. "*"
	end
	addGMFunction(timer_label, function()
		if timer_display_relay then
			timer_display_relay = false
		else
			timer_display_relay = true
		end
		GMTimerDisplay()
	end)
end
-------------------
--	End Mission  --
-------------------
function endMission()
	clearGMFunctions()
	addGMFunction("-Main from End",initialGMFunctions)
	addGMFunction("Human Victory",function()
		victory("Human Navy")
	end)
	addGMFunction("Kraylor Victory",function()
		victory("Kraylor")
	end)
	addGMFunction("Exuari Victory",function() 
		victory("Exuari")
	end)
	addGMFunction("Ghost Victory",function() 
		victory("Ghosts")
	end)
	addGMFunction("Arlenian Victory",function() 
		victory("Arlenians")	
	end)
	addGMFunction("Independent Victory",function() 
		victory("Independent")
	end)
	addGMFunction("Ktlitan Victory",function() 
		victory("Ktlitans")
	end)
	addGMFunction("TSN Victory",function()
		victory("TSN")
	end)
	addGMFunction("USN Victory",function()
		victory("USN")
	end)
	addGMFunction("CUF Victory",function()
		victory("CUF")
	end)
end
--------------------------
--	Ship communication  --
--------------------------
function commsShip()
	if comms_target.comms_data == nil then
		comms_target.comms_data = {friendlyness = random(0.0, 100.0)}
	end
	comms_data = comms_target.comms_data
	if comms_data.goods == nil then
		comms_data.goods = {}
		comms_data.goods[commonGoods[math.random(1,#commonGoods)]] = {quantity = 1, cost = random(20,80)}
		local shipType = comms_target:getTypeName()
		if shipType:find("Freighter") ~= nil then
			if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
				repeat
					comms_data.goods[commonGoods[math.random(1,#commonGoods)]] = {quantity = 1, cost = random(20,80)}
					local goodCount = 0
					for good, goodData in pairs(comms_data.goods) do
						goodCount = goodCount + 1
					end
				until(goodCount >= 3)
			end
		end
	end
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
		local shields = comms_target:getShieldCount()
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
	if comms_target.fleet ~= nil then
		--not used since there are not friendly fleets (yet)
		addCommsReply(string.format("Direct %s",comms_target.fleet), function()
			setCommsMessage(string.format("What command should be given to %s?",comms_target.fleet))
			addCommsReply("Report hull and shield status", function()
				msg = "Fleet status:"
				for _, fleetShip in ipairs(friendlyDefensiveFleetList[comms_target.fleet]) do
					if fleetShip ~= nil and fleetShip:isValid() then
						msg = msg .. "\n  " .. fleetShip:getCallSign() .. ":"
						msg = msg .. "\n    Hull: " .. math.floor(fleetShip:getHull() / fleetShip:getHullMax() * 100) .. "%"
						local shields = fleetShip:getShieldCount()
						if shields == 1 then
							msg = msg .. "\n    Shield: " .. math.floor(fleetShip:getShieldLevel(0) / fleetShip:getShieldMax(0) * 100) .. "%"
						else
							msg = msg .. "\n    Shields: "
							if shields == 2 then
								msg = msg .. "Front:" .. math.floor(fleetShip:getShieldLevel(0) / fleetShip:getShieldMax(0) * 100) .. "% Rear:" .. math.floor(fleetShip:getShieldLevel(1) / fleetShip:getShieldMax(1) * 100) .. "%"
							else
								for n=0,shields-1 do
									msg = msg .. " " .. n .. ":" .. math.floor(fleetShip:getShieldLevel(n) / fleetShip:getShieldMax(n) * 100) .. "%"
								end
							end
						end
					end
				end
				setCommsMessage(msg)
				addCommsReply("Back", commsShip)
			end)
			addCommsReply("Report missile status", function()
				msg = "Fleet missile status:"
				for _, fleetShip in ipairs(friendlyDefensiveFleetList[comms_target.fleet]) do
					if fleetShip ~= nil and fleetShip:isValid() then
						msg = msg .. "\n  " .. fleetShip:getCallSign() .. ":"
						local missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
						missileMsg = ""
						for _, missile_type in ipairs(missile_types) do
							if fleetShip:getWeaponStorageMax(missile_type) > 0 then
								missileMsg = missileMsg .. "\n      " .. missile_type .. ": " .. math.floor(fleetShip:getWeaponStorage(missile_type)) .. "/" .. math.floor(fleetShip:getWeaponStorageMax(missile_type))
							end
						end
						if missileMsg ~= "" then
							msg = msg .. "\n    Missiles: " .. missileMsg
						end
					end
				end
				setCommsMessage(msg)
				addCommsReply("Back", commsShip)
			end)
			addCommsReply("Assist me", function()
				for _, fleetShip in ipairs(friendlyDefensiveFleetList[comms_target.fleet]) do
					if fleetShip ~= nil and fleetShip:isValid() then
						fleetShip:orderDefendTarget(comms_source)
					end
				end
				setCommsMessage(string.format("%s heading toward you to assist",comms_target.fleet))
				addCommsReply("Back", commsShip)
			end)
			addCommsReply("Defend a waypoint", function()
				if comms_source:getWaypointCount() == 0 then
					setCommsMessage("No waypoints set. Please set a waypoint first.");
					addCommsReply("Back", commsShip)
				else
					setCommsMessage("Which waypoint should we defend?");
					for n=1,comms_source:getWaypointCount() do
						addCommsReply("Defend WP" .. n, function()
							for _, fleetShip in ipairs(friendlyDefensiveFleetList[comms_target.fleet]) do
								if fleetShip ~= nil and fleetShip:isValid() then
									fleetShip:orderDefendLocation(comms_source:getWaypoint(n))
								end
							end
							setCommsMessage("We are heading to assist at WP" .. n ..".");
							addCommsReply("Back", commsShip)
						end)
					end
				end
			end)
			addCommsReply("Go offensive, attack all enemy targets", function()
				for _, fleetShip in ipairs(friendlyDefensiveFleetList[comms_target.fleet]) do
					if fleetShip ~= nil and fleetShip:isValid() then
						fleetShip:orderRoaming()
					end
				end
				setCommsMessage(string.format("%s is on an offensive rampage",comms_target.fleet))
				addCommsReply("Back", commsShip)
			end)
		end)
	end
	local shipType = comms_target:getTypeName()
	if shipType:find("Freighter") ~= nil then
		if distance(comms_source, comms_target) < 5000 then
			if comms_data.friendlyness > 66 then
				if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
					if comms_source.goods ~= nil and comms_source.goods.luxury ~= nil and comms_source.goods.luxury > 0 then
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 and good ~= "luxury" then
								addCommsReply(string.format("Trade luxury for %s",good), function()
									goodData.quantity = goodData.quantity - 1
									if comms_source.goods == nil then
										comms_source.goods = {}
									end
									if comms_source.goods[good] == nil then
										comms_source.goods[good] = 0
									end
									comms_source.goods[good] = comms_source.goods[good] + 1
									comms_source.goods.luxury = comms_source.goods.luxury - 1
									setCommsMessage(string.format("Traded your luxury for %s from %s",good,comms_target:getCallSign()))
									addCommsReply("Back", commsShip)
								end)
							end
						end	--freighter goods loop
					end	--player has luxury branch
				end	--goods or equipment freighter
				if comms_source.cargo > 0 then
					for good, goodData in pairs(comms_data.goods) do
						if goodData.quantity > 0 then
							addCommsReply(string.format("Buy one %s for %i reputation",good,math.floor(goodData.cost)), function()
								if comms_source:takeReputationPoints(goodData.cost) then
									goodData.quantity = goodData.quantity - 1
									if comms_source.goods == nil then
										comms_source.goods = {}
									end
									if comms_source.goods[good] == nil then
										comms_source.goods[good] = 0
									end
									comms_source.goods[good] = comms_source.goods[good] + 1
									comms_source.cargo = comms_source.cargo - 1
									setCommsMessage(string.format("Purchased %s from %s",good,comms_target:getCallSign()))
								else
									setCommsMessage("Insufficient reputation for purchase")
								end
								addCommsReply("Back", commsShip)
							end)
						end
					end	--freighter goods loop
				end	--player has cargo space branch
			elseif comms_data.friendlyness > 33 then
				if comms_source.cargo > 0 then
					if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 then
								addCommsReply(string.format("Buy one %s for %i reputation",good,math.floor(goodData.cost)), function()
									if comms_source:takeReputationPoints(goodData.cost) then
										goodData.quantity = goodData.quantity - 1
										if comms_source.goods == nil then
											comms_source.goods = {}
										end
										if comms_source.goods[good] == nil then
											comms_source.goods[good] = 0
										end
										comms_source.goods[good] = comms_source.goods[good] + 1
										comms_source.cargo = comms_source.cargo - 1
										setCommsMessage(string.format("Purchased %s from %s",good,comms_target:getCallSign()))
									else
										setCommsMessage("Insufficient reputation for purchase")
									end
									addCommsReply("Back", commsShip)
								end)
							end	--freighter has something to sell branch
						end	--freighter goods loop
					else	--not goods or equipment freighter
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 then
								addCommsReply(string.format("Buy one %s for %i reputation",good,math.floor(goodData.cost*2)), function()
									if comms_source:takeReputationPoints(goodData.cost*2) then
										goodData.quantity = goodData.quantity - 1
										if comms_source.goods == nil then
											comms_source.goods = {}
										end
										if comms_source.goods[good] == nil then
											comms_source.goods[good] = 0
										end
										comms_source.goods[good] = comms_source.goods[good] + 1
										comms_source.cargo = comms_source.cargo - 1
										setCommsMessage(string.format("Purchased %s from %s",good,comms_target:getCallSign()))
									else
										setCommsMessage("Insufficient reputation for purchase")
									end
									addCommsReply("Back", commsShip)
								end)
							end	--freighter has something to sell branch
						end	--freighter goods loop
					end
				end	--player has room for cargo branch
			else	--least friendly
				if comms_source.cargo > 0 then
					if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 then
								addCommsReply(string.format("Buy one %s for %i reputation",good,math.floor(goodData.cost*2)), function()
									if comms_source:takeReputationPoints(goodData.cost*2) then
										goodData.quantity = goodData.quantity - 1
										if comms_source.goods == nil then
											comms_source.goods = {}
										end
										if comms_source.goods[good] == nil then
											comms_source.goods[good] = 0
										end
										comms_source.goods[good] = comms_source.goods[good] + 1
										comms_source.cargo = comms_source.cargo - 1
										setCommsMessage(string.format("Purchased %s from %s",good,comms_target:getCallSign()))
									else
										setCommsMessage("Insufficient reputation for purchase")
									end
									addCommsReply("Back", commsShip)
								end)
							end	--freighter has something to sell branch
						end	--freighter goods loop
					end	--goods or equipment freighter
				end	--player has room to get goods
			end	--various friendliness choices
		else	--not close enough to sell
			addCommsReply("Do you have cargo you might sell?", function()
				local goodCount = 0
				local cargoMsg = "We've got "
				for good, goodData in pairs(comms_data.goods) do
					if goodData.quantity > 0 then
						if goodCount > 0 then
							cargoMsg = cargoMsg .. ", " .. good
						else
							cargoMsg = cargoMsg .. good
						end
					end
					goodCount = goodCount + goodData.quantity
				end
				if goodCount == 0 then
					cargoMsg = cargoMsg .. "nothing"
				end
				setCommsMessage(cargoMsg)
				addCommsReply("Back", commsShip)
			end)
		end
	end
	return true
end
function enemyComms(comms_data)
	local faction = comms_target:getFaction()
	local tauntable = false
	local amenable = false
	if comms_data.friendlyness >= 33 then	--final: 33
		--taunt logic
		local taunt_option = "We will see to your destruction!"
		local taunt_success_reply = "Your bloodline will end here!"
		local taunt_failed_reply = "Your feeble threats are meaningless."
		local taunt_threshold = 30	--base chance of being taunted
		if faction == "Kraylor" then
			taunt_threshold = 35
			setCommsMessage("Ktzzzsss.\nYou will DIEEee weaklingsss!");
			local kraylorTauntChoice = math.random(1,3)
			if kraylorTauntChoice == 1 then
				taunt_option = "We will destroy you"
				taunt_success_reply = "We think not. It is you who will experience destruction!"
			elseif kraylorTauntChoice == 2 then
				taunt_option = "You have no honor"
				taunt_success_reply = "Your insult has brought our wrath upon you. Prepare to die."
				taunt_failed_reply = "Your comments about honor have no meaning to us"
			else
				taunt_option = "We pity your pathetic race"
				taunt_success_reply = "Pathetic? You will regret your disparagement!"
				taunt_failed_reply = "We don't care what you think of us"
			end
		elseif faction == "Arlenians" then
			taunt_threshold = 25
			setCommsMessage("We wish you no harm, but will harm you if we must.\nEnd of transmission.");
		elseif faction == "Exuari" then
			taunt_threshold = 40
			setCommsMessage("Stay out of our way, or your death will amuse us extremely!");
		elseif faction == "Ghosts" then
			taunt_threshold = 20
			setCommsMessage("One zero one.\nNo binary communication detected.\nSwitching to universal speech.\nGenerating appropriate response for target from human language archives.\n:Do not cross us:\nCommunication halted.");
			taunt_option = "EXECUTE: SELFDESTRUCT"
			taunt_success_reply = "Rogue command received. Targeting source."
			taunt_failed_reply = "External command ignored."
		elseif faction == "Ktlitans" then
			setCommsMessage("The hive suffers no threats. Opposition to any of us is opposition to us all.\nStand down or prepare to donate your corpses toward our nutrition.");
			taunt_option = "<Transmit 'The Itsy-Bitsy Spider' on all wavelengths>"
			taunt_success_reply = "We do not need permission to pluck apart such an insignificant threat."
			taunt_failed_reply = "The hive has greater priorities than exterminating pests."
		elseif faction == "TSN" then
			taunt_threshold = 15
			setCommsMessage("State your business")
		elseif faction == "USN" then
			taunt_threshold = 15
			setCommsMessage("What do you want? (not that we care)")
		elseif faction == "CUF" then
			taunt_threshold = 15
			setCommsMessage("Don't waste our time")
		else
			setCommsMessage("Mind your own business!");
		end
		comms_data.friendlyness = comms_data.friendlyness - random(0, 10)	--reduce friendlyness after each interaction
		addCommsReply(taunt_option, function()
			if random(0, 100) <= taunt_threshold then	--final: 30
				local current_order = comms_target:getOrder()
				print("order: " .. current_order)
				--Possible order strings returned:
				--Roaming
				--Fly towards
				--Attack
				--Stand Ground
				--Idle
				--Defend Location
				--Defend Target
				--Fly Formation (?)
				--Fly towards (ignore all)
				--Dock
				if comms_target.original_order == nil then
					comms_target.original_faction = faction
					comms_target.original_order = current_order
					if current_order == "Fly towards" or current_order == "Defend Location" or current_order == "Fly towards (ignore all)" then
						comms_target.original_target_x, comms_target.original_target_y = comms_target:getOrderTargetLocation()
						--print(string.format("Target_x: %f, Target_y: %f",comms_target.original_target_x,comms_target.original_target_y))
					end
					if current_order == "Attack" or current_order == "Dock" or current_order == "Defend Target" then
						local original_target = comms_target:getOrderTarget()
						--print("target:")
						--print(original_target)
						--print(original_target:getCallSign())
						comms_target.original_target = original_target
					end
					comms_target.taunt_may_expire = true	--change to conditional in future refactoring
					table.insert(enemy_reverts,comms_target)
				end
				comms_target:orderAttack(comms_source)	--consider alternative options besides attack in future refactoring
				setCommsMessage(taunt_success_reply);
			else
				setCommsMessage(taunt_failed_reply);
			end
		end)
		tauntable = true
	end
	local enemy_health = getEnemyHealth(comms_target)
	if change_enemy_order_diagnostic then print(string.format("   enemy health:    %.2f",enemy_health)) end
	if change_enemy_order_diagnostic then print(string.format("   friendliness:    %.1f",comms_data.friendlyness)) end
	if comms_data.friendlyness >= 66 or enemy_health < .5 then	--final: 66, .5
		--amenable logic
		local amenable_chance = comms_data.friendlyness/3 + (1 - enemy_health)*30
		if change_enemy_order_diagnostic then print(string.format("   amenability:     %.1f",amenable_chance)) end
		addCommsReply("Stop your actions",function()
			local amenable_roll = random(0,100)
			if change_enemy_order_diagnostic then print(string.format("   amenable roll:   %.1f",amenable_roll)) end
			if amenable_roll < amenable_chance then
				local current_order = comms_target:getOrder()
				if comms_target.original_order == nil then
					comms_target.original_order = current_order
					comms_target.original_faction = faction
					if current_order == "Fly towards" or current_order == "Defend Location" or current_order == "Fly towards (ignore all)" then
						comms_target.original_target_x, comms_target.original_target_y = comms_target:getOrderTargetLocation()
						--print(string.format("Target_x: %f, Target_y: %f",comms_target.original_target_x,comms_target.original_target_y))
					end
					if current_order == "Attack" or current_order == "Dock" or current_order == "Defend Target" then
						local original_target = comms_target:getOrderTarget()
						--print("target:")
						--print(original_target)
						--print(original_target:getCallSign())
						comms_target.original_target = original_target
					end
					table.insert(enemy_reverts,comms_target)
				end
				comms_target.amenability_may_expire = true
				comms_target:orderIdle()
				comms_target:setFaction("Independent")
				setCommsMessage("Just this once, we'll take your advice")
			else
				setCommsMessage("No")
			end
		end)
		comms_data.friendlyness = comms_data.friendlyness - random(0, 10)	--reduce friendlyness after each interaction
		amenable = true
	end
	if tauntable or amenable then
		return true
	else
		return false
	end
end
function neutralComms(comms_data)
	local shipType = comms_target:getTypeName()
	if shipType:find("Freighter") ~= nil then
		setCommsMessage("Yes?")
		addCommsReply("Do you have cargo you might sell?", function()
			local goodCount = 0
			local cargoMsg = "We've got "
			for good, goodData in pairs(comms_data.goods) do
				if goodData.quantity > 0 then
					if goodCount > 0 then
						cargoMsg = cargoMsg .. ", " .. good
					else
						cargoMsg = cargoMsg .. good
					end
				end
				goodCount = goodCount + goodData.quantity
			end
			if goodCount == 0 then
				cargoMsg = cargoMsg .. "nothing"
			end
			setCommsMessage(cargoMsg)
		end)
		if distance(comms_source,comms_target) < 5000 then
			if comms_source.cargo > 0 then
				if comms_data.friendlyness > 66 then
					if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 then
								addCommsReply(string.format("Buy one %s for %i reputation",good,math.floor(goodData.cost)), function()
									if comms_source:takeReputationPoints(goodData.cost) then
										goodData.quantity = goodData.quantity - 1
										if comms_source.goods == nil then
											comms_source.goods = {}
										end
										if comms_source.goods[good] == nil then
											comms_source.goods[good] = 0
										end
										comms_source.goods[good] = comms_source.goods[good] + 1
										comms_source.cargo = comms_source.cargo - 1
										setCommsMessage(string.format("Purchased %s from %s",good,comms_target:getCallSign()))
									else
										setCommsMessage("Insufficient reputation for purchase")
									end
									addCommsReply("Back", commsShip)
								end)
							end
						end	--freighter goods loop
					else
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 then
								addCommsReply(string.format("Buy one %s for %i reputation",good,math.floor(goodData.cost*2)), function()
									if comms_source:takeReputationPoints(goodData.cost*2) then
										goodData.quantity = goodData.quantity - 1
										if comms_source.goods == nil then
											comms_source.goods = {}
										end
										if comms_source.goods[good] == nil then
											comms_source.goods[good] = 0
										end
										comms_source.goods[good] = comms_source.goods[good] + 1
										comms_source.cargo = comms_source.cargo - 1
										setCommsMessage(string.format("Purchased %s from %s",good,comms_target:getCallSign()))
									else
										setCommsMessage("Insufficient reputation for purchase")
									end
									addCommsReply("Back", commsShip)
								end)
							end
						end	--freighter goods loop
					end
				elseif comms_data.friendlyness > 33 then
					if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 then
								addCommsReply(string.format("Buy one %s for %i reputation",good,math.floor(goodData.cost*2)), function()
									if comms_source:takeReputationPoints(goodData.cost*2) then
										goodData.quantity = goodData.quantity - 1
										if comms_source.goods == nil then
											comms_source.goods = {}
										end
										if comms_source.goods[good] == nil then
											comms_source.goods[good] = 0
										end
										comms_source.goods[good] = comms_source.goods[good] + 1
										comms_source.cargo = comms_source.cargo - 1
										setCommsMessage(string.format("Purchased %s from %s",good,comms_target:getCallSign()))
									else
										setCommsMessage("Insufficient reputation for purchase")
									end
									addCommsReply("Back", commsShip)
								end)
							end
						end	--freighter goods loop
					else
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 then
								addCommsReply(string.format("Buy one %s for %i reputation",good,math.floor(goodData.cost*3)), function()
									if comms_source:takeReputationPoints(goodData.cost*3) then
										goodData.quantity = goodData.quantity - 1
										if comms_source.goods == nil then
											comms_source.goods = {}
										end
										if comms_source.goods[good] == nil then
											comms_source.goods[good] = 0
										end
										comms_source.goods[good] = comms_source.goods[good] + 1
										comms_source.cargo = comms_source.cargo - 1
										setCommsMessage(string.format("Purchased %s from %s",good,comms_target:getCallSign()))
									else
										setCommsMessage("Insufficient reputation for purchase")
									end
									addCommsReply("Back", commsShip)
								end)
							end
						end	--freighter goods loop
					end
				else	--least friendly
					if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 then
								addCommsReply(string.format("Buy one %s for %i reputation",good,math.floor(goodData.cost*3)), function()
									if comms_source:takeReputationPoints(goodData.cost*3) then
										goodData.quantity = goodData.quantity - 1
										if comms_source.goods == nil then
											comms_source.goods = {}
										end
										if comms_source.goods[good] == nil then
											comms_source.goods[good] = 0
										end
										comms_source.goods[good] = comms_source.goods[good] + 1
										comms_source.cargo = comms_source.cargo - 1
										setCommsMessage(string.format("Purchased %s from %s",good,comms_target:getCallSign()))
									else
										setCommsMessage("Insufficient reputation for purchase")
									end
									addCommsReply("Back", commsShip)
								end)
							end
						end	--freighter goods loop
					end
				end	--end friendly branches
			end	--player has room for cargo
		end	--close enough to sell
	else	--not a freighter
		if comms_data.friendlyness > 50 then
			setCommsMessage("Sorry, we have no time to chat with you.\nWe are on an important mission.");
		else
			setCommsMessage("We have nothing for you.\nGood day.");
		end
	end	--end non-freighter communications else branch
	return true
end	--end neutral communications function
function getEnemyHealth(enemy)
	local enemy_health = 0
	local enemy_shield = 0
	local enemy_shield_count = enemy:getShieldCount()
	local faction = enemy:getFaction()
	if change_enemy_order_diagnostic then print(string.format("%s statistics:",enemy:getCallSign())) end
	if change_enemy_order_diagnostic then print(string.format("   shield count:    %i",enemy_shield_count)) end
	if enemy_shield_count > 0 then
		local total_shield_level = 0
		local max_shield_level = 0
		for i=1,enemy_shield_count do
			total_shield_level = total_shield_level + enemy:getShieldLevel(i-1)
			max_shield_level = max_shield_level + enemy:getShieldMax(i-1)
		end
		enemy_shield = total_shield_level/max_shield_level
	else
		enemy_shield = 1
	end
	if change_enemy_order_diagnostic then print(string.format("   shield health:   %.1f",enemy_shield)) end
	local enemy_hull = enemy:getHull()/enemy:getHullMax()
	if change_enemy_order_diagnostic then print(string.format("   hull health:     %.1f",enemy_hull)) end
	local enemy_reactor = enemy:getSystemHealth("reactor")
	if change_enemy_order_diagnostic then print(string.format("   reactor health:  %.1f",enemy_reactor)) end
	local enemy_maneuver = enemy:getSystemHealth("maneuver")
	if change_enemy_order_diagnostic then print(string.format("   maneuver health: %.1f",enemy_maneuver)) end
	local enemy_impulse = enemy:getSystemHealth("impulse")
	if change_enemy_order_diagnostic then print(string.format("   impulse health:  %.1f",enemy_impulse)) end
	local enemy_beam = 0
	if enemy:getBeamWeaponRange(0) > 0 then
		enemy_beam = enemy:getSystemHealth("beamweapons")
		if change_enemy_order_diagnostic then print(string.format("   beam health:     %.1f",enemy_beam)) end
	else
		enemy_beam = 1
		if change_enemy_order_diagnostic then print(string.format("   beam health:     %.1f (no beams)",enemy_beam)) end
	end
	local enemy_missile = 0
	if enemy:getWeaponTubeCount() > 0 then
		enemy_missile = enemy:getSystemHealth("missilesystem")
		if change_enemy_order_diagnostic then print(string.format("   missile health:  %.1f",enemy_missile)) end
	else
		enemy_missile = 1
		if change_enemy_order_diagnostic then print(string.format("   missile health:  %.1f (no missile system)",enemy_missile)) end
	end
	local enemy_warp = 0
	if enemy:hasWarpDrive() then
		enemy_warp = enemy:getSystemHealth("warp")
		if change_enemy_order_diagnostic then print(string.format("   warp health:     %.1f",enemy_warp)) end
	else
		enemy_warp = 1
		if change_enemy_order_diagnostic then print(string.format("   warp health:     %.1f (no warp drive)",enemy_warp)) end
	end
	local enemy_jump = 0
	if enemy:hasJumpDrive() then
		enemy_jump = enemy:getSystemHealth("jumpdrive")
		if change_enemy_order_diagnostic then print(string.format("   jump health:     %.1f",enemy_jump)) end
	else
		enemy_jump = 1
		if change_enemy_order_diagnostic then print(string.format("   jump health:     %.1f (no jump drive)",enemy_jump)) end
	end
	if change_enemy_order_diagnostic then print(string.format("   faction:         %s",faction)) end
	if faction == "Kraylor" then
		enemy_health = 
			enemy_shield 	* .3	+
			enemy_hull		* .4	+
			enemy_reactor	* .1 	+
			enemy_maneuver	* .03	+
			enemy_impulse	* .03	+
			enemy_beam		* .04	+
			enemy_missile	* .04	+
			enemy_warp		* .03	+
			enemy_jump		* .03
	elseif faction == "Arlenians" then
		enemy_health = 
			enemy_shield 	* .35	+
			enemy_hull		* .45	+
			enemy_reactor	* .05 	+
			enemy_maneuver	* .03	+
			enemy_impulse	* .04	+
			enemy_beam		* .02	+
			enemy_missile	* .02	+
			enemy_warp		* .02	+
			enemy_jump		* .02	
	elseif faction == "Exuari" then
		enemy_health = 
			enemy_shield 	* .2	+
			enemy_hull		* .3	+
			enemy_reactor	* .2 	+
			enemy_maneuver	* .05	+
			enemy_impulse	* .05	+
			enemy_beam		* .05	+
			enemy_missile	* .05	+
			enemy_warp		* .05	+
			enemy_jump		* .05	
	elseif faction == "Ghosts" then
		enemy_health = 
			enemy_shield 	* .25	+
			enemy_hull		* .25	+
			enemy_reactor	* .25 	+
			enemy_maneuver	* .04	+
			enemy_impulse	* .05	+
			enemy_beam		* .04	+
			enemy_missile	* .04	+
			enemy_warp		* .04	+
			enemy_jump		* .04	
	elseif faction == "Ktlitans" then
		enemy_health = 
			enemy_shield 	* .2	+
			enemy_hull		* .3	+
			enemy_reactor	* .1 	+
			enemy_maneuver	* .05	+
			enemy_impulse	* .05	+
			enemy_beam		* .05	+
			enemy_missile	* .05	+
			enemy_warp		* .1	+
			enemy_jump		* .1	
	elseif faction == "TSN" then
		enemy_health = 
			enemy_shield 	* .35	+
			enemy_hull		* .35	+
			enemy_reactor	* .08 	+
			enemy_maneuver	* .01	+
			enemy_impulse	* .02	+
			enemy_beam		* .02	+
			enemy_missile	* .01	+
			enemy_warp		* .08	+
			enemy_jump		* .08	
	elseif faction == "USN" then
		enemy_health = 
			enemy_shield 	* .38	+
			enemy_hull		* .38	+
			enemy_reactor	* .05 	+
			enemy_maneuver	* .02	+
			enemy_impulse	* .03	+
			enemy_beam		* .02	+
			enemy_missile	* .02	+
			enemy_warp		* .05	+
			enemy_jump		* .05	
	elseif faction == "CUF" then
		enemy_health = 
			enemy_shield 	* .35	+
			enemy_hull		* .38	+
			enemy_reactor	* .05 	+
			enemy_maneuver	* .03	+
			enemy_impulse	* .03	+
			enemy_beam		* .03	+
			enemy_missile	* .03	+
			enemy_warp		* .06	+
			enemy_jump		* .04	
	else
		enemy_health = 
			enemy_shield 	* .3	+
			enemy_hull		* .4	+
			enemy_reactor	* .06 	+
			enemy_maneuver	* .03	+
			enemy_impulse	* .05	+
			enemy_beam		* .03	+
			enemy_missile	* .03	+
			enemy_warp		* .05	+
			enemy_jump		* .05	
	end
	return enemy_health
end
function revertWait(delta)
	revert_timer = revert_timer - delta
	if revert_timer < 0 then
		revert_timer = delta + revert_timer_interval
		plotRevert = revertCheck
	end
end
function revertCheck(delta)
	if enemy_reverts ~= nil then
		for _, enemy in ipairs(enemy_reverts) do
			if enemy ~= nil and enemy:isValid() then
				local expiration_chance = 0
				local enemy_faction = enemy:getFaction()
				if enemy.taunt_may_expire then
					if enemy_faction == "Kraylor" then
						expiration_chance = 4.5
					elseif enemy_faction == "Arlenians" then
						expiration_chance = 7
					elseif enemy_faction == "Exuari" then
						expiration_chance = 2.5
					elseif enemy_faction == "Ghosts" then
						expiration_chance = 8.5
					elseif enemy_faction == "Ktlitans" then
						expiration_chance = 5.5
					elseif enemy_faction == "TSN" then
						expiration_chance = 3
					elseif enemy_faction == "USN" then
						expiration_chance = 3.5
					elseif enemy_faction == "CUF" then
						expiration_chance = 4
					else
						expiration_chance = 6
					end
				elseif enemy.amenability_may_expire then
					local enemy_health = getEnemyHealth(enemy)
					if enemy_faction == "Kraylor" then
						expiration_chance = 2.5
					elseif enemy_faction == "Arlenians" then
						expiration_chance = 3.25
					elseif enemy_faction == "Exuari" then
						expiration_chance = 6.6
					elseif enemy_faction == "Ghosts" then
						expiration_chance = 3.2
					elseif enemy_faction == "Ktlitans" then
						expiration_chance = 4.8
					elseif enemy_faction == "TSN" then
						expiration_chance = 3.5
					elseif enemy_faction == "USN" then
						expiration_chance = 2.8
					elseif enemy_faction == "CUF" then
						expiration_chance = 3
					else
						expiration_chance = 4
					end
					expiration_chance = expiration_chance + enemy_health*5
				end
				local expiration_roll = random(1,100)
				if expiration_roll < expiration_chance then
					local oo = enemy.original_order
					local otx = enemy.original_target_x
					local oty = enemy.original_target_y
					local ot = enemy.original_target
					if oo ~= nil then
						if oo == "Attack" then
							if ot ~= nil and ot:isValid() then
								enemy:orderAttack(ot)
							else
								enemy:orderRoaming()
							end
						elseif oo == "Dock" then
							if ot ~= nil and ot:isValid() then
								enemy:orderDock(ot)
							else
								enemy:orderRoaming()
							end
						elseif oo == "Defend Target" then
							if ot ~= nil and ot:isValid() then
								enemy:orderDefendTarget(ot)
							else
								enemy:orderRoaming()
							end
						elseif oo == "Fly towards" then
							if otx ~= nil and oty ~= nil then
								enemy:orderFlyTowards(otx,oty)
							else
								enemy:orderRoaming()
							end
						elseif oo == "Defend Location" then
							if otx ~= nil and oty ~= nil then
								enemy:orderDefendLocation(otx,oty)
							else
								enemy:orderRoaming()
							end
						elseif oo == "Fly towards (ignore all)" then
							if otx ~= nil and oty ~= nil then
								enemy:orderFlyTowardsBlind(otx,oty)
							else
								enemy:orderRoaming()
							end
						else
							enemy:orderRoaming()
						end
					else
						enemy:orderRoaming()
					end
					if enemy.original_faction ~= nil then
						enemy:setFaction(enemy.original_faction)
					end
					enemy.taunt_may_expire = false
					enemy.amenability_may_expire = false
				end
			end
		end
	end
	plotRevert = revertWait
end
-----------------------------
--	Station communication  --
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
	local ctd = comms_target.comms_data
    if comms_source:isFriendly(comms_target) then
		oMsg = "Good day, officer!\nWhat can we do for you today?\n"
    else
		oMsg = "Welcome to our lovely station.\n"
    end
    if comms_target:areEnemiesInRange(20000) then
		oMsg = oMsg .. "Forgive us if we seem a little distracted. We are carefully monitoring the enemies nearby."
	end
	setCommsMessage(oMsg)
	local missilePresence = 0
	local missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
	for _, missile_type in ipairs(missile_types) do
		missilePresence = missilePresence + comms_source:getWeaponStorageMax(missile_type)
	end
	if missilePresence > 0 then
		if 	(ctd.weapon_available.Nuke   and comms_source:getWeaponStorageMax("Nuke") > 0)   or 
			(ctd.weapon_available.EMP    and comms_source:getWeaponStorageMax("EMP") > 0)    or 
			(ctd.weapon_available.Homing and comms_source:getWeaponStorageMax("Homing") > 0) or 
			(ctd.weapon_available.Mine   and comms_source:getWeaponStorageMax("Mine") > 0)   or 
			(ctd.weapon_available.HVLI   and comms_source:getWeaponStorageMax("HVLI") > 0)   then
			addCommsReply("I need ordnance restocked", function()
				setCommsMessage("What type of ordnance?")
				if comms_source:getWeaponStorageMax("Nuke") > 0 then
					if ctd.weapon_available.Nuke then
						if math.random(1,10) <= 5 then
							nukePrompt = "Can you supply us with some nukes? ("
						else
							nukePrompt = "We really need some nukes ("
						end
						addCommsReply(nukePrompt .. getWeaponCost("Nuke") .. " rep each)", function()
							handleWeaponRestock("Nuke")
						end)
					end	--end station has nuke available if branch
				end	--end player can accept nuke if branch
				if comms_source:getWeaponStorageMax("EMP") > 0 then
					if ctd.weapon_available.EMP then
						if math.random(1,10) <= 5 then
							empPrompt = "Please re-stock our EMP missiles. ("
						else
							empPrompt = "Got any EMPs? ("
						end
						addCommsReply(empPrompt .. getWeaponCost("EMP") .. " rep each)", function()
							handleWeaponRestock("EMP")
						end)
					end	--end station has EMP available if branch
				end	--end player can accept EMP if branch
				if comms_source:getWeaponStorageMax("Homing") > 0 then
					if ctd.weapon_available.Homing then
						if math.random(1,10) <= 5 then
							homePrompt = "Do you have spare homing missiles for us? ("
						else
							homePrompt = "Do you have extra homing missiles? ("
						end
						addCommsReply(homePrompt .. getWeaponCost("Homing") .. " rep each)", function()
							handleWeaponRestock("Homing")
						end)
					end	--end station has homing for player if branch
				end	--end player can accept homing if branch
				if comms_source:getWeaponStorageMax("Mine") > 0 then
					if ctd.weapon_available.Mine then
						if math.random(1,10) <= 5 then
							minePrompt = "We could use some mines. ("
						else
							minePrompt = "How about mines? ("
						end
						addCommsReply(minePrompt .. getWeaponCost("Mine") .. " rep each)", function()
							handleWeaponRestock("Mine")
						end)
					end	--end station has mine for player if branch
				end	--end player can accept mine if branch
				if comms_source:getWeaponStorageMax("HVLI") > 0 then
					if ctd.weapon_available.HVLI then
						if math.random(1,10) <= 5 then
							hvliPrompt = "What about HVLI? ("
						else
							hvliPrompt = "Could you provide HVLI? ("
						end
						addCommsReply(hvliPrompt .. getWeaponCost("HVLI") .. " rep each)", function()
							handleWeaponRestock("HVLI")
						end)
					end	--end station has HVLI for player if branch
				end	--end player can accept HVLI if branch
			end)	--end player requests secondary ordnance comms reply branch
		end	--end secondary ordnance available from station if branch
	end	--end missles used on player ship if branch
	--[[
	--temporary code for session prepared near end of January 2020. Not used. Wombat was destroyed
	addCommsReply("Do you have a focuser for a Wombat beam array?", function()
		if comms_target == stationMaximilian then
			setCommsMessage("Sure, let me get that for you")
			if comms_source == playerWombat then
				playerWombat:setBeamWeapon(0, 10, 0, 900.0, 4.0, 3)		--extra beam (vs 1@ 700 6.0, 2)
			end
		else
			local wombat_response = math.random(1,6)
			if wombat_response == 1 then
				setCommsMessage("No spare parts here")
			elseif wombat_response == 2 then
				setCommsMessage("Wombat? We haven't had anything for those models in years")
			elseif wombat_response == 3 then
				setCommsMessage("Can't help you")
			elseif wombat_response == 4 then
				setCommsMessage("Let me look. I've got focusers for Phobos class and Repulse class, but nothing for Wombat")
			elseif wombat_response == 5 then
				setCommsMessage("I'm sure we've got those, let me get one.\n\n[silence followed by the sounds of clanking, mumbling and scraping]\n\nI can't seem to find them")
			else
				setCommsMessage("Sorry, we don't")
			end
		end
		addCommsReply("Back", commsStation)
	end)
	--]]
	if ctd.public_relations then
		addCommsReply("Tell me more about your station", function()
			setCommsMessage("What would you like to know?")
			addCommsReply("General information", function()
				setCommsMessage(ctd.general_information)
				addCommsReply("Back", commsStation)
			end)
			if ctd.history ~= nil then
				addCommsReply("Station history", function()
					setCommsMessage(ctd.history)
					addCommsReply("Back", commsStation)
				end)
			end
			if comms_source:isFriendly(comms_target) then
				if ctd.gossip ~= nil then
					if random(1,100) < 70 then
						addCommsReply("Gossip", function()
							setCommsMessage(ctd.gossip)
							addCommsReply("Back", commsStation)
						end)
					end
				end
			end
		end)	--end station info comms reply branch
	end	--end public relations if branch
	if ctd.character ~= nil then
		addCommsReply(string.format("Tell me about %s",ctd.character), function()
			if ctd.characterDescription ~= nil then
				setCommsMessage(ctd.characterDescription)
			else
				if ctd.characterDeadEnd == nil then
					local deadEndChoice = math.random(1,5)
					if deadEndChoice == 1 then
						ctd.characterDeadEnd = "Never heard of " .. ctd.character
					elseif deadEndChoice == 2 then
						ctd.characterDeadEnd = ctd.character .. " died last week. The funeral was yesterday"
					elseif deadEndChoice == 3 then
						ctd.characterDeadEnd = string.format("%s? Who's %s? There's nobody here named %s",ctd.character,ctd.character,ctd.character)
					elseif deadEndChoice == 4 then
						ctd.characterDeadEnd = string.format("We don't talk about %s. They are gone and good riddance",ctd.character)
					else
						ctd.characterDeadEnd = string.format("I think %s moved away",ctd.character)
					end
				end
				setCommsMessage(ctd.characterDeadEnd)
			end
			addCommsReply("Back", commsStation)
		end)
	end
	if comms_source:isFriendly(comms_target) then
		if random(1,100) <= 20 then
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
					resetPreviousSystemHealth()
					setCommsMessage("Repair crew member hired")
				end
				addCommsReply("Back", commsStation)
			end)
		end
		if comms_source.initialCoolant ~= nil then
			if math.random(1,100) <= 20 then
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
		if random(1,100) <= 20 then
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
					resetPreviousSystemHealth()
					setCommsMessage("Repair crew member hired")
				end
				addCommsReply("Back", commsStation)
			end)
		end
		if comms_source.initialCoolant ~= nil then
			if math.random(1,100) <= 20 then
				local coolantCost = math.random(60,120)
				if comms_source:getMaxCoolant() < comms_source.initialCoolant then
					coolantCost = math.random(45,90)
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
	end
	local goodCount = 0
	for good, goodData in pairs(ctd.goods) do
		goodCount = goodCount + 1
	end
	if goodCount > 0 then
		addCommsReply("Buy, sell, trade", function()
			local ctd = comms_target.comms_data
			local goodsReport = string.format("Station %s:\nGoods or components available for sale: quantity, cost in reputation\n",comms_target:getCallSign())
			for good, goodData in pairs(ctd.goods) do
				goodsReport = goodsReport .. string.format("     %s: %i, %i\n",good,goodData["quantity"],goodData["cost"])
			end
			if ctd.buy ~= nil then
				goodsReport = goodsReport .. "Goods or components station will buy: price in reputation\n"
				for good, price in pairs(ctd.buy) do
					goodsReport = goodsReport .. string.format("     %s: %i\n",good,price)
				end
			end
			goodsReport = goodsReport .. string.format("Current cargo aboard %s:\n",comms_source:getCallSign())
			local cargoHoldEmpty = true
			local goodCount = 0
			if comms_source.goods ~= nil then
				for good, goodQuantity in pairs(comms_source.goods) do
					goodCount = goodCount + 1
					goodsReport = goodsReport .. string.format("     %s: %i\n",good,goodQuantity)
				end
			end
			if goodCount < 1 then
				goodsReport = goodsReport .. "     Empty\n"
			end
			goodsReport = goodsReport .. string.format("Available Space: %i, Available Reputation: %i\n",comms_source.cargo,math.floor(comms_source:getReputationPoints()))
			setCommsMessage(goodsReport)
			for good, goodData in pairs(ctd.goods) do
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
			if ctd.buy ~= nil then
				for good, price in pairs(ctd.buy) do
					if comms_source.goods[good] ~= nil and comms_source.goods[good] > 0 then
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
			if ctd.trade.food and comms_source.goods["food"] > 0 then
				for good, goodData in pairs(ctd.goods) do
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
			if ctd.trade.medicine and comms_source.goods["medicine"] > 0 then
				for good, goodData in pairs(ctd.goods) do
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
			if ctd.trade.luxury and comms_source.goods["luxury"] > 0 then
				for good, goodData in pairs(ctd.goods) do
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
	end
end	--end of handleDockedState function
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
		if comms_source:getReputationPoints() > points_per_item * item_amount then
			if comms_source:takeReputationPoints(points_per_item * item_amount) then
				comms_source:setWeaponStorage(weapon, comms_source:getWeaponStorage(weapon) + item_amount)
				if comms_source:getWeaponStorage(weapon) == comms_source:getWeaponStorageMax(weapon) then
					setCommsMessage("You are fully loaded and ready to explode things.")
				else
					setCommsMessage("We generously resupplied you with some weapon charges.\nPut them to good use.")
				end
			else
				setCommsMessage("Not enough reputation.")
				return
			end
		else
			if comms_source:getReputationPoints() > points_per_item then
				setCommsMessage("You can't afford as much as I'd like to give you")
				addCommsReply("Get just one", function()
					if comms_source:takeReputationPoints(points_per_item) then
						comms_source:setWeaponStorage(weapon, comms_source:getWeaponStorage(weapon) + 1)
						if comms_source:getWeaponStorage(weapon) == comms_source:getWeaponStorageMax(weapon) then
							setCommsMessage("You are fully loaded and ready to explode things.")
						else
							setCommsMessage("We generously resupplied you with one weapon charge.\nPut it to good use.")
						end
					else
						setCommsMessage("Not enough reputation.")
					end
					return
				end)
			else
				setCommsMessage("Not enough reputation.")
				return				
			end
		end
        addCommsReply("Back", commsStation)
    end
end
function getWeaponCost(weapon)
    return math.ceil(comms_data.weapon_cost[weapon] * comms_data.reputation_cost_multipliers[getFriendStatus()])
end
function preOrderOrdnance()
	setCommsMessage(preorder_message)
	local ctd = comms_target.comms_data
	local hvli_count = math.floor(comms_source:getWeaponStorageMax("HVLI") * ctd.max_weapon_refill_amount[getFriendStatus()]) - comms_source:getWeaponStorage("HVLI")
	if ctd.weapon_available.HVLI and isAllowedTo(ctd.weapons["HVLI"]) and hvli_count > 0 then
		local hvli_prompt = ""
		local hvli_cost = getWeaponCost("HVLI")
		if hvli_count > 1 then
			hvli_prompt = string.format("%i HVLIs * %i Rep = %i Rep",hvli_count,hvli_cost,hvli_count*hvli_cost)
		else
			hvli_prompt = string.format("%i HVLI * %i Rep = %i Rep",hvli_count,hvli_cost,hvli_count*hvli_cost)
		end
		addCommsReply(hvli_prompt,function()
			if comms_source:takeReputationPoints(hvli_count*hvli_cost) then
				comms_source.preorder_hvli = hvli_count
				if hvli_count > 1 then
					setCommsMessage(string.format("%i HVLIs preordered",hvli_count))
				else
					setCommsMessage(string.format("%i HVLI preordered",hvli_count))
				end
			else
				setCommsMessage("Insufficient reputation")
			end
			preorder_message = "Docking crew is standing by. Would you like to pre-order anything?"
			addCommsReply("Back",preOrderOrdnance)
		end)
	end
	local homing_count = math.floor(comms_source:getWeaponStorageMax("Homing") * ctd.max_weapon_refill_amount[getFriendStatus()]) - comms_source:getWeaponStorage("Homing")
	if ctd.weapon_available.Homing and isAllowedTo(ctd.weapons["Homing"]) and homing_count > 0 then
		local homing_prompt = ""
		local homing_cost = getWeaponCost("Homing")
		if homing_count > 1 then
			homing_prompt = string.format("%i Homings * %i Rep = %i Rep",homing_count,homing_cost,homing_count*homing_cost)
		else
			homing_prompt = string.format("%i Homing * %i Rep = %i Rep",homing_count,homing_cost,homing_count*homing_cost)
		end
		addCommsReply(homing_prompt,function()
			if comms_source:takeReputationPoints(homing_count*homing_cost) then
				comms_source.preorder_homing = homing_count
				if homing_count > 1 then
					setCommsMessage(string.format("%i Homings preordered",homing_count))
				else
					setCommsMessage(string.format("%i Homing preordered",homing_count))
				end
			else
				setCommsMessage("Insufficient reputation")
			end
			preorder_message = "Docking crew is standing by. Would you like to pre-order anything?"
			addCommsReply("Back",preOrderOrdnance)
		end)
	end
	local mine_count = math.floor(comms_source:getWeaponStorageMax("Mine") * ctd.max_weapon_refill_amount[getFriendStatus()]) - comms_source:getWeaponStorage("Mine")
	if ctd.weapon_available.Mine and isAllowedTo(ctd.weapons["Mine"]) and mine_count > 0 then
		local mine_prompt = ""
		local mine_cost = getWeaponCost("Mine")
		if mine_count > 1 then
			mine_prompt = string.format("%i Mines * %i Rep = %i Rep",mine_count,mine_cost,mine_count*mine_cost)
		else
			mine_prompt = string.format("%i Mine * %i Rep = %i Rep",mine_count,mine_cost,mine_count*mine_cost)
		end
		addCommsReply(mine_prompt,function()
			if comms_source:takeReputationPoints(mine_count*mine_cost) then
				comms_source.preorder_mine = mine_count
				if mine_count > 1 then
					setCommsMessage(string.format("%i Mines preordered",mine_count))
				else
					setCommsMessage(string.format("%i Mine preordered",mine_count))
				end
			else
				setCommsMessage("Insufficient reputation")
			end
			preorder_message = "Docking crew is standing by. Would you like to pre-order anything?"
			addCommsReply("Back",preOrderOrdnance)
		end)
	end
	local emp_count = math.floor(comms_source:getWeaponStorageMax("EMP") * ctd.max_weapon_refill_amount[getFriendStatus()]) - comms_source:getWeaponStorage("EMP")
	if ctd.weapon_available.EMP and isAllowedTo(ctd.weapons["EMP"]) and emp_count > 0 then
		local emp_prompt = ""
		local emp_cost = getWeaponCost("EMP")
		if emp_count > 1 then
			emp_prompt = string.format("%i EMPs * %i Rep = %i Rep",emp_count,emp_cost,emp_count*emp_cost)
		else
			emp_prompt = string.format("%i EMP * %i Rep = %i Rep",emp_count,emp_cost,emp_count*emp_cost)
		end
		addCommsReply(emp_prompt,function()
			if comms_source:takeReputationPoints(emp_count*emp_cost) then
				comms_source.preorder_emp = emp_count
				if emp_count > 1 then
					setCommsMessage(string.format("%i EMPs preordered",emp_count))
				else
					setCommsMessage(string.format("%i EMP preordered",emp_count))
				end
			else
				setCommsMessage("Insufficient reputation")
			end
			preorder_message = "Docking crew is standing by. Would you like to pre-order anything?"
			addCommsReply("Back",preOrderOrdnance)
		end)
	end
	local nuke_count = math.floor(comms_source:getWeaponStorageMax("Nuke") * ctd.max_weapon_refill_amount[getFriendStatus()]) - comms_source:getWeaponStorage("Nuke")
	if ctd.weapon_available.Nuke and isAllowedTo(ctd.weapons["Nuke"]) and nuke_count > 0 then
		local nuke_prompt = ""
		local nuke_cost = getWeaponCost("Nuke")
		if nuke_count > 1 then
			nuke_prompt = string.format("%i Nukes * %i Rep = %i Rep",nuke_count,nuke_cost,nuke_count*nuke_cost)
		else
			nuke_prompt = string.format("%i Nuke * %i Rep = %i Rep",nuke_count,nuke_cost,nuke_count*nuke_cost)
		end
		addCommsReply(nuke_prompt,function()
			if comms_source:takeReputationPoints(nuke_count*nuke_cost) then
				comms_source.preorder_nuke = nuke_count
				if nuke_count > 1 then
					setCommsMessage(string.format("%i Nukes preordered",nuke_count))
				else
					setCommsMessage(string.format("%i Nuke preordered",nuke_count))
				end
			else
				setCommsMessage("Insufficient reputation")
			end
			preorder_message = "Docking crew is standing by. Would you like to pre-order anything?"
			addCommsReply("Back",preOrderOrdnance)
		end)
	end
	if comms_source.preorder_repair_crew == nil then
		if random(1,100) <= 20 then
			if comms_source:isFriendly(comms_target) then
				if comms_source:getRepairCrewCount() < comms_source.maxRepairCrew then
					hireCost = math.random(30,60)
				else
					hireCost = math.random(45,90)
				end
				addCommsReply(string.format("Recruit repair crew member for %i reputation",hireCost), function()
					if not comms_source:takeReputationPoints(hireCost) then
						setCommsMessage("Insufficient reputation")
					else
						comms_source.preorder_repair_crew = 1
						setCommsMessage("Repair crew hired on your behalf. They will board when you dock")
					end				
					preorder_message = "Docking crew is standing by. Would you like to pre-order anything?"
					addCommsReply("Back",preOrderOrdnance)
				end)
			end
		end
	end
	if comms_source.preorder_coolant == nil then
		if random(1,100) <= 20 then
			if comms_source:isFriendly(comms_target) then
				if comms_source.initialCoolant ~= nil then
					local coolant_cost = math.random(45,90)
					if comms_source:getMaxCoolant() < comms_source.initialCoolant then
						coolant_cost = math.random(30,60)
					end
					addCommsReply(string.format("Set aside coolant for %i reputation",coolant_cost), function()
						if comms_source:takeReputationPoints(coolant_cost) then
							comms_source.preorder_coolant = 2
							setCommsMessage("Coolant set aside for you. It will be loaded when you dock")
						else
							setCommsMessage("Insufficient reputation")
						end
						preorder_message = "Docking crew is standing by. Would you like to pre-order anything?"
						addCommsReply("Back",preOrderOrdnance)
					end)
				end
			end
		end
	end
end
function handleUndockedState()
    --Handle communications when we are not docked with the station.
    local ctd = comms_target.comms_data
    if comms_source:isFriendly(comms_target) then
        oMsg = "Good day, officer.\nIf you need supplies, please dock with us first."
    else
        oMsg = "Greetings.\nIf you want to do business, please dock with us first."
    end
    if comms_target:areEnemiesInRange(20000) then
		oMsg = oMsg .. "\nBe aware that if enemies in the area get much closer, we will be too busy to conduct business with you."
	end
	setCommsMessage(oMsg)
	if isAllowedTo(ctd.services.preorder) then
		addCommsReply("Expedite Dock",function()
			if comms_source.expedite_dock == nil then
				comms_source.expedite_dock = false
			end
			if comms_source.expedite_dock then
				--handle expedite request already present
				local existing_expedite = "Docking crew is standing by"
				if comms_target == comms_source.expedite_dock_station then
					existing_expedite = existing_expedite .. ". Current preorders:"
					local preorders_identified = false
					if comms_source.preorder_hvli ~= nil then
						preorders_identified = true
						existing_expedite = existing_expedite .. string.format("\n   HVLIs: %i",comms_source.preorder_hvli)
					end
					if comms_source.preorder_homing ~= nil then
						preorders_identified = true
						existing_expedite = existing_expedite .. string.format("\n   Homings: %i",comms_source.preorder_homing)						
					end
					if comms_source.preorder_mine ~= nil then
						preorders_identified = true
						existing_expedite = existing_expedite .. string.format("\n   Mines: %i",comms_source.preorder_mine)						
					end
					if comms_source.preorder_emp ~= nil then
						preorders_identified = true
						existing_expedite = existing_expedite .. string.format("\n   EMPs: %i",comms_source.preorder_emp)						
					end
					if comms_source.preorder_nuke ~= nil then
						preorders_identified = true
						existing_expedite = existing_expedite .. string.format("\n   Nukes: %i",comms_source.preorder_nuke)						
					end
					if comms_source.preorder_repair_crew ~= nil then
						preorders_identified = true
						existing_expedite = existing_expedite .. "\n   One repair crew"						
					end
					if comms_source.preorder_coolant ~= nil then
						preorders_identified = true
						existing_expedite = existing_expedite .. "\n   Coolant"						
					end
					if preorders_identified then
						existing_expedite = existing_expedite .. "\nWould you like to preorder anything else?"
					else
						existing_expedite = existing_expedite .. " none.\nWould you like to preorder anything?"						
					end
					preorder_message = existing_expedite
					preOrderOrdnance()
				else
					existing_expedite = existing_expedite .. string.format(" on station %s (not this station, %s).",comms_source.expedite_dock_station:getCallSign(),comms_target:getCallSign())
					setCommsMessage(existing_expedite)
				end
				addCommsReply("Back",commsStation)
			else
				setCommsMessage("If you would like to speed up the addition of resources such as energy, ordnance, etc., please provide a time frame for your arrival. A docking crew will stand by until that time, after which they will return to their normal duties")
				preorder_message = "Docking crew is standing by. Would you like to pre-order anything?"
				addCommsReply("One minute (5 rep)", function()
					if comms_source:takeReputationPoints(5) then
						comms_source.expedite_dock = true
						comms_source.expedite_dock_station = comms_target
						comms_source.expedite_dock_timer_max = 60
						preOrderOrdnance()
					else
						setCommsMessage("Insufficient reputation")
					end
					addCommsReply("Back", commsStation)
				end)
				addCommsReply("Two minutes (10 Rep)", function()
					if comms_source:takeReputationPoints(10) then
						comms_source.expedite_dock = true
						comms_source.expedite_dock_station = comms_target
						comms_source.expedite_dock_timer_max = 120
						preOrderOrdnance()
					else
						setCommsMessage("Insufficient reputation")
					end
					addCommsReply("Back", commsStation)
				end)
				addCommsReply("Three minutes (15 Rep)", function()
					if comms_source:takeReputationPoints(15) then
						comms_source.expedite_dock = true
						comms_source.expedite_dock_station = comms_target
						comms_source.expedite_dock_timer_max = 180
						preOrderOrdnance()
					else
						setCommsMessage("Insufficient reputation")
					end
					addCommsReply("Back", commsStation)
				end)
			end
			addCommsReply("Back", commsStation)
		end)
	end
 	addCommsReply("I need information", function()
 		local ctd = comms_target.comms_data
		setCommsMessage("What kind of information do you need?")
		addCommsReply("What ordnance do you have available for restock?", function()
			local ctd = comms_target.comms_data
			local missileTypeAvailableCount = 0
			local ordnanceListMsg = ""
			if ctd.weapon_available.Nuke then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				ordnanceListMsg = ordnanceListMsg .. "\n   Nuke"
			end
			if ctd.weapon_available.EMP then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				ordnanceListMsg = ordnanceListMsg .. "\n   EMP"
			end
			if ctd.weapon_available.Homing then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				ordnanceListMsg = ordnanceListMsg .. "\n   Homing"
			end
			if ctd.weapon_available.Mine then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				ordnanceListMsg = ordnanceListMsg .. "\n   Mine"
			end
			if ctd.weapon_available.HVLI then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				ordnanceListMsg = ordnanceListMsg .. "\n   HVLI"
			end
			if missileTypeAvailableCount == 0 then
				ordnanceListMsg = "We have no ordnance available for restock"
			elseif missileTypeAvailableCount == 1 then
				ordnanceListMsg = "We have the following type of ordnance available for restock:" .. ordnanceListMsg
			else
				ordnanceListMsg = "We have the following types of ordnance available for restock:" .. ordnanceListMsg
			end
			setCommsMessage(ordnanceListMsg)
			addCommsReply("Back", commsStation)
		end)
		local goodsAvailable = false
		if ctd.goods ~= nil then
			for good, goodData in pairs(ctd.goods) do
				if goodData["quantity"] > 0 then
					goodsAvailable = true
				end
			end
		end
		if goodsAvailable then
			addCommsReply("What goods do you have available for sale or trade?", function()
				local ctd = comms_target.comms_data
				local goodsAvailableMsg = string.format("Station %s:\nGoods or components available: quantity, cost in reputation",comms_target:getCallSign())
				for good, goodData in pairs(ctd.goods) do
					goodsAvailableMsg = goodsAvailableMsg .. string.format("\n   %14s: %2i, %3i",good,goodData["quantity"],goodData["cost"])
				end
				setCommsMessage(goodsAvailableMsg)
				addCommsReply("Back", commsStation)
			end)
		end
		addCommsReply("Where can I find particular goods?", function()
			local ctd = comms_target.comms_data
			gkMsg = "Friendly stations often have food or medicine or both. Neutral stations may trade their goods for food, medicine or luxury."
			if ctd.goodsKnowledge == nil then
				ctd.goodsKnowledge = {}
				local knowledgeCount = 0
				local knowledgeMax = 10
				for i=1,#regionStations do
					local station = regionStations[i]
					if station ~= nil and station:isValid() then
						local brainCheckChance = 60
						if distance(comms_target,station) > 75000 then
							brainCheckChance = 20
						end
						for good, goodData in pairs(ctd.goods) do
							if random(1,100) <= brainCheckChance then
								local stationCallSign = station:getCallSign()
								local stationSector = station:getSectorName()
								ctd.goodsKnowledge[good] =	{	station = stationCallSign,
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
			for good, goodKnowledge in pairs(ctd.goodsKnowledge) do
				goodsKnowledgeCount = goodsKnowledgeCount + 1
				addCommsReply(good, function()
					local ctd = comms_target.comms_data
					local stationName = ctd.goodsKnowledge[good]["station"]
					local sectorName = ctd.goodsKnowledge[good]["sector"]
					local goodName = good
					local goodCost = ctd.goodsKnowledge[good]["cost"]
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
		if ctd.public_relations then
			addCommsReply("Tell me more about your station", function()
				local ctd = comms_target.comms_data
				setCommsMessage("What would you like to know?")
				addCommsReply("General information", function()
					local ctd = comms_target.comms_data
					setCommsMessage(ctd.general_information)
					addCommsReply("Back", commsStation)
				end)
				if ctd.history ~= nil then
					addCommsReply("Station history", function()
						local ctd = comms_target.comms_data
						setCommsMessage(ctd.history)
						addCommsReply("Back", commsStation)
					end)
				end
				if comms_source:isFriendly(comms_target) then
					if ctd.gossip ~= nil then
						if random(1,100) < 50 then
							addCommsReply("Gossip", function()
								local ctd = comms_target.comms_data
								setCommsMessage(ctd.gossip)
								addCommsReply("Back", commsStation)
							end)
						end
					end
				end
			end)	--end station info comms reply branch
		end	--end public relations if branch
		addCommsReply("Report status", function()
			msg = "Hull: " .. math.floor(comms_target:getHull() / comms_target:getHullMax() * 100) .. "%\n"
			local shields = comms_target:getShieldCount()
			if shields == 1 then
				msg = msg .. "Shield: " .. math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100) .. "%\n"
			else
				for n=0,shields-1 do
					msg = msg .. "Shield " .. n .. ": " .. math.floor(comms_target:getShieldLevel(n) / comms_target:getShieldMax(n) * 100) .. "%\n"
				end
			end			
			setCommsMessage(msg);
			addCommsReply("Back", commsStation)
		end)
	end)
	if isAllowedTo(ctd.services.supplydrop) then
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
    if isAllowedTo(ctd.services.reinforcements) then
        addCommsReply("Please send reinforcements! ("..getServiceCost("reinforcements").."rep)", function()
            if comms_source:getWaypointCount() < 1 then
                setCommsMessage("You need to set a waypoint before you can request reinforcements.");
            else
                setCommsMessage("To which waypoint should we dispatch the reinforcements?");
                for n=1,comms_source:getWaypointCount() do
                    addCommsReply("WP" .. n, function()
						if comms_source:takeReputationPoints(getServiceCost("reinforcements")) then
							ship = CpuShip():setFactionId(comms_target:getFactionId()):setPosition(comms_target:getPosition()):setTemplate("Adder MK5"):setScanned(true):orderDefendLocation(comms_source:getWaypoint(n))
							ship:setCommsScript(""):setCommsFunction(commsShip)
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
    return math.ceil(comms_data.service_cost[service])
end
function getFriendStatus()
    if comms_source:isFriendly(comms_target) then
        return "friend"
    else
        return "neutral"
    end
end
--Cargo Inventory button for relay or operations
function cargoInventory1()
	local p = getPlayerShip(1)
	playerShipCargoInventory(p)
end
function cargoInventory2()
	local p = getPlayerShip(2)
	playerShipCargoInventory(p)
end
function cargoInventory3()
	local p = getPlayerShip(3)
	playerShipCargoInventory(p)
end
function cargoInventory4()
	local p = getPlayerShip(4)
	playerShipCargoInventory(p)
end
function cargoInventory5()
	local p = getPlayerShip(5)
	playerShipCargoInventory(p)
end
function cargoInventory6()
	local p = getPlayerShip(6)
	playerShipCargoInventory(p)
end
function cargoInventory7()
	local p = getPlayerShip(7)
	playerShipCargoInventory(p)
end
function cargoInventory8()
	local p = getPlayerShip(8)
	playerShipCargoInventory(p)
end
function playerShipCargoInventory(p)
	p:addToShipLog(string.format("%s Current cargo:",p:getCallSign()),"Yellow")
	local goodCount = 0
	if p.goods ~= nil then
		for good, goodQuantity in pairs(p.goods) do
			goodCount = goodCount + 1
			p:addToShipLog(string.format("     %s: %i",good,goodQuantity),"Yellow")
		end
	end
	if goodCount < 1 then
		p:addToShipLog("     Empty","Yellow")
	end
	p:addToShipLog(string.format("Available space: %i",p.cargo),"Yellow")
end
function resetPreviousSystemHealth(p)
	if healthDiagnostic then print("reset previous system health") end
	if p == nil then
		p = comms_source
		if healthDiagnostic then print("set p to comms source") end
	end
	if healthDiagnostic then print("reset shield") end
	local currentShield = 0
	if p:getShieldCount() > 1 then
		currentShield = (p:getSystemHealth("frontshield") + p:getSystemHealth("rearshield"))/2
	else
		currentShield = p:getSystemHealth("frontshield")
	end
	p.prevShield = currentShield
	if healthDiagnostic then print("reset reactor") end
	p.prevReactor = p:getSystemHealth("reactor")
	if healthDiagnostic then print("reset maneuver") end
	p.prevManeuver = p:getSystemHealth("maneuver")
	if healthDiagnostic then print("reset impulse") end
	p.prevImpulse = p:getSystemHealth("impulse")
	if healthDiagnostic then print("reset beam") end
	if p:getBeamWeaponRange(0) > 0 then
		if p.healthyBeam == nil then
			p.healthyBeam = 1.0
			p.prevBeam = 1.0
		end
		p.prevBeam = p:getSystemHealth("beamweapons")
	end
	if healthDiagnostic then print("reset missile") end
	if p:getWeaponTubeCount() > 0 then
		if p.healthyMissile == nil then
			p.healthyMissile = 1.0
			p.prevMissile = 1.0
		end
		p.prevMissile = p:getSystemHealth("missilesystem")
	end
	if healthDiagnostic then print("reset warp") end
	if p:hasWarpDrive() then
		if p.healthyWarp == nil then
			p.healthyWarp = 1.0
			p.prevWarp = 1.0
		end
		p.prevWarp = p:getSystemHealth("warp")
	end
	if healthDiagnostic then print("reset jump") end
	if p:hasJumpDrive() then
		if p.healthyJump == nil then
			p.healthyJump = 1.0
			p.prevJump = 1.0
		end
		p.prevJump = p:getSystemHealth("jumpdrive")
	end
	if healthDiagnostic then print("end of reset previous system health function") end
end
function update(delta)
	if updateDiagnostic then print("update: top of update function") end
	--generic sandbox items
	if timer_started then
		if timer_value == nil then
			timer_value = delta + timer_start_length*60
		end
		timer_value = timer_value - delta
	end
	healthCheckTimer = healthCheckTimer - delta
	for pidx=1,8 do
		if updateDiagnostic then print("update: pidx: " .. pidx) end
		local p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			if updateDiagnostic then print("update: valid player: adjust spawn point") end
			if p.spawnAdjust == nil then
				p:setPosition(playerSpawnX,playerSpawnY)	--put player in the correct region when spawned
				p.spawnAdjust = true
				assignPlayerShipScore(p)
			end
			if updateDiagnostic then print("update: valid player: inventory button") end
			if p.inventoryButton == nil then
				local goodCount = 0
				if p.goods ~= nil then
					for good, goodQuantity in pairs(p.goods) do
						goodCount = goodCount + 1
					end
				end
				if goodCount > 0 then		--add inventory button when cargo acquired
					if p:hasPlayerAtPosition("Relay") then
						if p.inventoryButton == nil then
							local tbi = "inventory" .. p:getCallSign()
							p:addCustomButton("Relay",tbi,"Inventory",cargoInventoryList[pidx])
							p.inventoryButton = true
						end
					end
					if p:hasPlayerAtPosition("Operations") then
						if p.inventoryButton == nil then
							local tbi = "inventoryOp" .. p:getCallSign()
							p:addCustomButton("Operations",tbi,"Inventory",cargoInventoryList[pidx])
							p.inventoryButton = true
						end
					end
					
				end
			end
			if updateDiagnostic then print("update: valid player: rendezvous point message") end
			if #rendezvousPoints > 0 then
				for _,rp in pairs(rendezvousPoints) do	--send rendezvous point message when applicable
					if rp.message == nil then
						rp.message = "sent"
						if p.rpMessage == nil then
							p.rpMessage = {}
						end
						rpCallSign = rp:getCallSign()
						if p.rpMessage[rpCallSign] == nil then
							p:addToShipLog(string.format("Coordinates for %s saved and ready for Engineering and Helm to transport",rpCallSign),"Green")
							p.rpMessage[rpCallSign] = "sent"
						end
					end
				end
			end
			if updateDiagnostic then print("update: valid player: scan clues") end
			if #scanClueList > 0 then	--decrement scan clue timer(s) and delete when applicable
				for sci,sc in pairs(scanClueList) do
					if sc:isValid() then
						if sc.timeToLive == nil then
							sc.timeToLive = delta + 300
						else
							sc.timeToLive = sc.timeToLive - delta
							if sc.timeToLive < 0 then
								table.remove(scanClueList,sci)
								sc:destroy()
							end
						end
					else
						table.remove(scanClueList,sci)
						sc:destroy()						
					end
				end
			end
			if updateDiagnostic then print("update: valid player: mortal repair crew") end
			if healthCheckTimer < 0 then	--check to see if any crew perish due to excessive damage
				if p:getRepairCrewCount() > 0 then
					local fatalityChance = 0
					local currentShield = 0
					if p:getShieldCount() > 1 then
						currentShield = (p:getSystemHealth("frontshield") + p:getSystemHealth("rearshield"))/2
					else
						currentShield = p:getSystemHealth("frontshield")
					end
					fatalityChance = fatalityChance + (p.prevShield - currentShield)
					p.prevShield = currentShield
					local currentReactor = p:getSystemHealth("reactor")
					fatalityChance = fatalityChance + (p.prevReactor - currentReactor)
					p.prevReactor = currentReactor
					local currentManeuver = p:getSystemHealth("maneuver")
					fatalityChance = fatalityChance + (p.prevManeuver - currentManeuver)
					p.prevManeuver = currentManeuver
					local currentImpulse = p:getSystemHealth("impulse")
					fatalityChance = fatalityChance + (p.prevImpulse - currentImpulse)
					p.prevImpulse = currentImpulse
					if p:getBeamWeaponRange(0) > 0 then
						if p.healthyBeam == nil then
							p.healthyBeam = 1.0
							p.prevBeam = 1.0
						end
						local currentBeam = p:getSystemHealth("beamweapons")
						fatalityChance = fatalityChance + (p.prevBeam - currentBeam)
						p.prevBeam = currentBeam
					end
					if p:getWeaponTubeCount() > 0 then
						if p.healthyMissile == nil then
							p.healthyMissile = 1.0
							p.prevMissile = 1.0
						end
						local currentMissile = p:getSystemHealth("missilesystem")
						fatalityChance = fatalityChance + (p.prevMissile - currentMissile)
						p.prevMissile = currentMissile
					end
					if p:hasWarpDrive() then
						if p.healthyWarp == nil then
							p.healthyWarp = 1.0
							p.prevWarp = 1.0
						end
						local currentWarp = p:getSystemHealth("warp")
						fatalityChance = fatalityChance + (p.prevWarp - currentWarp)
						p.prevWarp = currentWarp
					end
					if p:hasJumpDrive() then
						if p.healthyJump == nil then
							p.healthyJump = 1.0
							p.prevJump = 1.0
						end
						local currentJump = p:getSystemHealth("jumpdrive")
						fatalityChance = fatalityChance + (p.prevJump - currentJump)
						p.prevJump = currentJump
					end
					if p:getRepairCrewCount() == 1 then
						fatalityChance = fatalityChance/2	-- increase survival chances of last repair crew standing
					end
					if fatalityChance > 0 then
						if math.random() < (fatalityChance) then
							if p.initialCoolant == nil then
								p:setRepairCrewCount(p:getRepairCrewCount() - 1)
								if p:hasPlayerAtPosition("Engineering") then
									local repairCrewFatality = "repairCrewFatality"
									p:addCustomMessage("Engineering",repairCrewFatality,"One of your repair crew has perished")
								end
								if p:hasPlayerAtPosition("Engineering+") then
									local repairCrewFatalityPlus = "repairCrewFatalityPlus"
									p:addCustomMessage("Engineering+",repairCrewFatalityPlus,"One of your repair crew has perished")
								end
							else
								if random(1,100) < 50 then
									p:setRepairCrewCount(p:getRepairCrewCount() - 1)
									if p:hasPlayerAtPosition("Engineering") then
										local repairCrewFatality = "repairCrewFatality"
										p:addCustomMessage("Engineering",repairCrewFatality,"One of your repair crew has perished")
									end
									if p:hasPlayerAtPosition("Engineering+") then
										local repairCrewFatalityPlus = "repairCrewFatalityPlus"
										p:addCustomMessage("Engineering+",repairCrewFatalityPlus,"One of your repair crew has perished")
									end
								else
									p:setMaxCoolant(p:getMaxCoolant()*.5)
									if p:hasPlayerAtPosition("Engineering") then
										local coolantLoss = "coolantLoss"
										p:addCustomMessage("Engineering",coolantLoss,"Damage has caused a loss of coolant")
									end
									if p:hasPlayerAtPosition("Engineering+") then
										local coolantLossPlus = "coolantLossPlus"
										p:addCustomMessage("Engineering+",coolantLossPlus,"Damage has caused a loss of coolant")
									end
								end	--coolant loss branch
							end	--could lose coolant branch
						end	--bad consequences of damage branch
					end	--possible chance of bad consequences branch
				else	--no repair crew left
					if random(1,100) <= 4 then
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
					end	--medical science triumph branch
				end	--no repair crew left
			end	--health check branch
			if p.expedite_dock then
				if p.expedite_dock_timer == nil then
					p.expedite_dock_timer = p.expedite_dock_timer_max + delta
				end
				p.expedite_dock_timer = p.expedite_dock_timer - delta
				if p.expedite_dock_timer < 0 then
					if p.expedite_dock_timer < -1 then
						if p.expedite_dock_timer_info ~= nil then
							p:removeCustom(p.expedite_dock_timer_info)
							p.expedite_dock_timer_info = nil
						end
						if p.expedite_dock_timer_info_ops ~= nil then
							p:removeCustom(p.expedite_dock_timer_info_ops)
							p.expedite_dock_timer_info_ops = nil
						end
						p:addToShipLog(string.format("Docking crew of station %s returned to their normal duties",p.expedite_doc_station:getCallSign()),"Yellow")
						p.expedite_dock = nil
						p.expedite_timer = nil
						p.expedite_dock_station = nil
						p.preorder_hvli = nil
						p.preorder_homing = nil
						p.preorder_emp = nil
						p.preorder_nuke = nil
						p.preorder_repair_crew = nil
						p.preorder_coolant = nil
					else
						if p:hasPlayerAtPosition("Relay") then
							p.expedite_dock_timer_info = "expedite_dock_timer_info"
							p:addCustomInfo("Relay",p.expedite_dock_timer_info,"Fast Dock Expired")						
						end
						if p:hasPlayerAtPosition("Operations") then
							p.expedite_dock_timer_info_ops = "expedite_dock_timer_info_ops"
							p:addCustomInfo("Relay",p.expedite_dock_timer_info_ops,"Fast Dock Expired")						
						end
					end
				else	--timer not expired
					local expedite_dock_timer_status = "Fast Dock"
					local expedite_dock_timer_minutes = math.floor(p.expedite_dock_timer / 60)
					local expedite_dock_timer_seconds = math.floor(p.expedite_dock_timer % 60)
					if expedite_dock_timer_minutes <= 0 then
						expedite_dock_timer_status = string.format("%s %i",expedite_dock_timer_status,expedite_dock_timer_seconds)
					else
						expedite_dock_timer_status = string.format("%s %i:%.2i",expedite_dock_timer_status,expedite_dock_timer_minutes,expedite_dock_timer_seconds)
					end
					if p:hasPlayerAtPosition("Relay") then
						p.expedite_dock_timer_info = "expedite_dock_timer_info"
						p:addCustomInfo("Relay",p.expedite_dock_timer_info,expedite_dock_timer_status)
					end
					if p:hasPlayerAtPosition("Operations") then
						p.expedite_dock_timer_info_ops = "expedite_dock_timer_info_ops"
						p:addCustomInfo("Operations",p.expedite_dock_timer_info_ops,expedite_dock_timer_status)
					end					
				end
				if p.expedite_dock_station ~= nil and p.expedite_dock_station:isValid() then
					if p:isDocked(p.expedite_dock_station) then
						p:setEnergy(p:getMaxEnergy())
						p:setScanProbeCount(p:getMaxScanProbeCount())
						if p.preorder_hvli ~= nil then
							local new_amount = math.min(p:getWeaponStorage("HVLI") + p.preorder_hvli,p:getWeaponStorageMax("HVLI"))
							p:setWeaponStorage("HVLI",new_amount)
						end
						if p.preorder_homing ~= nil then
							new_amount = math.min(p:getWeaponStorage("Homing") + p.preorder_homing,p:getWeaponStorageMax("Homing"))
							p:setWeaponStorage("Homing",new_amount)
						end
						if p.preorder_mine ~= nil then
							new_amount = math.min(p:getWeaponStorage("Mine") + p.preorder_mine,p:getWeaponStorageMax("Mine"))
							p:setWeaponStorage("Mine",new_amount)
						end
						if p.preorder_emp ~= nil then
							new_amount = math.min(p:getWeaponStorage("EMP") + p.preorder_emp,p:getWeaponStorageMax("EMP"))
							p:setWeaponStorage("EMP",new_amount)
						end
						if p.preorder_nuke ~= nil then
							new_amount = math.min(p:getWeaponStorage("Nuke") + p.preorder_nuke,p:getWeaponStorageMax("Nuke"))
							p:setWeaponStorage("Nuke",new_amount)
						end
						if p.preorder_repair_crew ~= nil then
							p:setRepairCrewCount(p:getRepairCrewCount() + 1)
							resetPreviousSystemHealth()
						end
						if p.preorder_coolant ~= nil then
							p:setMaxCoolant(p:getMaxCoolant() + 2)
						end
						if p.expedite_dock_timer_info ~= nil then
							p:removeCustom(p.expedite_dock_timer_info)
							p.expedite_dock_timer_info = nil
						end
						if p.expedite_dock_timer_info_ops ~= nil then
							p:removeCustom(p.expedite_dock_timer_info_ops)
							p.expedite_dock_timer_info_ops = nil
						end
						p:addToShipLog(string.format("Docking crew at station %s completed replenishment as requested",p.expedite_dock_station:getCallSign()),"Yellow")
						p.expedite_dock = nil
						p.expedite_timer = nil
						p.expedite_dock_station = nil
						p.preorder_hvli = nil
						p.preorder_homing = nil
						p.preorder_emp = nil
						p.preorder_nuke = nil
						p.preorder_repair_crew = nil
						p.preorder_coolant = nil
					end
				end
			end
			if timer_started then
				if timer_value < 0 then	--timer expired
					if timer_value < -1 then	--timer expired condition expired
						if p.timer_helm ~= nil then
							p:removeCustom(p.timer_helm)
							p.timer_helm = nil
						end
						if p.timer_weapons ~= nil then
							p:removeCustom(p.timer_weapons)
							p.timer_weapons = nil
						end
						if p.timer_engineer ~= nil then
							p:removeCustom(p.timer_engineer)
							p.timer_engineer = nil
						end
						if p.timer_science ~= nil then
							p:removeCustom(p.timer_science)
							p.timer_science = nil
						end
						if p.timer_relay ~= nil then
							p:removeCustom(p.timer_relay)
							p.timer_relay = nil
						end
						if p.timer_tactical ~= nil then
							p:removeCustom(p.timer_tactical)
							p.timer_tactical = nil
						end
						if p.timer_operations ~= nil then
							p:removeCustom(p.timer_operations)
							p.timer_operations = nil
						end
						if p.timer_engineer_plus ~= nil then
							p:removeCustom(p.timer_engineer_plus)
							p.timer_engineer_plus = nil
						end
						timer_started = false
						timer_value = nil
						timer_gm_message = nil
					else	--timer expired (less than 0 but not less than -1)
						local final_status = timer_purpose .. " Expired"
						if timer_gm_message == nil then
							timer_gm_message = "sent"
							addGMMessage(final_status)
						end
						if timer_display_helm then
							if p:hasPlayerAtPosition("Helms") then
								p.timer_helm = "timer_helm"
								p:addCustomInfo("Helms",p.timer_helm,final_status)
							end
							if p:hasPlayerAtPosition("Tactical") then
								p.timer_tactical = "timer_tactical"
								p:addCustomInfo("Tactical",p.timer_tactical,final_status)
							end
						end
						if timer_display_weapons then
							if p:hasPlayerAtPosition("Weapons") then
								p.timer_weapons = "timer_weapons"
								p:addCustomInfo("Weapons",p.timer_weapons,final_status)
							end
							if p:hasPlayerAtPosition("Tactical") and p.timer_tactical == nil then
								p.timer_tactical = "timer_tactical"
								p:addCustomInfo("Tactical",p.timer_tactical,final_status)
							end
						end
						if timer_display_engineer then
							if p:hasPlayerAtPosition("Engineering") then
								p.timer_engineer = "timer_engineer"
								p:addCustomInfo("Engineering",p.timer_engineer,final_status)
							end
							if p:hasPlayerAtPosition("Engineering+") then
								p.timer_engineer_plus = "timer_engineer_plus"
								p:addCustomInfo("Engineering+",p.timer_engineer_plus,final_status)
							end
						end
						if timer_display_science then
							if p:hasPlayerAtPosition("Science") then
								p.timer_science = "timer_science"
								p:addCustomInfo("Science",p.timer_science,final_status)
							end
							if p:hasPlayerAtPosition("Operations") then
								p.timer_operations = "timer_operations"
								p:addCustomInfo("Operations",p.timer_operations,final_status)
							end
						end
						if timer_display_relay then
							if p:hasPlayerAtPosition("Relay") then
								p.timer_relay = "timer_relay"
								p:addCustomInfo("Relay",p.timer_relay,final_status)
							end
							if p:hasPlayerAtPosition("Operations") and p.timer_operations == nil then
								p.timer_operations = "timer_operations"
								p:addCustomInfo("Operations",p.timer_operations,final_status)
							end
						end	--relay timer display final status
					end	--end of timer value less than -1 checks
				else	--time has not yet expired
					local timer_status = timer_purpose
					local timer_minutes = math.floor(timer_value / 60)
					local timer_seconds = math.floor(timer_value % 60)
					if timer_minutes <= 0 then
						timer_status = string.format("%s %i",timer_status,timer_seconds)
					else
						timer_status = string.format("%s %i:%.2i",timer_status,timer_minutes,timer_seconds)
					end
					if timer_display_helm then
						if p:hasPlayerAtPosition("Helms") then
							p.timer_helm = "timer_helm"
							p:addCustomInfo("Helms",p.timer_helm,timer_status)
						end
						if p:hasPlayerAtPosition("Tactical") then
							p.timer_tactical = "timer_tactical"
							p:addCustomInfo("Tactical",p.timer_tactical,timer_status)
						end
					end
					if timer_display_weapons then
						if p:hasPlayerAtPosition("Weapons") then
							p.timer_weapons = "timer_weapons"
							p:addCustomInfo("Weapons",p.timer_weapons,timer_status)
						end
						if p:hasPlayerAtPosition("Tactical") and p.timer_tactical == nil then
							p.timer_tactical = "timer_tactical"
							p:addCustomInfo("Tactical",p.timer_tactical,timer_status)
						end
					end
					if timer_display_engineer then
						if p:hasPlayerAtPosition("Engineering") then
							p.timer_engineer = "timer_engineer"
							p:addCustomInfo("Engineering",p.timer_engineer,timer_status)
						end
						if p:hasPlayerAtPosition("Engineering+") then
							p.timer_engineer_plus = "timer_engineer_plus"
							p:addCustomInfo("Engineering+",p.timer_engineer_plus,timer_status)
						end
					end
					if timer_display_science then
						if p:hasPlayerAtPosition("Science") then
							p.timer_science = "timer_science"
							p:addCustomInfo("Science",p.timer_science,timer_status)
						end
						if p:hasPlayerAtPosition("Operations") then
							p.timer_operations = "timer_operations"
							p:addCustomInfo("Operations",p.timer_operations,timer_status)
						end
					end
					if timer_display_relay then
						if p:hasPlayerAtPosition("Relay") then
							p.timer_relay = "timer_relay"
							p:addCustomInfo("Relay",p.timer_relay,timer_status)
						end
						if p:hasPlayerAtPosition("Operations") and p.timer_operations == nil then
							p.timer_operations = "timer_operations"
							p:addCustomInfo("Operations",p.timer_operations,timer_status)
						end
					end	--end relay timer display
				end	--end of timer started boolean checks
			else	--timer started boolean is false
				if p.timer_helm ~= nil then
					p:removeCustom(p.timer_helm)
					p.timer_helm = nil
				end
				if p.timer_weapons ~= nil then
					p:removeCustom(p.timer_weapons)
					p.timer_weapons = nil
				end
				if p.timer_engineer ~= nil then
					p:removeCustom(p.timer_engineer)
					p.timer_engineer = nil
				end
				if p.timer_science ~= nil then
					p:removeCustom(p.timer_science)
					p.timer_science = nil
				end
				if p.timer_relay ~= nil then
					p:removeCustom(p.timer_relay)
					p.timer_relay = nil
				end
				if p.timer_tactical ~= nil then
					p:removeCustom(p.timer_tactical)
					p.timer_tactical = nil
				end
				if p.timer_operations ~= nil then
					p:removeCustom(p.timer_operations)
					p.timer_operations = nil
				end
				if p.timer_engineer_plus ~= nil then
					p:removeCustom(p.timer_engineer_plus)
					p.timer_engineer_plus = nil
				end
				timer_value = nil
				timer_gm_message = nil
			end	--end of timer started boolean checks
			if updateDiagnostic then print("update: end of player loop") end
		end	--player loop
	end
	if updateDiagnostic then print("update: outside player loop") end
	if healthCheckTimer < 0 then
		healthCheckTimer = delta + healthCheckTimerInterval
	end
	if plotRevert ~= nil then
		plotRevert(delta)
	end
	if plotMobile ~= nil then
		plotMobile(delta)
	end
	if plotPulse ~= nil then
		plotPulse(delta)
	end
	if updateDiagnostic then print("update: end of update function") end
end
function movingObjects(delta)
	if icarus_mobile_nebula_1 ~= nil and icarus_mobile_nebula_1:isValid() then
		local neb_x, neb_y = icarus_mobile_nebula_1:getPosition()
		if neb_x < -10000 then
			neb_x = -10000
		    icarus_mobile_nebula_1.increment = random(0,10)
			if neb_y > 110000 then
				--icarus_mobile_nebula_1.angle = random(1,89)
				icarus_mobile_nebula_1.angle = random(271,359)
			else
				--icarus_mobile_nebula_1.angle = random(91,179)
				icarus_mobile_nebula_1.angle = random(1,89)
			end
		end
		if neb_x > 80000 then
			neb_x = 80000
		    icarus_mobile_nebula_1.increment = random(0,10)
			if neb_y > 110000 then
				--icarus_mobile_nebula_1.angle = random(271,359)
				icarus_mobile_nebula_1.angle = random(181,269)
			else
				--icarus_mobile_nebula_1.angle = random(181,269)
				icarus_mobile_nebula_1.angle = random(91,179)
			end
		end
		if neb_y < 80000 then
			neb_y = 80000
		    icarus_mobile_nebula_1.increment = random(0,10)
			if neb_x > 45000 then
				--icarus_mobile_nebula_1.angle = random(181,269)
				icarus_mobile_nebula_1.angle = random(91,179)
			else
				--icarus_mobile_nebula_1.angle = random(91,179)
				icarus_mobile_nebula_1.angle = random(1,89)
			end
		end
		if neb_y > 140000 then
			neb_y = 140000
		    icarus_mobile_nebula_1.increment = random(0,10)
			if neb_x > 45000 then
				--icarus_mobile_nebula_1.angle = random(271,359)
				icarus_mobile_nebula_1.angle = random(181,269)
			else
				--icarus_mobile_nebula_1.angle = random(1,89)
				icarus_mobile_nebula_1.angle = random(271,359)
			end
		end
		local dx, dy = vectorFromAngle(icarus_mobile_nebula_1.angle,icarus_mobile_nebula_1.increment)
		icarus_mobile_nebula_1:setPosition(neb_x+dx,neb_y+dy)
		local nr = icarus_mobile_nebula_1:getRotation()
		nr = nr + .01
		if nr > 360 then 
			nr = nr - 360
		end
		icarus_mobile_nebula_1:setRotation(nr)
	end
	if kentar_mobile_nebula_1 ~= nil and kentar_mobile_nebula_1:isValid() then
		if kentar_mobile_nebula_1.lower_black_hole then
			--print(string.format("Lower start angle: %f, ready: %s",kentar_mobile_nebula_1.angle,tostring(kentar_mobile_nebula_1.ready)))
			kentar_mobile_nebula_1.angle = kentar_mobile_nebula_1.angle + kentar_mobile_nebula_1.increment
			if kentar_mobile_nebula_1.angle > 360 then
				kentar_mobile_nebula_1.angle = kentar_mobile_nebula_1.angle - 360
			end
			--print(string.format("Lower mod 1 angle: %f, ready: %s",kentar_mobile_nebula_1.angle,tostring(kentar_mobile_nebula_1.ready)))
			if kentar_mobile_nebula_1.ready then
				if kentar_mobile_nebula_1.angle >= 315 then
					--switch
					kentar_mobile_nebula_1.lower_black_hole = false
					kentar_mobile_nebula_1.angle = 135 - (kentar_mobile_nebula_1.angle - 315)
					kentar_mobile_nebula_1.center_x = 290000
					kentar_mobile_nebula_1.center_y = 210000
					kentar_mobile_nebula_1.ready = false
				end
			else
				if kentar_mobile_nebula_1.angle < 315 then
					kentar_mobile_nebula_1.ready = true
				end
			end
			--print(string.format("Lower mod 2 angle: %f, ready: %s",kentar_mobile_nebula_1.angle,tostring(kentar_mobile_nebula_1.ready)))
		else
			--print(string.format("Upper start angle: %f, ready: %s",kentar_mobile_nebula_1.angle,tostring(kentar_mobile_nebula_1.ready)))
			kentar_mobile_nebula_1.angle = kentar_mobile_nebula_1.angle - kentar_mobile_nebula_1.increment
			if kentar_mobile_nebula_1.angle < 0 then
				kentar_mobile_nebula_1.angle = kentar_mobile_nebula_1.angle + 360
			end
			--print(string.format("Upper mod 1 angle: %f, ready: %s",kentar_mobile_nebula_1.angle,tostring(kentar_mobile_nebula_1.ready)))
			if kentar_mobile_nebula_1.ready then
				if kentar_mobile_nebula_1.angle <= 135 then
					--switch
					kentar_mobile_nebula_1.lower_black_hole = true
					kentar_mobile_nebula_1.angle = 315 + (135 - kentar_mobile_nebula_1.angle)
					kentar_mobile_nebula_1.center_x = 210000
					kentar_mobile_nebula_1.center_y = 290000
					kentar_mobile_nebula_1.ready = false
				end
			else
				if kentar_mobile_nebula_1.angle > 135 then
					kentar_mobile_nebula_1.ready = true
				end
			end
			--print(string.format("Upper mod 2 angle: %f, ready: %s",kentar_mobile_nebula_1.angle,tostring(kentar_mobile_nebula_1.ready)))
		end
		local px,py = vectorFromAngle(kentar_mobile_nebula_1.angle,kentar_mobile_nebula_1.mobile_neb_dist)
		kentar_mobile_nebula_1:setPosition(kentar_mobile_nebula_1.center_x+px,kentar_mobile_nebula_1.center_y+py)
	end
end
function crewFate(p, fatalityChance)
	if math.random() < (fatalityChance) then
		if p.initialCoolant == nil then
			p:setRepairCrewCount(p:getRepairCrewCount() - 1)
			if p:hasPlayerAtPosition("Engineering") then
				local repairCrewFatality = "repairCrewFatality"
				p:addCustomMessage("Engineering",repairCrewFatality,"One of your repair crew has perished")
			end
			if p:hasPlayerAtPosition("Engineering+") then
				local repairCrewFatalityPlus = "repairCrewFatalityPlus"
				p:addCustomMessage("Engineering+",repairCrewFatalityPlus,"One of your repair crew has perished")
			end
		else
			if random(1,100) < 50 then
				p:setRepairCrewCount(p:getRepairCrewCount() - 1)
				if p:hasPlayerAtPosition("Engineering") then
					local repairCrewFatality = "repairCrewFatality"
					p:addCustomMessage("Engineering",repairCrewFatality,"One of your repair crew has perished")
				end
				if p:hasPlayerAtPosition("Engineering+") then
					local repairCrewFatalityPlus = "repairCrewFatalityPlus"
					p:addCustomMessage("Engineering+",repairCrewFatalityPlus,"One of your repair crew has perished")
				end
			else
				p:setMaxCoolant(p:getMaxCoolant()*.5)
				if p:hasPlayerAtPosition("Engineering") then
					local coolantLoss = "coolantLoss"
					p:addCustomMessage("Engineering",coolantLoss,"Damage has caused a loss of coolant")
				end
				if p:hasPlayerAtPosition("Engineering+") then
					local coolantLossPlus = "coolantLossPlus"
					p:addCustomMessage("Engineering+",coolantLossPlus,"Damage has caused a loss of coolant")
				end
			end
		end
	end
end


