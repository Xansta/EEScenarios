-- Name: Rings of Saturn
-- Description: Conduct operations amidst Saturn's rings. Note: Inaccuracies abound. Astronomy classes beware.
---
--- With the default settings, the scenario runs in about half an hour.
---
--- Version 1
---
--- USN Discord: https://discord.gg/PntGG3a where you can join a game online. There's usually one every weekend. All experience levels are welcome. 
-- Type: Mission
-- Author: Xansta (based on ideas from Sushi and Snow)
-- Setting[Enemies]: Configures strength and/or number of enemies in this scenario
-- Enemies[Easy]: Fewer or weaker enemies
-- Enemies[Normal|Default]: Normal number or strength of enemies
-- Enemies[Hard]: More or stronger enemies
-- Enemies[Extreme]: Much stronger, many more enemies
-- Enemies[Quixotic]: Insanely strong and/or inordinately large numbers of enemies
-- Setting[Rings]: Configures how fast the asteroids move when orbiting Saturn in rings. Default is normal
-- Rings[Molasses]: Asteroids orbit in rings very slowly
-- Rings[Slow]: Asteroids orbit in rings slowly
-- Rings[Normal|Default]: Asteroids orbit in rings normally
-- Rings[Fast]: Asteroids orbit in rings quickly
-- Rings[Blazing]: Asteroids orbit in rings very quickly
-- Setting[Inbound]: Configures how much time is given for the inbound mission. Default is 7 minutes
-- Inbound[10]: Ten minutes are given for the inbound mission
-- Inbound[7|Default]: Seven minutes are given for the inbound mission
-- Inbound[5]: Five minutes are given for the inbound mission
-- Inbound[3]: Three minutes are given for the inbound mission
-- Inbound[2]: Two minutes are given for the inbound mission
-- Setting[Outbound]: Configures how much time is given for the outbound mission. Default is 5 minutes
-- Outbound[10]: Ten minutes are given for the outbound mission
-- Outbound[7]: Seven minutes are given for the outbound mission
-- Outbound[5|Default]: Five minutes are given for the outbound mission
-- Outbound[3]: Three minutes are given for the outbound mission
-- Outbound[2]: Two minutes are given for the outbound mission

require("utils.lua")
require("place_station_scenario_utility.lua")
require("cpu_ship_diversification_scenario_utility.lua")
require("generate_call_sign_scenario_utility.lua")
require("comms_scenario_utility.lua")

--	Initialization
function init()
	scenario_version = "1.0.1"
	ee_version = "2024.12.08"
	print(string.format("    ----    Scenario: Saturn Frogger    ----    Version %s    ----    Tested with EE version %s    ----",scenario_version,ee_version))
	if _VERSION ~= nil then
		print("Lua version:",_VERSION)
	end
	setConstants()
	setGlobals()
	setVariations()
	constructEnvironment()
	onNewPlayerShip(setPlayers)
	missionMaintenance = startInitialMission
