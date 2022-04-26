
//updates a marker on the 2D map.  This is where the player is looking
//also determines when to reload/remove the functions for the optic
//a lot of exception handling is evaluted here

#include "\vbs2\customer\weapons\mef_universal_optic\mef_universal_optic_defines.hpp"

_unit = _this select 0;		//from config eventHandler
_optic = _this select 1;	//from config eventHandler

_vehicle = vehicle _unit;  
RUN_OPTIC_SCRIPTS = TRUE;

waitUntil {sleep .5; opticsState select 0};

//create the stare point
if (isNull MEF_CAM_STARE_POINT || isNil "MEF_CAM_STARE_POINT") then
{
	MEF_STARE_POINT_GRP = createGroup CIVILIAN;
	MEF_CAM_STARE_POINT = MEF_STARE_POINT_GRP createUnit ["vbs2_Logic", [0,0,0], [], 0, "NONE"];
};

//_hdl_1 = [-1,5000] diagMessage "";
//[-1,5000] diagMessage "starking script";

//run the loop
while
{
	player hasWeapon _optic &&				//when optic is removed from inventory
	_vehicle == vehicle _unit &&			//unit enters or exits a vehicle
	alive player && 							//unit dies
	(opticsState select 0)	&&				//optic off
	RUN_OPTIC_SCRIPTS
}
do
{	
	if (applicationState select 1 == "MISSION_INTERUPT") then
	{
		//VBS menu open in MP
		waitUntil {applicationState select 1 != "MISSION_INTERUPT"};
	};

	if (isNull MEF_CAM_STARE_POINT || isNil "MEF_CAM_STARE_POINT") then
	{
		MEF_STARE_POINT_GRP = createGroup CIVILIAN;
		MEF_CAM_STARE_POINT = MEF_STARE_POINT_GRP createUnit ["vbs2_Logic", [0,0,0], [], 0, "NONE"];
	};
	
	//update stare point location
	_pt1 = convertToASL positionCameraToWorld [0,0,0];  			//camera pos
	_pt2 = screenToWorld [0.5, 0.5, LASER_MAX_RANGE];							//point 15k away
	_endPt = [_unit, _pt1, _pt2] call fn_vector_findCollision;  //returns collision point ASL
	
	MEF_CAM_STARE_POINT setPosASL _endPt;							//global variable for the endpoint
	
	//show IZLID
	if (SHOW_IZLID) then
	{
		//get position above player's head
		_sourcePos = getPosASL2 _unit;	
		_sourcePos set [2, ((_sourcePos select 2)+1.9)];
		
		//crazy math time to calculate the dir and up vector
		//_vecForward = [_sourcePos, _pt2] call fn_vbs_vectorFromXToY;
		_vecForward = [_sourcePos, _endPt] call fn_vbs_vectorFromXToY;
		_vecRight = [[0,0,1], _vecForward] call fn_vbs_vectorFromXToY;
		_vecUp = [_vecForward, _vecRight] call fn_vbs_vectorFromXToY;
		
		//update izlid pos
		MEF_IZLID_1 setPosASL2 _sourcePos;
		MEF_IZLID_1 setVectorDirAndUp [_vecForward, _vecUp];
	};

	//if dialog open, exit and restart
	if (dialog) exitWith {};
	
	//[_hdl_1, 500] diagMessage "loop running";
	sleep .01;
};

//loop was stopped, check is a dlg was opened
if (dialog) then	
{
	//map, IWV or custom dialog open
	waitUntil {!dialog};
	
	//this is dangerous!  If this fails, user can only shut down VBS
	//since opticsState is a slow script, wait a bit and make sure optic is back in use
	disableUserInput TRUE; 
	sleep .75;
	disableUserInput FALSE;
	
	//same unit is using optic
	if (opticsState select 0) then
	{
		//optic still in use, recreate and restart script
		//[-1,5000] diagMessage "optic still in use";
		[] call fn_create_Optic_HUD;	
		_create_starePoint = [_unit, _optic] execVM "\vbs2\customer\weapons\mef_universal_optic\data\scripts\create_starePoint.sqf";
	}
	else
	{
		//optic put away (cargo, turnin, switch unit)
		//[-1,5000] diagMessage "optic stowed";
		//[_optic] call fn_removeBindKeys;
		[] call fn_removeBindKeys;
	};
}
else
{
	//check if player is running with optic
	//if ("mevas" in (animationState _unit) || "mrun" in (animationState _unit)) then
	if ("bin" in (animationState _unit)) then
	{
		//hide all the ctrls
		//[-1,5000] diagMessage "unit running";
		_optic_ctrls_list = OPTIC_CTRLS_ALL + [IDC_PLDR_IR_RANGE] + [IDC_PLDR_IR_TX_R];
		
		_display = MEF_UNIV_OPTIC;
		_ctrlArray = [_optic_ctrls_list, _display] call fn_find_dlg_ctrls;
		
		[[],_ctrlArray] call fn_showHideCtrl;
		
		//wait til optic is back in use
		waitUntil {opticsState select 0};
	
		//reload optic
		[] call fn_create_Optic_HUD;	
		_create_starePoint = [_unit, _optic] execVM "\vbs2\customer\weapons\mef_universal_optic\data\scripts\create_starePoint.sqf";
	}
	else
	{
		//[-1,5000] diagMessage "something else, close";
		[_optic] call fn_removeBindKeys;
	};
};

//[_hdl_1, 5000] diagMessage "stop";


