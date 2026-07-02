-- Player Ships
function addPlayerShip(name,typeName,func,ftl)
	assert(type(name)=="string",string.format("function addPlayerShip expected a string for the first argument, 'name,' but got a %s instead",type(name)))
	assert(type(typeName)=="string",string.format("function addPlayerShip expected a string for the second argument, 'typeName,' but got a %s instead",type(typeName)))
	assert(type(playerShipStats[typeName])=="table",string.format("function addPlayerShip used %s as a lookup value in playerShipStats and expected to get a table but did not",typeName))
	assert(type(func)=="function",string.format("function addPlayerShip expected a function for the third argument, 'func,' but got a %s instead",type(func)))
	assert(type(ftl)=="string",string.format("function addPlayerShip expected a string for the fourth argument, 'ftl,' but got a %s instead",type(ftl)))
	playerShipInfo[name]={active = "inactive",spawn = func, typeName = typeName, ftl = ftl}
end
function setPlayerShipStats()
--	patrol_probe value should be between 0 and 5 not inclusive (0 = no patrol probes). The higher the value, the faster the patrol probe and the fewer patrol probes available 
	playerShipStats = {	
		["Atlantis"]			= { strength = 52,	cargo = 6,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, tractor = true,		mining = true,	probes = 10,	pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = false,	trigger_missile = nil,						balance_shield = false,	},
		["Benedict"]			= { strength = 10,	cargo = 9,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, tractor = true,		mining = true,	probes = 10,	pods = 3,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = false,	trigger_missile = nil,						balance_shield = false,	},
		["Crucible"]			= { strength = 45,	cargo = 5,	distance = 200,	long_range_radar = 20000, short_range_radar = 6000, tractor = false,	mining = false,	probes = 9,		pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 1,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = false,	trigger_missile = nil,						balance_shield = false,	},
		["Ender"]				= { strength = 100,	cargo = 20,	distance = 2000,long_range_radar = 45000, short_range_radar = 7000, tractor = true,		mining = false,	probes = 12,	pods = 6,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 2,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = false,	trigger_missile = nil,						balance_shield = false,	},
		["Flavia P.Falcon"]		= { strength = 13,	cargo = 15,	distance = 200,	long_range_radar = 40000, short_range_radar = 5000, tractor = true,		mining = true,	probes = 8,		pods = 4,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = false,	trigger_missile = nil,						balance_shield = false,	},
		["Hathcock"]			= { strength = 30,	cargo = 6,	distance = 200,	long_range_radar = 35000, short_range_radar = 6000, tractor = false,	mining = true,	probes = 8,		pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 1,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = false,	trigger_missile = nil,						balance_shield = false,	},
		["Kiriya"]				= { strength = 10,	cargo = 9,	distance = 400,	long_range_radar = 35000, short_range_radar = 5000, tractor = true,		mining = true,	probes = 10,	pods = 3,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = false,	trigger_missile = nil,						balance_shield = false,	},
		["Maverick"]			= { strength = 45,	cargo = 5,	distance = 200,	long_range_radar = 20000, short_range_radar = 4000, tractor = false,	mining = true,	probes = 9,		pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = true,	trigger_missile = nil,						balance_shield = false,	},
		["MP52 Hornet"] 		= { strength = 7, 	cargo = 3,	distance = 100,	long_range_radar = 18000, short_range_radar = 4000, tractor = false,	mining = false,	probes = 5,		pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = true,	trigger_missile = nil,						balance_shield = false,	},
		["Nautilus"]			= { strength = 12,	cargo = 7,	distance = 200,	long_range_radar = 22000, short_range_radar = 4000, tractor = false,	mining = false,	probes = 10,	pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = true,	trigger_missile = nil,						balance_shield = false,	},
		["Phobos M3P"]			= { strength = 19,	cargo = 10,	distance = 200,	long_range_radar = 25000, short_range_radar = 5000, tractor = true,		mining = false,	probes = 6,		pods = 3,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = true,	trigger_missile = nil,						balance_shield = false,	},
		["Piranha"]				= { strength = 16,	cargo = 8,	distance = 200,	long_range_radar = 25000, short_range_radar = 6000, tractor = false,	mining = false,	probes = 6,		pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 1,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = true,	trigger_missile = nil,						balance_shield = false,	},
		["Player Cruiser"]		= { strength = 40,	cargo = 6,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, tractor = false,	mining = false,	probes = 10,	pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = false,	trigger_missile = nil,						balance_shield = false,	},
		["Player Missile Cr."]	= { strength = 45,	cargo = 8,	distance = 200,	long_range_radar = 35000, short_range_radar = 6000, tractor = false,	mining = false,	probes = 9,		pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 1,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = false,	trigger_missile = nil,						balance_shield = false,	},
		["Player Fighter"]		= { strength = 7,	cargo = 3,	distance = 100,	long_range_radar = 15000, short_range_radar = 4500, tractor = false,	mining = false,	probes = 4,		pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = true,	trigger_missile = nil,						balance_shield = false,	},
		["Repulse"]				= { strength = 14,	cargo = 12,	distance = 200,	long_range_radar = 38000, short_range_radar = 5000, tractor = true,		mining = false,	probes = 8,		pods = 5,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = false,	trigger_missile = nil,						balance_shield = false,	},
		["Striker"]				= { strength = 8,	cargo = 4,	distance = 200,	long_range_radar = 35000, short_range_radar = 5000, tractor = false,	mining = false,	probes = 6,		pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = false,	trigger_missile = nil,						balance_shield = false,	},
		["ZX-Lindworm"]			= { strength = 8,	cargo = 3,	distance = 100,	long_range_radar = 18000, short_range_radar = 5500, tractor = false,	mining = false,	probes = 4,		pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 1,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = true,	trigger_missile = nil,						balance_shield = false,	},
	--	Custom player ships	
		["Amalgam"]				= { strength = 42,	cargo = 7,	distance = 400,	long_range_radar = 36000, short_range_radar = 5000, tractor = false,	mining = false,	probes = 11,	pods = 3,	turbo_torp = true,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	power_sensor_interval = 5,	beam_damage_switch = true,	way_dist = false,	trigger_missile = nil,						balance_shield = false,	},
		["Atlantis II"]			= { strength = 60,	cargo = 6,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, tractor = true,		mining = true,	probes = 11,	pods = 3,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = false,	trigger_missile = nil,						balance_shield = false,	},
		["Barrow"]				= { strength = 9,	cargo = 9,	distance = 400,	long_range_radar = 35000, short_range_radar = 5000, tractor = true,		mining = true,	probes = 12,	pods = 3,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 2,	power_sensor_interval = 5,	beam_damage_switch = false,	way_dist = false,	trigger_missile = nil,						balance_shield = false,	},
		["Bermuda"]				= { strength = 30,	cargo = 4,	distance = 400,	long_range_radar = 30000, short_range_radar = 4500, tractor = true,		mining = false,	probes = 14,	pods = 3,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = false,	trigger_missile = {"E3","N3"},				balance_shield = false,	},
		["Butler"]				= { strength = 20,	cargo = 6,	distance = 200,	long_range_radar = 30000, short_range_radar = 5500, tractor = true,		mining = false,	probes = 8,		pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = false,	trigger_missile = nil,						balance_shield = false,	},
		["Caretaker"]			= { strength = 23,	cargo = 6,	distance = 200,	long_range_radar = 35000, short_range_radar = 5000, tractor = true,		mining = false,	probes = 9,		pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = false,	trigger_missile = nil,						balance_shield = false,	},
		["Chavez"]				= { strength = 21,	cargo = 6,	distance = 200,	long_range_radar = 25000, short_range_radar = 5000, tractor = true,		mining = true,	probes = 8,		pods = 2,	turbo_torp = false,	patrol_probe = 2.5,	prox_scan = 0,	epjam = 1,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = true,	trigger_missile = nil,						balance_shield = false,	},
		["Crab"]				= { strength = 20,	cargo = 6,	distance = 200,	long_range_radar = 30000, short_range_radar = 5500, tractor = false,	mining = true,	probes = 13,	pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = false,	trigger_missile = nil,						balance_shield = false,	},
		["Deimos"]				= { strength = 28,	cargo = 8,	distance = 200,	long_range_radar = 25000, short_range_radar = 5000, tractor = false,	mining = true,	probes = 11,	pods = 3,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 3,	epjam = 1,	power_sensor_interval = 7.5,beam_damage_switch = false,	way_dist = true,	trigger_missile = {"E4","N4"},				balance_shield = false,	},
		["Destroyer III"]		= { strength = 25,	cargo = 7,	distance = 200,	long_range_radar = 32000, short_range_radar = 5000, tractor = false,	mining = false,	probes = 8,		pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = false,	trigger_missile = nil,						balance_shield = false,	},
		["Destroyer IV"]		= { strength = 27,	cargo = 5,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, tractor = false,	mining = true,	probes = 8,		pods = 1,	turbo_torp = true,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = false,	trigger_missile = nil,						balance_shield = false,	},
		["Eldridge"]			= { strength = 25,	cargo = 7,	distance = 200,	long_range_radar = 24000, short_range_radar = 8000, tractor = false,	mining = true,	probes = 10,	pods = 2,	turbo_torp = false,	patrol_probe = 3,	prox_scan = 3,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = true,	trigger_missile = nil,						balance_shield = false,	},
		["Era"]					= { strength = 14,	cargo = 14,	distance = 200,	long_range_radar = 50000, short_range_radar = 5000, tractor = true,		mining = true,	probes = 8,		pods = 4,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 9,	epjam = 3,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = false,	trigger_missile = {"N3","N4"},				balance_shield = false,	},
		["Flavia 2C"]			= { strength = 25,	cargo = 12,	distance = 200,	long_range_radar = 30000, short_range_radar = 5000, tractor = false,	mining = true,	probes = 9,		pods = 3,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = false,	trigger_missile = nil,						balance_shield = false,	},
		["Focus"]				= { strength = 35,	cargo = 4,	distance = 200,	long_range_radar = 32000, short_range_radar = 5000, tractor = false,	mining = true,	probes = 8,		pods = 1,	turbo_torp = true,	patrol_probe = 1.25,prox_scan = 0,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = false,	trigger_missile = nil,						balance_shield = false,	},
		["Fowl"]				= { strength = 8,	cargo = 3,	distance = 100,	long_range_radar = 15000, short_range_radar = 4500, tractor = false,	mining = false,	probes = 4,		pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 3,	power_sensor_interval = 7.5,beam_damage_switch = false,	way_dist = true,	trigger_missile = nil,						balance_shield = false,	},
		["Fray"]				= { strength = 22,	cargo = 5,	distance = 200,	long_range_radar = 23000, short_range_radar = 4500, tractor = true,		mining = false,	probes = 7,		pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = false,	trigger_missile = nil,						balance_shield = false,	},
		["Fresnel"]				= { strength = 8,	cargo = 3,	distance = 100,	long_range_radar = 15000, short_range_radar = 4500, tractor = false,	mining = false,	probes = 4,		pods = 1,	turbo_torp = true,	patrol_probe = 0,	prox_scan = 9,	epjam = 0,	power_sensor_interval = 6,	beam_damage_switch = false,	way_dist = true,	trigger_missile = nil,						balance_shield = false,	},
		["Gadfly"]				= { strength = 9,	cargo = 3,	distance = 100,	long_range_radar = 15000, short_range_radar = 4500, tractor = false,	mining = false,	probes = 4,		pods = 1,	turbo_torp = false,	patrol_probe = 3.6,	prox_scan = 9,	epjam = 0,	power_sensor_interval = 6,	beam_damage_switch = false,	way_dist = true,	trigger_missile = nil,						balance_shield = false,	},
		["Glass Cannon"]		= { strength = 15,	cargo = 3,	distance = 100,	long_range_radar = 30000, short_range_radar = 5000, tractor = false,	mining = false,	probes = 8,		pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = false,	trigger_missile = nil,						balance_shield = false,	},
		["Gull"]				= { strength = 14,	cargo = 14,	distance = 200,	long_range_radar = 40000, short_range_radar = 5000, tractor = true,		mining = true,	probes = 8,		pods = 4,	turbo_torp = false,	patrol_probe = 4,	prox_scan = 0,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = false,	trigger_missile = nil,						balance_shield = false,	},
		["Holmes"]				= { strength = 35,	cargo = 6,	distance = 200,	long_range_radar = 35000, short_range_radar = 4000, tractor = true,		mining = false,	probes = 8,		pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = false,	trigger_missile = nil,						balance_shield = false,	},
		["Interlock"]			= { strength = 19,	cargo = 12,	distance = 200,	long_range_radar = 35000, short_range_radar = 5500, tractor = false,	mining = true,	probes = 13,	pods = 3,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 1,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = false,	trigger_missile = nil,						balance_shield = false,	},
		["Kludge"]				= { strength = 22,	cargo = 9,	distance = 200,	long_range_radar = 35000, short_range_radar = 3500, tractor = false,	mining = true,	probes = 20,	pods = 5,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = false,	trigger_missile = {"E3"},					balance_shield = false,	},
		["Lurker"]				= { strength = 18,	cargo = 3,	distance = 100,	long_range_radar = 21000, short_range_radar = 6000, tractor = false,	mining = false,	probes = 4,		pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 1,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = true,	trigger_missile = {"E4"},					balance_shield = false,	},
		["Mantis"]				= { strength = 30,	cargo = 8,	distance = 200,	long_range_radar = 25000, short_range_radar = 6000, tractor = false,	mining = false,	probes = 9,		pods = 2,	turbo_torp = true,	patrol_probe = 0,	prox_scan = 1,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = true,	trigger_missile = {"E3","E4","N3","N4"},	balance_shield = false,	},
		["Maverick XP"]			= { strength = 23,	cargo = 5,	distance = 200,	long_range_radar = 25000, short_range_radar = 7000, tractor = true,		mining = false,	probes = 10,	pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 2,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = true,	trigger_missile = nil,						balance_shield = false,	},
		["Midian"]				= { strength = 30,	cargo = 9,	distance = 200,	long_range_radar = 25000, short_range_radar = 5500, tractor = false,	mining = false,	probes = 9,		pods = 3,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = true,	trigger_missile = {"E3","E4"},				balance_shield = false,	},
		["Mortar"]				= { strength = 45,	cargo = 5,	distance = 200,	long_range_radar = 25000, short_range_radar = 4500, tractor = false,	mining = true,	probes = 9,		pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = false,	trigger_missile = nil,						balance_shield = false,	},
		["MX-Lindworm"]			= { strength = 10,	cargo = 3,	distance = 100,	long_range_radar = 30000, short_range_radar = 6000, tractor = false,	mining = false,	probes = 5,		pods = 1,	turbo_torp = false,	patrol_probe = 3,	prox_scan = 9,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = false,	trigger_missile = nil,						balance_shield = false,	},
		["Noble"]				= { strength = 37,	cargo = 6,	distance = 400,	long_range_radar = 27000, short_range_radar = 5000, tractor = true,		mining = false,	probes = 8,		pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = false,	trigger_missile = nil,						balance_shield = false,	},
		["Nusret"]				= { strength = 16,	cargo = 7,	distance = 200,	long_range_radar = 25000, short_range_radar = 4000, tractor = false,	mining = true,	probes = 10,	pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 3,	power_sensor_interval = 5,	beam_damage_switch = false,	way_dist = true,	trigger_missile = nil,						balance_shield = false,	},
		["Orca"]				= { strength = 19,	cargo = 6,	distance = 200,	long_range_radar = 25000, short_range_radar = 5000, tractor = true,		mining = false,	probes = 6,		pods = 3,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 1,	epjam = 1,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = true,	trigger_missile = nil,						balance_shield = false,	},
		["Pacu"]				= { strength = 18,	cargo = 7,	distance = 200,	long_range_radar = 20000, short_range_radar = 6000, tractor = false,	mining = false,	probes = 6,		pods = 2,	turbo_torp = false,	patrol_probe = 2.5,	prox_scan = 1,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = true,	trigger_missile = nil,						balance_shield = false,	},
		["Peacock"]				= { strength = 30,	cargo = 9,	distance = 400,	long_range_radar = 25000, short_range_radar = 5000, tractor = false,	mining = true,	probes = 10,	pods = 3,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = true,	trigger_missile = nil,						balance_shield = false,	},
		["Phargus"]				= { strength = 15,	cargo = 6,	distance = 200,	long_range_radar = 20000, short_range_radar = 5500, tractor = false,	mining = false,	probes = 6,		pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = false,	trigger_missile = nil,						balance_shield = false,	},
		["Phobos T2"]			= { strength = 19,	cargo = 9,	distance = 200,	long_range_radar = 25000, short_range_radar = 5000, tractor = true,		mining = false,	probes = 5,		pods = 3,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = true,	trigger_missile = nil,						balance_shield = false,	},
		["Phobos T2.2"]			= { strength = 19,	cargo = 9,	distance = 200,	long_range_radar = 25000, short_range_radar = 5000, tractor = true,		mining = false,	probes = 5,		pods = 3,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = true,	trigger_missile = nil,						balance_shield = false,	},
		["Phoenix"]				= { strength = 40,	cargo = 6,	distance = 400,	long_range_radar = 25000, short_range_radar = 5000, tractor = true,		mining = false,	probes = 6,		pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = true,	trigger_missile = nil,						balance_shield = false,	},
		["Porcupine"]			= { strength = 30,	cargo = 6,	distance = 400,	long_range_radar = 25000, short_range_radar = 5000, tractor = false,	mining = false,	probes = 10,	pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = true,	trigger_missile = nil,						balance_shield = false,	},
		["Proto-Atlantis"]		= { strength = 42,	cargo = 4,	distance = 400,	long_range_radar = 30000, short_range_radar = 4500, tractor = false,	mining = true,	probes = 8,		pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = false,	trigger_missile = nil,						balance_shield = false,	},
		["Proto-Atlantis 2"]	= { strength = 40,	cargo = 4,	distance = 400,	long_range_radar = 30000, short_range_radar = 4500, tractor = false,	mining = true,	probes = 8,		pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = false,	trigger_missile = nil,						balance_shield = false,	},
		["Raven"]				= { strength = 33,	cargo = 5,	distance = 400,	long_range_radar = 25000, short_range_radar = 6000, tractor = true,		mining = false,	probes = 7,		pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 1,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = true,	trigger_missile = nil,						balance_shield = false,	},
		["Redhook"]				= { strength = 14,	cargo = 8,	distance = 200,	long_range_radar = 20000, short_range_radar = 6000, tractor = false,	mining = false,	probes = 6,		pods = 2,	turbo_torp = false,	patrol_probe = 2.5,	prox_scan = 9,	epjam = 0,	power_sensor_interval = 5,	beam_damage_switch = false,	way_dist = false,	trigger_missile = {"E3","E4"},				balance_shield = false,	},
		["Roc"]					= { strength = 25,	cargo = 6,	distance = 200,	long_range_radar = 25000, short_range_radar = 5000, tractor = true,		mining = false,	probes = 6,		pods = 3,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 1,	epjam = 1,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = true,	trigger_missile = nil,						balance_shield = false,	},
		["Rodent"]				= { strength = 23,	cargo = 8,	distance = 200,	long_range_radar = 40000, short_range_radar = 5500, tractor = false,	mining = false,	probes = 9,		pods = 3,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 1,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = false,	trigger_missile = nil,						balance_shield = false,	},
		["Ronco"]				= { strength = 25,	cargo = 12,	distance = 200,	long_range_radar = 30000, short_range_radar = 5000, tractor = false,	mining = true,	probes = 9,		pods = 3,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = true,	way_dist = false,	trigger_missile = nil,						balance_shield = false,	},
		["Rook"]				= { strength = 15,	cargo = 12,	distance = 200,	long_range_radar = 41000, short_range_radar = 5500, tractor = false,	mining = true,	probes = 13,	pods = 3,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 1,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = false,	trigger_missile = nil,						balance_shield = false,	},
		["Rotor"]				= { strength = 35,	cargo = 5,	distance = 200,	long_range_radar = 25000, short_range_radar = 4000, tractor = true,		mining = false,	probes = 10,	pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = true,	trigger_missile = nil,						balance_shield = false,	},
		["Safari"]				= { strength = 15,	cargo = 10,	distance = 200,	long_range_radar = 33000, short_range_radar = 4500, tractor = true,		mining = false,	probes = 9,		pods = 3,	turbo_torp = false,	patrol_probe = 3.5,	prox_scan = 0,	epjam = 0,	power_sensor_interval = 5,	beam_damage_switch = false,	way_dist = false,	trigger_missile = nil,						balance_shield = false,	},
		["Scatter"]				= { strength = 30,	cargo = 6,	distance = 200,	long_range_radar = 28000, short_range_radar = 5000, tractor = false,	mining = true,	probes = 8,		pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = false,	trigger_missile = nil,						balance_shield = false,	},
		["Skray"]				= { strength = 15,	cargo = 3,	distance = 200, long_range_radar = 30000, short_range_radar = 7500, tractor = false,	mining = false,	probes = 25,	pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 3,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = false,	trigger_missile = nil,						balance_shield = false,	},
		["Sloop"]				= { strength = 20,	cargo = 8,	distance = 200,	long_range_radar = 35000, short_range_radar = 4500, tractor = true,		mining = true,	probes = 9,		pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 2,	epjam = 2,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = false,	trigger_missile = nil,						balance_shield = false,	},
		["Squid"]				= { strength = 15,	cargo = 8,	distance = 200,	long_range_radar = 25000, short_range_radar = 5000, tractor = false,	mining = false,	probes = 7,		pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 9,	epjam = 0,	power_sensor_interval = 8,	beam_damage_switch = false,	way_dist = true,	trigger_missile = {"N3","N4"},				balance_shield = false,	},
		["Striker LX"]			= { strength = 16,	cargo = 4,	distance = 200,	long_range_radar = 20000, short_range_radar = 4000, tractor = false,	mining = false,	probes = 7,		pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = false,	trigger_missile = nil,						balance_shield = false,	},
		["Surkov"]				= { strength = 35,	cargo = 6,	distance = 200,	long_range_radar = 35000, short_range_radar = 6000, tractor = false,	mining = false,	probes = 8,		pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 1,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = false,	trigger_missile = nil,						balance_shield = false,	},
		["Twister"]				= { strength = 32,	cargo = 6,	distance = 200,	long_range_radar = 23000, short_range_radar = 5500, tractor = false,	mining = true,	probes = 15,	pods = 2,	turbo_torp = false,	patrol_probe = 3,	prox_scan = 1,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = false,	trigger_missile = {"E3","E4","N3","N4"},	balance_shield = false,	},
		["Torch"]				= { strength = 9,	cargo = 3,	distance = 100,	long_range_radar = 15000, short_range_radar = 4000, tractor = false,	mining = false,	probes = 4,		pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = true,	trigger_missile = nil,						balance_shield = false,	},
		["Triumph"]				= { strength = 55,	cargo = 6,	distance = 400,	long_range_radar = 35000, short_range_radar = 5000, tractor = true,		mining = true,	probes = 10,	pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 1,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = false,	trigger_missile = nil,						balance_shield = false,	},
		["Vermin"]				= { strength = 13,	cargo = 3,	distance = 100,	long_range_radar = 22000, short_range_radar = 4000, tractor = false,	mining = true,	probes = 4,		pods = 1,	turbo_torp = false,	patrol_probe = 3.6,	prox_scan = 0,	epjam = 1,	power_sensor_interval = 10,	beam_damage_switch = false,	way_dist = true,	trigger_missile = nil,						balance_shield = false,	},
		["Windmill"]			= { strength = 24,	cargo = 11,	distance = 200,	long_range_radar = 33000, short_range_radar = 5000, tractor = false,	mining = true,	probes = 8,		pods = 4,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = false,	trigger_missile = nil,						balance_shield = false,	},
		["Wombat"]				= { strength = 18,	cargo = 3,	distance = 100,	long_range_radar = 18000, short_range_radar = 6000, tractor = false,	mining = false,	probes = 5,		pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 1,	epjam = 2,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = true,	trigger_missile = nil,						balance_shield = false,	},
		["Wrocket"]				= { strength = 19,	cargo = 8,	distance = 200,	long_range_radar = 32000, short_range_radar = 5500, tractor = false,	mining = false,	probes = 10,	pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 1,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = false,	trigger_missile = nil,						balance_shield = false,	},
		["XR-Lindworm"]			= { strength = 13,	cargo = 3,	distance = 100,	long_range_radar = 20000, short_range_radar = 6000, tractor = false,	mining = false,	probes = 5,		pods = 1,	turbo_torp = false,	patrol_probe = 3.9,	prox_scan = 9,	epjam = 0,	power_sensor_interval = 7.5,beam_damage_switch = false,	way_dist = true,	trigger_missile = nil,						balance_shield = false,	},

		-- not sure the strenghts of Ktlitan Breaker and Ktlitan Feeder... they seem too high
		["Ktlitan Breaker"]		= { strength = 15,	cargo = 2,	distance = 100,	long_range_radar = 10000, short_range_radar = 5000, tractor = false,	mining = false,	probes = 0,		pods = 0,	turbo_torp = false,	patrol_probe = 3.9,	prox_scan = 1,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = true,	trigger_missile = nil,						balance_shield = false,	},
		["Ktlitan Feeder"]		= { strength = 18,	cargo = 2,	distance = 100,	long_range_radar = 10000, short_range_radar = 5000, tractor = false,	mining = false,	probes = 0,		pods = 0,	turbo_torp = false,	patrol_probe = 3.9,	prox_scan = 1,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = true,	trigger_missile = nil,						balance_shield = false,	},
		
		-- TODO: decide on values here as well.
		-- Not sure why Queen entry has to be here...
		["Ktlitan Queen"]		= { strength = 28,	cargo = 2,	distance = 100,	long_range_radar = 10000, short_range_radar = 5000, tractor = false,	mining = false,	probes = 0,		pods = 0,	turbo_torp = false,	patrol_probe = 3.9,	prox_scan = 1,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = true,	trigger_missile = nil,						balance_shield = false,	},
		["Ktlitan Brood Mother"]= { strength = 28,	cargo = 2,	distance = 100,	long_range_radar = 10000, short_range_radar = 5000, tractor = false,	mining = false,	probes = 0,		pods = 0,	turbo_torp = false,	patrol_probe = 3.9,	prox_scan = 1,	epjam = 0,	power_sensor_interval = 0,	beam_damage_switch = false,	way_dist = true,	trigger_missile = nil,						balance_shield = false,	},
	}	
	-- this table has ended up not in alphabetical order
	-- likewise the creation functions are no longer in alphabetical order
	-- this probably wants to be fixed after the upcomming merge conflict has been dealt with
	playerShipInfo = {}
	addPlayerShip("Ambition",	"Phobos T2",	createPlayerShipAmbition	,"J")
	addPlayerShip("Anvil",		"Deimos",		createPlayerShipAnvil		,"W")
	addPlayerShip("Argonaut",	"Nusret",		createPlayerShipArgonaut	,"J")
	addPlayerShip("Arwine",		"Pacu",			createPlayerShipArwine		,"J")
	addPlayerShip("Barracuda",	"Redhook",		createPlayerShipBarracuda	,"J")
	addPlayerShip("Beowulf",	"Nusret",		createPlayerShipHrothgar	,"J")
	addPlayerShip("Blaire",		"Kludge",		createPlayerShipBlaire		,"B")
--	addPlayerShip("Blazon"		,createPlayerShipBlazon
	addPlayerShip("Bling",		"Gadfly",		createPlayerShipBling		,"J")
	addPlayerShip("Claw",		"Raven",		createPlayerShipClaw		,"W")
	addPlayerShip("Cobra",		"Striker LX",	createPlayerShipCobra		,"J")
	addPlayerShip("Crux",		"Mantis",		createPlayerShipCrux		,"W")
	addPlayerShip("Darkstar",	"Destroyer IV",	createPlayerShipDarkstar	,"J")
	addPlayerShip("Devon",		"Wombat",		createPlayerShipDevon		,"W")
	addPlayerShip("Dial",		"Ronco",		createPlayerShipDial		,"W")
	addPlayerShip("Dominant",	"Triumph",		createPlayerShipDominant	,"J")
	addPlayerShip("Eagle",		"Era",			createPlayerShipEagle		,"W")
	addPlayerShip("Endeavor",	"Bermuda",		createPlayerShipEndeavor	,"J")
	addPlayerShip("Enola",		"Fray",			createPlayerShipEnola		,"J")
--	addPlayerShip("Espadon",	"Orca",			createPlayerShipEspadon		,"W")
	addPlayerShip("Falcon",		"Eldridge",		createPlayerShipFalcon		,"W")
	addPlayerShip("Farrah",		"Wombat",		createPlayerShipDevon		,"W")	--set ship name in routine
	addPlayerShip("Fist",		"Interlock",	createPlayerShipFist		,"J")
	addPlayerShip("Flaire",		"Peacock",		createPlayerShipFlaire		,"J")
	addPlayerShip("Flipper",	"Midian",		createPlayerShipFlipper		,"W")
	addPlayerShip("Florentine",	"Safari",		createPlayerShipFlorentine	,"W")
	addPlayerShip("Gabble",		"Squid",		createPlayerShipGabble		,"J")
	addPlayerShip("George",		"Rodent",		createPlayerShipGeorge		,"J")
	addPlayerShip("Gorn",		"Proto-Atlantis",createPlayerShipGorn		,"J")
	addPlayerShip("Grad",		"Mortar",		createPlayerShipMortar		,"W")
	addPlayerShip("Guinevere",	"Caretaker",	createPlayerShipGuinevere	,"J")
	addPlayerShip("Halberd",	"Proto-Atlantis",createPlayerShipHalberd	,"J")	--proto-atlantis
	addPlayerShip("Headhunter",	"Redhook",		createPlayerShipHeadhunter	,"J")
	addPlayerShip("Hearken",	"Redhook",		createPlayerShipHearken		,"J")
	addPlayerShip("Hrothgar",	"Nusret",		createPlayerShipHrothgar	,"J")
	addPlayerShip("Hummer",		"XR-Lindworm",	createPlayerShipHummer		,"W")
	addPlayerShip("Ignite",		"Torch",		createPlayerShipTorch		,"W")
	addPlayerShip("Ink",		"Squid",		createPlayerShipInk			,"J")
	addPlayerShip("Jarvis",		"Butler",		createPlayerShipJarvis		,"W")
	addPlayerShip("Jeeves",		"Butler",		createPlayerShipJeeves		,"W")
	addPlayerShip("Kindling",	"Phoenix",		createPlayerShipKindling	,"J")
--	addPlayerShip("Knick",		"Glass Cannon",	createPlayerShipKnick		,"J"},"Experimental - not ready for use"
	addPlayerShip("Knuckle Drag","Destroyer III",createPlayerShipSimian		,"J")
	addPlayerShip("Lancelot",	"Noble",		createPlayerShipLancelot	,"J")
	addPlayerShip("Levant",		"Sloop",		createPlayerShipSloop		,"J")
	addPlayerShip("Magnum",		"Focus",		createPlayerShipMagnum		,"J")
	addPlayerShip("Manxman",	"Nusret",		createPlayerShipManxman		,"J")
	addPlayerShip("Mixer",		"Amalgam",		createPlayerShipMixer		,"J")
	addPlayerShip("Narsil",		"Proto-Atlantis",createPlayerShipNarsil		,"W")
	addPlayerShip("Nimbus",		"Phobos T2.2",	createPlayerShipNimbus		,"J")
	addPlayerShip("Osprey",		"Flavia 2C",	createPlayerShipOsprey		,"W")
	addPlayerShip("Outcast",	"Scatter",		createPlayerShipOutcast		,"J")
	addPlayerShip("Pinwheel",	"Rotor"	,		createPlayerShipPinwheel	,"W")
	addPlayerShip("Quarter",	"Barrow",		createPlayerShipQuarter		,"J")
	addPlayerShip("Quicksilver","XR-Lindworm",	createPlayerShipQuick		,"W")
	addPlayerShip("Quill",		"Porcupine",	createPlayerShipQuill		,"W")
	addPlayerShip("Raptor",		"Destroyer IV",	createPlayerShipRaptor		,"J")
	addPlayerShip("Rattler",	"MX-Lindworm",	createPlayerShipRattler		,"J")
	addPlayerShip("Rip",		"Lurker",		createPlayerShipRip			,"W")
	addPlayerShip("Rocinante",	"Windmill",		createPlayerShipRocinante	,"W")
	addPlayerShip("Rogue",		"Maverick XP",	createPlayerShipRogue		,"J")
	addPlayerShip("Skray",		"Skray",		createplayerShipSneak		,"J")
	addPlayerShip("Sparrow",	"Vermin",		createPlayerShipSparrow		,"W")
	addPlayerShip("Shannon",	"Wombat",		createPlayerShipDevon		,"W")	--set ship name in routine
	addPlayerShip("Slingshot",	"Wrocket",		createPlayerShipSlingshot	,"J")
	addPlayerShip("Splinter",	"Fresnel",		createPlayerShipSplinter	,"J")
	addPlayerShip("Spike",		"Surkov",		createPlayerShipStick		,"W")
	addPlayerShip("Spyder",		"Atlantis II",	createPlayerShipSpyder		,"J")
	addPlayerShip("Stick",		"Surkov",		createPlayerShipStick		,"W")
	addPlayerShip("Sting",		"Surkov",		createPlayerShipSting		,"W")
	addPlayerShip("Swoop",		"Roc",			createPlayerShipRoc			,"W")
	addPlayerShip("Szpieg",		"Ktlitan Breaker",	createPlayerShipSzpieg	,"W")
	addPlayerShip("Sztylet",	"Ktlitan Feeder",	createPlayerShipSztylet	,"W")
	addPlayerShip("Katarzyna",	"Ktlitan Brood Mother",	createPlayerShipKatarzyna	,"W")
	addPlayerShip("Tango",		"Twister",		createPlayerShipTango		,"W")
	addPlayerShip("Terror",		"Phobos T2.2",	createPlayerShipTerror		,"J")
	addPlayerShip("Thelonius",	"Crab",			createPlayerShipThelonius	,"W")
	addPlayerShip("Thunderbird","Destroyer IV",	createPlayerShipThunderbird	,"J")
	addPlayerShip("Vision",		"Era",			createPlayerShipVision		,"W")
	addPlayerShip("Watson",		"Holmes",		createPlayerShipWatson		,"W")
	addPlayerShip("Wesson",		"Chavez",		createPlayerShipWesson		,"J")
	addPlayerShip("Wiggy",		"Gull",			createPlayerShipWiggy		,"J")
	addPlayerShip("Yorik",		"Rook",			createPlayerShipYorik		,"J")
	makePlayerShipActive("Headhunter")		--J
	makePlayerShipActive("Rogue")			--J
	makePlayerShipActive("Gabble") 			--J 
	makePlayerShipActive("Narsil")			--W
	makePlayerShipActive("Jeeves")			--W
	makePlayerShipActive("Anvil") 			--W 
	stock_combat_maneuver = {
		["Atlantis"] =			{boost = 400, strafe = 250},
		["Benedict"] =			{boost = 400, strafe = 250},
		["Crucible"] =			{boost = 400, strafe = 250},
		["Ender"] =				{boost = 800, strafe = 500},
		["Flavia P.Falcon"] =	{boost = 250, strafe = 150},
		["Hathcock"] =			{boost = 200, strafe = 150},
		["Kiriya"] =			{boost = 400, strafe = 250},
		["Maverick"] =			{boost = 400, strafe = 250},
		["MP52 Hornet"] =		{boost = 600, strafe = 0},
		["Nautilus"] =			{boost = 250, strafe = 150},
		["Phobos M3P"] =		{boost = 400, strafe = 250},
		["Piranha"] =			{boost = 200, strafe = 150},
		["Player Cruiser"] =	{boost = 400, strafe = 250},
		["Player Missile Cr."] ={boost = 450, strafe = 150},
		["Player Fighter"] =	{boost = 600, strafe = 0},
		["Repulse"] =			{boost = 250, strafe = 150},
		["Striker"] =			{boost = 250, strafe = 150},
		["ZX-Lindworm"] =		{boost = 250, strafe = 150},
	}
	stock_tube_ordnance = {
		["Atlantis"] =			{"all but Mine","all but Mine","all but Mine","all but Mine","Mine"},
		["Benedict"] =			{},
		["Crucible"] =			{"HVLI","HVLI","HVLI","all but Mine","all but Mine","Mine"},
		["Ender"] =				{"Homing","Mine"},
		["Flavia P.Falcon"] =	{"all but EMP"},
		["Hathcock"] =			{"all but Mine","all but Mine"},
		["Kiriya"] =			{},
		["Maverick"] =			{"all but Mine","all but Mine","Mine"},
		["MP52 Hornet"] =		{},
		["Nautilus"] =			{"Mine","Mine","Mine"},
		["Phobos M3P"] =		{"all but Mine","all but Mine","Mine"},
		["Piranha"] =			{"Homing, HVLI","all","Homing, HVLI","Homing, HVLI","all","Homing, HVLI","Mine","Mine"},
		["Player Cruiser"] =	{"all but Mine","all but Mine","Mine"},
		["Player Missile Cr."] ={"all but Mine","all but Mine","Homing","Homing","Homing","Homing","Mine"},
		["Player Fighter"] =	{"HVLI"},
		["Repulse"] =			{"Homing, HVLI","Homing, HVLI"},
		["Striker"] =			{},
		["ZX-Lindworm"] =		{"Homing, HVLI","HVLI","HVLI"},
	}
	stock_tube_direction = {
		["Atlantis"] =			{-90,-90,90,90,180},
		["Benedict"] =			{},
		["Crucible"] =			{0,0,0,-90,90,180},
		["Ender"] =				{0,180},
		["Flavia P.Falcon"] =	{180},
		["Hathcock"] =			{-90,90},
		["Kiriya"] =			{},
		["Maverick"] =			{-90,90,180},
		["MP52 Hornet"] =		{},
		["Nautilus"] =			{180,180,180},
		["Phobos M3P"] =		{-1,1,180},
		["Piranha"] =			{-90,-90,-90,90,90,90,170,190},
		["Player Cruiser"] =	{-5,5,180},
		["Player Missile Cr."] ={0,0,90,90,-90,-90,180},
		["Player Fighter"] =	{0},
		["Repulse"] =			{0,180},
		["Striker"] =			{},
		["ZX-Lindworm"] =		{0,1,-1},
	}
	stock_beam_damage_type = {
		["Atlantis"] =			{"energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy"},
		["Benedict"] =			{"energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy"},
		["Crucible"] =			{"energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy"},
		["Ender"] =				{"energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy"},
		["Flavia P.Falcon"] =	{"energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy"},
		["Hathcock"] =			{"energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy"},
		["Kiriya"] =			{"energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy"},
		["Maverick"] =			{"energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy"},
		["MP52 Hornet"] =		{"energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy"},
		["Nautilus"] =			{"energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy"},
		["Phobos M3P"] =		{"energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy"},
		["Piranha"] =			{"energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy"},
		["Player Cruiser"] =	{"energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy"},
		["Player Missile Cr."] ={"energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy"},
		["Player Fighter"] =	{"energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy"},
		["Repulse"] =			{"energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy"},
		["Striker"] =			{"energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy"},
		["ZX-Lindworm"] =		{"energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy","energy"},
	}
	carrier_class_launch_time = {
		["Starfighter"] = 5,
		["Frigate"] = 10,
		["Corvette"] = 15,
		["Dreadnought"] = 20,
	}
	carrier_ship_types = {
		["Atlantis"] =				{carry = false,	class = "Corvette",		create = stockPlayer,	},
		["Benedict"] =				{carry = false,	class = "Corvette",		create = stockPlayer,	},
		["Crucible"] =				{carry = false,	class = "Corvette",		create = stockPlayer,	},
		["Ender"] =					{carry = false,	class = "Dreadnought",	create = stockPlayer,	},
		["Flavia P.Falcon"] =		{carry = false,	class = "Frigate",		create = stockPlayer,	},
		["Hathcock"] =				{carry = false,	class = "Frigate",		create = stockPlayer,	},
		["Kiriya"] =				{carry = false,	class = "Corvette",		create = stockPlayer,	},
		["Maverick"] =				{carry = false,	class = "Corvette",		create = stockPlayer,	},
		["MP52 Hornet"] = 			{carry = false,	class = "Starfighter",	create = stockPlayer,	},
		["Nautilus"] =				{carry = false,	class = "Frigate",		create = stockPlayer,	},
		["Phobos M3P"] =			{carry = false,	class = "Frigate",		create = stockPlayer,	},
		["Piranha"] =				{carry = false,	class = "Frigate",		create = stockPlayer,	},
		["Player Cruiser"] =		{carry = false,	class = "Corvette",		create = stockPlayer,	},
		["Player Missile Cr."] =	{carry = false,	class = "Corvette",		create = stockPlayer,	},
		["Player Fighter"] =		{carry = false,	class = "Starfighter",	create = stockPlayer,	},
		["Repulse"] =				{carry = false,	class = "Frigate",		create = stockPlayer,	},
		["Striker"] =				{carry = false,	class = "Starfighter",	create = stockPlayer,	},
		["ZX-Lindworm"] =			{carry = false,	class = "Starfighter",	create = stockPlayer,	},
		["Amalgam"] =				{carry = false,	class = "Corvette",		create = createPlayerShipMixer,	},
		["Atlantis II"] =			{carry = false,	class = "Corvette",		create = createPlayerShipSpyder,	},
		["Barrow"] =				{carry = false,	class = "Corvette",		create = createPlayerShipQuarter,	},
		["Bermuda"] =				{carry = false,	class = "Corvette",		create = createPlayerShipEndeavor,	},
		["Butler"] =				{carry = false,	class = "Corvette",		create = createPlayerShipJeeves,	},	--or Jarvis
		["Caretaker"] =				{carry = false,	class = "Corvette",		create = createPlayerShipGuinevere,	},
		["Chavez"] =				{carry = false,	class = "Frigate",		create = createPlayerShipWesson,	},
		["Crab"] =					{carry = false,	class = "Corvette",		create = createPlayerShipThelonius,	},
		["Deimos"] =				{carry = false,	class = "Frigate",		create = createPlayerShipAnvil,	},
		["Destroyer III"] =			{carry = false,	class = "Corvette",		create = createPlayerShipSimian,	},
		["Destroyer IV"] =			{carry = false,	class = "Corvette",		create = createPlayerShipDarkstar,	},	--or Raptor or Thunderbird
		["Eldridge"] =				{carry = false,	class = "Frigate",		create = createPlayerShipFalcon,	},
		["Era"] =					{carry = false,	class = "Frigate",		create = createPlayerShipEagle,	},		--or Vision
		["Flavia 2C"] =				{carry = false,	class = "Frigate",		create = createPlayerShipOsprey,	},
		["Focus"] =					{carry = false,	class = "Corvette",		create = createPlayerShipMagnum,	},
		["Fowl"] =					{carry = false,	class = "Starfighter",	create = createPlayerShipFowl,	},
		["Fray"] =					{carry = false,	class = "Corvette",		create = createPlayerShipEnola,	},
		["Fresnel"] =				{carry = false,	class = "Starfighter",	create = createPlayerShipSplinter,	},
		["Gadfly"] =				{carry = false,	class = "Starfighter",	create = createPlayerShipBling,	},
		["Glass Cannon"] =			{carry = false,	class = "Starfighter",	create = createPlayerShipKnick,	},
		["Gull"] =					{carry = false,	class = "Frigate",		create = createPlayerShipWiggy,	},
		["Holmes"] =				{carry = false,	class = "Corvette",		create = createPlayerShipWatson,	},
		["Interlock"] =				{carry = false,	class = "Frigate",		create = createPlayerShipFist,	},
		["Kludge"] =				{carry = false,	class = "Corvette",		create = createPlayerShipBlaire,	},
		["Lurker"] =				{carry = false,	class = "Starfighter",	create = createPlayerShipRip,	},
		["Mantis"] =				{carry = false,	class = "Corvette",		create = createPlayerShipCrux,	},
		["Maverick XP"] =			{carry = false,	class = "Corvette",		create = createPlayerShipRogue,	},
		["Midian"] =				{carry = false,	class = "Corvette",		create = createPlayerShipFlipper,	},
		["Mortar"] =				{carry = false,	class = "Corvette",		create = createPlayerShipMortar,	},
		["MX-Lindworm"] =			{carry = false,	class = "Starfighter",	create = createPlayerShipRattler,	},
		["Noble"] =					{carry = false,	class = "Corvette",		create = createPlayerShipLancelot,	},
		["Nusret"] =				{carry = false,	class = "Frigate",		create = createPlayerShipManxman,	},	--or Argonaut or Hrothgar
		["Orca"] =					{carry = false,	class = "Frigate",		create = createPlayerShipEspadon,	},
		["Pacu"] =					{carry = false,	class = "Frigate",		create = createPlayerShipArwine,	},
		["Peacock"] =				{carry = false,	class = "Corvette",		create = createPlayerShipFlaire,	},
		["Phargus"] =				{carry = false,	class = "Frigate",		create = createPlayerShipPhargus,	},
		["Phobos T2"] =				{carry = false,	class = "Frigate",		create = createPlayerShipAmbition,	},
		["Phobos T2.2"] =			{carry = false,	class = "Frigate",		create = createPlayerShipNimbus,	},	--or Terror
		["Phoenix"] =				{carry = false,	class = "Corvette",		create = createPlayerShipKindling,	},
		["Porcupine"] =				{carry = false,	class = "Frigate",		create = createPlayerShipQuill,	},
		["Proto-Atlantis"] =		{carry = false,	class = "Corvette",		create = createPlayerShipHalberd,	},	--or Gorn
		["Proto-Atlantis 2"] =		{carry = false,	class = "Corvette",		create = createPlayerShipNarsil,	},
		["Raven"] =					{carry = false,	class = "Corvette",		create = createPlayerShipClaw,	},
		["Redhook"] =				{carry = false,	class = "Frigate",		create = createPlayerShipHeadhunter,	},	--or Barracuda or Hearken
		["Roc"] =					{carry = false,	class = "Frigate",		create = createPlayerShipRoc,	},
		["Rodent"] =				{carry = false,	class = "Frigate",		create = createPlayerShipGeorge,	},
		["Ronco"] =					{carry = false,	class = "Frigate",		create = createPlayerShipDial,	},
		["Rook"] =					{carry = false,	class = "Frigate",		create = createPlayerShipYorik,	},
		["Rotor"] =					{carry = false,	class = "Corvette",		create = createPlayerShipPinwheel,	},
		["Safari"] =				{carry = false,	class = "Frigate",		create = createPlayerShipFlorentine,	},
		["Scatter"] =				{carry = false,	class = "Frigate",		create = createPlayerShipOutcast,	},
		["Skray"] =					{carry = false,	class = "Frigate",		create = createplayerShipSneak,	},
		["Sloop"] =					{carry = false,	class = "Frigate",		create = createPlayerShipSloop,	},
		["Squid"] =					{carry = false,	class = "Frigate",		create = createPlayerShipInk,	},	--or Gabble
		["Striker LX"] =			{carry = false,	class = "Starfighter",	create = createPlayerShipCobra,	},
		["Surkov"] =				{carry = false,	class = "Frigate",		create = createPlayerShipSting,	},	--or Stick or Spike
		["Twister"] =				{carry = false,	class = "Frigate",		create = createPlayerShipTango,	},
		["Torch"] =					{carry = false,	class = "Starfighter",	create = createPlayerShipTorch,	},
		["Triumph"] =				{carry = false,	class = "Corvette",		create = createPlayerShipDominant,	},
		["Vermin"] =				{carry = false,	class = "Starfighter",	create = createPlayerShipSparrow,	},
		["Windmill"] =				{carry = false,	class = "Frigate",		create = createPlayerShipRocinante,	},
		["Wombat"] =				{carry = false,	class = "Starfighter",	create = createPlayerShipDevon,	},
		["Wrocket"] =				{carry = false,	class = "Frigate",		create = createPlayerShipSlingshot,	},
		["XR-Lindworm"] =			{carry = false,	class = "Starfighter",	create = createPlayerShipQuick,	},	--or Hummer	
	}
	carrier_ship_names = {
		["Atlantis"] =				{"Golga","Gorgon","Outsize"},
		["Benedict"] =				{"Circular","Mobius","Nepotist"},
		["Crucible"] =				{"Cannon","Artillery","Catapult"},
		["Ender"] =					{"Galactic","Waamba","Gargantua"},
		["Flavia P.Falcon"] =		{"Heron","Boxer","Independence"},
		["Hathcock"] =				{"Prickly","Catcus","Needle Nose"},
		["Kiriya"] =				{"Dissociate","Avuncular","Mirror"},
		["Maverick"] =				{"Herald","Distilled","Surprise"},
		["MP52 Hornet"] = 			{"Carpenter","Stinger","Nitro"},
		["Nautilus"] =				{"Wherewithal","Puppeteer","Pidgeon"},
		["Phobos M3P"] =			{"Elastic","Entropy","Inchoate"},
		["Piranha"] =				{"Nibbler","Tubular","Rabid"},
		["Player Cruiser"] =		{"Starburst","Nova","Escape"},
		["Player Missile Cr."] =	{"Gatling","Endurance","Wary"},
		["Player Fighter"] =		{"Pin","Torque","Flip"},
		["Repulse"] =				{"Muscle","Spinner","Chopper"},
		["Striker"] =				{"Rough","Shard","Angle"},
		["ZX-Lindworm"] =			{"Pony","Trickster","Bang"},
		["Amalgam"] =				{"Everyman","Politico","Comforter"},
		["Atlantis II"] =			{"Borgo","Ego","Kraken"},
		["Barrow"] =				{"Doppleganger","Twin","Clone"},
		["Bermuda"] =				{"Persistent","Insistent","Tyrant"},
		["Butler"] =				{"Merciless","Inperturbable","Aloof"},
		["Caretaker"] =				{"Confidence","Inquisitorial","Response"},
		["Chavez"] =				{"Chameleon","Blend","Camoflage"},
		["Crab"] =					{"Pincer","Dodge","Salty"},
		["Deimos"] =				{"Gander","Trip","Gondala"},
		["Destroyer III"] =			{"Portent","Strand","Isometric"},
		["Destroyer IV"] =			{"Bent","Inpenetrable","Impervious"},
		["Eldridge"] =				{"Fortune","Sprightly","Constable"},
		["Era"] =					{"Mindful","Peer","Star Flow"},
		["Flavia 2C"] =				{"Trickle","Retuned","Insatiable"},
		["Focus"] =					{"Growth","Scalar","Justice"},
		["Fowl"] =					{"Robin","Penguin","Harrier"},
		["Fray"] =					{"Harry","Skunk","Cappuccino"},
		["Fresnel"] =				{"Magnified","Starlight","Techno"},
		["Gadfly"] =				{"Zippy","Mosquito","Dart"},
		["Glass Cannon"] =			{"Once","Mastadon","Sabretooth"},
		["Gull"] =					{"Wingspan","Discover","Recon"},
		["Holmes"] =				{"Yardstick","Deer Hat","Induction"},
		["Interlock"] =				{"Traverse","Jasper","Intransigent"},
		["Kludge"] =				{"Bullwinkle","Clouseau","Quasimodo"},
		["Lurker"] =				{"Spark","Twinge","Scratch"},
		["Mantis"] =				{"Ray","Nemo","Skelter"},
		["Maverick XP"] =			{"Condensed","Impact","Compound"},
		["Midian"] =				{"Ethereal","Torn","Zapper"},
		["Mortar"] =				{"Galadriel","Belinda","Slippery"},
		["MX-Lindworm"] =			{"Tickler","Lickety","Vex"},
		["Noble"] =					{"Word","Stature","Knight"},
		["Nusret"] =				{"Trembler","Bright","Terse"},
		["Orca"] =					{"Pursuer","Gnarly","Unblemished"},
		["Pacu"] =					{"Energetic","Ardent","Frugal"},
		["Peacock"] =				{"Kaleidoscopic","Redolent","Extravagant"},
		["Phargus"] =				{"Defender","Dramatic","Intent"},
		["Phobos T2"] =				{"Thorough","Portentious","Precocious"},
		["Phobos T2.2"] =			{"Flagon","Thirsty","Trust"},
		["Phoenix"] =				{"Firebrand","Resilient","Chaste"},
		["Porcupine"] =				{"Bias","Mercenary","Frightful"},
		["Proto-Atlantis"] =		{"Temporal","Literal","Spruce"},
		["Proto-Atlantis 2"] =		{"Gertrude","Mildred","Jax"},
		["Raven"] =					{"Nevermore","Blackened","Reflective"},
		["Redhook"] =				{"Gatherer","Trifecta","Blender"},
		["Roc"] =					{"Bulk","Roast","Grimwald"},
		["Rodent"] =				{"Chirp","Muskrat","Ferret"},
		["Ronco"] =					{"Slicer","Dicer","Grinder"},
		["Rook"] =					{"Moors","Estuary","Fractal"},
		["Rotor"] =					{"Prismatic","Hirsute","Fate"},
		["Safari"] =				{"Scavenger","Guide","Traveler"},
		["Scatter"] =				{"Frisky","Fraught","Nimble"},
		["Skray"] =					{"Clipper","Symbolic","Provoker"},
		["Sloop"] =					{"Effervescent","Artisan","Vaulted"},
		["Squid"] =					{"Insidious","Trampler","Livid"},
		["Striker LX"] =			{"Bluejay","Fencer","Basilisk"},
		["Surkov"] =				{"Inveterate","Vertiginous","Advent"},
		["Twister"] =				{"Bowl","Force","Leverage"},
		["Torch"] =					{"Simmer","Boil","Blinder"},
		["Triumph"] =				{"Veil","Crown","Dreadful"},
		["Vermin"] =				{"Plague","Spreader","Gray Death"},
		["Windmill"] =				{"Cervantes","Willful","Indomitable"},
		["Wombat"] =				{"Aggravator","Fiendish","Fearless"},
		["Wrocket"] =				{"Revisitor","Retrograde","Cycler"},
		["XR-Lindworm"] =			{"Pointed","Poniard","Rapier"},
	}
end
----------------------------------------------------
--	Support the creation of various player ships  --
----------------------------------------------------
--	Models with specific weapons emplacements: 
--		Atlantis			battleship_destroyer_1_upgraded
--			4 beams (negative, positive, negative, positive)
--			2 tubes (negative then positive)
--		Phobos				AtlasHeavyFighter
--			2 beams (positive then negative)
--			3 tubes (positive then negative then rear for mine)
--		Hornet				WespeScout
--			2 beams (positive then negative)
--		Player Cruiser		battleship_destroyer_5_upgraded	
--			2 beams (negative then positive)
--			2 tubes (centered, but -Z values)
--		Player Misslie Cr.	space_cruiser_4
--			2 tubes (negative then positive)
--		Player Fighter		small_fighter_1
--			1 beam (centered, but negative z)
--		Striker				dark_fighter_6
--			2 beams (negative then positive)
--		ZX-Lindworm			LindwurmFighter
--			3 tubes (center, positive, negative)
--		(none)				space_frigate_6
--			2 beams (negative then positive)
--			2 tubes (centered but negative z)
--		(none) Corsair DX	battleship_destroyer_2_upgraded
--			6 beams (neg, pos, neg, pos, neg, pos)
--		Blockade Runner		battleship_destroyer_3_upgraded
--			4 beams (pos, neg, pos, neg)
--		Starhammer			battleship_destroyer_4_upgraded
--			2 beams (neg, pos)
--			2 tubes (neg, pos)
--		Battlestation		Ender Battlecruiser
--			12 beams (2neg, 2pos, 2neg, 2pos, 2neg, 2pos)	
--		Adder				AdlerLongRangeScout
--			3 beams (centered, pos, neg
--			1 tube (centered, positive z)
function addShipReference(ship)
	ship:addCustomButton("Helms","open ship reference helm","Open Ship Ref",function()
		string.format("")
		openShipReference(ship,"Helms")
	end,500)
	ship:addCustomButton("Weapons","open ship reference weapons","Open Ship Ref",function()
		string.format("")
		openShipReference(ship,"Weapons")
	end,500)
	ship:addCustomButton("Engineering","open ship reference engineering","Open Ship Ref",function()
		string.format("")
		openShipReference(ship,"Engineering")
	end,500)
	ship:addCustomButton("Science","open ship reference science","Open Ship Ref",function()
		string.format("")
		openShipReference(ship,"Science")
	end,500)
	ship:addCustomButton("Relay","open ship reference relay","Open Ship Ref",function()
		string.format("")
		openShipReference(ship,"Relay")
	end,500)
	ship:addCustomButton("Tactical","open ship reference tactical","Open Ship Ref",function()
		string.format("")
		openShipReference(ship,"Tactical")
	end,500)
	ship:addCustomButton("Operations","open ship reference operations","Open Ship Ref",function()
		string.format("")
		openShipReference(ship,"Operations")
	end,500)
	ship:addCustomButton("Engineering+","open ship reference engineering+","Open Ship Ref",function()
		string.format("")
		openShipReference(ship,"Engineering+")
	end,500)
end
function openShipReference(ship,console)
	string.format("")
	local open_references = {
		["Helms"] = "open ship reference helm",
		["Weapons"] = "open ship reference weapons",
		["Engineering"] = "open ship reference engineering",
		["Science"] = "open ship reference science",
		["Relay"] = "open ship reference relay",
		["Tactical"] = "open ship reference tactical",
		["Operations"] = "open ship reference operations",
		["Engineering+"] = "open ship reference engineering+",
	}
	ship:removeCustom(open_references[console])
	local ship_references = {
		["Helms"] = {"Misc","Diff Sum","Engines","Tractor","Mining","Turbo Torp","Proximity Scan","Waypoint Calc"},
		["Weapons"] = {"Misc","Diff Sum","Defense","Beams","Tubes","Mining","Turbo Torp","EPJAM","Trigger Missile"},
		["Engineering"] = {"Misc","Diff Sum","Engines","Beams","Tubes","Tractor","Mining","Powered Sensors"},
		["Science"] = {"Misc","Diff Sum","Mining","Patrol Probe","Proximity Scan","Powered Sensors"},
		["Relay"] = {"Misc","Diff Sum","Engines","Patrol Probe","Waypoint Calc"},
		["Tactical"] = {"Misc","Diff Sum","Engines","Defense","Beams","Tubes","Tractor","Mining","Turbo Torp","Proximity Scan","EPJAM","Waypoint Calc","Trigger Missile"},
		["Operations"] = {"Misc","Diff Sum","Engines","Mining","Proximity Scan","Powered Sensors","Waypoint Calc"},
		["Engineering+"] = {"Misc","Diff Sum","Engines","Beams","Tubes","Tractor","Mining","Powered Sensors"},
	}
	local generic_reference_messages = {
		["Tractor"] = "Your ship has a tractor beam. The control buttons appear on the Engineering console. The object to be tractored must be within one unit of your ship. Your ship must be traveling slower than 1 unit per minute. Use the 'Lock on Tractor' button to enable the tractor beam. Use the button that starts with 'Target' to get distance and bearing on the current tractor beam target. Use the 'Other tractor target' button to change to another valid tractor beam target if more than one are available. Use the 'Disengage Tractor' button to turn off the tractor beam once it is on. The tractor beam will disengage if the ship speed exceeds 1 unit per minute. The engineer should monitor energy usage while the tractor beam is engaged.",
		["Mining"] = "Your ship can mine asteroids for minerals. The Weapons or Tactical officer should click the 'Start Mining' button to activate the mining beam. Before the beam can be activated, the Science or Operations officer needs to click the 'Lock for Mining' button for an asteroid within 1U of your ship. Science or Operations should click the 'Target Asteroid' button to get distance, bearing and mineral trace information on the mining target asteroid. Click the 'Other mining target' button to change to a different asteroid that may also be within 1U of your ship. Science or Operations may have to click the 'Scanning' widget to see other buttons. Engineering should monitor the beam system during mining.",
		["Turbo Torp"] = "Your ship can increase the speed of torpedoes of type %s. The Weapons or Tactical officer should click the 'Turbo Torpedo' button to have the next torpedo launched get a speed boost. It takes %s seconds to recharge the turbo torp system.\n\nTurning speed is not increased, so it works better the straighter the missile can fly towards the target.",
		["Patrol Probe"] = "Some of the probes on your ship can be programmed to patrol instead of stopping at their destination. The Relay officer should click the 'Patrol Probe Off' button to activate the patrol probe system. The next probe launched will be a patrol probe when the patrol probe system is active. Click the 'Patrol Probe On' button to deactivate the patrol probe system. The patrol probe system will automatically deactivate one you have %s patrol probes active. A patrol probe orbits your ship in a hexagonal pattern at the distance specified when setting the probe destination point. It will continue to orbit until it runs out of energy or is destroyed. A patrol probe cannot be linked to Science.",
		["Proximity Scan"] = "Your ship has automated sensors that will conduct a simple scan on ships within %sU",
		["EPJAM"] = "Your ship can generate an EMP blast of radius %sU. The Weapons or Tactical officer should click the 'Trigger %s EPJAM' button to trigger the blast. Be aware that this action takes down the shields and puts them in a calibration mode, so be careful when you use it. Why would you ever want to do this? If a nuke or other missile is getting too close, within the blast radius, they will get destroyed before hitting your ship, just like a normal EMP missile blast.",
		["Powered Sensors"] = "Your ship long range sensors, used by Science and Operations, can reach further with the application of ship's battery power. Engineering should click the 'Boost Sensors' button to change from a disabled powered sensor boost state to a configure state. To enable the powered sensor boost, Engineering should click one of the three powered sensor level buttons 'Sensor Boost X' where X is 1, 2, or 3. Higher = greater range and greater power drain. Engineering should click 'Stop Sensor Boost' to switch from an enabled powered sensor boost state to a disabled state. The powered sensor boost will be disabled at low battery energy. Engineering should monitor power levels while boosted sensors are enabled.",
		["Waypoint Calc"] = "Your ship has a waypoint distance calculator. This device calculates the distance from the ship to each waypoint that has been placed by the Relay officer. It also calculates the distance from each waypoint in sequence. The Helm or Tactical officer should see a 'Waypoint Distance' button they can click to exercise this function if one or more waypoints have been placed.",
		["Trigger Missile"] = "Your ship can trigger splash missiles remotely: %s. The Weapons or Tactical officer should click the 'Trigger EMP 3-4u', 'Trigger EMP 4-5u', 'Trigger Nuke 3-4u', or 'Trigger Nuke 4-5u' as applicable to remote detonate the missile type in range in flight. The button(s) only appear when the missile(s) in flight meet the type and range criteria.",
	}
	ship:addCustomButton(console,string.format("close ship reference %s",console),"Close Ship Ref",function()
		string.format("")
		ship:removeCustom(string.format("close ship reference %s",console))
		for i,ref in ipairs(ship_references[console]) do
			ship:removeCustom(string.format("ship reference %s %s",console,ref))
		end
		ship:addCustomButton(console,open_references[console],"Open Ship Ref",function()
			string.format("")
			openShipReference(ship,console)
		end,500)
	end,500)
	for i,ref in ipairs(ship_references[console]) do
		if ship.ship_reference[ref] ~= nil then
			ship:addCustomButton(console,string.format("ship reference %s %s",console,ref),ref,function()
				string.format("")
				local ref_msg = ship.ship_reference[ref].desc
				if ref_msg == nil then
					if ref == "EPJAM" then
						local epjam_radius = {".5","1","2"}
						local epjam_size = {"S","M","L"}
						ref_msg = string.format(generic_reference_messages[ref],epjam_radius[ship.epjam],epjam_size[ship.epjam])
					elseif ref == "Turbo Torp" then
						local missile_decode = {
							["EMPMissile"] = "EMP",
							["HomingMissile"] = "Homing",
							["Nuke"] = "Nuke",
						}
						local torp_types = ""
						for j,torp in ipairs(ship.turbo_torpedo_type) do
							if torp_types == "" then
								torp_types = missile_decode[torp]
							else
								torp_types = string.format("%s, %s",torp_types,missile_decode[torp])
							end
						end
						ref_msg = string.format(generic_reference_messages[ref],torp_types,ship.turbo_torp_charge_interval)
					elseif ref == "Proximity Scan" then
						ref_msg = string.format(generic_reference_messages[ref],ship.prox_scan)
					elseif ref == "Trigger Missile" then
						local range_type_decode = {
							["E3"] = "EMP@3-4u",
							["E4"] = "EMP@4-5u",
							["N3"] = "Nuke@3-4u",
							["N4"] = "Nuke@4-5u",
						}
						local ranges_types = ""
						for range_type,details in pairs(ship.trigger_missile) do
							if ranges_types == "" then
								ranges_types = range_type_decode[range_type]
							else
								ranges_types = string.format("%s, %s",ranges_types,range_type_decode[range_type])
							end
						end
						ref_msg = string.format(generic_reference_messages[ref],ranges_types)
					elseif ref == "Patrol Probe" then
						local max_patrol = math.floor((1 - ship.patrol_probe/5) * ship:getMaxScanProbeCount())
						ref_msg = string.format(generic_reference_messages[ref],max_patrol)
					else
						ref_msg = generic_reference_messages[ref]
					end
				end
				ship:addCustomMessage(console,string.format("ship reference message %s %s",console,ref),ref_msg)
			end,500 + ship.ship_reference[ref].ord)
		end
	end
end
function createShipReference(ship)
	local ftl = ""
	if ship:hasJumpDrive() then
		ftl = string.format("Jump: Long: %s, Short: %s",ship.max_jump_range/1000,ship.min_jump_range/1000)
	end
	if ship:hasWarpDrive() then
		if ftl == "" then
			ftl = string.format("Warp: Speed: %s",ship:getWarpSpeed())
		else
			ftl = string.format("%s\nWarp: Speed: %s",ftl,ship:getWarpSpeed())
		end
	end
	local shield_line = ""
	if ship:getShieldCount() > 1 then
		shield_line = string.format("Shields: Front: %s, Rear: %s",ship:getShieldMax(0),ship:getShieldMax(1))
	elseif ship:getShieldCount() > 0 then
		shield_line = string.format("Shield: %s",ship:getShieldMax(0))
	else
		shield_line = "Shields: None"
	end
	local beam_line = ""
	local beam_count = 0
	local explain_damage_type = false
	for i=0,15 do
		if ship:getBeamWeaponRange(i) > 1 then
			beam_count = beam_count + 1
			if beam_line == "" then
				beam_line = string.format("Direction: %s    Arc: %s    Range: %s    Cycle: %s    Damage: %s    Damage type: %s",ship:getBeamWeaponDirection(i),ship:getBeamWeaponArc(i),ship:getBeamWeaponRange(i)/1000,ship:getBeamWeaponCycleTime(i),ship:getBeamWeaponDamage(i),ship.beam_damage_type[i+1])
				if ship:getBeamWeaponTurretArc(i) > ship:getBeamWeaponArc(i) then
					beam_line = string.format("%s    Turret(arc: %s    speed: %.1f)",beam_line,ship:getBeamWeaponTurretArc(i),ship:getBeamWeaponTurretRotationRate(i))
				end
			else
				beam_line = string.format("%s\nDirection: %s    Arc: %s    Range: %s    Cycle: %s    Damage: %s    Damage type: %s",beam_line,ship:getBeamWeaponDirection(i),ship:getBeamWeaponArc(i),ship:getBeamWeaponRange(i)/1000,ship:getBeamWeaponCycleTime(i),ship:getBeamWeaponDamage(i),ship.beam_damage_type[i+1])
				if ship:getBeamWeaponTurretArc(i) > ship:getBeamWeaponArc(i) then
					beam_line = string.format("%s    Turret(arc: %s    speed: %.1f)",beam_line,ship:getBeamWeaponTurretArc(i),ship:getBeamWeaponTurretRotationRate(i))
				end
			end
			if ship.beam_damage_type[i+1] ~= "energy" then
				explain_damage_type = true
			end
		end
	end
	if beam_count > 0 then
		beam_line = string.format("Beams: %s\n%s",beam_count,beam_line)
		if explain_damage_type then
			beam_line = string.format("%s\nNote: beam damage type 'energy' is the typical beam weapon where the frequency of the beam and the frequency of the shield impacts the amount of damage applied. Damage type 'emp' just damages shields. Damage type 'kinetic' applies the given damage regardless of the frequency of the beam or shield",beam_line)
		end
	else
		beam_line = "No beam weapons"
	end
	local tube_line = ""
	local explain_missile_size = false
	if ship:getWeaponTubeCount() > 0 then
		tube_line = string.format("Tubes: %s",ship:getWeaponTubeCount())
		for i=1,ship:getWeaponTubeCount() do
			tube_line = string.format("%s\nDirection: %s    Speed: %s    Size: %s    Ordnance: %s",tube_line,ship.tube_direction[i],ship:getTubeLoadTime(i-1),ship:getTubeSize(i-1),ship.tube_ordnance[i])
			if ship:getTubeSize(i-1) ~= "medium" then
				explain_missile_size = true
			end
		end
		tube_line = string.format("%s\nMagazine:",tube_line)
		if ship:getWeaponStorageMax("Homing") > 0 then
			tube_line = string.format("%s    Homing: %s",tube_line,ship:getWeaponStorageMax("Homing"))
		end
		if ship:getWeaponStorageMax("Nuke") > 0 then
			tube_line = string.format("%s    Nuke: %s",tube_line,ship:getWeaponStorageMax("Nuke"))
		end
		if ship:getWeaponStorageMax("Mine") > 0 then
			tube_line = string.format("%s    Mine: %s",tube_line,ship:getWeaponStorageMax("Mine"))
		end
		if ship:getWeaponStorageMax("EMP") > 0 then
			tube_line = string.format("%s    EMP: %s",tube_line,ship:getWeaponStorageMax("EMP"))
		end
		if ship:getWeaponStorageMax("HVLI") > 0 then
			tube_line = string.format("%s    HVLI: %s",tube_line,ship:getWeaponStorageMax("HVLI"))
		end
		if explain_missile_size then
			tube_line = string.format("%s\nNote: Small missiles fly twice as fast as medium missiles, turn twice as fast as medium missiles and do half the damage (and half the blast radius for EMP/Nuke) of medium missiles. Large missiles fly half as fast as medium missiles, turn half as fast as medium missiles and do twice the damage (and twice the blast radius) of medium missiles.",tube_line)
		end
	else
		tube_line = "No weapon tubes"
	end
	local hot_template = ship:getTypeName()
	local ac_forward, ac_back = ship:getAcceleration()
	local im_forward, im_back = ship:getImpulseMaxSpeed()
	local turn = ship:getRotationMaxSpeed()
	local boost = ship.combat_maneuver_boost
	local strafe = ship.combat_maneuver_strafe
	ship.ship_reference = {
		["Misc"] = {ord = 1, desc = string.format("Relative strength: %s   Radar: Long: %s, Short: %s   Escape pod capacity: %s\nCargo space: %s   Probes: %s   Repair crew: %s   Energy capacity: %s",playerShipStats[hot_template].strength,playerShipStats[hot_template].long_range_radar/1000,playerShipStats[hot_template].short_range_radar/1000,playerShipStats[hot_template].pods,playerShipStats[hot_template].cargo,playerShipStats[hot_template].probes,ship:getRepairCrewCount(),ship:getEnergyLevelMax())},
		["Engines"] = {ord = 3, desc = string.format("%s\nImpulse: Forward: %s, Back: %s\nAccelerate: Forward: %s, Back: %s\nTurn: %s\nCombat maneuver: Boost: %s, Strafe: %s",ftl,im_forward,im_back,ac_forward,ac_back,turn,boost,strafe)},
		["Defense"] = {ord = 4, desc = string.format("Hull: %s\n%s",ship:getHullMax(),shield_line)},
		["Beams"] = {ord = 5, desc = beam_line},
		["Tubes"] = {ord = 6, desc = tube_line},
	}
	if playerShipStats[hot_template].tractor then
		ship.ship_reference["Tractor"] = {ord = 7}
	end
	if playerShipStats[hot_template].mining then
		ship.ship_reference["Mining"] = {ord = 8}
	end
	if playerShipStats[hot_template].turbo_torp then
		ship.ship_reference["Turbo Torp"] = {ord = 9}
	end
	if playerShipStats[hot_template].patrol_probe > 0 then
		ship.ship_reference["Patrol Probe"] = {ord = 10}
	end
	if playerShipStats[hot_template].prox_scan > 0 then
		ship.ship_reference["Proximity Scan"] = {ord = 11}
	end
	if playerShipStats[hot_template].epjam > 0 then
		ship.ship_reference["EPJAM"] = {ord = 12}
	end
	if playerShipStats[hot_template].power_sensor_interval > 0 then
		ship.ship_reference["Powered Sensors"] = {ord = 13}
	end
	if playerShipStats[hot_template].way_dist then
		ship.ship_reference["Waypoint Calc"] = {ord = 15}
	end
	if playerShipStats[hot_template].trigger_missile ~= nil then
		ship.ship_reference["Trigger Missile"] = {ord = 16}
	end
end
function createPlayerShipAmbition()
	--first version destroyed 1Feb2020, version 2 reduced hull strength
	local base_template = "Phobos M3P"
	local hot_template = "Phobos T2"
	local ship = PlayerSpaceship():setTemplate(base_template):setFaction("Human Navy"):setCallSign("Ambition")
	setBeamColor(ship)
	ship.combat_maneuver_boost = stock_combat_maneuver[base_template].boost
	ship.combat_maneuver_strafe = stock_combat_maneuver[base_template].strafe
	ship.beam_damage_type = stock_beam_damage_type[base_template]
	ship.beam_damage_type[1] = "emp"
	ship.beam_damage_type[2] = "emp"	
	ship.beam_damage_type[3] = "energy"	
	ship.beam_damage_type[4] = "energy"	
	ship.tube_direction = {0,0,0,180}
	ship.tube_ordnance = {"HVLI","HVLI","all but Mine","Mine"}
	ship:setTypeName(hot_template)
	ship:setRepairCrewCount(5)					--more repair crew (vs 3)
	ship:setHullMax(160)							--weaker hull (vs 200)
	ship:setHull(160)
	ship:setJumpDrive(true)						--jump drive (vs none)
	ship.max_jump_range = 25000					--shorter than typical (vs 50)
	ship.min_jump_range = 2000					--shorter than typical (vs 5)
	ship:setJumpDriveRange(ship.min_jump_range,ship.max_jump_range)
	ship:setJumpDriveCharge(ship.max_jump_range)
--                 		 Arc, Dir, Range, CycleTime, Dmg
	ship:setBeamWeapon(0, 10,  15,  1200,         8, 6):setBeamWeaponDamageType(0,"emp")	--uncrossed (vs crossed), emp damage (vs energy)
	ship:setBeamWeapon(1, 10, -15,  1200,         8, 6):setBeamWeaponDamageType(1,"emp")
	ship:setBeamWeapon(2, 90,  15,   900,		  8, 6)
	ship:setBeamWeapon(3, 90, -15,   900,		  8, 6)
--										 Arc, Dir, Rotate speed
	ship:setBeamWeaponTurret(0, 90,  15, .2)		--slow turret beams
	ship:setBeamWeaponTurret(1, 90, -15, .2)
	ship:setWeaponTubeCount(4)					--one more tube (vs 3)
	ship:setWeaponTubeDirection(0,0)				--straight (vs angled)
	ship:setWeaponTubeDirection(1,0)				--straight (vs angled)
	ship:setWeaponTubeDirection(2,0)				--forward (vs rear)
	ship:setWeaponTubeDirection(3,180)			--rear (vs none)
	ship:setWeaponTubeExclusiveFor(0,"HVLI")		--only HVLI (vs any)
	ship:setWeaponTubeExclusiveFor(1,"HVLI")		--only HVLI (vs any)
	ship:setWeaponTubeExclusiveFor(2,"HVLI")
	ship:setWeaponTubeExclusiveFor(3,"Mine")
	ship:weaponTubeAllowMissle(2,"Homing")
	ship:weaponTubeAllowMissle(2,"Nuke")
	ship:weaponTubeAllowMissle(2,"EMP")
	ship:setTubeSize(0,"small")					--small (vs normal)
	ship:setTubeSize(1,"small")					--small (vs normal)
	ship:setTubeLoadTime(2, 15)					--slower (vs 10)
	ship:setTubeLoadTime(3, 20)					--slower (vs 10)
	ship:setWeaponStorageMax("Homing",6)			--reduce homing storage (vs 10)
	ship:setWeaponStorage("Homing",6)
	ship:setSystemCoolantRate("reactor",		1.3)	--more (vs 1.2)
	ship:setSystemCoolantRate("beamweapons",	1.1)	--less (vs 1.2)
	ship:setSystemCoolantRate("maneuver",		1.05)	--less (vs 1.2)
	ship:setSystemCoolantRate("impulse",		1.1)	--less (vs 1.2)
	ship:setSystemCoolantRate("frontshield",	1.05)	--less (vs 1.2)
	ship:setSystemCoolantRate("rearshield",	1.15)	--less (vs 1.2)
	ship:setSystemPowerRate("reactor",		0.40)	--more (vs 0.30)
	ship:setSystemPowerRate("beamweapons",	0.275)	--less (vs 0.30)
	ship:setSystemPowerRate("maneuver",		0.225)	--less (vs 0.30)
	ship:setSystemPowerRate("impulse",		0.25)	--less (vs 0.30)
	ship:setSystemPowerRate("frontshield",	0.225)	--less (vs 0.30)
	ship:setSystemPowerRate("rearshield",		0.325)	--more (vs 0.30)
	createShipReference(ship)
	ship.ship_reference["Diff Sum"] = {ord = 2, desc = "Phobos T2 is based on Phobos M3P\nDifferences: more repair crew, weaker hull (vs 200), jump drive (vs none), uncrossed and turreted beams (vs crossed/fix mount), additional tube: 3 forward tubes, 1 rear (vs 3 tubes: 2 angled forward, 1 rear), 2 small forward tubes (vs medium tubes), fewer homing missiles (6 vs 10), varying speeds of coolant and power deployment per system (vs fixed)."}
	addShipReference(ship)
	ship:onTakingDamage(playerShipDamage)
	ship:addReputationPoints(50)
	return ship
end
function createPlayerShipAnvil()
	local base_template = "Phobos M3P"
	local hot_template = "Deimos"
	local ship = PlayerSpaceship():setTemplate(base_template):setFaction("Human Navy"):setCallSign("Anvil")
	setBeamColor(ship)
	ship.combat_maneuver_boost = stock_combat_maneuver[base_template].boost
	ship.combat_maneuver_strafe = stock_combat_maneuver[base_template].strafe
	ship.beam_damage_type = stock_beam_damage_type[base_template]
	ship.tube_direction = {4,-4,0,90,-90,180}
	ship.tube_ordnance = {"Homing","Homing","EMP","all but Mine","all but Mine","Mine"}
	ship:setTypeName(hot_template)
	ship:setWarpDrive(true)						--warp drive (vs none)
	ship:setWarpSpeed(450)
	ship:setShieldsMax(150, 80)					--asymmetric shields (vs 100, 100)
	ship:setShields(150, 80)
	ship:setHullMax(180)							--weaker hull (vs 200)
	ship:setHull(180)
	ship:setRotationMaxSpeed(15)					--faster spin (vs 10)
	ship:setAcceleration(30,25)					--faster (vs 20/20)
	ship:setImpulseMaxSpeed(80,72)				--slower reverse impulse (vs 80)
--                 				 Arc, Dir, Range,   CycleTime,  Damage
	ship:setBeamWeapon(0,  60,  20,	1200, 		  4.5,	5.5)	--narrower (vs 90), faster (vs 8), weaker (vs 6)
	ship:setBeamWeapon(1,  60, -20,	1200, 		  4.5,	5.5)	
	ship:setBeamWeapon(2,  10,   0,	1500, 		    6,	2.5)
--										Arc,  Dir, Rotate speed
	ship:setBeamWeaponTurret(2,	160,    0,			1)	
	ship:setWeaponTubeCount(6)					--more (vs 3)
	ship:setWeaponTubeDirection(0,  4)			--right with more angle (vs left -1)
	ship:setWeaponTubeDirection(1, -4)			--left with more angle (vs right 1)
	ship:setTubeSize(0,"large")					--large (vs medium)
	ship:setTubeSize(1,"large")					--large (vs medium)
	ship:setWeaponTubeExclusiveFor(0,"Homing")	--homing only (vs any)
	ship:setWeaponTubeExclusiveFor(1,"Homing")	--homing only (vs any)
	ship:setTubeLoadTime(0,20)					--slower (vs 10)
	ship:setTubeLoadTime(1,20)					--slower (vs 10)
	ship:setWeaponTubeDirection(2,   0)			--forward (vs rear)
	ship:setTubeSize(2,"small")					--small (vs medium)
	ship:setTubeLoadTime(2,8)					--faster (vs 10)
	ship:setWeaponTubeExclusiveFor(2,"EMP")		--EMP only (vs mine)
	ship:setWeaponTubeDirection(3,  90)			
	ship:setWeaponTubeDirection(4, -90)
	ship:setWeaponTubeExclusiveFor(3,"HVLI")
	ship:weaponTubeAllowMissle(3,"Homing")
	ship:weaponTubeAllowMissle(3,"Nuke")
	ship:weaponTubeAllowMissle(3,"EMP")
	ship:setWeaponTubeExclusiveFor(4,"HVLI")
	ship:weaponTubeAllowMissle(4,"Homing")
	ship:weaponTubeAllowMissle(4,"Nuke")
	ship:weaponTubeAllowMissle(4,"EMP")
	ship:setWeaponTubeDirection(5,180)
	ship:setWeaponTubeExclusiveFor(5,"Mine")
	ship:setTubeLoadTime(5,15)					--slower (vs 10)
	ship:setWeaponStorageMax("EMP", 6)			--more (vs 3)
	ship:setWeaponStorage("EMP", 6)
	createShipReference(ship)
	ship.ship_reference["Diff Sum"] = {ord = 2, desc = "Deimos is based on Phobos M3P\nDifferences: Warp drive (vs none), asymetric shields (vs 100), weaker hull (vs 200), faster spin (vs 10), faster acceleration (vs 20), slower reverse impulse (vs 80), beams that are narrower (vs 90), faster (vs 8) and weaker (vs 6), additional long, weak, turreted beam, more tubes (vs 3) of varying sizes, load times and angles, more EMPs (vs 3)"}
	addShipReference(ship)
	ship:onTakingDamage(playerShipDamage)
	ship:addReputationPoints(50)
	return ship
end
function createPlayerShipArgonaut()
	local base_template = "Nautilus"
	local hot_template = "Nusret"
	local ship = PlayerSpaceship():setTemplate(base_template):setFaction("Human Navy"):setCallSign("Argonaut")
	setBeamColor(ship)
	ship.combat_maneuver_boost = stock_combat_maneuver[base_template].boost
	ship.combat_maneuver_strafe = stock_combat_maneuver[base_template].strafe
	ship.beam_damage_type = stock_beam_damage_type[base_template]
	ship.tube_direction = {-60,60,180}
	ship.tube_ordnance = {"Homing","Homing","Mine"}
	ship:setTypeName(hot_template)
	ship.max_jump_range = 25000					--shorter than typical (vs 50)
	ship.min_jump_range = 2500					--shorter than typical (vs 5)
	ship:setJumpDriveRange(ship.min_jump_range,ship.max_jump_range)
	ship:setJumpDriveCharge(ship.max_jump_range)
	ship:setShieldsMax(100, 100)					--stronger shields (vs 60, 60)
	ship:setShields(100, 100)
	ship:setWeaponTubeDirection(0,-60)			--front left facing (vs back)
	ship:setWeaponTubeDirection(1, 60)			--front right facing (vs back)
	ship:setWeaponTubeExclusiveFor(0,"Homing")	--Homing only (vs Mine)
	ship:setWeaponTubeExclusiveFor(1,"Homing")	--Homing only (vs Mine)
	ship:setWeaponStorageMax("Homing",8)			--more homing (vs 0)
	ship:setWeaponStorage("Homing", 8)				
	ship:setWeaponStorageMax("Mine",8)			--fewer mines (vs 12)
	ship:setWeaponStorage("Mine", 8)				
	createShipReference(ship)
	ship.ship_reference["Diff Sum"] = {ord = 2, desc = "Nusret is based on Nautilus\nDifferences: shorter jump drive range (vs 50), stronger shields (vs 60/60), realign 1st two tubes from rear to 60/-60 and let them shoot homing missiles, decrease mines and increase homing missiles."}
	addShipReference(ship)
	ship:onTakingDamage(playerShipDamage)
	ship:addReputationPoints(50)
	return ship
end
function createPlayerShipArwine()
	--destroyed 14Dec2019
	local base_template = "Piranha"
	local hot_template = "Pacu"
	playerArwine = PlayerSpaceship():setTemplate("Piranha"):setFaction("Human Navy"):setCallSign("Arwine")
	local ship = playerArwine
	setBeamColor(ship)
	ship.combat_maneuver_boost = stock_combat_maneuver[base_template].boost
	ship.combat_maneuver_strafe = stock_combat_maneuver[base_template].strafe
	ship.beam_damage_type = stock_beam_damage_type[base_template]
	ship.tube_direction = {-90,-90,-90,90,90,90,180}
	ship.tube_ordnance = {"HVLI","all but Mine","HVLI","HVLI","all but Mine","HVLI","Mine"}
	ship:setTypeName("Pacu")
	ship:setRepairCrewCount(6)						--more repair crew (vs 2)
	ship.max_jump_range = 25000						--shorter than typical (vs 50)
	ship.min_jump_range = 2000						--shorter than typical (vs 5)
	ship:setJumpDriveRange(ship.min_jump_range,ship.max_jump_range)
	ship:setJumpDriveCharge(ship.max_jump_range)
	ship:setImpulseMaxSpeed(70)						--faster impulse max (vs 40)
	ship:setHullMax(150)							--stronger hull (vs 120)
	ship:setHull(150)
	ship:setShieldsMax(160,160)						--stronger shields (vs 70, 70)
	ship:setShields(160,160)
	ship:setBeamWeapon(0, 10, 0, 1200.0, 4.0, 4)	--one beam (vs 0)
	ship:setBeamWeaponTurret(0, 80, 0, .3)			--slow turret
	ship:setWeaponTubeCount(7)						--one fewer mine tube, but EMPs added
	ship:setWeaponTubeDirection(6, 180)				--mine tube points straight back
	ship:setWeaponTubeExclusiveFor(0,"HVLI")
	ship:setWeaponTubeExclusiveFor(1,"HVLI")
	ship:setWeaponTubeExclusiveFor(2,"HVLI")
	ship:setWeaponTubeExclusiveFor(3,"HVLI")
	ship:setWeaponTubeExclusiveFor(4,"HVLI")
	ship:setWeaponTubeExclusiveFor(5,"HVLI")
	ship:setWeaponTubeExclusiveFor(6,"Mine")
	ship:weaponTubeAllowMissle(1,"Homing")
	ship:weaponTubeAllowMissle(1,"EMP")
	ship:weaponTubeAllowMissle(1,"Nuke")
	ship:weaponTubeAllowMissle(4,"Homing")
	ship:weaponTubeAllowMissle(4,"EMP")
	ship:weaponTubeAllowMissle(4,"Nuke")
	ship:setWeaponStorageMax("EMP",4)				--more EMPs (vs 0)
	ship:setWeaponStorage("EMP", 4)					
	ship:setWeaponStorageMax("Nuke",4)				--fewer Nukes (vs 6)
	ship:setWeaponStorage("Nuke", 4)				
	ship:setSystemCoolantRate("reactor",		1.3)	--more (vs 1.2)
	ship:setSystemCoolantRate("beamweapons",	1.15)	--less (vs 1.2)
	ship:setSystemCoolantRate("missilesystem",	1.0)	--less (vs 1.2)
	ship:setSystemCoolantRate("maneuver",		1.15)	--less (vs 1.2)
	ship:setSystemCoolantRate("impulse",		1.35)	--more (vs 1.2) pump is here
	ship:setSystemCoolantRate("frontshield",	1.3)	--more (vs 1.2)
	ship:setSystemCoolantRate("rearshield",		1.0)	--less (vs 1.2)
	ship:setSystemPowerRate("reactor",			0.40)	--more (vs 0.30)
	ship:setSystemPowerRate("beamweapons",		0.275)	--less (vs 0.30)
	ship:setSystemPowerRate("missilesystem",	0.2)	--less (vs 0.30)
	ship:setSystemPowerRate("maneuver",			0.275)	--less (vs 0.30)
	ship:setSystemPowerRate("impulse",			0.375)	--more (vs 0.30)
	ship:setSystemPowerRate("jumpdrive",		0.325)	--more (vs 0.30)
	ship:setSystemPowerRate("frontshield",		0.35)	--more (vs 0.30)
	ship:setSystemPowerRate("rearshield",		0.2)	--less (vs 0.30)
	createShipReference(ship)
	ship.ship_reference["Diff Sum"] = {ord = 2, desc = "Pacu is based on Piranha\nDifferences: shorter jump drive range (vs 50), faster impulse (vs 40), stronger hull (vs 120), stronger shields (vs 70), one beam (vs none), fewer tubes (vs 8), One rear facing mine tube (vs 2 angled), more EMPs (vs 0), fewer nukes (vs 6), varying speeds of coolant and power deployment per system (vs fixed)."}
	addShipReference(ship)
	ship:onTakingDamage(playerShipDamage)
	ship:addReputationPoints(50)
	return ship
end
function createPlayerShipBarracuda()
	--destroyed 8feb2020
	--clone of Headhunter
	local base_template = "Piranha"
	local hot_template = "Redhook"
	local ship = PlayerSpaceship():setTemplate(base_template):setFaction("Human Navy"):setCallSign("Barracuda")
	setBeamColor(ship)
	ship.combat_maneuver_boost = stock_combat_maneuver[base_template].boost
	ship.combat_maneuver_strafe = stock_combat_maneuver[base_template].strafe
	ship.beam_damage_type = stock_beam_damage_type[base_template]
	ship.tube_direction = {-90,-90,-90,90,90,90,180}
	ship.tube_ordnance = {"HVLI","all but Mine","HVLI","HVLI","all but Mine","HVLI","Mine"}
	ship:setTypeName(hot_template)
	ship:setRepairCrewCount(4)						--more repair crew (vs 2)
	ship.max_jump_range = 30000						--shorter than typical (vs 50)
	ship.min_jump_range = 3000						--shorter than typical (vs 5)
	ship:setJumpDriveRange(ship.min_jump_range,ship.max_jump_range)
	ship:setJumpDriveCharge(ship.max_jump_range)
	ship:setSystemPowerFactor("jumpdrive",4)			--more efficient (vs 5)
	ship:setHullMax(140)								--stronger hull (vs 120)
	ship:setHull(140)
	ship:setShieldsMax(120, 120)						--stronger shields (vs 70, 70)
	ship:setShields(120, 120)
	ship:setBeamWeapon(0, 10, 0, 1000.0, 4.0, 4)		--one beam (vs 0)
	ship:setBeamWeaponTurret(0, 80, 0, .5)			--slow turret 
	ship:setWeaponTubeCount(7)						--one fewer mine tube, but EMPs added
	ship:setWeaponTubeDirection(6, 180)				--mine tube points straight back
	ship:setWeaponTubeExclusiveFor(0,"HVLI")
	ship:setWeaponTubeExclusiveFor(1,"HVLI")
	ship:setWeaponTubeExclusiveFor(2,"HVLI")
	ship:setWeaponTubeExclusiveFor(3,"HVLI")
	ship:setWeaponTubeExclusiveFor(4,"HVLI")
	ship:setWeaponTubeExclusiveFor(5,"HVLI")
	ship:setWeaponTubeExclusiveFor(6,"Mine")
	ship:setTubeSize(0,"small")						--small (vs large)
	ship:setTubeSize(3,"small")						--small (vs large)
	ship:setTubeLoadTime(0, 10)						--faster (vs 15)
	ship:setTubeLoadTime(3, 10)						--faster (vs 15)
	ship:setTubeLoadTime(2, 20)						--slower (vs 15)
	ship:setTubeLoadTime(5, 20)						--slower (vs 15)
	ship:weaponTubeAllowMissle(1,"Homing")
	ship:weaponTubeAllowMissle(1,"EMP")
	ship:weaponTubeAllowMissle(1,"Nuke")
	ship:weaponTubeAllowMissle(4,"Homing")
	ship:weaponTubeAllowMissle(4,"EMP")
	ship:weaponTubeAllowMissle(4,"Nuke")
	ship:setWeaponStorageMax("Mine",6)				--fewer mines (vs 8)
	ship:setWeaponStorage("Mine", 6)				
	ship:setWeaponStorageMax("EMP",6)				--more EMPs (vs 0)
	ship:setWeaponStorage("EMP", 6)					
	ship:setWeaponStorageMax("Nuke",4)				--fewer Nukes (vs 6)
	ship:setWeaponStorage("Nuke", 4)				
	createShipReference(ship)
	ship.ship_reference["Diff Sum"] = {ord = 2, desc = "Redhook is based on Piranha\nDifferences: shorter jump drive range (vs 50), more efficient jump drive (4 vs 5)"}
	addShipReference(ship)
	ship:onTakingDamage(playerShipDamage)
	ship:addReputationPoints(50)
	return ship
end
function createPlayerShipBlaire()
	local base_template = "Maverick"
	local hot_template = "Kludge"
	local ship = PlayerSpaceship():setTemplate(base_template):setFaction("Human Navy"):setCallSign("Blaire")
	setBeamColor(ship)
	ship.combat_maneuver_boost = stock_combat_maneuver[base_template].boost
	ship.combat_maneuver_strafe = stock_combat_maneuver[base_template].strafe
	ship.beam_damage_type = stock_beam_damage_type[base_template]
	ship.tube_direction = {-11,-23,174}
	ship.tube_ordnance = {"all but Mine","all but Mine","Mine"}
	ship:setTypeName(hot_template)
	ship:setMaxEnergy(1130)						--more maximum energy (vs 1000)
	ship:setEnergy(1130)							
	ship:setShieldsMax(160, 80)					--weaker shields (vs 160, 160)
	ship:setShields(100, 100)
	ship:setWarpSpeed(250)						--slower (vs 800)
	ship:setJumpDrive(true)						--jump drive (vs none)
	ship.max_jump_range = 18000					--shorter than typical (vs 50)
	ship.min_jump_range = 2000					--shorter than typical (vs 5)
	ship:setJumpDriveRange(ship.min_jump_range,ship.max_jump_range)
	ship:setJumpDriveCharge(ship.max_jump_range)
	ship:setRepairCrewCount(7)					--more repair crew (vs 4)
--                  		    Arc,   Dir,  Range, CycleTime, Dmg
	ship:setBeamWeapon(0, 10,   25, 1000.0,       6.0, 6)	--shorter (vs 2000), turreted, angled (vs 0)
	ship:setBeamWeapon(1, 34,   55,  500.0,       4.0, 8)	--shorter (vs 1500), angled (vs -20), faster (vs 6)
	ship:setBeamWeapon(2, 70, -120,  800.0,       6.0, 6)	--shorter (vs 1500), angled (vs 20), weaker (vs 8)
	ship:setBeamWeapon(3, 0, 0, 0, 0, 0)					--remove beams			
	ship:setBeamWeapon(4, 0, 0, 0, 0, 0)	
	ship:setBeamWeapon(5, 0, 0, 0, 0, 0)	
--									   Arc, Dir, Rotate speed
	ship:setBeamWeaponTurret(0, 50,  20, .2)
	ship:setWeaponTubeDirection(0, -11)			--angled (vs-90)
	ship:setWeaponTubeDirection(1,-23)			--angled (vs 90)
	ship:setWeaponTubeDirection(2,174)			--angled (vs 180)
	ship:setTubeSize(0,"small")					--small (vs medium)
	ship:setTubeLoadTime(1,6)					--faster (vs 8)
	ship:setTubeLoadTime(2,20)					--slower (vs 8)
	ship:setWeaponStorageMax("Homing", 3)		--less (vs 6)
	ship:setWeaponStorage("Homing", 3)				
	ship:setWeaponStorageMax("Nuke", 0)			--less (vs 2)
	ship:setWeaponStorage("Nuke", 0)				
	ship:setWeaponStorageMax("HVLI", 17)		--more (vs 10)
	ship:setWeaponStorage("HVLI", 17)				
	createShipReference(ship)
	ship.ship_reference["Diff Sum"] = {ord = 2, desc = "Kludge is based on Maverick\nDifferences: Jump plus Warp (vs Warp only), slower warp (vs 800), greater energy capacity (vs 1000), weaker rear shield (vs 160), fewer beams (vs 5) at unusual angles and ranges, tubes pointing in unusual directions, different sizes, different load times, different missile types."}
	addShipReference(ship)
	ship:onTakingDamage(playerShipDamage)
	ship:addReputationPoints(50)
	return ship
end
function createPlayerShipBlazon()
	--ship destroyed 24Aug2019
	local base_template = "Striker"
	local hot_template = "Stricken"
	local ship = PlayerSpaceship():setTemplate(base_template):setFaction("Human Navy"):setCallSign("Blazon")
	setBeamColor(ship)
	ship.combat_maneuver_boost = stock_combat_maneuver[base_template].boost
	ship.combat_maneuver_strafe = stock_combat_maneuver[base_template].strafe
	ship.beam_damage_type = stock_beam_damage_type[base_template]
	ship.tube_direction = {-60,60,180}
	ship.tube_ordnance = {"Homing,Nuke,EMP","Homing,Nuke,EMP","Mine"}
	ship:setTypeName(hot_template)
	ship:setRepairCrewCount(2)
	ship:setImpulseMaxSpeed(105)					-- up from default of 45
	ship:setRotationMaxSpeed(35)					-- up from default of 15
	ship:setShieldsMax(80,50)						-- up from 50, 30
	ship:setShields(80,50)							-- up from 50, 30
	ship:setBeamWeaponTurret(0,60,-15,2)			-- 60: narrower than default 100, 
	ship:setBeamWeaponTurret(1,60, 15,2)			-- 2: slower than default 6
	ship:setBeamWeapon(2,20,0,1200,6,5)				-- add forward facing beam
	ship:setWeaponTubeCount(3)						-- add tubes
	ship:setTubeLoadTime(0,10)
	ship:setTubeLoadTime(1,10)
	ship:setTubeLoadTime(2,15)
	ship:setWeaponTubeDirection(0,-60)
	ship:setWeaponTubeDirection(1,60)
	ship:setWeaponTubeDirection(2,180)
	ship:weaponTubeDisallowMissle(0,"Mine")
	ship:weaponTubeDisallowMissle(1,"Mine")
	ship:setWeaponTubeExclusiveFor(2,"Mine")
	ship:setWeaponStorageMax("Homing",6)
	ship:setWeaponStorage("Homing",6)
	ship:setWeaponStorageMax("EMP",2)
	ship:setWeaponStorage("EMP",2)
	ship:setWeaponStorageMax("Nuke",2)
	ship:setWeaponStorage("Nuke",2)
	ship:setWeaponStorageMax("Mine",4)
	ship:setWeaponStorage("Mine",4)
	createShipReference(ship)
	ship.ship_reference["Diff Sum"] = {ord = 2, desc = "Stricken is based on Striker\nDifferences: faster impulse (vs 45), faster spin (vs 15), stronger shields (vs 50/30), narrower beams (vs 100), slower turret (vs 6), additional beam, weapon tubes and missiles (vs none)"}
	addShipReference(ship)
	ship:onTakingDamage(playerShipDamage)
	ship:addReputationPoints(50)
	return ship
end
function createPlayerShipBling()
	local base_template = "Player Fighter"
	local hot_template = "Gadfly"
	playerGadfly = PlayerSpaceship():setTemplate(base_template):setFaction("Human Navy"):setCallSign("Bling")
	local ship = playerGadfly
	setBeamColor(ship)
	ship.combat_maneuver_boost = stock_combat_maneuver[base_template].boost
	ship.combat_maneuver_strafe = stock_combat_maneuver[base_template].strafe
	ship.beam_damage_type = stock_beam_damage_type[base_template]
	ship.tube_direction = {0,0,180}
	ship.tube_ordnance = {"HVLI","Nuke,EMP","Homing"}
	ship:setTypeName(hot_template)
	ship:setHullMax(120)						--stronger (vs 60)
	ship:setHull(120)
	ship:setShieldsMax(100,70)					--stronger shields (vs 40)
	ship:setShields(100,70)
	ship:setJumpDrive(true)						--jump drive (vs none)
	ship.max_jump_range = 15000					--shorter than typical (vs 50)
	ship.min_jump_range = 2000					--shorter than typical (vs 5)
	ship:setJumpDriveRange(ship.min_jump_range,ship.max_jump_range)
	ship:setJumpDriveCharge(ship.max_jump_range)
--                  			 Arc, Dir, Range, CycleTime, Dmg
	ship:setBeamWeapon(0, 50, 	0, 900.0, 		4.0, 9)		--wider (vs 40), shorter (vs 1), faster (vs 6)
	ship:setBeamWeapon(1,  0,	0,	   0,		  0, 0)		--fewer (vs 2)
	ship:setWeaponTubeCount(3)					--more (vs 0)
	ship:setWeaponTubeDirection(2, 180)
	ship:setTubeSize(0,"small")
	ship:setTubeLoadTime(0,5)
	ship:setWeaponTubeExclusiveFor(0,"HVLI")
	ship:setTubeLoadTime(1,10)
	ship:setWeaponTubeExclusiveFor(1,"Nuke")
	ship:weaponTubeAllowMissle(1,"EMP")
	ship:setTubeSize(2,"large")
	ship:setTubeLoadTime(2,15)
	ship:setWeaponTubeExclusiveFor(2,"Homing")
	ship:setWeaponStorageMax("Homing", 4)		--more (vs 0)
	ship:setWeaponStorage("Homing", 4)				
	ship:setWeaponStorageMax("Nuke", 2)			--more (vs 0)
	ship:setWeaponStorage("Nuke", 2)				
	ship:setWeaponStorageMax("EMP", 2)			--more (vs 0)
	ship:setWeaponStorage("EMP", 2)				
	ship:setWeaponStorageMax("HVLI", 6)			--more (vs 0)
	ship:setWeaponStorage("HVLI", 6)				
	createShipReference(ship)
	ship.ship_reference["Diff Sum"] = {ord = 2, desc = "Gadfly is based on Player Fighter\nDifferences: stronger hull (vs 60), stronger shields (vs 40), jump drive (vs no ftl), single beam (vs 2), weapon tubes and missiles (vs none)"}
	addShipReference(ship)
	ship:onTakingDamage(playerShipDamage)
	ship:addReputationPoints(50)
	return ship
end
function createPlayerShipClaw()
	local base_template = "Player Cruiser"
	local hot_template = "Raven"
	playerRaven = PlayerSpaceship():setTemplate(base_template):setFaction("Human Navy"):setCallSign("Claw")
	local ship = playerRaven
	setBeamColor(ship)
	ship.combat_maneuver_boost = stock_combat_maneuver[base_template].boost
	ship.combat_maneuver_strafe = stock_combat_maneuver[base_template].strafe
	ship.beam_damage_type = stock_beam_damage_type[base_template]
	ship.tube_direction = {-30,30,-60,60,0,180}
	ship.tube_ordnance = {"Nuke","Nuke","EMP","EMP","Homing","Mine"}
	ship:setTypeName(hot_template)
	ship:setJumpDrive(false)						
	ship:setWarpDrive(true)						--warp drive (vs jump)
	ship:setWarpSpeed(300)
	ship:setShieldsMax(120, 120)					--stronger shields (vs 80, 80)
	ship:setShields(120, 120)
	ship:setHullMax(160)							--weaker hull (vs 200)
	ship:setHull(160)
--                 				 Arc, Dir, Range,   CycleTime,  Damage
	ship:setBeamWeapon(0,  10, -90,	 900, 			6,	10)	--left (vs front) shorter (vs 1000)
	ship:setBeamWeapon(1,  10,  90,	 900, 			6,	10)	--right (vs front) shorter (vs 1000)
--										Arc,  Dir, Rotate speed
	ship:setBeamWeaponTurret(0,	 90,  -90,			1)	
	ship:setBeamWeaponTurret(1,	 90,   90,			1)	
	ship:setWeaponTubeCount(6)					--more (vs 3)
	ship:setWeaponTubeDirection(0, -30)			--more angled (vs -5)
	ship:setWeaponTubeDirection(1,  30)			--more angled (vs 5)
	ship:setTubeSize(0,"small")					--small (vs medium)
	ship:setTubeSize(1,"small")					--small (vs medium)
	ship:setWeaponTubeExclusiveFor(0,"Nuke")		--Nuke only (vs all but mine)
	ship:setWeaponTubeExclusiveFor(1,"Nuke")		--Nuke only (vs all but mine)
	ship:setWeaponTubeDirection(2, -60)			
	ship:setWeaponTubeDirection(3,  60)
	ship:setTubeSize(2,"small")
	ship:setTubeSize(3,"small")
	ship:setWeaponTubeExclusiveFor(2,"EMP")
	ship:setWeaponTubeExclusiveFor(3,"EMP")
	ship:setTubeLoadTime(4, 12)					--slower (vs 8)
	ship:setTubeSize(4,"large")
	ship:setWeaponTubeExclusiveFor(4,"Homing")
	ship:setWeaponTubeDirection(5, 180)
	ship:setTubeLoadTime(5, 10)					--slower (vs 8)
	ship:setWeaponTubeExclusiveFor(5,"Mine")
	ship:setWeaponStorageMax("Homing",8)			--less (vs 12)
	ship:setWeaponStorage("Homing",8)
	ship:setWeaponStorageMax("EMP",4)			--less (vs 6)
	ship:setWeaponStorage("EMP",4)
	ship:setWeaponStorageMax("Mine",6)			--less (vs 8)
	ship:setWeaponStorage("Mine",6)
	createShipReference(ship)
	ship.ship_reference["Diff Sum"] = {ord = 2, desc = "Raven is based on Player Cruiser\nDifferences: Warp instead of jump, stronger shields (vs 80), weaker hull (vs 200), broadside turreted beams (vs forward), more tubes (vs 3), fewer missiles"}
	addShipReference(ship)
	ship:onTakingDamage(playerShipDamage)
	ship:addReputationPoints(50)
	return ship
end
function createPlayerShipCobra()
	playerCobra = PlayerSpaceship():setTemplate("Striker"):setFaction("Human Navy"):setCallSign("Cobra")
	setBeamColor(playerCobra)
	playerCobra:setTypeName("Striker LX")
	playerCobra:setRepairCrewCount(3)						--more (vs 2)
	playerCobra:setShieldsMax(100,100)						--stronger shields (vs 50, 30)
	playerCobra:setShields(100,100)
	playerCobra:setHullMax(100)								--weaker hull (vs 120)
	playerCobra:setHull(100)
	playerCobra:setMaxEnergy(600)							--more maximum energy (vs 500)
	playerCobra:setEnergy(600)
	playerCobra:setJumpDrive(true)
	playerCobra.max_jump_range = 20000						--shorter than typical (vs 50)
	playerCobra.min_jump_range = 2000						--shorter than typical (vs 5)
	playerCobra:setJumpDriveRange(playerCobra.min_jump_range,playerCobra.max_jump_range)
	playerCobra:setJumpDriveCharge(playerCobra.max_jump_range)
	playerCobra:setImpulseMaxSpeed(65)						--faster impulse max (vs 45)
--                 				 Arc, Dir, Range, CycleTime, Damage
	playerCobra:setBeamWeapon(0,  10, -15,	1100, 		6.0, 	6.5)	--shorter (vs 1200) more damage (vs 6.0)
	playerCobra:setBeamWeapon(1,  10,  15,	1100, 		6.0,	6.5)
--									   Arc, Dir, Rotate speed
	playerCobra:setBeamWeaponTurret(0, 100, -15, .2)		--slower turret speed (vs 6)
	playerCobra:setBeamWeaponTurret(1, 100,  15, .2)
	playerCobra:setWeaponTubeCount(2)						--more tubes (vs 0)
	playerCobra:setWeaponTubeDirection(0,180)				
	playerCobra:setWeaponTubeDirection(1,180)
	playerCobra:setWeaponStorageMax("Homing",4)
	playerCobra:setWeaponStorage("Homing", 4)	
	playerCobra:setWeaponStorageMax("Nuke",2)	
	playerCobra:setWeaponStorage("Nuke", 2)	
	playerCobra:setWeaponStorageMax("EMP",3)	
	playerCobra:setWeaponStorage("EMP", 3)		
	playerCobra:setWeaponStorageMax("Mine",3)	
	playerCobra:setWeaponStorage("Mine", 3)	
	playerCobra:setWeaponStorageMax("HVLI",6)	
	playerCobra:setWeaponStorage("HVLI", 6)	
	playerCobra:setLongRangeRadarRange(20000)				--shorter longer range sensors (vs 30000)
	playerCobra.normal_long_range_radar = 20000
	playerCobra:setShortRangeRadarRange(4000)				--shorter short range sensors (vs 5000)
	playerCobra:onTakingDamage(playerShipDamage)
	playerCobra:addReputationPoints(50)
	return playerCobra
end
function createPlayerShipCrux()
	local base_template = "Player Missile Cr."
	local hot_template = "Mantis"
	local ship = PlayerSpaceship():setTemplate(base_template):setFaction("Human Navy"):setCallSign("Crux")
	setBeamColor(ship)
	ship.combat_maneuver_boost = stock_combat_maneuver[base_template].boost
	ship.combat_maneuver_strafe = stock_combat_maneuver[base_template].strafe
	ship.beam_damage_type = stock_beam_damage_type[base_template]
	ship.tube_direction = {0,0,-90,90,180}
	ship.tube_ordnance = {"HVLI","HVLI","Homing,Nuke,EMP","Homing,Nuke,EMP","Mine"}
	ship:setTypeName(hot_template)
--                  			  Arc, Dir,  Range, CycleTime, Dmg
	ship:setBeamWeapon(0,  60, -15,	1000.0,			6, 4)	--two beams (vs none)
	ship:setBeamWeapon(1,  60,  15,	1000.0,			6, 4)
	ship:setWeaponTubeCount(5)					--fewer (vs 7)
	ship:setWeaponTubeExclusiveFor(0,"HVLI")	--HVLI only
	ship:setWeaponTubeExclusiveFor(1,"HVLI")	--HVLI only
	ship:setTubeSize(0,"small")					--small (vs medium)
	ship:setTubeSize(1,"small")					--small (vs medium)
	ship:setTubeLoadTime(0, 5)					--faster (vs 8)
	ship:setTubeLoadTime(1, 5)					--faster (vs 8)
	ship:setWeaponTubeDirection(2,-90)			--left (vs right)
	ship:setWeaponTubeDirection(4,180)			--rear (vs left)
	ship:weaponTubeAllowMissle(2,"EMP")			--allow EMP (vs Homing only)
	ship:weaponTubeAllowMissle(2,"Nuke")		--allow Nuke (vs Homing only)
	ship:weaponTubeAllowMissle(3,"EMP")			--allow EMP (vs Homing only)
	ship:weaponTubeAllowMissle(3,"Nuke")		--allow Nuke (vs Homing only)
	ship:setWeaponTubeExclusiveFor(4,"Mine")	--Mine only (vs Homing)
	ship:setWeaponStorageMax("HVLI", 12)	
	ship:setWeaponStorage("HVLI",    12)	
	ship:setWeaponStorageMax("Homing",8)
	ship:setWeaponStorage("Homing",   8)	
	ship:setWeaponStorageMax("EMP",   6)
	ship:setWeaponStorage("EMP",      6)	
	ship:setWeaponStorageMax("Nuke",  3)
	ship:setWeaponStorage("Nuke",     3)	
	ship:setWeaponStorageMax("Mine",  3)
	ship:setWeaponStorage("Mine",     3)	
	ship.turbo_torpedo_type = {"EMPMissile"}
	ship.turbo_torp_factor = 3
	ship.turbo_torp_charge_interval = 60
	ship:setSystemCoolantRate("reactor",		1.25)	--more (vs 1.2)
	ship:setSystemCoolantRate("beamweapons",	1.3)	--more (vs 1.2)
	ship:setSystemCoolantRate("maneuver",		1.2)	--same (vs 1.2)
	ship:setSystemCoolantRate("warp",			1.3)	--more (vs 1.2)
	ship:setSystemCoolantRate("impulse",		1.15)	--less (vs 1.2)
	ship:setSystemCoolantRate("missilesystem",	1.25)	--more (vs 1.2)
	ship:setSystemCoolantRate("frontshield",	1)		--less (vs 1.2)
	ship:setSystemCoolantRate("rearshield",		1.1)	--less (vs 1.2)
	ship:setSystemPowerRate("reactor",		0.3)	--same (vs 0.30)
	ship:setSystemPowerRate("warp",			0.35)	--more (vs 0.30)
	ship:setSystemPowerRate("beamweapons",	0.3)	--same (vs 0.30)
	ship:setSystemPowerRate("maneuver",		0.25)	--less (vs 0.30)
	ship:setSystemPowerRate("impulse",		0.3)	--same (vs 0.30)
	ship:setSystemPowerRate("missilesystem",0.35)	--more (vs 0.30)
	ship:setSystemPowerRate("frontshield",	0.225)	--less (vs 0.30)
	ship:setSystemPowerRate("rearshield",	0.225)	--less (vs 0.30)
	createShipReference(ship)
	ship.ship_reference["Diff Sum"] = {ord = 2, desc = "Mantis is based on Player Missile Cruiser\nDifferences: Beams (vs none), fewer tubes (5 vs 7), 2 small, fast forward facing HVLI only tubes, single broadside pair for medium Homing, Nuke and HVLI, rear tube for Mine, factor 3 turbo torpedo system for EMP, different missiles (vs Homing:30   Nuke:8   Mine:12   EMP:10   HVLI:0), varying speeds of coolant and power deployment per system (vs fixed)."}
	addShipReference(ship)
	ship:onTakingDamage(playerShipDamage)
	ship:addReputationPoints(50)
	return ship
end
function createPlayerShipDarkstar()
	playerDarkstar = PlayerSpaceship():setTemplate("Player Cruiser"):setFaction("Human Navy"):setCallSign("Darkstar")
	setBeamColor(playerDarkstar)
	playerDarkstar:setTypeName("Destroyer IV")
	playerDarkstar.max_jump_range = 28000					--shorter (vs 50)
	playerDarkstar.min_jump_range = 3000					--shorter (vs 5)
	playerDarkstar:setJumpDriveRange(playerDarkstar.min_jump_range,playerDarkstar.max_jump_range)
	playerDarkstar:setJumpDriveCharge(playerDarkstar.max_jump_range)
	playerDarkstar:setShieldsMax(100, 100)					--stronger shields (vs 80, 80)
	playerDarkstar:setShields(100, 100)
	playerDarkstar:setHullMax(100)							--weaker hull (vs 200)
	playerDarkstar:setHull(100)
	playerDarkstar:setBeamWeapon(0, 40, -10, 1000.0, 5, 6)	--narrower (40 vs 90), faster (5 vs 6), weaker (6 vs 10)
	playerDarkstar:setBeamWeapon(1, 40,  10, 1000.0, 5, 6)
	playerDarkstar:setWeaponTubeDirection(0,-60)			--left -60 (vs -5)
	playerDarkstar:setWeaponTubeDirection(1, 60)			--right 60 (vs 5)
	playerDarkstar:setWeaponStorageMax("Homing",6)			--less (vs 12)
	playerDarkstar:setWeaponStorage("Homing", 6)				
	playerDarkstar:setWeaponStorageMax("Nuke",2)			--fewer (vs 4)
	playerDarkstar:setWeaponStorage("Nuke", 2)				
	playerDarkstar:setWeaponStorageMax("EMP",3)				--fewer (vs 6)
	playerDarkstar:setWeaponStorage("EMP", 3)				
	playerDarkstar:setWeaponStorageMax("Mine",4)			--fewer (vs 8)
	playerDarkstar:setWeaponStorage("Mine", 4)				
	playerDarkstar:setWeaponStorageMax("HVLI",6)			--more (vs 0)
	playerDarkstar:setWeaponStorage("HVLI", 6)				
	playerDarkstar:onTakingDamage(playerShipDamage)
	playerDarkstar:addReputationPoints(50)
	return playerDarkstar
end
function createPlayerShipDevon()
	playerWombat = PlayerSpaceship():setTemplate("ZX-Lindworm"):setFaction("Human Navy"):setCallSign("Devon")
	setBeamColor(playerWombat)
	--aka Devon or Farrah or Shannon
	playerWombat:setTypeName("Wombat")
	playerWombat:setHullMax(140)							--stronger hull (vs 75)
	playerWombat:setHull(140)
	playerWombat:setShieldsMax(160, 120)					--stronger shields (vs 40)
	playerWombat:setShields(160, 120)
	playerWombat:setRepairCrewCount(4)						--more repair crew (vs 1)
	playerWombat:setWarpDrive(true)							--add warp (vs none)
	playerWombat:setWarpSpeed(400)
--                 				 Arc, Dir, Range, CycleTime, Damage
	playerWombat:setBeamWeapon(0, 10, -20, 900.0,		4.0, 3)		--extra beam (vs 1@ 700 6.0, 2)
	playerWombat:setBeamWeapon(1, 10,  20, 900.0,		4.0, 3)	
--										Arc,	Dir, Rotate speed
	playerWombat:setBeamWeaponTurret( 0, 80,	-20, .3)
	playerWombat:setBeamWeaponTurret( 1, 80, 	 20, .3)
	playerWombat:setWeaponTubeCount(5)						--more (vs 3)
	playerWombat:setWeaponTubeDirection(0, 180)				
	playerWombat:setWeaponTubeDirection(1, 180)				
	playerWombat:setWeaponTubeDirection(2, 180)				
	playerWombat:setWeaponTubeDirection(3, 180)
	playerWombat:setWeaponTubeDirection(4, 180)
	playerWombat:setWeaponTubeExclusiveFor(0,"HVLI")
	playerWombat:setWeaponTubeExclusiveFor(1,"HVLI")
	playerWombat:weaponTubeAllowMissle(1,"Homing")
	playerWombat:setTubeSize(2,"large")						--large (vs small)
	playerWombat:setTubeLoadTime(2,15)						--slower load time (vs 10)
	playerWombat:setTubeLoadTime(0,5)						--faster load time (vs 10)
	playerWombat:setTubeLoadTime(1,5)						--faster load time (vs 10)
	playerWombat:setWeaponTubeExclusiveFor(2,"HVLI")
	playerWombat:weaponTubeAllowMissle(2,"Homing")
	playerWombat:setWeaponTubeExclusiveFor(3,"HVLI")
	playerWombat:weaponTubeAllowMissle(3,"EMP")
	playerWombat:weaponTubeAllowMissle(3,"Nuke")
	playerWombat:setWeaponTubeExclusiveFor(4,"Mine")
	playerWombat:setWeaponStorageMax("Mine",3)				--more (vs 0)
	playerWombat:setWeaponStorage("Mine",   3)				
	playerWombat:setWeaponStorageMax("EMP",3)				--more (vs 0)
	playerWombat:setWeaponStorage("EMP",   3)				
	playerWombat:setWeaponStorageMax("Nuke",2)				--more (vs 0)
	playerWombat:setWeaponStorage("Nuke",   2)				
	playerWombat:setWeaponStorageMax("Homing",8)			--more (vs 3)
	playerWombat:setWeaponStorage("Homing",   8)				
	playerWombat:onTakingDamage(playerShipDamage)
	playerWombat:addReputationPoints(50)
	return playerWombat
end
function createPlayerShipEagle()
	playerEagle = PlayerSpaceship():setTemplate("Flavia P.Falcon"):setFaction("Human Navy"):setCallSign("Eagle")
	setBeamColor(playerEagle)
	playerEagle:setTypeName("Era")
	playerEagle:setRotationMaxSpeed(15)									--faster spin (vs 10)
--                 				 Arc, Dir, Range, CycleTime, Damage
	playerEagle:setBeamWeapon(0,  10,   0,	1200, 		6.0, 	6.0)	--1 turret, 1 rear (vs 2 rear)
	playerEagle:setBeamWeapon(1,  80, 180,	1200, 		6.0,	6.0)
--										Arc,  Dir, Rotate speed
	playerEagle:setBeamWeaponTurret(0,	300,    0,			 .5)		--slow turret
	playerEagle:setShieldsMax(70, 100)									--stronger rear shields (vs 70, 70)
	playerEagle:setShields(70, 100)
	playerEagle:setLongRangeRadarRange(50000)							--longer long range sensors (vs 30000)
	playerEagle.normal_long_range_radar = 50000
	playerEagle:onTakingDamage(playerShipDamage)
	playerEagle:addReputationPoints(50)
	return playerEagle
end
function createPlayerShipEndeavor()
	local base_template = "Atlantis"
	local hot_template = "Bermuda"
	local ship = PlayerSpaceship():setTemplate(base_template):setFaction("Human Navy"):setCallSign("Endeavor")
	setBeamColor(ship)
	ship.combat_maneuver_boost = stock_combat_maneuver[base_template].boost
	ship.combat_maneuver_strafe = stock_combat_maneuver[base_template].strafe
	ship.beam_damage_type = stock_beam_damage_type[base_template]
	ship.tube_direction = {-90,90,180}
	ship.tube_ordnance = {"all but Mine","all but Mine","Mine"}
	ship:setTypeName(hot_template)
	ship:setRepairCrewCount(5)					--more repair crew (vs 3)
	ship:setImpulseMaxSpeed(70)					--slower impulse max (vs 90)
	ship:setAcceleration(30)						--faster acceleration (vs 20)
	ship:setMaxEnergy(800)						--less maximum energy (vs 1000)
	ship:setEnergy(800)
	ship:setHullMax(150)							--weaker hull (vs 250)
	ship:setHull(150)							
	ship:setShieldsMax(150,150)					--weaker shields (vs 200)
	ship:setShields(150,150)
	ship.max_jump_range = 35000					--shorter than typical (vs 50)
	ship.min_jump_range = 3500					--shorter than typical (vs 5)
	ship:setJumpDriveRange(ship.min_jump_range,ship.max_jump_range)
	ship:setJumpDriveCharge(ship.max_jump_range)
	ship:setBeamWeaponEnergyPerFire(0,ship:getBeamWeaponEnergyPerFire(0)*3)		--triple power use
	ship:setBeamWeaponHeatPerFire(0,ship:getBeamWeaponHeatPerFire(0)*3)			--triple heat
	ship:setBeamWeaponEnergyPerFire(1,ship:getBeamWeaponEnergyPerFire(1)*3)		--triple power use
	ship:setBeamWeaponHeatPerFire(1,ship:getBeamWeaponHeatPerFire(1)*3)			--triple heat
	ship:setWeaponTubeCount(3)					--fewer (vs 5)
	ship:setWeaponTubeDirection(1,  90)
	ship:setWeaponTubeDirection(2, 180)
	ship:setWeaponTubeExclusiveFor(2,"Mine")
	createShipReference(ship)
	ship.ship_reference["Diff Sum"] = {ord = 2, desc = "Bermuda is based on Atlantis\nDifferences: slower impulse (vs 90), faster acceleration (vs 20), less battery capacity (vs 1000), weaker hull (vs 250), weaker shields (vs 200), shorter jump (vs 50), beams eat more power and generate more heat, fewer tubes (vs 5)"}
	addShipReference(ship)
	ship:onTakingDamage(playerShipDamage)
	ship:addReputationPoints(50)
	return ship
end
function createPlayerShipEnola()
	playerEnola = PlayerSpaceship():setTemplate("Crucible"):setFaction("Human Navy"):setCallSign("Enola")
	setBeamColor(playerEnola)
	playerEnola:setTypeName("Fray")
	playerEnola:setWarpDrive(false)						--no warp drive (vs warp)
	playerEnola:setShieldsMax(100, 200)					--stronger rear shields (vs 160, 160)
	playerEnola:setShields(100, 200)
	playerEnola:setJumpDrive(true)						--jump drive (vs warp)
	playerEnola.max_jump_range = 20000					--shorter than typical (vs 50)
	playerEnola.min_jump_range = 2000					--shorter than typical (vs 5)
	playerEnola:setJumpDriveRange(playerEnola.min_jump_range,playerEnola.max_jump_range)
	playerEnola:setJumpDriveCharge(playerEnola.max_jump_range)
--                  			Arc, Dir, Range, CycleTime, Dmg
	playerEnola:setBeamWeapon(0, 10,   0, 900.0, 	   6.0,   4)	--3 beams (vs 2), shorter (vs 1000)
	playerEnola:setBeamWeapon(1, 10, -90, 900.0, 	   6.0,   4)	--less damage (vs 5)
	playerEnola:setBeamWeapon(2, 10,  90, 900.0, 	   6.0,   4)	--wider overall coverage, split overlap
--										Arc,  Dir, Rotate speed
	playerEnola:setBeamWeaponTurret(0,	110,    0,			 .3)	--slow turret
	playerEnola:setBeamWeaponTurret(1,	 90,  -90,			 .3)		
	playerEnola:setBeamWeaponTurret(2,	 90,   90,			 .3)		
	playerEnola:setWeaponTubeCount(4)					--fewer (vs 6)
	playerEnola:setWeaponTubeDirection(0, 180)			--all tubes face back (vs 3 front, 2 sides and 1 back)
	playerEnola:setWeaponTubeDirection(1, 180)
	playerEnola:setWeaponTubeDirection(2, 180)
	playerEnola:setWeaponTubeDirection(3, 180)
	playerEnola:setWeaponTubeExclusiveFor(1,"Homing")	
	playerEnola:weaponTubeAllowMissle(1,"EMP")			--Medium tube only for Homing or EMP (vs HVLI)
	playerEnola:setWeaponTubeExclusiveFor(2,"Nuke")		--Large tube only for nuke (vs HVLI)
	playerEnola:setWeaponTubeExclusiveFor(3,"Mine")
	playerEnola:setWeaponStorageMax("HVLI", 12)			--fewer (vs 24)
	playerEnola:setWeaponStorage("HVLI", 12)				
	playerEnola:setWeaponStorageMax("Homing",5)			--fewer (vs 8)
	playerEnola:setWeaponStorage("Homing", 5)				
	playerEnola:setWeaponStorageMax("EMP", 4)			--fewer (vs 6)
	playerEnola:setWeaponStorage("EMP", 4)				
	playerEnola:setWeaponStorageMax("Nuke", 2)			--fewer (vs 4)
	playerEnola:setWeaponStorage("Nuke", 2)				
	playerEnola:setWeaponStorageMax("Mine", 3)			--fewer (vs 6)
	playerEnola:setWeaponStorage("Mine", 3)				
	playerEnola:onTakingDamage(playerShipDamage)
	playerEnola:addReputationPoints(50)
	return playerEnola
end
function createPlayerShipEspadon()
	playerOrca = PlayerSpaceship():setTemplate("Phobos M3P"):setFaction("Human Navy"):setCallSign("Espadon")
	setBeamColor(playerOrca)
	playerOrca:setTypeName("Orca")
	playerOrca:setBeamWeapon(0, 0,  0,	 0,		 0, 0)
	playerOrca:setBeamWeapon(1, 0,  0,	 0,		 0, 0)
	playerOrca:onTakingDamage(playerShipDamage)
	playerOrca:addReputationPoints(50)
	return playerOrca	
end
function createPlayerShipFalcon()
	playerFalcon = PlayerSpaceship():setTemplate("Nautilus"):setFaction("Human Navy"):setCallSign("Falcon")
	setBeamColor(playerFalcon)
	playerFalcon:setTypeName("Eldridge")
	playerFalcon:setShieldsMax(100, 100)				--stronger shields (vs 60, 60)
	playerFalcon:setShields(100, 100)
	playerFalcon:setJumpDrive(false)					--no jump drive
	playerFalcon:setWarpDrive(true)						--warp drive (vs jump)
	playerFalcon:setWarpSpeed(400)						
	playerFalcon:setWeaponTubeDirection(0,0)			--front facing (vs back)
	playerFalcon:setWeaponTubeDirection(1,0)			--front facing (vs back)
	playerFalcon:setWeaponTubeExclusiveFor(0,"Homing")	--Homing only (vs Mine)
	playerFalcon:setWeaponTubeExclusiveFor(1,"Homing")	--Homing only (vs Mine)
	playerFalcon:setWeaponTubeExclusiveFor(2,"Mine")	--Mine only (vs any)
	playerFalcon:setWeaponStorageMax("Homing",12)		--more homing (vs 0)
	playerFalcon:setWeaponStorage("Homing", 12)				
	playerFalcon:setTubeLoadTime(2,20)					--slower (vs 10)
--                 				 Arc, Dir, Range, CycleTime, Damage
	playerFalcon:setBeamWeapon(0,  10, -90,	1200, 		6.0, 	6.0)	--broadside beams (vs forward, overlapping)	
	playerFalcon:setBeamWeapon(1,  10,  90,	1200, 		6.0,	6.0)
--										Arc,  Dir, Rotate speed
	playerFalcon:setBeamWeaponTurret(0,	 90,  -90,			 .3)		--slow turret
	playerFalcon:setBeamWeaponTurret(1,	 90,   90,			 .3)
	playerFalcon:onTakingDamage(playerShipDamage)
	playerFalcon:addReputationPoints(50)
	return playerFalcon
end
function createPlayerShipFist()
	playerInterlock = PlayerSpaceship():setTemplate("Repulse"):setFaction("Human Navy"):setCallSign("Fist")
	setBeamColor(playerInterlock)
	playerInterlock:setTypeName("Interlock")
	playerInterlock:setHullMax(250)							--stronger hull (vs 120)
	playerInterlock:setHull(250)
	playerInterlock:setShieldsMax(120, 120)					--stronger shields (vs 80, 80)
	playerInterlock:setShields(120, 120)
	playerInterlock.max_jump_range = 35000					--shorter than typical (vs 50)
	playerInterlock.min_jump_range = 3500					--shorter than typical (vs 5)
	playerInterlock:setJumpDriveRange(playerInterlock.min_jump_range,playerInterlock.max_jump_range)
	playerInterlock:setJumpDriveCharge(playerInterlock.max_jump_range)
--                 				 	 Arc, Dir, Range,   CycleTime,  Damage
	playerInterlock:setBeamWeapon(0,  10,   0,	 900, 			6,	6)	--front (vs right) shorter (vs 1200) stronger (vs 5)
	playerInterlock:setBeamWeapon(1,  10, 180,	 900, 			6,	4)	--rear (vs left) shorter (vs 1200) weaker (vs 5)
	playerInterlock:setBeamWeapon(2, 110, -35,	 300, 			6,	10)	--additional strong, short, front, wide
	playerInterlock:setBeamWeapon(3, 110,  35,	 300, 			6,	10)	--additional strong, short, front, wide
	playerInterlock:setBeamWeapon(4,  60, -20,	 600, 			6,	8)	--additional strong, medium, front
	playerInterlock:setBeamWeapon(5,  60,  20,	 600, 			6,	8)	--additional strong, medium, front
--											Arc,  Dir, Rotate speed
	playerInterlock:setBeamWeaponTurret(0,	100,    0,			1)		--slower turrets (vs 5)
	playerInterlock:setBeamWeaponTurret(1,	180,  180,			1)		
	playerInterlock:setWeaponTubeCount(3)					--more (vs 2)
	playerInterlock:setWeaponTubeDirection(0, -90)
	playerInterlock:setTubeSize(0,"large")
	playerInterlock:weaponTubeDisallowMissle(0,"Mine")	
	playerInterlock:setWeaponTubeDirection(1,  90)
	playerInterlock:setTubeSize(1,"large")
	playerInterlock:weaponTubeDisallowMissle(1,"Mine")	
	playerInterlock:setWeaponTubeDirection(2, 180)
	playerInterlock:setWeaponTubeExclusiveFor(2,"Mine")		--mine only
	playerInterlock:setWeaponStorageMax("Mine", 4)			--more mines (vs 0)
	playerInterlock:setWeaponStorage("Mine", 4)				
	playerInterlock:onTakingDamage(playerShipDamage)
	playerInterlock:addReputationPoints(50)
	return playerInterlock
end
function createPlayerShipFlaire()
	playerPeacock = PlayerSpaceship():setTemplate("Player Cruiser"):setFaction("Human Navy"):setCallSign("Flaire")
	setBeamColor(playerPeacock)
	playerPeacock:setTypeName("Peacock")
	playerPeacock:setRepairCrewCount(4)					--more repair crew (vs 3)
	playerPeacock:setImpulseMaxSpeed(75)				--slower impulse max (vs 90)
	playerPeacock:setRotationMaxSpeed(9)				--slower spin (vs 10)
	playerPeacock:setShieldsMax(120,100)				--stronger (vs 80,80)
	playerPeacock:setShields(120,100)
	playerPeacock.max_jump_range = 30000				--shorter than typical (vs 50)
	playerPeacock.min_jump_range = 3000					--shorter than typical (vs 5)
	playerPeacock:setJumpDriveRange(playerPeacock.min_jump_range,playerPeacock.max_jump_range)
	playerPeacock:setJumpDriveCharge(playerPeacock.max_jump_range)
--                 				   Arc, Dir, Range, CycleTime, Damage
	playerPeacock:setBeamWeapon(0,  10, -45,   800,			2,	2)	--4 light fast beams (vs 2 heavy)
	playerPeacock:setBeamWeapon(1,  10,  45,   800,			2,	2)
	playerPeacock:setBeamWeapon(2,  10, -15,  1000,			2,	2)
	playerPeacock:setBeamWeapon(3,  10,  15,  1000,			2,	2)
--										   Arc, Dir, Rotate speed
	playerPeacock:setBeamWeaponTurret(0,	60,	-45,	 .4)
	playerPeacock:setBeamWeaponTurret(1,	60,	 45,	 .4)
	playerPeacock:setBeamWeaponTurret(2,	60,	-15,	 .8)
	playerPeacock:setBeamWeaponTurret(3,	60,	 15,	 .8)
	playerPeacock:setWeaponTubeCount(5)					--5 add broadside (vs 3)
	playerPeacock:setWeaponTubeDirection(2,-90)			--left (vs rear)
	playerPeacock:setWeaponTubeDirection(3,90)			--right
	playerPeacock:setWeaponTubeDirection(4,180)			--rear
	playerPeacock:setWeaponTubeExclusiveFor(0,"Homing")	--homing only (vs any)
	playerPeacock:setWeaponTubeExclusiveFor(1,"Homing")	--homing only (vs any)
	playerPeacock:setWeaponTubeExclusiveFor(2,"EMP")	--EMP only (vs mine)
	playerPeacock:setWeaponTubeExclusiveFor(3,"Nuke")	--Nuke only
	playerPeacock:setWeaponTubeExclusiveFor(4,"Mine")	--mine only
	playerPeacock:setTubeSize(0,"small")				--small (vs normal)
	playerPeacock:setTubeSize(1,"small")				--small (vs normal)
	playerPeacock:setTubeLoadTime(0,5)					--faster (vs default 8)
	playerPeacock:setTubeLoadTime(1,5)					--faster (vs default 8)
	playerPeacock:setTubeLoadTime(4,12)					--slower (vs default 8)
	playerPeacock:setWeaponStorageMax("Homing",16)		--more (vs 12)
	playerPeacock:setWeaponStorage("Homing", 16)
	playerPeacock:setWeaponStorageMax("Nuke",3)			--less (vs 4)
	playerPeacock:setWeaponStorage("Nuke", 3)
	playerPeacock:setWeaponStorageMax("EMP",5)			--less (vs 6)
	playerPeacock:setWeaponStorage("EMP", 5)
	playerPeacock:setSystemCoolantRate("reactor",		1.275)	--more (vs 1.2)
	playerPeacock:setSystemCoolantRate("beamweapons",	1.2)	--same (vs 1.2)
	playerPeacock:setSystemCoolantRate("maneuver",		1.15)	--less (vs 1.2)
	playerPeacock:setSystemCoolantRate("jumpdrive",		1.275)	--more (vs 1.2)
	playerPeacock:setSystemCoolantRate("impulse",		1.175)	--less (vs 1.2)
	playerPeacock:setSystemCoolantRate("missilesystem",	1.225)	--more (vs 1.2)
	playerPeacock:setSystemCoolantRate("frontshield",	1.25)	--more (vs 1.2)
	playerPeacock:setSystemCoolantRate("rearshield",	1.2)	--same (vs 1.2)
	playerPeacock:setSystemPowerRate("reactor",		0.375)	--more (vs 0.30)
	playerPeacock:setSystemPowerRate("jumpdrive",	0.35)	--more (vs 0.30)
	playerPeacock:setSystemPowerRate("beamweapons",	0.25)	--less (vs 0.30)
	playerPeacock:setSystemPowerRate("maneuver",	0.2)	--less (vs 0.30)
	playerPeacock:setSystemPowerRate("impulse",		0.225)	--less (vs 0.30)
	playerPeacock:setSystemPowerRate("missilesystem",0.275)	--less (vs 0.30)
	playerPeacock:setSystemPowerRate("frontshield",	0.325)	--more (vs 0.30)
	playerPeacock:setSystemPowerRate("rearshield",	0.3)	--same (vs 0.30)
	playerPeacock:onTakingDamage(playerShipDamage)
	playerPeacock:addReputationPoints(50)
	return playerPeacock
end
function createPlayerShipFlipper()
	local base_template = "Player Missile Cr."
	local hot_template = "Midian"
	local ship = PlayerSpaceship():setTemplate(base_template):setFaction("Human Navy"):setCallSign("Flipper")
	setBeamColor(ship)
	ship.combat_maneuver_boost = stock_combat_maneuver[base_template].boost
	ship.combat_maneuver_strafe = stock_combat_maneuver[base_template].strafe
	ship.beam_damage_type = stock_beam_damage_type[base_template]
	ship.tube_direction = {-2,2,-90,90,180}
	ship.tube_ordnance = {"Homing","Homing","Nuke,EMP,HVLI","Nuke,EMP,HVLI","Mine"}
	ship:setTypeName(hot_template)
	ship:setRadarTrace("cruiser.png")	--different radar trace
	ship:setWarpSpeed(320)				--slower (vs 800)
--                  				Arc, Dir, Range, CycleTime, Dmg
	ship:setBeamWeapon(0,   50, -20,  1000, 	     6, 4)	--beams (vs none)
	ship:setBeamWeapon(1,   50,  20,  1000, 	     6, 4)
	ship:setBeamWeapon(2,   10, 180,  1000, 	     6, 2)
--									     Arc, Dir, Rotate speed
	ship:setBeamWeaponTurret(2, 220, 180, .3)
	ship:setWeaponTubeCount(5)					--fewer (vs 7)
	ship:setWeaponTubeDirection(0,-2)			--angled (vs front)
	ship:setWeaponTubeDirection(1, 2)			--angled (vs front)
	ship:setWeaponTubeDirection(2,-90)			--left (vs right)
	ship:setWeaponTubeDirection(4,180)			--rear (vs left)
	ship:setTubeSize(0,"small")				--small vs medium
	ship:setTubeSize(1,"small")				--small vs medium
	ship:setWeaponTubeExclusiveFor(0,"Homing")	--homing only
	ship:setWeaponTubeExclusiveFor(1,"Homing")	--homing only
	ship:setWeaponTubeExclusiveFor(2,"HVLI")
	ship:setWeaponTubeExclusiveFor(3,"HVLI")
	ship:setWeaponTubeExclusiveFor(4,"Mine")
	ship:weaponTubeAllowMissle(2,"EMP")
	ship:weaponTubeAllowMissle(3,"EMP")
	ship:weaponTubeAllowMissle(2,"Nuke")
	ship:weaponTubeAllowMissle(3,"Nuke")
	ship:setTubeLoadTime(2,12)
	ship:setTubeLoadTime(3,12)
	ship:setTubeLoadTime(4,15)
	ship:setWeaponStorageMax("Homing",16)		--less (vs 30)
	ship:setWeaponStorage("Homing",   16)				
	ship:setWeaponStorageMax("Nuke",   2)		--less (vs 8)
	ship:setWeaponStorage("Nuke",      2)				
	ship:setWeaponStorageMax("EMP",    5)		--less (vs 10)
	ship:setWeaponStorage("EMP",       5)				
	ship:setWeaponStorageMax("Mine",   8)		--less (vs 12)
	ship:setWeaponStorage("Mine",      8)				
	ship:setWeaponStorageMax("HVLI",  16)		--more (vs 0)
	ship:setWeaponStorage("HVLI",     16)
	ship.smallHomingOnly = true
	createShipReference(ship)
	ship.ship_reference["Diff Sum"] = {ord = 2, desc = "Midian is based on Player Missile Cruiser\nDifferences: uses the cruiser radar trace, slower warp speed (vs 800), 3 beams (vs none), fewer tubes (vs 7) with varying sizes, angles and load times, different set of ordnance (vs Homing:30   Nuke:8   Mine:12   EMP:10   HVLI:0), waypoint distance calculator, trigger splash missiles remotely"}
	addShipReference(ship)
	ship:onTakingDamage(playerShipDamage)
	ship:addReputationPoints(50)
	return ship
end
function createPlayerShipFlorentine()
	local base_template = "Flavia P.Falcon"
	local hot_template = "Safari"
	local ship = PlayerSpaceship():setTemplate(base_template):setFaction("Human Navy"):setCallSign("Florentine")
	setBeamColor(ship)
	ship.combat_maneuver_boost = stock_combat_maneuver[base_template].boost
	ship.combat_maneuver_strafe = stock_combat_maneuver[base_template].strafe
	ship.beam_damage_type = stock_beam_damage_type[base_template]
	ship.beam_damage_type[1] = "emp"
	ship.beam_damage_type[2] = "kinetic"	
	ship.tube_direction = {-90,90,180}
	ship.tube_ordnance = {"HVLI","HVLI","Mine"}
	ship:setTypeName(hot_template)
	ship:setShieldsMax(150, 90)					--stronger front, weaker rear (vs 70, 70)
	ship:setShields(150, 90)
--                 		  Arc, Dir, Range, CycleTime, Damage
	ship:setBeamWeapon(0,  10,   0,	1200, 		5.0, 	7.0)	--1 forward, 1 turret (vs 2 rear)
	ship:setBeamWeapon(1,  60,   0,	1000, 		6.0,    6.0)	--shorter (vs 1200)
	ship:setBeamWeapon(2,  40,   0,	 800, 		8.0,   12.0)	--extra beam
--								Arc,  Dir, Rotate speed
	ship:setBeamWeaponTurret(0,	 80,    0,			 .4)		--slow turret
	ship:setBeamWeaponDamageType(0,"emp")
	ship:setBeamWeaponDamageType(1,"kinetic")
	ship:setWeaponTubeCount(3)									--more (vs 1)
	ship:setWeaponTubeDirection(0, -90)							--left (vs rear)
	ship:setWeaponTubeDirection(1,  90)							--right (vs none)
	ship:setWeaponTubeDirection(2, 180)							--rear (vs none)
	ship:setWeaponTubeExclusiveFor(0,"HVLI")					--HVLI only (vs any)
	ship:setWeaponTubeExclusiveFor(1,"HVLI")					--HVLI only (vs none)
	ship:setWeaponTubeExclusiveFor(2,"Mine")					--Mine only (vs none)
	ship:setTubeSize(0,"small")									--small (vs medium)
	ship:setTubeSize(1,"small")									--small (vs none)
	ship:setTubeLoadTime(0,8)									--faster (vs 20)
	ship:setTubeLoadTime(1,8)									--faster (vs none)
	ship:setWeaponStorageMax("Homing", 0)						--less (vs 3)
	ship:setWeaponStorage("Homing", 0)
	ship:setWeaponStorageMax("Nuke", 0)							--less (vs 1)
	ship:setWeaponStorage("Nuke", 0)
	ship:setWeaponStorageMax("HVLI", 20)						--more (vs 5)
	ship:setWeaponStorage("HVLI", 20)
	ship:setWeaponStorageMax("Mine", 4)							--more (vs 1)
	ship:setWeaponStorage("Mine", 4)
	createShipReference(ship)
	ship.ship_reference["Diff Sum"] = {ord = 2, desc = "Safari is based on Flavia P. Falcon\nDifferences: stronger shields (150/90 vs 70/70), different beams including an added beam, more tubes, different missile types"}
	addShipReference(ship)
	ship:onTakingDamage(playerShipDamage)
	ship:addReputationPoints(50)
	return ship
end
function createPlayerShipGabble()
	local base_template = "Piranha"
	local hot_template = "Squid"
	local ship = PlayerSpaceship():setTemplate(base_template):setFaction("Human Navy"):setCallSign("Gabble")
	setBeamColor(ship)
	ship.combat_maneuver_boost = stock_combat_maneuver[base_template].boost
	ship.combat_maneuver_strafe = stock_combat_maneuver[base_template].strafe
	ship.beam_damage_type = stock_beam_damage_type[base_template]
	ship.tube_direction = {0,-90,-90,0,90,90,170,190}
	ship.tube_ordnance = {"HVLI","all but Mine","Homing","HVLI","all but Mine","Homing","Mine","Mine"}
	ship:setTypeName(hot_template)
	ship:setRepairCrewCount(5)					--more repair crew (vs 2)
	ship:setShieldsMax(120, 120)				--stronger shields (vs 70, 70)
	ship:setShields(120, 120)
	ship.max_jump_range = 20000					--shorter than typical (vs 50)
	ship.min_jump_range = 2000					--shorter than typical (vs 5)
	ship:setJumpDriveRange(ship.min_jump_range,ship.max_jump_range)
	ship:setJumpDriveCharge(ship.max_jump_range)
--                 				 Arc, Dir, Range, CycleTime, Damage
	ship:setBeamWeapon(0, 10,	0,	1000,		4,		4)		--one beam (vs 0)
--									   Arc,	  Dir, Rotate speed
	ship:setBeamWeaponTurret(0,	80,		0,		1)		--slow turret 
	ship:setWeaponTubeDirection(0,0)					--forward facing (vs left)
	ship:setWeaponTubeDirection(3,0)					--forward facing (vs right)
	ship:setWeaponTubeExclusiveFor(2,"Homing")			--homing only (vs HVLI)
	ship:setWeaponTubeExclusiveFor(5,"Homing")			--homing only (vs HVLI)
	ship:setWeaponTubeExclusiveFor(0,"HVLI")			--HVLI only (vs Homing + HVLI)
	ship:setWeaponTubeExclusiveFor(3,"HVLI")			--HVLI only (vs Homing + HVLI)
	ship:weaponTubeDisallowMissle(1,"Mine")				--no sideways mines
	ship:weaponTubeDisallowMissle(4,"Mine")				--no sideways mines
	ship:setWeaponStorageMax("Homing",8)				--fewer Homing (vs 12)
	ship:setWeaponStorage("Homing", 8)				
	ship:setWeaponStorageMax("Mine",6)					--fewer mines (vs 8)
	ship:setWeaponStorage("Mine", 6)				
	ship:setWeaponStorageMax("EMP",4)					--more EMPs (vs 0)
	ship:setWeaponStorage("EMP", 4)					
	ship:setWeaponStorageMax("Nuke",4)					--fewer Nukes (vs 6)
	ship:setWeaponStorage("Nuke", 4)				
	ship:setLongRangeRadarRange(25000)					--shorter long range sensors (vs 30000)
	ship.normal_long_range_radar = 25000
	createShipReference(ship)
	ship.ship_reference["Diff Sum"] = {ord = 2, desc = "Squid is based on Piranha\nDifferences: more repair crew (5 vs 2), stronger shields (120 vs 70), added beam weapon, realigned tubes, shorter sensor range (25U vs 30U)"}
	addShipReference(ship)
	ship:onTakingDamage(playerShipDamage)
	ship:addReputationPoints(50)
	return ship
end
function createPlayerShipGeorge()
	playerRodent = PlayerSpaceship():setTemplate("Phobos M3P"):setFaction("Human Navy"):setCallSign("George")
	setBeamColor(playerRodent)
	playerRodent:setTypeName("Rodent")
	playerRodent:setRepairCrewCount(5)					--more repair crew (vs 3)
	playerRodent:setJumpDrive(true)
	playerRodent.max_jump_range = 37000					--shorter than typical (vs 50)
	playerRodent.min_jump_range = 4000					--shorter than typical (vs 5)
	playerRodent:setJumpDriveRange(playerRodent.min_jump_range,playerRodent.max_jump_range)
	playerRodent:setJumpDriveCharge(playerRodent.max_jump_range)
	playerRodent:setShieldsMax(100,50)					--weaker rear (vs 100,100)
	playerRodent:setShields(100,50)
	playerRodent:setHullMax(150)						--weaker hull (vs 200)
	playerRodent:setHull(150)
--                  			  Arc, Dir,   Range, CycleTime, Dmg
	playerRodent:setBeamWeapon(0,  60, -15,	1200.0,			8, 5)		--narrower (vs 90), weaker (vs 6)
	playerRodent:setBeamWeapon(1,  60,  15,	1200.0,			8, 5)		
	playerRodent:setBeamWeapon(2,  10,	 0,	 600.0,			8, 3)		--add turret front & sides
	playerRodent:setBeamWeapon(3,  10, 180,	 500.0,			8, 4)		--add turret rear & sides
--										Arc,  Dir, Rotate speed
	playerRodent:setBeamWeaponTurret(2,	270,  	0,			 .4)		--slow turret
	playerRodent:setBeamWeaponTurret(3,	270,  180,			 .4)
	playerRodent:setWeaponTubeCount(5)					--more (vs 3)
	playerRodent:setWeaponTubeDirection(0, 0)			--straight (vs -1)
	playerRodent:setTubeLoadTime(0,8)					--faster (vs 10)
	playerRodent:setTubeSize(0,"small")					--small (vs medium)
	playerRodent:setWeaponTubeExclusiveFor(0,"HVLI")	--only HVLI (vs any)
	playerRodent:weaponTubeAllowMissle(0,"Homing")
	playerRodent:setWeaponTubeDirection(1, 0)			--straight (vs 1)
	playerRodent:setTubeLoadTime(1,8)					--faster (vs 10)
	playerRodent:setTubeSize(1,"small")					--small (vs medium)
	playerRodent:setWeaponTubeExclusiveFor(1,"HVLI")	--only HVLI & Homing (vs any)
	playerRodent:weaponTubeAllowMissle(1,"Homing")
	playerRodent:setWeaponTubeDirection(3, -90)			--left (vs 0)
	playerRodent:setWeaponTubeExclusiveFor(3,"EMP")		--only EMP & Nuke (vs any)
	playerRodent:weaponTubeAllowMissle(3,"Nuke")
	playerRodent:setWeaponTubeDirection(4, 90)			--left (vs 0)
	playerRodent:setWeaponTubeExclusiveFor(4,"EMP")		--only EMP & Nuke (vs any)
	playerRodent:weaponTubeAllowMissle(4,"Nuke")
	playerRodent:setTubeLoadTime(4,20)					--slower (vs 10)
	playerRodent:setTubeSize(4,"large")					--large (vs medium)
	playerRodent:setWeaponTubeDirection(2, 180)			--rear (vs 0)
	playerRodent:setWeaponTubeExclusiveFor(2,"Mine")	--only Mine (vs any)
	playerRodent:setTubeLoadTime(2,15)					--slower (vs 10)
	playerRodent:setSystemCoolantRate("reactor",		1.35)	--more (vs 1.2)
	playerRodent:setSystemCoolantRate("beamweapons",	1.2)	--same (vs 1.2)
	playerRodent:setSystemCoolantRate("maneuver",		1.1)	--less (vs 1.2)
	playerRodent:setSystemCoolantRate("jumpdrive",		1.25)	--more (vs 1.2)
	playerRodent:setSystemCoolantRate("impulse",		1.15)	--less (vs 1.2)
	playerRodent:setSystemCoolantRate("missilesystem",	1.25)	--more (vs 1.2)
	playerRodent:setSystemCoolantRate("frontshield",	1.1)	--less (vs 1.2)
	playerRodent:setSystemCoolantRate("rearshield",		1.2)	--same (vs 1.2)
	playerRodent:setSystemPowerRate("reactor",		0.40)	--more (vs 0.30)
	playerRodent:setSystemPowerRate("jumpdrive",	0.3)	--same (vs 0.30)
	playerRodent:setSystemPowerRate("beamweapons",	0.275)	--less (vs 0.30)
	playerRodent:setSystemPowerRate("maneuver",		0.225)	--less (vs 0.30)
	playerRodent:setSystemPowerRate("impulse",		0.25)	--less (vs 0.30)
	playerRodent:setSystemPowerRate("missilesystem",0.3)	--same (vs 0.30)
	playerRodent:setSystemPowerRate("frontshield",	0.225)	--less (vs 0.30)
	playerRodent:setSystemPowerRate("rearshield",	0.325)	--more (vs 0.30)
	playerRodent:onTakingDamage(playerShipDamage)
	playerRodent:addReputationPoints(50)
	return playerRodent
end
function createPlayerShipGorn()
	playerGorn = PlayerSpaceship():setTemplate("Atlantis"):setFaction("Human Navy"):setCallSign("Gorn")
	setBeamColor(playerGorn)
	playerGorn:setTypeName("Proto-Atlantis")
	playerGorn:setRepairCrewCount(5)					--more repair crew (vs 3)
	playerGorn.max_jump_range = 30000					--shorter than typical (vs 50)
	playerGorn.min_jump_range = 3000					--shorter than typical (vs 5)
	playerGorn:setJumpDriveRange(playerGorn.min_jump_range,playerGorn.max_jump_range)
	playerGorn:setJumpDriveCharge(playerGorn.max_jump_range)
	playerGorn:setBeamWeaponEnergyPerFire(0,playerGorn:getBeamWeaponEnergyPerFire(0)*3)		--triple power use
	playerGorn:setBeamWeaponHeatPerFire(0,playerGorn:getBeamWeaponHeatPerFire(0)*3)			--triple heat
	playerGorn:setBeamWeaponEnergyPerFire(1,playerGorn:getBeamWeaponEnergyPerFire(1)*3)		--triple power use
	playerGorn:setBeamWeaponHeatPerFire(1,playerGorn:getBeamWeaponHeatPerFire(1)*3)			--triple heat
	playerGorn:setWeaponTubeExclusiveFor(0,"HVLI")		--HVLI only (vs all but Mine)
	playerGorn:setWeaponTubeExclusiveFor(1,"Homing")	--Homing only (vs all but Mine)
	playerGorn:setWeaponTubeExclusiveFor(2,"HVLI")		--HVLI only (vs all but Mine)
	playerGorn:setWeaponTubeExclusiveFor(3,"Homing")	--Homing only (vs all but Mine)
	playerGorn:setWeaponStorageMax("EMP",0)				--fewer (vs 6)
	playerGorn:setWeaponStorage("EMP", 0)				
	playerGorn:setWeaponStorageMax("Nuke",0)			--fewer (vs 4)
	playerGorn:setWeaponStorage("Nuke", 0)	
	playerGorn:setLongRangeRadarRange(28000)			--shorter longer range sensors (vs 30000)
	playerGorn.normal_long_range_radar = 28000
	playerGorn:onTakingDamage(playerShipDamage)
	playerGorn:addReputationPoints(50)
	return playerGorn
end
function createPlayerShipGuinevere()
	local base_template = "Crucible"
	local hot_template = "Caretaker"
	local ship = PlayerSpaceship():setTemplate(base_template):setFaction("Human Navy"):setCallSign("Guinevere")
	setBeamColor(ship)
	ship.combat_maneuver_boost = stock_combat_maneuver[base_template].boost
	ship.combat_maneuver_strafe = stock_combat_maneuver[base_template].strafe
	ship.beam_damage_type = stock_beam_damage_type[base_template]
	ship.tube_direction = {0,0,0,180}
	ship.tube_ordnance = {"HVLI","Nuke,EMP","Homing","Mine"}
	ship:setTypeName(hot_template)
	ship:setWarpDrive(false)						--no warp drive (vs warp)
	ship:setJumpDrive(true)						--jump drive (vs warp)
	ship.max_jump_range = 40000					--shorter than typical (vs 50)
	ship.min_jump_range = 4000					--shorter than typical (vs 5)
	ship:setJumpDriveRange(ship.min_jump_range,ship.max_jump_range)
	ship:setJumpDriveCharge(ship.max_jump_range)
	ship:setShieldsMax(100, 100)					--weaker shields (vs 160, 160)
--                  			 Arc, Dir, Range, CycleTime, Dmg
	ship:setBeamWeapon(0, 80, -90, 900.0, 		5.0,   6)	--side beams (vs forward), faster (vs 6)
	ship:setBeamWeapon(1, 80,  90, 900.0, 		5.0,   6)	
	ship:setWeaponTubeCount(4)					--fewer (vs 6)
	ship:setWeaponTubeExclusiveFor(1,"EMP")		--normal sized tube allow EMPs and Nukes (vs HVLI)
	ship:weaponTubeAllowMissle(1,"Nuke")
	ship:setWeaponTubeExclusiveFor(2,"Homing")	--large tube for homing (vs HVLI)
	ship:setWeaponTubeExclusiveFor(3,"Mine")
	ship:setWeaponTubeDirection(3, 180)
	ship:setWeaponStorageMax("Homing",6)			--fewer (vs 8)
	ship:setWeaponStorage("Homing", 6)				
	ship:setWeaponStorageMax("EMP",3)			--fewer (vs 6)
	ship:setWeaponStorage("EMP", 3)				
	ship:setWeaponStorageMax("Nuke",2)			--fewer (vs 4)
	ship:setWeaponStorage("Nuke", 2)				
	ship:setWeaponStorageMax("Mine",3)			--fewer (vs 6)
	ship:setWeaponStorage("Mine", 3)				
	createShipReference(ship)
	ship.ship_reference["Diff Sum"] = {ord = 2, desc = "Caretaker is based on Crucible\nDifferences: Jump (vs Warp), weaker shields (vs 160), broadside beams (vs forwards), faster beam cycle time (vs 6), fewer tubes (vs 6), no broadside tubes, different missile types for front tubes, different missiles (vs Homing:8   Nuke:4   Mine:6   EMP:6)"}
	addShipReference(ship)
	ship:onTakingDamage(playerShipDamage)
	ship:addReputationPoints(50)
	return ship
end
function createPlayerShipHalberd()
	--destroyed 29Feb2020
	playerHalberd = PlayerSpaceship():setTemplate("Atlantis"):setFaction("Human Navy"):setCallSign("Halberd")
	setBeamColor(playerHalberd)
	playerHalberd:setTypeName("Proto-Atlantis")
	playerHalberd:setRepairCrewCount(4)					--more repair crew (vs 3)
	playerHalberd:setImpulseMaxSpeed(70)				--slower impulse max (vs 90)
	playerHalberd:setRotationMaxSpeed(14)				--faster spin (vs 10)
	playerHalberd.max_jump_range = 30000				--shorter than typical (vs 50)
	playerHalberd.min_jump_range = 3000					--shorter than typical (vs 5)
	playerHalberd:setJumpDriveRange(playerHalberd.min_jump_range,playerHalberd.max_jump_range)
	playerHalberd:setJumpDriveCharge(playerHalberd.max_jump_range)
	playerHalberd:setHullMax(230)						--weaker hull (vs 250)
	playerHalberd:setHull(230)							
--                 				 Arc, Dir, Range, CycleTime, Dmg
	playerHalberd:setBeamWeapon(0, 5, -10,  1500,       6.0, 8)		--narrower turreted beams
	playerHalberd:setBeamWeapon(1, 5,  10,  1500,       6.0, 8)		--vs arc:100, dir:-20
--									    Arc, Dir, Rotate speed
	playerHalberd:setBeamWeaponTurret(0, 70, -10, .25)
	playerHalberd:setBeamWeaponTurret(1, 70,  10, .25)

	playerHalberd:setWeaponTubeDirection(0,-45)			--front left facing (vs left)
	playerHalberd:setWeaponTubeDirection(1, 45)			--front right facing (vs left)
	playerHalberd:setWeaponTubeDirection(2,-90)			--left facing (vs right)
	playerHalberd:setWeaponTubeExclusiveFor(0,"HVLI")	--HVLI or Homing (vs all but Mine)
	playerHalberd:setWeaponTubeExclusiveFor(1,"HVLI")	--HVLI or Homing (vs all but Mine)
	playerHalberd:weaponTubeAllowMissle(0,"Homing")
	playerHalberd:weaponTubeAllowMissle(1,"Homing")
	playerHalberd:setWeaponTubeExclusiveFor(2,"Nuke")	--Nuke only (vs all but Mine)
	playerHalberd:setWeaponTubeExclusiveFor(3,"EMP")	--EMP only (vs all but Mine)
	playerHalberd:onTakingDamage(playerShipDamage)
	playerHalberd:addReputationPoints(50)
	return playerHalberd
end
function createPlayerShipHeadhunter()
	playerHeadhunter = PlayerSpaceship():setTemplate("Piranha"):setFaction("Human Navy"):setCallSign("Headhunter")
	setBeamColor(playerHeadhunter)
	playerHeadhunter:setTypeName("Redhook")
	playerHeadhunter:setRepairCrewCount(4)							--more repair crew (vs 2)
	playerHeadhunter.max_jump_range = 25000							--shorter than typical (vs 50)
	playerHeadhunter.min_jump_range = 2500							--shorter than typical (vs 5)
	playerHeadhunter:setJumpDriveRange(playerHeadhunter.min_jump_range,playerHeadhunter.max_jump_range)
	playerHeadhunter:setJumpDriveCharge(playerHeadhunter.max_jump_range)
	playerHeadhunter:setHullMax(140)								--stronger hull (vs 120)
	playerHeadhunter:setHull(140)
	playerHeadhunter:setShieldsMax(100, 100)						--stronger shields (vs 70, 70)
	playerHeadhunter:setShields(100, 100)
--                 				 	 Arc, Dir, Range, CycleTime, Dmg
	playerHeadhunter:setBeamWeapon(0, 10,   0,  1000,		4.0, 4)	--one beam (vs 0)
--									    	Arc, Dir, Rotate speed
	playerHeadhunter:setBeamWeaponTurret(0, 120,   0, 1)			
	playerHeadhunter:setWeaponTubeCount(6)							--two fewer tubes, EMPS added, one front tube, 2 broadsides: medium and large, rear mine tube
	playerHeadhunter:setWeaponTubeDirection(0,   0):setTubeSize(0,"small" ):setTubeLoadTime(0, 6):setWeaponTubeExclusiveFor(0,"HVLI")
	playerHeadhunter:setWeaponTubeDirection(1, -90):setTubeSize(1,"medium"):setTubeLoadTime(1, 8):setWeaponTubeExclusiveFor(1,"HVLI"):weaponTubeAllowMissle(1,"Homing"):weaponTubeAllowMissle(1,"EMP"):weaponTubeAllowMissle(1,"Nuke")
	playerHeadhunter:setWeaponTubeDirection(2, -90):setTubeSize(2,"large" ):setTubeLoadTime(2,12):setWeaponTubeExclusiveFor(2,"HVLI")
	playerHeadhunter:setWeaponTubeDirection(3,  90):setTubeSize(3,"medium"):setTubeLoadTime(3, 8):setWeaponTubeExclusiveFor(3,"HVLI"):weaponTubeAllowMissle(3,"Homing"):weaponTubeAllowMissle(3,"EMP"):weaponTubeAllowMissle(3,"Nuke")
	playerHeadhunter:setWeaponTubeDirection(4,  90):setTubeSize(4,"large" ):setTubeLoadTime(4,12):setWeaponTubeExclusiveFor(4,"HVLI")
	playerHeadhunter:setWeaponTubeDirection(5, 180):setTubeSize(5,"medium"):setTubeLoadTime(5,10):setWeaponTubeExclusiveFor(5,"Mine")
	playerHeadhunter:setWeaponStorageMax("Mine",6)					--fewer mines (vs 8)
	playerHeadhunter:setWeaponStorage(   "Mine",6)				
	playerHeadhunter:setWeaponStorageMax("EMP", 4)					--more EMPs (vs 0)
	playerHeadhunter:setWeaponStorage(   "EMP", 4)					
	playerHeadhunter:setWeaponStorageMax("Nuke",4)					--fewer Nukes (vs 6)
	playerHeadhunter:setWeaponStorage(   "Nuke",4)				
	playerHeadhunter:onTakingDamage(playerShipDamage)
	playerHeadhunter:addReputationPoints(50)
	return playerHeadhunter
end
function createPlayerShipHearken()
	playerHearken = PlayerSpaceship():setTemplate("Piranha"):setFaction("Human Navy"):setCallSign("Hearken")
	setBeamColor(playerHearken)
	playerHearken:setTypeName("Redhook")
	playerHearken:setImpulseMaxSpeed(70,85)					--faster impulse max (vs 60)
	playerHearken:setRepairCrewCount(5)						--more repair crew (vs 2)
	playerHearken.max_jump_range = 30000					--shorter than typical (vs 50)
	playerHearken.min_jump_range = 3000						--shorter than typical (vs 5)
	playerHearken:setJumpDriveRange(playerHearken.min_jump_range,playerHearken.max_jump_range)
	playerHearken:setJumpDriveCharge(playerHearken.max_jump_range)
	playerHearken:setHullMax(180)							--stronger hull (vs 120)
	playerHearken:setHull(180)
	playerHearken:setShieldsMax(120, 120)					--stronger shields (vs 70, 70)
	playerHearken:setShields(120, 120)
--                 				  Arc,Dir,	Range, CycleTime, Dmg
	playerHearken:setBeamWeapon(0, 10,	0,	 1000,		 4.0, 4.5)	--one beam (vs 0)
--										Arc,  Dir, Rotate speed
	playerHearken:setBeamWeaponTurret(0, 80,	0, .5)				--slow turret 
	playerHearken:setWeaponTubeCount(7)						--one fewer mine tube, but EMPs added
	playerHearken:setWeaponTubeDirection(6, 180)			--mine tube points straight back
	playerHearken:setWeaponTubeExclusiveFor(0,"HVLI")
	playerHearken:setWeaponTubeExclusiveFor(1,"HVLI")
	playerHearken:setWeaponTubeExclusiveFor(2,"HVLI")
	playerHearken:setWeaponTubeExclusiveFor(3,"HVLI")
	playerHearken:setWeaponTubeExclusiveFor(4,"HVLI")
	playerHearken:setWeaponTubeExclusiveFor(5,"HVLI")
	playerHearken:setWeaponTubeExclusiveFor(6,"Mine")
	playerHearken:weaponTubeAllowMissle(0,"Homing")
	playerHearken:weaponTubeAllowMissle(3,"Homing")
	playerHearken:weaponTubeAllowMissle(1,"EMP")
	playerHearken:weaponTubeAllowMissle(4,"EMP")
	playerHearken:setWeaponStorageMax("EMP",4)				--more EMPs (vs 0)
	playerHearken:setWeaponStorage("EMP", 4)					
	playerHearken:setWeaponStorageMax("Nuke",0)				--fewer Nukes (vs 6)
	playerHearken:setWeaponStorage("Nuke", 0)				
	playerHearken:setSystemCoolantRate("reactor",		1.15)	--less (vs 1.2)
	playerHearken:setSystemCoolantRate("jumpdrive",		1.3)	--more (vs 1.2)
	playerHearken:setSystemCoolantRate("beamweapons",	0.95)	--less (vs 1.2)
	playerHearken:setSystemCoolantRate("maneuver",		1.2)	--same (vs 1.2)
	playerHearken:setSystemCoolantRate("impulse",		1.2)	--same (vs 1.2)
	playerHearken:setSystemCoolantRate("frontshield",	1.2)	--same (vs 1.2)
	playerHearken:setSystemCoolantRate("rearshield",	1.05)	--less (vs 1.2)
	playerHearken:setSystemCoolantRate("missilesystem",	1.05)	--less (vs 1.2)
	playerHearken:setSystemPowerRate("reactor",			0.375)	--more (vs 0.30)
	playerHearken:setSystemPowerRate("beamweapons",		0.275)	--less (vs 0.30)
	playerHearken:setSystemPowerRate("jumpdrive",		0.35)	--more (vs 0.30)
	playerHearken:setSystemPowerRate("maneuver",		0.3)	--same (vs 0.30)
	playerHearken:setSystemPowerRate("impulse",			0.4)	--more (vs 0.30)
	playerHearken:setSystemPowerRate("frontshield",		0.35)	--more (vs 0.30)
	playerHearken:setSystemPowerRate("rearshield",		0.225)	--less (vs 0.30)	
	playerHearken:setSystemPowerRate("missilesystem",	0.225)	--less (vs 0.30)	
	playerHearken:onTakingDamage(playerShipDamage)
	playerHearken:addReputationPoints(50)
	return playerHearken
end
function createPlayerShipHrothgar()
	local base_template = "Nautilus"
	local hot_template = "Nusret"
	playerNusret = PlayerSpaceship():setTemplate(base_template):setFaction("Human Navy"):setCallSign("Beowulf")
	local ship = playerNusret
	setBeamColor(ship)
	ship.combat_maneuver_boost = stock_combat_maneuver[base_template].boost
	ship.combat_maneuver_strafe = stock_combat_maneuver[base_template].strafe
	ship.beam_damage_type = stock_beam_damage_type[base_template]
	ship.tube_direction = {-60,60,180}
	ship.tube_ordnance = {"Homing","Homing","Mine"}
	ship:setTypeName(hot_template)
	ship:setHullMax(150)						--stronger hull (vs 100)
	ship:setHull(150)
	ship:setShieldsMax(100, 100)				--stronger shields (vs 60, 60)
	ship:setShields(100, 100)
	ship:setRepairCrewCount(6)					--more repair crew (vs 4)
	ship.max_jump_range = 25000					--shorter than typical (vs 50)
	ship.min_jump_range = 2500						--shorter than typical (vs 5)
	ship:setJumpDriveRange(ship.min_jump_range,ship.max_jump_range)
	ship:setJumpDriveCharge(ship.max_jump_range)
--                 		  Arc, Dir, Range, CycleTime, Damage
	ship:setBeamWeapon(0,  10, -35,	1000, 		6.0, 	6.0)	
	ship:setBeamWeapon(1,  10,  35,	1000, 		6.0,    6.0)	
	ship:setBeamWeapon(2,  40,	 0,	 500,		8.0,	9.0)	--additional short, slow, stronger beam
--								Arc,  Dir, Rotate speed
	ship:setBeamWeaponTurret(0,	 90,  -35,			 .4)		--slow turret
	ship:setBeamWeaponTurret(1,	 90,   35,			 .4)
	ship:setTubeLoadTime(2,8)					--faster (vs 10)
	ship:setWeaponTubeDirection(0,-60)			--front left facing (vs back)
	ship:setWeaponTubeDirection(1, 60)			--front right facing (vs back)
	ship:setWeaponTubeExclusiveFor(0,"Homing")	--Homing only (vs Mine)
	ship:setWeaponTubeExclusiveFor(1,"Homing")	--Homing only (vs Mine)
	ship:setWeaponStorageMax("Homing",8)		--more homing (vs 0)
	ship:setWeaponStorage("Homing", 8)				
	ship:setWeaponStorageMax("Mine",8)			--fewer mines (vs 12)
	ship:setWeaponStorage("Mine", 8)				
	ship:setSystemCoolantRate("reactor",		1.25)	--more (vs 1.2)
	ship:setSystemCoolantRate("jumpdrive",		1.15)	--less (vs 1.2)
	ship:setSystemCoolantRate("beamweapons",	1.25)	--more (vs 1.2)
	ship:setSystemCoolantRate("maneuver",		1.2)	--same (vs 1.2)
	ship:setSystemCoolantRate("impulse",		0.9)	--less (vs 1.2)
	ship:setSystemCoolantRate("frontshield",	0.95)	--less (vs 1.2)
	ship:setSystemCoolantRate("rearshield",		0.95)	--less (vs 1.2)
	ship:setSystemCoolantRate("missilesystem",	1.2)	--same (vs 1.2)
	ship:setSystemPowerRate("reactor",			0.4)	--more (vs 0.30)
	ship:setSystemPowerRate("beamweapons",		0.35)	--more (vs 0.30)
	ship:setSystemPowerRate("jumpdrive",		0.35)	--more (vs 0.30)
	ship:setSystemPowerRate("maneuver",			0.325)	--more (vs 0.30)
	ship:setSystemPowerRate("impulse",			0.275)	--less (vs 0.30)
	ship:setSystemPowerRate("frontshield",		0.3)	--same (vs 0.30)
	ship:setSystemPowerRate("rearshield",		0.3)	--same (vs 0.30)	
	ship:setSystemPowerRate("missilesystem",	0.375)	--more (vs 0.30)	
	createShipReference(ship)
	ship.ship_reference["Diff Sum"] = {ord = 2, desc = "Nusret is based on Nautilus\nDifferences: more repair crew, stronger hull (vs 100), shorter jump drive range (vs 50), stronger shields (vs 60/60), turreted beams (vs fix mount), additional short, strong beam, realign 1st two tubes from rear to 60/-60 and speed up their load times and let them shoot homing missiles, decrease mines and increase homing missiles, varying speeds of coolant and power deployment per system (vs fixed)."}
	addShipReference(ship)
	ship:onTakingDamage(playerShipDamage)
	ship:addReputationPoints(50)
	return ship
end
function createPlayerShipHummer()
	playerHummer = PlayerSpaceship():setTemplate("ZX-Lindworm"):setFaction("Human Navy"):setCallSign("Hummer")
	setBeamColor(playerHummer)
	playerHummer:setTypeName("XR-Lindworm")
	playerHummer:setRepairCrewCount(3)			--more repair crew (vs 1)
	playerHummer:setWarpDrive(true)				--warp drive (vs none)
	playerHummer:setWarpSpeed(320)
	playerHummer:setShieldsMax(100,30)			--stronger front, weaker rear (vs 40)
	playerHummer:setShields(100,30)
	playerHummer:setHullMax(120)				--stronger (vs 75)
	playerHummer:setHull(120)							
	playerHummer:setWeaponTubeCount(6)			--more (vs 3)
	playerHummer:setWeaponTubeExclusiveFor(0,"HVLI")
	playerHummer:setWeaponTubeExclusiveFor(3,"EMP")
	playerHummer:setWeaponTubeExclusiveFor(4,"EMP")
	playerHummer:setWeaponTubeExclusiveFor(5,"Mine")
	playerHummer:setWeaponTubeDirection(1,3)	--angled (vs 1)
	playerHummer:setWeaponTubeDirection(2,-3)	--angled (vs -1)
	playerHummer:setWeaponTubeDirection(3,-90)
	playerHummer:setWeaponTubeDirection(4,90)
	playerHummer:setWeaponTubeDirection(5,180)
	playerHummer:weaponTubeAllowMissle(1,"Homing")
	playerHummer:weaponTubeAllowMissle(2,"Homing")
	playerHummer:weaponTubeAllowMissle(3,"Nuke")
	playerHummer:weaponTubeAllowMissle(4,"Nuke")
	playerHummer:setWeaponStorageMax("Homing",8)--more (vs 3)
	playerHummer:setWeaponStorage("Homing", 8)				
	playerHummer:setWeaponStorageMax("Nuke",2)	--more Nukes (vs 0)
	playerHummer:setWeaponStorage("Nuke", 2)				
	playerHummer:setWeaponStorageMax("EMP",3)	--more EMPs (vs 0)
	playerHummer:setWeaponStorage("EMP", 3)
	playerHummer:setWeaponStorageMax("Mine",2)	--more (vs 0)
	playerHummer:setWeaponStorage("Mine", 2)
	playerHummer:setTubeLoadTime(3,15)
	playerHummer:setTubeLoadTime(4,15)
	playerHummer:setTubeLoadTime(5,25)
--	playerHummer:setSystemHeatRate("reactor",		.5)	--more (vs .05) Lingling	
	playerHummer:onTakingDamage(playerShipDamage)
	playerHummer:addReputationPoints(50)
	return playerHummer
end
function createPlayerShipInk()
	playerInk = PlayerSpaceship():setTemplate("Piranha"):setFaction("Human Navy"):setCallSign("Ink")
	setBeamColor(playerInk)
	playerInk:setTypeName("Squid")
	playerInk:setRepairCrewCount(5)					--more repair crew (vs 2)
	playerInk:setShieldsMax(100, 100)				--stronger shields (vs 70, 70)
	playerInk:setShields(100, 100)
	playerInk:setHullMax(130)						--stronger (vs 120)
	playerInk:setHull(130)							
	playerInk.max_jump_range = 20000				--shorter than typical (vs 50)
	playerInk.min_jump_range = 2000					--shorter than typical (vs 5)
	playerInk:setJumpDriveRange(playerInk.min_jump_range,playerInk.max_jump_range)
	playerInk:setJumpDriveCharge(playerInk.max_jump_range)
--                 				 Arc, Dir, Range, CycleTime, Damage
	playerInk:setBeamWeapon(0, 10,	0,	1000,		4,		4)		--one beam (vs 0)
--									   Arc,	  Dir, Rotate speed
	playerInk:setBeamWeaponTurret(0,	80,		0,		1)			--slow turret 
	playerInk:setWeaponTubeDirection(0,0)					--forward facing (vs left)
	playerInk:setWeaponTubeDirection(3,0)					--forward facing (vs right)
	playerInk:setTubeLoadTime(0,12)							--slower (vs 8)
	playerInk:setTubeLoadTime(3,12)							--slower (vs 8)
	playerInk:setWeaponTubeExclusiveFor(2,"Homing")			--homing only (vs HVLI)
	playerInk:setWeaponTubeExclusiveFor(5,"Homing")			--homing only (vs HVLI)
	playerInk:setTubeLoadTime(2,10)							--slower (vs 8)
	playerInk:setTubeLoadTime(5,10)							--slower (vs 8)
	playerInk:setTubeLoadTime(6,15)							--slower (vs 8)
	playerInk:setTubeLoadTime(7,15)							--slower (vs 8)
	playerInk:setWeaponTubeExclusiveFor(0,"HVLI")			--HVLI only (vs Homing + HVLI)
	playerInk:setWeaponTubeExclusiveFor(3,"HVLI")			--HVLI only (vs Homing + HVLI)
	playerInk:weaponTubeDisallowMissle(1,"Mine")			--no sideways mines
	playerInk:weaponTubeDisallowMissle(4,"Mine")			--no sideways mines
	playerInk:setWeaponStorageMax("HVLI",10)				--fewer HVLI (vs 20)
	playerInk:setWeaponStorage("HVLI", 10)				
	playerInk:setWeaponStorageMax("Homing",10)				--fewer Homing (vs 12)
	playerInk:setWeaponStorage("Homing", 10)				
	playerInk:setWeaponStorageMax("Mine",6)					--fewer mines (vs 8)
	playerInk:setWeaponStorage("Mine", 6)				
	playerInk:setWeaponStorageMax("EMP",4)					--more EMPs (vs 0)
	playerInk:setWeaponStorage("EMP", 4)					
	playerInk:setWeaponStorageMax("Nuke",4)					--fewer Nukes (vs 6)
	playerInk:setWeaponStorage("Nuke", 4)				
	playerInk:setLongRangeRadarRange(25000)					--shorter long range sensors (vs 30000)
	playerInk.normal_long_range_radar = 25000
--	playerInk:setSystemHeatRate("reactor",		.5)	--more (vs .05) Lingling	
	playerInk:onTakingDamage(playerShipDamage)
	playerInk:addReputationPoints(50)
	return playerInk
end
function createPlayerShipJarvis()
	playerJarvis = PlayerSpaceship():setTemplate("Crucible"):setFaction("Human Navy"):setCallSign("Jarvis")
	setBeamColor(playerJarvis)
	playerJarvis:setTypeName("Butler")
	playerJarvis:setImpulseMaxSpeed(70)						--slower impulse max (vs 80)
	playerJarvis:setWarpSpeed(400)							--slower (vs 750)
	playerJarvis:setHullMax(100)							--weaker hull (vs 160)
	playerJarvis:setHull(100)
	playerJarvis:setShieldsMax(100, 100)					--weaker shields (vs 160, 160)
--                  			 Arc, Dir, Range, CycleTime, Dmg
	playerJarvis:setBeamWeapon(0, 10, -60, 900.0, 		6.0,   6)	--left, right, overlap beams (vs forward)
	playerJarvis:setBeamWeapon(1, 10,  60, 900.0, 		6.0,   6)	
--										Arc, Dir, Rotate speed
	playerJarvis:setBeamWeaponTurret(0, 140, -60, .6)		--slow turret beams
	playerJarvis:setBeamWeaponTurret(1, 140,  60, .6)
	playerJarvis:setWeaponTubeCount(4)						--fewer (vs 6)
	playerJarvis:setWeaponTubeExclusiveFor(0,"Nuke")		--small sized tube nuke only (vs HVLI)
	playerJarvis:setWeaponTubeExclusiveFor(1,"EMP")			--normal sized tube EMP only (vs HVLI)
	playerJarvis:setWeaponTubeExclusiveFor(3,"Homing")		--homing only
	playerJarvis:setWeaponTubeDirection(3, 180)				--on rear tube
	playerJarvis:setWeaponStorageMax("Homing",4)			--fewer (vs 8)
	playerJarvis:setWeaponStorage("Homing", 4)				
	playerJarvis:setWeaponStorageMax("EMP",4)				--fewer (vs 6)
	playerJarvis:setWeaponStorage("EMP", 4)				
	playerJarvis:setWeaponStorageMax("Nuke",3)				--fewer (vs 4)
	playerJarvis:setWeaponStorage("Nuke", 3)				
	playerJarvis:setWeaponStorageMax("Mine",0)				--fewer (vs 6)
	playerJarvis:setWeaponStorage("Mine", 0)				
	playerJarvis:setSystemCoolantRate("reactor",		1.35)	--more (vs 1.2)
	playerJarvis:setSystemCoolantRate("warp",			1.25)	--more (vs 1.2)
	playerJarvis:setSystemCoolantRate("beamweapons",	1.1)	--less (vs 1.2)
	playerJarvis:setSystemCoolantRate("maneuver",		1.05)	--less (vs 1.2)
	playerJarvis:setSystemCoolantRate("impulse",		0.75)	--less (vs 1.2)
	playerJarvis:setSystemCoolantRate("frontshield",	1.15)	--less (vs 1.2)
	playerJarvis:setSystemCoolantRate("rearshield",		1.4)	--more (vs 1.2)
	playerJarvis:setSystemCoolantRate("missilesystem",	0.8)	--less (vs 1.2)
	playerJarvis:setSystemPowerRate("reactor",			0.40)	--more (vs 0.30)
	playerJarvis:setSystemPowerRate("beamweapons",		0.325)	--more (vs 0.30)
	playerJarvis:setSystemPowerRate("warp",				0.35)	--more (vs 0.30)
	playerJarvis:setSystemPowerRate("maneuver",			0.275)	--less (vs 0.30)
	playerJarvis:setSystemPowerRate("impulse",			0.075)	--less (vs 0.30)
	playerJarvis:setSystemPowerRate("frontshield",		0.25)	--less (vs 0.30)
	playerJarvis:setSystemPowerRate("rearshield",		0.375)	--more (vs 0.30)	
	playerJarvis:setSystemPowerRate("missilesystem",	0.075)	--less (vs 0.30)	
	playerJarvis:onTakingDamage(playerShipDamage)
	playerJarvis:addReputationPoints(50)
	return playerJarvis
end
function createPlayerShipJeeves()
	local base_template = "Crucible"
	local hot_template = "Butler"
	playerJeeves = PlayerSpaceship():setTemplate(base_template):setFaction("Human Navy"):setCallSign("Jeeves")
	local ship = playerJeeves
	setBeamColor(ship)
	ship.combat_maneuver_boost = stock_combat_maneuver[base_template].boost
	ship.combat_maneuver_strafe = stock_combat_maneuver[base_template].strafe
	ship.beam_damage_type = stock_beam_damage_type[base_template]
	ship.tube_direction = {0,0,0,180}
	ship.tube_ordnance = {"HVLI","Nuke,EMP","Homing","Mine"}
	ship:setTypeName(hot_template)
	ship:setWarpSpeed(400)							--slower (vs 750)
	ship:setHullMax(100)							--weaker hull (vs 160)
	ship:setHull(100)
	ship:setShieldsMax(100, 100)					--weaker shields (vs 160, 160)
--                  	 Arc, Dir, Range, CycleTime, Dmg
	ship:setBeamWeapon(0, 80, -90, 900.0, 		6.0,   6)	--side beams (vs forward)
	ship:setBeamWeapon(1, 80,  90, 900.0, 		6.0,   6)	
	ship:setWeaponTubeCount(4)						--fewer (vs 6)
	ship:setWeaponTubeExclusiveFor(1,"EMP")			--normal sized tube allow EMPs and Nukes (vs HVLI)
	ship:weaponTubeAllowMissle(1,"Nuke")
	ship:setWeaponTubeExclusiveFor(2,"Homing")		--large tube for homing (vs HVLI)
	ship:setWeaponTubeExclusiveFor(3,"Mine")
	ship:setWeaponTubeDirection(3, 180)
	ship:setWeaponStorageMax("Homing",6)			--fewer (vs 8)
	ship:setWeaponStorage("Homing", 6)				
	ship:setWeaponStorageMax("EMP",3)				--fewer (vs 6)
	ship:setWeaponStorage("EMP", 3)				
	ship:setWeaponStorageMax("Nuke",2)				--fewer (vs 4)
	ship:setWeaponStorage("Nuke", 2)				
	ship:setWeaponStorageMax("Mine",3)				--fewer (vs 6)
	ship:setWeaponStorage("Mine", 3)		
	createShipReference(ship)
	ship.ship_reference["Diff Sum"] = {ord = 2, desc = "Butler is based on Crucible\nDifferences: Slower warp speed (vs 750), weaker hull (vs 160), weaker shields (vs 160), broadside beams (vs forward), fewer tubes (vs 6), no broadside tubes, different missile types for forward facing tubes, different missiles (vs Homing:8   Nuke:4   Mine:6   EMP:6), tractor beam."}
	addShipReference(ship)
	ship:onTakingDamage(playerShipDamage)
	ship:addReputationPoints(50)
	return ship
end
function createPlayerShipKindling()
	playerKindling = PlayerSpaceship():setTemplate("Player Cruiser"):setFaction("Human Navy"):setCallSign("Kindling")
	setBeamColor(playerKindling)
	playerKindling:setTypeName("Phoenix")
	playerKindling.max_jump_range = 28000					--shorter than typical (vs 50)
	playerKindling.min_jump_range = 3000					--shorter than typical (vs 5)
	playerKindling:setJumpDriveRange(playerKindling.min_jump_range,playerKindling.max_jump_range)
	playerKindling:setJumpDriveCharge(playerKindling.max_jump_range)
	playerKindling:setShieldsMax(130, 95)					--stronger shields (vs 80, 80)
	playerKindling:setShields(130, 95)
	playerKindling:setHullMax(100)							--weaker hull (vs 200)
	playerKindling:setHull(100)
	playerKindling:setWeaponTubeDirection(0,-90)			--left -60 (vs -5)
	playerKindling:setWeaponTubeDirection(1, 90)			--right 60 (vs 5)
	playerKindling:setWeaponStorageMax("Homing",6)			--less (vs 12)
	playerKindling:setWeaponStorage("Homing", 6)				
	playerKindling:setWeaponStorageMax("Nuke",1)			--fewer (vs 4)
	playerKindling:setWeaponStorage("Nuke", 1)				
	playerKindling:setWeaponStorageMax("EMP",1)				--fewer (vs 6)
	playerKindling:setWeaponStorage("EMP", 1)				
	playerKindling:setWeaponStorageMax("Mine",2)			--fewer (vs 8)
	playerKindling:setWeaponStorage("Mine", 2)				
	playerKindling:setWeaponStorageMax("HVLI",10)			--more (vs 0)
	playerKindling:setWeaponStorage("HVLI", 10)				
	playerKindling:setLongRangeRadarRange(25000)
	playerKindling.normal_long_range_radar = 25000
	playerKindling:onTakingDamage(playerShipDamage)
	playerKindling:addReputationPoints(50)
	local update_data = {
		update = function (self, obj, delta)
				-- in a small sign of mercy to players they get their best beams at 90% max heat rather than burning hotel
				-- it would be kind of cool to give extra damage or something, but given how long ships last this probably wont be seen
				local heat=extraMath.clamp(obj:getSystemHeat("beamweapons"),0,0.90)
				heat=heat/0.90 -- scale to that 0.90 = 1
				obj:setBeamWeapon(0, extraMath.lerp(120,15,heat), extraMath.lerp(-90,5,heat), extraMath.lerp(500,1250,heat), 6, 8)
				obj:setBeamWeapon(1, extraMath.lerp(120,15,heat), extraMath.lerp(90,-5,heat), extraMath.lerp(500,1250,heat), 6, 8)
			end
	}
	update_system:addUpdate(playerKindling,"dynamic kindling beams",update_data)
	return playerKindling
end
function createPlayerShipKnick()
	playerKnick = PlayerSpaceship():setTemplate("ZX-Lindworm"):setFaction("Human Navy"):setCallSign("Knick")
	setBeamColor(playerKnick)
	playerKnick:setTypeName("Glass Cannon")
	playerKnick:setTubeSize(0, "large")
	playerKnick:setTubeSize(1, "large")
	playerKnick:setTubeSize(2, "large")
	playerKnick:onTakingDamage(playerShipDamage)
	playerKnick:addReputationPoints(50)
	return playerKnick
end
function createPlayerShipLancelot()
	playerLancelot = PlayerSpaceship():setTemplate("Player Cruiser"):setFaction("Human Navy"):setCallSign("Lancelot")
	setBeamColor(playerLancelot)
	playerLancelot:setTypeName("Noble")
	playerLancelot:setRepairCrewCount(5)					--more repair crew (vs 3)
	playerLancelot:setMaxEnergy(800)						--less maximum energy (vs 1000)
	playerLancelot:setEnergy(800)							
	playerLancelot:setShieldsMax(150, 80)					--stronger front shield (vs 80, 80)
	playerLancelot:setShields(150, 80)
	playerLancelot.max_jump_range = 30000					--shorter than typical (vs 50)
	playerLancelot.min_jump_range = 3000					--shorter than typical (vs 5)
	playerLancelot:setJumpDriveRange(playerLancelot.min_jump_range,playerLancelot.max_jump_range)
	playerLancelot:setJumpDriveCharge(playerLancelot.max_jump_range)
--                 				   Arc, Dir, Range, CycleTime, Dmg
	playerLancelot:setBeamWeapon(0, 60, -30,  1000,         6, 8)	--4 beams (vs 2)
	playerLancelot:setBeamWeapon(1, 60,  30,  1000,         6, 8)	--weaker (vs 10 dmg)
	playerLancelot:setBeamWeapon(2, 30, -10,  1000,         6, 8)	
	playerLancelot:setBeamWeapon(3, 30,  10,  1000,         6, 8)	--narrower (vs 90 degrees)
	playerLancelot:setBeamWeaponEnergyPerFire(0,playerLancelot:getBeamWeaponEnergyPerFire(0)*3)
	playerLancelot:setBeamWeaponHeatPerFire(0,playerLancelot:getBeamWeaponHeatPerFire(0)*3)
	playerLancelot:setBeamWeaponEnergyPerFire(1,playerLancelot:getBeamWeaponEnergyPerFire(1)*3)
	playerLancelot:setBeamWeaponHeatPerFire(1,playerLancelot:getBeamWeaponHeatPerFire(1)*3)
	playerLancelot:setBeamWeaponEnergyPerFire(2,playerLancelot:getBeamWeaponEnergyPerFire(2)*3)
	playerLancelot:setBeamWeaponHeatPerFire(2,playerLancelot:getBeamWeaponHeatPerFire(2)*3)
	playerLancelot:setBeamWeaponEnergyPerFire(3,playerLancelot:getBeamWeaponEnergyPerFire(3)*3)
	playerLancelot:setBeamWeaponHeatPerFire(3,playerLancelot:getBeamWeaponHeatPerFire(3)*3)
	playerLancelot:setWeaponTubeCount(5)					--more (vs 3)
	playerLancelot:setWeaponTubeDirection(0,-3)				--1st tube points less left (vs -5)
	playerLancelot:setWeaponTubeDirection(1, 3)				--2nd tube points less right (vs 5)
	playerLancelot:setWeaponTubeDirection(2,-90)			--3rd tube points left (vs rear)
	playerLancelot:setWeaponTubeDirection(3, 90)			--4th tube points right (vs none)
	playerLancelot:setWeaponTubeDirection(4,180)			--5th tube points to the rear (vs none)
	playerLancelot:setTubeSize(0,"small")					--left front HVLI tube smaller
	playerLancelot:setTubeSize(2,"large")					--left broadside larger
	playerLancelot:setTubeLoadTime(0,6)						--left front HVLI tube faster
	playerLancelot:setTubeLoadTime(2,20)					--left broadside slower
	playerLancelot:setTubeLoadTime(4,15)					--rear mining tube slower
	playerLancelot:setWeaponTubeExclusiveFor(0,"HVLI")		--only HVLI
	playerLancelot:setWeaponTubeExclusiveFor(1,"HVLI")		--only HVLI
	playerLancelot:setWeaponTubeExclusiveFor(2,"Homing")	--only Homing, Nuke, EMP
	playerLancelot:weaponTubeAllowMissle(2,"Nuke")
	playerLancelot:weaponTubeAllowMissle(2,"EMP")
	playerLancelot:setWeaponTubeExclusiveFor(3,"Homing")	--only Homing, Nuke, EMP
	playerLancelot:weaponTubeAllowMissle(3,"Nuke")
	playerLancelot:weaponTubeAllowMissle(3,"EMP")
	playerLancelot:setWeaponTubeExclusiveFor(4,"Mine")		--only mine
	playerLancelot:setWeaponStorageMax("HVLI", 8)			--more (vs 0)
	playerLancelot:setWeaponStorage("HVLI", 8)				
	playerLancelot:setCombatManeuver(250,200)				--less (vs 400,250)
	playerLancelot:onTakingDamage(playerShipDamage)
	playerLancelot:addReputationPoints(50)
	return playerLancelot
end
function createPlayerShipMagnum()
	local base_template = "Crucible"
	local hot_template = "Focus"
	playerMagnum = PlayerSpaceship():setTemplate(base_template):setFaction("Human Navy"):setCallSign("Magnum")
	local ship = playerMagnum
	setBeamColor(ship)
	ship.combat_maneuver_boost = stock_combat_maneuver[base_template].boost
	ship.combat_maneuver_strafe = stock_combat_maneuver[base_template].strafe
	ship.beam_damage_type = stock_beam_damage_type[base_template]
	ship.tube_direction = {0,0,180}
	ship.tube_ordnance = {"HVLI","HVLI","all but Mine","Mine"}
	ship:setTypeName(hot_template)
	ship:setImpulseMaxSpeed(70)						--slower (vs 80)
	ship:setRotationMaxSpeed(20)					--faster spin (vs 15)
	ship:setWarpDrive(false)						--no warp
	ship:setJumpDrive(true)							--jump drive
	ship.max_jump_range = 25000					--shorter than typical (vs 50)
	ship.min_jump_range = 2500						--shorter than typical (vs 5)
	ship:setJumpDriveRange(ship.min_jump_range,ship.max_jump_range)
	ship:setJumpDriveCharge(ship.max_jump_range)
	ship:setHullMax(120)							--weaker hull (vs 160)
	ship:setHull(120)
	ship:setShieldsMax(120, 120)					--weaker shields (vs 160, 160)
	ship:setShields(120, 120)
	ship:setBeamWeapon(0, 60, -20, 1000.0, 6.0, 5)	--narrower (vs 70)
	ship:setBeamWeapon(1, 60,  20, 1000.0, 6.0, 5)	
	ship:setWeaponTubeCount(4)						--fewer (vs 6)
	ship:weaponTubeAllowMissle(2,"Homing")
	ship:weaponTubeAllowMissle(2,"EMP")
	ship:weaponTubeAllowMissle(2,"Nuke")
	ship:setWeaponTubeExclusiveFor(3,"Mine")
	ship:setWeaponTubeDirection(3, 180)
	ship:setWeaponStorageMax("EMP",2)				--fewer (vs 6)
	ship:setWeaponStorage("EMP", 2)				
	ship:setWeaponStorageMax("Nuke",2)				--fewer (vs 4)
	ship:setWeaponStorage("Nuke", 2)	
	ship.turbo_torpedo_type = {"Nuke","HomingMissile"}
	ship.turbo_torp_factor = 3
	ship.turbo_torp_charge_interval = 90
	createShipReference(ship)
	ship.ship_reference["Diff Sum"] = {ord = 2, desc = "Focus is based on Crucible\nDifferences: slower impulse (vs 80), faster spin (vs 15), jump instead of warp, weaker hull (vs 160), weaker shields (vs 160), narrower beams (vs 70), fewer tubes (vs 6), no broadsides, large tube shoots Homing, Nuke, EMP, and HVLI, fewer Nukes (vs 4) and EMPs (vs 6), turbo torpedo, mining"}
	addShipReference(ship)
	ship:onTakingDamage(playerShipDamage)
	ship:addReputationPoints(50)
	return ship
end
function createPlayerShipMixer()
	playerAmalgam = PlayerSpaceship():setTemplate("Atlantis"):setFaction("Human Navy"):setCallSign("Mixer")
	setBeamColor(playerAmalgam)
	playerAmalgam:setTypeName("Amalgam")
	playerAmalgam:setRepairCrewCount(5)					--more repair crew (vs 3)
	playerAmalgam.max_jump_range = 40000				--shorter (vs 50)
	playerAmalgam.min_jump_range = 4000					--shorter (vs 5)
	playerAmalgam:setJumpDriveRange(playerAmalgam.min_jump_range,playerAmalgam.max_jump_range)
	playerAmalgam:setJumpDriveCharge(playerAmalgam.max_jump_range)
	playerAmalgam:setImpulseMaxSpeed(80)				--slower (vs 90)
	playerAmalgam:setRotationMaxSpeed(8)				--slower (vs 10)
	playerAmalgam:setShieldsMax(150,150)				--weaker shields (vs 200)
	playerAmalgam:setShields(150,150)
--								  Arc, Dir, Range, CycleTime, Dmg
	playerAmalgam:setBeamWeapon(0, 90, -20,  1200,         6, 8)	--narrower (vs 100), shorter (vs 1500)
	playerAmalgam:setBeamWeapon(1, 90,  20,  1200,         6, 8)	--narrower (vs 100), shorter (vs 1500)
	playerAmalgam:setBeamWeapon(2, 10, -60,  1000,         4, 6)	--additional beam
	playerAmalgam:setBeamWeapon(3, 10,  60,  1000,         4, 6)	--additional beam
--											Arc,  Dir, Rotate speed
	playerAmalgam:setBeamWeaponTurret(2,	 60,  -60,			.6)
	playerAmalgam:setBeamWeaponTurret(3,	 60,   60,			.6)
	playerAmalgam:setWeaponTubeCount(4)					--2 fewer broadside, 1 extra mine (vs 5)
	playerAmalgam:setWeaponTubeDirection(1, 90)			--mine tube points right (vs left)
	playerAmalgam:setWeaponTubeDirection(2, 180)		--mine tube points back (vs right)
	playerAmalgam:setWeaponTubeDirection(3, 180)		--mine tube points back (vs right)
	playerAmalgam:setWeaponTubeExclusiveFor(0,"Homing")	--homing only (vs any)
	playerAmalgam:setWeaponTubeExclusiveFor(1,"Homing")	--homing only (vs any)
	playerAmalgam:setWeaponTubeExclusiveFor(2,"Mine")	--mine only (vs any)
	playerAmalgam:setWeaponTubeExclusiveFor(3,"Mine")	--mine only (vs any)
	playerAmalgam:setTubeLoadTime(2,16)					--rear tube slower (vs 8)
	playerAmalgam:setTubeLoadTime(3,16)					--rear tube slower (vs 8)
	playerAmalgam:setTubeSize(0,"large")				--left tube large (vs normal)
	playerAmalgam:setTubeSize(1,"large")				--right tube large (vs normal)
	playerAmalgam:setWeaponStorageMax("Homing", 16)		--more (vs 12)
	playerAmalgam:setWeaponStorage("Homing", 16)				
	playerAmalgam:setWeaponStorageMax("Nuke", 0)		--less (vs 4)
	playerAmalgam:setWeaponStorage("Nuke", 0)				
	playerAmalgam:setWeaponStorageMax("Mine", 10)		--more (vs 8)
	playerAmalgam:setWeaponStorage("Mine", 10)				
	playerAmalgam:setWeaponStorageMax("EMP", 0)			--less (vs 6)
	playerAmalgam:setWeaponStorage("EMP", 0)				
	playerAmalgam:setWeaponStorageMax("HVLI", 0)		--less (vs 20)
	playerAmalgam:setWeaponStorage("HVLI", 0)
--	playerAmalgam:setSystemHeatRate("reactor",		.5)	--more (vs .05) Lingling	
	playerAmalgam:onTakingDamage(playerShipDamage)
	playerAmalgam:addReputationPoints(50)
	return playerAmalgam
end
function createPlayerShipManxman()
	playerManxman = PlayerSpaceship():setTemplate("Nautilus"):setFaction("Human Navy"):setCallSign("Manxman")
	setBeamColor(playerManxman)
	playerManxman:setTypeName("Nusret")
	playerManxman.max_jump_range = 30000				--shorter than typical (vs 50)
	playerManxman.min_jump_range = 3000					--shorter than typical (vs 5)
	playerManxman:setJumpDriveRange(playerManxman.min_jump_range,playerManxman.max_jump_range)
	playerManxman:setJumpDriveCharge(playerManxman.max_jump_range)
	playerManxman:setWeaponTubeCount(5)					--more (vs 3)
	playerManxman:setWeaponTubeDirection(0,  0)			--front (vs back)
	playerManxman:setWeaponTubeDirection(1,-90)			--left facing (vs back)
	playerManxman:setWeaponTubeDirection(2, 90)			--right facing (vs back)
	playerManxman:setWeaponTubeDirection(3,180)
	playerManxman:setWeaponTubeDirection(4,180)
	playerManxman:setTubeSize(0,"small")				--small (vs medium)
	playerManxman:setTubeSize(3,"large")
	playerManxman:setWeaponTubeExclusiveFor(0,"Homing")	--Homing only (vs Mine)
	playerManxman:setWeaponTubeExclusiveFor(1,"Homing")	--Homing only (vs Mine)
	playerManxman:setWeaponTubeExclusiveFor(2,"Homing")	--Homing only (vs Mine)
	playerManxman:setWeaponTubeExclusiveFor(3,"Homing")
	playerManxman:setWeaponTubeExclusiveFor(4,"Mine")
	playerManxman:setTubeLoadTime(0,5)					--faster (vs 10)
	playerManxman:setTubeLoadTime(3,20)					--slower (vs 10)
	playerManxman:setWeaponStorageMax("Homing",8)		--more homing (vs 0)
	playerManxman:setWeaponStorage("Homing", 8)				
	playerManxman:setWeaponStorageMax("Mine",8)			--fewer mines (vs 12)
	playerManxman:setWeaponStorage("Mine", 8)				
	playerManxman:onTakingDamage(playerShipDamage)
	playerManxman:addReputationPoints(50)
	return playerManxman
end
function createPlayerShipMortar()
	playerMortar = PlayerSpaceship():setTemplate("Player Missile Cr."):setFaction("Human Navy"):setCallSign("Grad")
	setBeamColor(playerMortar)
	playerMortar:setTypeName("Mortar")
	playerMortar:setRadarTrace("laser.png")
	playerMortar:setHullMax(160)						--weaker hull (vs 200)
	playerMortar:setHull(160)
	playerMortar:setShieldsMax(160,160)					--stronger shields (vs 110,70)
	playerMortar:setShields(160,160)
	playerMortar:setImpulseMaxSpeed(80)					--faster impulse max (vs 60)
	playerMortar:setRotationMaxSpeed(15)				--faster spin (vs 8)
	playerMortar:setAcceleration(40,40)					--faster (vs 15)
	playerMortar:setCombatManeuver(400,250)				--changed vs (450,150)
--                  			  Arc, Dir,Range, CycleTime,  Dmg
	playerMortar:setBeamWeapon(0,  60, -15,	1500,		6.0,	6):setBeamWeaponDamageType(0,"emp")
	playerMortar:setBeamWeapon(1,  60,  15,	1500,		6.0,	6):setBeamWeaponDamageType(0,"emp")
	playerMortar:setBeamWeapon(2,  60, -15,	1000,		6.0,	6):setBeamWeaponDamageType(0,"kinetic")
	playerMortar:setBeamWeapon(3,  60,  15,	1000,		6.0,	6):setBeamWeaponDamageType(0,"kinetic")
	playerMortar:setBeamWeapon(4,  60, -15,	 500,		6.0,	6)
	playerMortar:setBeamWeapon(5,  60,  15,	 500,		6.0,	6)
	playerMortar:setWeaponTubeCount(3)					--fewer (vs 7)
	playerMortar:setWeaponTubeDirection(0, -90):setTubeSize(0,"medium"):setTubeLoadTime(0, 8):setWeaponTubeExclusiveFor(0,"HVLI"):weaponTubeAllowMissle(0,"Homing"):weaponTubeAllowMissle(0,"EMP"):weaponTubeAllowMissle(0,"Nuke")
	playerMortar:setWeaponTubeDirection(1,  90):setTubeSize(1,"medium"):setTubeLoadTime(1, 8):setWeaponTubeExclusiveFor(1,"HVLI"):weaponTubeAllowMissle(1,"Homing"):weaponTubeAllowMissle(1,"EMP"):weaponTubeAllowMissle(1,"Nuke")
	playerMortar:setWeaponTubeDirection(2, 180):setTubeSize(2,"medium"):setTubeLoadTime(2, 8):setWeaponTubeExclusiveFor(2,"Mine")
	playerMortar:setWeaponStorageMax("HVLI",	10)			--more (vs 0)
	playerMortar:setWeaponStorage(   "HVLI",	10)				
	playerMortar:setWeaponStorageMax("Homing",	6)			--fewer (vs 30)
	playerMortar:setWeaponStorage(   "Homing",	6)				
	playerMortar:setWeaponStorageMax("Mine",	2)			--fewer (vs 12)
	playerMortar:setWeaponStorage(   "Mine",	2)				
	playerMortar:setWeaponStorageMax("EMP", 	4)			--fewer (vs 10)
	playerMortar:setWeaponStorage(   "EMP", 	4)					
	playerMortar:setWeaponStorageMax("Nuke",	2)			--fewer (vs 8)
	playerMortar:setWeaponStorage(   "Nuke",	2)				
	playerMortar:onTakingDamage(playerShipDamage)
	playerMortar:addReputationPoints(50)
	return playerMortar
end
function createPlayerShipNarsil()
	--experimental
	playerNarsil = PlayerSpaceship():setTemplate("Atlantis"):setFaction("Human Navy"):setCallSign("Narsil")
	setBeamColor(playerNarsil)
	playerNarsil:setTypeName("Proto-Atlantis 2")
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
	playerNarsil:setWeaponTubeDirection(1, 90)			--right facing (vs left)
	playerNarsil:setWeaponTubeDirection(2,  0)			--front facing (vs right)
	playerNarsil:setWeaponTubeDirection(4,-90)			--left facing (vs rear)
	playerNarsil:setWeaponTubeDirection(5,180)			--rear facing
	playerNarsil:setWeaponTubeExclusiveFor(0,"HVLI")	--HVLI only (vs any)
	playerNarsil:setWeaponTubeExclusiveFor(1,"HVLI")	--HVLI only (vs any)
	playerNarsil:setWeaponTubeExclusiveFor(2,"HVLI")	--HVLI only (vs any)
	playerNarsil:setWeaponTubeExclusiveFor(4,"HVLI")	--All but mine (vs mine only)
	playerNarsil:weaponTubeAllowMissle(4,"Nuke")
	playerNarsil:weaponTubeAllowMissle(4,"Homing")
	playerNarsil:weaponTubeAllowMissle(4,"EMP")
	playerNarsil:setWeaponTubeExclusiveFor(5,"Mine")
	playerNarsil:setTubeSize(0,"large")					--left tube large (vs normal)
	playerNarsil:setTubeSize(1,"large")					--right tube large (vs normal)
	playerNarsil:setTubeLoadTime(0,12)					--slower (vs 8)
	playerNarsil:setTubeLoadTime(1,12)					--slower (vs 8)
	playerNarsil:setTubeLoadTime(5,15)					--slower (vs 8)
	playerNarsil:onTakingDamage(playerShipDamage)
	playerNarsil:addReputationPoints(50)
	return playerNarsil
end
function createPlayerShipNimbus()
	playerNimbus = PlayerSpaceship():setTemplate("Phobos M3P"):setFaction("Human Navy"):setCallSign("Nimbus")
	setBeamColor(playerNimbus)
	playerNimbus:setTypeName("Phobos T2.2")
	playerNimbus:setRepairCrewCount(5)					--more repair crew (vs 3)
	playerNimbus:setJumpDrive(true)						--jump drive (vs none)
	playerNimbus.max_jump_range = 25000					--shorter than typical (vs 50)
	playerNimbus.min_jump_range = 2000						--shorter than typical (vs 5)
	playerNimbus:setJumpDriveRange(playerNimbus.min_jump_range,playerNimbus.max_jump_range)
	playerNimbus:setJumpDriveCharge(playerNimbus.max_jump_range)
	playerNimbus:setRotationMaxSpeed(20)				--faster spin (vs 10)
--                 				 Arc, Dir, Range, CycleTime, Dmg
	playerNimbus:setBeamWeapon(0, 10, -15,  1200,         8, 6)
	playerNimbus:setBeamWeapon(1, 10,  15,  1200,         8, 6)
--									   Arc, Dir, Rotate speed
	playerNimbus:setBeamWeaponTurret(0, 90, -15, .2)	--slow turret beams
	playerNimbus:setBeamWeaponTurret(1, 90,  15, .2)
	playerNimbus:setWeaponTubeCount(2)					--one fewer tube (1 forward, 1 rear vs 2 forward, 1 rear)
	playerNimbus:setWeaponTubeDirection(0,0)			--first tube points straight forward
	playerNimbus:setWeaponTubeDirection(1,180)			--second tube points straight back
	playerNimbus:setWeaponTubeExclusiveFor(1,"Mine")
	playerNimbus:setWeaponStorageMax("Homing",6)		--reduce homing storage (vs 10)
	playerNimbus:setWeaponStorage("Homing",6)
	playerNimbus:setWeaponStorageMax("HVLI",10)			--reduce HVLI storage (vs 20)
	playerNimbus:setWeaponStorage("HVLI",10)
	playerNimbus:onTakingDamage(playerShipDamage)
	playerNimbus:addReputationPoints(50)
	return playerNimbus
end
function createPlayerShipOsprey()
	--destroyed 29Feb2020
	playerOsprey = PlayerSpaceship():setTemplate("Flavia P.Falcon"):setFaction("Human Navy"):setCallSign("Osprey")
	setBeamColor(playerOsprey)
	playerOsprey:setTypeName("Flavia 2C")
	playerOsprey:setRotationMaxSpeed(20)					--faster spin (vs 10)
	playerOsprey:setImpulseMaxSpeed(70)						--faster (vs 60)
	playerOsprey:setShieldsMax(160, 160)					--stronger shields (vs 70, 70)
	playerOsprey:setShields(160, 160)
	playerOsprey:setBeamWeapon(0, 40, -10, 1200.0, 5.5, 6.5)	--two forward (vs rear)
	playerOsprey:setBeamWeapon(1, 40,  10, 1200.0, 5.5, 6.5)	--faster (vs 6.0) and stronger (vs 6.0)
	playerOsprey:setWeaponTubeCount(3)						--more (vs 1)
	playerOsprey:setWeaponTubeDirection(0,-90)				--left facing (vs none)
	playerOsprey:setWeaponTubeDirection(1, 90)				--right facing (vs none)
	playerOsprey:setWeaponTubeDirection(2, 180)				--rear facing
	playerOsprey:setWeaponTubeExclusiveFor(0,"Homing"):setTubeSize(0,"large")
	playerOsprey:setWeaponTubeExclusiveFor(1,"Homing"):setTubeSize(1,"large")
	playerOsprey:setWeaponStorageMax("EMP",		2)			--more (vs 0)
	playerOsprey:setWeaponStorage("EMP",		2)				
	playerOsprey:setWeaponStorageMax("Nuke",	2)			--more (vs 1)
	playerOsprey:setWeaponStorage("Nuke",		2)				
	playerOsprey:setWeaponStorageMax("Mine",	2)			--more (vs 1)
	playerOsprey:setWeaponStorage("Mine",		2)				
	playerOsprey:setWeaponStorageMax("Homing",	6)			--more (vs 3)
	playerOsprey:setWeaponStorage("Homing", 	6)				
	playerOsprey:onTakingDamage(playerShipDamage)
	playerOsprey:addReputationPoints(50)
	return playerOsprey
end
function createPlayerShipOutcast()
	playerOutcast = PlayerSpaceship():setTemplate("Hathcock"):setFaction("Human Navy"):setCallSign("Outcast")
	setBeamColor(playerOutcast)
	playerOutcast:setTypeName("Scatter")
	playerOutcast:setRepairCrewCount(4)					--more repair crew (vs 2)
	playerOutcast:setImpulseMaxSpeed(65)				--faster impulse max (vs 50)
	playerOutcast.max_jump_range = 28000				--shorter than typical (vs 50)
	playerOutcast.min_jump_range = 2500					--shorter than typical (vs 5)
	playerOutcast:setJumpDriveRange(playerOutcast.min_jump_range,playerOutcast.max_jump_range)
	playerOutcast:setJumpDriveCharge(playerOutcast.max_jump_range)
	playerOutcast:setShieldsMax(140,100)				--stronger (vs 70,70)
	playerOutcast:setShields(140,100)
--                 				   Arc, Dir, Range, CycleTime, Damage
	playerOutcast:setBeamWeapon(0,  10,   0,  1200,			5,	4)	--3 front, 1 rear turret (vs 4 front)
	playerOutcast:setBeamWeapon(1,  80, -20,  1000, 		5,	5)	--shorter (vs 1400, 1200, 1000, 800)
	playerOutcast:setBeamWeapon(2,  80,  20,  1000, 		5,	5)	--shorter beams stronger
	playerOutcast:setBeamWeapon(3,  10, 180,  1000, 		5,	5)
--										   Arc, Dir, Rotate speed
	playerOutcast:setBeamWeaponTurret(3,	90,	180,	 .4)	--slow turret
	playerOutcast:setWeaponTubeCount(3)							--more (vs 2)
	playerOutcast:setWeaponTubeDirection(2,180)
	playerOutcast:setWeaponStorageMax("Mine",3)					--more (vs 0)
	playerOutcast:setWeaponStorage("Mine",3)
	playerOutcast:setTubeLoadTime(2,30)							--longer load time (vs 15)
	playerOutcast:weaponTubeDisallowMissle(0,"Mine")			--no mines (vs all)
	playerOutcast:weaponTubeDisallowMissle(1,"Mine")
	playerOutcast:setSystemCoolantRate("reactor",		1.4)	--more (vs 1.2)
	playerOutcast:setSystemCoolantRate("jumpdrive",		1.3)	--more (vs 1.2)
	playerOutcast:setSystemCoolantRate("beamweapons",	0.95)	--less (vs 1.2)
	playerOutcast:setSystemCoolantRate("maneuver",		1.05)	--less (vs 1.2)
	playerOutcast:setSystemCoolantRate("impulse",		1.15)	--less (vs 1.2)
	playerOutcast:setSystemCoolantRate("frontshield",	1.25)	--more (vs 1.2)
	playerOutcast:setSystemCoolantRate("rearshield",	1.2)	--same (vs 1.2)
	playerOutcast:setSystemCoolantRate("missilesystem",	1.2)	--same (vs 1.2)
	playerOutcast:setSystemPowerRate("reactor",			0.40)	--more (vs 0.30)
	playerOutcast:setSystemPowerRate("beamweapons",		0.2)	--less (vs 0.30)
	playerOutcast:setSystemPowerRate("jumpdrive",		0.325)	--more (vs 0.30)
	playerOutcast:setSystemPowerRate("maneuver",		0.25)	--less (vs 0.30)
	playerOutcast:setSystemPowerRate("impulse",			0.3)	--same (vs 0.30)
	playerOutcast:setSystemPowerRate("frontshield",		0.3)	--same (vs 0.30)
	playerOutcast:setSystemPowerRate("rearshield",		0.325)	--more (vs 0.30)	
	playerOutcast:setSystemPowerRate("missilesystem",	0.275)	--less (vs 0.30)	
	playerOutcast:onTakingDamage(playerShipDamage)
	playerOutcast:addReputationPoints(50)
	return playerOutcast
end
function createPlayerShipPinwheel()
	playerRotor = PlayerSpaceship():setTemplate("Maverick"):setFaction("Human Navy"):setCallSign("Pinwheel")
	setBeamColor(playerRotor)
	playerRotor:setTypeName("Rotor")
	playerRotor:setWarpSpeed(450)							--slower (vs 800)
--                  		    Arc, Dir,  Range,   CycleTime, Dmg
	playerRotor:setBeamWeapon(0, 10,   0, 1000.0,			6, 3)	--5 reconfigured beams (vs 6)
	playerRotor:setBeamWeapon(1, 10, 180, 1000.0,			6, 3)
	playerRotor:setBeamWeapon(2, 60, -25,  800.0,			6, 4)
	playerRotor:setBeamWeapon(3, 60,  25,  800.0,			6, 4)
	playerRotor:setBeamWeapon(4, 40,   0,  600.0,			6, 5)
	playerRotor:setBeamWeapon(5,  0,   0,  0,				0, 0)
--									   Arc, Dir, Rotate speed
	playerRotor:setBeamWeaponTurret(0, 190,   0, 1)
	playerRotor:setBeamWeaponTurret(1, 190, 180, 1)
	playerRotor:setLongRangeRadarRange(25000)				--shorter longer range sensors (vs 30000)
	playerRotor.normal_long_range_radar = 25000
	playerRotor:setShortRangeRadarRange(4000)				--shorter short range sensors (vs 5000)
	playerRotor:setWeaponTubeCount(1)						--fewer (vs 3)
	playerRotor:setWeaponTubeDirection(0, 180)				--rear (vs left)
	playerRotor:setWeaponTubeExclusiveFor(0,"Mine")			--Mine only (vs any)
	playerRotor:setWeaponStorageMax("Mine", 6)				--more (vs 2)
	playerRotor:setWeaponStorage("Mine", 6)
	playerRotor:setWeaponStorageMax("Homing", 0)			--fewer (vs 6)
	playerRotor:setWeaponStorage("Homing", 0)
	playerRotor:setWeaponStorageMax("HVLI", 0)				--fewer (vs 10)
	playerRotor:setWeaponStorage("HVLI", 0)
	playerRotor:setWeaponStorageMax("EMP", 0)				--fewer (vs 4)
	playerRotor:setWeaponStorage("EMP", 0)
	playerRotor:setWeaponStorageMax("Nuke", 0)				--fewer (vs 2)
	playerRotor:setWeaponStorage("Nuke", 0)
	playerRotor:setSystemCoolantRate("reactor",			1.15)	--less (vs 1.2)
	playerRotor:setSystemCoolantRate("warp",			1.05)	--less (vs 1.2)
	playerRotor:setSystemCoolantRate("beamweapons",		1.2)	--same (vs 1.2)
	playerRotor:setSystemCoolantRate("maneuver",		1.1)	--less (vs 1.2)
	playerRotor:setSystemCoolantRate("impulse",			1)		--less (vs 1.2)
	playerRotor:setSystemCoolantRate("frontshield",		1.35)	--more (vs 1.2)
	playerRotor:setSystemCoolantRate("rearshield",		1.3)	--more (vs 1.2)
	playerRotor:setSystemCoolantRate("missilesystem",	1)		--less (vs 1.2)
	playerRotor:setSystemPowerRate("reactor",			0.30)	--same (vs 0.30)
	playerRotor:setSystemPowerRate("beamweapons",		0.325)	--more (vs 0.30)
	playerRotor:setSystemPowerRate("warp",				0.25)	--less (vs 0.30)
	playerRotor:setSystemPowerRate("maneuver",			0.275)	--less (vs 0.30)
	playerRotor:setSystemPowerRate("impulse",			0.175)	--less (vs 0.30)
	playerRotor:setSystemPowerRate("frontshield",		0.375)	--more (vs 0.30)
	playerRotor:setSystemPowerRate("rearshield",		0.35)	--more (vs 0.30)	
	playerRotor:setSystemPowerRate("missilesystem",		0.2)	--less (vs 0.30)	
	playerRotor:onTakingDamage(playerShipDamage)
	playerRotor:addReputationPoints(50)
	return playerRotor
end
function createPlayerShipQuarter()
	playerBarrow = PlayerSpaceship():setTemplate("Benedict"):setFaction("Human Navy"):setCallSign("Quarter")
	setBeamColor(playerBarrow)
	playerBarrow:setTypeName("Barrow")
	playerBarrow:setShieldsMax(100, 100)				--stronger shields (vs 70, 70)
	playerBarrow:setShields(100, 100)
	playerBarrow.max_jump_range = 40000					--shorter (vs 90)
	playerBarrow.min_jump_range = 4000					--shorter (vs 5)
	playerBarrow:setJumpDriveRange(playerBarrow.min_jump_range,playerBarrow.max_jump_range)
	playerBarrow:setJumpDriveCharge(playerBarrow.max_jump_range)
--	playerBarrow.carrier_space_group = {
--	 	["Carpenter"] =	{create = stockPlayer, template = "MP52 Hornet",	state = "aboard",	launch_button = "launch_carpenter",	time = 5,	repair = 0, mine = 0},
--	 	["Chack"] =		{create = createPlayerShipFowl,						state = "aboard",	launch_button = "launch_chack",		time = 10,	repair = 0, mine = 4},
--	}
--	playerBarrow.launch_bay = "empty"
	playerBarrow:onTakingDamage(playerShipDamage)
	playerBarrow:addReputationPoints(50)
	return playerBarrow
end
function createPlayerShipQuick()
	playerQuick = PlayerSpaceship():setTemplate("ZX-Lindworm"):setFaction("Human Navy"):setCallSign("Quicksilver")
	setBeamColor(playerQuick)
	playerQuick:setTypeName("XR-Lindworm")
	playerQuick:setRepairCrewCount(3)			--more repair crew (vs 1)
	playerQuick:setWarpDrive(true)				--warp drive (vs none)
	playerQuick:setWarpSpeed(450)
	playerQuick:setShieldsMax(100,50)			--stronger front (vs 40)
	playerQuick:setShields(100,50)
	playerQuick:setWeaponTubeExclusiveFor(0,"HVLI")
	playerQuick:setTubeSize(0,"large")
	playerQuick:setTubeLoadTime(0,15)
	playerQuick:weaponTubeAllowMissle(1,"Homing")
	playerQuick:weaponTubeAllowMissle(2,"Homing")
	playerQuick:weaponTubeAllowMissle(1,"EMP")
	playerQuick:weaponTubeAllowMissle(2,"Nuke")
	playerQuick:setWeaponStorageMax("Homing",8)		--more homing (vs 3)
	playerQuick:setWeaponStorage("Homing", 8)				
	playerQuick:setWeaponStorageMax("Nuke",3)	--more Nukes (vs 0)
	playerQuick:setWeaponStorage("Nuke", 3)				
	playerQuick:setWeaponStorageMax("EMP",5)	--more EMPs (vs 0)
	playerQuick:setWeaponStorage("EMP", 5)				
	playerQuick:setSystemCoolantRate("reactor",			1.25)	--more (vs 1.2)
	playerQuick:setSystemCoolantRate("warp",			1.3)	--more (vs 1.2)
	playerQuick:setSystemCoolantRate("beamweapons",		1.15)	--less (vs 1.2)
	playerQuick:setSystemCoolantRate("maneuver",		1.25)	--more (vs 1.2)
	playerQuick:setSystemCoolantRate("impulse",			1.05)	--less (vs 1.2)
	playerQuick:setSystemCoolantRate("frontshield",		1.2)	--same (vs 1.2)
	playerQuick:setSystemCoolantRate("rearshield",		1.05)	--less (vs 1.2)
	playerQuick:setSystemCoolantRate("missilesystem",	1.2)	--same (vs 1.2)
	playerQuick:setSystemPowerRate("reactor",			0.4)	--more (vs 0.30)
	playerQuick:setSystemPowerRate("beamweapons",		0.375)	--more (vs 0.30)
	playerQuick:setSystemPowerRate("warp",				0.35)	--more (vs 0.30)
	playerQuick:setSystemPowerRate("maneuver",			0.35)	--more (vs 0.30)
	playerQuick:setSystemPowerRate("impulse",			0.225)	--less (vs 0.30)
	playerQuick:setSystemPowerRate("frontshield",		0.3)	--same (vs 0.30)
	playerQuick:setSystemPowerRate("rearshield",		0.275)	--less (vs 0.30)	
	playerQuick:setSystemPowerRate("missilesystem",		0.35)	--more (vs 0.30)	
	playerQuick:onTakingDamage(playerShipDamage)
	playerQuick:addReputationPoints(50)
	return playerQuick
end
function createPlayerShipQuill()
	playerQuill = PlayerSpaceship():setTemplate("Flavia P.Falcon"):setFaction("Human Navy"):setCallSign("Quill")
	setBeamColor(playerQuill)
	playerQuill:setTypeName("Porcupine")
	-- weapons are designed from scratch, so no comparision vs stock
	-- 5 tubes on the left side, all small
	-- middle 3 HVLI only and are fast
	-- first and last take homing + other
	playerQuill:setWeaponTubeCount(5)
	playerQuill:setWeaponTubeDirection(0,-50)
		:setTubeSize(0,"small")
		:setWeaponTubeExclusiveFor(0,"Homing")
		:weaponTubeAllowMissle(0,"EMP")
	playerQuill:setWeaponTubeDirection(1,-70)
		:setTubeSize(1,"small")
		:setWeaponTubeExclusiveFor(1,"HVLI")
		:setTubeLoadTime(1,10) -- half default
	playerQuill:setWeaponTubeDirection(2,-90)
		:setTubeSize(2,"small")
		:setWeaponTubeExclusiveFor(2,"HVLI")
		:setTubeLoadTime(2,10) -- half default
	playerQuill:setWeaponTubeDirection(3,-110)
		:setTubeSize(3,"small")
		:setWeaponTubeExclusiveFor(3,"HVLI")
		:setTubeLoadTime(3,10) -- half default
	playerQuill:setWeaponTubeDirection(4,-130)
		:setTubeSize(4,"small")
		:setWeaponTubeExclusiveFor(4,"Homing")
		:weaponTubeAllowMissle(4,"Mine")
		:weaponTubeAllowMissle(4,"Nuke")
	playerQuill:setWeaponStorageMax("Homing",8)
	playerQuill:setWeaponStorage("Homing", 8)
	playerQuill:setWeaponStorageMax("Nuke",2)
	playerQuill:setWeaponStorage("Nuke", 2)
	playerQuill:setWeaponStorageMax("EMP",2)
	playerQuill:setWeaponStorage("EMP", 2)
	playerQuill:setWeaponStorageMax("Mine",2)
	playerQuill:setWeaponStorage("Mine", 2)
	playerQuill:setWeaponStorageMax("HVLI",20)
	playerQuill:setWeaponStorage("HVLI", 20)
-- 3 beam arcs on the right
-- all slow average dps turrets
-- there are 2 overlap points where 2 of the 3 turrets can both hit
	playerQuill:setBeamWeapon(0, 5,   90,	1100.0, 	   6.0,   6)
		:setBeamWeaponTurret(0,	45,   90,	.1)
	playerQuill:setBeamWeapon(1, 5, 90-35,	1100.0, 	   6.0,   6)
		:setBeamWeaponTurret(1,	45,   90-35,.1)
	playerQuill:setBeamWeapon(2, 5,  90+35,1100.0, 	   6.0,   6)
		:setBeamWeaponTurret(2,	45,   90+35,.1)
	playerQuill:setWarpSpeed(300)			--slower (vs 500)
	playerQuill:setShieldsMax(130, 130)		--stronger (vs 70,70)
	playerQuill:setShields(130, 130)
	playerQuill:setLongRangeRadarRange(25000)
	playerQuill.normal_long_range_radar = 25000
	playerQuill:onTakingDamage(playerShipDamage)
	playerQuill:addReputationPoints(50)
	return playerQuill
end
function createPlayerShipRaptor()
	playerRaptor = PlayerSpaceship():setTemplate("Player Cruiser"):setFaction("Human Navy"):setCallSign("Raptor")
	setBeamColor(playerRaptor)
	playerRaptor:setTypeName("Destroyer IV")
	playerRaptor.max_jump_range = 32000						--shorter than typical (vs 50)
	playerRaptor.min_jump_range = 3000						--shorter than typical (vs 5)
	playerRaptor:setJumpDriveRange(playerRaptor.min_jump_range,playerRaptor.max_jump_range)
	playerRaptor:setJumpDriveCharge(playerRaptor.max_jump_range)
	playerRaptor:setShieldsMax(100, 100)					--stronger shields (vs 80, 80)
	playerRaptor:setShields(100, 100)
	playerRaptor:setHullMax(150)							--weaker hull (vs 200)
	playerRaptor:setHull(150)
	playerRaptor:setBeamWeapon(0, 45, -10, 1000.0, 5, 6)	--narrower (45 vs 90), faster (5 vs 6), weaker (6 vs 10)
	playerRaptor:setBeamWeapon(1, 45,  10, 1000.0, 5, 6)
	playerRaptor:setWeaponTubeDirection(0,-60)				--left -60 (vs -5)
	playerRaptor:setWeaponTubeDirection(1, 60)				--right 60 (vs 5)
	playerRaptor:setWeaponStorageMax("Homing",6)			--less (vs 12)
	playerRaptor:setWeaponStorage("Homing", 6)				
	playerRaptor:setWeaponStorageMax("Nuke",2)				--fewer (vs 4)
	playerRaptor:setWeaponStorage("Nuke", 2)				
	playerRaptor:setWeaponStorageMax("EMP",3)				--fewer (vs 6)
	playerRaptor:setWeaponStorage("EMP", 3)				
	playerRaptor:setWeaponStorageMax("Mine",4)				--fewer (vs 8)
	playerRaptor:setWeaponStorage("Mine", 4)				
	playerRaptor:setWeaponStorageMax("HVLI",6)				--more (vs 0)
	playerRaptor:setWeaponStorage("HVLI", 6)				
	playerRaptor:onTakingDamage(playerShipDamage)
	playerRaptor:addReputationPoints(50)
	return playerRaptor
end
function createPlayerShipRattler()
	--	stolen from Kraylor, may be used for intelligence gathering
	playerRattler = PlayerSpaceship():setTemplate("ZX-Lindworm"):setFaction("Human Navy"):setCallSign("Rattler")
	setBeamColor(playerRattler)
	playerRattler:setTypeName("MX-Lindworm")
	playerRattler:setRepairCrewCount(2)						--more (vs 1)
	playerRattler:setJumpDrive(true)
	playerRattler:setShieldsMax(80)							--stronger shields (vs 40)
	playerRattler:setShields(80)
	playerRattler.max_jump_range = 20000					--shorter than typical (vs 50)
	playerRattler.min_jump_range = 3000						--shorter than typical (vs 5)
	playerRattler:setJumpDriveRange(playerRattler.min_jump_range,playerRattler.max_jump_range)
	playerRattler:setJumpDriveCharge(playerRattler.max_jump_range)
	playerRattler:setImpulseMaxSpeed(77)					--faster (vs 70)
	playerRattler:setShortRangeRadarRange(6000)				--longer (vs 5000)
--											Arc, Dir, Rotate speed
	playerRattler:setBeamWeaponTurret( 0,   270, 180, 1)	--slower turret (vs 4)
	playerRattler:setWeaponTubeCount(4)						--more (vs 3)
	playerRattler:setTubeSize(0,"large")					--large (vs small)
	playerRattler:setTubeSize(1,"medium")					--medium (vs small)
	playerRattler:setWeaponTubeExclusiveFor(0,"HVLI")		--only HVLI (vs any)
	playerRattler:setWeaponTubeExclusiveFor(1,"Nuke")		--only Nuke (vs HVLI)
	playerRattler:setWeaponTubeExclusiveFor(2,"Homing")		--only Homing & EMP (vs HVLI)
	playerRattler:weaponTubeAllowMissle(2,"EMP")			
	playerRattler:setTubeLoadTime(1,25)						--slower load time (vs 10)
	playerRattler:setWeaponTubeDirection(3,180)
	playerRattler:setWeaponTubeExclusiveFor(3,"Mine")
	playerRattler:setTubeLoadTime(3,45)						--slower load time (vs 10)
	playerRattler:setWeaponStorageMax("Homing",5)			--more (vs 3)
	playerRattler:setWeaponStorage("Homing",   5)				
	playerRattler:setWeaponStorageMax("EMP",   4)			--more (vs 0)
	playerRattler:setWeaponStorage("EMP",      4)				
	playerRattler:setWeaponStorageMax("Nuke",  2)			--more (vs 0)
	playerRattler:setWeaponStorage("Nuke",     2)
	playerRattler:setWeaponStorageMax("Mine",  2)			--more (vs 0)
	playerRattler:setWeaponStorage("Mine",     2)
	playerRattler:onTakingDamage(playerShipDamage)
	playerRattler:addReputationPoints(50)
	return playerRattler
end
function createPlayerShipRip()
	playerLurker = PlayerSpaceship():setTemplate("ZX-Lindworm"):setFaction("Human Navy"):setCallSign("Rip")
	setBeamColor(playerLurker)
	playerLurker:setTypeName("Lurker")
	playerLurker:setHullMax(120)						--stronger hull (vs 75)
	playerLurker:setHull(120)
	playerLurker:setShieldsMax(100)						--stronger shield (vs 40)
	playerLurker:setShields(100)
	playerLurker:setRotationMaxSpeed(12)				--slower spin (vs 15)
	playerLurker:setAcceleration(18)					--slower (vs 25)
	playerLurker:setWarpDrive(true)						--add warp (vs none)
	playerLurker:setWarpSpeed(320)
	playerLurker:setRepairCrewCount(2)					--more repair crew (vs 1)
--                 				 Arc, Dir, Range, CycleTime, Damage
	playerLurker:setBeamWeapon(0, 10, 180,	1000,		2.0, 2)		--faster, longer, (vs 6 Cyc, .9 U) 
--										 Arc,	Dir, Rotate speed
	playerLurker:setBeamWeaponTurret( 0, 180,	180, .3)			--narrower, slower (vs 270 arc, 4 rotate)
	playerLurker:setTubeSize(1,"medium")				--medium (vs small)
	playerLurker:setTubeSize(2,"medium")				--medium (vs small)
	playerLurker:setTubeLoadTime(1,15)					--slower load time (vs 10)
	playerLurker:setTubeLoadTime(2,15)					--slower load time (vs 10)
	playerLurker:setWeaponTubeDirection(1, 5)			--more angled (vs  1)	
	playerLurker:setWeaponTubeDirection(2,-5)			--more angled (vs -1)	
	playerLurker:setWeaponTubeExclusiveFor(0,"HVLI")	--only HVLI (vs any)
	playerLurker:setWeaponTubeExclusiveFor(1,"Homing")	--Homing, Nuke, EMP (vs only HVLI)
	playerLurker:weaponTubeAllowMissle(1,"EMP")
	playerLurker:weaponTubeAllowMissle(1,"Nuke")
	playerLurker:setWeaponTubeExclusiveFor(2,"Homing")	--Homing, Nuke, EMP (vs only HVLI)
	playerLurker:weaponTubeAllowMissle(2,"EMP")
	playerLurker:weaponTubeAllowMissle(2,"Nuke")
	playerLurker:setWeaponStorageMax("Homing",8)			--more (vs 3)
	playerLurker:setWeaponStorage("Homing",   8)				
	playerLurker:setWeaponStorageMax("EMP",   5)			--more (vs 0)
	playerLurker:setWeaponStorage("EMP",      5)				
	playerLurker:setWeaponStorageMax("Nuke",  3)			--more (vs 0)
	playerLurker:setWeaponStorage("Nuke",     3)
	playerLurker:setSystemCoolantRate("reactor",		1.1)	--less (vs 1.2)
	playerLurker:setSystemCoolantRate("beamweapons",	1.1)	--less (vs 1.2)
	playerLurker:setSystemCoolantRate("missilesystem",	1.7)	--more (vs 1.2)
	playerLurker:setSystemCoolantRate("maneuver",		1.1)	--less (vs 1.2)
	playerLurker:setSystemCoolantRate("impulse",		1.1)	--less (vs 1.2)
	playerLurker:setSystemCoolantRate("warp",			1.1)	--less (vs 1.2)
	playerLurker:setSystemCoolantRate("frontshield",	1.1)	--less (vs 1.2)
	playerLurker:setSystemHeatRate("reactor",			0.04)	--less (vs 0.05)
	playerLurker:setSystemHeatRate("beamweapons",		0.04)	--less (vs 0.05)
	playerLurker:setSystemHeatRate("missilesystem",		0.11)	--more (vs 0.05)
	playerLurker:setSystemHeatRate("maneuver",			0.04)	--less (vs 0.05)
	playerLurker:setSystemHeatRate("impulse",			0.04)	--less (vs 0.05)
	playerLurker:setSystemHeatRate("warp",				0.04)	--less (vs 0.05)
	playerLurker:setSystemHeatRate("frontshield",		0.04)	--less (vs 0.05)
	playerLurker:setSystemPowerRate("reactor",			0.20)	--less (vs 0.30)
	playerLurker:setSystemPowerRate("beamweapons",		0.20)	--less (vs 0.30)
	playerLurker:setSystemPowerRate("missilesystem",	0.90)	--more (vs 0.30)
	playerLurker:setSystemPowerRate("maneuver",			0.20)	--less (vs 0.30)
	playerLurker:setSystemPowerRate("impulse",			0.20)	--less (vs 0.30)
	playerLurker:setSystemPowerRate("warp",				0.20)	--less (vs 0.30)
	playerLurker:setSystemPowerRate("frontshield",		0.20)	--less (vs 0.30)
	playerLurker:onTakingDamage(playerShipDamage)
	playerLurker:addReputationPoints(50)
	return playerLurker	
end
function createPlayerShipRoc()
	playerRoc = PlayerSpaceship():setTemplate("Phobos M3P"):setFaction("Human Navy"):setCallSign("Swoop")
	setBeamColor(playerRoc)
	playerRoc:setTypeName("Roc")
	playerRoc:setRepairCrewCount(5)					--more repair crew (vs 3)
	playerRoc:setWarpDrive(true)					--warp drive (vs none)
	playerRoc:setWarpSpeed(480)
	playerRoc:setShieldsMax(150,80)					--strong front, weak rear (vs 100,100)
	playerRoc:setShields(150,80)
	playerRoc:setImpulseMaxSpeed(75)				--slower impulse max (vs 80)
	playerRoc:setRotationMaxSpeed(9)				--slower spin (vs 10)
	playerRoc:setAcceleration(15)					--slower acceleration (vs 20)
--                 			  Arc, Dir, Range, CycleTime, Damage
	playerRoc:setBeamWeapon(0, 30,  10,	 1000,		 8.0, 6)	--shorter, narrower (vs 1.2u, 90 deg) 
	playerRoc:setBeamWeapon(1, 30, -10,	 1000,		 8.0, 6)	--shorter, narrower (vs 1.2u, 90 deg) 
	playerRoc:setBeamWeapon(2, 10, 180,	 1500,		 2.0, 1)	--weak turreted 3rd beam 
--									  Arc,	Dir, Rotate speed
	playerRoc:setBeamWeaponTurret( 2, 310,	180, 1)		
	playerRoc:setWeaponTubeCount(8)					--more (vs 3)
	playerRoc:setWeaponTubeDirection(0, 4)			--more angled (vs  -1)	
	playerRoc:setWeaponTubeDirection(1,-4)			--more angled (vs   1)	
	playerRoc:setWeaponTubeDirection(2, 0)			--forward (vs rear)	
	playerRoc:setWeaponTubeDirection(3, 90)
	playerRoc:setWeaponTubeDirection(4, 90)
	playerRoc:setWeaponTubeDirection(5,-90)
	playerRoc:setWeaponTubeDirection(6,-90)
	playerRoc:setWeaponTubeDirection(7,180)
	playerRoc:setTubeSize(0,"small")				--small (vs medium)
	playerRoc:setTubeSize(1,"small")				--small (vs medium)
	playerRoc:setTubeSize(4,"large")
	playerRoc:setTubeSize(6,"large")
	playerRoc:setTubeLoadTime(0,5)					--faster load time (vs 10)
	playerRoc:setTubeLoadTime(1,5)					--faster load time (vs 10)
	playerRoc:setTubeLoadTime(4,20)					--slower load time (vs 10)
	playerRoc:setTubeLoadTime(6,20)					--slower load time (vs 10)
	playerRoc:setTubeLoadTime(7,15)					--slower load time (vs 10)
	playerRoc:setWeaponTubeExclusiveFor(0,"HVLI")	--HVLI & Homing (vs all but mine)
	playerRoc:weaponTubeAllowMissle(0,"Homing")
	playerRoc:setWeaponTubeExclusiveFor(1,"HVLI")	--HVLI & Homing (vs all but mine)
	playerRoc:weaponTubeAllowMissle(1,"Homing")
	playerRoc:setWeaponTubeExclusiveFor(2,"HVLI")	--HVLI (vs mine)
	playerRoc:weaponTubeDisallowMissle(3,"Mine")
	playerRoc:weaponTubeDisallowMissle(4,"Mine")
	playerRoc:weaponTubeDisallowMissle(5,"Mine")
	playerRoc:weaponTubeDisallowMissle(6,"Mine")
	playerRoc:setWeaponTubeExclusiveFor(7,"Mine")
	playerRoc:setWeaponStorageMax("HVLI",18)		--more (vs 0)
	playerRoc:setWeaponStorage("HVLI", 18)
	playerRoc:setSystemCoolantRate("reactor",		1.35)	--more (vs 1.2)
	playerRoc:setSystemCoolantRate("beamweapons",	1.2)	--same (vs 1.2)
	playerRoc:setSystemCoolantRate("maneuver",		1.1)	--less (vs 1.2)
	playerRoc:setSystemCoolantRate("jumpdrive",		1.25)	--more (vs 1.2)
	playerRoc:setSystemCoolantRate("impulse",		1.15)	--less (vs 1.2)
	playerRoc:setSystemCoolantRate("missilesystem",	1.25)	--more (vs 1.2)
	playerRoc:setSystemCoolantRate("frontshield",	1.1)	--less (vs 1.2)
	playerRoc:setSystemCoolantRate("rearshield",	1.2)	--same (vs 1.2)
	playerRoc:setSystemPowerRate("reactor",			0.40)	--more (vs 0.30)
	playerRoc:setSystemPowerRate("jumpdrive",		0.3)	--same (vs 0.30)
	playerRoc:setSystemPowerRate("beamweapons",		0.275)	--less (vs 0.30)
	playerRoc:setSystemPowerRate("maneuver",		0.225)	--less (vs 0.30)
	playerRoc:setSystemPowerRate("impulse",			0.25)	--less (vs 0.30)
	playerRoc:setSystemPowerRate("missilesystem",	0.3)	--same (vs 0.30)
	playerRoc:setSystemPowerRate("frontshield",		0.225)	--less (vs 0.30)
	playerRoc:setSystemPowerRate("rearshield",		0.325)	--more (vs 0.30)
	playerRoc:onTakingDamage(playerShipDamage)
	playerRoc:addReputationPoints(50)
	return playerRoc	
end
function createPlayerShipRocinante()
	playerWindmill = PlayerSpaceship():setTemplate("Flavia P.Falcon"):setFaction("Human Navy"):setCallSign("Rocinante")
	setBeamColor(playerWindmill)
	playerWindmill:setTypeName("Windmill")
	playerWindmill:setImpulseMaxSpeed(100)	--faster impulse max (vs 60)
	playerWindmill:setWarpSpeed(350)		--slower (vs 500)
	playerWindmill:setShieldsMax(100,70)	--stronger (vs 70,70)
	playerWindmill:setShields(100,70)
	playerWindmill:setRepairCrewCount(5)	--less repair crew (vs 8)
--                 				   Arc, Dir,   Range, CycleTime, Damage
	playerWindmill:setBeamWeapon(0,	60,   0,	1000, 		6.0, 	6.0)	--front (vs rear), short (vs 1200)
	playerWindmill:setBeamWeapon(1,	60, 180,	1000, 		6.0, 	6.0)	--short (vs 1200)
	playerWindmill:setBeamWeapon(2,	10, -90,	1200, 		6.0, 	4.0)	--left turret (vs none)
	playerWindmill:setBeamWeapon(3,	10,  90,	1200, 		6.0, 	4.0)	--right turret (vs none)
--											Arc,  Dir, Rotate speed
	playerWindmill:setBeamWeaponTurret(2,	140,  -90,			 .5)		--slow turret
	playerWindmill:setBeamWeaponTurret(3,	140,   90,			 .5)		--slow turret
	playerWindmill:setWeaponTubeCount(5)					--more (vs 1)
	playerWindmill:setTubeSize(0,"small")					--small (vs normal)
	playerWindmill:setTubeLoadTime(0,5)						--fast (vs 20)
	playerWindmill:setWeaponTubeDirection(0,0)				--forward facing
	playerWindmill:weaponTubeDisallowMissle(0,"Mine")		--all but mine
	playerWindmill:setTubeLoadTime(1,10)
	playerWindmill:setWeaponTubeDirection(1,-90)			--left facing
	playerWindmill:weaponTubeDisallowMissle(1,"Mine")		--all but mine
	playerWindmill:setTubeLoadTime(2,10)
	playerWindmill:setWeaponTubeDirection(2,90)				--right facing
	playerWindmill:weaponTubeDisallowMissle(2,"Mine")		--all but mine
	playerWindmill:setTubeSize(3,"large")					
	playerWindmill:setTubeLoadTime(3,15)
	playerWindmill:setWeaponTubeDirection(3,180)			--rear facing
	playerWindmill:weaponTubeDisallowMissle(3,"Mine")		--all but mine
	playerWindmill:setTubeLoadTime(4,20)
	playerWindmill:setWeaponTubeDirection(4,180)			--rear facing
	playerWindmill:setWeaponTubeExclusiveFor(4,"Mine")		--mine only
	playerWindmill:setWeaponStorageMax("Homing", 8)			--more (vs 3)
	playerWindmill:setWeaponStorage("Homing", 8)
	playerWindmill:setWeaponStorageMax("Mine", 5)			--more (vs 1)
	playerWindmill:setWeaponStorage("Mine", 5)
	playerWindmill:setWeaponStorageMax("EMP", 3)			--more (vs 0)
	playerWindmill:setWeaponStorage("EMP", 3)
	playerWindmill:setWeaponStorageMax("HVLI", 12)			--more (vs 5)
	playerWindmill:setWeaponStorage("HVLI", 12)
--	playerWindmill:setSystemHeatRate("reactor",		0.5)	--more (vs.05) Lingling
--	playerWindmill:setSystemHeatRate("frontshield",	0.25)	--more (vs.05) Lingling
	playerWindmill:setSystemCoolantRate("reactor",		3)	--more (vs 1.2) Arlenian pumps
	playerWindmill:setSystemCoolantRate("beamweapons",	3)	--more (vs 1.2) Arlenian pumps
	playerWindmill:setSystemCoolantRate("missilesystem",3)	--more (vs 1.2) Arlenian pumps
	playerWindmill:setSystemCoolantRate("maneuver",		3)	--more (vs 1.2) Arlenian pumps
	playerWindmill:setSystemCoolantRate("impulse",		3)	--more (vs 1.2) Arlenian pumps
	playerWindmill:setSystemCoolantRate("rearshield",	3)	--more (vs 1.2) Arlenian pumps
	playerWindmill:setSystemCoolantRate("frontshield",	3)	--more (vs 1.2) Arlenian pumps
	playerWindmill:onTakingDamage(playerShipDamage)
	playerWindmill:addReputationPoints(50)
	return playerWindmill
end
function createPlayerShipRogue()
	playerRogue = PlayerSpaceship():setTemplate("Maverick"):setFaction("Human Navy"):setCallSign("Rogue")
	setBeamColor(playerRogue)
	playerRogue:setTypeName("Maverick XP")
	playerRogue:setImpulseMaxSpeed(65)						--slower impulse max (vs 80)
	playerRogue:setWarpDrive(false)							--no warp
	playerRogue:setJumpDrive(true)
	playerRogue.max_jump_range = 20000					--shorter than typical (vs 50)
	playerRogue.min_jump_range = 2000						--shorter than typical (vs 5)
	playerRogue:setJumpDriveRange(playerRogue.min_jump_range,playerRogue.max_jump_range)
	playerRogue:setJumpDriveCharge(playerRogue.max_jump_range)
--                  		    Arc, Dir,  Range, CycleTime, Dmg
	playerRogue:setBeamWeapon(0, 10,   0, 1000.0,      20.0, 20)
--									   Arc, Dir, Rotate speed
	playerRogue:setBeamWeaponTurret(0, 270,   0, .2)
	playerRogue:setBeamWeaponEnergyPerFire(0,playerRogue:getBeamWeaponEnergyPerFire(0)*6)
	playerRogue:setBeamWeaponHeatPerFire(0,playerRogue:getBeamWeaponHeatPerFire(0)*5)
	playerRogue:setBeamWeapon(1, 0, 0, 0, 0, 0)				--eliminate 5 beams
	playerRogue:setBeamWeapon(2, 0, 0, 0, 0, 0)				
	playerRogue:setBeamWeapon(3, 0, 0, 0, 0, 0)				
	playerRogue:setBeamWeapon(4, 0, 0, 0, 0, 0)	
	playerRogue:setBeamWeapon(5, 0, 0, 0, 0, 0)	
	playerRogue:setLongRangeRadarRange(25000)				--shorter longer range sensors (vs 30000)
	playerRogue.normal_long_range_radar = 25000
	playerRogue:setShortRangeRadarRange(6000)				--longer short range sensors (vs 5000)
	playerRogue:onTakingDamage(playerShipDamage)
	playerRogue:addReputationPoints(50)
	return playerRogue
end
function createPlayerShipDial()
	playerRonco = PlayerSpaceship():setTemplate("Flavia P.Falcon"):setFaction("Human Navy"):setCallSign("Dial")
	setBeamColor(playerRonco)
	playerRonco:setTypeName("Ronco")
--                  		     Arc, Dir,  Range,CycleTime, Dmg
	playerRonco:setBeamWeapon(0,  40,   0, 1000.0,		6.0, 6)
	playerRonco:setBeamWeapon(1,  10,  60,  900.0,		6.0, 6)
	playerRonco:setBeamWeapon(2,  10, -60,  900.0,		6.0, 6)
	playerRonco:setBeamWeapon(3,  40, 180,  800.0,		6.0, 6)
--									   Arc, Dir, Rotate speed
	playerRonco:setBeamWeaponTurret(1, 140,  90, .2)
	playerRonco:setBeamWeaponTurret(2, 140, -90, .2)
	playerRonco:setBeamWeaponDamageType(0,"emp")
	playerRonco:setBeamWeaponDamageType(1,"energy")
	playerRonco:setBeamWeaponDamageType(2,"energy")
	playerRonco:setBeamWeaponDamageType(3,"kinetic")
	playerRonco:onTakingDamage(playerShipDamage)
	playerRonco:addReputationPoints(50)
	return playerRonco
end
function createPlayerShipSimian()
	playerSimian = PlayerSpaceship():setTemplate("Player Missile Cr."):setFaction("Human Navy"):setCallSign("Knuckle Drag")
	setBeamColor(playerSimian)
	--aka Knuckle Drag or Simian
	playerSimian:setTypeName("Destroyer III")
	playerSimian:setWarpDrive(false)
	playerSimian:setJumpDrive(true)
	playerSimian.max_jump_range = 20000					--shorter than typical (vs 50)
	playerSimian.min_jump_range = 2000						--shorter than typical (vs 5)
	playerSimian:setJumpDriveRange(playerSimian.min_jump_range,playerSimian.max_jump_range)
	playerSimian:setJumpDriveCharge(playerSimian.max_jump_range)
	playerSimian:setHullMax(120)									--weaker hull (vs 200)
	playerSimian:setHull(120)
--                 				 Arc, Dir, Range, CycleTime, Damage
	playerSimian:setBeamWeapon(0,  8,   0, 900.0,         5, 6)		--turreted beam (vs none)
--									    Arc, Dir, Rotate speed
	playerSimian:setBeamWeaponTurret(0, 270,   0, .4)				--slow turret
	playerSimian:setWeaponTubeCount(5)								--fewer (vs 7)
	playerSimian:setWeaponTubeDirection(2, -90)						--left (vs right)
	playerSimian:setWeaponTubeDirection(4, 180)						--rear (vs left)
	playerSimian:setWeaponTubeExclusiveFor(0,"HVLI")				--only HVLI
	playerSimian:setTubeSize(0,"large")								--large (vs medium)
	playerSimian:setTubeLoadTime(0,20)								--slower (vs 8)
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
	playerSimian:setSystemCoolantRate("reactor",		1.3)	--more (vs 1.2)
	playerSimian:setSystemCoolantRate("jumpdrive",		1.3)	--more (vs 1.2)
	playerSimian:setSystemCoolantRate("beamweapons",	1.25)	--more (vs 1.2)
	playerSimian:setSystemCoolantRate("maneuver",		1.15)	--less (vs 1.2)
	playerSimian:setSystemCoolantRate("impulse",		1.1)	--less (vs 1.2)
	playerSimian:setSystemCoolantRate("frontshield",	1.15)	--less (vs 1.2)
	playerSimian:setSystemCoolantRate("rearshield",		1.15)	--less (vs 1.2)
	playerSimian:setSystemCoolantRate("missilesystem",	1.2)	--same (vs 1.2)
	playerSimian:setSystemPowerRate("reactor",			0.375)	--more (vs 0.30)
	playerSimian:setSystemPowerRate("beamweapons",		0.3)	--more (vs 0.30)
	playerSimian:setSystemPowerRate("jumpdrive",		0.325)	--more (vs 0.30)
	playerSimian:setSystemPowerRate("maneuver",			0.25)	--less (vs 0.30)
	playerSimian:setSystemPowerRate("impulse",			0.275)	--less (vs 0.30)
	playerSimian:setSystemPowerRate("frontshield",		0.25)	--less (vs 0.30)
	playerSimian:setSystemPowerRate("rearshield",		0.3)	--same (vs 0.30)	
	playerSimian:setSystemPowerRate("missilesystem",	0.325)	--more (vs 0.30)	
	playerSimian:setLongRangeRadarRange(20000)				--shorter longer range sensors (vs 30000)
	playerSimian:onTakingDamage(playerShipDamage)
	playerSimian:addReputationPoints(50)
	return playerSimian
end
function createPlayerShipSlingshot()
	playerWrocket = PlayerSpaceship():setTemplate("Piranha"):setFaction("Human Navy"):setCallSign("Slingshot")
	setBeamColor(playerWrocket)
	playerWrocket:setTypeName("Wrocket")
	playerWrocket:setShieldsMax(100,100)				--stronger shields (vs 80,80)
	playerWrocket:setShields(100,100)
	playerWrocket.max_jump_range = 30000				--shorter than typical (vs 50)
	playerWrocket.min_jump_range = 3000					--shorter than typical (vs 5)
	playerWrocket:setCombatManeuver(300,200)			--more (vs 200,150)
	playerWrocket:setJumpDriveRange(playerWrocket.min_jump_range,playerWrocket.max_jump_range)
	playerWrocket:setJumpDriveCharge(playerWrocket.max_jump_range)
--                 				   Arc, Dir,   Range, CycleTime, Damage
	playerWrocket:setBeamWeapon(0,  10,   0,	2000, 		8.0, 	0.5)	--long, very weak, turreted (vs none)
	playerWrocket:setBeamWeapon(1,  10, 180,	2000, 		8.0, 	0.5)	--fighter deterrents
--											Arc,  Dir, Rotate speed
	playerWrocket:setBeamWeaponTurret(0,	270,    0,			 1)
	playerWrocket:setBeamWeaponTurret(1,	270,  180,			 1)
	playerWrocket:setTubeSize(0,"small")				--small (vs large)
	playerWrocket:setTubeSize(3,"small")				--small (vs large)
	playerWrocket:setTubeLoadTime(0,6)					--faster (vs 8)
	playerWrocket:setTubeLoadTime(3,6)					--faster (vs 8)
	playerWrocket:setTubeLoadTime(2,12)					--slower (vs 8)
	playerWrocket:setTubeLoadTime(5,12)					--slower (vs 8)
	playerWrocket:weaponTubeDisallowMissle(1,"Mine")	--no side launching mines
	playerWrocket:weaponTubeDisallowMissle(4,"Mine")
	playerWrocket:setWeaponStorageMax("EMP",8)			--more (vs 0)
	playerWrocket:setWeaponStorage("EMP", 8)
	playerWrocket:setSystemCoolantRate("reactor",		1.25)	--more (vs 1.2)
	playerWrocket:setSystemCoolantRate("jumpdrive",		1.3)	--more (vs 1.2)
	playerWrocket:setSystemCoolantRate("beamweapons",	0.95)	--less (vs 1.2)
	playerWrocket:setSystemCoolantRate("maneuver",		1.2)	--same (vs 1.2)
	playerWrocket:setSystemCoolantRate("impulse",		1.2)	--same (vs 1.2)
	playerWrocket:setSystemCoolantRate("frontshield",	1.2)	--same (vs 1.2)
	playerWrocket:setSystemCoolantRate("rearshield",	1.05)	--less (vs 1.2)
	playerWrocket:setSystemCoolantRate("missilesystem",	1.05)	--less (vs 1.2)
	playerWrocket:setSystemPowerRate("reactor",			0.4)	--more (vs 0.30)
	playerWrocket:setSystemPowerRate("beamweapons",		0.25)	--less (vs 0.30)
	playerWrocket:setSystemPowerRate("jumpdrive",		0.325)	--more (vs 0.30)
	playerWrocket:setSystemPowerRate("maneuver",		0.275)	--less (vs 0.30)
	playerWrocket:setSystemPowerRate("impulse",			0.375)	--more (vs 0.30)
	playerWrocket:setSystemPowerRate("frontshield",		0.325)	--more (vs 0.30)
	playerWrocket:setSystemPowerRate("rearshield",		0.2)	--less (vs 0.30)	
	playerWrocket:setSystemPowerRate("missilesystem",	0.2)	--less (vs 0.30)	
	playerWrocket:onTakingDamage(playerShipDamage)
	playerWrocket:addReputationPoints(50)
	return playerWrocket
end
function createPlayerShipSloop()
	playerSloop = PlayerSpaceship():setTemplate("Phobos M3P"):setFaction("Human Navy"):setCallSign("Levant")
	setBeamColor(playerSloop)
	playerSloop:setTypeName("Sloop")
	playerSloop:setRepairCrewCount(5)				--more repair crew (vs 3)
	playerSloop:setJumpDrive(true)
	playerSloop.max_jump_range = 35000				--shorter than typical (vs 50)
	playerSloop.min_jump_range = 3500				--shorter than typical (vs 5)
	playerSloop:setJumpDriveRange(playerSloop.min_jump_range,playerSloop.max_jump_range)
	playerSloop:setJumpDriveCharge(playerSloop.max_jump_range)
	playerSloop:setImpulseMaxSpeed(90)				--faster impulse max (vs 80)
	playerSloop:setRotationMaxSpeed(15)				--faster spin (vs 10)
	playerSloop:setAcceleration(15)					--slower acceleration (vs 20)
--                 				Arc, Dir, Range, CycleTime, Damage
	playerSloop:setBeamWeapon(0, 40,  10,	 1200,	   8.0, 6)	--narrower (vs 90 deg) 
	playerSloop:setBeamWeapon(1, 40, -10,	 1200,	   8.0, 6)	--narrower (vs 90 deg) 
	playerSloop:setWeaponTubeCount(5)					--more (vs 3)
	playerSloop:setWeaponTubeDirection(0, 10)			--more angled (vs  -1)	
	playerSloop:setWeaponTubeDirection(1,-10)			--more angled (vs   1)	
	playerSloop:setWeaponTubeDirection(3,170)	
	playerSloop:setWeaponTubeDirection(4,190)
	playerSloop:setWeaponTubeExclusiveFor(0,"Homing")	--Homing (vs all but mine)
	playerSloop:setWeaponTubeExclusiveFor(1,"Homing")	--Homing (vs all but mine)
	playerSloop:setWeaponTubeExclusiveFor(3,"Mine")
	playerSloop:setWeaponTubeExclusiveFor(4,"Mine")
	playerSloop:setWeaponStorageMax("Homing",12)		--more (vs 10)
	playerSloop:setWeaponStorage("Homing", 12)
	playerSloop:setWeaponStorageMax("Mine",6)			--more (vs 4)
	playerSloop:setWeaponStorage("Mine", 6)
	playerSloop:setWeaponStorageMax("Nuke",0)			--less (vs 2)
	playerSloop:setWeaponStorage("Nuke", 0)
	playerSloop:setWeaponStorageMax("EMP",0)			--less (vs 3)
	playerSloop:setWeaponStorage("EMP", 0)
	playerSloop:setWeaponStorageMax("HVLI",0)			--less (vs 3)
	playerSloop:setWeaponStorage("HVLI", 0)
	playerSloop:onTakingDamage(playerShipDamage)
	playerSloop:addReputationPoints(50)
	return playerSloop	
end
function createplayerShipSneak()
	playerSneak = PlayerSpaceship():setTemplate("Repulse"):setTypeName("Skray"):setFaction("Human Navy"):setCallSign("5N3AK-E")
	setBeamColor(playerSneak)
	playerSneak:setWeaponStorageMax("Homing", 10)
	playerSneak:setWeaponStorage("Homing", 10)
	playerSneak:setWeaponStorageMax("HVLI", 10)
	playerSneak:setWeaponStorage("HVLI", 10)
--                 				 Arc, Dir, Range, CycleTime, Damage
	playerSneak:setBeamWeapon(0,  10, -70,	1200, 		6.0, 	5.0)
	playerSneak:setBeamWeapon(1,  10,  70,	1200, 		6.0,	5.0)
--										Arc,  Dir, Rotate speed
	playerSneak:setBeamWeaponTurret(0,	 30,  -70,			5)
	playerSneak:setBeamWeaponTurret(1,	 30,   70,			5)
	playerSneak:setShortRangeRadarRange(7500)
	playerSneak:onTakingDamage(playerShipDamage)
	playerSneak:addReputationPoints(50)
	return playerSneak
end
function createPlayerShipSparrow()
	playerSparrow = PlayerSpaceship():setTemplate("Player Fighter"):setFaction("Human Navy"):setCallSign("Sparrow")
	setBeamColor(playerSparrow)
	playerSparrow:setTypeName("Vermin")
	playerSparrow:setRepairCrewCount(4)						--more repair crew (vs 3)
	playerSparrow:setMaxEnergy(500)							--more maximum energy (vs 400)
	playerSparrow:setEnergy(500)							
	playerSparrow:setWarpDrive(true)						--warp drive (vs none)
	playerSparrow:setWarpSpeed(900)
	playerSparrow:setShieldsMax(100,60)						--stronger shields (vs 40)
	playerSparrow:setShields(100,60)
	playerSparrow:setBeamWeapon(0, 12,   0, 1000, 6, 4)		--3 beams (vs 2)
	playerSparrow:setBeamWeapon(1, 40, -10,  800, 6, 6)	
	playerSparrow:setBeamWeapon(2, 40,  10,  800, 6, 6)	
	playerSparrow:setWeaponTubeCount(2)						--more (vs 1)
	playerSparrow:setWeaponTubeExclusiveFor(0,"HVLI")
	playerSparrow:setTubeSize(0,"small")					--small (vs medium)
	playerSparrow:setTubeLoadTime(1,20)						--slower (vs 10)
	playerSparrow:setWeaponTubeDirection(1,180)
	playerSparrow:setWeaponTubeExclusiveFor(1,"Mine")
	playerSparrow:setWeaponStorageMax("HVLI", 10)			--more (vs 4)
	playerSparrow:setWeaponStorage("HVLI", 10)
	playerSparrow:setWeaponStorageMax("Mine",6)				--more Mines (vs 0)
	playerSparrow:setWeaponStorage("Mine",6)
	playerSparrow:onTakingDamage(playerShipDamage)
	playerSparrow:addReputationPoints(50)
	return playerSparrow
end
function createPlayerShipSplinter()
	playerFresnel = PlayerSpaceship():setTemplate("Player Fighter"):setFaction("Human Navy"):setCallSign("Splinter")
	setBeamColor(playerFresnel)
	playerFresnel:setTypeName("Fresnel")
	playerFresnel:setRadarTrace("ktlitan_fighter.png")	--different radar trace
	playerFresnel:setMaxEnergy(500)								--more maximum energy (vs 400)
	playerFresnel:setEnergy(500)
	playerFresnel:setShieldsMax(120,80)							--stronger shields (vs 40)
	playerFresnel:setShields(120,80)
	playerFresnel:setJumpDrive(true)							--jump drive (vs none)
	playerFresnel.max_jump_range = 20000						--shorter than typical (vs 50)
	playerFresnel.min_jump_range = 2000							--shorter than typical (vs 5)
	playerFresnel:setSystemPowerFactor("jumpdrive",3.5)			--more efficient (vs 5)
	playerFresnel:setJumpDriveRange(playerFresnel.min_jump_range,playerFresnel.max_jump_range)
	playerFresnel:setJumpDriveCharge(playerFresnel.max_jump_range)
--                 				   Arc, Dir, Range, CycleTime, Damage
	playerFresnel:setBeamWeapon(0,	 5,   0,	2300, 		6.0, 	1.5)
	playerFresnel:setBeamWeapon(1,  10, -20,	 800, 		6.0, 	4.0)	
	playerFresnel:setBeamWeapon(2,  10,  20,	 800, 		6.0,	4.0)
--										   Arc,  Dir, Rotate speed
	playerFresnel:setBeamWeaponTurret(1,	60,  -20,		 .3)		--slow turret
	playerFresnel:setBeamWeaponTurret(2,	60,   20,		 .3)
	playerFresnel:setWeaponTubeCount(2)							--more (vs 1)
	playerFresnel:setWeaponTubeDirection(0,120)					--angled rear (vs front)
	playerFresnel:setWeaponTubeDirection(1,240)					--angled rear (vs none)
	playerFresnel:setWeaponTubeExclusiveFor(0,"Homing")			--homing only (vs HVLI)
	playerFresnel:setWeaponTubeExclusiveFor(2,"Homing")
	playerFresnel:setWeaponStorageMax("HVLI",  0)				--fewer HVLI (vs 4)
	playerFresnel:setWeaponStorage("HVLI",     0)				
	playerFresnel:setWeaponStorageMax("Homing",4)				--more homing (vs 0)
	playerFresnel:setWeaponStorage("Homing",   4)
	playerFresnel.turbo_torp_factor = 3
	playerFresnel:onTakingDamage(playerShipDamage)
	playerFresnel:addReputationPoints(50)
	return playerFresnel
end
function createPlayerShipSpyder()
	--experimental
	playerSpyder = PlayerSpaceship():setTemplate("Atlantis"):setFaction("Human Navy"):setCallSign("Spyder")
	setBeamColor(playerSpyder)
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
	playerSpyder:setSystemCoolantRate("reactor",			1.3)	--more (vs 1.2)
	playerSpyder:setSystemCoolantRate("jumpdrive",		1.2)	--same (vs 1.2)
	playerSpyder:setSystemCoolantRate("beamweapons",		1.15)	--less (vs 1.2)
	playerSpyder:setSystemCoolantRate("maneuver",		1.05)	--less (vs 1.2)
	playerSpyder:setSystemCoolantRate("impulse",			1.2)	--same (vs 1.2)
	playerSpyder:setSystemCoolantRate("frontshield",		1.05)	--less (vs 1.2)
	playerSpyder:setSystemCoolantRate("rearshield",		1.15)	--less (vs 1.2)
	playerSpyder:setSystemCoolantRate("missilesystem",	1.3)	--more (vs 1.2)
	playerSpyder:setSystemPowerRate("reactor",			0.375)	--more (vs 0.30)
	playerSpyder:setSystemPowerRate("beamweapons",		0.3)	--same (vs 0.30)
	playerSpyder:setSystemPowerRate("jumpdrive",		0.325)	--more (vs 0.30)
	playerSpyder:setSystemPowerRate("maneuver",			0.25)	--less (vs 0.30)
	playerSpyder:setSystemPowerRate("impulse",			0.275)	--less (vs 0.30)
	playerSpyder:setSystemPowerRate("frontshield",		0.25)	--less (vs 0.30)
	playerSpyder:setSystemPowerRate("rearshield",		0.3)	--same (vs 0.30)	
	playerSpyder:setSystemPowerRate("missilesystem",	0.325)	--more (vs 0.30)	
	playerSpyder:onTakingDamage(playerShipDamage)
	playerSpyder:addReputationPoints(50)
	return playerSpyder
end
function createPlayerShipStick()
	local base_template = "Hathcock"
	local hot_template = "Surkov"
	local ship = PlayerSpaceship():setTemplate(base_template):setFaction("Human Navy"):setCallSign("Spike")
	setBeamColor(ship)
	--aka stick or spike
	ship.combat_maneuver_boost = stock_combat_maneuver[base_template].boost
	ship.combat_maneuver_strafe = stock_combat_maneuver[base_template].strafe
	ship.beam_damage_type = stock_beam_damage_type[base_template]
	ship.beam_damage_type[1] = "emp"
	ship.beam_damage_type[2] = "emp"
	ship.tube_direction = {-90,90,180}
	ship.tube_ordnance = {"Homing, HVLI","Homing, HVLI","Mine"}
	ship:setTypeName(hot_template)
	ship:setRepairCrewCount(3)	--more repair crew (vs 2)
	ship:setImpulseMaxSpeed(60)	--faster impulse max (vs 50)
	ship:setJumpDrive(false)		--no jump
	ship:setWarpDrive(true)		--add warp
	ship:setWarpSpeed(500)
	ship:setShieldsMax(80,120)	--stronger (vs 70,70)
	ship:setShields(80,120)
	ship:setHullMax(175)			--stronger (vs 120)
	ship:setHull(175)
--                 		   Arc, Dir,   Range, Cycle,  Dmg
	ship:setBeamWeapon(0,	10,  40,	1200,	6.0,	5)	--stronger (vs 4), shorter range (vs 1400), angled
	ship:setBeamWeapon(1,	10, -40,	1200,	6.0,	5)	--stronger (vs 4), angled
	ship:setBeamWeapon(2,	50,  10,	 900,	6.0,	7)	--stronger (vs 4), shorter range (vs 1000), angled
	ship:setBeamWeapon(3,	50, -10,	 900,	6.0,	7)	--stronger (vs 4), longer range (vs 800), angled
--								Arc,   Dir,  Rotate
	ship:setBeamWeaponTurret(0,	120,	40,		0.5):setBeamWeaponDamageType(0,"emp")
	ship:setBeamWeaponTurret(1,	120,   -40,		0.5):setBeamWeaponDamageType(1,"emp")
	ship:setWeaponTubeCount(3)	--one more tube for mines, no other splash ordnance
	ship:setWeaponTubeDirection(0, -90)
	ship:weaponTubeDisallowMissle(0,"Mine")
	ship:weaponTubeDisallowMissle(0,"Nuke")
	ship:weaponTubeDisallowMissle(0,"EMP")
	ship:setWeaponStorageMax("Mine",3)		--more (vs 0)
	ship:setWeaponStorage("Mine",3)
	ship:setWeaponStorageMax("Nuke",0)		--less
	ship:setWeaponStorage("Nuke",0)
	ship:setWeaponStorageMax("EMP",0)		--less
	ship:setWeaponStorage("EMP",0)
	ship:setWeaponTubeDirection(1, 90)
	ship:weaponTubeDisallowMissle(1,"Mine")
	ship:weaponTubeDisallowMissle(1,"Nuke")
	ship:weaponTubeDisallowMissle(1,"EMP")
	ship:setWeaponTubeDirection(2,180)
	ship:setWeaponTubeExclusiveFor(2,"Mine")
	ship:setTubeLoadTime(2, 20)				--slower (vs 15)
	ship:setSystemCoolantRate("warp",			1.4)	--more (vs 1.2) pump is here
	ship:setSystemCoolantRate("reactor",			1.35)	--more (vs 1.2)
	ship:setSystemCoolantRate("beamweapons",		1.1)	--less (vs 1.2)
	ship:setSystemCoolantRate("impulse",			1.3)	--more (vs 1.2)
	ship:setSystemCoolantRate("frontshield",		1.1)	--less (vs 1.2)
	ship:setSystemCoolantRate("missilesystem",	1.05)	--less (vs 1.2)
	ship:setSystemCoolantRate("rearshield",		1.35)	--more (vs 1.2)
	ship:setSystemPowerRate("reactor",			0.40)	--more (vs 0.30)
	ship:setSystemPowerRate("warp",				0.375)	--more (vs 0.30)
	ship:setSystemPowerRate("beamweapons",		0.225)	--less (vs 0.30)
	ship:setSystemPowerRate("maneuver",			0.275)	--less (vs 0.30)
	ship:setSystemPowerRate("impulse",			0.325)	--more (vs 0.30)
	ship:setSystemPowerRate("frontshield",		0.35)	--more (vs 0.30)
	ship:setSystemPowerRate("rearshield",		0.35)	--more (vs 0.30)
--	ship:setSystemHeatRate("beamweapons",	.5)	--more (vs .05) Lingling	
	createShipReference(ship)
	ship.ship_reference["Diff Sum"] = {ord = 2, desc = "Surkov is based on Hathcock\nDifferences: Faster impulse (vs 50), Warp instead of Jump, stronger shields (vs 70/70), stronger hull (vs 120), more repair crew (vs 2), different beam configuration: longer turreted beams hit shields, divergent coolant and power rates, different tube and magazine configuration"}
	addShipReference(ship)
	ship:onTakingDamage(playerShipDamage)
	ship:addReputationPoints(50)
	return ship
end
function createPlayerShipSting()
	--sent to Kraylor war front. May return later
	local base_template = "Hathcock"
	local hot_template = "Surkov"
	local ship = PlayerSpaceship():setTemplate(base_template):setFaction("Human Navy"):setCallSign("Sting")
	setBeamColor(ship)
	ship.combat_maneuver_boost = stock_combat_maneuver[base_template].boost
	ship.combat_maneuver_strafe = stock_combat_maneuver[base_template].strafe
	ship.beam_damage_type = stock_beam_damage_type[base_template]
	ship.tube_direction = {-90,90,180}
	ship.tube_ordnance = {"Homing,HVLI","Homing,HVLI","Mine"}
	ship:setTypeName(hot_template)
	ship:setRepairCrewCount(4)	--more repair crew (vs 2)
	ship:setImpulseMaxSpeed(60)	--faster impulse max (vs 50)
	ship:setRotationMaxSpeed(20)	--faster spin (vs 15)
	ship:setJumpDrive(false)		--no jump
	ship:setWarpDrive(true)		--add warp
	ship:setWarpSpeed(400)
	ship:setWeaponTubeCount(3)	--one more tube for mines, no other splash ordnance
	ship:setWeaponTubeDirection(0, -90)
	ship:weaponTubeDisallowMissle(0,"Mine")
	ship:weaponTubeDisallowMissle(0,"Nuke")
	ship:weaponTubeDisallowMissle(0,"EMP")
	ship:setWeaponStorageMax("Mine",3)
	ship:setWeaponStorage("Mine",3)
	ship:setWeaponStorageMax("Nuke",0)
	ship:setWeaponStorage("Nuke",0)
	ship:setWeaponStorageMax("EMP",0)
	ship:setWeaponStorage("EMP",0)
	ship:setWeaponTubeDirection(1, 90)
	ship:weaponTubeDisallowMissle(1,"Mine")
	ship:weaponTubeDisallowMissle(1,"Nuke")
	ship:weaponTubeDisallowMissle(1,"EMP")
	ship:setWeaponTubeDirection(2,180)
	ship:setWeaponTubeExclusiveFor(2,"Mine")
	createShipReference(ship)
	ship.ship_reference["Diff Sum"] = {ord = 2, desc = "Surkov is based on Hathcock\nDifferences: More repair crew (vs 2), faster impulse (vs 50), faster spin (vs 15), warp drive (vs jump), more tubes (vs 2), different tube configuration"}
	addShipReference(ship)
	ship:onTakingDamage(playerShipDamage)
	ship:addReputationPoints(50)
	return ship
end
function createPlayerShipTango()
	playerTwister = PlayerSpaceship():setTemplate("Hathcock"):setFaction("Human Navy"):setCallSign("Tango")
	setBeamColor(playerTwister)
	playerTwister:setTypeName("Twister")
	playerTwister:setRadarTrace("ktlitan_destroyer.png")				--different radar trace
	playerTwister:setRepairCrewCount(5)		--more repair crew (vs 2)
	playerTwister:setShieldsMax(100,120)	--stronger (vs 70,70)
	playerTwister:setShields(100,120)
	playerTwister:setRotationMaxSpeed(10)	--slower spin (vs 15)
	playerTwister:setAcceleration(25)		--faster (vs 8)
	playerTwister:setJumpDrive(false)		--no jump
	playerTwister:setWarpDrive(true)		--add warp (vs jump)
	playerTwister:setWarpSpeed(425)
	playerTwister:setMaxEnergy(800)			--less maximum energy (vs 1000)
	playerTwister:setEnergy(800)							
--                 				   Arc, Dir,   Range, CycleTime, Damage
	playerTwister:setBeamWeapon(0,  10,   0,	1000, 		6.0, 	5.0)	--2 turreted beams (vs 4 fixed)
	playerTwister:setBeamWeapon(1,  10, 180,	1000, 		6.0,	5.0)	--full coverage (vs forward focused), more dmg/beam (vs 4)
	playerTwister:setBeamWeapon(2,   0,   0,	   0, 		  0,	  0)
	playerTwister:setBeamWeapon(3,   0,   0,	   0, 		  0,	  0)
--											Arc,  Dir, Rotate speed
	playerTwister:setBeamWeaponTurret(0,	190,    0,			 .4)		--slow turret
	playerTwister:setBeamWeaponTurret(1,	190,  180,			 .4)		--slow turret
	playerTwister:setWeaponTubeCount(6)					--more (vs 2)
	playerTwister:setWeaponTubeDirection(0,  0)			--front (vs side)
	playerTwister:setWeaponTubeDirection(1,-10)			--angled front (vs side)
	playerTwister:setWeaponTubeDirection(2, 10)
	playerTwister:setWeaponTubeDirection(3,170)
	playerTwister:setWeaponTubeDirection(4,190)
	playerTwister:setWeaponTubeDirection(5,180)
	playerTwister:setWeaponTubeExclusiveFor(0,"HVLI")	--HVLI (vs any)
	playerTwister:setWeaponTubeExclusiveFor(1,"Homing")	--Homing (vs any)
	playerTwister:setWeaponTubeExclusiveFor(2,"Homing")
	playerTwister:setWeaponTubeExclusiveFor(3,"EMP")
	playerTwister:weaponTubeAllowMissle(3,"Nuke")
	playerTwister:setWeaponTubeExclusiveFor(4,"EMP")
	playerTwister:weaponTubeAllowMissle(4,"Nuke")
	playerTwister:setWeaponTubeExclusiveFor(5,"Mine")
	playerTwister:setTubeSize(1,"large")				--large (vs medium)
	playerTwister:setTubeSize(2,"large")				--large (vs medium)
	playerTwister:setTubeLoadTime(0, 5)					--faster (vs 15)
	playerTwister:setTubeLoadTime(1, 10)				--faster (vs 15)
	playerTwister:setTubeLoadTime(2, 10)
	playerTwister:setTubeLoadTime(3, 20)
	playerTwister:setTubeLoadTime(4, 20)
	playerTwister:setWeaponStorageMax("HVLI",  16)		--more (vs 8)
	playerTwister:setWeaponStorageMax("Homing", 8)		--more (vs 4)
	playerTwister:setWeaponStorageMax("EMP",    6)		--more (vs 2)
	playerTwister:setWeaponStorageMax("Nuke",   4)		--more (vs 1)
	playerTwister:setWeaponStorageMax("Mine",   4)
	playerTwister:setWeaponStorage("HVLI",     16)
	playerTwister:setWeaponStorage("Homing",    8)
	playerTwister:setWeaponStorage("EMP",       6)
	playerTwister:setWeaponStorage("Nuke",      4)
	playerTwister:setWeaponStorage("Mine",      4)
	playerTwister:setSystemCoolantRate("reactor",		1.4)	--more (vs 1.2)
	playerTwister:setSystemCoolantRate("warp",			1.35)	--more (vs 1.2)
	playerTwister:setSystemCoolantRate("beamweapons",	1.1)	--less (vs 1.2)
	playerTwister:setSystemCoolantRate("maneuver",		1.15)	--less (vs 1.2)
	playerTwister:setSystemCoolantRate("impulse",		1.25)	--more (vs 1.2)
	playerTwister:setSystemCoolantRate("frontshield",	1.15)	--less (vs 1.2)
	playerTwister:setSystemCoolantRate("rearshield",	1.3)	--more (vs 1.2)
	playerTwister:setSystemCoolantRate("missilesystem",	1.1)	--less (vs 1.2)
	playerTwister:setSystemPowerRate("reactor",			0.40)	--more (vs 0.30)
	playerTwister:setSystemPowerRate("beamweapons",		0.225)	--less (vs 0.30)
	playerTwister:setSystemPowerRate("warp",			0.35)	--more (vs 0.30)
	playerTwister:setSystemPowerRate("maneuver",		0.25)	--less (vs 0.30)
	playerTwister:setSystemPowerRate("impulse",			0.3)	--same (vs 0.30)
	playerTwister:setSystemPowerRate("frontshield",		0.3)	--same (vs 0.30)
	playerTwister:setSystemPowerRate("rearshield",		0.325)	--more (vs 0.30)	
	playerTwister:setSystemPowerRate("missilesystem",	0.275)	--less (vs 0.30)	
	playerTwister:onTakingDamage(playerShipDamage)
	playerTwister:addReputationPoints(50)
	return playerTwister
end
function createPlayerShipTerror()
	playerPhobosT2 = PlayerSpaceship():setTemplate("Phobos M3P"):setFaction("Human Navy"):setCallSign("Terror")
	setBeamColor(playerPhobosT2)
	playerPhobosT2:setTypeName("Phobos T2.2")
	playerPhobosT2:setRepairCrewCount(4)					--more repair crew (vs 3)
	playerPhobosT2:setJumpDrive(true)						--jump drive (vs none)
	playerPhobosT2.max_jump_range = 25000					--shorter than typical (vs 50)
	playerPhobosT2.min_jump_range = 2000						--shorter than typical (vs 5)
	playerPhobosT2:setJumpDriveRange(playerPhobosT2.min_jump_range,playerPhobosT2.max_jump_range)
	playerPhobosT2:setJumpDriveCharge(playerPhobosT2.max_jump_range)
	playerPhobosT2:setRotationMaxSpeed(20)					--faster spin (vs 10)
	playerPhobosT2:setShieldsMax(120,80)					--stronger front, weaker rear (vs 100,100)
	playerPhobosT2:setShields(120,80)
	playerPhobosT2:setMaxEnergy(800)						--less maximum energy (vs 1000)
	playerPhobosT2:setEnergy(800)
--                 				   Arc, Dir, Range, CycleTime, Dmg
	playerPhobosT2:setBeamWeapon(0, 10, -30,  1200,         4, 6)	--split direction (30 vs 15)
	playerPhobosT2:setBeamWeapon(1, 10,  30,  1200,         4, 6)	--reduced cycle time (4 vs 8)
--										 Arc, Dir, Rotate speed
	playerPhobosT2:setBeamWeaponTurret(0, 40, -30, .2)		--slow turret beams
	playerPhobosT2:setBeamWeaponTurret(1, 40,  30, .2)
	playerPhobosT2:setWeaponTubeCount(2)					--one fewer tube (1 forward, 1 rear vs 2 forward, 1 rear)
	playerPhobosT2:setWeaponTubeDirection(0,0)				--first tube points straight forward
	playerPhobosT2:setWeaponTubeDirection(1,180)			--second tube points straight back
	playerPhobosT2:setWeaponTubeExclusiveFor(1,"Mine")
	playerPhobosT2:setWeaponStorageMax("Homing",8)			--reduce homing storage (vs 10)
	playerPhobosT2:setWeaponStorage("Homing",8)
	playerPhobosT2:setWeaponStorageMax("HVLI",16)			--reduce HVLI storage (vs 20)
	playerPhobosT2:setWeaponStorage("HVLI",16)
	playerPhobosT2:onTakingDamage(playerShipDamage)
	playerPhobosT2:addReputationPoints(50)
	return playerPhobosT2
end
function createPlayerShipThelonius()
	playerThelonius = PlayerSpaceship():setTemplate("Crucible"):setFaction("Human Navy"):setCallSign("Thelonius")
	setBeamColor(playerThelonius)
	playerThelonius:setTypeName("Crab")
	playerThelonius:setWarpSpeed(450)						--slower (vs 750)
	playerThelonius:setShieldsMax(280,280)					--stronger (vs 160,160) Lingling effect
	playerThelonius:setShields(280,280)
--                 				 	Arc, Dir,  Range, CycleTime, Damage
	playerThelonius:setBeamWeapon(0, 10, 165,	1000, 		6.0, 	6.0)	--turreted, stronger (vs fixed, 5 Dmg)
	playerThelonius:setBeamWeapon(1, 10, 195,	1000, 		6.0,	6.0)	--rear facing
--										   Arc, Dir, Rotate speed
	playerThelonius:setBeamWeaponTurret(0,	70,	165,		 .5)		--slow turret
	playerThelonius:setBeamWeaponTurret(1,	70,	195,		 .5)		--slow turret
	playerThelonius:setWeaponTubeCount(5)					--fewer (vs 6), no mine tube or mines
	playerThelonius:setTubeSize(0,"large")					--large (vs small)
	playerThelonius:setTubeSize(1,"small")					--small (vs normal)
	playerThelonius:setWeaponTubeDirection(1,-20)			--angled (vs zero degrees)
	playerThelonius:setWeaponTubeExclusiveFor(1,"Homing")	--homing only (vs HVLI)
	playerThelonius:setTubeSize(2,"small")					--medium (vs large)
	playerThelonius:setWeaponTubeDirection(2, 20)			--angled (vs zero degrees)
	playerThelonius:setWeaponTubeExclusiveFor(2,"Homing")	--homing only (vs HVLI)
	playerThelonius:setWeaponStorageMax("Homing",16)		--more (vs 8)
	playerThelonius:setWeaponStorage("Homing", 16)				
	playerThelonius:setWeaponStorageMax("EMP",3)			--fewer (vs 6)
	playerThelonius:setWeaponStorage("EMP", 3)				
	playerThelonius:setWeaponStorageMax("Nuke",2)			--fewer (vs 4)
	playerThelonius:setWeaponStorage("Nuke", 2)				
	playerThelonius:setWeaponStorageMax("Mine",0)			--fewer (vs 6)
	playerThelonius:setWeaponStorage("Mine", 0)				
	playerThelonius:setWeaponStorageMax("HVLI",16)			--fewer (vs 24)
	playerThelonius:setWeaponStorage("HVLI", 16)		
--	playerThelonius:setSystemHeatRate("reactor",		.8)	--more (vs .05) Lingling	
--	playerThelonius:setSystemHeatRate("beamweapons",	.8)	--more (vs .05) Lingling	
--	playerThelonius:setSystemHeatRate("missilesystem",	.5)	--more (vs .05) Lingling	
--	playerThelonius:setSystemHeatRate("impulse",		.5)	--more (vs .05) Lingling	
--	playerThelonius:setSystemHeatRate("warp",			.5)	--more (vs .05) Lingling	
	playerThelonius:setSystemHeatRate("frontshield",	1)	--more (vs .05) Lingling	
	playerThelonius:setSystemHeatRate("rearshield",		1)	--more (vs .05) Lingling	
	playerThelonius:onTakingDamage(playerShipDamage)
	playerThelonius:addReputationPoints(50)
	return playerThelonius
end
function createPlayerShipThunderbird()
	--destroyed 29Feb2020
	local base_template = "Player Cruiser"
	local hot_template = "Destroyer IV"
	local ship = PlayerSpaceship():setTemplate(base_template):setFaction("Human Navy"):setCallSign("Thunderbird")
	setBeamColor(ship)
	ship.combat_maneuver_boost = stock_combat_maneuver[base_template].boost
	ship.combat_maneuver_strafe = stock_combat_maneuver[base_template].strafe
	ship.beam_damage_type = stock_beam_damage_type[base_template]
	ship.tube_direction = {-60,60,180}
	ship.tube_ordnance = {"all but Mine","all but Mine","Mine"}
	ship:setTypeName(hot_template)
	ship.max_jump_range = 28000					--shorter than typical (vs 50)
	ship.min_jump_range = 3000						--shorter than typical (vs 5)
	ship:setJumpDriveRange(ship.min_jump_range,ship.max_jump_range)
	ship:setJumpDriveCharge(ship.max_jump_range)
	ship:setShieldsMax(100, 100)					--stronger shields (vs 80, 80)
	ship:setShields(100, 100)
	ship:setHullMax(150)							--weaker hull (vs 200)
	ship:setHull(150)
	ship:setBeamWeapon(0, 40, -10, 1000.0, 5, 6)	--narrower (40 vs 90), faster (5 vs 6), weaker (6 vs 10)
	ship:setBeamWeapon(1, 40,  10, 1000.0, 5, 6)
	ship:setWeaponTubeDirection(0,-60)				--left -60 (vs -5)
	ship:setWeaponTubeDirection(1, 60)				--right 60 (vs 5)
	ship:setWeaponStorageMax("Homing",8)			--less (vs 12)
	ship:setWeaponStorage("Homing", 8)				
	ship:setWeaponStorageMax("Nuke",2)				--fewer (vs 4)
	ship:setWeaponStorage("Nuke", 2)				
	ship:setWeaponStorageMax("EMP",4)				--fewer (vs 6)
	ship:setWeaponStorage("EMP", 4)				
	ship:setWeaponStorageMax("Mine",6)				--fewer (vs 8)
	ship:setWeaponStorage("Mine", 6)				
	ship:setWeaponStorageMax("HVLI",12)				--more (vs 0)
	ship:setWeaponStorage("HVLI", 12)				
	createShipReference(ship)
	ship.ship_reference["Diff Sum"] = {ord = 2, desc = "Destroyer IV is based on Player Cruiser\nDifferences: Shorter jump (vs 50), stronger shields (100 vs 80), weaker hull (150 vs 200), narrower, faster, weaker beams, different tube angles and missile load out"}
	addShipReference(ship)
	ship:onTakingDamage(playerShipDamage)
	ship:addReputationPoints(50)
	return ship
end
function createPlayerShipDominant()
	local base_template = "Atlantis"
	local hot_template = "Triumph"
	local ship = PlayerSpaceship():setTemplate(base_template):setFaction("Human Navy"):setCallSign("Dominant")
	setBeamColor(ship)
	ship.combat_maneuver_boost = stock_combat_maneuver[base_template].boost
	ship.combat_maneuver_strafe = stock_combat_maneuver[base_template].strafe
	ship.beam_damage_type = stock_beam_damage_type[base_template]
	ship.tube_direction = {-90,90,-90,90,180}
	ship.tube_ordnance = {"Homing","Homing","all but Mine","all but Mine","Mine"}
	ship:setTypeName(hot_template)
	ship.max_jump_range = 30000					--shorter (vs 50)
	ship.min_jump_range = 3000						--shorter (vs 5)
	ship:setJumpDriveRange(ship.min_jump_range,ship.max_jump_range)
	ship:setJumpDriveCharge(ship.max_jump_range)
	ship:setHullMax(180)							--weaker hull (vs 250)
	ship:setHull(180)
	ship:setRotationMaxSpeed(15)					--faster spin (vs 10)
	ship:setAcceleration(30,25)					--faster (vs 20/20)
	ship:setImpulseMaxSpeed(90,80)					--slower reverse impulse (vs 90)
--                 				  Arc, Dir,  Range, CycleTime, Damage
	ship:setBeamWeapon(0, 60, -20, 1200.0,		  4.5, 6.5)	--narrower (vs 100), faster (vs 6), weaker (vs 8)
	ship:setBeamWeapon(1, 60,  20, 1200.0,		  4.5, 6.5)
	ship:setBeamWeapon(2, 10, -90, 1000.0,			4, 3.5)
	ship:setBeamWeapon(3, 10,  90, 1000.0,			4, 3.5)
--										 Arc, Dir, Rotate speed
	ship:setBeamWeaponTurret(2, 160, -90, 1)				--slow turret
	ship:setBeamWeaponTurret(3, 160,  90, 1)
	ship:setWeaponTubeDirection(1,  90)					--right (vs left)
	ship:setWeaponTubeDirection(2, -90)					--left (vs right)
	ship:setTubeSize(0,"large")							--large (vs medium)
	ship:setTubeSize(1,"large")							--large (vs medium)
	ship:setWeaponTubeExclusiveFor(0,"Homing")				--homing only (vs all)
	ship:setWeaponTubeExclusiveFor(1,"Homing")				--homing only (vs all)
	ship:setTubeLoadTime(0, 15)							--slower (vs 8)
	ship:setTubeLoadTime(1, 15)							--slower (vs 8)
	ship:setTubeLoadTime(4, 12)							--slower (vs 8)
	createShipReference(ship)
	ship.ship_reference["Diff Sum"] = {ord = 2, desc = "Triumph is based on Atlantis\nDifferences: Shorter jump (vs 50), weaker hull (vs 250), faster spin (vs 10), faster acceleration (vs 20), slower reverse impulse (vs 90), narrower beams (vs 100), faster beams (vs 6), weaker beams (vs 8), added two turreted beams, different tube configuration"}
	addShipReference(ship)
	ship:onTakingDamage(playerShipDamage)
	ship:addReputationPoints(50)
	return ship
end
function createPlayerShipTorch()
	playerTorch = PlayerSpaceship():setTemplate("Player Fighter"):setFaction("Human Navy"):setCallSign("Ignite")
	setBeamColor(playerTorch)
	playerTorch:setTypeName("Torch")
	playerTorch:setWarpDrive(true)					--add warp (vs none)
	playerTorch:setImpulseMaxSpeed(100)				--slower impulse max (vs 110)
	playerTorch:setAcceleration(30)					--slower (vs 40)
	playerTorch:setWarpSpeed(960)
	playerTorch:setShieldsMax(80)					--stronger shields (vs 40)
	playerTorch:setShields(80)
	playerTorch:setHullMax(120)						--stronger hull (vs 60)
	playerTorch:setHull(120)
	local update_data = {
		update = function (self, obj, delta)
			local upper_heat = 0.98
			local heat = extraMath.clamp(obj:getSystemHeat("beamweapons"),0,upper_heat)
			heat = heat/upper_heat
			--					Arc,  Dir, Range,		  Cycle Time, Dmg
			obj:setBeamWeapon(0, 90,    0,  1000, extraMath.lerp(6,3,heat),	3)
			obj:setBeamWeapon(1, 45, -7.5,   900, extraMath.lerp(6,2,heat),	4)
			obj:setBeamWeapon(2, 45,  7.5,   900, extraMath.lerp(6,2,heat),	4)
			obj:setBeamWeapon(3, 30,    0,   700, extraMath.lerp(6,1,heat),	5)
		end
	}
	update_system:addUpdate(playerTorch,"dynamic heating cycle beams", update_data)
	playerTorch:setWeaponTubeDirection(0,-180)			--back (vs front)
	playerTorch:setTubeLoadTime(0, 25)					--slower (vs 10)
	playerTorch:setWeaponTubeExclusiveFor(0,"Mine")		--mine only (vs HVLI)
	playerTorch:setWeaponStorageMax("HVLI",	0)			--less (vs 4)
	playerTorch:setWeaponStorage("HVLI", 	0)				
	playerTorch:setWeaponStorageMax("Mine",	4)			--more (vs 0)
	playerTorch:setWeaponStorage("Mine", 	4)				
	playerTorch:onTakingDamage(playerShipDamage)
	playerTorch:addReputationPoints(50)
	return playerTorch
end
function createPlayerShipVision()
	playerVision = PlayerSpaceship():setTemplate("Flavia P.Falcon"):setFaction("Human Navy"):setCallSign("Vision")
	setBeamColor(playerVision)
	playerVision:setTypeName("Era")
	playerVision:setRotationMaxSpeed(15)									--faster spin (vs 10)
--                 				 Arc, Dir, Range, CycleTime, Damage
	playerVision:setBeamWeapon(0,  10,   0,	1200, 		6.0, 	6.0)	--1 turret, 1 rear (vs 2 rear)
	playerVision:setBeamWeapon(1,  80, 180,	1200, 		6.0,	6.0)
--										Arc,  Dir, Rotate speed
	playerVision:setBeamWeaponTurret(0,	300,    0,			 .5)		--slow turret
	playerVision:setShieldsMax(100, 130)									--stronger rear shields (vs 70, 70)
	playerVision:setShields(100, 130)
	playerVision:setLongRangeRadarRange(50000)							--longer long range sensors (vs 30000)
	playerVision.normal_long_range_radar = 50000
	playerVision:onTakingDamage(playerShipDamage)
	playerVision:addReputationPoints(50)
	return playerVision
end
function createPlayerShipWiggy()
	playerWiggy = PlayerSpaceship():setTemplate("Flavia P.Falcon"):setFaction("Human Navy"):setCallSign("Wiggy")
	setBeamColor(playerWiggy)
	playerWiggy:setTypeName("Gull")
	playerWiggy:setRotationMaxSpeed(12)									--faster spin (vs 10)
--                 				 Arc, Dir, Range, CycleTime, Damage
	playerWiggy:setBeamWeapon(0,  10,   0,	1100, 		6.0, 	6.0)	--1 turret, 1 rear (vs 2 rear)
	playerWiggy:setBeamWeapon(1,  80, 180,	1100, 		6.0,	6.0)	--shorter (vs 1200)
--										Arc,  Dir, Rotate speed
	playerWiggy:setBeamWeaponTurret(0,	300,    0,			 .5)		--slow turret
	playerWiggy:setWarpDrive(false)						--no warp drive (vs warp)
	playerWiggy:setJumpDrive(true)						--jump drive (vs warp)
	playerWiggy.max_jump_range = 35000					--shorter than typical (vs 50)
	playerWiggy.min_jump_range = 3500					--shorter than typical (vs 5)
	playerWiggy:setJumpDriveRange(playerWiggy.min_jump_range,playerWiggy.max_jump_range)
	playerWiggy:setJumpDriveCharge(playerWiggy.max_jump_range)
	playerWiggy:setHullMax(120)							--stronger hull (vs 100)
	playerWiggy:setHull(120)
	playerWiggy:setShieldsMax(70, 120)					--stronger rear shields (vs 70, 70)
	playerWiggy:setShields(70, 120)
	playerWiggy:setMaxEnergy(800)						--less maximum energy (vs 1000)
	playerWiggy:setEnergy(800)
	playerWiggy:setLongRangeRadarRange(40000)			--longer long range sensors (vs 30000)
	playerWiggy.normal_long_range_radar = 40000
	playerWiggy:setWeaponStorageMax("Homing",5)
	playerWiggy:setWeaponStorage("Homing", 5)
	playerWiggy:setWeaponStorageMax("Mine",3)
	playerWiggy:setWeaponStorage("Mine", 3)
	playerWiggy:setWeaponStorageMax("Nuke",3)
	playerWiggy:setWeaponStorage("Nuke", 3)
	playerWiggy:onTakingDamage(playerShipDamage)
	playerWiggy:addReputationPoints(50)
	return playerWiggy
end
function createPlayerShipWatson()
	local base_template = "Crucible"
	local hot_template = "Holmes"
	local ship = PlayerSpaceship():setTemplate(base_template):setFaction("Human Navy"):setCallSign("Watson")
	setBeamColor(ship)
	ship.combat_maneuver_boost = stock_combat_maneuver[base_template].boost
	ship.combat_maneuver_strafe = stock_combat_maneuver[base_template].strafe
	ship.beam_damage_type = stock_beam_damage_type[base_template]
	ship.beam_damage_type[1] = "emp"
	ship.beam_damage_type[3] = "emp"
	ship.tube_direction = {0,0,0,180}
	ship.tube_ordnance = {"Homing","Homing","Homing","Mine"}
	ship:setTypeName(hot_template)
	ship:setImpulseMaxSpeed(70)						--slower (vs 80)
--                 		 Arc, Dir,  Range,CycleTime, Dmg
	ship:setBeamWeapon(0, 10, -90, 1000.0, 		3.0, 7):setBeamWeaponDamageType(0,"emp")
	ship:setBeamWeapon(1, 60, -90,  500.0, 		6.0, 8)	
	ship:setBeamWeapon(2, 10,  90, 1000.0, 		3.0, 7):setBeamWeaponDamageType(2,"emp")
	ship:setBeamWeapon(3, 60,  90,  500.0, 		6.0, 8)	
	for i=0,3 do
		ship:setBeamWeaponHeatPerFire(i,0.3)
		ship:setBeamWeaponEnergyPerFire(i,6)
	end
	ship:setWeaponTubeCount(4)						--fewer (vs 6)
	ship:setWeaponTubeExclusiveFor(0,"Homing")		--tubes only shoot homing missiles (vs more options)
	ship:setWeaponTubeExclusiveFor(1,"Homing")
	ship:setWeaponTubeExclusiveFor(2,"Homing")
	ship:setWeaponTubeExclusiveFor(3,"Mine")
	ship:setWeaponTubeDirection(3, 180)
	ship:setWeaponStorageMax("Homing",10)			--more (vs 8)
	ship:setWeaponStorage("Homing", 10)				
	ship:setWeaponStorageMax("HVLI",0)				--fewer
	ship:setWeaponStorage("HVLI", 0)				
	ship:setWeaponStorageMax("EMP",0)				--fewer
	ship:setWeaponStorage("EMP", 0)				
	ship:setWeaponStorageMax("Nuke",0)				--fewer
	ship:setWeaponStorage("Nuke", 0)	
	ship:setLongRangeRadarRange(35000)				--longer longer range sensors (vs 30000)
	ship.normal_long_range_radar = 35000
	ship:setShortRangeRadarRange(4000)				--shorter short range sensors (vs 5000)
	createShipReference(ship)
	ship.ship_reference["Diff Sum"] = {ord = 2, desc = "Holmes is based on Crucible\nDifferences: Slower impulse (vs 80), broadside beams (long beam only impacts shields) - more damage, heat, energy per fire, different tube and magazine configuration, longer sensor range"}
	addShipReference(ship)
	ship:onTakingDamage(playerShipDamage)
	ship:addReputationPoints(50)
	return ship
end
function createPlayerShipWesson()
	playerChavez = PlayerSpaceship():setTemplate("Hathcock"):setFaction("Human Navy"):setCallSign("Wesson")
	setBeamColor(playerChavez)
	playerChavez:setTypeName("Chavez")
	playerChavez:setRepairCrewCount(5)		--more (vs 2)
	playerChavez.maxRepairCrew = playerChavez:getRepairCrewCount()
	playerChavez.max_jump_range = 25000					--shorter than typical (vs 50)
	playerChavez.min_jump_range = 2500					--shorter than typical (vs 5)
	playerChavez:setJumpDriveRange(playerChavez.min_jump_range,playerChavez.max_jump_range)
	playerChavez:setJumpDriveCharge(playerChavez.max_jump_range)
	playerChavez:setImpulseMaxSpeed(70)		--faster (vs 50)
	playerChavez:setHullMax(160)			--stronger (vs 120)
	playerChavez:setHull(160)
	playerChavez:setRotationMaxSpeed(20)	--faster spin (vs 15)
	playerChavez:setAcceleration(10)		--faster (vs 8)
--      				           	Arc,  Dir,  Range,Cyc,Dmg
	playerChavez:setBeamWeapon(0,	 50,  -20,	 1200,	6,	4)	--fewer (vs 4)
	playerChavez:setBeamWeapon(1,	 50,   20,	 1200,	6,	4)
	playerChavez:setBeamWeapon(2,	  0,    0,	    0,	0,	0)
	playerChavez:setBeamWeapon(3,	  0,    0,	    0,	0,	0)
	playerChavez:setWeaponTubeCount(4)					--more (vs2)
	playerChavez:setWeaponTubeDirection(0, 0)
	playerChavez:setWeaponTubeExclusiveFor(0,"Homing")
	playerChavez:weaponTubeAllowMissle(0,"HVLI")
	playerChavez:setWeaponTubeDirection(1,-90)
	playerChavez:setWeaponTubeDirection(2,90)
	playerChavez:setWeaponTubeDirection(3,180)
	playerChavez:setWeaponTubeExclusiveFor(1,"EMP")
	playerChavez:setWeaponTubeExclusiveFor(2,"Nuke")
	playerChavez:setWeaponTubeExclusiveFor(3,"Mine")
	playerChavez:setWeaponStorageMax("Homing",	6)	--more (vs 4)
	playerChavez:setWeaponStorage("Homing",		6)
	playerChavez:setWeaponStorageMax("HVLI",	6)	--fewer (vs 8)
	playerChavez:setWeaponStorage("HVLI",   	6)
	playerChavez:setWeaponStorageMax("EMP", 	4)	--more (vs 2)
	playerChavez:setWeaponStorage("EMP",    	4)
	playerChavez:setWeaponStorageMax("Nuke",	2)	--more (vs 1)
	playerChavez:setWeaponStorage("Nuke",   	2)
	playerChavez:setWeaponStorageMax("Mine",	4)	--more (vs none)
	playerChavez:setWeaponStorage("Mine",   	4)
	playerChavez:setTubeLoadTime(0,10)				--faster (vs 15)
	playerChavez:setTubeLoadTime(1,15)	
	playerChavez:setTubeLoadTime(2,15)
	playerChavez:setTubeLoadTime(3,20)
--	playerChavez:setSystemHeatRate("beamweapons",	.5)	--more (vs .05) Lingling	
	playerChavez:onTakingDamage(playerShipDamage)
	playerChavez:addReputationPoints(50)
	return playerChavez
end
function createPlayerShipYorik()
	playerYorik = PlayerSpaceship():setTemplate("Repulse"):setFaction("Human Navy"):setCallSign("Yorik")
	setBeamColor(playerYorik)
	playerYorik:setTypeName("Rook")
	playerYorik.max_jump_range = 30000					--shorter than typical (vs 50)
	playerYorik.min_jump_range = 3000						--shorter than typical (vs 5)
	playerYorik:setJumpDriveRange(playerYorik.min_jump_range,playerYorik.max_jump_range)
	playerYorik:setJumpDriveCharge(playerYorik.max_jump_range)
	playerYorik:setImpulseMaxSpeed(75)					--faster impulse max (vs 55)
	playerYorik:setRotationMaxSpeed(8)					--slower spin (vs 9)
	playerYorik:setHullMax(200)							--stronger hull (vs 120)
	playerYorik:setHull(200)
	playerYorik:setShieldsMax(200, 100)					--stronger shields (vs 80, 80)
	playerYorik:setShields(200, 100)
--                 				 Arc, Dir, Range, CycleTime, Damage
	playerYorik:setBeamWeapon(0,  10, -25,	1000, 		6.0, 	4.0)	--front facing (vs left/right with overlap in front and back
	playerYorik:setBeamWeapon(1,  10,  25,	1000, 		6.0,	4.0)	--shorter (vs 1200), weaker (vs 5)
--										Arc,  Dir, Rotate speed
	playerYorik:setBeamWeaponTurret(0,	 60,  -25,			.15)		--slow turret, narrower arc (vs 200)
	playerYorik:setBeamWeaponTurret(1,	 60,   25,			.15)		--slow turret, narrower arc (vs 200)
	playerYorik:setWeaponTubeCount(3)					--more (vs 2)
	playerYorik:setWeaponTubeDirection(0,-90)			--first tube points left (vs forward)
	playerYorik:setWeaponTubeDirection(1, 90)			--second tube points right (vs rear)
	playerYorik:setWeaponTubeDirection(2,180)			--third tube points rear (vs none)
	playerYorik:weaponTubeDisallowMissle(0,"Mine")		--no Mine (vs any)
	playerYorik:weaponTubeDisallowMissle(1,"Mine")		--no Mine (vs any)
	playerYorik:setWeaponTubeExclusiveFor(2,"Mine")		--only mine
	playerYorik:setWeaponStorageMax("Homing", 8)		--more (vs 4)
	playerYorik:setWeaponStorage("Homing", 8)				
	playerYorik:setWeaponStorageMax("EMP", 6)			--more (vs 0)
	playerYorik:setWeaponStorage("EMP", 6)				
	playerYorik:setWeaponStorageMax("Nuke", 3)			--more (vs 0)
	playerYorik:setWeaponStorage("Nuke", 3)				
	playerYorik:setWeaponStorageMax("Mine", 5)			--more (vs 0)
	playerYorik:setWeaponStorage("Mine", 5)				
	playerYorik:onTakingDamage(playerShipDamage)
	playerYorik:addReputationPoints(50)
	return playerYorik
end
function createPlayerShipSzpieg()
	playerSzpieg = PlayerSpaceship():setTemplate("Ktlitan Breaker"):setFaction("Human Navy"):setCallSign("Szpieg")
	setBeamColor(playerSzpieg)
	playerSzpieg:setWarpDrive(true)
	playerSzpieg:setCombatManeuver(200,300)
	playerSzpieg:setShieldsMax(100, 100)				--stronger shields (vs none)
	playerSzpieg:setShields(100, 100)
	playerSzpieg:setMaxScanProbeCount(5)
	playerSzpieg:setScanProbeCount(5)
	playerSzpieg:setWeaponTubeCount(3)					--more (vs none)
	playerSzpieg:setWeaponTubeDirection(1,180)
	playerSzpieg:setWeaponTubeDirection(2,180)
	playerSzpieg:setWeaponTubeExclusiveFor(2,"Mine")
	playerSzpieg:setWeaponStorageMax("HVLI", 	6)		--more (vs none)
	playerSzpieg:setWeaponStorageMax("Homing", 5)		--more (vs none)
	playerSzpieg:setWeaponStorageMax("Mine",	3)		--more (vs none)
	playerSzpieg:setWeaponStorageMax("EMP",	3)		--more (vs none)
	playerSzpieg:setWeaponStorageMax("Nuke",	2)		--more (vs none)
	playerSzpieg:setWeaponStorage("HVLI",		6)
	playerSzpieg:setWeaponStorage("Homing",	5)
	playerSzpieg:setWeaponStorage("Mine",		3)
	playerSzpieg:setWeaponStorage("EMP",		3)
	playerSzpieg:setWeaponStorage("Nuke",		2)
	playerSzpieg:onTakingDamage(playerShipDamage)
	playerSzpieg:addReputationPoints(50)
	return playerSzpieg
end
function createPlayerShipSztylet()
	playerSztylet = PlayerSpaceship():setTemplate("Ktlitan Feeder"):setFaction("Human Navy"):setCallSign("Sztylet")
	setBeamColor(playerSztylet)
	playerSztylet:setWarpDrive(true)
	playerSztylet:setCombatManeuver(300,200)
	playerSztylet:setShieldsMax(150, 50)				--stronger shields (vs none)
	playerSztylet:setShields(150, 50)
	playerSztylet:setMaxScanProbeCount(5)
	playerSztylet:setScanProbeCount(5)
	playerSztylet:setWeaponTubeCount(5)					--more (vs none)
	playerSztylet:setWeaponTubeDirection(1,90)
	playerSztylet:setWeaponTubeDirection(2,-90)
	playerSztylet:setWeaponTubeDirection(3,180)
	playerSztylet:setWeaponTubeDirection(4,180)
	playerSztylet:setTubeSize(1,"small")
	playerSztylet:setTubeSize(2,"small")
	playerSztylet:setWeaponTubeExclusiveFor(0,"HVLI")
	playerSztylet:setWeaponTubeExclusiveFor(1,"HVLI")
	playerSztylet:setWeaponTubeExclusiveFor(2,"HVLI")
	playerSztylet:setWeaponTubeExclusiveFor(3,"HVLI")
	playerSztylet:setWeaponTubeExclusiveFor(4,"Mine")
	playerSztylet:weaponTubeAllowMissle(0,"Homing")
	playerSztylet:weaponTubeAllowMissle(1,"Homing")
	playerSztylet:weaponTubeAllowMissle(2,"Homing")
	playerSztylet:weaponTubeAllowMissle(3,"Homing")
	playerSztylet:setWeaponStorageMax("HVLI", 	6)		--more (vs none)
	playerSztylet:setWeaponStorageMax("Homing", 6)		--more (vs none)
	playerSztylet:setWeaponStorageMax("Mine",	3)		--more (vs none)
	playerSztylet:setWeaponStorage("HVLI",		6)
	playerSztylet:setWeaponStorage("Homing",	6)
	playerSztylet:setWeaponStorage("Mine",		3)
	playerSztylet:setTubeLoadTime(0, 10)
	playerSztylet:setTubeLoadTime(1, 5)
	playerSztylet:setTubeLoadTime(2, 5)
	playerSztylet:setTubeLoadTime(3, 10)
	playerSztylet:setTubeLoadTime(4, 20)
	playerSztylet:onTakingDamage(playerShipDamage)
	playerSztylet:addReputationPoints(50)
	return playerSztylet
end
function createPlayerShipKatarzyna()
	playerKatarzyna = PlayerSpaceship():setTemplate("Ktlitan Queen"):setFaction("Human Navy"):setCallSign("Katarzyna"):
		setBeamWeapon(0, 25, -15, 1000.0, 6.0, 8):
		setBeamWeapon(1, 15, -45, 1500.0, 6.0, 4):
		setBeamWeapon(2, 25, 15, 1000.0, 6.0, 8):
		setBeamWeapon(3, 15, 45, 1500.0, 6.0, 4):
		setBeamWeapon(4, 15, 80, 1300.0, 6.0, 4):
		setBeamWeapon(5, 15, -80, 1300.0, 6.0, 4):
		setBeamWeaponTurret(4, 45, 80, 3000.0, 6.0, 3):
		setBeamWeaponTurret(5, 45, -80, 3000.0, 6.0, 3):
		setWeaponTubeCount(6):
		setTubeSize(0, "large"):
		setTubeSize(1, "large"):
		setTubeSize(2, "medium"):
		setTubeSize(3, "medium"):
		setTubeSize(4, "medium"):
		setTubeSize(5, "medium"):
		setWeaponTubeDirection(0, 80):
		setWeaponTubeDirection(1, -80):
		setWeaponTubeDirection(2, 100):
		setWeaponTubeDirection(3, -100):
		setWeaponTubeDirection(4, 190):
		setWeaponTubeDirection(5, -190):
		setWeaponStorage("Nuke", 8):
		setWeaponStorage("EMP", 8):
		setWeaponStorage("Mine", 4):
		setWeaponStorage("Homing", 15):
		setWeaponStorage("HVLI", 30):
		setWeaponStorageMax("Nuke", 8):
		setWeaponStorageMax("EMP", 8):
		setWeaponStorageMax("Mine", 4):
		setWeaponStorageMax("Homing", 15):
		setWeaponStorageMax("HVLI", 30):
		setWeaponTubeExclusiveFor(0,"EMP"):
		weaponTubeAllowMissle(0, "Nuke"):
		setWeaponTubeExclusiveFor(1, "EMP"):
		weaponTubeAllowMissle(1, "Nuke"):
		setWeaponTubeExclusiveFor(2, "HVLI"):
		weaponTubeAllowMissle(2, "Homing"):
		setWeaponTubeExclusiveFor(3, "HVLI"):
		weaponTubeAllowMissle(3,"Homing"):
		setWeaponTubeExclusiveFor(4,"Mine"):
		setWeaponTubeExclusiveFor(5,"Mine"):
		setTubeLoadTime(0, 10):
		setTubeLoadTime(1, 10):
		setTubeLoadTime(2, 10):
		setTubeLoadTime(3, 10):
		setTubeLoadTime(4, 20):
		setTubeLoadTime(5, 20):
		setHull(300):
		setWarpDrive(true):
		setCombatManeuver(150,150):
		setMaxScanProbeCount(4):
		setScanProbeCount(4):
		setImpulseMaxSpeed(40.0):
		setRotationMaxSpeed(8):
		setHull(318):
		setHullMax(318):
		setShields(95, 153):
		setShieldsMax(95, 153):
		setEnergy(1388):
		setMaxEnergy(1388):
		setTypeName("Ktlitan Brood Mother"):
		setDescriptions("Special type of Ktlitan warship", "Ktlitan Brood Mother is a subtype of Ktlitan Queen.")
	playerKatarzyna:addReputationPoints(50)
	setBeamColor(playerKatarzyna)
	playerKatarzyna:onTakingDamage(playerShipDamage)
	return playerKatarzyna
end
--	Specialized ships spawned by a carrier
function createPlayerShipFowl()
	playerFowl = PlayerSpaceship():setTemplate("Player Fighter"):setFaction("Human Navy"):setCallSign("Chack")
	setBeamColor(playerFowl)
	playerFowl:setTypeName("Fowl")
	playerFowl:setRepairCrewCount(4)					--more repair crew (vs 3)
	playerFowl:setMaxEnergy(500)						--more maximum energy (vs 400)
	playerFowl:setEnergy(500)							
	playerFowl:setShieldsMax(100,60)					--stronger shields (vs 40)
	playerFowl:setShields(100,60)
--                  		   Arc, Dir,	Range, Cycle Time, Dmg
	playerFowl:setBeamWeapon(0, 12,   0,	 1000,			6, 3)	--3 beams (vs 2)
	playerFowl:setBeamWeapon(1, 40, -10,	  800,			6, 4)	
	playerFowl:setBeamWeapon(2, 40,  10,	  800,			6, 4)	
	playerFowl:setWeaponTubeDirection(0,180)			--tube points backwards (vs forward)
	playerFowl:setWeaponTubeExclusiveFor(0,"Mine")		--and only lays mines (vs HVLI)
	playerFowl:setWeaponStorageMax("HVLI",0)			--fewer HVLIs (vs 4)
	playerFowl:setWeaponStorage("HVLI",0)
	playerFowl:setWeaponStorageMax("Mine",4)			--more Mines (vs 0)
	playerFowl:setWeaponStorage("Mine",4)
	playerFowl:onTakingDamage(playerShipDamage)
	return playerFowl
end
function createPlayerShipPhargus()
	playerPhargus = PlayerSpaceship():setTemplate("Phobos M3P"):setFaction("Human Navy"):setCallSign("Gringo")
	setBeamColor(playerPhargus)
	--aka Gringo
	playerPhargus:setTypeName("Phargus")
	playerPhargus:setShieldsMax(70,50)					--weaker (vs 100,100)
	playerPhargus:setShields(70,50)
	playerPhargus:setHullMax(120)						--weaker hull (vs 200)
	playerPhargus:setHull(120)
--                  			   Arc, Dir,    Range, CycleTime, Dmg
	playerPhargus:setBeamWeapon(0,  10, -15,	800.0,		   6, 4)		--shorter (vs 1200), weaker (vs 6), faster (vs 8)
	playerPhargus:setBeamWeapon(1,  10,  15,	800.0,		   6, 4)		
--										   Arc, Dir, Rotate speed
	playerPhargus:setBeamWeaponTurret(0,	70,	-15,		 .4)		--slow turret, narrower overall arc (vs 90)
	playerPhargus:setBeamWeaponTurret(1,	70,	 15,		 .4)
	playerPhargus:onTakingDamage(playerShipDamage)
--	playerPhargus:addReputationPoints(50)	--avoid if spawned by carrier
	return playerPhargus
end
--	Standard ship creation
function setBeamColor(ship)
	local faction = ship:getFaction()
	if faction_beam_color[faction] == nil then
		faction_beam_color[faction] = tableRemoveRandom(faction_beam_color_pool)
--		print("Faction",faction,"now set to",faction_beam_color[faction].name,"r:",faction_beam_color[faction].ir,"g:",faction_beam_color[faction].ig,"b:",faction_beam_color[faction].ib)
	end
	local r = faction_beam_color[faction].r
	local g = faction_beam_color[faction].g
	local b = faction_beam_color[faction].b
--	print("Faction:",faction,"r:",r,"g:",g,"b:",b,faction_beam_color[faction].name)
	for i=0,15 do
		ship:setBeamWeaponArcColor(i,r,g,b,16/255,16/255,16/255)
	end
	local factions_db = queryScienceDatabase("Factions")
	local color_db = queryScienceDatabase("Factions","Colors")
	if color_db == nil then
		factions_db:addEntry("Colors")
		color_db = queryScienceDatabase("Factions","Colors")
	end
	local color_out = "As you identify each faction, the onboard computer system assigns a color to the beam arcs to help identify factions. These are the current faction/color correlations:\n"
	for faction,color in pairs(faction_beam_color) do
		color_out = string.format("%s\n%s: %s",color_out,faction,color.name)
	end
	color_db:setLongDescription(color_out)
end
function stockPlayer(template)
	print("stock player template:",template)
	local ship = PlayerSpaceship()
	ship:setTemplate(template):setFaction("Human Navy")
	setBeamColor(ship)
	ship:onTakingDamage(playerShipDamage)
	if template == "Player Fighter" then
--                  		  Arc, Dir,Range, Cyc,Dmg
		ship:setBeamWeapon(0,  20,   0,	1200,	6,	8):setBeamWeaponDamageType(0,"emp")
		ship:setBeamWeapon(1,  30,   0,	1000,	6,	8)
	end
	return ship
end

