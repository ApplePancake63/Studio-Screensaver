local data = {}
local uis = game:GetService("UserInputService")
local run_service = game:GetService("RunService")
local bubbles = "Bubbles"
local function turn_on(main_folder)
	if tick() < data.unactive_since+data.sleep_time then return end
	local style = main_folder:GetAttribute("Style")
	local style_module = main_folder.StylesFolder:FindFirstChild(style)
	data.style=style_module and style or "Bubbles"
	local effect = require(main_folder.StylesFolder:FindFirstChild(data.style)or bubbles)
	return effect
end
return function(main_folder:Folder)
	data.sleep_time=main_folder:GetAttribute("SleepTime")
	data.unactive_since=tick()
	--|
	local connections = {}
	connections[1]=main_folder:GetAttributeChangedSignal("Style"):Connect(function()
		local style = main_folder:GetAttribute("Style")
		local style_module = main_folder.StylesFolder:FindFirstChild(style)
		data.style=style_module and style or "Bubbles"
		data.unactive_since=tick()
		if data.active~=nil then data.active:off() data.active=nil end
	end)
	connections[2]=main_folder:GetAttributeChangedSignal("SleepTime"):Connect(function()
		data.sleep_time=main_folder:GetAttribute("SleepTime")
		local effect=turn_on(main_folder)
		if data.active then data.active:off() end
		data.active = effect:on()
	end)
	connections[3]=uis.InputBegan:Connect(function()
		if data.sleep_time<=0 then return end
		data.unactive_since=tick()
		if data.active~=nil then data.active:off() data.active=nil end
	end)
	connections[4]=run_service.Heartbeat:Connect(function()
		if tick() < data.unactive_since+data.sleep_time or data.active then return end
		local effect=turn_on(main_folder)
		data.active=effect:on()
	end)
	--|
	local function termination_func()
		if data.active then data.active:off() end
		for _, v in connections do
			v:Disconnect()
		end
	end
	connections[5]=main_folder.Destroying:Once(termination_func)
	connections[6]=main_folder:GetPropertyChangedSignal("Parent"):Once(termination_func)
end
