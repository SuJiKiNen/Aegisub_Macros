tr = aegisub.gettext

export script_name = tr"Space Converter"
export script_description = tr"Convert space between halfwidth and fullwidth"
export script_author = "SuJiKiNen"
export script_version = "1"

half2full = (subs, sel) ->
	
	for _,i in ipairs sel 
		line = subs[i]
		line.text  = string.gsub line.text," ","　"
		subs[i] = line
		
full2half = (subs, sel) ->
	
	for _,i in ipairs sel 
		line = subs[i]
		line.text  = string.gsub line.text,"　"," "
		subs[i] = line
		
		
aegisub.register_macro "#{script_name}/Half2Full", script_description, half2full
aegisub.register_macro "#{script_name}/Full2Half", script_description, full2half