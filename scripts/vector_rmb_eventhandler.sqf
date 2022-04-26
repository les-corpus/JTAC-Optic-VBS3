//right mouse button eventHandler

#include "\vbs2\customer\weapons\mef_universal_optic\mef_universal_optic_defines.hpp"

//exception handling
//application is not running, remove eventHandlers
if
(
	!(applicationState select 0) && 		//returns true if vbs menu is open in network and singlePlayer
	!isSimulationEnabled && 				//returns true if vbs menu is open in network mode
	!(opticsState select 0)				//returns true if optic not in use
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
_mouseButton = _this select 0;	//"RMBdn" or "RMBup"

//on mouse button down add 1
if (_mouseButton == "RMBdn") then
{
	RMB_STATE = 1;
	
	NUM_RMB_DN = NUM_RMB_DN + 1;  //add 1 to number of clicks

	if (NUM_RMB_DN > 5) then	//too many clicks, reset to 0
	{
		NUM_RMB_DN = 1;
	};
	
	_event = [NUM_LMB_DN, NUM_LMB_UP, LMB_STATE, NUM_RMB_DN, NUM_RMB_UP, RMB_STATE];
	[_mouseButton, _event] execVM "\vbs2\customer\weapons\mef_universal_optic\data\scripts\vectorActions.sqf";
};

//on mouse button up
if (_mouseButton == "RMBup") then
{
	RMB_STATE = 0;	//button off
	
	NUM_RMB_UP = NUM_RMB_UP + 1;  //add 1 to number of clicks

	if (NUM_RMB_UP > 5) then	//too many clicks, reset to 1
	{
		NUM_RMB_UP = 1;
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
			NUM_RMB_UP = 0;
			NUM_RMB_DN = 0;
		};
		
		if (RMB_STATE == 1) exitWith  {};  //key pressed within time, exit loop
		sleep .01;
	};
};

