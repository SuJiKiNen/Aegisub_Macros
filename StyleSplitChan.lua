
script_name = "StyleSplitChan"
script_description = "Use it to Split Styled Bilingual line to 2 lines with specific style";
script_author = "SuJiKiNen";
script_version = "1.0";
script_last_update_date = "2014/14/01";

require "karaskel"
require "re"
--GUI Part

dialog_config=
{
	[2]={class="label",x=0,y=0,label="SelectSpiltStyle:"},
	[3]={class="dropdown",name="SelectedSpiltStyle",x=1,y=0,width=1,height=1,items={},value=""},
	
	[4]={class="label",x=2,y=0,width=1,height=1,label="SplitCharacter:"},
	[5]={class="edit",name="SplitCharacter",x=3,y=0,width=1,height=1,value="\\N"},
	[6]={class="checkbox",name="DeleteSplitStyleLine",x=4,y=0,width=1,height=1,label="DeleteSplitedLines",value=true},
	
	[7]={class="label",x=0,y=1,width=1,hegiht=1,label="SetFirstPartStyle:"},
	[8]={class="dropdown",name="FirstPartStyle",x=1,y=1,width=1,height=1,items={},value=""},
	[9]={class="checkbox",name="FirstPartKeepTags",x=2,y=1,width=1,height=1,label="KeepASSTags",value=false},
	[10]={class="label",x=3,y=1,width=1,hegiht=1,label="SetFirstPartLayer:"},
	[11]={class="intedit",name="FirstPartLayer",x=4,y=1,width=1,height=1,value=1},
	
	[12]={class="label",x=0,y=2,width=1,hegiht=1,label="SetSecondPartStyle:"},
	[13]={class="dropdown",name="SecondPartStyle",x=1,y=2,width=1,height=1,items={},value=""},
	[14]={class="checkbox",name="SecondPartKeepTags",x=2,y=2,width=1,height=1,label="KeepASSTags",value=false},		
	[15]={class="label",x=3,y=2,width=1,hegiht=1,label="SetSecondPartLayer:"},
	[16]={class="intedit",name="SecondPartLayer",x=4,y=2,width=1,height=1,value=2},
}


SplitIdx = 3;
FirstPartIdx = 8;
SecondPartIdx = 13;

function SetDropItem(subs,sel)
   
	meta, styles = karaskel.collect_head(subs);
	dialog_config[ SplitIdx ].items={};
	for i=1,styles.n,1 do
		table.insert(dialog_config[ SplitIdx ].items,styles[i].name);
	end
	
	dialog_config[ FirstPartIdx ].items = table.copy(dialog_config[ SplitIdx ].items );
	dialog_config[ FirstPartIdx ].value = dialog_config[ FirstPartIdx ].items[1];
	
	dialog_config[ SecondPartIdx ].items = table.copy(dialog_config[ SplitIdx ].items );
	dialog_config[ SecondPartIdx ].value = dialog_config[ SecondPartIdx ].items[1]; 
	   
	   
   --set default by maximum line style
	
	local count={};
	for i=1,styles.n,1 do
		count[ styles[i].name ] = 0;
	end	 
	
	for i=1,#subs,1 do
		local line = subs[i];
		if line.class == "dialogue" then
		 count[ line.style ] = count[ line.style ]+1;
		end
	end
	
	local MaxLine=0;
	local MaxLineStyleName = nil;
	for i=1,styles.n,1 do
		local tname  = styles[i].name;
		local tcount = count[ tname ];
		if tcount > MaxLine then
			MaxLine = tcount;
			MaxLineStyleName = tname;
		end
	end
	
	if MaxLineStyleName~=nil then
		dialog_config[ SplitIdx ].value = MaxLineStyleName;
	end
	
end


function TextTagsFilter(Text)
   return Text:gsub("{[^}]+}", "");
end

function Split(pString, pPattern)
	local Table = {}	 -- NOTE: use {n = 0} in Lua-5.0
	local fpat = "(.-)" .. pPattern
	local last_end = 1
	local s, e, cap = pString:find(fpat, 1)
	while s do
		if s ~= 1 or cap ~= "" then
			table.insert(Table,cap)
		end
		last_end = e+1
		s, e, cap = pString:find(fpat, last_end)
	end
	if last_end <= #pString then
		cap = pString:sub(last_end)
		table.insert(Table, cap)
	end
	return Table
end


function SplitLine(subs,sel)
	buttons,results =aegisub.dialog.display(dialog_config,{"OK","Cancel"});	
	if buttons=="OK" then
		local SpecificSplitStyle = results["SelectedSpiltStyle"];
		local FirstSetStyle = results["FirstPartStyle"]; 
		local SecondSetStyle = results["SecondPartStyle"];
		local SplitCharacter = results["SplitCharacter"];
		local FirstPartKeepTags	= results["FirstPartKeepTags"];
		local SecondPartKeepTags = results["SecondPartKeepTags"]; 
		local FirstPartLayer = results["FirstPartLayer"];
		local SecondPartLayer = results["SecondPartLayer"];
		local DeleteSplitStyleLine = results["DeleteSplitStyleLine"];
		
		local TotalProcessLineNum = 0;
		for i=1,#subs,1 do
			local line = subs[i];
			if line.class=="dialogue" and line.style==SpecificSplitStyle then
				TotalProcessLineNum = TotalProcessLineNum  + 1;
			end
		end
		
		local CurrentProcessLineNum = 0;
		local SpecificStyleIndex={};
		local OldSubsLen = #subs;
		for i=1,OldSubsLen,1 do
			local line = subs[i];
			if line.class=="dialogue" and line.style==SpecificSplitStyle then
			
				CurrentProcessLineNum = CurrentProcessLineNum + 1;
				SpecificStyleIndex[#SpecificStyleIndex + 1] = i;
				local SplitTextTable = Split(line.text,SplitCharacter);
				local FirstText = SplitTextTable[1];
				local SecondText = SplitTextTable[2];
				if FirstText~=nil then
					if FirstPartKeepTags == false then
						FirstText = TextTagsFilter(FirstText);
					end
					local NewLine = table.copy(line);
					NewLine.text = FirstText;
					NewLine.style = FirstSetStyle;
					NewLine.layer = FirstPartLayer;
					subs.append(NewLine);
				end
			   
				if SecondText~=nil then
					if SecondPartKeepTags == false then
						SecondText = TextTagsFilter(SecondText);
					end
					local NewLine = table.copy(line);
					NewLine.text = SecondText;
					NewLine.style = SecondSetStyle;
					NewLine.layer = SecondPartLayer;
					subs.append(NewLine);
				end
			end
			aegisub.progress.set(CurrentProcessLineNum/TotalProcessLineNum);
		end
		
		if DeleteSplitStyleLine == true then
			subs.delete(SpecificStyleIndex);
		end
	end
end

function script_main(subs,sel)
	SetDropItem(subs,sel);
	SplitLine(subs,sel);
end

aegisub.register_macro(script_name, script_description, script_main)