end
function setConstants()
	relative_strength = 1
	system_types = {"reactor","beamweapons","missilesystem","maneuver","impulse","warp","jumpdrive","frontshield","rearshield"}
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
	player_respawns = false
	player_respawn_max = 0
	deployed_player_count = 0
	deployed_players = {}
	player_ship_stats = {	
		["MP52 Hornet"] 		= { strength = 7, 	cargo = 3,	distance = 100,	long_range_radar = 18000, short_range_radar = 4000, probes = 8,	tractor = false,	mining = false	},
		["Piranha"]				= { strength = 16,	cargo = 8,	distance = 200,	long_range_radar = 25000, short_range_radar = 6000, probes = 8,	tractor = false,	mining = false	},
		["Flavia P.Falcon"]		= { strength = 13,	cargo = 15,	distance = 200,	long_range_radar = 40000, short_range_radar = 5000, probes = 8,	tractor = true,		mining = true	},
		["Phobos M3P"]			= { strength = 19,	cargo = 10,	distance = 200,	long_range_radar = 25000, short_range_radar = 5000, probes = 8,	tractor = true,		mining = false	},
		["Atlantis"]			= { strength = 52,	cargo = 6,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, probes = 8,	tractor = true,		mining = true	},
		["Player Cruiser"]		= { strength = 40,	cargo = 6,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, probes = 8,	tractor = false,	mining = false	},
		["Player Missile Cr."]	= { strength = 45,	cargo = 8,	distance = 200,	long_range_radar = 35000, short_range_radar = 6000, probes = 8,	tractor = false,	mining = false	},
		["Player Fighter"]		= { strength = 7,	cargo = 3,	distance = 100,	long_range_radar = 15000, short_range_radar = 4500, probes = 8,	tractor = false,	mining = false	},
		["Benedict"]			= { strength = 10,	cargo = 9,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, probes = 8,	tractor = true,		mining = true	},
		["Kiriya"]				= { strength = 10,	cargo = 9,	distance = 400,	long_range_radar = 35000, short_range_radar = 5000, probes = 8,	tractor = true,		mining = true	},
		["Striker"]				= { strength = 8,	cargo = 4,	distance = 200,	long_range_radar = 35000, short_range_radar = 5000, probes = 8,	tractor = false,	mining = false	},
		["ZX-Lindworm"]			= { strength = 8,	cargo = 3,	distance = 100,	long_range_radar = 18000, short_range_radar = 5500, probes = 8,	tractor = false,	mining = false	},
		["Repulse"]				= { strength = 14,	cargo = 12,	distance = 200,	long_range_radar = 38000, short_range_radar = 5000, probes = 8,	tractor = true,		mining = false	},
		["Ender"]				= { strength = 100,	cargo = 20,	distance = 2000,long_range_radar = 45000, short_range_radar = 7000, probes = 8,	tractor = true,		mining = false	},
		["Nautilus"]			= { strength = 12,	cargo = 7,	distance = 200,	long_range_radar = 22000, short_range_radar = 4000, probes = 8,	tractor = false,	mining = false	},
		["Hathcock"]			= { strength = 30,	cargo = 6,	distance = 200,	long_range_radar = 35000, short_range_radar = 6000, probes = 8,	tractor = false,	mining = true	},
		["Maverick"]			= { strength = 45,	cargo = 5,	distance = 200,	long_range_radar = 20000, short_range_radar = 4000, probes = 8,	tractor = false,	mining = true	},
		["Crucible"]			= { strength = 45,	cargo = 5,	distance = 200,	long_range_radar = 20000, short_range_radar = 6000, probes = 8,	tractor = false,	mining = false	},
		["Proto-Atlantis"]		= { strength = 40,	cargo = 4,	distance = 400,	long_range_radar = 30000, short_range_radar = 4500, probes = 8,	tractor = false,	mining = true	},
		["Saipan"]				= { strength = 30,	cargo = 4,	distance = 200,	long_range_radar = 25000, short_range_radar = 4500, probes = 10,tractor = false,	mining = false	},
		["Stricken"]			= { strength = 40,	cargo = 4,	distance = 200,	long_range_radar = 20000, short_range_radar = 4000, probes = 8,	tractor = false,	mining = false	},
		["Surkov"]				= { strength = 35,	cargo = 6,	distance = 200,	long_range_radar = 35000, short_range_radar = 6000, probes = 8,	tractor = false,	mining = false	},
		["Redhook"]				= { strength = 11,	cargo = 8,	distance = 200,	long_range_radar = 20000, short_range_radar = 6000, probes = 8,	tractor = false,	mining = false	},
		["Pacu"]				= { strength = 18,	cargo = 7,	distance = 200,	long_range_radar = 20000, short_range_radar = 6000, probes = 8,	tractor = false,	mining = false	},
		["Phobos T2"]			= { strength = 19,	cargo = 9,	distance = 200,	long_range_radar = 25000, short_range_radar = 5000, probes = 8,	tractor = true,		mining = false	},
		["Wombat"]				= { strength = 13,	cargo = 3,	distance = 100,	long_range_radar = 18000, short_range_radar = 6000, probes = 8,	tractor = false,	mining = false	},
		["Holmes"]				= { strength = 35,	cargo = 6,	distance = 200,	long_range_radar = 35000, short_range_radar = 4000, probes = 8,	tractor = true,		mining = false	},
		["Focus"]				= { strength = 35,	cargo = 4,	distance = 200,	long_range_radar = 32000, short_range_radar = 5000, probes = 8,	tractor = false,	mining = true	},
		["Flavia 2C"]			= { strength = 25,	cargo = 12,	distance = 200,	long_range_radar = 30000, short_range_radar = 5000, probes = 8,	tractor = false,	mining = true	},
		["Destroyer IV"]		= { strength = 25,	cargo = 5,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, probes = 8,	tractor = false,	mining = false	},
		["Destroyer III"]		= { strength = 25,	cargo = 7,	distance = 200,	long_range_radar = 30000, short_range_radar = 5000, probes = 8,	tractor = false,	mining = false	},
		["MX-Lindworm"]			= { strength = 10,	cargo = 3,	distance = 100,	long_range_radar = 30000, short_range_radar = 5000, probes = 8,	tractor = false,	mining = false	},
		["Striker LX"]			= { strength = 16,	cargo = 4,	distance = 200,	long_range_radar = 20000, short_range_radar = 4000, probes = 8,	tractor = false,	mining = false	},
		["Maverick XP"]			= { strength = 23,	cargo = 5,	distance = 200,	long_range_radar = 25000, short_range_radar = 7000, probes = 8,	tractor = true,		mining = false	},
		["Era"]					= { strength = 14,	cargo = 14,	distance = 200,	long_range_radar = 50000, short_range_radar = 5000, probes = 8,	tractor = true,		mining = true	},
		["Squid"]				= { strength = 14,	cargo = 8,	distance = 200,	long_range_radar = 25000, short_range_radar = 5000, probes = 8,	tractor = false,	mining = false	},
		["Atlantis II"]			= { strength = 60,	cargo = 6,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, probes = 8,	tractor = true,		mining = true	},
	}
	player_ship_names_for = {
		["Atlantis"] =			{"Excaliber","Thrasher","Punisher","Vorpal","Protang","Drummond","Parchim","Coronado"},
		["Atlantis II"] =		{"Spyder", "Shelob", "Tarantula", "Aragog", "Charlotte"},
		["Benedict"] =			{"Elizabeth","Ford","Vikramaditya","Liaoning","Avenger","Naruebet","Washington","Lincoln","Garibaldi","Eisenhower"},
		["Crucible"] =			{"Sling", "Stark", "Torrid", "Kicker", "Flummox"},
		["Ender"] =				{"Mongo","Godzilla","Leviathan","Kraken","Jupiter","Saturn"},
		["Flavia P.Falcon"] =	{"Ladyhawke","Hunter","Seeker","Gyrefalcon","Kestrel","Magpie","Bandit","Buccaneer"},
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
		["Striker"] =			{"Sparrow","Sizzle","Squawk","Crow","Phoenix","Snowbird","Hawk"},
		["Surkov"] =			{"Sting", "Sneak", "Bingo", "Thrill", "Vivisect"},
		["ZX-Lindworm"] =		{"Seagull","Catapult","Blowhard","Flapper","Nixie","Pixie","Tinkerbell"},
		["Leftovers"] =			{"Foregone","Righteous","Scandalous"},
	}
	stations = {}
	messages = {}
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
end
function setVariations()
	local enemy_config = {
		["Easy"] =		{number = .5},
		["Normal"] =	{number = 1},
		["Hard"] =		{number = 2},
		["Extreme"] =	{number = 3},
		["Quixotic"] =	{number = 5},
	}
	enemy_power =	enemy_config[getScenarioSetting("Enemies")].number
	local inbound_config = {
		["10"] =	{number = 10*60,	},
		["7"] =		{number = 7*60,		},
		["5"] =		{number = 5*60,		},
		["3"] =		{number = 3*60,		},
		["2"] =		{number = 2*60,		},
	}
	frogger_in_timer = inbound_config[getScenarioSetting("Inbound")].number
	local outbound_config = {
		["10"] =	{number = 10*60,	},
		["7"] =		{number = 7*60,		},
		["5"] =		{number = 5*60,		},
		["3"] =		{number = 3*60,		},
		["2"] =		{number = 2*60,		},
	}
	frogger_out_timer = outbound_config[getScenarioSetting("Outbound")].number
	rings_config = {
		["Molasses"] =	{lo = 15,	hi = 20,	},
		["Slow"] =		{lo = 10,	hi = 20,	},
		["Normal"] =	{lo = 1,	hi = 20,	},
		["Fast"] =		{lo = 1,	hi = 5,		},
		["Blazing"] =	{lo = .25,	hi = 2,		},
	}
	orbit_speed_lo = rings_config[getScenarioSetting("Rings")].lo
	orbit_speed_hi = rings_config[getScenarioSetting("Rings")].hi
