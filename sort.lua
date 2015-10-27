
local tr = aegisub.gettext;

script_name = tr"Sort"
script_description = tr"Sort Lines By Various Means"
script_author = "SuJiKiNen"
script_version = "1.0"
script_last_update="2015/24/10"
sort_sel = "Sort/Sort Selected Lines"
sort_all = "Sort/Sort All Lines"

include("karaskel.lua")

start_time_cmp = function(a,b) return a.start_time < b.start_time end
end_time_cmp = function(a,b) return a.end_time < b.end_time end 
dur_cmp = function(a,b) return (a.end_time - a.start_time) < (b.end_time-b.start_time) end
style_cmp = function(a,b) return a.style < b.style end
actor_cmp = function(a,b) return a.actor < b.actor end
effect_cmp = function(a,b) return a.effect < b.effect end
text_len_cmp = function(a,b) return unicode.len(a.text_stripped) < unicode.len(b.text_stripped) end
layer_cmp = function(a,b) return a.layer < b.layer end

function start_time_sort_sel(subs,sel)
	local sel_lines={}
	for _, i in ipairs(sel) do
		local line = subs[i]
		table.insert(sel_lines,line)
	end
	
	table.sort(sel_lines,start_time_cmp)
	
	local j=1
	for _, i in ipairs(sel) do
		subs[i] = sel_lines[ j ];
		j = j + 1
	end	
end

function start_time_sort_all(subs)
	local sel = {}
	for i=1,#subs do
		local line  = subs[i]
		if line.class == "dialogue" then
			table.insert(sel,i)
		end
	end
	sort_sel(subs,sel)
end

function end_time_sort_sel(subs,sel)
	local sel_lines={}
	for _, i in ipairs(sel) do
		local line = subs[i]
		table.insert(sel_lines,line)
	end
	
	table.sort(sel_lines,end_time_cmp)
	
	local j=1
	for _, i in ipairs(sel) do
		subs[i] = sel_lines[ j ];
		j = j + 1
	end	
end

function end_time_sort_all(subs)
	local sel = {}
	for i=1,#subs do
		local line  = subs[i]
		if line.class == "dialogue" then
			table.insert(sel,i)
		end
	end
	end_time_sort_sel(subs,sel)
end

function dur_sort_sel(subs, sel)
	local sel_lines={}
	for _, i in ipairs(sel) do
		local line = subs[i]
		table.insert(sel_lines,line)
	end
	
	table.sort(sel_lines,dur_cmp)
	
	local j=1
	for _, i in ipairs(sel) do
		subs[i] = sel_lines[ j ];
		j = j + 1
	end
end

function dur_sort_all(subs) 
	local sel = {}
	for i=1,#subs do
		local line = subs[i]
		if line.class == "dialogue" then
			table.insert(sel,i)
		end
	end
	dur_sort_sel(subs,sel)
end

function style_sort_sel(subs, sel)
	local sel_lines={}
	for _, i in ipairs(sel) do
		local line = subs[i]
		table.insert(sel_lines,line)
	end
	
	table.sort(sel_lines,style_cmp)
	
	local j=1
	for _, i in ipairs(sel) do
		subs[i] = sel_lines[ j ];
		j = j + 1
	end
end

function style_sort_all(subs) 
	local sel = {}
	for i=1,#subs do
		local line = subs[i]
		if line.class == "dialogue" then
			table.insert(sel,i)
		end
	end
	style_sort_sel(subs,sel)
end
function actor_sort_sel(subs, sel)
	local sel_lines={}
	for _, i in ipairs(sel) do
		local line = subs[i]
		table.insert(sel_lines,line)
	end
	
	table.sort(sel_lines,actor_cmp)
	
	local j=1
	for _, i in ipairs(sel) do
		subs[i] = sel_lines[ j ];
		j = j + 1
	end
end

function actor_sort_all(subs) 
	local sel = {}
	for i=1,#subs do
		local line = subs[i]
		if line.class == "dialogue" then
			table.insert(sel,i)
		end
	end
	actor_sort_sel(subs,sel)
end

