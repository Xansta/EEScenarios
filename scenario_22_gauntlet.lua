-- Name: The Exuari Gauntlet
-- Description: The Exuari have laid down the gauntlet. Will you take up the challenge?
---
--- Designed for 1 or more player ships
---
--- Version 1
---
--- USN Discord: https://discord.gg/PntGG3a where you can join a game online. There's usually one every weekend. All experience levels are welcome. 
-- Type: Mission
-- Author: Xansta
-- Setting[Respawn]: Configures whether the player ship automatically respawns in game or not and how often if it does automatically respawn
-- Respawn[None|Default]: Player ship does not automatically respawn
-- Respawn[One]: Player ship will automatically respawn once
-- Respawn[Two]: Player ship will automatically respawn twice
-- Respawn[Three]: Player ship will automatically respawn thrice
-- Respawn[Infinite]: Player ship will automatically respawn forever
-- Setting[Murphy]: Configures the perversity of the universe according to Murphy's law
-- Murphy[Easy]: Random factors are more in your favor
-- Murphy[Normal|Default]: Random factors are normal
-- Murphy[Hard]: Random factors are more against you
-- Murphy[Extreme]: Random factors are severely against you
-- Murphy[Quixotic]: No need for paranoia, the universe *is* out to get you
-- Setting[Enemies]: Configures strength and/or number of enemies in this scenario
-- Enemies[Easy]: Fewer or weaker enemies
-- Enemies[Normal|Default]: Normal number or strength of enemies
-- Enemies[Hard]: More or stronger enemies
-- Enemies[Extreme]: Much stronger, many more enemies
-- Enemies[Quixotic]: Insanely strong and/or inordinately large numbers of enemies

require("utils.lua")
require("place_station_scenario_utility.lua")
require("cpu_ship_diversification_scenario_utility.lua")
require("generate_call_sign_scenario_utility.lua")
require("comms_scenario_utility.lua")
require("spawn_ships_scenario_utility.lua")

function init()
	scenario_version = "1.0.0"
	ee_version = "2024.12.08"
	print(string.format("    ----    Scenario: The Exuari Gauntlet    ----    Version %s    ----    Tested with EE version %s    ----",scenario_version,ee_version))
	if _VERSION ~= nil then
		print("Lua version:",_VERSION)
	end
	onNewPlayerShip(setPlayers)
	setConstants()
	setGlobals()
	setVariations()
	mainGMButtons()
	constructEnvironment()
