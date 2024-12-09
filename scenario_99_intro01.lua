-- Name: Intro 01
-- Description: Introduction to scenario scripting
-- Type: Development
function init()
	PlayerSpaceship():setTemplate("Atlantis")
	CpuShip():setTemplate("Adder MK5"):orderRoaming()
end
function update()
end
