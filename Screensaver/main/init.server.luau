--\
local create_folder = require(script.create_folder)
local connect = require(script.connect)
--|
local http = game:GetService("HttpService")
local core_gui = game:GetService("CoreGui")
local main_folder = core_gui:FindFirstChild("!Bubbles")
--/

--\
if not main_folder then main_folder = create_folder() end
main_folder.GetData.OnInvoke = function(key)
	local sets = plugin:GetSetting("preset_data")or{}
	return sets[key]
end
main_folder.SetData.OnInvoke = function(key, value)
	local sets = plugin:GetSetting("preset_data")or{}
	sets[key]=value
	return plugin:SetSetting("preset_data", sets)
end
--/

--\
local styles:Folder=main_folder.StylesFolder
styles:ClearAllChildren()
main_folder.gui:ClearAllChildren()

local function rewrite_source()
	local presets={}
	for _, v in styles:GetChildren() do
		if not v:IsA("ModuleScript")then continue end
		presets[v.Name]=v.Source
	end
	plugin:SetSetting("_presets", presets)
end
local function reg_on_change(v:ModuleScript)
	local con=nil
	con=v.Changed:Connect(function(prop)
		if v.Parent ~= styles then return end
		rewrite_source()
		if prop=="Parent" then con:Disconnect() end
	end)
end
local presets = plugin:GetSetting("_presets")or{}
for i, v in presets do
	local module=Instance.new("ModuleScript")
	module.Name=i
	module.Source=v
	module.Parent=styles
	reg_on_change(module)
end
styles.ChildAdded:Connect(function(v)
	if not v:IsA("ModuleScript")then return end
	reg_on_change(v)
	rewrite_source()
end)
styles.ChildRemoved:Connect(function(v)
	rewrite_source()
end)
for _, v in script.Parent.presets:GetChildren() do
	if styles:FindFirstChild(v.Name)then continue end
	v:Clone().Parent=styles
end
--/

--\
main_folder:SetAttribute("SleepTime", 30)
main_folder:SetAttribute("Style", "Bubbles")
--|
local folder = plugin:GetSetting("folder")or{}
for i, v in folder do
	main_folder:SetAttribute(i,v)
end
main_folder.AttributeChanged:Connect(function(att)
	local folder = plugin:GetSetting("folder")or{}
	folder[att]=main_folder:GetAttribute(att)
end)
connect(main_folder)
--/