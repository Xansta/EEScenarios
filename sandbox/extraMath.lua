function math.lerp (a,b,t)
	-- intended to mirror C++ lerp
	-- linear interpolation
	assert(type(a)=="number")
	assert(type(b)=="number")
	assert(type(t)=="number")
	return a + t * (b - a)
end
function math.CosineInterpolate(y1,y2,mu)
	-- see http://paulbourke.net/miscellaneous/interpolation/
	assert(type(y1)=="number")
	assert(type(y2)=="number")
	assert(type(mu)=="number")
	local mu2 = (1-math.cos(mu*math.pi))/2
	assert(type(mu2)=="number")
	return (y1*(1-mu2)+y2*mu2)
end
function math._CosineInterpolateTableInner(tbl,elmt,t)
	assert(type(tbl)=="table")
	assert(type(t)=="number")
	assert(type(elmt)=="number")
	assert(elmt<#tbl)
	local x_delta=tbl[elmt+1].x-tbl[elmt].x
	if x_delta == 0 then
		return tbl[elmt].y
	end
	local t_scaled=(t-tbl[elmt].x)*(1/x_delta)
	return math.CosineInterpolate(tbl[elmt].y,tbl[elmt+1].y,t_scaled)
end
function math.CosineInterpolateTable(tbl,t)
	assert(type(tbl)=="table")
	assert(type(t)=="number")
	assert(#tbl>1)
	for i=1,#tbl-1 do
		if tbl[i+1].x>t then
			return math._CosineInterpolateTableInner(tbl,i,t)
		end
	end
	return math._CosineInterpolateTableInner(tbl,#tbl-1,t)
end
function math.CubicInterpolate(y0,y1,y2,y3,mu)
	-- see http://paulbourke.net/miscellaneous/interpolation/
	assert(type(y0)=="number")
	assert(type(y1)=="number")
	assert(type(y2)=="number")
	assert(type(y3)=="number")
	assert(type(mu)=="number")
	local mu2 = mu*mu;
	local a0 = y3 - y2 - y0 + y1;
	local a1 = y0 - y1 - a0;
	local a2 = y2 - y0;
	local a3 = y1;
	return(a0*mu*mu2+a1*mu2+a2*mu+a3);
end
function math.CubicInterpolate2DTable(tbl,t)
	-- this takes an array with 2 elements each (x and y)
	-- and returns the Cubic interpolation for the (floating point) element t
	-- it would be tricky and not very useful allowing a table with 3 elements and t==1
	-- likewise caluclation at exactly 1 smaller than the length of the array is slightly tricky for the code
	-- fixing these wouldnt be hard, just branchy and needing a lot of looking at to confirm it all works as expected
	-- currently they will just fail asserts, which in turn allows it to be fixed at a later date without breaking old code
	assert(type(tbl)=="table")
	assert(type(t)=="number")
	assert(t>=1,"CubicInterpolate2DTable t must be >= 1")
	assert(math.ceil(t)+1<=#tbl,"CubicInterpolate2DTable tbl must have one one more element than the size of t")
	local i = math.floor(t)
	local mu = t - i
	local x = math.CubicInterpolate(tbl[i].x,tbl[i+1].x,tbl[i+2].x,tbl[i+3].x,mu)
	local y = math.CubicInterpolate(tbl[i].y,tbl[i+1].y,tbl[i+2].y,tbl[i+3].y,mu)
	return x,y
end
function math.lerpTest()
	assert(math.lerp(1,2,0)==1)
	assert(math.lerp(1,2,1)==2)
	assert(math.lerp(2,1,0)==2)
	assert(math.lerp(2,1,1)==1)
	assert(math.lerp(2,1,.5)==1.5)
	-- extrapolation
	assert(math.lerp(1,2,-1)==0)
	assert(math.lerp(1,2,2)==3)
end
function math.clamp(value,lo,hi)
	-- intended to mirror C++ clamp
	-- clamps value within the range of low and high
	assert(type(value)=="number")
	assert(type(lo)=="number")
	assert(type(hi)=="number")
	if value < lo then
		value = lo
	end
	if value > hi then
		return hi
	end
	return value
end
function math.clampTest()
	assert(math.clamp(0,1,2)==1)
	assert(math.clamp(3,1,2)==2)
	assert(math.clamp(1.5,1,2)==1.5)

	assert(math.clamp(0,2,3)==2)
	assert(math.clamp(4,2,3)==3)
	assert(math.clamp(2.5,2,3)==2.5)
end
function math.extraTests()
	math.lerpTest()
	math.clampTest()
end