-- Name: Operations
-- Description: 1-6 player ships (5-36 players). The mission consists of four tasks, a different player ship per task. If at least one player ship survives a task, the other crews can rejoin for the next task.
---
--- Duration: 60-90 minutes with default settings. Terrain differs each scenario run. Difficulty: low to medium with default settings.
---
--- Version 1
---
--- USN Discord: https://discord.gg/PntGG3a where you can join a game online. There's usually one every weekend. All experience levels are welcome. 
-- Type: Mission
-- Author: Xansta 
-- Setting[Players]: Number of player ships. Default is 1
-- Players[One|Default]: Number of player ships is 1
-- Players[Two]: Number of player ships is 2
-- Players[Three]: Number of player ships is 3
-- Players[Four]: Number of player ships is 4
-- Players[Five]: Number of player ships is 5
-- Players[Six]: Number of player ships is 6
-- Setting[Enemies]: Configures strength and/or number of enemies in this scenario
-- Enemies[Easy]: Fewer or weaker enemies
-- Enemies[Normal|Default]: Normal number or strength of enemies
-- Enemies[Hard]: More or stronger enemies
-- Enemies[Extreme]: Much stronger, many more enemies
-- Enemies[Quixotic]: Insanely strong and/or inordinately large numbers of enemies
-- Setting[Murphy]: Configures the perversity of the universe according to Murphy's law
-- Murphy[Easy]: Random factors are more in your favor
-- Murphy[Normal|Default]: Random factors are normal
-- Murphy[Hard]: Random factors are more against you
-- Murphy[Extreme]: Random factors are severely against you
-- Murphy[Quixotic]: No need for paranoia, the universe *is* out to get you
-- Setting[Reputation]: Amount of reputation to start with. Default: 20
-- Reputation[Unknown]: Zero reputation - nobody knows anything about you
-- Reputation[Nice|Default]: 20 reputation - you've had a small positive influence on the local community
-- Reputation[Hero]: 50 reputation - you helped important people or lots of people
-- Reputation[Major Hero]: 100 reputation - you're well known by nearly everyone as a force for good
-- Reputation[Super Hero]: 200 reputation - everyone knows you and relies on you for help
-- Setting[Transfer]: Time delay interval for player ship transfer activities
-- Transfer[Short]: 5 second interval
-- Transfer[Medium|Default]: 8 second interval
-- Transfer[Long]: 12 second interval
-- Transfer[Restful]: 17 second interval

require("utils.lua")
require("place_station_scenario_utility.lua")
require("cpu_ship_diversification_scenario_utility.lua")
require("generate_call_sign_scenario_utility.lua")
require("comms_scenario_utility.lua")

--	Initialization
function init()
	scenario_version = "0.0.3"
	scenario_name = "Operations"
	getScriptStorage():set("scenario_name", scenario_name)
	ee_version = "2024.12.08"
	print(string.format("    ----    Scenario: %s    ----    Version %s    ----    Tested with EE version %s    ----",scenario_name,scenario_version,ee_version))
	if _VERSION ~= nil then
		print("Lua version:",_VERSION)
	end
	setConstants()
	setGlobals()
	setVariations()
	primary_orders = _("orders-comms","Fight off attacking Kraylor")
	constructEnvironment()