end
--	Terrain
function constructEnvironment()
	center_x = 100000
	center_y = -50
    planet_saturn = Planet():setPosition(center_x, center_y)
    	:setPlanetRadius(12000)
    	:setPlanetSurfaceTexture("planets/gas-3.png")
    	:setPlanetAtmosphereTexture("planets/atmosphere.png")
    	:setPlanetAtmosphereColor(0.50,0.50,0.70)
    	:setAxialRotationTime(500.00)
    	:setDistanceFromMovementPlane(-1200)
    local moon_x, moon_y = vectorFromAngle(random(0,360),17000,true)
    moon_x = moon_x + center_x
    moon_y = moon_y + center_y
    moon_rhea = Planet():setPosition(moon_x, moon_y)
    	:setPlanetRadius(1527)
    	:setPlanetSurfaceTexture("planets/moon-1.png")
    	:setPlanetAtmosphereColor(random(0,1),random(0,1),random(0,1))
    	:setAxialRotationTime(random(400,600))
    	:setDistanceFromMovementPlane(1500)
    	:setOrbit(planet_saturn,500)
    	:setCallSign("Rhea")
    local psx, psy = vectorFromAngle(random(0,360),20000,true)
    hq_station = placeStation(psx + center_x, psy + center_y,"RandomHumanNeutral","Human Navy")
    hq_station:setShortRangeRadarRange(10000 + random(0,5000))
    table.insert(stations,hq_station)
    moon_x, moon_y = vectorFromAngle(random(0,360),25000,true)
    moon_x = moon_x + center_x
    moon_y = moon_y + center_y
    moon_mimas = Planet():setPosition(moon_x, moon_y)
    	:setPlanetRadius(396)
    	:setPlanetSurfaceTexture("planets/moon-2.png")
    	:setPlanetAtmosphereColor(random(0,1),random(0,1),random(0,1))
    	:setAxialRotationTime(random(400,600))
    	:setDistanceFromMovementPlane(-400)
    	:setOrbit(planet_saturn,700)
    	:setCallSign("Mimas")
