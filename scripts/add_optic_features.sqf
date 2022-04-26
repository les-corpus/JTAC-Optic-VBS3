//executes when player uses the item, stows, or open inventory window

sleep .1;

#include "\vbs2\headers\dikCodes.hpp"

_unit = _this select 0;		//unit using optic
_optic = _this select 1;		//optic passed
_inUse = _this select 4;		//true when player is using optic

_path = "\vbs2\customer\weapons\mef_universal_optic\data\scripts";

//just in case, remove any systemEventHandlers
removeAllSystemEventHandlers "MouseButtonDown";
removeAllSystemEventHandlers "MouseButtonUp";

hint "";


//[-1, 5000] diagMessage format ["inUSe: %1", _inUse];

if (_inUse) then
{
	titleText ["Loading Optic", "BLACK FADED"];

	sleep 3;

	titleText ["Loading Optic", "BLACK IN"];

	//make sure optic is displayed
	//sleep .1;
	waitUntil {opticsState select 0};
	
	//load function library
	if (isNil "OPTIC_FUNCTIONS_LOADED") then
	{
		_load_fn_library = [_unit, _optic] execVM format["%1\fn_library_universalOptic.sqf", _path];
	};
	
	//initialize the script
	_init_optic = [_unit] execVM format["%1\init_optic.sqf", _path];

	//load bindkeys
	_load_bindKeys = [_unit] execVM format["%1\load_bindKeys.sqf", _path];

	//start loop to update marker on 2D map
	_create_starePoint = [_unit, _optic] execVM format["%1\create_starePoint.sqf", _path];
	

	
}
else
{
	//end script
	[] call fn_removeBindKeys;
};







