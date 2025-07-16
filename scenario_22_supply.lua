-- Name: Solar System Supply Run
-- Description: Deliver supplies throughout the solar system
---
--- Designed for 1 player ship
---
--- Version 1
---
--- USN Discord: https://discord.gg/PntGG3a where you can join a game online. There's usually one every weekend. All experience levels are welcome. 
-- Type: Mission
-- Author: Xansta, Iñaki
-- Setting[Respawn]: Configures whether the player ship automatically respawns in game or not and how often if it does automatically respawn
-- Respawn[None|Default]: Player ship does not automatically respawn
-- Respawn[One]: Player ship will automatically respawn once
-- Respawn[Two]: Player ship will automatically respawn twice
-- Respawn[Three]: Player ship will automatically respawn thrice
-- Respawn[Infinite]: Player ship will automatically respawn forever
-- Setting[Alignment]: Configures whether and how the planets are aligned at the start of the game
-- Alignment[Full]: Planets are on a line at the start of the game
-- Alignment[Majority|Default]: Planets are close to being on a line at the start of a game
-- Alignment[Random]: Planets are only aligned if they happen to be at the start of a game
-- Setting[Belt]: Configures the density of the asteroid belt
-- Belt[Light|Default]: Asteroids are light in the belt
-- Belt[Medium]: Medium asteroid density in the belt
-- Belt[Heavy]: Heavy population of asteroids in the belt
-- Belt[Dense]: Dense asteroids in the belt
-- Belt[Crowded]: Many asteroids in the belt
-- Setting[Delivery]: Allocate time to deliver package from Neptune to Earth. Default is fifteen minutes
-- Delivery[Five]: Players have five minutes to deliver package
-- Delivery[Ten]: Players have ten minutes to deliver package
-- Delivery[Fifteen|Default]: Players have fifteen minutes to deliver package
-- Delivery[Twenty]: Players have twenty minutes to deliver package
-- Delivery[Thirty]: Players have thirty minutes to deliver package
-- Setting[Budget]: Configures how much leeway is given to the players when they purchase nukes for the clean up mission. Default is zero
-- Budget[Zero|Default]: No leeway. The players must match the nukes they purchase to the debris exactly
-- Budget[One]: The players can purchase one extra in case they miss their target
-- Budget[Two]: The players can purchase two extra in case they miss their target
-- Setting[Grunge]: Configures the range of the warp jammers classified as debris. Default is 10 units.
-- Grunge[Dull]: Debris warp jammer range is 7 units
-- Grunge[Dirty|Default]: Debris warp jammer range is 10 units
-- Grunge[Messy]: Debris warp jammer range is 15 units
-- Grunge[Grungy]: Debris warp jammer range is 20 units

require("utils.lua")
require("place_station_scenario_utility.lua")
require("cpu_ship_diversification_scenario_utility.lua")
require("generate_call_sign_scenario_utility.lua")
require("comms_scenario_utility.lua")
require("spawn_ships_scenario_utility.lua")

