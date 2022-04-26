//left mouse button eventHandler

#include "\vbs2\customer\weapons\mef_universal_optic\mef_universal_optic_defines.hpp"

//exception handling
//application is not running, remove eventHandlers

if
(
	!(applicationState select 0) && 
	!isSimulationEnabled  &&
	!(opticsState select 0)
)
exitWith
{
	removeAllSystemEventHandlers "MouseButtonDown";
	removeAllSystemEventHandlers "MouseButtonUp";
}; 

//any dialog is open
_exception = [] call fn_exception_handling;
if (_exception) exitWith {};

//define some variables
_mouseButton = _this select 0;	//"LMBdn" or "LMBup"

//on mouse button down add 1
if (_mouseButton == "LMBdn") then
{
	LMB_STATE = 1;	//button on
	
	NUM_LMB_DN = NUM_LMB_DN + 1;  //add 1 to number of clicks

	if (NUM_LMB_DN > 5) then	//too many clicks, reset to 1
	{
		NUM_LMB_DN = 1;
	};

	_event = [NUM_LMB_DN, NUM_LMB_UP, LMB_STATE, NUM_RMB_DN, NUM_RMB_UP, RMB_STATE];
	[_mouseButton, _event] execVM "\vbs2\customer\weapons\mef_universal_optic\data\scripts\vectorActions.sqf";
};

//on mouse button up
if (_mouseButton == "LMBup") then
{
	LMB_STATE = 0;	//button off
	
	NUM_LMB_UP = NUM_LMB_UP + 1;  //add 1 to number of clicks

	if (NUM_LMB_UP > 5) then	//too many clicks, reset to 1
	{
		NUM_LMB_UP = 1;
	};
	
	_event = [NUM_LMB_DN, NUM_LMB_UP, LMB_STATE, NUM_RMB_DN, NUM_RMB_UP, RMB_STATE];
	[_mouseButton, _event] execVM "\vbs2\customer\weapons\mef_universal_optic\data\scripts\vectorActions.sqf";
	
	_stTime = time;
	while {true} do	//timeout script
	{	
		if (time > (_stTime + KEY_PRESS_TIMER)) exitWith
		{
			_event = [NUM_LMB_DN, NUM_LMB_UP, LMB_STATE, NUM_RMB_DN, NUM_RMB_UP, RMB_STATE];
			["timeOut", _event] execVM "\vbs2\customer\weapons\mef_universal_optic\data\scripts\vectorActions.sqf";
			NUM_LMB_UP = 0;
			NUM_LMB_DN = 0;
		};
		
		if (LMB_STATE == 1) exitWith  {};  //key pressed within time, exit loop
		sleep .01;
	};
};

