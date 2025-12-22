--[[------------------------------------------------------------------

	EnumExtender.lua

	This module is licensed under APLv2, refer to LICENSE file or:
	https://www.apache.org/licenses/LICENSE-2.0

	To use this code, you must keep this notice in all copies of
	(significant pieces of) this code.

	Copyright 2018 buildthomas

--[[------------------------------------------------------------------

  - Table of Contents: -
    > Description
    > Exposed functionality
    > Structure
    > Options

  - Description: -

    This module extends the global 'Enum' so that custom enumerators
    can be added, while  preserving the existing  enumerators in the
    global 'Enum'. The added enumerators  mimic the functionality of
    existing enumerators as closely as possible.

  - Exposed functionality: -

    void Enums.new(string name, table list)

        Creates a new Enum in the Enums object.

        name : the string name* for the new enumerator

        list : table with natural numeric keys with string values**,
        as value/item sets of new Enum

        NOTES:
         *) Cannot be equal to "new" or "Find" or "GetStandardEnums"
            or "FromValue"
        **) Cannot be "GetEnumItems"

    Enum Enums:Find(string name)

        If  a  certain  enumerator  exists,  then  it  is  returned,
        otherwise  nil.

        name : the name of the enumerator to find

    userdata Enums:GetStandardEnums()

        Returns the original contents of the global 'Enum'

    EnumItem Enums:FromValue(string enum, int value)

        Find the item of a certain value, of a certain Enum.

        enum* : the name of the existing enumerator

        value : the value of the item to find

        NOTES:
        *) This structure was needed  to make it work  with existing
        enumerators, since no methods can be added to these.

    Enum Enums.<string name>                              (readonly)

        Indexing  Enums   with  a  certain  name   will  return  the
        corresponding  Enum.

        Will throw an error if no such Enum exists.

        name : the name of the existing enumerator

    bool Enums.UserEnumOverwriteEnabled                   (readonly)

        Returns ENUM_OVERWRITE_ENABLED. (see Options)

    bool Enums.StandardEnumOverwriteEnabled               (readonly)

        Returns RBX_ENUM_OVERWRITED_ENABLED. (see Options)

    bool Enums.EmpyEnumEnabled                            (readonly)

        Returns EMPTY_ENUM_ENABLED. (see Options)

    bool Enums.VariableStyleEnforced                      (readonly)

        Returns VARIABLE_STYLE_NAMING. (see Options)

    bool Enums.WarningsEnabled                            (readonly)

        Returns WARNINGS_ENABLED. (see Options)

    table Enum:GetEnumItems()

        Returns a table  containing all of the EnumItem values  that
        the enumerator  can take.

    EnumItem Enum.<string name>                           (readonly)

        Indexing  Enum   with  a  certain  name   will   return  the
        corresponding   EnumItem.

        Will throw an error if no such EnumItem exists.

        name : the name of the existing item of the enumerator

  - Structure: -

    There are three types of objects:
    - Enums    : main container (= 'Enum' globally)
    - Enum     : a single enumerator
    - EnumItem : values of an Enum

    The hierarchy is shown below:

    Enums (object)
     - Enum (oject)
       - EnumItem (object)
         | Name (property)
         | Value (property)
       - (more EnumItem objects)
     - (more Enum objects)

------------------------------------------------------------------]]--

-- Options: ---

-- Whether user-made enumerators can be overwritten:
-- DEFAULT: false

ENUM_OVERWRITE_ENABLED      = false

-- Whether standard enumerators can be overwritten:
-- DEFAULT: false

RBX_ENUM_OVERWRITED_ENABLED = false

-- Whether enumerators without values are allowed:
-- DEFAULT: false

EMPTY_ENUM_ENABLED          = false

-- Enforce variable styled naming of enum items:
-- (consist of characters/numbers/underscores,
-- can't start with a number)
-- DEFAULT: true

VARIABLE_STYLE_NAMING       = true

-- Whether or not warnings will be printed:
-- DEFAULT: true

WARNINGS_ENABLED            = true

------------------------------------------------------------------]]--