function init()
	scenario_version = "1.0.9"
	ee_version = "2024.12.08"
	print(string.format("    ----    Scenario: Solar System Supply Run    ----    Version %s    ----    Tested with EE version %s    ----",scenario_version,ee_version))
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
	--[[
	local dead_faction = getFactionInfo("Exuari")
	dead_faction:destroy()
	local dead_faction = getFactionInfo("Kraylor")
	dead_faction:destroy()
	local dead_faction = getFactionInfo("Ktlitans")
	dead_faction:destroy()
	local dead_faction = getFactionInfo("Arlenians")
	dead_faction:destroy()
	local dead_faction = getFactionInfo("Ghosts")
	dead_faction:destroy()
	local dead_faction = getFactionInfo("TSN")
	dead_faction:destroy()
	local dead_faction = getFactionInfo("USN")
	dead_faction:destroy()
	local dead_faction = getFactionInfo("CUF")
	dead_faction:destroy()
	--]]
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
--	stations_support_transport_missions = true
--	stations_support_cargo_missions = true
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
	messages = {}
	reputation_start_amount = 100
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
		_("scienceDescription-buoy","Visit the Proboscis shop for all your specialty probe needs"),
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
				{	name = "Nikawiy",	},
				{	name = "Orkaria",	},
				{	name = "Poerava",	},
				{	name = "Stribor",	},
				{	name = "Taygeta",	},
				{	name = "Tuiren",	},
				{	name = "Ukdah",	},
				{	name = "Wouri",	},
				{	name = "Xihe",	},
				{	name = "Yildun",	},
				{	name = "Zosma",	},
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
	local belt_config = {
		["Light"] = 30,
		["Medium"] = 60,
		["Heavy"] = 100,
		["Dense"] = 160,
		["Crowded"] = 240,
	}
	belt_density = belt_config[getScenarioSetting("Belt")]
	local delivery_time_config = {
		["Five"] = 60*5,
		["Ten"] = 60*10,
		["Fifteen"] = 60*15,
		["Twenty"] = 60*20,
		["Thirty"] = 60*30,
	}
	delivery_time_limit = delivery_time_config[getScenarioSetting("Delivery")]
	local budget_config = {
		["Zero"] = 2,
		["One"] = 1,
		["Two"] = 0,
	}
	budget_allowance = budget_config[getScenarioSetting("Budget")]
	local grunge_config = {
		["Dull"] = 7000,
		["Dirty"] = 10000,
		["Messy"] = 15000,
		["Grungy"] = 20000,
	}
	grunge_range = grunge_config[getScenarioSetting("Grunge")]
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
				local final_message = _("msgMainscreen","All player ships destroyed.")
				final_message = string.format("%s\n%s",final_message,finalStats())
				globalMessage(final_message)
				victory("Kraylor")
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
	transport_list = {}
	--	Sol
	local radius = 80000
	star_sol = Planet():setPosition(center_x,center_y):setCallSign("Sol")
	star_sol:setPlanetRadius(radius):setDistanceFromMovementPlane(-radius*.5)
	if random(1,100) < 43 then
		star_sol:setDistanceFromMovementPlane(radius*.5)
	end
	star_sol:setDescriptions(_("scienceDescription-star","White, spectral type G"),_("scienceDescription-star","White (yellow from Earth), spectral type G2V, surface temperature 5,778 K"))
	star_sol:setPlanetAtmosphereTexture("planets/star-1.png"):setPlanetAtmosphereColor(.5,.5,0)
	--	Mercury
	local mercury_dist = 130000
	local mercury_arc = 90
	if getScenarioSetting("Alignment") == "Majority" then
		mercury_arc = random(45,90)
	elseif getScenarioSetting("Alignment") == "Random" then
		mercury_arc = random(0,360)
	end
	local pm_x, pm_y = vectorFromAngle(mercury_arc,mercury_dist,true)
	planet_mercury = Planet():setCallSign("Mercury"):setPosition(pm_x + center_x, pm_y + center_y)
	planet_mercury:setPlanetRadius(1900):setDistanceFromMovementPlane(-300)
	planet_mercury:setPlanetSurfaceTexture("planets/planet-2.png"):setAxialRotationTime(600)
	planet_mercury:setPlanetAtmosphereColor(.5,.5,0)
	planet_mercury:setOrbit(star_sol,20000)
	--	Mercury mining outpost
	mission_stations = {}
	local station_angle = random(300,340)
	local sm_x, sm_y = vectorFromAngle(station_angle,9000,true)
	sm_x = sm_x + pm_x + center_x
	sm_y = sm_y + pm_y + center_y
	station_mmo = placeStation(sm_x,sm_y,"MMO","USN","Small Station")
	station_mmo.planet = planet_mercury
	station_mmo.planet_angle = station_angle
	station_mmo.planet_distance = 9000
	orbital_stations = {}
	table.insert(orbital_stations,station_mmo)
	table.insert(mission_stations,station_mmo)
	local fast_transport = {800,750,700,650,600}
	local transport, transport_size = randomTransportType()
	transport:setFaction(station_mmo:getFaction())
	if transport:hasJumpDrive() then
		transport:setImpulseMaxSpeed(100)
	else
		transport:setImpulseMaxSpeed(fast_transport[transport_size])
	end
	local td_x, td_y = vectorFromAngle(station_angle,29000,true)
	transport:setPosition(td_x + sm_x, td_y + sm_y)
	table.insert(transport_list,transport)
	--	Pirate patrol
	local ps_x, ps_y = vectorFromAngle(random(0,360),2500)
	local pirate = CpuShip():setTemplate("MT52 Hornet"):setFaction("Kraylor"):setPosition(sm_x + ps_x,sm_y + ps_y):orderDefendTarget(station_mmo)
	--	Player ship
	player_spawn_x = sm_x
	player_spawn_y = sm_y + 25000
	player_faction = "Human Navy"
	player = PlayerSpaceship():setTemplate("Phobos M3P")
	allowNewPlayerShips(false)
	--	Venus
	local venus_dist = mercury_dist + 50000
	local venus_arc = 90
	if getScenarioSetting("Alignment") == "Majority" then
		venus_arc = random(45,90)
	elseif getScenarioSetting("Alignment") == "Random" then
		venus_arc = random(0,360)
	end
	local pv_x, pv_y = vectorFromAngle(venus_arc,venus_dist,true)
	planet_venus = Planet():setCallSign("Venus"):setPosition(pv_x + center_x, pv_y + center_y)
	planet_venus:setPlanetRadius(4750):setDistanceFromMovementPlane(-2000)
	planet_venus:setPlanetSurfaceTexture("planets/planet-2.png"):setAxialRotationTime(800)
	planet_venus:setPlanetAtmosphereColor(1.02,1.5,1.5):setPlanetCloudTexture("planets/clouds-3.png")
	planet_venus:setPlanetAtmosphereTexture("planets/atmosphere.png")
	planet_venus:setOrbit(star_sol,30000)
	--	Venus orbital station one
	station_angle = random(120,165)
	local sv_x, sv_y = vectorFromAngle(station_angle,12000,true)
	sv_x = sv_x + pv_x + center_x
	sv_y = sv_y + pv_y + center_y
	station_vos = placeStation(sv_x,sv_y,"VOS-1","Human Navy","Medium Station")
	station_vos.planet = planet_venus
	station_vos.planet_angle = station_angle
	station_vos.planet_distance = 12000
	table.insert(orbital_stations,station_vos)
	table.insert(mission_stations,station_vos)
	transport, transport_size = randomTransportType()
	transport:setFaction(station_vos:getFaction())
	if transport:hasJumpDrive() then
		transport:setImpulseMaxSpeed(100)
	else
		transport:setImpulseMaxSpeed(fast_transport[transport_size])
	end
	td_x, td_y = vectorFromAngle(station_angle,32000,true)
	transport:setPosition(td_x + sv_x, td_y + sv_y)
	table.insert(transport_list,transport)
	--	Earth
	local earth_dist = venus_dist + 35000
	local earth_arc = 90
	if getScenarioSetting("Alignment") == "Majority" then
		earth_arc = random(45,90)
	elseif getScenarioSetting("Alignment") == "Random" then
		earth_arc = random(0,360)
	end
	local pe_x, pe_y = vectorFromAngle(earth_arc,earth_dist,true)
	planet_earth = Planet():setCallSign("Earth"):setPosition(pe_x + center_x, pe_y + center_y)
	planet_earth:setPlanetRadius(5000):setDistanceFromMovementPlane(-1800)
	planet_earth:setPlanetSurfaceTexture("planets/planet-earth.png"):setAxialRotationTime(900)
	planet_earth:setPlanetAtmosphereColor(.01,.1,.5):setPlanetCloudTexture("planets/clouds-1.png")
	planet_earth:setPlanetAtmosphereTexture("planets/atmosphere.png")
	planet_earth:setOrbit(star_sol,35000)
	--	United Earth Space Agency command
	station_angle = random(155,195)
	local se_x, se_y = vectorFromAngle(station_angle,11000,true)
	se_x = se_x + pe_x + center_x
	se_y = se_y + pe_y + center_y
	station_uesac = placeStation(se_x,se_y,"UESA Command","Human Navy","Large Station")
	station_uesac.planet = planet_earth
	station_uesac.planet_angle = station_angle
	station_uesac.planet_distance = 11000
	table.insert(orbital_stations,station_uesac)
	table.insert(mission_stations,station_uesac)
	transport, transport_size = randomTransportType()
	transport:setFaction(station_uesac:getFaction())
	if transport:hasJumpDrive() then
		transport:setImpulseMaxSpeed(100)
	else
		transport:setImpulseMaxSpeed(fast_transport[transport_size])
	end
	td_x, td_y = vectorFromAngle(station_angle,31000,true)
	transport:setPosition(td_x + se_x, td_y + se_y)
	table.insert(transport_list,transport)
	--	Mars
	local mars_dist = earth_dist + 40000
	local mars_arc = 90
	if getScenarioSetting("Alignment") == "Majority" then
		mars_arc = random(45,90)
	elseif getScenarioSetting("Alignment") == "Random" then
		mars_arc = random(0,360)
	end
	pm_x, pm_y = vectorFromAngle(mars_arc,mars_dist,true)
	planet_mars = Planet():setCallSign("Mars"):setPosition(pm_x + center_x, pm_y + center_y)
	planet_mars:setPlanetRadius(2650):setDistanceFromMovementPlane(-420)
	planet_mars:setPlanetSurfaceTexture("planets/planet-3.png"):setAxialRotationTime(850)
	planet_mars:setPlanetAtmosphereColor(.5,.01,.01):setPlanetCloudTexture("planets/clouds-2.png")
	planet_mars:setPlanetAtmosphereTexture("planets/atmosphere.png")
	planet_mars:setOrbit(star_sol,45000)
	--	Mars Manufacturing and Trade 4
	station_angle = random(175,205)
	sm_x, sm_y = vectorFromAngle(station_angle,7500,true)
	sm_x = sm_x + pm_x + center_x
	sm_y = sm_y + pm_y + center_y
	station_mmt = placeStation(sm_x,sm_y,"MMT-4","TSN")
	station_mmt.planet = planet_mars
	station_mmt.planet_angle = station_angle
	station_mmt.planet_distance = 7500
	table.insert(orbital_stations,station_mmt)
	table.insert(mission_stations,station_mmt)
	transport, transport_size = randomTransportType()
	transport:setFaction(station_mmt:getFaction())
	if transport:hasJumpDrive() then
		transport:setImpulseMaxSpeed(100)
	else
		transport:setImpulseMaxSpeed(fast_transport[transport_size])
	end
	td_x, td_y = vectorFromAngle(station_angle,27500,true)
	transport:setPosition(td_x + sm_x, td_y + sm_y)
	table.insert(transport_list,transport)
	--	Asteroid belt
	orbiting_asteroids = {}
	for i=1,10 do
		local orbit_speed = random(1,20)
		for j=1,belt_density do
			local angle = random(0,360)
			local lo = (i-1) * 5000
			local hi = i * 5000
			local dist_interval = random(lo,hi)
			local dist = mars_dist + 30000 + dist_interval
			local ax, ay = vectorFromAngle(angle,dist,true)
			local a = Asteroid():setPosition(ax + center_x, ay + center_y)
			local max_size = math.min(dist_interval - lo, hi - dist_interval)
			local a_size = math.min(max_size,random(1,150) + random(1,150) + random(1,150) + random(1,150) + random(1,150) + random(1,150) + random(1,150) + random(1,150) + random(1,150) + random(1,150))
			a:setSize(a_size)
			a.angle = angle
			a.orbit_speed = orbit_speed
			a.dist = dist
			a.x = ax + center_x
			a.y = ay + center_y
			table.insert(orbiting_asteroids,a)
		end
	end
	--	Jupiter
	local jupiter_dist = mars_dist + 180000
	local jupiter_arc = 90
	if getScenarioSetting("Alignment") == "Majority" then
		jupiter_arc = random(45,90)
	elseif getScenarioSetting("Alignment") == "Random" then
		jupiter_arc = random(0,360)
	end
	local pj_x, pj_y = vectorFromAngle(jupiter_arc,jupiter_dist,true)
	planet_jupiter = Planet():setCallSign("Jupiter"):setPosition(pj_x + center_x, pj_y + center_y)
	planet_jupiter:setPlanetRadius(56000):setDistanceFromMovementPlane(-20000)
	planet_jupiter:setPlanetSurfaceTexture("planets/gas-1.png"):setAxialRotationTime(1200)
	planet_jupiter:setPlanetAtmosphereColor(.95,.60,0)
	planet_jupiter:setPlanetAtmosphereTexture("planets/atmosphere.png")
	planet_jupiter:setOrbit(star_sol,75000)
	--	Jupiter Orbital Defense Surveillance Seven
	station_angle = random(250,290)
	local sj_x, sj_y = vectorFromAngle(station_angle,60000,true)
	sj_x = sj_x + pj_x + center_x
	sj_y = sj_y + pj_y + center_y
	station_jods = placeStation(sj_x,sj_y,"JODS-7","Arlenians","Medium Station")
	station_jods.planet = planet_jupiter
	station_jods.planet_angle = station_angle
	station_jods.planet_distance = 60000
	table.insert(orbital_stations,station_jods)
	table.insert(mission_stations,station_jods)
	transport, transport_size = randomTransportType()
	transport:setFaction(station_jods:getFaction())
	if transport:hasJumpDrive() then
		transport:setImpulseMaxSpeed(100)
	else
		transport:setImpulseMaxSpeed(fast_transport[transport_size])
	end
	td_x, td_y = vectorFromAngle(station_angle,80000,true)
	transport:setPosition(td_x + sj_x, td_y + sj_y)
	table.insert(transport_list,transport)
	--	Jupiter scan artifact
	local aj_x, aj_y = vectorFromAngle(station_angle + 180,60000,true)
	aj_x = aj_x + pj_x + center_x
	aj_y = aj_y + pj_y + center_y
	artifact_js = Artifact():setPosition(aj_x,aj_y)
	artifact_js:setDescriptions(_("scienceDescription-artifact","Sure Dave, I can do that"),_("scienceDescription-artifact","Prop storage for super sequel 2543 The Space Odyssey AI Revenge where LEN<e> says, 'Sure Dave, I can do that'"))
	artifact_js.planet = planet_jupiter
	artifact_js.planet_angle = station_angle + 180
	artifact_js.planet_distance = 60000
	artifact_js:setScanningParameters(3,3):setModel("cubesat")
	table.insert(orbital_stations,artifact_js)
	--	Saturn
	local saturn_dist = jupiter_dist + 180000
	local saturn_arc = 90
	if getScenarioSetting("Alignment") == "Majority" then
		saturn_arc = random(45,90)
	elseif getScenarioSetting("Alignment") == "Random" then
		saturn_arc = random(0,360)
	end
	ps_x, ps_y = vectorFromAngle(saturn_arc,saturn_dist,true)
	planet_saturn = Planet():setCallSign("Saturn"):setPosition(ps_x + center_x, ps_y + center_y)
	planet_saturn:setPlanetRadius(47250):setDistanceFromMovementPlane(-15000)
	planet_saturn:setPlanetSurfaceTexture("planets/gas-2.png"):setAxialRotationTime(1500)
	planet_saturn:setPlanetAtmosphereColor(.95,.898,.671)
	planet_saturn:setPlanetAtmosphereTexture("planets/atmosphere.png")
	planet_saturn:setOrbit(star_sol,85000)
	--	Saturn Research and Resource Hub Two
	station_angle = random(10,50)
	local ss_x, ss_y = vectorFromAngle(station_angle,52000,true)
	ss_x = ss_x + ps_x + center_x
	ss_y = ss_y + ps_y + center_y
	station_srrh = placeStation(ss_x,ss_y,"SRRH-2","CUF")
	station_srrh.planet = planet_saturn
	station_srrh.planet_angle = station_angle
	station_srrh.planet_distance = 52000
	table.insert(orbital_stations,station_srrh)
	table.insert(mission_stations,station_srrh)
	transport, transport_size = randomTransportType()
	transport:setFaction(station_srrh:getFaction())
	if transport:hasJumpDrive() then
		transport:setImpulseMaxSpeed(100)
	else
		transport:setImpulseMaxSpeed(fast_transport[transport_size])
	end
	td_x, td_y = vectorFromAngle(station_angle,20000,true)
	transport:setPosition(td_x + ss_x, td_y + ss_y)
	table.insert(transport_list,transport)
	--	Saturn debris
	local debris_angle = station_angle + 18
	local tritanium_cost = station_mmo.comms_data.goods.tritanium.cost
	local nickel_cost = station_vos.comms_data.goods.nickel.cost
