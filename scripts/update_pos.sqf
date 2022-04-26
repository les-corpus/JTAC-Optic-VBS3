//show players position on the dagr	

#include "\vbs2\customer\weapons\mef_universal_optic\mef_universal_optic_defines.hpp"

_unit = _this select 0;

SCREEN_NUM = 0;

_path = "\vbs2\customer\weapons\mef_universal_optic\data";
_format = "mgrs";	//position format	
_output = ["%1", "%1", "%1 e", "%1 n", "+ %1 m"];	//output text

_display = DEVICE_DAGR_DLG; //global variable assigned in dlg

//hide all the text ctrls
_dagr_ctrl_list = DAGR_SCREEN_CTRLS;

_ctrlArray = [_dagr_ctrl_list, _display] call fn_find_dlg_ctrls;

[[],_ctrlArray] call fn_showHideCtrl;


//show page 1 player position controls
_dagr_ctrl_list = DAGR_CTRLS_PRESENT_POS;

_ctrlArray = [_dagr_ctrl_list, _display] call fn_find_dlg_ctrls;

[_ctrlArray,[]] call fn_showHideCtrl;


//init ctrl buttons, will be used to dynamically change UI eventHandlers
_ctrl_pwrQuit = _display displayCtrl IDC_DAGR_BTN_PWRQUIT;
_ctrl_wpEnter = _display displayCtrl IDC_DAGR_BTN_WPENTER;
_ctrl_posPage = _display displayCtrl IDC_DAGR_BTN_POSPAGE;
_ctrl_up = _display displayCtrl IDC_DAGR_BTN_UP;
_ctrl_dn = _display displayCtrl IDC_DAGR_BTN_DN;

//remove ctrlEventHandlers
{_x ctrlRemoveAllEventHandlers "MouseButtonUp"} forEach [_ctrl_pwrQuit, _ctrl_wpEnter, _ctrl_posPage, _ctrl_up, _ctrl_dn];
		
while {dialog} do
{	
	_objPos = getPosASL _unit;
	
	//change dagr to position screen
	_file = DAGR_SCREEN_NAMES select SCREEN_NUM;	
	ctrlSetText [IDC_DAGR_SCREEN, format ["%1\dagr_%2_ca.paa", _path, _file]];
	
	[_objPos, DAGR_CTRLS_PRESENT_POS, _format, _output] call fn_findObjectPosition;

	sleep .1
};








