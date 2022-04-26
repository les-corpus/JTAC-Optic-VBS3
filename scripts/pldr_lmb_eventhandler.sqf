//mouse button handler for pldr day range finder

#include "\vbs2\customer\weapons\mef_universal_optic\mef_universal_optic_defines.hpp"

//exception handling
//application is not running, remove eventHandlers
if
(
	!(applicationState select 0) && 
	!isSimulationEnabled && 
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

_mode = _this select 0;			//"pldr_day" or "pldr_ir"
_mouseButton = _this select 1;		//"LMBup" or "LMBdn"

_unit = player;
PLDR_STOP_RANGE = FALSE;

//initialize controls
_display = MEF_UNIV_OPTIC;
_greenDot_R = _display displayCtrl IDC_PLDR_DOT_GREEN_R;
_pldr_day_range = _display displayCtrl IDC_PLDR_RANGE_RED;
_pldr_ir_range = _display displayCtrl IDC_PLDR_IR_RANGE;
_pldr_ir_firing = _display displayCtrl IDC_PLDR_IR_FIRING;

//daytime mode
if ("day" in _mode)then
{
	switch (_mouseButton) do
	{
		case "LMBup":
		{
			[[_pldr_day_range],[_greenDot_R]] call fn_showHideCtrl;
			PLDR_STOP_RANGE = TRUE;
		};
		
		case "LMBdn":
		{
			[[_greenDot_R, _pldr_day_range],[]] call fn_showHideCtrl;
			
			//show range
			waitUntil 
			{
				[_unit, MEF_CAM_STARE_POINT, "slant", "meter", 0, _pldr_day_range, "%1"] call fn_showDistance;
				PLDR_STOP_RANGE
			};
		};
	};
}
else	//ir mode
{
	switch (_mouseButton) do
	{
		case "LMBup":
		{
			[[_pldr_ir_range],[_pldr_ir_firing]] call fn_showHideCtrl;
			PLDR_STOP_RANGE = TRUE;
		};
		
		case "LMBdn":
		{
			[[_pldr_ir_range, _pldr_ir_firing],[]] call fn_showHideCtrl;
			
			//show range
			waitUntil 
			{
				[_unit, MEF_CAM_STARE_POINT, "slant", "meters", 0, _pldr_ir_range, "%1  m"] call fn_showDistance;
				PLDR_STOP_RANGE
			};
		};
	};
};