function effect_sort_sel(subs, sel)
	local sel_lines={}
	for _, i in ipairs(sel) do
		local line = subs[i]
		table.insert(sel_lines,line)
	end
	
	table.sort(sel_lines,effect_cmp)
	
	local j=1
	for _, i in ipairs(sel) do
		subs[i] = sel_lines[ j ];
		j = j + 1
	end
end

function effect_sort_all(subs) 
	local sel = {}
	for i=1,#subs do
		local line = subs[i]
		if line.class == "dialogue" then
			table.insert(sel,i)
		end
	end
	effect_sort_sel(subs,sel)
end

function layer_sort_sel(subs, sel)
	local sel_lines={}
	for _, i in ipairs(sel) do
		local line = subs[i]
		table.insert(sel_lines,line)
	end
	
	table.sort(sel_lines,layer_cmp)
	
	local j=1
	for _, i in ipairs(sel) do
		subs[i] = sel_lines[ j ];
		j = j + 1
	end
end

function layer_sort_all(subs) 
	local sel = {}
	for i=1,#subs do
		local line = subs[i]
		if line.class == "dialogue" then
			table.insert(sel,i)
		end
	end
	layer_sort_sel(subs,sel)
end

function text_len_sort_sel(subs, sel)
	local meta, styles = karaskel.collect_head(subs,false)
	local sel_lines={}
	for _, i in ipairs(sel) do
		local line = subs[i]
		karaskel.preproc_line_text(meta, styles, line)
		table.insert(sel_lines,line)
	end
	
	table.sort(sel_lines,text_len_cmp)
	
	local j=1
	for _, i in ipairs(sel) do
		subs[i] = sel_lines[ j ];
		j = j + 1
	end
end

function text_len_sort_all(subs) 
	local sel = {}
	for i=1,#subs do
		local line = subs[i]
		if line.class == "dialogue" then
			table.insert(sel,i)
		end
	end
	text_len_sort_sel(subs,sel)
end

function reverse_sort_sel(subs,sel)
	local sel_lines = {}
	for _, i in ipairs(sel) do
		local line = subs[i]
		table.insert(sel_lines,line)
	end
	
	for k,v in ipairs(sel) do
		subs [ v ] = sel_lines[ #sel - k + 1 ]
	end
	return sel
end

function reverse_sort_all(subs)
	local sel = {}
	for i=1,#subs do
		local line  = subs[i]
		if line.class == "dialogue" then
			table.insert(sel,i)
		end
	end
	reverse_sort_sel(subs,sel)
end


aegisub.register_macro(sort_sel.."/Start Time", script_description,start_time_sort_sel)
aegisub.register_macro(sort_all.."/Start Time", script_description,start_time_sort_all)

aegisub.register_macro(sort_sel.."/End Time", script_description,end_time_sort_sel)
aegisub.register_macro(sort_all.."/End Time", script_description,end_time_sort_all)

aegisub.register_macro(sort_sel.."/Duration", script_description,dur_sort_sel)
aegisub.register_macro(sort_all.."/Duration", script_description,dur_sort_all)

aegisub.register_macro(sort_sel.."/Style Name", script_description,style_sort_sel)
aegisub.register_macro(sort_all.."/Style Name", script_description,style_sort_all)

aegisub.register_macro(sort_sel.."/Actor Name", script_description,actor_sort_sel)
aegisub.register_macro(sort_all.."/Actor Name", script_description,actor_sort_all)

aegisub.register_macro(sort_sel.."/Effect", script_description,effect_sort_sel)
aegisub.register_macro(sort_all.."/Effect", script_description,effect_sort_all)

aegisub.register_macro(sort_sel.."/Layer", script_description,layer_sort_sel)
aegisub.register_macro(sort_all.."/Layer", script_description,layer_sort_all)

aegisub.register_macro(sort_sel.."/Text Length", script_description,text_len_sort_sel)
aegisub.register_macro(sort_all.."/Text Length", script_description,text_len_sort_all)

aegisub.register_macro(sort_sel.."/Reverse", script_description,reverse_sort_sel)
aegisub.register_macro(sort_all.."/Reverse", script_description,reverse_sort_all)
