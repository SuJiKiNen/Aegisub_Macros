local tr = aegisub.gettext

script_name = tr"Furigana Sytlize"
script_description = tr"Generate independent style datas for every syllable and furigana from Aegisub karaskel furigana work"
script_author = "SuJiKiNen"
script_version = "1.0"

require "karaskel"

furi_styles = {}
main_styles = {}
cover_styles = {}
furi_lines = {}

 -- settings
local generate_furigana = true
karaskel.furigana_scale = 0.4
maintext_vertical_position_fixed = 0
maintext_horizontal_position_fixed = 0
furigana_vertical_position_fixed = 0
furigana_horizontal_position_fixed = 0
furigana_spacing = 0
no_blank_syl = true
no_blank_furi = true
--  settings

function remove_furiganas(subs) 
	local i = 1
	while i <= #subs do
		local l = subs[i]
		i = i + 1
		if l.class == "dialogue" and l.effect == "furigana" then
			i = i - 1
			subs.delete(i)
		end
	end
end

function remove_karaskel_furigana_styles(subs)
	local i = 1
	while i <= #subs do
		local l = subs[i]
		i = i + 1
		if l.class == "style" and l.name:match("furigana") then
			i = i - 1
			subs.delete(i)
		end
	end
end

function set_furigana_spacing(styles)
	for i=1, #styles do
      local style = styles[i]
	  if style.name:match("furigana") then
			style.spacing = furigana_spacing
	  end
   end
end

function sytlize(subs)
   remove_karaskel_furigana_styles(subs)
   remove_furiganas(subs)
   meta,styles = karaskel.collect_head(subs,generate_furigana)
   set_furigana_spacing(styles)
   
   local style_start_i = nil
   local style_end_i = nil
   local dialog_start_i = nil
   local dialog_end_i = nil
   dialog_start_i,dialog_end_i = get_dialogs_range(subs)
   for i=dialog_start_i,dialog_end_i do
		local line = subs[i]
		karaskel.preproc_line_text(meta,styles,line)
		karaskel.preproc_line_size(meta,styles,line)
		karaskel.preproc_line_pos(meta,styles,line)
		local syl_count = 0
		for k=1,#line.kara do 
			local syl = line.kara[k]
			if not (no_blank_syl and is_syl_blank(syl)) then
				syl_count = syl_count + 1
				local syl_line = table.copy(line)
				syl_line.text =  syl.text_stripped
				syl_line.effect = "furigana"
				syl_line.comment = false
				syl_line.style = string.format("line_%d_syl_%d",i-dialog_start_i+1,syl_count)
				syl_line.actor = string.format("{syl,%d,%d,%d}",syl.start_time,syl.end_time,syl.duration)
				
				local syl_style = table.copy(line.styleref)
				syl_style.name = syl_line.style
				syl_style.margin_l = line.left+syl.left+maintext_horizontal_position_fixed
				syl_style.margin_r = 0
				syl_style.align = ( (line.styleref.align <4) and 1) or 7
				syl_style.margin_t = line.eff_margin_t + maintext_vertical_position_fixed
				syl_style.margin_b = line.eff_margin_b + maintext_vertical_position_fixed
				syl_style.margin_v = line.eff_margin_v + maintext_vertical_position_fixed

				if not styles[ syl_style.name ] then 
					table.insert(main_styles,syl_style)
				else
					cover_styles[ syl_style.name ] = syl_style
				end
				subs.append(syl_line)
			end
		end
		
		local furi_count = 0
		for j=1,line.furi.n do
			local furi = line.furi[j]
			if not (no_blank_furi and is_furi_blank(furi)) then
				furi_count = furi_count +1
				local furi_line = table.copy(line)
				furi_line.text = furi.text
				furi_line.effect = "furigana"
				furi_line.comment = false
				furi_line.layer = furi_count
				furi_line.style = string.format("line_%d_furi_%d",i-dialog_start_i+1,furi_count)
				furi_line.actor = string.format("{furi,%d,%d,%d}",furi.start_time,furi.end_time,furi.duration)
				local furi_style = table.copy(line.styleref)
				furi_style.name = furi_line.style
				furi_style.margin_l = line.left+furi.left+furigana_horizontal_position_fixed
				furi_style.margin_r = 0
				furi_style.align = ( (line.styleref.align <4) and 1) or 7
				furi_style.fontsize = furi_style.fontsize*karaskel.furigana_scale
				furi_style.outline  = furi_style.outline *karaskel.furigana_scale
				furi_style.shadow   = furi_style.shadow  *karaskel.furigana_scale
				furi_style.margin_t = line.eff_margin_t + line.height + furigana_vertical_position_fixed
				furi_style.margin_b = line.eff_margin_b + line.height + furigana_vertical_position_fixed
				furi_style.margin_v = line.eff_margin_v + line.height + furigana_vertical_position_fixed 
				if not styles[ furi_style.name ] then 
					table.insert(furi_styles,furi_style)
				else
					cover_styles[ furi_style.name ] = furi_style
				end
				subs.append(furi_line)
			end
		end
   end
   style_start_i,style_end_i=get_styles_range(subs)
   for i=style_start_i,style_end_i do
		local style = subs[i]
		if cover_styles[ style.name ] then
		   subs[ i ] = cover_styles[ style.name ]
		end
   end
   
   for i=1,#main_styles do
		subs[ -style_start_i ] = main_styles[i]
   end
   
   for i=1,#furi_styles do
		subs[ -style_start_i ] = furi_styles[i]
   end
   remove_karaskel_furigana_styles(subs)
end

function get_styles_range(subs)
   local style_start_i = nil
   local style_end_i = nil
   for i = 1, #subs do
      local line = subs[i];
      
	  if not style_start_i and line.class == "style" then
		  style_start_i = i
	  end
	  if line.class == "style" then
		  style_end_i = i
	  end
   end
   return style_start_i,style_end_i
end

function get_dialogs_range(subs)
   local dialog_start_i = nil
   local dialog_end_i = nil
      for i = 1, #subs do
      local line = subs[i];
	  
	  if not dialog_start_i and line.class == "dialogue" then
		  dialog_start_i = i
	  end
	  if line.class == "dialogue" then
		  dialog_end_i = i
	  end
   end
   return dialog_start_i,dialog_end_i
end

function is_furi_blank(furi)
	if furi.duration <= 0 then
		return true
	end
	
	local t = furi.text_stripped
	if t:len() <= 0 then return true end
	t = t:gsub("[ \t\n\r]", "") -- regular ASCII space characters
	t = t:gsub("　", "") -- fullwidth space
	return t:len() <= 0
end

function is_syl_blank(syl)
	if syl.duration <= 0 then
		return true
	end
	
	-- try to remove common spacing characters
	local t = syl.text_stripped
	if t:len() <= 0 then return true end
	t = t:gsub("[ \t\n\r]", "") -- regular ASCII space characters
	t = t:gsub("　", "") -- fullwidth space
	return t:len() <= 0
end

aegisub.register_macro(script_name, script_description, sytlize)