--	set up rings of asteroids
    orbiting_asteroids = {}
    local belt_density = 100
	for i=1,10 do
		ring_boundary = {
			{lo = 30000, hi = 35000},
			{lo = 35000, hi = 40000},
			{lo = 40000, hi = 45000},
			{lo = 45000, hi = 50000},
			{lo = 50000, hi = 55000},
			{lo = 55000, hi = 60000},
			{lo = 65000, hi = 70000},
			{lo = 70000, hi = 75000},
			{lo = 80000, hi = 85000},
			{lo = 85000, hi = 90000},
		}
		local orbit_speed = random(orbit_speed_lo,orbit_speed_hi)
		local angle = random(0,360)
		local lo = ring_boundary[i].lo
		local hi = ring_boundary[i].hi
		local dist = (lo + hi)/2
		local wx, wy = vectorFromAngle(angle,dist,true)
		local wj = WarpJammer()
		wj.x = wx + center_x
		wj.y = wy + center_y
		wj:setPosition(wj.x, wj.y):setRange(random(10000,20000))
		wj.angle = angle
		wj.orbit_speed = orbit_speed	
		wj.dist = dist
		table.insert(orbiting_asteroids,wj)
		for j=1,belt_density + i * 10 do
			angle = random(0,360)
			dist = random(lo,hi)
			local ax, ay = vectorFromAngle(angle,dist,true)
			local a = Asteroid()
			a.x = ax + center_x
			a.y = ay + center_y
			local max_size = math.min(dist - lo, hi - dist)
			local a_size = math.min(max_size,random(1,100) + random(1,100) + random(1,100) + random(1,100) + random(1,100) + random(1,100) + random(1,100) + random(1,100) + random(1,100) + random(1,100))
			a:setPosition(a.x, a.y):setSize(a_size)
			a.angle = angle
			a.orbit_speed = orbit_speed
			a.dist = dist
			table.insert(orbiting_asteroids,a)
		end		
	end
    moon_x, moon_y = vectorFromAngle(random(0,360),63000,true)
    moon_x = moon_x + center_x
    moon_y = moon_y + center_y
    moon_prometheus = Planet():setPosition(moon_x, moon_y)
    	:setPlanetRadius(385)
    	:setPlanetSurfaceTexture("planets/moon-3.png")
    	:setPlanetAtmosphereColor(random(0,1),random(0,1),random(0,1))
    	:setAxialRotationTime(random(400,600))
    	:setDistanceFromMovementPlane(-800)
    	:setOrbit(planet_saturn,700)
    	:setCallSign("Prometheus")
    local moon_angle = random(0,360)
    moon_x, moon_y = vectorFromAngle(moon_angle,77500,true)
    moon_x = moon_x + center_x
    moon_y = moon_y + center_y
    moon_epimetheus = Planet():setPosition(moon_x, moon_y)
    	:setPlanetRadius(1117)
    	:setPlanetSurfaceTexture("planets/moon-1.png")
    	:setPlanetAtmosphereColor(random(0,1),random(0,1),random(0,1))
    	:setAxialRotationTime(random(400,600))
    	:setDistanceFromMovementPlane(300)
    	:setOrbit(planet_saturn,5700)
    	:setCallSign("Epimetheus")
    local es_x, es_y = vectorFromAngle(moon_angle + 90,2000,true)
    epimetheus_station = placeStation(moon_x + es_x, moon_y + es_y,"RandomHumanNeutral","Human Navy")
    epimetheus_station:setShortRangeRadarRange(10000 + random(0,5000))
    epimetheus_station_name = epimetheus_station:getCallSign()
    table.insert(stations,epimetheus_station)
    moon_x, moon_y = vectorFromAngle(random(0,360),108000,true)
    moon_x = moon_x + center_x
    moon_y = moon_y + center_y
    moon_janus = Planet():setPosition(moon_x, moon_y)
    	:setPlanetRadius(1178)
    	:setPlanetSurfaceTexture("planets/moon-2.png")
    	:setPlanetAtmosphereColor(random(0,1),random(0,1),random(0,1))
    	:setAxialRotationTime(random(400,600))
    	:setDistanceFromMovementPlane(-300)
    	:setOrbit(planet_saturn,3700)
    	:setCallSign("Janus")
    moon_x, moon_y = vectorFromAngle(random(0,360),112000,true)
    moon_x = moon_x + center_x
    moon_y = moon_y + center_y
    moon_enceladus = Planet():setPosition(moon_x, moon_y)
    	:setPlanetRadius(1504)
    	:setPlanetSurfaceTexture("planets/moon-3.png")
    	:setPlanetAtmosphereColor(random(0,1),random(0,1),random(0,1))
    	:setAxialRotationTime(random(400,600))
    	:setDistanceFromMovementPlane(400)
    	:setOrbit(planet_saturn,4700)
    	:setCallSign("Enceladus")
    moon_x, moon_y = vectorFromAngle(random(0,360),117000,true)
    moon_x = moon_x + center_x
    moon_y = moon_y + center_y
    moon_tethys = Planet():setPosition(moon_x, moon_y)
    	:setPlanetRadius(1062)
    	:setPlanetSurfaceTexture("planets/moon-1.png")
    	:setPlanetAtmosphereColor(random(0,1),random(0,1),random(0,1))
    	:setAxialRotationTime(random(400,600))
    	:setDistanceFromMovementPlane(500)
    	:setOrbit(planet_saturn,2500)
    	:setCallSign("Tethys")
    moon_x, moon_y = vectorFromAngle(random(0,360),121000,true)
    moon_x = moon_x + center_x
    moon_y = moon_y + center_y
    moon_dione = Planet():setPosition(moon_x, moon_y)
    	:setPlanetRadius(1123)
    	:setPlanetSurfaceTexture("planets/moon-2.png")
    	:setPlanetAtmosphereColor(random(0,1),random(0,1),random(0,1))
    	:setAxialRotationTime(random(400,600))
    	:setDistanceFromMovementPlane(-1100)
    	:setOrbit(planet_saturn,6500)
    	:setCallSign("Dione")
    moon_x, moon_y = vectorFromAngle(random(0,360),130000,true)
    moon_x = moon_x + center_x
    moon_y = moon_y + center_y
    moon_titan = Planet():setPosition(moon_x, moon_y)
    	:setPlanetRadius(5149)
    	:setPlanetSurfaceTexture("planets/moon-3.png")
    	:setPlanetAtmosphereColor(random(0,1),random(0,1),random(0,1))
    	:setAxialRotationTime(random(400,600))
    	:setDistanceFromMovementPlane(-1600)
    	:setOrbit(planet_saturn,12000)
    	:setCallSign("Titan")
    titan_station = placeStation(moon_x + 5000, moon_y + 5000,"RandomHumanNeutral","Human Navy")
    titan_station_name = titan_station:getCallSign()
    table.insert(stations,titan_station)
