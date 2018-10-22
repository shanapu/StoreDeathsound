/*
 * Death sound for Zephyrus store
 * by: shanapu
 * https://github.com/shanapu/StoreDeathsound
 * 
 * Copyright (C) 2018 Thomas Schmidt (shanapu)
 * Contributer: good-live, Kxnrl
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
bool g_bBlockOrignal[STORE_MAX_ITEMS];
float g_fVolume[STORE_MAX_ITEMS];

public Plugin myinfo = {
	name = "Death sound for Zephyrus Store",
	author = "shanapu",
	description = "Adds support for death sounds to Zephyrus Store plugin",
	version = "1.3",
	url = "https://github.com/shanapu/StoreDeathsound"
};

public void OnPluginStart()
{
	Store_RegisterHandler("death_sound", "path", DeathSound_OnMapStart, DeathSound_Reset, DeathSound_Config, DeathSound_Equip, DeathSound_Remove, true);
	HookEvent("player_death", Event_PlayerDeath);
	AddNormalSoundHook(Hook_NormalSound);
}

public void DeathSound_OnMapStart()
{
	char sBuffer[256];

	for (int i = 0; i < g_iCount; ++i)
	{
		PrecacheSound(g_sSounds[i]);
		FormatEx(sBuffer, sizeof(sBuffer), "sound/%s", g_sSounds[i]);
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
	g_bBlockOrignal[g_iCount] = view_as<bool>(KvGetNum(kv, "block", 1));

	char sBuffer[256];
	FormatEx(sBuffer, sizeof(sBuffer), "sound/%s", g_sSounds[g_iCount]);
	if (!FileExists(sBuffer, true))
		return false;

	g_iCount++;

	return true;
}

public int DeathSound_Equip(int client, int id)
{
	g_iSound[client] = Store_GetDataIndex(id);
	g_bItem[client] = true;

	return -1;
}

public int DeathSound_Remove(int client)
{
	g_bItem[client] = false;

	return 0;
}

public void OnClientDisconnect(int client)
{
	g_iSound[client] = -1;
	g_bItem[client] = false;
}

public void Event_PlayerDeath(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));

	if (!g_bItem[client])
		return;

	if (client == attacker)
		return;

	switch (g_iOrigin[g_iSound[client]])
	{
		// Sound From global world
		case 1:
		{
			EmitSoundToAll(g_sSounds[g_iSound[client]], SOUND_FROM_WORLD, _, SNDLEVEL_RAIDSIREN, _, g_fVolume[g_iSound[client]]);
		}
		// Sound From local player
		case 2:
		{
			float fVec[3];
			GetClientAbsOrigin(client, fVec);
			EmitAmbientSound(g_sSounds[g_iSound[client]], fVec, SOUND_FROM_PLAYER, SNDLEVEL_RAIDSIREN, _, g_fVolume[g_iSound[client]]);
		}
		// Sound From player voice
		case 3:
		{
			float fPos[3], fAgl[3];
			GetClientEyePosition(client, fPos);
			GetClientEyeAngles(client, fAgl);

			// player`s mouth
			fPos[2] -= 3.0;

			EmitSoundToAll(g_sSounds[g_iSound[client]], client, SNDCHAN_VOICE, SNDLEVEL_NORMAL, SND_NOFLAGS, g_fVolume[g_iSound[client]], SNDPITCH_NORMAL, client, fPos, fAgl, true);
		}
	}
}

public Action Hook_NormalSound(int clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &client, int &channel, float &volume, int &level, int &pitch, int &flags)
{
	if (channel != SNDCHAN_VOICE || client > MaxClients || client < 1 || !IsClientInGame(client) || sample[0] != '~' || !g_bItem[client])
		return Plugin_Continue;

	if (g_bBlockOrignal[g_iSound[client]] && StrContains(sample, "~player/death", false) == 0)
		return Plugin_Handled;

	return Plugin_Continue;
}

