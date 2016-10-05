tr = aegisub.gettext

export script_name = tr"Romaji Converter"
export script_description = tr"Translate Plain Japanese Sentence to romaji via Google Translate"
export script_author = "SuJiKiNen"
export script_version = "1"
export script_created = "2016_09_24"
export script_last_updatee = "2016_10_02"

DownloadManager = require "DM.DownloadManager"
html = require 'html'

encode = (str) ->
	--Ensure all newlines are in CRLF form
	str = str\gsub "\r?\n", "\r\n"
	--Percent-encode all non-unreserved characters
	--as per RFC 3986, Section 2.3
	--(except for space, which gets plus-encoded)
	str = str\gsub "([^%w%-%.%_%~ ])",(c) -> return string.format "%%%02X", string.byte c

	--Convert spaces to plus signs
	str = str\gsub " ", "+"
	return str
	
romaji = (subs, sel) ->
	
	src_lang = "jp"
	dst_lang = "en"
	dlm = DownloadManager!
	base = aegisub.decode_path "?user/"
	filename = "tmp.txt"
	save_path = base..filename
	
	process_i = 0
	for _,i in ipairs sel 
		line = subs[i]
		if line.class == "dialogue"
			process_i +=1
			encoded_str = encode line.text
			url = "https://translate.google.com/?hl=en&eotf=1&sl=#{src_lang}&tl=#{dst_lang}&q=#{encoded_str}"
			dl, err = dlm\addDownload url,save_path
			dlm\waitForFinish -> true
			if dl.error
				aegisub.debug.out "error while downloading\n"
			else
				file = io.open save_path,"r"
				html_str = file\read "*a"
				file\close!
				--<div id=src-translit class=translit dir=ltr style="text-align:;display:block">Nihon</div>
				romaji_str = html_str\match "<div id=src%-translit.->(.-)</div>"
				line.text = html.unescape romaji_str
				subs[i] = line
			
			aegisub.progress.set process_i*100/#sel
		
			
aegisub.register_macro script_name, script_description, romaji