end
--	Players
function setPlayers()
	for i,p in ipairs(getActivePlayerShips()) do
		if p.shipScore == nil then
			updatePlayerSoftTemplate(p)
			deployed_player_count = deployed_player_count + 1
		end
		local already_recorded = false
		for j,dp in ipairs(deployed_players) do
			if p == dp.p then
				already_recorded = true
				break
			end
		end
		if not already_recorded then
			table.insert(deployed_players,{p=p,name=p:getCallSign(),count=1,template=p:getTypeName()})
		end
	end
end
function updatePlayerSoftTemplate(p)
	--set defaults for those ships not found in the list
	p.shipScore = 24
	p.maxCargo = 5
	p.cargo = p.maxCargo
	p.tractor = false
	p.tractor_target_lock = false
	p.mining = false
	p.goods = {}
	p:setFaction("Human Navy")
	p:onDestroyed(playerDestroyed)
	p:onDestruction(playerDestruction)
	local temp_type_name = p:getTypeName()
	if temp_type_name ~= nil then
		local p_stat = player_ship_stats[temp_type_name]
		if p_stat ~= nil then
			p.maxCargo = p_stat.cargo
			p.cargo = p.maxCargo
			p:setMaxScanProbeCount(p_stat.probes)
			p:setScanProbeCount(p:getMaxScanProbeCount())
			p:setLongRangeRadarRange(player_ship_stats[temp_type_name].long_range_radar)
			p:setShortRangeRadarRange(player_ship_stats[temp_type_name].short_range_radar)
			p.normal_long_range_radar = player_ship_stats[temp_type_name].long_range_radar
			p.tractor = p_stat.tractor
			p.tractor_target_lock = false
			p.mining = p_stat.mining
			if temp_type_name == "MP52 Hornet" then
				p:setWarpDrive(true)
				p:setWarpSpeed(900)
			elseif temp_type_name == "ZX-Lindworm" then
				p:setWarpDrive(true)
				p:setWarpSpeed(850)
			elseif temp_type_name == "Striker" then
				p:setJumpDrive(true)
				p:setJumpDriveRange(3000,40000)
				p:setImpulseMaxSpeed(90)
			elseif temp_type_name == "Phobos M3P" then
				p:setWarpDrive(true)
				p:setWarpSpeed(800)
			elseif temp_type_name == "Player Fighter" then
				p:setJumpDrive(true)
				p:setJumpDriveRange(3000,40000)
			end
			if p.name_set == nil then
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
				p.name_set = true
			end
			p.score_settings_source = temp_type_name
		else
			addGMMessage(string.format("Player ship %s's template type (%s) could not be found in table player_ship_stats",p:getCallSign(),temp_type_name))
		end
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
	local tube_count = p:getWeaponTubeCount()
	if tube_count > 0 then
		p.healthyMissile = 1.0
		p.prevMissile = 1.0
		local size_letter = {
			["small"] = 	"S",
			["medium"] =	"M",
			["large"] =		"L",
		}
		p.tube_size = ""
		for i=1,tube_count do
			p.tube_size = p.tube_size .. size_letter[p:getTubeSize(i-1)]
		end
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
	p.normal_coolant_rate = {}
	p.normal_power_rate = {}
	for _, system in ipairs(system_types) do
		p.normal_coolant_rate[system] = p:getSystemCoolantRate(system)
		p.normal_power_rate[system] = p:getSystemPowerRate(system)
	end
end
function playerDestroyed()
	string.format("")
end
function playerDestruction(self,instigator)
	string.format("")
	for i,dp in ipairs(deployed_players) do
		if self == dp.p then
			if dp.count > player_respawn_max then
				globalMessage(string.format(_("msgMainscreen","%s has been destroyed."),self:getCallSign()))
			else
				local respawned_player = PlayerSpaceship():setTemplate(self:getTypeName()):setFaction("Human Navy")
				dp.p = respawned_player
				dp.count = dp.count + 1
				respawned_player:setCallSign(string.format("%s %i",dp.name,dp.count))
				respawned_player.name_set = true
				respawned_player.individual_mission = self.individual_mission
				updatePlayerSoftTemplate(respawned_player)
				globalMessage(string.format(_("msgMainscreen","The Human Navy has respawned %s to replace %s."),respawned_player:getCallSign(),self:getCallSign()))
				self:transferPlayersToShip(respawned_player)
			end
			break
		end
	end
end
--	Missions
function startInitialMission()
	local t_x, t_y = titan_station:getPosition()
	local players_to_titan_distance = distance(0, 0, t_x, t_y)
	local enemy_angle = angleHeading(center_x, center_y, t_x, t_y)
	local divisor = {
		["Small Station"] = 3,
		["Medium Station"] = 4,
		["Large Station"] = 5,
		["Huge Station"] = 6,
	}
	local enemy_distance = math.min(30000,players_to_titan_distance / divisor[titan_station:getTypeName()])
	local enemy_x, enemy_y = vectorFromAngle(enemy_angle,enemy_distance,true)
	local fleet = spawnRandomArmed(enemy_x + t_x, enemy_y + t_y)
	attack_titan_fleet = {}
	for i,ship in ipairs(fleet) do
		ship:orderFlyTowards(t_x, t_y)
		table.insert(attack_titan_fleet,ship)
	end
	missionMaintenance = attackTitanStation