--	print("tritanium:",tritanium_cost,"nickel:",nickel_cost)
	local max_regenerate = 2
	local regenerate_count = 0
	saturn_debris_warp_jammers = {}
	for i=1,10 do
		local sd_x, sd_y = vectorFromAngle(debris_angle,55000,true)
		sd_x = sd_x + ps_x + center_x
		sd_y = sd_y + ps_y + center_y
		wj = WarpJammer():setPosition(sd_x,sd_y):setRange(grunge_range):setScanningParameters(2,1)
		local random_models = {
			"Morass",
			"Interdict",
			"Tackle",
		}
		wj:setDescriptions(_("scienceDescription-warpJammer","Warp Jammer"),string.format(_("scienceDescription-warpJammer","Warp Jammer Model %s"),tableSelectRandom(random_models)))
		if regenerate_count < max_regenerate then
			if random(1,100) < 31 then
				regenerate_count = regenerate_count + 1
				wj.enduro = true
				wj:setDescriptions(_("scienceDescription-warpJammer","Warp Jammer"),_("scienceDescription-warpJammer","Warp Jammer Model Enduro"))
				wj:setHull(150)
				wj:onTakingDamage(function(self,instigator)
					string.format("")
					self:setHull(150)
				end)
			end
		end
		wj.planet = planet_saturn
		wj.planet_angle = debris_angle
		wj.planet_distance = 55000
		table.insert(orbital_stations,wj)
		table.insert(saturn_debris_warp_jammers,wj)
		debris_angle = debris_angle + 36
	end
	--	Uranus
	local uranus_dist = saturn_dist + 180000
	local uranus_arc = 90
	if getScenarioSetting("Alignment") == "Majority" then
		uranus_arc = random(45,90)
	elseif getScenarioSetting("Alignment") == "Random" then
		uranus_arc = random(0,360)
	end
	local pu_x, pu_y = vectorFromAngle(uranus_arc,uranus_dist,true)
	planet_uranus = Planet():setCallSign("Uranus"):setPosition(pu_x + center_x, pu_y + center_y)
	planet_uranus:setPlanetRadius(20000):setDistanceFromMovementPlane(-4000)
	planet_uranus:setPlanetSurfaceTexture("planets/gas-3.png"):setAxialRotationTime(900)
	planet_uranus:setPlanetAtmosphereColor(.48,.8,.71)
	planet_uranus:setPlanetAtmosphereTexture("planets/atmosphere.png")
	planet_uranus:setOrbit(star_sol,95000)
	--	Uranus Orbital Station Three
	station_angle = random(70,110)
	local su_x, su_y = vectorFromAngle(station_angle,25000,true)
	su_x = su_x + pu_x + center_x
	su_y = su_y + pu_y + center_y
	station_uos = placeStation(su_x,su_y,"UOS-3","USN","Small Station")
	station_uos.planet = planet_uranus
	station_uos.planet_angle = station_angle
	station_uos.planet_distance = 25000
	table.insert(orbital_stations,station_uos)
	table.insert(mission_stations,station_uos)
	transport, transport_size = randomTransportType()
	transport:setFaction(station_uos:getFaction())
	if transport:hasJumpDrive() then
		transport:setImpulseMaxSpeed(100)
	else
		transport:setImpulseMaxSpeed(fast_transport[transport_size])
	end
	td_x, td_y = vectorFromAngle(station_angle,20000,true)
	transport:setPosition(td_x + su_x, td_y + su_y)
	table.insert(transport_list,transport)
	--	Neptune
	local neptune_dist = uranus_dist + 180000
	local neptune_arc = 90
	if getScenarioSetting("Alignment") == "Majority" then
		neptune_arc = random(45,90)
	elseif getScenarioSetting("Alignment") == "Random" then
		neptune_arc = random(0,360)
	end
	local pn_x, pn_y = vectorFromAngle(neptune_arc,neptune_dist,true)
	planet_neptune = Planet():setCallSign("Neptune"):setPosition(pn_x + center_x, pn_y + center_y)
	planet_neptune:setPlanetRadius(19400):setDistanceFromMovementPlane(-3200)
	planet_neptune:setPlanetSurfaceTexture("planets/planet-4.png"):setAxialRotationTime(700)
	planet_neptune:setPlanetAtmosphereColor(.188,.55,.494):setPlanetCloudTexture("planets/clouds-3.png")
	planet_neptune:setPlanetAtmosphereTexture("planets/atmosphere.png")
	planet_neptune:setOrbit(star_sol,95000)
	--	Neptune Research Station Five
	station_angle = random(0,40)
	local sn_x, sn_y = vectorFromAngle(station_angle,25000,true)
	sn_x = sn_x + pn_x + center_x
	sn_y = sn_y + pn_y + center_y
	station_nrs = placeStation(sn_x,sn_y,"NRS-5","TSN","Small Station")
	station_nrs.planet = planet_neptune
	station_nrs.planet_angle = station_angle
	station_nrs.planet_distance = 25000
	table.insert(orbital_stations,station_nrs)
	table.insert(mission_stations,station_nrs)
	transport, transport_size = randomTransportType()
	transport:setFaction(station_uos:getFaction())
	if transport:hasJumpDrive() then
		transport:setImpulseMaxSpeed(100)
	else
		transport:setImpulseMaxSpeed(fast_transport[transport_size])
	end
	td_x, td_y = vectorFromAngle(station_angle,20000,true)
	transport:setPosition(td_x + sn_x, td_y + sn_y)
	table.insert(transport_list,transport)
	--	Make sure there are nukes available for the debris clean up mission
	local stations_with_nukes = {}
	local stations_without_nukes = {}
	for i,station in ipairs(mission_stations) do
		if station:isFriendly(player) then
			if station.comms_data.weapon_available.Nuke then
				table.insert(stations_with_nukes,station)
			else
				table.insert(stations_without_nukes,station)
			end
		end
	end
	if #stations_with_nukes < 3 then
		local selected_station = tableRemoveRandom(stations_without_nukes)
		selected_station.comms_data.weapon_available.Nuke = true
		selected_station.comms_data.weapon_cost.Nuke = math.random(12,18)
		selected_station = tableRemoveRandom(stations_without_nukes)
		selected_station.comms_data.weapon_available.Nuke = true
		selected_station.comms_data.weapon_cost.Nuke = math.random(12,18)
	end
	--	Message stations in command hierarchy order
	message_stations = {station_uesac,station_vos}
