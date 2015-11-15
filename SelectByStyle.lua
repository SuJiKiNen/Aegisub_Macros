local tr = aegisub.gettext

script_name = tr"Select By Style"
script_description = tr"Select parts of subtitles by style"
script_author = "SujiKiNen"
script_version = "1.0"
script_last_update = "2015/15/11"

function select_by_style(subs)
	button, results = aegisub.dialog.display(get_config_dialog(subs), {"OK","Cancel"})
	if button == "OK" then
		local sel_styles = {}
		
		for i = 1,#subs do
			local l = subs[i]
			if l.class == "style" then
				sel_styles[ l.name ] = false
				sel_styles[ l.name ] = results[l.name]
			end
		end
		
		local sel_idxs = {}
		
		for i = 1, #subs do
			local l = subs[i]
			if (l.class == "dialogue") and (sel_styles[ l.style ] == true) then
				table.insert(sel_idxs,i)
			end
			
		end
		return sel_idxs
	else
		aegisub.cancel()
	end
end

function get_config_dialog(subs)
	local config_dialog = {
		{
			class = "label",
			label = "Choose styles to select:",
			x = 0, y = 0, width = 1, height = 1
		}
	}
	
	local style_n = 0
	local pre_n = 0
	
	for i = 1, #subs do
		local l = subs[i]
		if l.class == "style" then
			style_n = style_n +  1
			table.insert(config_dialog, {class = "label",   label = l.name,            x=0,y=style_n+pre_n,width=1,height=1})
			table.insert(config_dialog, {class = "checkbox",name  = l.name,value=false,x=1,y=style_n+pre_n,width=1,height=1})
		end
	end
	return config_dialog 
end

aegisub.register_macro(script_name, script_description, select_by_style)


