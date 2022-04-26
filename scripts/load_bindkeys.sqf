//add bindKeys for addition functions

#include "\vbs2\headers\dikCodes.hpp"

_unit = _this select 0;

//display JTAC tools
KEYID_J = DIK_J bindKey
{
	if (isNil "JTAC_GEAR") then	//global variable assigned in dlg hpp
	{
		//initial key press opens JTAC tools 
		[] call fn_create_JTAC_tools;
	}
	else
	{
		//tools are open, now close them
		closeDialog 0;
	};
};

//save this bindkey in case player is using mef custom JTAC
_unit setVariable ["JTAC_TOOLS_BINDKEY", KEYID_J];

//hack to track key presses
//command setOpticsState and opticsState does not work in a vehicle turret
KEYID_N = DIK_N bindKey {nul = [opticsState select 7] execVM "\vbs2\customer\weapons\mef_universal_optic\data\scripts\CycleOptics.sqf"};

//remove inventory.  causes the config eventhandler to fire when open
KEYID_I = "GEAR" bindKey {hint "Inventory disabled while Universal Optic is in use"; true};

//remove annoying half bino look
KEYID_V = DIK_V bindKey {TRUE};


//temp izlid, 
KEYID_Y = DIK_Y bindKey
{
	if (isNil "SHOW_IZLID") then	//global variable
	{
		SHOW_IZLID = TRUE;
		MEF_IZLID_1 = "#laserpoint" createVehicle getPos player; //nothing
		hint "IZLID On";
	}
	else
	{
		SHOW_IZLID = nil;
		deleteVehicle MEF_IZLID_1;	
		hint "IZLID Off";
	};
};



//save bindKeys for removal later
OPTIC_BINDKEYS = [KEYID_J, KEYID_N, KEYID_I, KEYID_Y, KEYID_V];

//add mouseButton eventhandlers for the vector
MB_dn_idx = addSystemEventHandler ["MouseButtonDown",
"	
	if (_this select 2 == 1) then
	{
		nul = ['RMBdn'] execVM '\vbs2\customer\weapons\mef_universal_optic\data\scripts\vector_RMB_EventHandler.sqf';
	}
	else
	{
		nul = ['LMBdn'] execVM '\vbs2\customer\weapons\mef_universal_optic\data\scripts\vector_LMB_EventHandler.sqf'
	};
"];

MB_up_idx = addSystemEventHandler ["MouseButtonUp",
"
	if (_this select 2 == 1) then
	{
		nul = ['RMBup'] execVM '\vbs2\customer\weapons\mef_universal_optic\data\scripts\vector_RMB_EventHandler.sqf';
	}
	else
	{
		['LMBup'] execVM '\vbs2\customer\weapons\mef_universal_optic\data\scripts\vector_LMB_EventHandler.sqf'
	};
"];
