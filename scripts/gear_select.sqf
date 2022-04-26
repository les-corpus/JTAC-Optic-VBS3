//opens dialog to select a specific optic

#include "\vbs2\headers\dikCodes.hpp"
#include "\vbs2\customer\weapons\mef_universal_optic\mef_universal_optic_defines.hpp"

_device = _this select 0;

//close any dialogs
closeDialog 0;

//init variables
_unit = player;
_newOpticMode = -1;
_nCycle = -1;

_path = "\vbs2\customer\weapons\mef_universal_optic\data\scripts";

//get current optic mode
_oldOpticMode = OPTIC_MODE;

//what did the player select?
switch(_device) do
{
	case "VECTOR":  
	{
		_newOpticMode = 0;
	};
	case "DEFAULT_DAY":  
	{
		_newOpticMode = 1;
	};
	case "DEFAULT_NV":  
	{
		//player must have NVG in inventory for this mode to work.
		_newOpticMode = 2;
	};	
	case "PLDR_DAY":  
	{
		_newOpticMode = 3;
	};
};

//if dismounted, switch to selectd optic
_vehicle = vehicle player;			
if (player == _vehicle) then
{
	//player is dismounted
	setOpticsState (OPTICS_MODE_ARRAY select _newOpticMode);
	
	//execute cycle optics script to handle batteries and LMB/RMB eventHandlers
	OPTIC_MODE = _newOpticMode -1;
	nul = [(_newOpticMode-1)] execVM format["%1\CycleOptics.sqf", _path];
}
else
{
	//player is in a vehicle.  hack to handle selected optic. cmd setOpticsState does not work in a turret
	_nCycle = _newOpticMode - _oldOpticMode;
	if (_nCycle < 0) then
	{
		_nCycle = 6 + _nCycle;
	};

	//execute crazy loop to select correct optic
	for "_i" from 1 to _nCycle do
	{
		DIK_N setAction 1;
		nul = [_i] execVM format["%1\CycleOptics.sqf", _path];
		sleep .1;
	};
};












