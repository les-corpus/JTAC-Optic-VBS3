//controls button actions and basic dagr functions

#include "\vbs2\customer\weapons\mef_universal_optic\mef_universal_optic_defines.hpp"

_event = _this select 0;
_unit = player;

//init ctrl buttons, will be used to dynamically change UI eventHandlers
_display = DEVICE_DAGR_DLG;
_ctrl_pwrQuit = _display displayCtrl IDC_DAGR_BTN_PWRQUIT;
_ctrl_wpEnter = _display displayCtrl IDC_DAGR_BTN_WPENTER;
_ctrl_posPage = _display displayCtrl IDC_DAGR_BTN_POSPAGE;
_ctrl_up = _display displayCtrl IDC_DAGR_BTN_UP;
_ctrl_dn = _display displayCtrl IDC_DAGR_BTN_DN;

_path = "\vbs2\customer\weapons\mef_universal_optic\data";

switch (_event) do
{
	case "init_dagr":
	{
		//initialize dagr for use
		private ["_display","_dagr_ctrl_list","_ctrlArray","_file","_endPt"];
		
		//find all dagr ctrls
		_display = DEVICE_DAGR_DLG;
		_dagr_ctrl_list = DAGR_CTRLS_ALL;
		_ctrlArray = [_dagr_ctrl_list, _display] call fn_find_dlg_ctrls;
		  
		//save list of controls to a global variable for use later
		DAGR_CTRL_LIST = _ctrlArray;
		
		//see if positions were saved
		[_ctrlArray, _display] call fn_load_dagr_pos;
	
		//hide all the text ctrls
		_dagr_ctrl_list = DAGR_SCREEN_CTRLS;
		_ctrlArray = [_dagr_ctrl_list, _display] call fn_find_dlg_ctrls;
		[[],_ctrlArray] call fn_showHideCtrl;
	
		//init some variables
		SCREEN_NUM = 0;  //player's position
		_file = "";
	
		//check if LRF shot was sent
		_endPt = _unit getVariable "VECTOR_LRF_SHOT";
		if (isNil "_endPt" || isNull _endPt) then
		{
			//no LRF, show current position
			nul = [_unit] execVM format["%1\scripts\update_pos.sqf", _path];
		}
		else
		{
			//lrf shot received
			nul = ["lrf_shot", _unit, "mef_universal_optic", _endPt] execVM format["%1\scripts\dagrActions.sqf", _path];
		};
	};
	
	
	case "lrf_shot":
	{
		//lrf shot sent to dagr
		private ["_unit","_optic","_endPt","_path","_file","_slantRng","_slantRng_format","_tgtElevMSL", "_tgtElevMSL_format", "_gridAz","_vector3D","_elevAngle","_elevAngle_format","_magAz","_magAz_format","_ctrlArray","_outPut","_results"];

		_unit = _this select 1;
		_optic = _this select 2;
		_endPt = _this select 3;
		//get the saved optic endpoint
		//_endPt = _unit getVariable "VECTOR_LRF_SHOT";
		_path = "\vbs2\customer\weapons\mef_universal_optic\data";
		
		//change screen
		SCREEN_NUM = 1;	//lrf shot received
		_file = DAGR_SCREEN_NAMES select SCREEN_NUM;
		ctrlSetText [IDC_DAGR_SCREEN, format ["%1\dagr_%2_ca.paa", _path, _file]];

		//hide all the text ctrls
		_dagr_ctrl_list = DAGR_SCREEN_CTRLS;
		_ctrlArray = [_dagr_ctrl_list, _display] call fn_find_dlg_ctrls;
		[[],_ctrlArray] call fn_showHideCtrl;

		//show page 2 lrf shot controls 
		_dagr_ctrl_list = DAGR_CTRLS_LRF;
		_ctrlArray = [_dagr_ctrl_list, _display] call fn_find_dlg_ctrls;
		[_ctrlArray,[]] call fn_showHideCtrl;
		
		//find slant range and elevation MSL
		_slantRng = _unit distance _endPt;
		_slantRng_format = [_slantRng, 2, FALSE] call fn_vbs_cutDecimals; //returns a number	
		
		//if distance > 12000m show 99999
		if (_slantRng_format > 12000) then
		{
			_slantRng_format = 99999;
		};
		
		_tgtElevMSL = (getPosASL _endPt) select 2;
		_tgtElevMSL_format = [_tgtElevMSL, 0, FALSE] call fn_vbs_cutDecimals; //returns a number	
		
		//find weapon direction and elevation angle
		_vector3D = (_unit weaponDirection _optic);
		
		_elevAngle = asin (_vector3D select 2);
		_elevAngle_format = [_elevAngle, 2, FALSE] call fn_vbs_cutDecimals; //returns a number
		
		_gridAz = (_vector3D select 0) atan2 (_vector3D select 1);
		_magAz = _gridAz + getdeclination;
		
		//check wrap around
		if (_magAz > 360) then
		{
			_magAz = _magAz - 360;
		}
		else
		{
			if (_magAz < 0) then
			{
				_magAz = _magAz + 360;
			};
		};
		
		_magAz_format = [_magAz, 2, FALSE] call fn_vbs_cutDecimals; //returns a number		
		
		//create global variable to save lrf data
		DAGR_LRF_SHOT_DATA = [_unit, _magAz_format, _elevAngle_format, _slantRng_format, _tgtElevMSL_format];
		
		//output values
		_ctrlArray = [IDC_DAGR_PG2_SLANT_RNG];
		_outPut = ["%1 m"];
		_results = [_slantRng_format];
		
		[_ctrlArray, _output, _results] call fn_output_results;
		
		//output text with special characters
		ctrlSetText [IDC_DAGR_PG2_AZ, format ["%1%2M", _magAz_format, toString [176]]];
		ctrlSetText [IDC_DAGR_PG2_ELEV_ANG, format ["%1%2", _elevAngle_format, toString [176]]];	
		
		//remove ctrlEventHandlers
		{_x ctrlRemoveAllEventHandlers "MouseButtonUp"} forEach [_ctrl_pwrQuit, _ctrl_wpEnter, _ctrl_posPage, _ctrl_up, _ctrl_dn];
		
		//update ctrlEventHandlers
		//player setVariable ['VECTOR_LRF_SHOT', nil];
		_ctrl_pwrQuit ctrlAddEventHandler
		[
			"MouseButtonUp",
			"
				MEF_CAM_STARE_POINT = objNull;
				player setVariable ['VECTOR_LRF_SHOT', MEF_CAM_STARE_POINT];	
				[player] execVM '\vbs2\customer\weapons\mef_universal_optic\data\scripts\update_pos.sqf'
			"
		];
		
		_ctrl_wpEnter ctrlAddEventHandler
		[
			"MouseButtonUp",
			"
				['check_range', (DAGR_LRF_SHOT_DATA select 3)] execVM '\vbs2\customer\weapons\mef_universal_optic\data\scripts\dagrActions.sqf' 		
			"		
		];
		
		_ctrl_posPage ctrlAddEventHandler 
		[
			"MouseButtonUp",
			"
				[player] execVM '\vbs2\customer\weapons\mef_universal_optic\data\scripts\update_pos.sqf'
			"
		];
		
		{_x ctrlAddEventHandler ["MouseButtonUp",""]} forEach [_ctrl_up, _ctrl_dn];
	};
	
	case "check_range":
	{
		//check distance from lrf shot to the player
		private ["_slantRng","_tgtElevMSL","_file","_ctrlArray","_outPut","_results"];

		_slantRng = _this select 1;
		
		//hide all the text ctrls
		_dagr_ctrl_list = DAGR_SCREEN_CTRLS;
		
		_ctrlArray = [_dagr_ctrl_list, _display] call fn_find_dlg_ctrls;
		
		[[],_ctrlArray] call fn_showHideCtrl;
		
		//check distance
		if (_slantRng < DAGR_WARNING_DIS) then
		{
			if (_slantRng < DAGR_DANGER_DIS) then
			{
				//lrf shot > 100 m, show danger screen
				SCREEN_NUM = 2;		//danger screen
				_file = DAGR_SCREEN_NAMES select SCREEN_NUM;
				ctrlSetText [IDC_DAGR_SCREEN, format ["%1\dagr_%2_ca.paa", _path, _file]];	
			}
			else
			{
				//lrf shot < 1000 m, show warning screen
				SCREEN_NUM = 3;		//warning screen
				_file = DAGR_SCREEN_NAMES select SCREEN_NUM;
				ctrlSetText [IDC_DAGR_SCREEN, format ["%1\dagr_%2_ca.paa", _path, _file]];
				
				//show page 4 warning message 
				_dagr_ctrl_list = DAGR_CTRLS_WARNING;
				_ctrlArray = [_dagr_ctrl_list, _display] call fn_find_dlg_ctrls;
				[_ctrlArray,[]] call fn_showHideCtrl;
				
				//output values
				_ctrlArray = DAGR_CTRLS_WARNING;
				_outPut = ["%1 m"];
				_results = [_slantRng];
				
				[_ctrlArray, _output, _results] call fn_output_results;
			};	
		}
		else
		{
			//lrf shot > 1000m continue to fire support screens
			nul = ["fire_support_screens", DAGR_LRF_SHOT_DATA] execVM "\vbs2\customer\weapons\mef_universal_optic\data\scripts\dagrActions.sqf";	
		};
		
		//remove ctrlEventHandlers
		{_x ctrlRemoveAllEventHandlers "MouseButtonUp"} forEach [_ctrl_pwrQuit, _ctrl_wpEnter, _ctrl_posPage, _ctrl_up, _ctrl_dn];
		
		//update button eventHandlers
		_ctrl_wpEnter ctrlAddEventHandler
		[
			"MouseButtonUp",
			"
				['fire_support_screens', DAGR_LRF_SHOT_DATA] execVM '\vbs2\customer\weapons\mef_universal_optic\data\scripts\dagrActions.sqf'		
			"		
		];
		
		_ctrl_posPage ctrlAddEventHandler 
		[
			"MouseButtonUp",
			"
				[player] execVM '\vbs2\customer\weapons\mef_universal_optic\data\scripts\update_pos.sqf'
			"
		];
	};
	
	case "fire_support_screens":
	{
		//show lrf shot data (fire support screens)
		private ["_unit","_magAz","_elevAngle","_slantRng","_tgtElevMSL","_file","_ctrlArray","_outPut","_results"];
		
		_lrf_data = _this select 1;
		
		_unit = _lrf_data select 0;
		_magAz = _lrf_data select 1;
		_elevAngle = _lrf_data select 2;
		_slantRng = _lrf_data select 3;
		_tgtElevMSL = _lrf_data select 4;
		
		//initialize pages
		DAGR_UP_BTN = 0;
		DAGR_DN_BTN = 0;
		
		//show fire support screens
		SCREEN_NUM = 4;		//lrf data screen
		_file = DAGR_SCREEN_NAMES select SCREEN_NUM;
		ctrlSetText [IDC_DAGR_SCREEN, format ["%1\dagr_%2_ca.paa", _path, _file]];		

		//hide all the text ctrls
		_dagr_ctrl_list = DAGR_SCREEN_CTRLS;
		_ctrlArray = [_dagr_ctrl_list, _display] call fn_find_dlg_ctrls;
		[[],_ctrlArray] call fn_showHideCtrl;

		//show page 5 lrf data 
		_dagr_ctrl_list = DAGR_CTRLS_LRF_DATA;
		_ctrlArray = [_dagr_ctrl_list, _display] call fn_find_dlg_ctrls;
		[_ctrlArray,[]] call fn_showHideCtrl;
		
		//output values
		_ctrlArray = [IDC_DAGR_PG5_SLANT_RNG, IDC_DAGR_PG5_ELEV];
		_outPut = ["%1 m", "%1 m MSL"];
		_results = [_slantRng, _tgtElevMSL];
		
		[_ctrlArray, _output, _results] call fn_output_results;
		
		//output text with special characters
		ctrlSetText [IDC_DAGR_PG5_AZ, format ["%1%2 M", _magAz, toString [176]]];
		
		//remove ctrlEventHandlers
		{_x ctrlRemoveAllEventHandlers "MouseButtonUp"} forEach [_ctrl_pwrQuit, _ctrl_wpEnter, _ctrl_posPage, _ctrl_up, _ctrl_dn];
		
		//add button actions
		_ctrl_posPage ctrlAddEventHandler 
		[
			"MouseButtonUp",
			"
				[player] execVM '\vbs2\customer\weapons\mef_universal_optic\data\scripts\update_pos.sqf'
			"
		];
		
		_ctrl_up ctrlAddEventHandler 
		[
			"MouseButtonUp",
			"
				[SCREEN_NUM] call fn_dagr_up_arrow;
			"
		];
		
		_ctrl_dn ctrlAddEventHandler 
		[
			"MouseButtonUp",
			"
				[SCREEN_NUM] call fn_dagr_dn_arrow;
			"
		];
	};
	
	case "update_dagr":
	{
		private ["_screen_num", "_unit", "_slantRng", "_tgtElevMSL", "_ctrlArray","_outPut","_results", "_endPt", "_format"];
		
		_screen_num = _this select 1;
		//get data from global variable
		
		_unit = DAGR_LRF_SHOT_DATA select 0;
		_magAz = DAGR_LRF_SHOT_DATA select 1;

		_slantRng = DAGR_LRF_SHOT_DATA select 3;
		_tgtElevMSL = DAGR_LRF_SHOT_DATA select 4;
		
		//hide all the text ctrls
		_dagr_ctrl_list = DAGR_SCREEN_CTRLS;
		_ctrlArray = [_dagr_ctrl_list, _display] call fn_find_dlg_ctrls;
		[[],_ctrlArray] call fn_showHideCtrl;
		
		switch (_screen_num) do
		{
			case 4:	//lrf data
			{
				//show lrf data 
				_dagr_ctrl_list = DAGR_CTRLS_LRF_DATA;
				_ctrlArray = [_dagr_ctrl_list, _display] call fn_find_dlg_ctrls;
				[_ctrlArray,[]] call fn_showHideCtrl;
			
				_ctrlArray = [IDC_DAGR_PG5_SLANT_RNG, IDC_DAGR_PG5_ELEV];
				_output = ["%1 m", "%1 m MSL"];
				_results = [_slantRng, _tgtElevMSL];
				
				[_ctrlArray, _output, _results] call fn_output_results;
				
				//output text with special characters
				ctrlSetText [IDC_DAGR_PG5_AZ, format ["%1%2 M", _magAz, toString [176]]];
			};

			case 5:	//safety check
			{
				//show safety check
				_dagr_ctrl_list = DAGR_CTRLS_SAFETY_CHK;
				_ctrlArray = [_dagr_ctrl_list, _display] call fn_find_dlg_ctrls;
				[_ctrlArray,[]] call fn_showHideCtrl;
				
				_ctrlArray = [IDC_DAGR_PG6_SLANT_RNG];
				_output = ["%1 m"];
				_results = [_slantRng];
				
				[_ctrlArray, _output, _results] call fn_output_results;		
			};
			
			case 6:	//tgt loc
			{
				//show target location
				_dagr_ctrl_list = DAGR_CTRLS_TARGET_POS;
				_ctrlArray = [_dagr_ctrl_list, _display] call fn_find_dlg_ctrls;
				[_ctrlArray,[]] call fn_showHideCtrl;
				
				_endPt = _unit getVariable "VECTOR_LRF_SHOT"; //end point
				
				_endPtPos = getPosASL _endPt;
				_ctrlArray = DAGR_CTRLS_TARGET_POS;
				_format = "mgrs";	//position format	
				_output = ["%1", "%1", "%1 e", "%1 n", "+ %1 m"];	//output text
				
				//[_endPt, _ctrlArray, _format, _output] call fn_findObjectPosition;
				[_endPtPos, _ctrlArray, _format, _output] call fn_findObjectPosition;
			};
		};
	};
};






