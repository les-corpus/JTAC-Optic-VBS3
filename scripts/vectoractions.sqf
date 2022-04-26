//display information for the vector

/*
- LMB click = azimuth (AZ)*
- LMB press = constant AZ*
- LMB click + LMB press = continuous AZ and vertical interval (VI)*
- LMB press + RMB click = save p1; LMB release = AZ and dis from p1 to p2*
- LMB click + LMB press + RMB click = save p1; LMB release = fall of shot*
- LMB click x3 = set declination*
- LMB click x5 = change units of measure*

- RMB click = range*
- RMB click + RMB press = distance and height above or below observer's pos
- RMB press + LMB click = save p1; RMB release = distance from p1 to p2
- RMB click + RMB press + LMB click = save p1; RMB release = width and height of object
*/

#include "\vbs2\customer\weapons\mef_universal_optic\mef_universal_optic_defines.hpp"

_mouseButton = _this select 0;		//LMBup or LMBdn or RMBup or RMBdn
_event = _this select 1;				//[NUM_LMB_DN, NUM_LMB_UP, LMB_STATE, NUM_RMB_DN, NUM_RMB_UP, RMB_STATE]
_unit = player;

//initialize vector controls
_display = MEF_UNIV_OPTIC;
_ctrl_left = _display displayCtrl IDC_VECTOR_TX_LEFT;
_ctrl_right = _display displayCtrl IDC_VECTOR_TX_RIGHT;
_aiming_circle = _display displayCtrl IDC_VECTOR_AIM_CIRCLE;

switch (_mouseButton) do
{
	case "LMBup":
	{
		switch (str _event) do
		{
			case "[1,1,0,0,0,0]":
			{
				//show left ctrl
				[[_ctrl_left],[_ctrl_right,_aiming_circle ]] call fn_showHideCtrl;
			};
			
			case "[1,1,0,1,1,0]":
			{
				//RMB click + LMB click = LRF shot
				[[_ctrl_left, _ctrl_right],[_aiming_circle ]] call fn_showHideCtrl;	
				
				[_unit, MEF_CAM_STARE_POINT, "slant", VECTOR_SET_DIS, 0, _ctrl_right, "%1"] call fn_showDistance;
				
				//save location of the stare point for the dagr	
				_unit setVariable ["VECTOR_LRF_SHOT", MEF_CAM_STARE_POINT];					
			};
		};
	};
	
	case "LMBdn":
	{
		switch (str _event) do
		{
			case "[1,0,1,0,0,0]":
			{
				//LMB press = constant AZ
				[[_ctrl_left, _aiming_circle],[_ctrl_right]] call fn_showHideCtrl;
				
				//convert declination to degrees
				_declinationConverted = [VECTOR_SET_DEC, VECTOR_SET_DIR, "360"] call fn_vector_convertDirection; 
				
				//display direction
				waitUntil
				{
					sleep .1;
					[_unit, MEF_CAM_STARE_POINT, _declinationConverted, VECTOR_SET_DIR, ZERO_DECIMAL, _ctrl_left, "%1"] call fn_showDirection;

					LMB_STATE == 0
				};
			};
		};
	};
	
	case "RMBup":
	{
		switch (str _event) do
		{		
			case "[0,0,0,1,1,0]": 
			{
				//RMB click = range		
				[[_ctrl_right],[_aiming_circle]] call fn_showHideCtrl;
				
				[_unit, MEF_CAM_STARE_POINT, "slant", VECTOR_SET_DIS, 0, _ctrl_right, "%1"] call fn_showDistance;
			};	
			
			case "[1,1,0,1,1,0]":
			{
				//RMB click + LMB click = LRF shot
				[[_ctrl_left, _ctrl_right],[_aiming_circle ]] call fn_showHideCtrl;	

				[_unit, MEF_CAM_STARE_POINT, "slant", VECTOR_SET_DIS, 0, _ctrl_right, "%1"] call fn_showDistance;
				
				//save location of the stare point for the dagr
				_unit setVariable ["VECTOR_LRF_SHOT", MEF_CAM_STARE_POINT];
			};
		};
	};
	
	case "RMBdn":
	{
		switch (str _event) do
		{
			case "[0,0,0,1,0,1]": 
			{
				//show aiming circle and left ctrl
				[[_aiming_circle],[_ctrl_right]] call fn_showHideCtrl;		
			};
		};
	};
	
	case "timeOut":
	{
		switch (str _event) do
		{
			case "[3,3,0,0,0,0]": 
			{
				//change declination
				[[_ctrl_left, _ctrl_right ],[_aiming_circle]] call fn_showHideCtrl;
			};

			case "[5,5,0,0,0,0]": 
			{
				//change units
				[[_ctrl_left, _ctrl_right ],[_aiming_circle]] call fn_showHideCtrl;						
			};				
		};
	};
};



/*
		case "[2,1,1,0,0,0]":
		{
			//LMB click + LMB press = continuous AZ and vertical interval (VI)
			player sideChat "cont AZ and VI";	
		};
		
		case "[1,0,1,1,1,0]":
		{
			//LMB press + RMB click = save p1; LMB release = AZ and dis from p1 to p2
			player sideChat "save p1 az and dis *special*";	
		};
		
		case "[1,1,0,1,1,0]":
		{
			//LMB press + RMB click = save p1; LMB release = AZ and dis from p1 to p2
			player sideChat "AZ and dis from p1 to p2";	
		};
		
		case "[2,1,1,1,1,0]":
		{
			//LMB click + LMB press + RMB click = save p1; LMB release = fall of shot
			player sideChat "save p1 fall of shot *special*";
		};
		
		case "[2,2,0,1,1,0]":
		{
			//LMB click + LMB press + RMB click = save p1; LMB release = fall of shot
			player sideChat "fall of shot";
		};
		
		case "[0,0,0,2,1,1]":
		{
			//RMB click + RMB press = distance and height above or below observer's pos
			player sideChat "dis height above obs pos";
		};
		
		case "[1,1,0,1,0,1]":
		{
			//RMB press + LMB click = save p1; RMB release = distance from p1 to p2
			player sideChat "save p1 dis p1 to p2 *special*";
		};		
		case "[1,1,0,1,1,0]":
		{
			//RMB press + LMB click = save p1; RMB release = distance from p1 to p2
			player sideChat "dis p1 to p2";
		};
		case "[1,1,0,2,1,1]":
		{
			//RMB click + RMB press + LMB click = save p1; RMB release = width and height of object
			player sideChat "save p1 width and height";
		};
		case "[1,1,0,2,2,0]":
		{
			//RMB click + RMB press + LMB click = save p1; RMB release = width and height of object
			player sideChat "width and height";
		};
	*/
	
					
					