end
function setConstants()
	relative_strength = 1
	max_repeat_loop = 100
	ordnance_types = {"Homing", "Nuke", "Mine", "EMP", "HVLI"}
	system_types = {"reactor","beamweapons","missilesystem","maneuver","impulse","warp","jumpdrive","frontshield","rearshield"}
	missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
	ship_template = {	--ordered by relative strength
		-- normal ships that are part of the fleet spawn process
		["Gnat"] =				{strength = 2,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true,		drone = true,	unusual = false,	base = false,	short_range_radar = 4500,	hop_angle = 0,	hop_range = 580,	create = gnat},
		["Lite Drone"] =		{strength = 3,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = true,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	create = droneLite},
		["Jacket Drone"] =		{strength = 4,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = true,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	create = droneJacket},
		["Ktlitan Drone"] =		{strength = 4,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = true,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	create = stockTemplate},
		["Heavy Drone"] =		{strength = 5,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = true,	unusual = false,	base = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 580,	create = droneHeavy},
		["Adder MK3"] =			{strength = 5,	adder = true,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	create = stockTemplate},
		["MT52 Hornet"] =		{strength = 5,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 680,	create = stockTemplate},
		["MU52 Hornet"] =		{strength = 5,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 880,	create = stockTemplate},
		["Dagger"] =			{strength = 6,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["MV52 Hornet"] =		{strength = 6,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = hornetMV52},
		["MT55 Hornet"] =		{strength = 6,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 680,	create = hornetMT55},
		["Adder MK4"] =			{strength = 6,	adder = true,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	create = stockTemplate},
		["Fighter"] =			{strength = 6,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Shepherd"] =			{strength = 6,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 2880,	create = shepherd},
		["Ktlitan Fighter"] =	{strength = 6,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1180,	create = stockTemplate},
		["Touchy"] =			{strength = 7,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 2000,	create = touchy},
		["Blade"] =				{strength = 7,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Gunner"] =			{strength = 7,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["K2 Fighter"] =		{strength = 7,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1180,	create = k2fighter},
		["Adder MK5"] =			{strength = 7,	adder = true,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	create = stockTemplate},
		["WX-Lindworm"] =		{strength = 7,	adder = false,	missiler = true,	beamer = false,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 2500,	create = stockTemplate},
		["K3 Fighter"] =		{strength = 8,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1180,	create = k3fighter},
		["Shooter"] =			{strength = 8,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Jagger"] =			{strength = 8,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Adder MK6"] =			{strength = 8,	adder = true,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	create = stockTemplate},
		["Ktlitan Scout"] =		{strength = 8,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 7000,	hop_angle = 0,	hop_range = 580,	create = stockTemplate},
		["WZ-Lindworm"] =		{strength = 9,	adder = false,	missiler = true,	beamer = false,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 2500,	create = wzLindworm},
		["Adder MK7"] =			{strength = 9,	adder = true,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	create = stockTemplate},
		["Adder MK8"] =			{strength = 10,	adder = true,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 580,	create = stockTemplate},
		["Adder MK9"] =			{strength = 11,	adder = true,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 0,	hop_range = 580,	create = stockTemplate},
		["Nirvana R3"] =		{strength = 12,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Phobos R2"] =			{strength = 13,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1180,	create = phobosR2},
		["Missile Cruiser"] =	{strength = 14,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 7000,	hop_angle = 0,	hop_range = 2500,	create = stockTemplate},
		["Waddle 5"] =			{strength = 15,	adder = true,	missiler = false,	beamer = false,	frigate = false,	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	create = waddle5},
		["Jade 5"] =			{strength = 15,	adder = true,	missiler = false,	beamer = false,	frigate = false,	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	create = jade5},
		["Phobos T3"] =			{strength = 15,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1180,	create = stockTemplate},
		["Guard"] =				{strength = 15,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1180,	create = stockTemplate},
		["Piranha F8"] =		{strength = 15,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 90,	hop_range = 2500,	create = stockTemplate},
		["Piranha F12"] =		{strength = 15,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 90,	hop_range = 2500,	create = stockTemplate},
		["Piranha F12.M"] =		{strength = 16,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 90,	hop_range = 2500,	create = stockTemplate},
		["Phobos M3"] =			{strength = 16,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 1180,	create = stockTemplate},
		["Farco 3"] =			{strength = 16,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 8000,	hop_angle = 0,	hop_range = 1480,	create = farco3},
		["Farco 5"] =			{strength = 16,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 8000,	hop_angle = 0,	hop_range = 1180,	create = farco5},
		["Karnack"] =			{strength = 17,	adder = false,	missiler = false,	beamer = true,	frigate = true,		chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Gunship"] =			{strength = 17,	adder = false,	missiler = false,	beamer = false,	frigate = true,		chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Phobos T4"] =			{strength = 18,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1480,	create = phobosT4},
		["Nirvana R5"] =		{strength = 19,	adder = false,	missiler = false,	beamer = true,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1180,	create = stockTemplate},
		["Farco 8"] =			{strength = 19,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 8000,	hop_angle = 0,	hop_range = 1480,	create = farco8},
		["Nirvana R5A"] =		{strength = 20,	adder = false,	missiler = false,	beamer = true,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1180,	create = stockTemplate},
		["Adv. Gunship"] =		{strength = 20,	adder = false,	missiler = false,	beamer = false,	frigate = true,		chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 7000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Ktlitan Worker"] =	{strength = 20,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 90,	hop_range = 580,	create = stockTemplate},
		["Farco 11"] =			{strength = 21,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 8000,	hop_angle = 0,	hop_range = 1480,	create = farco11},
		["Storm"] =				{strength = 22,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 0,	hop_range = 1180,	create = stockTemplate},
		["Warden"] =			{strength = 22,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 0,	hop_range = 1180,	create = stockTemplate},
		["Racer"] =				{strength = 22,	adder = false,	missiler = false,	beamer = true,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Stalker R5"] =		{strength = 22,	adder = false,	missiler = false,	beamer = true,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Stalker Q5"] =		{strength = 22,	adder = false,	missiler = false,	beamer = true,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Strike"] =			{strength = 23,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Dash"] =				{strength = 23,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Farco 13"] =			{strength = 24,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1480,	create = farco13},
		["Sentinel"] =			{strength = 24,	adder = false,	missiler = false,	beamer = true,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1180,	create = stockTemplate},
		["Ranus U"] =			{strength = 25,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 0,	hop_range = 2500,	create = stockTemplate},
		["Flash"] =				{strength = 25,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 0,	hop_range = 2500,	create = stockTemplate},
		["Ranger"] =			{strength = 25,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 0,	hop_range = 2500,	create = stockTemplate},
		["Buster"] =			{strength = 25,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 0,	hop_range = 2500,	create = stockTemplate},
		["Stalker Q7"] =		{strength = 25,	adder = false,	missiler = false,	beamer = true,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Stalker R7"] =		{strength = 25,	adder = false,	missiler = false,	beamer = true,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Whirlwind"] =			{strength = 26,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 90,	hop_range = 2500,	create = whirlwind},
		["Hunter"] =			{strength = 26,	adder = false,	missiler = false,	beamer = true,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Adv. Striker"] =		{strength = 27,	adder = false,	missiler = false,	beamer = true,	frigate = true,		chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Elara P2"] =			{strength = 28,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 8000,	hop_angle = 0,	hop_range = 1480,	create = stockTemplate},
		["Tempest"] =			{strength = 30,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 90,	hop_range = 2500,	create = tempest},
		["Strikeship"] =		{strength = 30,	adder = false,	missiler = false,	beamer = true,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Fiend G3"] =			{strength = 33,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6500,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Maniapak"] =			{strength = 34,	adder = true,	missiler = false,	beamer = false,	frigate = false, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 0,	hop_range = 580,	create = maniapak},
		["Fiend G4"] =			{strength = 35,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6500,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Cucaracha"] =			{strength = 36,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1480,	create = cucaracha},
		["Fiend G5"] =			{strength = 37,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6500,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Fiend G6"] =			{strength = 39,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6500,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Barracuda"] =			{strength = 40,	adder = false,	missiler = false,	beamer = false,	frigate = true,		chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 1180,	create = barracuda},
		["Ryder"] =				{strength = 41, adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 8000,	hop_angle = 90,	hop_range = 1180,	create = stockTemplate},
		["Predator"] =			{strength = 42,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 7500,	hop_angle = 0,	hop_range = 980,	create = predator},
		["Ktlitan Breaker"] =	{strength = 45,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 780,	create = stockTemplate},
		["Hurricane"] =			{strength = 46,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 15,	hop_range = 2500,	create = hurricane},
		["Ktlitan Feeder"] =	{strength = 48,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	create = stockTemplate},
		["Atlantis X23"] =		{strength = 50,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 10000,	hop_angle = 0,	hop_range = 1480,	create = stockTemplate},
		["Ktlitan Destroyer"] =	{strength = 50,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 9000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["K2 Breaker"] =		{strength = 55,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 780,	create = k2breaker},
		["Atlantis Y42"] =		{strength = 60,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 10000,	hop_angle = 0,	hop_range = 1480,	create = atlantisY42},
		["Blockade Runner"] =	{strength = 63,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Starhammer II"] =		{strength = 70,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 10000,	hop_angle = 0,	hop_range = 1480,	create = stockTemplate},
		["Enforcer"] =			{strength = 75,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 9000,	hop_angle = 0,	hop_range = 1480,	create = enforcer},
		["Dreadnought"] =		{strength = 80,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 9000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Starhammer III"] =	{strength = 85,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 12000,	hop_angle = 0,	hop_range = 1480,	create = starhammerIII},
		["Starhammer V"] =		{strength = 90,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 15000,	hop_angle = 0,	hop_range = 1480,	create = starhammerV},
		["Battlestation"] =		{strength = 100,adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 9000,	hop_angle = 90,	hop_range = 2480,	create = stockTemplate},
		["Fortress"] =			{strength = 130,adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 9000,	hop_angle = 90,	hop_range = 2380,	create = stockTemplate},
		["Tyr"] =				{strength = 150,adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 9500,	hop_angle = 90,	hop_range = 2480,	create = tyr},
		["Odin"] =				{strength = 250,adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 20000,	hop_angle = 0,	hop_range = 3180,	create = stockTemplate},
	}
	fleet_group = {
		["adder"] = "Adders",
		["Adders"] = "adder",
		["missiler"] = "Missilers",
		["Missilers"] = "missiler",
		["beamer"] = "Beamers",
		["Beamers"] = "beamer",
		["frigate"] = "Frigates",
		["Frigates"] = "frigate",
		["chaser"] = "Chasers",
		["Chasers"] = "chaser",
		["fighter"] = "Fighters",
		["Fighters"] = "fighter",
		["drone"] = "Drones",
		["Drones"] = "drone",
	}
	formation_delta = {
		["square"] = {
			x = {0,1,0,-1, 0,1,-1, 1,-1,2,0,-2, 0,2,-2, 2,-2,2, 2,-2,-2,1,-1, 1,-1,0, 0,3,-3,1, 1,3,-3,-1,-1, 3,-3,2, 2,3,-3,-2,-2, 3,-3,3, 3,-3,-3,4,0,-4, 0,4,-4, 4,-4,-4,-4,-4,-4,-4,-4,4, 4,4, 4,4, 4, 1,-1, 2,-2, 3,-3,1,-1,2,-2,3,-3,5,-5,0, 0,5, 5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,5, 5,5, 5,5, 5,5, 5, 1,-1, 2,-2, 3,-3, 4,-4,1,-1,2,-2,3,-3,4,-4},
			y = {0,0,1, 0,-1,1,-1,-1, 1,0,2, 0,-2,2,-2,-2, 2,1,-1, 1,-1,2, 2,-2,-2,3,-3,0, 0,3,-3,1, 1, 3,-3,-1,-1,3,-3,2, 2, 3,-3,-2,-2,3,-3, 3,-3,0,4, 0,-4,4,-4,-4, 4, 1,-1, 2,-2, 3,-3,1,-1,2,-2,3,-3,-4,-4,-4,-4,-4,-4,4, 4,4, 4,4, 4,0, 0,5,-5,5,-5, 5,-5, 1,-1, 2,-2, 3,-3, 4,-4,1,-1,2,-2,3,-3,4,-4,-5,-5,-5,-5,-5,-5,-5,-5,5, 5,5, 5,5, 5,5, 5},
		},
		["hexagonal"] = {
			x = {0,2,-2,1,-1, 1,-1,4,-4,0, 0,2,-2,-2, 2,3,-3, 3,-3,6,-6,1,-1, 1,-1,3,-3, 3,-3,4,-4, 4,-4,5,-5, 5,-5,8,-8,4,-4, 4,-4,5,5 ,-5,-5,2, 2,-2,-2,0, 0,6, 6,-6,-6,7, 7,-7,-7,10,-10,5, 5,-5,-5,6, 6,-6,-6,7, 7,-7,-7,8, 8,-8,-8,9, 9,-9,-9,3, 3,-3,-3,1, 1,-1,-1,12,-12,6,-6, 6,-6,7,-7, 7,-7,8,-8, 8,-8,9,-9, 9,-9,10,-10,10,-10,11,-11,11,-11,4,-4, 4,-4,2,-2, 2,-2,0, 0},
			y = {0,0, 0,1, 1,-1,-1,0, 0,2,-2,2,-2, 2,-2,1,-1,-1, 1,0, 0,3, 3,-3,-3,3,-3,-3, 3,2,-2,-2, 2,1,-1,-1, 1,0, 0,4,-4,-4, 4,3,-3, 3,-3,4,-4, 4,-4,4,-4,2,-2, 2,-2,1,-1, 1,-1, 0,  0,5,-5, 5,-5,4,-4, 4,-4,3,-3, 3,-7,2,-2, 2,-2,1,-1, 1,-1,5,-5, 5,-5,5,-5, 5,-5, 0,  0,6, 6,-6,-6,5, 5,-5,-5,4, 4,-4,-4,3, 3,-3,-3, 2,  2,-2, -2, 1,  1,-1, -1,6, 6,-6,-6,6, 6,-6,-6,6,-6},
		},
		["pyramid"] = {
			[1] = {
				{angle =  0, distance = 0},
			},
			[2] = {
				{angle = -1, distance = 1},
				{angle =  1, distance = 1},
			},
			[3] = {
				{angle =  0, distance = 0},
				{angle = -1, distance = 1},
				{angle =  1, distance = 1},				
			},
			[4] = {
				{angle =  0, distance = 0},
				{angle = -1, distance = 1},
				{angle =  1, distance = 1},
				{angle =  0, distance = 2},	
			},
			[5] = {
				{angle =  0, distance = 0},
				{angle = -1, distance = 1},
				{angle =  1, distance = 1},
				{angle = -2, distance = 2},
				{angle =  2, distance = 2},
			},
			[6] = {
				{angle =  0, distance = 0},
				{angle = -1, distance = 1},
				{angle =  1, distance = 1},
				{angle = -2, distance = 2},
				{angle =  2, distance = 2},
				{angle =  0, distance = 2},	
			},
			[7] = {
				{angle =  0, distance = 0},
				{angle = -1, distance = 1},
				{angle =  1, distance = 1},
				{angle = -2, distance = 2},
				{angle =  2, distance = 2},
				{angle = -3, distance = 3},
				{angle =  3, distance = 3},
			},
			[8] = {
				{angle =  0, distance = 0},
				{angle = -1, distance = 1},
				{angle =  1, distance = 1},
				{angle = -2, distance = 2},
				{angle =  2, distance = 2},
				{angle =  0, distance = 2},	
				{angle = -3, distance = 3},
				{angle =  3, distance = 3},
			},
			[9] = {
				{angle =  0, distance = 0},
				{angle = -1, distance = 1},
				{angle =  1, distance = 1},
				{angle = -2, distance = 2},
				{angle =  2, distance = 2},
				{angle = -3, distance = 3},
				{angle =  3, distance = 3},
				{angle = -4, distance = 4},
				{angle =  4, distance = 4},
			},
			[10] = {
				{angle =  0, distance = 0},
				{angle = -1, distance = 1},
				{angle =  1, distance = 1},
				{angle = -2, distance = 2},
				{angle =  2, distance = 2},
				{angle =  0, distance = 2},	
				{angle = -3, distance = 3},
				{angle =  3, distance = 3},
				{angle = -2, distance = 3},
				{angle =  2, distance = 3},
			},
			[11] = {
				{angle =  0, distance = 0},
				{angle = -1, distance = 1},
				{angle =  1, distance = 1},
				{angle = -2, distance = 2},
				{angle =  2, distance = 2},
				{angle = -3, distance = 3},
				{angle =  3, distance = 3},
				{angle = -4, distance = 4},
				{angle =  4, distance = 4},
				{angle = -3, distance = 4},
				{angle =  3, distance = 4},
			},
			[12] = {
				{angle =  0, distance = 0},
				{angle = -1, distance = 1},
				{angle =  1, distance = 1},
				{angle = -2, distance = 2},
				{angle =  2, distance = 2},
				{angle =  0, distance = 2},	
				{angle = -3, distance = 3},
				{angle =  3, distance = 3},
				{angle = -2, distance = 3},
				{angle =  2, distance = 3},
				{angle = -1, distance = 3},
				{angle =  1, distance = 3},
			},
			[13] = {
				{angle =  0, distance = 0},
				{angle = -1, distance = 1},
				{angle =  1, distance = 1},
				{angle = -2, distance = 2},
				{angle =  2, distance = 2},
				{angle = -3, distance = 3},
				{angle =  3, distance = 3},
				{angle =  0, distance = 3},
				{angle = -2, distance = 4},
				{angle =  2, distance = 4},
				{angle = -1, distance = 5},
				{angle =  1, distance = 5},
				{angle =  0, distance = 6},
			},
			[14] = {
				{angle =  0, distance = 0},
				{angle = -1, distance = 1},
				{angle =  1, distance = 1},
				{angle = -2, distance = 2},
				{angle =  2, distance = 2},
				{angle =  0, distance = 2},	
				{angle = -3, distance = 3},
				{angle =  3, distance = 3},
				{angle =  0, distance = 4},
				{angle = -2, distance = 4},
				{angle =  2, distance = 4},
				{angle = -1, distance = 5},
				{angle =  1, distance = 5},
				{angle =  0, distance = 6},
			},
			[15] = {
				{angle =  0, distance = 0},
				{angle = -1, distance = 1},
				{angle =  1, distance = 1},
				{angle = -2, distance = 2},
				{angle =  2, distance = 2},
				{angle =  0, distance = 2},	
				{angle = -3, distance = 3},
				{angle =  3, distance = 3},
				{angle =  0, distance = 3},
				{angle =  0, distance = 4},
				{angle = -2, distance = 4},
				{angle =  2, distance = 4},
				{angle = -1, distance = 5},
				{angle =  1, distance = 5},
				{angle =  0, distance = 6},
			},
		},
	}
end
function setGlobals()
	current_orders_button = true
	stations_improve_ships = true
	stations_sell_goods = true
	include_goods_for_sale_in_status = true
	sensor_impact = 1
	player_respawns = false
	player_respawn_max = 0
	deployed_player_count = 0
	deployed_players = {}
	player_ship_stats = {	
		["MP52 Hornet"] 		= { strength = 7, 	cargo = 3,	distance = 100,	long_range_radar = 18000, short_range_radar = 4000, power_sensor_interval = 0,	probes = 8,	tractor = false,	mining = false	},
		["Piranha"]				= { strength = 16,	cargo = 8,	distance = 200,	long_range_radar = 25000, short_range_radar = 6000, power_sensor_interval = 0,	probes = 8,	tractor = false,	mining = false	},
		["Flavia P.Falcon"]		= { strength = 13,	cargo = 15,	distance = 200,	long_range_radar = 40000, short_range_radar = 5000, power_sensor_interval = 0,	probes = 8,	tractor = true,		mining = true	},
		["Phobos M3P"]			= { strength = 19,	cargo = 10,	distance = 200,	long_range_radar = 25000, short_range_radar = 5000, power_sensor_interval = 0,	probes = 8,	tractor = true,		mining = false	},
		["Atlantis"]			= { strength = 52,	cargo = 6,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, power_sensor_interval = 0,	probes = 8,	tractor = true,		mining = true	},
		["Player Cruiser"]		= { strength = 40,	cargo = 6,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, power_sensor_interval = 0,	probes = 8,	tractor = false,	mining = false	},
		["Player Missile Cr."]	= { strength = 45,	cargo = 8,	distance = 200,	long_range_radar = 35000, short_range_radar = 6000, power_sensor_interval = 0,	probes = 8,	tractor = false,	mining = false	},
		["Player Fighter"]		= { strength = 7,	cargo = 3,	distance = 100,	long_range_radar = 15000, short_range_radar = 4500, power_sensor_interval = 0,	probes = 8,	tractor = false,	mining = false	},
		["Benedict"]			= { strength = 10,	cargo = 9,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, power_sensor_interval = 0,	probes = 8,	tractor = true,		mining = true	},
		["Kiriya"]				= { strength = 10,	cargo = 9,	distance = 400,	long_range_radar = 35000, short_range_radar = 5000, power_sensor_interval = 0,	probes = 8,	tractor = true,		mining = true	},
		["Striker"]				= { strength = 8,	cargo = 4,	distance = 200,	long_range_radar = 35000, short_range_radar = 5000, power_sensor_interval = 0,	probes = 8,	tractor = false,	mining = false	},
		["ZX-Lindworm"]			= { strength = 8,	cargo = 3,	distance = 100,	long_range_radar = 18000, short_range_radar = 5500, power_sensor_interval = 0,	probes = 8,	tractor = false,	mining = false	},
		["Repulse"]				= { strength = 14,	cargo = 12,	distance = 200,	long_range_radar = 38000, short_range_radar = 5000, power_sensor_interval = 0,	probes = 8,	tractor = true,		mining = false	},
		["Ender"]				= { strength = 100,	cargo = 20,	distance = 2000,long_range_radar = 45000, short_range_radar = 7000, power_sensor_interval = 0,	probes = 8,	tractor = true,		mining = false	},
		["Nautilus"]			= { strength = 12,	cargo = 7,	distance = 200,	long_range_radar = 22000, short_range_radar = 4000, power_sensor_interval = 0,	probes = 8,	tractor = false,	mining = false	},
		["Hathcock"]			= { strength = 30,	cargo = 6,	distance = 200,	long_range_radar = 35000, short_range_radar = 6000, power_sensor_interval = 0,	probes = 8,	tractor = false,	mining = true	},
		["Maverick"]			= { strength = 45,	cargo = 5,	distance = 200,	long_range_radar = 20000, short_range_radar = 4000, power_sensor_interval = 0,	probes = 8,	tractor = false,	mining = true	},
		["Crucible"]			= { strength = 45,	cargo = 5,	distance = 200,	long_range_radar = 20000, short_range_radar = 6000, power_sensor_interval = 0,	probes = 8,	tractor = false,	mining = false	},
		["Proto-Atlantis"]		= { strength = 40,	cargo = 4,	distance = 400,	long_range_radar = 30000, short_range_radar = 4500, power_sensor_interval = 0,	probes = 8,	tractor = false,	mining = true	},
		["Saipan"]				= { strength = 30,	cargo = 4,	distance = 200,	long_range_radar = 25000, short_range_radar = 4500, power_sensor_interval = 0,	probes = 10,tractor = false,	mining = false	},
		["Stricken"]			= { strength = 40,	cargo = 4,	distance = 200,	long_range_radar = 20000, short_range_radar = 4000, power_sensor_interval = 0,	probes = 8,	tractor = false,	mining = false	},
		["Surkov"]				= { strength = 35,	cargo = 6,	distance = 200,	long_range_radar = 35000, short_range_radar = 6000, power_sensor_interval = 0,	probes = 8,	tractor = false,	mining = false	},
		["Redhook"]				= { strength = 11,	cargo = 8,	distance = 200,	long_range_radar = 20000, short_range_radar = 6000, power_sensor_interval = 0,	probes = 8,	tractor = false,	mining = false	},
		["Pacu"]				= { strength = 18,	cargo = 7,	distance = 200,	long_range_radar = 20000, short_range_radar = 6000, power_sensor_interval = 0,	probes = 8,	tractor = false,	mining = false	},
		["Phobos T2"]			= { strength = 19,	cargo = 9,	distance = 200,	long_range_radar = 25000, short_range_radar = 5000, power_sensor_interval = 0,	probes = 8,	tractor = true,		mining = false	},
		["Wombat"]				= { strength = 13,	cargo = 3,	distance = 100,	long_range_radar = 18000, short_range_radar = 6000, power_sensor_interval = 0,	probes = 8,	tractor = false,	mining = false	},
		["Holmes"]				= { strength = 35,	cargo = 6,	distance = 200,	long_range_radar = 35000, short_range_radar = 4000, power_sensor_interval = 0,	probes = 8,	tractor = true,		mining = false	},
		["Focus"]				= { strength = 35,	cargo = 4,	distance = 200,	long_range_radar = 32000, short_range_radar = 5000, power_sensor_interval = 0,	probes = 8,	tractor = false,	mining = true	},
		["Flavia 2C"]			= { strength = 25,	cargo = 12,	distance = 200,	long_range_radar = 30000, short_range_radar = 5000, power_sensor_interval = 0,	probes = 8,	tractor = false,	mining = true	},
		["Destroyer IV"]		= { strength = 25,	cargo = 5,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, power_sensor_interval = 0,	probes = 8,	tractor = false,	mining = false	},
		["Destroyer III"]		= { strength = 25,	cargo = 7,	distance = 200,	long_range_radar = 30000, short_range_radar = 5000, power_sensor_interval = 0,	probes = 8,	tractor = false,	mining = false	},
		["MX-Lindworm"]			= { strength = 10,	cargo = 3,	distance = 100,	long_range_radar = 30000, short_range_radar = 5000, power_sensor_interval = 0,	probes = 8,	tractor = false,	mining = false	},
		["Striker LX"]			= { strength = 16,	cargo = 4,	distance = 200,	long_range_radar = 20000, short_range_radar = 4000, power_sensor_interval = 0,	probes = 8,	tractor = false,	mining = false	},
		["Maverick XP"]			= { strength = 23,	cargo = 5,	distance = 200,	long_range_radar = 25000, short_range_radar = 7000, power_sensor_interval = 0,	probes = 8,	tractor = true,		mining = false	},
		["Era"]					= { strength = 14,	cargo = 14,	distance = 200,	long_range_radar = 50000, short_range_radar = 5000, power_sensor_interval = 0,	probes = 8,	tractor = true,		mining = true	},
		["Squid"]				= { strength = 14,	cargo = 8,	distance = 200,	long_range_radar = 25000, short_range_radar = 5000, power_sensor_interval = 0,	probes = 8,	tractor = false,	mining = false	},
		["Atlantis II"]			= { strength = 60,	cargo = 6,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, power_sensor_interval = 0,	probes = 8,	tractor = true,		mining = true	},
	}
	player_ship_names_for = {
		["Atlantis"] =			{"Excaliber","Thrasher","Punisher","Vorpal","Protang","Drummond","Parchim","Coronado"},
		["Atlantis II"] =		{"Spyder", "Shelob", "Tarantula", "Aragog", "Charlotte"},
		["Benedict"] =			{"Elizabeth","Ford","Vikramaditya","Liaoning","Avenger","Naruebet","Washington","Lincoln","Garibaldi","Eisenhower"},
		["Crucible"] =			{"Sling", "Stark", "Torrid", "Kicker", "Flummox"},
		["Ender"] =				{"Mongo","Godzilla","Leviathan","Kraken","Jupiter","Saturn"},
		["Flavia P.Falcon"] =	{"Ladyhawke","Hunter","Seeker","Gyrefalcon","Kestrel","Magpie","Bandit","Buccaneer","Corvus","Jackdaw","Myna","Cyanocitta","Bower","Alcyon","Gentoo","Rook"},
		["Hathcock"] =			{"Hayha","Waldron","Plunkett","Mawhinney","Furlong","Zaytsev","Pavlichenko","Pegahmagabow","Fett","Hawkeye","Hanzo"},
		["Kiriya"] =			{"Cavour","Reagan","Gaulle","Paulo","Truman","Stennis","Kuznetsov","Roosevelt","Vinson","Old Salt"},
		["Maverick"] =			{"Angel", "Thunderbird", "Roaster", "Magnifier", "Hedge"},
		["MP52 Hornet"] =		{"Dragonfly","Scarab","Mantis","Yellow Jacket","Jimminy","Flik","Thorny","Buzz"},
		["Nautilus"] =			{"October","Abdiel","Manxman","Newcon","Nusret","Pluton","Amiral","Amur","Heinkel","Dornier"},
		["Phobos M3P"] =		{"Blinder","Shadow","Distortion","Diemos","Ganymede","Castillo","Thebe","Retrograde"},
		["Phobos M5P"] =		{"Blinder","Shadow","Distortion","Diemos","Ganymede","Castillo","Thebe","Retrograde","Rage","Cogitate","Thrust","Coyote"},
		["Piranha"] =			{"Razor","Biter","Ripper","Voracious","Carnivorous","Characid","Vulture","Predator"},
		["Player Cruiser"] =	{"Excelsior","Velociraptor","Thunder","Kona","Encounter","Perth","Aspern","Panther"},
		["Player Fighter"] =	{"Buzzer","Flitter","Zippiticus","Hopper","Molt","Stinger","Stripe"},
		["Player Missile Cr."] ={"Projectus","Hurlmeister","Flinger","Ovod","Amatola","Nakhimov","Antigone"},
		["Proto-Atlantis"] =	{"Narsil", "Blade", "Decapitator", "Trisect", "Sabre"},
		["Redhook"] =			{"Headhunter", "Thud", "Troll", "Scalper", "Shark"},
		["Repulse"] =			{"Fiddler","Brinks","Loomis","Mowag","Patria","Pandur","Terrex","Komatsu","Eitan"},
		["Saipan"] =			{"Atlas", "Bernard", "Alexander", "Retribution", "Sulaco", "Conestoga", "Saratoga", "Pegasus"},
		["Stricken"] =			{"Blazon", "Streaker", "Pinto", "Spear", "Javelin"},
		["Striker"] =			{"Sparrow","Sizzle","Squawk","Crow","Phoenix","Snowbird","Hawk","Eagle","Heron","Skua","Raptor","Harrier","Sparhawk","Pandion","Buteo","Milvus"},
		["Surkov"] =			{"Sting", "Sneak", "Bingo", "Thrill", "Vivisect"},
		["ZX-Lindworm"] =		{"Seagull","Catapult","Blowhard","Flapper","Nixie","Pixie","Tinkerbell"},
		["Leftovers"] =			{"Foregone","Righteous","Scandalous"},
	}
	stations = {}
	fly_formation = {
		["*18"] =	{
						{angle = 30	, dist = 1	},
						{angle = 90	, dist = 1	},
						{angle = 330, dist = 1	},
						{angle = 150, dist = 1	},
						{angle = 210, dist = 1	},
						{angle = 270, dist = 1	},
						{angle = 30	, dist = 2	},
						{angle = 90	, dist = 2	},
						{angle = 330, dist = 2	},
						{angle = 150, dist = 2	},
						{angle = 210, dist = 2	},
						{angle = 270, dist = 2	},
						{angle = 30	, dist = 3	},
						{angle = 90	, dist = 3	},
						{angle = 330, dist = 3	},
						{angle = 150, dist = 3	},
						{angle = 210, dist = 3	},
						{angle = 270, dist = 3	},
					},
		["Xac16"] =	{
						{angle = 30	, dist = 1	},
						{angle = 330, dist = 1	},
						{angle = 150, dist = 1	},
						{angle = 210, dist = 1	},
						{angle = 30	, dist = 2	},
						{angle = 330, dist = 2	},
						{angle = 150, dist = 2	},
						{angle = 210, dist = 2	},
						{angle = 30	, dist = 3	},
						{angle = 330, dist = 3	},
						{angle = 150, dist = 3	},
						{angle = 210, dist = 3	},
						{angle = 30	, dist = 4	},
						{angle = 330, dist = 4	},
						{angle = 150, dist = 4	},
						{angle = 210, dist = 4	},
					},
		["O2R"] =	{
						{angle = 0,		dist = 1},					--1
						{angle = 120,	dist = 1},					--2
						{angle = 240,	dist = 1},					--3
						{angle = 60,	dist = 1},					--4
						{angle = 180,	dist = 1},					--5
						{angle = 300,	dist = 1},					--6
						{angle = 0,		dist = 2},					--7
						{angle = 120,	dist = 2},					--8
						{angle = 240,	dist = 2},					--9
						{angle = 60,	dist = 2},					--10
						{angle = 180,	dist = 2},					--11
						{angle = 300,	dist = 2},					--12
						{angle = 30,	dist = 1.7320508075689},	--13
						{angle = 150,	dist = 1.7320508075689},	--14
						{angle = 270,	dist = 1.7320508075689},	--15
						{angle = 90,	dist = 1.7320508075689},	--16
						{angle = 210,	dist = 1.7320508075689},	--17
						{angle = 330,	dist = 1.7320508075689},	--18
					},
		["Xac12"] =	{
						{angle = 30	, dist = 1	},
						{angle = 330, dist = 1	},
						{angle = 150, dist = 1	},
						{angle = 210, dist = 1	},
						{angle = 30	, dist = 2	},
						{angle = 330, dist = 2	},
						{angle = 150, dist = 2	},
						{angle = 210, dist = 2	},
						{angle = 30	, dist = 3	},
						{angle = 330, dist = 3	},
						{angle = 150, dist = 3	},
						{angle = 210, dist = 3	},
					},
		["X16"] =	{
						{angle = 60	, dist = 1	},
						{angle = 300, dist = 1	},
						{angle = 120, dist = 1	},
						{angle = 240, dist = 1	},
						{angle = 60	, dist = 2	},
						{angle = 300, dist = 2	},
						{angle = 120, dist = 2	},
						{angle = 240, dist = 2	},
						{angle = 60	, dist = 3	},
						{angle = 300, dist = 3	},
						{angle = 120, dist = 3	},
						{angle = 240, dist = 3	},
						{angle = 60	, dist = 4	},
						{angle = 300, dist = 4	},
						{angle = 120, dist = 4	},
						{angle = 240, dist = 4	},
					},
		["X12"] =	{
						{angle = 60	, dist = 1	},
						{angle = 300, dist = 1	},
						{angle = 120, dist = 1	},
						{angle = 240, dist = 1	},
						{angle = 60	, dist = 2	},
						{angle = 300, dist = 2	},
						{angle = 120, dist = 2	},
						{angle = 240, dist = 2	},
						{angle = 60	, dist = 3	},
						{angle = 300, dist = 3	},
						{angle = 120, dist = 3	},
						{angle = 240, dist = 3	},
					},
		["Xac8"] =	{
						{angle = 30	, dist = 1	},
						{angle = 330, dist = 1	},
						{angle = 150, dist = 1	},
						{angle = 210, dist = 1	},
						{angle = 30	, dist = 2	},
						{angle = 330, dist = 2	},
						{angle = 150, dist = 2	},
						{angle = 210, dist = 2	},
					},
		["*12"] =	{
						{angle = 30	, dist = 1	},
						{angle = 90	, dist = 1	},
						{angle = 330, dist = 1	},
						{angle = 150, dist = 1	},
						{angle = 210, dist = 1	},
						{angle = 270, dist = 1	},
						{angle = 30	, dist = 2	},
						{angle = 90	, dist = 2	},
						{angle = 330, dist = 2	},
						{angle = 150, dist = 2	},
						{angle = 210, dist = 2	},
						{angle = 270, dist = 2	},
					},
		["H"] =		{
						{angle = 90	, dist = 1	},
						{angle = 270, dist = 1	},
						{angle = 45 , dist = math.sqrt(2) },
						{angle = 135, dist = math.sqrt(2) },
						{angle = 225, dist = math.sqrt(2) },
						{angle = 315, dist = math.sqrt(2) },
					},
		["M6"] =	{
						{angle = 60	, dist = 1	},
						{angle = 90	, dist = 1	},
						{angle = 300, dist = 1	},
						{angle = 270, dist = 1	},
						{angle = 120, dist = 1.3},
						{angle = 240, dist = 1.3},
					},
		["X8"] =	{
						{angle = 60	, dist = 1	},
						{angle = 300, dist = 1	},
						{angle = 120, dist = 1	},
						{angle = 240, dist = 1	},
						{angle = 60	, dist = 2	},
						{angle = 300, dist = 2	},
						{angle = 120, dist = 2	},
						{angle = 240, dist = 2	},
					},
		["Wac"] =	{
						{angle = 150, dist = 1	},
						{angle = 210, dist = 1	},
						{angle = 90	, dist = 1	},
						{angle = 270, dist = 1	},
					},
		["Mac"] =	{
						{angle = 30	, dist = 1	},
						{angle = 90	, dist = 1	},
						{angle = 330, dist = 1	},
						{angle = 270, dist = 1	},
					},
		["Xac"] =	{
						{angle = 30	, dist = 1	},
						{angle = 330, dist = 1	},
						{angle = 150, dist = 1	},
						{angle = 210, dist = 1	},
					},
		["W"] =		{
						{angle = 120, dist = 1	},
						{angle = 240, dist = 1	},
						{angle = 90	, dist = 1	},
						{angle = 270, dist = 1	},
					},
		["M"] =		{
						{angle = 60	, dist = 1	},
						{angle = 90	, dist = 1	},
						{angle = 300, dist = 1	},
						{angle = 270, dist = 1	},
					},
		["A"] =		{
						{angle = 120, dist = 1	},
						{angle = 240, dist = 1	},
					},
		["Vac"] =	{
						{angle = 30	, dist = 1	},
						{angle = 330, dist = 1	},
					},
		["X"] =		{
						{angle = 60	, dist = 1	},
						{angle = 300, dist = 1	},
						{angle = 120, dist = 1	},
						{angle = 240, dist = 1	},
					},
		["V"] =		{
						{angle = 60	, dist = 1	},
						{angle = 300, dist = 1	},
					},
		}
	fleetComposition = "Random"
	fleet_composition_labels = {
		["Random"] = _("buttonGM","Random"),
		["Fighters"] = _("buttonGM","Fighters"),
		["Chasers"] = _("buttonGM","Chasers"),
		["Frigates"] = _("buttonGM","Frigates"),
		["Beamers"] = _("buttonGM","Beamers"),
		["Missilers"] = _("buttonGM","Missilers"),
		["Adders"] = _("buttonGM","Adders"),
		["Non-DB"] = _("buttonGM","Non-DB"),
		["Drones"] = _("buttonGM","Drones"),
	}
	template_pool_size = 10
	star_list = {
		{radius = random(600,1400), distance = random(-2500,-1400), 
			info = {
				{
					name = "Gamma Piscium",
					unscanned = _("scienceDescription-star","Yellow,\nspectral type G8 III"),
					scanned = _("scienceDescription-star","Yellow,\nspectral type G8 III,\ngiant,\nsurface temperature 4,833 K,\n11 solar radii"),
				},
				{
					name = "Beta Leporis",
					unscanned = _("scienceDescription-star","Classification G5 II"),
					scanned = _("scienceDescription-star","Classification G5 II,\nbright giant,\nbinary"),
				},
				{
					name = "Sigma Draconis",
					unscanned = _("scienceDescription-star","Classification K0 V or G9 V"),
					scanned = _("scienceDescription-star","Classification K0 V or G9 V,\nmain sequence dwarf,\n84% of Sol mass"),
				},
				{
					name = "Iota Carinae",
					unscanned = _("scienceDescription-star","Classification A7 lb"),
					scanned = _("scienceDescription-star","Classification A7 lb,\nsupergiant,\ntemperature 7,500 K,\n7xSol mass"),
				},
				{
					name = "Theta Arietis",
					unscanned = _("scienceDescription-star","Classification A1 Vn"),
					scanned = _("scienceDescription-star","Classification A1 Vn,\ntype A main sequence,\nnebulous"),
				},
				{
					name = "Epsilon Indi",
					unscanned = _("scienceDescription-star","Classification K5V"),
					scanned = _("scienceDescription-star","Classification K5V,\norange,\ntemperature 4,649 K"),
				},
				{
					name = "Beta Hydri",
					unscanned = _("scienceDescription-star","Classification G2 IV"),
					scanned = _("scienceDescription-star","Classification G2 IV,\n113% of Sol mass,\n185% Sol radius"),
				},
				{
					name = "Acamar",
					unscanned = _("scienceDescription-star","Classification A3 IV-V"),
					scanned = _("scienceDescription-star","Classification A3 IV-V,\n2.6xSol mass"),
				},
				{
					name = "Bellatrix",
					unscanned = _("scienceDescription-star","Classification B2 III or B2 V"),
					scanned = _("scienceDescription-star","Classification B2 III or B2 V,\n8.6xSol mass,\ntemperature 22,000 K"),
				},
				{
					name = "Castula",
					unscanned = _("scienceDescription-star","Classification G8 IIIb Fe-0.5"),
					scanned = _("scienceDescription-star","Classification G8 IIIb Fe-0.5,\nyellow,\nred clump giant"),
				},
				{
					name = "Dziban",
					unscanned = _("scienceDescription-star","Classification F5 IV-V"),
					scanned = _("scienceDescription-star","Classification F5 IV-V,\nF-type subgiant\nF-type main sequence"),
				},
				{
					name = "Elnath",
					unscanned = _("scienceDescription-star","Classification B7 III"),
					scanned = _("scienceDescription-star","Classification B7 III,\nB-class giant,\n5xSol mass"),
				},
				{
					name = "Flegetonte",
					unscanned = _("scienceDescription-star","Classification K0"),
					scanned = _("scienceDescription-star","Classification K0,\norange-red,\ntemperature ~4,000 K"),
				},
				{
					name = "Geminga",
					unscanned = _("scienceDescription-star","Pulsar or Neutron star"),
					scanned = _("scienceDescription-star","Pulsar or Neutron star,\ngamma ray source"),
				},
				{	
					name = "Helvetios",	
					unscanned = _("scienceDescription-star","Classification G2V"),
					scanned = _("scienceDescription-star","Classification G2V,\nyellow,\ntemperature 5,571 K"),
				},
				{	
					name = "Inquill",	
					unscanned = _("scienceDescription-star","Classification G1V(w)"),
					scanned = _("scienceDescription-star","Classification G1V(w),\n1.24xSol mass,n7th magnitude G-type main sequence"),
				},
				{	
					name = "Jishui",	
					unscanned = _("scienceDescription-star","Classification F3 III"),
					scanned = _("scienceDescription-star","Classification F3 III,\nF-type giant,\ntemperature 6,309 K"),
				},
				{	
					name = "Kaus Borealis",	
					unscanned = _("scienceDescription-star","Classification K1 IIIb"),
					scanned = _("scienceDescription-star","Classification K1 IIIb,\ngiant,\ntemperature 4,768 K"),
				},
				{	
					name = "Liesma",	
					unscanned = _("scienceDescription-star","Classification G0V"),
					scanned = _("scienceDescription-star","Classification G0V,\nG-type giant, \ntemperature 5,741 K"),
				},
				{	
					name = "Macondo",	
					unscanned = _("scienceDescription-star","Classification K2IV-V or K3V"),
					scanned = _("scienceDescription-star","Classification K2IV-V or K3V,\norange,\nK-type main sequence,\ntemperature 5,030 K"),
				},
				{	
					name = "Nikawiy",	
					unscanned = _("scienceDescription-star","Classification G5"),
					scanned = _("scienceDescription-star","Classification G5,\nyellow,\nluminosity 7.7"),
				},
				{	
					name = "Orkaria",	
					unscanned = _("scienceDescription-star","Classification M4.5"),
					scanned = _("scienceDescription-star","Classification M4.5,\nRed Dwarf,\nluminosity .0035,\ntemperature 3,111 K"),
				},
				{	
					name = "Poerava",	
					unscanned = _("scienceDescription-star","Classification F7V"),
					scanned = _("scienceDescription-star","Classification F7V,\nyellow-white,\nluminosity 1.9,\ntemperature 6,440 K"),
				},
				{	
					name = "Stribor",	
					unscanned = _("scienceDescription-star","Classification F8V"),
					scanned = _("scienceDescription-star","Classification F8V,\nluminosity 2.9,\ntemperature 6,122 K"),
				},
				{	
					name = "Taygeta",	
					unscanned = _("scienceDescription-star","Classification B"),
					scanned = _("scienceDescription-star","Classification B-type subgiant, blue-white, luminosity 600, temperature 13,696 K"),
				},
				{	
					name = "Tuiren",	
					unscanned = _("scienceDescription-star","Classification G"),
					scanned = _("scienceDescription-star","Classification G,\nmagnitude 12.26,\ntemperature 5,580 K"),
				},
				{	
					name = "Ukdah",	
					unscanned = _("scienceDescription-star","Classification K"),
					scanned = _("scienceDescription-star","Classification K2.5 III,\nK-type giant,\ntemperature 4,244 K"),
				},
				{	
					name = "Wouri",	
					unscanned = _("scienceDescription-star","Classification K"),
					scanned = _("scienceDescription-star","Classification 5V,\nK-type main sequence,\ntemperature 4,782 K"),
				},
				{	
					name = "Xihe",	
					unscanned = _("scienceDescription-star","Classification G"),
					scanned = _("scienceDescription-star","Classification G8 III,\nevolved G-type giant,\ntemperature 4,790 K"),
				},
				{	
					name = "Yildun",	
					unscanned = _("scienceDescription-star","Classification A"),
					scanned = _("scienceDescription-star","Classification A1 Van,\nwhite hued,\nA-type main sequence,\ntemperature 9,911 K"),
				},
				{	
					name = "Zosma",	
					unscanned = _("scienceDescription-star","Classification A"),
					scanned = _("scienceDescription-star","Classification A4 V,\nwhite hued,\nA-type main sequence,\ntemperature 8,296 K"),
				},
			},
			color = {
				red = random(0.5,1), green = random(0.5,1), blue = random(0.5,1)
			},
			texture = {
				atmosphere = "planets/star-1.png"
			},
		},
	}
	planet_list = {
		{
			name = {"Bespin","Aldea","Bersallis"},
			unscanned = _("scienceDescription-planet","Class J"),
			scanned = _("scienceDescription-planet","Class J, Jovian, source for hydrogen and helium and a large variety of exotic gasses"),
			texture = {
				surface = "planets/gas-1.png"
			},
			radius = random(4000,7500),
		},
		{
			name = {"Farius Prime","Deneb","Mordan"},
			unscanned = _("scienceDescription-planet","Class J"),
			scanned = _("scienceDescription-planet","Class J, Neptunian, source for hydrogen helium, ammonia, methane, water"),
			texture = {
				surface = "planets/gas-2.png"
			},
			radius = random(4000,7500),
		},
		{
			name = {"Kepler-7b","Alpha Omicron","Nelvana"},
			unscanned = _("scienceDescription-planet","Class J"),
			scanned = _("scienceDescription-planet","Class J, Neptunian, composed of hydrogen, helium, methane, water"),
			texture = {
				surface = "planets/gas-3.png"
			},
			radius = random(4000,7500),
		},
		{
			name = {"Alderaan","Dagobah","Dantooine","Rigel"},
			color = {
				red = random(0,0.2), 
				green = random(0,0.2), 
				blue = random(0.8,1)
			},
			texture = {
				surface = "planets/planet-1.png", 
				cloud = "planets/clouds-1.png", 
				atmosphere = "planets/atmosphere.png"
			},
			radius = random(3000,5000),
		},
		{
			name = {"Pahvo","Penthara","Scalos"},
			color = {
				red = random(0,0.2), 
				green = random(0,0.2), 
				blue = random(0.8,1)
			},
			texture = {
				surface = "planets/planet-4.png", 
				cloud = "planets/clouds-3.png", 
				atmosphere = "planets/atmosphere.png"
			},
			radius = random(3000,5000),
		},
		{
			name = {"Tanuga","Vacca","Terlina","Timor"},
			color = {
				red = random(0,0.2), 
				green = random(0,0.2), 
				blue = random(0.8,1)
			},
			texture = {
				surface = "planets/planet-5.png", 
				cloud = "planets/clouds-2.png", 
				atmosphere = "planets/atmosphere.png"
			},
			radius = random(3000,5000),
		},
	}
	moon_list = {
		{
			name = {"Ganymede", "Europa", "Deimos", "Luna"},
			texture = {
				surface = "planets/moon-1.png"
			},
			radius = random(1000,3000),
		},
		{
			name = {"Myopia", "Zapata", "Lichen", "Fandango"},
			texture = {
				surface = "planets/moon-2.png"
			},
			radius = random(1000,3000),
		},
		{
			name = {"Scratmat", "Tipple", "Dranken", "Calypso"},
			texture = {
				surface = "planets/moon-3.png"
			},
			radius = random(1000,3000),
		},
	}
	artifact_number = 0
	sensor_jammer_list = {}
	warp_jammer_list = {}
	warp_jammer_info = {
		["Human Navy"] =	{id = "H", count = 0},
		["Independent"] =	{id = "I", count = 0},
		["Kraylor"] =		{id = "K", count = 0},
		["Arlenians"] =		{id = "A", count = 0},
		["Exuari"] =		{id = "E", count = 0},
		["Ghosts"] =		{id = "G", count = 0},
		["Ktlitans"] =		{id = "B", count = 0},
		["TSN"] =			{id = "T", count = 0},
		["USN"] =			{id = "U", count = 0},
		["CUF"] =			{id = "C", count = 0},
		["Mehklar"] =		{id = "M", count = 0},
	}
	advertising_billboards = {
		_("scienceDescription-buoy","Come to Billy Bob's for the best food in the sector"),
		_("scienceDescription-buoy","It's never too late to buy life insurance"),
		_("scienceDescription-buoy","You'll feel better in an Adder Mark 9"),
		_("scienceDescription-buoy","Melinda's Mynock Management service: excellent rates, satisfaction guaranteed"),
		_("scienceDescription-buoy","Visit Repulse shipyards for the best deals"),
		_("scienceDescription-buoy","Fresh fish! We catch, you buy!"),
		_("scienceDescription-buoy","Get your fuel cells at Mariana's Market"),
		_("scienceDescription-buoy","Find a special companion. All species available"),
		_("scienceDescription-buoy","Feeling down? Robotherapist is there for you"),
		_("scienceDescription-buoy","30 days, 30 kilograms, guaranteed"),
		_("scienceDescription-buoy","Be sure to drink your Ovaltine"),
		_("scienceDescription-buoy","Need a personal upgrade? Contact Celine's Cybernetic Implants"),
		_("scienceDescription-buoy","Try our asteroid dust diet weight loss program"),
		_("scienceDescription-buoy","Best tasting water in the quadrant at Willy's Waterway"),
		_("scienceDescription-buoy","Amazing shows every night at Lenny's Lounge"),
		_("scienceDescription-buoy","Get all your vaccinations at Fred's Pharmacy. Pick up some snacks, too"),
		_("scienceDescription-buoy","Tip: make lemons an integral part of your diet"),
		_("scienceDescription-buoy","Visit the Proboscis shop for all your specialty probe needs"),
	}
end
function setVariations()
	local player_ships_config = {
		["One"] =	1,
		["Two"] =	2,
		["Three"] =	3,
		["Four"] =	4,
		["Five"] =	5,
		["Six"] =	6,
	}
	player_ship_count = player_ships_config[getScenarioSetting("Players")]
	local enemy_config = {
		["Easy"] =		{number = .5},
		["Normal"] =	{number = 1},
		["Hard"] =		{number = 2},
		["Extreme"] =	{number = 3},
		["Quixotic"] =	{number = 5},
	}
	enemy_power =	enemy_config[getScenarioSetting("Enemies")].number
	local murphy_config = {
		["Easy"] =		{number = .5,	rm = 1},
		["Normal"] =	{number = 1,	rm = 1},
		["Hard"] =		{number = 2,	rm = 1.1},
		["Extreme"] =	{number = 3,	rm = 1.2},
		["Quixotic"] =	{number = 5,	rm = 1.5},
	}
	difficulty =		murphy_config[getScenarioSetting("Murphy")].number
	range_multiplier =	murphy_config[getScenarioSetting("Murphy")].rm
	local reputation_config = {
		["Unknown"] = 		0,
		["Nice"] = 			20,
		["Hero"] = 			50,
		["Major Hero"] =	100,
		["Super Hero"] =	200,
	}
	reputation_start_amount = reputation_config[getScenarioSetting("Reputation")]
	local transfer_config = {
		["Short"] =		5,
		["Medium"] =	8,
		["Long"] =		12,
		["Restful"] =	17,
	}
	transfer_interval = transfer_config[getScenarioSetting("Transfer")]
end
--	Terrain
function constructEnvironment()
	center_x = random(100000,200000)
	center_y = random(50000,100000)
	inner_space = {}
	stations = {}
	inner_stations = {}
	transports = {}
	--	central star
	local radius = random(600,1400)
	central_star = Planet():setPlanetRadius(radius):setDistanceFromMovementPlane(-radius*.5):setPosition(center_x, center_y)
	if random(1,100) < 43 then
		central_star:setDistanceFromMovementPlane(radius*.5)
	end
	local star_item = tableRemoveRandom(star_list[1].info)
	central_star:setCallSign(star_item.name)
	if star_item.unscanned ~= nil then
		central_star:setDescriptions(star_item.unscanned,star_item.scanned)
		central_star:setScanningParameters(1,2)
	end
	central_star:setPlanetAtmosphereTexture(star_list[1].texture.atmosphere):setPlanetAtmosphereColor(random(0.5,1),random(0.5,1),random(0.5,1))
	table.insert(inner_space,{obj=central_star,dist=radius,shape="circle"})
	--	home station
	player_faction = "Human Navy"
	local station_angle = random(0,360)
	home_station_x, home_station_y = vectorFromAngle(station_angle,random(6000,10000),true)
	home_station_x = home_station_x + center_x
	home_station_y = home_station_y + center_y
	local home_station_size = szt("Small Station")
	home_station = placeStation(home_station_x, home_station_y,"RandomHumanNeutral","Human Navy",home_station_size)
	home_station_name = home_station:getCallSign()
	home_station:setShortRangeRadarRange(10000 + random(0,5000))
	local missile_available_count = 0
	if home_station.comms_data.weapon_available.Homing then
		missile_available_count = missile_available_count + 1
	end
	if home_station.comms_data.weapon_available.Nuke then
		missile_available_count = missile_available_count + 1
	end
	if home_station.comms_data.weapon_available.Mine then
		missile_available_count = missile_available_count + 1
	end
	if home_station.comms_data.weapon_available.EMP then
		missile_available_count = missile_available_count + 1
	end
	if home_station.comms_data.weapon_available.HVLI then
		missile_available_count = missile_available_count + 1
	end
	if missile_available_count == 0 then
		home_station.comms_data.weapon_available.Homing = true
		home_station.comms_data.weapon_available.Nuke = true
		home_station.comms_data.weapon_available.Mine = true
		home_station.comms_data.weapon_available.EMP = true
		home_station.comms_data.weapon_available.HVLI = true
	end
	table.insert(stations,home_station)
	table.insert(inner_stations,home_station)
	table.insert(inner_space,{obj=home_station,dist=4000,shape="circle"})
	--	inner stations
	local station_angle = random(0,360)
	local psx, psy = vectorFromAngle(station_angle,random(15000,45000),true)
	local placed_station = placeStation(psx + center_x,psy + center_y,"RandomHumanNeutral","Independent")
	table.insert(stations,placed_station)
	table.insert(inner_stations,placed_station)
	table.insert(inner_space,{obj=placed_station,dist=4000,shape="circle"})
	local a_station_angle = station_angle + random(90,150)
	psx, psy = vectorFromAngle(a_station_angle,random(15000,45000),true)
	placed_station = placeStation(psx + center_x,psy + center_y,"RandomHumanNeutral","Independent")
	table.insert(stations,placed_station)
	table.insert(inner_stations,placed_station)
	table.insert(inner_space,{obj=placed_station,dist=4000,shape="circle"})
	a_station_angle = station_angle - random(90,150)
	psx, psy = vectorFromAngle(a_station_angle,random(15000,45000),true)
	placed_station = placeStation(psx + center_x,psy + center_y,"RandomHumanNeutral","Independent")
	table.insert(stations,placed_station)
	table.insert(inner_stations,placed_station)
	table.insert(inner_space,{obj=placed_station,dist=4000,shape="circle"})
	--	player start
	local player_start_angle = (station_angle + 90) % 360
	player_spawn_x, player_spawn_y = vectorFromAngle(player_start_angle,25000,true)
	player_spawn_x = player_spawn_x + home_station_x
	player_spawn_y = player_spawn_y + home_station_y
	local sp = 3000	--start spacing of player ships
	multi_player_spawn = {	-- a is angle, d is distance
		{	--single player ship
			{a = 0,		d = 0},
		},
		{	--two player ships
			{a = 90,	d = sp},
			{a = 270,	d = sp},
		},
		{	--three player ships
			{a = 0,		d = 0},
			{a = 120,	d = sp},
			{a = 240,	d = sp},
		},
		{	--four player ships
			{a = 90,	d = sp},
			{a = 270,	d = sp},
			{a = 135,	d = math.sqrt(sp * sp + sp * sp)},
			{a = 225,	d = math.sqrt(sp * sp + sp * sp)},
		},
		{	--five player ships
			{a = 0,		d = 0},
			{a = 120,	d = sp},
			{a = 240,	d = sp},
			{a = 120,	d = sp * 2},
			{a = 240,	d = sp * 2},
		},
		{	--six player ships
			{a = 0,		d = 0},
			{a = 120,	d = sp},
			{a = 240,	d = sp},
			{a = 120,	d = sp * 2},
			{a = 240,	d = sp * 2},
			{a = 180,	d = sp},
		},
	}
	for i=1,player_ship_count do
		local temp_type_name = "Striker"
		local p = PlayerSpaceship():setTemplate(temp_type_name):setFaction("Human Navy")
		local sx, sy = vectorFromAngle(player_start_angle + multi_player_spawn[player_ship_count][i].a,multi_player_spawn[player_ship_count][i].d,true)
		sx = sx + player_spawn_x
		sy = sy + player_spawn_y
		p:setPosition(sx, sy):setHeading((player_start_angle + 180) % 360):commandTargetRotation((player_start_angle + 90) % 360)
		p.normal_long_range_radar = player_ship_stats[temp_type_name].long_range_radar
		p:setBeamWeapon(0, 50,-10, 800.0, 6.0, 6)
		p:setBeamWeapon(1, 50, 10, 800.0, 6.0, 6)
		p:setBeamWeapon(2, 10, 0, 1000.0, 6.0, 4):setBeamWeaponDamageType(2,"emp")
		p:setBeamWeaponTurret( 0, 0, 0, 0)
		p:setBeamWeaponTurret( 1, 0, 0, 0)
		p:setBeamWeaponTurret( 2, 200, 0, 2)
		p:setImpulseMaxSpeed(80,60)	--faster than default 45/45
		p:commandImpulse(1)
		local player_ship_name_list = player_ship_names_for["Striker"]
		local player_ship_name = nil
		if player_ship_name_list ~= nil then
			player_ship_name = tableRemoveRandom(player_ship_name_list)
		end
		if player_ship_name == nil then
			player_ship_name = tableSelectRandom(player_ship_names_for["Leftovers"])
		end
		if player_ship_name ~= nil then
			p:setCallSign(player_ship_name)
		end
		p:onDestruction(playerStrikerDestroyed)
		table.insert(inner_space,{obj=p,dist=5000,shape="circle"})
		p.player_escorts = {}
		for j,form in ipairs(fly_formation["X"]) do
			local ship = CpuShip():setTemplate("Fighter"):setFaction("Human Navy")
			local form_x, form_y = vectorFromAngle(player_start_angle + 180 + form.angle, form.dist * 1000, true)
			local form_prime_x, form_prime_y = vectorFromAngle(form.angle, form.dist * 1000)
			ship.form_prime_x = form_prime_x
			ship.form_prime_y = form_prime_y
			ship.formation_leader = p
			ship:setPosition(sx + form_x, sy + form_y):setHeading(player_start_angle + 180):orderFlyFormation(p,form_prime_x,form_prime_y)
			ship:setCallSign(generateCallSign(p:getCallSign()))
			ship:setScannedByFaction("Human Navy",true)
			ship:setCommsFunction(commsFormationFighters)
			table.insert(p.player_escorts,ship)
		end
	end
	fleetComposition = "Fighters"
	enemy_spawn_x, enemy_spawn_y = vectorFromAngle(player_start_angle + 180,15000,true)
	enemy_spawn_x = enemy_spawn_x + home_station_x
	enemy_spawn_y = enemy_spawn_y + home_station_y
	relative_strength = 1.5	--2 was too hard. trying 1.5
	enemy_fighter_fleet = spawnRandomArmed(enemy_spawn_x, enemy_spawn_y)
	for i,ship in ipairs(enemy_fighter_fleet) do
		ship:orderFlyTowards(home_station_x,home_station_y)
		table.insert(inner_space,{obj=ship,dist=500,shape="circle"})
	end
	relative_strength = 1
	fleetComposition = "Random"
	missionMaintenance = startInitialMission
	allowNewPlayerShips(false)
	--	band planet
	local band_angle = random(0,360)
	local bp_x, bp_y = vectorFromAngle(band_angle,75000,true)
	local band_planet_item = tableRemoveRandom(planet_list)
	local band_planet_radius = band_planet_item.radius
	band_planet = Planet():setPosition(bp_x + center_x,bp_y + center_y):setPlanetRadius(band_planet_radius)
	band_planet:setDistanceFromMovementPlane(band_planet_radius*-.3)
	band_planet:setCallSign(tableSelectRandom(band_planet_item.name))
	band_planet:setPlanetSurfaceTexture(band_planet_item.texture.surface)
	rotation_time = random(300,500)
	if band_planet_item.texture.atmosphere ~= nil then
		rotation_time = rotation_time * .65
		band_planet:setPlanetAtmosphereTexture(band_planet_item.texture.atmosphere)
	end
	if band_planet_item.texture.cloud ~= nil then
		band_planet:setPlanetCloudTexture(band_planet_item.texture.cloud)
	end
	if band_planet_item.color ~= nil then
		band_planet:setPlanetAtmosphereColor(band_planet_item.color.red,band_planet_item.color.green,band_planet_item.color.blue)
	end
	band_planet:setAxialRotationTime(rotation_time)
	band_planet:setOrbit(central_star,2300)
	if band_planet_item.unscanned ~= nil then
		band_planet:setDescriptions(band_planet_item.unscanned,band_planet_item.scanned)
		band_planet:setScanningParameters(1,2)
	end
	--	band moon
	band_angle = random(0,360)
	local bm_x, bm_y = vectorFromAngle(band_angle,band_planet_radius + 8000)
	local band_moon_item = tableRemoveRandom(moon_list)
	local band_moon_radius = band_moon_item.radius
	band_moon = Planet():setPosition(bm_x + bp_x + center_x,bm_y + bp_y + center_y):setPlanetRadius(band_moon_radius)
	band_moon:setDistanceFromMovementPlane(band_moon_radius*.25)
	band_moon:setCallSign(tableSelectRandom(band_moon_item.name))
	band_moon:setPlanetSurfaceTexture(band_moon_item.texture.surface)
	band_moon:setAxialRotationTime(random(400,600))
	band_moon:setOrbit(band_planet,random(100,300))
	distort_bell = {
		{lo = 1000,	hi = 2250},
		{lo = 1000,	hi = 2250},
		{lo = 1000,	hi = 2250},
		{lo = 1000,	hi = 2250},
		{lo = 1000,	hi = 2250},
		{lo = 1000,	hi = 2250},	
		{lo = 1000,	hi = 2250},
		{lo = 1000,	hi = 2250},
	}
	placement_areas = {
		["Inner Torus"] = {
			stations = inner_stations,
			transports = transports, 
			space = inner_space,
			shape = "torus",
			center_x = center_x, 
			center_y = center_y, 
			inner_radius = radius + 4000, 
			outer_radius = 50000,
		},
	}
	local terrain = {
--		{chance = 4,	count = 0,	max = math.random(1,2),		radius = "Star",	obj = Planet,		desc = "Star",		},
--		{chance = 4,	count = 0,	max = math.random(1,2),		radius = "Hole",	obj = BlackHole,						},
		{chance = 7,	count = 0,	max = -1,					radius = "Tiny",	obj = ScanProbe,						},
		{chance = 4,	count = 0,	max = math.random(7,15),	radius = "Tiny",	obj = WarpJammer,						},
		{chance = 6,	count = 0,	max = math.random(3,9),		radius = "Tiny",	obj = Artifact,		desc = "Jammer",	},
--		{chance = 3,	count = 0,	max = math.random(1,3),		radius = "Hole",	obj = WormHole,							},
		{chance = 6,	count = 0,	max = math.random(2,5),		radius = "Tiny",	obj = Artifact,		desc = "Sensor",	},
		{chance = 8,	count = 0,	max = -1,					radius = "Tiny",	obj = Artifact,		desc = "Ad",		},
		{chance = 8,	count = 0,	max = -1,					radius = "Neb",		obj = Nebula,							},
		{chance = 5,	count = 0,	max = -1,					radius = "Mine",	obj = Mine,								},
		{chance = 5,	count = 0,	max = math.random(3,7),		radius = "Circ",	obj = Mine,			desc = "Circle",	},
		{chance = 5,	count = 0,	max = math.random(3,9),		radius = "Rect",	obj = Mine,			desc = "Rectangle",	},
		{chance = 5,	count = 0,	max = math.random(2,7),		radius = "Field",	obj = Asteroid,		desc = "Field",		},
		{chance = 6,	count = 0,	max = math.random(3,9),		radius = "Blob",	obj = Asteroid,		desc = "Blob",		},
		{chance = 6,	count = 0,	max = math.random(3,9),		radius = "Blob",	obj = Mine,			desc = "Blob",		},
--		{chance = 4,	count = 0,	max = 10,					radius = "Trans",	obj = CpuShip,		desc = "Transport",	},
		{chance = 4,	count = 0,	max = 10,					radius = "Tiny",	obj = SupplyDrop,						},
	}
	local objects_placed_count = 0
	repeat
		local roll = random(0,100)
		local object_chance = 0
		for i,terrain_object in ipairs(terrain) do
			object_chance = object_chance + terrain_object.chance
			local placement_result = false
			if roll <= object_chance then
				if terrain_object.max < 0 or terrain_object.count < terrain_object.max then
					placement_result = placeTerrain("Inner Torus",terrain_object)
				else
					placement_result = placeTerrain("Inner Torus",{obj = Asteroid, desc = "Lone", radius = "Tiny"})
				end
				if placement_result then
					terrain_object.count = terrain_object.count + 1
				end
				break
			elseif i == #terrain then
				placement_result = placeTerrain("Inner Torus",{obj = Asteroid, desc = "Lone", radius = "Tiny"})
				if placement_result then
					terrain_object.count = terrain_object.count + 1
				end
			end
		end
		objects_placed_count = objects_placed_count + 1
	until(objects_placed_count >= 20)
	--	target station
	target_station_angle = (station_angle - 90) % 360
	local target_station_x, target_station_y = vectorFromAngle(target_station_angle,150000,true)
	target_station_x = target_station_x + home_station_x
	target_station_y = target_station_y + home_station_y
	target_station = placeStation(target_station_x,target_station_y,"Sinister","Kraylor")
	if difficulty > 1 then
		local dp_angle = random(0,360)
		for i=1,6 do
			local dp_x, dp_y = vectorFromAngle(dp_angle,3000)
			dp_x = dp_x + target_station_x
			dp_y = dp_y + target_station_y
			local dp = CpuShip():setTemplate("Defense platform"):setFaction("Kraylor")
			dp:setPosition(dp_x,dp_y):orderStandGround()
			dp_angle = (dp_angle + 60) % 360
		end
	end
end
function findClearSpot(objects,area_shape,area_point_x,area_point_y,area_distance,area_distance_2,area_angle,new_buffer,placing_station)
	--area distance 2 is only required for torus areas, bell torus areas and rectangle areas
	--area angle is only required for rectangle areas
--	assert(type(objects)=="table",string.format("function findClearSpot expects an object list table as the first parameter, but got a %s instead",type(objects)))
--	assert(type(area_shape)=="string",string.format("function findClearSpot expects an area shape string as the second parameter, but got a %s instead",type(area_shape)))
--	assert(type(area_point_x)=="number",string.format("function findClearSpot expects an area point X coordinate number as the third parameter, but got a %s instead",type(area_point_x)))
--	assert(type(area_point_y)=="number",string.format("function findClearSpot expects an area point Y coordinate number as the fourth parameter, but got a %s instead",type(area_point_y)))
--	assert(type(area_distance)=="number",string.format("function findClearSpot expects an area distance number as the fifth parameter, but got a %s instead",type(area_distance)))
	local valid_shapes = {"circle","torus","rectangle"}
--	assert(valid_shapes[area_shape] == nil,string.format("function findClearSpot expects a valid shape in the second parameter, but got %s instead",area_shape))
--	assert(type(new_buffer)=="number",string.format("function findClearSpot expects a new item buffer distance number as the eighth parameter, but got a %s instead",type(new_buffer)))
	local valid_table_item_shapes = {"circle","zone"}
	local far_enough = true
	local current_loop_count = 0
	local cx, cy = 0	--candidate x and y coordinates
	if area_shape == "circle" then
		repeat
			current_loop_count = current_loop_count + 1
			cx, cy = vectorFromAngle(random(0,360),random(0,area_distance),true)
			cx = cx + area_point_x
			cy = cy + area_point_y
			far_enough = true
			for i,item in ipairs(objects) do
--				assert(item.shape ~= nil,string.format("function findClearSpot expects an object list table where each item in the table is identified by shape, but item index %s's shape was nil",i))
--				assert(valid_table_item_shapes[item.shape] == nil,string.format("function findClearSpot expects a valid shape in the object list table item index %i, but got %s instead",i,item.shape))
				if item.shape == "circle" then
--					assert(type(item.obj)=="table",string.format("function findClearSpot expects a space object or table as the object in the object list table item index %i, but got a %s instead",i,type(item.obj)))
					local ix, iy = item.obj:getPosition()
--					assert(type(item.dist)=="number",string.format("function findClearSpot expects a distance number as the dist value in the object list table item index %i, but got a %s instead",i,type(item.dist)))
					local comparison_dist = item.dist
					if placing_station ~= nil then
						if placing_station then
							if isObjectType(item.obj,"SpaceStation") then
								comparison_dist = 12000
							end
						end
					end
					if distance_diagnostic then
						print("distance_diagnostic 1: cx, cy, ix, iy in find clear spot, circle",cx,cy,ix,iy)
					end
					if distance(cx,cy,ix,iy) < (comparison_dist + new_buffer) then
						far_enough = false
						break
					end
				end
				if item.shape == "zone" then
--					assert(type(item.obj)=="table",string.format("function findClearSpot expects a space object or table as the object in the object list table item index %i, but got a %s instead",i,type(item.obj)))
					local ta = Artifact():setPosition(cx,cy)
					if item.obj:isInside(ta) then
						far_enough = false
					end
					ta:destroy()
					if not far_enough then
						break
					end
				end
			end
		until(far_enough or current_loop_count > max_repeat_loop)
		if current_loop_count > max_repeat_loop then
			return
		else
			return cx, cy
		end
	elseif area_shape == "bell torus" then
--		assert(type(area_distance_2)=="table",string.format("function findClearSpot expects a table of random range parameters as the sixth parameter when the shape is bell torus, but got a %s instead",type(area_distance_2)))
		repeat
			local random_radius = 0
			for i,dist in ipairs(area_distance_2) do
				random_radius = random_radius + random(dist.lo,dist.hi)
			end
			cx, cy = vectorFromAngle(random(0,360),random_radius,true)
			cx = cx + area_point_x
			cy = cy + area_point_y
			far_enough = true
			for i,item in ipairs(objects) do
--				assert(item.shape ~= nil,string.format("function findClearSpot expects an object list table where each item in the table is identified by shape, but item index %s's shape was nil",i))
--				assert(valid_table_item_shapes[item.shape] == nil,string.format("function findClearSpot expects a valid shape in the object list table item index %i, but got %s instead",i,item.shape))
				if item.shape == "circle" then
--					assert(type(item.obj)=="table",string.format("function findClearSpot expects a space object or table as the object in the object list table item index %i, but got a %s instead",i,type(item.obj)))
					local ix, iy = item.obj:getPosition()
--					assert(type(item.dist)=="number",string.format("function findClearSpot expects a distance number as the dist value in the object list table item index %i, but got a %s instead",i,type(item.dist)))
					local comparison_dist = item.dist
					if placing_station ~= nil then
						if placing_station then
							if isObjectType(item.obj,"SpaceStation") then
								comparison_dist = 12000
							end
						end
					end
					if distance_diagnostic then
						print("distance_diagnostic 2: cx, cy, ix, iy in find clear spot, bell torus:",cx,cy,ix,iy)
					end
					if distance(cx,cy,ix,iy) < (comparison_dist + new_buffer) then
						far_enough = false
						break
					end
				end
			end
			current_loop_count = current_loop_count + 1
		until(far_enough or current_loop_count > max_repeat_loop)
		if current_loop_count > max_repeat_loop then
			return
		else
			return cx, cy
		end
	elseif area_shape == "torus" then
--		assert(type(area_distance_2)=="number",string.format("function findClearSpot expects an area distance number as the sixth parameter when the shape is torus, but got a %s instead",type(area_distance_2)))
		repeat
			cx, cy = vectorFromAngle(random(0,360),random(area_distance,area_distance_2),true)
			cx = cx + area_point_x
			cy = cy + area_point_y
			far_enough = true
			for i,item in ipairs(objects) do
--				assert(item.shape ~= nil,string.format("function findClearSpot expects an object list table where each item in the table is identified by shape, but item index %s's shape was nil",i))
--				assert(valid_table_item_shapes[item.shape] == nil,string.format("function findClearSpot expects a valid shape in the object list table item index %i, but got %s instead",i,item.shape))
				if item.shape == "circle" then
--					assert(type(item.obj)=="table",string.format("function findClearSpot expects a space object or table as the object in the object list table item index %i, but got a %s instead",i,type(item.obj)))
					local ix, iy = item.obj:getPosition()
--					assert(type(item.dist)=="number",string.format("function findClearSpot expects a distance number as the dist value in the object list table item index %i, but got a %s instead",i,type(item.dist)))
					local comparison_dist = item.dist
					if placing_station ~= nil then
						if placing_station then
							if isObjectType(item.obj,"SpaceStation") then
								comparison_dist = 12000
							end
						end
					end
					if distance_diagnostic then
						print("distance_diagnostic 3: cx, cy, ix, iy: find clear spot, torus:",cx,cy,ix,iy)
					end
					if distance(cx,cy,ix,iy) < (comparison_dist + new_buffer) then
						far_enough = false
						break
					end
				end
			end
			current_loop_count = current_loop_count + 1
		until(far_enough or current_loop_count > max_repeat_loop)
		if current_loop_count > max_repeat_loop then
			return
		else
			return cx, cy
		end
	elseif area_shape == "central rectangle" then
--		assert(type(area_distance_2)=="number",string.format("function findClearSpot expects an area distance number (width) as the sixth parameter when the shape is rectangle, but got a %s instead",type(area_distance_2)))
--		assert(type(area_angle)=="number",string.format("function findClearSpot expects an area angle number as the seventh parameter when the shape is rectangle, but got a %s instead",type(area_angle)))
		repeat
			cx, cy = vectorFromAngle(area_angle,random(-area_distance/2,area_distance/2),true)
			cx = cx + area_point_x
			cy = cy + area_point_y
			local px, py = vectorFromAngle(area_angle + 90,random(-area_distance_2/2,area_distance_2/2),true)
			cx = cx + px
			cy = cy + py
			far_enough = true
			for i,item in ipairs(objects) do
--				assert(item.shape ~= nil,string.format("function findClearSpot expects an object list table where each item in the table is identified by shape, but item index %s's shape was nil",i))
--				assert(valid_table_item_shapes[item.shape] == nil,string.format("function findClearSpot expects a valid shape in the object list table item index %i, but got %s instead",i,item.shape))
				if item.shape == "circle" then
--					assert(type(item.obj)=="table",string.format("function findClearSpot expects a space object or table as the object in the object list table item index %i, but got a %s instead",i,type(item.obj)))
					local ix, iy = item.obj:getPosition()
--					assert(type(item.dist)=="number",string.format("function findClearSpot expects a distance number as the dist value in the object list table item index %i, but got a %s instead",i,type(item.dist)))
					local comparison_dist = item.dist
					if placing_station ~= nil then
						if placing_station then
							if isObjectType(item.obj,"SpaceStation") then
								comparison_dist = 12000
							end
						end
					end
					if distance_diagnostic then
						print("distance_diagnostic 4: cx,cy,ix,iy: find clear spot, central rectangle:",cx,cy,ix,iy)
					end
					if distance(cx,cy,ix,iy) < (comparison_dist + new_buffer) then
						far_enough = false
						break
					end
				end
			end
			current_loop_count = current_loop_count + 1
		until(far_enough or current_loop_count > max_repeat_loop)
		if current_loop_count > max_repeat_loop then
			return
		else
			return cx, cy
		end
	elseif area_shape == "rectangle" then
--		assert(type(area_distance_2)=="number",string.format("function findClearSpot expects an area distance number (width) as the sixth parameter when the shape is rectangle, but got a %s instead",type(area_distance_2)))
--		assert(type(area_angle)=="number",string.format("function findClearSpot expects an area angle number as the seventh parameter when the shape is rectangle, but got a %s instead",type(area_angle)))
		repeat
			cx, cy = vectorFromAngle(area_angle,random(0,area_distance),true)
			cx = cx + area_point_x
			cy = cy + area_point_y
			local px, py = vectorFromAngle(area_angle + 90,random(-area_distance_2/2,area_distance_2/2),true)
			cx = cx + px
			cy = cy + py
			far_enough = true
			for i,item in ipairs(objects) do
--				assert(item.shape ~= nil,string.format("function findClearSpot expects an object list table where each item in the table is identified by shape, but item index %s's shape was nil",i))
--				assert(valid_table_item_shapes[item.shape] == nil,string.format("function findClearSpot expects a valid shape in the object list table item index %i, but got %s instead",i,item.shape))
				if item.shape == "circle" then
--					assert(type(item.obj)=="table",string.format("function findClearSpot expects a space object or table as the object in the object list table item index %i, but got a %s instead",i,type(item.obj)))
					local ix, iy = item.obj:getPosition()
--					assert(type(item.dist)=="number",string.format("function findClearSpot expects a distance number as the dist value in the object list table item index %i, but got a %s instead",i,type(item.dist)))
					local comparison_dist = item.dist
					if placing_station ~= nil then
						if placing_station then
							if isObjectType(item.obj,"SpaceStation") then
								comparison_dist = 12000
							end
						end
					end
					if distance_diagnostic then
						print("distance_diagnostic 5: cx, cy, ix, iy: find clear spot, rectangle:",cx,cy,ix,iy)
					end
					if distance(cx,cy,ix,iy) < (comparison_dist + new_buffer) then
						far_enough = false
						break
					end
				end
			end
			current_loop_count = current_loop_count + 1
		until(far_enough or current_loop_count > max_repeat_loop)
		if current_loop_count > max_repeat_loop then
			return
		else
			return cx, cy
		end
	end
end
function placeTerrain(placement_area,terrain)
	local function getStationPool(placement_area)
		local station_pool = {}
		if placement_areas[placement_area].stations ~= nil and #placement_areas[placement_area].stations > 0 then
			for i,station in ipairs(placement_areas[placement_area].stations) do
				if station:isValid() then
					table.insert(station_pool,station)
				end
			end
		end
		return station_pool
	end
	local function placeAsteroid(placement_area)
		local asteroid_size = random(2,200) + random(2,200) + random(2,200) + random(2,200)
		local area = placement_areas[placement_area]
		local eo_x, eo_y = nil
		if placement_area == "Inner Torus" or placement_area == "Region 2 Torus" or placement_area == "Region 3 Torus" or placement_area == "Region 4 Torus" then
			eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.inner_radius,area.outer_radius,nil,asteroid_size)
		end
		if eo_x ~= nil then
			local ta = Asteroid():setPosition(eo_x, eo_y):setSize(asteroid_size)
			table.insert(area.space,{obj=ta,dist=asteroid_size,shape="circle"})
			local tether = random(asteroid_size + 10,800)
			local v_angle = random(0,360)
			local vx, vy = vectorFromAngle(v_angle,tether,true)
			vx = vx + eo_x
			vy = vy + eo_y
			local vast = VisualAsteroid():setPosition(vx,vy):setSize(random(10,tether))
			tether = random(asteroid_size + 10, asteroid_size + 800)
			v_angle = (v_angle + random(120,240)) % 360
			local vx, vy = vectorFromAngle(v_angle,tether,true)
			vx = vx + eo_x
			vy = vy + eo_x
			vast = VisualAsteroid():setPosition(vx,vy):setSize(random(10,tether))
			return true
		else
			return false
		end
	end
	local radii = {
		["Blob"] =	random(1500,4500),
		["Star"] =	random(600,1400),
		["Hole"] =	6000,
		["Tiny"] = 	200,
		["Neb"] =	3000,
		["Mine"] =	1000,
		["Rect"] =	random(4000,10000),
		["Circ"] =	4000,
		["Field"] =	random(2000,8000),
		["Trans"] =	600,
	}
	local area = placement_areas[placement_area]
	local radius = radii[terrain.radius]
	if radius == nil then
		radius = 200
	end
	local eo_x, eo_y = nil
	--	exceptions to a simple radius for findClearSpot
	local field_size = 0
	if terrain.desc == "Circle" then
		field_size = math.random(1,3)
		radius = radius + (field_size * 1500)
	elseif terrain.desc == "Field" then
		field_size = radius
		radius = radius + 500 
	end
	if placement_area == "Inner Torus" or placement_area == "Region 2 Torus" or placement_area == "Region 3 Torus" or placement_area == "Region 4 Torus" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.inner_radius,area.outer_radius,nil,radius)
	end
	if eo_x ~= nil then
		if terrain.obj == WormHole then
			local we_x, we_y = nil
			local count_repeat_loop = 0
			repeat
				if placement_area == "Region 2 Torus" or placement_area == "Region 3 Torus" or placement_area == "Region 4 Torus" then
					we_x, we_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.inner_radius,area.outer_radius,nil,500)
				end
				count_repeat_loop = count_repeat_loop + 1
				if distance_diagnostic then
					print("distance_diagnostic 6: eo_x, eo_y, we_x, we_y: place terrain, wormhole",eo_x,eo_y,we_x,we_y)
				end
			until((we_x ~= nil and distance(eo_x, eo_y, we_x, we_y) > 50000) or count_repeat_loop > max_repeat_loop)
			if count_repeat_loop > max_repeat_loop then
				print("repeated too many times while placing a wormhole")
				print("eo_x:",eo_x,"eo_y:",eo_y,"we_x:",we_x,"we_y:",we_y)
			end
			if we_x ~= nil then
				local wh = WormHole():setPosition(eo_x, eo_y):setTargetPosition(we_x, we_y)
				wh:onTeleportation(function(self,transportee)
					string.format("")
					if transportee ~= nil then
						if transportee:isValid() then
							if isObjectType(transportee,"PlayerSpaceship") then
								transportee:setEnergy(transportee:getMaxEnergy()/2)	--reduces if more than half, increases if less than half
							end
						end
					end
				end)
				local va_exit = VisualAsteroid():setPosition(we_x, we_y)
				table.insert(area.space,{obj=wh,dist=6000,shape="circle"})
				table.insert(area.space,{obj=va_exit,dist=500,shape="circle"})
				return true
			else
				placeAsteroid(placement_area)
				return false
			end
		elseif terrain.desc == "Jammer" then
			local lo_range = 10000
			local hi_range = 70000
			local lo_impact = 10000
			local hi_impact = 60000
			local range_increment = (hi_range - lo_range)/8
			local impact_increment = (hi_impact - lo_impact)/4
		--	local mix = math.random(2,10 - (4 - (2*math.floor(difficulty))))	--	2-6, 2-8, 2-10
			local mix = math.random(2,10 - (4 - (2)))	--	2-8
			sensor_jammer_scan_complexity = 1 
			sensor_jammer_scan_depth = 1
			if mix > 5 then
				sensor_jammer_scan_depth = math.min(math.random(mix-4,mix),8)
				sensor_jammer_scan_complexity = math.max(mix - sensor_jammer_scan_depth,1)
			else
				sensor_jammer_scan_depth = math.random(1,mix)
				sensor_jammer_scan_complexity = math.max(mix - sensor_jammer_scan_depth,1)
			end
			sensor_jammer_range = lo_range + (sensor_jammer_scan_depth*range_increment)
			sensor_jammer_impact = lo_impact + (sensor_jammer_scan_complexity*impact_increment)
			local sj = sensorJammer(eo_x, eo_y)
			table.insert(area.space,{obj=sj,dist=radius,shape="circle"})
			return true
		elseif terrain.desc == "Circle" then
			local mine_circle = {
				{inner_count = 4,	mid_count = 10,		outer_count = 15},	--1
				{inner_count = 9,	mid_count = 15,		outer_count = 20},	--2
				{inner_count = 15,	mid_count = 20,		outer_count = 25},	--3
			}
			--	field_size randomized earlier (1 to 3)
			local angle = random(0,360)
			local mine_x, mine_y = 0
			for i=1,mine_circle[field_size].inner_count do
				mine_x, mine_y = vectorFromAngle(angle,field_size * 1000)
				local m = Mine():setPosition(eo_x + mine_x, eo_y + mine_y)
				table.insert(area.space,{obj=m,dist=1000,shape="circle"})
				angle = (angle + (360/mine_circle[field_size].inner_count)) % 360
			end
			for i=1,mine_circle[field_size].mid_count do
				mine_x, mine_y = vectorFromAngle(angle,field_size * 1000 + 1200)
				local m = Mine():setPosition(eo_x + mine_x, eo_y + mine_y)
				table.insert(area.space,{obj=m,dist=1000,shape="circle"})
				angle = (angle + (360/mine_circle[field_size].mid_count)) % 360
			end
			if random(1,100) < 50 then
				local n_x, n_y = vectorFromAngle(random(0,360),random(50,2000))
				local neb = Nebula():setPosition(eo_x + n_x, eo_y + n_y)
				neb:setDescriptions(_("scienceDescription-nebula","Nebula"),_("scienceDescription-nebula","Nebula"))
				neb:setScanningParameters(2,1)
			end
			return true
		elseif terrain.desc == "Field" then	--asteroid field
			local asteroid_field = {}
			for n=1,math.floor(field_size/random(300,500)) do
				local asteroid_size = 0
				for s=1,4 do
					asteroid_size = asteroid_size + random(2,200)
				end
				local dist = random(100,field_size)
				local x,y = findClearSpot(asteroid_field,"bell torus",eo_x,eo_y,field_size,distort_bell,nil,asteroid_size)
				if x ~= nil then
					local ast = Asteroid():setPosition(x,y):setSize(asteroid_size)
					table.insert(area.space,{obj=ast,dist=asteroid_size,shape="circle"})
					table.insert(asteroid_field,{obj=ast,dist=asteroid_size,shape="circle"})
					local tether = random(asteroid_size + 10,800)
					local v_angle = random(0,360)
					local vx, vy = vectorFromAngle(v_angle,tether,true)
					vx = vx + x
					vy = vy + y
					local vast = VisualAsteroid():setPosition(vx,vy):setSize(random(10,tether))
					tether = random(asteroid_size + 10, asteroid_size + 800)
					v_angle = (v_angle + random(120,240)) % 360
					local vx, vy = vectorFromAngle(v_angle,tether,true)
					vx = vx + x
					vy = vy + y
					vast = VisualAsteroid():setPosition(vx,vy):setSize(random(10,tether))
				else
					break
				end
			end
			return true
		elseif terrain.desc == "Transport" then
			local ship, ship_size = randomTransportType()
			if transport_faction_list == nil or #transport_faction_list == 0 then
				transport_faction_list = {}
				for i,faction in pairs(transport_factions) do
					table.insert(transport_faction_list,faction)
				end
			end
			ship:setPosition(eo_x, eo_y):setFaction(tableRemoveRandom(transport_faction_list))
			ship:setCallSign(generateCallSign(nil,ship:getFaction()))
			table.insert(area.space,{obj=ship,dist=600,shape="circle"})
			table.insert(transport_list,ship)
			return true
		else
			local object = terrain.obj():setPosition(eo_x,eo_y)
			local dist = radius
			if terrain.desc == "Blob" or terrain.desc == "Rectangle" then
				local objects = {}
				table.insert(objects,object)
				local reached_the_edge = false
				local object_space = 1400
				if terrain.desc == "Blob" then
					local asteroid_size = 0
					if terrain.obj == Asteroid then
						asteroid_size = random(2,180) + random(2,180) + random(2,180) + random(2,180)
						object:setSize(asteroid_size)
					end
					repeat
						local overlay = false
						local new_obj_x, new_obj_y = nil
						repeat
							overlay = false
							local base_obj_index = math.random(1,#objects)
							local base_object = objects[base_obj_index]
							local base_obj_x, base_obj_y = base_object:getPosition()
							local angle = random(0,360)
							if terrain.obj == Asteroid then
								asteroid_size = random(2,180) + random(2,180) + random(2,180) + random(2,180)
								object_space = (base_object:getSize() + asteroid_size) * random(1.05,1.25)
							end
							new_obj_x, new_obj_y = vectorFromAngle(angle,object_space,true)
							new_obj_x = new_obj_x + base_obj_x
							new_obj_y = new_obj_y + base_obj_y
							for i,obj in ipairs(objects) do
								if i ~= base_obj_index then
									local compare_obj_x, compare_obj_y = obj:getPosition()
									if distance_diagnostic then
										print("distance_diagnostic 7: compare_obj_x, compare_obj_y, new_obj_x, new_obj_y: place terrain, blob:",compare_obj_x,compare_obj_y,new_obj_x,new_obj_y)
									end
									local obj_dist = distance(compare_obj_x,compare_obj_y,new_obj_x,new_obj_y)
									if obj_dist < object_space then
										overlay = true
										break
									end
								end
							end
						until(not overlay)
						object = terrain.obj():setPosition(new_obj_x, new_obj_y)
						if terrain.obj == Asteroid then
							object:setSize(asteroid_size)
						end
						table.insert(objects,object)
						if distance_diagnostic then
							print("distance_diagnostic 8: eo_x, eo_y, new_obj_x, new_obj_y: place terrain, blob:",eo_x, eo_y, new_obj_x, new_obj_y)
						end
						if distance(eo_x, eo_y, new_obj_x, new_obj_y) > radius then
							reached_the_edge = true
						end
					until(reached_the_edge)
				elseif terrain.desc == "Rectangle" then
					local long_axis = random(0,360)
					local reach_index = 0
					local new_mine_x, new_mine_y = 0
					repeat
						reach_index = reach_index + 1
						new_obj_x, new_obj_y = vectorFromAngle(long_axis,object_space * reach_index,true)
						new_obj_x = new_obj_x + eo_x
						new_obj_y = new_obj_y + eo_y
						if distance_diagnostic then
							print("distance_diagnostic 9: new_obj_x,new_obj_y,eo_x,eo_y: place terrain, rectangle:",new_obj_x,new_obj_y,eo_x,eo_y)
						end
						if distance(new_obj_x,new_obj_y,eo_x,eo_y) > radius then
							reached_the_edge = true
						else
							if random(1,100) < 77 then
								table.insert(objects,Mine():setPosition(new_obj_x, new_obj_y))
							end
							new_obj_x, new_obj_y = vectorFromAngle((long_axis + 180) % 360,object_space * reach_index,true)
							new_obj_x = new_obj_x + eo_x
							new_obj_y = new_obj_y + eo_y
							if random(1,100) < 77 then
								table.insert(objects,Mine():setPosition(new_obj_x, new_obj_y))
							end
						end
					until(reached_the_edge)
					if random(1,100) < 69 then
						reach_index = 0
						reached_the_edge = false
						local new_line_x, new_line_y = vectorFromAngle((long_axis + 90) % 360,object_space,true)
						new_line_x = new_line_x + eo_x
						new_line_y = new_line_y + eo_y
						table.insert(objects,Mine():setPosition(new_line_x, new_line_y))
						repeat
							reach_index = reach_index + 1
							new_obj_x, new_obj_y = vectorFromAngle(long_axis,object_space * reach_index,true)
							new_obj_x = new_obj_x + new_line_x
							new_obj_y = new_obj_y + new_line_y
							if distance_diagnostic then
								print("distance_diagnostic 10: new_obj_x,new_obj_y,eo_x,eo_y: place terrain, rectangle:",new_obj_x,new_obj_y,eo_x,eo_y)
							end
							if distance(new_obj_x,new_obj_y,eo_x,eo_y) > radius then
								reached_the_edge = true
							else
								if random(1,100) < 77 then
									table.insert(objects,Mine():setPosition(new_obj_x, new_obj_y))
								end
								new_obj_x, new_obj_y = vectorFromAngle((long_axis + 180) % 360,object_space * reach_index,true)
								new_obj_x = new_obj_x + new_line_x
								new_obj_y = new_obj_y + new_line_y
								if random(1,100) < 77 then
									table.insert(objects,Mine():setPosition(new_obj_x, new_obj_y))
								end
							end
						until(reached_the_edge)
						if random(1,100) < 28 then
							reach_index = 0
							reached_the_edge = false
							new_line_x, new_line_y = vectorFromAngle((long_axis + 270) % 360,object_space,true)
							new_line_x = new_line_x + eo_x
							new_line_y = new_line_y + eo_y
							table.insert(objects,Mine():setPosition(new_line_x, new_line_y))
							repeat
								reach_index = reach_index + 1
								new_obj_x, new_obj_y = vectorFromAngle(long_axis,object_space * reach_index,true)
								new_obj_x = new_obj_x + new_line_x
								new_obj_y = new_obj_y + new_line_y
								if distance_diagnostic then
									print("distance_diagnostic 11: new_obj_x,new_obj_y,eo_x,eo_y: place terrain, rectangle:",new_obj_x,new_obj_y,eo_x,eo_y)
								end
								if distance(new_obj_x,new_obj_y,eo_x,eo_y) > radius then
									reached_the_edge = true
								else
									if random(1,100) < 77 then
										table.insert(objects,Mine():setPosition(new_obj_x, new_obj_y))
									end
									new_obj_x, new_obj_y = vectorFromAngle((long_axis + 180) % 360,object_space * reach_index,true)
									new_obj_x = new_obj_x + new_line_x
									new_obj_y = new_obj_y + new_line_y
									if random(1,100) < 77 then
										table.insert(objects,Mine():setPosition(new_obj_x, new_obj_y))
									end
								end
							until(reached_the_edge)
						end
					end
				end
				for i,object in ipairs(objects) do
					dist = object_space
					if isObjectType(object,"Asteroid") then
						dist = object:getSize()
						local tether_x, tether_y = object:getPosition()
						local tether_length = random(dist + 10, 800)
						local vis_ast_angle = random(0,360)
						local vx, vy = vectorFromAngle(vis_ast_angle,tether_length,true)
						vx = vx + tether_x
						vy = vy + tether_y
						VisualAsteroid():setPosition(vx,vy):setSize(random(10,tether_length))
						tether_length = random(dist + 10, dist + 800)
						vis_ast_angle = (vis_ast_angle + random(120,240)) % 360
						vx, vy = vectorFromAngle(vis_ast_angle,tether_length,true)
						vx = vx + tether_x
						vy = vy + tether_y
						VisualAsteroid():setPosition(vx,vy):setSize(random(10,tether_length))
					end
					table.insert(area.space,{obj=object,dist=dist,shape="circle"})
				end
				return true
			else	--not blob or rectangle
				if terrain.desc == "Star" then
					object:setPlanetRadius(radius):setDistanceFromMovementPlane(-radius*.5)
					if random(1,100) < 43 then
						object:setDistanceFromMovementPlane(radius*.5)
					end
					local star_item = tableRemoveRandom(star_list[1].info)
					object:setCallSign(star_item.name)
					if star_item.unscanned ~= nil then
						object:setDescriptions(star_item.unscanned,star_item.scanned)
						object:setScanningParameters(1,2)
					end
					object:setPlanetAtmosphereTexture(star_list[1].texture.atmosphere):setPlanetAtmosphereColor(random(0.5,1),random(0.5,1),random(0.5,1))
					dist = radius + 1000
				elseif terrain.obj == SupplyDrop then
					local supply_types = {"energy", "ordnance", "coolant", "repair crew", "probes", "hull", "jump charge"}
					local supply_type = tableSelectRandom(supply_types)
					object:setScanningParameters(math.random(1,2),math.random(1,2)):setFaction(player_faction)
					if supply_type == "energy" then
						local energy_boost = random(300,800)
						object:setEnergy(energy_boost)
						object:setDescriptions(_("scienceDescription-supplyDrop","Supply Drop"),string.format(_("scienceDescription-supplyDrop","%i energy boost supply drop."),math.floor(energy_boost)))
					elseif supply_type == "ordnance" then
						local restock_ranges = {
							["Homing"] =	{lo = 4, hi = 12},
							["Nuke"] = 		{lo = 1, hi = 5},
							["Mine"] =		{lo = 3, hi = 8},
							["EMP"] =		{lo = 2, hi = 8},
							["HVLI"] =		{lo = 8, hi = 20},
						}
						local ordnance_type = tableSelectRandom(ordnance_types)
						local restock_amount = math.random(restock_ranges[ordnance_type].lo,restock_ranges[ordnance_type].hi)
						object:setWeaponStorage(ordnance_type,restock_amount)
						object:setDescriptions(_("scienceDescription-supplyDrop","Supply Drop"),string.format(_("scienceDescription-supplyDrop","%i %s supply drop."),restock_amount,ordnance_type))
					else
						object:onPickUp(supplyPickupProcess)
						if supply_type == "coolant" then
							object.coolant = random(1,5)
							object:setDescriptions(_("scienceDescription-supplyDrop","Supply Drop"),string.format(_("scienceDescription-supplyDrop","%.1f%% coolant supply drop."),object.coolant*10))
						elseif supply_type == "repair crew" then
							object.repairCrew = 1
							object:setDescriptions(_("scienceDescription-supplyDrop","Supply Drop"),_("scienceDescription-supplyDrop","Robotic repair crew supply drop."))
						elseif supply_type == "probes" then
							object.probes = math.random(4,12)
							object:setDescriptions(_("scienceDescription-supplyDrop","Supply Drop"),string.format(_("scienceDescription-supplyDrop","%i probes supply drop."),object.probes))
						elseif supply_type == "hull" then
							object.armor = random(20,80)
							object:setDescriptions(_("scienceDescription-supplyDrop","Supply Drop"),string.format(_("scienceDescription-supplyDrop","%.1f hull repair points supply drop."),object.armor))
						elseif supply_type == "jump charge" then
							object.jump_charge = random(20000,40000)
							object:setDescriptions(_("scienceDescription-supplyDrop","Supply Drop"),string.format(_("scienceDescription-supplyDrop","%.1fK jump drive charge supply drop."),object.jump_charge/1000))
						end
					end
				elseif terrain.obj == ScanProbe then
					local station_pool = getStationPool(placement_area)
					local owner = tableSelectRandom(station_pool)
					local s_x, s_y = owner:getPosition()
					object:setLifetime(20*60):setOwner(owner):setTarget(eo_x,eo_y):setPosition(s_x,s_y)
					object:onExpiration(probeExpired)
					object:onDestruction(probeDestroyed)
					object = VisualAsteroid():setPosition(eo_x,eo_y)
				elseif terrain.obj == WarpJammer then
					local closest_station_distance = 999999
					local closest_station = nil
					local station_pool = getStationPool(placement_area)
					for i, station in ipairs(station_pool) do
						if distance_diagnostic then
							print("distance_diagnostic 12: station, eo_x, eo_y, place terrain, warp jammer:",station:getCallSign(), eo_x, eo_y)
						end
						local current_distance = distance(station, eo_x, eo_y)
						if current_distance < closest_station_distance then
							closest_station_distance = current_distance
							closest_station = station
						end
					end
					local selected_faction = closest_station:getFaction()
					local warp_jammer_range = 0
					for i=1,5 do
						warp_jammer_range = warp_jammer_range + random(1000,4000)
					end
					object:setRange(warp_jammer_range):setFaction(selected_faction)
					warp_jammer_info[selected_faction].count = warp_jammer_info[selected_faction].count + 1
					local wj_id = string.format("%sWJ%i",warp_jammer_info[selected_faction].id,warp_jammer_info[selected_faction].count)
					object.identifier = wj_id
					object.range = warp_jammer_range
					object:setDescriptions(_("scienceDescription-warpJammer","Warp jammer"),string.format(_("scienceDescription-warpJammer","Warp jammer. Operated by %s. Placed by station %s. Identifier: %s"),selected_faction,closest_station:getCallSign(),wj_id))
					object:setScanningParameters(1,1)
					table.insert(warp_jammer_list,object)
				elseif terrain.desc == "Sensor" then
					object:setScanningParameters(math.random(1,2),math.random(1,2)):setRadarSignatureInfo(random(0,1),random(0,1),random(0,1)):setModel("SensorBuoyMKIII")
					local buoy_type_list = {}
					local buoy_type = ""
					local station_pool = getStationPool(placement_area)
					local out = ""
					if #station_pool > 0 then
						table.insert(buoy_type_list,"station")
					end
					if transport_list ~= nil and #transport_list > 0 then
						table.insert(buoy_type_list,"transport")
					end
					if #buoy_type_list > 0 then
						buoy_type = tableSelectRandom(buoy_type_list)
						if buoy_type == "station" then
							local selected_stations = {}
							for i, station in ipairs(station_pool) do
								table.insert(selected_stations,station)
							end
							for i=1,3 do
								if #selected_stations > 0 then
									local station = tableRemoveRandom(selected_stations)
									if out == "" then
										out = string.format(_("scienceDescription-buoy","Sensor Record: %s station %s in %s"),station:getFaction(),station:getCallSign(),station:getSectorName())
									else
										out = string.format(_("scienceDescription-buoy","%s, %s station %s in %s"),out,station:getFaction(),station:getCallSign(),station:getSectorName())
									end
								else
									break
								end
							end
						end
						if buoy_type == "transport" then
							local selected_transports = {}
							for i, transport in ipairs(transport_list) do
								table.insert(selected_transports,transport)
							end
							for i=1,3 do
								if #selected_transports > 0 then
									local transport = tableRemoveRandom(selected_transports)
									if transport.comms_data == nil then
										transport.comms_data = {friendlyness = random(0.0, 100.0)}
									end
									if transport.comms_data.goods == nil then
										goodsOnShip(transport,transport.comms_data)
									end
									local goods_carrying = ""
									for good, goodData in pairs(transport.comms_data.goods) do
										if goods_carrying == "" then
											goods_carrying = good
										else
											goods_carrying = string.format("%s, %s",goods_carrying,good)
										end
									end
									if out == "" then
										out = string.format(_("scienceDescription-buoy","Sensor Record: %s %s %s in %s carrying %s"),transport:getFaction(),transport:getTypeName(),transport:getCallSign(),transport:getSectorName(),goods_carrying)
									else
										out = string.format(_("scienceDescription-buoy","%s; %s %s %s in %s carrying %s"),out,transport:getFaction(),transport:getTypeName(),transport:getCallSign(),transport:getSectorName(),goods_carrying)
									end
								else
									break
								end
							end
						end
					else
						out = _("scienceDescription-buoy","No data recorded")
					end
					object:setDescriptions(_("scienceDescription-buoy","Automated data gathering device"),out)
				elseif terrain.desc == "Ad" then
					object:setScanningParameters(2,1):setRadarSignatureInfo(random(0,1),random(0,1),random(0,1)):setModel("SensorBuoyMKIII")
					if billboards == nil then
						billboards = {}
					end
					if #billboards < 1 then
						for i,ad in ipairs(advertising_billboards) do
							table.insert(billboards,ad)
						end
					end
					object:setDescriptions(_("scienceDescription-buoy","Automated data gathering device"),tableRemoveRandom(billboards))
				elseif terrain.obj == Nebula then
					dist = 1500
					if random(1,100) < 77 then
						local n_angle = random(0,360)
						local n_x, n_y = vectorFromAngle(n_angle,random(5000,10000))
						local neb = Nebula():setPosition(eo_x + n_x, eo_y + n_y)
						neb:setDescriptions(_("scienceDescription-nebula","Nebula"),_("scienceDescription-nebula","Nebula"))
						neb:setScanningParameters(2,1)
						if random(1,100) < 37 then
							local n2_angle = (n_angle + random(120,240)) % 360
							n_x, n_y = vectorFromAngle(n2_angle,random(5000,10000))
							eo_x = eo_x + n_x
							eo_y = eo_y + n_y
							neb = Nebula():setPosition(eo_x, eo_y)
							neb:setDescriptions(_("scienceDescription-nebula","Nebula"),_("scienceDescription-nebula","Nebula"))
							neb:setScanningParameters(2,1)
							if random(1,100) < 22 then
								local n3_angle = (n2_angle + random(120,240)) % 360
								n_x, n_y = vectorFromAngle(n3_angle,random(5000,10000))
								neb = Nebula():setPosition(eo_x + n_x, eo_y + n_y)
								neb:setDescriptions(_("scienceDescription-nebula","Nebula"),_("scienceDescription-nebula","Nebula"))
								neb:setScanningParameters(2,1)
							end
						end
					end
				elseif terrain.obj == BlackHole or terrain.obj == Mine then
					--black hole, mine; no more action needed
				else	--default to asteroid
					placeAsteroid(placement_area)
					return false
				end
				table.insert(area.space,{obj=object,dist=dist,shape="circle"})
				return true
			end
		end
	else
		placeAsteroid(placement_area)
		return false
	end
end
function supplyPickupProcess(self, player)
	if self.repairCrew ~= nil then
		player:setRepairCrewCount(player:getRepairCrewCount() + self.repairCrew)
	end
	if self.coolant ~= nil then
		player:setMaxCoolant(player:getMaxCoolant() + self.coolant)
	end
	if self.probes ~= nil then
		player:setScanProbeCount(math.min(player:getScanProbeCount() + self.probes,player:getMaxScanProbeCount()))
	end
	if self.armor ~= nil then
		player:setHull(math.min(player:getHull() + self.armor,player:getHullMax()))
	end
	if player:hasJumpDrive() then
		if self.jump_charge ~= nil then
			player:setJumpDriveCharge(player:getJumpDriveCharge() + self.jump_charge)
		end
	end
end
function szt(larger)
--Randomly choose station size template
	local distribution = {
		["Default"] = {			--provide any of the template sizes
			{thresh = 8,	size = "Huge Station"},		--	8% huge
			{thresh = 24,	size = "Large Station"},	--	16% large
			{thresh = 50,	size = "Medium Station"},	--	26% medium
			{thresh = 100,	size = "Small Station"},	--	50% small
		},
		["Small Station"] = {	--provide something larger than small
			{thresh = 10,	size = "Huge Station"},		--	10% huge
			{thresh = 30,	size = "Large Station"},	--	20% large
			{thresh = 100,	size = "Medium Station"},	--	70% medium
		},
		["Medium Station"] = {	--provide something larger than medium
			{thresh = 25,	size = "Huge Station"},		--	25% huge
			{thresh = 100,	size = "Large Station"},	--	75% large
		},
	}
	if larger == nil then
		larger = "Default"
	end
	local selected_distribution = distribution[larger]
	if selected_distribution == nil then
		selected_distribution = distribution["Default"]
	end
	local stationSizeRandom = random(1,100)
	sizeTemplate = "Small Station"
	for i,d in ipairs(selected_distribution) do
		if stationSizeRandom <= d.thresh then
			sizeTemplate = d.size
			break
		end
	end
	return sizeTemplate
end
--	Sensor jammer functions
function sensorJammerPickupProcess(self,retriever)
	string.format("")
	local jammer_call_sign = self:getCallSign()
	sensor_jammer_list[jammer_call_sign] = nil
	if not self:isScannedBy(retriever) then
		retriever:setCanScan(false)
		retriever.scanner_dead = "scanner_dead"
		retriever:addCustomMessage("Science",retriever.scanner_dead,_("msgScience","The unscanned artifact we just picked up has fried our scanners"))
		retriever.scanner_dead_ops = "scanner_dead_ops"
		retriever:addCustomMessage("Operations",retriever.scanner_dead_ops,_("msgOperations","The unscanned artifact we just picked up has fried our scanners"))
	end
	may_explain_sensor_jammer = true
end
function sensorJammer(x,y)
	artifact_number = artifact_number + math.random(1,4)
	local random_suffix = string.char(math.random(65,90))
	local jammer_call_sign = string.format("SJ%i%s",artifact_number,random_suffix)
	local scanned_description = string.format(_("scienceDescription-artifact","Source of emanations interfering with long range sensors. Range:%.1fu Impact:%.1fu"),sensor_jammer_range/1000,sensor_jammer_impact/1000)
	local sensor_jammer = Artifact():setPosition(x,y):setScanningParameters(sensor_jammer_scan_complexity,sensor_jammer_scan_depth):setRadarSignatureInfo(.2,.4,.1):setModel("SensorBuoyMKIII"):setDescriptions(_("scienceDescription-artifact","Source of unusual emanations"),scanned_description):setCallSign(jammer_call_sign)
	sensor_jammer:onPickUp(sensorJammerPickupProcess)
	sensor_jammer_list[jammer_call_sign] = sensor_jammer
	sensor_jammer.jam_range = sensor_jammer_range
	sensor_jammer.jam_impact = sensor_jammer_impact
	sensor_jammer.jam_impact_units = sensor_jammer_power_units
	return sensor_jammer
end
function updatePlayerLongRangeSensors(delta,p)
	local free_sensor_boost = false
	local sensor_boost_present = false
	local sensor_boost_amount = 0
	if p.station_sensor_boost == nil then
		local station_pool = {}
		for i,station in ipairs(inner_stations) do
			if station ~= nil and station:isValid() then
				table.insert(station_pool,station)
			end
		end
		for i,sensor_station in ipairs(station_pool) do
			if sensor_station:isValid() and p:isDocked(sensor_station) then
				if sensor_station.comms_data.sensor_boost ~= nil then
					sensor_boost_present = true
					if sensor_station.comms_data.sensor_boost.cost < 1 then
						free_sensor_boost = true
						p.station_sensor_boost = sensor_station.comms_data.sensor_boost.value
						break
					end
					sensor_boost_amount = sensor_station.comms_data.sensor_boost.value
				end
			end
		end
	end
	local base_range = p.normal_long_range_radar
	if p.station_sensor_boost ~= nil then
		base_range = base_range + p.station_sensor_boost
	end
	if p:getDockedWith() == nil then
		base_range = p.normal_long_range_radar
		p.station_sensor_boost = nil
	end
	if p.power_sensor_interval ~= nil and p.power_sensor_interval > 0 and p:getEnergyLevel() > p:getEnergyLevelMax()*.05 then
		if p.power_sensor_state == nil then
			p.power_sensor_state = "disabled"
		end
		if p.power_sensor_state == "disabled" then
			p.power_sensor_state = "standby"
			updatePowerSensorButtons(p)
		elseif p.power_sensor_state == "enabled" then
			base_range = base_range + (1000 * p.power_sensor_interval * p.power_sensor_level)
			local power_decrement = delta*p.power_sensor_level*2
			p:setEnergyLevel(p:getEnergyLevel() - power_decrement)
		end
	else
		if p.power_sensor_state ~= nil then
			p.power_sensor_state = "disabled"
			updatePowerSensorButtons(p)
		end
	end
	local impact_range = math.max(base_range*sensor_impact,p:getShortRangeRadarRange())
	local sensor_jammer_impact = 0
	for jammer_name, sensor_jammer in pairs(sensor_jammer_list) do
		if sensor_jammer ~= nil and sensor_jammer:isValid() then
			local jammer_distance = distance(p,sensor_jammer)
			if jammer_distance < sensor_jammer.jam_range then
				if sensor_jammer.jam_impact_units then
					sensor_jammer_impact = math.max(sensor_jammer_impact,sensor_jammer.jam_impact*(1-(jammer_distance/sensor_jammer.jam_range)))
				else
					sensor_jammer_impact = math.max(sensor_jammer_impact,impact_range*sensor_jammer.jam_impact/100000*(1-(jammer_distance/sensor_jammer.jam_range)))
				end
			end
		else
			sensor_jammer_list[jammer_name] = nil
		end
	end
	impact_range = math.max(p:getShortRangeRadarRange(),impact_range - sensor_jammer_impact)
	local probe_scan_boost_impact = 0
	if boost_probe_list ~= nil then
		for boost_probe_index, boost_probe in ipairs(boost_probe_list) do
			if boost_probe ~= nil and boost_probe:isValid() then
				local boost_probe_distance = distance(boost_probe,p)
				if boost_probe_distance < boost_probe.range*1000 then
					if boost_probe_distance < boost_probe.range*1000/2 then
						probe_scan_boost_impact = math.max(probe_scan_boost_impact,boost_probe.boost*1000)
					else
						local best_boost = boost_probe.boost*1000
						local adjusted_range = boost_probe.range*1000
						local half_adjusted_range = adjusted_range/2
						local raw_scan_gradient = boost_probe_distance/half_adjusted_range
						local scan_gradient = 2 - raw_scan_gradient
						probe_scan_boost_impact = math.max(probe_scan_boost_impact,best_boost * scan_gradient)
					end
				end
			else
				boost_probe_list[boost_probe_index] = boost_probe_list[#boost_probe_list]
				boost_probe_list[#boost_probe_list] = nil
				break
			end
		end
	end
	impact_range = math.max(p:getShortRangeRadarRange(),impact_range + probe_scan_boost_impact)
	p:setLongRangeRadarRange(impact_range)
end
--	Players
function playerStrikerDestroyed(self,instigator)
	if player_strikers_destroyed == nil then
		player_strikers_destroyed = {}
	end
	if self.player_escorts ~= nil and #self.player_escorts > 0 then
		for i,ship in ipairs(self.player_escorts) do
			if ship ~= nil and ship:isValid() then
				ship:orderDefendTarget(home_station)
			end
		end
	end
	table.insert(player_strikers_destroyed,self:getCallSign())
end
function playerFlaviaDestroyed(self,instigator)
	if player_flavias_destroyed == nil then
		player_flavias_destroyed = {}
	end
	if self.player_escorts ~= nil and #self.player_escorts > 0 then
		for i,ship in ipairs(self.player_escorts) do
			if ship ~= nil and ship:isValid() then
				ship:orderDefendTarget(home_station)
			end
		end
	end
	table.insert(player_flavias_destroyed,self:getCallSign())
end
function playerPhobosDestroyed(self,instigator)
	if player_phobos_destroyed == nil then
		player_phobos_destroyed = {}
	end
	if self.player_escorts ~= nil and #self.player_escorts > 0 then
		for i,ship in ipairs(self.player_escorts) do
			if ship ~= nil and ship:isValid() then
				ship:orderDefendTarget(home_station)
			end
		end
	end
	table.insert(player_phobos_destroyed,self:getCallSign())
end
function playerAtlantisDestroyed(self,instigator)
	if player_atlantis_destroyed == nil then
		player_atlantis_destroyed = {}
	end
	table.insert(player_atlantis_destroyed,self:getCallSign())
end
--	Missions
function startInitialMission()
	local target_station_x, target_station_y = target_station:getPosition()
	local fleet = spawnRandomArmed(target_station_x,target_station_y)
	target_station.defense_fleet = {}
	for i,ship in ipairs(fleet) do
		ship:orderDefendTarget(target_station)
		table.insert(target_station.defense_fleet,ship)
	end
	for i,p in ipairs(getActivePlayerShips()) do
		p:addToShipLog(string.format(_("goal-shipLog","You have been recalled from your recent battle with Kraylor at the perimeter. Their action consisted of two battle groups. Your patrol group destroyed the first Kraylor group. The second Kraylor group destroyed our other perimeter patrol. They threaten station %s in sector %s."),home_station:getCallSign(),home_station:getSectorName()),"Magenta")
		p:addToShipLog(string.format(_("goal-shipLog","Defend your home station, %s from the rapidly approaching Kraylor."),home_station:getCallSign()),"Magenta")
	end
	missionMaintenance = defendHomeStationFromFighters
end
function defendHomeStationFromFighters()
	if enemy_fighter_fleet ~= nil and #enemy_fighter_fleet > 0 then
		for i,ship in ipairs(enemy_fighter_fleet) do
			if not ship:isValid() then
				enemy_fighter_fleet[i] = enemy_fighter_fleet[#enemy_fighter_fleet]
				enemy_fighter_fleet[#enemy_fighter_fleet] = nil
				break
			end
		end
	else
		for i,p in ipairs(getActivePlayerShips()) do
			p:addToShipLog(string.format(_("goal-shipLog","Kraylor fighter fleet destroyed. Dock with %s"),home_station:getCallSign()),"Magenta")
		end
		missionMaintenance = dockAfterFightersDestroyed
		primary_orders = string.format(_("orders-comms","Dock with station %s"),home_station:getCallSign())
	end
end
function dockAfterFightersDestroyed()
	local all_docked = true
	for i,p in ipairs(getActivePlayerShips()) do
		local docked_station = p:getDockedWith()
		if docked_station ~= nil and docked_station == home_station then
			if p.get_resource_message == nil then
				p.get_resource_message = "sent"
				goods_retrieval_message = string.format(_("goal-shipLog","Since the Kraylor have increased their attacks, we'd like to install defense platforms around station %s. We have most of what we need, but we're missing some components and/or materials. There are some Independent stations around here that have what we need or have what we can adapt to get those platforms built. You need to get those goods. The Kraylor will try to stop you."),home_station:getCallSign())
				p:addToShipLog(goods_retrieval_message,"Magenta")
			end
		end
		if docked_station == nil or docked_station ~= home_station then
			all_docked = false
			break
		end
	end
	primary_orders = _("orders-comms","Transfer to Flavia P. Falcon to gather resources")
	if all_docked then
		local out = ""
		if player_strikers_destroyed ~= nil then
			local ships = ""
			for i,name in ipairs(player_strikers_destroyed) do
				if ships == "" then
					ships = name
				else
					ships = string.format("%s, %s",ships,name)
				end
			end
			out = string.format(_("goal-shipLog","Inform crew of %s that they will be placed on a Flavia P. Falcon shortly."),ships)
			if #player_strikers_destroyed > 1 then
				out = string.format(_("goal-shipLog","Inform crews of %s that they will be placed on a Flavia P. Falcon shortly."),ships)
			end
		end
		for i,p in ipairs(getActivePlayerShips()) do
			p:addReputationPoints(25)
			p:setCanDock(false)
			p:addToShipLog(_("goal-shipLog","Stand by for transfer to Flavia P. Falcon"),"Magenta")
			if out ~= "" then
				p:addToShipLog(out,"Magenta")
			end
		end
		missionMaintenance = transferToFlavia
	end
end
function transferToFlavia()
	if flavia_time == nil then
		striker_retire_time = getScenarioTime() + (transfer_interval * 3)
		flavia_time = getScenarioTime() + (transfer_interval * 2)
		flavia_delivery_time = getScenarioTime() + transfer_interval
		active_player_fighters = {}
		for i,p in ipairs(getActivePlayerShips()) do
			p:setCanBeDestroyed(false)
			table.insert(active_player_fighters,p)
		end
	end
	if getScenarioTime() > striker_retire_time then
		for i,p in ipairs(getActivePlayerShips()) do
			if p:getTypeName() == "Striker" then
				for i,pa in ipairs(getActivePlayerShips()) do
					pa:addToShipLog(string.format(_("goal-shipLog","%s has withdrawn to the shipyard at %s for maintenance."),p:getCallSign(),home_station:getCallSign()),"Magenta")
				end
				if p.player_escorts ~= nil and #p.player_escorts > 0 then
					for j,ship in ipairs(p.player_escorts) do
						if ship:isValid() then
							ship:orderDefendTarget(home_station)
						end
					end
				end
				p:destroy()
			end
		end
		missionMaintenance = flaviaGoods
	end
	if getScenarioTime() > flavia_delivery_time then
		if flavia_delivered == nil then
			local jda = random(0,360)
			local jd_x, jd_y = vectorFromAngle(jda,3000)
			jd_x = jd_x + home_station_x
			jd_y = jd_y + home_station_y
			jump_delivery = CpuShip():setTemplate("Jump Carrier"):setFaction("Human Navy")
			jump_delivery:setPosition(jd_x,jd_y):setScannedByFaction("Human Navy",true)
			jump_delivery:setCallSign(generateCallSign(nil,"Human Navy"))
			local temp_type_name = "Flavia P.Falcon"
			local flavia_angle = random(0,360)
			for i=1,player_ship_count do
				local p = PlayerSpaceship()
				p:setTemplate(temp_type_name)
				p:setFaction("Human Navy")
				flavia_angle = (flavia_angle + (360 / player_ship_count)) % 360
				local px, py = vectorFromAngle(flavia_angle, 300, true)
				px = px + jd_x
				py = py + jd_y
				p:setPosition(px, py)
				p:setHeading(flavia_angle)
				p:commandTargetRotation((flavia_angle + 270) % 360)
				p:commandDock(jump_delivery)
				p:setScannedByFaction("Human Navy",true)
				p.normal_long_range_radar = player_ship_stats[temp_type_name].long_range_radar
				local player_ship_name_list = player_ship_names_for[temp_type_name]
				local player_ship_name = nil
				if player_ship_name_list ~= nil then
					player_ship_name = tableRemoveRandom(player_ship_name_list)
				end
				if player_ship_name == nil then
					player_ship_name = tableSelectRandom(player_ship_names_for["Leftovers"])
				end
				if player_ship_name ~= nil then
					p:setCallSign(player_ship_name)
				end
				p:onDestruction(playerFlaviaDestroyed)
			end
			for i,p in ipairs(getActivePlayerShips()) do
				p:addToShipLog(string.format(_("goal-shipLog","Delivery ship, %s has arrived."),jump_delivery:getCallSign()),"Magenta")
			end
			flavia_delivered = true
		end
	end
	if getScenarioTime() > flavia_time then
		if flavia_board == nil then
			for i,p in ipairs(active_player_fighters) do
				for j,pf in ipairs(getActivePlayerShips()) do
					if pf:getTypeName() == "Flavia P.Falcon" and pf.transfer_from == nil then
						p:transferPlayersToShip(pf)
						pf.transfer_from = p:getCallSign()
						for k,pm in ipairs(getActivePlayerShips()) do
							pm:addToShipLog(string.format(_("goal-shipLog","Crew from %s transferred to %s."),p:getCallSign(),pf:getCallSign()),"Magenta")
						end
						local consoles = {"Helms","Weapons","Engineering","Science","Relay","Tactical","Operations","Engineering+","Single","DamageControl","PowerManagement","Database","AltRelay","CommsOnly","ShipLog"}
						for j,console in ipairs(consoles) do
							local msg = string.format(_("goal-shipLog","You have been transferred from your previous ship %s to your new ship %s."),p:getCallSign(),pf:getCallSign())
							if console == "Engineering" or console == "Engineering+" or console == "DamageControl" then
								msg = string.format(_("goal-shipLog","%s\nIf you don't see any repair crew, you will need to manually exit the ship and re-enter in order to have them show up."),msg)
							end
							pf:addCustomMessage(console,string.format("transfer%s",console),msg)
						end
						break
					end
				end
			end
			if player_strikers_destroyed ~= nil and #player_strikers_destroyed > 0 then
				local global_board_message = _("msgMainscreen","Crew Reassignment:")
				local banner_message = ""
				for i,name in ipairs(player_strikers_destroyed) do
					for j,pf in ipairs(getActivePlayerShips()) do
						if pf:getTypeName() == "Flavia P.Falcon" and pf.transfer_from == nil then
							pf.transfer_from = name
							local board_message = string.format(_("goal-shipLog","Crew from %s should board %s."),name,pf:getCallSign())
							for k,pm in ipairs(getActivePlayerShips()) do
								pm:addToShipLog(board_message,"Magenta")
							end
							banner_message = string.format("%s %s",banner_message,board_message)
							global_board_message = string.format("%s\n%s",global_board_message,board_message)
							break
						end
					end
				end
				addGMMessage(global_board_message)
				globalMessage(global_board_message,10)
				setBanner(banner_message)
			end
			flavia_board = "complete"
		end
	end
end
function flaviaGoods()
	if flavia_mission == nil then
		mission_goods = {}
		for i,station in ipairs(inner_stations) do
			if station:isValid() and station:getFaction() == "Independent" then
				local s_x, s_y = station:getPosition()
				local fleet = spawnRandomArmed(s_x, s_y)
				for i,ship in ipairs(fleet) do
					ship:orderDefendTarget(station)
				end
				if station.comms_data ~= nil then
					if station.comms_data.goods ~= nil then
						local added_to_mission_goods = false
						for good,details in pairs(station.comms_data.goods) do
							if good ~= "food" and good ~= "medicine" and good ~= "luxury" then
								local already_mission_good = false
								for j,mission_good in ipairs(mission_goods) do
									if good == mission_good.good then
										already_mission_good = true
									end
								end
								if not already_mission_good and details.quantity > 0 then
									table.insert(mission_goods,{station=station,good=good})
									added_to_mission_goods = true
									break
								end
							end
						end
						if not added_to_mission_goods then
							for i,mineral in ipairs(mineralGoods) do
								local already_in_station = false
								for good,details in pairs(station.comms_data.goods) do
									if good == mineral then
										already_in_station = true
										break
									end
								end
								if not already_in_station then
									local already_in_mission = false
									for j,mission_good in ipairs(mission_goods) do
										if mineral == mission_good.good then
											already_in_mission = true
											break
										end
									end
									if not already_in_mission then
										station.comms_data.goods[mineral] = {quantity = 5, cost = math.random(55,95)}
										table.insert(mission_goods,{station=station,good=mineral})
										added_to_mission_goods = true
										break
									end
								end
								if added_to_mission_goods then
									break
								end
							end
						end
					end
				end
			end
		end
		flavia_mission = true
	end
	if #mission_goods > 0 then
		if mission_good_message == nil then
			mission_good_message = "sent"
			local station_lines = ""
			for i,mission_good in ipairs(mission_goods) do
				local station_line = string.format(_("goal-shipLog","%s at station %s in sector %s"),mission_good.good,mission_good.station:getCallSign(),mission_good.station:getSectorName())
				if station_lines == "" then
					station_lines = station_line
				else
					station_lines = string.format("%s\n%s",station_lines,station_line)
				end
			end
			for i,p in ipairs(getActivePlayerShips()) do
				p:addToShipLog(string.format(_("goal-shipLog","You and your crew have been transferred from the patrol fighter (Striker class) ship to the %s, a Flavia Falcon class ship. It's an armed freighter with a warp drive. The Kraylor have placed 'defensive' ships around the stations where you need to pick up cargo. Your armed freighter's weapons point rearwards to defend against pirates trying to steal cargo. You may need to use these armaments offensively to drive away the Kraylor."),p:getCallSign()),"Magenta")
				p:addToShipLog(goods_retrieval_message,"Magenta")
				p:addToShipLog(string.format(_("goal-shipLog","Retrieve the following goods at the following stations:\n%s\nReturn them to station %s."),station_lines,home_station:getCallSign()),"Magenta")
				if #getActivePlayerShips() > 1 then
					p:addToShipLog(_("goal-shipLog","You may want to go together to pick up goods since the Kraylor will try to prevent you from getting the goods. Fighting as a group is usually more effective than fighting individually. Be careful not to shoot each other with your missile weapons."),"Magenta")
				end
			end
			primary_orders = _("goal-shipLog","Gather goods:")
			for i,mission_good in ipairs(mission_goods) do
				if difficulty > 1 then
					primary_orders = string.format("%s %s",primary_orders,mission_good.good)
				else
					if primary_orders == _("goal-shipLog","Gather goods:") then
						primary_orders = string.format(_("goal-shipLog","%s %s at %s"),primary_orders,mission_good.good,mission_good.station:getCallSign())
					else
						primary_orders = string.format(_("goal-shipLog","%s, %s at %s"),primary_orders,mission_good.good,mission_good.station:getCallSign())
					end
				end
			end
			primary_orders = string.format(_("goal-shipLog","%s. Bring them to %s."),primary_orders,home_station:getCallSign())
		end
		if difficulty < 1 then
			for i,p in ipairs(getActivePlayerShips()) do
				if p.player_escorts == nil then
					p.player_escorts = {}
					local home_station_x, home_station_y = home_station:getPosition()
					local ship = CpuShip():setTemplate("Elara P2"):setFaction("Human Navy")
					ship:setPosition(home_station_x, home_station_y):orderDefendTarget(p)
					ship:setCommsFunction(commsShip):setScannedByFaction("Human Navy",true)
					table.insert(p.player_escorts,ship)
				end
			end
		end
		local delivered_count = 0
		for i,mission_good in ipairs(mission_goods) do
			if mission_good.delivered then
				delivered_count = delivered_count + 1
			end
		end
		if delivered_count >= #mission_goods then
			missionMaintenance = flaviaGoodsDelivered
		end
	else
		print("failed to set up mission goods list")
	end
	if jump_delivery:isValid() then
		local function deliveryShipDeparture()
			if jump_delivery:isValid() then
				jump_delivery_name = jump_delivery:getCallSign()
				for i,p in ipairs(getActivePlayerShips()) do
					if p:getDockedWith() == jump_delivery then
						p:commandUndock()
					end
					p:addToShipLog(string.format(_("goal-shipLog","%s has returned to the primary Human Navy shipyard to prepare to make other ship deliveries."),jump_delivery_name),"Magenta")
				end
				jump_delivery:destroy()
			end
		end
		if flavia_delivery_departure_time == nil then
			local all_undocked = true
			for i,p in ipairs(getActivePlayerShips()) do
				local docked_entity = p:getDockedWith()
				if docked_entity ~= nil and docked_entity == jump_delivery then
					all_undocked = false
					break
				end
			end
			if all_undocked then
				flavia_delivery_departure_time = getScenarioTime() + 10
			end
			if wait_for_players_to_undock_time == nil then
				wait_for_players_to_undock_time = getScenarioTime() + 60
			end
			if getScenarioTime() > wait_for_players_to_undock_time then
				deliveryShipDeparture()
			end
		else
			if getScenarioTime() > flavia_delivery_departure_time then
				deliveryShipDeparture()
			end
		end
	end
end
function flaviaGoodsDelivered()
	if post_goods_retrieval_message == nil then
		post_goods_retrieval_message = "sent"
		for i,p in ipairs(getActivePlayerShips()) do
			p:addToShipLog(string.format(_("goal-shipLog","The resources to build defense platforms has been obtained. We will start construction immediately. We detect more Kraylor coming. We have requisitioned Phobos class ships for you to use to defend station %s. The Flavia P. Falcon is not designed for station defense. Dock to facilitate transfer."),home_station:getCallSign()),"Magenta")
		end
	end
	local all_docked = true
	for i,p in ipairs(getActivePlayerShips()) do
		local docked_station = p:getDockedWith()
		if docked_station ~= nil and docked_station == home_station then
			if p.defend_station_message == nil then
				p.defend_station_message = "sent"
				p:addToShipLog(string.format(_("goal-shipLog","Defend %s from imminent Kraylor attack."),home_station:getCallSign()),"Magenta")
			end
		end
		if docked_station == nil or docked_station ~= home_station then
			all_docked = false
			break
		end
	end
	primary_orders = _("goal-shipLog","Dock, then transfer to Phobos to defend station")
	if all_docked then
		local out = ""
		if player_flavias_destroyed ~= nil then
			local ships = ""
			for i,name in ipairs(player_flavias_destroyed) do
				if ships == "" then
					ships = name
				else
					ships = string.format("%s, %s",ships,name)
				end
			end
			out = string.format(_("goal-shipLog","Inform crew of %s that they will be placed on a Phobos M3P shortly."),ships)
			if #player_flavias_destroyed > 1 then
				out = string.format(_("goal-shipLog","Inform crews of %s that they will be placed on a Phobos M3P shortly."),ships)
			end
		end
		for i,p in ipairs(getActivePlayerShips()) do
			p:addReputationPoints(25)
			p:setCanDock(false)
			p:addToShipLog(_("goal-shipLog","Stand by for transfer to Phobos M3P"),"Magenta")
			if out ~= "" then
				p:addToShipLog(out,"Magenta")
			end
		end
		missionMaintenance = transferToPhobos
	end
end
function transferToPhobos()
	if phobos_time == nil then
		flavia_retire_time = getScenarioTime() + (transfer_interval * 3)
		phobos_time = getScenarioTime() + (transfer_interval * 2)
		phobos_delivery_time = getScenarioTime() + transfer_interval
		active_player_flavias = {}
		for i,p in ipairs(getActivePlayerShips()) do
			p:setCanBeDestroyed(false)
			table.insert(active_player_flavias,p)
		end
	end
	if getScenarioTime() > flavia_retire_time then
		for i,p in ipairs(getActivePlayerShips()) do
			if p:getTypeName() == "Flavia P.Falcon" then
				for i,pa in ipairs(getActivePlayerShips()) do
					pa:addToShipLog(string.format(_("goal-shipLog","%s has withdrawn to the shipyard at %s for maintenance."),p:getCallSign(),home_station:getCallSign()),"Magenta")
				end
				p:destroy()
			end
		end
		missionMaintenance = phobosDefendHome
	end
	if getScenarioTime() > phobos_delivery_time then
		if phobos_delivered == nil then
			local jda = random(0,360)
			local jd_x, jd_y = vectorFromAngle(jda,3000)
			jd_x = jd_x + home_station_x
			jd_y = jd_y + home_station_y
			jump_delivery = CpuShip():setTemplate("Jump Carrier"):setFaction("Human Navy")
			jump_delivery:setPosition(jd_x,jd_y):setScannedByFaction("Human Navy",true)
			jump_delivery:setCallSign(jump_delivery_name)
			local temp_type_name = "Phobos M3P"
			local phobos_angle = random(0,360)
			for i=1,player_ship_count do
				local p = PlayerSpaceship()
				p:setTemplate(temp_type_name)
				p:setFaction("Human Navy")
				phobos_angle = (phobos_angle + (360 / player_ship_count)) % 360
				local px, py = vectorFromAngle(phobos_angle, 300, true)
				px = px + jd_x
				py = py + jd_y
				p:setPosition(px, py)
				p:setHeading(phobos_angle)
				p:commandTargetRotation((phobos_angle + 270) % 360)
				p:commandDock(jump_delivery)
				p:setScannedByFaction("Human Navy",true)
				p.normal_long_range_radar = player_ship_stats[temp_type_name].long_range_radar
				local player_ship_name_list = player_ship_names_for[temp_type_name]
				local player_ship_name = nil
				if player_ship_name_list ~= nil then
					player_ship_name = tableRemoveRandom(player_ship_name_list)
				end
				if player_ship_name == nil then
					player_ship_name = tableSelectRandom(player_ship_names_for["Leftovers"])
				end
				if player_ship_name ~= nil then
					p:setCallSign(player_ship_name)
				end
				p:onDestruction(playerPhobosDestroyed)
			end
			for i,p in ipairs(getActivePlayerShips()) do
				p:addToShipLog(string.format(_("goal-shipLog","Delivery ship, %s has arrived."),jump_delivery:getCallSign()),"Magenta")
			end
			phobos_delivered = true
		end
	end
	if getScenarioTime() > phobos_time then
		if phobos_board == nil then
			for i,p in ipairs(active_player_flavias) do
				for j,pf in ipairs(getActivePlayerShips()) do
					if pf:getTypeName() == "Phobos M3P" and pf.transfer_from == nil then
						p:transferPlayersToShip(pf)
						pf.transfer_from = p:getCallSign()
						for k,pm in ipairs(getActivePlayerShips()) do
							pm:addToShipLog(string.format(_("goal-shipLog","Crew from %s transferred to %s."),p:getCallSign(),pf:getCallSign()),"Magenta")
						end
						local consoles = {"Helms","Weapons","Engineering","Science","Relay","Tactical","Operations","Engineering+","Single","DamageControl","PowerManagement","Database","AltRelay","CommsOnly","ShipLog"}
						for j,console in ipairs(consoles) do
							local msg = string.format(_("goal-shipLog","You have been transferred from your previous ship %s to your new ship %s."),p:getCallSign(),pf:getCallSign())
							if console == "Engineering" or console == "Engineering+" or console == "DamageControl" then
								msg = string.format(_("goal-shipLog","%s\nIf you don't see any repair crew, you will need to manually exit the ship and re-enter in order to have them show up."),msg)
							end
							pf:addCustomMessage(console,string.format("transfer%s",console),msg)
						end
						break
					end
				end
			end
			if player_flavias_destroyed ~= nil and #player_flavias_destroyed > 0 then
				local global_board_message = _("msgMainscreen","Crew Reassignment:")
				local banner_message = ""
				for i,name in ipairs(player_flavias_destroyed) do
					for j,pf in ipairs(getActivePlayerShips()) do
						if pf:getTypeName() == "Phobos M3P" and pf.transfer_from == nil then
							pf.transfer_from = name
							local board_message = string.format(_("goal-shipLog","Crew from %s should board %s."),name,pf:getCallSign())
							for k,pm in ipairs(getActivePlayerShips()) do
								pm:addToShipLog(board_message,"Magenta")
							end
							banner_message = string.format("%s %s",banner_message,board_message)
							global_board_message = string.format("%s\n%s",global_board_message,board_message)
							break
						end
					end
				end
				addGMMessage(global_board_message)
				globalMessage(global_board_message,10)
				setBanner(banner_message)
			end
			phobos_board = "complete"
		end
	end
end
function phobosDefendHome()
	if jump_delivery:isValid() then
		local function deliveryShipDeparture()
			if jump_delivery:isValid() then
				for i,p in ipairs(getActivePlayerShips()) do
					if p:getDockedWith() == jump_delivery then
						p:commandUndock()
					end
					p:addToShipLog(string.format(_("goal-shipLog","%s has returned to the primary Human Navy shipyard to prepare to make other ship deliveries."),jump_delivery_name),"Magenta")
				end
				jump_delivery:destroy()
			end
		end
		if phobos_delivery_departure_time == nil then
			local all_undocked = true
			for i,p in ipairs(getActivePlayerShips()) do
				local docked_entity = p:getDockedWith()
				if docked_entity ~= nil and docked_entity == jump_delivery then
					all_undocked = false
					break
				end
			end
			if all_undocked then
				phobos_delivery_departure_time = getScenarioTime() + 10
			end
			if wait_for_phobos_players_to_undock_time == nil then
				wait_for_phobos_players_to_undock_time = getScenarioTime() + 60
			end
			if getScenarioTime() > wait_for_phobos_players_to_undock_time then
				deliveryShipDeparture()
			end
		else
			if getScenarioTime() > phobos_delivery_departure_time then
				deliveryShipDeparture()
			end
		end
	end
	for i,p in ipairs(getActivePlayerShips()) do
		local docked_entity = p:getDockedWith()
		if docked_entity == nil or docked_entity ~= jump_delivery then
			local home_station_x, home_station_y = home_station:getPosition()
			if p.player_escorts == nil then
				p.player_escorts = {}
				local jd_x, jd_y = jump_delivery:getPosition()
				local launch_angle = angleHeading(home_station_x, home_station_y, jd_x, jd_y)
				local lp_x, lp_y = vectorFromAngle(launch_angle,1000)
				lp_x = lp_x + home_station_x
				lp_y = lp_y + home_station_y
				for j,form in ipairs(fly_formation["X"]) do
					local ship = CpuShip():setTemplate("MU52 Hornet"):setFaction("Human Navy")
					local form_prime_x, form_prime_y = vectorFromAngle(form.angle, form.dist * 1000)
					ship.form_prime_x = form_prime_x
					ship.form_prime_y = form_prime_y
					ship.formation_leader = p
					ship:setPosition(lp_x,lp_y):setHeading(launch_angle):orderFlyFormation(p,form_prime_x,form_prime_y)
					ship:setCallSign(generateCallSign(p:getCallSign()))
					ship:setScannedByFaction("Human Navy",true)
					ship:setCommsFunction(commsFormationFighters)
					table.insert(p.player_escorts,ship)
				end
			end
			if phobos_fighters == nil then
				second_kraylor_fighter_fleet = true
				phobos_fighters = {}
				local target_station_x, target_station_y = target_station:getPosition()
				local enemy_angle = angleHeading(home_station_x, home_station_y, target_station_x, target_station_y)
				local es_x, es_y = vectorFromAngle(enemy_angle,20000)
				es_x = es_x + home_station_x
				es_y = es_y + home_station_y
				fleetComposition = "Fighters"
				relative_strength = 3
				phobos_fighters = spawnRandomArmed(es_x,es_y)
				for i,ship in ipairs(phobos_fighters) do
					ship:orderFlyTowards(home_station_x, home_station_y)
				end
				relative_strength = 1
				fleetComposition = "Random"
			end
		end
	end
	if second_kraylor_fighter_fleet then
		if phobos_fighters ~= nil and #phobos_fighters > 0 then
			for i,ship in ipairs(phobos_fighters) do
				if not ship:isValid() then
					phobos_fighters[i] = phobos_fighters[#phobos_fighters]
					phobos_fighters[#phobos_fighters] = nil
					break
				end
			end
		else
			for i,p in ipairs(getActivePlayerShips()) do
				p:addToShipLog(string.format(_("goal-shipLog","Kraylor fighter fleet destroyed. Dock with %s"),home_station:getCallSign()),"Magenta")
			end
			missionMaintenance = dockAfterSecondFighterWave
			primary_orders = string.format(_("orders-comms","Dock with station %s"),home_station:getCallSign())
		end
		build_defense_platform = true
	end
end
function buildDefensePlatform()
	local home_station_x, home_station_y = home_station:getPosition()
	if construction_freighter == nil then
		construction_freighter = CpuShip():setTemplate("Equipment Freighter 3"):setFaction("Independent"):setScannedByFaction("Human Navy",true)
		construction_angle = random(0,360)
		local cx, cy = vectorFromAngle(construction_angle,100,true)
		cx = cx + home_station_x
		cy = cy + home_station_y
		construction_freighter:setPosition(cx,cy)
		construction_freighter:setCallSign(generateCallSign())
		construction_freighter.zone_index = 1
	else
		if construction_freighter.construction_zones == nil then
			construction_freighter.construction_zones = {}
		end
		if construction_freighter.zone_index > 6 then
			construction_freighter:orderDock(home_station)
			build_defense_platform = false
		else
			if construction_freighter.construction_zones[construction_freighter.zone_index] == nil then
				local zx, zy = vectorFromAngle(construction_angle,3000,true)
				zx = zx + home_station_x
				zy = zy + home_station_y
				construction_freighter:orderFlyTowards(zx,zy)
				table.insert(construction_freighter.construction_zones,{x=zx,y=zy})
			end
			local cx, cy = construction_freighter:getPosition()
			if construction_freighter.construction_zones[construction_freighter.zone_index].built == nil then
				local zx, zy = nil
				if construction_freighter.construction_zones[construction_freighter.zone_index] ~= nil then
					zx = construction_freighter.construction_zones[construction_freighter.zone_index].x
					zy = construction_freighter.construction_zones[construction_freighter.zone_index].y
				end
		--		print("zx, zy, cx, cy:",zx,zy,cx,cy)
				if zx ~= nil and distance(zx,zy,cx,cy) < 800 and construction_freighter.construction_zones[construction_freighter.zone_index] ~= nil then
					local dp = CpuShip():setTemplate("Defense platform"):setFaction("Human Navy")
					dp:setPosition(construction_freighter.construction_zones[construction_freighter.zone_index].x,construction_freighter.construction_zones[construction_freighter.zone_index].y)
					dp:setScannedByFaction("Human Navy",true):orderStandGround()
					construction_freighter:orderDock(home_station)
					construction_freighter.construction_zones[construction_freighter.zone_index].built = true
					construction_freighter.zone_index = construction_freighter.zone_index + 1
					construction_angle = (construction_angle + 60) % 360
				end
			end
		end
	end
end
function dockAfterSecondFighterWave()
	local all_docked = true
	for i,p in ipairs(getActivePlayerShips()) do
		local docked_station = p:getDockedWith()
		local home_station_x, home_station_y = home_station:getPosition()
		local target_station_x, target_station_y = target_station:getPosition()
		local kraylor_heading = angleHeading(home_station_x, home_station_y, target_station_x, target_station_y)
		if docked_station ~= nil and docked_station == home_station then
			if p.defend_station_message == nil then
				p.defend_station_message = "sent"
				bearing_message = string.format(_("goal-shipLog","You will find Kraylor station %s on bearing %.1f from station %s. We expect the defense platforms to protect %s, but it's still a good idea to destroy Kraylor that are heading for %s."),target_station:getCallSign(),kraylor_heading,home_station:getCallSign(),home_station:getCallSign(),home_station:getCallSign())
				p:addToShipLog(bearing_message,"Magenta")
			end
		end
		if docked_station == nil or docked_station ~= home_station then
			all_docked = false
			break
		end
	end
	primary_orders = string.format(_("orders-comms","Destroy Kraylor station %s in sector %s"),target_station:getCallSign(),target_station:getSectorName())
	if all_docked then
		local out = ""
		if player_phobos_destroyed ~= nil then
			local ships = ""
			for i,name in ipairs(player_phobos_destroyed) do
				if ships == "" then
					ships = name
				else
					ships = string.format("%s, %s",ships,name)
				end
			end
			out = string.format(_("goal-shipLog","Inform crew of %s that they will be placed on an Atlantis shortly."),ships)
			if #player_phobos_destroyed > 1 then
				out = string.format(_("goal-shipLog","Inform crews of %s that they will be placed on an Atlantis shortly."),ships)
			end
		end
		for i,p in ipairs(getActivePlayerShips()) do
			p:addReputationPoints(25)
			p:setCanDock(false)
			p:addToShipLog(_("goal-shipLog","Stand by for transfer to Atlantis"),"Magenta")
			if out ~= "" then
				p:addToShipLog(out,"Magenta")
			end
		end
		missionMaintenance = transferToAtlantis
	end
	if post_second_kraylor_fleet_message == nil then
		post_second_kraylor_fleet_message = "sent"
		for i,p in ipairs(getActivePlayerShips()) do
			p:addToShipLog(string.format(_("goal-shipLog","We need to take the battle to the Kraylor. To that end, we have requested Atlantis class ships for you to hunt down the Kraylor station. Dock with %s to facilitate transfer from the Phobos class to the Atlantis class ship."),home_station:getCallSign()),"Magenta")
		end
	end
end
function transferToAtlantis()
	if atlantis_time == nil then
		phobos_retire_time = getScenarioTime() + (transfer_interval * 3)
		atlantis_time = getScenarioTime() + (transfer_interval * 2)
		atlantis_delivery_time = getScenarioTime() + transfer_interval
		active_player_phobos = {}
		for i,p in ipairs(getActivePlayerShips()) do
			p:setCanBeDestroyed(false)
			table.insert(active_player_phobos,p)
		end
	end
	if getScenarioTime() > phobos_retire_time then
		for i,p in ipairs(getActivePlayerShips()) do
			if p:getTypeName() == "Phobos M3P" then
				for i,pa in ipairs(getActivePlayerShips()) do
					pa:addToShipLog(string.format(_("goal-shipLog","%s has withdrawn to the shipyard at %s for maintenance."),p:getCallSign(),home_station:getCallSign()),"Magenta")
				end
				if p.player_escorts ~= nil and #p.player_escorts > 0 then
					for j,ship in ipairs(p.player_escorts) do
						if ship:isValid() then
							ship:orderDefendTarget(home_station)
						end
					end
				end
				p:destroy()
			end
		end
		missionMaintenance = atlantisAttackKraylorStation
	end
	if getScenarioTime() > atlantis_delivery_time then
		if atlantis_delivered == nil then
			local jda = random(0,360)
			local jd_x, jd_y = vectorFromAngle(jda,3000)
			jd_x = jd_x + home_station_x
			jd_y = jd_y + home_station_y
			jump_delivery = CpuShip():setTemplate("Jump Carrier"):setFaction("Human Navy")
			jump_delivery:setPosition(jd_x,jd_y):setScannedByFaction("Human Navy",true)
			jump_delivery:setCallSign(jump_delivery_name)
			local temp_type_name = "Atlantis"
			local atlantis_angle = random(0,360)
			for i=1,player_ship_count do
				local p = PlayerSpaceship()
				p:setTemplate(temp_type_name)
				p:setFaction("Human Navy")
				atlantis_angle = (atlantis_angle + (360 / player_ship_count)) % 360
				local px, py = vectorFromAngle(atlantis_angle, 400, true)
				px = px + jd_x
				py = py + jd_y
				p:setPosition(px, py)
				p:setHeading(atlantis_angle)
				p:commandTargetRotation((atlantis_angle + 270) % 360)
				p:commandDock(jump_delivery)
				p:setScannedByFaction("Human Navy",true)
				p.normal_long_range_radar = player_ship_stats[temp_type_name].long_range_radar
				local player_ship_name_list = player_ship_names_for[temp_type_name]
				local player_ship_name = nil
				if player_ship_name_list ~= nil then
					player_ship_name = tableRemoveRandom(player_ship_name_list)
				end
				if player_ship_name == nil then
					player_ship_name = tableSelectRandom(player_ship_names_for["Leftovers"])
				end
				if player_ship_name ~= nil then
					p:setCallSign(player_ship_name)
				end
				p:onDestruction(playerAtlantisDestroyed)
			end
			for i,p in ipairs(getActivePlayerShips()) do
				p:addToShipLog(string.format(_("goal-shipLog","Delivery ship, %s has arrived."),jump_delivery:getCallSign()),"Magenta")
			end
			atlantis_delivered = true
		end
	end
	if getScenarioTime() > atlantis_time then
		if atlantis_board == nil then
			for i,p in ipairs(active_player_phobos) do
				for j,pf in ipairs(getActivePlayerShips()) do
					if pf:getTypeName() == "Atlantis" and pf.transfer_from == nil then
						p:transferPlayersToShip(pf)
						pf.transfer_from = p:getCallSign()
						for k,pm in ipairs(getActivePlayerShips()) do
							pm:addToShipLog(string.format(_("goal-shipLog","Crew from %s transferred to %s."),p:getCallSign(),pf:getCallSign()),"Magenta")
						end
						pf:addToShipLog(bearing_message,"Magenta")
						local consoles = {"Helms","Weapons","Engineering","Science","Relay","Tactical","Operations","Engineering+","Single","DamageControl","PowerManagement","Database","AltRelay","CommsOnly","ShipLog"}
						for j,console in ipairs(consoles) do
							local msg = string.format(_("goal-shipLog","You have been transferred from your previous ship %s to your new ship %s."),p:getCallSign(),pf:getCallSign())
							if console == "Engineering" or console == "Engineering+" or console == "DamageControl" then
								msg = string.format("%s\nIf you don't see any repair crew, you will need to manually exit the ship and re-enter in order to have them show up.",msg)
							end
							pf:addCustomMessage(console,string.format("transfer%s",console),msg)
						end
						break
					end
				end
			end
			if player_phobos_destroyed ~= nil and #player_phobos_destroyed > 0 then
				local global_board_message = _("msgMainscreen","Crew Reassignment:")
				local banner_message = ""
				for i,name in ipairs(player_phobos_destroyed) do
					for j,pf in ipairs(getActivePlayerShips()) do
						if pf:getTypeName() == "Atlantis" and pf.transfer_from == nil then
							pf.transfer_from = name
							local board_message = string.format("Crew from %s should board %s.",name,pf:getCallSign())
							for k,pm in ipairs(getActivePlayerShips()) do
								pm:addToShipLog(board_message,"Magenta")
							end
							banner_message = string.format("%s %s",banner_message,board_message)
							global_board_message = string.format("%s\n%s",global_board_message,board_message)
							break
						end
					end
				end
				addGMMessage(global_board_message)
				globalMessage(global_board_message,10)
				setBanner(banner_message)
			end
			atlantis_board = "complete"
		end
	end
end
function atlantisAttackKraylorStation()
	if kraylor_defense_fleet_respawn_interval_time == nil then
		kraylor_defense_fleet_respawn_interval_time = 60
	end
	if target_station.defense_fleet == nil then
		target_station.defense_fleet = {}
	end
	local clean_defense_list = true
	for i,ship in ipairs(target_station.defense_fleet) do
		if ship == nil or not ship:isValid() then
			target_station.defense_fleet[i] = target_station.defense_fleet[#target_station.defense_fleet]
			target_station.defense_fleet[#target_station.defense_fleet] = nil
			clean_defense_list = false
			break
		end
	end
	if clean_defense_list then
		if #target_station.defense_fleet < 2 then
			if kraylor_defense_fleet_respawn_time == nil then
				kraylor_defense_fleet_respawn_time = kraylor_defense_fleet_respawn_interval_time + random(1,8)
			end
			if getScenarioTime() > kraylor_defense_fleet_respawn_time then
				local target_station_x, target_station_y = target_station:getPosition()
				local fleet = spawnRandomArmed(target_station_x, target_station_y)
				for i,ship in ipairs(fleet) do
					ship:orderDefendTarget(target_station)
					table.insert(target_station.defense_fleet,ship)
				end
				kraylor_defense_fleet_respawn_time = nil
				kraylor_defense_fleet_respawn_interval_time = kraylor_defense_fleet_respawn_interval_time + 10
			end
		end
	end
	if kraylor_offense_fleet_respawn_interval_time == nil then
		kraylor_offense_fleet_respawn_interval_time = 300
	end
	if target_station.offense_fleet == nil then
		target_station.offense_fleet = {}
		local target_station_x, target_station_y = target_station:getPosition()
		local fleet = spawnRandomArmed(target_station_x, target_station_y)
		local home_station_x, home_station_y = home_station:getPosition()
		for i,ship in ipairs(fleet) do
			ship:orderFlyTowards(home_station_x, home_station_y)
			table.insert(target_station.offense_fleet,ship)
		end
	end
	local clean_offense_list = true
	for i,ship in ipairs(target_station.offense_fleet) do
		if ship == nil or not ship:isValid() then
			target_station.offense_fleet[i] = target_station.offense_fleet[#target_station.offense_fleet]
			target_station.offense_fleet[#target_station.offense_fleet] = nil
			clean_offense_list = false
			break
		end
	end
	if clean_offense_list then
		if #target_station.offense_fleet < 2 then
			if kraylor_offense_fleet_respawn_time == nil then
				kraylor_offense_fleet_respawn_time = kraylor_offense_fleet_respawn_interval_time + random(1,8)
			end
			if getScenarioTime() > kraylor_offense_fleet_respawn_time then
				local target_station_x, target_station_y = target_station:getPosition()
				local home_station_x, home_station_y = home_station:getPosition()
				fleetComposition = "Chasers"
				relative_strength = 2
				local fleet = spawnRandomArmed(target_station_x, target_station_y)
				for i,ship in ipairs(fleet) do
					ship:orderFlyTowards(home_station_x, home_station_y)
					table.insert(target_station.offense_fleet,ship)
				end
				relative_strength = 1
				fleetComposition = "Random"
				kraylor_offense_fleet_respawn_time = nil
				kraylor_offense_fleet_respawn_interval_time = kraylor_offense_fleet_respawn_interval_time + 15
			end
		end
	end
end
--	Spawning
function getTemplatePool(max_strength)
	local function getStrengthSort(tbl, sortFunction)
		local keys = {}
		for key in pairs(tbl) do
			table.insert(keys,key)
		end
		table.sort(keys, function(a,b)
			return sortFunction(tbl[a], tbl[b])
		end)
		return keys
	end
	local ship_template_by_strength = getStrengthSort(ship_template, function(a,b)
		return a.strength > b.strength
	end)
	local template_pool = {}
	if pool_selectivity == "less/heavy" then
		for _, current_ship_template in ipairs(ship_template_by_strength) do
			if ship_template[current_ship_template].strength <= max_strength then
				if fleetComposition == "Non-DB" then
					if ship_template[current_ship_template].create ~= stockTemplate then
						table.insert(template_pool,current_ship_template)
					end
				elseif fleetComposition == "Random" then
					table.insert(template_pool,current_ship_template)
				else
					if ship_template[current_ship_template].fleet_group[fleetComposition] then
						table.insert(template_pool,current_ship_template)							
					end
				end
			end
			if #template_pool >= template_pool_size then
				break
			end
		end
	elseif pool_selectivity == "more/light" then
		for i=#ship_template_by_strength,1,-1 do
			local current_ship_template = ship_template_by_strength[i]
			if ship_template[current_ship_template].strength <= max_strength then
				if fleetComposition == "Non-DB" then
					if ship_template[current_ship_template].create ~= stockTemplate then
						table.insert(template_pool,current_ship_template)
					end
				elseif fleetComposition == "Random" then
					table.insert(template_pool,current_ship_template)
				else
					if ship_template[current_ship_template].fleet_group[fleetComposition] then
						table.insert(template_pool,current_ship_template)							
					end
				end
			end
			if #template_pool >= template_pool_size then
				break
			end
		end
	else	--full
		for current_ship_template, details in pairs(ship_template) do
			if details.strength <= max_strength then
				if fleetComposition == "Non-DB" then
					if ship_template[current_ship_template].create ~= stockTemplate then
						table.insert(template_pool,current_ship_template)
					end
				elseif fleetComposition == "Random" then
					table.insert(template_pool,current_ship_template)
				else
					if ship_template[current_ship_template][fleet_group[fleetComposition]] then
						table.insert(template_pool,current_ship_template)							
					end
				end
			end
		end
	end
	return template_pool
end
function spawnRandomArmed(x, y, enemy_strength, template_pool)
--x and y are central spawn coordinates
--fleetIndex is the number of the fleet to be spawned
--spawn_distance optional - used for ambush or pyramid
--spawn_angle optional - used for ambush or pyramid
--px and py are the player coordinates or the pyramid fly towards point coordinates
	if enemy_strength == nil then
		enemy_strength = math.max(relative_strength * playerPower() * enemy_power,5)
	end
	local sp = random(500,1000)			--random spacing of spawned group
	local shape = "square"
	if random(1,100) < 50 then
		shape = "hexagonal"
	end
	local enemy_position = 0
	local enemyList = {}
	--print("in spawn random armed function about to call get template pool function")
	if template_pool == nil then
		template_pool = getTemplatePool(enemy_strength)
	end
	if #template_pool < 1 then
		addGMMessage("Empty Template pool: fix excludes or other criteria")
		return enemyList
	end
	local fleet_prefix = generateCallSignPrefix()
	if fleetSpawnFaction == nil then
		fleetSpawnFaction = "Kraylor"
	end
	while enemy_strength > 0 do
		local selected_template = template_pool[math.random(1,#template_pool)]
		if ship_template[selected_template].create == nil then
			print("Template",selected_template,"does not have a create routine in ship_template")
		end
		local ship = ship_template[selected_template].create(fleetSpawnFaction,selected_template)
		ship:setCallSign(generateCallSign(nil,fleetSpawnFaction))
		ship:orderRoaming()
		enemy_position = enemy_position + 1
		ship:setPosition(x + formation_delta[shape].x[enemy_position] * sp, y + formation_delta[shape].y[enemy_position] * sp)
		table.insert(enemyList, ship)
		enemy_strength = enemy_strength - ship_template[selected_template].strength
	end
	return enemyList
end
function playerPower()
	local playerShipScore = 0
	for i,p in ipairs(getActivePlayerShips()) do
		if p.shipScore ~= nil then
			playerShipScore = playerShipScore + p.shipScore
		else
			playerShipScore = playerShipScore + 24
		end
	end
	return playerShipScore
end
--	Messaging
function scenarioShipMissions()
	local comms_options_presented = 0
	if comms_source:isFriendly(comms_target) then
		comms_options_presented = comms_options_presented + 1
		if comms_target.leader ~= nil and comms_target.leader:isValid() then
			addCommsReply(_("ship-comms","Return to original formation"),function()
				comms_target:orderFlyFormation(comms_target.leader,comms_target.form_prime_x,comms_target.form_prime_y)
				comms_target:setCommsFunction(commsSAUV)
				setCommsMessage(_("ship-comms","Returning to original formation"))
			end)
		end
	end
	return comms_options_presented
end
function commsSAUV()
	if comms_source:isFriendly(comms_target) then
		setCommsMessage(_("ship-comms","What are your orders"))
		if comms_target.sauv_leader then
			if comms_target.mother:isValid() then
				if comms_source == comms_target.mother then
					local assist_me_prompts = {
						_("shipAssist-comms", "Assist me"),
						_("shipAssist-comms", "Help me"),
						string.format(_("shipAssist-comms", "Assist %s"),comms_source:getCallSign()),
						string.format(_("shipAssist-comms", "Move to %s to assist"),comms_source:getCallSign()),
					}
					addCommsReply(tableSelectRandom(assist_me_prompts), function()
						local assist_confirmation = {
							_("shipAssist-comms", "Heading toward you to assist."),
							_("shipAssist-comms", "Moving to you to assist."),
							string.format(_("shipAssist-comms", "Setting course for %s to assist."),comms_source:getCallSign()),
							string.format(_("shipAssist-comms", "%s is changing course in order to move to %s to help."),comms_target:getCallSign(),comms_source:getCallSign()),
						}
						setCommsMessage(tableSelectRandom(assist_confirmation))
						comms_target:orderDefendTarget(comms_source)
						addCommsReply(_("Back"), commsSAUV)
					end)
					addCommsReply(_("ship-comms","Go to waypoint"),function()
						if comms_source:getWaypointCount() == 0 then
							local set_waypoint_first = {
								_("shipAssist-comms", "No waypoints set. Please set a waypoint first."),
								_("shipAssist-comms", "It is impossible to go to a waypoint when none are set."),
								_("shipAssist-comms", "We can't go to a waypoint when there are no waypoints set"),
								_("shipAssist-comms", "You need to set a waypoint first so that we can go to it."),
							}
							setCommsMessage(tableSelectRandom(set_waypoint_first))
						else
							local defend_what_waypoint = {
								_("shipAssist-comms", "Which waypoint should we go to?"),
								_("shipAssist-comms", "What waypoint should we go to?"),
								_("shipAssist-comms", "Designate the waypoint we should go to"),
								string.format(_("shipAssist-comms", "Identify the waypoint for %s to go to"),comms_target:getCallSign()),
							}
							setCommsMessage(tableSelectRandom(defend_what_waypoint))
							for n=1,comms_source:getWaypointCount() do
								addCommsReply(string.format(_("shipAssist-comms", "Go to waypoint %d"), n), function()
									comms_target:orderDefendLocation(comms_source:getWaypoint(n))
									local defend_wp_confirmation = {
										string.format(_("shipAssist-comms", "We are heading to assist at waypoint %d."), n),
										string.format(_("shipAssist-comms", "Changing course to assist at waypoint %d."), n),
										string.format(_("shipAssist-comms", "Moving to assist at waypoint %d."), n),
										string.format(_("shipAssist-comms", "%s is changing course to assist at waypoint %d."),comms_target:getCallSign(), n),
									}
									setCommsMessage(tableSelectRandom(defend_wp_confirmation));
									addCommsReply(_("Back"), commsSAUV)
								end)
							end
						end
						addCommsReply(_("Back"), commsSAUV)
					end)
					addCommsReply(_("ship-comms","Return to mother ship"),function()
						local m_x, m_y = comms_source:getPosition()
						comms_target:orderFlyTowards(m_x, m_y)
						if mother_returnees == nil then
							mother_returnees = {}
						end
						table.insert(mother_returnees,comms_target)
						setCommsMessage(_("ship-comms","Returning to mother ship"))
						addCommsReply(_("Back"), commsSAUV)
					end)
				end
				--non-mother ship and mother ship giving orders
				addCommsReply(_("ship-comms","Report status"), function()
					msg = string.format(_("ship-comms","Hull: %s%%\n"),math.floor(comms_target:getHull() / comms_target:getHullMax() * 100))
					local shields = comms_target:getShieldCount()
					if shields == 1 then
						msg = string.format(_("ship-comms","%sShield: %s%%\n"),msg,math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100))
					elseif shields == 2 then
						msg = string.format(_("ship-comms","%sFront Shield: %s%%\n"),msg,math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100))
						msg = string.format(_("ship-comms","%sRear Shield: %s%%\n"),msg,math.floor(comms_target:getShieldLevel(1) / comms_target:getShieldMax(1) * 100))
					else
						for n=0,shields-1 do
							msg = string.format(_("ship-comms","%sShield %i: %s%%\n"),msg,n,math.floor(comms_target:getShieldLevel(n) / comms_target:getShieldMax(n) * 100))
						end
					end
					for i, missile_type in ipairs(missile_types) do
						if comms_target:getWeaponStorageMax(missile_type) > 0 then
							msg = string.format(_("ship-comms","%s%s Missiles: %s/%s\n"),msg,missile_type,math.floor(comms_target:getWeaponStorage(missile_type)),math.floor(comms_target:getWeaponStorageMax(missile_type)))
						end
					end
					if comms_target:hasJumpDrive() then
						msg = string.format(_("ship-comms","%sJump drive charge: %s\n"),msg,comms_target:getJumpDriveCharge())
					end
					local orders = comms_target:getOrder()
					msg = string.format(_("ship-comms","%s\nCurrent orders: %s"),msg,orders)
					if orders == "Attack" or orders == "Defend Target" or orders == "Dock" or orders == "Fly in formation" then
						local order_target = comms_target:getOrderTarget()
						msg = string.format(_("ship-comms","%s   Target: %s"),msg,order_target:getCallSign())
					end
					setCommsMessage(msg);
					addCommsReply("Back", commsSAUV)
				end)
			else	--mother ship is dead
				addCommsReply(string.format(_("ship-comms","Transfer to new mothership, %s"),comms_source:getCallSign()),function()
					comms_target.mother = comms_source
					setCommsMessage(string.format(_("ship-comms","Transferring to %s as new mothership."),comms_source:getCallSign()))
				end)
			end
		else	--not sauv leader
			if comms_target.leader ~= nil and comms_target.leader:isValid() then
				local ship_order = comms_target:getOrder()
				if ship_order == "Fly in formation" then
					setCommsMessage(string.format(_("ship-comms","Orders for the entire formation are given to the leader, %s. But you can give independent orders to this ship if you wish for it to no longer be part of the formation."),comms_target.leader:getCallSign()))
					addCommsReply(string.format(_("ship-comms","Make %s independent of the formation"),comms_target:getCallSign()),function()
						setCommsMessage(_("ship-comms","Reconfiguring for independent operation. Contact me again to give me specific orders."))
						comms_target:setCommsFunction(commsShip)
					end)
				end
			else	--sauv leader is dead
				if comms_target.mother ~= nil and comms_target.mother:isValid() then
					addCommsReply(_("ship-comms","Return to mother ship"),function()
						local m_x, m_y = comms_source:getPosition()
						comms_target:orderFlyTowards(m_x, m_y)
						if mother_returnees == nil then
							mother_returnees = {}
						end
						table.insert(mother_returnees,comms_target)
						setCommsMessage(_("ship-comms","Returning to mother ship"))
						addCommsReply(_("Back"), commsSAUV)
					end)
				else	--mother ship is dead
					addCommsReply(string.format(_("ship-comms","Transfer to new mothership, %s"),comms_source:getCallSign()),function()
						comms_target.mother = comms_source
						setCommsMessage(string.format(_("ship-comms","Transferring to %s as new mothership."),comms_source:getCallSign()))
					end)
				end
			end
		end
		return true
	else
		return false
	end
end
function commsFormationFighters()
	if comms_source:isFriendly(comms_target) then
		return friendlyFormationFighterComms()
	end
end
function friendlyFormationFighterComms()
	setCommsMessage(_("ship-comms","What are your orders?"))
	addCommsReply(_("ship-comms","Report status"), function()		
		msg = string.format(_("ship-comms","Hull: %s%%\n"),math.floor(comms_target:getHull() / comms_target:getHullMax() * 100))
		local shields = comms_target:getShieldCount()
		if shields == 1 then
			msg = string.format(_("ship-comms","%sShield: %s%%\n"),msg,math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100))
		elseif shields == 2 then
			msg = string.format(_("ship-comms","%sFront Shield: %s%%\n"),msg,math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100))
			msg = string.format(_("ship-comms","%sRear Shield: %s%%\n"),msg,math.floor(comms_target:getShieldLevel(1) / comms_target:getShieldMax(1) * 100))
		else
			for n=0,shields-1 do
				msg = string.format(_("ship-comms","%sShield %i: %s%%\n"),msg,n,math.floor(comms_target:getShieldLevel(n) / comms_target:getShieldMax(n) * 100))
			end
		end
		for i, missile_type in ipairs(missile_types) do
			if comms_target:getWeaponStorageMax(missile_type) > 0 then
				msg = string.format(_("ship-comms","%s%s Missiles: %s/%s\n"),msg,missile_type,math.floor(comms_target:getWeaponStorage(missile_type)),math.floor(comms_target:getWeaponStorageMax(missile_type)))
			end
		end
		if comms_target:hasJumpDrive() then
			msg = string.format(_("ship-comms","%sJump drive charge: %s\n"),msg,comms_target:getJumpDriveCharge())
		end
		local orders = comms_target:getOrder()
		msg = string.format(_("ship-comms","%s\nCurrent orders: %s"),msg,orders)
		if orders == "Attack" or orders == "Defend Target" or orders == "Dock" or orders == "Fly in formation" then
			local order_target = comms_target:getOrderTarget()
			msg = string.format(_("ship-comms","%s   Target: %s"),msg,order_target:getCallSign())
		end
		setCommsMessage(msg);
		addCommsReply(_("Back"), commsFormationFighters)
	end)
	local ship_order = comms_target:getOrder()
				--Possible order strings returned:
				--Roaming
				--Fly towards
				--Attack
				--Stand Ground
				--Idle
				--Defend Location
				--Defend Target
				--Fly in formation
				--Fly towards (ignore all)
				--Dock
	if ship_order == "Dock" then
		if comms_target.formation_leader ~= nil and comms_target.formation_leader:isValid() and comms_target.formation_leader == comms_source then
			addCommsReply(_("ship-comms","Return to formation"), function()
				setCommsMessage(string.format(_("ship-comms","%s returning to formation"),comms_target:getCallSign()))
				comms_target:orderFlyFormation(comms_source,comms_target.form_prime_x,comms_target.form_prime_y)
				addCommsReply(_("Back"), commsFormationFighters)
			end)
		end
	else
		if comms_target.formation_leader ~= nil and comms_target.formation_leader:isValid() and comms_target.formation_leader == comms_source then
			if ship_order == "Fly in formation" then
				for _, obj in ipairs(comms_target:getObjectsInRange(5000)) do
					if isObjectType(obj,"SpaceStation") and not comms_target:isEnemy(obj) then
						addCommsReply(string.format(_("ship-comms","Dock at %s"),obj:getCallSign()), function()
							setCommsMessage(string.format(_("ship-comms","Docking at %s."),obj:getCallSign()))
							comms_target:orderDock(obj)
							addCommsReply(_("Back"), commsFormationFighters)
						end)
					end
				end
			end
		end
	end
	if not comms_target.formation_leader:isValid() then
		addCommsReply(_("ship-comms","Revert to standard ship comms protocol"),function()
			setCommsMessage(_("ship-comms","Reverting"))
			comms_target:setCommsFunction(commsShip)
		end)
	end
	return true
end
function scenarioShipEnhancements()
	if comms_source.sauv_launcher == nil and comms_source:getTypeName() == "Atlantis" then
		addCommsReply(_("upgrade-comms","Get SAUV launch capability"),function()
			setCommsMessage(_("upgrade-comms","Your ship can now launch Semi-Autonomous Unmanned Vehicles (SAUVs). Weapons launches them. Relay controls them. They don't have jump drives, so it's easy to accidentally leave them behind."))
			comms_source.sauv_launcher = true
			comms_source.sauvs_launched = false
			comms_source.sauv_count = 20
			addCommsReply(_("Back"), commsStation)
		end)		
	end
	if comms_source.probe_upgrade == nil then
		addCommsReply(_("upgrade-comms","Check on probe capacity upgrade availability"),function()
			setCommsMessage(_("upgrade-comms","Our scan probe system specialist, Felix Heavier, has been experimenting with probe storage systems and has some potential upgrades available."))
			if comms_target.probe_storage_upgrades == nil then
				comms_target.probe_storage_upgrades = {
					{bump = 6,	power = 1},
					{bump = 8,	power = .9},
					{bump = 12,	power = .8},
				}
			end
			addCommsReply(_("upgrade-comms","Tell me about the Tetris Mark 4 probe storage upgrade"),function()
				if comms_target.tetris == nil then
					comms_target.tetris = tableRemoveRandom(comms_target.probe_storage_upgrades)
				end
				if comms_target.tetris.power == 1 then
					setCommsMessage(string.format(_("upgrade-comms","The Tetris Mark 4 probe storage upgrade increases your probe storage capacity by %i"),comms_target.tetris.bump))
				else
					setCommsMessage(string.format(_("upgrade-comms","The Tetris Mark 4 probe storage upgrade increases your probe storage capacity by %i but reduces your battery capacity to %i."),comms_target.tetris.bump,math.floor(comms_target.tetris.power * comms_source:getMaxEnergy())))
				end
				addCommsReply(_("upgrade-comms","Please install the Tetris Mark 4 probe storage upgrade"),function()
					comms_source.probe_upgrade = true
					comms_source:setMaxScanProbeCount(comms_source:getMaxScanProbeCount() + comms_target.tetris.bump)
					comms_source:setMaxEnergy(comms_source:getMaxEnergy()*comms_target.tetris.power)
					setCommsMessage(_("upgrade-comms","Felix installed the Tetris Mark 4 probe storage upgrade."))
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(_("Back"), commsStation)
			end)
			addCommsReply(_("upgrade-comms","Tell me about the Jenga VI probe storage upgrade"),function()
				if comms_target.jenga == nil then
					comms_target.jenga = tableRemoveRandom(comms_target.probe_storage_upgrades)
				end
				if comms_target.jenga.power == 1 then
					setCommsMessage(string.format(_("upgrade-comms","The Jenga VI probe storage upgrade increases your probe storage capacity by %i"),comms_target.jenga.bump))
				else
					setCommsMessage(string.format(_("upgrade-comms","The Jenga VI probe storage upgrade increases your probe storage capacity by %i but reduces your battery capacity to %i."),comms_target.jenga.bump,math.floor(comms_target.jenga.power * comms_source:getMaxEnergy())))
				end
				addCommsReply(_("upgrade-comms","Please install the Jenga VI probe storage upgrade"),function()
					comms_source.probe_upgrade = true
					comms_source:setMaxScanProbeCount(comms_source:getMaxScanProbeCount() + comms_target.jenga.bump)
					comms_source:setMaxEnergy(comms_source:getMaxEnergy()*comms_target.jenga.power)
					setCommsMessage(_("upgrade-comms","Felix installed the Jenga VI probe storage upgrade."))
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(_("Back"), commsStation)
			end)
			addCommsReply(_("upgrade-comms","Tell me about the Ikea Mea 3 probe storage upgrade"),function()
				if comms_target.ikea == nil then
					comms_target.ikea = tableRemoveRandom(comms_target.probe_storage_upgrades)
				end
				if comms_target.ikea.power == 1 then
					setCommsMessage(string.format(_("upgrade-comms","The Ikea Mea 3 probe storage upgrade increases your probe storage capacity by %i"),comms_target.ikea.bump))
				else
					setCommsMessage(string.format(_("upgrade-comms","The Ikea Mea 3 probe storage upgrade increases your probe storage capacity by %i but reduces your battery capacity to %i."),comms_target.ikea.bump,math.floor(comms_target.ikea.power * comms_source:getMaxEnergy())))
				end
				addCommsReply(_("upgrade-comms","Please install the Ikea Mea 3 probe storage upgrade"),function()
					comms_source.probe_upgrade = true
					comms_source:setMaxScanProbeCount(comms_source:getMaxScanProbeCount() + comms_target.ikea.bump)
					comms_source:setMaxEnergy(comms_source:getMaxEnergy()*comms_target.ikea.power)
					setCommsMessage(_("upgrade-comms","Felix installed the Ikea Mea 3 probe storage upgrade."))
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(_("Back"), commsStation)
			end)
			addCommsReply(_("Back"), commsStation)
		end)
	end
	if not comms_source.sensor_upgrade then
		addCommsReply(_("upgrade-comms","Check on long range sensor upgrade availability"),function()
			setCommsMessage(string.format(_("upgrade-comms","Our quartermaster, Sylvia Trondheim, has several spare long range sensor upgrade packages. They were scheduled to be installed on exploration vessels coming into the region, but those exploration missions were cancelled or repurposed. She's willing to install one on %s"),comms_source:getCallSign()))
			if comms_target.sensor_upgrades == nil then
				comms_target.sensor_upgrades = {
					{long = 40000, short = 5000},
					{long = 50000, short = 4500},
					{long = 60000, short = 4000},
				}
			end
			addCommsReply(_("upgrade-comms","Tell me about the Richter version 7 sensor upgrade."),function()
				if comms_target.richter == nil then
					comms_target.richter = tableRemoveRandom(comms_target.sensor_upgrades)
				end
				if comms_target.richter.long > comms_source.normal_long_range_radar then
					setCommsMessage(string.format(_("upgrade-comms","The Richter version 7 sets your long range sensor range to %i units and your short range sensor range to %.1f units."),comms_target.richter.long/1000,comms_target.richter.short/1000))
					addCommsReply(_("upgrade-comms","Please install the Richter version 7 sensor upgrade"),function()
						comms_source.sensor_upgrade = true
						comms_source.normal_long_range_radar = comms_target.richter.long
						comms_source.normal_short_range_radar = comms_target.richter.short
						comms_source:setLongRangeRadarRange(comms_source.normal_long_range_radar)
						comms_source:setShortRangeRadarRange(comms_source.normal_short_range_radar)
						setCommsMessage(_("upgrade-comms","Sylvia has installed the Richter version 7 sensor upgrade"))
						addCommsReply(_("Back"), commsStation)
					end)
				else
					setCommsMessage(_("upgrade-comms","The Richter version 7 would not add any sensor range benefit"))
				end
				addCommsReply(_("Back"), commsStation)
			end)
			addCommsReply(_("upgrade-comms","What about the Omniscient Mark 4 sensor upgrade?"),function()
				if comms_target.omniscient == nil then
					comms_target.omniscient = tableRemoveRandom(comms_target.sensor_upgrades)
				end
				if comms_target.omniscient.long > comms_source.normal_long_range_radar then
					setCommsMessage(string.format(_("upgrade-comms","The Omniscient Mark 4 sets your long range sensor range to %i units and your short range sensor range to %.1f units."),comms_target.omniscient.long/1000,comms_target.omniscient.short/1000))
					addCommsReply(_("upgrade-comms","Please install the Omniscient Mark 4 sensor upgrade"),function()
						comms_source.sensor_upgrade = true
						comms_source.normal_long_range_radar = comms_target.omniscient.long
						comms_source.normal_short_range_radar = comms_target.omniscient.short
						comms_source:setLongRangeRadarRange(comms_source.normal_long_range_radar)
						comms_source:setShortRangeRadarRange(comms_source.normal_short_range_radar)
						setCommsMessage(_("upgrade-comms","Sylvia has installed the Omniscient Mark 4 sensor upgrade"))
						addCommsReply(_("Back"), commsStation)
					end)
				else
					setCommsMessage(_("upgrade-comms","The Omniscient Mark 4 would not add any sensor range benefit"))
				end
				addCommsReply(_("Back"), commsStation)
			end)
			addCommsReply(_("upgrade-comms","Please provide details on the Voriax II sensor upgrade."),function()
				if comms_target.voriax == nil then
					comms_target.voriax = tableRemoveRandom(comms_target.sensor_upgrades)
				end
				if comms_target.voriax.long > comms_source.normal_long_range_radar then
					setCommsMessage(string.format(_("upgrade-comms","The Voriax II sets your long range sensor range to %i units and your short range sensor range to %.1f units."),comms_target.voriax.long/1000,comms_target.voriax.short/1000))
					addCommsReply(_("upgrade-comms","Please install the Voriax II sensor upgrade"),function()
						comms_source.sensor_upgrade = true
						comms_source.normal_long_range_radar = comms_target.voriax.long
						comms_source.normal_short_range_radar = comms_target.voriax.short
						comms_source:setLongRangeRadarRange(comms_source.normal_long_range_radar)
						comms_source:setShortRangeRadarRange(comms_source.normal_short_range_radar)
						setCommsMessage(_("upgrade-comms","Sylvia has installed the Voriax II sensor upgrade"))
						addCommsReply(_("Back"), commsStation)
					end)
				else
					setCommsMessage(_("upgrade-comms","The Voriax II would not add any sensor range benefit"))
				end
				addCommsReply(_("Back"), commsStation)
			end)
			addCommsReply(_("Back"), commsStation)
		end)
	end
end
function scenarioInformation()
	if comms_target.station_knowledge ~= nil then
		addCommsReply(_("areaDescription-comms","What do you know about stations around here?"),function()
			setCommsMessage(comms_target.station_knowledge)
			addCommsReply(_("Back"), commsStation)
		end)
	end
end
function scenarioMissions()
	local reply_count = 0
	if comms_target == home_station then
		if mission_goods ~= nil and #mission_goods > 0 then
			for i,mission_good in ipairs(mission_goods) do
				if not mission_good.delivered then
					addCommsReply(string.format(_("goal-comms","Deliver %s to %s"),mission_good.good,comms_target:getCallSign()),function()
						if comms_source.goods ~= nil then
							if comms_source.goods[mission_good.good] ~= nil then
								if comms_source.goods[mission_good.good] > 0 then
									comms_source:addReputationPoints(50)
									setCommsMessage(string.format(_("goal-comms","You delivered %s."),mission_good.good))
									mission_good.delivered = true
									comms_source:addReputationPoints(10)
									comms_source.goods[mission_good.good] = comms_source.goods[mission_good.good] - 1
								else
									setCommsMessage(string.format(_("goal-comms","You don't have any %s anymore."),mission_good.good))
								end
							else
								setCommsMessage(string.format(_("goal-comms","You don't have any %s."),mission_good.good))
							end
						else
							setCommsMessage(_("goal-comms","You don't have any goods."))
						end
						addCommsReply(_("Back"), commsStation)
					end)
					reply_count = reply_count + 1
				end
			end
		end
	end
	return reply_count
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
function getCurrentOrders()
	local current_orders_prompts = {
		_("orders-comms","Current orders?"),
		_("orders-comms","What are my current orders?"),
		string.format(_("orders-comms","Current orders for %s?"),comms_source:getCallSign()),
		_("orders-comms","Remind me of our current orders, please"),
	}
	addCommsReply(tableRemoveRandom(current_orders_prompts),function()
		setOptionalOrders()
		ordMsg = primary_orders .. "\n" .. optional_orders
		setCommsMessage(ordMsg)
		addCommsReply(_("Back"), commsStation)
	end)
end
function setOptionalOrders()
	optional_orders = ""
	if comms_source.transport_mission ~= nil or comms_source.cargo_mission ~= nil then
		local optional_orders_header = {
			_("orders-comms","\nOptional:"),
			_("orders-comms","\nOptional orders:"),
			_("orders-comms","\nThese orders are optional:"),
			_("orders-comms","\nNot required:"),
		}
		optional_orders = tableRemoveRandom(optional_orders_header)
	end
	if comms_source.transport_mission ~= nil then
		if comms_source.transport_mission.destination ~= nil and comms_source.transport_mission.destination:isValid() then
			optional_orders = string.format(_("orders-comms","%s\nTransport %s to %s station %s in %s"),optional_orders,comms_source.transport_mission.character.name,comms_source.transport_mission.destination:getFaction(),comms_source.transport_mission.destination_name,comms_source.transport_mission.destination:getSectorName())
		else
			optional_orders = string.format(_("orders-comms","%s\nTransport %s to station %s (defunct)"),optional_orders,comms_source.transport_mission.character.name,comms_source.transport_mission.destination_name)
		end
	end
	if comms_source.cargo_mission ~= nil then
		if comms_source.cargo_mission.loaded then
			if comms_source.cargo_mission.destination ~= nil and comms_source.cargo_mission.destination:isValid() then
				optional_orders = string.format(_("orders-comms","%s\nDeliver cargo for %s to station %s in %s"),optional_orders,comms_source.cargo_mission.character.name,comms_source.cargo_mission.destination_name,comms_source.cargo_mission.destination:getSectorName())
			else
				optional_orders = string.format(_("orders-comms","%s\nDeliver cargo for %s to station %s (defunct)"),optional_orders,comms_source.cargo_mission.character.name,comms_source.cargo_mission.destination_name)
			end
		else
			if comms_source.cargo_mission.origin ~= nil and comms_source.cargo_mission.origin:isValid() then
				optional_orders = string.format(_("orders-comms","%s\nPick up cargo for %s at station %s in %s"),optional_orders,comms_source.cargo_mission.character.name,comms_source.cargo_mission.origin_name,comms_source.cargo_mission.origin:getSectorName())
			else
				optional_orders = string.format(_("orders-comms","%s\nPick up cargo for %s at station %s (defunct)"),optional_orders,comms_source.cargo_mission.character.name,comms_source.cargo_mission.origin_name)
			end
		end
	end
	if comms_source.restoration_mission ~= nil then
		if comms_source.restoration_mission.achievement then
			if comms_source.restoration_mission.destination ~= nil and comms_source.restoration_mission.destination:isValid() then
				optional_orders = string.format("%s\n%s",optional_orders,comms_source.restoration_mission.optional_orders_second_half)
			else
				optional_orders = string.format(_("orders-comms","%s\n%s (defunct)"),optional_orders,comms_source.restoration_mission.optional_orders_second_half)
			end
		else
			if comms_source.restoration_mission.origin ~= nil and comms_source.restoration_mission.origin:isValid() then
				optional_orders = string.format("%s\n%s",optional_orders,comms_source.restoration_mission.optional_orders_first_half)
			else
				optional_orders = string.format(_("orders-comms","%s\n%s (defunct)"),optional_orders,comms_source.restoration_mission.optional_orders_first_half)
			end
		end
	end
end
function finalStats()
	local final_message = ""
	if enemy_fighter_fleet ~= nil and #enemy_fighter_fleet < 1 then
		final_message = string.format(_("msgMainscreen","%s\nDefended %s against first Kraylor fighter fleet"),final_message,home_station_name)
	end
	if mission_goods ~= nil then
		local delivered_count = 0
		for i,mission_good in ipairs(mission_goods) do
			if mission_good.delivered then
				delivered_count = delivered_count + 1
			end
		end
		if delivered_count >= #mission_goods then
			final_message = string.format(_("msgMainscreen","%s\nDelivered goods to %s"),final_message,home_station_name)
		elseif delivered_count > 0 then
			final_message = string.format(_("msgMainscreen","%s\nPartial goods delivery to %s"),final_message,home_station_name)
		end
	end
	if phobos_fighters ~= nil and #phobos_fighters < 1 then
		final_message = string.format(_("msgMainscreen","%s\nDefended %s against second Kraylor fighter fleet"),final_message,home_station_name)
	end
	if target_station:isValid() then
		if target_station:getHull() < target_station:getHullMax() then
			final_message = string.format(_("msgMainscreen","%s\nDid some damage to Kraylor station %s's hull"),final_message,target_station:getCallSign())
		end
	else
		final_message = string.format(_("msgMainscreen","%s\nDestroyed Kraylor station"),final_message)
	end
	final_message = string.format(_("msgMainscreen","%s\nTime spent in scenario: %s"),final_message,formatTime(getScenarioTime()))
	final_message = string.format(_("msgMainscreen","%s\nEnemies:%s Murphy:%s"),final_message,getScenarioSetting("Enemies"),getScenarioSetting("Murphy"))
	return final_message
end
function checkMotherReturnees()
	for i,ship in ipairs(mother_returnees) do
		if ship:isValid() then
			if ship.mother ~= nil and ship.mother:isValid() then
				local m_x, m_y = ship.mother:getPosition()
				local s_x, s_y = ship:getPosition()
				if distance(m_x, m_y, s_x, s_y) < 1000 then
					if ship.followers ~= nil then
						for j,follower in ipairs(ship.followers) do
							if follower:isValid() then
								if follower:getOrder() == "Fly in formation" then
									follower:destroy()
									ship.mother.sauv_count = ship.mother.sauv_count + 1
								end
							end
						end
					end
					ship:destroy()
					ship.mother.sauv_count = ship.mother.sauv_count + 1
					mother_returnees[i] = mother_returnees[#mother_returnees]
					mother_returnees[#mother_returnees] = nil
					break
				else
					ship:orderFlyTowards(m_x, m_y)
				end
			end
		else
			mother_returnees[i] = mother_returnees[#mother_returnees]
			mother_returnees[#mother_returnees] = nil
			break
		end
	end
end
function launchSAUV(p)
	local leader = CpuShip():setTemplate("Striker"):setFaction(p:getFaction())
	leader:setImpulseMaxSpeed(80,60)
	local m_x, m_y = p:getPosition()
	local head = p:getHeading()
	local d_x, d_y = vectorFromAngle(head,100,true)
	leader:setPosition(m_x + d_x, m_y + d_y):orderDefendTarget(p)
	leader:setHeading(head):setCommsFunction(commsSAUV)
	leader:setCallSign(string.format("%s SAUV Lead",p:getCallSign()))
	leader:setScannedByFaction(p:getFaction(),true)
	leader.mother = p
	leader.sauv_leader = true
	p.sauv_count = p.sauv_count - 1
	leader.formation_spacing = 1000
	leader.followers = {}
	p.sauvs_launched = true
	if p.sauvs == nil then
		p.sauvs = {}
	end
	table.insert(p.sauvs,leader)
	for i,form in ipairs(fly_formation["X"]) do
		if p.sauv_count > 0 then
			head = head + 72
			local follower = CpuShip():setTemplate("Fighter"):setFaction(p:getFaction())
			d_x, d_y = vectorFromAngle(head,100,true)
			follower:setPosition(m_x + d_x, m_y + d_y):setHeading(head):setCommsFunction(commsSAUV)
			local form_prime_x, form_prime_y = vectorFromAngle(form.angle, form.dist * leader.formation_spacing)
			follower.form_prime_x = form_prime_x
			follower.form_prime_y = form_prime_y
			follower.leader = leader
			follower.mother = p
			follower:orderFlyFormation(leader,form_prime_x,form_prime_y)
			follower:setCallSign(string.format("%s SAUV %s",p:getCallSign(),i))
			follower:setScannedByFaction(p:getFaction(),true)
			table.insert(leader.followers,follower)
			table.insert(p.sauvs,follower)
			p.sauv_count = p.sauv_count - 1
		else
			break
		end
	end
end
function updateSAUVButton(p)
	if p.sauv_launcher then
		if p.sauvs_launched then
			if p.launch_sauv_button_wea ~= nil and p.launch_sauv_button_tac ~= nil then
				p:removeCustom(p.launch_sauv_button_wea)
				p:removeCustom(p.launch_sauv_button_tac)
				p.launch_sauv_button_wea = nil
				p.launch_sauv_button_tac = nil
			end
		else
			if p.sauv_count > 0 then
				p.launch_sauv_button_wea = "launch_sauv_button_wea"
				p:addCustomButton("Weapons",p.launch_sauv_button_wea,_("buttonWeapons","Launch SAUVs"),function()
					string.format("")
					launchSAUV(p)
				end)
				p.launch_sauv_button_tac = "launch_sauv_button_tac"
				p:addCustomButton("Tactical",p.launch_sauv_button_tac,_("buttonTactical","Launch SAUVs"),function()
					string.format("")
					launchSAUV(p)
				end)
			end
		end
		if p.sauvs ~= nil and #p.sauvs > 0 then
			for i,sauv in ipairs(p.sauvs) do
				if sauv == nil or not sauv:isValid() then
					p.sauvs[i] = p.sauvs[#p.sauvs]
					p.sauvs[#p.sauvs] = nil
					break
				end
			end
		else
			p.sauvs_launched = false
		end
	end
end
--	General
function update(delta)
	if delta == 0 then
		if deployed_players ~= nil then
			for i,dp in ipairs(deployed_players) do
				for j,p in ipairs(getActivePlayerShips()) do
					if p == dp.p then
						dp.name = p:getCallSign()
					end
				end
			end
		end
		return	--because the scenario is paused
	end
	for i,p in ipairs(getActivePlayerShips()) do
		updatePlayerLongRangeSensors(delta,p)
		updateSAUVButton(p)
		local name_banner = string.format(_("nameSector-tabRelay&Ops&Helm&Tactical","%s in %s"),p:getCallSign(),p:getSectorName())
		p.name_banner_rel = "name_banner_rel"
		p:addCustomInfo("Relay",p.name_banner_rel,name_banner,1)
		p.name_banner_ops = "name_banner_ops"
		p:addCustomInfo("Operations",p.name_banner_ops,name_banner,1)
		p.name_banner_hlm = "name_banner_hlm"
		p:addCustomInfo("Helms",p.name_banner_hlm,name_banner,1)
		p.name_banner_tac = "name_banner_tac"
		p:addCustomInfo("Tactical",p.name_banner_tac,name_banner,1)
	end
	if home_station ~= nil and home_station:isValid() then
		if missionMaintenance ~= nil then
			missionMaintenance()
		end
		if build_defense_platform then
			buildDefensePlatform()
		end
	else
		local msg = finalStats()
		globalMessage(string.format(_("msgMainscreen","You did not protect your home station.\n%s"),msg))
		victory("Kraylor")
	end
	if #getActivePlayerShips() < 1 then
		local msg = finalStats()
		globalMessage(string.format(_("msgMainscreen","All player ships destroyed.\n%s"),msg))
		victory("Kraylor")
	end
	if not target_station:isValid() and missionMaintenance == atlantisAttackKraylorStation then
		local msg = finalStats()
		globalMessage(string.format(_("msgMainscreen","Kraylor station destroyed.\n%s"),msg))
		victory("Human Navy")
	end
	if mother_returnees ~= nil then
		checkMotherReturnees()
	end
end