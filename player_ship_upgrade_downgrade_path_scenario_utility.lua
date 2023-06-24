function playerShipUpgradeDowngradeData()
	if base_upgrade_cost == nil then
		base_upgrade_cost = 5
	end
	upgrade_path = {	--one path per player ship
		["Atlantis"] = {	--10 + beam(7) + missile(10) + shield(9) + hull(8) + impulse(16) + ftl(10) + sensors(10) = 80
			["beam"] = {
				{	--1
					{idx = 0, arc = 60, dir = -20, rng = 1000, cyc = 6, dmg = 6},
					{idx = 1, arc = 60, dir =  20, rng = 1000, cyc = 6, dmg = 6},
					["downgrade"] = _("downgrade-comms","reduced range by 20%"),
				},
				{	--2
					{idx = 0, arc = 60, dir = -20, rng = 1250, cyc = 6, dmg = 6},
					{idx = 1, arc = 60, dir =  20, rng = 1250, cyc = 6, dmg = 6},
					["desc"] = _("upgrade-comms","increase range by 25%"),
					["downgrade"] = _("downgrade-comms","decreased arc by 25%"),
				},
				{	--3
					{idx = 0, arc = 80, dir = -20, rng = 1250, cyc = 6, dmg = 6},
					{idx = 1, arc = 80, dir =  20, rng = 1250, cyc = 6, dmg = 6},
					["desc"] = _("upgrade-comms","increase arc by 1/3"),
					["downgrade"] = _("downgrade-comms","decreased damage by 25%"),
				},
				{	--4
					{idx = 0, arc = 80, dir = -20, rng = 1250, cyc = 6, dmg = 8},
					{idx = 1, arc = 80, dir =  20, rng = 1250, cyc = 6, dmg = 8},
					["desc"] = _("upgrade-comms","increase damage by 1/3"),
					["downgrade"] = _("downgrade-comms","removed beams"),
				},
				{	--5
					{idx = 0, arc = 80, dir = -20, rng = 1250, cyc = 6, dmg = 8},
					{idx = 1, arc = 80, dir =  20, rng = 1250, cyc = 6, dmg = 8},
					{idx = 2, arc = 80, dir = -40, rng = 1250, cyc = 6, dmg = 8},
					{idx = 3, arc = 80, dir =  40, rng = 1250, cyc = 6, dmg = 8},
					["desc"] = _("upgrade-comms","add beams"),
					["downgrade"] = _("downgrade-comms","decreased arc by 20%"),
				},
				{	--6
					{idx = 0, arc = 100, dir = -20, rng = 1250, cyc = 6, dmg = 8},
					{idx = 1, arc = 100, dir =  20, rng = 1250, cyc = 6, dmg = 8},
					{idx = 2, arc = 100, dir = -40, rng = 1250, cyc = 6, dmg = 8},
					{idx = 3, arc = 100, dir =  40, rng = 1250, cyc = 6, dmg = 8},
					["desc"] = _("upgrade-comms","increase arc by 25%"),
					["downgrade"] = _("downgrade-comms","decreased range by ~17%"),
				},
				{	--7
					{idx = 0, arc = 100, dir = -20, rng = 1500, cyc = 6, dmg = 8},
					{idx = 1, arc = 100, dir =  20, rng = 1500, cyc = 6, dmg = 8},
					{idx = 2, arc = 100, dir = -40, rng = 1500, cyc = 6, dmg = 8},
					{idx = 3, arc = 100, dir =  40, rng = 1500, cyc = 6, dmg = 8},
					["desc"] = _("upgrade-comms","increase range by 20%"),
					["downgrade"] = _("downgrade-comms","increased cycle time by 20%"),
				},
				{	--8
					{idx = 0, arc = 100, dir = -20, rng = 1500, cyc = 5, dmg = 8},
					{idx = 1, arc = 100, dir =  20, rng = 1500, cyc = 5, dmg = 8},
					{idx = 2, arc = 100, dir = -40, rng = 1500, cyc = 5, dmg = 8},
					{idx = 3, arc = 100, dir =  40, rng = 1500, cyc = 5, dmg = 8},
					["desc"] = _("upgrade-comms","decrease cycle time by 1/6"),
				},
				["stock"] = {
					{idx = 0, arc = 100, dir = -20, rng = 1500, cyc = 6, dmg = 8},
					{idx = 1, arc = 100, dir =  20, rng = 1500, cyc = 6, dmg = 8},
				},
				["start"] = 5,
			},
			["missiles"] = {
				{tube = 1,	ord = 1, downgrade = _("downgrade-comms","decreased missile stock capacity")},																				--1
				{tube = 1,	ord = 2, desc = _("upgrade-comms","increase missile stock capacity"),	downgrade = _("downgrade-comms","decreased homing missile capacity")},				--2  
				{tube = 1,	ord = 3, desc = _("upgrade-comms","increase homing missile capacity"),	downgrade = _("downgrade-comms","removed mine tube")},								--3  
				{tube = 2,	ord = 4, desc = _("upgrade-comms","add a mine tube"),					downgrade = _("downgrade-comms","increased tube load times")},						--4
				{tube = 3,	ord = 4, desc = _("upgrade-comms","decrease tube load times"),			downgrade = _("downgrade-comms","removed mines, EMPs and nukes")},					--5
				{tube = 3,	ord = 5, desc = _("upgrade-comms","add mines, emps and nukes"),			downgrade = _("downgrade-comms","removed two medium sized side tubes")},			--6
				{tube = 4,	ord = 5, desc = _("upgrade-comms","add two medium sized side tubes"),	downgrade = _("downgrade-comms","reduced EMP capacity")},							--7
				{tube = 4,	ord = 6, desc = _("upgrade-comms","increase EMP capacity"),				downgrade = _("downgrade-comms","reduced nuke capacity capacity")},					--8
				{tube = 4,	ord = 7, desc = _("upgrade-comms","increase nuke capacity"),			downgrade = _("downgrade-comms","reduced tube sizes")},								--9
				{tube = 5,	ord = 7, desc = _("upgrade-comms","increase tube sizes"),				downgrade = _("downgrade-comms","reduced mine load speed, removed front tube")},	--10
				{tube = 6,	ord = 7, desc = _("upgrade-comms","decrease mine load speed, add front tube")},																				--11
				["start"] = 4,
			},
			["tube"] = {
				{	--1
					{idx = 0, dir = -90, siz = "S", spd = 10, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 1, dir =  90, siz = "S", spd = 10, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
				},
				{	--2
					{idx = 0, dir = -90, siz = "S", spd = 10, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 1, dir =  90, siz = "S", spd = 10, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--3
					{idx = 0, dir = -90, siz = "S", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 1, dir =  90, siz = "S", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--4
					{idx = 0, dir = -90, siz = "S", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 1, dir =  90, siz = "S", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 2, dir = -90, siz = "M", spd = 10, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 10, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 4, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--5
					{idx = 0, dir = -90, siz = "M", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 1, dir =  90, siz = "M", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 2, dir = -90, siz = "L", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 3, dir =  90, siz = "L", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 4, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--6
					{idx = 0, dir =   0, siz = "S", spd = 6,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 1, dir = -90, siz = "M", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 2, dir =  90, siz = "M", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 3, dir = -90, siz = "L", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 4, dir =  90, siz = "L", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 5, dir = 180, siz = "M", spd = 8,  hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				["stock"] = {
					{idx = 0, dir = -90, siz = "M", spd = 8, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 1, dir = -90, siz = "M", spd = 8, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 2, dir =  90, siz = "M", spd = 8, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 8, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 4, dir = 180, siz = "M", spd = 8, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				["start"] = 2,
			},
			["ordnance"] = {
				{hom = 4,  nuk = 0, emp = 0, min = 0, hvl = 10},	--1
				{hom = 6,  nuk = 0, emp = 0, min = 0, hvl = 20},	--2		
				{hom = 12, nuk = 0, emp = 0, min = 0, hvl = 20},	--3		
				{hom = 12, nuk = 0, emp = 0, min = 4, hvl = 20},	--4		
				{hom = 12, nuk = 2, emp = 4, min = 8, hvl = 20},	--5		
				{hom = 12, nuk = 2, emp = 6, min = 8, hvl = 20},	--6		
				{hom = 12, nuk = 4, emp = 6, min = 8, hvl = 20},	--7		
				["stock"] = {hom = 12, nuk = 4, emp = 6, min = 8, hvl = 20},
				["start"] = 4,
			},
			["shield"] = {
				{	--1
					{idx = 0, max = 80},
					["downgrade"] = _("downgrade-comms","reduced shield charge capacity by 20%"),
				},
				{	--2
					{idx = 0, max = 100},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
					["downgrade"] = _("downgrade-comms","reduced shield charge capacity by 1/3"),
				},
				{	--3
					{idx = 0, max = 150},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 50%"),
					["downgrade"] = _("downgrade-comms","removed rear shield arc"),
				},
				{	--4
					{idx = 0, max = 80},
					{idx = 1, max = 80},
					["desc"] = _("upgrade-comms","add rear shield arc"),
					["downgrade"] = _("downgrade-comms","reduced front shield charge capacity by 20%"),
				},
				{	--5
					{idx = 0, max = 100},
					{idx = 1, max = 80},
					["desc"] = _("upgrade-comms","increase front shield charge capacity by 25%"),
					["downgrade"] = _("downgrade-comms","reduced rear shield charge capacity by 20%"),
				},
				{	--6
					{idx = 0, max = 100},
					{idx = 1, max = 100},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by 25%"),
					["downgrade"] = _("downgrade-comms","reduced shield charge capacity by 1/3"),
				},
				{	--7
					{idx = 0, max = 150},
					{idx = 1, max = 150},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 50%"),
					["downgrade"] = _("downgrade-comms","reduced shield charge capacity by 25%"),
				},
				{	--8
					{idx = 0, max = 200},
					{idx = 1, max = 200},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 1/3"),
					["downgrade"] = _("downgrade-comms","reduced shield charge capacity by ~13%"),
				},
				{	--9
					{idx = 0, max = 230},
					{idx = 1, max = 230},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 15%"),
					["downgrade"] = _("downgrade-comms","reduced shield charge capacity by 8%"),
				},
				{	--10
					{idx = 0, max = 250},
					{idx = 1, max = 250},
					["desc"] = _("upgrade-comms","increase shield charge capacity by ~13%"),
				},
				["stock"] = {
					{idx = 0, max = 200},
					{idx = 1, max = 200},
				},
				["start"] = 5,
			},
			["hull"] = {
				{max = 100,	["downgrade"] = _("downgrade-comms","decreased hull max by 20%")},																--1
				{max = 120, ["desc"] = _("upgrade-comms","increase hull max by 25%"),	["downgrade"] = _("downgrade-comms","decreased hull max by ~14%")},	--2
				{max = 140, ["desc"] = _("upgrade-comms","increase hull max by ~17%"),	["downgrade"] = _("downgrade-comms","decreased hull max by ~22%")},	--3
				{max = 180, ["desc"] = _("upgrade-comms","increase hull max by ~29%"),	["downgrade"] = _("downgrade-comms","decreased hull max by 10%")},	--4
				{max = 200, ["desc"] = _("upgrade-comms","increase hull max by ~11%"),	["downgrade"] = _("downgrade-comms","decreased hull max by 20%")},	--5
				{max = 250, ["desc"] = _("upgrade-comms","increase hull max by 25%"),	["downgrade"] = _("downgrade-comms","decreased hull max by ~17%")},	--6
				{max = 300, ["desc"] = _("upgrade-comms","increase hull max by 20%")},																		--7
				["stock"] = {max = 250},
				["start"] = 3,
			},
			["impulse"] = {
				{	--1
					max_front =		70,		max_back =		70,
					accel_front =	20,		accel_back = 	20,
					turn = 			10,
					boost =			0,		strafe =		0,
					downgrade =	_("downgrade-comms","reduced max forward impulse speed by 12.5%"),
				},
				{	--2
					max_front =		80,		max_back =		70,
					accel_front =	20,		accel_back = 	20,
					turn = 			10,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase max forward impulse speed by ~14%"),
					downgrade =	_("downgrade-comms","removed combat maneuver"),
				},
				{	--3
					max_front =		80,		max_back =		70,
					accel_front =	20,		accel_back = 	20,
					turn = 			10,
					boost =			200,	strafe =		0,
					desc = _("upgrade-comms","add combat maneuver forward boost"),
					downgrade =	_("downgrade-comms","decreased max reverse impulse speed by 12.5%"),
				},
				{	--4
					max_front =		80,		max_back =		80,
					accel_front =	20,		accel_back = 	20,
					turn = 			10,
					boost =			200,	strafe =		0,
					desc = _("upgrade-comms","increase max reverse impulse speed by ~14%"),
					downgrade =	_("downgrade-comms","removed combat maneuver strafe"),
				},
				{	--5
					max_front =		80,		max_back =		80,
					accel_front =	20,		accel_back = 	20,
					turn = 			10,
					boost =			200,	strafe =		125,
					desc = _("upgrade-comms","add combat maneuver strafe"),
					downgrade =	_("downgrade-comms","decreased maneuverability by ~17%"),
				},
				{	--6
					max_front =		80,		max_back =		80,
					accel_front =	20,		accel_back = 	20,
					turn = 			12,
					boost =			200,	strafe =		125,
					desc = _("upgrade-comms","increase maneuverability by 20%"),
					downgrade =	_("downgrade-comms","decreased max forward impulse speed by ~11%"),
				},
				{	--7
					max_front =		90,		max_back =		80,
					accel_front =	20,		accel_back = 	20,
					turn = 			12,
					boost =			200,	strafe =		125,
					desc = _("upgrade-comms","increase max forward impulse speed by 12.5%"),
					downgrade =	_("downgrade-comms","decreased combat maneuver forward boost by 1/3"),
				},
				{	--8
					max_front =		90,		max_back =		80,
					accel_front =	20,		accel_back = 	20,
					turn = 			12,
					boost =			300,	strafe =		125,
					desc = _("upgrade-comms","increase combat maneuver forward boost by 50%"),
					downgrade =	_("downgrade-comms","decreased impulse forward acceleration by 20%"),
				},
				{	--9
					max_front =		90,		max_back =		80,
					accel_front =	25,		accel_back = 	20,
					turn = 			12,
					boost =			300,	strafe =		125,
					desc = _("upgrade-comms","increase impulse forward acceleration by 25%"),
					downgrade =	_("downgrade-comms","decreased combat maneuver strafe by 37.5%"),
				},
				{	--10
					max_front =		90,		max_back =		80,
					accel_front =	25,		accel_back = 	20,
					turn = 			12,
					boost =			300,	strafe =		200,
					desc = _("upgrade-comms","increase combat maneuver strafe by 60%"),
					downgrade =	_("downgrade-comms","decreased maneuverability by 20%"),
				},
				{	--11
					max_front =		90,		max_back =		80,
					accel_front =	25,		accel_back = 	20,
					turn = 			15,
					boost =			300,	strafe =		200,
					desc = _("upgrade-comms","increase maneuverability by 25%"),
					downgrade =	_("downgrade-comms","decreased combat maneuver forward boost by 25%"),
				},
				{	--12
					max_front =		90,		max_back =		80,
					accel_front =	25,		accel_back = 	20,
					turn = 			15,
					boost =			400,	strafe =		200,
					desc = _("upgrade-comms","increase combat maneuver forward boost by 1/3"),
					downgrade =	_("downgrade-comms","decreased max forward impulse speed by 10%"),
				},
				{	--13
					max_front =		100,	max_back =		80,
					accel_front =	25,		accel_back = 	20,
					turn = 			15,
					boost =			400,	strafe =		200,
					desc = _("upgrade-comms","increase max forward impulse speed by ~11%"),
					downgrade =	_("downgrade-comms","decreased combat maneuver strafe by 20%"),
				},
				{	--14
					max_front =		100,	max_back =		80,
					accel_front =	25,		accel_back = 	20,
					turn = 			15,
					boost =			400,	strafe =		250,
					desc = _("upgrade-comms","increase combat maneuver strafe by 25%"),
					downgrade =	_("downgrade-comms","decreased max reverse impulse speed by ~11%"),
				},
				{	--14
					max_front =		100,	max_back =		90,
					accel_front =	25,		accel_back = 	20,
					turn = 			15,
					boost =			400,	strafe =		250,
					desc = _("upgrade-comms","increase max reverse impulse speed by 12.5%"),
					downgrade =	_("downgrade-comms","decreased forward acceleration by ~17%"),
				},
				{	--15
					max_front =		100,	max_back =		90,
					accel_front =	30,		accel_back = 	20,
					turn = 			15,
					boost =			400,	strafe =		250,
					desc = _("upgrade-comms","increase impulse forward acceleration by 20%"),
					downgrade =	_("downgrade-comms","decreased combat maneuver strafe by ~17%"),
				},
				{	--16
					max_front =		100,	max_back =		90,
					accel_front =	30,		accel_back = 	20,
					turn = 			15,
					boost =			400,	strafe =		300,
					desc = _("upgrade-comms","increase combat maneuver strafe by 20%"),
					downgrade =	_("downgrade-comms","decreased maneuverability by 25%"),
				},
				{	--17
					max_front =		100,	max_back =		90,
					accel_front =	30,		accel_back = 	20,
					turn = 			20,
					boost =			400,	strafe =		300,
					desc = _("upgrade-comms","increase maneuverability by 1/3"),
				},
				["stock"] = {
					{max_front = 90, turn = 10, accel_front = 20, max_back = 90, accel_back = 20, boost = 400, strafe = 250},
				},
				["start"] = 5,
			},
			["ftl"] = {
				{	--1
					jump_long = 0, jump_short = 0, warp = 0,
					downgrade =	_("downgrade-comms","removed jump drive"),
				},
				{	--2
					jump_long = 20000, jump_short = 2000, warp = 0,
					desc = _("upgrade-comms","add 20k jump drive"),
					downgrade =	_("downgrade-comms","reduced jump range by 20%"),
				},
				{	--3
					jump_long = 25000, jump_short = 2500, warp = 0,
					desc = _("upgrade-comms","increase jump range by 25%"),
					downgrade =	_("downgrade-comms","reduced jump range by ~17%"),
				},
				{	--4
					jump_long = 30000, jump_short = 3000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 20%"),
					downgrade =	_("downgrade-comms","reduced jump range by 25%"),
				},
				{	--5
					jump_long = 40000, jump_short = 4000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 1/3"),
					downgrade =	_("downgrade-comms","reduced jump range by 20%"),
				},
				{	--6
					jump_long = 50000, jump_short = 5000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 25%"),
					downgrade =	_("downgrade-comms","reduced jump range by ~9%"),
				},
				{	--7
					jump_long = 55000, jump_short = 5500, warp = 0,
					desc = _("upgrade-comms","increase jump range by 10%"),
					downgrade =	_("downgrade-comms","removed warp drive"),
				},
				{	--8
					jump_long = 55000, jump_short = 5500, warp = 400,
					desc = _("upgrade-comms","add warp drive"),
					downgrade =	_("downgrade-comms","reduced warp speed by 20%"),
				},
				{	--9
					jump_long = 55000, jump_short = 5500, warp = 500,
					desc = _("upgrade-comms","increase warp speed by 25%"),
					downgrade =	_("downgrade-comms","reduced jump range by ~8%"),
				},
				{	--10
					jump_long = 60000, jump_short = 6000, warp = 500,
					desc = _("upgrade-comms","increase jump range by ~9%"),
					downgrade =	_("downgrade-comms","reduced warp speed by ~17%"),
				},
				{	--11
					jump_long = 60000, jump_short = 6000, warp = 600,
					desc = _("upgrade-comms","increase warp speed by 20%"),
				},
				["stock"] = {
					{jump_long = 50000, jump_short = 5000, warp = 0},
				},
				["start"] = 4
			},
			["sensors"] = {
				{	--1
					short = 4000, long = 15000, prox_scan = 0,
					downgrade =	_("downgrade-comms","reduced long range sensors by 25%"),
				},
				{	--2
					short = 4000, long = 20000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by 1/3"),
					downgrade =	_("downgrade-comms","removed automated proximity scanner"),
				},
				{	--3
					short = 4000, long = 20000, prox_scan = 2,
					desc = _("upgrade-comms","add 2 unit automated proximity scanner"),
					downgrade =	_("downgrade-comms","reduced long range sensors by ~9%"),
				},
				{	--4
					short = 4000, long = 22000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by 10%"),
					downgrade =	_("downgrade-comms","reduced short range sensors by ~11%"),
				},
				{	--5
					short = 4500, long = 22000, prox_scan = 2,
					desc = _("upgrade-comms","increase short range sensors by 12.5%"),
					downgrade =	_("downgrade-comms","reduced long range sensors by 12%"),
				},
				{	--6
					short = 4500, long = 25000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by ~14%"),
					downgrade =	_("downgrade-comms","reduced long range sensors by ~17%"),
				},
				{	--7
					short = 4500, long = 30000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by 20%"),
					downgrade =	_("downgrade-comms","reduced short range sensors by 10%"),
				},
				{	--8
					short = 5000, long = 30000, prox_scan = 2,
					desc = _("upgrade-comms","increase short range sensors by ~11%"),
					downgrade =	_("downgrade-comms","reduced long range sensors by ~14%"),
				},
				{	--9
					short = 5000, long = 35000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by ~17%"),
					downgrade =	_("downgrade-comms","reduced long range sensors by 12.5%"),
				},
				{	--10
					short = 5000, long = 40000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by ~14%"),
					downgrade =	_("downgrade-comms","reduced automated proximity scanner by 1/3"),
				},
				{	--11
					short = 5000, long = 40000, prox_scan = 3,
					desc = _("upgrade-comms","increase automated proximity scanner by 50%"),
				},
				["stock"] = {
					{short = 5000, long = 30000}, prox_scan = 0,
				},
				["start"] = 4,
			},
			["providers"] = false,
			["score"] = 33,
		},
		["Crucible"] = {	--9 + beam(7) + missile(10) + shield(9) + hull(6) + impulse(17) + ftl(10) + sensors(11) = 79
			["beam"] = {
				{	--1
					{idx = 0, arc = 60, dir = -20, rng = 900, cyc = 7, dmg = 4},
					{idx = 1, arc = 60, dir =  20, rng = 900, cyc = 7, dmg = 4},
					["downgrade"] = _("downgrade-comms","reduced range by ~5%"),
				},
				{	--2
					{idx = 0, arc = 60, dir = -20, rng = 950, cyc = 7, dmg = 4},
					{idx = 1, arc = 60, dir =  20, rng = 950, cyc = 7, dmg = 4},
					["desc"] = _("upgrade-comms","increase range by ~6%"),
					["downgrade"] = _("downgrade-comms","increased cycle time by by ~8%"),
				},
				{	--3
					{idx = 0, arc = 60, dir = -20, rng = 950, cyc = 6.5, dmg = 4},
					{idx = 1, arc = 60, dir =  20, rng = 950, cyc = 6.5, dmg = 4},
					["desc"] = _("upgrade-comms","decrease cycle time by ~7%"),
					["downgrade"] = _("downgrade-comms","decreased damage by 20%"),
				},
				{	--4
					{idx = 0, arc = 60, dir = -20, rng = 950, cyc = 6.5, dmg = 5},
					{idx = 1, arc = 60, dir =  20, rng = 950, cyc = 6.5, dmg = 5},
					["desc"] = _("upgrade-comms","increase damage by 25%"),
					["downgrade"] = _("downgrade-comms","decreased range by 5%"),
				},
				{	--5
					{idx = 0, arc = 60, dir = -20, rng = 1000, cyc = 6.5, dmg = 5},
					{idx = 1, arc = 60, dir =  20, rng = 1000, cyc = 6.5, dmg = 5},
					["desc"] = _("upgrade-comms","increase range by ~5%"),
					["downgrade"] = _("downgrade-comms","increased cycle time by ~8%"),
				},
				{	--6
					{idx = 0, arc = 60, dir = -20, rng = 1000, cyc = 6, dmg = 5},
					{idx = 1, arc = 60, dir =  20, rng = 1000, cyc = 6, dmg = 5},
					["desc"] = _("upgrade-comms","decrease cycle time by 8%"),
					["downgrade"] = _("downgrade-comms","decreased range by ~9%"),
				},
				{	--7
					{idx = 0, arc = 60, dir = -20, rng = 1100, cyc = 6, dmg = 5},
					{idx = 1, arc = 60, dir =  20, rng = 1100, cyc = 6, dmg = 5},
					["desc"] = _("upgrade-comms","increase range by 10%"),
					["downgrade"] = _("downgrade-comms","decreased damage by ~17%"),
				},
				{	--8
					{idx = 0, arc = 60, dir = -20, rng = 1100, cyc = 6, dmg = 6},
					{idx = 1, arc = 60, dir =  20, rng = 1100, cyc = 6, dmg = 6},
					["desc"] = _("upgrade-comms","increase damage by 20%"),
				},
				["stock"] = {
					{idx = 0, arc = 70, dir = -30, rng = 1000, cyc = 6, dmg = 5},
					{idx = 1, arc = 70, dir =  30, rng = 1000, cyc = 6, dmg = 5},
				},
				["start"] = 3
			},
			["missiles"] = {
				{tube = 1,	ord = 1, downgrade = _("downgrade-comms","removed medium tube")},																							--1
				{tube = 2,	ord = 1, desc = _("upgrade-comms","add medium tube"), downgrade = _("downgrade-comms","reduced HVLI missile capacity")},									--2  
				{tube = 2,	ord = 2, desc = _("upgrade-comms","increase HVLI missile capacity"), downgrade = _("downgrade-comms","removed large tube and reduced HVLI capacity")},		--3  
				{tube = 3,	ord = 3, desc = _("upgrade-comms","add large tube and increase HVLI capacity"), downgrade = _("downgrade-comms","increased tube load times")},				--4
				{tube = 4,	ord = 3, desc = _("upgrade-comms","decrease tube load times"), downgrade = _("downgrade-comms","removed broadside tubes and homing missiles")},				--5
				{tube = 5,	ord = 4, desc = _("upgrade-comms","add broadside tubes and homing missiles"), downgrade = _("downgrade-comms","removed mining tube")},						--6
				{tube = 6,	ord = 5, desc = _("upgrade-comms","add mining tube"), downgrade = _("downgrade-comms","removed nukes and EMPs from broadside tubes")},						--7
				{tube = 7,	ord = 6, desc = _("upgrade-comms","add nukes and EMPs to broadside tubes"), downgrade = _("downgrade-comms","decreased heavy missile capacity")},			--8
				{tube = 7,	ord = 7, desc = _("upgrade-comms","increase heavy missile capacity"), downgrade = _("downgrade-comms","increased tube load times")},						--9
				{tube = 8,	ord = 7, desc = _("upgrade-comms","decrease tube load times"), downgrade = _("downgrade-comms","decreased missile capacity")},								--10
				{tube = 8,	ord = 8, desc = _("upgrade-comms","increase missile capacity")},																							--11
				["start"] = 4,
			},
			["tube"] = {
				{	--1
					{idx = 0, dir =   0, siz = "S", spd = 10, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--2
					{idx = 0, dir =   0, siz = "S", spd = 10, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   0, siz = "M", spd = 12, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--3
					{idx = 0, dir =   0, siz = "S", spd = 10, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   0, siz = "M", spd = 12, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir =   0, siz = "L", spd = 14, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--4
					{idx = 0, dir =   0, siz = "S", spd = 8,  hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   0, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir =   0, siz = "L", spd = 12, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--5
					{idx = 0, dir =   0, siz = "S", spd = 8,  hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   0, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir =   0, siz = "L", spd = 12, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 3, dir = -90, siz = "M", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 4, dir =  90, siz = "M", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
				},
				{	--6
					{idx = 0, dir =   0, siz = "S", spd = 8,  hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   0, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir =   0, siz = "L", spd = 12, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 3, dir = -90, siz = "M", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 4, dir =  90, siz = "M", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 5, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--7
					{idx = 0, dir =   0, siz = "S", spd = 8,  hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   0, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir =   0, siz = "L", spd = 12, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 3, dir = -90, siz = "M", spd = 10, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 4, dir =  90, siz = "M", spd = 10, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 5, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--8
					{idx = 0, dir =   0, siz = "S", spd = 6,  hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   0, siz = "M", spd = 8,  hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir =   0, siz = "L", spd = 10, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 3, dir = -90, siz = "M", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 4, dir =  90, siz = "M", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 5, dir = 180, siz = "M", spd = 8,  hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				["stock"] = {
					{idx = 0, dir =   0, siz = "S", spd = 8, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   0, siz = "M", spd = 8, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir =   0, siz = "L", spd = 8, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 3, dir = -90, siz = "M", spd = 8, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 4, dir =  90, siz = "M", spd = 8, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 5, dir = 180, siz = "M", spd = 8, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
			},
			["ordnance"] = {
				{hom = 0,  nuk = 0, emp = 0, min = 0, hvl = 12},	--1
				{hom = 0,  nuk = 0, emp = 0, min = 0, hvl = 18},	--2
				{hom = 0,  nuk = 0, emp = 0, min = 0, hvl = 24},	--3
				{hom = 6,  nuk = 0, emp = 0, min = 0, hvl = 24},	--4		
				{hom = 6,  nuk = 0, emp = 0, min = 4, hvl = 24},	--5		
				{hom = 8,  nuk = 2, emp = 4, min = 4, hvl = 24},	--6		
				{hom = 8,  nuk = 4, emp = 6, min = 6, hvl = 24},	--7	
				{hom = 12, nuk = 6, emp = 9, min = 8, hvl = 30},	--8		
				["stock"] = {hom = 8, nuk = 4, emp = 6, min = 6, hvl = 24},
			},
			["shield"] = {
				{	--1
					{idx = 0, max = 80},
					["downgrade"] = _("downgrade-comms","decreased shield charge capacity by 20%"),
				},
				{	--2
					{idx = 0, max = 100},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
					["downgrade"] = _("downgrade-comms","decreased shield charge capacity by ~17%"),
				},
				{	--3
					{idx = 0, max = 120},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
					["downgrade"] = _("downgrade-comms","removed rear shield arc"),
				},
				{	--4
					{idx = 0, max = 60},
					{idx = 1, max = 60},
					["desc"] = _("upgrade-comms","add rear shield arc"),
					["downgrade"] = _("downgrade-comms","decreased front shield charge capacity by 25%"),
				},
				{	--5
					{idx = 0, max = 80},
					{idx = 1, max = 60},
					["desc"] = _("upgrade-comms","increase front shield charge capacity by 1/3"),
					["downgrade"] = _("downgrade-comms","decreased rear shield charge capacity by 25%"),
				},
				{	--6
					{idx = 0, max = 80},
					{idx = 1, max = 80},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by 1/3"),
					["downgrade"] = _("downgrade-comms","decreased shield charge capacity by 20%"),
				},
				{	--7
					{idx = 0, max = 100},
					{idx = 1, max = 100},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
					["downgrade"] = _("downgrade-comms","decreased shield charge capacity by 1/3"),
				},
				{	--8
					{idx = 0, max = 150},
					{idx = 1, max = 150},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 50%"),
					["downgrade"] = _("downgrade-comms","decreased shield charge capacity by ~17%"),
				},
				{	--9
					{idx = 0, max = 180},
					{idx = 1, max = 180},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
					["downgrade"] = _("downgrade-comms","decreased shield charge capacity by 10%"),
				},
				{	--10
					{idx = 0, max = 200},
					{idx = 1, max = 200},
					["desc"] = _("upgrade-comms","increase shield charge capacity by ~11%"),
				},
				["stock"] = {
					{idx = 0, max = 160},
					{idx = 1, max = 160},
				},
				["start"] = 5,
			},	
			["hull"] = {
				{max = 100, downgrade = _("downgrade-comms","decreased hull max by ~17%")},																--1
				{max = 120, ["desc"] = _("upgrade-comms","increase hull max by 20%"), downgrade = _("downgrade-comms","decreased hull max by 1/7")},		--2
				{max = 140, ["desc"] = _("upgrade-comms","increase hull max by ~17%"), downgrade = _("downgrade-comms","decreased hull max by 1/8")},		--3
				{max = 160, ["desc"] = _("upgrade-comms","increase hull max by ~14%"), downgrade = _("downgrade-comms","decreased hull max by 1/9")},		--4
				{max = 180, ["desc"] = _("upgrade-comms","increase hull max by 12.5%"), downgrade = _("downgrade-comms","decreased hull max by 10%")},	--5
				{max = 200, ["desc"] = _("upgrade-comms","increase hull max by ~11%"), downgrade = _("downgrade-comms","decreased hull max by 1/11")},		--6
				{max = 220, ["desc"] = _("upgrade-comms","increase hull max by 10%")},		--7
				["stock"] = {max = 160},
				["start"] = 3,
			},
			["impulse"] = {
				{	--1
					max_front =		70,		max_back =		70,
					accel_front =	25,		accel_back = 	25,
					turn = 			15,
					boost =			0,		strafe =		0,
					downgrade = _("downgrade-comms","decreased max forward impulse speed by ~7%"),
				},
				{	--2
					max_front =		75,		max_back =		70,
					accel_front =	25,		accel_back = 	25,
					turn = 			15,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase max forward impulse speed by ~7%"),
					downgrade = _("downgrade-comms","removed combat maneuver forward boost"),
				},
				{	--3
					max_front =		75,		max_back =		70,
					accel_front =	25,		accel_back = 	25,
					turn = 			15,
					boost =			200,	strafe =		0,
					desc = _("upgrade-comms","add combat maneuver forward boost"),
					downgrade = _("downgrade-comms","decreased max reverse impulse speed by 1/8"),
				},
				{	--4
					max_front =		75,		max_back =		80,
					accel_front =	25,		accel_back = 	25,
					turn = 			15,
					boost =			200,	strafe =		0,
					desc = _("upgrade-comms","increase max reverse impulse speed by ~14%"),
					downgrade = _("downgrade-comms","removed combat maneuver strafe"),
				},
				{	--5
					max_front =		75,		max_back =		80,
					accel_front =	25,		accel_back = 	25,
					turn = 			15,
					boost =			200,	strafe =		150,
					desc = _("upgrade-comms","add combat maneuver strafe"),
					downgrade = _("downgrade-comms","decreased maneuverability by 25%"),
				},
				{	--6
					max_front =		75,		max_back =		80,
					accel_front =	25,		accel_back = 	25,
					turn = 			20,
					boost =			200,	strafe =		150,
					desc = _("upgrade-comms","increase maneuverability by 1/3"),
					downgrade = _("downgrade-comms","decreased max forward impulse speed by 1/16"),
				},
				{	--7
					max_front =		80,		max_back =		80,
					accel_front =	25,		accel_back = 	25,
					turn = 			20,
					boost =			200,	strafe =		150,
					desc = _("upgrade-comms","increase max forward impulse speed by ~7%"),
					downgrade = _("downgrade-comms","decreased combat maneuver forward boost by 20%"),
				},
				{	--8
					max_front =		80,		max_back =		80,
					accel_front =	25,		accel_back = 	25,
					turn = 			20,
					boost =			250,	strafe =		150,
					desc = _("upgrade-comms","increase combat maneuver forward boost by 25%"),
					downgrade = _("downgrade-comms","decreased impulse max forward speed by ~6%"),
				},
				{	--9
					max_front =		85,		max_back =		80,
					accel_front =	25,		accel_back = 	25,
					turn = 			20,
					boost =			250,	strafe =		150,
					desc = _("upgrade-comms","increase impulse max forward speed by 1/16"),
					downgrade = _("downgrade-comms","decreased combat maneuver strafe by 25%"),
				},
				{	--10
					max_front =		85,		max_back =		80,
					accel_front =	25,		accel_back = 	25,
					turn = 			20,
					boost =			250,	strafe =		200,
					desc = _("upgrade-comms","increase combat maneuver strafe by 1/3"),
					downgrade = _("downgrade-comms","decreased maneuverability by 20%"),
				},
				{	--11
					max_front =		85,		max_back =		80,
					accel_front =	25,		accel_back = 	25,
					turn = 			25,
					boost =			250,	strafe =		200,
					desc = _("upgrade-comms","increase maneuverability by 25%"),
					downgrade = _("downgrade-comms","decreased combat maneuver forward boost by 2/7"),
				},
				{	--12
					max_front =		85,		max_back =		80,
					accel_front =	25,		accel_back = 	25,
					turn = 			25,
					boost =			350,	strafe =		200,
					desc = _("upgrade-comms","increase combat maneuver forward boost by 60%"),
					downgrade = _("downgrade-comms","decreased impulse forward acceleration by 1/6"),
				},
				{	--13
					max_front =		85,		max_back =		80,
					accel_front =	30,		accel_back = 	25,
					turn = 			25,
					boost =			350,	strafe =		200,
					desc = _("upgrade-comms","increase impulse forward acceleration by 20%"),
					downgrade = _("downgrade-comms","decreased combat maneuver strafe by 20%"),
				},
				{	--14
					max_front =		85,		max_back =		80,
					accel_front =	30,		accel_back = 	25,
					turn = 			25,
					boost =			400,	strafe =		250,
					desc = _("upgrade-comms","increase combat maneuver strafe by 25% and boost by ~14%"),
					downgrade = _("downgrade-comms","decreased max reverse impulse speed by 1/9"),
				},
				{	--15
					max_front =		85,		max_back =		90,
					accel_front =	30,		accel_back = 	25,
					turn = 			25,
					boost =			400,	strafe =		250,
					desc = _("upgrade-comms","increase max reverse impulse speed by 12.5%"),
					downgrade = _("downgrade-comms","decreased impulse forward acceleration by 1/7"),
				},
				{	--16
					max_front =		85,		max_back =		90,
					accel_front =	35,		accel_back = 	25,
					turn = 			25,
					boost =			400,	strafe =		250,
					desc = _("upgrade-comms","increase impulse forward acceleration by ~17%"),
					downgrade = _("downgrade-comms","decreased combat maneuver strafe by 1/6"),
				},
				{	--17
					max_front =		85,		max_back =		90,
					accel_front =	35,		accel_back = 	25,
					turn = 			25,
					boost =			400,	strafe =		300,
					desc = _("upgrade-comms","increase combat maneuver strafe by 20%"),
					downgrade = _("downgrade-comms","decreased max impulse forward speed by 1/18 and reverse by 10%"),
				},
				{	--18
					max_front =		90,		max_back =		100,
					accel_front =	35,		accel_back = 	25,
					turn = 			25,
					boost =			400,	strafe =		300,
					desc = _("upgrade-comms","increase max impulse forward by ~6% and reverse by ~11%"),
				},
				["stock"] = {
					{max_front = 80, turn = 15, accel_front = 40, max_back = 80, accel_back = 40, boost = 400, strafe = 250},
				},
				["start"] = 5,
			},
			["ftl"] = {
				{	--1
					jump_long = 0, jump_short = 0, warp = 0,
					downgrade = _("downgrade-comms","removed warp drive"),
				},
				{	--2
					jump_long = 0, jump_short = 0, warp = 400,
					desc = _("upgrade-comms","add warp drive"),
					downgrade = _("downgrade-comms","reduced warp speed by 20%"),
				},
				{	--3
					jump_long = 0, jump_short = 0, warp = 500,
					desc = _("upgrade-comms","increase warp speed by 25%"),
					downgrade = _("downgrade-comms","reduced warp speed by 1/6"),
				},
				{	--4
					jump_long = 0, jump_short = 0, warp = 600,
					desc = _("upgrade-comms","increase warp speed by 20%"),
					downgrade = _("downgrade-comms","reduced warp speed by 1/7"),
				},
				{	--5
					jump_long = 0, jump_short = 0, warp = 700,
					desc = _("upgrade-comms","increase warp speed by ~17%"),
					downgrade = _("downgrade-comms","reduced warp speed by 1/15"),
				},
				{	--6
					jump_long = 0, jump_short = 0, warp = 750,
					desc = _("upgrade-comms","increase warp speed by ~7%"),
					downgrade = _("downgrade-comms","reduced warp speed by 1/16"),
				},
				{	--7
					jump_long = 0, jump_short = 0, warp = 800,
					desc = _("upgrade-comms","increase warp speed by ~7%"),
					downgrade = _("downgrade-comms","removed jump drive"),
				},
				{	--8
					jump_long = 20000, jump_short = 2000, warp = 800,
					desc = _("upgrade-comms","add jump drive"),
					downgrade = _("downgrade-comms","reduced jump range by 20%"),
				},
				{	--9
					jump_long = 25000, jump_short = 2500, warp = 800,
					desc = _("upgrade-comms","increase jump range by 25%"),
					downgrade = _("downgrade-comms","reduced warp speed by 1/9"),
				},
				{	--10
					jump_long = 25000, jump_short = 2500, warp = 900,
					desc = _("upgrade-comms","increase warp speed by 12.5%"),
					downgrade = _("downgrade-comms","reduced jump range by 1/6"),
				},
				{	--11
					jump_long = 30000, jump_short = 3000, warp = 900,
					desc = _("upgrade-comms","increase jump range by 20%"),
				},
				["stock"] = {
					{jump_long = 0, jump_short = 0, warp = 750},
				},
				["start"] = 3,
			},
			["sensors"] = {
				{	--1
					short = 4000, long = 15000, prox_scan = 0,
					downgrade = _("downgrade-comms","removed automated proximity scanner"),
				},
				{	--2
					short = 4000, long = 15000, prox_scan = 1,
					desc = _("upgrade-comms","add a one unit automated proximity scanner"),
					downgrade = _("downgrade-comms","reduced long range sensors by 20%"),
				},
				{	--3
					short = 4000, long = 20000, prox_scan = 1,
					desc = _("upgrade-comms","increase long range sensors by 25%"),
					downgrade = _("downgrade-comms","reduced long range sensors by ~9%"),
				},
				{	--4
					short = 4000, long = 22000, prox_scan = 1,
					desc = _("upgrade-comms","increase long range sensors by 10%"),
					downgrade = _("downgrade-comms","reduced short range sensors by ~11%"),
				},
				{	--5
					short = 4500, long = 22000, prox_scan = 1,
					desc = _("upgrade-comms","increase short range sensors by 12.5%"),
					downgrade = _("downgrade-comms","reduced long range sensors by 12%"),
				},
				{	--6
					short = 4500, long = 25000, prox_scan = 1,
					desc = _("upgrade-comms","increase long range sensors by ~14%"),
					downgrade = _("downgrade-comms","reduced long range sensors by 1/6"),
				},
				{	--7
					short = 4500, long = 30000, prox_scan = 1,
					desc = _("upgrade-comms","increase long range sensors by 20%"),
					downgrade = _("downgrade-comms","reduced short range sensors by 10%"),
				},
				{	--8
					short = 5000, long = 30000, prox_scan = 1,
					desc = _("upgrade-comms","increase short range sensors by ~11%"),
					downgrade = _("downgrade-comms","reduced long range sensors by 1/7"),
				},
				{	--9
					short = 5000, long = 35000, prox_scan = 1,
					desc = _("upgrade-comms","increase long range sensors by ~17%"),
					downgrade = _("downgrade-comms","cut automated proximity scanner range in half"),
				},
				{	--10
					short = 5000, long = 35000, prox_scan = 2,
					desc = _("upgrade-comms","double automated proximity scanner range"),
					downgrade = _("downgrade-comms","reduced long range sensors by 1/8"),
				},
				{	--11
					short = 5000, long = 40000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by ~14%"),
					downgrade = _("downgrade-comms","reduced short range sensors by 1/11"),
				},
				{	--12
					short = 5500, long = 40000, prox_scan = 2,
					desc = _("upgrade-comms","increase short range sensors by 10%"),
				},
				["stock"] = {
					{short = 5000, long = 30000}, prox_scan = 0,
				},
				["start"] = 4,
			},
			["providers"] = false,
			["score"] = 32,
		},
		["Maverick"] = {	--9 + beam(11) + missile(12) + shield(9) + hull(6) + impulse(17) + ftl(10) + sensors(11) = 85
			["beam"] = {
				{	--1
					{idx = 0, arc = 60, dir = -20, rng = 1000, cyc = 7, dmg = 5},
					{idx = 1, arc = 60, dir =  20, rng = 1000, cyc = 7, dmg = 5},
					downgrade = _("downgrade-comms","decrease range by 1/3"),
				},
				{	--2
					{idx = 0, arc = 60, dir = -20, rng = 1500, cyc = 7, dmg = 5},
					{idx = 1, arc = 60, dir =  20, rng = 1500, cyc = 7, dmg = 5},
					["desc"] = _("upgrade-comms","increase range by 50%"),
					downgrade = _("downgrade-comms","decrease arc by 20%"),
				},
				{	--3
					{idx = 0, arc = 75, dir = -20, rng = 1500, cyc = 7, dmg = 5},
					{idx = 1, arc = 75, dir =  20, rng = 1500, cyc = 7, dmg = 5},
					["desc"] = _("upgrade-comms","increase arc by 25%"),
					downgrade = _("downgrade-comms","removed beams"),
				},
				{	--4
					{idx = 0, arc = 75, dir = -20, rng = 1500, cyc = 7, dmg = 5},
					{idx = 1, arc = 75, dir =  20, rng = 1500, cyc = 7, dmg = 5},
					{idx = 2, arc = 40, dir = -70, rng = 1000, cyc = 7, dmg = 5},
					{idx = 3, arc = 40, dir =  70, rng = 1000, cyc = 7, dmg = 5},
					["desc"] = _("upgrade-comms","add beams"),
					downgrade = _("downgrade-comms","increased cycle time by 1/6"),
				},
				{	--5
					{idx = 0, arc = 75, dir = -20, rng = 1500, cyc = 6, dmg = 5},
					{idx = 1, arc = 75, dir =  20, rng = 1500, cyc = 6, dmg = 5},
					{idx = 2, arc = 40, dir = -70, rng = 1000, cyc = 6, dmg = 5},
					{idx = 3, arc = 40, dir =  70, rng = 1000, cyc = 6, dmg = 5},
					["desc"] = _("upgrade-comms","decrease cycle time by ~14%"),
					downgrade = _("downgrade-comms","removed sniping beam and reduced primary arcs by 1/6"),
				},
				{	--6
					{idx = 0, arc = 90, dir = -20, rng = 1500, cyc = 6, dmg = 5},
					{idx = 1, arc = 90, dir =  20, rng = 1500, cyc = 6, dmg = 5},
					{idx = 2, arc = 40, dir = -70, rng = 1000, cyc = 6, dmg = 5},
					{idx = 3, arc = 40, dir =  70, rng = 1000, cyc = 6, dmg = 5},
					{idx = 4, arc = 10, dir =   0, rng = 2000, cyc = 6, dmg = 5},
					["desc"] = _("upgrade-comms","add sniping beam, increase primary arcs by 20%"),
					downgrade = _("downgrade-comms","reduced damage by 1/6"),
				},
				{	--7
					{idx = 0, arc = 90, dir = -20, rng = 1500, cyc = 6, dmg = 6},
					{idx = 1, arc = 90, dir =  20, rng = 1500, cyc = 6, dmg = 6},
					{idx = 2, arc = 40, dir = -70, rng = 1000, cyc = 6, dmg = 6},
					{idx = 3, arc = 40, dir =  70, rng = 1000, cyc = 6, dmg = 6},
					{idx = 4, arc = 10, dir =   0, rng = 2000, cyc = 6, dmg = 6},
					["desc"] = _("upgrade-comms","increase damage by 20%"),
					downgrade = _("downgrade-comms","removed rear turret"),
				},
				{	--8
					{idx = 0, arc = 90, dir = -20, rng = 1500, cyc = 6, dmg = 6},
					{idx = 1, arc = 90, dir =  20, rng = 1500, cyc = 6, dmg = 6},
					{idx = 2, arc = 40, dir = -70, rng = 1000, cyc = 6, dmg = 6},
					{idx = 3, arc = 40, dir =  70, rng = 1000, cyc = 6, dmg = 6},
					{idx = 4, arc = 10, dir =   0, rng = 2000, cyc = 6, dmg = 6},
					{idx = 5, arc = 10, dir = 180, rng =  800, cyc = 6, dmg = 4, tar = 180, tdr = 180, trt = .5},
					["desc"] = _("upgrade-comms","add rear turret"),
					downgrade = _("downgrade-comms","reduced primary damage by 25%"),
				},
				{	--9
					{idx = 0, arc = 90, dir = -20, rng = 1500, cyc = 6, dmg = 8},
					{idx = 1, arc = 90, dir =  20, rng = 1500, cyc = 6, dmg = 8},
					{idx = 2, arc = 40, dir = -70, rng = 1000, cyc = 6, dmg = 6},
					{idx = 3, arc = 40, dir =  70, rng = 1000, cyc = 6, dmg = 6},
					{idx = 4, arc = 10, dir =   0, rng = 2000, cyc = 6, dmg = 6},
					{idx = 5, arc = 10, dir = 180, rng =  800, cyc = 6, dmg = 4, tar = 180, tdr = 180, trt = .5},
					["desc"] = _("upgrade-comms","increase primary damage by 1/3"),
					downgrade = _("downgrade-comms","increased secondary cycle time by 50%"),
				},
				{	--10
					{idx = 0, arc = 90, dir = -20, rng = 1500, cyc = 6, dmg = 8},
					{idx = 1, arc = 90, dir =  20, rng = 1500, cyc = 6, dmg = 8},
					{idx = 2, arc = 40, dir = -70, rng = 1000, cyc = 4, dmg = 6},
					{idx = 3, arc = 40, dir =  70, rng = 1000, cyc = 4, dmg = 6},
					{idx = 4, arc = 10, dir =   0, rng = 2000, cyc = 6, dmg = 6},
					{idx = 5, arc = 10, dir = 180, rng =  800, cyc = 6, dmg = 4, tar = 180, tdr = 180, trt = .5},
					["desc"] = _("upgrade-comms","decrease secondary cycle time by 1/3"),
					downgrade = _("downgrade-comms","reduced damage by ~15%"),
				},
				{	--11
					{idx = 0, arc = 90, dir = -20, rng = 1500, cyc = 6, dmg = 9},
					{idx = 1, arc = 90, dir =  20, rng = 1500, cyc = 6, dmg = 9},
					{idx = 2, arc = 40, dir = -70, rng = 1000, cyc = 4, dmg = 7},
					{idx = 3, arc = 40, dir =  70, rng = 1000, cyc = 4, dmg = 7},
					{idx = 4, arc = 10, dir =   0, rng = 2000, cyc = 6, dmg = 7},
					{idx = 5, arc = 10, dir = 180, rng =  800, cyc = 6, dmg = 5, tar = 180, tdr = 180, trt = .5},
					["desc"] = _("upgrade-comms","increase damage by ~17%"),
					downgrade = _("downgrade-comms","cut turret speed in half"),
				},
				{	--12
					{idx = 0, arc = 90, dir = -20, rng = 1500, cyc = 6, dmg = 9},
					{idx = 1, arc = 90, dir =  20, rng = 1500, cyc = 6, dmg = 9},
					{idx = 2, arc = 40, dir = -70, rng = 1000, cyc = 4, dmg = 7},
					{idx = 3, arc = 40, dir =  70, rng = 1000, cyc = 4, dmg = 7},
					{idx = 4, arc = 10, dir =   0, rng = 2000, cyc = 6, dmg = 7},
					{idx = 5, arc = 10, dir = 180, rng =  800, cyc = 6, dmg = 5, tar = 180, tdr = 180, trt = 1},
					["desc"] = _("upgrade-comms","double turret speed"),
				},
				["stock"] = {
					{idx = 0, arc = 10, dir =   0, rng = 2000, cyc = 6, dmg = 6},
					{idx = 1, arc = 90, dir = -20, rng = 1500, cyc = 6, dmg = 8},
					{idx = 2, arc = 90, dir =  20, rng = 1500, cyc = 6, dmg = 8},
					{idx = 3, arc = 40, dir = -70, rng = 1000, cyc = 4, dmg = 6},
					{idx = 4, arc = 40, dir =  70, rng = 1000, cyc = 4, dmg = 6},
					{idx = 5, arc = 10, dir = 180, rng =  800, cyc = 6, dmg = 4, tar = 180, tdr = 180, trt = .5},
				},
				["start"] = 5,
			},
			["missiles"] = {
				{tube = 1,	ord = 1, downgrade = _("downgrade-comms","removed homing")},																					--1
				{tube = 2,	ord = 2, desc = _("upgrade-comms","add homing"), downgrade = _("downgrade-comms","cut homing missile capacity in half")},						--2  
				{tube = 2,	ord = 3, desc = _("upgrade-comms","double homing missile capacity"), downgrade = _("downgrade-comms","increased tube load speed by 25%")},		--3  
				{tube = 3,	ord = 3, desc = _("upgrade-comms","decrease tube load speed by 20%"), downgrade = _("downgrade-comms","reduced HVLI capacity by 20%")},			--4
				{tube = 3,	ord = 4, desc = _("upgrade-comms","increase HVLI capacity by 25%"), downgrade = _("downgrade-comms","removed mining tube")},					--5
				{tube = 4,	ord = 5, desc = _("upgrade-comms","add mining tube"), downgrade = _("downgrade-comms","removed EMPs")},											--6
				{tube = 5,	ord = 6, desc = _("upgrade-comms","add EMPs"), downgrade = _("downgrade-comms","removed nuke capability")},										--7
				{tube = 6,	ord = 7, desc = _("upgrade-comms","add nuke capability"), downgrade = _("downgrade-comms","decreased tube size")},								--8
				{tube = 7,	ord = 7, desc = _("upgrade-comms","increase tube size"), downgrade = _("downgrade-comms","reduced homing, nuke and EMP missiles")},				--9
				{tube = 7,	ord = 8, desc = _("upgrade-comms","more homing, nuke and EMP missiles"), downgrade = _("downgrade-comms","reduced mine loading speed by 25%")},	--10
				{tube = 8,	ord = 8, desc = _("upgrade-comms","20% faster mine loading"), downgrade = _("downgrade-comms","reduced homing, mine and HVLI missiles")},		--11
				{tube = 8,	ord = 9, desc = _("upgrade-comms","more homing, mine and HVLI missiles"), downgrade = _("downgrade-comms","reduced mines and HVLIs")},			--12
				{tube = 8,	ord = 10,desc = _("upgrade-comms","more mine and HVLI missiles")},																				--13
				["start"] = 3
			},
			["tube"] = {
				{	--1
					{idx = 0, dir = -90, siz = "S", spd = 10, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  90, siz = "S", spd = 10, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--2
					{idx = 0, dir = -90, siz = "S", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  90, siz = "S", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
				},
				{	--3
					{idx = 0, dir = -90, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  90, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
				},
				{	--4
					{idx = 0, dir = -90, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  90, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--5
					{idx = 0, dir = -90, siz = "S", spd = 8,  hom = true,  nuk = false, emp = true,  min = false, hvl = true },
					{idx = 1, dir =  90, siz = "S", spd = 8,  hom = true,  nuk = false, emp = true,  min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--6
					{idx = 0, dir = -90, siz = "S", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 1, dir =  90, siz = "S", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--7
					{idx = 0, dir = -90, siz = "M", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 1, dir =  90, siz = "M", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--8
					{idx = 0, dir = -90, siz = "M", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 1, dir =  90, siz = "M", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 8,  hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				["stock"] = {
					{idx = 0, dir = -90, siz = "M", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 1, dir =  90, siz = "M", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 8,  hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
			},
			["ordnance"] = {
				{hom = 0,  nuk = 0, emp = 0, min = 0, hvl = 8},		--1
				{hom = 2,  nuk = 0, emp = 0, min = 0, hvl = 8},		--2
				{hom = 4,  nuk = 0, emp = 0, min = 0, hvl = 8},		--3
				{hom = 4,  nuk = 0, emp = 0, min = 0, hvl = 10},	--4		
				{hom = 4,  nuk = 0, emp = 0, min = 2, hvl = 10},	--5		
				{hom = 4,  nuk = 0, emp = 2, min = 2, hvl = 10},	--6		
				{hom = 4,  nuk = 1, emp = 2, min = 2, hvl = 10},	--7		
				{hom = 6,  nuk = 2, emp = 4, min = 2, hvl = 10},	--8	
				{hom = 8,  nuk = 2, emp = 4, min = 3, hvl = 12},	--9		
				{hom = 8,  nuk = 2, emp = 4, min = 5, hvl = 14},	--10		
				["stock"] = {hom = 6, nuk = 2, emp = 4, min = 2, hvl = 10},
			},
			["shield"] = {
				{	--1
					{idx = 0, max = 80},
					downgrade = _("downgrade-comms","reduced shield charge capacity by 20%"),
				},
				{	--2
					{idx = 0, max = 100},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
					downgrade = _("downgrade-comms","reduced shield charge capacity by 1/6"),
				},
				{	--3
					{idx = 0, max = 120},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
					downgrade = _("downgrade-comms","removed rear shield arc"),
				},
				{	--4
					{idx = 0, max = 60},
					{idx = 1, max = 60},
					["desc"] = _("upgrade-comms","add rear shield arc"),
					downgrade = _("downgrade-comms","reduced front shield charge capacity by 25%"),
				},
				{	--5
					{idx = 0, max = 80},
					{idx = 1, max = 60},
					["desc"] = _("upgrade-comms","increase front shield charge capacity by 1/3"),
					downgrade = _("downgrade-comms","reduced rear shield charge capacity by 20%"),
				},
				{	--6
					{idx = 0, max = 80},
					{idx = 1, max = 80},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by 1/3"),
					downgrade = _("downgrade-comms","reduced shield charge capacity by 20%"),
				},
				{	--7
					{idx = 0, max = 100},
					{idx = 1, max = 100},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
					downgrade = _("downgrade-comms","reduced shield charge capacity by 1/3"),
				},
				{	--8
					{idx = 0, max = 150},
					{idx = 1, max = 150},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 50%"),
					downgrade = _("downgrade-comms","reduced shield charge capacity by 1/6"),
				},
				{	--9
					{idx = 0, max = 180},
					{idx = 1, max = 180},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
					downgrade = _("downgrade-comms","reduced chield charge capacity by 10%"),
				},
				{	--10
					{idx = 0, max = 200},
					{idx = 1, max = 200},
					["desc"] = _("upgrade-comms","increase shield charge capacity by ~11%"),
				},
				["stock"] = {
					{idx = 0, max = 160},
					{idx = 1, max = 160},
				},
				["start"] = 5,
			},	
			["hull"] = {
				{max = 100},															--1
				{max = 120, ["desc"] = _("upgrade-comms","increase hull max by 20%"),	downgrade = _("downgrade-comms","reduced hull max by 1/7")},	--2
				{max = 140, ["desc"] = _("upgrade-comms","increase hull max by ~17%"),	downgrade = _("downgrade-comms","reduced hull max by 1/8")},	--3
				{max = 160, ["desc"] = _("upgrade-comms","increase hull max by ~14%"),	downgrade = _("downgrade-comms","reduced hull max by 1/9")},	--4
				{max = 180, ["desc"] = _("upgrade-comms","increase hull max by 12.5%"),	downgrade = _("downgrade-comms","reduced hull max by 10%")},--5
				{max = 200, ["desc"] = _("upgrade-comms","increase hull max by ~11%"),	downgrade = _("downgrade-comms","reduced hull max by 1/11")},	--6
				{max = 220, ["desc"] = _("upgrade-comms","increase hull max by 10%")},	--7
				["stock"] = {max = 160},
				["start"] = 3,
			},
			["impulse"] = {
				{	--1
					max_front =		70,		max_back =		70,
					accel_front =	25,		accel_back = 	25,
					turn = 			15,
					boost =			0,		strafe =		0,
					downgrade = _("downgrade-comms","reduced max forward impulse speed by 1/15"),
				},
				{	--2
					max_front =		75,		max_back =		70,
					accel_front =	25,		accel_back = 	25,
					turn = 			15,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase max forward impulse speed by ~7%"),
					downgrade = _("downgrade-comms","removed combat maneuver"),
				},
				{	--3
					max_front =		75,		max_back =		70,
					accel_front =	25,		accel_back = 	25,
					turn = 			15,
					boost =			200,	strafe =		0,
					desc = _("upgrade-comms","add combat maneuver forward boost"),
					downgrade = _("downgrade-comms","reduced max reverse impulse speed by 1/8"),
				},
				{	--4
					max_front =		75,		max_back =		80,
					accel_front =	25,		accel_back = 	25,
					turn = 			15,
					boost =			200,	strafe =		0,
					desc = _("upgrade-comms","increase max reverse impulse speed by ~14%"),
					downgrade = _("downgrade-comms","removed combat maneuver strafe"),
				},
				{	--5
					max_front =		75,		max_back =		80,
					accel_front =	25,		accel_back = 	25,
					turn = 			15,
					boost =			200,	strafe =		150,
					desc = _("upgrade-comms","add combat maneuver strafe"),
					downgrade = _("downgrade-comms","reduced maneuverability by 25%"),
				},
				{	--6
					max_front =		75,		max_back =		80,
					accel_front =	25,		accel_back = 	25,
					turn = 			20,
					boost =			200,	strafe =		150,
					desc = _("upgrade-comms","increase maneuverability by 1/3"),
					downgrade = _("downgrade-comms","reduced max forward impulse speed by 1/16"),
				},
				{	--7
					max_front =		80,		max_back =		80,
					accel_front =	25,		accel_back = 	25,
					turn = 			20,
					boost =			200,	strafe =		150,
					desc = _("upgrade-comms","increase max forward impulse speed by ~7%"),
					downgrade = _("downgrade-comms","reduced combat maneuver forward boost by 20%"),
				},
				{	--8
					max_front =		80,		max_back =		80,
					accel_front =	25,		accel_back = 	25,
					turn = 			20,
					boost =			250,	strafe =		150,
					desc = _("upgrade-comms","increase combat maneuver forward boost by 25%"),
					downgrade = _("downgrade-comms","reduced max forward impulse speed by ~6%"),
				},
				{	--9
					max_front =		85,		max_back =		80,
					accel_front =	25,		accel_back = 	25,
					turn = 			20,
					boost =			250,	strafe =		150,
					desc = _("upgrade-comms","increase max forward impulse impulse speed by 6.25%"),
					downgrade = _("downgrade-comms","reduced combat maneuver strafe by 25%"),
				},
				{	--10
					max_front =		85,		max_back =		80,
					accel_front =	25,		accel_back = 	25,
					turn = 			20,
					boost =			250,	strafe =		200,
					desc = _("upgrade-comms","increase combat maneuver strafe by 1/3"),
					downgrade = _("downgrade-comms","reduced maneuverability by 20%"),
				},
				{	--11
					max_front =		85,		max_back =		80,
					accel_front =	25,		accel_back = 	25,
					turn = 			25,
					boost =			250,	strafe =		200,
					desc = _("upgrade-comms","increase maneuverability by 25%"),
					downgrade = _("downgrade-comms","reduced combat maneuver forward boost by 2/7"),
				},
				{	--12
					max_front =		85,		max_back =		80,
					accel_front =	25,		accel_back = 	25,
					turn = 			25,
					boost =			350,	strafe =		200,
					desc = _("upgrade-comms","increase combat maneuver forward boost by 60%"),
					downgrade = _("downgrade-comms","reduced impulse forward acceleration by 1/6"),
				},
				{	--13
					max_front =		85,		max_back =		80,
					accel_front =	30,		accel_back = 	25,
					turn = 			25,
					boost =			350,	strafe =		200,
					desc = _("upgrade-comms","increase impulse forward acceleration by 20%"),
					downgrade = _("downgrade-comms","reduced combat maneuver strafe by 20% and boost by 1/8"),
				},
				{	--14
					max_front =		85,		max_back =		80,
					accel_front =	30,		accel_back = 	25,
					turn = 			25,
					boost =			400,	strafe =		250,
					desc = _("upgrade-comms","increase combat maneuver strafe by 25% and boost by ~14%"),
					downgrade = _("downgrade-comms","reduced max reverse impulse speed by 1/9"),
				},
				{	--15
					max_front =		85,		max_back =		90,
					accel_front =	30,		accel_back = 	25,
					turn = 			25,
					boost =			400,	strafe =		250,
					desc = _("upgrade-comms","increase max reverse impulse speed by 12.5%"),
					downgrade = _("downgrade-comms","reduced impulse forward acceleration by 1/7"),
				},
				{	--16
					max_front =		85,		max_back =		90,
					accel_front =	35,		accel_back = 	25,
					turn = 			25,
					boost =			400,	strafe =		250,
					desc = _("upgrade-comms","increase impulse forward acceleration by ~17%"),
					downgrade = _("downgrade-comms","reduced combat maneuver strafe by 1/6"),
				},
				{	--17
					max_front =		85,		max_back =		90,
					accel_front =	35,		accel_back = 	25,
					turn = 			25,
					boost =			400,	strafe =		300,
					desc = _("upgrade-comms","increase combat maneuver strafe by 20%"),
					downgrade = _("downgrade-comms","reduced max impulse forward speed by ~6% and reverse by 10%"),
				},
				{	--18
					max_front =		90,		max_back =		100,
					accel_front =	35,		accel_back = 	25,
					turn = 			25,
					boost =			400,	strafe =		300,
					desc = _("upgrade-comms","increase max impulse forward by ~6% and reverse by ~11%"),
				},
				["stock"] = {
					{max_front = 80, turn = 15, accel_front = 40, max_back = 80, accel_back = 40, boost = 400, strafe = 250},
				},
				["start"] = 5,
			},
			["ftl"] = {
				{	--1
					jump_long = 0, jump_short = 0, warp = 0,
					downgrade = _("downgrade-comms","removed warp drive"),
				},
				{	--2
					jump_long = 0, jump_short = 0, warp = 400,
					desc = _("upgrade-comms","add warp drive"),
					downgrade = _("downgrade-comms","reduced warp speed by 20%"),
				},
				{	--3
					jump_long = 0, jump_short = 0, warp = 500,
					desc = _("upgrade-comms","increase warp speed by 25%"),
					downgrade = _("downgrade-comms","reduced warp speed by 1/6"),
				},
				{	--4
					jump_long = 0, jump_short = 0, warp = 600,
					desc = _("upgrade-comms","increase warp speed by 20%"),
					downgrade = _("downgrade-comms","reduced warp speed by 1/7"),
				},
				{	--5
					jump_long = 0, jump_short = 0, warp = 700,
					desc = _("upgrade-comms","increase warp speed by ~17%"),
					downgrade = _("downgrade-comms","reduced warp speed by 1/15"),
				},
				{	--6
					jump_long = 0, jump_short = 0, warp = 750,
					desc = _("upgrade-comms","increase warp speed by ~7%"),
					downgrade = _("downgrade-comms","reduced warp speed by 1/16"),
				},
				{	--7
					jump_long = 0, jump_short = 0, warp = 800,
					desc = _("upgrade-comms","increase warp speed by ~7%"),
					downgrade = _("downgrade-comms","removed jump drive"),
				},
				{	--8
					jump_long = 20000, jump_short = 2000, warp = 800,
					desc = _("upgrade-comms","add jump drive"),
					downgrade = _("downgrade-comms","reduced jump range by 20%"),
				},
				{	--9
					jump_long = 25000, jump_short = 2500, warp = 800,
					desc = _("upgrade-comms","increase jump range by 25%"),
					downgrade = _("downgrade-comms","reduced warp speed by 1/9"),
				},
				{	--10
					jump_long = 25000, jump_short = 2500, warp = 900,
					desc = _("upgrade-comms","increase warp speed by 12.5%"),
					downgrade = _("downgrade-comms","reduced jump range by 1/6")
				},
				{	--11
					jump_long = 30000, jump_short = 3000, warp = 900,
					desc = _("upgrade-comms","increase jump range by 20%"),
				},
				["stock"] = {
					{jump_long = 0, jump_short = 0, warp = 750},
				},
				["start"] = 3,
			},
			["sensors"] = {
				{	--1
					short = 4000, long = 15000, prox_scan = 0,
					downgrade = _("downgrade-comms","removed automated proximity scanner"),
				},
				{	--2
					short = 4000, long = 15000, prox_scan = 1,
					desc = _("upgrade-comms","add a one unit automated proximity scanner"),
					downgrade = _("downgrade-comms","reduced long range sensors by 25%"),
				},
				{	--3
					short = 4000, long = 20000, prox_scan = 1,
					desc = _("upgrade-comms","increase long range sensors by 1/3"),
					downgrade = _("downgrade-comms","reduced long range sensors by 1/11"),
				},
				{	--4
					short = 4000, long = 22000, prox_scan = 1,
					desc = _("upgrade-comms","increase long range sensors by 10%"),
					downgrade = _("downgrade-comms","reduced short range sensors by 1/9"),
				},
				{	--5
					short = 4500, long = 22000, prox_scan = 1,
					desc = _("upgrade-comms","increase short range sensors by 12.5%"),
					downgrade = _("downgrade-comms","reduced long range sensors by ~14%"),
				},
				{	--6
					short = 4500, long = 25000, prox_scan = 1,
					desc = _("upgrade-comms","increase long range sensors by ~14%"),
					downgrade = _("downgrade-comms","reduced long range sensors by 1/6"),
				},
				{	--7
					short = 4500, long = 30000, prox_scan = 1,
					desc = _("upgrade-comms","increase long range sensors by 20%"),
					downgrade = _("downgrade-comms","reduced short range sensors by 10%"),
				},
				{	--8
					short = 5000, long = 30000, prox_scan = 1,
					desc = _("upgrade-comms","increase short range sensors by ~11%"),
					downgrade = _("downgrade-comms","reduced long range sensors by 1/7"),
				},
				{	--9
					short = 5000, long = 35000, prox_scan = 1,
					desc = _("upgrade-comms","increase long range sensors by ~17%"),
					downgrade = _("downgrade-comms","cut automated proximity scanner range in half"),
				},
				{	--10
					short = 5000, long = 35000, prox_scan = 2,
					desc = _("upgrade-comms","double automated proximity scanner range"),
					downgrade = _("downgrade-comms","reduced long range sensors by 1/8"),
				},
				{	--11
					short = 5000, long = 40000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by ~14%"),
					downgrade = _("downgrade-comms","reduced short range sensors by 1/11"),
				},
				{	--12
					short = 5500, long = 40000, prox_scan = 2,
					desc = _("upgrade-comms","increase short range sensors by 10%"),
				},
				["stock"] = {
					{short = 5000, long = 30000}, prox_scan = 0,
				},
				["start"] = 4,
			},
			["providers"] = false,
			["score"] = 30,
		},
		["Benedict"] = {	--7 + beam(9) + missile(13) + shield(9) + hull(6) + impulse(17) + ftl(10) + sensors(9) = 81
			["beam"] = {
				{	--1
					{idx = 0, arc = 10, dir =   0, rng = 1000, cyc = 7, dmg = 4, tar = 30, tdr =   0, trt = 4},
					{idx = 1, arc = 10, dir = 180, rng = 1000, cyc = 7, dmg = 4, tar = 30, tdr = 180, trt = 4},
				},
				{	--2
					{idx = 0, arc = 10, dir =   0, rng = 1000, cyc = 7, dmg = 4, tar = 60, tdr =   0, trt = 4},
					{idx = 1, arc = 10, dir = 180, rng = 1000, cyc = 7, dmg = 4, tar = 60, tdr = 180, trt = 4},
					["desc"] = _("upgrade-comms","double arc width")
				},
				{	--3
					{idx = 0, arc = 10, dir =   0, rng = 1000, cyc = 7, dmg = 4, tar = 60, tdr =   0, trt = 5},
					{idx = 1, arc = 10, dir = 180, rng = 1000, cyc = 7, dmg = 4, tar = 60, tdr = 180, trt = 5},
					["desc"] = _("upgrade-comms","increase turret speed by 25%")
				},
				{	--4
					{idx = 0, arc = 10, dir =   0, rng = 1000, cyc = 7, dmg = 4, tar = 90, tdr =   0, trt = 5},
					{idx = 1, arc = 10, dir = 180, rng = 1000, cyc = 7, dmg = 4, tar = 90, tdr = 180, trt = 5},
					["desc"] = _("upgrade-comms","increase arc width by 50%")
				},
				{	--5
					{idx = 0, arc = 10, dir =   0, rng = 1000, cyc = 6, dmg = 4, tar = 90, tdr =   0, trt = 5},
					{idx = 1, arc = 10, dir = 180, rng = 1000, cyc = 6, dmg = 4, tar = 90, tdr = 180, trt = 5},
					["desc"] = _("upgrade-comms","decrease cycle time by ~14%"),
				},
				{	--6
					{idx = 0, arc = 10, dir =   0, rng = 1000, cyc = 6, dmg = 4, tar = 90, tdr =   0, trt = 5},
					{idx = 1, arc = 10, dir = 180, rng = 1000, cyc = 6, dmg = 4, tar = 90, tdr = 180, trt = 5},
					{idx = 2, arc = 10, dir = -90, rng = 1000, cyc = 6, dmg = 4, tar = 40, tdr = -90, trt = 5},
					{idx = 3, arc = 10, dir =  90, rng = 1000, cyc = 6, dmg = 4, tar = 40, tdr =  90, trt = 5},
					["desc"] = _("upgrade-comms","add beams"),
				},
				{	--7
					{idx = 0, arc = 10, dir =   0, rng = 1500, cyc = 6, dmg = 4, tar = 90, tdr =   0, trt = 5},
					{idx = 1, arc = 10, dir = 180, rng = 1500, cyc = 6, dmg = 4, tar = 90, tdr = 180, trt = 5},
					{idx = 2, arc = 10, dir = -90, rng = 1500, cyc = 6, dmg = 4, tar = 40, tdr = -90, trt = 5},
					{idx = 3, arc = 10, dir =  90, rng = 1500, cyc = 6, dmg = 4, tar = 40, tdr =  90, trt = 5},
					["desc"] = _("upgrade-comms","increase range by 50%"),
				},
				{	--8
					{idx = 0, arc = 10, dir =   0, rng = 1500, cyc = 6, dmg = 4, tar = 110, tdr =   0, trt = 5},
					{idx = 1, arc = 10, dir = 180, rng = 1500, cyc = 6, dmg = 4, tar = 110, tdr = 180, trt = 5},
					{idx = 2, arc = 10, dir = -90, rng = 1500, cyc = 6, dmg = 4, tar = 110, tdr = -90, trt = 5},
					{idx = 3, arc = 10, dir =  90, rng = 1500, cyc = 6, dmg = 4, tar = 110, tdr =  90, trt = 5},
					["desc"] = _("upgrade-comms","overlap arcs"),
				},
				{	--9
					{idx = 0, arc = 10, dir =   0, rng = 1500, cyc = 6, dmg = 4, tar = 110, tdr =   0, trt = 6},
					{idx = 1, arc = 10, dir = 180, rng = 1500, cyc = 6, dmg = 4, tar = 110, tdr = 180, trt = 6},
					{idx = 2, arc = 10, dir = -90, rng = 1500, cyc = 6, dmg = 4, tar = 110, tdr = -90, trt = 6},
					{idx = 3, arc = 10, dir =  90, rng = 1500, cyc = 6, dmg = 4, tar = 110, tdr =  90, trt = 6},
					["desc"] = _("upgrade-comms","increase turret speed by 20%"),
				},
				{	--10
					{idx = 0, arc = 10, dir =   0, rng = 1500, cyc = 6, dmg = 5, tar = 110, tdr =   0, trt = 6},
					{idx = 1, arc = 10, dir = 180, rng = 1500, cyc = 6, dmg = 5, tar = 110, tdr = 180, trt = 6},
					{idx = 2, arc = 10, dir = -90, rng = 1500, cyc = 6, dmg = 5, tar = 110, tdr = -90, trt = 6},
					{idx = 3, arc = 10, dir =  90, rng = 1500, cyc = 6, dmg = 5, tar = 110, tdr =  90, trt = 6},
					["desc"] = _("upgrade-comms","increase damage by 25%"),
				},
				["stock"] = {
					{idx = 0, arc = 10, dir =   0, rng = 1500, cyc = 6, dmg = 4, tar = 90, tdr =   0, trt = 6},
					{idx = 1, arc = 10, dir = 180, rng = 1500, cyc = 6, dmg = 4, tar = 90, tdr = 180, trt = 6},
				},
				["start"] = 4,
			},
			["missiles"] = {
				{tube = 1,	ord = 1},																		--1
				{tube = 2,	ord = 2, desc = _("upgrade-comms","add mines")},								--2  
				{tube = 3,	ord = 2, desc = _("upgrade-comms","speed up tube load speed by 25%")},			--3  
				{tube = 3,	ord = 3, desc = _("upgrade-comms","increase mine capacity by 50%")},			--4
				{tube = 4,	ord = 3, desc = _("upgrade-comms","speed up tube load speed by 1/3")},			--5
				{tube = 4,	ord = 4, desc = _("upgrade-comms","increase mine capacity by 1/3")},			--6
				{tube = 5,	ord = 4, desc = _("upgrade-comms","speed up mine load speed by ~17%")},			--7
				{tube = 5,	ord = 5, desc = _("upgrade-comms","increase mine capacity by 25%")},			--8
				{tube = 6,	ord = 6, desc = _("upgrade-comms","add homing missiles")},						--9
				{tube = 6,	ord = 7, desc = _("upgrade-comms","double homing missile capacity")},			--10
				{tube = 7,	ord = 7, desc = _("upgrade-comms","speed up mine loading speed by 20%")},		--11
				{tube = 7,	ord = 8, desc = _("upgrade-comms","increase homing missile capacity by 50%")},	--12
				{tube = 8,	ord = 8, desc = _("upgrade-comms","medium sized homing misile tubes")},			--13
				{tube = 8,	ord = 9, desc = _("upgrade-comms","increase mine capacity by 20%")},			--14
				["start"] = 4,
			},
			["tube"] = {
				{	--1
					{idx = -1},
				},
				{	--2
					{idx = 0, dir = 180, siz = "M", spd = 20, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--3
					{idx = 0, dir = 180, siz = "M", spd = 15, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--4
					{idx = 0, dir = 180, siz = "M", spd = 12, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--5
					{idx = 0, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--6
					{idx = 0, dir =   0, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir =  60, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 2, dir = 120, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 3, dir = 300, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 4, dir = 240, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 5, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--7
					{idx = 0, dir =   0, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir =  60, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 2, dir = 120, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 3, dir = 300, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 4, dir = 240, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 5, dir = 180, siz = "M", spd = 8,  hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--8
					{idx = 0, dir =   0, siz = "M", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir =  60, siz = "M", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 2, dir = 120, siz = "M", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 3, dir = 300, siz = "M", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 4, dir = 240, siz = "M", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 5, dir = 180, siz = "M", spd = 8,  hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				["stock"] = {
					{idx = -1},
				},
			},
			["ordnance"] = {
				{hom = 0,  nuk = 0, emp = 0, min = 0, hvl = 0},		--1
				{hom = 0,  nuk = 0, emp = 0, min = 2, hvl = 0},		--2
				{hom = 0,  nuk = 0, emp = 0, min = 3, hvl = 0},		--3
				{hom = 0,  nuk = 0, emp = 0, min = 4, hvl = 0},		--4		
				{hom = 0,  nuk = 0, emp = 0, min = 5, hvl = 0},		--5		
				{hom = 5,  nuk = 0, emp = 0, min = 5, hvl = 0},		--6		
				{hom = 10, nuk = 0, emp = 0, min = 5, hvl = 0},		--7		
				{hom = 15, nuk = 0, emp = 0, min = 5, hvl = 0},		--8		
				{hom = 15, nuk = 0, emp = 0, min = 6, hvl = 0},		--9		
				["stock"] = {hom = 0, nuk = 0, emp = 0, min = 0, hvl = 0},
			},
			["shield"] = {
				{	--1
					{idx = 0, max = 50},
				},
				{	--2
					{idx = 0, max = 60},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--3
					{idx = 0, max = 70},
					["desc"] = _("upgrade-comms","increase shield charge capacity by ~17%"),
				},
				{	--4
					{idx = 0, max = 50},
					{idx = 1, max = 50},
					["desc"] = _("upgrade-comms","add rear shield arc"),
				},
				{	--5
					{idx = 0, max = 60},
					{idx = 1, max = 60},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--6
					{idx = 0, max = 80},
					{idx = 1, max = 80},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 1/3"),
				},
				{	--7
					{idx = 0, max = 100},
					{idx = 1, max = 100},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--8
					{idx = 0, max = 100},
					{idx = 1, max = 150},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by 50%"),
				},
				{	--9
					{idx = 0, max = 100},
					{idx = 1, max = 180},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by 20%"),
				},
				{	--10
					{idx = 0, max = 100},
					{idx = 1, max = 200},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by ~11%"),
				},
				["stock"] = {
					{idx = 0, max = 70},
					{idx = 1, max = 70},
				},
				["start"] = 3,
			},	
			["hull"] = {
				{max = 100},															--1
				{max = 120, ["desc"] = _("upgrade-comms","increase hull max by 20%")},	--2
				{max = 150, ["desc"] = _("upgrade-comms","increase hull max by 25%")},	--3
				{max = 180, ["desc"] = _("upgrade-comms","increase hull max by 20%")},	--4
				{max = 200, ["desc"] = _("upgrade-comms","increase hull max by ~11%")},	--5
				{max = 220, ["desc"] = _("upgrade-comms","increase hull max by 10%")},	--6
				{max = 240, ["desc"] = _("upgrade-comms","increase hull max by ~9%")},	--7
				["stock"] = {max = 200},
				["start"] = 4,
			},
			["impulse"] = {
				{	--1
					max_front =		50,		max_back =		50,
					accel_front =	6,		accel_back = 	6,
					turn = 			5,
					boost =			0,		strafe =		0,
				},
				{	--2
					max_front =		60,		max_back =		50,
					accel_front =	6,		accel_back = 	6,
					turn = 			5,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase max forward impulse speed by ~20%"),
				},
				{	--3
					max_front =		60,		max_back =		50,
					accel_front =	6,		accel_back = 	6,
					turn = 			5,
					boost =			300,	strafe =		0,
					desc = _("upgrade-comms","add combat maneuver forward boost"),
				},
				{	--4
					max_front =		60,		max_back =		50,
					accel_front =	8,		accel_back = 	6,
					turn = 			5,
					boost =			300,	strafe =		0,
					desc = _("upgrade-comms","increase max forward acceleration by 1/3"),
				},
				{	--5
					max_front =		60,		max_back =		50,
					accel_front =	8,		accel_back = 	6,
					turn = 			5,
					boost =			300,	strafe =		200,
					desc = _("upgrade-comms","add combat maneuver strafe"),
				},
				{	--6
					max_front =		60,		max_back =		50,
					accel_front =	8,		accel_back = 	6,
					turn = 			8,
					boost =			300,	strafe =		200,
					desc = _("upgrade-comms","increase maneuverability by 60%"),
				},
				{	--7
					max_front =		70,		max_back =		50,
					accel_front =	8,		accel_back = 	6,
					turn = 			8,
					boost =			300,	strafe =		200,
					desc = _("upgrade-comms","increase max forward impulse speed by ~17%"),
				},
				{	--8
					max_front =		70,		max_back =		50,
					accel_front =	8,		accel_back = 	6,
					turn = 			8,
					boost =			400,	strafe =		200,
					desc = _("upgrade-comms","increase combat maneuver forward boost by 1/3"),
				},
				{	--9
					max_front =		70,		max_back =		50,
					accel_front =	10,		accel_back = 	6,
					turn = 			8,
					boost =			400,	strafe =		200,
					desc = _("upgrade-comms","increase impulse forward acceleration by 25%"),
				},
				{	--10
					max_front =		70,		max_back =		50,
					accel_front =	10,		accel_back = 	6,
					turn = 			8,
					boost =			400,	strafe =		250,
					desc = _("upgrade-comms","increase combat maneuver strafe by 25%"),
				},
				{	--11
					max_front =		70,		max_back =		50,
					accel_front =	10,		accel_back = 	6,
					turn = 			10,
					boost =			400,	strafe =		250,
					desc = _("upgrade-comms","increase maneuverability by 25%"),
				},
				{	--12
					max_front =		70,		max_back =		50,
					accel_front =	10,		accel_back = 	6,
					turn = 			10,
					boost =			500,	strafe =		250,
					desc = _("upgrade-comms","increase combat maneuver forward boost by 25%"),
				},
				{	--13
					max_front =		70,		max_back =		50,
					accel_front =	12,		accel_back = 	6,
					turn = 			10,
					boost =			500,	strafe =		250,
					desc = _("upgrade-comms","increase impulse forward acceleration by 20%"),
				},
				{	--14
					max_front =		70,		max_back =		50,
					accel_front =	12,		accel_back = 	6,
					turn = 			10,
					boost =			500,	strafe =		300,
					desc = _("upgrade-comms","increase combat maneuver strafe by 20%"),
				},
				{	--15
					max_front =		77,		max_back =		50,
					accel_front =	12,		accel_back = 	6,
					turn = 			10,
					boost =			500,	strafe =		300,
					desc = _("upgrade-comms","increase max forward impulse speed by 10%"),
				},
				{	--16
					max_front =		77,		max_back =		50,
					accel_front =	15,		accel_back = 	6,
					turn = 			10,
					boost =			500,	strafe =		300,
					desc = _("upgrade-comms","increase impulse forward acceleration by 25%"),
				},
				{	--17
					max_front =		77,		max_back =		60,
					accel_front =	15,		accel_back = 	8,
					turn = 			10,
					boost =			500,	strafe =		300,
					desc = _("upgrade-comms","increase max reverse impulse by 20% and reverse acceleration by 1/3"),
				},
				{	--18
					max_front =		77,		max_back =		60,
					accel_front =	15,		accel_back = 	8,
					turn = 			11,
					boost =			500,	strafe =		300,
					desc = _("upgrade-comms","increase maneuverability by 10%"),
				},
				["stock"] = {
					{max_front = 60, turn = 6, accel_front = 8, max_back = 60, accel_back = 8, boost = 400, strafe = 250},
				},
				["start"] = 5,
			},
			["ftl"] = {
				{	--1
					jump_long = 0, jump_short = 0, warp = 0,
				},
				{	--2
					jump_long = 40000, jump_short = 4000, warp = 0,
					desc = _("upgrade-comms","add 40k jump drive"),
				},
				{	--3
					jump_long = 50000, jump_short = 5000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 25%"),
				},
				{	--4
					jump_long = 60000, jump_short = 5000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 20%"),
				},
				{	--5
					jump_long = 70000, jump_short = 5000, warp = 0,
					desc = _("upgrade-comms","increase jump range by ~17%"),
				},
				{	--6
					jump_long = 80000, jump_short = 5000, warp = 0,
					desc = _("upgrade-comms","increase jump range by ~14%"),
				},
				{	--7
					jump_long = 90000, jump_short = 5000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 12.5%"),
				},
				{	--8
					jump_long = 90000, jump_short = 5000, warp = 300,
					desc = _("upgrade-comms","add warp drive"),
				},
				{	--9
					jump_long = 90000, jump_short = 5000, warp = 400,
					desc = _("upgrade-comms","increase warp speed by 1/3"),
				},
				{	--10
					jump_long = 100000, jump_short = 5000, warp = 400,
					desc = _("upgrade-comms","increase jump range by ~11%"),
				},
				{	--11
					jump_long = 100000, jump_short = 5000, warp = 500,
					desc = _("upgrade-comms","increase warp speed by 25%"),
				},
				["stock"] = {
					{jump_long = 90000, jump_short = 5000, warp = 0},
				},
				["start"] = 3,
			},
			["sensors"] = {
				{	--1
					short = 4000, long = 20000, prox_scan = 0,
				},
				{	--2
					short = 4000, long = 25000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by 20%"),
				},
				{	--3
					short = 4000, long = 30000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by 20%"),
				},
				{	--4
					short = 4500, long = 30000, prox_scan = 0,
					desc = _("upgrade-comms","increase short range sensors by 12.5%"),
				},
				{	--5
					short = 4500, long = 35000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by ~17%"),
				},
				{	--6
					short = 4500, long = 40000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by ~14%"),
				},
				{	--7
					short = 4500, long = 40000, prox_scan = 2,
					desc = _("upgrade-comms","add 2 unit automated proximity scanner"),
				},
				{	--8
					short = 5000, long = 40000, prox_scan = 2,
					desc = _("upgrade-comms","increase short range sensors by ~11%"),
				},
				{	--9
					short = 5000, long = 45000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by 12.5%"),
				},
				{	--10
					short = 5000, long = 50000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by ~11%"),
				},
				["stock"] = {
					{short = 5000, long = 30000}, prox_scan = 0,
				},
				["start"] = 2,
			},
			["providers"] = false,
			["score"] = 25,
		},
		["Kiriya"] = {	--7 + beam(9) + missile(13) + shield(9) + hull(6) + impulse(17) + ftl(10) + sensors(9) = 81
			["beam"] = {
				{	--1
					{idx = 0, arc = 10, dir =   0, rng = 1000, cyc = 7, dmg = 4, tar = 30, tdr =   0, trt = 4},
					{idx = 1, arc = 10, dir = 180, rng = 1000, cyc = 7, dmg = 4, tar = 30, tdr = 180, trt = 4},
				},
				{	--2
					{idx = 0, arc = 10, dir =   0, rng = 1000, cyc = 7, dmg = 4, tar = 60, tdr =   0, trt = 4},
					{idx = 1, arc = 10, dir = 180, rng = 1000, cyc = 7, dmg = 4, tar = 60, tdr = 180, trt = 4},
					["desc"] = _("upgrade-comms","double arc width")
				},
				{	--3
					{idx = 0, arc = 10, dir =   0, rng = 1000, cyc = 7, dmg = 4, tar = 60, tdr =   0, trt = 5},
					{idx = 1, arc = 10, dir = 180, rng = 1000, cyc = 7, dmg = 4, tar = 60, tdr = 180, trt = 5},
					["desc"] = _("upgrade-comms","increase turret speed by 25%")
				},
				{	--4
					{idx = 0, arc = 10, dir =   0, rng = 1000, cyc = 7, dmg = 4, tar = 90, tdr =   0, trt = 5},
					{idx = 1, arc = 10, dir = 180, rng = 1000, cyc = 7, dmg = 4, tar = 90, tdr = 180, trt = 5},
					["desc"] = _("upgrade-comms","increase arc width by 50%")
				},
				{	--5
					{idx = 0, arc = 10, dir =   0, rng = 1000, cyc = 6, dmg = 4, tar = 90, tdr =   0, trt = 5},
					{idx = 1, arc = 10, dir = 180, rng = 1000, cyc = 6, dmg = 4, tar = 90, tdr = 180, trt = 5},
					["desc"] = _("upgrade-comms","decrease cycle time by ~14%"),
				},
				{	--6
					{idx = 0, arc = 10, dir =   0, rng = 1000, cyc = 6, dmg = 4, tar = 90, tdr =   0, trt = 5},
					{idx = 1, arc = 10, dir = 180, rng = 1000, cyc = 6, dmg = 4, tar = 90, tdr = 180, trt = 5},
					{idx = 2, arc = 10, dir = -90, rng = 1000, cyc = 6, dmg = 4, tar = 40, tdr = -90, trt = 5},
					{idx = 3, arc = 10, dir =  90, rng = 1000, cyc = 6, dmg = 4, tar = 40, tdr =  90, trt = 5},
					["desc"] = _("upgrade-comms","add beams"),
				},
				{	--7
					{idx = 0, arc = 10, dir =   0, rng = 1500, cyc = 6, dmg = 4, tar = 90, tdr =   0, trt = 5},
					{idx = 1, arc = 10, dir = 180, rng = 1500, cyc = 6, dmg = 4, tar = 90, tdr = 180, trt = 5},
					{idx = 2, arc = 10, dir = -90, rng = 1500, cyc = 6, dmg = 4, tar = 40, tdr = -90, trt = 5},
					{idx = 3, arc = 10, dir =  90, rng = 1500, cyc = 6, dmg = 4, tar = 40, tdr =  90, trt = 5},
					["desc"] = _("upgrade-comms","increase range by 50%"),
				},
				{	--8
					{idx = 0, arc = 10, dir =   0, rng = 1500, cyc = 6, dmg = 4, tar = 110, tdr =   0, trt = 5},
					{idx = 1, arc = 10, dir = 180, rng = 1500, cyc = 6, dmg = 4, tar = 110, tdr = 180, trt = 5},
					{idx = 2, arc = 10, dir = -90, rng = 1500, cyc = 6, dmg = 4, tar = 110, tdr = -90, trt = 5},
					{idx = 3, arc = 10, dir =  90, rng = 1500, cyc = 6, dmg = 4, tar = 110, tdr =  90, trt = 5},
					["desc"] = _("upgrade-comms","overlap arcs"),
				},
				{	--9
					{idx = 0, arc = 10, dir =   0, rng = 1500, cyc = 6, dmg = 4, tar = 110, tdr =   0, trt = 6},
					{idx = 1, arc = 10, dir = 180, rng = 1500, cyc = 6, dmg = 4, tar = 110, tdr = 180, trt = 6},
					{idx = 2, arc = 10, dir = -90, rng = 1500, cyc = 6, dmg = 4, tar = 110, tdr = -90, trt = 6},
					{idx = 3, arc = 10, dir =  90, rng = 1500, cyc = 6, dmg = 4, tar = 110, tdr =  90, trt = 6},
					["desc"] = _("upgrade-comms","increase turret speed by 20%"),
				},
				{	--10
					{idx = 0, arc = 10, dir =   0, rng = 1500, cyc = 6, dmg = 5, tar = 110, tdr =   0, trt = 6},
					{idx = 1, arc = 10, dir = 180, rng = 1500, cyc = 6, dmg = 5, tar = 110, tdr = 180, trt = 6},
					{idx = 2, arc = 10, dir = -90, rng = 1500, cyc = 6, dmg = 5, tar = 110, tdr = -90, trt = 6},
					{idx = 3, arc = 10, dir =  90, rng = 1500, cyc = 6, dmg = 5, tar = 110, tdr =  90, trt = 6},
					["desc"] = _("upgrade-comms","increase damage by 25%"),
				},
				["stock"] = {
					{idx = 0, arc = 10, dir =   0, rng = 1500, cyc = 6, dmg = 4, tar = 90, tdr =   0, trt = 6},
					{idx = 1, arc = 10, dir = 180, rng = 1500, cyc = 6, dmg = 4, tar = 90, tdr = 180, trt = 6},
				},
				["start"] = 6,
			},
			["missiles"] = {
				{tube = 1,	ord = 1},														--1
				{tube = 2,	ord = 2, desc = _("upgrade-comms","add mines")},									--2  
				{tube = 3,	ord = 2, desc = _("upgrade-comms","speed up tube load speed by 25%")},				--3  
				{tube = 3,	ord = 3, desc = _("upgrade-comms","increase mine capacity by 50%")},				--4
				{tube = 4,	ord = 3, desc = _("upgrade-comms","speed up tube load speed by 1/3")},				--5
				{tube = 4,	ord = 4, desc = _("upgrade-comms","increase mine capacity by 1/3")},				--6
				{tube = 5,	ord = 4, desc = _("upgrade-comms","speed up mine load speed by ~17%")},			--7
				{tube = 5,	ord = 5, desc = _("upgrade-comms","increase mine capacity by 25%")},				--8
				{tube = 6,	ord = 6, desc = _("upgrade-comms","add homing missiles")},							--9
				{tube = 6,	ord = 7, desc = _("upgrade-comms","double homing missile capacity")},				--10
				{tube = 7,	ord = 7, desc = _("upgrade-comms","speed up mine loading speed by 20%")},			--11
				{tube = 7,	ord = 8, desc = _("upgrade-comms","increase homing missile capacity by 50%")},		--12
				{tube = 8,	ord = 8, desc = _("upgrade-comms","medium sized homing misile tubes")},			--13
				{tube = 8,	ord = 9, desc = _("upgrade-comms","increase mine capacity by 20%")},				--14
				["start"] = 3,
			},
			["tube"] = {
				{	--1
					{idx = -1},
				},
				{	--2
					{idx = 0, dir = 180, siz = "M", spd = 20, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--3
					{idx = 0, dir = 180, siz = "M", spd = 15, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--4
					{idx = 0, dir = 180, siz = "M", spd = 12, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--5
					{idx = 0, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--6
					{idx = 0, dir =   0, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir =  60, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 2, dir = 120, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 3, dir = 300, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 4, dir = 240, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 5, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--7
					{idx = 0, dir =   0, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir =  60, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 2, dir = 120, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 3, dir = 300, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 4, dir = 240, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 5, dir = 180, siz = "M", spd = 8,  hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--8
					{idx = 0, dir =   0, siz = "M", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir =  60, siz = "M", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 2, dir = 120, siz = "M", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 3, dir = 300, siz = "M", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 4, dir = 240, siz = "M", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 5, dir = 180, siz = "M", spd = 8,  hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				["stock"] = {
					{idx = -1},
				},
			},
			["ordnance"] = {
				{hom = 0,  nuk = 0, emp = 0, min = 0, hvl = 0},		--1
				{hom = 0,  nuk = 0, emp = 0, min = 2, hvl = 0},		--2
				{hom = 0,  nuk = 0, emp = 0, min = 3, hvl = 0},		--3
				{hom = 0,  nuk = 0, emp = 0, min = 4, hvl = 0},		--4		
				{hom = 0,  nuk = 0, emp = 0, min = 5, hvl = 0},		--5		
				{hom = 5,  nuk = 0, emp = 0, min = 5, hvl = 0},		--6		
				{hom = 10, nuk = 0, emp = 0, min = 5, hvl = 0},		--7		
				{hom = 15, nuk = 0, emp = 0, min = 5, hvl = 0},		--8		
				{hom = 15, nuk = 0, emp = 0, min = 6, hvl = 0},		--9		
				["stock"] = {hom = 0, nuk = 0, emp = 0, min = 0, hvl = 0},
			},
			["shield"] = {
				{	--1
					{idx = 0, max = 50},
				},
				{	--2
					{idx = 0, max = 60},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--3
					{idx = 0, max = 70},
					["desc"] = _("upgrade-comms","increase shield charge capacity by ~17%"),
				},
				{	--4
					{idx = 0, max = 50},
					{idx = 1, max = 50},
					["desc"] = _("upgrade-comms","add rear shield arc"),
				},
				{	--5
					{idx = 0, max = 60},
					{idx = 1, max = 60},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--6
					{idx = 0, max = 80},
					{idx = 1, max = 80},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 1/3"),
				},
				{	--7
					{idx = 0, max = 100},
					{idx = 1, max = 100},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--8
					{idx = 0, max = 100},
					{idx = 1, max = 150},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by 50%"),
				},
				{	--9
					{idx = 0, max = 100},
					{idx = 1, max = 180},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by 20%"),
				},
				{	--10
					{idx = 0, max = 100},
					{idx = 1, max = 200},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by ~11%"),
				},
				["stock"] = {
					{idx = 0, max = 70},
					{idx = 1, max = 70},
				},
				["start"] = 3,
			},	
			["hull"] = {
				{max = 100},															--1
				{max = 120, ["desc"] = _("upgrade-comms","increase hull max by 20%")},	--2
				{max = 150, ["desc"] = _("upgrade-comms","increase hull max by 25%")},	--3
				{max = 180, ["desc"] = _("upgrade-comms","increase hull max by 20%")},	--4
				{max = 200, ["desc"] = _("upgrade-comms","increase hull max by ~11%")},	--5
				{max = 220, ["desc"] = _("upgrade-comms","increase hull max by 10%")},	--6
				{max = 240, ["desc"] = _("upgrade-comms","increase hull max by ~9%")},	--7
				["stock"] = {max = 200},
				["start"] = 3,
			},
			["impulse"] = {
				{	--1
					max_front =		50,		max_back =		50,
					accel_front =	6,		accel_back = 	6,
					turn = 			5,
					boost =			0,		strafe =		0,
				},
				{	--2
					max_front =		60,		max_back =		50,
					accel_front =	6,		accel_back = 	6,
					turn = 			5,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase max forward impulse speed by ~20%"),
				},
				{	--3
					max_front =		60,		max_back =		50,
					accel_front =	6,		accel_back = 	6,
					turn = 			5,
					boost =			300,	strafe =		0,
					desc = _("upgrade-comms","add combat maneuver forward boost"),
				},
				{	--4
					max_front =		60,		max_back =		50,
					accel_front =	8,		accel_back = 	6,
					turn = 			5,
					boost =			300,	strafe =		0,
					desc = _("upgrade-comms","increase max forward acceleration by 1/3"),
				},
				{	--5
					max_front =		60,		max_back =		50,
					accel_front =	8,		accel_back = 	6,
					turn = 			5,
					boost =			300,	strafe =		200,
					desc = _("upgrade-comms","add combat maneuver strafe"),
				},
				{	--6
					max_front =		60,		max_back =		50,
					accel_front =	8,		accel_back = 	6,
					turn = 			8,
					boost =			300,	strafe =		200,
					desc = _("upgrade-comms","increase maneuverability by 60%"),
				},
				{	--7
					max_front =		70,		max_back =		50,
					accel_front =	8,		accel_back = 	6,
					turn = 			8,
					boost =			300,	strafe =		200,
					desc = _("upgrade-comms","increase max forward impulse speed by ~17%"),
				},
				{	--8
					max_front =		70,		max_back =		50,
					accel_front =	8,		accel_back = 	6,
					turn = 			8,
					boost =			400,	strafe =		200,
					desc = _("upgrade-comms","increase combat maneuver forward boost by 1/3"),
				},
				{	--9
					max_front =		70,		max_back =		50,
					accel_front =	10,		accel_back = 	6,
					turn = 			8,
					boost =			400,	strafe =		200,
					desc = _("upgrade-comms","increase impulse forward acceleration by 25%"),
				},
				{	--10
					max_front =		70,		max_back =		50,
					accel_front =	10,		accel_back = 	6,
					turn = 			8,
					boost =			400,	strafe =		250,
					desc = _("upgrade-comms","increase combat maneuver strafe by 25%"),
				},
				{	--11
					max_front =		70,		max_back =		50,
					accel_front =	10,		accel_back = 	6,
					turn = 			10,
					boost =			400,	strafe =		250,
					desc = _("upgrade-comms","increase maneuverability by 25%"),
				},
				{	--12
					max_front =		70,		max_back =		50,
					accel_front =	10,		accel_back = 	6,
					turn = 			10,
					boost =			500,	strafe =		250,
					desc = _("upgrade-comms","increase combat maneuver forward boost by 25%"),
				},
				{	--13
					max_front =		70,		max_back =		50,
					accel_front =	12,		accel_back = 	6,
					turn = 			10,
					boost =			500,	strafe =		250,
					desc = _("upgrade-comms","increase impulse forward acceleration by 20%"),
				},
				{	--14
					max_front =		70,		max_back =		50,
					accel_front =	12,		accel_back = 	6,
					turn = 			10,
					boost =			500,	strafe =		300,
					desc = _("upgrade-comms","increase combat maneuver strafe by 20%"),
				},
				{	--15
					max_front =		77,		max_back =		50,
					accel_front =	12,		accel_back = 	6,
					turn = 			10,
					boost =			500,	strafe =		300,
					desc = _("upgrade-comms","increase max forward impulse speed by 10%"),
				},
				{	--16
					max_front =		77,		max_back =		50,
					accel_front =	15,		accel_back = 	6,
					turn = 			10,
					boost =			500,	strafe =		300,
					desc = _("upgrade-comms","increase impulse forward acceleration by 25%"),
				},
				{	--17
					max_front =		77,		max_back =		60,
					accel_front =	15,		accel_back = 	8,
					turn = 			10,
					boost =			500,	strafe =		300,
					desc = _("upgrade-comms","increase max reverse impulse by 20% and reverse acceleration by 1/3"),
				},
				{	--18
					max_front =		77,		max_back =		60,
					accel_front =	15,		accel_back = 	8,
					turn = 			11,
					boost =			500,	strafe =		300,
					desc = _("upgrade-comms","increase maneuverability by 10%"),
				},
				["stock"] = {
					{max_front = 60, turn = 6, accel_front = 8, max_back = 60, accel_back = 8, boost = 400, strafe = 250},
				},
				["start"] = 5,
			},
			["ftl"] = {
				{	--1
					jump_long = 0, jump_short = 0, warp = 0,
				},
				{	--2
					jump_long = 0, jump_short = 0, warp = 300,
					desc = _("upgrade-comms","add warp drive"),
				},
				{	--3
					jump_long = 0, jump_short = 0, warp = 400,
					desc = _("upgrade-comms","increase warp speed by 1/3"),
				},
				{	--4
					jump_long = 0, jump_short = 0, warp = 500,
					desc = _("upgrade-comms","increase warp speed by 25%"),
				},
				{	--5
					jump_long = 0, jump_short = 0, warp = 600,
					desc = _("upgrade-comms","increase warp speed by 20%"),
				},
				{	--6
					jump_long = 0, jump_short = 0, warp = 700,
					desc = _("upgrade-comms","increase warp speed by ~17%"),
				},
				{	--7
					jump_long = 0, jump_short = 0, warp = 800,
					desc = _("upgrade-comms","increase warp speed by ~14%"),
				},
				{	--8
					jump_long = 20000, jump_short = 2000, warp = 800,
					desc = _("upgrade-comms","add 20k jump drive"),
				},
				{	--9
					jump_long = 25000, jump_short = 2500, warp = 800,
					desc = _("upgrade-comms","increase jump range by 25%"),
				},
				{	--10
					jump_long = 25000, jump_short = 2500, warp = 900,
					desc = _("upgrade-comms","increase warp speed by 12.5%"),
				},
				{	--11
					jump_long = 30000, jump_short = 3000, warp = 900,
					desc = _("upgrade-comms","increase jump range by 20%"),
				},
				["stock"] = {
					{jump_long = 0, jump_short = 0, warp = 750},
				},
				["start"] = 3,
			},
			["sensors"] = {
				{	--1
					short = 4000, long = 20000, prox_scan = 0,
				},
				{	--2
					short = 4000, long = 25000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by 20%"),
				},
				{	--3
					short = 4000, long = 30000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by 20%"),
				},
				{	--4
					short = 4500, long = 30000, prox_scan = 0,
					desc = _("upgrade-comms","increase short range sensors by 12.5%"),
				},
				{	--5
					short = 4500, long = 35000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by ~17%"),
				},
				{	--6
					short = 4500, long = 40000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by ~14%"),
				},
				{	--7
					short = 4500, long = 40000, prox_scan = 2,
					desc = _("upgrade-comms","add 2 unit automated proximity scanner"),
				},
				{	--8
					short = 5000, long = 40000, prox_scan = 2,
					desc = _("upgrade-comms","increase short range sensors by ~11%"),
				},
				{	--9
					short = 5000, long = 45000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by 12.5%"),
				},
				{	--10
					short = 5000, long = 50000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by ~11%"),
				},
				["stock"] = {
					{short = 5000, long = 30000}, prox_scan = 0,
				},
				["start"] = 2,
			},
			["providers"] = false,
			["score"] = 25,
		},
		["Phobos M3P"] = {	--8 + beam(9) + missile(12) + shield(9) + hull(6) + impulse(13) + ftl(9) + sensors(12) = 78
			["beam"] = {
				{	--1
					{idx = 0, arc = 40, dir = -15, rng = 1000, cyc = 10, dmg = 5},
					{idx = 1, arc = 40, dir =  15, rng = 1000, cyc = 10, dmg = 5},
				},
				{	--2
					{idx = 0, arc = 40, dir = -15, rng = 1000, cyc = 9, dmg = 5},
					{idx = 1, arc = 40, dir =  15, rng = 1000, cyc = 9, dmg = 5},
					["desc"] = _("upgrade-comms","reduce cycle time by 10%")
				},
				{	--3
					{idx = 0, arc = 60, dir = -15, rng = 1000, cyc = 9, dmg = 5},
					{idx = 1, arc = 60, dir =  15, rng = 1000, cyc = 9, dmg = 5},
					["desc"] = _("upgrade-comms","increase arc width by 50%")
				},
				{	--4
					{idx = 0, arc = 60, dir = -15, rng = 1100, cyc = 9, dmg = 5},
					{idx = 1, arc = 60, dir =  15, rng = 1100, cyc = 9, dmg = 5},
					["desc"] = _("upgrade-comms","increase range by 10%")
				},
				{	--5
					{idx = 0, arc = 60, dir = -15, rng = 1100, cyc = 9, dmg = 6},
					{idx = 1, arc = 60, dir =  15, rng = 1100, cyc = 9, dmg = 6},
					["desc"] = _("upgrade-comms","increase damage by 20%"),
				},
				{	--6
					{idx = 0, arc = 60, dir = -15, rng = 1100, cyc = 8, dmg = 6},
					{idx = 1, arc = 60, dir =  15, rng = 1100, cyc = 8, dmg = 6},
					["desc"] = _("upgrade-comms","reduce cycle time by ~11%"),
				},
				{	--7
					{idx = 0, arc = 90, dir = -15, rng = 1100, cyc = 8, dmg = 6},
					{idx = 1, arc = 90, dir =  15, rng = 1100, cyc = 8, dmg = 6},
					["desc"] = _("upgrade-comms","increase arc width by 50%"),
				},
				{	--8
					{idx = 0, arc = 90, dir = -15, rng = 1200, cyc = 8, dmg = 6},
					{idx = 1, arc = 90, dir =  15, rng = 1200, cyc = 8, dmg = 6},
					["desc"] = _("upgrade-comms","increase range by ~9%"),
				},
				{	--9
					{idx = 0, arc = 90, dir = -15, rng = 1200, cyc = 8, dmg = 6},
					{idx = 1, arc = 90, dir =  15, rng = 1200, cyc = 8, dmg = 6},
					{idx = 2, arc = 30, dir =   0, rng = 1200, cyc = 8, dmg = 6},
					["desc"] = _("upgrade-comms","add beam"),
				},
				{	--10
					{idx = 0, arc = 90, dir = -15, rng = 1200, cyc = 8, dmg = 6},
					{idx = 1, arc = 90, dir =  15, rng = 1200, cyc = 8, dmg = 6},
					{idx = 2, arc = 30, dir =   0, rng = 1500, cyc = 8, dmg = 6},
					["desc"] = _("upgrade-comms","increase center beam range by 25%"),
				},
				["stock"] = {
					{idx = 0, arc = 90, dir = -15, rng = 1200, cyc = 8, dmg = 6},
					{idx = 0, arc = 90, dir =  15, rng = 1200, cyc = 8, dmg = 6},
				},
				["start"] = 3,
			},
			["missiles"] = {
				{tube = 1,	ord = 1},																		--1
				{tube = 2,	ord = 1, desc = _("upgrade-comms","increase tube load speed by ~17%")},			--2  
				{tube = 3,	ord = 2, desc = _("upgrade-comms","add homing missiles")},						--3  
				{tube = 3,	ord = 3, desc = _("upgrade-comms","increase homing missile capacity by 50%")},	--4
				{tube = 3,	ord = 4, desc = _("upgrade-comms","increase HVLI capacity by 60%")},			--5
				{tube = 4,	ord = 5, desc = _("upgrade-comms","add mining tube")},							--6
				{tube = 5,	ord = 5, desc = _("upgrade-comms","speed up forward tube load time by 20%")},	--7
				{tube = 6,	ord = 6, desc = _("upgrade-comms","add EMPs")},									--8
				{tube = 7,	ord = 6, desc = _("upgrade-comms","increase tube size")},						--9
				{tube = 8,	ord = 7, desc = _("upgrade-comms","add nukes, more EMPs")},						--10
				{tube = 8,	ord = 8, desc = _("upgrade-comms","1/3 more homing capacity")},					--11
				{tube = 8,	ord = 9, desc = _("upgrade-comms","more homing and HVLI missiles")},			--12
				{tube = 8,	ord = 10,desc = _("upgrade-comms","more homing, nuke, EMP and mine missiles")},	--13
				["start"] = 4
			},
			["tube"] = {
				{	--1
					{idx = 0, dir =   1, siz = "S", spd = 12, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  -1, siz = "S", spd = 12, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--2
					{idx = 0, dir =   1, siz = "S", spd = 10, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  -1, siz = "S", spd = 10, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--3
					{idx = 0, dir =   1, siz = "S", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  -1, siz = "S", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
				},
				{	--4
					{idx = 0, dir =   1, siz = "S", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  -1, siz = "S", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = 180, siz = "S", spd = 12, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--5
					{idx = 0, dir =   1, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  -1, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = 180, siz = "S", spd = 12, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--6
					{idx = 0, dir =   1, siz = "S", spd = 8,  hom = true,  nuk = false, emp = true,  min = false, hvl = true },
					{idx = 1, dir =  -1, siz = "S", spd = 8,  hom = true,  nuk = false, emp = true,  min = false, hvl = true },
					{idx = 2, dir = 180, siz = "S", spd = 12, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--7
					{idx = 0, dir =   1, siz = "M", spd = 8,  hom = true,  nuk = false, emp = true,  min = false, hvl = true },
					{idx = 1, dir =  -1, siz = "M", spd = 8,  hom = true,  nuk = false, emp = true,  min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 12, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--8
					{idx = 0, dir =   1, siz = "M", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 1, dir =  -1, siz = "M", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 12, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				["stock"] = {
					{idx = 0, dir =  -1, siz = "M", spd = 10, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 1, dir =   1, siz = "M", spd = 10, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
				},
			},
			["ordnance"] = {
				{hom = 0,  nuk = 0, emp = 0, min = 0, hvl = 10},	--1
				{hom = 4,  nuk = 0, emp = 0, min = 0, hvl = 10},	--2
				{hom = 6,  nuk = 0, emp = 0, min = 0, hvl = 10},	--3
				{hom = 6,  nuk = 0, emp = 0, min = 0, hvl = 16},	--4		
				{hom = 6,  nuk = 0, emp = 0, min = 2, hvl = 16},	--5		
				{hom = 6,  nuk = 0, emp = 2, min = 2, hvl = 16},	--6		
				{hom = 6,  nuk = 2, emp = 4, min = 2, hvl = 16},	--7		
				{hom = 8,  nuk = 2, emp = 4, min = 2, hvl = 16},	--8	
				{hom = 10, nuk = 2, emp = 4, min = 2, hvl = 20},	--9		
				{hom = 12, nuk = 3, emp = 5, min = 4, hvl = 20},	--10		
				["stock"] = {hom = 10, nuk = 2, emp = 3, min = 4, hvl = 20},
			},
			["shield"] = {
				{	--1
					{idx = 0, max = 80},
				},
				{	--2
					{idx = 0, max = 90},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 12.5%"),
				},
				{	--3
					{idx = 0, max = 120},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 1/3"),
				},
				{	--4
					{idx = 0, max = 60},
					{idx = 1, max = 60},
					["desc"] = _("upgrade-comms","add rear shield arc"),
				},
				{	--5
					{idx = 0, max = 80},
					{idx = 1, max = 80},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 1/3"),
				},
				{	--6
					{idx = 0, max = 100},
					{idx = 1, max = 80},
					["desc"] = _("upgrade-comms","increase front shield charge capacity by 25%"),
				},
				{	--7
					{idx = 0, max = 120},
					{idx = 1, max = 80},
					["desc"] = _("upgrade-comms","increase front shield charge capacity by 20%"),
				},
				{	--8
					{idx = 0, max = 120},
					{idx = 1, max = 100},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by 20%"),
				},
				{	--9
					{idx = 0, max = 150},
					{idx = 1, max = 100},
					["desc"] = _("upgrade-comms","increase front shield charge capacity by 25%"),
				},
				{	--10
					{idx = 0, max = 150},
					{idx = 1, max = 120},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by 20%"),
				},
				["stock"] = {
					{idx = 0, max = 100},
					{idx = 1, max = 100},
				},
				["start"] = 5
			},	
			["hull"] = {
				{max = 100},															--1
				{max = 120, ["desc"] = _("upgrade-comms","increase hull max by 20%")},	--2
				{max = 150, ["desc"] = _("upgrade-comms","increase hull max by 25%")},	--3
				{max = 180, ["desc"] = _("upgrade-comms","increase hull max by 20%")},	--4
				{max = 200, ["desc"] = _("upgrade-comms","increase hull max by ~11%")},	--5
				{max = 220, ["desc"] = _("upgrade-comms","increase hull max by 10%")},	--6
				{max = 240, ["desc"] = _("upgrade-comms","increase hull max by ~9%")},	--7
				["stock"] = {max = 200},
				["start"] = 4,
			},
			["impulse"] = {
				{	--1
					max_front =		70,		max_back =		60,
					accel_front =	16,		accel_back = 	14,
					turn = 			8,
					boost =			0,		strafe =		0,
				},
				{	--2
					max_front =		70,		max_back =		60,
					accel_front =	16,		accel_back = 	14,
					turn = 			9,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase maneuverability by 12.5%"),
				},
				{	--3
					max_front =		75,		max_back =		60,
					accel_front =	16,		accel_back = 	14,
					turn = 			9,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase max forward impulse by ~7%"),
				},
				{	--4
					max_front =		75,		max_back =		60,
					accel_front =	16,		accel_back = 	14,
					turn = 			9,
					boost =			200,	strafe =		0,
					desc = _("upgrade-comms","add combat maneuver boost"),
				},
				{	--5
					max_front =		75,		max_back =		70,
					accel_front =	16,		accel_back = 	14,
					turn = 			9,
					boost =			200,	strafe =		0,
					desc = _("upgrade-comms","increase max reverse impulse by ~17%"),
				},
				{	--6
					max_front =		80,		max_back =		70,
					accel_front =	20,		accel_back = 	14,
					turn = 			9,
					boost =			200,	strafe =		0,
					desc = _("upgrade-comms","increase forward impulse speed and acceleration"),
				},
				{	--7
					max_front =		80,		max_back =		70,
					accel_front =	20,		accel_back = 	14,
					turn = 			9,
					boost =			200,	strafe =		150,
					desc = _("upgrade-comms","add combat maneuver strafe"),
				},
				{	--7
					max_front =		80,		max_back =		70,
					accel_front =	20,		accel_back = 	14,
					turn = 			10,
					boost =			200,	strafe =		150,
					desc = _("upgrade-comms","increase maneuverability by ~11%"),
				},
				{	--8
					max_front =		80,		max_back =		70,
					accel_front =	20,		accel_back = 	14,
					turn = 			10,
					boost =			400,	strafe =		300,
					desc = _("upgrade-comms","double combat maneuverability"),
				},
				{	--9
					max_front =		80,		max_back =		80,
					accel_front =	20,		accel_back = 	20,
					turn = 			10,
					boost =			400,	strafe =		300,
					desc = _("upgrade-comms","increase reverse impulse speed and acceleration"),
				},
				{	--10
					max_front =		80,		max_back =		80,
					accel_front =	25,		accel_back = 	20,
					turn = 			10,
					boost =			400,	strafe =		300,
					desc = _("upgrade-comms","increase forward acceleration by 25%"),
				},
				{	--11
					max_front =		80,		max_back =		88,
					accel_front =	25,		accel_back = 	20,
					turn = 			10,
					boost =			400,	strafe =		300,
					desc = _("upgrade-comms","increase reverse impulse max speed by 10%"),
				},
				{	--12
					max_front =		80,		max_back =		88,
					accel_front =	25,		accel_back = 	20,
					turn = 			10,
					boost =			500,	strafe =		300,
					desc = _("upgrade-comms","increase combat maneuver boost by 25%"),
				},
				{	--13
					max_front =		80,		max_back =		88,
					accel_front =	25,		accel_back = 	20,
					turn = 			12,
					boost =			500,	strafe =		300,
					desc = _("upgrade-comms","increase maneuverability by 20%"),
				},
				{	--14
					max_front =		88,		max_back =		88,
					accel_front =	25,		accel_back = 	20,
					turn = 			12,
					boost =			500,	strafe =		300,
					desc = _("upgrade-comms","increase max forward impulse speed by 10%"),
				},
				["stock"] = {
					{max_front = 80, turn = 10, accel_front = 20, max_back = 80, accel_back = 20, boost = 400, strafe = 250},
				},
				["start"] = 3,
			},
			["ftl"] = {
				{	--1
					jump_long = 0, jump_short = 0, warp = 0,
				},
				{	--2
					jump_long = 0, jump_short = 0, warp = 300,
					desc = _("upgrade-comms","add warp drive"),
				},
				{	--3
					jump_long = 20000, jump_short = 2000, warp = 300,
					desc = _("upgrade-comms","add 20k jump drive"),
				},
				{	--4
					jump_long = 20000, jump_short = 2000, warp = 400,
					desc = _("upgrade-comms","increase warp speed by 1/3"),
				},
				{	--5
					jump_long = 25000, jump_short = 2500, warp = 400,
					desc = _("upgrade-comms","increase jump range by 25%"),
				},
				{	--6
					jump_long = 25000, jump_short = 2500, warp = 500,
					desc = _("upgrade-comms","increase warp speed by 25%"),
				},
				{	--7
					jump_long = 30000, jump_short = 3000, warp = 500,
					desc = _("upgrade-comms","increase jump range by 20%"),
				},
				{	--8
					jump_long = 30000, jump_short = 3000, warp = 600,
					desc = _("upgrade-comms","increase warp speed by 20%"),
				},
				{	--9
					jump_long = 35000, jump_short = 3500, warp = 600,
					desc = _("upgrade-comms","increase jump range by ~17%"),
				},
				{	--10
					jump_long = 35000, jump_short = 3500, warp = 700,
					desc = _("upgrade-comms","increase warp speed by ~17%"),
				},
				["stock"] = {
					{jump_long = 0, jump_short = 0, warp = 0},
				},
				["start"] = 3,
			},
			["sensors"] = {
				{	--1
					short = 4000, long = 15000, prox_scan = 0,
				},
				{	--2
					short = 4000, long = 20000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by 25%"),
				},
				{	--3
					short = 4000, long = 20000, prox_scan = 1,
					desc = _("upgrade-comms","add 1 unit automated proximity scanner"),
				},
				{	--4
					short = 4000, long = 22000, prox_scan = 1,
					desc = _("upgrade-comms","increase long range sensors by 10%"),
				},
				{	--5
					short = 4500, long = 22000, prox_scan = 1,
					desc = _("upgrade-comms","increase short range sensors by 12.5%"),
				},
				{	--6
					short = 4500, long = 25000, prox_scan = 1,
					desc = _("upgrade-comms","increase long range sensors by ~14%"),
				},
				{	--7
					short = 4500, long = 30000, prox_scan = 1,
					desc = _("upgrade-comms","increase long range sensors by 20%"),
				},
				{	--8
					short = 5000, long = 30000, prox_scan = 1,
					desc = _("upgrade-comms","increase short range sensors by ~11%"),
				},
				{	--9
					short = 5000, long = 30000, prox_scan = 3,
					desc = _("upgrade-comms","triple automated proximity scanner range"),
				},
				{	--10
					short = 5000, long = 35000,
					desc = _("upgrade-comms","increase long range sensors by ~17%"),
				},
				{	--11
					short = 5500, long = 35000,
					desc = _("upgrade-comms","increase short range sensors by 10%"),
				},
				{	--12
					short = 5500, long = 40000,
					desc = _("upgrade-comms","increase long range sensors by ~14%"),
				},
				{	--13
					short = 6000, long = 40000,
					desc = _("upgrade-comms","increase short range sensors by ~9%"),
				},
				["stock"] = {
					{short = 5000, long = 30000}, prox_scan = 0,
				},
				["start"] = 4,
			},
			["providers"] = false,
			["score"] = 27,
		},
		["Hathcock"] = {	--8 + beam(9) + missile(13) + shield(9) + hull(6) + impulse(14) + ftl(8) + sensors(11) = 78
			["beam"] = {
				{	--1
					{idx = 0, arc = 20, dir =   0, rng = 1200, cyc = 8,  dmg = 4},
					{idx = 1, arc = 40, dir =   0, rng = 1000, cyc = 8,  dmg = 4},
				},
				{	--2
					{idx = 0, arc = 20, dir =   0, rng = 1200, cyc = 7,  dmg = 4},
					{idx = 1, arc = 40, dir =   0, rng = 1000, cyc = 7,  dmg = 4},
					["desc"] = _("upgrade-comms","reduce cycle time by 12.5%")
				},
				{	--3
					{idx = 0, arc = 20, dir =   0, rng = 1200, cyc = 7,  dmg = 4},
					{idx = 1, arc = 60, dir =   0, rng = 1000, cyc = 7,  dmg = 4},
					["desc"] = _("upgrade-comms","increase arc width by 50%")
				},
				{	--4
					{idx = 0, arc = 20, dir =   0, rng = 1200, cyc = 7,  dmg = 4},
					{idx = 1, arc = 60, dir =   0, rng = 1000, cyc = 7,  dmg = 4},
					{idx = 2, arc = 80, dir =   0, rng =  800, cyc = 7,  dmg = 4},
					["desc"] = _("upgrade-comms","add beam")
				},
				{	--5
					{idx = 0, arc = 20, dir =   0, rng = 1200, cyc = 6,  dmg = 4},
					{idx = 1, arc = 60, dir =   0, rng = 1000, cyc = 6,  dmg = 4},
					{idx = 2, arc = 80, dir =   0, rng =  800, cyc = 6,  dmg = 4},
					["desc"] = _("upgrade-comms","reduce cycle time by ~14%"),
				},
				{	--6
					{idx = 0, arc = 20, dir =   0, rng = 1200, cyc = 6,  dmg = 4},
					{idx = 1, arc = 60, dir =   0, rng = 1000, cyc = 6,  dmg = 4},
					{idx = 2, arc = 90, dir =   0, rng =  800, cyc = 6,  dmg = 4},
					["desc"] = _("upgrade-comms","increase arc width by 12.5%"),
				},
				{	--7
					{idx = 0, arc =  4, dir =   0, rng = 1400, cyc = 6,  dmg = 4},
					{idx = 1, arc = 20, dir =   0, rng = 1200, cyc = 6,  dmg = 4},
					{idx = 2, arc = 60, dir =   0, rng = 1000, cyc = 6,  dmg = 4},
					{idx = 3, arc = 90, dir =   0, rng =  800, cyc = 6,  dmg = 4},
					["desc"] = _("upgrade-comms","add beam"),
				},
				{	--8
					{idx = 0, arc =  4, dir =   0, rng = 1400, cyc = 6,  dmg = 5},
					{idx = 1, arc = 20, dir =   0, rng = 1200, cyc = 6,  dmg = 5},
					{idx = 2, arc = 60, dir =   0, rng = 1000, cyc = 6,  dmg = 5},
					{idx = 3, arc = 90, dir =   0, rng =  800, cyc = 6,  dmg = 5},
					["desc"] = _("upgrade-comms","increase damage by 25%"),
				},
				{	--9
					{idx = 0, arc =  4, dir =   0, rng = 1500, cyc = 6,  dmg = 5},
					{idx = 1, arc = 20, dir =   0, rng = 1300, cyc = 6,  dmg = 5},
					{idx = 2, arc = 60, dir =   0, rng = 1100, cyc = 6,  dmg = 5},
					{idx = 3, arc = 90, dir =   0, rng =  900, cyc = 6,  dmg = 5},
					["desc"] = _("upgrade-comms","increase range by ~9.5%"),
				},
				{	--10
					{idx = 0, arc =  4, dir =   0, rng = 1500, cyc = 5,  dmg = 5},
					{idx = 1, arc = 20, dir =   0, rng = 1300, cyc = 5,  dmg = 5},
					{idx = 2, arc = 60, dir =   0, rng = 1100, cyc = 5,  dmg = 5},
					{idx = 3, arc = 90, dir =   0, rng =  900, cyc = 5,  dmg = 5},
					["desc"] = _("upgrade-comms","reduce cycle time by ~17%"),
				},
				["stock"] = {
					{idx = 0, arc =  4, dir =   0, rng = 1400, cyc = 6, dmg = 4},
					{idx = 1, arc = 20, dir =   0, rng = 1200, cyc = 6, dmg = 4},
					{idx = 2, arc = 60, dir =   0, rng = 1000, cyc = 6, dmg = 4},
					{idx = 3, arc = 90, dir =   0, rng =  800, cyc = 6, dmg = 4},
				},
				["start"] = 4,
			},
			["missiles"] = {
				{tube = 1,	ord = 1},																	--1
				{tube = 2,	ord = 2, desc = _("upgrade-comms","add homing")},							--2  
				{tube = 3,	ord = 2, desc = _("upgrade-comms","increase tube size")},					--3  
				{tube = 3,	ord = 3, desc = _("upgrade-comms","increase HVLI capacity by 50%")},		--4
				{tube = 3,	ord = 4, desc = _("upgrade-comms","double homing capacity")},				--5
				{tube = 4,	ord = 4, desc = _("upgrade-comms","speed up missile load time by 10%")},	--6
				{tube = 5,	ord = 5, desc = _("upgrade-comms","add nukes and EMPs")},					--7
				{tube = 5,	ord = 6, desc = _("upgrade-comms","increase HVLI capacity by 1/3")},		--8
				{tube = 6,	ord = 6, desc = _("upgrade-comms","speed up load time by ~17%")},			--9
				{tube = 7,	ord = 7, desc = _("upgrade-comms","add mine tube")},						--10
				{tube = 8,	ord = 7, desc = _("upgrade-comms","20% faster broadside loading")},			--11
				{tube = 8,	ord = 8, desc = _("upgrade-comms","more homing, mine and HVLI missiles")},	--12
				{tube = 8,	ord = 9, desc = _("upgrade-comms","more nuke and EMP missiles")},			--13
				{tube = 8,	ord = 10,desc = _("upgrade-comms","more homing and mine missiles")},		--14
				["start"] = 3,
			},
			["tube"] = {
				{	--1
					{idx = 0, dir = -90, siz = "S", spd = 20, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  90, siz = "S", spd = 20, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--2
					{idx = 0, dir = -90, siz = "S", spd = 20, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  90, siz = "S", spd = 20, hom = true,  nuk = false, emp = false, min = false, hvl = true },
				},
				{	--3
					{idx = 0, dir = -90, siz = "M", spd = 20, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  90, siz = "M", spd = 20, hom = true,  nuk = false, emp = false, min = false, hvl = true },
				},
				{	--4
					{idx = 0, dir = -90, siz = "M", spd = 18, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  90, siz = "M", spd = 18, hom = true,  nuk = false, emp = false, min = false, hvl = true },
				},
				{	--5
					{idx = 0, dir = -90, siz = "M", spd = 18, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 1, dir =  90, siz = "M", spd = 18, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
				},
				{	--6
					{idx = 0, dir = -90, siz = "M", spd = 15, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 1, dir =  90, siz = "M", spd = 15, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
				},
				{	--7
					{idx = 0, dir = -90, siz = "M", spd = 15, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 1, dir =  90, siz = "M", spd = 15, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 20, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--8
					{idx = 0, dir = -90, siz = "M", spd = 12, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 1, dir =  90, siz = "M", spd = 12, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 20, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				["stock"] = {
					{idx = 0, dir = -90, siz = "M", spd = 15, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 1, dir =  90, siz = "M", spd = 15, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
				},
			},
			["ordnance"] = {
				{hom = 0,  nuk = 0, emp = 0, min = 0, hvl = 4},		--1
				{hom = 2,  nuk = 0, emp = 0, min = 0, hvl = 4},		--2
				{hom = 2,  nuk = 0, emp = 0, min = 0, hvl = 6},		--3
				{hom = 4,  nuk = 0, emp = 0, min = 0, hvl = 6},		--4		
				{hom = 4,  nuk = 1, emp = 2, min = 0, hvl = 6},		--5		
				{hom = 4,  nuk = 1, emp = 2, min = 0, hvl = 8},		--6		
				{hom = 4,  nuk = 1, emp = 2, min = 2, hvl = 8},		--7		
				{hom = 6,  nuk = 1, emp = 2, min = 3, hvl = 10},	--8	
				{hom = 6,  nuk = 2, emp = 4, min = 3, hvl = 10},	--9		
				{hom = 8,  nuk = 2, emp = 4, min = 4, hvl = 10},	--10		
				["stock"] = {hom = 4, nuk = 1, emp = 2, min = 0, hvl = 8},
			},
			["shield"] = {
				{	--1
					{idx = 0, max = 50},
				},
				{	--2
					{idx = 0, max = 60},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--3
					{idx = 0, max = 80},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 1/3"),
				},
				{	--4
					{idx = 0, max = 50},
					{idx = 1, max = 50},
					["desc"] = _("upgrade-comms","add rear shield arc"),
				},
				{	--5
					{idx = 0, max = 60},
					{idx = 1, max = 60},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--6
					{idx = 0, max = 80},
					{idx = 1, max = 60},
					["desc"] = _("upgrade-comms","increase front shield charge capacity by 1/3"),
				},
				{	--7
					{idx = 0, max = 100},
					{idx = 1, max = 60},
					["desc"] = _("upgrade-comms","increase front shield charge capacity by 25%"),
				},
				{	--8
					{idx = 0, max = 100},
					{idx = 1, max = 80},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by 1/3"),
				},
				{	--9
					{idx = 0, max = 120},
					{idx = 1, max = 80},
					["desc"] = _("upgrade-comms","increase front shield charge capacity by 20%"),
				},
				{	--10
					{idx = 0, max = 150},
					{idx = 1, max = 80},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by 25%"),
				},
				["stock"] = {
					{idx = 0, max = 70},
					{idx = 1, max = 70},
				},
				["start"] = 6,
			},	
			["hull"] = {
				{max = 80},												--1
				{max = 100, ["desc"] = _("upgrade-comms","increase hull max by 25%")},		--2
				{max = 120, ["desc"] = _("upgrade-comms","increase hull max by 20%")},		--3
				{max = 150, ["desc"] = _("upgrade-comms","increase hull max by 25%")},		--4
				{max = 175, ["desc"] = _("upgrade-comms","increase hull max by ~17%")},	--5
				{max = 200, ["desc"] = _("upgrade-comms","increase hull max by ~14%")},	--6
				{max = 220, ["desc"] = _("upgrade-comms","increase hull max by 10%")},		--7
				["stock"] = {max = 120},
				["start"] = 4,
			},
			["impulse"] = {
				{	--1
					max_front =		50,		max_back =		50,
					accel_front =	6,		accel_back = 	10,
					turn = 			10,
					boost =			0,		strafe =		0,
				},
				{	--2
					max_front =		50,		max_back =		60,
					accel_front =	6,		accel_back = 	10,
					turn = 			10,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase max reverse impulse speed by 20%"),
				},
				{	--3
					max_front =		50,		max_back =		60,
					accel_front =	6,		accel_back = 	15,
					turn = 			10,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase reverse acceleration by 50%"),
				},
				{	--4
					max_front =		50,		max_back =		60,
					accel_front =	6,		accel_back = 	15,
					turn = 			15,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase maneuverability by 50%"),
				},
				{	--5
					max_front =		50,		max_back =		60,
					accel_front =	6,		accel_back = 	15,
					turn = 			15,
					boost =			200,	strafe =		150,
					desc = _("upgrade-comms","add combat maneuver"),
				},
				{	--6
					max_front =		60,		max_back =		60,
					accel_front =	6,		accel_back = 	15,
					turn = 			15,
					boost =			200,	strafe =		150,
					desc = _("upgrade-comms","increase forward impulse speed by 20%"),
				},
				{	--7
					max_front =		60,		max_back =		60,
					accel_front =	9,		accel_back = 	15,
					turn = 			15,
					boost =			200,	strafe =		150,
					desc = _("upgrade-comms","increase forward impulse acceleration by 50%"),
				},
				{	--8
					max_front =		60,		max_back =		80,
					accel_front =	9,		accel_back = 	15,
					turn = 			15,
					boost =			200,	strafe =		150,
					desc = _("upgrade-comms","increase reverse impulse speed by 1/3"),
				},
				{	--9
					max_front =		60,		max_back =		80,
					accel_front =	9,		accel_back = 	15,
					turn = 			15,
					boost =			400,	strafe =		300,
					desc = _("upgrade-comms","double combat maneuverability"),
				},
				{	--10
					max_front =		60,		max_back =		80,
					accel_front =	9,		accel_back = 	18,
					turn = 			15,
					boost =			400,	strafe =		300,
					desc = _("upgrade-comms","increase reverse impulse acceleration by 20%"),
				},
				{	--11
					max_front =		60,		max_back =		80,
					accel_front =	12,		accel_back = 	18,
					turn = 			15,
					boost =			400,	strafe =		300,
					desc = _("upgrade-comms","increase forward acceleration by 1/3"),
				},
				{	--12
					max_front =		66,		max_back =		80,
					accel_front =	12,		accel_back = 	18,
					turn = 			15,
					boost =			400,	strafe =		300,
					desc = _("upgrade-comms","increase forward impulse speed by 10%"),
				},
				{	--13
					max_front =		66,		max_back =		80,
					accel_front =	12,		accel_back = 	18,
					turn = 			15,
					boost =			500,	strafe =		300,
					desc = _("upgrade-comms","increase combat maneuver boost by 25%"),
				},
				{	--14
					max_front =		66,		max_back =		88,
					accel_front =	12,		accel_back = 	18,
					turn = 			15,
					boost =			500,	strafe =		300,
					desc = _("upgrade-comms","increase reverse impulse speed by 10%"),
				},
				{	--15
					max_front =		66,		max_back =		88,
					accel_front =	12,		accel_back = 	18,
					turn = 			18,
					boost =			500,	strafe =		300,
					desc = _("upgrade-comms","increase maneuverability by 20%"),
				},
				["stock"] = {
					{max_front = 50, turn = 15, accel_front = 8, max_back = 50, accel_back = 8, boost = 200, strafe = 150},
				},
				["start"] = 5,
			},
			["ftl"] = {
				{	--1
					jump_long = 0, jump_short = 0, warp = 0,
				},
				{	--2
					jump_long = 20000, jump_short = 2000, warp = 0,
					desc = _("upgrade-comms","add 20k jump drive"),
				},
				{	--3
					jump_long = 25000, jump_short = 2500, warp = 0,
					desc = _("upgrade-comms","increase jump range by 25%"),
				},
				{	--4
					jump_long = 30000, jump_short = 3000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 20%"),
				},
				{	--5
					jump_long = 40000, jump_short = 4000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 1/3"),
				},
				{	--6
					jump_long = 50000, jump_short = 5000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 25%"),
				},
				{	--7
					jump_long = 50000, jump_short = 5000, warp = 400,
					desc = _("upgrade-comms","add warp drive"),
				},
				{	--8
					jump_long = 50000, jump_short = 5000, warp = 500,
					desc = _("upgrade-comms","increase warp speed by 25%"),
				},
				{	--9
					jump_long = 50000, jump_short = 5000, warp = 600,
					desc = _("upgrade-comms","increase warp speed by 20%"),
				},
				["stock"] = {
					{jump_long = 50000, jump_short = 5000, warp = 0},
				},
				["start"] = 3,
			},
			["sensors"] = {
				{	--1
					short = 4000, long = 15000, prox_scan = 0,
				},
				{	--2
					short = 4000, long = 20000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by 25%"),
				},
				{	--3
					short = 4000, long = 22000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by 10%"),
				},
				{	--4
					short = 4500, long = 22000, prox_scan = 0,
					desc = _("upgrade-comms","increase short range sensors by 12.5%"),
				},
				{	--5
					short = 4500, long = 25000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by ~14%"),
				},
				{	--6
					short = 4500, long = 25000, prox_scan = 2,
					desc = _("upgrade-comms","add 2 unit automated proximity scanner"),
				},
				{	--7
					short = 4500, long = 30000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by 20%"),
				},
				{	--8
					short = 5000, long = 30000, prox_scan = 2,
					desc = _("upgrade-comms","increase short range sensors by ~11%"),
				},
				{	--9
					short = 5000, long = 35000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by ~17%"),
				},
				{	--10
					short = 5000, long = 40000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by ~14%"),
				},
				{	--11
					short = 5000, long = 45000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by 12.5%"),
				},
				{	--12
					short = 5000, long = 50000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by ~11%"),
				},
				["stock"] = {
					{short = 5000, long = 30000}, prox_scan = 0,
				},
				["start"] = 6,
			},
			["providers"] = false,
			["score"] = 32,
		},
		["Piranha"] = {		--9 + beam(8) + missile(15) + shield(8) + hull(6) + impulse(9) + ftl(8) + sensors(11) = 74
			["beam"] = {
				{	--1
					{idx = 0, arc = 30, dir =   0, rng = 800, cyc = 8, dmg = 4},
				},
				{	--2
					{idx = 0, arc = 30, dir =   0, rng = 900, cyc = 8, dmg = 4},
					["desc"] = _("upgrade-comms","increase range by 12.5%")
				},
				{	--3
					{idx = 0, arc = 45, dir =   0, rng = 900, cyc = 8, dmg = 4},
					["desc"] = _("upgrade-comms","increase arc by 50%")
				},
				{	--4
					{idx = 0, arc = 45, dir =   0, rng = 900, cyc = 7, dmg = 4},
					["desc"] = _("upgrade-comms","decrease cycle time by 12.5%")
				},
				{	--5
					{idx = 0, arc = 45, dir =   0, rng = 900, cyc = 7, dmg = 5},
					["desc"] = _("upgrade-comms","increase damage by 25%"),
				},
				{	--6
					{idx = 0, arc = 45, dir =   0, rng = 1000, cyc = 7, dmg = 5},
					["desc"] = _("upgrade-comms","increase range by ~11%"),
				},
				{	--7
					{idx = 0, arc = 45, dir =   0, rng = 1000, cyc = 7, dmg = 5},
					{idx = 1, arc = 30, dir =   0, rng = 1000, cyc = 7, dmg = 5},
					["desc"] = _("upgrade-comms","add beam"),
				},
				{	--8
					{idx = 0, arc = 45, dir =   0, rng = 1000, cyc = 6, dmg = 5},
					{idx = 1, arc = 30, dir =   0, rng = 1000, cyc = 6, dmg = 5},
					["desc"] = _("upgrade-comms","decrease cycle time by ~14%"),
				},
				{	--9
					{idx = 0, arc = 90, dir =   0, rng = 1000, cyc = 6, dmg = 5},
					{idx = 1, arc = 60, dir =   0, rng = 1000, cyc = 6, dmg = 5},
					["desc"] = _("upgrade-comms","double arc width"),
				},
				["stock"] = {
					{idx = -1},
				},
				["start"] = 3,
			},
			["missiles"] = {
				{tube = 1,	ord = 1},																							--1
				{tube = 2,	ord = 1, desc = _("upgrade-comms","large tubes")},													--2  
				{tube = 3,	ord = 1, desc = _("upgrade-comms","decrease load time by 25%")},									--3  
				{tube = 4,	ord = 2, desc = _("upgrade-comms","add mining tube")},												--4
				{tube = 5,	ord = 3, desc = _("upgrade-comms","add medium homing tubes and homing missiles")},					--5
				{tube = 5,	ord = 4, desc = _("upgrade-comms","increase homing missile capacity by 50%")},						--6
				{tube = 6,	ord = 4, desc = _("upgrade-comms","add homing capability to large tubes")},							--7
				{tube = 7,	ord = 4, desc = _("upgrade-comms","increase tube load speed by 20%")},								--8
				{tube = 8,	ord = 5, desc = _("upgrade-comms","add nukes and EMPs, increase homing and HVLI capacity")},		--9
				{tube = 8,	ord = 6, desc = _("upgrade-comms","increase EMP and mine capacity")},								--10
				{tube = 9,	ord = 6, desc = _("upgrade-comms","add a second mine tube")},										--11
				{tube = 10,	ord = 7, desc = _("upgrade-comms","add large tubes, increase homing capacity")},					--12
				{tube = 11,	ord = 7, desc = _("upgrade-comms","increase tube load speed by 25%")},								--13
				{tube = 12,	ord = 8, desc = _("upgrade-comms","add 3rd mining tube, increase mine, EMP and nuke capacity")},	--14
				{tube = 13,	ord = 9, desc = _("upgrade-comms","increase tube load speeds, increase nuke and HVLI capacity")},	--15
				{tub = 13,	ord = 10,desc = _("upgrade-comms","increase homing, EMP, mine and HVLI capacity)")},				--16
				["start"] = 5,
			},		
			["tube"] = {
				{	--1
					{idx = 0, dir = -90, siz = "M", spd = 20, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  90, siz = "M", spd = 20, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--2
					{idx = 0, dir = -90, siz = "L", spd = 20, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  90, siz = "L", spd = 20, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--3
					{idx = 0, dir = -90, siz = "L", spd = 15, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  90, siz = "L", spd = 15, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--4
					{idx = 0, dir = -90, siz = "L", spd = 15, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  90, siz = "L", spd = 15, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 15, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--5
					{idx = 0, dir = -90, siz = "L", spd = 15, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  90, siz = "L", spd = 15, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = -90, siz = "M", spd = 15, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 15, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 4, dir = 180, siz = "M", spd = 15, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--6
					{idx = 0, dir = -90, siz = "L", spd = 15, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  90, siz = "L", spd = 15, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = -90, siz = "M", spd = 15, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 15, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 4, dir = 180, siz = "M", spd = 15, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--7
					{idx = 0, dir = -90, siz = "L", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  90, siz = "L", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = -90, siz = "M", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 4, dir = 180, siz = "M", spd = 12, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--8
					{idx = 0, dir = -90, siz = "L", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  90, siz = "L", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = -90, siz = "M", spd = 12, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 12, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 4, dir = 180, siz = "M", spd = 12, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--9
					{idx = 0, dir = -90, siz = "L", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  90, siz = "L", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = -90, siz = "M", spd = 12, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 12, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 4, dir = 170, siz = "M", spd = 12, hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 5, dir = 190, siz = "M", spd = 12, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--10
					{idx = 0, dir = -90, siz = "L", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  90, siz = "L", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = -90, siz = "M", spd = 12, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 12, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 4, dir = -90, siz = "L", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 5, dir =  90, siz = "L", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 6, dir = 170, siz = "M", spd = 12, hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 7, dir = 190, siz = "M", spd = 12, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--11
					{idx = 0, dir = -90, siz = "L", spd = 9,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  90, siz = "L", spd = 9,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = -90, siz = "M", spd = 9,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 9,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 4, dir = -90, siz = "L", spd = 9,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 5, dir =  90, siz = "L", spd = 9,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 6, dir = 170, siz = "M", spd = 9,  hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 7, dir = 190, siz = "M", spd = 9,  hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--12
					{idx = 0, dir = -90, siz = "L", spd = 9,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  90, siz = "L", spd = 9,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = -90, siz = "M", spd = 9,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 9,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 4, dir = -90, siz = "L", spd = 9,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 5, dir =  90, siz = "L", spd = 9,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 6, dir = 170, siz = "M", spd = 9,  hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 7, dir = 180, siz = "M", spd = 9,  hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 8, dir = 190, siz = "M", spd = 9,  hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--13
					{idx = 0, dir = -90, siz = "L", spd = 7,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  90, siz = "L", spd = 7,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = -90, siz = "M", spd = 6,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 6,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 4, dir = -90, siz = "L", spd = 7,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 5, dir =  90, siz = "L", spd = 7,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 6, dir = 170, siz = "M", spd = 8,  hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 7, dir = 180, siz = "M", spd = 8,  hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 8, dir = 190, siz = "M", spd = 8,  hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				["stock"] = {
					{idx = 0, dir = -90, siz = "L", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir = -90, siz = "M", spd = 8,  hom = true,  nuk = true,  emp = true,  min = true,  hvl = true },
					{idx = 2, dir = -90, siz = "L", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 3, dir = -90, siz = "L", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 4, dir = -90, siz = "M", spd = 8,  hom = true,  nuk = true,  emp = true,  min = true,  hvl = true },
					{idx = 5, dir = -90, siz = "L", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 6, dir = 170, siz = "M", spd = 8,  hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 7, dir = 190, siz = "M", spd = 8,  hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
			},
			["ordnance"] = {
				{hom = 0,  nuk = 0, emp = 0, min = 0, hvl = 10},	--1
				{hom = 0,  nuk = 0, emp = 0, min = 3, hvl = 10},	--2
				{hom = 4,  nuk = 0, emp = 0, min = 3, hvl = 10},	--3
				{hom = 6,  nuk = 0, emp = 0, min = 3, hvl = 10},	--4		
				{hom = 8,  nuk = 2, emp = 2, min = 3, hvl = 16},	--5		
				{hom = 8,  nuk = 2, emp = 4, min = 4, hvl = 16},	--6		
				{hom = 12, nuk = 2, emp = 4, min = 4, hvl = 16},	--7		
				{hom = 12, nuk = 4, emp = 6, min = 6, hvl = 16},	--8	
				{hom = 12, nuk = 6, emp = 6, min = 6, hvl = 20},	--9		
				{hom = 16, nuk = 6, emp = 8, min = 9, hvl = 24},	--10		
				["stock"] = {hom = 12, nuk = 6, emp = 0, min = 8, hvl = 20},
			},
			["shield"] = {
				{	--1
					{idx = 0, max = 50},
				},
				{	--2
					{idx = 0, max = 60},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--3
					{idx = 0, max = 80},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 1/3"),
				},
				{	--4
					{idx = 0, max = 50},
					{idx = 1, max = 50},
					["desc"] = _("upgrade-comms","add rear shield arc"),
				},
				{	--5
					{idx = 0, max = 60},
					{idx = 1, max = 60},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--6
					{idx = 0, max = 80},
					{idx = 1, max = 80},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 1/3"),
				},
				{	--7
					{idx = 0, max = 100},
					{idx = 1, max = 100},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--8
					{idx = 0, max = 120},
					{idx = 1, max = 120},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--9
					{idx = 0, max = 132},
					{idx = 1, max = 132},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 10%"),
				},
				["stock"] = {
					{idx = 0, max = 70},
					{idx = 1, max = 70},
				},
				["start"] = 3,
			},	
			["hull"] = {
				{max = 80},																--1
				{max = 100, ["desc"] = _("upgrade-comms","increase hull max by 25%")},	--2
				{max = 120, ["desc"] = _("upgrade-comms","increase hull max by 20%")},	--3
				{max = 150, ["desc"] = _("upgrade-comms","increase hull max by 25%")},	--4
				{max = 175, ["desc"] = _("upgrade-comms","increase hull max by ~17%")},	--5
				{max = 200, ["desc"] = _("upgrade-comms","increase hull max by ~14%")},	--6
				{max = 220, ["desc"] = _("upgrade-comms","increase hull max by 10%")},	--7
				["stock"] = {max = 120},
				["start"] = 4,
			},
			["impulse"] = {
				{	--1
					max_front =		50,		max_back =		50,
					accel_front =	6,		accel_back = 	6,
					turn = 			8,
					boost =			0,		strafe =		0,
				},
				{	--2
					max_front =		60,		max_back =		50,
					accel_front =	6,		accel_back = 	6,
					turn = 			8,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase max forward impulse speed by 20%"),
				},
				{	--3
					max_front =		60,		max_back =		50,
					accel_front =	8,		accel_back = 	6,
					turn = 			8,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase forward acceleration by 1/3"),
				},
				{	--4
					max_front =		60,		max_back =		50,
					accel_front =	8,		accel_back = 	6,
					turn = 			10,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase maneuverability by 25%"),
				},
				{	--5
					max_front =		60,		max_back =		50,
					accel_front =	8,		accel_back = 	6,
					turn = 			10,
					boost =			200,	strafe =		0,
					desc = _("upgrade-comms","add combat maneuver boost"),
				},
				{	--6
					max_front =		72,		max_back =		60,
					accel_front =	8,		accel_back = 	6,
					turn = 			10,
					boost =			200,	strafe =		0,
					desc = _("upgrade-comms","increase max impulse speed by 20%"),
				},
				{	--7
					max_front =		72,		max_back =		60,
					accel_front =	8,		accel_back = 	6,
					turn = 			10,
					boost =			200,	strafe =		150,
					desc = _("upgrade-comms","add combat maneuver strafe"),
				},
				{	--8
					max_front =		72,		max_back =		60,
					accel_front =	16,		accel_back = 	12,
					turn = 			10,
					boost =			200,	strafe =		150,
					desc = _("upgrade-comms","double impulse acceleration"),
				},
				{	--9
					max_front =		72,		max_back =		60,
					accel_front =	16,		accel_back = 	12,
					turn = 			12,
					boost =			200,	strafe =		150,
					desc = _("upgrade-comms","increase maneuverability by 20%"),
				},
				{	--10
					max_front =		72,		max_back =		60,
					accel_front =	16,		accel_back = 	12,
					turn = 			12,
					boost =			300,	strafe =		225,
					desc = _("upgrade-comms","increase combat maneuver by 50%"),
				},
				["stock"] = {
					{max_front = 60, turn = 10, accel_front = 8, max_back = 60, accel_back = 8, boost = 200, strafe = 150},
				},
				["start"] = 3,
			},		
			["ftl"] = {
				{	--1
					jump_long = 0, jump_short = 0, warp = 0,
				},
				{	--2
					jump_long = 20000, jump_short = 2000, warp = 0,
					desc = _("upgrade-comms","add 20k jump drive"),
				},
				{	--3
					jump_long = 25000, jump_short = 2500, warp = 0,
					desc = _("upgrade-comms","increase jump range by 25%"),
				},
				{	--4
					jump_long = 30000, jump_short = 3000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 20%"),
				},
				{	--5
					jump_long = 40000, jump_short = 4000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 1/3"),
				},
				{	--6
					jump_long = 50000, jump_short = 5000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 25%"),
				},
				{	--7
					jump_long = 50000, jump_short = 5000, warp = 400,
					desc = _("upgrade-comms","add warp drive"),
				},
				{	--8
					jump_long = 50000, jump_short = 5000, warp = 500,
					desc = _("upgrade-comms","increase warp speed by 25%"),
				},
				{	--9
					jump_long = 50000, jump_short = 5000, warp = 600,
					desc = _("upgrade-comms","increase warp speed by 20%"),
				},
				["stock"] = {
					{jump_long = 50000, jump_short = 5000, warp = 0},
				},
				["start"] = 3,
			},
			["sensors"] = {
				{	--1
					short = 4000, long = 15000, prox_scan = 0,
				},
				{	--2
					short = 4000, long = 20000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by 25%"),
				},
				{	--3
					short = 4000, long = 22000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by 10%"),
				},
				{	--4
					short = 4500, long = 22000, prox_scan = 0,
					desc = _("upgrade-comms","increase short range sensors by 12.5%"),
				},
				{	--5
					short = 4500, long = 25000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by ~14%"),
				},
				{	--6
					short = 4500, long = 30000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by 20%"),
				},
				{	--7
					short = 5000, long = 30000, prox_scan = 0,
					desc = _("upgrade-comms","increase short range sensors by ~11%"),
				},
				{	--8
					short = 5000, long = 35000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by ~17%"),
				},
				{	--9
					short = 5000, long = 35000, prox_scan = 2,
					desc = _("upgrade-comms","add 2 unit automated proximity scanner"),
				},
				{	--10
					short = 5500, long = 35000, prox_scan = 2,
					desc = _("upgrade-comms","increase short range sensors by 10%"),
				},
				{	--11
					short = 5500, long = 40000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by ~14%"),
				},
				{	--12
					short = 6000, long = 40000, prox_scan = 2,
					desc = _("upgrade-comms","increase short range sensors by ~9%"),
				},
				["stock"] = {
					{short = 5000, long = 30000}, prox_scan = 0,
				},
				["start"] = 3,
			},
			["providers"] = false,
			["score"] = 26,
		},
		["Flavia P.Falcon"] = {	--7 + beam(9) + missile(14) + shield(9) + hull(6) + impulse(10) + ftl(9) + sensors(11) = 77
			["beam"] = {
				{	--1
					{idx = 0, arc = 30, dir = 180, rng = 800, cyc = 8, dmg = 4},
				},
				{	--2
					{idx = 0, arc = 30, dir = 180, rng = 1000, cyc = 8, dmg = 4},
					["desc"] = _("upgrade-comms","increase range by 25%")
				},
				{	--3
					{idx = 0, arc = 40, dir = 180, rng = 1000, cyc = 8, dmg = 4},
					["desc"] = _("upgrade-comms","increase arc by 1/3")
				},
				{	--4
					{idx = 0, arc = 40, dir = 180, rng = 1000, cyc = 6, dmg = 4},
					["desc"] = _("upgrade-comms","decrease cycle time by 25%")
				},
				{	--5
					{idx = 0, arc = 40, dir = 180, rng = 1000, cyc = 6, dmg = 5},
					["desc"] = _("upgrade-comms","increase damage by 25%"),
				},
				{	--6
					{idx = 0, arc = 40, dir = 180, rng = 1200, cyc = 6, dmg = 5},
					["desc"] = _("upgrade-comms","increase range by 20%"),
				},
				{	--7
					{idx = 0, arc = 40, dir = 170, rng = 1200, cyc = 6, dmg = 5},
					{idx = 1, arc = 40, dir = 190, rng = 1200, cyc = 6, dmg = 5},
					["desc"] = _("upgrade-comms","add beam"),
				},
				{	--8
					{idx = 0, arc = 40, dir = 170, rng = 1200, cyc = 6, dmg = 5},
					{idx = 1, arc = 40, dir = 190, rng = 1200, cyc = 6, dmg = 5},
					{idx = 2, arc = 60, dir =   0, rng = 1200, cyc = 6, dmg = 5},
					["desc"] = _("upgrade-comms","add front beam"),
				},
				{	--9
					{idx = 0, arc = 40, dir = 170, rng = 1200, cyc = 6, dmg = 8},
					{idx = 1, arc = 40, dir = 190, rng = 1200, cyc = 6, dmg = 8},
					{idx = 2, arc = 60, dir =   0, rng = 1200, cyc = 6, dmg = 8},
					["desc"] = _("upgrade-comms","increase damage by 60%"),
				},
				{	--10
					{idx = 0, arc = 40, dir = 170, rng = 1200, cyc = 4, dmg = 8},
					{idx = 1, arc = 40, dir = 190, rng = 1200, cyc = 4, dmg = 8},
					{idx = 2, arc = 60, dir =   0, rng = 1200, cyc = 4, dmg = 8},
					["desc"] = _("upgrade-comms","decrease cycle time by 1/3"),
				},
				["stock"] = {
					{idx = 0, arc = 40, dir = 170, rng = 1200, cyc = 6, dmg = 6},
					{idx = 1, arc = 40, dir = 190, rng = 1200, cyc = 6, dmg = 6},
				},
				["start"] = 4,
			},
			["missiles"] = {
				{tube = 1,	ord = 1},																				--1
				{tube = 2,	ord = 2, desc = _("upgrade-comms","add homing")},										--2  
				{tube = 3,	ord = 2, desc = _("upgrade-comms","speed up tube load time by 25%")},					--3  
				{tube = 3,	ord = 3, desc = _("upgrade-comms","increase missile capacity: homing: 50%, HVLI: 25%")},--4
				{tube = 4,	ord = 4, desc = _("upgrade-comms","add nuke")},											--5
				{tube = 4,	ord = 5, desc = _("upgrade-comms","increase homing capacity by 2/3")},					--6
				{tube = 5,	ord = 5, desc = _("upgrade-comms","add medium sized homing and mine tube")},			--7
				{tube = 5,	ord = 6, desc = _("upgrade-comms","increase HVLI capacity by 40%")},					--8
				{tube = 6,	ord = 6, desc = _("upgrade-comms","add HVLI to medium sized tube")},					--9
				{tube = 6,	ord = 7, desc = _("upgrade-comms","double nuke and mine capacity")},					--10
				{tube = 7,	ord = 7, desc = _("upgrade-comms","add large tube for HVLIs and mines")},				--11
				{tube = 7,	ord = 8, desc = _("upgrade-comms","increase homing capacity by 20%")},					--12
				{tube = 8,	ord = 8, desc = _("upgrade-comms","reduce tube loading time by 25%")},					--13
				{tube = 9,	ord = 9, desc = _("upgrade-comms","add EMP to medium tube and homing to large tube")},	--14
				{tube = 9,	ord = 10,desc = _("upgrade-comms","increase homing, mine and HVLI capacity")},			--15
				["start"] = 5,
			},
			["tube"] = {
				{	--1
					{idx = 0, dir = 180, siz = "S", spd = 25, hom = false, nuk = false, emp = false, min = true,  hvl = true },
				},
				{	--2
					{idx = 0, dir = 180, siz = "S", spd = 25, hom = true,  nuk = false, emp = false, min = true,  hvl = true },
				},
				{	--3
					{idx = 0, dir = 180, siz = "S", spd = 20, hom = true,  nuk = false, emp = false, min = true,  hvl = true },
				},
				{	--4
					{idx = 0, dir = 180, siz = "S", spd = 20, hom = true,  nuk = true,  emp = false, min = true,  hvl = true },
				},
				{	--5
					{idx = 0, dir = 180, siz = "S", spd = 20, hom = true,  nuk = true,  emp = false, min = true,  hvl = true },
					{idx = 1, dir = 180, siz = "M", spd = 20, hom = true,  nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--6
					{idx = 0, dir = 180, siz = "S", spd = 20, hom = true,  nuk = true,  emp = false, min = true,  hvl = true },
					{idx = 1, dir = 180, siz = "M", spd = 20, hom = true,  nuk = false, emp = false, min = true,  hvl = true },
				},
				{	--7
					{idx = 0, dir = 180, siz = "S", spd = 20, hom = true,  nuk = true,  emp = false, min = true,  hvl = true },
					{idx = 1, dir = 180, siz = "M", spd = 20, hom = true,  nuk = false, emp = false, min = true,  hvl = true },
					{idx = 2, dir = 180, siz = "L", spd = 20, hom = false, nuk = false, emp = false, min = true,  hvl = true },
				},
				{	--8
					{idx = 0, dir = 180, siz = "S", spd = 15, hom = true,  nuk = true,  emp = false, min = true,  hvl = true },
					{idx = 1, dir = 180, siz = "M", spd = 15, hom = true,  nuk = false, emp = false, min = true,  hvl = true },
					{idx = 2, dir = 180, siz = "L", spd = 15, hom = false, nuk = false, emp = false, min = true,  hvl = true },
				},
				{	--9
					{idx = 0, dir = 180, siz = "S", spd = 15, hom = true,  nuk = true,  emp = false, min = true,  hvl = true },
					{idx = 1, dir = 180, siz = "M", spd = 15, hom = true,  nuk = false, emp = true,  min = true,  hvl = true },
					{idx = 2, dir = 180, siz = "L", spd = 15, hom = false, nuk = false, emp = false, min = true,  hvl = true },
				},
				{	--10
					{idx = 0, dir = 180, siz = "S", spd = 15, hom = true,  nuk = true,  emp = false, min = true,  hvl = true },
					{idx = 1, dir = 180, siz = "M", spd = 15, hom = true,  nuk = false, emp = true,  min = true,  hvl = true },
					{idx = 2, dir = 180, siz = "L", spd = 15, hom = true,  nuk = false, emp = false, min = true,  hvl = true },
				},
				["stock"] = {
					{idx = 0, dir = 180, siz = "M", spd = 20, hom = true,  nuk = true,  emp = false, min = true,  hvl = true },
				},
			},
			["ordnance"] = {
				{hom = 0,  nuk = 0, emp = 0, min = 1, hvl = 4},		--1
				{hom = 2,  nuk = 0, emp = 0, min = 1, hvl = 4},		--2
				{hom = 3,  nuk = 0, emp = 0, min = 1, hvl = 5},		--3
				{hom = 3,  nuk = 1, emp = 0, min = 1, hvl = 5},		--4		
				{hom = 5,  nuk = 1, emp = 0, min = 1, hvl = 5},		--5		
				{hom = 5,  nuk = 1, emp = 0, min = 1, hvl = 7},		--6		
				{hom = 5,  nuk = 2, emp = 0, min = 2, hvl = 7},		--7		
				{hom = 6,  nuk = 2, emp = 0, min = 2, hvl = 7},		--8	
				{hom = 6,  nuk = 2, emp = 4, min = 2, hvl = 7},		--9		
				{hom = 7,  nuk = 2, emp = 4, min = 4, hvl = 9},		--10		
				["stock"] = {hom = 4, nuk = 1, emp = 2, min = 0, hvl = 8},
			},
			["shield"] = {
				{	--1
					{idx = 0, max = 60},
				},
				{	--2
					{idx = 0, max = 75},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--3
					{idx = 0, max = 90},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--4
					{idx = 0, max = 80},
					{idx = 1, max = 80},
					["desc"] = _("upgrade-comms","add rear shield arc"),
				},
				{	--5
					{idx = 0, max = 80},
					{idx = 1, max = 100},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by 25%"),
				},
				{	--6
					{idx = 0, max = 80},
					{idx = 1, max = 120},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by 20%"),
				},
				{	--7
					{idx = 0, max = 100},
					{idx = 1, max = 120},
					["desc"] = _("upgrade-comms","increase front shield charge capacity by 25%"),
				},
				{	--8
					{idx = 0, max = 100},
					{idx = 1, max = 150},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by 20%"),
				},
				{	--9
					{idx = 0, max = 110},
					{idx = 1, max = 165},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 10%"),
				},
				{	--10
					{idx = 0, max = 110},
					{idx = 1, max = 200},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by ~21%"),
				},
				["stock"] = {
					{idx = 0, max = 70},
					{idx = 1, max = 70},
				},
				["start"] = 3,
			},	
			["hull"] = {
				{max = 80},																--1
				{max = 100, ["desc"] = _("upgrade-comms","increase hull max by 25%")},	--2
				{max = 120, ["desc"] = _("upgrade-comms","increase hull max by 20%")},	--3
				{max = 150, ["desc"] = _("upgrade-comms","increase hull max by 25%")},	--4
				{max = 165, ["desc"] = _("upgrade-comms","increase hull max by 10%")},	--5
				{max = 180, ["desc"] = _("upgrade-comms","increase hull max by ~9%")},	--6
				{max = 200, ["desc"] = _("upgrade-comms","increase hull max by ~11%")},	--7
				["stock"] = {max = 100},
				["start"] = 4,
			},
			["impulse"] = {
				{	--1
					max_front =		50,		max_back =		50,
					accel_front =	8,		accel_back = 	8,
					turn = 			8,
					boost =			0,		strafe =		0,
				},
				{	--2
					max_front =		60,		max_back =		50,
					accel_front =	8,		accel_back = 	8,
					turn = 			8,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase max forward impulse speed by 20%"),
				},
				{	--3
					max_front =		60,		max_back =		50,
					accel_front =	10,		accel_back = 	8,
					turn = 			8,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase forward acceleration by 25%"),
				},
				{	--4
					max_front =		60,		max_back =		50,
					accel_front =	10,		accel_back = 	8,
					turn = 			8,
					boost =			0,		strafe =		150,
					desc = _("upgrade-comms","add combat maneuver strafe"),
				},
				{	--5
					max_front =		60,		max_back =		50,
					accel_front =	10,		accel_back = 	8,
					turn = 			10,
					boost =			0,		strafe =		150,
					desc = _("upgrade-comms","increase maneuverability by 25%"),
				},
				{	--6
					max_front =		80,		max_back =		50,
					accel_front =	10,		accel_back = 	8,
					turn = 			10,
					boost =			0,		strafe =		150,
					desc = _("upgrade-comms","increase max impulse speed by 1/3"),
				},
				{	--7
					max_front =		80,		max_back =		50,
					accel_front =	10,		accel_back = 	8,
					turn = 			10,
					boost =			250,	strafe =		150,
					desc = _("upgrade-comms","add combat maneuver boost"),
				},
				{	--8
					max_front =		80,		max_back =		60,
					accel_front =	10,		accel_back = 	8,
					turn = 			10,
					boost =			250,	strafe =		150,
					desc = _("upgrade-comms","increase rear impulse max speed by 20%"),
				},
				{	--9
					max_front =		80,		max_back =		60,
					accel_front =	13,		accel_back = 	8,
					turn = 			10,
					boost =			250,	strafe =		150,
					desc = _("upgrade-comms","increase forward impulse acceleration by 30%"),
				},
				{	--10
					max_front =		80,		max_back =		60,
					accel_front =	13,		accel_back = 	8,
					turn = 			12,
					boost =			250,	strafe =		150,
					desc = _("upgrade-comms","increase maneuverability by 20%"),
				},
				{	--11
					max_front =		80,		max_back =		60,
					accel_front =	13,		accel_back = 	10,
					turn = 			12,
					boost =			250,	strafe =		150,
					desc = _("upgrade-comms","increase reverse impulse acceleration by 25%"),
				},
				["stock"] = {
					{max_front = 60, turn = 10, accel_front = 10, max_back = 60, accel_back = 10, boost = 250, strafe = 150},
				},
				["start"] = 4,
			},
			["ftl"] = {
				{	--1
					jump_long = 0, jump_short = 0, warp = 0,
				},
				{	--2
					jump_long = 0, jump_short = 0, warp = 350,
					desc = _("upgrade-comms","add warp drive"),
				},
				{	--3
					jump_long = 0, jump_short = 0, warp = 400,
					desc = _("upgrade-comms","increase warp speed by ~14%"),
				},
				{	--4
					jump_long = 0, jump_short = 0, warp = 500,
					desc = _("upgrade-comms","increase warp speed by 25%"),
				},
				{	--5
					jump_long = 0, jump_short = 0, warp = 600,
					desc = _("upgrade-comms","increase warp speed by 20%"),
				},
				{	--6
					jump_long = 0, jump_short = 0, warp = 650,
					desc = _("upgrade-comms","increase warp speed by ~8%"),
				},
				{	--7
					jump_long = 20000, jump_short = 2000, warp = 650,
					desc = _("upgrade-comms","add 20U jump drive"),
				},
				{	--8
					jump_long = 25000, jump_short = 2500, warp = 650,
					desc = _("upgrade-comms","increase jump range by 25%"),
				},
				{	--9
					jump_long = 25000, jump_short = 2500, warp = 700,
					desc = _("upgrade-comms","increase warp speed by ~8%"),
				},
				{	--10
					jump_long = 30000, jump_short = 3000, warp = 700,
					desc = _("upgrade-comms","increase jump range by 20%"),
				},
				["stock"] = {
					{jump_long = 0, jump_short = 0, warp = 500},
				},
				["start"] = 2,
			},
			["sensors"] = {
				{	--1
					short = 4000, long = 15000, prox_scan = 0,
				},
				{	--2
					short = 4000, long = 20000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by 25%"),
				},
				{	--3
					short = 4000, long = 20000, prox_scan = 3,
					desc = _("upgrade-comms","add 3 unit automated proximity scanner"),
				},
				{	--4
					short = 4000, long = 22000, prox_scan = 3,
					desc = _("upgrade-comms","increase long range sensors by 10%"),
				},
				{	--5
					short = 4500, long = 22000, prox_scan = 3,
					desc = _("upgrade-comms","increase short range sensors by 12.5%"),
				},
				{	--6
					short = 4500, long = 25000, prox_scan = 3,
					desc = _("upgrade-comms","increase long range sensors by ~14%"),
				},
				{	--7
					short = 4500, long = 30000, prox_scan = 3,
					desc = _("upgrade-comms","increase long range sensors by 20%"),
				},
				{	--8
					short = 5000, long = 30000, prox_scan = 3,
					desc = _("upgrade-comms","increase short range sensors by ~11%"),
				},
				{	--9
					short = 5000, long = 35000, prox_scan = 3,
					desc = _("upgrade-comms","increase long range sensors by ~17%"),
				},
				{	--10
					short = 5500, long = 35000, prox_scan = 3,
					desc = _("upgrade-comms","increase short range sensors by 10%"),
				},
				{	--11
					short = 5500, long = 40000, prox_scan = 3,
					desc = _("upgrade-comms","increase long range sensors by ~14%"),
				},
				{	--12
					short = 6000, long = 40000, prox_scan = 3,
					desc = "increase short range sensors by ~9%",
				},
				["stock"] = {
					{short = 5000, long = 30000}, prox_scan = 0,
				},
				["start"] = 4,
			},
			["providers"] = false,
			["score"] = 26,
		},
		["Repulse"] = {		--8 + beam(10) + missile(13) + shield(9) + hull(6) + impulse(10) + ftl(9) + sensors(10) = 75
			["beam"] = {
				{	--1
					{idx = 0, arc = 10, dir =  90, rng = 1000, cyc = 8, dmg = 4, tar =  90, tdr =  90, trt = 1},
					{idx = 1, arc = 10, dir = -90, rng = 1000, cyc = 8, dmg = 4, tar =  90, tdr = -90, trt = 1},
				},
				{	--2
					{idx = 0, arc = 10, dir =  90, rng = 1200, cyc = 8, dmg = 4, tar =  90, tdr =  90, trt = 1},
					{idx = 1, arc = 10, dir = -90, rng = 1200, cyc = 8, dmg = 4, tar =  90, tdr = -90, trt = 1},
					["desc"] = _("upgrade-comms","increase range by 20%")
				},
				{	--3
					{idx = 0, arc = 10, dir =  90, rng = 1200, cyc = 8, dmg = 4, tar = 120, tdr =  90, trt = 1},
					{idx = 1, arc = 10, dir = -90, rng = 1200, cyc = 8, dmg = 4, tar = 120, tdr = -90, trt = 1},
					["desc"] = _("upgrade-comms","increase arc by 1/3")
				},
				{	--4
					{idx = 0, arc = 10, dir =  90, rng = 1200, cyc = 6, dmg = 4, tar = 120, tdr =  90, trt = 1},
					{idx = 1, arc = 10, dir = -90, rng = 1200, cyc = 6, dmg = 4, tar = 120, tdr = -90, trt = 1},
					["desc"] = _("upgrade-comms","decrease cycle time by 25%")
				},
				{	--5
					{idx = 0, arc = 10, dir =  90, rng = 1200, cyc = 6, dmg = 5, tar = 120, tdr =  90, trt = 1},
					{idx = 1, arc = 10, dir = -90, rng = 1200, cyc = 6, dmg = 5, tar = 120, tdr = -90, trt = 1},
					["desc"] = _("upgrade-comms","increase damage by 25%"),
				},
				{	--6
					{idx = 0, arc = 10, dir =  90, rng = 1200, cyc = 6, dmg = 5, tar = 120, tdr =  90, trt = 2},
					{idx = 1, arc = 10, dir = -90, rng = 1200, cyc = 6, dmg = 5, tar = 120, tdr = -90, trt = 2},
					["desc"] = _("upgrade-comms","double turret speed"),
				},
				{	--7
					{idx = 0, arc = 10, dir =  90, rng = 1200, cyc = 6, dmg = 5, tar = 150, tdr =  90, trt = 2},
					{idx = 1, arc = 10, dir = -90, rng = 1200, cyc = 6, dmg = 5, tar = 150, tdr = -90, trt = 2},
					["desc"] = _("upgrade-comms","increase arc size by 25%"),
				},
				{	--8
					{idx = 0, arc = 10, dir =  90, rng = 1200, cyc = 6, dmg = 5, tar = 150, tdr =  90, trt = 4},
					{idx = 1, arc = 10, dir = -90, rng = 1200, cyc = 6, dmg = 5, tar = 150, tdr = -90, trt = 4},
					["desc"] = _("upgrade-comms","double turret speed"),
				},
				{	--9
					{idx = 0, arc = 10, dir =  90, rng = 1200, cyc = 6, dmg = 7, tar = 150, tdr =  90, trt = 4},
					{idx = 1, arc = 10, dir = -90, rng = 1200, cyc = 6, dmg = 7, tar = 150, tdr = -90, trt = 4},
					["desc"] = _("upgrade-comms","increase damage by 40%"),
				},
				{	--10
					{idx = 0, arc = 10, dir =  90, rng = 1200, cyc = 6, dmg = 7, tar = 200, tdr =  90, trt = 4},
					{idx = 1, arc = 10, dir = -90, rng = 1200, cyc = 6, dmg = 7, tar = 200, tdr = -90, trt = 4},
					["desc"] = _("upgrade-comms","overlap arcs"),
				},
				{	--11
					{idx = 0, arc = 10, dir =  90, rng = 1200, cyc = 5, dmg = 7, tar = 200, tdr =  90, trt = 4},
					{idx = 1, arc = 10, dir = -90, rng = 1200, cyc = 5, dmg = 7, tar = 200, tdr = -90, trt = 4},
					["desc"] = _("upgrade-comms","reduce cycle time by ~17%"),
				},
				["stock"] = {
					{idx = 0, arc = 10, dir =  90, rng = 1200, cyc = 6, dmg = 5, tar = 200, tdr =  90, trt = 5},
					{idx = 1, arc = 10, dir = -90, rng = 1200, cyc = 6, dmg = 5, tar = 200, tdr = -90, trt = 5},
				},
				["start"] = 5,
			},
			["missiles"] = {
				{tube = 1,	ord = 1},																			--1
				{tube = 2,	ord = 1, desc = _("upgrade-comms","decrease tube load time by 20%")},				--2  
				{tube = 2,	ord = 2, desc = _("upgrade-comms","increase capacity: homing: 100%, HVLI: 50%")},	--3  
				{tube = 3,	ord = 2, desc = _("upgrade-comms","increase tube size to medium")},					--4
				{tube = 3,	ord = 3, desc = _("upgrade-comms","increase capacity: homing: 50%, HVLI: 1/3")},	--5
				{tube = 4,	ord = 3, desc = _("upgrade-comms","speed up missile load time by 25%")},			--6
				{tube = 4,	ord = 4, desc = _("upgrade-comms","increase capacity: homing: 1/3, HVLI: 25%")},	--7
				{tube = 5,	ord = 4, desc = _("upgrade-comms","speed up load time by 20%")},					--8
				{tube = 6,	ord = 4, desc = _("upgrade-comms","increase tube size to large")},					--9
				{tube = 7,	ord = 5, desc = _("upgrade-comms","add mine tube")},								--10
				{tube = 7,	ord = 6, desc = _("upgrade-comms","double mine capacity")},							--11
				{tube = 7,	ord = 7, desc = _("upgrade-comms","increase mine capacity by 50%")},				--12
				{tube = 8,	ord = 7, desc = _("upgrade-comms","decrease tube load speed by 25%")},				--13
				{tube = 8,	ord = 8, desc = _("upgrade-comms","increase homing mine and HVLI capacity")},		--14
				["start"] = 4,
			},
			["tube"] = {
				{	--1
					{idx = 0, dir =   0, siz = "S", spd = 25, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir = 180, siz = "S", spd = 25, hom = true,  nuk = false, emp = false, min = false, hvl = true },
				},
				{	--2
					{idx = 0, dir =   0, siz = "S", spd = 20, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir = 180, siz = "S", spd = 20, hom = true,  nuk = false, emp = false, min = false, hvl = true },
				},
				{	--3
					{idx = 0, dir =   0, siz = "M", spd = 20, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir = 180, siz = "M", spd = 20, hom = true,  nuk = false, emp = false, min = false, hvl = true },
				},
				{	--4
					{idx = 0, dir =   0, siz = "M", spd = 15, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir = 180, siz = "M", spd = 15, hom = true,  nuk = false, emp = false, min = false, hvl = true },
				},
				{	--5
					{idx = 0, dir =   0, siz = "M", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir = 180, siz = "M", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
				},
				{	--6
					{idx = 0, dir =   0, siz = "L", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir = 180, siz = "L", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
				},
				{	--7
					{idx = 0, dir =   0, siz = "L", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir = 180, siz = "L", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 20, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--8
					{idx = 0, dir =   0, siz = "L", spd =  9, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir = 180, siz = "L", spd =  9, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 15, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				["stock"] = {
					{idx = 0, dir =   0, siz = "M", spd = 15, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir = 180, siz = "M", spd = 15, hom = true,  nuk = false, emp = false, min = false, hvl = true },
				},
			},
			["ordnance"] = {
				{hom = 2,  nuk = 0, emp = 0, min = 0, hvl = 4},		--1
				{hom = 4,  nuk = 0, emp = 0, min = 0, hvl = 6},		--2
				{hom = 6,  nuk = 0, emp = 0, min = 0, hvl = 8},		--3
				{hom = 8,  nuk = 0, emp = 0, min = 0, hvl = 10},	--4		
				{hom = 8,  nuk = 0, emp = 0, min = 1, hvl = 10},	--5		
				{hom = 8,  nuk = 0, emp = 0, min = 2, hvl = 10},	--6		
				{hom = 8,  nuk = 0, emp = 0, min = 3, hvl = 10},	--7		
				{hom = 10, nuk = 0, emp = 0, min = 4, hvl = 12},	--8	
				["stock"] = {hom = 4, nuk = 0, emp = 0, min = 0, hvl = 6},
			},
			["shield"] = {
				{	--1
					{idx = 0, max = 60},
				},
				{	--2
					{idx = 0, max = 75},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--3
					{idx = 0, max = 90},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--4
					{idx = 0, max = 80},
					{idx = 1, max = 80},
					["desc"] = _("upgrade-comms","add rear shield arc"),
				},
				{	--5
					{idx = 0, max = 80},
					{idx = 1, max = 100},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by 25%"),
				},
				{	--7
					{idx = 0, max = 100},
					{idx = 1, max = 100},
					["desc"] = _("upgrade-comms","increase front shield charge capacity by 25%"),
				},
				{	--8
					{idx = 0, max = 100},
					{idx = 1, max = 120},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by 20%"),
				},
				{	--9
					{idx = 0, max = 110},
					{idx = 1, max = 132},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 10%"),
				},
				{	--10
					{idx = 0, max = 110},
					{idx = 1, max = 150},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by ~14%"),
				},
				["stock"] = {
					{idx = 0, max = 80},
					{idx = 1, max = 80},
				},
				["start"] = 5,
			},	
			["hull"] = {
				{max = 80},																--1
				{max = 100, ["desc"] = _("upgrade-comms","increase hull max by 25%")},	--2
				{max = 120, ["desc"] = _("upgrade-comms","increase hull max by 20%")},	--3
				{max = 150, ["desc"] = _("upgrade-comms","increase hull max by 25%")},	--4
				{max = 180, ["desc"] = _("upgrade-comms","increase hull max by 20%")},	--5
				{max = 210, ["desc"] = _("upgrade-comms","increase hull max by ~17%")},	--6
				{max = 250, ["desc"] = _("upgrade-comms","increase hull max by ~19%")},	--7
				["stock"] = {max = 120},
				["start"] = 4,
			},
			["impulse"] = {
				{	--1
					max_front =		50,		max_back =		50,
					accel_front =	8,		accel_back = 	8,
					turn = 			8,
					boost =			0,		strafe =		0,
				},
				{	--2
					max_front =		60,		max_back =		60,
					accel_front =	8,		accel_back = 	8,
					turn = 			8,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase max impulse speed by 20%"),
				},
				{	--3
					max_front =		60,		max_back =		60,
					accel_front =	10,		accel_back = 	8,
					turn = 			8,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase forward acceleration by 25%"),
				},
				{	--4
					max_front =		60,		max_back =		60,
					accel_front =	10,		accel_back = 	8,
					turn = 			10,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase maneuverability by 25%"),
				},
				{	--5
					max_front =		60,		max_back =		60,
					accel_front =	10,		accel_back = 	8,
					turn = 			10,
					boost =			200,	strafe =		0,
					desc = _("upgrade-comms","add combat maneuver boost"),
				},
				{	--6
					max_front =		80,		max_back =		60,
					accel_front =	10,		accel_back = 	8,
					turn = 			10,
					boost =			200,	strafe =		0,
					desc = _("upgrade-comms","increase max impulse speed by 1/3"),
				},
				{	--7
					max_front =		80,		max_back =		60,
					accel_front =	10,		accel_back = 	8,
					turn = 			10,
					boost =			200,	strafe =		100,
					desc = _("upgrade-comms","add combat maneuver strafe"),
				},
				{	--8
					max_front =		80,		max_back =		60,
					accel_front =	10,		accel_back = 	10,
					turn = 			10,
					boost =			200,	strafe =		100,
					desc = _("upgrade-comms","increase rear impulse acceleration by 25%"),
				},
				{	--9
					max_front =		80,		max_back =		60,
					accel_front =	10,		accel_back = 	10,
					turn = 			10,
					boost =			300,	strafe =		150,
					desc = _("upgrade-comms","increase combat maneuver by 50%"),
				},
				{	--10
					max_front =		80,		max_back =		60,
					accel_front =	10,		accel_back = 	10,
					turn = 			12,
					boost =			300,	strafe =		150,
					desc = _("upgrade-comms","increase maneuverability by 20%"),
				},
				{	--11
					max_front =		80,		max_back =		60,
					accel_front =	15,		accel_back = 	10,
					turn = 			12,
					boost =			300,	strafe =		150,
					desc = _("upgrade-comms","increase forward impulse acceleration by 50%"),
				},
				["stock"] = {
					{max_front = 55, turn = 9, accel_front = 10, max_back = 55, accel_back = 10, boost = 250, strafe = 150},
				},
				["start"] = 5,
			},
			["ftl"] = {
				{	--1
					jump_long = 0, jump_short = 0, warp = 0,
				},
				{	--2
					jump_long = 25000, jump_short = 2500, warp = 0,
					desc = _("upgrade-comms","add 25u jump drive"),
				},
				{	--3
					jump_long = 30000, jump_short = 3000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 20%"),
				},
				{	--4
					jump_long = 40000, jump_short = 4000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 1/3"),
				},
				{	--5
					jump_long = 50000, jump_short = 5000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 25%"),
				},
				{	--6
					jump_long = 60000, jump_short = 5000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 20%"),
				},
				{	--7
					jump_long = 60000, jump_short = 5000, warp = 300,
					desc = _("upgrade-comms","add warp drive"),
				},
				{	--8
					jump_long = 60000, jump_short = 5000, warp = 400,
					desc = _("upgrade-comms","increase warp speed by 1/3"),
				},
				{	--9
					jump_long = 60000, jump_short = 5000, warp = 500,
					desc = _("upgrade-comms","increase warp speed by 25%"),
				},
				{	--10
					jump_long = 60000, jump_short = 5000, warp = 600,
					desc = _("upgrade-comms","increase warp speed by 20%"),
				},
				["stock"] = {
					{jump_long = 50000, jump_short = 5000, warp = 0},
				},
				["start"] = 2,
			},
			["sensors"] = {
				{	--1
					short = 4000, long = 15000, prox_scan = 0,
				},
				{	--2
					short = 4000, long = 20000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by 25%"),
				},
				{	--3
					short = 4000, long = 20000, prox_scan = 2,
					desc = _("upgrade-comms","add 2 unit automated proximity scanner"),
				},
				{	--4
					short = 4000, long = 22000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by 10%"),
				},
				{	--5
					short = 4500, long = 22000, prox_scan = 2,
					desc = _("upgrade-comms","increase short range sensors by 12.5%"),
				},
				{	--6
					short = 4500, long = 25000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by ~14%"),
				},
				{	--7
					short = 4500, long = 30000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by 20%"),
				},
				{	--8
					short = 5000, long = 30000, prox_scan = 2,
					desc = _("upgrade-comms","increase short range sensors by ~11%"),
				},
				{	--9
					short = 5000, long = 30000, prox_scan = 4,
					desc = _("upgrade-comms","double automated proximity scanner range"),
				},
				{	--10
					short = 5000, long = 35000, prox_scan = 4,
					desc = _("upgrade-comms","increase long range sensors by ~17%"),
				},
				{	--11
					short = 5000, long = 40000, prox_scan = 4,
					desc = _("upgrade-comms","increase long range sensors by ~14%"),
				},
				["stock"] = {
					{short = 5000, long = 30000}, prox_scan = 0,
				},
				["start"] = 4,
			},
			["providers"] = false,
			["score"] = 30,
		},
		["Player Cruiser"] = {	--10 + beam(8) + missile(12) + shield(8) + hull(6) + impulse(10) + ftl(10) + sensors(10) = 74
			["beam"] = {
				{	--1
					{idx = 0, arc = 60, dir = -15, rng = 800, cyc = 8, dmg = 6},
					{idx = 1, arc = 60, dir =  15, rng = 800, cyc = 8, dmg = 6},
				},
				{	--2
					{idx = 0, arc = 60, dir = -15, rng = 1000, cyc = 8, dmg = 6},
					{idx = 1, arc = 60, dir =  15, rng = 1000, cyc = 8, dmg = 6},
					["desc"] = _("upgrade-comms","increase range by 25%")
				},
				{	--3
					{idx = 0, arc = 75, dir = -15, rng = 1000, cyc = 8, dmg = 6},
					{idx = 1, arc = 75, dir =  15, rng = 1000, cyc = 8, dmg = 6},
					["desc"] = _("upgrade-comms","increase arc by 25%")
				},
				{	--4
					{idx = 0, arc = 75, dir = -15, rng = 1000, cyc = 8, dmg = 8},
					{idx = 1, arc = 75, dir =  15, rng = 1000, cyc = 8, dmg = 8},
					["desc"] = _("upgrade-comms","increase damage by 1/3")
				},
				{	--5
					{idx = 0, arc = 75, dir = -15, rng = 1000, cyc = 6, dmg = 8},
					{idx = 1, arc = 75, dir =  15, rng = 1000, cyc = 6, dmg = 8},
					["desc"] = _("upgrade-comms","decrease cycle time by 25%")
				},
				{	--6
					{idx = 0, arc = 90, dir = -15, rng = 1000, cyc = 6, dmg = 8},
					{idx = 1, arc = 90, dir =  15, rng = 1000, cyc = 6, dmg = 8},
					["desc"] = _("upgrade-comms","increase arc by 20%")
				},
				{	--7
					{idx = 0, arc = 90, dir = -15, rng = 1000, cyc = 6, dmg = 10},
					{idx = 1, arc = 90, dir =  15, rng = 1000, cyc = 6, dmg = 10},
					["desc"] = _("upgrade-comms","increase damage by 25%")
				},
				{	--8
					{idx = 0, arc = 90, dir = -15, rng = 1000, cyc = 4, dmg = 10},
					{idx = 1, arc = 90, dir =  15, rng = 1000, cyc = 4, dmg = 10},
					["desc"] = _("upgrade-comms","decrease cycle time by 1/3")
				},
				{	--9
					{idx = 0, arc = 90, dir = -15, rng = 1200, cyc = 4, dmg = 10},
					{idx = 1, arc = 90, dir =  15, rng = 1200, cyc = 4, dmg = 10},
					["desc"] = _("upgrade-comms","increase range by 20%")
				},
				["stock"] = {
					{idx = 0, arc =  90, dir = -15, rng = 1000, cyc = 6, dmg = 10},
					{idx = 1, arc =  90, dir =  15, rng = 1000, cyc = 6, dmg = 10},
				},
				["start"] = 2,
			},
			["missiles"] = {
				{tube = 1,	ord = 1},																				--1
				{tube = 1,	ord = 2, desc = _("upgrade-comms","double HVLI capacity")},								--2  
				{tube = 2,	ord = 3, desc = _("upgrade-comms","add mining tube")},									--3  
				{tube = 2,	ord = 4, desc = _("upgrade-comms","triple mine capacity")},								--4
				{tube = 3,	ord = 5, desc = _("upgrade-comms","add homing missiles")},								--5
				{tube = 4,	ord = 5, desc = _("upgrade-comms","increase tube size to medium")},						--6
				{tube = 5,	ord = 5, desc = _("upgrade-comms","increase load speed by 25%")},						--7
				{tube = 5,	ord = 6, desc = _("upgrade-comms","increase homing capacity by 50%")},					--8
				{tube = 6,	ord = 7, desc = _("upgrade-comms","add nuke and EMPs")},								--9
				{tube = 6,	ord = 8, desc = _("upgrade-comms","increase HVLI capacity by 25%")},					--10
				{tube = 7,	ord = 8, desc = _("upgrade-comms","decrease load speed by 1/3")},						--11
				{tube = 7,	ord = 9, desc = _("upgrade-comms","increase homing capacity by 1/3")},					--12
				{tube = 7,	ord = 10,desc = _("upgrade-comms","increase capacity: nuke:100%, EMP:100%, mine:1/3")},	--13
				["start"] = 6,
			},
			["tube"] = {
				{	--1
					{idx = 0, dir = -90, siz = "S", spd = 12, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  90, siz = "S", spd = 12, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--2
					{idx = 0, dir = -90, siz = "S", spd = 12, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  90, siz = "S", spd = 12, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 20, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--3
					{idx = 0, dir = -90, siz = "S", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  90, siz = "S", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 20, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--4
					{idx = 0, dir = -90, siz = "M", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  90, siz = "M", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 20, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--5
					{idx = 0, dir = -90, siz = "M", spd = 9,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  90, siz = "M", spd = 9,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 15, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--6
					{idx = 0, dir = -90, siz = "M", spd = 9,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 1, dir =  90, siz = "M", spd = 9,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 15, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--7
					{idx = 0, dir = -90, siz = "M", spd = 6,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 1, dir =  90, siz = "M", spd = 6,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				["stock"] = {
					{idx = 0, dir = -90, siz = "M", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = false},
					{idx = 1, dir =  90, siz = "M", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = false},
					{idx = 2, dir = 180, siz = "M", spd = 8,  hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
			},
			["ordnance"] = {
				{hom = 0,  nuk = 0, emp = 0, min = 0, hvl = 4},		--1
				{hom = 0,  nuk = 0, emp = 0, min = 0, hvl = 8},		--2
				{hom = 0,  nuk = 0, emp = 0, min = 1, hvl = 8},		--3
				{hom = 0,  nuk = 0, emp = 0, min = 3, hvl = 8},		--4		
				{hom = 4,  nuk = 0, emp = 0, min = 3, hvl = 8},		--5		
				{hom = 6,  nuk = 0, emp = 0, min = 3, hvl = 8},		--6		
				{hom = 6,  nuk = 1, emp = 2, min = 3, hvl = 8},		--7		
				{hom = 6,  nuk = 1, emp = 2, min = 3, hvl = 10},	--8	
				{hom = 8,  nuk = 1, emp = 2, min = 3, hvl = 10},	--9		
				{hom = 8,  nuk = 2, emp = 4, min = 4, hvl = 10},	--10		
				["stock"] = {hom = 4, nuk = 1, emp = 2, min = 0, hvl = 8},
			},
			["shield"] = {
				{	--1
					{idx = 0, max = 60},
				},
				{	--2
					{idx = 0, max = 75},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--3
					{idx = 0, max = 90},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--4
					{idx = 0, max = 80},
					{idx = 1, max = 80},
					["desc"] = _("upgrade-comms","add rear shield arc"),
				},
				{	--5
					{idx = 0, max = 100},
					{idx = 1, max = 80},
					["desc"] = _("upgrade-comms","increase front shield charge capacity by 25%"),
				},
				{	--6
					{idx = 0, max = 100},
					{idx = 1, max = 100},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by 25%"),
				},
				{	--7
					{idx = 0, max = 120},
					{idx = 1, max = 100},
					["desc"] = _("upgrade-comms","increase front shield charge capacity by 20%"),
				},
				{	--8
					{idx = 0, max = 132},
					{idx = 1, max = 110},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 10%"),
				},
				{	--9
					{idx = 0, max = 150},
					{idx = 1, max = 110},
					["desc"] = _("upgrade-comms","increase front shield charge capacity by ~14%"),
				},
				["stock"] = {
					{idx = 0, max = 80},
					{idx = 1, max = 80},
				},
				["start"] = 4,
			},	
			["hull"] = {
				{max = 100},															--1
				{max = 120, ["desc"] = _("upgrade-comms","increase hull max by 20%")},	--2
				{max = 150, ["desc"] = _("upgrade-comms","increase hull max by 25%")},	--3
				{max = 180, ["desc"] = _("upgrade-comms","increase hull max by 20%")},	--4
				{max = 210, ["desc"] = _("upgrade-comms","increase hull max by ~17%")},	--5
				{max = 250, ["desc"] = _("upgrade-comms","increase hull max by ~19%")},	--6
				{max = 275, ["desc"] = _("upgrade-comms","increase hull max by 10%")},	--7
				["stock"] = {max = 200},
				["start"] = 3,
			},
			["impulse"] = {
				{	--1
					max_front =		70,		max_back =		70,
					accel_front =	12,		accel_back = 	12,
					turn = 			8,
					boost =			0,		strafe =		0,
				},
				{	--2
					max_front =		80,		max_back =		80,
					accel_front =	12,		accel_back = 	12,
					turn = 			8,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase max impulse speed by ~14%"),
				},
				{	--3
					max_front =		80,		max_back =		80,
					accel_front =	15,		accel_back = 	12,
					turn = 			8,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase forward acceleration by 25%"),
				},
				{	--4
					max_front =		80,		max_back =		80,
					accel_front =	15,		accel_back = 	12,
					turn = 			10,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase maneuverability by 25%"),
				},
				{	--5
					max_front =		80,		max_back =		80,
					accel_front =	15,		accel_back = 	12,
					turn = 			10,
					boost =			300,	strafe =		0,
					desc = _("upgrade-comms","add combat maneuver boost"),
				},
				{	--6
					max_front =		90,		max_back =		90,
					accel_front =	15,		accel_back = 	12,
					turn = 			10,
					boost =			300,	strafe =		0,
					desc = _("upgrade-comms","increase max impulse speed by 12.5%"),
				},
				{	--7
					max_front =		90,		max_back =		90,
					accel_front =	15,		accel_back = 	12,
					turn = 			10,
					boost =			300,	strafe =		200,
					desc = _("upgrade-comms","add combat maneuver strafe"),
				},
				{	--8
					max_front =		90,		max_back =		90,
					accel_front =	20,		accel_back = 	16,
					turn = 			10,
					boost =			300,	strafe =		200,
					desc = _("upgrade-comms","increase impulse acceleration by 1/3"),
				},
				{	--9
					max_front =		90,		max_back =		90,
					accel_front =	20,		accel_back = 	16,
					turn = 			10,
					boost =			450,	strafe =		300,
					desc = _("upgrade-comms","increase combat maneuver by 50%"),
				},
				{	--10
					max_front =		90,		max_back =		90,
					accel_front =	20,		accel_back = 	16,
					turn = 			12,
					boost =			450,	strafe =		300,
					desc = _("upgrade-comms","increase maneuverability by 20%"),
				},
				{	--11
					max_front =		100,	max_back =		90,
					accel_front =	20,		accel_back = 	16,
					turn = 			12,
					boost =			450,	strafe =		300,
					desc = _("upgrade-comms","increase forward max impulse speed by ~11%"),
				},
				["stock"] = {
					{max_front = 90, turn = 10, accel_front = 20, max_back = 90, accel_back = 20, boost = 400, strafe = 250},
				},
				["start"] = 5,
			},
			["ftl"] = {
				{	--1
					jump_long = 0, jump_short = 0, warp = 0,
				},
				{	--2
					jump_long = 20000, jump_short = 2000, warp = 0,
					desc = _("upgrade-comms","add 20k jump drive"),
				},
				{	--3
					jump_long = 25000, jump_short = 2500, warp = 0,
					desc = _("upgrade-comms","increase jump range by 25%"),
				},
				{	--4
					jump_long = 30000, jump_short = 3000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 20%"),
				},
				{	--5
					jump_long = 40000, jump_short = 4000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 1/3"),
				},
				{	--6
					jump_long = 50000, jump_short = 5000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 25%"),
				},
				{	--7
					jump_long = 55000, jump_short = 5500, warp = 0,
					desc = _("upgrade-comms","increase jump range by 10%"),
				},
				{	--8
					jump_long = 55000, jump_short = 5500, warp = 400,
					desc = _("upgrade-comms","add warp drive"),
				},
				{	--9
					jump_long = 55000, jump_short = 5500, warp = 500,
					desc = _("upgrade-comms","increase warp speed by 25%"),
				},
				{	--10
					jump_long = 60000, jump_short = 6000, warp = 500,
					desc = _("upgrade-comms","increase jump range by ~9%"),
				},
				{	--11
					jump_long = 60000, jump_short = 6000, warp = 600,
					desc = _("upgrade-comms","increase warp speed by 20%"),
				},
				["stock"] = {
					{jump_long = 50000, jump_short = 5000, warp = 0},
				},
				["start"] = 2,
			},
			["sensors"] = {
				{	--1
					short = 4000, long = 15000, prox_scan = 0,
				},
				{	--2
					short = 4000, long = 20000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by 25%"),
				},
				{	--2
					short = 4000, long = 20000, prox_scan = 2,
					desc = _("upgrade-comms","add 2 unit automated proximity scanner"),
				},
				{	--4
					short = 4000, long = 22000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by 10%"),
				},
				{	--5
					short = 4500, long = 22000, prox_scan = 2,
					desc = _("upgrade-comms","increase short range sensors by 12.5%"),
				},
				{	--6
					short = 4500, long = 25000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by ~14%"),
				},
				{	--7
					short = 4500, long = 30000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by 20%"),
				},
				{	--8
					short = 5000, long = 30000, prox_scan = 2,
					desc = _("upgrade-comms","increase short range sensors by ~11%"),
				},
				{	--9
					short = 5000, long = 35000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by ~17%"),
				},
				{	--10
					short = 5000, long = 40000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by ~14%"),
				},
				{	--11
					short = 5000, long = 40000, prox_scan = 4,
					desc = _("upgrade-comms","double automated proximity scanner range"),
				},
				["stock"] = {
					{short = 5000, long = 30000}, prox_scan = 0,
				},
				["start"] = 4,
			},
			["providers"] = false,
			["score"] = 29,
		},
		["Player Missile Cr."] = {	--10 + beam(9) + missile(17) + shield(8) + hull(6) + impulse(10) + ftl(9) + sensors(10) = 79
			["beam"] = {
				{	--1
					{idx = -1},
				},
				{	--2
					{idx = 0, arc = 30, dir = 180, rng = 800, cyc = 8, dmg = 4},
					["desc"] = _("upgrade-comms","add beam")
				},
				{	--3
					{idx = 0, arc = 30, dir = 180, rng = 800, cyc = 8, dmg = 4},
					{idx = 1, arc = 30, dir =   0, rng = 800, cyc = 8, dmg = 4},
					["desc"] = _("upgrade-comms","add beam")
				},
				{	--4
					{idx = 0, arc = 30, dir = 180, rng = 800, cyc = 8, dmg = 4},
					{idx = 1, arc = 30, dir =   0, rng = 800, cyc = 8, dmg = 4},
					{idx = 2, arc = 30, dir = -90, rng = 800, cyc = 8, dmg = 4},
					{idx = 3, arc = 30, dir =  90, rng = 800, cyc = 8, dmg = 4},
					["desc"] = _("upgrade-comms","add beams")
				},
				{	--5
					{idx = 0, arc = 45, dir = 180, rng = 800, cyc = 8, dmg = 4},
					{idx = 1, arc = 45, dir =   0, rng = 800, cyc = 8, dmg = 4},
					{idx = 2, arc = 45, dir = -90, rng = 800, cyc = 8, dmg = 4},
					{idx = 3, arc = 45, dir =  90, rng = 800, cyc = 8, dmg = 4},
					["desc"] = _("upgrade-comms","increase arc width by 50%")
				},
				{	--6
					{idx = 0, arc = 45, dir = 180, rng = 900, cyc = 8, dmg = 4},
					{idx = 1, arc = 45, dir =   0, rng = 900, cyc = 8, dmg = 4},
					{idx = 2, arc = 45, dir = -90, rng = 900, cyc = 8, dmg = 4},
					{idx = 3, arc = 45, dir =  90, rng = 900, cyc = 8, dmg = 4},
					["desc"] = _("upgrade-comms","increase range by 12.5%"),
				},
				{	--7
					{idx = 0, arc = 45, dir = 180, rng = 900, cyc = 7, dmg = 4},
					{idx = 1, arc = 45, dir =   0, rng = 900, cyc = 7, dmg = 4},
					{idx = 2, arc = 45, dir = -90, rng = 900, cyc = 7, dmg = 4},
					{idx = 3, arc = 45, dir =  90, rng = 900, cyc = 7, dmg = 4},
					["desc"] = _("upgrade-comms","decrease cycle time by 12.5%"),
				},
				{	--8
					{idx = 0, arc = 45, dir = 180, rng = 900, cyc = 7, dmg = 5},
					{idx = 1, arc = 45, dir =   0, rng = 900, cyc = 7, dmg = 5},
					{idx = 2, arc = 45, dir = -90, rng = 900, cyc = 7, dmg = 5},
					{idx = 3, arc = 45, dir =  90, rng = 900, cyc = 7, dmg = 5},
					["desc"] = _("upgrade-comms","increase damage by 25%"),
				},
				{	--9
					{idx = 0, arc = 60, dir = 180, rng = 900, cyc = 7, dmg = 5},
					{idx = 1, arc = 60, dir =   0, rng = 900, cyc = 7, dmg = 5},
					{idx = 2, arc = 60, dir = -90, rng = 900, cyc = 7, dmg = 5},
					{idx = 3, arc = 60, dir =  90, rng = 900, cyc = 7, dmg = 5},
					["desc"] = _("upgrade-comms","increase arc width by 1/3"),
				},
				{	--10
					{idx = 0, arc = 60, dir = 180, rng = 1000, cyc = 7, dmg = 5},
					{idx = 1, arc = 60, dir =   0, rng = 1000, cyc = 7, dmg = 5},
					{idx = 2, arc = 60, dir = -90, rng = 1000, cyc = 7, dmg = 5},
					{idx = 3, arc = 60, dir =  90, rng = 1000, cyc = 7, dmg = 5},
					["desc"] = _("upgrade-comms","increase range by ~11%"),
				},
				["stock"] = {
					{idx = -1},
				},
				["start"] = 4,
			},
			["missiles"] = {
				{tube = 1,	ord = 1},																							--1
				{tube = 2,	ord = 2, desc = _("upgrade-comms","mining tube")},													--2  
				{tube = 2,	ord = 3, desc = _("upgrade-comms","increase homing and HVLI capacity by 25%")},						--3  
				{tube = 3,	ord = 3, desc = _("upgrade-comms","add broadside tubes")},											--4
				{tube = 4,	ord = 3, desc = _("upgrade-comms","switch to medium sized tubes")},									--5
				{tube = 5,	ord = 4, desc = _("upgrade-comms","add nukes and EMPs to front tubes")},							--6
				{tube = 5,	ord = 5, desc = _("upgrade-comms","increase homing capacity by 60%")},								--7
				{tube = 6,	ord = 5, desc = _("upgrade-comms","add more broadside tubes")},										--8
				{tube = 6,	ord = 6, desc = _("upgrade-comms","triple mine capacity")},											--9
				{tube = 7,	ord = 6, desc = _("upgrade-comms","make second broadside tubes large")},							--10
				{tube = 7,	ord = 7, desc = _("upgrade-comms","increase homing capacity by 25%")},								--11
				{tube = 7,	ord = 8, desc = _("upgrade-comms","increase capacity: nuke: 100%, EMP: 50%, mine: 100%")},			--12
				{tube = 7,	ord = 9, desc = _("upgrade-comms","increase homing capacity by 50%")},								--13
				{tube = 8,	ord = 9, desc = _("upgrade-comms","increase front and broadside tubes' load time by 20%")},			--14
				{tube = 9,	ord = 9, desc = _("upgrade-comms","add two more mining tubes")},									--15
				{tube = 9,	ord = 10,desc = _("upgrade-comms","increase capacity: nuke:100%, EMP:2/3, mine:100%, HVLI:20%")},	--16
				{tube = 10,	ord = 10,desc = _("upgrade-comms","increase load speed of medium tubes ~16%")},						--17
				{tube = 10,	ord = 11,desc = _("upgrade-comms","increase capacity by ~14% on average")},							--18
				["start"] = 5,
			},	
			["tube"] = {
				{	--1
					{idx = 0, dir =   0, siz = "S", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   0, siz = "S", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
				},
				{	--2
					{idx = 0, dir =   0, siz = "S", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   0, siz = "S", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--3
					{idx = 0, dir =   0, siz = "S", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   0, siz = "S", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = -90, siz = "S", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 3, dir =  90, siz = "S", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 4, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--4
					{idx = 0, dir =   0, siz = "M", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   0, siz = "M", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = -90, siz = "M", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 4, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--5
					{idx = 0, dir =   0, siz = "M", spd = 10, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 1, dir =   0, siz = "M", spd = 10, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 2, dir = -90, siz = "M", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 4, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--6
					{idx = 0, dir =   0, siz = "M", spd = 10, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 1, dir =   0, siz = "M", spd = 10, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 2, dir = -90, siz = "M", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 4, dir = -90, siz = "M", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 5, dir =  90, siz = "M", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 6, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--7
					{idx = 0, dir =   0, siz = "M", spd = 10, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 1, dir =   0, siz = "M", spd = 10, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 2, dir = -90, siz = "M", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 4, dir = -90, siz = "L", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 5, dir =  90, siz = "L", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 6, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--8
					{idx = 0, dir =   0, siz = "M", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 1, dir =   0, siz = "M", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 2, dir = -90, siz = "M", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 4, dir = -90, siz = "L", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 5, dir =  90, siz = "L", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 6, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--9
					{idx = 0, dir =   0, siz = "M", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 1, dir =   0, siz = "M", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 2, dir = -90, siz = "M", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 4, dir = -90, siz = "L", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 5, dir =  90, siz = "L", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 6, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 7, dir = 170, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 8, dir = 190, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--10
					{idx = 0, dir =   0, siz = "M", spd = 7,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 1, dir =   0, siz = "M", spd = 7,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 2, dir = -90, siz = "M", spd = 7,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 7,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 4, dir = -90, siz = "L", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 5, dir =  90, siz = "L", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 6, dir = 180, siz = "M", spd = 8,  hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 7, dir = 170, siz = "M", spd = 8,  hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 8, dir = 190, siz = "M", spd = 8,  hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				["stock"] = {
					{idx = 0, dir =   0, siz = "M", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = false},
					{idx = 1, dir =   0, siz = "M", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = false},
					{idx = 2, dir =  90, siz = "M", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 3, dir =  90, siz = "M", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 4, dir = -90, siz = "M", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 5, dir = -90, siz = "M", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 7, dir = 180, siz = "M", spd = 8,  hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
			},
			["ordnance"] = {
				{hom = 8,  nuk = 0, emp = 0, min = 0, hvl = 8},		--1
				{hom = 8,  nuk = 0, emp = 0, min = 1, hvl = 8},		--2
				{hom = 10, nuk = 0, emp = 0, min = 1, hvl = 10},	--3
				{hom = 10, nuk = 2, emp = 4, min = 1, hvl = 10},	--4
				{hom = 16, nuk = 2, emp = 4, min = 1, hvl = 10},	--5
				{hom = 16, nuk = 2, emp = 4, min = 3, hvl = 10},	--6
				{hom = 20, nuk = 2, emp = 4, min = 3, hvl = 10},	--7
				{hom = 20, nuk = 4, emp = 6, min = 6, hvl = 10},	--8
				{hom = 30, nuk = 4, emp = 6, min = 6, hvl = 10},	--9
				{hom = 30, nuk = 8, emp = 10,min = 12,hvl = 12},	--10
				{hom = 36, nuk = 10,emp = 16,min = 18,hvl = 16},	--11
				["stock"] = {hom = 30, nuk = 8, emp = 10, min = 12, hvl = 0},
			},
			["shield"] = {
				{	--1
					{idx = 0, max = 80},
				},
				{	--2
					{idx = 0, max = 100},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--3
					{idx = 0, max = 120},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--4
					{idx = 0, max = 90},
					{idx = 1, max = 60},
					["desc"] = _("upgrade-comms","add rear shield arc"),
				},
				{	--5
					{idx = 0, max = 100},
					{idx = 1, max = 60},
					["desc"] = _("upgrade-comms","increase front shield charge capacity by ~11%"),
				},
				{	--6
					{idx = 0, max = 100},
					{idx = 1, max = 70},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by ~17%"),
				},
				{	--7
					{idx = 0, max = 110},
					{idx = 1, max = 70},
					["desc"] = _("upgrade-comms","increase front shield charge capacity by 10%"),
				},
				{	--8
					{idx = 0, max = 121},
					{idx = 1, max = 70},
					["desc"] = _("upgrade-comms","increase front shield charge capacity by 10%"),
				},
				{	--9
					{idx = 0, max = 121},
					{idx = 1, max = 80},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by ~14%"),
				},
				["stock"] = {
					{idx = 0, max = 110},
					{idx = 1, max = 70},
				},
				["start"] = 4,
			},	
			["hull"] = {
				{max = 100},															--1
				{max = 120, ["desc"] = _("upgrade-comms","increase hull max by 20%")},	--2
				{max = 150, ["desc"] = _("upgrade-comms","increase hull max by 25%")},	--3
				{max = 180, ["desc"] = _("upgrade-comms","increase hull max by 20%")},	--4
				{max = 210, ["desc"] = _("upgrade-comms","increase hull max by ~17%")},	--5
				{max = 250, ["desc"] = _("upgrade-comms","increase hull max by ~19%")},	--6
				{max = 275, ["desc"] = _("upgrade-comms","increase hull max by 10%")},	--7
				["stock"] = {max = 200},
				["start"] = 3,
			},
			["impulse"] = {
				{	--1
					max_front =		50,		max_back =		50,
					accel_front =	12,		accel_back = 	12,
					turn = 			7,
					boost =			0,		strafe =		0,
				},
				{	--2
					max_front =		60,		max_back =		60,
					accel_front =	12,		accel_back = 	12,
					turn = 			7,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase max impulse speed by 20%"),
				},
				{	--3
					max_front =		60,		max_back =		60,
					accel_front =	15,		accel_back = 	12,
					turn = 			7,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase forward acceleration by 25%"),
				},
				{	--4
					max_front =		60,		max_back =		60,
					accel_front =	15,		accel_back = 	12,
					turn = 			8,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase maneuverability by ~14%"),
				},
				{	--5
					max_front =		60,		max_back =		60,
					accel_front =	15,		accel_back = 	12,
					turn = 			8,
					boost =			450,	strafe =		0,
					desc = _("upgrade-comms","add combat maneuver boost"),
				},
				{	--6
					max_front =		70,		max_back =		70,
					accel_front =	15,		accel_back = 	12,
					turn = 			8,
					boost =			450,	strafe =		0,
					desc = _("upgrade-comms","increase max impulse speed by ~17%"),
				},
				{	--7
					max_front =		70,		max_back =		70,
					accel_front =	15,		accel_back = 	12,
					turn = 			8,
					boost =			450,	strafe =		150,
					desc = _("upgrade-comms","add combat maneuver strafe"),
				},
				{	--8
					max_front =		70,		max_back =		70,
					accel_front =	20,		accel_back = 	12,
					turn = 			8,
					boost =			450,	strafe =		150,
					desc = _("upgrade-comms","increase impulse acceleration by 1/3"),
				},
				{	--9
					max_front =		70,		max_back =		70,
					accel_front =	20,		accel_back = 	12,
					turn = 			8,
					boost =			540,	strafe =		180,
					desc = _("upgrade-comms","increase combat maneuver by 20%"),
				},
				{	--10
					max_front =		70,		max_back =		70,
					accel_front =	20,		accel_back = 	12,
					turn = 			10,
					boost =			540,	strafe =		180,
					desc = _("upgrade-comms","increase maneuverability by 25%"),
				},
				{	--11
					max_front =		80,		max_back =		70,
					accel_front =	20,		accel_back = 	12,
					turn = 			10,
					boost =			540,	strafe =		180,
					desc = _("upgrade-comms","increase forward max impulse speed by ~14%"),
				},
				["stock"] = {
					{max_front = 60, turn = 8, accel_front = 15, max_back = 60, accel_back = 15, boost = 450, strafe = 150},
				},
				["start"] = 5,
			},
			["ftl"] = {
				{	--1
					jump_long = 0, jump_short = 0, warp = 0,
				},
				{	--2
					jump_long = 0, jump_short = 0, warp = 400,
					desc = _("upgrade-comms","add warp drive"),
				},
				{	--3
					jump_long = 0, jump_short = 0, warp = 500,
					desc = _("upgrade-comms","increase warp speed by 25%"),
				},
				{	--4
					jump_long = 0, jump_short = 0, warp = 600,
					desc = _("upgrade-comms","increase warp speed by 20%"),
				},
				{	--5
					jump_long = 0, jump_short = 0, warp = 700,
					desc = _("upgrade-comms","increase warp speed by ~17%"),
				},
				{	--6
					jump_long = 0, jump_short = 0, warp = 750,
					desc = _("upgrade-comms","increase warp speed by ~7%"),
				},
				{	--7
					jump_long = 0, jump_short = 0, warp = 800,
					desc = _("upgrade-comms","increase warp speed by ~7%"),
				},
				{	--8
					jump_long = 20000, jump_short = 2000, warp = 800,
					desc = _("upgrade-comms","add jump drive"),
				},
				{	--9
					jump_long = 20000, jump_short = 2000, warp = 900,
					desc = _("upgrade-comms","increase warp speed by 12.5%"),
				},
				{	--10
					jump_long = 25000, jump_short = 2500, warp = 900,
					desc = _("upgrade-comms","increase jump range by 20%"),
				},
				["stock"] = {
					{jump_long = 0, jump_short = 0, warp = 750},
				},
				["start"] = 2,
			},
			["sensors"] = {
				{	--1
					short = 4500, long = 15000, prox_scan = 0,
				},
				{	--2
					short = 4500, long = 20000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by 25%"),
				},
				{	--3
					short = 4500, long = 20000, prox_scan = 1,
					desc = _("upgrade-comms","add 1 unit automated proximity scanner"),
				},
				{	--4
					short = 4500, long = 25000, prox_scan = 1,
					desc = _("upgrade-comms","increase long range sensors by 20%"),
				},
				{	--5
					short = 5000, long = 25000, prox_scan = 1,
					desc = _("upgrade-comms","increase short range sensors by ~11%"),
				},
				{	--6
					short = 5000, long = 25000, prox_scan = 2,
					desc = _("upgrade-comms","increase automated proximity scan range by 100%"),
				},
				{	--7
					short = 5000, long = 30000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by 20%"),
				},
				{	--8
					short = 5000, long = 30000, prox_scan = 3,
					desc = _("upgrade-comms","increase automated proximity scan range by 50%"),
				},
				{	--9
					short = 5000, long = 35000, prox_scan = 3,
					desc = _("upgrade-comms","increase long range sensors by ~17%"),
				},
				{	--10
					short = 5000, long = 35000, prox_scan = 4,
					desc = _("upgrade-comms","increase automated proximity scan range by 1/3"),
				},
				{	--11
					short = 5000, long = 40000, prox_scan = 4,
					desc = _("upgrade-comms","increase long range sensors by ~14%"),
				},
				["stock"] = {
					{short = 5000, long = 30000}, prox_scan = 0,
				},
				["start"] = 4,
			},
			["providers"] = false,
			["score"] = 30,
		},
		["Player Fighter"] = {	--5 + beam(11) + missile(10) + shield(7) + hull(5) + impulse(8) + ftl(9) + sensors(7) = 62
			["beam"] = {
				{	--1
					{idx = 0, arc = 40, dir =   0, rng = 800, cyc = 8, dmg = 6},
				},
				{	--2
					{idx = 0, arc = 40, dir =   0, rng = 1000, cyc = 8, dmg = 6},
					["desc"] = _("upgrade-comms","increase range by 25%")
				},
				{	--3
					{idx = 0, arc = 40, dir =   0, rng = 1000, cyc = 7, dmg = 6},
					["desc"] = _("upgrade-comms","reduce cycle time by 12.5%")
				},
				{	--4
					{idx = 0, arc = 40, dir =   0, rng = 1000, cyc = 7, dmg = 6},
					{idx = 1, arc = 40, dir =   0, rng =  800, cyc = 7, dmg = 6},
					["desc"] = _("upgrade-comms","add beam")
				},
				{	--5
					{idx = 0, arc = 60, dir =   0, rng = 1000, cyc = 7, dmg = 6},
					{idx = 1, arc = 40, dir =   0, rng =  800, cyc = 7, dmg = 6},
					["desc"] = _("upgrade-comms","increase arc width of long beam by 50%")
				},
				{	--6
					{idx = 0, arc = 60, dir =   0, rng = 1000, cyc = 7, dmg = 7},
					{idx = 1, arc = 40, dir =   0, rng =  800, cyc = 7, dmg = 7},
					["desc"] = _("upgrade-comms","increase damage by ~17%"),
				},
				{	--7
					{idx = 0, arc = 60, dir =   0, rng = 1000, cyc = 6, dmg = 7},
					{idx = 1, arc = 40, dir =   0, rng =  800, cyc = 6, dmg = 7},
					["desc"] = _("upgrade-comms","decrease cycle time by ~14%"),
				},
				{	--8
					{idx = 0, arc = 60, dir =   0, rng = 1000, cyc = 6, dmg = 7},
					{idx = 1, arc = 40, dir =   0, rng =  800, cyc = 6, dmg = 8},
					["desc"] = _("upgrade-comms","increase damage of short beam by ~14%"),
				},
				{	--9
					{idx = 0, arc = 90, dir =   0, rng = 1000, cyc = 6, dmg = 7},
					{idx = 1, arc = 60, dir =   0, rng =  800, cyc = 6, dmg = 8},
					["desc"] = _("upgrade-comms","increase arc width by 50%"),
				},
				{	--10
					{idx = 0, arc = 90, dir =   0, rng = 1000, cyc = 6, dmg = 8},
					{idx = 1, arc = 60, dir =   0, rng =  800, cyc = 6, dmg = 10},
					["desc"] = _("upgrade-comms","increase damage by ~18%"),
				},
				{	--11
					{idx = 0, arc = 90, dir =   0, rng = 1000, cyc = 5, dmg = 8},
					{idx = 1, arc = 60, dir =   0, rng =  800, cyc = 5, dmg = 10},
					["desc"] = _("upgrade-comms","reduce cycle time by ~17%"),
				},
				{	--12
					{idx = 0, arc = 90, dir =   0, rng = 1100, cyc = 5, dmg = 8},
					{idx = 1, arc = 60, dir =   0, rng =  880, cyc = 5, dmg = 10},
					["desc"] = _("upgrade-comms","increase range by 10%"),
				},
				["stock"] = {
					{idx = 0, arc = 40, dir = -10, rng = 1000, cyc = 6, dmg = 8},
					{idx = 1, arc = 40, dir =  10, rng = 1000, cyc = 6, dmg = 8},
				},
				["start"] = 4,
			},
			["missiles"] = {
				{tube = 1,	ord = 1},																						--1
				{tube = 2,	ord = 1, desc = _("upgrade-comms","reduce tube load speed by 1/3")},							--2  
				{tube = 2,	ord = 2, desc = _("upgrade-comms","double HVLI capacity")},										--3  
				{tube = 3,	ord = 2, desc = _("upgrade-comms","make tube medium sized")},									--4
				{tube = 4,	ord = 2, desc = _("upgrade-comms","add a small tube")},											--5
				{tube = 5,	ord = 3, desc = _("upgrade-comms","add homing capability to small tube")},						--6
				{tube = 5,	ord = 4, desc = _("upgrade-comms","increase HVLI capacity by 25%")},							--7
				{tube = 5,	ord = 5, desc = _("upgrade-comms","increase homing capacity by 50%")},							--8
				{tube = 6,	ord = 6, desc = _("upgrade-comms","add a mining tube")},										--9
				{tube = 6,	ord = 7, desc = _("upgrade-comms","increase capacity: homing: 1/3, mining: 100%, HVLI: 20%")},	--10
				{tube = 7,	ord = 7, desc = _("upgrade-comms","reduce mine tube load time by 1/3")},						--11
				["start"] = 4,
			},
			["tube"] = {
				{	--1
					{idx = 0, dir =   0, siz = "S", spd = 15, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--2
					{idx = 0, dir =   0, siz = "S", spd = 10, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--3
					{idx = 0, dir =   0, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--4
					{idx = 0, dir =   0, siz = "S", spd = 8,  hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   0, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--5
					{idx = 0, dir =   0, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   0, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--6
					{idx = 0, dir =   0, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   0, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 20, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--7
					{idx = 0, dir =   0, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   0, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 15, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				["stock"] = {
					{idx = 0, dir =   0, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
			},
			["ordnance"] = {
				{hom = 0,  nuk = 0, emp = 0, min = 0, hvl = 2},		--1
				{hom = 0,  nuk = 0, emp = 0, min = 0, hvl = 4},		--2
				{hom = 2,  nuk = 0, emp = 0, min = 0, hvl = 4},		--3
				{hom = 2,  nuk = 0, emp = 0, min = 0, hvl = 5},		--4		
				{hom = 3,  nuk = 0, emp = 0, min = 0, hvl = 5},		--5		
				{hom = 3,  nuk = 0, emp = 0, min = 1, hvl = 5},		--6		
				{hom = 4,  nuk = 0, emp = 0, min = 2, hvl = 6},		--7		
				["stock"] = {hom = 0, nuk = 0, emp = 0, min = 0, hvl = 4},
			},
			["shield"] = {
				{	--1
					{idx = 0, max = 30},
				},
				{	--2
					{idx = 0, max = 40},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 1/3"),
				},
				{	--3
					{idx = 0, max = 50},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--4
					{idx = 0, max = 60},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--5
					{idx = 0, max = 40},
					{idx = 1, max = 40},
					["desc"] = _("upgrade-comms","add rear arc"),
				},
				{	--6
					{idx = 0, max = 50},
					{idx = 1, max = 50},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--7
					{idx = 0, max = 60},
					{idx = 1, max = 60},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--8
					{idx = 0, max = 66},
					{idx = 1, max = 66},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 10%"),
				},
				["stock"] = {
					{idx = 0, max = 40},
				},
				["start"] = 3,
			},
			["hull"] = {
				{max =  40},															--1
				{max =  50, ["desc"] = _("upgrade-comms","increase hull max by 25%")},	--2
				{max =  60, ["desc"] = _("upgrade-comms","increase hull max by 20%")},	--3
				{max =  80, ["desc"] = _("upgrade-comms","increase hull max by 1/3")},	--4
				{max = 100, ["desc"] = _("upgrade-comms","increase hull max by 25%")},	--5
				{max = 120, ["desc"] = _("upgrade-comms","increase hull max by 20%")},	--6
				["stock"] = {max = 60},
				["start"] = 3,
			},
			["impulse"] = {
				{	--1
					max_front =		90,		max_back =		90,
					accel_front =	36,		accel_back = 	30,
					turn = 			16,
					boost =			0,		strafe =		0,
				},
				{	--2
					max_front =		100,	max_back =		100,
					accel_front =	36,		accel_back = 	30,
					turn = 			16,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase max impulse speed by ~11%"),
				},
				{	--3
					max_front =		100,	max_back =		100,
					accel_front =	45,		accel_back = 	30,
					turn = 			16,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase forward acceleration by 25%"),
				},
				{	--4
					max_front =		100,	max_back =		100,
					accel_front =	45,		accel_back = 	30,
					turn = 			20,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase maneuverability by 25%"),
				},
				{	--5
					max_front =		100,	max_back =		100,
					accel_front =	45,		accel_back = 	30,
					turn = 			20,
					boost =			600,	strafe =		0,
					desc = _("upgrade-comms","add combat maneuver boost"),
				},
				{	--6
					max_front =		120,	max_back =		120,
					accel_front =	45,		accel_back = 	30,
					turn = 			20,
					boost =			600,	strafe =		0,
					desc = _("upgrade-comms","increase max impulse speed by 20%"),
				},
				{	--7
					max_front =		120,	max_back =		120,
					accel_front =	45,		accel_back = 	30,
					turn = 			20,
					boost =			700,	strafe =		0,
					desc = _("upgrade-comms","increase combat maneuver by ~17%"),
				},
				{	--8
					max_front =		120,	max_back =		120,
					accel_front =	45,		accel_back = 	30,
					turn = 			25,
					boost =			700,	strafe =		0,
					desc = _("upgrade-comms","increase maneuverability by 25%"),
				},
				{	--9
					max_front =		120,	max_back =		120,
					accel_front =	45,		accel_back = 	36,
					turn = 			25,
					boost =			700,	strafe =		0,
					desc = _("upgrade-comms","increase reverse impulse acceleration by 20%"),
				},
				["stock"] = {
					{max_front = 110, turn = 20, accel_front = 40, max_back = 110, accel_back = 40, boost = 600, strafe = 0},
				},
				["start"] = 4,
			},
			["ftl"] = {
				{	--1
					jump_long = 0, jump_short = 0, warp = 0,
				},
				{	--2
					jump_long = 0, jump_short = 0, warp = 400,
					desc = _("upgrade-comms","add warp drive"),
				},
				{	--3
					jump_long = 20000, jump_short = 2000, warp = 400,
					desc = _("upgrade-comms","add 20k jump drive"),
				},
				{	--4
					jump_long = 20000, jump_short = 2000, warp = 500,
					desc = _("upgrade-comms","increase warp speed by 25%"),
				},
				{	--5
					jump_long = 25000, jump_short = 2500, warp = 500,
					desc = _("upgrade-comms","increase jump range by 25%"),
				},
				{	--6
					jump_long = 25000, jump_short = 2500, warp = 600,
					desc = _("upgrade-comms","increase warp speed by 20%"),
				},
				{	--7
					jump_long = 30000, jump_short = 3000, warp = 600,
					desc = _("upgrade-comms","increase jump range by 20%"),
				},
				{	--8
					jump_long = 30000, jump_short = 3000, warp = 700,
					desc = _("upgrade-comms","increase warp speed by ~17%"),
				},
				{	--9
					jump_long = 35000, jump_short = 3500, warp = 700,
					desc = _("upgrade-comms","increase jump range by ~17%"),
				},
				{	--10
					jump_long = 35000, jump_short = 3500, warp = 800,
					desc = _("upgrade-comms","increase warp speed by ~14%"),
				},
				["stock"] = {
					{jump_long = 0, jump_short = 0, warp = 0},
				},
				["start"] = 2,
			},
			["sensors"] = {
				{	--1
					short = 4000, long = 15000, prox_scan = 0,
				},
				{	--2
					short = 4000, long = 20000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by 25%"),
				},
				{	--3
					short = 4000, long = 20000, prox_scan = 2,
					desc = _("upgrade-comms","add 2 unit automated proximity scanner"),
				},
				{	--4
					short = 4000, long = 25000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by 20%"),
				},
				{	--5
					short = 5000, long = 25000, prox_scan = 2,
					desc = _("upgrade-comms","increase short range sensors by 25%"),
				},
				{	--6
					short = 5000, long = 30000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by 20%"),
				},
				{	--7
					short = 5000, long = 35000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by ~17%"),
				},
				{	--8
					short = 5000, long = 35000, prox_scan = 4,
					desc = _("upgrade-comms","double automated proximity scanner range"),
				},
				["stock"] = {
					{short = 5000, long = 30000}, prox_scan = 0,
				},
				["start"] = 4,
			},
			["providers"] = false,
			["score"] = 22,
		},
		["Nautilus"] = {	--8 + beam(11) + missile(13) + shield(7) + hull(5) + impulse(9) + ftl(10) + sensors(9) = 72
			["beam"] = {
				{	--1
					{idx = 0, arc = 10, dir =   0, rng =  800, cyc = 8, dmg = 5, tar =  60, tdr = 0, trt = 2},
				},
				{	--2
					{idx = 0, arc = 10, dir =   0, rng = 1000, cyc = 8, dmg = 5, tar =  60, tdr = 0, trt = 2},
					["desc"] = _("upgrade-comms","increase range by 25%")
				},
				{	--3
					{idx = 0, arc = 10, dir =   0, rng = 1000, cyc = 7, dmg = 5, tar =  60, tdr = 0, trt = 2},
					["desc"] = _("upgrade-comms","reduce cycle time by 12.5%")
				},
				{	--4
					{idx = 0, arc = 10, dir =  35, rng = 1000, cyc = 7, dmg = 5, tar =  60, tdr =  35, trt = 2},
					{idx = 1, arc = 10, dir = -35, rng = 1000, cyc = 7, dmg = 5, tar =  60, tdr = -35, trt = 2},
					["desc"] = _("upgrade-comms","add beam")
				},
				{	--5
					{idx = 0, arc = 10, dir =  35, rng = 1000, cyc = 7, dmg = 5, tar =  90, tdr =  35, trt = 2},
					{idx = 1, arc = 10, dir = -35, rng = 1000, cyc = 7, dmg = 5, tar =  90, tdr = -35, trt = 2},
					["desc"] = _("upgrade-comms","increase arc width by 50%")
				},
				{	--6
					{idx = 0, arc = 10, dir =  35, rng = 1000, cyc = 7, dmg = 6, tar =  90, tdr =  35, trt = 2},
					{idx = 1, arc = 10, dir = -35, rng = 1000, cyc = 7, dmg = 6, tar =  90, tdr = -35, trt = 2},
					["desc"] = _("upgrade-comms","increase damage by 20%"),
				},
				{	--7
					{idx = 0, arc = 10, dir =  35, rng = 1000, cyc = 7, dmg = 6, tar =  90, tdr =  35, trt = 4},
					{idx = 1, arc = 10, dir = -35, rng = 1000, cyc = 7, dmg = 6, tar =  90, tdr = -35, trt = 4},
					["desc"] = _("upgrade-comms","double turret speed"),
				},
				{	--8
					{idx = 0, arc = 10, dir =  35, rng = 1000, cyc = 6, dmg = 6, tar =  90, tdr =  35, trt = 4},
					{idx = 1, arc = 10, dir = -35, rng = 1000, cyc = 6, dmg = 6, tar =  90, tdr = -35, trt = 4},
					["desc"] = _("upgrade-comms","decrease cycle time by ~14%"),
				},
				{	--9
					{idx = 0, arc = 10, dir =  35, rng = 1200, cyc = 6, dmg = 6, tar =  90, tdr =  35, trt = 4},
					{idx = 1, arc = 10, dir = -35, rng = 1200, cyc = 6, dmg = 6, tar =  90, tdr = -35, trt = 4},
					["desc"] = _("upgrade-comms","increase range by 20%"),
				},
				{	--10
					{idx = 0, arc = 10, dir =  35, rng = 1200, cyc = 6, dmg = 6, tar =  90, tdr =  35, trt = 6},
					{idx = 1, arc = 10, dir = -35, rng = 1200, cyc = 6, dmg = 6, tar =  90, tdr = -35, trt = 6},
					["desc"] = _("upgrade-comms","increase turret speed by 50%"),
				},
				{	--11
					{idx = 0, arc = 10, dir =  35, rng = 1200, cyc = 6, dmg = 8, tar =  90, tdr =  35, trt = 6},
					{idx = 1, arc = 10, dir = -35, rng = 1200, cyc = 6, dmg = 8, tar =  90, tdr = -35, trt = 6},
					["desc"] = _("upgrade-comms","increase damage by 1/3"),
				},
				{	--12
					{idx = 0, arc = 10, dir =  35, rng = 1200, cyc = 5, dmg = 8, tar =  90, tdr =  35, trt = 6},
					{idx = 1, arc = 10, dir = -35, rng = 1200, cyc = 5, dmg = 8, tar =  90, tdr = -35, trt = 6},
					["desc"] = _("upgrade-comms","decrease cycle time by ~17%"),
				},
				["stock"] = {
					{idx = 0, arc = 10, dir =  35, rng = 1000, cyc = 6, dmg = 6, tar =  90, tdr =  35, trt = 6},
					{idx = 1, arc = 10, dir = -35, rng = 1000, cyc = 6, dmg = 6, tar =  90, tdr = -35, trt = 6},
				},
				["start"] = 4,
			},
			["missiles"] = {
				{tube = 1,	ord = 1},																					--1
				{tube = 1,	ord = 2, desc = _("upgrade-comms","increase mine capacity by 1/3")},						--2  
				{tube = 2,	ord = 2, desc = _("upgrade-comms","add another mining tube")},								--3  
				{tube = 3,	ord = 2, desc = _("upgrade-comms","reduce tube load time by 25%")},							--4
				{tube = 3,	ord = 3, desc = _("upgrade-comms","increase mine capacity by 50%")},						--5
				{tube = 4,	ord = 3, desc = _("upgrade-comms","reduce load speed by 1/3")},								--6
				{tube = 5,	ord = 3, desc = _("upgrade-comms","add another mining tube")},								--7
				{tube = 6,	ord = 4, desc = _("upgrade-comms","add HVLI capability to first mining tube")},				--8
				{tube = 7,	ord = 5, desc = _("upgrade-comms","add homing capability to second mining tube")},			--9
				{tube = 8,	ord = 6, desc = _("upgrade-comms","make first tube a large tube")},							--10
				{tube = 8,	ord = 7, desc = _("upgrade-comms","increase HVLI capacity by 25%")},						--11
				{tube = 9,	ord = 7, desc = _("upgrade-comms","reduce tube load speed time by 20%")},					--12
				{tube = 9,	ord = 8, desc = _("upgrade-comms","increase capacity: homing:100%, mine:1/3, HVLI:20%")},	--13
				{tube = 10,	ord = 8, desc = _("upgrade-comms","make second tube a large tube")},						--14
				["start"] = 5,
			},
			["tube"] = {
				{	--1
					{idx = 0, dir = 180, siz = "M", spd = 20, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--2
					{idx = 0, dir = 180, siz = "M", spd = 20, hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 1, dir = 180, siz = "M", spd = 20, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--3
					{idx = 0, dir = 180, siz = "M", spd = 15, hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 1, dir = 180, siz = "M", spd = 15, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--4
					{idx = 0, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 1, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--5
					{idx = 0, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 1, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 2, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--6
					{idx = 0, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = true },
					{idx = 1, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 2, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--7
					{idx = 0, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = true },
					{idx = 1, dir = 180, siz = "M", spd = 10, hom = true,  nuk = false, emp = false, min = true,  hvl = false},
					{idx = 2, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--8
					{idx = 0, dir = 180, siz = "L", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = true },
					{idx = 1, dir = 180, siz = "M", spd = 10, hom = true,  nuk = false, emp = false, min = true,  hvl = false},
					{idx = 2, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--9
					{idx = 0, dir = 180, siz = "L", spd = 8,  hom = false, nuk = false, emp = false, min = true,  hvl = true },
					{idx = 1, dir = 180, siz = "M", spd = 8,  hom = true,  nuk = false, emp = false, min = true,  hvl = false},
					{idx = 2, dir = 180, siz = "M", spd = 8,  hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--10
					{idx = 0, dir = 180, siz = "L", spd = 8,  hom = false, nuk = false, emp = false, min = true,  hvl = true },
					{idx = 1, dir = 180, siz = "L", spd = 8,  hom = true,  nuk = false, emp = false, min = true,  hvl = false},
					{idx = 2, dir = 180, siz = "M", spd = 8,  hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				["stock"] = {
					{idx = 0, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 1, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 2, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
			},
			["ordnance"] = {
				{hom = 0,  nuk = 0, emp = 0, min = 3, hvl = 0},		--1
				{hom = 0,  nuk = 0, emp = 0, min = 4, hvl = 0},		--2
				{hom = 0,  nuk = 0, emp = 0, min = 6, hvl = 0},		--3
				{hom = 0,  nuk = 0, emp = 0, min = 6, hvl = 4},		--4		
				{hom = 2,  nuk = 0, emp = 0, min = 6, hvl = 4},		--5		
				{hom = 2,  nuk = 0, emp = 0, min = 9, hvl = 4},		--6		
				{hom = 2,  nuk = 0, emp = 0, min = 9, hvl = 5},		--7		
				{hom = 4,  nuk = 0, emp = 0, min = 12,hvl = 6},		--8	
				["stock"] = {hom = 0, nuk = 0, emp = 0, min = 12, hvl = 0},
			},
			["shield"] = {
				{	--1
					{idx = 0, max = 40},
				},
				{	--2
					{idx = 0, max = 50},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--3
					{idx = 0, max = 60},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--4
					{idx = 0, max = 50},
					{idx = 1, max = 50},
					["desc"] = _("upgrade-comms","add rear arc"),
				},
				{	--5
					{idx = 0, max = 50},
					{idx = 1, max = 60},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by 20%"),
				},
				{	--6
					{idx = 0, max = 60},
					{idx = 1, max = 72},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--7
					{idx = 0, max = 60},
					{idx = 1, max = 96},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by 1/3"),
				},
				{	--8
					{idx = 0, max = 75},
					{idx = 1, max = 120},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				["stock"] = {
					{idx = 0, max = 60},
					{idx = 1, max = 60},
				},
				["start"] = 3,
			},
			["hull"] = {
				{max = 60},												--1
				{max =  80, ["desc"] = _("upgrade-comms","increase hull max by 1/3")},		--2
				{max = 100, ["desc"] = _("upgrade-comms","increase hull max by 25%")},		--3
				{max = 120, ["desc"] = _("upgrade-comms","increase hull max by 20%")},		--4
				{max = 150, ["desc"] = _("upgrade-comms","increase hull max by 25%")},		--5
				{max = 180, ["desc"] = _("upgrade-comms","increase hull max by 20%")},		--6
				["stock"] = {max = 100},
				["start"] = 4,
			},
			["impulse"] = {
				{	--1
					max_front =		80,		max_back =		80,
					accel_front =	12,		accel_back = 	12,
					turn = 			8,
					boost =			0,		strafe =		0,
				},
				{	--2
					max_front =		100,	max_back =		80,
					accel_front =	12,		accel_back = 	12,
					turn = 			8,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase max forward impulse speed by 20%"),
				},
				{	--3
					max_front =		100,	max_back =		80,
					accel_front =	15,		accel_back = 	12,
					turn = 			8,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase forward acceleration by 25%"),
				},
				{	--4
					max_front =		100,	max_back =		80,
					accel_front =	15,		accel_back = 	12,
					turn = 			10,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase maneuverability by 25%"),
				},
				{	--5
					max_front =		100,	max_back =		80,
					accel_front =	15,		accel_back = 	12,
					turn = 			10,
					boost =			200,	strafe =		0,
					desc = _("upgrade-comms","add combat maneuver boost"),
				},
				{	--6
					max_front =		110,	max_back =		88,
					accel_front =	15,		accel_back = 	12,
					turn = 			10,
					boost =			200,	strafe =		0,
					desc = _("upgrade-comms","increase max impulse speed by 10%"),
				},
				{	--7
					max_front =		110,	max_back =		88,
					accel_front =	15,		accel_back = 	12,
					turn = 			10,
					boost =			200,	strafe =		100,
					desc = _("upgrade-comms","add combat maneuver strafe"),
				},
				{	--8
					max_front =		110,	max_back =		88,
					accel_front =	20,		accel_back = 	15,
					turn = 			10,
					boost =			200,	strafe =		100,
					desc = _("upgrade-comms","increase impulse acceleration by 1/3"),
				},
				{	--9
					max_front =		110,	max_back =		88,
					accel_front =	20,		accel_back = 	15,
					turn = 			10,
					boost =			300,	strafe =		200,
					desc = _("upgrade-comms","increase combat maneuver by 50%"),
				},
				{	--10
					max_front =		110,	max_back =		88,
					accel_front =	20,		accel_back = 	15,
					turn = 			12,
					boost =			300,	strafe =		200,
					desc = _("upgrade-comms","increase maneuverability by 20%"),
				},
				["stock"] = {
					{max_front = 100, turn = 10, accel_front = 15, max_back = 100, accel_back = 15, boost = 250, strafe = 150},
				},
				["start"] = 5,
			},
			["ftl"] = {
				{	--1
					jump_long = 0, jump_short = 0, warp = 0,
				},
				{	--2
					jump_long = 20000, jump_short = 2000, warp = 0,
					desc = _("upgrade-comms","add 20k jump drive"),
				},
				{	--3
					jump_long = 25000, jump_short = 2500, warp = 0,
					desc = _("upgrade-comms","increase jump range by 25%"),
				},
				{	--4
					jump_long = 30000, jump_short = 3000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 20%"),
				},
				{	--5
					jump_long = 40000, jump_short = 4000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 1/3"),
				},
				{	--6
					jump_long = 50000, jump_short = 5000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 25%"),
				},
				{	--7
					jump_long = 55000, jump_short = 5500, warp = 0,
					desc = _("upgrade-comms","increase jump range by 10%"),
				},
				{	--8
					jump_long = 55000, jump_short = 5500, warp = 300,
					desc = _("upgrade-comms","add warp drive"),
				},
				{	--9
					jump_long = 55000, jump_short = 5500, warp = 400,
					desc = _("upgrade-comms","increase warp speed by 1/3"),
				},
				{	--10
					jump_long = 60000, jump_short = 6000, warp = 400,
					desc = _("upgrade-comms","increase jump range by ~9%"),
				},
				{	--11
					jump_long = 60000, jump_short = 6000, warp = 500,
					desc = _("upgrade-comms","increase warp speed by 25%"),
				},
				["stock"] = {
					{jump_long = 50000, jump_short = 5000, warp = 0},
				},
				["start"] = 2,
			},
			["sensors"] = {
				{	--1
					short = 4000, long = 15000, prox_scan = 0,
				},
				{	--2
					short = 4000, long = 20000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by 25%"),
				},
				{	--3
					short = 4000, long = 20000, prox_scan = 2,
					desc = _("upgrade-comms","add 2 unit automated proximity scanner"),
				},
				{	--4
					short = 4000, long = 25000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by 20%"),
				},
				{	--5
					short = 5000, long = 25000, prox_scan = 2,
					desc = _("upgrade-comms","increase short range sensors by 25%"),
				},
				{	--6
					short = 5000, long = 30000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by 20%"),
				},
				{	--7
					short = 5000, long = 35000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by ~17%"),
				},
				{	--8
					short = 5000, long = 40000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by ~14%"),
				},
				{	--9
					short = 5000, long = 50000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by 25%"),
				},
				{	--10
					short = 5000, long = 60000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by 20%"),
				},
				["stock"] = {
					{short = 5000, long = 30000}, prox_scan = 0,
				},
				["start"] = 4,
			},
			["providers"] = false,
			["score"] = 28,
		},
		["Striker"] = {		--6 + beam(8) + missile(11) + shield(8) + hull(5) + impulse(8) + ftl(6) + sensors(5) = 57
			["beam"] = {
				{	--1
					{idx = 0, arc = 30, dir = -15, rng = 800, cyc = 8, dmg = 4},
					{idx = 1, arc = 30, dir =  15, rng = 800, cyc = 8, dmg = 4},
				},
				{	--2
					{idx = 0, arc = 30, dir = -15, rng = 1000, cyc = 8, dmg = 4},
					{idx = 1, arc = 30, dir =  15, rng = 1000, cyc = 8, dmg = 4},
					["desc"] = _("upgrade-comms","increase range by 25%")
				},
				{	--3
					{idx = 0, arc = 30, dir = -15, rng = 1000, cyc = 6, dmg = 4},
					{idx = 1, arc = 30, dir =  15, rng = 1000, cyc = 6, dmg = 4},
					["desc"] = _("upgrade-comms","reduce cycle time by 25%")
				},
				{	--4
					{idx = 0, arc = 50, dir = -15, rng = 1000, cyc = 6, dmg = 4},
					{idx = 1, arc = 50, dir =  15, rng = 1000, cyc = 6, dmg = 4},
					["desc"] = _("upgrade-comms","increase arc width by 2/3")
				},
				{	--5
					{idx = 0, arc = 50, dir = -15, rng = 1000, cyc = 6, dmg = 6},
					{idx = 1, arc = 50, dir =  15, rng = 1000, cyc = 6, dmg = 6},
					["desc"] = _("upgrade-comms","increase damage by 50%")
				},
				{	--6
					{idx = 0, arc = 50, dir = -15, rng = 1000, cyc = 5, dmg = 6},
					{idx = 1, arc = 50, dir =  15, rng = 1000, cyc = 5, dmg = 6},
					["desc"] = _("upgrade-comms","reduce cycle time by ~17%"),
				},
				{	--7
					{idx = 0, arc = 60, dir = -15, rng = 1000, cyc = 5, dmg = 6},
					{idx = 1, arc = 60, dir =  15, rng = 1000, cyc = 5, dmg = 6},
					["desc"] = _("upgrade-comms","increase arc width by 20%"),
				},
				{	--8
					{idx = 0, arc = 60, dir = -15, rng = 1000, cyc = 5, dmg = 6},
					{idx = 1, arc = 60, dir =  15, rng = 1000, cyc = 5, dmg = 6},
					{idx = 2, arc = 20, dir =   0, rng = 1500, cyc = 5, dmg = 5},
					["desc"] = _("upgrade-comms","add sniping beam"),
				},
				{	--9
					{idx = 0, arc = 60, dir = -15, rng = 1000, cyc = 5, dmg = 7},
					{idx = 1, arc = 60, dir =  15, rng = 1000, cyc = 5, dmg = 7},
					{idx = 2, arc = 20, dir =   0, rng = 1500, cyc = 5, dmg = 6},
					["desc"] = _("upgrade-comms","increase damage by ~18%"),
				},
				["stock"] = {
					{idx = 0, arc = 50, dir = -15, rng = 1000, cyc = 6, dmg = 6},
					{idx = 1, arc = 50, dir =  15, rng = 1000, cyc = 6, dmg = 6},
				},
				["start"] = 3,
			},
			["missiles"] = {
				{tube = 1,	ord = 1},																		--1
				{tube = 2,	ord = 2, desc = _("upgrade-comms","add small HVLI broadsides")},				--2  
				{tube = 3,	ord = 2, desc = _("upgrade-comms","reduce tube load time by 10%")},				--3  
				{tube = 3,	ord = 3, desc = _("upgrade-comms","double HVLI capacity")},						--4
				{tube = 4,	ord = 3, desc = _("upgrade-comms","reduce tube load time by 1/3")},				--5
				{tube = 5,	ord = 4, desc = _("upgrade-comms","add homing capability to tubes")},			--6
				{tube = 5,	ord = 5, desc = _("upgrade-comms","increase capacity: homing:100%, HVLI:50%")},	--7
				{tube = 6,	ord = 6, desc = _("upgrade-comms","add a mining tube")},						--8
				{tube = 6,	ord = 7, desc = _("upgrade-comms","double mine capacity")},						--9
				{tube = 7,	ord = 7, desc = _("upgrade-comms","reduce tube load speed by 25%")},			--10
				{tube = 8,	ord = 7, desc = _("upgrade-comms","make broadside tubes medium size")},			--11
				{tube = 8,	ord = 8, desc = _("upgrade-comms","increase HVLI capacity by 1/3")},			--12
				["start"] = 4,
			},
			["tube"] = {
				{	--1
					{idx = -1},
				},
				{	--2
					{idx = 0, dir =  90, siz = "S", spd = 20, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir = -90, siz = "S", spd = 20, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--3
					{idx = 0, dir =  90, siz = "S", spd = 18, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir = -90, siz = "S", spd = 18, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--4
					{idx = 0, dir =  90, siz = "S", spd = 12, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir = -90, siz = "S", spd = 12, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--5
					{idx = 0, dir =  90, siz = "S", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir = -90, siz = "S", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
				},
				{	--6
					{idx = 0, dir =  90, siz = "S", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir = -90, siz = "S", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 20, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--7
					{idx = 0, dir =  90, siz = "S", spd = 9,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir = -90, siz = "S", spd = 9,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 15, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--8
					{idx = 0, dir =  90, siz = "M", spd = 9,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir = -90, siz = "M", spd = 9,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 15, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				["stock"] = {
					{idx = -1},
				},
			},
			["ordnance"] = {
				{hom = 0,  nuk = 0, emp = 0, min = 0, hvl = 0},		--1
				{hom = 0,  nuk = 0, emp = 0, min = 0, hvl = 2},		--2
				{hom = 0,  nuk = 0, emp = 0, min = 0, hvl = 4},		--3
				{hom = 2,  nuk = 0, emp = 0, min = 0, hvl = 4},		--4
				{hom = 4,  nuk = 0, emp = 0, min = 0, hvl = 6},		--5
				{hom = 4,  nuk = 0, emp = 0, min = 1, hvl = 6},		--6
				{hom = 4,  nuk = 0, emp = 0, min = 2, hvl = 6},		--7
				{hom = 4,  nuk = 0, emp = 0, min = 2, hvl = 8},		--8
				["stock"] = {hom = 0, nuk = 0, emp = 0, min = 0, hvl = 0},
			},
			["shield"] = {
				{	--1
					{idx = 0, max = 40},
				},
				{	--2
					{idx = 0, max = 50},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--3
					{idx = 0, max = 60},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--4
					{idx = 0, max = 40},
					{idx = 1, max = 40},
					["desc"] = _("upgrade-comms","add rear arc"),
				},
				{	--5
					{idx = 0, max = 50},
					{idx = 1, max = 40},
					["desc"] = _("upgrade-comms","increase front shield charge capacity by 25%"),
				},
				{	--6
					{idx = 0, max = 60},
					{idx = 1, max = 48},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--7
					{idx = 0, max = 80},
					{idx = 1, max = 48},
					["desc"] = _("upgrade-comms","increase front shield charge capacity by 1/3"),
				},
				{	--8
					{idx = 0, max = 100},
					{idx = 1, max = 60},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--9
					{idx = 0, max = 100},
					{idx = 1, max = 72},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by 20%"),
				},
				["stock"] = {
					{idx = 0, max = 50},
					{idx = 1, max = 30},
				},
				["start"] = 2,
			},
			["hull"] = {
				{max = 80},																--1
				{max = 100, ["desc"] = _("upgrade-comms","increase hull max by 25%")},	--2
				{max = 120, ["desc"] = _("upgrade-comms","increase hull max by 20%")},	--3
				{max = 144, ["desc"] = _("upgrade-comms","increase hull max by 20%")},	--4
				{max = 180, ["desc"] = _("upgrade-comms","increase hull max by 25%")},	--5
				{max = 210, ["desc"] = _("upgrade-comms","increase hull max by ~17%")},	--6
				["stock"] = {max = 120},
				["start"] = 3,
			},
			["impulse"] = {
				{	--1
					max_front =		45,		max_back =		45,
					accel_front =	24,		accel_back = 	24,
					turn = 			12,
					boost =			0,		strafe =		0,
				},
				{	--2
					max_front =		60,		max_back =		60,
					accel_front =	24,		accel_back = 	24,
					turn = 			12,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase max impulse speed by 1/3"),
				},
				{	--3
					max_front =		60,		max_back =		60,
					accel_front =	30,		accel_back = 	24,
					turn = 			12,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase forward acceleration by 25%"),
				},
				{	--4
					max_front =		60,		max_back =		60,
					accel_front =	30,		accel_back = 	24,
					turn = 			15,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase maneuverability by 25%"),
				},
				{	--5
					max_front =		72,		max_back =		60,
					accel_front =	30,		accel_back = 	24,
					turn = 			15,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase forward max impulse by 20%"),
				},
				{	--6
					max_front =		72,		max_back =		60,
					accel_front =	30,		accel_back = 	24,
					turn = 			15,
					boost =			200,	strafe =		100,
					desc = _("upgrade-comms","add combat maneuver"),
				},
				{	--7
					max_front =		72,		max_back =		60,
					accel_front =	30,		accel_back = 	24,
					turn = 			20,
					boost =			200,	strafe =		100,
					desc = _("upgrade-comms","increase maneuverability by 1/3"),
				},
				{	--8
					max_front =		90,		max_back =		60,
					accel_front =	30,		accel_back = 	24,
					turn = 			20,
					boost =			200,	strafe =		100,
					desc = _("upgrade-comms","increase max impulse speed by 25%"),
				},
				{	--9
					max_front =		90,		max_back =		60,
					accel_front =	30,		accel_back = 	24,
					turn = 			20,
					boost =			300,	strafe =		150,
					desc = _("upgrade-comms","increase combat maneuver by 50%"),
				},
				["stock"] = {
					{max_front = 45, turn = 15, accel_front = 30, max_back = 45, accel_back = 15, boost = 250, strafe = 150},
				},
				["start"] = 5,
			},
			["ftl"] = {
				{	--1
					jump_long = 0, jump_short = 0, warp = 0,
				},
				{	--2
					jump_long = 20000, jump_short = 2000, warp = 0,
					desc = _("upgrade-comms","add 20k jump drive"),
				},
				{	--3
					jump_long = 30000, jump_short = 3000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 50%"),
				},
				{	--4
					jump_long = 30000, jump_short = 3000, warp = 500,
					desc = _("upgrade-comms","add warp drive"),
				},
				{	--5
					jump_long = 30000, jump_short = 3000, warp = 600,
					desc = _("upgrade-comms","increase warp speed by 20%"),
				},
				{	--6
					jump_long = 30000, jump_short = 3000, warp = 700,
					desc = _("upgrade-comms","increase warp speed by ~17%"),
				},
				{	--7
					jump_long = 40000, jump_short = 4000, warp = 700,
					desc = _("upgrade-comms","increase jump range by 1/3"),
				},
				["stock"] = {
					{jump_long = 50000, jump_short = 5000, warp = 0},
				},
				["start"] = 3,
			},
			["sensors"] = {
				{	--1
					short = 4000, long = 20000, prox_scan = 0,
				},
				{	--2
					short = 4000, long = 30000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by 50%"),
				},
				{	--3
					short = 4000, long = 30000, prox_scan = 2,
					desc = _("upgrade-comms","add 2 unit automated proximity scanner"),
				},
				{	--4
					short = 5000, long = 30000, prox_scan = 2,
					desc = _("upgrade-comms","increase short range sensors by 25%"),
				},
				{	--5
					short = 5000, long = 35000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by ~17%"),
				},
				{	--6
					short = 5000, long = 40000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by ~14%"),
				},
				["stock"] = {
					{short = 5000, long = 30000}, prox_scan = 0,
				},
				["start"] = 2,
			},
			["providers"] = false,
			["score"] = 21,
		},
		["Ender"] = {		--25 + beam(11) + missile(11) + shield(8) + hull(5) + impulse(14) + ftl(8) + sensors(11) = 93
			["beam"] = {
				{	--1
					{idx = 0, arc = 10, dir = -90, rng = 1500, cyc = 8.1, dmg = 4, tar = 60, tdr = -90, trt = 6},
					{idx = 1, arc = 10, dir = -90, rng = 1500, cyc = 8.0, dmg = 4, tar = 60, tdr = -90, trt = 6},
					{idx = 2, arc = 10, dir =  90, rng = 1500, cyc = 8.1, dmg = 4, tar = 60, tdr =  90, trt = 6},
					{idx = 3, arc = 10, dir =  90, rng = 1500, cyc = 8.0, dmg = 4, tar = 60, tdr =  90, trt = 6},
				},
				{	--2
					{idx = 0, arc = 10, dir = -90, rng = 1500, cyc = 8.1, dmg = 4, tar = 60, tdr = -90, trt = 6},
					{idx = 1, arc = 10, dir = -90, rng = 1500, cyc = 8.0, dmg = 4, tar = 60, tdr = -90, trt = 6},
					{idx = 2, arc = 10, dir =  90, rng = 1500, cyc = 8.1, dmg = 4, tar = 60, tdr =  90, trt = 6},
					{idx = 3, arc = 10, dir =  90, rng = 1500, cyc = 8.0, dmg = 4, tar = 60, tdr =  90, trt = 6},
					{idx = 4, arc = 10, dir = -90, rng = 1500, cyc = 8.1, dmg = 4, tar = 60, tdr = -90, trt = 6},
					{idx = 5, arc = 10, dir = -90, rng = 1500, cyc = 8.0, dmg = 4, tar = 60, tdr = -90, trt = 6},
					{idx = 6, arc = 10, dir =  90, rng = 1500, cyc = 8.1, dmg = 4, tar = 60, tdr =  90, trt = 6},
					{idx = 7, arc = 10, dir =  90, rng = 1500, cyc = 8.0, dmg = 4, tar = 60, tdr =  90, trt = 6},
					["desc"] = _("upgrade-comms","add beams")
				},
				{	--3
					{idx = 0, arc = 10, dir = -90, rng = 1500, cyc = 8.1, dmg = 4, tar = 60, tdr = -90, trt = 6},
					{idx = 1, arc = 10, dir = -90, rng = 1500, cyc = 8.0, dmg = 4, tar = 60, tdr = -90, trt = 6},
					{idx = 2, arc = 10, dir =  90, rng = 1500, cyc = 8.1, dmg = 4, tar = 60, tdr =  90, trt = 6},
					{idx = 3, arc = 10, dir =  90, rng = 1500, cyc = 8.0, dmg = 4, tar = 60, tdr =  90, trt = 6},
					{idx = 4, arc = 10, dir = -90, rng = 1500, cyc = 8.1, dmg = 4, tar = 60, tdr = -90, trt = 6},
					{idx = 5, arc = 10, dir = -90, rng = 1500, cyc = 8.0, dmg = 4, tar = 60, tdr = -90, trt = 6},
					{idx = 6, arc = 10, dir =  90, rng = 1500, cyc = 8.1, dmg = 4, tar = 60, tdr =  90, trt = 6},
					{idx = 7, arc = 10, dir =  90, rng = 1500, cyc = 8.0, dmg = 4, tar = 60, tdr =  90, trt = 6},
					{idx = 8, arc = 10, dir = -90, rng = 1500, cyc = 8.1, dmg = 4, tar = 60, tdr = -90, trt = 6},
					{idx = 9, arc = 10, dir = -90, rng = 1500, cyc = 8.0, dmg = 4, tar = 60, tdr = -90, trt = 6},
					{idx = 10,arc = 10, dir =  90, rng = 1500, cyc = 8.1, dmg = 4, tar = 60, tdr =  90, trt = 6},
					{idx = 11,arc = 10, dir =  90, rng = 1500, cyc = 8.0, dmg = 4, tar = 60, tdr =  90, trt = 6},
					["desc"] = _("upgrade-comms","add beams")
				},
				{	--4
					{idx = 0, arc = 10, dir = -90, rng = 2000, cyc = 8.1, dmg = 4, tar = 60, tdr = -90, trt = 6},
					{idx = 1, arc = 10, dir = -90, rng = 2000, cyc = 8.0, dmg = 4, tar = 60, tdr = -90, trt = 6},
					{idx = 2, arc = 10, dir =  90, rng = 2000, cyc = 8.1, dmg = 4, tar = 60, tdr =  90, trt = 6},
					{idx = 3, arc = 10, dir =  90, rng = 2000, cyc = 8.0, dmg = 4, tar = 60, tdr =  90, trt = 6},
					{idx = 4, arc = 10, dir = -90, rng = 2000, cyc = 8.1, dmg = 4, tar = 60, tdr = -90, trt = 6},
					{idx = 5, arc = 10, dir = -90, rng = 2000, cyc = 8.0, dmg = 4, tar = 60, tdr = -90, trt = 6},
					{idx = 6, arc = 10, dir =  90, rng = 2000, cyc = 8.1, dmg = 4, tar = 60, tdr =  90, trt = 6},
					{idx = 7, arc = 10, dir =  90, rng = 2000, cyc = 8.0, dmg = 4, tar = 60, tdr =  90, trt = 6},
					{idx = 8, arc = 10, dir = -90, rng = 2000, cyc = 8.1, dmg = 4, tar = 60, tdr = -90, trt = 6},
					{idx = 9, arc = 10, dir = -90, rng = 2000, cyc = 8.0, dmg = 4, tar = 60, tdr = -90, trt = 6},
					{idx = 10,arc = 10, dir =  90, rng = 2000, cyc = 8.1, dmg = 4, tar = 60, tdr =  90, trt = 6},
					{idx = 11,arc = 10, dir =  90, rng = 2000, cyc = 8.0, dmg = 4, tar = 60, tdr =  90, trt = 6},
					["desc"] = _("upgrade-comms","increase range by 1/3"),
				},
				{	--5
					{idx = 0, arc = 10, dir = -90, rng = 2000, cyc = 8.1, dmg = 4, tar = 90, tdr = -90, trt = 6},
					{idx = 1, arc = 10, dir = -90, rng = 2000, cyc = 8.0, dmg = 4, tar = 90, tdr = -90, trt = 6},
					{idx = 2, arc = 10, dir =  90, rng = 2000, cyc = 8.1, dmg = 4, tar = 90, tdr =  90, trt = 6},
					{idx = 3, arc = 10, dir =  90, rng = 2000, cyc = 8.0, dmg = 4, tar = 90, tdr =  90, trt = 6},
					{idx = 4, arc = 10, dir = -90, rng = 2000, cyc = 8.1, dmg = 4, tar = 90, tdr = -90, trt = 6},
					{idx = 5, arc = 10, dir = -90, rng = 2000, cyc = 8.0, dmg = 4, tar = 90, tdr = -90, trt = 6},
					{idx = 6, arc = 10, dir =  90, rng = 2000, cyc = 8.1, dmg = 4, tar = 90, tdr =  90, trt = 6},
					{idx = 7, arc = 10, dir =  90, rng = 2000, cyc = 8.0, dmg = 4, tar = 90, tdr =  90, trt = 6},
					{idx = 8, arc = 10, dir = -90, rng = 2000, cyc = 8.1, dmg = 4, tar = 90, tdr = -90, trt = 6},
					{idx = 9, arc = 10, dir = -90, rng = 2000, cyc = 8.0, dmg = 4, tar = 90, tdr = -90, trt = 6},
					{idx = 10,arc = 10, dir =  90, rng = 2000, cyc = 8.1, dmg = 4, tar = 90, tdr =  90, trt = 6},
					{idx = 11,arc = 10, dir =  90, rng = 2000, cyc = 8.0, dmg = 4, tar = 90, tdr =  90, trt = 6},
					["desc"] = _("upgrade-comms","increase arc width by 50%"),
				},
				{	--6
					{idx = 0, arc = 10, dir = -90, rng = 2000, cyc = 6.1, dmg = 4, tar = 90, tdr = -90, trt = 6},
					{idx = 1, arc = 10, dir = -90, rng = 2000, cyc = 6.0, dmg = 4, tar = 90, tdr = -90, trt = 6},
					{idx = 2, arc = 10, dir =  90, rng = 2000, cyc = 6.1, dmg = 4, tar = 90, tdr =  90, trt = 6},
					{idx = 3, arc = 10, dir =  90, rng = 2000, cyc = 6.0, dmg = 4, tar = 90, tdr =  90, trt = 6},
					{idx = 4, arc = 10, dir = -90, rng = 2000, cyc = 6.1, dmg = 4, tar = 90, tdr = -90, trt = 6},
					{idx = 5, arc = 10, dir = -90, rng = 2000, cyc = 6.0, dmg = 4, tar = 90, tdr = -90, trt = 6},
					{idx = 6, arc = 10, dir =  90, rng = 2000, cyc = 6.1, dmg = 4, tar = 90, tdr =  90, trt = 6},
					{idx = 7, arc = 10, dir =  90, rng = 2000, cyc = 6.0, dmg = 4, tar = 90, tdr =  90, trt = 6},
					{idx = 8, arc = 10, dir = -90, rng = 2000, cyc = 6.1, dmg = 4, tar = 90, tdr = -90, trt = 6},
					{idx = 9, arc = 10, dir = -90, rng = 2000, cyc = 6.0, dmg = 4, tar = 90, tdr = -90, trt = 6},
					{idx = 10,arc = 10, dir =  90, rng = 2000, cyc = 6.1, dmg = 4, tar = 90, tdr =  90, trt = 6},
					{idx = 11,arc = 10, dir =  90, rng = 2000, cyc = 6.0, dmg = 4, tar = 90, tdr =  90, trt = 6},
					["desc"] = _("upgrade-comms","decrease cycle time by 25%")
				},
				{	--7
					{idx = 0, arc = 10, dir = -90, rng = 2500, cyc = 6.1, dmg = 4, tar = 90, tdr = -90, trt = 6},
					{idx = 1, arc = 10, dir = -90, rng = 2500, cyc = 6.0, dmg = 4, tar = 90, tdr = -90, trt = 6},
					{idx = 2, arc = 10, dir =  90, rng = 2500, cyc = 6.1, dmg = 4, tar = 90, tdr =  90, trt = 6},
					{idx = 3, arc = 10, dir =  90, rng = 2500, cyc = 6.0, dmg = 4, tar = 90, tdr =  90, trt = 6},
					{idx = 4, arc = 10, dir = -90, rng = 2500, cyc = 6.1, dmg = 4, tar = 90, tdr = -90, trt = 6},
					{idx = 5, arc = 10, dir = -90, rng = 2500, cyc = 6.0, dmg = 4, tar = 90, tdr = -90, trt = 6},
					{idx = 6, arc = 10, dir =  90, rng = 2500, cyc = 6.1, dmg = 4, tar = 90, tdr =  90, trt = 6},
					{idx = 7, arc = 10, dir =  90, rng = 2500, cyc = 6.0, dmg = 4, tar = 90, tdr =  90, trt = 6},
					{idx = 8, arc = 10, dir = -90, rng = 2500, cyc = 6.1, dmg = 4, tar = 90, tdr = -90, trt = 6},
					{idx = 9, arc = 10, dir = -90, rng = 2500, cyc = 6.0, dmg = 4, tar = 90, tdr = -90, trt = 6},
					{idx = 10,arc = 10, dir =  90, rng = 2500, cyc = 6.1, dmg = 4, tar = 90, tdr =  90, trt = 6},
					{idx = 11,arc = 10, dir =  90, rng = 2500, cyc = 6.0, dmg = 4, tar = 90, tdr =  90, trt = 6},
					["desc"] = _("upgrade-comms","increase range by 25%")
				},
				{	--8
					{idx = 0, arc = 10, dir = -90, rng = 2500, cyc = 6.1, dmg = 5, tar = 90, tdr = -90, trt = 6},
					{idx = 1, arc = 10, dir = -90, rng = 2500, cyc = 6.0, dmg = 5, tar = 90, tdr = -90, trt = 6},
					{idx = 2, arc = 10, dir =  90, rng = 2500, cyc = 6.1, dmg = 5, tar = 90, tdr =  90, trt = 6},
					{idx = 3, arc = 10, dir =  90, rng = 2500, cyc = 6.0, dmg = 5, tar = 90, tdr =  90, trt = 6},
					{idx = 4, arc = 10, dir = -90, rng = 2500, cyc = 6.1, dmg = 5, tar = 90, tdr = -90, trt = 6},
					{idx = 5, arc = 10, dir = -90, rng = 2500, cyc = 6.0, dmg = 5, tar = 90, tdr = -90, trt = 6},
					{idx = 6, arc = 10, dir =  90, rng = 2500, cyc = 6.1, dmg = 5, tar = 90, tdr =  90, trt = 6},
					{idx = 7, arc = 10, dir =  90, rng = 2500, cyc = 6.0, dmg = 5, tar = 90, tdr =  90, trt = 6},
					{idx = 8, arc = 10, dir = -90, rng = 2500, cyc = 6.1, dmg = 5, tar = 90, tdr = -90, trt = 6},
					{idx = 9, arc = 10, dir = -90, rng = 2500, cyc = 6.0, dmg = 5, tar = 90, tdr = -90, trt = 6},
					{idx = 10,arc = 10, dir =  90, rng = 2500, cyc = 6.1, dmg = 5, tar = 90, tdr =  90, trt = 6},
					{idx = 11,arc = 10, dir =  90, rng = 2500, cyc = 6.0, dmg = 5, tar = 90, tdr =  90, trt = 6},
					["desc"] = _("upgrade-comms","increase damage by 25%"),
				},
				{	--9
					{idx = 0, arc = 10, dir = -90, rng = 2500, cyc = 6.1, dmg = 5, tar = 120, tdr = -90, trt = 6},
					{idx = 1, arc = 10, dir = -90, rng = 2500, cyc = 6.0, dmg = 5, tar = 120, tdr = -90, trt = 6},
					{idx = 2, arc = 10, dir =  90, rng = 2500, cyc = 6.1, dmg = 5, tar = 120, tdr =  90, trt = 6},
					{idx = 3, arc = 10, dir =  90, rng = 2500, cyc = 6.0, dmg = 5, tar = 120, tdr =  90, trt = 6},
					{idx = 4, arc = 10, dir = -90, rng = 2500, cyc = 6.1, dmg = 5, tar = 120, tdr = -90, trt = 6},
					{idx = 5, arc = 10, dir = -90, rng = 2500, cyc = 6.0, dmg = 5, tar = 120, tdr = -90, trt = 6},
					{idx = 6, arc = 10, dir =  90, rng = 2500, cyc = 6.1, dmg = 5, tar = 120, tdr =  90, trt = 6},
					{idx = 7, arc = 10, dir =  90, rng = 2500, cyc = 6.0, dmg = 5, tar = 120, tdr =  90, trt = 6},
					{idx = 8, arc = 10, dir = -90, rng = 2500, cyc = 6.1, dmg = 5, tar = 120, tdr = -90, trt = 6},
					{idx = 9, arc = 10, dir = -90, rng = 2500, cyc = 6.0, dmg = 5, tar = 120, tdr = -90, trt = 6},
					{idx = 10,arc = 10, dir =  90, rng = 2500, cyc = 6.1, dmg = 5, tar = 120, tdr =  90, trt = 6},
					{idx = 11,arc = 10, dir =  90, rng = 2500, cyc = 6.0, dmg = 5, tar = 120, tdr =  90, trt = 6},
					["desc"] = _("upgrade-comms","increase arc width by 1/3"),
				},
				{	--10
					{idx = 0, arc = 10, dir = -90, rng = 2500, cyc = 5.1, dmg = 5, tar = 120, tdr = -90, trt = 6},
					{idx = 1, arc = 10, dir = -90, rng = 2500, cyc = 5.0, dmg = 5, tar = 120, tdr = -90, trt = 6},
					{idx = 2, arc = 10, dir =  90, rng = 2500, cyc = 5.1, dmg = 5, tar = 120, tdr =  90, trt = 6},
					{idx = 3, arc = 10, dir =  90, rng = 2500, cyc = 5.0, dmg = 5, tar = 120, tdr =  90, trt = 6},
					{idx = 4, arc = 10, dir = -90, rng = 2500, cyc = 5.1, dmg = 5, tar = 120, tdr = -90, trt = 6},
					{idx = 5, arc = 10, dir = -90, rng = 2500, cyc = 5.0, dmg = 5, tar = 120, tdr = -90, trt = 6},
					{idx = 6, arc = 10, dir =  90, rng = 2500, cyc = 5.1, dmg = 5, tar = 120, tdr =  90, trt = 6},
					{idx = 7, arc = 10, dir =  90, rng = 2500, cyc = 5.0, dmg = 5, tar = 120, tdr =  90, trt = 6},
					{idx = 8, arc = 10, dir = -90, rng = 2500, cyc = 5.1, dmg = 5, tar = 120, tdr = -90, trt = 6},
					{idx = 9, arc = 10, dir = -90, rng = 2500, cyc = 5.0, dmg = 5, tar = 120, tdr = -90, trt = 6},
					{idx = 10,arc = 10, dir =  90, rng = 2500, cyc = 5.1, dmg = 5, tar = 120, tdr =  90, trt = 6},
					{idx = 11,arc = 10, dir =  90, rng = 2500, cyc = 5.0, dmg = 5, tar = 120, tdr =  90, trt = 6},
					["desc"] = _("upgrade-comms","reduce cycle time by ~17%"),
				},
				{	--11
					{idx = 0, arc = 10, dir =  -80, rng = 2500, cyc = 5.1, dmg = 5, tar = 120, tdr =  -80, trt = 6},
					{idx = 1, arc = 10, dir = -100, rng = 2500, cyc = 5.0, dmg = 5, tar = 120, tdr = -100, trt = 6},
					{idx = 2, arc = 10, dir =   80, rng = 2500, cyc = 5.1, dmg = 5, tar = 120, tdr =   80, trt = 6},
					{idx = 3, arc = 10, dir =  100, rng = 2500, cyc = 5.0, dmg = 5, tar = 120, tdr =  100, trt = 6},
					{idx = 4, arc = 10, dir =  -80, rng = 2500, cyc = 5.1, dmg = 5, tar = 120, tdr =  -80, trt = 6},
					{idx = 5, arc = 10, dir = -100, rng = 2500, cyc = 5.0, dmg = 5, tar = 120, tdr = -100, trt = 6},
					{idx = 6, arc = 10, dir =   80, rng = 2500, cyc = 5.1, dmg = 5, tar = 120, tdr =   80, trt = 6},
					{idx = 7, arc = 10, dir =  100, rng = 2500, cyc = 5.0, dmg = 5, tar = 120, tdr =  100, trt = 6},
					{idx = 8, arc = 10, dir =  -80, rng = 2500, cyc = 5.1, dmg = 5, tar = 120, tdr =  -80, trt = 6},
					{idx = 9, arc = 10, dir = -100, rng = 2500, cyc = 5.0, dmg = 5, tar = 120, tdr = -100, trt = 6},
					{idx = 10,arc = 10, dir =   80, rng = 2500, cyc = 5.1, dmg = 5, tar = 120, tdr =   80, trt = 6},
					{idx = 11,arc = 10, dir =  100, rng = 2500, cyc = 5.0, dmg = 5, tar = 120, tdr =  100, trt = 6},
					["desc"] = _("upgrade-comms","adjust beam angles for more coverage"),
				},
				{	--12
					{idx = 0, arc = 10, dir =  -80, rng = 2500, cyc = 5.1, dmg = 5, tar = 150, tdr =  -80, trt = 6},
					{idx = 1, arc = 10, dir = -100, rng = 2500, cyc = 5.0, dmg = 5, tar = 150, tdr = -100, trt = 6},
					{idx = 2, arc = 10, dir =   80, rng = 2500, cyc = 5.1, dmg = 5, tar = 150, tdr =   80, trt = 6},
					{idx = 3, arc = 10, dir =  100, rng = 2500, cyc = 5.0, dmg = 5, tar = 150, tdr =  100, trt = 6},
					{idx = 4, arc = 10, dir =  -80, rng = 2500, cyc = 5.1, dmg = 5, tar = 150, tdr =  -80, trt = 6},
					{idx = 5, arc = 10, dir = -100, rng = 2500, cyc = 5.0, dmg = 5, tar = 150, tdr = -100, trt = 6},
					{idx = 6, arc = 10, dir =   80, rng = 2500, cyc = 5.1, dmg = 5, tar = 150, tdr =   80, trt = 6},
					{idx = 7, arc = 10, dir =  100, rng = 2500, cyc = 5.0, dmg = 5, tar = 150, tdr =  100, trt = 6},
					{idx = 8, arc = 10, dir =  -80, rng = 2500, cyc = 5.1, dmg = 5, tar = 150, tdr =  -80, trt = 6},
					{idx = 9, arc = 10, dir = -100, rng = 2500, cyc = 5.0, dmg = 5, tar = 150, tdr = -100, trt = 6},
					{idx = 10,arc = 10, dir =   80, rng = 2500, cyc = 5.1, dmg = 5, tar = 150, tdr =   80, trt = 6},
					{idx = 11,arc = 10, dir =  100, rng = 2500, cyc = 5.0, dmg = 5, tar = 150, tdr =  100, trt = 6},
					["desc"] = _("upgrade-comms","increase beam arc by 25%"),
				},
				["stock"] = {
					{idx = 0, arc = 10, dir = -90, rng = 2500, cyc = 6.1, dmg = 4, tar = 120, tdr = -90, trt = 6},
					{idx = 1, arc = 10, dir = -90, rng = 2500, cyc = 6.0, dmg = 4, tar = 120, tdr = -90, trt = 6},
					{idx = 2, arc = 10, dir =  90, rng = 2500, cyc = 5.8, dmg = 4, tar = 120, tdr =  90, trt = 6},
					{idx = 3, arc = 10, dir =  90, rng = 2500, cyc = 6.3, dmg = 4, tar = 120, tdr =  90, trt = 6},
					{idx = 4, arc = 10, dir = -90, rng = 2500, cyc = 5.9, dmg = 4, tar = 120, tdr = -90, trt = 6},
					{idx = 5, arc = 10, dir = -90, rng = 2500, cyc = 6.4, dmg = 4, tar = 120, tdr = -90, trt = 6},
					{idx = 6, arc = 10, dir =  90, rng = 2500, cyc = 5.7, dmg = 4, tar = 120, tdr =  90, trt = 6},
					{idx = 7, arc = 10, dir =  90, rng = 2500, cyc = 5.6, dmg = 4, tar = 120, tdr =  90, trt = 6},
					{idx = 8, arc = 10, dir = -90, rng = 2500, cyc = 6.6, dmg = 4, tar = 120, tdr = -90, trt = 6},
					{idx = 9, arc = 10, dir = -90, rng = 2500, cyc = 5.5, dmg = 4, tar = 120, tdr = -90, trt = 6},
					{idx = 10,arc = 10, dir =  90, rng = 2500, cyc = 6.5, dmg = 4, tar = 120, tdr =  90, trt = 6},
					{idx = 11,arc = 10, dir =  90, rng = 2500, cyc = 6.2, dmg = 4, tar = 120, tdr =  90, trt = 6},
				},
				["start"] = 3,
			},
			["missiles"] = {
				{tube = 1,	ord = 1},																	--1
				{tube = 2,	ord = 2, desc = _("upgrade-comms","add medium homing tubes")},				--2  
				{tube = 2,	ord = 3, desc = _("upgrade-comms","double capacity)")},						--3  
				{tube = 3,	ord = 3, desc = _("upgrade-comms","reduce tube load time by 10%")},			--4
				{tube = 3,	ord = 4, desc = _("upgrade-comms","increase capacity by 50%")},				--5
				{tube = 4,	ord = 4, desc = _("upgrade-comms","add more tubes")},						--6
				{tube = 5,	ord = 4, desc = _("upgrade-comms","reduce tube load time by ~17%")},		--7
				{tube = 5,	ord = 5, desc = _("upgrade-comms","increase capacity by 1/3")},				--8
				{tube = 6,	ord = 5, desc = _("upgrade-comms","make two lower tubes large")},			--9
				{tube = 6,	ord = 6, desc = _("upgrade-comms","increase capacity by 25%")},				--10
				{tube = 7,	ord = 7, desc = _("upgrade-comms","reduce tube load times by 20%")},		--11
				{tube = 8,	ord = 7, desc = _("upgrade-comms","reduce medium tube load times by 25%")},	--12
				["start"] = 2,
			},
			["tube"] = {
				{	--1
					{idx = -1},
				},
				{	--2
					{idx = 0, dir =   0, siz = "M", spd = 20, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir = 180, siz = "M", spd = 20, hom = true,  nuk = false, emp = false, min = false, hvl = false},
				},
				{	--3
					{idx = 0, dir =   0, siz = "M", spd = 18, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir = 180, siz = "M", spd = 18, hom = true,  nuk = false, emp = false, min = false, hvl = false},
				},
				{	--4
					{idx = 0, dir =   0, siz = "M", spd = 18, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir = 180, siz = "M", spd = 18, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 0, dir =   0, siz = "M", spd = 18, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir = 180, siz = "M", spd = 18, hom = true,  nuk = false, emp = false, min = false, hvl = false},
				},
				{	--5
					{idx = 0, dir =   0, siz = "M", spd = 15, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir = 180, siz = "M", spd = 15, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 0, dir =   0, siz = "M", spd = 15, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir = 180, siz = "M", spd = 15, hom = true,  nuk = false, emp = false, min = false, hvl = false},
				},
				{	--6
					{idx = 0, dir =   0, siz = "M", spd = 15, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir = 180, siz = "M", spd = 15, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 0, dir =   0, siz = "L", spd = 15, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir = 180, siz = "L", spd = 15, hom = true,  nuk = false, emp = false, min = false, hvl = false},
				},
				{	--7
					{idx = 0, dir =   0, siz = "M", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir = 180, siz = "M", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 0, dir =   0, siz = "L", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir = 180, siz = "L", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = false},
				},
				{	--8
					{idx = 0, dir =   0, siz = "M", spd = 9,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir = 180, siz = "M", spd = 9,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 0, dir =   0, siz = "L", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir = 180, siz = "L", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = false},
				},
				["stock"] = {
					{idx = -1},
				},
			},
			["ordnance"] = {
				{hom = 0,  nuk = 0, emp = 0, min = 0, hvl = 0},		--1
				{hom = 4,  nuk = 0, emp = 0, min = 0, hvl = 0},		--2
				{hom = 8,  nuk = 0, emp = 0, min = 0, hvl = 0},		--3
				{hom = 12, nuk = 0, emp = 0, min = 0, hvl = 0},		--4
				{hom = 16, nuk = 0, emp = 0, min = 0, hvl = 0},		--5
				{hom = 20, nuk = 0, emp = 0, min = 0, hvl = 0},		--6
				["stock"] = {hom = 0, nuk = 0, emp = 0, min = 0, hvl = 0},
			},
			["shield"] = {
				{	--1
					{idx = 0, max = 400},
				},
				{	--2
					{idx = 0, max = 600},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 50%"),
				},
				{	--3
					{idx = 0, max = 800},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 1/3"),
				},
				{	--4
					{idx = 0, max = 600},
					{idx = 1, max = 600},
					["desc"] = _("upgrade-comms","add rear arc"),
				},
				{	--5
					{idx = 0, max = 800},
					{idx = 1, max = 800},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 1/3"),
				},
				{	--6
					{idx = 0, max = 1000},
					{idx = 1, max = 1000},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--7
					{idx = 0, max = 1200},
					{idx = 1, max = 1200},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--8
					{idx = 0, max = 1500},
					{idx = 1, max = 1500},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--9
					{idx = 0, max = 1800},
					{idx = 1, max = 1800},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by 20%"),
				},
				["stock"] = {
					{idx = 0, max = 1200},
					{idx = 1, max = 1200},
				},
				["start"] = 2,
			},
			["hull"] = {
				{max = 80},																--1
				{max = 100, ["desc"] = _("upgrade-comms","increase hull max by 25%")},	--2
				{max = 120, ["desc"] = _("upgrade-comms","increase hull max by 20%")},	--3
				{max = 144, ["desc"] = _("upgrade-comms","increase hull max by 20%")},	--4
				{max = 180, ["desc"] = _("upgrade-comms","increase hull max by 25%")},	--5
				{max = 210, ["desc"] = _("upgrade-comms","increase hull max by ~17%")},	--6
				["stock"] = {max = 100},
				["start"] = 3,
			},
			["impulse"] = {
				{	--1
					max_front =		15,		max_back =		15,
					accel_front =	2,		accel_back = 	2,
					turn = 			1,
					boost =			0,		strafe =		0,
				},
				{	--2
					max_front =		18,		max_back =		18,
					accel_front =	2,		accel_back = 	2,
					turn = 			1,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase max impulse speed by 20%"),
				},
				{	--3
					max_front =		18,		max_back =		18,
					accel_front =	3,		accel_back = 	2,
					turn = 			1,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase forward acceleration by 50%"),
				},
				{	--4
					max_front =		18,		max_back =		18,
					accel_front =	3,		accel_back = 	2,
					turn = 			1.5,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase maneuverability by 50%"),
				},
				{	--5
					max_front =		20,		max_back =		20,
					accel_front =	3,		accel_back = 	2,
					turn = 			1.5,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase max impulse by ~11%"),
				},
				{	--6
					max_front =		20,		max_back =		20,
					accel_front =	4,		accel_back = 	2,
					turn = 			1.5,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase forward acceleratione by 1/3"),
				},
				{	--7
					max_front =		20,		max_back =		20,
					accel_front =	4,		accel_back = 	2,
					turn = 			2,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase maneuverability by 1/3"),
				},
				{	--8
					max_front =		24,		max_back =		24,
					accel_front =	4,		accel_back = 	2,
					turn = 			2,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase max impulse speed by 20%"),
				},
				{	--9
					max_front =		24,		max_back =		24,
					accel_front =	6,		accel_back = 	3,
					turn = 			2,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase acceleration by 50%"),
				},
				{	--10
					max_front =		24,		max_back =		24,
					accel_front =	6,		accel_back = 	3,
					turn = 			2.5,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase maneuverability by 25%"),
				},
				{	--11
					max_front =		30,		max_back =		30,
					accel_front =	6,		accel_back = 	3,
					turn = 			2.5,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase max impulse speed by 25%"),
				},
				{	--12
					max_front =		30,		max_back =		30,
					accel_front =	7,		accel_back = 	3,
					turn = 			2.5,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase forward acceleration by ~17%"),
				},
				{	--13
					max_front =		36,		max_back =		30,
					accel_front =	7,		accel_back = 	3,
					turn = 			2.5,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase max forward impulse speed by 20%"),
				},
				{	--14
					max_front =		36,		max_back =		30,
					accel_front =	7,		accel_back = 	3,
					turn = 			3,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase maneuverability by 20%"),
				},
				{	--15
					max_front =		36,		max_back =		30,
					accel_front =	8,		accel_back = 	4,
					turn = 			3,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase acceleration by ~24%"),
				},
				["stock"] = {
					{max_front = 20, turn = 1.5, accel_front = 3, max_back = 20, accel_back = 1.5, boost = 0, strafe = 0},
				},
				["start"] = 4,
			},
			["ftl"] = {
				{	--1
					jump_long = 0, jump_short = 0, warp = 0,
				},
				{	--2
					jump_long = 20000, jump_short = 2000, warp = 0,
					desc = _("upgrade-comms","add 20k jump drive"),
				},
				{	--3
					jump_long = 25000, jump_short = 2500, warp = 0,
					desc = _("upgrade-comms","increase jump range by 25%"),
				},
				{	--4
					jump_long = 30000, jump_short = 3000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 20%"),
				},
				{	--5
					jump_long = 35000, jump_short = 3500, warp = 0,
					desc = _("upgrade-comms","increase jump range by ~16%"),
				},
				{	--6
					jump_long = 40000, jump_short = 4000, warp = 0,
					desc = _("upgrade-comms","increase jump range by ~14%"),
				},
				{	--7
					jump_long = 45000, jump_short = 4500, warp = 0,
					desc = _("upgrade-comms","increase jump range by 12.5%"),
				},
				{	--8
					jump_long = 50000, jump_short = 5000, warp = 0,
					desc = _("upgrade-comms","increase jump range by ~11%"),
				},
				{	--9
					jump_long = 50000, jump_short = 2000, warp = 0,
					desc = _("upgrade-comms","cut minimum jump range to 2 units"),
				},
				["stock"] = {
					{jump_long = 50000, jump_short = 5000, warp = 0},
				},
				["start"] = 2,
			},
			["sensors"] = {
				{	--1
					short = 4000, long = 20000, prox_scan = 0,
				},
				{	--2
					short = 4000, long = 30000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by 50%"),
				},
				{	--3
					short = 5000, long = 30000, prox_scan = 0,
					desc = _("upgrade-comms","increase short range sensors by 25%"),
				},
				{	--4
					short = 5000, long = 35000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by ~17%"),
				},
				{	--5
					short = 5000, long = 40000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by ~14%"),
				},
				{	--6
					short = 5000, long = 45000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by 12.5%"),
				},
				{	--7
					short = 5000, long = 50000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by ~11%"),
				},
				{	--8
					short = 6000, long = 50000, prox_scan = 0,
					desc = _("upgrade-comms","increase short range sensors by 20%"),
				},
				{	--9
					short = 6000, long = 50000, prox_scan = 4,
					desc = _("upgrade-comms","add 4 unit automated proximity scanner"),
				},
				{	--10
					short = 6000, long = 60000, prox_scan = 4,
					desc = _("upgrade-comms","increase long range scan by 20%"),
				},
				{	--11
					short = 6000, long = 70000, prox_scan = 4,
					desc = _("upgrade-comms","increase long range scan by ~17%"),
				},
				{	--12
					short = 6000, long = 80000, prox_scan = 4,
					desc = _("upgrade-comms","increase long range scan by ~14%"),
				},
				["stock"] = {
					{short = 5000, long = 30000}, prox_scan = 0,
				},
				["start"] = 2,
			},
			["providers"] = false,
			["score"] = 36,
		},
		["MP52 Hornet"] = {	--5 + beam(11) + missile(12) + shield(7) + hull(5) + impulse(6) + ftl(9) + sensors(4) = 59
			["beam"] = {
				{	--1
					{idx = 0, arc = 20, dir =   5, rng = 800, cyc = 5, dmg = 2},
					{idx = 1, arc = 20, dir =  -5, rng = 800, cyc = 5, dmg = 2},
				},
				{	--2
					{idx = 0, arc = 20, dir =   5, rng = 900, cyc = 5, dmg = 2},
					{idx = 1, arc = 20, dir =  -5, rng = 900, cyc = 5, dmg = 2},
					["desc"] = _("upgrade-comms","increase range by 25%")
				},
				{	--3
					{idx = 0, arc = 20, dir =   5, rng = 900, cyc = 4, dmg = 2},
					{idx = 1, arc = 20, dir =  -5, rng = 900, cyc = 4, dmg = 2},
					["desc"] = _("upgrade-comms","reduce cycle time by 20%")
				},
				{	--4
					{idx = 0, arc = 20, dir =   5, rng = 900, cyc = 4, dmg = 2.5},
					{idx = 1, arc = 20, dir =  -5, rng = 900, cyc = 4, dmg = 2.5},
					["desc"] = _("upgrade-comms","increase damage by 25%")
				},
				{	--5
					{idx = 0, arc = 30, dir =   5, rng = 900, cyc = 4, dmg = 2.5},
					{idx = 1, arc = 30, dir =  -5, rng = 900, cyc = 4, dmg = 2.5},
					["desc"] = _("upgrade-comms","increase arc width by 50%")
				},
				{	--6
					{idx = 0, arc = 30, dir =   5, rng = 900, cyc = 4, dmg = 3},
					{idx = 1, arc = 30, dir =  -5, rng = 900, cyc = 4, dmg = 3},
					["desc"] = _("upgrade-comms","increase damage by 20%"),
				},
				{	--7
					{idx = 0, arc = 30, dir =   5, rng = 900, cyc = 4, dmg = 3},
					{idx = 1, arc = 30, dir =  -5, rng = 900, cyc = 4, dmg = 3},
					{idx = 2, arc = 20, dir =   0, rng = 800, cyc = 6, dmg = 6},
					["desc"] = _("upgrade-comms","add beam"),
				},
				{	--8
					{idx = 0, arc = 30, dir =   5, rng = 900, cyc = 4, dmg = 3},
					{idx = 1, arc = 30, dir =  -5, rng = 900, cyc = 4, dmg = 3},
					{idx = 2, arc = 20, dir =   0, rng = 800, cyc = 6, dmg = 7},
					["desc"] = _("upgrade-comms","increase damage of short beam by ~17%"),
				},
				{	--9
					{idx = 0, arc = 36, dir =   5, rng = 900, cyc = 4, dmg = 3},
					{idx = 1, arc = 36, dir =  -5, rng = 900, cyc = 4, dmg = 3},
					{idx = 2, arc = 24, dir =   0, rng = 800, cyc = 6, dmg = 7},
					["desc"] = _("upgrade-comms","increase arc width by 20%"),
				},
				{	--10
					{idx = 0, arc = 36, dir =   5, rng = 900, cyc = 4, dmg = 4},
					{idx = 1, arc = 36, dir =  -5, rng = 900, cyc = 4, dmg = 4},
					{idx = 2, arc = 24, dir =   0, rng = 800, cyc = 6, dmg = 7},
					["desc"] = _("upgrade-comms","increase long beam damage by 1/3"),
				},
				{	--11
					{idx = 0, arc = 36, dir =   5, rng = 1000, cyc = 4, dmg = 4},
					{idx = 1, arc = 36, dir =  -5, rng = 1000, cyc = 4, dmg = 4},
					{idx = 2, arc = 24, dir =   0, rng = 800,  cyc = 6, dmg = 7},
					["desc"] = _("upgrade-comms","increase long beam range by ~11%"),
				},
				{	--12
					{idx = 0, arc = 36, dir =   5, rng = 1000, cyc = 4, dmg = 4},
					{idx = 1, arc = 36, dir =  -5, rng = 1000, cyc = 4, dmg = 4},
					{idx = 2, arc = 24, dir =   0, rng = 800,  cyc = 6, dmg = 8},
					["desc"] = _("upgrade-comms","increase short beam damage by ~14%"),
				},
				["stock"] = {
					{idx = 0, arc = 30, dir =   5, rng = 900, cyc = 4, dmg = 2.5},
					{idx = 1, arc = 30, dir =  -5, rng = 900, cyc = 4, dmg = 2.5},
				},
				["start"] = 4,
			},
			["missiles"] = {
				{tube = 1,	ord = 1},																					--1
				{tube = 2,	ord = 2, desc = _("upgrade-comms","add rear HVLI tube")},									--2  
				{tube = 2,	ord = 3, desc = _("upgrade-comms","double HVLI capacity")},									--3  
				{tube = 3,	ord = 3, desc = _("upgrade-comms","reduce tube load time by 25%")},							--4
				{tube = 4,	ord = 3, desc = _("upgrade-comms","make small tube medium sized")},							--5
				{tube = 5,	ord = 3, desc = _("upgrade-comms","reduce tube load time by 20%")},							--6
				{tube = 6,	ord = 3, desc = _("upgrade-comms","add small tube")},										--7
				{tube = 7,	ord = 4, desc = _("upgrade-comms","add homing capability to small tube")},					--8
				{tube = 7,	ord = 5, desc = _("upgrade-comms","double capacity")},										--9
				{tube = 8,	ord = 5, desc = _("upgrade-comms","reduce small tube load time by ~17%")},					--10
				{tube = 8,	ord = 6, desc = _("upgrade-comms","increase homing capacity by 50%")},						--11
				{tube = 9,	ord = 7, desc = _("upgrade-comms","add a mining tube")},									--12
				{tube = 9,	ord = 8, desc = _("upgrade-comms","increase capacity: homing:1/3, mine:100%, HVLI:50%")},	--13
				["start"] = 3
			},
			["tube"] = {
				{	--1
					{idx = -1},
				},
				{	--2
					{idx = 0, dir = 180, siz = "S", spd = 20, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--3
					{idx = 0, dir = 180, siz = "S", spd = 15, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--4
					{idx = 0, dir = 180, siz = "M", spd = 15, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--5
					{idx = 0, dir = 180, siz = "M", spd = 12, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--6
					{idx = 0, dir = 180, siz = "S", spd = 12, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir = 180, siz = "M", spd = 12, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--7
					{idx = 0, dir = 180, siz = "S", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir = 180, siz = "M", spd = 12, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--8
					{idx = 0, dir = 180, siz = "S", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir = 180, siz = "M", spd = 12, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--9
					{idx = 0, dir = 180, siz = "S", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir = 180, siz = "M", spd = 12, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 20, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				["stock"] = {
					{idx = -1},
				},
			},
			["ordnance"] = {
				{hom = 0,  nuk = 0, emp = 0, min = 0, hvl = 0},		--1
				{hom = 0,  nuk = 0, emp = 0, min = 0, hvl = 1},		--2
				{hom = 0,  nuk = 0, emp = 0, min = 0, hvl = 2},		--3
				{hom = 1,  nuk = 0, emp = 0, min = 0, hvl = 2},		--4
				{hom = 2,  nuk = 0, emp = 0, min = 0, hvl = 4},		--5		
				{hom = 3,  nuk = 0, emp = 0, min = 0, hvl = 4},		--6		
				{hom = 3,  nuk = 0, emp = 0, min = 1, hvl = 4},		--7		
				{hom = 4,  nuk = 0, emp = 0, min = 2, hvl = 6},		--8		
				["stock"] = {hom = 0, nuk = 0, emp = 0, min = 0, hvl = 0},
			},
			["shield"] = {
				{	--1
					{idx = 0, max = 40},
				},
				{	--2
					{idx = 0, max = 50},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--3
					{idx = 0, max = 60},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--4
					{idx = 0, max = 80},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 1/3"),
				},
				{	--5
					{idx = 0, max = 50},
					{idx = 1, max = 50},
					["desc"] = _("upgrade-comms","add rear arc"),
				},
				{	--6
					{idx = 0, max = 60},
					{idx = 1, max = 60},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--7
					{idx = 0, max = 80},
					{idx = 1, max = 60},
					["desc"] = _("upgrade-comms","increase front shield charge capacity by 1/3"),
				},
				{	--8
					{idx = 0, max = 96},
					{idx = 1, max = 72},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				["stock"] = {
					{idx = 0, max = 60},
				},
				["start"] = 3,
			},
			["hull"] = {
				{max = 50},																	--1
				{max =  60, ["desc"] = _("upgrade-comms","increase hull max by 20%")},		--2
				{max =  80, ["desc"] = _("upgrade-comms","increase hull max by 1/3")},		--3
				{max = 100, ["desc"] = _("upgrade-comms","increase hull max by 25%")},		--4
				{max = 120, ["desc"] = _("upgrade-comms","increase hull max by 20%")},		--5
				{max = 144, ["desc"] = _("upgrade-comms","increase hull max by 20%")},		--6
				["stock"] = {max = 70},
				["start"] = 2,
			},
			["impulse"] = {
				{	--1
					max_front =		100,	max_back =		100,
					accel_front =	36,		accel_back = 	36,
					turn = 			24,
					boost =			0,		strafe =		0,
				},
				{	--2
					max_front =		120,	max_back =		120,
					accel_front =	36,		accel_back = 	36,
					turn = 			24,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase max impulse speed by 20%"),
				},
				{	--3
					max_front =		120,	max_back =		120,
					accel_front =	42,		accel_back = 	36,
					turn = 			24,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase forward acceleration by ~17%"),
				},
				{	--4
					max_front =		120,	max_back =		120,
					accel_front =	42,		accel_back = 	36,
					turn = 			30,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase maneuverability by 25%"),
				},
				{	--5
					max_front =		120,	max_back =		120,
					accel_front =	42,		accel_back = 	36,
					turn = 			30,
					boost =			600,		strafe =		0,
					desc = _("upgrade-comms","add combat maneuver boost"),
				},
				{	--6
					max_front =		132,	max_back =		120,
					accel_front =	42,		accel_back = 	36,
					turn = 			30,
					boost =			600,		strafe =		0,
					desc = _("upgrade-comms","increase forward max impulse speed by 10%"),
				},
				{	--7
					max_front =		132,	max_back =		120,
					accel_front =	42,		accel_back = 	36,
					turn = 			33,
					boost =			600,		strafe =		0,
					desc = _("upgrade-comms","increase maneuverability by 10%"),
				},
				["stock"] = {
					{max_front = 125, turn = 32, accel_front = 40, max_back = 125, accel_back = 40, boost = 600, strafe = 0},
				},
				["start"] = 2,
			},
			["ftl"] = {
				{	--1
					jump_long = 0, jump_short = 0, warp = 0,
				},
				{	--2
					jump_long = 0, jump_short = 0, warp = 400,
					desc = _("upgrade-comms","add warp drive"),
				},
				{	--3
					jump_long = 20000, jump_short = 2000, warp = 400,
					desc = _("upgrade-comms","add 20k jump drive"),
				},
				{	--4
					jump_long = 20000, jump_short = 2000, warp = 500,
					desc = _("upgrade-comms","increase warp speed by 25%"),
				},
				{	--5
					jump_long = 25000, jump_short = 2500, warp = 500,
					desc = _("upgrade-comms","increase jump range by 25%"),
				},
				{	--6
					jump_long = 25000, jump_short = 2500, warp = 600,
					desc = _("upgrade-comms","increase warp speed by 20%"),
				},
				{	--7
					jump_long = 30000, jump_short = 3000, warp = 600,
					desc = _("upgrade-comms","increase jump range by 20%"),
				},
				{	--8
					jump_long = 30000, jump_short = 3000, warp = 700,
					desc = _("upgrade-comms","increase warp speed by ~17%"),
				},
				{	--9
					jump_long = 35000, jump_short = 3500, warp = 700,
					desc = _("upgrade-comms","increase jump range by ~17%"),
				},
				{	--10
					jump_long = 35000, jump_short = 3500, warp = 800,
					desc = _("upgrade-comms","increase warp speed by ~14%"),
				},
				["stock"] = {
					{jump_long = 0, jump_short = 0, warp = 0},
				},
				["start"] = 2,
			},
			["sensors"] = {
				{	--1
					short = 4000, long = 20000, prox_scan = 0,
				},
				{	--2
					short = 4000, long = 20000, prox_scan = 2,
					desc = _("upgrade-comms","add 2 unit automated proximity scanner"),
				},
				{	--3
					short = 5000, long = 20000, prox_scan = 2,
					desc = _("upgrade-comms","increase short range sensors by 25%"),
				},
				{	--4
					short = 5000, long = 30000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by 50%"),
				},
				{	--5
					short = 5000, long = 30000, prox_scan = 4,
					desc = _("upgrade-comms","double automated proximity scanner range"),
				},
				["stock"] = {
					{short = 5000, long = 30000}, prox_scan = 0,
				},
				["start"] = 2,
			},
			["providers"] = false,
			["score"] = 16,
		},
		["ZX-Lindworm"] = {	--5 + beam(8) + missile(16) + shield(5) + hull(5) + impulse(9) + ftl(9) + sensors(5) = 62
			["beam"] = {
				{	--1
					{idx = 0, arc = 10, dir = 180, rng =  700, cyc = 8, dmg = 2, tar =  90, tdr = 180, trt = 1},
				},
				{	--2
					{idx = 0, arc = 10, dir = 180, rng =  700, cyc = 8, dmg = 2, tar = 180, tdr = 180, trt = 1},
					["desc"] = _("upgrade-comms","double arc width"),
				},
				{	--3
					{idx = 0, arc = 10, dir = 180, rng =  700, cyc = 8, dmg = 2, tar = 180, tdr = 180, trt = 2},
					["desc"] = _("upgrade-comms","double turret speed"),
				},
				{	--4
					{idx = 0, arc = 10, dir = 180, rng =  700, cyc = 8, dmg = 2, tar = 270, tdr = 180, trt = 2},
					["desc"] = _("upgrade-comms","increase arc width by 50%"),
				},
				{	--5
					{idx = 0, arc = 10, dir = 180, rng =  700, cyc = 6, dmg = 2, tar = 270, tdr = 180, trt = 2},
					["desc"] = _("upgrade-comms","reduce cycle time by 25%"),
				},
				{	--6
					{idx = 0, arc = 10, dir =   0, rng =  700, cyc = 6, dmg = 2, tar = 270, tdr =   0, trt = 2},
					{idx = 1, arc = 10, dir = 180, rng =  700, cyc = 6, dmg = 2, tar = 270, tdr = 180, trt = 2},
					["desc"] = _("upgrade-comms","add beam"),
				},
				{	--7
					{idx = 0, arc = 10, dir =   0, rng =  700, cyc = 6, dmg = 2, tar = 270, tdr =   0, trt = 3},
					{idx = 1, arc = 10, dir = 180, rng =  700, cyc = 6, dmg = 2, tar = 270, tdr = 180, trt = 3},
					["desc"] = _("upgrade-comms","increase turret speed by 50%"),
				},
				{	--8
					{idx = 0, arc = 10, dir =   0, rng =  800, cyc = 6, dmg = 2, tar = 200, tdr =   0, trt = 3},
					{idx = 1, arc = 10, dir = 180, rng =  800, cyc = 6, dmg = 2, tar = 200, tdr = 180, trt = 3},
					["desc"] = _("upgrade-comms","increase range by ~14%, decrease arc width by ~26%"),
				},
				{	--9
					{idx = 0, arc = 10, dir =   0, rng =  800, cyc = 6, dmg = 3, tar = 200, tdr =   0, trt = 3},
					{idx = 1, arc = 10, dir = 180, rng =  800, cyc = 6, dmg = 3, tar = 200, tdr = 180, trt = 3},
					["desc"] = _("upgrade-comms","increase damage by 50%"),
				},
				["stock"] = {
					{idx = 0, arc = 10, dir = 180, rng =  700, cyc = 6, dmg = 2, tar = 270, tdr = 180, trt = 2},
				},
				["start"] = 2,
			},
			["missiles"] = {
				{tube = 1,	ord = 1},														--1
				{tube = 1,	ord = 2, desc = _("upgrade-comms","increase HVLI capacity by 25%")},				--2  
				{tube = 2,	ord = 3, desc = _("upgrade-comms","add homing capability")},						--3  
				{tube = 2,	ord = 4, desc = _("upgrade-comms","increase HVLI capacity by 20%")},				--4
				{tube = 3,	ord = 5, desc = _("upgrade-comms","add two small HVLI tubes, increase HVLI capacity by 1/3")},	--5
				{tube = 4,	ord = 5, desc = _("upgrade-comms","reduce tube load speed by ~17%")},				--6
				{tube = 5,	ord = 5, desc = _("upgrade-comms","increase HVLI capacity by 25%")},				--7
				{tube = 5,	ord = 5, desc = _("upgrade-comms","add two more small HVLI tubes")},				--8
				{tube = 5,	ord = 6, desc = _("upgrade-comms","increase capacity: homing:100%, HVLI:25%")},	--9
				{tube = 6,	ord = 6, desc = _("upgrade-comms","make central tube medium sized")},				--10
				{tube = 7,	ord = 6, desc = _("upgrade-comms","reduce small tube load time by 20%")},			--11
				{tube = 7,	ord = 7, desc = _("upgrade-comms","increase capacity: homing:50%, HVLI:20%")},		--12
				{tube = 8,	ord = 7, desc = _("upgrade-comms","reduce tube load time by ~23%")},				--13
				{tube = 8,	ord = 8, desc = _("upgrade-comms","increase HVLI capacity by ~17%")},				--14
				{tube = 9,	ord = 8, desc = _("upgrade-comms","add two more small HVLI tubes")},				--15
				{tube = 9,	ord = 9, desc = _("upgrade-comms","increase HVLI capacity by ~14%")},				--16
				{tube = 9,	ord = 10,desc = _("upgrade-comms","increase capacity: homing:1/3, HVLI:25%")},		--17
				["start"] = 5,
			},
			["tube"] = {
				{	--1
					{idx = 0, dir =   0, siz = "S", spd = 18, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--2
					{idx = 0, dir =   0, siz = "S", spd = 18, hom = true,  nuk = false, emp = false, min = false, hvl = true },
				},
				{	--3
					{idx = 0, dir =   0, siz = "S", spd = 18, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   1, siz = "S", spd = 18, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir =  -1, siz = "S", spd = 18, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--4
					{idx = 0, dir =   0, siz = "S", spd = 15, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   1, siz = "S", spd = 15, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir =  -1, siz = "S", spd = 15, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--5
					{idx = 0, dir =   0, siz = "S", spd = 15, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   1, siz = "S", spd = 15, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir =  -1, siz = "S", spd = 15, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 3, dir =   2, siz = "S", spd = 15, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 4, dir =  -2, siz = "S", spd = 15, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--6
					{idx = 0, dir =   0, siz = "M", spd = 15, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   1, siz = "S", spd = 15, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir =  -1, siz = "S", spd = 15, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 3, dir =   2, siz = "S", spd = 15, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 4, dir =  -2, siz = "S", spd = 15, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--7
					{idx = 0, dir =   0, siz = "M", spd = 15, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   1, siz = "S", spd = 12, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir =  -1, siz = "S", spd = 12, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 3, dir =   2, siz = "S", spd = 12, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 4, dir =  -2, siz = "S", spd = 12, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--8
					{idx = 0, dir =   0, siz = "M", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   1, siz = "S", spd = 9,  hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir =  -1, siz = "S", spd = 9,  hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 3, dir =   2, siz = "S", spd = 9,  hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 4, dir =  -2, siz = "S", spd = 9,  hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--9
					{idx = 0, dir =   0, siz = "M", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   1, siz = "S", spd = 9,  hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir =  -1, siz = "S", spd = 9,  hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 3, dir =   2, siz = "S", spd = 9,  hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 4, dir =  -2, siz = "S", spd = 9,  hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 5, dir =   3, siz = "S", spd = 9,  hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 6, dir =  -3, siz = "S", spd = 9,  hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				["stock"] = {
					{idx = 0, dir =   0, siz = "S", spd = 10, hom = true, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   1, siz = "S", spd = 10, hom = false,nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir =  -1, siz = "S", spd = 10, hom = false,nuk = false, emp = false, min = false, hvl = true },
				},
			},
			["ordnance"] = {
				{hom = 0,  nuk = 0, emp = 0, min = 0, hvl = 4},		--1
				{hom = 0,  nuk = 0, emp = 0, min = 0, hvl = 5},		--2
				{hom = 1,  nuk = 0, emp = 0, min = 0, hvl = 5},		--3
				{hom = 1,  nuk = 0, emp = 0, min = 0, hvl = 6},		--4		
				{hom = 1,  nuk = 0, emp = 0, min = 0, hvl = 8},		--5		
				{hom = 2,  nuk = 0, emp = 0, min = 0, hvl = 10},	--6		
				{hom = 3,  nuk = 0, emp = 0, min = 0, hvl = 12},	--7		
				{hom = 3,  nuk = 0, emp = 0, min = 0, hvl = 14},	--8	
				{hom = 3,  nuk = 0, emp = 0, min = 0, hvl = 16},	--9
				{hom = 4,  nuk = 0, emp = 0, min = 0, hvl = 20},	--10	
				["stock"] = {hom = 1, nuk = 0, emp = 0, min = 0, hvl = 4},
			},
			["shield"] = {
				{	--1
					{idx = 0, max = 30},
				},
				{	--2
					{idx = 0, max = 40},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 1/3"),
				},
				{	--3
					{idx = 0, max = 60},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 50%"),
				},
				{	--4
					{idx = 0, max = 80},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 1/3"),
				},
				{	--5
					{idx = 0, max = 60},
					{idx = 1, max = 60},
					["desc"] = _("upgrade-comms","add rear arc"),
				},
				{	--6
					{idx = 0, max = 80},
					{idx = 1, max = 80},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 1/3"),
				},
				["stock"] = {
					{idx = 0, max = 40},
				},
				["start"] = 2,
			},
			["hull"] = {
				{max = 50},												--1
				{max =  60, ["desc"] = _("upgrade-comms","increase hull max by 20%")},		--2
				{max =  80, ["desc"] = _("upgrade-comms","increase hull max by 1/3")},		--3
				{max = 100, ["desc"] = _("upgrade-comms","increase hull max by 25%")},		--4
				{max = 120, ["desc"] = _("upgrade-comms","increase hull max by 20%")},		--5
				{max = 150, ["desc"] = _("upgrade-comms","increase hull max by 25%")},		--6
				["stock"] = {max = 75},
				["start"] = 3,
			},
			["impulse"] = {
				{	--1
					max_front =		60,		max_back =		60,
					accel_front =	20,		accel_back = 	20,
					turn = 			12,
					boost =			0,		strafe =		0,
				},
				{	--2
					max_front =		70,		max_back =		70,
					accel_front =	20,		accel_back = 	20,
					turn = 			12,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase max impulse speed by ~17%"),
				},
				{	--3
					max_front =		70,		max_back =		70,
					accel_front =	20,		accel_back = 	25,
					turn = 			12,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase rear acceleration by 25%"),
				},
				{	--4
					max_front =		70,		max_back =		80,
					accel_front =	20,		accel_back = 	25,
					turn = 			12,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase max rear impulse by ~15%"),
				},
				{	--5
					max_front =		70,		max_back =		80,
					accel_front =	20,		accel_back = 	25,
					turn = 			12,
					boost =			250,	strafe =		150,
					desc = _("upgrade-comms","add combat maneuver"),
				},
				{	--6
					max_front =		70,		max_back =		80,
					accel_front =	20,		accel_back = 	25,
					turn = 			15,
					boost =			250,	strafe =		150,
					desc = _("upgrade-comms","increase maneuverability by 25%"),
				},
				{	--7
					max_front =		70,		max_back =		80,
					accel_front =	20,		accel_back = 	25,
					turn = 			15,
					boost =			300,	strafe =		180,
					desc = _("upgrade-comms","increase combat maneuver by 20%"),
				},
				{	--8
					max_front =		84,		max_back =		96,
					accel_front =	20,		accel_back = 	25,
					turn = 			15,
					boost =			300,	strafe =		180,
					desc = _("upgrade-comms","increase max impulse by 20%"),
				},
				{	--9
					max_front =		84,		max_back =		96,
					accel_front =	24,		accel_back = 	30,
					turn = 			15,
					boost =			300,	strafe =		180,
					desc = _("upgrade-comms","increase acceleration by 20%"),
				},
				{	--10
					max_front =		84,		max_back =		96,
					accel_front =	24,		accel_back = 	30,
					turn = 			20,
					boost =			300,	strafe =		180,
					desc = _("upgrade-comms","increase maneuverability by 1/3"),
				},
				["stock"] = {
					{max_front = 70, turn = 15, accel_front = 25, max_back = 70, accel_back = 25, boost = 250, strafe = 150},
				},
				["start"] = 4,
			},
			["ftl"] = {
				{	--1
					jump_long = 0, jump_short = 0, warp = 0,
				},
				{	--2
					jump_long = 0, jump_short = 0, warp = 400,
					desc = _("upgrade-comms","add warp drive"),
				},
				{	--3
					jump_long = 20000, jump_short = 2000, warp = 400,
					desc = _("upgrade-comms","add 20k jump drive"),
				},
				{	--4
					jump_long = 20000, jump_short = 2000, warp = 500,
					desc = _("upgrade-comms","increase warp speed by 25%"),
				},
				{	--5
					jump_long = 25000, jump_short = 2500, warp = 500,
					desc = _("upgrade-comms","increase jump range by 25%"),
				},
				{	--6
					jump_long = 25000, jump_short = 2500, warp = 600,
					desc = _("upgrade-comms","increase warp speed by 20%"),
				},
				{	--7
					jump_long = 30000, jump_short = 3000, warp = 600,
					desc = _("upgrade-comms","increase jump range by 20%"),
				},
				{	--8
					jump_long = 30000, jump_short = 3000, warp = 700,
					desc = _("upgrade-comms","increase warp speed by ~17%"),
				},
				{	--9
					jump_long = 35000, jump_short = 3500, warp = 700,
					desc = _("upgrade-comms","increase jump range by ~17%"),
				},
				{	--10
					jump_long = 35000, jump_short = 3500, warp = 800,
					desc = _("upgrade-comms","increase warp speed by ~14%"),
				},
				["stock"] = {
					{jump_long = 0, jump_short = 0, warp = 0},
				},
				["start"] = 2,
			},
			["sensors"] = {
				{	--1
					short = 4000, long = 20000, prox_scan = 0,
				},
				{	--2
					short = 4000, long = 20000, prox_scan = 2,
					desc = _("upgrade-comms","add 2 unit automated proximity scanner"),
				},
				{	--3
					short = 5000, long = 20000, prox_scan = 2,
					desc = _("upgrade-comms","increase short range sensors by 25%"),
				},
				{	--4
					short = 5000, long = 30000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by 50%"),
				},
				{	--5
					short = 5000, long = 30000, prox_scan = 4,
					desc = _("upgrade-comms","double automated proximity scanner range"),
				},
				{	--6
					short = 5000, long = 40000, prox_scan = 4,
					desc = _("upgrade-comms","increase long range sensors by 1/3"),
				},
				["stock"] = {
					{short = 5000, long = 30000}, prox_scan = 0,
				},
				["start"] = 2,
			},
			["providers"] = false,
			["score"] = 18,
		},
		["Amalgam"] = {		--9 + beam(7) + missile(10) + shield(7) + hull(6) + impulse(8) + ftl(6) + sensors(4) = 57
			["beam"] = {
				{	--1
					{idx = 0, arc =  60, dir = -20, rng = 1000, cyc = 8, dmg = 6},
					{idx = 1, arc =  60, dir =  20, rng = 1000, cyc = 8, dmg = 6},
				},
				{	--2
					{idx = 0, arc =  60, dir = -20, rng = 1200, cyc = 8, dmg = 6},
					{idx = 1, arc =  60, dir =  20, rng = 1200, cyc = 8, dmg = 6},
					["desc"] = _("upgrade-comms","increase range by 25%"),
				},
				{	--3
					{idx = 0, arc =  90, dir = -20, rng = 1200, cyc = 8, dmg = 6},
					{idx = 1, arc =  90, dir =  20, rng = 1200, cyc = 8, dmg = 6},
					["desc"] = _("upgrade-comms","increase arc by 50%"),
				},
				{	--4
					{idx = 0, arc =  90, dir = -20, rng = 1200, cyc = 8, dmg = 6},
					{idx = 1, arc =  90, dir =  20, rng = 1200, cyc = 8, dmg = 6},
					{idx = 2, arc =  10, dir = -60, rng = 1000, cyc = 6, dmg = 4, tar =  60, tdr = -60, trt = .6},
					{idx = 3, arc =  10, dir =  60, rng = 1000, cyc = 6, dmg = 4, tar =  60, tdr =  60, trt = .6},
					["desc"] = _("upgrade-comms","add beams"),
				},
				{	--5
					{idx = 0, arc =  90, dir = -20, rng = 1200, cyc = 8, dmg = 8},
					{idx = 1, arc =  90, dir =  20, rng = 1200, cyc = 8, dmg = 8},
					{idx = 2, arc =  10, dir = -60, rng = 1000, cyc = 6, dmg = 6, tar =  60, tdr = -60, trt = .6},
					{idx = 3, arc =  10, dir =  60, rng = 1000, cyc = 6, dmg = 6, tar =  60, tdr =  60, trt = .6},
					["desc"] = _("upgrade-comms","increase damage by ~42%"),
				},
				{	--6
					{idx = 0, arc =  90, dir = -20, rng = 1200, cyc = 8, dmg = 8},
					{idx = 1, arc =  90, dir =  20, rng = 1200, cyc = 8, dmg = 8},
					{idx = 2, arc =  10, dir = -60, rng = 1000, cyc = 6, dmg = 6, tar =  60, tdr = -60, trt = .6},
					{idx = 3, arc =  10, dir =  60, rng = 1000, cyc = 6, dmg = 6, tar =  60, tdr =  60, trt = .6},
					{idx = 4, arc =  10, dir =   0, rng =  800, cyc = 8, dmg = 4, tar = 130, tdr =   0, trt = .6},
					{idx = 5, arc =  10, dir = 120, rng =  800, cyc = 8, dmg = 4, tar = 130, tdr = 120, trt = .6},
					{idx = 6, arc =  10, dir = 240, rng =  800, cyc = 8, dmg = 4, tar = 130, tdr = 240, trt = .6},
					["desc"] = _("upgrade-comms","add beams"),
				},
				{	--7
					{idx = 0, arc =  90, dir = -20, rng = 1200, cyc = 8, dmg = 8},
					{idx = 1, arc =  90, dir =  20, rng = 1200, cyc = 8, dmg = 8},
					{idx = 2, arc =  10, dir = -60, rng = 1000, cyc = 6, dmg = 6, tar =  60, tdr = -60, trt = 1},
					{idx = 3, arc =  10, dir =  60, rng = 1000, cyc = 6, dmg = 6, tar =  60, tdr =  60, trt = 1},
					{idx = 4, arc =  10, dir =   0, rng =  800, cyc = 8, dmg = 4, tar = 130, tdr =   0, trt = 1},
					{idx = 5, arc =  10, dir = 120, rng =  800, cyc = 8, dmg = 4, tar = 130, tdr = 120, trt = 1},
					{idx = 6, arc =  10, dir = 240, rng =  800, cyc = 8, dmg = 4, tar = 130, tdr = 240, trt = 1},
					["desc"] = _("upgrade-comms","increase turret speed by 2/3"),
				},
				{	--8
					{idx = 0, arc =  90, dir = -20, rng = 1200, cyc = 6, dmg = 8},
					{idx = 1, arc =  90, dir =  20, rng = 1200, cyc = 6, dmg = 8},
					{idx = 2, arc =  10, dir = -60, rng = 1000, cyc = 4, dmg = 6, tar =  60, tdr = -60, trt = 1},
					{idx = 3, arc =  10, dir =  60, rng = 1000, cyc = 4, dmg = 6, tar =  60, tdr =  60, trt = 1},
					{idx = 4, arc =  10, dir =   0, rng =  800, cyc = 6, dmg = 4, tar = 130, tdr =   0, trt = 1},
					{idx = 5, arc =  10, dir = 120, rng =  800, cyc = 6, dmg = 4, tar = 130, tdr = 120, trt = 1},
					{idx = 6, arc =  10, dir = 240, rng =  800, cyc = 6, dmg = 4, tar = 130, tdr = 240, trt = 1},
					["desc"] = _("upgrade-comms","decrease cycle time by ~24%"),
				},
				["stock"] = {
					{idx = 0, arc =  90, dir = -20, rng = 1200, cyc = 6, dmg = 8},
					{idx = 1, arc =  90, dir =  20, rng = 1200, cyc = 6, dmg = 8},
					{idx = 2, arc =  10, dir = -60, rng = 1000, cyc = 4, dmg = 6, tar =  60, tdr = -60, trt = .6},
					{idx = 3, arc =  10, dir =  60, rng = 1000, cyc = 4, dmg = 6, tar =  60, tdr =  60, trt = .6},
				},
				["start"] = 4,
			},
			["missiles"] = {
				{tube = 1,	ord = 1},																		--1
				{tube = 2,	ord = 1, desc = _("upgrade-comms","make broadside tubes medium sized")},		--2  
				{tube = 2,	ord = 2, desc = _("upgrade-comms","increase homing capacity by 50%")},			--3  
				{tube = 3,	ord = 3, desc = _("upgrade-comms","add a mine tube and mine")},					--4
				{tube = 4,	ord = 3, desc = _("upgrade-comms","decrease broadside load times by ~17%")},	--5
				{tube = 4,	ord = 4, desc = _("upgrade-comms","double missile capacity")},					--6
				{tube = 5,	ord = 4, desc = _("upgrade-comms","make broadside tubes large sized")},			--7
				{tube = 5,	ord = 5, desc = _("upgrade-comms","increase mine capacity by 50%")},			--8
				{tube = 6,	ord = 5, desc = _("upgrade-comms","decrease broadside load time by 20%")},		--9
				{tube = 6,	ord = 6, desc = _("upgrade-comms","increase missile capacity by 1/3")},			--10
				{tube = 6,	ord = 7, desc = _("upgrade-comms","increase missile capacity by 25%")},			--11
				["start"] = 4,
			},
			["tube"] = {
				{	--1
					{idx = 0, dir = -90, siz = "S", spd = 12,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir =  90, siz = "S", spd = 12,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 2, dir = 180, siz = "M", spd = 16,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--2
					{idx = 0, dir = -90, siz = "M", spd = 12,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir =  90, siz = "M", spd = 12,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 2, dir = 180, siz = "M", spd = 16,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--3
					{idx = 0, dir = -90, siz = "M", spd = 12,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir =  90, siz = "M", spd = 12,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 2, dir = 180, siz = "M", spd = 16,hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 3, dir = 180, siz = "M", spd = 16,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--4
					{idx = 0, dir = -90, siz = "M", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir =  90, siz = "M", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 2, dir = 180, siz = "M", spd = 16,hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 3, dir = 180, siz = "M", spd = 16,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--5
					{idx = 0, dir = -90, siz = "L", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir =  90, siz = "L", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 2, dir = 180, siz = "M", spd = 16,hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 3, dir = 180, siz = "M", spd = 16,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--6
					{idx = 0, dir = -90, siz = "L", spd = 8, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir =  90, siz = "L", spd = 8, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 2, dir = 180, siz = "M", spd = 16,hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 3, dir = 180, siz = "M", spd = 16,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				["stock"] = {
					{idx = 0, dir = -90, siz = "L", spd = 8, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir =  90, siz = "L", spd = 8, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 2, dir = 180, siz = "M", spd = 16,hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 3, dir = 180, siz = "M", spd = 16,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
			},
			["ordnance"] = {
				{hom = 4,  nuk = 0, emp = 0, min = 1, hvl = 0},		--1
				{hom = 6,  nuk = 0, emp = 0, min = 1, hvl = 0},		--2
				{hom = 6,  nuk = 0, emp = 0, min = 2, hvl = 0},		--3
				{hom = 12, nuk = 0, emp = 0, min = 4, hvl = 0},		--4
				{hom = 12, nuk = 0, emp = 0, min = 6, hvl = 0},		--5
				{hom = 16, nuk = 0, emp = 0, min = 8, hvl = 0},		--6
				{hom = 20, nuk = 0, emp = 0, min = 10,hvl = 0},		--7
				["stock"] = {hom = 16, nuk = 0, emp = 0, min = 10, hvl = 0},
			},
			["shield"] = {
				{	--1
					{idx = 0, max = 70},
				},
				{	--2
					{idx = 0, max = 90},
					["desc"] = _("upgrade-comms","increase shield charge capacity by ~28%"),
				},
				{	--3
					{idx = 0, max = 120},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 1/3"),
				},
				{	--4
					{idx = 0, max = 80},
					{idx = 1, max = 80},
					["desc"] = _("upgrade-comms","add rear shield arc"),
				},
				{	--5
					{idx = 0, max = 100},
					{idx = 1, max = 100},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--6
					{idx = 0, max = 120},
					{idx = 1, max = 120},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--7
					{idx = 0, max = 150},
					{idx = 1, max = 150},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--8
					{idx = 0, max = 180},
					{idx = 1, max = 180},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				["stock"] = {
					{idx = 0, max = 150},
					{idx = 1, max = 150},
				},
				["start"] = 3
			},
			["hull"] = {
				{max = 80},												--1
				{max = 100, ["desc"] = _("upgrade-comms","increase hull max by 25%")},		--2
				{max = 120, ["desc"] = _("upgrade-comms","increase hull max by 20%")},		--3
				{max = 150, ["desc"] = _("upgrade-comms","increase hull max by 25%")},		--4
				{max = 180, ["desc"] = _("upgrade-comms","increase hull max by 20%")},		--5
				{max = 250, ["desc"] = _("upgrade-comms","increase hull max by ~39%")},	--6
				{max = 275, ["desc"] = _("upgrade-comms","increase hull max by 10%")},		--7
				["stock"] = {max = 250},
				["start"] = 4,
			},
			["impulse"] = {
				{	--1
					max_front =		70,		max_back =		70,
					accel_front =	15,		accel_back = 	15,
					turn = 			6,
					boost =			0,		strafe =		0,
				},
				{	--2
					max_front =		70,		max_back =		80,
					accel_front =	15,		accel_back = 	15,
					turn = 			6,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase max reverse impulse speed by ~14%"),
				},
				{	--3
					max_front =		70,		max_back =		80,
					accel_front =	15,		accel_back = 	20,
					turn = 			6,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase rear acceleration by 1/3"),
				},
				{	--4
					max_front =		70,		max_back =		80,
					accel_front =	15,		accel_back = 	20,
					turn = 			8,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase maneuverability by 1/3"),
				},
				{	--5
					max_front =		70,		max_back =		80,
					accel_front =	15,		accel_back = 	20,
					turn = 			8,
					boost =			300,	strafe =		200,
					desc = _("upgrade-comms","add combat maneuver"),
				},
				{	--6
					max_front =		77,		max_back =		88,
					accel_front =	15,		accel_back = 	20,
					turn = 			8,
					boost =			300,	strafe =		200,
					desc = _("upgrade-comms","increase max impulse speed by 10%"),
				},
				{	--7
					max_front =		77,		max_back =		88,
					accel_front =	15,		accel_back = 	20,
					turn = 			8,
					boost =			450,	strafe =		300,
					desc = _("upgrade-comms","increase combat maneuver by 50%"),
				},
				{	--8
					max_front =		77,		max_back =		88,
					accel_front =	18,		accel_back = 	24,
					turn = 			8,
					boost =			450,	strafe =		300,
					desc = _("upgrade-comms","increase acceleration by 20%"),
				},
				{	--9
					max_front =		77,		max_back =		88,
					accel_front =	18,		accel_back = 	24,
					turn = 			10,
					boost =			450,	strafe =		300,
					desc = _("upgrade-comms","increase maneuverability by 25%"),
				},
				["stock"] = {
					{max_front = 80, turn = 8, accel_front = 20, max_back = 80, accel_back = 20, boost = 400, strafe = 250},
				},
				["start"] = 5,
			},
			["ftl"] = {
				{	--1
					jump_long = 0, jump_short = 0, warp = 0,
				},
				{	--2
					jump_long = 20000, jump_short = 2000, warp = 0,
					desc = _("upgrade-comms","add 20k jump drive"),
				},
				{	--3
					jump_long = 25000, jump_short = 2500, warp = 0,
					desc = _("upgrade-comms","increase jump range by 25%"),
				},
				{	--4
					jump_long = 30000, jump_short = 3000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 20%"),
				},
				{	--5
					jump_long = 40000, jump_short = 4000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 1/3"),
				},
				{	--6
					jump_long = 50000, jump_short = 5000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 25%"),
				},
				{	--7
					jump_long = 50000, jump_short = 5000, warp = 450,
					desc = _("upgrade-comms","add warp drive"),
				},
				["stock"] = {
					{jump_long = 40000, jump_short = 4000, warp = 0},
				},
				["start"] = 2,
			},
			["sensors"] = {
				{	--1
					short = 5000, long = 20000, prox_scan = 0,
				},
				{	--2
					short = 5000, long = 20000, prox_scan = 2,
					desc = _("upgrade-comms","add 2 unit automated proximity scanner"),
				},
				{	--3
					short = 5000, long = 30000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by 50%"),
				},
				{	--4
					short = 5000, long = 30000, prox_scan = 4,
					desc = _("upgrade-comms","double automated proximity scanner range"),
				},
				{	--5
					short = 5000, long = 36000, prox_scan = 4,
					desc = _("upgrade-comms","increase long range sensors by 20%"),
				},
				["stock"] = {
					{short = 5000, long = 36000}, prox_scan = 0,
				},
				["start"] = 3,
			},
			["providers"] = false,
			["score"] = 27,
		},
		["Midian"] = {		--8 + beam(10) + missile(16) + shield(8) + hull(6) + impulse(8) + ftl(5) + sensors(5) = 66
			["beam"] = {
				{	--1
					{idx = 0, arc =  10, dir = 180, rng =  800, cyc = 6, dmg = 2, tar =  90, tdr = 180, trt = .2},
				},
				{	--2
					{idx = 0, arc =  10, dir = 180, rng = 1000, cyc = 6, dmg = 2, tar =  90, tdr = 180, trt = .2},
					["desc"] = _("upgrade-comms","increase range by 25%"),
				},
				{	--3
					{idx = 0, arc =  10, dir = 180, rng = 1000, cyc = 6, dmg = 2, tar = 120, tdr = 180, trt = .2},
					["desc"] = _("upgrade-comms","increase arc by 1/3"),
				},
				{	--4
					{idx = 0, arc =  40, dir = -20, rng =  800, cyc = 6, dmg = 2},
					{idx = 1, arc =  40, dir =  20, rng =  800, cyc = 6, dmg = 2},
					{idx = 2, arc =  10, dir = 180, rng = 1000, cyc = 6, dmg = 2, tar = 120, tdr = 180, trt = .2},
					["desc"] = _("upgrade-comms","add beams"),
				},
				{	--5
					{idx = 0, arc =  40, dir = -20, rng =  800, cyc = 6, dmg = 4},
					{idx = 1, arc =  40, dir =  20, rng =  800, cyc = 6, dmg = 4},
					{idx = 2, arc =  10, dir = 180, rng = 1000, cyc = 6, dmg = 2, tar = 120, tdr = 180, trt = .2},
					["desc"] = _("upgrade-comms","increase front damage by 50%"),
				},
				{	--6
					{idx = 0, arc =  40, dir = -20, rng = 1000, cyc = 6, dmg = 4},
					{idx = 1, arc =  40, dir =  20, rng = 1000, cyc = 6, dmg = 4},
					{idx = 2, arc =  10, dir = 180, rng = 1000, cyc = 6, dmg = 2, tar = 120, tdr = 180, trt = .2},
					["desc"] = _("upgrade-comms","increase front range by 25%"),
				},
				{	--7
					{idx = 0, arc =  50, dir = -20, rng = 1000, cyc = 6, dmg = 4},
					{idx = 1, arc =  50, dir =  20, rng = 1000, cyc = 6, dmg = 4},
					{idx = 2, arc =  10, dir = 180, rng = 1000, cyc = 6, dmg = 2, tar = 150, tdr = 180, trt = .2},
					["desc"] = _("upgrade-comms","increase arc by 25%"),
				},
				{	--8
					{idx = 0, arc =  50, dir = -20, rng = 1000, cyc = 6, dmg = 4},
					{idx = 1, arc =  50, dir =  20, rng = 1000, cyc = 6, dmg = 4},
					{idx = 2, arc =  10, dir = 180, rng = 1000, cyc = 6, dmg = 2, tar = 200, tdr = 180, trt = .2},
					["desc"] = _("upgrade-comms","increase rear arc by 1/3"),
				},
				{	--9
					{idx = 0, arc =  50, dir = -20, rng = 1000, cyc = 6, dmg = 4},
					{idx = 1, arc =  50, dir =  20, rng = 1000, cyc = 6, dmg = 4},
					{idx = 2, arc =  10, dir = 180, rng = 1000, cyc = 6, dmg = 2, tar = 200, tdr = 180, trt = .3},
					["desc"] = _("upgrade-comms","increase turret speed by 50%"),
				},
				{	--10
					{idx = 0, arc =  50, dir = -20, rng = 1000, cyc = 5, dmg = 4},
					{idx = 1, arc =  50, dir =  20, rng = 1000, cyc = 5, dmg = 4},
					{idx = 2, arc =  10, dir = 180, rng = 1000, cyc = 5, dmg = 2, tar = 200, tdr = 180, trt = .3},
					["desc"] = _("upgrade-comms","reduce cycle time by ~17%"),
				},
				{	--11
					{idx = 0, arc =  50, dir = -20, rng = 1000, cyc = 5, dmg = 8},
					{idx = 1, arc =  50, dir =  20, rng = 1000, cyc = 5, dmg = 8},
					{idx = 2, arc =  10, dir = 180, rng = 1000, cyc = 5, dmg = 4, tar = 200, tdr = 180, trt = .3},
					["desc"] = _("upgrade-comms","double damage"),
				},
				["stock"] = {
					{idx = 0, arc =  50, dir = -20, rng = 1000, cyc = 6, dmg = 4},
					{idx = 1, arc =  50, dir =  20, rng = 1000, cyc = 6, dmg = 4},
					{idx = 2, arc =  10, dir = 180, rng = 1000, cyc = 6, dmg = 2, tar = 220, tdr = 180, trt = .3},
				},
				["start"] = 4,
			},
			["missiles"] = {
				{tube = 1,	ord = 1},														--1
				{tube = 1,	ord = 2, desc = _("upgrade-comms","increase homing capacity by 1/3")},				--2  
				{tube = 2,	ord = 3, desc = _("upgrade-comms","add broadsides for nukes, EMPs and HVLIs")},	--3  
				{tube = 2,	ord = 4, desc = _("upgrade-comms","increase EMP capacity by 25%")},				--4
				{tube = 3,	ord = 4, desc = _("upgrade-comms","make broadside tubes medium sized")},			--5
				{tube = 4,	ord = 4, desc = _("upgrade-comms","reduce front tubes' load time by 20%")},		--6
				{tube = 4,	ord = 5, desc = _("upgrade-comms","increase homing capacity by 50%")},				--7
				{tube = 5,	ord = 6, desc = _("upgrade-comms","add mining tube and mines")},					--8
				{tube = 6,	ord = 6, desc = _("upgrade-comms","reduce mine load time by ~17%")},				--9
				{tube = 7,	ord = 6, desc = _("upgrade-comms","add rear homing tube")},						--10
				{tube = 7,	ord = 7, desc = _("upgrade-comms","increase capacity: homing:1/3, HVLI:50%")},		--11
				{tube = 8,	ord = 7, desc = _("upgrade-comms","make forward tubes medium sized")},				--12
				{tube = 8,	ord = 8, desc = _("upgrade-comms","double mine capacity")},						--13
				{tube = 9,	ord = 8, desc = _("upgrade-comms","make rear mine tube large sized")},				--14
				{tube = 9,	ord = 9, desc = _("upgrade-comms","increase capacity: nuke:50%, EMP:20%, HVLI:1/3")},	--15
				{tube = 10,	ord = 9, desc = _("upgrade-comms","reduce load time on broadside and rear tubes by ~18%")},	--16
				{tube = 11,	ord = 9, desc = _("upgrade-comms","Add HVLI capability to rear tube")},			--17
				["start"] = 5,
			},
			["tube"] = {
				{	--1
					{idx = 0, dir =  -2, siz = "S", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir =   2, siz = "S", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
				},
				{	--2
					{idx = 0, dir =  -2, siz = "S", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir =   2, siz = "S", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 2, dir = -90, siz = "S", spd = 12,hom = false, nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 3, dir =  90, siz = "S", spd = 12,hom = false, nuk = true,  emp = true,  min = false, hvl = true },
				},
				{	--3
					{idx = 0, dir =  -2, siz = "S", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir =   2, siz = "S", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 2, dir = -90, siz = "M", spd = 12,hom = false, nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 12,hom = false, nuk = true,  emp = true,  min = false, hvl = true },
				},
				{	--4
					{idx = 0, dir =  -2, siz = "S", spd = 8, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir =   2, siz = "S", spd = 8, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 2, dir = -90, siz = "M", spd = 12,hom = false, nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 12,hom = false, nuk = true,  emp = true,  min = false, hvl = true },
				},
				{	--5
					{idx = 0, dir =  -2, siz = "S", spd = 8, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir =   2, siz = "S", spd = 8, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 2, dir = -90, siz = "M", spd = 12,hom = false, nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 12,hom = false, nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 4, dir = 180, siz = "M", spd = 18,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--6
					{idx = 0, dir =  -2, siz = "S", spd = 8, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir =   2, siz = "S", spd = 8, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 2, dir = -90, siz = "M", spd = 12,hom = false, nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 12,hom = false, nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 4, dir = 180, siz = "M", spd = 15,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--7
					{idx = 0, dir =  -2, siz = "S", spd = 8, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir =   2, siz = "S", spd = 8, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 2, dir = -90, siz = "M", spd = 12,hom = false, nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 12,hom = false, nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 4, dir = 180, siz = "M", spd = 12,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 5, dir = 180, siz = "M", spd = 15,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--8
					{idx = 0, dir =  -2, siz = "M", spd = 8, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir =   2, siz = "M", spd = 8, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 2, dir = -90, siz = "M", spd = 12,hom = false, nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 12,hom = false, nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 4, dir = 180, siz = "M", spd = 12,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 5, dir = 180, siz = "M", spd = 15,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--9
					{idx = 0, dir =  -2, siz = "M", spd = 8, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir =   2, siz = "M", spd = 8, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 2, dir = -90, siz = "M", spd = 12,hom = false, nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 12,hom = false, nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 4, dir = 180, siz = "L", spd = 12,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 5, dir = 180, siz = "M", spd = 15,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--10
					{idx = 0, dir =  -2, siz = "M", spd = 8, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir =   2, siz = "M", spd = 8, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 2, dir = -90, siz = "M", spd = 10,hom = false, nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 10,hom = false, nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 4, dir = 180, siz = "L", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 5, dir = 180, siz = "M", spd = 12,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--11
					{idx = 0, dir =  -2, siz = "M", spd = 8, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir =   2, siz = "M", spd = 8, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 2, dir = -90, siz = "M", spd = 10,hom = false, nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 10,hom = false, nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 4, dir = 180, siz = "L", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 5, dir = 180, siz = "M", spd = 12,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				["stock"] = {
					{idx = 0, dir =  -2, siz = "S", spd = 8, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir =   2, siz = "S", spd = 8, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 2, dir = -90, siz = "M", spd = 12,hom = false, nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 12,hom = false, nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 4, dir = 180, siz = "M", spd = 15,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
			},
			["ordnance"] = {
				{hom = 6,  nuk = 0, emp = 0, min = 0, hvl = 0},		--1
				{hom = 8,  nuk = 0, emp = 0, min = 0, hvl = 0},		--2
				{hom = 8,  nuk = 2, emp = 4, min = 0, hvl = 8},		--3
				{hom = 8,  nuk = 2, emp = 5, min = 0, hvl = 8},		--4
				{hom = 12, nuk = 2, emp = 5, min = 0, hvl = 8},		--5
				{hom = 12, nuk = 2, emp = 5, min = 3, hvl = 8},		--6
				{hom = 16, nuk = 2, emp = 5, min = 3, hvl = 12},	--7
				{hom = 16, nuk = 2, emp = 5, min = 6, hvl = 12},	--8
				{hom = 16, nuk = 3, emp = 6, min = 6, hvl = 16},	--9
				["stock"] = {hom = 16, nuk = 2, emp = 5, min = 5, hvl = 16},
			},
			["shield"] = {
				{	--1
					{idx = 0, max = 80},
				},
				{	--2
					{idx = 0, max = 100},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--3
					{idx = 0, max = 120},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--4
					{idx = 0, max = 90},
					{idx = 1, max = 60},
					["desc"] = _("upgrade-comms","add rear shield arc"),
				},
				{	--5
					{idx = 0, max = 120},
					{idx = 1, max =  80},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 1/3"),
				},
				{	--6
					{idx = 0, max = 120},
					{idx = 1, max = 100},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by 25%"),
				},
				{	--7
					{idx = 0, max = 150},
					{idx = 1, max = 100},
					["desc"] = _("upgrade-comms","increase front shield charge capacity by 25%"),
				},
				{	--8
					{idx = 0, max = 180},
					{idx = 1, max = 120},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--9
					{idx = 0, max = 198},
					{idx = 1, max = 132},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 10%"),
				},
				["stock"] = {
					{idx = 0, max = 110},
					{idx = 1, max = 70},
				},
				["start"] = 5,
			},
			["hull"] = {
				{max = 120},											--1
				{max = 140, ["desc"] = _("upgrade-comms","increase hull max by ~17%")},	--2
				{max = 160, ["desc"] = _("upgrade-comms","increase hull max by ~14%")},	--3
				{max = 180, ["desc"] = _("upgrade-comms","increase hull max by 12.5%")},	--4
				{max = 200, ["desc"] = _("upgrade-comms","increase hull max by ~11%")},	--5
				{max = 220, ["desc"] = _("upgrade-comms","increase hull max by 10%")},		--6
				{max = 242, ["desc"] = _("upgrade-comms","increase hull max by 10%")},		--7
				["stock"] = {max = 200},
				["start"] = 2,
			},
			["impulse"] = {
				{	--1
					max_front =		60,		max_back =		60,
					accel_front =	12,		accel_back = 	12,
					turn = 			6,
					boost =			0,		strafe =		0,
				},
				{	--2
					max_front =		60,		max_back =		60,
					accel_front =	12,		accel_back = 	12,
					turn = 			6,
					boost =			300,	strafe =		100,
					desc = _("upgrade-comms","add combat maneuver"),
				},
				{	--3
					max_front =		60,		max_back =		60,
					accel_front =	15,		accel_back = 	15,
					turn = 			6,
					boost =			300,	strafe =		100,
					desc = _("upgrade-comms","increase acceleration by 1/3"),
				},
				{	--4
					max_front =		60,		max_back =		60,
					accel_front =	15,		accel_back = 	15,
					turn = 			8,
					boost =			300,	strafe =		100,
					desc = _("upgrade-comms","increase maneuverability by 1/3"),
				},
				{	--5
					max_front =		60,		max_back =		60,
					accel_front =	15,		accel_back = 	15,
					turn = 			8,
					boost =			450,	strafe =		150,
					desc = _("upgrade-comms","increase combat maneuver by 50%"),
				},
				{	--6
					max_front =		75,		max_back =		75,
					accel_front =	15,		accel_back = 	15,
					turn = 			8,
					boost =			450,	strafe =		150,
					desc = _("upgrade-comms","increase max impulse speed by 25%"),
				},
				{	--7
					max_front =		75,		max_back =		75,
					accel_front =	20,		accel_back = 	15,
					turn = 			8,
					boost =			450,	strafe =		150,
					desc = _("upgrade-comms","increase forward acceleration by 1/3"),
				},
				{	--8
					max_front =		75,		max_back =		75,
					accel_front =	20,		accel_back = 	15,
					turn = 			12,
					boost =			450,	strafe =		150,
					desc = _("upgrade-comms","increase maneuverability by 50%"),
				},
				{	--9
					max_front =		75,		max_back =		75,
					accel_front =	20,		accel_back = 	15,
					turn = 			12,
					boost =			540,	strafe =		180,
					desc = _("upgrade-comms","increase combat maneuver by 20%"),
				},
				["stock"] = {
					{max_front = 60, turn = 8, accel_front = 15, max_back = 60, accel_back = 15, boost = 450, strafe = 150},
				},
				["start"] = 5,
			},
			["ftl"] = {
				{	--1
					jump_long = 0, jump_short = 0, warp = 0,
				},
				{	--2
					jump_long = 0, jump_short = 0, warp = 600,
					desc = _("upgrade-comms","add warp drive"),
				},
				{	--3
					jump_long = 0, jump_short = 0, warp = 700,
					desc = _("upgrade-comms","increase warp speed by ~17%"),
				},
				{	--4
					jump_long = 0, jump_short = 0, warp = 800,
					desc = _("upgrade-comms","increase warp speed by ~14%"),
				},
				{	--5
					jump_long = 0, jump_short = 0, warp = 900,
					desc = _("upgrade-comms","increase warp speed by 12.5%"),
				},
				{	--6
					jump_long = 20000, jump_short = 2000, warp = 900,
					desc = _("upgrade-comms","add jump drive"),
				},
				["stock"] = {
					{jump_long = 0, jump_short = 0, warp = 800},
				},
				["start"] = 2,
			},
			["sensors"] = {
				{	--1
					short = 5000, long = 15000, prox_scan = 0,
				},
				{	--2
					short = 5000, long = 15000, prox_scan = 2,
					desc = _("upgrade-comms","add 2 unit automated proximity scanner"),
				},
				{	--3
					short = 5000, long = 20000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by 1/3"),
				},
				{	--4
					short = 5500, long = 20000, prox_scan = 2,
					desc = _("upgrade-comms","increase short range sensors by 10%"),
				},
				{	--5
					short = 5500, long = 25000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by 25%"),
				},
				{	--6
					short = 5500, long = 30000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by 20%"),
				},
				["stock"] = {
					{short = 5500, long = 25000}, prox_scan = 0,
				},
				["start"] = 3,
			},
			["providers"] = false,
			["score"] = 27,
		},
		["Raven"] = {		--8 + beam(8) + missile(9) + shield(7) + hull(6) + impulse(9) + ftl(5) + sensors(5) = 57
			["beam"] = {
				{	--1
					{idx = 0, arc =  10, dir = -90, rng =  800, cyc = 6, dmg = 8, tar =  60, tdr = -90, trt = 1},
					{idx = 1, arc =  10, dir =  90, rng =  800, cyc = 6, dmg = 8, tar =  60, tdr =  90, trt = 1},
				},
				{	--2
					{idx = 0, arc =  10, dir = -90, rng =  900, cyc = 6, dmg = 8, tar =  60, tdr = -90, trt = 1},
					{idx = 1, arc =  10, dir =  90, rng =  900, cyc = 6, dmg = 8, tar =  60, tdr =  90, trt = 1},
					["desc"] = _("upgrade-comms","increase range by 25%"),
				},
				{	--3
					{idx = 0, arc =  10, dir = -90, rng =  900, cyc = 6, dmg = 10, tar =  60, tdr = -90, trt = 1},
					{idx = 1, arc =  10, dir =  90, rng =  900, cyc = 6, dmg = 10, tar =  60, tdr =  90, trt = 1},
					["desc"] = _("upgrade-comms","increase damage by 25%"),
				},
				{	--4
					{idx = 0, arc =  10, dir = -60, rng =  900, cyc = 6, dmg = 10, tar =  90, tdr = -60, trt = 1},
					{idx = 1, arc =  10, dir =  60, rng =  900, cyc = 6, dmg = 10, tar =  90, tdr =  60, trt = 1},
					["desc"] = _("upgrade-comms","increase arc by 50%"),
				},
				{	--5
					{idx = 0, arc =  10, dir = -60, rng =  900, cyc = 5, dmg = 10, tar =  90, tdr = -60, trt = 1},
					{idx = 1, arc =  10, dir =  60, rng =  900, cyc = 5, dmg = 10, tar =  90, tdr =  60, trt = 1},
					["desc"] = _("upgrade-comms","decrease cycle time by ~17%"),
				},
				{	--6
					{idx = 0, arc =  10, dir = -60, rng =  900, cyc = 5, dmg = 10, tar = 135, tdr = -60, trt = 1},
					{idx = 1, arc =  10, dir =  60, rng =  900, cyc = 5, dmg = 10, tar = 135, tdr =  60, trt = 1},
					["desc"] = _("upgrade-comms","increase arc by 50%"),
				},
				{	--7
					{idx = 0, arc =  10, dir = -60, rng =  900, cyc = 5, dmg = 10, tar = 135, tdr = -60, trt = 1},
					{idx = 1, arc =  10, dir =  60, rng =  900, cyc = 5, dmg = 10, tar = 135, tdr =  60, trt = 1},
					["desc"] = _("upgrade-comms","increase damage by 25%"),
				},
				{	--8
					{idx = 0, arc =  10, dir = -60, rng = 1000, cyc = 5, dmg = 10, tar = 135, tdr = -60, trt = 1},
					{idx = 1, arc =  10, dir =  60, rng = 1000, cyc = 5, dmg = 10, tar = 135, tdr =  60, trt = 1},
					["desc"] = _("upgrade-comms","increase range by ~11%"),
				},
				{	--9
					{idx = 0, arc =  10, dir = -60, rng = 1000, cyc = 5, dmg = 10, tar = 135, tdr = -60, trt = 2},
					{idx = 1, arc =  10, dir =  60, rng = 1000, cyc = 5, dmg = 10, tar = 135, tdr =  60, trt = 2},
					["desc"] = _("upgrade-comms","double turret speed"),
				},
				{	--10
					{idx = 0, arc =  10, dir = -60, rng = 1000, cyc = 5, dmg = 10, tar = 180, tdr = -60, trt = 2},
					{idx = 1, arc =  10, dir =  60, rng = 1000, cyc = 5, dmg = 10, tar = 180, tdr =  60, trt = 2},
					["desc"] = _("upgrade-comms","increase arc by 1/3"),
				},
				["stock"] = {
					{idx = 0, arc =  10, dir = -90, rng =  900, cyc = 6, dmg = 10, tar =  90, tdr = -90, trt = 1},
					{idx = 1, arc =  10, dir =  90, rng =  900, cyc = 6, dmg = 10, tar =  90, tdr =  90, trt = 1},
				},
				["start"] = 3,
			},
			["missiles"] = {
				{tube = 1,	ord = 1},														--1
				{tube = 2,	ord = 2, desc = _("upgrade-comms","add mining tube and mines")},					--2  
				{tube = 3,	ord = 2, desc = _("upgrade-comms","increase tube load speed by ~23%")},			--3  
				{tube = 4,	ord = 3, desc = _("upgrade-comms","add small nuke tubes and nukes")},				--4
				{tube = 5,	ord = 3, desc = _("upgrade-comms","make homing tube medium sized")},				--5
				{tube = 6,	ord = 4, desc = _("upgrade-comms","add small EMP tubes and EMPs")},				--6
				{tube = 6,	ord = 5, desc = _("upgrade-comms","increase capacity: nuke:50%, EMP:1/3, mine:50%")},	--7
				{tube = 7,	ord = 5, desc = _("upgrade-comms","make homing tube large sized")},				--8
				{tube = 8,	ord = 6, desc = _("upgrade-comms","add HVLI capability to large tube and HVLIs")},	--9
				{tube = 8,	ord = 7, desc = _("upgrade-comms","increase capacity: nuke:1/3, mine:1/3, HVLI:25%")},		--10
				["start"] = 4,
			},
			["tube"] = {
				{	--1
					{idx = 0, dir =   0, siz = "S", spd = 16,hom = true,  nuk = false, emp = false, min = false, hvl = false},
				},
				{	--2
					{idx = 0, dir =   0, siz = "S", spd = 16,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir = 180, siz = "M", spd = 12,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--3
					{idx = 0, dir =   0, siz = "S", spd = 12,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir = 180, siz = "M", spd = 10,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--4
					{idx = 0, dir =   0, siz = "S", spd = 12,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir = -30, siz = "S", spd = 8, hom = false, nuk = true,  emp = false, min = false, hvl = false},
					{idx = 2, dir =  30, siz = "S", spd = 8, hom = false, nuk = true,  emp = false, min = false, hvl = false},
					{idx = 3, dir = 180, siz = "M", spd = 10,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--5
					{idx = 0, dir =   0, siz = "M", spd = 12,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir = -30, siz = "S", spd = 8, hom = false, nuk = true,  emp = false, min = false, hvl = false},
					{idx = 2, dir =  30, siz = "S", spd = 8, hom = false, nuk = true,  emp = false, min = false, hvl = false},
					{idx = 3, dir = 180, siz = "M", spd = 10,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--6
					{idx = 0, dir =   0, siz = "M", spd = 12,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir = -30, siz = "S", spd = 8, hom = false, nuk = true,  emp = false, min = false, hvl = false},
					{idx = 2, dir =  30, siz = "S", spd = 8, hom = false, nuk = true,  emp = false, min = false, hvl = false},
					{idx = 3, dir = -60, siz = "S", spd = 8, hom = false, nuk = false, emp = true,  min = false, hvl = false},
					{idx = 4, dir =  60, siz = "S", spd = 8, hom = false, nuk = false, emp = true,  min = false, hvl = false},
					{idx = 5, dir = 180, siz = "M", spd = 10,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--7
					{idx = 0, dir =   0, siz = "L", spd = 12,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir = -30, siz = "S", spd = 8, hom = false, nuk = true,  emp = false, min = false, hvl = false},
					{idx = 2, dir =  30, siz = "S", spd = 8, hom = false, nuk = true,  emp = false, min = false, hvl = false},
					{idx = 3, dir = -60, siz = "S", spd = 8, hom = false, nuk = false, emp = true,  min = false, hvl = false},
					{idx = 4, dir =  60, siz = "S", spd = 8, hom = false, nuk = false, emp = true,  min = false, hvl = false},
					{idx = 5, dir = 180, siz = "M", spd = 10,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--8
					{idx = 0, dir =   0, siz = "L", spd = 12,hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir = -30, siz = "S", spd = 8, hom = false, nuk = true,  emp = false, min = false, hvl = false},
					{idx = 2, dir =  30, siz = "S", spd = 8, hom = false, nuk = true,  emp = false, min = false, hvl = false},
					{idx = 3, dir = -60, siz = "S", spd = 8, hom = false, nuk = false, emp = true,  min = false, hvl = false},
					{idx = 4, dir =  60, siz = "S", spd = 8, hom = false, nuk = false, emp = true,  min = false, hvl = false},
					{idx = 5, dir = 180, siz = "M", spd = 10,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				["stock"] = {
					{idx = 0, dir = -30, siz = "S", spd = 8, hom = false, nuk = true,  emp = false, min = false, hvl = false},
					{idx = 1, dir =  30, siz = "S", spd = 8, hom = false, nuk = true,  emp = false, min = false, hvl = false},
					{idx = 2, dir = -60, siz = "S", spd = 8, hom = false, nuk = false, emp = true,  min = false, hvl = false},
					{idx = 3, dir =  60, siz = "S", spd = 8, hom = false, nuk = false, emp = true,  min = false, hvl = false},
					{idx = 4, dir =   0, siz = "L", spd = 12,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 5, dir = 180, siz = "M", spd = 10,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
			},
			["ordnance"] = {
				{hom = 6,  nuk = 0, emp = 0, min = 0, hvl = 0},		--1
				{hom = 6,  nuk = 0, emp = 0, min = 2, hvl = 0},		--2
				{hom = 6,  nuk = 2, emp = 0, min = 2, hvl = 0},		--3
				{hom = 6,  nuk = 2, emp = 3, min = 2, hvl = 0},		--4
				{hom = 6,  nuk = 3, emp = 4, min = 3, hvl = 0},		--5
				{hom = 6,  nuk = 3, emp = 4, min = 3, hvl = 4},		--6
				{hom = 6,  nuk = 4, emp = 4, min = 4, hvl = 5},		--7
				["stock"] = {hom = 4, nuk = 4, emp = 4, min = 4, hvl = 0},
			},
			["shield"] = {
				{	--1
					{idx = 0, max = 80},
				},
				{	--2
					{idx = 0, max = 100},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--3
					{idx = 0, max = 120},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--4
					{idx = 0, max = 80},
					{idx = 1, max = 80},
					["desc"] = _("upgrade-comms","add rear shield arc"),
				},
				{	--5
					{idx = 0, max = 100},
					{idx = 1, max = 100},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--6
					{idx = 0, max = 120},
					{idx = 1, max = 120},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--7
					{idx = 0, max = 150},
					{idx = 1, max = 150},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--8
					{idx = 0, max = 180},
					{idx = 1, max = 180},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				["stock"] = {
					{idx = 0, max = 100},
					{idx = 1, max = 100},
				},
				["start"] = 3,
			},
			["hull"] = {
				{max = 90},												--1
				{max = 100, ["desc"] = _("upgrade-comms","increase hull max by ~11%")},	--2
				{max = 120, ["desc"] = _("upgrade-comms","increase hull max by 25%")},		--3
				{max = 144, ["desc"] = _("upgrade-comms","increase hull max by 20%")},		--4
				{max = 150, ["desc"] = _("upgrade-comms","increase hull max by ~4%")},		--5
				{max = 180, ["desc"] = _("upgrade-comms","increase hull max by 20%")},		--6
				{max = 200, ["desc"] = _("upgrade-comms","increase hull max by ~17%")},	--7
				["stock"] = {max = 150},
				["start"] = 3,
			},
			["impulse"] = {
				{	--1
					max_front =		75,		max_back =		75,
					accel_front =	15,		accel_back = 	15,
					turn = 			8,
					boost =			0,		strafe =		0,
				},
				{	--2
					max_front =		90,		max_back =		90,
					accel_front =	15,		accel_back = 	15,
					turn = 			8,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase impulse max speed by 20%"),
				},
				{	--3
					max_front =		90,		max_back =		90,
					accel_front =	20,		accel_back = 	20,
					turn = 			8,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase acceleration by 1/3"),
				},
				{	--4
					max_front =		90,		max_back =		90,
					accel_front =	20,		accel_back = 	20,
					turn = 			10,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase maneuverability by 25%"),
				},
				{	--5
					max_front =		90,		max_back =		90,
					accel_front =	20,		accel_back = 	20,
					turn = 			10,
					boost =			300,	strafe =		200,
					desc = _("upgrade-comms","add combat maneuver"),
				},
				{	--6
					max_front =		90,		max_back =		90,
					accel_front =	25,		accel_back = 	20,
					turn = 			10,
					boost =			300,	strafe =		200,
					desc = _("upgrade-comms","increase forward acceleration by 25%"),
				},
				{	--7
					max_front =		90,		max_back =		90,
					accel_front =	25,		accel_back = 	20,
					turn = 			12,
					boost =			300,	strafe =		200,
					desc = _("upgrade-comms","increase maneuverability by 20%"),
				},
				{	--8
					max_front =		90,		max_back =		100,
					accel_front =	25,		accel_back = 	20,
					turn = 			12,
					boost =			300,	strafe =		200,
					desc = _("upgrade-comms","increase max rear impulse speed by ~11%"),
				},
				{	--9
					max_front =		90,		max_back =		100,
					accel_front =	25,		accel_back = 	20,
					turn = 			12,
					boost =			400,	strafe =		200,
					desc = _("upgrade-comms","increase combat maneuver boost by 1/3"),
				},
				{	--10
					max_front =		90,		max_back =		100,
					accel_front =	25,		accel_back = 	20,
					turn = 			12,
					boost =			400,	strafe =		300,
					desc = _("upgrade-comms","increase combat maneuver strafe by 50%"),
				},
				["stock"] = {
					{max_front = 90, turn = 10, accel_front = 20, max_back = 90, accel_back = 20, boost = 400, strafe = 250},
				},
				["start"] = 5,
			},
			["ftl"] = {
				{	--1
					jump_long = 0, jump_short = 0, warp = 0,
				},
				{	--2
					jump_long = 0, jump_short = 0, warp = 250,
					desc = _("upgrade-comms","add warp drive"),
				},
				{	--3
					jump_long = 0, jump_short = 0, warp = 300,
					desc = _("upgrade-comms","increase warp speed by 20%"),
				},
				{	--4
					jump_long = 0, jump_short = 0, warp = 360,
					desc = _("upgrade-comms","increase warp speed by 20%"),
				},
				{	--5
					jump_long = 20000, jump_short = 2000, warp = 360,
					desc = _("upgrade-comms","add jump drive"),
				},
				{	--6
					jump_long = 20000, jump_short = 2000, warp = 450,
					desc = _("upgrade-comms","increase warp speed by 25%"),
				},
				["stock"] = {
					{jump_long = 0, jump_short = 0, warp = 300},
				},
				["start"] = 2,
			},
			["sensors"] = {
				{	--1
					short = 5000, long = 15000, prox_scan = 0,
				},
				{	--2
					short = 5000, long = 15000, prox_scan = 2,
					desc = _("upgrade-comms","add 2 unit automated proximity scanner"),
				},
				{	--3
					short = 5000, long = 20000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by 1/3"),
				},
				{	--4
					short = 6000, long = 20000, prox_scan = 2,
					desc = _("upgrade-comms","increase short range sensors by 20%"),
				},
				{	--5
					short = 6000, long = 25000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by 25%"),
				},
				{	--6
					short = 6000, long = 30000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by 20%"),
				},
				["stock"] = {
					{short = 6000, long = 25000}, prox_scan = 0,
				},
				["start"] = 3,
			},
			["providers"] = false,
			["score"] = 24,
		},
		["Squid"] = {		--8 + beam(6) + missile(9) + shield(6) + hull(4) + impulse(7) + ftl(5) + sensors(4) = 49
			["beam"] = {
				{	--1
					{idx = 0, arc =  10, dir =   0, rng =  800, cyc = 6, dmg =  4, tar =  60, tdr =   0, trt = .5},
				},
				{	--2
					{idx = 0, arc =  10, dir =   0, rng = 1000, cyc = 6, dmg =  4, tar =  60, tdr =   0, trt = .5},
					["desc"] = _("upgrade-comms","increase range by 25%"),
				},
				{	--3
					{idx = 0, arc =  10, dir =   0, rng = 1000, cyc = 4, dmg =  4, tar =  60, tdr =   0, trt = .5},
					["desc"] = _("upgrade-comms","reduce cycle time by 1/3"),
				},
				{	--4
					{idx = 0, arc =  10, dir =   0, rng = 1000, cyc = 4, dmg =  4, tar =  80, tdr =   0, trt = .5},
					["desc"] = _("upgrade-comms","increase arc by 1/3"),
				},
				{	--5
					{idx = 0, arc =  10, dir =   0, rng = 1000, cyc = 4, dmg =  4, tar =  80, tdr =   0, trt = 1},
					["desc"] = _("upgrade-comms","double turret speed"),
				},
				{	--6
					{idx = 0, arc =  10, dir =   0, rng = 1000, cyc = 4, dmg =  4, tar =  80, tdr =   0, trt = 1},
					{idx = 1, arc =  10, dir =   0, rng =  800, cyc = 6, dmg =  6, tar =  60, tdr =   0, trt = .5},
					["desc"] = _("upgrade-comms","add beam"),
				},
				{	--7
					{idx = 0, arc =  10, dir =   0, rng = 1000, cyc = 4, dmg =  6, tar =  80, tdr =   0, trt = 1},
					{idx = 1, arc =  10, dir =   0, rng =  800, cyc = 6, dmg =  9, tar =  60, tdr =   0, trt = .5},
					["desc"] = _("upgrade-comms","increase damage by 50%"),
				},
				["stock"] = {
					{idx = 0, arc =  10, dir =   0, rng = 1000, cyc = 4, dmg =  4, tar =  80, tdr =   0, trt = 1},
				},
				["start"] = 2,
			},
			["missiles"] = {
				{tube = 1,	ord = 1},														--1
				{tube = 2,	ord = 2, desc = _("upgrade-comms","add forward HVLI tube and HVLIs")},				--2  
				{tube = 3,	ord = 3, desc = _("upgrade-comms","add heavy broadsides and missiles")},			--3  
				{tube = 4,	ord = 4, desc = _("upgrade-comms","add mining tube and mines")},					--4
				{tube = 5,	ord = 4, desc = _("upgrade-comms","add another forward tube and mining tube")},	--5
				{tube = 5,	ord = 5, desc = _("upgrade-comms","double capacity: nuke, EMP, mine")},			--6
				{tube = 6,	ord = 5, desc = _("upgrade-comms","make front and broadside homing tubes large")},	--7
				{tube = 6,	ord = 6, desc = _("upgrade-comms","increase capacity: homing:2/3, mine:50%, HVLI:2/3")},	--8
				{tube = 7,	ord = 6, desc = _("upgrade-comms","decrease tube load time for heavy broadsides")},	--9
				{tube = 7,	ord = 7, desc = _("upgrade-comms","increase capacity: homing:20% HVLI:60%")},		--10
				["start"] = 4,
			},
			["tube"] = {
				{	--1
					{idx = 0, dir = -90, siz = "M", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir =  90, siz = "M", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
				},
				{	--2
					{idx = 0, dir =   0, siz = "M", spd = 12,hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir = -90, siz = "M", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 2, dir =  90, siz = "M", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
				},
				{	--3
					{idx = 0, dir =   0, siz = "M", spd = 12,hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir = -90, siz = "M", spd = 10,hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 2, dir = -90, siz = "M", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 3, dir =  90, siz = "M", spd = 10,hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 4, dir =  90, siz = "M", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
				},
				{	--4
					{idx = 0, dir =   0, siz = "M", spd = 12,hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir = -90, siz = "M", spd = 10,hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 2, dir = -90, siz = "M", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 3, dir =  90, siz = "M", spd = 10,hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 4, dir =  90, siz = "M", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 5, dir = 180, siz = "M", spd = 15,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--5
					{idx = 0, dir =   0, siz = "M", spd = 12,hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   0, siz = "M", spd = 12,hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = -90, siz = "M", spd = 10,hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 3, dir = -90, siz = "M", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 4, dir =  90, siz = "M", spd = 10,hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 5, dir =  90, siz = "M", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 6, dir = 170, siz = "M", spd = 15,hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 7, dir = 190, siz = "M", spd = 15,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--6
					{idx = 0, dir =   0, siz = "L", spd = 12,hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   0, siz = "L", spd = 12,hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = -90, siz = "M", spd = 10,hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 3, dir = -90, siz = "L", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 4, dir =  90, siz = "M", spd = 10,hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 5, dir =  90, siz = "L", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 6, dir = 170, siz = "M", spd = 15,hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 7, dir = 190, siz = "M", spd = 15,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--7
					{idx = 0, dir =   0, siz = "L", spd = 12,hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   0, siz = "L", spd = 12,hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = -90, siz = "M", spd = 8, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 3, dir = -90, siz = "L", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 4, dir =  90, siz = "M", spd = 8, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 5, dir =  90, siz = "L", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 6, dir = 170, siz = "M", spd = 15,hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 7, dir = 190, siz = "M", spd = 15,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				["stock"] = {
					{idx = 0, dir =   0, siz = "L", spd = 12,hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir = -90, siz = "M", spd = 8, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 2, dir = -90, siz = "L", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 3, dir =   0, siz = "L", spd = 12,hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 4, dir =  90, siz = "M", spd = 8, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 5, dir =  90, siz = "L", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 6, dir = 170, siz = "M", spd = 15,hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 7, dir = 190, siz = "M", spd = 15,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
			},
			["ordnance"] = {
				{hom = 6,  nuk = 0, emp = 0, min = 0, hvl = 0},		--1
				{hom = 6,  nuk = 0, emp = 0, min = 0, hvl = 6},		--2
				{hom = 6,  nuk = 2, emp = 2, min = 0, hvl = 6},		--3
				{hom = 6,  nuk = 2, emp = 2, min = 2, hvl = 6},		--4
				{hom = 6,  nuk = 4, emp = 4, min = 4, hvl = 6},		--5
				{hom = 10, nuk = 4, emp = 4, min = 6, hvl = 10},	--6
				{hom = 12, nuk = 4, emp = 4, min = 6, hvl = 16},	--7
				["stock"] = {hom = 10, nuk = 4, emp = 4, min = 6, hvl = 10},
			},
			["shield"] = {
				{	--1
					{idx = 0, max = 80},
				},
				{	--2
					{idx = 0, max = 100},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--3
					{idx = 0, max = 120},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--4
					{idx = 0, max = 80},
					{idx = 1, max = 80},
					["desc"] = _("upgrade-comms","add rear shield arc"),
				},
				{	--5
					{idx = 0, max = 100},
					{idx = 1, max = 100},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--6
					{idx = 0, max = 120},
					{idx = 1, max = 120},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--7
					{idx = 0, max = 150},
					{idx = 1, max = 150},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				["stock"] = {
					{idx = 0, max = 100},
					{idx = 1, max = 100},
				},
				["start"] = 3,
			},
			["hull"] = {
				{max = 100},											--1
				{max = 120, ["desc"] = _("upgrade-comms","increase hull max by 25%")},		--2
				{max = 130, ["desc"] = _("upgrade-comms","increase hull max by ~9%")},		--3
				{max = 140, ["desc"] = _("upgrade-comms","increase hull max by ~8%")},		--4
				{max = 160, ["desc"] = _("upgrade-comms","increase hull max by ~14%")},	--5
				["stock"] = {max = 130},
				["start"] = 3,
			},
			["impulse"] = {
				{	--1
					max_front =		60,		max_back =		60,
					accel_front =	6,		accel_back = 	6,
					turn = 			8,
					boost =			0,		strafe =		0,
				},
				{	--2
					max_front =		60,		max_back =		60,
					accel_front =	8,		accel_back = 	8,
					turn = 			8,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase acceleration by 1/3"),
				},
				{	--3
					max_front =		60,		max_back =		60,
					accel_front =	8,		accel_back = 	8,
					turn = 			10,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase maneuverability by 25%"),
				},
				{	--4
					max_front =		60,		max_back =		60,
					accel_front =	8,		accel_back = 	8,
					turn = 			10,
					boost =			200,	strafe =		150,
					desc = _("upgrade-comms","add combat maneuver"),
				},
				{	--5
					max_front =		75,		max_back =		60,
					accel_front =	8,		accel_back = 	8,
					turn = 			10,
					boost =			200,	strafe =		150,
					desc = _("upgrade-comms","increase max forward impulse by 25%"),
				},
				{	--6
					max_front =		75,		max_back =		60,
					accel_front =	10,		accel_back = 	8,
					turn = 			10,
					boost =			200,	strafe =		150,
					desc = _("upgrade-comms","increase forward acceleration by 25%"),
				},
				{	--7
					max_front =		75,		max_back =		60,
					accel_front =	10,		accel_back = 	8,
					turn = 			10,
					boost =			300,	strafe =		225,
					desc = _("upgrade-comms","increase combat maneuver by 50%"),
				},
				{	--8
					max_front =		75,		max_back =		60,
					accel_front =	10,		accel_back = 	8,
					turn = 			12,
					boost =			300,	strafe =		225,
					desc = _("upgrade-comms","increase maneuverability by 25%"),
				},
				["stock"] = {
					{max_front = 60, turn = 10, accel_front = 8, max_back = 60, accel_back = 8, boost = 200, strafe = 150},
				},
				["start"] = 4,
			},
			["ftl"] = {
				{	--1
					jump_long = 0, jump_short = 0, warp = 0,
				},
				{	--2
					jump_long = 15000, jump_short = 1500, warp = 0,
					desc = _("upgrade-comms","add 15k jump drive"),
				},
				{	--3
					jump_long = 20000, jump_short = 2000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 1/3"),
				},
				{	--4
					jump_long = 25000, jump_short = 2500, warp = 0,
					desc = _("upgrade-comms","increase jump range by 25%"),
				},
				{	--5
					jump_long = 30000, jump_short = 3000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 20%"),
				},
				{	--6
					jump_long = 30000, jump_short = 3000, warp = 250,
					desc = _("upgrade-comms","add warp drive"),
				},
				["stock"] = {
					{jump_long = 20000, jump_short = 2000, warp = 0},
				},
				["start"] = 2,
			},
			["sensors"] = {
				{	--1
					short = 5000, long = 20000, prox_scan = 0,
				},
				{	--2
					short = 5000, long = 25000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by 25%"),
				},
				{	--3
					short = 5000, long = 25000, prox_scan = 3,
					desc = _("upgrade-comms","add 3 unit automated proximity scanner"),
				},
				{	--4
					short = 5000, long = 30000, prox_scan = 3,
					desc = _("upgrade-comms","increase long range scan range by 20%"),
				},
				{	--5
					short = 5500, long = 30000, prox_scan = 3,
					desc = _("upgrade-comms","increase short range sensors by 10%"),
				},
				["stock"] = {
					{short = 5000, long = 25000}, prox_scan = 0,
				},
				["start"] = 2,
			},
			["providers"] = false,
			["score"] = 21,
		},
	}
end