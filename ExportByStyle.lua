local tr = aegisub.gettext

script_name = tr"Export By Style"
script_description = tr"Export parts of subtitles by style"
script_author = "SujiKiNen"
script_version = "1.0"

function export_by_style(subs,configs)
	local export_styles = {}
	
	for i = 1,#subs do
		local l = subs[i]
		if l.class == "style" then
			export_styles[ l.name ] = false
			export_styles[ l.name ] = configs[l.name]
		end
	end
	
	local del_line_idxs = {}
	
    for i = 1, #subs do
        local l = subs[i]
		if (l.class == "dialogue") and (export_styles[ l.style ] == false) then
			table.insert(del_line_idxs,i)
		end
		
		if l.class=="dialogue" and l.text=="" and configs["rm_b_line"] == true then
			table.insert(del_line_idxs,i)
		end
    end
	
	if #del_line_idxs~=0 then
		subs.delete(del_line_idxs)
	end
end

function export_by_style_config_dialog(subs, old_setting)
	local config_dialog = {
		{
			class = "label",
			label = "Remove blank line",
			x = 0 , y = 0 , width =1 ,height = 1
		},
		{
			class = "checkbox",
			name = "rm_b_line",
			value = true,
			x = 1 , y = 0 , width =1 ,height =1 
		},
		{
			class = "label",
			label = "Choose specific style of lines to export:",
			x = 0, y = 1, width = 1, height = 1
		}
	}
	
	local style_n = 0
	local pre_n = 1
	
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

aegisub.register_filter(script_name, script_description, 3000, export_by_style,export_by_style_config_dialog)