end
function setConstants()
	relative_strength = 1
	human_navy_wreck = FactionInfo():setName("Wreck")
		:setGMColor(255,128,128)
		:setFriendly(getFactionInfo("Human Navy"))
	pretty_system = {
		["reactor"] = _("stationServices-comms","reactor"),
		["beamweapons"] = _("stationServices-comms","beam weapons"),
		["missilesystem"] = _("stationServices-comms","missile system"),
		["maneuver"] = _("stationServices-comms","maneuver"),
		["impulse"] = _("stationServices-comms","impulse engines"),
		["warp"] = _("stationServices-comms","warp drive"),
		["jumpdrive"] = _("stationServices-comms","jump drive"),
		["frontshield"] = _("stationServices-comms","front shield"),
		["rearshield"] = _("stationServices-comms","rear shield"),
		["power"] = _("stationServices-comms","power"),
		["hull"] = _("stationServices-comms","hull"),
	}
	pretty_short_system = {
		["reactor"] = _("stationServices-comms","reactor"),
		["beamweapons"] = _("stationServices-comms","beams"),
		["missilesystem"] = _("stationServices-comms","missiles"),
		["maneuver"] = _("stationServices-comms","maneuver"),
		["impulse"] = _("stationServices-comms","impulse"),
		["warp"] = _("stationServices-comms","warp"),
		["jumpdrive"] = _("stationServices-comms","jump"),
		["frontshield"] = _("stationServices-comms","front shield"),
		["rearshield"] = _("stationServices-comms","rear shield"),
	}
	system_types = {"reactor","beamweapons","missilesystem","maneuver","impulse","warp","jumpdrive","frontshield","rearshield"}
	stations_improve_ships = true
	stations_sell_goods = true
	stations_buy_goods = true
	stations_trade_goods = true
	stations_support_transport_missions = true
	stations_support_cargo_missions = true
	current_orders_button = true
	center_x = 200000 + random(-80000,80000)
	center_y = 150000 + random(-60000,60000)
	max_repeat_loop = 100
	commonGoods = {"food","medicine","nickel","platinum","gold","dilithium","tritanium","luxury","cobalt","impulse","warp","shield","tractor","repulsor","beam","optic","robotic","filament","transporter","sensor","communication","autodoc","lifter","android","nanites","software","circuit","battery"}
	mineralGoods = {"nickel","platinum","gold","dilithium","tritanium","cobalt"}
	componentGoods = {"impulse","warp","shield","tractor","repulsor","beam","optic","robotic","filament","transporter","sensor","communication","autodoc","lifter","android","nanites","software","circuit","battery"}
	good_desc = {
		["food"] =			_("trade-comms","food"),
		["medicine"] =		_("trade-comms","medicine"),
		["luxury"] =		_("trade-comms","luxury"),
		["cobalt"] =		_("trade-comms","cobalt"),
		["dilithium"] =		_("trade-comms","dilithium"),
		["gold"] =			_("trade-comms","gold"),
		["nickel"] =		_("trade-comms","nickel"),
		["platinum"] =		_("trade-comms","platinum"),
		["tritanium"] =		_("trade-comms","tritanium"),
		["autodoc"] =		_("trade-comms","autodoc"),
		["android"] =		_("trade-comms","android"),
		["battery"] =		_("trade-comms","battery"),
		["beam"] =			_("trade-comms","beam"),
		["circuit"] =		_("trade-comms","circuit"),
		["communication"] =	_("trade-comms","communication"),
		["filament"] =		_("trade-comms","filament"),
		["impulse"] =		_("trade-comms","impulse"),
		["lifter"] =		_("trade-comms","lifter"),
		["nanites"] =		_("trade-comms","nanites"),
		["optic"] =			_("trade-comms","optic"),
		["repulsor"] =		_("trade-comms","repulsor"),
		["robotic"] =		_("trade-comms","robotic"),
		["sensor"] =		_("trade-comms","sensor"),
		["shield"] =		_("trade-comms","shield"),
		["software"] =		_("trade-comms","software"),
		["tractor"] =		_("trade-comms","tractor"),
		["transporter"] =	_("trade-comms","transporter"),
		["warp"] =			_("trade-comms","warp"),
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
		["Sweeper"] =			{strength = 17,	adder = true,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	create = sweeper},
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
		["Mikado"] =			{strength = 38,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 0,	hop_range = 1180,	create = mikado},
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
	shipTemplateDistance = {
		["Adder MK3"] =						100,
		["Adder MK4"] =						100,
		["Adder MK5"] =						100,
		["Adder MK6"] =						100,
		["Adder MK7"] =						100,
		["Adder MK8"] =						100,
		["Adder MK9"] =						100,
		["Adv. Gunship"] =					400,
		["Adv. Striker"] = 					300,
		["Atlantis X23"] =					400,
		["Atlantis Y42"] =					400,
		["Battlestation"] =					2000,
		["Beast Breaker"] =					300,
		["Blockade Runner"] =				400,
		["Blade"] =							300,
		["Broom"] =							100,
		["Brush"] =							100,
		["Buster"] =						100,
		["Command Base"] =					800,		
		["Courier"] =						600,
		["Cruiser"] =						200,
		["Cucaracha"] =						200,
		["Dagger"] =						100,
		["Dash"] =							200,
		["Defense platform"] =				800,
		["Diva"] =							350,
		["Tsarina"] =						350,
		["Brood Mother"] =					350,
		["Dread No More"] =					400,
		["Dreadnought"] =					400,
		["Elara P2"] =						200,
		["Enforcer"] =						400,
		["Enforcer V2"] =					400,
		["Equipment Freighter 1"] =			600,
		["Equipment Freighter 2"] =			600,
		["Equipment Freighter 3"] =			600,
		["Equipment Freighter 4"] =			800,
		["Equipment Freighter 5"] =			800,
		["Equipment Jump Freighter 3"] =	600,
		["Equipment Jump Freighter 4"] =	800,
		["Equipment Jump Freighter 5"] =	800,
		["Farco 3"] =						200,
		["Farco 5"] =						200,
		["Farco 8"] =						200,
		["Farco 11"] =						200,
		["Farco 13"] =						200,
		["Fiend G3"] =						400,
		["Fiend G4"] =						400,
		["Fiend G5"] =						400,
		["Fiend G6"] =						400,
		["Fighter"] =						200,
		["Flash"] =							100,
		["Flavia"] =						200,
		["Flavia Falcon"] =					200,
		["Fortress"] =						2000,
		["Foul Feeder"] =					300,
		["Fray"] =							200,
		["Fuel Freighter 1"] =				600,
		["Fuel Freighter 2"] =				600,
		["Fuel Freighter 3"] =				600,
		["Fuel Freighter 4"] =				800,
		["Fuel Freighter 5"] =				800,
		["Fuel Jump Freighter 3"] =			600,
		["Fuel Jump Freighter 4"] =			800,
		["Fuel Jump Freighter 5"] =			800,
		["Garbage Freighter 1"] =			600,
		["Garbage Freighter 2"] =			600,
		["Garbage Freighter 3"] =			600,
		["Garbage Freighter 4"] =			800,
		["Garbage Freighter 5"] =			800,
		["Garbage Jump Freighter 3"] =		600,
		["Garbage Jump Freighter 4"] =		800,
		["Garbage Jump Freighter 5"] =		800,
		["Gnat"] =							300,
		["Goods Freighter 1"] =				600,
		["Goods Freighter 2"] =				600,
		["Goods Freighter 3"] =				600,
		["Goods Freighter 4"] =				800,
		["Goods Freighter 5"] =				800,
		["Goods Jump Freighter 3"] =		600,
		["Goods Jump Freighter 4"] =		800,
		["Goods Jump Freighter 5"] =		800,
		["Guard"] =							600,	--transport_1_1
		["Gulper"] =						400,
		["Gunner"] =						100,
		["Gunship"] =						400,
		["Heavy Drone"] = 					300,
		["Hunter"] =						200,
		["Jacket Drone"] =					300,
		["Jade 5"] =						100,
		["Jagger"] =						100,
		["Jump Carrier"] =					800,		
		["Karnack"] =						200,
		["K2 Fighter"] =					300,
		["K3 Fighter"] =					300,
		["Ktlitan Breaker"] =				300,
		["Ktlitan Destroyer"] = 			500,
		["Ktlitan Drone"] =					300,
		["Ktlitan Feeder"] =				300,
		["Ktlitan Fighter"] =				300,
		["Ktlitan Queen"] =					500,
		["Ktlitan Scout"] =					300,
		["Ktlitan Worker"] =				300,
		["Laden Lorry"] =					600,
		["Lite Drone"] = 					300,
		["Loki"] =							1500,
		["Maniapak"] =						100,
		["Mikado"] =						200,
		["Military Outpost"] =				800,
		["Missile Pod D1"] =				800,
		["Missile Pod D2"] =				800,
		["Missile Pod D4"] =				800,
		["Missile Pod T1"] =				800,
		["Missile Pod T2"] =				800,
		["Missile Pod TI2"] =				800,
		["Missile Pod TI4"] =				800,
		["Missile Pod TI8"] =				800,
		["Missile Pod TX4"] =				800,
		["Missile Pod TX8"] =				800,
		["Missile Pod TX16"] =				800,
		["Missile Pod S1"] =				800,
		["Missile Pod S4"] =				800,
		["Missile Cruiser"] =				200,
		["MT52 Hornet"] =					100,
		["MT55 Hornet"] =					100,
		["MU52 Hornet"] =					100,
		["MU55 Hornet"] =					100,
		["Munemi"] =						100,
		["MV52 Hornet"] =					100,
		["Nirvana R3"] =					200,
		["Nirvana R5"] =					200,
		["Nirvana R5A"] =					200,
		["Odin"] = 							1500,
		["Omnibus"] = 						800,
		["Personnel Freighter 1"] =			600,
		["Personnel Freighter 2"] =			600,
		["Personnel Freighter 3"] =			600,
		["Personnel Freighter 4"] =			800,
		["Personnel Freighter 5"] =			800,
		["Personnel Jump Freighter 3"] =	600,
		["Personnel Jump Freighter 4"] =	800,
		["Personnel Jump Freighter 5"] =	800,
		["Phobos M3"] =						200,
		["Phobos R2"] =						200,
		["Phobos T3"] =						200,
		["Phobos T4"] =						200,
		["Physics Research"] =				600,
		["Piranha F10"] =					200,
		["Piranha F12"] =					200,
		["Piranha F12.M"] =					200,
		["Piranha F8"] =					200,
		["Porcupine"] =						400,
		["Prador"] =						2000,
		["Predator"] =						200,
		["Predator V2"] =					200,
		["Racer"] =							200,
		["Ranger"] =						100,
		["Ranus U"] =						200,
		["Roc"] =							200,
		["Rook"] =							200,
		["Ryder"] =							2000,
		["Sentinel"] =						600,
		["Service Jonque"] =				800,
		["Shooter"] =						100,
		["Sloop"] =							200,
		["Sniper Tower"] =					800,
		["Space Sedan"] =					600,
		["Stalker Q5"] =					200,
		["Stalker Q7"] =					200,
		["Stalker R5"] =					200,
		["Stalker R7"] =					200,
		["Starhammer II"] =					400,
		["Starhammer III"] =				400,
		["Starhammer V"] =					400,
		["Storm"] =							200,
		["Strike"] =						200,
		["Strikeship"] = 					200,
		["Strongarm"] =						400,
		["Supervisor"] =					400,
		["Sweeper"] =						100,
		["Tempest"] =						200,
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
		["Tug"] =							200,
		["Tyr"] =							2000,
		["Waddle 5"] =						100,
		["Warden"] =						600,
		["Weapons platform"] =				200,
		["Whirlwind"] =						200,
		["Wombat"] =						100,
		["Work Wagon"] =					600,
		["WX-Lindworm"] =					100,
		["WZ-Lindworm"] =					100,
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
	station_spacing = {
		["Small Station"] =		{neb = 9000,	touch = 300,	defend = 2600,	platform = 1200,	outer_platform = 7500},
		["Medium Station"] =	{neb = 10800,	touch = 1200,	defend = 4000,	platform = 2400,	outer_platform = 9100},
		["Large Station"] =		{neb = 11600,	touch = 1400,	defend = 4600,	platform = 2800,	outer_platform = 9700},
		["Huge Station"] =		{neb = 12300,	touch = 2000,	defend = 4960,	platform = 3500,	outer_platform = 10100},
	}
	missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
end
function setGlobals()
	inner_stations = {}
	outer_stations = {}
	friendly_spike_stations = {}
	inner_space = {}
	maintenancePlot = warpJammerMaintenance
	dangerous_planets = true
	collision_planets = {}
	message_stations = {}
	code_bearers = {}
	gauntlet_defense_fleet = {}
	explain_cyber_missile = false
	attack_delay = 1
	min_delay = 180
	max_delay = 300
	gauntlet_orbit_time = 3.5
	gauntlet_range = 10000
	cyber_missiles = {}
	transport_list = {}
	messages = {}
	deployed_players = {}
	deployed_player_count = 0
	sensor_impact = 1	--normal
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
		["Phobos M3P"] =		{"Blinder","Shadow","Distortion","Diemos","Ganymede","Castillo","Thebe","Retrograde","Rage","Cogitate","Thrust","Coyote","Fortune","Centurion","Shade","Trident","Haft","Gauntlet"},
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
	star_list = {
		{radius = random(600,1400), distance = random(-2500,-1400), 
			info = {
				{
					name = "Gamma Piscium",
					unscanned = _("scienceDescription-star","Yellow, spectral type G8 III"),
					scanned = _("scienceDescription-star","Yellow, spectral type G8 III, giant, surface temperature 4,833 K, 11 solar radii"),
				},
				{
					name = "Beta Leporis",
					unscanned = _("scienceDescription-star","Classification G5 II"),
					scanned = _("scienceDescription-star","Classification G5 II, bright giant, possible binary"),
				},
				{
					name = "Sigma Draconis",
					unscanned = _("scienceDescription-star","Classification K0 V or G9 V"),
					scanned = _("scienceDescription-star","Classification K0 V or G9 V, main sequence dwarf, 84% of Sol mass"),
				},
				{
					name = "Iota Carinae",
					unscanned = _("scienceDescription-star","Classification A7 lb"),
					scanned = _("scienceDescription-star","Classification A7 lb, supergiant, temprature 7,500 K, 7xSol mass"),
				},
				{
					name = "Theta Arietis",
					unscanned = _("scienceDescription-star","Classification A1 Vn"),
					scanned = _("scienceDescription-star","Classification A1 Vn, type A main sequence, binary, nebulous"),
				},
				{
					name = "Epsilon Indi",
					unscanned = _("scienceDescription-star","Classification K5V"),
					scanned = _("scienceDescription-star","Classification K5V, orange, temperature 4,649 K"),
				},
				{
					name = "Beta Hydri",
					unscanned = _("scienceDescription-star","Classification G2 IV"),
					scanned = _("scienceDescription-star","Classification G2 IV, 113% of Sol mass, 185% Sol radius"),
				},
				{
					name = "Acamar",
					unscanned = _("scienceDescription-star","Classification A3 IV-V"),
					scanned = _("scienceDescription-star","Classification A3 IV-V, binary, 2.6xSol mass"),
				},
				{
					name = "Bellatrix",
					unscanned = _("scienceDescription-star","Classification B2 III or B2 V"),
					scanned = _("scienceDescription-star","Classification B2 III or B2 V, 8.6xSol mass, temperature 22,000 K"),
				},
				{
					name = "Castula",
					unscanned = _("scienceDescription-star","Classification G8 IIIb Fe-0.5"),
					scanned = _("scienceDescription-star","Classification G8 IIIb Fe-0.5, yellow, red clump giant"),
				},
				{
					name = "Dziban",
					unscanned = _("scienceDescription-star","Classification F5 IV-V"),
					scanned = _("scienceDescription-star","Classification F5 IV-V, binary, F-type subgiant and F-type main sequence"),
				},
				{
					name = "Elnath",
					unscanned = _("scienceDescription-star","Classification B7 III"),
					scanned = _("scienceDescription-star","Classification B7 III, B-class giant, double star, 5xSol mass"),
				},
				{
					name = "Flegetonte",
					unscanned = _("scienceDescription-star","Classification K0"),
					scanned = _("scienceDescription-star","Classification K0, orange-red, temperature ~4,000 K"),
				},
				{
					name = "Geminga",
					unscanned = _("scienceDescription-star","Pulsar or Neutron star"),
					scanned = _("scienceDescription-star","Pulsar or Neutron star, gamma ray source"),
				},
				{	
					name = "Helvetios",	
					unscanned = _("scienceDescription-star","Classification G2V"),
					scanned = _("scienceDescription-star","Classification G2V, yellow, temperature 5,571 K"),
				},
				{	
					name = "Inquill",	
					unscanned = _("scienceDescription-star","Classification G1V(w)"),
					scanned = _("scienceDescription-star","Classification G1V(w), 1.24xSol mass, 7th magnitude G-type main sequence"),
				},
				{	
					name = "Jishui",	
					unscanned = _("scienceDescription-star","Classification F3 III"),
					scanned = _("scienceDescription-star","Classification F3 III, F-type giant, temperature 6,309 K"),
				},
				{	
					name = "Kaus Borealis",	
					unscanned = _("scienceDescription-star","Classification K1 IIIb"),
					scanned = _("scienceDescription-star","Classification K1 IIIb, giant, temperature 4,768 K"),
				},
				{	
					name = "Liesma",	
					unscanned = _("scienceDescription-star","Classification G0V"),
					scanned = _("scienceDescription-star","Classification G0V, G-type giant, temperature 5,741 K"),
				},
				{	
					name = "Macondo",	
					unscanned = _("scienceDescription-star","Classification K2IV-V or K3V"),
					scanned = _("scienceDescription-star","Classification K2IV-V or K3V, orange, K-type main sequence, temperature 5,030 K"),
				},
				{	
					name = "Nikawiy",	
					unscanned = _("scienceDescription-star","Classification G5"),
					scanned = _("scienceDescription-star","Classification G5, yellow, luminosity 7.7"),
				},
				{	
					name = "Orkaria",	
					unscanned = _("scienceDescription-star","Classification M4.5"),
					scanned = _("scienceDescription-star","Classification M4.5, Red Dwarf, luminosity .0035, temperature 3,111 K"),
				},
				{	
					name = "Poerava",	
					unscanned = _("scienceDescription-star","Classification F7V"),
					scanned = _("scienceDescription-star","Classification F7V, yellow-white, luminosity 1.9, temperature 6,440 K"),
				},
				{	
					name = "Stribor",	
					unscanned = _("scienceDescription-star","Classification F8V"),
					scanned = _("scienceDescription-star","Classification F8V, luminosity 2.9, temperature 6,122 K"),
				},
				{	
					name = "Taygeta",	
					unscanned = _("scienceDescription-star","Classification B"),
					scanned = _("scienceDescription-star","Classification B-type subgiant, blue-white, luminosity 600, temperature 13,696 K"),
				},
				{	
					name = "Tuiren",	
					unscanned = _("scienceDescription-star","Classification G"),
					scanned = _("scienceDescription-star","Classification G, magnitude 12.26, temperature 5,580 K"),
				},
				{	
					name = "Ukdah",	
					unscanned = _("scienceDescription-star","Classification K"),
					scanned = _("scienceDescription-star","Classification K2.5 III, K-type giant, temperature 4,244 K"),
				},
				{	
					name = "Wouri",	
					unscanned = _("scienceDescription-star","Classification K"),
					scanned = _("scienceDescription-star","Classification 5V, K-type main sequence, temperature 4,782 K"),
				},
				{	
					name = "Xihe",	
					unscanned = _("scienceDescription-star","Classification G"),
					scanned = _("scienceDescription-star","Classification G8 III, evolved G-type giant, temperature 4,790 K"),
				},
				{	
					name = "Yildun",	
					unscanned = _("scienceDescription-star","Classification A"),
					scanned = _("scienceDescription-star","Classification A1 Van, white hued, A-type main sequence, temperature 9,911 K"),
				},
				{	
					name = "Zosma",	
					unscanned = _("scienceDescription-star","Classification A"),
					scanned = _("scienceDescription-star","Classification A4 V, white hued, A-type main sequence, temperature 8,296 K"),
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
			texture = {
				surface = "planets/gas-1.png"
			},
			radius = random(4000,7500),
		},
		{
			name = {"Farius Prime","Deneb","Mordan"},
			texture = {
				surface = "planets/gas-2.png"
			},
			radius = random(4000,7500),
		},
		{
			name = {"Kepler-7b","Alpha Omicron","Nelvana"},
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
end
function setVariations()
	local respawn_config = {
		["None"] =		{respawn = false,	max = 0},
		["One"] =		{respawn = true,	max = 1},
		["Two"] =		{respawn = true,	max = 2},
		["Three"] =		{respawn = true,	max = 3},
		["Infinite"] =	{respawn = true,	max = 999},	--I know, it's not infinite, but after 999, it should stop
	}
	player_respawns = respawn_config[getScenarioSetting("Respawn")].respawn
	player_respawn_max = respawn_config[getScenarioSetting("Respawn")].max
	local murphy_config = {
		["Easy"] =		{number = .5,	rep = 90,	bump = 20,	sys_count = 1,	impact = .0001,	gsp_lo_c = 1,	gsp_hi_c = 2,	gsp_lo_d = 1,	gsp_hi_d = 2,	},
		["Normal"] =	{number = 1,	rep = 50,	bump = 10,	sys_count = 3,	impact = .001,	gsp_lo_c = 1,	gsp_hi_c = 2,	gsp_lo_d = 1,	gsp_hi_d = 3,	},
		["Hard"] =		{number = 2,	rep = 30,	bump = 5,	sys_count = 5,	impact = .005,	gsp_lo_c = 1,	gsp_hi_c = 3,	gsp_lo_d = 1,	gsp_hi_d = 3,	},
		["Extreme"] =	{number = 3,	rep = 20,	bump = 3,	sys_count = 6,	impact = .01,	gsp_lo_c = 2,	gsp_hi_c = 3,	gsp_lo_d = 1,	gsp_hi_d = 3,	},
		["Quixotic"] =	{number = 5,	rep = 10,	bump = 1,	sys_count = 7,	impact = .03,	gsp_lo_c = 2,	gsp_hi_c = 3,	gsp_lo_d = 2,	gsp_hi_d = 4,	},
	}
	difficulty =				murphy_config[getScenarioSetting("Murphy")].number
	reputation_start_amount =	murphy_config[getScenarioSetting("Murphy")].rep
	reputation_bump_amount =	murphy_config[getScenarioSetting("Murphy")].bump
	gauntlet_system_count =		murphy_config[getScenarioSetting("Murphy")].sys_count
	system_impact =				murphy_config[getScenarioSetting("Murphy")].impact
	gsp_lo_complexity =			murphy_config[getScenarioSetting("Murphy")].gsp_lo_c	--gauntlet artifact scanning parameter low range for complexity
	gsp_hi_complexity =			murphy_config[getScenarioSetting("Murphy")].gsp_hi_c	--gauntlet artifact scanning parameter high range for complexity
	gsp_lo_depth =				murphy_config[getScenarioSetting("Murphy")].gsp_lo_d	--gauntlet artifact scanning parameter low range for depth
	gsp_hi_depth =				murphy_config[getScenarioSetting("Murphy")].gsp_hi_c	--gauntlet artifact scanning parameter high range for depth
	local enemy_config = {
		["Easy"] =		{number = .5},
		["Normal"] =	{number = 1},
		["Hard"] =		{number = 2},
		["Extreme"] =	{number = 3},
		["Quixotic"] =	{number = 5},
	}
	enemy_power =	enemy_config[getScenarioSetting("Enemies")].number
end
function mainGMButtons()
	clearGMFunctions()
	addGMFunction(_("buttonGM","+Spawn Ship(s)"),spawnGMShips)
end
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
	p:setPosition(player_spawn_x, player_spawn_y)
	--set defaults for those ships not found in the list
	p.shipScore = 24
	p.maxCargo = 5
	p.cargo = p.maxCargo
	p.tractor = false
	p.tractor_target_lock = false
	p.mining = false
	p.goods = {}
	p:setFaction(player_faction)
	p.command_log = {}
	p:onDestroyed(playerDestroyed)
	p:onDestruction(playerDestruction)
	if p:getReputationPoints() == 0 then
		p:setReputationPoints(reputation_start_amount)
	end
	if p.probe_type_list == nil then
		p.probe_type_list = {}
		table.insert(p.probe_type_list,{name = "standard", count = -1})
	end
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
				local respawned_player = PlayerSpaceship():setTemplate(self:getTypeName()):setFaction(player_faction)
				dp.p = respawned_player
				dp.count = dp.count + 1
				respawned_player:setCallSign(string.format("%s %i",dp.name,dp.count))
				respawned_player.name_set = true
				updatePlayerSoftTemplate(respawned_player)
				globalMessage(string.format(_("msgMainscreen","The %s has respawned %s to replace %s."),player_faction,respawned_player:getCallSign(),self:getCallSign()))
				self:transferPlayersToShip(respawned_player)
			end
			break
		end
	end
end
function constructEnvironment()
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
	--	player start and faction
	local player_start_angle = random(0,360)
	player_spawn_x, player_spawn_y = vectorFromAngle(player_start_angle,random(radius + 3000,5000),true)
	player_spawn_x = player_spawn_x + center_x
	player_spawn_y = player_spawn_y + center_y
	table.insert(inner_space,{obj=VisualAsteroid(),dist=500,shape="circle"})
	player_factions = {"Human Navy","CUF","USN","TSN"}
	player_faction = tableSelectRandom(player_factions)
	friendly_factions = {"Human Navy",player_faction}
	if player_faction == "Human Navy" then
		friendly_factions = {"Human Navy","CUF","USN","TSN"}
	end
	friendly_lookup_factions = {}
	for i,faction in ipairs(friendly_factions) do
		friendly_lookup_factions[faction] = true
	end
	--	home station
	local hs_x, hs_y = vectorFromAngle(player_start_angle + random(160,200),random(radius + 5000,10000),true)
	hs_x = hs_x + center_x
	hs_y = hs_y + center_y
	home_station = placeStation(hs_x,hs_y,"RandomHumanNeutral",player_faction)
	table.insert(message_stations,home_station)
	table.insert(inner_stations,home_station)
	table.insert(inner_space,{obj=home_station,dist=station_spacing[home_station:getTypeName()].defend,shape="circle"})
	--	gauntlet station
	local gauntlet_angle = random(0,360)
	gauntlet_station_x, gauntlet_station_y = vectorFromAngle(gauntlet_angle,random(90000,110000),true)
	gauntlet_station_x = gauntlet_station_x + center_x
	gauntlet_station_y = gauntlet_station_y + center_y
	gauntlet_station = placeStation(gauntlet_station_x,gauntlet_station_y,"Sinister","Exuari","Large Station")
	table.insert(inner_stations,gauntlet_station)
	--	gauntlet artifacts and warp jammers
	local gauntlet_zone_colors = {
		{r = 55,	g = 55,	b = 55},
		{r = 255,	g = 69,	b = 0},
		{r = 255,	g = 127,b = 80},
		{r = 95,	g = 158,b = 160},
		{r = 65,	g = 105,b = 225},
		{r = 138,	g = 43,	b = 226},
		{r = 186,	g = 85,	b = 211},
		{r = 160,	g = 82,	b = 45},
		{r = 178,	g = 150,b = 80},
		{r = 85,	g = 107,b = 47},
		{r = 34,	g = 139,b = 34},
		{r = 178,	g = 34,	b = 34},
	}
	gauntlet_artifacts = {}
	local impact_systems = {}
	for i=1,10 do
		local ga_x, ga_y = vectorFromAngle(i*36,15000,true)
		ga = Artifact():setPosition(ga_x + gauntlet_station_x, ga_y + gauntlet_station_y)
		ga:setModel("cubesat")
		ga.zone_color = tableRemoveRandom(gauntlet_zone_colors)
		ga:setRadarTraceColor(ga.zone_color.r,ga.zone_color.g,ga.zone_color.b)
		ga.impact_systems = {}
		for j=1,gauntlet_system_count do
			if #impact_systems < 1 then
				for k,system in ipairs(system_types) do
					table.insert(impact_systems,system)
				end
				table.insert(impact_systems,"hull")
				table.insert(impact_systems,"power")
			end
			table.insert(ga.impact_systems,tableRemoveRandom(impact_systems))
		end
		ga.angle = (i*36)%360
		ga.min_rad_w = random(2000,5000)
		ga.max_rad_w = random(10000,20000)
		ga.rad_w = random(ga.min_rad_w,ga.max_rad_w)	--set radial width
		ga.rad_w_delta = random(1,20)
		if random(1,100) < 50 then 
			ga.rad_w_delta = ga.rad_w_delta * -1
		end
		ga.min_rad_h = random(2000,5000)
		ga.max_rad_h = random(10000,20000)
		ga.rad_h = random(ga.min_rad_h,ga.max_rad_h)	--set radial height
		ga.rad_h_delta = random(1,20)
		if random(1,100) < 50 then 
			ga.rad_h_delta = ga.rad_h_delta * -1
		end
		local impacted_systems_list = ""
		for j,sys in ipairs(ga.impact_systems) do
			impacted_systems_list = string.format("%s %s",impacted_systems_list,pretty_system[sys])
		end
		if #ga.impact_systems > 1 then
			impacted_systems_list = string.format(_("scienceDescription-artifact","Field Generator. Systems impacted:%s"),impacted_systems_list)
		else
			impacted_systems_list = string.format(_("scienceDescription-artifact","Field Generator. System impacted:%s"),impacted_systems_list)			
		end
		ga:setDescriptions(_("scienceDescription-artifact","Field Generator"),impacted_systems_list)
		ga:setScanningParameters(math.random(gsp_lo_complexity,gsp_hi_complexity),math.random(gsp_lo_depth,gsp_hi_depth))
		table.insert(gauntlet_artifacts,ga)
		local gw_x, gw_y = vectorFromAngle(i*36 + 18,15000,true)
		gw = WarpJammer():setPosition(gw_x + gauntlet_station_x, gw_y + gauntlet_station_y):setFaction("Exuari")
		gw.angle = (i*36 + 18)%360
		gw.range_min = gauntlet_range - 3000 + random(-1000,1000)
		gw.range_max = gauntlet_range + random(-1000,1000)
		gw.range_delta = random(1,20)
		if random(1,100) < 50 then
			gw.range_delta = gw.range_delta * -1
		end
		gw:setRange(gauntlet_range)
		table.insert(gauntlet_artifacts,gw)
	end
	local factions = {"Independent","Human Navy","CUF","USN","TSN","Kraylor","Exuari","Ghosts","Ktlitans","Arlenians"}
	non_enemy_factions = {}
	enemy_factions = {}
	comprehensive_enemy_factions = {
		["Human Navy"] = {"Kraylor","Exuari","Ghosts","Ktlitans"},
		["CUF"] = {"Kraylor","Exuari","Ghosts"},
		["TSN"] = {"Kraylor","Arlenians","Exuari","Ktlitans","USN"},
		["USN"] = {"Exuari","Ghosts","Ktlitans","TSN"},
	}
	enemy_factions = comprehensive_enemy_factions[player_faction]
	enemy_lookup_factions = {}
	for i,faction in ipairs(enemy_factions) do
		enemy_lookup_factions[faction] = true
	end
	local circular_station_factions = {"Exuari","Ghosts","Ktlitans","CUF","Arlenians","USN","Kraylor","Independent","TSN","Human Navy"}
	local station_angle = (gauntlet_angle + 180 + random(-20,20))%360
	for i,faction in ipairs(circular_station_factions) do
		local station_name = "RandomHumanNeutral"
		if enemy_factions[faction] ~= nil then
			station_name = "Sinister"
		end
		local psx, psy = vectorFromAngle(station_angle,random(35000,65000),true)
		psx = psx + center_x
		psy = psy + center_x
		local station = placeStation(psx,psy,station_name,faction)
		table.insert(inner_stations,station)
		table.insert(inner_space,{obj=station,dist=station_spacing[station:getTypeName()].defend,shape="circle"})
		local ship, ship_size = randomTransportType()
		local tx, ty = vectorFromAngle(station_angle + 180,random(10000,20000),true)
		local sx, sy = station:getPosition()
		ship:setPosition(tx + sx, ty + sy):setFaction(faction):setCallSign(generateCallSign(nil,faction))
		table.insert(transport_list,ship)
		table.insert(inner_space,{obj=ship,dist=500,shape="circle"})
		station_angle = station_angle + 360/(#circular_station_factions + 1)
	end
	placement_areas = {
		["Inner Circle"] = {
			stations = inner_stations,
			transports = transport_list,
			space = inner_space,
			shape = "circle",
			center_x = center_x,
			center_y = center_y,
			radius = 65000,
		}
--		["Inner Torus"] = {
--			stations = inner_stations,
--			transports = transport_list, 
--			space = inner_space,
--			shape = "torus",
--			center_x = center_x, 
--			center_y = center_y, 
--			inner_radius = 8000, 
--			outer_radius = 20000,
--		},
	}
	local terrain = {
		{chance = 4,	count = 0,	max = math.random(1,2),		radius = "Star",	obj = Planet,		desc = "Star",		},
		{chance = 2,	count = 0,	max = 1,					radius = "Rocky",	obj = Planet,		desc = "Rocky",		},
		{chance = 2,	count = 0,	max = 1,					radius = "Gas",		obj = Planet,		desc = "Gas",		},
		{chance = 4,	count = 0,	max = math.random(1,2),		radius = "Hole",	obj = BlackHole,						},
		{chance = 7,	count = 0,	max = -1,					radius = "Tiny",	obj = ScanProbe,						},
		{chance = 4,	count = 0,	max = math.random(7,15),	radius = "Tiny",	obj = WarpJammer,						},
		{chance = 6,	count = 0,	max = math.random(3,9),		radius = "Tiny",	obj = Artifact,		desc = "Jammer",	},
		{chance = 3,	count = 0,	max = math.random(1,3),		radius = "Hole",	obj = WormHole,							},
		{chance = 6,	count = 0,	max = math.random(2,5),		radius = "Tiny",	obj = Artifact,		desc = "Sensor",	},
		{chance = 8,	count = 0,	max = -1,					radius = "Tiny",	obj = Artifact,		desc = "Ad",		},
		{chance = 8,	count = 0,	max = -1,					radius = "Neb",		obj = Nebula,							},
		{chance = 5,	count = 0,	max = -1,					radius = "Mine",	obj = Mine,								},
		{chance = 4,	count = 0,	max = math.random(3,7),		radius = "Circ",	obj = Mine,			desc = "Circle",	},
		{chance = 4,	count = 0,	max = math.random(3,9),		radius = "Rect",	obj = Mine,			desc = "Rectangle",	},
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
					placement_result = placeTerrain("Inner Circle",terrain_object)
				else
					placement_result = placeTerrain("Inner Circle",{obj = Asteroid, desc = "Lone", radius = "Tiny"})
				end
				if placement_result then
					terrain_object.count = terrain_object.count + 1
				end
				break
			elseif i == #terrain then
				placement_result = placeTerrain("Inner Circle",{obj = Asteroid, desc = "Lone", radius = "Tiny"})
				if placement_result then
					terrain_object.count = terrain_object.count + 1
				end
			end
		end
		objects_placed_count = objects_placed_count + 1
	until(objects_placed_count >= 100)
end
function findClearSpot(objects,area_shape,area_point_x,area_point_y,area_distance,area_distance_2,area_angle,new_buffer,placing_station)
	--area distance 2 is only required for torus areas, bell torus areas and rectangle areas
	--area angle is only required for rectangle areas
	assert(type(objects)=="table",string.format("function findClearSpot expects an object list table as the first parameter, but got a %s instead",type(objects)))
	assert(type(area_shape)=="string",string.format("function findClearSpot expects an area shape string as the second parameter, but got a %s instead",type(area_shape)))
	assert(type(area_point_x)=="number",string.format("function findClearSpot expects an area point X coordinate number as the third parameter, but got a %s instead",type(area_point_x)))
	assert(type(area_point_y)=="number",string.format("function findClearSpot expects an area point Y coordinate number as the fourth parameter, but got a %s instead",type(area_point_y)))
	assert(type(area_distance)=="number",string.format("function findClearSpot expects an area distance number as the fifth parameter, but got a %s instead",type(area_distance)))
	local valid_shapes = {"circle","torus","rectangle"}
	assert(valid_shapes[area_shape] == nil,string.format("function findClearSpot expects a valid shape in the second parameter, but got %s instead",area_shape))
	assert(type(new_buffer)=="number",string.format("function findClearSpot expects a new item buffer distance number as the eighth parameter, but got a %s instead",type(new_buffer)))
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
				assert(item.shape ~= nil,string.format("function findClearSpot expects an object list table where each item in the table is identified by shape, but item index %s's shape was nil",i))
				assert(valid_table_item_shapes[item.shape] == nil,string.format("function findClearSpot expects a valid shape in the object list table item index %i, but got %s instead",i,item.shape))
				if item.shape == "circle" then
					assert(type(item.obj)=="table",string.format("function findClearSpot expects a space object or table as the object in the object list table item index %i, but got a %s instead",i,type(item.obj)))
					local ix, iy = item.obj:getPosition()
					assert(type(item.dist)=="number",string.format("function findClearSpot expects a distance number as the dist value in the object list table item index %i, but got a %s instead",i,type(item.dist)))
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
					assert(type(item.obj)=="table",string.format("function findClearSpot expects a space object or table as the object in the object list table item index %i, but got a %s instead",i,type(item.obj)))
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
		assert(type(area_distance_2)=="table",string.format("function findClearSpot expects a table of random range parameters as the sixth parameter when the shape is bell torus, but got a %s instead",type(area_distance_2)))
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
				assert(item.shape ~= nil,string.format("function findClearSpot expects an object list table where each item in the table is identified by shape, but item index %s's shape was nil",i))
				assert(valid_table_item_shapes[item.shape] == nil,string.format("function findClearSpot expects a valid shape in the object list table item index %i, but got %s instead",i,item.shape))
				if item.shape == "circle" then
					assert(type(item.obj)=="table",string.format("function findClearSpot expects a space object or table as the object in the object list table item index %i, but got a %s instead",i,type(item.obj)))
					local ix, iy = item.obj:getPosition()
					assert(type(item.dist)=="number",string.format("function findClearSpot expects a distance number as the dist value in the object list table item index %i, but got a %s instead",i,type(item.dist)))
					local comparison_dist = item.dist
					if placing_station ~= nil then
						if placing_station then
							if isObjectType(item.obj,"SpaceStation") then
								comparison_dist = 12000
							end
						end
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
		assert(type(area_distance_2)=="number",string.format("function findClearSpot expects an area distance number as the sixth parameter when the shape is torus, but got a %s instead",type(area_distance_2)))
		repeat
			cx, cy = vectorFromAngle(random(0,360),random(area_distance,area_distance_2),true)
			cx = cx + area_point_x
			cy = cy + area_point_y
			far_enough = true
			for i,item in ipairs(objects) do
				assert(item.shape ~= nil,string.format("function findClearSpot expects an object list table where each item in the table is identified by shape, but item index %s's shape was nil",i))
				assert(valid_table_item_shapes[item.shape] == nil,string.format("function findClearSpot expects a valid shape in the object list table item index %i, but got %s instead",i,item.shape))
				if item.shape == "circle" then
					assert(type(item.obj)=="table",string.format("function findClearSpot expects a space object or table as the object in the object list table item index %i, but got a %s instead",i,type(item.obj)))
					local ix, iy = item.obj:getPosition()
					assert(type(item.dist)=="number",string.format("function findClearSpot expects a distance number as the dist value in the object list table item index %i, but got a %s instead",i,type(item.dist)))
					local comparison_dist = item.dist
					if placing_station ~= nil then
						if placing_station then
							if isObjectType(item.obj,"SpaceStation") then
								comparison_dist = 12000
							end
						end
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
		assert(type(area_distance_2)=="number",string.format("function findClearSpot expects an area distance number (width) as the sixth parameter when the shape is rectangle, but got a %s instead",type(area_distance_2)))
		assert(type(area_angle)=="number",string.format("function findClearSpot expects an area angle number as the seventh parameter when the shape is rectangle, but got a %s instead",type(area_angle)))
		repeat
			cx, cy = vectorFromAngle(area_angle,random(-area_distance/2,area_distance/2),true)
			cx = cx + area_point_x
			cy = cy + area_point_y
			local px, py = vectorFromAngle(area_angle + 90,random(-area_distance_2/2,area_distance_2/2),true)
			cx = cx + px
			cy = cy + py
			far_enough = true
			for i,item in ipairs(objects) do
				assert(item.shape ~= nil,string.format("function findClearSpot expects an object list table where each item in the table is identified by shape, but item index %s's shape was nil",i))
				assert(valid_table_item_shapes[item.shape] == nil,string.format("function findClearSpot expects a valid shape in the object list table item index %i, but got %s instead",i,item.shape))
				if item.shape == "circle" then
					assert(type(item.obj)=="table",string.format("function findClearSpot expects a space object or table as the object in the object list table item index %i, but got a %s instead",i,type(item.obj)))
					local ix, iy = item.obj:getPosition()
					assert(type(item.dist)=="number",string.format("function findClearSpot expects a distance number as the dist value in the object list table item index %i, but got a %s instead",i,type(item.dist)))
					local comparison_dist = item.dist
					if placing_station ~= nil then
						if placing_station then
							if isObjectType(item.obj,"SpaceStation") then
								comparison_dist = 12000
							end
						end
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
		assert(type(area_distance_2)=="number",string.format("function findClearSpot expects an area distance number (width) as the sixth parameter when the shape is rectangle, but got a %s instead",type(area_distance_2)))
		assert(type(area_angle)=="number",string.format("function findClearSpot expects an area angle number as the seventh parameter when the shape is rectangle, but got a %s instead",type(area_angle)))
		repeat
			cx, cy = vectorFromAngle(area_angle,random(0,area_distance),true)
			cx = cx + area_point_x
			cy = cy + area_point_y
			local px, py = vectorFromAngle(area_angle + 90,random(-area_distance_2/2,area_distance_2/2),true)
			cx = cx + px
			cy = cy + py
			far_enough = true
			for i,item in ipairs(objects) do
				assert(item.shape ~= nil,string.format("function findClearSpot expects an object list table where each item in the table is identified by shape, but item index %s's shape was nil",i))
				assert(valid_table_item_shapes[item.shape] == nil,string.format("function findClearSpot expects a valid shape in the object list table item index %i, but got %s instead",i,item.shape))
				if item.shape == "circle" then
					assert(type(item.obj)=="table",string.format("function findClearSpot expects a space object or table as the object in the object list table item index %i, but got a %s instead",i,type(item.obj)))
					local ix, iy = item.obj:getPosition()
					assert(type(item.dist)=="number",string.format("function findClearSpot expects a distance number as the dist value in the object list table item index %i, but got a %s instead",i,type(item.dist)))
					local comparison_dist = item.dist
					if placing_station ~= nil then
						if placing_station then
							if isObjectType(item.obj,"SpaceStation") then
								comparison_dist = 12000
							end
						end
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
		if placement_area == "Inner Circle" then
			eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.radius,nil,nil,asteroid_size)
--torus			eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.inner_radius,area.outer_radius,nil,asteroid_size)
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
		["Rocky"] =	random(2000,5000),
		["Gas"] = 	random(5000,12000),
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
	if placement_area == "Inner Circle" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.radius,nil,nil,radius)
--torus		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.inner_radius,area.outer_radius,nil,radius)
	end
	if eo_x ~= nil then
		if terrain.obj == WormHole then
			local we_x, we_y = nil
			local count_repeat_loop = 0
			repeat
				if placement_area == "Inner Circle" then
					we_x, we_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.radius,nil,nil,500)
--torus					we_x, we_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.inner_radius,area.outer_radius,nil,500)
				end
				count_repeat_loop = count_repeat_loop + 1
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
			local hi_range = 30000
			local lo_impact = 10000
			local hi_impact = 20000
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
				local x,y = findClearSpot(asteroid_field,"circle",eo_x,eo_y,field_size,nil,nil,asteroid_size)
--torus				local x,y = findClearSpot(asteroid_field,"bell torus",eo_x,eo_y,field_size,distort_bell,nil,asteroid_size)
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
				elseif terrain.obj == Planet then
					if gas_lo == nil then
						gas_lo = 1
						gas_hi = 3
						rock_lo = 4
						rock_hi = 6
					end
					if terrain.desc == "Rocky" then
						planet_index = math.random(rock_lo,rock_hi)
						rock_hi = rock_hi - 1
					elseif terrain.desc == "Gas" then
						planet_index = math.random(gas_lo,gas_hi)
						gas_hi = gas_hi - 1
						rock_lo = rock_lo - 1
						rock_hi = rock_hi - 1
					end
					local selected_planet = planet_list[planet_index]
					table.remove(planet_list,planet_index)
					object:setPlanetRadius(radius):setDistanceFromMovementPlane(-radius*.35)
					if random(1,100) < 43 then
						object:setDistanceFromMovementPlane(radius*.35)
					end
					object:setCallSign(tableSelectRandom(selected_planet.name))
					object:setPlanetSurfaceTexture(selected_planet.texture.surface)
					if selected_planet.texture.atmosphere ~= nil then
						object:setPlanetAtmosphereTexture(selected_planet.texture.atmosphere)
					end
					if selected_planet.texture.cloud ~= nil then
						object:setPlanetCloudTexture(selected_planet.texture.cloud)
					end
					if selected_planet.color ~= nil then
						object:setPlanetAtmosphereColor(selected_planet.color.red,selected_planet.color.green,selected_planet.color.blue)
					end
					if terrain.desc == "Rocky" then
						object:setAxialRotationTime(random(350,500))
					elseif terrain.desc == "Gas" then
						object:setAxialRotationTime(random(500,1000))
					end
					if dangerous_planets then
						table.insert(collision_planets,object)
					end
				elseif terrain.obj == SupplyDrop then
					local supply_types = {"energy", "ordnance", "coolant", "repair crew", "probes", "hull", "jump charge"}
					local supply_type = tableSelectRandom(supply_types)
					object:setScanningParameters(math.random(1,2),math.random(1,2)):setFaction(player_faction)
					if supply_type == "energy" then
						local energy_boost = random(300,800)
						object:setEnergy(energy_boost)
						object:setDescriptions(_("scienceDescription-supplyDrop","Supply Drop"),string.format(_("scienceDescription-supplyDrop","%i energy boost supply drop."),math.floor(energy_boost)))
					elseif supply_type == "ordnance" then
						local ordnance_types = {"Homing", "Nuke", "Mine", "EMP", "HVLI"}
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
					object:setLifetime(30*60):setOwner(owner):setTarget(eo_x,eo_y):setPosition(s_x,s_y)
					object:onExpiration(probeExpired)
					object:onDestruction(probeDestroyed)
					object = VisualAsteroid():setPosition(eo_x,eo_y)
				elseif terrain.obj == WarpJammer then
					local closest_station_distance = 999999
					local closest_station = nil
					local station_pool = getStationPool(placement_area)
					for i, station in ipairs(station_pool) do
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
function randomTransportType()
	local transport_type = {"Personnel","Goods","Garbage","Equipment","Fuel"}
	local freighter_engine = "Freighter"
	local freighter_size = math.random(1,5)
	if random(1,100) < 30 then
		freighter_engine = "Jump Freighter"
		freighter_size = math.random(3,5)
	end
	local transport_template = string.format("%s %s %i",tableSelectRandom(transport_type),freighter_engine,freighter_size)
	return CpuShip():setTemplate(transport_template):setCommsScript(""):setCommsFunction(commsShip), freighter_size
end
--	Dynamic terrain probes
function probeExpired(self)
	if probe_respawn == nil then
		probe_respawn = {}
	end
	local station_owner = self:getOwner()
	local target_x, target_y = self:getTarget()
	table.insert(probe_respawn,{time=getScenarioTime() + random(60,240),owner=station_owner,x=target_x,y=target_y})
end
function probeDestroyed(self,instigator)
	if probe_respawn == nil then
		probe_respawn = {}
	end
	local station_owner = self:getOwner()
	local target_x, target_y = self:getTarget()
	table.insert(probe_respawn,{time=getScenarioTime() + random(60,240),owner=station_owner,x=target_x,y=target_y,instigator=instigator})
end
--	Maintenance
function respawnProbe()
	if probe_respawn ~= nil then
		if #probe_respawn > 0 then
			for i,info in ipairs(probe_respawn) do
				if getScenarioTime() > info.time then
					if info.instigator ~= nil and info.instigator:isValid() then
						if info.owner ~= nil and info.owner:isValid() then
							local s_x, s_y = info.owner:getPosition()
							local t_x, t_y = info.instigator:getPosition()
							local probe = ScanProbe():setLifetime(random(10,30)*60):setOwner(info.owner):setTarget(t_x,t_y):setPosition(s_x,s_y)
							probe:onExpiration(probeExpired)
							probe:onDestruction(probeDestroyed)
						end
					else
						if info.owner ~= nil and info.owner:isValid() then
							local s_x, s_y = info.owner:getPosition()
							local probe = ScanProbe():setLifetime(random(10,30)*60):setOwner(info.owner):setTarget(info.x,info.y):setPosition(s_x,s_y)
							probe:onExpiration(probeExpired)
							probe:onDestruction(probeDestroyed)
						end
					end
					probe_respawn[i] = probe_respawn[#probe_respawn]
					probe_respawn[#probe_respawn] = nil
					break
				end
			end
		end
	end
	maintenancePlot = warpJammerMaintenance
end
function warpJammerMaintenance()
	if #warp_jammer_list > 0 then
		for wj_index, wj in ipairs(warp_jammer_list) do
			if wj ~= nil and wj:isValid() then
				if wj.reset_time ~= nil then
					if getScenarioTime() > wj.reset_time then
						wj:setRange(wj.range)
						wj.reset_time = nil
					end
				end
			else
				warp_jammer_list[wj_index] = warp_jammer_list[#warp_jammer_list]
				warp_jammer_list[#warp_jammer_list] = nil
				break
			end
		end
	end
	maintenancePlot = transportCommerceMaintenance
end
function transportCommerceMaintenance()
	if cleanList(transport_list) then
		for i,transport in ipairs(transport_list) do
			local temp_faction = transport:getFaction()
			local transport_target = nil
			local docked_with = transport:getDockedWith()
			if docked_with ~= nil then
				if transport.undock_timer == nil then
					transport.undock_timer = getScenarioTime() + random(10,25)
				elseif getScenarioTime() > transport.undock_timer then
					transport.undock_timer = nil
					transport_target = pickTransportTarget(transport)
					if transport_target ~= nil then
						transport:setFaction("Independent")
						transport:orderDock(transport_target)
						transport:setFaction(temp_faction)
					end
				end
			else
				if string.find("Dock",transport:getOrder()) then
					transport_target = transport:getOrderTarget()
					if transport_target == nil or not transport_target:isValid() then
						transport_target = pickTransportTarget(transport)
						if transport_target ~= nil then
							transport:setFaction("Independent")
							transport:orderDock(transport_target)
							transport:setFaction(temp_faction)
						end
					end
				else
					transport_target = pickTransportTarget(transport)
					if transport_target ~= nil then
						transport:setFaction("Independent")
						transport:orderDock(transport_target)
						transport:setFaction(temp_faction)
					end
				end
			end
		end
		if transport_population_time == nil then
			transport_population_time = getScenarioTime() + random(60,300)
		else
			if getScenarioTime() > transport_population_time then
				if cleanList(inner_stations) then
					transport_population_time = nil
					if #inner_stations > #transport_list then
						local ship, ship_size = randomTransportType()
						local faction_list = {}
						for i,station in ipairs(inner_stations) do
							local station_faction = station:getFaction()
							local already_recorded = false
							for j,faction in ipairs(faction_list) do
								if faction == station_faction then
									already_recorded = true
									break
								end
							end
							if not already_recorded then
								table.insert(faction_list,station_faction)
							end
						end
						ship:setFaction(tableSelectRandom(faction_list))
						local t_x, t_y = vectorFromAngle(random(0,360),120000)
						ship:setPosition(t_x + center_x, t_y + center_y)
						ship:setCallSign(generateCallSign(nil,ship:getFaction()))
						table.insert(transport_list,ship)
					end
				end
			end
		end
	end
	maintenancePlot = stationDefenseFleet
end
function stationDefenseFleet()
	if cleanList(inner_stations) then
		for i,station in ipairs(inner_stations) do
			if station:areEnemiesInRange(8000) and station ~= gauntlet_station then
				local objects = station:getObjectsInRange(8000)
				for j,obj in ipairs(objects) do
					if obj:isEnemy(station) and (isObjectType(obj,"CpuShip") or isObjectType(obj,"PlayerSpaceship")) then
						if station.defense_fleet == nil then
							station.defense_fleet = {}
							station.defense_fleet_time = getScenarioTime() + random(3,10)
						end
						if cleanList(station.defense_fleet) then
							if #station.defense_fleet < 2 then
								if station.defense_fleet_time == nil then
									station.defense_fleet_time = getScenarioTime() + random(180,300)
								elseif getScenarioTime() > station.defense_fleet_time then
									local x, y = station:getPosition()
									fleetSpawnFaction = station:getFaction()
									local fleet = spawnRandomArmed(x,y,25)
									for i,ship in ipairs(fleet) do
										ship:orderDefendTarget(station)
										table.insert(station.defense_fleet,ship)
									end
									station.defense_fleet_time = nil
								end
							end
						end
					end
				end
			end
		end
	end
	maintenancePlot = respawnProbe
end
function pickTransportTarget(transport)
	local transport_target = nil
	if cleanList(inner_stations) then
		local station_pool = {}
		for i,station in ipairs(inner_stations) do
			if not station:isEnemy(transport) then
				table.insert(station_pool,station)
			end
		end
		transport_target = tableSelectRandom(station_pool)
	end
	return transport_target
end
--	Sensor jammer utilities
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
			if distance_diagnostic then
				print("distance_diagnostic 13: p, sensor_jammer: update player long range sensors, sensor jammer:",p:getCallSign(),jammer_name)
			end
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
				if distance_diagnostic then
					local bp_x, bp_y = boost_probe:getPosition()
					print("distance_diagnostic 14: boost_probe, p: update player long range sensors, boost probe:",bp_x, bp_y,p:getCallSign())
				end
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
--	Communication
function scenarioMissionsUndocked()
	if explain_cyber_missile then
		cyberExplainComms()
	end
end
function scenarioInformation()
	if explain_cyber_missile then
		cyberExplainComms()
	end
end
function cyberExplainComms()
	addCommsReply(_("cyberCodesMissiles-comms","Explain Cyber Codes and Cyber Missiles"),function()
		setCommsMessage(string.format(_("cyberCodesMissiles-comms","After studying your telemetry and database, the scientists on station %s suggested a system on your ship to defeat the Exuari field generators at least in part. Your engineers, scientists, and probe technicians worked together to implement the suggestions."),home_station:getCallSign()))
		addCommsReply(_("cyberCodesMissiles-comms","My officers are asking about Cyber Codes"),function()
			setCommsMessage(_("cyberCodesMissiles-comms","Cyber Codes are added to a specialized database in engineering when an Exuari ship system is 100% hacked."))
			addCommsReply(_("cyberCodesMissiles-comms","What are they used for?"),function()
				setCommsMessage(_("cyberCodesMissiles-comms","They are used to program a Cyber Missile to inject a virus into an Exuari field generator to disable its ability to damage a ship system. (see Cyber Missile explanation)"))
				addCommsReply(_("Back"), commsStation)
			end)
			addCommsReply(_("cyberCodesMissiles-comms","Can they be reused?"),function()
				setCommsMessage(_("cyberCodesMissiles-comms","No. One code per missile."))
				addCommsReply(_("Back"), commsStation)
			end)
			addCommsReply(_("cyberCodesMissiles-comms","Can more than one officer hack an enemy ship simultaneously?"),function()
				setCommsMessage(_("cyberCodesMissiles-comms","Yes. If an officer's primary responsibility is not Relay, we recommend they use the Strategic Map console to hack an enemy to avoid conflict with Relay."))
				addCommsReply(_("Back"), commsStation)
			end)
			addCommsReply(_("cyberCodesMissiles-comms","Can we get more than one code from an enemy ship?"),function()
				setCommsMessage(_("cyberCodesMissiles-comms","There should be a code in each of the enemy systems you are able to hack."))
				addCommsReply(_("Back"), commsStation)
			end)
			addCommsReply(_("Back"), commsStation)
		end)
		addCommsReply(_("cyberCodesMissiles-comms","What are Cyber Missiles?"),function()
			setCommsMessage(_("cyberCodesMissiles-comms","Cyber Missiles are scan probes reprogrammed to go to an Exuari field generator and inject a Cyber Code virus to disable the field's ability to damage a ship system."))
			addCommsReply(_("cyberCodesMissiles-comms","How do I pick the field generator to target?"),function()
				setCommsMessage(_("cyberCodesMissiles-comms","The probe serving as the Cyber Missile is programmed to travel to the nearest field generator at the time it's launched."))
				addCommsReply(_("Back"), commsStation)
			end)
			addCommsReply(_("cyberCodesMissiles-comms","Which officer launches the Cyber Missile/probe?"),function()
				setCommsMessage(_("cyberCodesMissiles-comms","The weapons or tactical officer launches the Cyber Missile."))
				addCommsReply(_("cyberCodesMissiles-comms","And how do they do that?"),function()
					setCommsMessage(_("cyberCodesMissiles-comms","When the conditions are right (have at least one Cyber Code, have at least one probe, are within ten units of an Exuari field generator), a button will appear on the weapons console or the tactical console. They click it to launch."))
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(_("Back"), commsStation)
			end)
			addCommsReply(_("cyberCodesMissiles-comms","How close does the ship have to be to launch a Cyber Missile?"),function()
				setCommsMessage(_("cyberCodesMissiles-comms","The ship needs to be within ten units of a field generator in order to launch a Cyber Missile."))
				addCommsReply(_("Back"), commsStation)
			end)
			addCommsReply(_("cyberCodesMissiles-comms","What if we run out of probes?"),function()
				setCommsMessage(_("cyberCodesMissiles-comms","The button will not be presented to weapons or tactical if the ship does not have any probes in stock."))
				addCommsReply(_("Back"), commsStation)
			end)
			addCommsReply(_("cyberCodesMissiles-comms","Can a Cyber Missile be launched while we're in warp?"),function()
				setCommsMessage(_("cyberCodesMissiles-comms","Yes, if the launch button is present."))
				addCommsReply(_("Back"), commsStation)
			end)
			addCommsReply(_("Back"), commsStation)
		end)
		addCommsReply(_("Back"), commsStation)
	end)
end
function scenarioMissions()
	local presented = 0
	return presented
end
function scenarioShipEnhancements()
	if probe_upgrade_station == nil then
		local station_pool = {}
		for i,station in ipairs(inner_stations) do
			if station ~= nil and station:isValid() and not station:isEnemy(comms_source) then
				table.insert(station_pool,station)
			end
		end
		probe_upgrade_station = tableRemoveRandom(station_pool)
		sensor_upgrade_station = tableRemoveRandom(station_pool)
		jump_upgrade_station = tableRemoveRandom(station_pool)
	end
	if comms_target == probe_upgrade_station and comms_source.probe_upgrade == nil then
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
	if comms_target == sensor_upgrade_station and comms_source.sensor_upgrade == nil then
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
	if comms_target == jump_upgrade_station and comms_source.jump_upgrade == nil then
		addCommsReply(_("upgrade-comms","Check on jump drive availability"),function()
			setCommsMessage(_("upgrade-comms","Jonathan Rogers, our resident engine systems specialist has three jump drives not being used. He could install one of them on your ship. One is a Repulse Rabbit XR5, one is a Vesta UK41, and the third is a Ketrik Presence D8"))
			if comms_target.jump_upgrades == nil then
				comms_target.jump_upgrades = {
					{long = 50000,	short = 5000,	adjacent = true,	charged = true},
					{long = 100000, short = 5000,	adjacent = false,	charged = true},
					{long = 150000,	short = 10000,	adjacent = false,	charged = false},
				}
			end
			addCommsReply(_("upgrade-comms","Tell me about the Repulse Rabbit XR5"),function()
				if comms_target.repulse == nil then
					comms_target.repulse = tableRemoveRandom(comms_target.jump_upgrades)
				end
				local charge = _("upgrade-comms","comes fully")
				if not comms_target.repulse.charged then
					charge = _("upgrade-comms","is not")
				end
				local adjacent = _("upgrade-comms","but cannot be")
				if comms_target.repulse.adjacent then
					adjacent = _("upgrade-comms","and can be")
				end
				setCommsMessage(string.format(_("upgrade-comms","The Repulse Rabbit XR5 has a long jump range of up to %i units, minimum jump range of %i units, %s charged, %s installed alongside your warp drive."),comms_target.repulse.long/1000, comms_target.repulse.short/1000, charge, adjacent))
				addCommsReply(_("upgrade-comms","Install the Repulse Rabbit XR5 jump drive"),function()
					comms_source.jump_upgrade = true
					comms_source:setJumpDrive(true):setJumpDriveRange(comms_target.repulse.short,comms_target.repulse.long)
					if comms_target.repulse.charged then
						comms_source:setJumpDriveCharge(comms_target.repulse.long)
					else
						comms_source:setJumpDriveCharge(0)
					end
					if not comms_target.repulse.adjacent then
						comms_source:setWarpDrive(false)
					end
					setCommsMessage(_("upgrade-comms","Jonathan Rogers has installed a Repulse Rabbit XR5 jump drive"))
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(_("Back"), commsStation)
			end)
			addCommsReply(_("upgrade-comms","The Vesta UK41 sounds interesting"),function()
				if comms_target.vesta == nil then
					comms_target.vesta = tableRemoveRandom(comms_target.jump_upgrades)
				end
				local charge = _("upgrade-comms","comes fully")
				if not comms_target.vesta.charged then
					charge = _("upgrade-comms","is not")
				end
				local adjacent = _("upgrade-comms","but cannot be")
				if comms_target.vesta.adjacent then
					adjacent = _("upgrade-comms","and can be")
				end
				setCommsMessage(string.format(_("upgrade-comms","The Vesta UK41 has a long jump range of up to %i units, minimum jump range of %i units, %s charged, %s installed alongside your warp drive."),comms_target.vesta.long/1000, comms_target.vesta.short/1000, charge, adjacent))
				addCommsReply(_("upgrade-comms","Install the Vesta UK41 jump drive"),function()
					comms_source.jump_upgrade = true
					comms_source:setJumpDrive(true):setJumpDriveRange(comms_target.vesta.short,comms_target.vesta.long)
					if comms_target.vesta.charged then
						comms_source:setJumpDriveCharge(comms_target.vesta.long)
					else
						comms_source:setJumpDriveCharge(0)
					end
					if not comms_target.vesta.adjacent then
						comms_source:setWarpDrive(false)
					end
					setCommsMessage(_("upgrade-comms","Jonathan Rogers has installed a Vesta UK41 jump drive"))
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(_("Back"), commsStation)
			end)
			addCommsReply(_("upgrade-comms","What do you know of the Ketrik Presence D8"),function()
				if comms_target.ketrik == nil then
					comms_target.ketrik = tableRemoveRandom(comms_target.jump_upgrades)
				end
				local charge = _("upgrade-comms","comes fully")
				if not comms_target.ketrik.charged then
					charge = _("upgrade-comms","is not")
				end
				local adjacent = _("upgrade-comms","but cannot be")
				if comms_target.ketrik.adjacent then
					adjacent = _("upgrade-comms","and can be")
				end
				setCommsMessage(string.format(_("upgrade-comms","The Ketrik Presence D8 has a long jump range of up to %i units, minimum jump range of %i units, %s charged, %s installed alongside your warp drive."),comms_target.ketrik.long/1000, comms_target.ketrik.short/1000, charge, adjacent))
				addCommsReply(_("upgrade-comms","Install the Ketrik Presence D8 jump drive"),function()
					comms_source.jump_upgrade = true
					comms_source:setJumpDrive(true):setJumpDriveRange(comms_target.ketrik.short,comms_target.ketrik.long)
					if comms_target.ketrik.charged then
						comms_source:setJumpDriveCharge(comms_target.ketrik.long)
					else
						comms_source:setJumpDriveCharge(0)
					end
					if not comms_target.ketrik.adjacent then
						comms_source:setWarpDrive(false)
					end
					setCommsMessage(_("upgrade-comms","Jonathan Rogers has installed a Ketrik Presence D8 jump drive"))
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
						for k,station in ipairs(message_stations) do
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
--	Updates
function planetCollisionDetection()
	local planet_bump_damage = 5
	for planet_index, planet in ipairs(collision_planets) do
		local planet_x, planet_y = planet:getPosition()
		local collision_list = getObjectsInRadius(planet_x, planet_y, planet:getPlanetRadius() + 2000)
		local obj_dist = 0
		local ship_distance = 0
		local obj_type_name = ""
		for i, obj in ipairs(collision_list) do
			if obj:isValid() then
				obj_dist = distance(obj,planet)
				if isObjectType(obj,"CpuShip") then
					obj_type_name = obj:getTypeName()
					if obj_type_name ~= nil then
						ship_distance = shipTemplateDistance[obj:getTypeName()]
						if ship_distance == nil then
							ship_distance = 400
						end
					else
						ship_distance = 400
					end
					if obj_dist <= (planet:getPlanetRadius() + ship_distance + 100) then
						obj:takeDamage(planet_bump_damage,"kinetic",planet_x,planet_y)
					end
				end
				if isObjectType(obj,"PlayerSpaceship") then
					obj_type_name = obj:getTypeName()
					if obj_type_name ~= nil then
						ship_distance = player_ship_stats[obj:getTypeName()].distance
						if ship_distance == nil then
							ship_distance = 400
						end
					else
						ship_distance = 400
					end
					if obj_dist <= (planet:getPlanetRadius() + ship_distance + 100) then
						obj:takeDamage(planet_bump_damage,"kinetic",planet_x,planet_y)
					end
				end
			end
		end
	end
end
function continuousAttack()
	if getScenarioTime() > attack_delay then
		local fleet = {}
		fleetSpawnFaction = "Exuari"
		if #gauntlet_defense_fleet < 3 then
			fleet = spawnRandomArmed(gauntlet_station_x,gauntlet_station_y)
			for i,ship in ipairs(fleet) do
				ship:orderDefendTarget(gauntlet_station)
				ship.codes = {}
				table.insert(gauntlet_defense_fleet,ship)
				table.insert(code_bearers,ship)
			end
			if getScenarioTime() < 30 then
				attack_delay = getScenarioTime() + 5
			end
		elseif #code_bearers < 20 then
			fleet = spawnRandomArmed(gauntlet_station_x,gauntlet_station_y)
			for i,ship in ipairs(fleet) do
				ship:orderFlyTowards(center_x,center_y)
				ship.codes = {}
				table.insert(code_bearers,ship)
			end
		end
		if getScenarioTime() > attack_delay then
			local average_player_ship_distance = 0
			for i,p in ipairs(getActivePlayerShips()) do
				average_player_ship_distance = distance(p,gauntlet_station)
			end
			average_player_ship_distance = average_player_ship_distance/#getActivePlayerShips()
			if average_player_ship_distance < 20000 then
				attack_delay = getScenarioTime() + max_delay
			elseif average_player_ship_distance > 60000 then
				attack_delay = getScenarioTime() + min_delay
			else
				attack_delay = getScenarioTime() + random(min_delay,max_delay)
			end
		end
	end
end
function finalStats()
	local final_message = ""
	--main messages here
	if deployed_player_count > 1 then
		final_message = string.format(_("msgMainscreen","%s\nDeployed %s player ships."),final_message,deployed_player_count)
	else
		final_message = string.format(_("msgMainscreen","%s\nDeployed one player ship."),final_message)
	end
	local remaining_ga_count = 0
	for i,ga in ipairs(gauntlet_artifacts) do
		if ga ~= nil and ga:isValid() then
			if not isObjectType(ga,"WarpJammer") then
				remaining_ga_count = remaining_ga_count + 1
			end
		end
	end
	if remaining_ga_count < 10 then
		if remaining_ga_count == 0 then
			final_message = string.format(_("msgMainscreen","%s\nAll Exuari field generators destroyed."),final_message)
		else
			final_message = string.format(_("msgMainscreen","%s\n%i out of 10 Exuari field generators remain."),final_message,remaining_ga_count)
		end
	end
	final_message = string.format(_("msgMainscreen","%s\nTime spent: %s"),final_message,formatTime(getScenarioTime()))
	final_message = string.format(_("msgMainscreen","%s\nRespawn:%s"),final_message,getScenarioSetting("Respawn"))
	final_message = string.format(_("msgMainscreen","%s\nMurphy:%s Enemies:%s"),final_message,getScenarioSetting("Murphy"),getScenarioSetting("Enemies"))
	return final_message
end
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
function updateGauntletOrbits(delta)
	if cleanList(gauntlet_artifacts) then
		for i,obj in ipairs(gauntlet_artifacts) do
			obj.angle = (obj.angle + delta/gauntlet_orbit_time)%360
			local x, y = vectorFromAngle(obj.angle,15000,true)
			obj:setPosition(x + gauntlet_station_x, y + gauntlet_station_y)
		end
	end
end
function checkGauntletZones(p)
	if cleanList(gauntlet_artifacts) then
		for i,ga in ipairs(gauntlet_artifacts) do
			if not isObjectType(ga,"WarpJammer") then
				if ga.zone ~= nil and ga.zone:isInside(p) then
					explain_cyber_missile = true
					for j,sys in ipairs(ga.impact_systems) do
						if sys == "hull" then
							local hull_points = p:getHullMax()*system_impact
							p:setHull(p:getHull() - hull_points)
						elseif sys == "power" then
							local power_points = p:getMaxEnergy()*system_impact
							p:setEnergy(p:getEnergy() - power_points)
						else
							if p:hasSystem(sys) then
								p:setSystemHealth(sys,p:getSystemHealth(sys) - system_impact)
							end
						end
					end
				end
			end
		end
	end
end
function checkHackingCodeGathering()
	if cleanList(code_bearers) then
		for i,ship in ipairs(code_bearers) do
			for j,sys in ipairs(system_types) do
				if ship.codes[sys] == nil then
					if ship:getSystemHackedLevel(sys) == 1 then
						local p = getPlayerShip(-1)
						if #getActivePlayerShips() > 1 then
							for i,ap in ipairs(getActivePlayerShips()) do
								if distance(ship,ap) < distance(ship,p) then
									p = ap
								end
							end
						end
						if p.codes == nil then
							p.codes = 0
						end
						p.codes = p.codes + 1
						ship.codes[sys] = true
						break
					end
				end
			end
		end
	end
end
function cyberMissileLaunchButton(p)
	if p.codes ~= nil and p.codes > 0 then
		if cleanList(gauntlet_artifacts) then
			selected_ga = nil
			for i,ga in ipairs(gauntlet_artifacts) do
				if not isObjectType(ga,"WarpJammer") then
					local dist = distance(p,ga)
					local closest = 15000
					if dist < 10000 then
						explain_cyber_missile = true
						if dist < closest then
							selected_ga = ga
							closest = dist
						end
					end
				end
			end
			if selected_ga == nil or p:getScanProbeCount() < 1 then
				p:removeCustom("launch_cyber_missile_wea")
				p:removeCustom("launch_cyber_missile_tac")
			else
				explain_cyber_missile = true
				p:addCustomButton("Weapons","launch_cyber_missile_wea","Launch Cyber Missile",function()
					string.format("")
					launchCyberMissile(p,selected_ga)
				end,9)
				p:addCustomButton("Tactical","launch_cyber_missile_tac","Launch Cyber Missile",function()
					string.format("")
					launchCyberMissile(p,selected_ga)
				end,9)
			end
		end
	end
end
function launchCyberMissile(p,ga)
	string.format("")
	p.codes = p.codes - 1
	p:setScanProbeCount(p:getScanProbeCount() - 1)
	local px, py = p:getPosition()
	local gx, gy = ga:getPosition()
	local cm = ScanProbe():setPosition(px,py):setTarget(gx,gy):setOwner(p):onArrival(detonateCyberMissile)
	cm.ga = ga
	table.insert(cyber_missiles,cm)
end
function steerCyberMissile()
	if cleanList(cyber_missiles) then
		for i,m in ipairs(cyber_missiles) do
			if m.ga:isValid() then
				local gx, gy = m.ga:getPosition()
				m:setTarget(gx,gy)
			end
		end
	end
end
function detonateCyberMissile(self,x,y)
	string.format("")
	if self.ga:isValid() then
		local removed_system = tableRemoveRandom(self.ga.impact_systems)
		local p = self:getOwner()
		if removed_system ~= nil then
			p:addCustomMessage("Relay","detonation_results_message_rel",string.format("The cyber missile successfully removed %s from the list of systems the field generator impacts.",removed_system))
			p:addCustomMessage("Operations","detonation_results_message_ops",string.format("The cyber missile successfully removed %s from the list of systems the field generator impacts.",removed_system))
		else
			p:addCustomMessage("Relay","detonation_results_message_rel","The field generator had no system to remove. Its fangs had already been pulled.")
			p:addCustomMessage("Operations","detonation_results_message_ops","The field generator had no system to remove. Its fangs had already been pulled.")
		end
		local impacted_systems_list = ""
		for j,sys in ipairs(self.ga.impact_systems) do
			impacted_systems_list = string.format("%s %s",impacted_systems_list,pretty_system[sys])
		end
		if #self.ga.impact_systems > 1 then
			impacted_systems_list = string.format(_("scienceDescription-artifact","Field Generator. Systems impacted:%s"),impacted_systems_list)
		else
			if #self.ga.impact_systems == 1 then
				impacted_systems_list = string.format(_("scienceDescription-artifact","Field Generator. System impacted:%s"),impacted_systems_list)			
			else
				impacted_systems_list = _("scienceDescription-artifact","Field Generator. No Systems impacted.")
			end
		end
		self.ga:setDescriptions(_("scienceDescription-artifact","Field Generator"),impacted_systems_list)
		if #self.ga.impact_systems < 1 then
			self.ga.death_knell = true
		end
		self:destroy()
	end
end
function codeCounts(p)
	if p.codes ~= nil and p.codes > 0  then
		explain_cyber_missile = true
		p:addCustomInfo("Engineering","show_code_count_eng",string.format("Cyber Codes: %s",p.codes),8)
		p:addCustomInfo("Engineering+","show_code_count_epl",string.format("Cyber Codes: %s",p.codes),8)
	else
		p:removeCustom("show_code_count_eng")
		p:removeCustom("show_code_count_epl")
	end
end
function updateGauntletZones(delta)
	if cleanList(gauntlet_artifacts) then
		for i,obj in ipairs(gauntlet_artifacts) do
			if isObjectType(obj,"WarpJammer") then
				local gw = obj
				gw:setRange(gw:getRange() + gw.range_delta)
				if gw:getRange() < gw.range_min then
					gw.range_delta = random(1,20)
				elseif gw:getRange() > gw.range_max then
					gw.range_delta = random(1,20) * -1
				end
				--obj:setRange(gauntlet_range + random(-2000,2000))
			else
				local ga = obj
				local ga_x, ga_y = ga:getPosition()
				ga.rad_w = ga.rad_w + ga.rad_w_delta
				if ga.rad_w < ga.min_rad_w then
					ga.rad_w_delta = random(1,20)
				elseif ga.rad_w > ga.max_rad_w then
					ga.rad_w_delta = random(1,20) * -1
				end
				ga.rad_h = ga.rad_h + ga.rad_h_delta
				if ga.rad_h < ga.min_rad_h then
					ga.rad_h_delta = random(1,20)
				elseif ga.rad_h > ga.max_rad_h then
					ga.rad_h_delta = random(1,20) * -1
				end
				if ga.death_knell then
					if ga.zone_color.r < 255 then
						ga.zone_color.r = ga.zone_color.r + 1
					elseif ga.zone_color.g < 255 then
						ga.zone_color.g = ga.zone_color.g + 1
					elseif ga.zone_color.b < 255 then
						ga.zone_color.b = ga.zone_color.b + 1
					else
						local ex, ey = ga:getPosition()
						ExplosionEffect():setPosition(ex,ey):setSize(2500):setOnRadar(true)
						ElectricExplosionEffect():setPosition(ex,ey):setSize(3000):setOnRadar(true)
						ga.zone:destroy()
						ga:destroy()
					end
					if ga:isValid() then
						ga:setRadarTraceColor(ga.zone_color.r,ga.zone_color.g,ga.zone_color.b)
					end
				end
				if ga:isValid() then
					local ga_zone = Zone():setPoints(
						ga_x - ga.rad_w,	ga_y - ga.rad_h,
						ga_x + ga.rad_w,	ga_y - ga.rad_h,
						ga_x + ga.rad_w,	ga_y + ga.rad_h,
						ga_x - ga.rad_w,	ga_y + ga.rad_h
					):setColor(ga.zone_color.r,ga.zone_color.g,ga.zone_color.b)
					local old_zone = ga.zone
					ga.zone = ga_zone
					if old_zone ~= nil then
						old_zone:destroy()
					end
				end
			end
		end
	end
end
function update(delta)
	if delta == 0 then
		return
	end
	--	game is no longer paused
	--	initial mission message
	if initial_mission_message == nil then
		local player_message = _("goal-incCall","Find and destroy the Exuari station that keeps sending out ships to attack us. They have some kind of new technology that is empowering them with a sense of impunity.")
		table.insert(messages,{msg=player_message,list={}})
		local messages_index = #messages
		for i,p in ipairs(getActivePlayerShips()) do
			table.insert(messages[messages_index].list,p)
		end
		primary_orders = _("orders-comms","Find and destroy the attacking Exuari station.")
		initial_mission_message = "sent"
	end
	if gauntlet_station == nil or not gauntlet_station:isValid() then
		globalMessage(string.format(_("msgMainscreen","You have destroyed that pesky Exuari station!\n%s"),finalStats()))
		victory(player_faction)
	end
	if home_station == nil or not home_station:isValid() then
		globalMessage(string.format(_("msgMainscreen","Your home station has been destroyed.\n%s"),finalStats()))
		victory("Exuari")
	end
	for i,p in ipairs(getActivePlayerShips()) do
		checkGauntletZones(p)
		codeCounts(p)
		cyberMissileLaunchButton(p)
		updatePlayerLongRangeSensors(delta,p)
	end
	if maintenancePlot ~= nil then
		maintenancePlot()
	end
	planetCollisionDetection()
	steerCyberMissile()
	continuousAttack()
	checkHackingCodeGathering()
	messagePlayers()
	updateGauntletOrbits(delta)
	updateGauntletZones(delta)
end