end
function attackTitanStation()
	if attack_titan_station_time == nil then
		attack_titan_station_time = getScenarioTime() + 10
	end
	if getScenarioTime() > attack_titan_station_time then
		if cleanList(attack_titan_fleet) then
			if #attack_titan_fleet > 0 then
				for i,ship in ipairs(attack_titan_fleet) do
					local t_x, t_y = titan_station:getPosition()
					if distance(t_x, t_y, ship) < 5000 then
						ship:orderRoaming()
					else
						ship:orderFlyTowards(t_x, t_y)
					end
				end
			else
				local player_message = string.format(_("goal-incCall","The conflict with the Kraylor caused numerous injuries. The medical facilities on %s cannot handle several of the injured. Dock with %s to pick up injured personnel."),titan_station:getCallSign(),titan_station:getCallSign())
				table.insert(messages,{msg=player_message,list={}})
				local messages_index = #messages
				for i,p in ipairs(getActivePlayerShips()) do
					p.individual_mission = "dock with titan to get injured people"
					table.insert(messages[messages_index].list,p)
				end
				primary_orders = string.format(_("orders-comms","Dock with station %s."),titan_station:getCallSign())
				missionMaintenance = froggerIn
			end
			attack_titan_station_time = nil
		end
	end
end
function froggerIn()
	local waiting_counter = 0
	for i,p in ipairs(getActivePlayerShips()) do
		if p.individual_mission == "dock with titan to get injured people" then
			if p:isDocked(titan_station) then
				p.individual_mission = "dock with hq to drop injured people"
				p.frogger_in_time = getScenarioTime() + frogger_in_timer
				local player_message = string.format(_("goal-incCall","Several injured people are now on your ship. Take them to station %s in sector %s for medical treatment. Be careful of the asteroid rings. Look out for the warp jammers in the rings."),hq_station:getCallSign(),hq_station:getSectorName())
				table.insert(messages,{msg=player_message,list={p}})
			end
		end
		if p.individual_mission == "dock with hq to drop injured people" then
			if p:isDocked(hq_station) then
				p.individual_mission = "wait for other players"
				local player_message = string.format(_("goal-incCall","The injured personnel have been transferred to the medical bay on station %s for treatment."),hq_station:getCallSign())
				table.insert(messages,{msg=player_message,list={p}})
				for i,dp in ipairs(deployed_players) do
					if dp.p == p then
						dp.remaining_injured_drop_time = p.frogger_in_time - getScenarioTime()
						break
					end
				end
				p:removeCustom(p.injured_banner_timer_hlm)
				p:removeCustom(p.injured_banner_timer_tac)
			else
				if getScenarioTime() > p.frogger_in_time then
					local final_message = string.format(_("msgMainscreen","The injured on %s did not get to %s before dying.\nThe Human Navy is disgraced."),p:getCallSign(),hq_station:getCallSign())
					final_message = string.format("%s\n%s",final_message,finalStats())
					globalMessage(final_message)
					victory("Kraylor")
				else
					p.injured_banner_timer_hlm = "injured_banner_timer_hlm"
					p.injured_banner_timer_tac = "injured_banner_timer_tac"
					p:addCustomInfo("Helms",p.injured_banner_timer_hlm,string.format(_("tabHelm","Fatality: %s"),formatTime(p.frogger_in_time - getScenarioTime())),11)
					p:addCustomInfo("Tactical",p.injured_banner_timer_tac,string.format(_("tabTactical","Fatality: %s"),formatTime(p.frogger_in_time - getScenarioTime())),11)
				end
			end
		end
		if p.individual_mission == "wait for other players" then
			waiting_counter = waiting_counter + 1
		end
	end
	if waiting_counter == #getActivePlayerShips() then
		local player_message = string.format(_("goal-incCall","You picked up some highly dangerous pathogens from the injured personnel that you just delivered. Dock with %s to decontaminate your ship. %s is currently in sector %s."),epimetheus_station:getCallSign(),epimetheus_station:getCallSign(),epimetheus_station:getSectorName())
		table.insert(messages,{msg=player_message,list={}})
		local messages_index = #messages
		for i,p in ipairs(getActivePlayerShips()) do
			table.insert(messages[messages_index].list,p)
		end
		primary_orders = string.format(_("orders-comms","Dock with station %s."),epimetheus_station:getCallSign())
		frogger_out_time = getScenarioTime() + frogger_out_timer
		missionMaintenance = froggerOut
	end