end
--	Communication
function queueJupiterScanMessage()
	local player_message = _("goal-incCall","We have detected unusual readings near Jupiter. It could be nothing -- or something worse. Go find out what you can about them. Approach with caution.")
	table.insert(messages,{msg=player_message,list={}})
	local messages_index = #messages
	for i,p in ipairs(getActivePlayerShips()) do
		table.insert(messages[messages_index].list,p)
	end
	primary_orders = _("orders-comms","Investigate unusual readings near Jupiter.")
end
function queueSaturnClearDebrisMessage()
	local player_message = _("goal-incCall","Saturn is cluttered with legacy debris. A number of warp jammers were placed in orbit to help defend against unwanted incursions. These are now a navigation hazard. They need to be destroyed.\n\nMost warp jammer models can be destroyed with normal missiles. However, the Enduro models require a nuke to destroy. Scan the warp jammer to determine the model.\n\nNukes are in limited supply and vary in price from station to station. Find the best deal before you get more nukes.\n\nClean up those orbits. We need those lanes clear.")
	table.insert(messages,{msg=player_message,list={}})
	local messages_index = #messages
	for i,p in ipairs(getActivePlayerShips()) do
		table.insert(messages[messages_index].list,p)
	end
	primary_orders = _("orders-comms","Clean up legacy debris warp jammers orbiting Saturn.")
