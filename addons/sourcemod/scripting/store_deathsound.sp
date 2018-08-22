/*
 * Death sound for Zephyrus store
 * by: shanapu
 * https://github.com/shanapu/StoreDeathsound
 * 
 * Copyright (C) 2018 Thomas Schmidt (shanapu)
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 */

#include <sourcemod>
#include <sdktools>
#include <store>

#pragma semicolon 1
#pragma newdecls required

bool g_bItem[MAXPLAYERS+1] = false;

char g_sSounds[STORE_MAX_ITEMS][PLATFORM_MAX_PATH];

int g_iCount = 0;
int g_iSound[MAXPLAYERS+1];
int g_iOrigin[STORE_MAX_ITEMS];
float g_fVolume[STORE_MAX_ITEMS];

public Plugin myinfo = {
	name = "Death sound for Zephyrus Store",
	author = "shanapu",
	description = "Adds support for death sounds to Zephyrus Store plugin",
	version = "1.0",
	url = "https://github.com/shanapu/StoreDeathsound"
};

public void OnPluginStart()
{
	Store_RegisterHandler("death_sound", "", DeathSound_OnMapStart, DeathSound_Reset, DeathSound_Config, DeathSound_Equip, DeathSound_Remove, true);
	HookEvent("player_death", Event_PlayerDeath);
}

public void DeathSound_OnMapStart()
{
	char sBuffer[256];

	for (int i = 0; i < g_iCount; ++i)
	{
		PrecacheSound(g_sSounds[i]);
		Format(sBuffer, sizeof(sBuffer), "sound/%s", g_sSounds[i]);
		AddFileToDownloadsTable(sBuffer);
	}
}

public void DeathSound_Reset()
{
	g_iCount = 0;
}

public bool DeathSound_Config(Handle &kv, int itemid)
{
	Store_SetDataIndex(itemid, g_iCount);

	KvGetString(kv, "path", g_sSounds[g_iCount], PLATFORM_MAX_PATH);
	g_iOrigin[g_iCount] = KvGetNum(kv, "origin", 1);
	g_fVolume[g_iCount] = KvGetFloat(kv, "volume", 1.0);

	if (!FileExists(g_sSounds[g_iCount], true))
		return false;

	g_iCount++;

	return true;
}

public int DeathSound_Equip(int client, int id)
{
	g_iSound[client] = Store_GetDataIndex(id);
	g_bItem[client] = true;

	return 0;
}

public int DeathSound_Remove(int client)
{
	g_bItem[client] = false;

	return 0;
}

public void Event_PlayerDeath(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));

	if (!g_bItem[client])
		return;

	if (client == attacker)
		return;

	if (g_iOrigin[g_iSound[client]] == 1)
	{
		EmitSoundToAll(g_sSounds[g_iSound[client]], SOUND_FROM_WORLD, _, SNDLEVEL_RAIDSIREN, _, g_fVolume[g_iSound[client]]);
	}
	else
	{
		float fVec[3];
		GetClientAbsOrigin(client, fVec);
		EmitAmbientSound(g_sSounds[g_iSound[client]], fVec, SOUND_FROM_PLAYER, SNDLEVEL_RAIDSIREN, _, g_fVolume[g_iSound[client]]);
	}
}