local meta do
	
	-- Message when someone tries to obtain metatables:
	local __METATABLE = "The metatable is locked"
	
	local function GetEnumItems(object)
		
		local children = {}
		for key, value in pairs(object) do
			-- Get all values apart from the GetEnumItems function:
			if key ~= "GetEnumItems" then
				table.insert(children, value)
			end
		end
		
		-- Sort EnumItems based on their Value properties:
		table.sort(children, function(a, b) return a.Value < b.Value end)
		return children
		
	end
	
	-- Will contain all user-made enumerators:
	local enums = {}
	
	-- Creation function:
	function enums.new(name, list)
		
		-- Check validity of first argument and type of second argument:
		if name == nil or type(name) ~= "string" then
			error("bad argument #1 to 'new' (string expected, got " .. (name ~= nil and type(name) or "no value") .. ")", 2)
		elseif name == "new" or name == "find" or name == "GetRawEnums" then
			error("bad argument #1 to 'new' (enumerator '" .. name .. "' cannot be created)", 2)
		elseif not ENUM_OVERWRITE_ENABLED and enums[name] then
			error("bad argument #1 to 'new' (user-made enumerator '" .. name .. "' already exists)", 2)
		elseif not RBX_ENUM_OVERWRITED_ENABLED and pcall(function() return Enum[name] end) then
			error("bad argument #1 to 'new' (standard enumerator '" .. name .. "' already exists)", 2)
		elseif list == nil or type(list) ~= "table" then
			error("bad argument #2 to 'new' (table expected, got " .. (list ~= nil and type(list) or "no value") .. ")", 2)
		elseif not EMPTY_ENUM_ENABLED and #list == 0 then
			error("bad argument #2 to 'new' (table has no elements)", 2)
		end
		
		local keys = {}
		local values = {}
		
		-- Loop over table elements and check their validity:
		for key, value in pairs(list) do
			if type(key) ~= "number" then
				error("bad argument #2 to 'new' (table has non-numerical index)", 2)
			elseif key ~= math.floor(key) then
				error("bad argument #2 to 'new' (table has non-integer index)", 2)
			elseif key < 0 then
				error("bad argument #2 to 'new' (table has negative index)", 2)
			elseif type(value) ~= "string" then
				error("bad argument #2 to 'new' (table has non-string value)", 2)
			elseif value == "GetEnumItems" then
				error("bad argument #2 to 'new' (table has illegal value '" .. value .. "')", 2)
			elseif VARIABLE_STYLE_NAMING and not value:match("^[%a_][%w_]*$") then
				error("bad argument #2 to 'new' (table has illegal value '" .. value .. "')", 2)
			elseif keys[key] then
				error("bad argument #2 to 'new' (table keys should be unique)", 2)
			elseif values[value] then
				error("bad argument #2 to 'new' (table values should be unique)", 2)
			end
			keys[key] = true
			values[value] = true
		end
		
		-- Print warnings for possibly unintended behaviour if enabled:
		if WARNINGS_ENABLED then
			if ENUM_OVERWRITE_ENABLED and enums[name] then
				warn("user-made enumerator '" .. name .. "' is being overwritten")
			end
			if RBX_ENUM_OVERWRITED_ENABLED and pcall(function() return Enum[name] end) then
				warn("standard enumerator '" .. name .. "' is being overwritten")
			end
			if EMPTY_ENUM_ENABLED and #list == 0 then
				warn("enumerator '" .. name .. "' has no elements")
			end
		end
		
		-- Loop over values in table and create EnumItem objects for them:
		local enumlist = {}
		for value, itemname in pairs(list) do
			
			local vars = {Value = value, Name = itemname}
			
			local enumitem = setmetatable(
				{},{
					__metatable = __METATABLE,
					__index = function(_, key)
						return vars[key] or error(key .. " is not a valid member", 2)
					end,
					__newindex = function() error("EnumItem cannot be modified", 2) end,
					__tostring = function() return string.format("Enum.%s.%s", name, itemname) end
				}
			)
			
			enumlist[itemname] = enumitem
			
		end
		
		-- Add reference to GetEnumItems to Enum object:
		enumlist["GetEnumItems"] = function() return GetEnumItems(enumlist) end
		
		-- Create Enum object itself:
		local enum = setmetatable(
			{},{
				__metatable = __METATABLE,
				__index = function(_, key)
					return enumlist[key] or error(key .. " is not a valid member", 2)
				end,
				__newindex = function() error("Enum cannot be modified", 2) end,
				__tostring = function() return name end
			}
		)
		
		-- Add new enumerator to the list of enumerators:
		enums[name] = enum
		
	end
	
	-- Check if a certain enumerator exists and return it:
	function enums:Find(name)
		-- Check validity of name argument:
		if name == nil or type(name) ~= "string" then
			error("bad argument #1 to 'Find' (string expected, got " .. (name ~= nil and type(name) or "no value") .. ")", 2)
		elseif name == "new" or name == "Find" or name == "GetStandardEnums" or name == "FromValue" then
			return nil
		end
		-- We don't want this function to hard crash on non-existing enumerator,
		-- so wrap index to Enum into a pcall:
		return enums[name] or pcall(function() return Enum[name] end)
	end
	
	-- Get the original Enums userdata:
	function enums:GetStandardEnums()
		return Enum
	end
	
	-- Get an EnumItem from a name of the enumerator and its value:
	function enums:FromValue(name, value)
		
		-- Check validity of arguments:
		if name == nil or type(name) ~= "string" then
			error("bad argument #1 to 'FromValue' (string expected, got " .. (name ~= nil and type(name) or "no value") .. ")", 2)
		elseif name == "new" or name == "Find" or name == "GetStandardEnums" or name == "FromValue" then
			error("bad argument #1 to 'FromValue' (enumerator to find with illegal name)", 2)
		elseif type(value) ~= "number" then
			error("bad argument #2 to 'FromValue' (value is not a number)", 2)
		elseif value ~= math.floor(value) then
			error("bad argument #2 to 'FromValue' (value is not an integer)", 2)
		elseif value < 0 then
			error("bad argument #2 to 'FromValue' (value is negative)", 2)
		end
		
		-- Loop over EnumItems and return EnumItem with corresponding Value:
		local items = meta[name]:GetEnumItems()
		
		for _,item in pairs(items) do
			if item.Value == value then
				return item
			end
		end
		
		return nil
		
	end
	
	-- Create main Enums object:
	meta = setmetatable(
		{},{
			__metatable = __METATABLE,
			__index = function(_, key)
				return enums[key] or Enum[key]
			end,
			__newindex = function() error("Enums cannot be modified", 2) end,
			__tostring = function() return tostring(Enum) end
		}
	)

end

return meta
