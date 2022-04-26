//functions and global variables for universal optic
//this file is loaded one time for each player using the device.

#include "\vbs2\headers\dikCodes.hpp"
#include "\vbs2\customer\weapons\mef_universal_optic\mef_universal_optic_defines.hpp"

//initialize variables for the script
_unit = _this select 0;
_optic = _this select 1;

//these global variables are loaded one time only
OPTIC_FUNCTIONS_LOADED = TRUE;	//flag to execute this file only once	
NUM_LMB_DN = 0;						//vector21 mouse handlers
NUM_LMB_UP = 0;						
NUM_RMB_DN = 0;
NUM_RMB_UP = 0;
LMB_STATE = 0;
RMB_STATE = 0;
DAGR_CTRL_LIST = [];
DAGR_CTRL_POS = [];
MEF_CAM_STARE_POINT = objNull;
_unit setVariable ["VECTOR_LRF_SHOT", MEF_CAM_STARE_POINT];		

//functions
fn_removeBindKeys = 
{	
	//delete stare point, reset global variables, stop loops
	deleteVehicle MEF_CAM_STARE_POINT;
	deleteVehicle MEF_IZLID_1;
	//MEF_CAM_STARE_POINT = nil;
	MEF_CAM_STARE_POINT = objNull;
	RUN_OPTIC_SCRIPTS = FALSE;
	JTAC_GEAR = nil;
	
	//clear hints and rscTitles
	hint "";
	titleRsc ["default", "plain"];	
	
	//remove bindKeys and eventHandlers
	{unbindKey _x} forEach OPTIC_BINDKEYS;
	removeAllSystemEventHandlers "MouseButtonDown";
	removeAllSystemEventHandlers "MouseButtonUp";
	
	//re-add batteries
	if (ADD_BATTERY) then
	{
		player addmagazine "vbs2_Batteries";
	};
	
	hint "Optic Stowed";
};

fn_exception_handling =
{
	//check if the following are open
	private ["_exception"];
	
	_exception = FALSE;
	
	if 
	(
		!(applicationState select 0) ||	//option menu open
		!isNil "map" ||						//map open
		dialog ||								//dialog open
		!(opticsstate select 0)			//optic not in use
	)
	then
	{
		_exception = TRUE;
	};
	
	_exception
};


fn_create_JTAC_tools = 
{
	//creates the JTAC tools from a bindKey
	private ["_exception"];
	
	_exception = [] call fn_exception_handling;
	if (_exception) exitWith {};
	
	createDialog "JTAC_Gear_DLG";
};

fn_create_DAGR = 
{	
	//no exception handling, this is created from JTAC gui
	
	//close any dialogs
	closeDialog 0;
	
	//display the dagr dialog
	createDialog "device_DAGR_dlg";
};

fn_create_Optic_HUD = 
{
	//creates the text for vector and pldr optic
	//executes each time the optic is changed or unloaded when a dlg or menu is opened
	private ["_display", "_ctrl_left", "_ctrl_right", "_aiming_circle"];
	
	TitleRsc ["Optics_HUD", "PLAIN"];
	_display = MEF_UNIV_OPTIC;
	
	//hide all the ctrls
	_optic_ctrls_list = OPTIC_CTRLS_ALL;
	_ctrlArray = [_optic_ctrls_list, _display] call fn_find_dlg_ctrls;
	[[],_ctrlArray] call fn_showHideCtrl;
	
	//show ctrls for pldr in ir mode
	_ctrl_pldr_ir_range = _display displayCtrl IDC_PLDR_IR_RANGE;
	_ctrl_pldr_ir_R = _display displayCtrl IDC_PLDR_IR_TX_R;
		
	if (OPTIC_MODE > 3) then
	{
		{_x ctrlShow TRUE} forEach [_ctrl_pldr_ir_range, _ctrl_pldr_ir_R];
	}
	else
	{
		{_x ctrlShow FALSE} forEach [_ctrl_pldr_ir_range, _ctrl_pldr_ir_R];
	};
	
	//[-1,5000] diagMessage format ["%1 || %2 || %3", OPTIC_MODE, JTAC_GEAR, SHOW_IZLID];
	
	
};

fn_showHideCtrl = 
{
	//show or hide an array of dialog controls
	private ["_showTheseCtrls", "_hideTheseCtrls", "_x"];
		
	_hideTheseCtrls = _this select 1;	//array of ctrls to hide
	{_x ctrlShow FALSE} forEach _hideTheseCtrls;	
	
	_showTheseCtrls = _this select 0;	//array of ctrls to display
	{_x ctrlShow TRUE} forEach _showTheseCtrls;
};