end
function scenarioMissionsUndocked()
	if comms_target == station_uesac then
		if scan_mission == nil then
			if artifact_js:isScannedByFaction(player_faction) then
				addCommsReply(_("orders-comms","Provide scan data on Jupiter object"),function()
					setCommsMessage(_("orders-comms","Prop storage, huh? I wish those movie production companies would keep us better informed."))
					addCommsReply(_("Back"), commsStation)
					scan_mission = "complete"
					include_ordnance_in_status = true
					queueSaturnClearDebrisMessage()
				end)
			end
		end
	end
end
function checkDebrisMission()
	if debris_clear_mission == nil and scan_mission ~= nil then
		if cleanList(saturn_debris_warp_jammers) then
			if #saturn_debris_warp_jammers == 0 then
				debris_clear_mission = "complete"
				local player_message = _("goal-incCall","A package currently at NRS-5 orbiting Neptune needs to be delivered quickly to UESA Command at Earth. No questions asked -- just pick it up and don't drop it.")
				table.insert(messages,{msg=player_message,list={}})
				local messages_index = #messages
				for i,p in ipairs(getActivePlayerShips()) do
					table.insert(messages[messages_index].list,p)
				end
				primary_orders = _("orders-comms","Transport package from Neptune to Earth.")
				transport_neptune_to_earth_time = getScenarioTime() + delivery_time_limit
			end
		end
	end