end
function froggerOut()
	local players_docked_counter = 0
	if getScenarioTime() > frogger_out_time then
		local final_message = ""
		if #getActivePlayerShips() > 1 then
			final_message = string.format(_("msgMainscreen","All player ships did not reach %s in time.\nContamination runs rampant through the Human Navy.\nAll die a hideous death."),epimetheus_station:getCallSign())
		else
			final_message = string.format(_("msgMainscreen","%s did not reach %s in time.\nContamination runs rampant through the Human Navy.\nAll die a hideous death."),getPlayerShip(-1):getCallSign(),epimetheus_station:getCallSign())
		end
		final_message = string.format("%s\n%s",final_message,finalStats())
		globalMessage(final_message)
		victory("Kraylor")
	end
	for i,p in ipairs(getActivePlayerShips()) do
		if p:isDocked(epimetheus_station) and not p.docked_to_epimetheus_in_frogger_out_mission then
			local player_message = string.format(_("goal-incCall","%s has been decontaminated."),p:getCallSign())
			table.insert(messages,{msg=player_message,list={p}})
			p:removeCustom(p.decontamination_banner_timer_hlm)
			p:removeCustom(p.decontamination_banner_timer_tac)
			p.docked_to_epimetheus_in_frogger_out_mission = true
		else
			p.decontamination_banner_timer_hlm = "decontamination_banner_timer_hlm"
			p.decontamination_banner_timer_tac = "decontamination_banner_timer_tac"
			p:addCustomInfo("Helms",p.decontamination_banner_timer_hlm,string.format(_("tabHelm","Contamination: %s"),formatTime(frogger_out_time - getScenarioTime())),11)
			p:addCustomInfo("Tactical",p.decontamination_banner_timer_tac,string.format(_("tabTactical","Contamination: %s"),formatTime(frogger_out_time - getScenarioTime())),11)
			remaining_decontamination_drop_time = frogger_out_time - getScenarioTime()
		end
		if p.docked_to_epimetheus_in_frogger_out_mission then
			players_docked_counter = players_docked_counter + 1
		end
	end
	if players_docked_counter == #getActivePlayerShips() then
		local player_message = string.format(_("goal-incCall","All ships decontaminated. The Kraylor have returned to attack %s again. Please defend %s, currently in sector %s."),titan_station:getCallSign(),titan_station:getCallSign(),titan_station:getSectorName())
		table.insert(messages,{msg=player_message,list={}})
		local messages_index = #messages
		for i,p in ipairs(getActivePlayerShips()) do
			table.insert(messages[messages_index].list,p)
		end
		primary_orders = string.format(_("orders-comms","Protect station %s."),titan_station:getCallSign())
		local t_x, t_y = titan_station:getPosition()
		local players_to_titan_distance = 0
		for i,p in ipairs(getActivePlayerShips()) do
			local p_x, p_y = p:getPosition()
			players_to_titan_distance = players_to_titan_distance + distance(t_x, t_y, p_x, p_y)
		end
		players_to_titan_distance = players_to_titan_distance/#getActivePlayerShips()
		local enemy_angle = angleHeading(center_x, center_y, t_x, t_y)
		local divisor = {
			["Small Station"] = 3,
			["Medium Station"] = 4,
			["Large Station"] = 5,
			["Huge Station"] = 6,
		}
		local enemy_distance = math.min(40000,players_to_titan_distance / divisor[titan_station:getTypeName()])
		local enemy_x, enemy_y = vectorFromAngle(enemy_angle,enemy_distance,true)
		relative_strength = 2
		local fleet = spawnRandomArmed(enemy_x + t_x, enemy_y + t_y)
		for i,ship in ipairs(fleet) do
			ship:orderFlyTowards(t_x, t_y)
			table.insert(attack_titan_fleet,ship)
		end
		missionMaintenance = rescueTitan
	end
end
function rescueTitan()
	if attack_titan_station_time == nil then
		attack_titan_station_time = getScenarioTime() + 10
	end
	if getScenarioTime() > attack_titan_station_time then
		if cleanList(attack_titan_fleet) then
			if #attack_titan_fleet > 0 then
				local t_x, t_y = titan_station:getPosition()
				for i,ship in ipairs(attack_titan_fleet) do
					if distance(t_x, t_y, ship) < 5000 then
						ship:orderRoaming()
					else
						ship:orderFlyTowards(t_x, t_y)
					end
				end
			else
				local final_message = string.format(_("msgMainscreen","You defeated the Kraylor attacking %s!"),titan_station:getCallSign())
				final_message = string.format("%s\n%s",final_message,finalStats())
				globalMessage(final_message)
				victory("Human Navy")
			end
			attack_titan_station_time = nil
		end
	end
end
function finalStats()
	local final_message = ""
	if deployed_player_count > 1 then
		final_message = string.format(_("msgMainscreen","%s\nDeployed %s player ships."),final_message,deployed_player_count)
	else
		final_message = string.format(_("msgMainscreen","%s\nDeployed one player ship."),final_message)
	end
	local remaining_inbound_by_player = ""
	for i,dp in ipairs(deployed_players) do
		if dp.remaining_injured_drop_time ~= nil then
			remaining_inbound_by_player = string.format("%s\n%s - %s",remaining_inbound_by_player,dp.name,formatTime(dp.remaining_injured_drop_time))
		end
	end
	if remaining_inbound_by_player ~= "" then
		if #deployed_players > 1 then
			if getScenarioSetting("Inbound") == "1" then
				final_message = string.format(_("msgMainscreen","%s\nInbound time remaining out of %s minute per player ship%s"),final_message,getScenarioSetting("Inbound"),remaining_inbound_by_player)
			else
				final_message = string.format(_("msgMainscreen","%s\nInbound time remaining out of %s minutes per player ship%s"),final_message,getScenarioSetting("Inbound"),remaining_inbound_by_player)
			end
		else
			if getScenarioSetting("Inbound") == "1" then
				final_message = string.format(_("msgMainscreen","%s\nInbound time remaining out of %s minute %s"),final_message,getScenarioSetting("Inbound"),remaining_inbound_by_player)
			else
				final_message = string.format(_("msgMainscreen","%s\nInbound time remaining out of %s minutes %s"),final_message,getScenarioSetting("Inbound"),remaining_inbound_by_player)
			end
		end
	end
	if remaining_decontamination_drop_time ~= nil then
		if getScenarioSetting("Outbound") == "1" then
			final_message = string.format(_("msgMainscreen","%s\nOutbound time remaining out of %s minute - %s"),final_message,getScenarioSetting("Outbound"),formatTime(remaining_decontamination_drop_time))
		else
			final_message = string.format(_("msgMainscreen","%s\nOutbound time remaining out of %s minutes - %s"),final_message,getScenarioSetting("Outbound"),formatTime(remaining_decontamination_drop_time))
		end
	end
	final_message = string.format(_("msgMainscreen","%s\nTime spent in scenario: %s"),final_message,formatTime(getScenarioTime()))
	final_message = string.format(_("msgMainscreen","%s\nEnemies:%s Rings:%s Reputation:%i"),final_message,getScenarioSetting("Enemies"),getScenarioSetting("Rings"),math.floor(getPlayerShip(-1):getReputationPoints()))
	return final_message
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
function scenarioShipEnhancements()
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
					{long = 50000, short = 5000},
					{long = 75000, short = 4500},
					{long = 100000, short = 4000},
				}
			end
			addCommsReply(_("upgrade-comms","Tell me about the Richter version 7 sensor upgrade."),function()
				if comms_target.richter == nil then
					comms_target.richter = tableRemoveRandom(comms_target.sensor_upgrades)
				end
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
				addCommsReply(_("Back"), commsStation)
			end)
			addCommsReply(_("upgrade-comms","What about the Omniscient Mark 4 sensor upgrade?"),function()
				if comms_target.omniscient == nil then
					comms_target.omniscient = tableRemoveRandom(comms_target.sensor_upgrades)
				end
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
				addCommsReply(_("Back"), commsStation)
			end)
			addCommsReply(_("upgrade-comms","Please provide details on the Voriax II sensor upgrade."),function()
				if comms_target.voriax == nil then
					comms_target.voriax = tableRemoveRandom(comms_target.sensor_upgrades)
				end
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
				addCommsReply(_("Back"), commsStation)
			end)
			addCommsReply(_("Back"), commsStation)
		end)
	end