fn_vector_findCollision = 
{
	//center screen location.  accounts for terrain and objects
	private ["_unit", "_start", "_end", "_impact", "_x", "_y", "_z", "_collisionASL"];
	
	_unit = _this select 0;		//object to omit
	_start = _this select 1;		//start loc [pos]
	_end = _this select 2;		//end loc [pos]

	_impact = cylinderCollision [_start,  _end, 0, _unit, "GEOM", .01]; //find terrain or object collision
	_x = _impact select 0;
	_y = _impact select 1;
	_z = _impact select 2;	
	
	_collisionASL = [_x, _y, _z];	//[collision point]
	
	//position array above sea level
	_collisionASL
};

fn_vector_convertDirection = 
{
	//given a direction, convert to another unit
	private ["_dir", "_input", "_output"];
	
	_dir = _this select 0;		//angle, degrees or mils
	_input = _this select 1;		//current unit
	_output = _this select 2;		//future unit
	
	if (_input == "6400") then	//input mils
	{
		if (_output == "360") then	
		{
			_dir = _dir / NUM_MILS_IN_ONE_DEG;	//output deg
		};
	}
	else	
	{
		if (_output == "6400") then	 //input deg
		{
			_dir = _dir * NUM_MILS_IN_ONE_DEG;	//output mils
		};		
	};
	
	//float in mils or degrees
	_dir
};

fn_showDirection = 
{
	//given two points, display direction, accounts for vector settings and declination
	private ["_pt1", "_pt2", "_declination", "_units", "_decimals", "_ctrl", "_text",  "_gridHeading", "_magHeading", "_magHeadingFormatted"];
	
	_pt1 = _this select 0;					//obj or pos
	_pt2 = _this select 1;					//obj or pos
	_declination = _this select 2;		//vector declination in degrees
	_units = _this select 3;				//desired output unit
	_decimals = _this select 4;			//number of decimal places
	_ctrl = _this select 5;				//ctrl to update
	_text = _this select 6;				//how to output the value
	
	_gridHeading = [_pt1, _pt2] call fn_vbs_dirTo; //number, map heading in degrees

	//if result is "scalar" exit and display nothing
	if (isNil "_gridHeading") exitWith {};
	
	//subtract declination (0= grid heading)
	_magHeading = _gridHeading + _declination;		
	
	//check for wrap around
	if (_magHeading > 360) then
	{
		_magHeading = _magHeading - 360;
	}
	else
	{
		if (_magHeading < 0) then
		{
			_magHeading = _magHeading + 360;
		};
	};
	
	//check vector and convert from degrees to mils if needed
	if (_units == "6400") then
	{
		_magHeading = _magHeading * NUM_MILS_IN_ONE_DEG;
	};
	
	//format decimals	
	_magHeadingFormatted = [_magHeading, _decimals, FALSE] call fn_vbs_cutDecimals; //returns number
	
	//output results
	_ctrl ctrlSetText format[_text,_magHeadingFormatted];
};


fn_showDistance = 
{
	//given two points, display distance, accounts for vector settings
	private ["_pt1", "_pt2", "_type", "_units", "_decimals", "_ctrl", "_text", "_dis", "_disFormatted"];
	
	_pt1 = _this select 0;			//obj or pos
	_pt2 = _this select 1;			//obj or pos
	_type = _this select 2;		//"slant" or "map"
	_units = _this select 3;		//desired output unit
	_decimals = _this select 4;	//number of decimal places
	_ctrl = _this select 5;		//ctrl to update
	_text = _this select 6;		//text output
	
	//calculate range, returns number in meters
	switch(_type) do
	{
		case "map":	//map distance
		{
			_dis = [_pt1, _pt2] call fn_vbs_distance2D;					
		};
		case "slant":	//distance to include altitude
		{
			_dis = _pt1 distance _pt2;	
		};
	};
	
	//if result is "scalar" exit and display nothing
	if (isNil "_dis") exitWith {};
	
	//convert if needed
	if (_units == "FEEt") then	//(yes, little t)
	{	
		_dis = _dis * NUM_FT_IN_ONE_M;	//output number in feet
	};
	
	//format decimals	
	_disFormatted = [_dis, _decimals, FALSE] call fn_vbs_cutDecimals; //returns number
	
	//if distance > 12000m show 99999
	if (_disFormatted > 12000) then
	{
		_disFormatted = 99999;
	};
	
	//output results
	_ctrl ctrlSetText format[_text,_disFormatted];
};