end
function checkPackageTransportMission()
	if neptune_earth_delivery_mission == nil and transport_neptune_to_earth_time ~= nil then
		if getScenarioTime() > transport_neptune_to_earth_time then
			local final_message = _("msgMainscreen","You did not deliver the package in time.")
			final_message = string.format("%s\n%s",final_message,finalStats())
			globalMessage(final_message)
			victory("Kraylor")
		else
			player:addCustomInfo("Helms","transport_time_hlm",string.format(_("timer-tabHelms","Delivery %s"),formatTime(transport_neptune_to_earth_time - getScenarioTime())),5)
			player:addCustomInfo("Tactical","transport_time_tac",string.format(_("timer-tabTactical","Delivery %s"),formatTime(transport_neptune_to_earth_time - getScenarioTime())),5)
		end
	else
		player:removeCustom("transport_time_hlm")
		player:removeCustom("transport_time_tac")
	end
end
function scenarioInformation()
	addCommsReply(_("stationAssist-comms","Where are the other stations in the solar system?"),function()
		setCommsMessage(_("stationAssist-comms","Which station are you interested in? These are the stations that might be pertinent to your mission:"))
		for i,station in ipairs(mission_stations) do
			if station:isValid() then
				addCommsReply(string.format("%s (%s)",station:getCallSign(),station:getDescription()),function()
					if station == comms_target then
						setCommsMessage(_("stationAssist-comms","This is the station where you are docked"))
					else
						setCommsMessage(string.format(_("stationAssist-comms","%s is in sector %s. It is in orbit around planet %s. It is %.1f units away on bearing %i.\n\nReminders: Planets orbit Sol, so these stations won't stay in the same place. Each sector is 20 units square."),station:getCallSign(),station:getSectorName(),station.planet:getCallSign(),distance(comms_source,station)/1000,math.floor(angleHeading(comms_source,station))))
					end
					addCommsReply(_("Back"), commsStation)
				end)
			end
		end
		addCommsReply(_("Back"), commsStation)
	end)
end
function setUpDebrisClearingMission()
	local lowest_nuke_cost = 999
	for i,station in ipairs(mission_stations) do
		if station:isValid() and station:isFriendly(player) then
			if station.comms_data.weapon_available.Nuke then
				if station.comms_data.weapon_cost.Nuke < lowest_nuke_cost then
					lowest_nuke_cost = station.comms_data.weapon_cost.Nuke
				end
			end
		end
	end
	if lowest_nuke_cost < 999 then
		local enduro_count = math.floor(player:getReputationPoints()/lowest_nuke_cost) + budget_allowance
		local wj_enduros = {}
		local wj_normal = {}
		for i,wj in ipairs(saturn_debris_warp_jammers) do
			if wj:isValid() then
				if wj.enduro then
					table.insert(wj_enduros,wj)
				else
					table.insert(wj_normal,wj)
				end
			end
		end
		if #wj_enduros < enduro_count then
			for i=1,enduro_count - #wj_enduros do
				local wj = tableRemoveRandom(wj_normal)
				if wj ~= nil then
					wj.enduro = true
					wj:setDescriptions(_("scienceDescription-warpJammer","Warp Jammer"),_("scienceDescription-warpJammer","Warp Jammer Model Enduro"))
					wj:setHull(150)
					wj:onTakingDamage(function(self,instigator)
						string.format("")
						self:setHull(150)
					end)
				end
			end
		end
	else
		print("no nukes available")
	end
