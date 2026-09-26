# 🫧 Studio Screensaver
## About Plugin
Do you remeber the Windows 7 Bubble Screensaver?

You can have it in Roblox Studio now!

![Preview](https://github.com/user-attachments/assets/96a6b105-03a2-4240-9628-b75087901c1c)

## How to Setup
1. Download [Screensaver.rbxmx](https://github.com/ApplePancake63/Studio-Screensaver/blob/main/Screensaver.rbxmx) [(About .rbxmx)](https://fileinfo.com/extension/rbxmx)
2. Open local plugins folder

   Windows: Press **Win+R** and execute ```%LOCALAPPDATA%\Roblox\Plugins```

   MacOS: Open ```~/Library/Application Support/Roblox/Plugins```

4. Put **Screensaver.rbxmx** into this folder
5. Plugin is ready-to-use! But let's configure it
6. Enable CoreGui for the Roblox Studio Explorer [(Guide)](https://devforum.roblox.com/t/accessing-the-coregui-in-a-localscript/495164/6)
7. Find a folder in CoreGui named **!Bubbles** and check it's attributes
8. Screensaver turns on after elapsing the time in seconds set in **SleepTime** attribute

   Set a time in seconds you're comfortable with (30 sec by default)
9. You can change the style of Screensaver at any time with **Style** attribute

   Set the **Style** attribute to the name of a module in StylesFolder (Bubbles by default)
10. All attributes are saved to plugin's data after changes

    So, after restarting Roblox Studio, you won't lose changed attributes
## Creating & Changing Styles
1. Enable CoreGui in the Roblox Studio Explorer [(Guide)](https://devforum.roblox.com/t/accessing-the-coregui-in-a-localscript/495164/6)
2. Create a new module in CoreGui/!Bubbles/StylesFolder

   Recommended layout:
   ```lua
   local style={}
   style.__index=style

   function style:On()
     local self = setmetatable({},style)
     return self
   end

   function style:Off()
   end

   return style
   ```
   Or this in case you don't want to use metatable:
   ```lua
   local style={}

   function style:On()
     local self = {}

     function self:Off()
     end

     return self
   end
   
   return style
   ```
   style:On() function fires when user is afk for **SleepTime** seconds

   **self**:Off() function fires when user's action detected
3. To **get** any style's data from the plugin's data, you can use BindableFunctions:
   ```lua
   local value = script.Parent.Parent.GetData:Invoke(key)
   ```
   To **save** any style's data to the plugin's data, you can use:
   ```lua
   script.Parent.Parent.SetData:Invoke(key, value)
   ```
4. Plugin automatically saves any changes of styles from StylesFolder

   So, after restarting Roblox Studio, you won't lose changed styles

   Plugin saves only StylesFolder's Children, not Descendants
   
5. P.S. Roblox module caching can be quirky a bit
   
   So style executor may not see the changes immediately

   Plugin itself **does** see & saves the changes immediately though
## FAQ
I want to stop the plugin
1. Destroy the !Bubbles folder in CoreGui so style executor will stop working and will attempt to turn the style off
2. It will come back to work after restart/launching into the test

I want to delete the plugin
1. Destroy the !Bubbles folder in CoreGui so style executor will stop working and will attempt to turn the style off
2. Delete Screensaver.rbxmx from the Roblox's local plugin folder

I changed the code of style but when it turned On, changes weren't applied
1. It happens because of caching in RobloxStudio
2. Create a new module with the same name
3. Paste your code into it
4. Destroy the past module
