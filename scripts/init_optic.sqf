//initialize the optic.  Executes each time the player uses the optic

#include "\vbs2\headers\dikCodes.hpp"


_unit = _this select 0;
_vehicle = vehicle _unit; 

//init some variables
//set first optic
OPTIC_MODE = 0;
JTAC_GEAR = nil;
SHOW_IZLID = nil;





//initialize variables
//get current vector values, can be set a run time.  if not, initialized from fn_library_universalOptic.sqf

_initVectorSettings = _unit getVariable "VECTOR_CURRENT_STATE";
if (isNil "_initVectorSettings") then
{
	_unit setVariable ["VECTOR_CURRENT_STATE", ["6400", "SI-U", (getDeclination)*17.77777]];
	VECTOR_SET_DIR = "6400";  //"6400" or "360"	
	VECTOR_SET_DIS = "SI_U";  //"SI_U" or "FEEt"
	VECTOR_SET_DEC = (getDeclination)*17.77777;  //number in mils or degrees, relative to zero (1, 2, 3, etc or -1, -2, -3 etc)
};



//remove batteries so only PLDR can designate
_magazines = magazines _unit;
_count = {"vbs2_Batteries" in _x} count magazines _unit;

if (_count > 0) then
{
	for "_i" from 1 to _count do
	{
		_unit removeMagazine "vbs2_Batteries";
	};
	
	ADD_BATTERY = TRUE;		//readd batteries later
}
else
{
	ADD_BATTERY = FALSE;	
};

//since opening the inventory causes the cfg eventHandler to fire,
//just reset the optic when player is dismounted by simulating V key press

/*
//not sure what this does??
[-1,5000] diagMessage format ["%1 || %2", player, _vehicle];

//fade screen when player is in 
if (player == _vehicle) then
{

	[-1,5000] diagMessage "some script";
	titleText ["Loading Optic", "BLACK FADED"];
	DIK_V  setAction 1;
	sleep .5;
	DIK_V  setAction 1;
	sleep .5;
	titleText ["Loading Optic", "BLACK IN"];
};
*/

// done initializing, now create text for various optics
[] call fn_create_Optic_HUD;			




	