end
function scenarioMissions()
	local presented = 0
	if comms_target == station_uesac then
		if scan_mission == nil then
			if artifact_js:isScannedByFaction(player_faction) then
				presented = presented + 1
				addCommsReply(_("orders-comms","Provide scan data on Jupiter object"),function()
					setCommsMessage(_("orders-comms","Prop storage, huh? I wish those movie production companies would keep us better informed."))
					addCommsReply(_("Back"), commsStation)
					scan_mission = "complete"
					include_ordnance_in_status = true
					queueSaturnClearDebrisMessage()
				end)
			end
		end
		if resource_mission_1 == nil then
			presented = presented + 1
			local good_count = 0
			local tritanium_count = 0
			local nickel_count = 0
			if comms_source.goods ~= nil then
				for good, good_quantity in pairs(comms_source.goods) do
					good_count = good_count + good_quantity
					if good == "tritanium" then
						tritanium_count = tritanium_count + good_quantity
					end
					if good == "nickel" then
						nickel_count = nickel_count + good_quantity
					end
				end
			end
			addCommsReply(_("goal-comms","Provide resources to UESA Command"),function()
				string.format("")
				if good_count > 0 then
					setCommsMessage(_("goal-comms","What would you like to provide to UESA Command?"))
					if tritanium_count > 0 or nickel_count > 0 then
						if tritanium_count > 0 then
							addCommsReply(_("goal-comms","Provide tritanium to UESA Command"),function()
								comms_source.goods.tritanium = 0
								setCommsMessage(string.format(_("goal-comms","Thanks for the tritanium, %s. Your handling of proximity maneuvers shows promise."),comms_source:getCallSign()))
								resource_mission_1 = _("msgMainscreen","complete")
								setUpDebrisClearingMission()
								queueJupiterScanMessage()
								addCommsReply(_("Back"), commsStation)
							end)
						end
						if nickel_count > 0 then
							addCommsReply(_("goal-comms","Provide nickel to UESA Command"),function()
								comms_source.goods.nickel = 0
								setCommsMessage(string.format(_("goal-comms","Thanks for the nickel, %s. Your handling of proximity maneuvers shows promise."),comms_source:getCallSign()))
								resource_mission_1 = _("msgMainscreen","complete")
								setUpDebrisClearingMission()
								queueJupiterScanMessage()
								addCommsReply(_("Back"), commsStation)
							end)
						end
						if nickel_count > 0 and tritanium_count > 0 then
							addCommsReply(_("goal-comms","Provide tritanium and nickel to UESA Command"),function()
								comms_source.goods.tritanium = 0
								comms_source.goods.nickel = 0
								setCommsMessage(string.format(_("goal-comms","Thanks for the tritanium and nickel, %s. Your handling of proximity maneuvers shows promise."),comms_source:getCallSign()))
								resource_mission_1 = _("msgMainscreen","doubly complete")
								setUpDebrisClearingMission()
								queueJupiterScanMessage()
								addCommsReply(_("Back"), commsStation)
							end)
						end
					else
						setCommsMessage(_("goal-comms","The goods in your cargo hold are not the goods that station UESA Command needs."))
					end
				else
					setCommsMessage(_("goal-comms","There are no goods in your cargo hold to provide to station UESA Command."))
				end
				addCommsReply(_("Back"), commsStation)
			end)
		end
		if neptune_earth_delivery_mission == nil then
			if comms_source.neptune_earth_package then
				presented = presented + 1
				addCommsReply("Deliver package from Neptune",function()
					setCommsMessage("The package from Neptune has been delivered.")
					neptune_earth_delivery_mission = "complete"
				end)
			end
		end
	end
	if comms_target == station_nrs then
		presented = presented + 1
		addCommsReply(_("goal-comms","Get package for delivery to UESA Command"),function()
			setCommsMessage(_("goal-comms","The package for UESA Command is aboard."))
			comms_source.neptune_earth_package = true
		end)
	end
	return presented
