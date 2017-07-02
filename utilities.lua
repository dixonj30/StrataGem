local image = require 'image'
local json = require 'dkjson'

-- all prints go to debug.txt file. achtung!
love.filesystem.remove("debug.txt")
local reallyprint = print
function print(...)
	reallyprint(...)
	local args = {...}
	for i = 1, #args do
		if type(args[i]) == "table" then args[i] = "table"
		elseif args[i] == true then args[i] = "true"
		elseif args[i] == false then args[i] = "false"
		elseif type(args[i]) == "userdata" then args[i] = "userdata"
		elseif type(args[i]) == "function" then args[i] = "function"
		elseif type(args[i]) == "thread" then args[i] = "thread"
		end
	end
	local write = table.concat(args, ", ")
	love.filesystem.append("debug.txt", write .. "\n")
end

function sprint(...)
	if frame % 10 == 0 then print(...) end
end

debugTool = {}
function debugTool.printDamageAndScore(num_matches, p1dmg, p2dmg, p1super, p2super)
	local toprint = {
		{"----------------------------------------"},
		{"Combo hit:", game.scoring_combo, "Matches done:", num_matches},
		{"P1 damage:", p1dmg, "P2 damage:", p2dmg},
		{"P1 super gain:", p1super, "P2 super gain:", p2super},
		{}
	}

	for i = 1, #toprint do print(unpack(toprint[i])) end
end

function debugTool.printSummaryState(grid, p1, p2)
	local toprint = {"", "", "", "", "", "", "", "", ""}
	for row = 7, 14 do
		for col = 1, 8 do
			if grid[row][col].gem then
				local colors = {RED = "R", BLUE = "B", GREEN = "G", YELLOW = "Y"}
				toprint[row-6] = toprint[row-6] .. colors[ grid[row][col].gem.color ]
			else
				toprint[row-6] = toprint[row-6] .. "."
			end
		end
	end
	toprint[9] = p1.cur_mp .. "|" .. p2.cur_mp
	for i = 1, #toprint do print(toprint[i]) end
end

function math.clamp(_in, low, high)
	if (_in < low ) then return low end
	if (_in > high ) then return high end
	return _in
end

function string:split(inSplitPattern, outResults)
	if not outResults then
		outResults = { }
	end
	local theStart = 1
	local theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
	while theSplitStart do
		table.insert( outResults, string.sub( self, theStart, theSplitStart-1 ) )
		theStart = theSplitEnd + 1
		theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
	end
	table.insert( outResults, string.sub( self, theStart ) )
	return outResults
end

function spairs(tab, ...)
	local keys,vals,idx = {},{},0
	for k in pairs(tab) do
		keys[#keys+1] = k
	end
	table.sort(keys, ...)
	for i=1,#keys do
		vals[i]=tab[keys[i]]
	end
	return function()
		idx = idx + 1
		return keys[idx], vals[idx]
	end
end

function players()
  local i = 0
  local p = {p1, p2}
  return function() i = i + 1 return p[i] end
end
    
function gridGems(grd)
	--if not grd then print(debug.traceback()) assert(grd, "wrong grid") end
	local gems, rows, columns, index = {}, {}, {}, 0
	for i = 0, grd.rows + 1 do
		for j = 0, grd.columns + 1 do
			if grd[i][j].gem then
				gems[#gems+1] = grd[i][j].gem
				rows[#rows+1] = i
				columns[#columns+1] = j
			end
		end
	end
	return function()
		index = index + 1
		return gems[index], rows[index], columns[index]
	end
end

function reverseTable(table)
	local reversedTable = {}
	local itemCount = #table
	for k, v in ipairs(table) do
		reversedTable[itemCount + 1 - k] = v
	end
	return reversedTable
end

function pointIsInRect(x, y, rx, ry, rw, rh)
	return x >= rx and y >= ry and x < rx + rw and y < ry + rh
end

rng = {orig_rng_seed = 0}
function rng.newSeed(seed)
	rng.seed = seed
end

function rng.random(n)
	local new_seed = (((20077 * rng.seed) % 2147483648) + ((1103495168 * rng.seed) % 2147483648) + 12345) % 2147483648
	rng.seed = new_seed
	return (math.floor(new_seed / 2048) % n) + 1
end

function checkVersion()
	local major, minor, revision, codename = love.getVersion()
	local version = major * 10000 + minor * 100 + revision * 1
	local min_version = 001000
	assert(version >= min_version, "Please update your Love2D to the latest version.")
end

function columnSort(column_num, grd)
	local column = {}
	for i = 1, grd.rows do
		column[i] = grd[i][column_num].gem
	end
	for i = grd.rows, 1, -1 do 
		 if not column[i] then 
			 table.remove(column, i)
		 end 
	end 
	for i = 1, grd.rows - #column do
		table.insert(column, 1, false)
	end
	return column
end

local deepcpy_mapping = {}
local real_deepcpy
function real_deepcpy(tab)
  if deepcpy_mapping[tab] ~= nil then
    return deepcpy_mapping[tab]
  end
  local ret = {}
  deepcpy_mapping[tab] = ret
  deepcpy_mapping[ret] = ret
  for k,v in pairs(tab) do
    if type(k) == "table" then
      k=real_deepcpy(k)
    end
    if type(v) == "table" then
      v=real_deepcpy(v)
    end
    ret[k]=v
  end
  return setmetatable(ret, getmetatable(tab))
end

function deepcpy(tab)
  if type(tab) ~= "table" then return tab end
  local ret = real_deepcpy(tab)
  deepcpy_mapping = {}
  return ret
end