
require "karaskel"

script_name = "Dark Ruby"
script_description = "simple ruby way for (kanji,furigana) format"
script_author = "SujiKiNen"
script_version = 2.0
script_last_modified = "2015/08/21"

rubypadding = 0 
rubyscale = 0.5 


meta = nil
styles = nil

function ripairs(t)
  local function ripairs_it(t,i)
    i=i-1
    local v=t[i]
    if v==nil then return v end
    return i,v
  end
  return ripairs_it, t, #t+1
end

function dark_ruby(subs, sel)
	meta, styles = karaskel.collect_head(subs)
	for _, i in ripairs(sel) do
		local line = subs[i]
		line.comment =  true
		subs[i] = line
		process_line(subs,line,i)
	end
end



function process_line(subs,line,li)
	line.comment = false
	local originline = table.copy(line)
	
	local ktag="{\\k0}"
	local stylefs = styles[ line.style ].fontsize
	local rubbyfs = stylefs * rubyscale
	
	line.text = string.gsub(line.text,"%((.-),(.-)%)",ktag.."%1".."|".."%2"..ktag)
	karaskel.preproc_line(subs, meta, styles,line)
	originline.text = string.gsub(originline.text,"%((.-),(.-)%)","%1")
	originline.text = string.format("{\\pos(%d,%d)}",line.x,line.y)..originline.text
	
	for i = line.furi.n,1,-1 do
		local ruby_line = table.copy(line)
		local ruby_x = line.left + line.furi[i].syl.center;
		local ruby_y = line.top - rubbyfs/2 - rubypadding;
		ruby_line.text = string.format("{\\an5\\fs%d\\pos(%d,%d)}%s",rubbyfs,ruby_x,ruby_y,line.furi[i].text);
		subs[ -(li + 1) ] = ruby_line
	end
	subs[ -(li + 1) ] = originline
end


aegisub.register_macro(script_name, script_description, dark_ruby)