end
function scenarioShipEnhancements()
	if comms_target == station_mmo and comms_source.warp_upgrade_1 == nil then
		addCommsReply(_("upgrade-comms","Check on warp drive availability"),function()
			setCommsMessage(_("upgrade-comms","Enrique Garcia, my maintenance technician, says he's got a warp drive gathering dust on the work bench in the back of his shop. It's an older Repulse Radon Mark III model, but it's in good working condition."))
			if comms_source:hasWarpDrive() then
				addCommsReply(_("upgrade-comms","What else can you tell me about the Repulse Radon Mark III?"),function()
					if comms_source:getWarpSpeed() < 800 then
						setCommsMessage(_("upgrade-comms","It's faster than your current warp drive."))
					elseif comms_source:getWarpSpeed() > 800 then
						setCommsMessage(_("upgrade-comms","It's slower than your current warp drive."))
					else
						setCommsMessage(_("upgrade-comms","It's the same speed as your current warp drive."))
					end
					addCommsReply(_("Back"), commsStation)
				end)
			end
			addCommsReply(_("upgrade-comms","Please install the warp drive"),function()
				comms_source:setWarpDrive(true)
				comms_source:setWarpSpeed(800)
				comms_source.warp_upgrade_1 = true
				setCommsMessage(_("upgrade-comms","You now have a Repulse Radon Mark III warp drive"))
				addCommsReply(_("Back"), commsStation)
			end)
			addCommsReply(_("Back"), commsStation)
		end)
	end
	if comms_target == station_vos and comms_source.sensor_upgrade == nil then
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
	if comms_target == station_mmt and comms_source.jump_upgrade == nil then
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
--	Updates
function finalStats()
	local a_player = getPlayerShip(-1)
	local final_message = ""
	if resource_mission_1 == nil then
		final_message = _("msgMainscreen","Mission to get resources for Earth: incomplete.")
	else
		final_message = string.format(_("msgMainscreen","Mission to get resources for Earth: %s."),resource_mission_1)
		if scan_mission == nil then
			final_message = string.format(_("msgMainscreen","%s\nMission to check readings near Jupiter: incomplete."),final_message)
		else
			final_message = string.format(_("msgMainscreen","%s\nMission to check readings near Jupiter: complete."),final_message)
			if debris_clear_mission == nil then
				final_message = string.format(_("msgMainscreen","%s\nMission to clean up around Saturn: incomplete."),final_message)
			else
				final_message = string.format(_("msgMainscreen","%s\nMission to clean up around Saturn: complete."),final_message)
				if neptune_earth_delivery_mission == nil then
					final_message = string.format(_("msgMainscreen","%s\nMission to deliver package: incomplete."),final_message)
				else
					final_message = string.format(_("msgMainscreen","%s\nMission to deliver package: complete."),final_message)
				end
			end
		end
	end
	if deployed_player_count > 1 then
		final_message = string.format(_("msgMainscreen","%s\nDeployed %s player ships."),final_message,deployed_player_count)
	else
		final_message = string.format(_("msgMainscreen","%s\nDeployed one player ship."),final_message)
	end
	final_message = string.format(_("msgMainscreen","%s\nTime spent: %s."),final_message,formatTime(getScenarioTime()))
	final_message = string.format(_("msgMainscreen","%s\nRespawn:%s Alignment:%s Belt:%s"),final_message,getScenarioSetting("Respawn"),getScenarioSetting("Alignment"),getScenarioSetting("Belt"))
	final_message = string.format(_("msgMainscreen","%s\nDelivery:%s Budget:%s Grunge:%s"),final_message,getScenarioSetting("Delivery"),getScenarioSetting("Budget"),getScenarioSetting("Grunge"))
	return final_message
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
function maintainTransports()
	local function pickTransportTarget(transport)
		local transport_target = nil
		if cleanList(orbital_stations) then
			local station_pool = {}
			for i,station in ipairs(orbital_stations) do
				if not station:isEnemy(transport) then
					table.insert(station_pool,station)
				end
			end
			transport_target = tableSelectRandom(station_pool)
		end
		return transport_target
	end
	if transport_list ~= nil then
		local clean_list = true
		for i,transport in ipairs(transport_list) do
			if not transport:isValid() then
				transport_list[i] = transport_list[#transport_list]
				transport_list[#transport_list] = nil
				clean_list = false
				break
			end
		end
		if clean_list then
			for i,transport in ipairs(transport_list) do
				if transport ~= nil and transport:isValid() then
					if transport:getDockedWith() ~= nil then
						if transport.dock_time == nil then
							transport.dock_time = getScenarioTime() + random(5,30)
						end
					elseif transport:getOrder() ~= "Dock" then
						if transport.dock_time == nil then
							transport.dock_time = getScenarioTime() + random(5,30)
						end						
					elseif transport:getOrder() == "Dock" then
						if transport:getOrderTarget() == nil or not transport:getOrderTarget():isValid() then
							if transport.dock_time == nil then
								transport.dock_time = getScenarioTime() + random(5,30)
							end						
						end
					end
				end
				if transport.dock_time ~= nil and getScenarioTime() > transport.dock_time then
					local transport_station_pool = {}
					for j,station in ipairs(orbital_stations) do
						if station ~= nil then
							if station:isValid() then
								if not transport:isEnemy(station) then
									table.insert(transport_station_pool,station)
								end
							else
								orbital_stations[j] = orbital_stations[#orbital_stations]
								orbital_stations[#orbital_stations] = nil
								clean_list = false
								break
							end
						else
							orbital_stations[j] = orbital_stations[#orbital_stations]
							orbital_stations[#orbital_stations] = nil
							clean_list = false
							break
						end
					end
					if clean_list and #transport_station_pool > 0 then
						local dock_station = tableSelectRandom(transport_station_pool)
						transport:orderDock(dock_station)
						transport.dock_time = nil
					end
				end
			end
		end
	end
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
function updateOrbitalStations()
	for i,station in ipairs(orbital_stations) do
		if station:isValid() then
			local p_x, p_y = station.planet:getPosition()
			local s_x, s_y = vectorFromAngle(station.planet_angle,station.planet_distance,true)
			station:setPosition(p_x + s_x, p_y + s_y)
		end
	end
end
function mandatoryMissionsComplete()
	local complete = true
	if resource_mission_1 == nil then
		complete = false
	end
	if scan_mission == nil then
		complete = false
	end
	if debris_clear_mission == nil then
		complete = false
	end
	if neptune_earth_delivery_mission == nil then
		complete = false
	end
	if complete then
		local final_message = _("msgMainscreen","All missions completed.")
		final_message = string.format("%s\n%s",final_message,finalStats())
		globalMessage(final_message)
		victory("Human Navy")
	end
end
function update(delta)
	if delta == 0 then
		return
	end
	--	game is no longer paused
	--	initial message describing mission and setting goals
	if mission_message == nil then
		mission_message = "queued"
		local player_message = string.format(_("goal-incCall","Welcome crew of the %s.\n\nYou are now part of the %s deep-space task unit. The solar system depends on your team for resource gathering, recon, and delivery under strict time and budget conditions.\n\nYour latest assignment has taken you from station %s in Earth orbit to Mercury. Dock with station %s to get some tritanium, sulfer or nickel, all of which are in short supply on station %s. Station %s may have an advanced engine for you, too.\n\nBeware of people accepting resource donations at stations. Donating the goods instead of going to the proper office to provide the goods does not satisfy your mission goals.\n\nWe wish you success -- humanity is watching."),player:getCallSign(),player_faction,station_uesac:getCallSign(),station_mmo:getCallSign(),station_uesac:getCallSign(),station_mmo:getCallSign())
		table.insert(messages,{msg=player_message,list={}})
		local messages_index = #messages
		for i,p in ipairs(getActivePlayerShips()) do
			table.insert(messages[messages_index].list,p)
		end
		primary_orders = string.format(_("orders-comms","Get tritanium, nickel or sulfer from station %s for station %s"),station_mmo:getCallSign(),station_uesac:getCallSign())
	end
	maintainTransports()
	checkDebrisMission()
	checkPackageTransportMission()
	updateOrbitalStations()
	updateAsteroidOrbits(delta)
	messagePlayers()
	mandatoryMissionsComplete()
end
