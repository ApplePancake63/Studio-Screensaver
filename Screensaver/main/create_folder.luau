local core_gui=game:GetService("CoreGui")
return function()
	local main_folder=Instance.new("Folder")
	main_folder.Name="!Bubbles"
	main_folder.IconTint=Color3.fromRGB(0,85,255)
	main_folder.Parent=core_gui
	--|
	local styles_folder=Instance.new("Folder")
	styles_folder.Name="StylesFolder"
	styles_folder.Parent=main_folder
	styles_folder.IconTint=Color3.fromRGB(128,0,255)
	--|
	local get_data=Instance.new("BindableFunction")
	get_data.Name="GetData"
	get_data.Parent=main_folder
	local set_data=Instance.new("BindableFunction")
	set_data.Name="SetData"
	set_data.Parent=main_folder
	--|
	local gui=Instance.new("ScreenGui")
	gui.Name="gui"
	gui.DisplayOrder=2147483647
	gui.ScreenInsets=Enum.ScreenInsets.None
	gui.Parent=main_folder
	--|
	return main_folder
end
