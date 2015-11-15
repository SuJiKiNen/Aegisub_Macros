local tr = aegisub.gettext

script_name = tr"Export By Actor"
script_description = tr"Export parts of subtitles by actor"
script_author = "SujiKiNen"
script_version = "1.0"

function export_by_actor(subs,configs)

	local export_actors = {n=0}
	
	for i = 1,#subs do
		local l = subs[i]
		if l.class == "dialogue" then
			export_actors.n =  export_actors.n + 1
			export_actors[ l.actor ] = false
			export_actors[ l.actor] = configs[ l.actor ]
		end
	end
	
	if export_actors.n>0 then 
		local del_line_idxs = {}
		for i = 1, #subs do
			local l = subs[i]
			if (l.class == "dialogue") and (l.actor~="") and (export_actors[ l.actor ] == false) then
				table.insert(del_line_idxs,i)
			end
			
			if l.class == "dialogue" and l.actor=="" and configs["rm_n_actor"] == true then
				table.insert(del_line_idxs,i)
			end
			
			if l.class == "dialogue" and l.text=="" and configs["rm_b_line"] == true then
				table.insert(del_line_idxs,i)
			end
		end
		
		if #del_line_idxs~=0 then
			subs.delete(del_line_idxs)
		end
	end
	
end

function export_by_actor_config_dialog(subs, old_setting)
	local actors = {n=0}
	
	for i=1,#subs do
		local l = subs[i]
		if l.class == "dialogue" then
			
			if  actors[ l.actor ]==nil and l.actor~="" then
				actors.n = actors.n + 1
				actors[ l.actor ] = true
				actors[ actors.n ] = l.actor
			end
			
		end
	end
	
	local config_dialog = {}
	
	if actors.n~=0 then
		table.insert(config_dialog,{class = "label",label="Remove no actor line:",x=0,y=0,width=1,height=1})
		table.insert(config_dialog,{class = "checkbox",name="rm_n_actor",value=true,x=1,y=0,width=1,height=1})
		table.insert(config_dialog,{class = "label",label="Remove blank line:",x=0,y=1,width=1,height=1})
		table.insert(config_dialog,{class = "checkbox",name="rm_b_line",value=true,x=1,y=1,width=1,height=1})	
		table.insert(config_dialog,{class = "label",label="Choose specific actor of lines to export:",x=0,y=2,width=1,height=1})
	else
		table.insert(config_dialog,{class = "label",label="No actors found!",x=0,y=0,width=1,height=1})
	end
	
	local pre_n = 2
	
	for i=1,actors.n do
		table.insert(config_dialog,{class = "label",label=actors[i],x=0,y=i+pre_n,width=1,height=1})
		table.insert(config_dialog,{class = "checkbox",name = actors[i],value=false,x=1,y=i+pre_n,width=1,height=1})
	end
	
	return config_dialog 
end

aegisub.register_filter(script_name, script_description, 3000, export_by_actor,export_by_actor_config_dialog)


