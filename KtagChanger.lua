
local tr = aegisub.gettext

script_name = tr"Ktag Changer"
script_description = tr"Change Ktag"
script_author = "SuJiKiNen"
script_version = "2.0"
script_modified = "2015/02/14"
script_last_modified =  "2015/08/21"
include("utils.lua")

--settings
local new_ktag="\\kf"

dialog_config = 
{
	[1] = {class="label",x=2,y=0,width=1,height=1,label="New Ktag:"},
	[2] = {class="dropdown",name="ktag",x=4,y=0,width=1,height=1,items={"kf","k","K","ko"},value="kf"},
}

function change_ktag(subs)
	button,result = aegisub.dialog.display(dialog_config,{"OK","Cancel"})
	if button =="OK" then
		for i=1,#subs do
			local line = subs[i]
			if line.class == "dialogue" or line.class == "comment" then
				 line.text = line.text:gsub("{(.-)(\\[kK][of]?)(%d+)(.-)}","{%1".."\\"..result["ktag"].."%3%4}")
				 subs[i] = line
			end
		end
	else
		aegisub.cancel()
	end
end

aegisub.register_macro(script_name, script_description, change_ktag)