end
function messagePlayers()
	if messages ~= nil and #messages > 0 then
		for i,msg in ipairs(messages) do
			if msg.list ~= nil and #msg.list > 0 then
				for j,p in ipairs(msg.list) do
					if availableForComms(p) then
						for k,station in ipairs(stations) do
							if station ~= nil and station:isValid() then
								station:sendCommsMessage(p,msg.msg)
								break
							end
						end
						msg.list[j] = msg.list[#msg.list]
						msg.list[#msg.list] = nil
						break
					end
				end
			else
				messages[i] = messages[#messages]
				messages[#messages] = nil
			end
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
		if missionMaintenance == froggerIn then
			if comms_source.individual_mission == "wait for other players" then
				ordMsg = string.format(_("orders-comms","Other ships are still in the process of delivering injured personnel. Once all the injured are taken care of, you will receive new orders. Right now, just wait.\n%s"),optional_orders)
			elseif comms_source.individual_mission == "dock with hq to drop injured people" then
				ordMsg = string.format(_("orders-comms","Deliver injured personnel to station %s.\nTime remaining before one of the injured dies: %s\n%s"),hq_station:getCallSign(),formatTime(comms_source.frogger_in_time),optional_orders)
			elseif comms_source.individual_mission == "dock with titan to get injured people" then
				ordMsg = string.format(_("orders-comms","Pick up injured personnel from station %s.\n%s"),titan_station:getCallSign(),optional_orders)
			end
		end
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
--	General
function cleanList(list)
	local clean_list = true
	if #list > 0 then
		for i,obj in ipairs(list) do
			if obj == nil or not obj:isValid() then
				list[i] = list[#list]
				list[#list] = nil
				clean_list = false
				break
			end
		end
	end
	return clean_list
end
function updateAsteroidOrbits(delta)
	if cleanList(orbiting_asteroids) then
		for i,ast in ipairs(orbiting_asteroids) do
			local angle = (ast.angle + delta/ast.orbit_speed) % 360
			local ax, ay = vectorFromAngle(angle,ast.dist,true)
			ax = ax + center_x
			ay = ay + center_y
			ast:setPosition(ax, ay)
			ast.angle = angle
		end
	end
end
function update(delta)
	if delta == 0 then
		return	--because the scenario is paused
	end
	updateAsteroidOrbits(delta)
	messagePlayers()
	if missionMaintenance ~= nil then
		missionMaintenance()
	end
	local final_message = ""
	if epimetheus_station:isValid() then
		local em_x, em_y = moon_epimetheus:getPosition()
		local angle = angleHeading(center_x, center_y, em_x, em_y)
		local es_x, es_y = vectorFromAngle(angle + 90,2000,true)
		epimetheus_station:setPosition(es_x + em_x, es_y + em_y)
	else
		final_message = string.format(_("msgMainscreen","Station %s has been destroyed."),epimetheus_station_name)
		final_message = string.format("%s\n%s",final_message,finalStats())
		globalMessage(final_message)
		victory("Kraylor")
	end
	if titan_station:isValid() then
		local tm_x, tm_y = moon_titan:getPosition()
		titan_station:setPosition(tm_x + 5000, tm_y + 5000)
	else
		final_message = string.format(_("msgMainscreen","Station %s has been destroyed."),titan_station_name)
		final_message = string.format("%s\n%s",final_message,finalStats())
		globalMessage(final_message)
		victory("Kraylor")
	end
	if mission_message == nil then
		mission_message = "queued"
		local player_message = string.format(_("goal-incCall","Welcome to the region around Saturn.\n\nWe are having a bit of a problem with the Kraylor. They are attacking station %s. We could use your assistance fighting them off. %s station is currently located in sector %s."),titan_station:getCallSign(),titan_station:getCallSign(),titan_station:getSectorName())
		table.insert(messages,{msg=player_message,list={}})
		local messages_index = #messages
		for i,p in ipairs(getActivePlayerShips()) do
			table.insert(messages[messages_index].list,p)
		end
		primary_orders = string.format(_("orders-comms","Protect station %s."),titan_station:getCallSign())
	end
end