fn_findObjectPosition =
{
	//passed array [_somePosition, _control, _units, _output]
	private ["_objPos", "_ctrlArray", "_format", "_output", "_mapCoordsLong", "_mapSheetLn", "_mapSheet", "_gridZone", "_squareID", "_easting","_northing","_alt","_altFormatted","_results"];
	
	_objPos = _this select 0;		//unit pos
	_ctrlArray = _this select 1;	//list of ctrl numbers to update
	_format = _this select 2;		//what format (mgrs)
	_output = _this select 3;		//text to output
		
	//find full mgrs grid  (11SMS1234567890) and string length
	_mapCoordsLong = (PosToCoord [_objPos, _format, MGRS_PRECISION]) select 0;
	_fullStrLn = strlen _mapCoordsLong;
	
	//find full map sheet (11SMS)
	_mapSheetLn = _fullStrLn-(MGRS_PRECISION*2);
	_mapSheet = trim [_mapCoordsLong, 0, MGRS_PRECISION*2];  //returns 4 or 5 letter string
	
	//find gridZone (11s)
	_gridZone = trim [_mapSheet, 0, 2];	
	
	//find squareID (MS)
	_squareID = trim [_mapSheet, (_mapSheetLn-2), 0];
	
	//find easting and northing
	_easting = trim [_mapCoordsLong, _mapSheetLn, MGRS_PRECISION];
	_northing = trim [_mapCoordsLong,(_mapSheetLn + MGRS_PRECISION),0];
	
	//find altitude above sea level
	_alt = _objPos select 2;
	_altFormatted = [_alt, 0, FALSE] call fn_vbs_cutDecimals; //returns a number
	
	//output results
	_results = [_gridZone, _squareID, _easting, _northing, _altFormatted];
	
	[_ctrlArray, _output, _results] call fn_output_results;
};

fn_output_results =
{
	//loop through ctrl numbers and update
	//custom output for a single value to a single ctrl
	private ["_ctrlArray", "_output", "_results"];
	
	_ctrlArray = _this select 0;
	_output = _this select 1;
	_results = _this select 2;

	_count = count _ctrlArray;
	for "_i" from 0 to (_count -1)do
	{

		_ctrl = _ctrlArray select _i;
		_text = _output select _i;
		_value = _results select _i;

		ctrlSetText [_ctrl, format[_text,_value]];
	};
};


fn_find_dlg_ctrls = 
{
	//find list of controls
	private ["_ctrlArray","_display", "_dagr_ctrl_list","_ctrl"];

	_ctrlArray = _this select 0;
	_display = _this select 1;

	_dagr_ctrl_list = [];
	{
		_ctrl = _display displayCtrl _x;	
		_dagr_ctrl_list = _dagr_ctrl_list + [_ctrl];
	} forEach _ctrlArray;

	_dagr_ctrl_list
};


fn_load_dagr_pos = 
{
	//load previous dagr position
	private ["_ctrlArray", "_display", "_count", "_ctrl", "_pos"];
	
	_ctrlArray = _this select 0;
	_display = _this select 1;
	
	//check if positions were saved
	if (count DAGR_CTRL_POS > 0) then
	{
		//positions found, move controls
		_count = count _ctrlArray;

		for "_i" from 0 to (_count - 1) do
		{
			_ctrl = _ctrlArray select _i;
			_pos = DAGR_CTRL_POS select _i;
			
			_ctrl ctrlSetPosition _pos;
			_ctrl ctrlCommit 0;
		};
	};
};

fn_save_dagr_pos=
{
	//dagr stowed, find position for each ctrl
	private ["_dagr_ctrl_pos","_ctrlPos"];
	
	_dagr_ctrl_pos = [];

	//loop through each ctrl and save position to a global variable
	{
		_ctrlPos = ctrlPosition _x;
		_dagr_ctrl_pos = _dagr_ctrl_pos + [_ctrlPos];
		
	} forEach DAGR_CTRL_LIST;

	DAGR_CTRL_POS = _dagr_ctrl_pos;
};

fn_dagr_up_arrow =
{
	private ["_screen_Num", "_path", "_file"];
	
	_screen_Num = _this select 0;
	
	//change screen number
	_screen_Num = _screen_Num - 1; 

	//only show values from 4 to 6
	if (_screen_Num < 4) then	
	{
		_screen_Num = 6;
	};
	
	//update global variable
	SCREEN_NUM = _screen_Num;

	//update dagr screen	
	_path = "\vbs2\customer\weapons\mef_universal_optic\data";
	
	_file = DAGR_SCREEN_NAMES select _screen_Num;	
	ctrlSetText [IDC_DAGR_SCREEN, format ["%1\dagr_%2_ca.paa", _path, _file]];
	
	nul = ["update_dagr", _screen_Num] execVM "\vbs2\customer\weapons\mef_universal_optic\data\scripts\dagrActions.sqf";
};

fn_dagr_dn_arrow =
{
	private ["_screen_Num", "_path", "_file"];

	_screen_Num = _this select 0;
	
	//change screen number
	_screen_Num = _screen_Num + 1; 

	//only show values from 4 to 6
	if (_screen_Num > 6) then	
	{
		_screen_Num = 4;
	};

	//update global variable
	SCREEN_NUM = _screen_Num;
	
	//update dagr screen
	_path = "\vbs2\customer\weapons\mef_universal_optic\data";
	
	_file = DAGR_SCREEN_NAMES select _screen_Num;	
	ctrlSetText [IDC_DAGR_SCREEN, format ["%1\dagr_%2_ca.paa", _path, _file]];
	
	nul = ["update_dagr", _screen_Num] execVM "\vbs2\customer\weapons\mef_universal_optic\data\scripts\dagrActions.sqf";
};






















