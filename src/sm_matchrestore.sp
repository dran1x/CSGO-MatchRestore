#include <matchrestore>
#include <ripext/json>
#include <sourcemod>

#define PLUGIN_DESCRIPTION ""
#define PLUGIN_VERSION     ""

#pragma semicolon 1
#pragma newdecls required

enum struct Global
{
	ConVar Debug;
	ConVar Enabled;
	ConVar AutoLoad;

	ConVar RecentFiles;
	ConVar AutoLoadPause;
	ConVar LoadFile;
	ConVar StoreMemory;
	ConVar FilePrefix;
	ConVar LastFile;
	ConVar FilePattern;

	GlobalForward fOnMatchRestored;
}

Global Core;

public Plugin myinfo =
{
	name    = "Match Restore",
	author  = "DRANIX",
	version = "1.0",
	url     = "https://github.com/dran1x"
}

public void OnPluginStart()
{
	CreateConVar("mr_version", PLUGIN_VERSION, PLUGIN_DESCRIPTION, FCVAR_NOTIFY | FCVAR_DONTRECORD | FCVAR_REPLICATED);

	Core.Debug    = CreateConVar("mr_debug", "0", "Enable plugin debugging.");
	Core.Enabled  = CreateConVar("mr_enable", "1", "Enable plugin functionality.");
	Core.AutoLoad = CreateConVar("mr_autoload", "1", "Attempts to auto load backups on game start after crash.");

	Core.RecentFiles   = FindConVar("mp_backup_restore_list_files");
	Core.AutoLoadPause = FindConVar("mp_backup_restore_load_autopause");
	Core.LoadFile      = FindConVar("mp_backup_restore_load_file");
	Core.StoreMemory   = FindConVar("mp_backup_round_auto");
	Core.FilePrefix    = FindConVar("mp_backup_round_file");
	Core.LastFile      = FindConVar("mp_backup_round_file_last");
	Core.FilePattern   = FindConVar("mp_backup_round_file_pattern");
}

public APLRes AskPluginLoad2(Handle hSelf, bool bLate, char[] szError, int iLength)
{
	if (GetEngineVersion() != Engine_CSGO)
	{
		strcopy(szError, iLength, "This plugin works only on CS:GO");

		return APLRes_Failure;
	}

	Core.fOnMatchRestored = CreateGlobalForward("MR_OnMatchRestored", ET_Ignore);

	return APLRes_Success;
}