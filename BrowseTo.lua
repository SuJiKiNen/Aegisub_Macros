local tr = aegisub.gettext
script_name = tr"Browse To"
script_description = tr"Open Containing Folder"
script_author = "SuJiKiNen"
script_version = "1"
script_created = "2016/31/08"
script_last_updated = "2016/03/09"

local ffi = require('ffi')
local shell32 = ffi.load("Shell32")
local ole32 = ffi.load("Ole32")

ffi.cdef[[

enum{CP_UTF8 = 65001};
typedef unsigned int UINT;
typedef unsigned long DWORD;
typedef const char* LPCSTR;
typedef const wchar_t* LPCWSTR;
typedef wchar_t* LPWSTR;
int MultiByteToWideChar(UINT, DWORD, LPCSTR, int, LPWSTR, int);
typedef int INT;


typedef unsigned short USHORT;
typedef unsigned char BYTE;
typedef long LONG;
typedef LONG HRESULT;
typedef LPCWSTR PCTSTR;
typedef void *LPVOID;

typedef struct _SHITEMID {
    USHORT cb;
    BYTE abID[1];
} SHITEMID;

typedef struct _ITEMIDLIST {
    SHITEMID mkid;
} ITEMIDLIST;
typedef ITEMIDLIST ITEMID_CHILD;

typedef const ITEMID_CHILD *PCUITEMID_CHILD;
typedef const PCUITEMID_CHILD *PCUITEMID_CHILD_ARRAY;

typedef const ITEMIDLIST *LPCITEMIDLIST;

typedef ITEMIDLIST ITEMIDLIST_RELATIVE;
typedef ITEMIDLIST_RELATIVE *PIDLIST_RELATIVE;

typedef enum tagCOINIT { 
  COINIT_APARTMENTTHREADED  = 0x2,
  COINIT_MULTITHREADED      = 0x0,
  COINIT_DISABLE_OLE1DDE    = 0x4,
  COINIT_SPEED_OVER_MEMORY  = 0x8
} COINIT;

HRESULT CoInitialize(LPVOID pvReserved);
HRESULT CoInitializeEx(LPVOID pvReserved,DWORD dwCoInit);
void CoUninitialize(void);

HRESULT SHOpenFolderAndSelectItems(LPCITEMIDLIST pidlFolder,UINT cidl,PCUITEMID_CHILD_ARRAY apidl,DWORD dwFlags);
LPCITEMIDLIST ILCreateFromPath(PCTSTR pszPath);
void ILFree(PIDLIST_RELATIVE pidl);

enum {S_OK=0x00000000L,S_FALSE=0x00000001L};
]]

local function utf8_to_utf16(s)
	-- Get resulting utf16 characters number (+ null-termination)
	local wlen = ffi.C.MultiByteToWideChar(ffi.C.CP_UTF8, 0x0, s, -1, nil, 0)
	-- Allocate array for utf16 characters storage
	local ws = ffi.new("wchar_t[?]", wlen)
	-- Convert utf8 string to utf16 characters
	ffi.C.MultiByteToWideChar(ffi.C.CP_UTF8, 0x0, s, -1, ws, wlen)
	-- Return utf16 C string
	return ws
end

function browse_2_script(subs,sel)
	local path = aegisub.decode_path("?script/")..aegisub.file_name()
	local ret = ole32.CoInitializeEx(nil,ffi.C.COINIT_MULTITHREADED)
	local pid = shell32.ILCreateFromPath(utf8_to_utf16(path))
	local status = shell32.SHOpenFolderAndSelectItems(pid,ffi.new("UINT",0),nil,ffi.new("DWORD",0))
	shell32.ILFree(ffi.cast("PIDLIST_RELATIVE",pid))
	ole32.CoUninitialize()
end

function browse_2_video(subs,sel)
	properties = aegisub.project_properties()
	local path = properties.video_file
	
	if path:sub(1,6)=="?dummy" then
		aegisub.debug.out("dummy video！",3)
		return 
	end
	
	local ret = ole32.CoInitializeEx(nil,ffi.C.COINIT_MULTITHREADED)
	local pid = shell32.ILCreateFromPath(utf8_to_utf16(path))
	local status = shell32.SHOpenFolderAndSelectItems(pid,ffi.new("UINT",0),nil,ffi.new("DWORD",0))
	shell32.ILFree(ffi.cast("PIDLIST_RELATIVE",pid))
	ole32.CoUninitialize()
end

function browse_2_audio(subs,sel)
	properties = aegisub.project_properties()
	local path = properties.audio_file
	
	if path:sub(1,11)=="dummy-audio" then
		aegisub.debug.out("dummy audio！",3)
		return 
	end
	
	local ret = ole32.CoInitializeEx(nil,ffi.C.COINIT_MULTITHREADED)
	local pid = shell32.ILCreateFromPath(utf8_to_utf16(path))
	local status = shell32.SHOpenFolderAndSelectItems(pid,ffi.new("UINT",0),nil,ffi.new("DWORD",0))
	shell32.ILFree(ffi.cast("PIDLIST_RELATIVE",pid))
	ole32.CoUninitialize()
end


aegisub.register_macro(script_name.."/Subtitle", script_description,browse_2_script)
aegisub.register_macro(script_name.."/Video", script_description,browse_2_video)
aegisub.register_macro(script_name.."/Audio", script_description,browse_2_audio)
