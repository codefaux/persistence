if persistence_encoder_loaded~=true then
	-- On load only;

	---encode number to hex string for saving
	---@param number integer
	---@return string hex_data
	local function number_to_hex(number)
		if number == nil then return ""; end

		local positive = math.abs(number);
		return (positive == number and "" or "-") .. string.format("%x", positive);
	end

	---decode hex string to number
	---@param hex string hex_data
	---@return number
	local function hex_to_number(hex)
		if hex == nil then return 0; end

		if string.sub(hex, 1, 1) == "-" then
			return tonumber(string.sub(hex, 2), 16) * -1;
		else
			return tonumber(hex, 16);
		end
	end

	local hex_chars = { "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f", "-" }
	---encode hex value and write to disk under named tag (mod_flag_name will be prepended)
	---@param name string name of psuedo-variable
	---@param hex string|nil
	local function write_encode_hex(name, hex)
		if hex == nil then
			for j = 1, #hex_chars do
				RemoveFlagPersistent(mod_flag_name .. "_" .. name .. "_" .. 1 .. "_" .. hex_chars[j]);
			end
			return;
		end

		for i = 1, #hex do
			for j = 1, #hex_chars do
				RemoveFlagPersistent(mod_flag_name .. "_" .. name .. "_" .. i .. "_" .. hex_chars[j]);
			end
			AddFlagPersistent(mod_flag_name .. "_" .. name .. "_" .. i .. "_" .. string.sub(hex, i, i));
		end
		for j = 1, #hex_chars do
			RemoveFlagPersistent(mod_flag_name .. "_" .. name .. "_" .. #hex + 1 .. "_" .. hex_chars[j]);
		end
	end

	---decode hex value of named tag from disk (mod_flag_name will be prepended)
	---@param name string name of pseudo-variable
	---@return string
	local function load_decode_hex(name)
		local output = "";
		local i = 1;
		repeat
			local hex_found = false;
			for j = 1, #hex_chars do
				if HasFlagPersistent(mod_flag_name .. "_" .. name .. "_" .. i .. "_" .. hex_chars[j]) then
					output = output .. hex_chars[j];
					hex_found = true;
					break;
				end
			end
			i = i + 1;
		until not hex_found
		return (output == "" and nil or output);
	end

	---decode number value of named tag from disk
	---@param name string name of pseudo-variable (mod_flag_name will be prepended)
	---@return number
	function load_decode_integer(name)
		return hex_to_number(load_decode_hex(name));
	end

	---write encoded number value of named tag to disk
	---@param name string name of pseudo-variable (mod_flag_name will be prepended)
	---@param value integer value of pseudo-variable
	function write_encode_integer(name, value)
		write_encode_hex(name, number_to_hex(value));
	end

	---write encoded number value of named tag to disk
	---@param name string name of pseudo-variable (mod_flag_name will be prepended)
	function clear_encode_integer(name)
		write_encode_hex(name, nil);
	end
	---end function declarations, run code here;


	print("=========================");
	print("persistence: Encoder loaded.");
	persistence_encoder_loaded=true;
end
