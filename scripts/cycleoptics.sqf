//Controls when to add batteries to the optic and when to add the mouse button eventhanlders

// exception handling
_exception = [] call fn_exception_handling;
if (_exception) exitWith {};

#include "\vbs2\headers\dikCodes.hpp"
#include "\vbs2\customer\weapons\mef_universal_optic\mef_universal_optic_defines.hpp"

_opticMode = _this select 0;

//wait before removing eventHandlers
sleep .02;

//just in case, remove eventHandlers and batteries
removeAllSystemEventHandlers "MouseButtonDown";
removeAllSystemEventHandlers "MouseButtonUp";
player removeMagazine "vbs2_Batteries";

_vehicle = vehicle player;

//cycle optic counter between 0 and 5
OPTIC_MODE = OPTIC_MODE + 1;		
if (OPTIC_MODE > 5) then
{
	OPTIC_MODE = 0;
};

_opticMode = OPTIC_MODE;

//if Vector is selected add the mouse button eventHandlers
if (_opticMode == 0) then
{	
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
			nul = ['LMBup'] execVM '\vbs2\customer\weapons\mef_universal_optic\data\scripts\vector_LMB_EventHandler.sqf'
		};
	"];
};

//any PLDR mode, add battery
if (_opticMode > 2)then
{
	player addmagazine "vbs2_Batteries";
};

//pldr range finder (red range text)
if (_opticMode == 3) then
{
	MB_dn_idx = addSystemEventHandler ["MouseButtonDown",
	"
		if (_this select 2 == 0) then
		{
			nul = ['pldr_day','LMBdn'] execVM '\vbs2\customer\weapons\mef_universal_optic\data\scripts\pldr_LMB_EventHandler.sqf'
		};
	"];
	
	MB_dn_idx = addSystemEventHandler ["MouseButtonUp",
	"
		if (_this select 2 == 0) then
		{
			nul = ['pldr_day','LMBup'] execVM '\vbs2\customer\weapons\mef_universal_optic\data\scripts\pldr_LMB_EventHandler.sqf'
		};
	"];
};

if (_opticMode > 3) then //(firing and range text)
{
	MB_dn_idx = addSystemEventHandler ["MouseButtonDown",
	"
		if (_this select 2 == 0) then
		{
			nul = ['pldr_ir','LMBdn'] execVM '\vbs2\customer\weapons\mef_universal_optic\data\scripts\pldr_LMB_EventHandler.sqf'
		};
	"];
	
	MB_dn_idx = addSystemEventHandler ["MouseButtonUp",
	"
		if (_this select 2 == 0) then
		{
			nul = ['pldr_ir','LMBup'] execVM '\vbs2\customer\weapons\mef_universal_optic\data\scripts\pldr_LMB_EventHandler.sqf'
		};
	"];
};

//reset optic
[] call fn_create_Optic_HUD;




