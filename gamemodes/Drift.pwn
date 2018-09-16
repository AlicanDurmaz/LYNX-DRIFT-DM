/*
		 __________   ___   ______  __       _______. __    ______   .__   __.
		|   ____\  \ /  /  /      ||  |     /       ||  |  /  __  \  |  \ |  |
		|  |__   \  V  /  |  ,----'|  |    |   (----`|  | |  |  |  | |   \|  |
		|   __|   >   <   |  |     |  |     \   \    |  | |  |  |  | |  . `  |
		|  |____ /  .  \  |  `----.|  | .----)   |   |  | |  `--'  | |  |\   |
		|_______/__/ \__\  \______||__| |_______/    |__|  \______/  |__| \__|

						         + LYNX DRIFT +
	          				    ~ (10/12/2016) ~
				                  + Excision +

--> http://patorjk.com/software/taag/#p=display&f=Graffiti&t=Type%20Something%20
																				*/
#include 				          												<a_samp>

#undef MAX_PLAYERS
#define MAX_PLAYERS 50

#undef MAX_VEHICLES
#define MAX_VEHICLES 50

#include                                                              			<sscanf2>
#include 				          									   			<a_mysql>
#include 																		<a_http>
#include                                                              			<streamer>
#include                                                               			<foreach>
#define WC_CUSTOM_VENDING_MACHINES false
#include                                                         				<weapon-config>
#include                                                           				<crashdetect>
#include																		<mSelection>
#include 																		<dutils>
#include                                                                  		<Dini>
#include 															   			<antiFly>
#include 															 			<progress2>
#include 																		<callbacks>

#define HOSTNAME																"hostname ["VERSION"] LYNX DRIFT - DM - RACE"
#define MODENAME                												"DRIFT/DM/RACE/TDM"
#define VERSION                 												"v1.0.9"
#define LANGUAGE																"language Turkce"
#define WEBSITE                 												"weburl www.LynxSlidaz.tk"
#define MAPNAME                 												"mapname Paradise"
#define RCONPASS																"rcon_password ananbendexd"
#define CHATLOG 																"chatlogging 0"

#define dcmd(%1,%2,%3) if(!strcmp((%3)[1], #%1, true, (%2)) && ((((%3)[(%2) + 1] == '\0') && (dcmd_%1(playerid, ""))) || (((%3)[(%2) + 1] == ' ') && (dcmd_%1(playerid, (%3)[(%2) + 2]))))) return 1
#define function%0(%1) forward%0(%1); public%0(%1)

#define PVG->%0->%1[%2] GetPVar%0(%2,#%1)
#define PVS->%0->%1[%2]->%3; SetPVar%0(%2,#%1,%3);

#define PRESSED(%0)	(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))

new MySQL: g_SQL;
enum
{
    DIALOG_REGISTER,
    DIALOG_LOGIN,
    DIALOG_DMZONE,
    DIALOG_RADIO,
    DIALOG_STATS,
    DIALOG_STUFFS,
    DIALOG_CEZA,
    DIALOG_CREDITS,
	DIALOG_MYCAR,
	DIALOG_DUEL_WEAPON,
	DIALOG_DUEL_WEAPON2,
	DIALOG_DUEL_MAP,
	DIALOG_DUEL,
	DIALOG_RACE,
	DIALOG_TDM,
	DIALOG_AKA,
	DIALOG_TUNE
};
enum p_Vars
{
	Para,
	Skor,
	bool: Giris,
	LoginTimer,
	GirisSayisi,
	Kayit,
	Admin,
	DJ,
	Online,
	IP[16],
	SQL,
	Olum,
	Oldurme,
	NBan,
	Exp,
	ExpLevel,
	Skin,
	bool:Muted,
	YaraliTime,
	TalkTime,
	SpecType,
	SpecID,
	bool:Specte,
	TeleTimer,
	UpdateKMH_Timer,
	NosTimer,
	Spree,
	Text3D:Label,
    bool: TDM,
	TDM_Team,
	bool:MuzikIzin,
	bool:Araba,
	Arabam,
	bool:eJump,
	bool:rDurum,
	bool:PMengel,
	LastPM,
	bool:Dmde,
	bool:Yarista,
	DMModu,
	bool:Posaldim,
	bool:pSpawn,
	bool:GunGamede,
	GunGameLevel,
	bool:Duelde,
	DuelRakip,
	DuelSilah1,
	DuelSilah2,
	DuelMap,
	DuelTick,
	LastTimeSprinted,
	LastMonitoredSpeed,
	TimesWarned,
	LastTimeWarned,
	Attemp
};
new	Oyuncu[MAX_PLAYERS][p_Vars];

new SonMuzik[256], Text3D: SpawnLabel, SpawnIcon;

enum s_Vars
{
	r_Oyuncu,
	r_Tarih,
	r_MOyuncu,
}
new RekorInfo[s_Vars];

#define TEAM_1 20
#define TEAM_2 21
enum t_Vars
{
	TDM[56],
	Team1_Skin,
	Team2_Skin,
	Team1[56],
	Team2[56],
	bool: Starts,
	bool: t_Aktif,
	Float:Team1_X,
	Float:Team1_Y,
	Float:Team1_Z,
	Float:Team2_X,
	Float:Team2_Y,
	Float:Team2_Z,
	bool: Plus,
	Timer,
	Timer2,
	Team1_Score,
	Team2_Score,
	Sayac, Sure
};
new TDMInfo[t_Vars], Text:TDMTextdraw;

new	Duello_Sayac[MAX_PLAYERS],	Duello_Timer[MAX_PLAYERS];

new PlayerText:RaceInfo[MAX_PLAYERS], PlayerText:SpeedoText[MAX_PLAYERS], PlayerBar:SpeedoBar[MAX_PLAYERS], PlayerText:ExpText[MAX_PLAYERS],
	PlayerBar:ExpBar[MAX_PLAYERS], PlayerText:ExpOdul[MAX_PLAYERS], Text:ExpOdulBox, Text:ExpOdulBox2,
	PlayerText:ParaText[MAX_PLAYERS], Text:ParaBox, Text:LYNX, Text:PmText[8], LinesText[8][128];

new AracIsimler[212][] =
{
	{"Landstalker"},{"Bravura"},{"Buffalo"},{"Linerunner"},{"Perrenial"},{"Sentinel"},{"Dumper"},{"Firetruck"},{"Trashmaster"},{"Stretch"},{"Manana"},{"Infernus"},{"Voodoo"},{"Pony"},{"Mule"},{"Cheetah"},{"Ambulance"},{"Leviathan"},{"Moonbeam"},{"Esperanto"},{"Taxi"},{"Washington"},
	{"Bobcat"},{"Mr Whoopee"},{"BF Injection"},{"Hunter"},{"Premier"},{"Enforcer"},{"Securicar"},{"Banshee"},{"Predator"},{"Bus"},{"Rhino"},{"Barracks"},{"Hotknife"},{"Trailer 1"},{"Previon"},{"Coach"},{"Cabbie"},{"Stallion"},{"Rumpo"},{"RC Bandit"},{"Romero"},{"Packer"},{"Monster"},
	{"Admiral"},{"Squalo"},{"Seasparrow"},{"Pizzaboy"},{"Tram"},{"Trailer 2"},{"Turismo"},{"Speeder"},{"Reefer"},{"Tropic"},{"Flatbed"},{"Yankee"},{"Caddy"},{"Solair"},{"Berkley's RC Van"},{"Skimmer"},{"PCJ-600"},{"Faggio"},{"Freeway"},{"RC Baron"},{"RC Raider"},{"Glendale"},{"Oceanic"},
	{"Sanchez"},{"Sparrow"},{"Patriot"},{"Quad"},{"Coastguard"},{"Dinghy"},{"Hermes"},{"Sabre"},{"Rustler"},{"ZR-350"},{"Walton"},{"Regina"},{"Comet"},{"BMX"},{"Burrito"},{"Camper"},{"Marquis"},{"Baggage"},{"Dozer"},{"Maverick"},{"News Chopper"},{"Rancher"},{"FBI Rancher"},{"Virgo"},{"Greenwood"},
	{"Jetmax"},{"Hotring"},{"Sandking"},{"Blista Compact"},{"Police Maverick"},{"Boxville"},{"Benson"},{"Mesa"},{"RC Goblin"},{"Hotring Racer A"},{"Hotring Racer B"},{"Bloodring Banger"},{"Rancher"},{"Super GT"},{"Elegant"},{"Journey"},{"Bike"},{"Mountain Bike"},{"Beagle"},{"Cropdust"},{"Stunt"},
	{"Tanker"}, {"Roadtrain"},{"Nebula"},{"Majestic"},{"Buccaneer"},{"Shamal"},{"Hydra"},{"FCR-900"},{"NRG-500"},{"HPV1000"},{"Cement Truck"},{"Tow Truck"},{"Fortune"},{"Cadrona"},{"FBI Truck"},{"Willard"},{"Forklift"},{"Tractor"},{"Combine"},{"Feltzer"},{"Remington"},{"Slamvan"},
	{"Blade"},{"Freight"},{"Streak"},{"Vortex"},{"Vincent"},{"Bullet"},{"Clover"},{"Sadler"},{"Firetruck LA"},{"Hustler"},{"Intruder"},{"Primo"},{"Cargobob"},{"Tampa"},{"Sunrise"},{"Merit"},{"Utility"},{"Nevada"},{"Yosemite"},{"Windsor"},{"Monster A"},{"Monster B"},{"Uranus"},{"Jester"},
	{"Sultan"},{"Stratum"},{"Elegy"},{"Raindance"},{"RC Tiger"},{"Flash"},{"Tahoma"},{"Savanna"},{"Bandito"},{"Freight Flat"},{"Streak Carriage"},{"Kart"},{"Mower"},{"Duneride"},{"Sweeper"},{"Broadway"},{"Tornado"},{"AT-400"},{"DFT-30"},{"Huntley"},{"Stafford"},{"BF-400"},{"Newsvan"},
	{"Tug"},{"Trailer 3"},{"Emperor"},{"Wayfarer"},{"Euros"},{"Hotdog"},{"Club"},{"Freight Carriage"},{"Trailer 3"},{"Andromada"},{"Dodo"},{"RC Cam"},{"Launch"},{"Police Car (LSPD)"},{"Police Car (SFPD)"},{"Police Car (LVPD)"},{"Police Ranger"},{"Picador"},{"S.W.A.T. Van"},{"Alpha"},{"Phoenix"},{"Glendale"},
	{"Sadler"},{"Luggage Trailer A"},{"Luggage Trailer B"},{"Stair Trailer"},{"Boxville"},{"Farm Plow"},{"Utility Trailer"}
};
#define ConvertTimeEx(%0,%1,%2,%3,%4) \
	new \
 	   Float: %0 = floatdiv(%1, 60000) \
	;\
	%2 = floatround(%0, floatround_tozero); \
	%3 = floatround(floatmul(%0 - %2, 60), floatround_tozero); \
	%4 = floatround(floatmul(floatmul(%0 - %2, 60) - %3, 1000), floatround_tozero)

#define Loop(%0,%1) for(new %0 = 0;%0 != %1; %0++)
#define MAX_RACE_CHECKPOINTS_EACH_RACE 120
#define MAX_RACES 100
new
	BuildRace,
	BuildRaceType,
	BuildVehicle,
	BuildCreatedVehicle,
	BuildModeVID,
	BuildName[30],
	bool: BuildTakeVehPos,
	BuildVehPosCount,
	bool: BuildTakeCheckpoints,
	BuildCheckPointCount,
	RaceBusy = 0x00,
	RaceName[30],
	RaceVehicle,
	RaceStarter,
	RaceType,
	TotalCP,
	Float: RaceVehCoords[2][4],
	Float: CPCoords[MAX_RACE_CHECKPOINTS_EACH_RACE][4],
	CreatedRaceVeh[MAX_PLAYERS],
	Index,
	PlayersCount[2],
	CountTimer,
	CountAmount,
	RaceTick,
	bool: RaceStarted,
	CPProgess[MAX_PLAYERS],
	Position,
	FinishCount,
	JoinCount,
	rCounter,
	RaceTime,
	InfoTimer[MAX_PLAYERS],
	RaceNames[MAX_RACES][128],
 	TotalRaces,
 	TimeProgress,
	Float:SosPos[MAX_PLAYERS][4],
	Float:SosHiz[MAX_PLAYERS][3],
	YarislarEx[2048],
	RaceIcon
;
new Float:MinigunSpawn[][] =
{
	{973.0589,  2316.3159,   11.4609, 87.1686},
	{986.4928,2325.1326,11.4609, 267.1686},
	{986.4928,2325.1326,11.4609, 354.9028}
};
new Float:Minigun2Spawn[][] =
{
	{1234.1995,-1532.9268,61.8965},
	{1244.6893,-1531.7697,61.8965},
	{1260.9058,-1532.6482,61.8965},
	{1263.6920,-1544.9302,61.8887},
	{1261.5153,-1555.6399,61.8887},
	{1251.4204,-1556.0851,61.8887}
};
new Float:Minigun3Spawn[][] =
{
	{-2427.4009,1554.4165,5.0234},
	{-2414.5095,1548.7104,2.1231},
	{-2437.6494,1544.8699,8.3984},
	{-2379.4399,1553.3627,2.1172},
	{-2389.1731,1547.5798,2.1172},
	{-2366.2214,1535.8253,2.1172}
};
new Float:DeagleSpawn[][4] =
{
	{1310.3135,2185.9031,11.0234},
	{1334.8992,2188.3469,11.0234},
	{1357.5551,2188.4478,11.0156},
	{1358.9692,2158.6802,11.0156},
	{1341.2158,2151.2722,11.0156},
	{1320.0950,2150.0845,11.0234}
};
new Float:RPGSpawn[][4] =
{
    {246.9303,1385.9288,23.3703,0.0000},
    {165.2390,1357.2312,26.2036,0.0000},
    {165.9894,1426.7672,26.2623,0.0000},
    {132.4376,1355.1686,26.1223,134.3979},
    {203.1333,1398.6799,43.0946,0.0000}
};
new Float:KnifeSpawn[][] =
{
	{-1231.8455,53.4615,14.2328},
	{-1226.9824,50.9824,14.2328},
	{-1227.5969,53.7017,14.2328}
};
new Float:SniperSpawn[][] =
{
    {-1275.2830, 2549.3999, 87.0439},
    {-1294.8413, 2550.2292, 86.8636},
    {-1300.4288, 2527.4558, 87.5890},
    {-1304.5908, 2513.4658, 87.0420},
    {-1325.3331, 2483.3584, 87.0469},
    {-1311.9021, 2463.9019, 87.3888},
    {-1284.0488, 2461.8347, 87.5566},
    {-1290.9120, 2485.2249, 87.0940}
};
new Float:PBSpawn[][] =
{
    {2241.5171,-1154.6251,1029.7969},
    {2246.8867,-1189.7568,1029.8043},
    {2240.3855,-1186.5699,1033.7969},
    {2221.1074,-1150.9645,1025.7969}
};
new Float:PB2Spawn[][] =
{
    {1280.6078,-5.7545,1001.0156},
    {1257.9564,-41.2606,1001.0156},
    {1253.1864,-2.1560,1001.0156}
};
new Float:PB3Spawn[][] =
{
    {-948.3098,1930.6299,5.0000},
    {-942.2321,1849.2006,5.0000},
    {-960.5627,1888.6068,9.0000}
};
new Float:myPos[MAX_PLAYERS][4];
new Radiolar[][][] =
{
    {"http://bit.ly/1s2C9wp", "Metro FM"},
    {"http://bit.ly/1g3pgRQ", "Hitplay Radio"},
    {"http://bit.ly/2kmKjGL", "Fenomen Radio"},
    {"http://bit.ly/2gbHk2A", "House"},
    {"http://bit.ly/2yg7W8W", "Club"},
    {"http://bit.ly/2kF2VSe", "Amsterdam Trance Radio"},
    {"http://bit.ly/2wNZieu", "Noise FM"},
    {"http://bit.ly/2ge6GwB", "Dubstep FM"},
    {"http://bit.ly/2yFygdN", "RADIO LIVE"}
};
new OyuncununSilahlari[MAX_PLAYERS][12];
new PlayerColors[200] =
{
	0xFF8C13FF,0xC715FFFF,0x20B2AAFF,0xDC143CFF,0x6495EDFF,0xf0e68cFF,0x778899FF,0xFF1493FF,0xF4A460FF,
	0xEE82EEFF,0xFFD720FF,0x8b4513FF,0x4949A0FF,0x148b8bFF,0x14ff7fFF,0x556b2fFF,0x0FD9FAFF,0x10DC29FF,
	0x534081FF,0x0495CDFF,0xEF6CE8FF,0xBD34DAFF,0x247C1BFF,0x0C8E5DFF,0x635B03FF,0xCB7ED3FF,0x65ADEBFF,
	0x5C1ACCFF,0xF2F853FF,0x11F891FF,0x7B39AAFF,0x53EB10FF,0x54137DFF,0x275222FF,0xF09F5BFF,0x3D0A4FFF,
	0x22F767FF,0xD63034FF,0x9A6980FF,0xDFB935FF,0x3793FAFF,0x90239DFF,0xE9AB2FFF,0xAF2FF3FF,0x057F94FF,
	0xB98519FF,0x388EEAFF,0x028151FF,0xA55043FF,0x0DE018FF,0x93AB1CFF,0x95BAF0FF,0x369976FF,0x18F71FFF,
	0x4B8987FF,0x491B9EFF,0x829DC7FF,0xBCE635FF,0xCEA6DFFF,0x20D4ADFF,0x2D74FDFF,0x3C1C0DFF,0x12D6D4FF,
	0x48C000FF,0x2A51E2FF,0xE3AC12FF,0xFC42A8FF,0x2FC827FF,0x1A30BFFF,0xB740C2FF,0x42ACF5FF,0x2FD9DEFF,
	0xFAFB71FF,0x05D1CDFF,0xC471BDFF,0x94436EFF,0xC1F7ECFF,0xCE79EEFF,0xBD1EF2FF,0x93B7E4FF,0x3214AAFF,
	0x184D3BFF,0xAE4B99FF,0x7E49D7FF,0x4C436EFF,0xFA24CCFF,0xCE76BEFF,0xA04E0AFF,0x9F945CFF,0xDCDE3DFF,
	0x10C9C5FF,0x70524DFF,0x0BE472FF,0x8A2CD7FF,0x6152C2FF,0xCF72A9FF,0xE59338FF,0xEEDC2DFF,0xD8C762FF,
	0xD8C762FF,0xFF8C13FF,0xC715FFFF,0x20B2AAFF,0xDC143CFF,0x6495EDFF,0xf0e68cFF,0x778899FF,0xFF1493FF,
	0xF4A460FF,0xEE82EEFF,0xFFD720FF,0x8b4513FF,0x4949A0FF,0x148b8bFF,0x14ff7fFF,0x556b2fFF,0x0FD9FAFF,
	0x10DC29FF,0x534081FF,0x0495CDFF,0xEF6CE8FF,0xBD34DAFF,0x247C1BFF,0x0C8E5DFF,0x635B03FF,0xCB7ED3FF,
	0x65ADEBFF,0x5C1ACCFF,0xF2F853FF,0x11F891FF,0x7B39AAFF,0x53EB10FF,0x54137DFF,0x275222FF,0xF09F5BFF,
	0x3D0A4FFF,0x22F767FF,0xD63034FF,0x9A6980FF,0xDFB935FF,0x3793FAFF,0x90239DFF,0xE9AB2FFF,0xAF2FF3FF,
	0x057F94FF,0xB98519FF,0x388EEAFF,0x028151FF,0xA55043FF,0x0DE018FF,0x93AB1CFF,0x95BAF0FF,0x369976FF,
	0x18F71FFF,0x4B8987FF,0x491B9EFF,0x829DC7FF,0xBCE635FF,0xCEA6DFFF,0x20D4ADFF,0x2D74FDFF,0x3C1C0DFF,
	0x12D6D4FF,0x48C000FF,0x2A51E2FF,0xE3AC12FF,0xFC42A8FF,0x2FC827FF,0x1A30BFFF,0xB740C2FF,0x42ACF5FF,
	0x2FD9DEFF,0xFAFB71FF,0x05D1CDFF,0xC471BDFF,0x94436EFF,0xC1F7ECFF,0xCE79EEFF,0xBD1EF2FF,0x93B7E4FF,
	0x3214AAFF,0x184D3BFF,0xAE4B99FF,0x7E49D7FF,0x4C436EFF,0xFA24CCFF,0xCE76BEFF,0xA04E0AFF,0x9F945CFF,
	0xDCDE3DFF,0x10C9C5FF,0x70524DFF,0x0BE472FF,0x8A2CD7FF,0x6152C2FF,0xCF72A9FF,0xE59338FF,0xEEDC2DFF,
	0xD8C762FF,0xD8C762FF
};
new v1 = mS_INVALID_LISTID;
new v2 = mS_INVALID_LISTID;
new v3 = mS_INVALID_LISTID;
new v4 = mS_INVALID_LISTID;
new v5 = mS_INVALID_LISTID;
new v6 = mS_INVALID_LISTID;
new v7 = mS_INVALID_LISTID;
new v8 = mS_INVALID_LISTID;
new v9 = mS_INVALID_LISTID;
new v10 = mS_INVALID_LISTID;
new v11 = mS_INVALID_LISTID;
new v12 = mS_INVALID_LISTID;
new v13 = mS_INVALID_LISTID;
new v14 = mS_INVALID_LISTID;
new v15 = mS_INVALID_LISTID;
new v16 = mS_INVALID_LISTID;
new v17 = mS_INVALID_LISTID;

#define ADMIN_SPEC_TYPE_NONE 	0
#define ADMIN_SPEC_TYPE_PLAYER 	1
#define ADMIN_SPEC_TYPE_VEHICLE 2
enum c_Vars
{
	ColorName[4],
	ColorID[7]
};
new RenkInfo[][c_Vars] =
{
	{"g","00FF00"},{"r","FF0000"},{"w","FFFFFF"},
	{"b","0000FF"},{"y","FFCC00"},{"o","FF9900"},
	{"t","00FFFF"},{"p","FF00FF"}
};

new rTestcount, rTestStr[128], rMoney, rScore, rExp, bool:rTest = false;

new bool:IgnoreSpawn[MAX_PLAYERS];

new bool:Locked;

enum k_Vars
{
	k_Name[25]
};
new Komutlar[113][k_Vars] =
{
	{"/setlevel"},{"/setdj"},{"/setarmour"},{"/setheal"},{"/setscore"},
	{"/givecash"},{"/giveexp"},{"/ban"},{"/unbanip"},{"/nban"},{"/kick"},
	{"/mute"},{"/unmute"},{"/sarki"},{"/cc"},{"/goto"},{"/get"},
	{"/setallweather"},{"/setalltime"},{"/mkapat"},{"/yayinac"},{"/pm"},{"/re"},
	{"/pmon"},{"/pmoff"},{"/l"},{"/jetpack"},{"/gopos"},{"/setcolor"},{"/aka"},
 	{"/spec"},{"/specoff"},{"/rac"},{"/pmspec"},{"/pmspecoff"},{"/otorenk"},{"/yarisekle"},
 	{"/yarisdurdur"},{"/myskin"},{"/saveskin"},{"/mytime"},{"/myweather"},{"/radio"},
 	{"/dinle"},{"/gungamecik"},{"/dmcik"},{"/sos"},{"/yariscik"},{"/tdmcik"},{"/tdmler"},
 	{"/tdmkatil"},{"/yarislar"},{"/mapyenile"},{"/yariskatil"},{"/gungame"},{"/duel"},{"/veh"},
 	{"/vrenk"},{"/savepos"},{"/loadpos"},{"/stats"},{"/admins"},{"/adminlistesi"},
 	{"/djs"},{"/djlistesi"},{"/nickdegis"},{"/sifredegis"},{"/tune"},
 	{"/mycar"},{"/ojump"},{"/dmzone"},{"/mg1"},{"/mg2"},{"/mg3"},
  	{"/deagle"},{"/rpg"},{"/knifedm"},{"/sniperdm"},{"/pb1"},{"/pb2"},{"/pb3"},
  	{"/snipshot"},{"/dgshot"},{"/topskor"},{"/toppara"},{"/topkill"},{"/topdeath"},
  	{"/toponline"},{"/credits"},{"/drift1"},{"/drift2"},{"/drift3"},
  	{"/drift4"},{"/drift5"},{"/drift6"},{"/drift7"},{"/drift8"},{"/drift9"},{"/drift10"},
	{"/drift11"},{"/drift12"},{"/drift13"},{"/drift14"},{"/drift15"},{"/lvap"},
  	{"/sfap"},{"/olap"},{"/lsap"},{"/dag"},{"/djmekan"},{"/skilledinf"},{"/superstunt"},{"/cz"}
};
main()
{
	AntiDeAMX();
	WasteDeAMXersTime();
	new Yil,Ay,Gun,Saat,Dakika,Saniye;
	getdate(Yil, Ay, Gun), gettime(Saat,Dakika,Saniye);
	print("																");
	print("																");
	print("\t» ===============[E][X][C][I][S][I][O][N]=============== «");
	print("\t»                                                        «");
	print("\t»                      LYNX DRIFT V1                     «");
	print("\t»                       By Excision                      «");
	print("\t»                                                        «");
	print("\t» ===============[E][X][C][I][S][I][O][N]=============== «");
	printf("\t» =========== Tarih: %d/%d/%d Saat: %d:%d:%d =========== «",Gun, Ay, Yil, Saat, Dakika, Saniye);
	print("																");
	print("																");
}
AntiDeAMX()
{
	new a[][] =
	{
		"Unarmed (Fist)",
		"Brass K"
	};
	#pragma unused a
}
WasteDeAMXersTime()
{
    new b;
    #emit load.pri b
    #emit stor.pri b
}
public OnGameModeInit()
{
    foreach(new i: Player) Kick(i);
	new t = GetTickCount();

	new MySQLOpt: option_id = mysql_init_options();
	mysql_set_option(option_id, AUTO_RECONNECT, true);
	g_SQL = mysql_connect("127.0.0.1", "root", "", "lynx", option_id);
	if(g_SQL == MYSQL_INVALID_HANDLE || mysql_errno(g_SQL) != 0)
	{
		print("[MySQL-ERROR]: Veritabanina baglanti kurulamadi.");
		SendRconCommand("exit");
		return 1;
	}
	print("[MySQL]: Veritabanina baglanti kuruldu.");
	new query[1024];
	strcat(query,	"CREATE TABLE IF NOT EXISTS `hesaplar` (\
												`player_id` int(11) NOT NULL AUTO_INCREMENT,\
												`player_name` varchar(24) NOT NULL,\
												`player_sifre` varchar(65) NOT NULL,\
												`player_gsifre` varchar(65) NOT NULL,\
												`player_ip` varchar(16) NOT NULL,\
												`player_admin` int(11) NOT NULL DEFAULT '0',\
												`player_dj` int(11) NOT NULL DEFAULT '0',\
												`player_kayit` int(11) NOT NULL DEFAULT '0',\
												`player_skor` int(11) NOT NULL DEFAULT '0',");
												
	strcat(query, "        						`player_para` int(11) NOT NULL DEFAULT '0',\
												`player_oldurme` int(11) NOT NULL DEFAULT '0',\
												`player_olum` int(11) NOT NULL DEFAULT '0',\
												`player_giris` int(11) NOT NULL DEFAULT '0',\
												`player_online` int(11) NOT NULL DEFAULT '0',\
												`player_nban` int(11) NOT NULL DEFAULT '0',\
												`player_skin` int(11) NOT NULL DEFAULT '0',\
												`player_exp` int(11) NOT NULL DEFAULT '0',");
												
	strcat(query, "								`player_explevel` int(11) NOT NULL DEFAULT '1',\
												`player_ates` int(11) NOT NULL DEFAULT '0',\
												`player_h` int(11) NOT NULL DEFAULT '0',\
												PRIMARY KEY (`player_id`))");
	mysql_tquery(g_SQL, query);
	SendRconCommand(HOSTNAME);
	SendRconCommand(LANGUAGE);
	SendRconCommand(WEBSITE);
	SendRconCommand(MAPNAME);
	SendRconCommand(RCONPASS);
	SendRconCommand(CHATLOG);
	SetGameModeText(MODENAME);
	
    SetVehicleUnoccupiedDamage(true);
    SetVehiclePassengerDamage(true);
    SetDisableSyncBugs(true);
    
	SetTimer("ServerTimer", 1000, true);
	SetTimer("RandomMessage", 180000, true);
 	SetTimer("ReactionTest", 1000*60*5, true);
	
	SetWeather(0);
	SetWorldTime(7);
	DisableInteriorEnterExits();
	UsePlayerPedAnims();
    AllowInteriorWeapons(1);
    EnableStuntBonusForAll(0);
 	Rekorlar();
 	Akalar();
 	LoadRaceNames();
 	SonMuzik = "http://bit.ly/1g3pgRQ";
	for(new i = 0; i <= 311; i++) AddPlayerClass(i, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
 	SpawnLabel = Create3DTextLabel("\n\nSpawn Zone\n{FFFFFF}LYNX Drift", 0xFF0000FF, -307.9476, 1555.0444, 80.1332, 100.0, 0, 1);

    v1 = LoadModelSelectionMenu("LYNX/Diger/v1-v17/v1.txt");
    v2 = LoadModelSelectionMenu("LYNX/Diger/v1-v17/v2.txt");
    v3 = LoadModelSelectionMenu("LYNX/Diger/v1-v17/v3.txt");
    v4 = LoadModelSelectionMenu("LYNX/Diger/v1-v17/v4.txt");
    v5 = LoadModelSelectionMenu("LYNX/Diger/v1-v17/v5.txt");
	v6 = LoadModelSelectionMenu("LYNX/Diger/v1-v17/v6.txt");
	v7 = LoadModelSelectionMenu("LYNX/Diger/v1-v17/v7.txt");
	v8 = LoadModelSelectionMenu("LYNX/Diger/v1-v17/v8.txt");
	v9 = LoadModelSelectionMenu("LYNX/Diger/v1-v17/v9.txt");
	v10 = LoadModelSelectionMenu("LYNX/Diger/v1-v17/v10.txt");
	v11 = LoadModelSelectionMenu("LYNX/Diger/v1-v17/v11.txt");
	v12 = LoadModelSelectionMenu("LYNX/Diger/v1-v17/v12.txt");
	v13 = LoadModelSelectionMenu("LYNX/Diger/v1-v17/v13.txt");
	v14 = LoadModelSelectionMenu("LYNX/Diger/v1-v17/v14.txt");
	v15 = LoadModelSelectionMenu("LYNX/Diger/v1-v17/v15.txt");
	v16 = LoadModelSelectionMenu("LYNX/Diger/v1-v17/v16.txt");
	v17 = LoadModelSelectionMenu("LYNX/Diger/v1-v17/v17.txt");

	BuildCreatedVehicle = (BuildCreatedVehicle == 0x01) ? (DestroyVehicle(BuildVehicle), BuildCreatedVehicle = 0x00) : (DestroyVehicle(BuildVehicle), BuildCreatedVehicle = 0x00);
	KillTimer(rCounter);
	KillTimer(CountTimer);
	foreach(new i: Player)
	{
        DisableRemoteVehicleCollisions(i, 0);
		DisablePlayerRaceCheckpoint(i);
		PlayerTextDrawDestroy(i, RaceInfo[i]);
		DestroyVehicle(CreatedRaceVeh[i]);
		Oyuncu[i][Yarista] = false;
		KillTimer(InfoTimer[i]);
		RemovePlayerMapIcon(i, RaceIcon);
	}
	JoinCount = 0;
	FinishCount = 0;
	TimeProgress = 0;

	LYNX = TextDrawCreate(527.000000, 426.000000, "~r~L~r~~h~Y~r~~h~N~r~~h~~h~~h~X ~r~~h~~h~~h~D~r~~h~~h~R~r~~h~I~r~F~r~~h~T");
	TextDrawBackgroundColor(LYNX, 255);
	TextDrawFont(LYNX, 1);
	TextDrawLetterSize(LYNX, 0.589999, 2.299998);
	TextDrawColor(LYNX, -1);
	TextDrawSetOutline(LYNX, 0);
	TextDrawSetProportional(LYNX, 1);
	TextDrawSetShadow(LYNX, 0);
	TextDrawSetSelectable(LYNX, 0);
	
	ExpOdulBox = TextDrawCreate(310.000000, 180.000000, "_");
	TextDrawAlignment(ExpOdulBox, 2);
	TextDrawBackgroundColor(ExpOdulBox, 255);
	TextDrawFont(ExpOdulBox, 1);
	TextDrawLetterSize(ExpOdulBox, 0.500000, 12.000000);
	TextDrawColor(ExpOdulBox, -1);
	TextDrawSetOutline(ExpOdulBox, 0);
	TextDrawSetProportional(ExpOdulBox, 1);
	TextDrawSetShadow(ExpOdulBox, 1);
	TextDrawUseBox(ExpOdulBox, 1);
	TextDrawBoxColor(ExpOdulBox, -500022494);
	TextDrawTextSize(ExpOdulBox, 20.000000, 170.000000);
	TextDrawSetSelectable(ExpOdulBox, 0);

	ExpOdulBox2 = TextDrawCreate(310.000000, 184.000000, "_");
	TextDrawAlignment(ExpOdulBox2, 2);
	TextDrawBackgroundColor(ExpOdulBox2, 255);
	TextDrawFont(ExpOdulBox2, 1);
	TextDrawLetterSize(ExpOdulBox2, 0.500000, 11.099996);
	TextDrawColor(ExpOdulBox2, -1);
	TextDrawSetOutline(ExpOdulBox2, 0);
	TextDrawSetProportional(ExpOdulBox2, 1);
	TextDrawSetShadow(ExpOdulBox2, 1);
	TextDrawUseBox(ExpOdulBox2, 1);
	TextDrawBoxColor(ExpOdulBox2, -500022494);
	TextDrawTextSize(ExpOdulBox2, 21.000000, 163.000000);
	TextDrawSetSelectable(ExpOdulBox2, 0);

	ParaBox = TextDrawCreate(611.000000, 79.000000, "_");
	TextDrawBackgroundColor(ParaBox, 255);
	TextDrawFont(ParaBox, 1);
	TextDrawLetterSize(ParaBox, 0.500000, 2.000000);
	TextDrawColor(ParaBox, -1);
	TextDrawSetOutline(ParaBox, 0);
	TextDrawSetProportional(ParaBox, 1);
	TextDrawSetShadow(ParaBox, 1);
	TextDrawUseBox(ParaBox, 1);
	TextDrawBoxColor(ParaBox, 255);
	TextDrawTextSize(ParaBox, 494.000000, 2.000000);
	TextDrawSetSelectable(ParaBox, 0);
	
	TDMTextdraw = TextDrawCreate(86.0000, 298.5000, "~y~~h~TDM Bilgileri~n~~r~~h~~h~Ballas: ~w~~h~~h~30~n~~g~~h~~h~Grove: ~w~~h~~h~30~n~~b~~h~~h~~h~Sure: ~w~~h~~h~04:45");
	TextDrawFont(TDMTextdraw, 1);
	TextDrawLetterSize(TDMTextdraw, 0.2000, 1.0000);
	TextDrawAlignment(TDMTextdraw, 2);
	TextDrawColor(TDMTextdraw, -1);
	TextDrawSetOutline(TDMTextdraw, -1);
	TextDrawBackgroundColor(TDMTextdraw, 255);
	TextDrawSetProportional(TDMTextdraw, 1);
	TextDrawSetProportional(TDMTextdraw, 1);
	TextDrawUseBox(TDMTextdraw, 1);
	TextDrawBoxColor(TDMTextdraw, 34);
	TextDrawTextSize(TDMTextdraw, 241.0000, 101.0000);

    for(new i = 0; i < 7; i++)
    {
        PmText[i] = TextDrawCreate(3.000000, 250.000000 - i* 10, "");
        TextDrawBackgroundColor(PmText[i], 51);
        TextDrawFont(PmText[i], 1);
        TextDrawLetterSize(PmText[i], 0.200000, 1.100000);
        TextDrawTextSize(PmText[i], 640, 480);
        TextDrawColor(PmText[i], -1);
        TextDrawSetOutline(PmText[i], 0);
        TextDrawSetProportional(PmText[i], 1);
        TextDrawSetShadow(PmText[i], 0);

        LinesText[i] = "";
        TextDrawSetString(PmText[i], LinesText[i]);
    }
  	printf("\tMod yuklendi. Sure: %d ms.", GetTickCount() - t);
	return 1;
}
public OnGameModeExit()
{
	foreach(new i: Player) Kick(i);
	mysql_close();
    Delete3DTextLabel(SpawnLabel);
	return 1;
}
function VeriTemizle(playerid)
{
	Oyuncu[playerid][Olum] = 0;
	Oyuncu[playerid][Oldurme] = 0;
	Oyuncu[playerid][SQL] = 0;
	Oyuncu[playerid][Admin] = 0;
	Oyuncu[playerid][DJ] = 0;
	Oyuncu[playerid][Kayit] = -1;
	Oyuncu[playerid][GirisSayisi] = 0;
	Oyuncu[playerid][NBan] = 0;
 	Oyuncu[playerid][Para] = 0;
 	Oyuncu[playerid][Skor] = 0;
 	Oyuncu[playerid][Exp] = 0;
 	Oyuncu[playerid][ExpLevel] = 1;
  	Oyuncu[playerid][Skin] = 0;
	Oyuncu[playerid][Muted] = false;
	Oyuncu[playerid][TDM] = false;
	Oyuncu[playerid][TDM_Team] = -1;
 	Oyuncu[playerid][Specte] = false;
 	Oyuncu[playerid][eJump] = false;
	Oyuncu[playerid][Spree] = 0;
	Oyuncu[playerid][PMengel] = true;
	Oyuncu[playerid][MuzikIzin] = true;
	Oyuncu[playerid][rDurum] = false;
    Oyuncu[playerid][LastPM] = INVALID_PLAYER_ID;
    Oyuncu[playerid][Dmde] = false;
    Oyuncu[playerid][DMModu] = 0;
    Oyuncu[playerid][Posaldim] = false;
    Oyuncu[playerid][pSpawn] = false;
    Oyuncu[playerid][GunGamede] = false;
    Oyuncu[playerid][GunGameLevel] = 0;
	Oyuncu[playerid][Duelde] = false;
 	Oyuncu[playerid][DuelRakip] = INVALID_PLAYER_ID;
	Oyuncu[playerid][DuelSilah1] = 0;
	Oyuncu[playerid][DuelSilah2] = 0;
	Oyuncu[playerid][DuelMap] = 0;
	Oyuncu[playerid][Attemp] = 0;

	SetPVarInt(playerid, "ClassSecOc", 0);
	for(new i = 0; i < 12; i++) OyuncununSilahlari[playerid][i] = 0;
	return 1;
}
public OnPlayerConnect(playerid)
{
	GetPlayerIp(playerid, Oyuncu[playerid][IP], 16);
	
	if(GetNumberOfPlayersOnThisIP(Oyuncu[playerid][IP]) > 3)
	{
		printf("[BOT] %s(%i) isimli oyuncu  bot saldýrý yaptý. %s.", PlayerName(playerid), playerid, Oyuncu[playerid][IP]);
	   	BanReason(playerid, "Bot Hack", "Sistem");
	    return 1;
	}
	for(new ex = 0; ex < 10; ex++) SendClientMessage(playerid, 0xFFFFFFFF, "");
 	new stramk[78 + MAX_PLAYER_NAME];
    format(stramk, sizeof(stramk), "[GIRIS] {FFFFFF}%s sunucuya giriþ yaptý. [%i/%i]", PlayerName(playerid), Iter_Count(Player), GetMaxPlayers());
    SendClientMessageToAll(0x0099CCFF, stramk);
	SendClientMessage(playerid, 0xFF0000FF, "LYNX DRIFT {FFFFFF}Best Of Drift Server {FF0000}|| {FFFFFF}Website: {FF0000}www.LynxSlidaz.tk");

	RekorCheck(playerid);
    AKA(playerid);
	VeriTemizle(playerid);
    OnConnection(playerid);

	ParaText[playerid] = CreatePlayerTextDraw(playerid, 498.000000, 75.000000, " ");
	PlayerTextDrawBackgroundColor(playerid, ParaText[playerid], 255);
	PlayerTextDrawFont(playerid, ParaText[playerid], 3);
	PlayerTextDrawLetterSize(playerid, ParaText[playerid], 0.590000, 2.600000);
	PlayerTextDrawColor(playerid, ParaText[playerid], 0xFF0000FF);
	PlayerTextDrawSetOutline(playerid, ParaText[playerid], 1);
	PlayerTextDrawSetProportional(playerid, ParaText[playerid], 1);
	PlayerTextDrawSetSelectable(playerid, ParaText[playerid], 0);

	RaceInfo[playerid] = CreatePlayerTextDraw(playerid, 86.0000, 298.5000, " ");
	PlayerTextDrawFont(playerid, RaceInfo[playerid], 1);
	PlayerTextDrawLetterSize(playerid, RaceInfo[playerid], 0.2000, 1.0000);
	PlayerTextDrawAlignment(playerid, RaceInfo[playerid], 2);
	PlayerTextDrawColor(playerid, RaceInfo[playerid], -1);
	PlayerTextDrawSetOutline(playerid, RaceInfo[playerid], -1);
	PlayerTextDrawBackgroundColor(playerid, RaceInfo[playerid], 255);
	PlayerTextDrawSetProportional(playerid, RaceInfo[playerid], 1);
	PlayerTextDrawSetProportional(playerid, RaceInfo[playerid], 1);
	PlayerTextDrawUseBox(playerid, RaceInfo[playerid], 1);
	PlayerTextDrawBoxColor(playerid, RaceInfo[playerid], 34);
	PlayerTextDrawTextSize(playerid, RaceInfo[playerid], 241.0000, 101.0000);

	SpeedoText[playerid] = CreatePlayerTextDraw(playerid, 638.000000, 408.000000, "	");
	PlayerTextDrawAlignment(playerid, SpeedoText[playerid], 3);
	PlayerTextDrawBackgroundColor(playerid, SpeedoText[playerid], 51);
	PlayerTextDrawFont(playerid, SpeedoText[playerid], 2);
	PlayerTextDrawLetterSize(playerid, SpeedoText[playerid], 0.250000, 0.700000);
	PlayerTextDrawColor(playerid, SpeedoText[playerid], -1);
	PlayerTextDrawSetOutline(playerid, SpeedoText[playerid], 0);
	PlayerTextDrawSetProportional(playerid, SpeedoText[playerid], 1);
	PlayerTextDrawSetShadow(playerid, SpeedoText[playerid], 0);
	PlayerTextDrawSetSelectable(playerid, SpeedoText[playerid], 0);

	ExpText[playerid] = CreatePlayerTextDraw(playerid, 85.000000, 434.000000, " ");
	PlayerTextDrawAlignment(playerid,ExpText[playerid], 2);
	PlayerTextDrawBackgroundColor(playerid,ExpText[playerid], 51);
	PlayerTextDrawFont(playerid,ExpText[playerid], 2);
	PlayerTextDrawLetterSize(playerid,ExpText[playerid], 0.159998, 1.100000);
	PlayerTextDrawColor(playerid,ExpText[playerid], -1);
	PlayerTextDrawSetOutline(playerid,ExpText[playerid], 0);
	PlayerTextDrawSetProportional(playerid,ExpText[playerid], 1);
	PlayerTextDrawSetShadow(playerid,ExpText[playerid], 0);
	PlayerTextDrawSetSelectable(playerid,ExpText[playerid], 0);

	ExpOdul[playerid] = CreatePlayerTextDraw(playerid, 312.000000, 189.000000, " ");
	PlayerTextDrawAlignment(playerid, ExpOdul[playerid], 2);
	PlayerTextDrawBackgroundColor(playerid, ExpOdul[playerid], 34);
	PlayerTextDrawFont(playerid, ExpOdul[playerid], 2);
	PlayerTextDrawLetterSize(playerid, ExpOdul[playerid], 0.500000, 2.400000);
	PlayerTextDrawColor(playerid, ExpOdul[playerid], -1);
	PlayerTextDrawSetOutline(playerid, ExpOdul[playerid], 1);
	PlayerTextDrawSetProportional(playerid, ExpOdul[playerid], 1);
	PlayerTextDrawSetSelectable(playerid, ExpOdul[playerid], 0);

    Oyuncu[playerid][Label] = Create3DTextLabel(" ", GetPlayerColor(playerid), 0.0, 0.0, 1.4, 60.0, 1);
    Attach3DTextLabelToPlayer(Oyuncu[playerid][Label], playerid, 0.0, 0.0, 0.7);
    
	SetPlayerMapIcon(playerid, SpawnIcon, -307.9476, 1555.0444, 80.1332, 35, 0, MAPICON_GLOBAL);
    for(new j = 0; j < 7; j++) TextDrawHideForPlayer(playerid, PmText[j]);
    
    KillTimer(Oyuncu[playerid][UpdateKMH_Timer]);
    Oyuncu[playerid][UpdateKMH_Timer] = SetTimerEx("GostergeYenile", 50, true, "i", playerid);
    SpeedoBar[playerid] = CreatePlayerProgressBar(playerid, 640.000000, 417.000000, 111.500000, 4.199999, -500022273, 500.0000, 1, 0);
    ExpBar[playerid] = CreatePlayerProgressBar(playerid, 34.000000, 428.000000, 109.000000, 4.199998, 845519103, 500.0000, 0, 0);
	return 1;
}
public OnPlayerText(playerid, text[])
{
	if(Oyuncu[playerid][Giris] == false)
	{
		SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Giriþ yapmadan konuþamazsýnýz.");
		return 0;
	}
	if(GetPlayerState(playerid) == PLAYER_STATE_WASTED || GetPlayerState(playerid) == PLAYER_STATE_NONE)
	{
	    SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Spawn olmadan konuþamazsýnýz.");
	    return 0;
	}
	if(Oyuncu[playerid][Muted] == true)
	{
		SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Susturulmuþsunuz konuþamazsýnýz.");
		return 0;
 	}
	new string[256];
    if(text[0] == '@' && (Oyuncu[playerid][Admin] >= 1))
	{
		format(string,sizeof(string),"Admin Chat » {a3ddee}%s(%i): {FFFFFF}%s", PlayerName(playerid),playerid,text[1]);
		foreach(new i: Player) if(Oyuncu[i][Admin] >= 1 || IsPlayerAdmin(i)) SendClientMessage(i, 0xAFAFAFFF, string);
        printf("[admin chat] [%s]: %s", PlayerName(playerid), text);
	    return 0;
	}
	if(text[0] == '#' && (Oyuncu[playerid][Admin] >= 1 || Oyuncu[playerid][DJ] >= 1))
	{
		format(string,sizeof(string),"DJ Chat » {a3ddee}%s(%i): {FFFFFF}%s", PlayerName(playerid),playerid,text[1]);
		foreach(new i: Player) if(Oyuncu[i][DJ] >= 1 || Oyuncu[i][Admin] >= 1 || IsPlayerAdmin(i)) SendClientMessage(i, 0xAFAFAFFF, string);
    	printf("[dj chat] [%s]: %s", PlayerName(playerid), text);
	    return 0;
	}
	if(text[0] == '!' && Oyuncu[playerid][TDM] == true)
	{
	    switch(Oyuncu[playerid][TDM_Team])
		{
			case TEAM_1: format(string,sizeof(string), "{DF3535}(%s Chat) {FFFFFF}%s: %s", TDMInfo[Team1], PlayerName(playerid), text[1]);
			case TEAM_2: format(string,sizeof(string), "{55DF35}(%s Chat) {FFFFFF}%s: %s", TDMInfo[Team2], PlayerName(playerid), text[1]);
		}
		foreach(new i: Player) if(Oyuncu[playerid][TDM_Team] == Oyuncu[i][TDM_Team]) SendClientMessage(i, -1, string);
		return 0;
	}
	if(Oyuncu[playerid][Admin] < 1)
	{
 		if(GetTickCount() < Oyuncu[playerid][TalkTime])
 		{
    		format(string, sizeof(string),"Hata » {FFFFFF}Tekrar konuþmak için %d saniye beklemelisin.", ConvertTimer(Oyuncu[playerid][TalkTime] - GetTickCount()));
			SendClientMessage(playerid, 0xFF0000FF, string);
 			return 0;
		}
	}
	if(rTest == true)
	{
 		if(!strcmp(rTestStr, text, false))
   		{
 			format(string, sizeof(string), "Reaction » {FFFFFF}%s reaction testi kazandý {00D799}Odul $%d + %d skor + %d exp (%s)", PlayerName(playerid), rMoney, rScore, rExp, ConvertTime(GetTickCount() - rTestcount));
	   		SendClientMessageToAll(0x10869EFF, string);
	   		GivePlayerCash(playerid, rMoney);
	   		GivePlayerScore(playerid, rScore);
      		GivePlayerExp(playerid, rExp);
   			rTest = false;
		}
	}
	if(Oyuncu[playerid][rDurum] == true && Oyuncu[playerid][TDM] == false) SetPlayerColor(playerid, PlayerColors[random(200)]), LabelAyarla(playerid);
	if(Oyuncu[playerid][Admin] >= 1)
	{
		format(string, sizeof(string),"%s(%i): {FFFFFF}%s",PlayerName(playerid), playerid, RenkKontrol(text));
	}else
	{
   		format(string, sizeof(string),"%s(%i): {FFFFFF}%s", PlayerName(playerid), playerid, text);
	}
    SendClientMessageToAll(GetPlayerColor(playerid), string);
    SetPlayerChatBubble(playerid, text, GetPlayerColor(playerid), 100.0, 10000);
    printf("[chat] [%s]: %s", PlayerName(playerid), text);
    Oyuncu[playerid][TalkTime] = GetTickCount() + 4000;
 	return 0;
}

public OnPlayerDisconnect(playerid, reason)
{
	SavePlayer(playerid);
	new str[144];
    switch(reason)
    {
        case 0: format(str, sizeof(str), "[CIKIS] {FFFFFF}%s serverden ayrýldý. .: Crash :. [%i/%i]", PlayerName(playerid), (Iter_Count(Player)-1), GetMaxPlayers());
        case 1: format(str, sizeof(str), "[CIKIS] {FFFFFF}%s serverden ayrýldý. [%i/%i]", PlayerName(playerid), (Iter_Count(Player)-1), GetMaxPlayers());
        case 2: format(str, sizeof(str), "[CIKIS] {FFFFFF}%s serverden ayrýldý. .: Ban/Kick :. [%i/%i]", PlayerName(playerid), (Iter_Count(Player)-1), GetMaxPlayers());
    }
	SendClientMessageToAll(0x0099CCFF, str);

	if(Oyuncu[playerid][Yarista] == true)
    {
		JoinCount--;
		Oyuncu[playerid][Yarista] = false;
		DisableRemoteVehicleCollisions(playerid, 0);
		DestroyVehicle(CreatedRaceVeh[playerid]);
		DisablePlayerRaceCheckpoint(playerid);
		RemovePlayerMapIcon(playerid, RaceIcon);
		PlayerTextDrawHide(playerid, RaceInfo[playerid]);
		CPProgess[playerid] = 0;
		KillTimer(InfoTimer[playerid]);
		SetPlayerVirtualWorld(playerid, 0);
	}
	if(BuildRace == playerid+1) BuildRace = 0;
	if(Oyuncu[playerid][Duelde])
	{
	    format(str, sizeof(str), "Duel » {FFFFFF}%s duelloda %s'yý maðlup etti. Silahlar: {FF9900}%s & %s {FFFFFF}Sure: {FF9900}%s", PlayerName(Oyuncu[playerid][DuelRakip]), PlayerName(playerid), ReturnWeaponNameEx(Oyuncu[playerid][DuelSilah1]),ReturnWeaponNameEx(Oyuncu[playerid][DuelSilah2]), ConvertTime(GetTickCount() - Oyuncu[playerid][DuelTick]));
	    SendClientMessageToAll(0x99CC00FF, str);
        Oyuncu[Oyuncu[playerid][DuelRakip]][Duelde] = false;
	    Oyuncu[Oyuncu[playerid][DuelRakip]][DuelRakip] = INVALID_PLAYER_ID;
	    Oyuncu[Oyuncu[playerid][DuelRakip]][DuelSilah1] = 0;
	    Oyuncu[Oyuncu[playerid][DuelRakip]][DuelSilah2] = 0;
	    Oyuncu[Oyuncu[playerid][DuelRakip]][DuelMap] = 0;
        Oyuncu[playerid][Duelde] = false;
        Oyuncu[playerid][DuelRakip] = INVALID_PLAYER_ID;
        Oyuncu[playerid][DuelSilah1] = 0;
        Oyuncu[playerid][DuelSilah2] = 0;
        Oyuncu[playerid][DuelMap] = 0;
	}
    Oyuncu[playerid][DMModu] = 0;
    Oyuncu[playerid][Dmde] = false;
    
 	Delete3DTextLabel(Oyuncu[playerid][Label]);
 	
	if(Oyuncu[playerid][Araba] == true)
	{
		DestroyVehicle(Oyuncu[playerid][Arabam]);
		Oyuncu[playerid][Araba] = false;
	}
	
	PlayerTextDrawDestroy(playerid, RaceInfo[playerid]);
	PlayerTextDrawDestroy(playerid, ParaText[playerid]);
	PlayerTextDrawDestroy(playerid, SpeedoText[playerid]);
	PlayerTextDrawDestroy(playerid, ExpText[playerid]);
	PlayerTextDrawDestroy(playerid, ExpOdul[playerid]);

    KillTimer(Duello_Timer[playerid]);
	KillTimer(Oyuncu[playerid][NosTimer]);
    KillTimer(Oyuncu[playerid][TeleTimer]);
    KillTimer(Oyuncu[playerid][UpdateKMH_Timer]);
    KillTimer(Oyuncu[playerid][LoginTimer]);
    
	DestroyPlayerProgressBar(playerid, SpeedoBar[playerid]);
	DestroyPlayerProgressBar(playerid, ExpBar[playerid]);
	
	TextDrawHideForPlayer(playerid, LYNX);
	if(Iter_Count(Player) == 1 && Locked == true)
	{
		Locked = false;
		SendRconCommand("password 0");
	}
 	return 1;
}
forward OnPlayerRegister(playerid);
public OnPlayerRegister(playerid)
{
	Oyuncu[playerid][SQL] = cache_insert_id();
	SendClientMessage(playerid, 0x66FFFFFF,"Bilgi » {FFFFFF}Yeni bir hesap olusturdunuz. Iyi eglenceler!");
	KillTimer(Oyuncu[playerid][LoginTimer]);
	Oyuncu[playerid][Kayit] = gettime();
	Oyuncu[playerid][Giris] = true;
	new string[128];
	format(string, sizeof(string), "Server » {FFFFFF}%s(%i) adlý oyuncu sunucuya kayýt oldu. Kayýtlý oyuncu sayýsý {FF0000}%d", PlayerName(playerid), playerid, Oyuncu[playerid][SQL]);
	SendClientMessageToAll(0xFF6600FF, string);
	GivePlayerCash(playerid, 50000);
	GivePlayerExp(playerid, 15);
	PlayerPlaySound(playerid, 1057, 0, 0, 0);
	LabelAyarla(playerid);

	mysql_format(g_SQL, string, sizeof(string), "UPDATE `hesaplar` SET `player_ip` = '%s' WHERE `player_id` = '%i'", Oyuncu[playerid][IP], Oyuncu[playerid][SQL]);
	mysql_tquery(g_SQL, string);
	Oyuncu[playerid][GirisSayisi]++;
	SetPlayerScore(playerid, Oyuncu[playerid][Skor]);
	return 1;
}
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == DIALOG_REGISTER)
	{
 		if(!response) return Kick(playerid);
  		if(strlen(inputtext) > 32 || strlen(inputtext) < 4)
		{
			new String[128], str[250+24];
			strcat(str, "{FF0000}LYNX DRIFT{FFFFFF}'e Hoþgeldiniz!\n");
			format(String, sizeof(String), "{FFFFFF}Sunucu veritabanýnda {FF0000}%s(%i) {FFFFFF}adýnda bir kullanýcý bulunmuyor.\n", PlayerName(playerid), playerid);
			strcat(str, String);
			strcat(str, "{FFFFFF}Kayýt olmak için aþaðýdaki kutucuða þifrenizi giriniz.\n\n");
			strcat(str, "{FF0000}Bilgi » {FFFFFF}Þifreniz en az 4, en fazla 32 karakterden oluþabilir.");
			ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "{FF0000}LYNX DRIFT - {FFFFFF}Kayýt", str, "Kayýt", "Çýkýþ");
		}else
		{
			new Query[400];
			mysql_format(g_SQL, Query, sizeof(Query),"INSERT INTO `hesaplar` (player_name, player_sifre, player_gsifre, player_ip, player_kayit) VALUES ('%e', md5('%e'), '%e', '%s', %d)",PlayerName(playerid), inputtext, inputtext, Oyuncu[playerid][IP], gettime());
			mysql_tquery(g_SQL, Query, "OnPlayerRegister", "d", playerid);
		}
	}
	if(dialogid == DIALOG_LOGIN)
	{
		if(!response) return Kick(playerid);
	    if(strlen(inputtext) > 32 || strlen(inputtext) < 4)
		{
			new String[128], str[250+24];
			strcat(str, "{FF0000}LYNX DRIFT{FFFFFF}'e Hoþgeldiniz!\n");
			format(String, sizeof(String), "{FFFFFF}Sunucu veritabanýnda {FF0000}%s(%i) {FFFFFF}adýnda bir kullanýcý bulunuyor.\n", PlayerName(playerid), playerid);
			strcat(str, String);
			strcat(str, "{FFFFFF}Giriþ yapmak için aþaðýdaki kutucuða þifrenizi giriniz.\n\n");
			strcat(str, "{FF0000}Bilgi » {FFFFFF}Þifrenizi 40 saniye içinde girmelisiniz.");
			ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "{FF0000}LYNX DRIFT - {FFFFFF}Giriþ", str, "Giriþ", "Çýkýþ");
		}else
		{
			new Query[600];
			mysql_format(g_SQL, Query,sizeof(Query),"SELECT * FROM `hesaplar` WHERE `player_name` = '%s' AND `player_sifre` = md5('%e')", PlayerName(playerid), inputtext);
			new Cache:VeriCek = mysql_query(g_SQL, Query);
		    if(cache_num_rows())
			{
			    Oyuncu[playerid][Giris] = true;
				LoadStats(playerid);
				KillTimer(Oyuncu[playerid][LoginTimer]);
				SendClientMessage(playerid, 0x66FFFFFF,"Bilgi » {FFFFFF}Basariyla hesabiniza baglanti kuruldu, iyi eglenceler.");
				LabelAyarla(playerid);
			}else
			{
			    Oyuncu[playerid][Attemp]++;
			    if(Oyuncu[playerid][Attemp] == 3) return KickReason(playerid, "Hatali Giriþ", "Sistem");
				new String[128], Yazi[350], str[56];
				strcat(Yazi, "{FF0000}LYNX DRIFT{FFFFFF}'e Hoþgeldiniz!\n");
				format(String, sizeof(String), "{FFFFFF}Sunucu veritabanýnda {FF0000}%s(%i) {FFFFFF}adýnda bir kullanýcý bulunuyor.\n", PlayerName(playerid), playerid);
				strcat(Yazi, String);
				strcat(Yazi, "{FFFFFF}Giriþ yapmak için aþaðýdaki kutucuða þifrenizi giriniz.\n\n");
				strcat(Yazi, "{FF0000}Bilgi » {FFFFFF}Þifrenizi 40 saniye içinde girmelisiniz.");
				format(str, sizeof(str), "{FF0000}LYNX DRIFT - {FFFFFF}Giriþ (%d/3)", Oyuncu[playerid][Attemp]);
				ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, str, Yazi, "Giriþ", "Çýkýþ");
			}
			cache_delete(VeriCek);
		}
	}
  	if(dialogid == DIALOG_DMZONE)
  	{
  	    if(!response) return 1;
		switch(listitem)
		{
			case 0: OnPlayerCommandText(playerid, "/mg1");
			case 1: OnPlayerCommandText(playerid, "/mg2");
			case 2: OnPlayerCommandText(playerid, "/mg3");
			case 3: OnPlayerCommandText(playerid, "/deagle");
			case 4: OnPlayerCommandText(playerid, "/rpg");
			case 5: OnPlayerCommandText(playerid, "/knifedm");
			case 6: OnPlayerCommandText(playerid, "/sniperdm");
			case 7: OnPlayerCommandText(playerid, "/pb1");
			case 8: OnPlayerCommandText(playerid, "/pb2");
			case 9: OnPlayerCommandText(playerid, "/pb3");
			case 10: OnPlayerCommandText(playerid, "/snipshot");
			case 11: OnPlayerCommandText(playerid, "/dgshot");
		}
  	}
	if(dialogid == DIALOG_RADIO)
 	{
		if(!response) return 1;
		if(listitem == sizeof(Radiolar)) return OnPlayerCommandText(playerid, "/radio");
		StopAudioStreamForPlayer(playerid);
		PlayAudioStreamForPlayer(playerid, Radiolar[listitem][0]);
		new string[78];
		format(string, 78, "Bilgi » {FFFFFF}%s Adlý yayini açtiniz.", Radiolar[listitem][1]);
		SendClientMessage(playerid, 0x66FFFFFF, string);
    }
	if(dialogid == DIALOG_TUNE)
	{
		if(response)
		{
			if(listitem == 0) 
			{
				ShowPlayerDialog(playerid, DIALOG_TUNE+1, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Paintjob", "Paint Job 1\nPaint Job 2\nPaint Job 3\n[Geri]", "Seç", "Çýkýþ");
			}
			if(listitem == 1)
			{
				ShowPlayerDialog(playerid, DIALOG_TUNE+2, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Renk", "Black\nWhite\nRed\nBlue\nGreen\nYellow\nPink\nBrown\n[Geri]", "Seç", "Çýkýþ");
			}
			if(listitem == 2)
			{
				ShowPlayerDialog(playerid, DIALOG_TUNE+3, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Egzos", "Wheel Arch Alien Exhaust\nWheel Arch X-Flow Exhaust\nLocos Low Chromer Exhaust\nLocos Low Slamin Exhaust\n[Geri]", "Seç", "Çýkýþ");
			}
			if(listitem == 3)
			{
				ShowPlayerDialog(playerid, DIALOG_TUNE+4, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Ön Tampon", "Wheel Arch Alien bumper\nWheel Arch X-Flow bumper\nLocos Low Chromer bumper\nLocos Low Slamin bumper\n[Geri]", "Seç", "Çýkýþ");
			}
			if(listitem == 4)
			{
				ShowPlayerDialog(playerid, DIALOG_TUNE+5, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Arka Tampon", "Wheel Arch Alien bumper\nWheel Arch X-Flow bumper\nLocos Low Chromer bumper\nLocos Low Slamin bumper\n[Geri]", "Seç", "Çýkýþ");
			}
			if(listitem == 5)
			{
				ShowPlayerDialog(playerid, DIALOG_TUNE+6, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Çatý", "Wheel Arch Alien Roof Vent\nWheel Arch X-Flow Roof Vent\nLocos Low Hardtop Roof\nLocos Low Softtop Roof\n[Geri]", "Seç", "Çýkýþ");
			}
			if(listitem == 6)
			{
				ShowPlayerDialog(playerid, DIALOG_TUNE+7, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Spoiler", "Alien Spoiler\nX-Flow Spoiler\n[Geri]", "Seç", "Çýkýþ");
			}
			if(listitem == 7)
			{
				ShowPlayerDialog(playerid, DIALOG_TUNE+8, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Yan Etek", "Wheel Arch Alien Side Skirts\nWheel Arch X-Flow Side Skirts\nLocos Low Chrome Strip\nLocos Low Chrome Flames\nLocos Low Chrome Arches\nLocos Low Chrome Trim\nLocos Low Wheelcovers\n[Geri]", "Seç", "Çýkýþ");
			}
            if(listitem == 8)
			{
				ShowPlayerDialog(playerid, DIALOG_TUNE+9, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Bullbar", "Locos Low Chrome Grill\nLocos Low Chrome Bars\nLocos Low Chrome Lights\nLocos Low Chrome Bullbar\n[Geri]", "Seç", "Çýkýþ");
			}
			if(listitem == 9)
			{
				ShowPlayerDialog(playerid, DIALOG_TUNE+10, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Tekerlek", "Offroad\nMega\nWires\nTwist\nGrove\nImport\nAtomic\nAhab\nVirtual\nAccess\n[Diðer Sayfa]\n[Geri]", "Seç", "Çýkýþ");
			}
			if(listitem == 10)
			{
				ShowPlayerDialog(playerid, DIALOG_TUNE+11, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Müzik Seti", "Bass Boost\nSuper Bass Boost\nUltra Bass Boost\nKing Bass Boost\n[Geri]", "Seç", "Çýkýþ");
			}
			if(listitem == 11)
			{
				ShowPlayerDialog(playerid, DIALOG_TUNE+12, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Araç Modifiye", "Hidrolikler\nNitro x10\nAraç Tamir\n[Geri]", "Seç", "Çýkýþ");
			}
			if(listitem == 12)
			{
				ShowPlayerDialog(playerid, DIALOG_TUNE+13, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Tekerlek", "Trance\nShadow\nRimshine\nClassic\nCutter\nSwitch\nDollar\n[Geri]", "Seç", "Çýkýþ");
			}
		}
	}
	if(dialogid == DIALOG_TUNE+1)
	{
		if(response)
		{
			if(listitem == 0)
			{
				if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 562 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 565 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 559 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 561 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 560 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 575 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 534 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 567 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 536 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 535 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 576 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 483 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 558)
		        {
					ChangeVehiclePaintjob(GetPlayerVehicleID(playerid),0);
					PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Paintjob 1'i baþarýyla aracýna ekledin.");
                    ShowPlayerDialog(playerid, DIALOG_TUNE+1, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Paintjob", "Paint Job 1\nPaint Job 2\nPaint Job 3\n[Geri]", "Seç", "Çýkýþ");

				}else
				{
				   SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Bu paintjob Wheel Arch Angel ve Loco Low Co. tipi araçlar içindir!");
			       ShowPlayerDialog(playerid, DIALOG_TUNE, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Araç Modifiye","Paint Job\nRenkler\nEgzostlar\nÖn Tampon\nArka Tampon\nÇatý\nSpoiler\nYan Etekler\nBullbar\nTekerlerkler\nAraç Ses Sistemi\n[Diðer Sayfa]", "Seç", "Çýkýþ");
				}
			}
			if(listitem == 1)
			{
				if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 562 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 565 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 559 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 561 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 560 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 575 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 534 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 567 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 536 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 535 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 576 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 483 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 558)
                {
					ChangeVehiclePaintjob(GetPlayerVehicleID(playerid),1);
					PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Paintjob 2'yi baþarýyla aracýna ekledin.");
                    ShowPlayerDialog(playerid, DIALOG_TUNE+1, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Paintjob", "Paint Job 1\nPaint Job 2\nPaint Job 3\n[Geri]", "Seç", "Çýkýþ");

				}else
				{
				   SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Bu paintjob Wheel Arch Angel ve Loco Low Co. tipi araçlar içindir!");
			       ShowPlayerDialog(playerid, DIALOG_TUNE, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Araç Modifiye","Paint Job\nRenkler\nEgzostlar\nÖn Tampon\nArka Tampon\nÇatý\nSpoiler\nYan Etekler\nBullbar\nTekerlerkler\nAraç Ses Sistemi\n[Diðer Sayfa]", "Seç", "Çýkýþ");
				}
			}
			if(listitem == 2)
			{
				if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 562 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 565 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 559 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 561 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 560 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 575 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 534 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 567 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 536 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 535 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 576 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 483 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 558)
			    {
                   ChangeVehiclePaintjob(GetPlayerVehicleID(playerid),2);
                   PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
				   SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Paintjob 3'ü baþarýyla aracýna ekledin.");
                   ShowPlayerDialog(playerid, DIALOG_TUNE+1, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Paintjob", "Paint Job 1\nPaint Job 2\nPaint Job 3\n[Geri]", "Seç", "Çýkýþ");
				}else
				{
				   SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Bu paintjob Wheel Arch Angel ve Loco Low Co. tipi araçlar içindir!");
			       ShowPlayerDialog(playerid, DIALOG_TUNE, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Araç Modifiye","Paint Job\nRenkler\nEgzostlar\nÖn Tampon\nArka Tampon\nÇatý\nSpoiler\nYan Etekler\nBullbar\nTekerlerkler\nAraç Ses Sistemi\n[Diðer Sayfa]", "Seç", "Çýkýþ");
				}
			}
			if(listitem == 3)
			{
				ShowPlayerDialog(playerid, DIALOG_TUNE, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Araç Modifiye","Paint Job\nRenkler\nEgzostlar\nÖn Tampon\nArka Tampon\nÇatý\nSpoiler\nYan Etekler\nBullbar\nTekerlerkler\nAraç Ses Sistemi\n[Diðer Sayfa]", "Seç", "Çýkýþ");
			}
		}
	}
	if(dialogid == DIALOG_TUNE+2)
	{
		if(response)
		{
			if(listitem == 0)
			{
		            ChangeVehicleColor(GetPlayerVehicleID(playerid),0,0);
		            PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
		            SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Aracýný Siyaha Boyadýn.");
		            ShowPlayerDialog(playerid, DIALOG_TUNE+2, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Renk", "Siyah\nBeyaz\nKýrmýzý\nMavi\nYeþil\nSarý\nPembe\nKahverengi\n[Geri]", "Seç", "Çýkýþ");

			}
			if(listitem == 1)
			{
			        ChangeVehicleColor(GetPlayerVehicleID(playerid),1,1);
			        PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
			        SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Aracýný Beyaza Boyadýn.");
			        ShowPlayerDialog(playerid, DIALOG_TUNE+2, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Renk", "Siyah\nBeyaz\nKýrmýzý\nMavi\nYeþil\nSarý\nPembe\nKahverengi\n[Geri]", "Seç", "Çýkýþ");

			}
			if(listitem == 2)
			{
			        ChangeVehicleColor(GetPlayerVehicleID(playerid),3,3);
			        PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
			        SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Aracýný Kýrmýzýya Boyadýn.");
			        ShowPlayerDialog(playerid, DIALOG_TUNE+2, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Renk", "Siyah\nBeyaz\nKýrmýzý\nMavi\nYeþil\nSarý\nPembe\nKahverengi\n[Geri]", "Seç", "Çýkýþ");

			}
			if(listitem == 3)
			{
			        ChangeVehicleColor(GetPlayerVehicleID(playerid),79,79);
			        PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
			        SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Aracýný Maviye Boyadýn.");
			        ShowPlayerDialog(playerid, DIALOG_TUNE+2, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Renk", "Siyah\nBeyaz\nKýrmýzý\nMavi\nYeþil\nSarý\nPembe\nKahverengi\n[Geri]", "Seç", "Çýkýþ");

			}
			if(listitem == 4)
			{
			        ChangeVehicleColor(GetPlayerVehicleID(playerid),86,86);
			        PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
			        SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Aracýný Yeþile Boyadýn.");
			        ShowPlayerDialog(playerid, DIALOG_TUNE+2, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Renk", "Siyah\nBeyaz\nKýrmýzý\nMavi\nYeþil\nSarý\nPembe\nKahverengi\n[Geri]", "Seç", "Çýkýþ");
			}
			if(listitem == 5)
			{
			        ChangeVehicleColor(GetPlayerVehicleID(playerid),6,6);
			        PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
			        SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Aracýný Sarýya Boyadýn.");
			        ShowPlayerDialog(playerid, DIALOG_TUNE+2, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Renk", "Siyah\nBeyaz\nKýrmýzý\nMavi\nYeþil\nSarý\nPembe\nKahverengi\n[Geri]", "Seç", "Çýkýþ");

			}
			if(listitem == 6)
			{
			        
			        ChangeVehicleColor(GetPlayerVehicleID(playerid),126,126);
			        PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
			        SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Aracýný Pembeye Boyadýn.");
			        ShowPlayerDialog(playerid, DIALOG_TUNE+2, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Renk", "Siyah\nBeyaz\nKýrmýzý\nMavi\nYeþil\nSarý\nPembe\nKahverengi\n[Geri]", "Seç", "Çýkýþ");
			}
			if(listitem == 7)
			{
			        
			        ChangeVehicleColor(GetPlayerVehicleID(playerid),66,66);
			        PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
	          		SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Aracýný Kahverengiye Boyadýn.");
			        ShowPlayerDialog(playerid, DIALOG_TUNE+2, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Renk", "Siyah\nBeyaz\nKýrmýzý\nMavi\nYeþil\nSarý\nPembe\nKahverengi\n[Geri]", "Seç", "Çýkýþ");
            }
            if(listitem == 8)
			{
        		    ShowPlayerDialog(playerid, DIALOG_TUNE, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Araç Modifiye","Paint Job\nRenkler\nEgzostlar\nÖn Tampon\nArka Tampon\nÇatý\nSpoiler\nYan Etekler\nBullbar\nTekerlerkler\nAraç Ses Sistemi\n[Diðer Sayfa]", "Seç", "Çýkýþ");
            }
		}
   }
   	if(dialogid == DIALOG_TUNE+3)
   	{
		if(response)
		{
			if(listitem == 0)
			{
                if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 562 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 565 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 559 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 561 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 560)
		        {
		            
		            if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 562)
		            {
		            	AddVehicleComponent(GetPlayerVehicleID(playerid),1034);
		            	PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
		            	SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch Alien egzostu Elegy'ye baþarýyla ekledin.");
		            	ShowPlayerDialog(playerid, DIALOG_TUNE+3, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Egzost", "Wheel Arch Alien Egzost\nWheel Arch X-Flow Egzost\nLocos Low Chromer Egzost\nLocos Low Slamin Egzost\n[Geri]", "Seç", "Çýkýþ");
					}else
					if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 565)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1046);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch Alien egzostu Flash'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+3, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Egzost", "Wheel Arch Alien Egzost\nWheel Arch X-Flow Egzost\nLocos Low Chromer Egzost\nLocos Low Slamin Egzost\n[Geri]", "Seç", "Çýkýþ");
					}else
					if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 559)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1065);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch Alien egzostu Jester'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+3, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Egzost", "Wheel Arch Alien Egzost\nWheel Arch X-Flow Egzost\nLocos Low Chromer Egzost\nLocos Low Slamin Egzost\n[Geri]", "Seç", "Çýkýþ");
					}else
					if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 561)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1064);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch Alien egzostu Stratum'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+3, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Egzost", "Wheel Arch Alien Egzost\nWheel Arch X-Flow Egzost\nLocos Low Chromer Egzost\nLocos Low Slamin Egzost\n[Geri]", "Seç", "Çýkýþ");
					}else
					if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 560)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1028);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch Alien egzostu Sultan'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+3, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Egzost", "Wheel Arch Alien Egzost\nWheel Arch X-Flow Egzost\nLocos Low Chromer Egzost\nLocos Low Slamin Egzost\n[Geri]", "Seç", "Çýkýþ");
					}else
					if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 558)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1089);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
				 	    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch Alien egzostu Uranus'e baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+3, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Egzost", "Wheel Arch Alien Egzost\nWheel Arch X-Flow Egzost\nLocos Low Chromer Egzost\nLocos Low Slamin Egzost\n[Geri]", "Seç", "Çýkýþ");
  					}
    			}else
				{
				    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Bu parçayý yanlýzca Wheel Arch Angel tipi araçlara ekleyebilirsin!");
					ShowPlayerDialog(playerid, DIALOG_TUNE, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Araç Modifiye","Paint Job\nRenkler\nEgzostlar\nÖn Tampon\nArka Tampon\nÇatý\nSpoiler\nYan Etekler\nBullbar\nTekerlerkler\nAraç Ses Sistemi\n[Diðer Sayfa]", "Seç", "Çýkýþ");
     			}
            }
			if(listitem == 1)
            {
                if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 562 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 565 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 559 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 561 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 560)
                {
			        
			        if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 562)
			        {
			            AddVehicleComponent(GetPlayerVehicleID(playerid),1037);
			            PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
			            SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch X-Flow egzostu Elegy'ye baþarýyla ekledin.");
			            ShowPlayerDialog(playerid, DIALOG_TUNE+3, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Egzost", "Wheel Arch Alien Egzost\nWheel Arch X-Flow Egzost\nLocos Low Chromer Egzost\nLocos Low Slamin Egzost\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 565)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1045);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch X-Flow egzostu Flash'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+3, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Egzost", "Wheel Arch Alien Egzost\nWheel Arch X-Flow Egzost\nLocos Low Chromer Egzost\nLocos Low Slamin Egzost\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 559)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1066);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch X-Flow egzostu Jester'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+3, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Egzost", "Wheel Arch Alien Egzost\nWheel Arch X-Flow Egzost\nLocos Low Chromer Egzost\nLocos Low Slamin Egzost\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 561)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1059);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch X-Flow egzostu Stratum'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+3, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Egzost", "Wheel Arch Alien Egzost\nWheel Arch X-Flow Egzost\nLocos Low Chromer Egzost\nLocos Low Slamin Egzost\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 560)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1029);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch X-Flow egzostu Sultan'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+3, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Egzost", "Wheel Arch Alien Egzost\nWheel Arch X-Flow Egzost\nLocos Low Chromer Egzost\nLocos Low Slamin Egzost\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 558)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1092);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch X-Flow egzostu Uranus'e baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+3, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Egzost", "Wheel Arch Alien Egzost\nWheel Arch X-Flow Egzost\nLocos Low Chromer Egzost\nLocos Low Slamin Egzost\n[Geri]", "Seç", "Çýkýþ");
					}
				}else
				{
				    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Bu parçayý yanlýzca Wheel Arch Angel tipi araçlara ekleyebilirsin!");
					ShowPlayerDialog(playerid, DIALOG_TUNE, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Araç Modifiye","Paint Job\nRenkler\nEgzostlar\nÖn Tampon\nArka Tampon\nÇatý\nSpoiler\nYan Etekler\nBullbar\nTekerlerkler\nAraç Ses Sistemi\n[Diðer Sayfa]", "Seç", "Çýkýþ");
				}
            }
			if(listitem == 2)
            {
                if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 575 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 534 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 567 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 536 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 576 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 535)
			    {
			        
			        if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 575)
			        {
			            AddVehicleComponent(GetPlayerVehicleID(playerid),1044);
			            PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
		             	SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Locos Low Chromer egzostu Brodway'e baþarýyla ekledin.");
			            ShowPlayerDialog(playerid, DIALOG_TUNE+3, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Egzost", "Wheel Arch Alien Egzost\nWheel Arch X-Flow Egzost\nLocos Low Chromer Egzost\nLocos Low Slamin Egzost\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 534)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1126);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Locos Low Chromer egzostu Remington'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+3, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Egzost", "Wheel Arch Alien Egzost\nWheel Arch X-Flow Egzost\nLocos Low Chromer Egzost\nLocos Low Slamin Egzost\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 567)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1129);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
	                    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Locos Low Chromer egzostu Savanna'ya baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+3, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Egzost", "Wheel Arch Alien Egzost\nWheel Arch X-Flow Egzost\nLocos Low Chromer Egzost\nLocos Low Slamin Egzost\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 536)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1104);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Locos Low Chromer egzostu Blade'e baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+3, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Egzost", "Wheel Arch Alien Egzost\nWheel Arch X-Flow Egzost\nLocos Low Chromer Egzost\nLocos Low Slamin Egzost\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 535)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1113);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Locos Low Chromer egzostu Slamvan'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+3, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Egzost", "Wheel Arch Alien Egzost\nWheel Arch X-Flow Egzost\nLocos Low Chromer Egzost\nLocos Low Slamin Egzost\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 576)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1136);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					   	SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Locos Low Chromer egzostu Tornado'ya baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+3, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Egzost", "Wheel Arch Alien Egzost\nWheel Arch X-Flow Egzost\nLocos Low Chromer Egzost\nLocos Low Slamin Egzost\n[Geri]", "Seç", "Çýkýþ");
					}
				}else
				{
				    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Bu parçayý yanlýzca Locos Low Car tipi araçlara ekleyebilirsin!");
					ShowPlayerDialog(playerid, DIALOG_TUNE, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Araç Modifiye","Paint Job\nRenkler\nEgzostlar\nÖn Tampon\nArka Tampon\nÇatý\nSpoiler\nYan Etekler\nBullbar\nTekerlerkler\nAraç Ses Sistemi\n[Diðer Sayfa]", "Seç", "Çýkýþ");
				}
            }
			if(listitem == 3)
            {
                if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 575 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 534 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 567 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 536 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 576 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 535)
			    {
			        
			        if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 575)
			        {
			            AddVehicleComponent(GetPlayerVehicleID(playerid),1043);
			            PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
			            SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF} Locos Low Slamin egzostu Brodway'e baþarýyla ekledin.");
			            ShowPlayerDialog(playerid, DIALOG_TUNE+3, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Egzost", "Wheel Arch Alien Egzost\nWheel Arch X-Flow Egzost\nLocos Low Chromer Egzost\nLocos Low Slamin Egzost\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 534)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1127);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF} Locos Low Slamin egzostu Remington'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+3, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Egzost", "Wheel Arch Alien Egzost\nWheel Arch X-Flow Egzost\nLocos Low Chromer Egzost\nLocos Low Slamin Egzost\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 567)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1132);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF} Locos Low Slamin egzostu Savanna'ya baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+3, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Egzost", "Wheel Arch Alien Egzost\nWheel Arch X-Flow Egzost\nLocos Low Chromer Egzost\nLocos Low Slamin Egzost\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 536)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1105);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF} Locos Low Slamin egzostu Blade'e baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+3, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Egzost", "Wheel Arch Alien Egzost\nWheel Arch X-Flow Egzost\nLocos Low Chromer Egzost\nLocos Low Slamin Egzost\n[Geri]", "Seç", "Çýkýþ");
					}

					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 535)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1114);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF} Locos Low Slamin egzostu Slamvan'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+3, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Egzost", "Wheel Arch Alien Egzost\nWheel Arch X-Flow Egzost\nLocos Low Chromer Egzost\nLocos Low Slamin Egzost\n[Geri]", "Seç", "Çýkýþ");
					}

					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 576)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1135);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF} Locos Low Slamin egzostu Tornado'ya baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+3, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Egzost", "Wheel Arch Alien Egzost\nWheel Arch X-Flow Egzost\nLocos Low Chromer Egzost\nLocos Low Slamin Egzost\n[Geri]", "Seç", "Çýkýþ");
					}
     			}else
				{
				    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Bu parçayý yanlýzca Locos Low Car tipi araçlara ekleyebilirssin!");
					ShowPlayerDialog(playerid, DIALOG_TUNE, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Araç Modifiye","Paint Job\nRenkler\nEgzostlar\nÖn Tampon\nArka Tampon\nÇatý\nSpoiler\nYan Etekler\nBullbar\nTekerlerkler\nAraç Ses Sistemi\n[Diðer Sayfa]", "Seç", "Çýkýþ");
				}
            }
			if(listitem == 4)
            {
                 ShowPlayerDialog(playerid, DIALOG_TUNE, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Araç Modifiye","Paint Job\nRenkler\nEgzostlar\nÖn Tampon\nArka Tampon\nÇatý\nSpoiler\nYan Etekler\nBullbar\nTekerlerkler\nAraç Ses Sistemi\n[Diðer Sayfa]", "Seç", "Çýkýþ");
            }
	    }
   }
   	if(dialogid == DIALOG_TUNE+4)
   	{
		if(response)
		{
			if(listitem == 0)
			{
   				if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 562 ||
				   GetVehicleModel(GetPlayerVehicleID(playerid)) == 565 ||
				   GetVehicleModel(GetPlayerVehicleID(playerid)) == 559 ||
				   GetVehicleModel(GetPlayerVehicleID(playerid)) == 561 ||
				   GetVehicleModel(GetPlayerVehicleID(playerid)) == 560)
				   {
		            
		            if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 562)
		            {
		            	AddVehicleComponent(GetPlayerVehicleID(playerid),1171);
		            	PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
	              		SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch Alien ön tamponu Elegy'ye baþarýyla ekledin.");
		            	ShowPlayerDialog(playerid, DIALOG_TUNE+4, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Ön Tampon", "Wheel Arch Alien Tampon\nWheel Arch X-Flow Tampon\nLocos Low Chromer Tampon\nLocos Low Slamin Tampon\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 565)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1153);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch Alien ön tamponu Flash'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+4, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Ön Tampon", "Wheel Arch Alien Tampon\nWheel Arch X-Flow Tampon\nLocos Low Chromer Tampon\nLocos Low Slamin Tampon\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 559)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1160);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch Alien ön tamponu Jester'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+4, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Ön Tampon", "Wheel Arch Alien Tampon\nWheel Arch X-Flow Tampon\nLocos Low Chromer Tampon\nLocos Low Slamin Tampon\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 561)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1155);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch Alien ön tamponu Stratum'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+4, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Ön Tampon", "Wheel Arch Alien Tampon\nWheel Arch X-Flow Tampon\nLocos Low Chromer Tampon\nLocos Low Slamin Tampon\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 560)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1169);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch Alien ön tamponu Sultan'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+4, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Ön Tampon", "Wheel Arch Alien Tampon\nWheel Arch X-Flow Tampon\nLocos Low Chromer Tampon\nLocos Low Slamin Tampon\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 558)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1166);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
				 	    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch Alien ön tamponu Uranus'e baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+4, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Ön Tampon", "Wheel Arch Alien Tampon\nWheel Arch X-Flow Tampon\nLocos Low Chromer Tampon\nLocos Low Slamin Tampon\n[Geri]", "Seç", "Çýkýþ");
					}
				}else
				{
				    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Bu parçayý sadece Wheel Arch Angels tipi araçlara ekleyebilirsin!");
					ShowPlayerDialog(playerid, DIALOG_TUNE, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Araç Modifiye","Paint Job\nRenkler\nEgzostlar\nÖn Tampon\nArka Tampon\nÇatý\nSpoiler\nYan Etekler\nBullbar\nTekerlerkler\nAraç Ses Sistemi\n[Diðer Sayfa]", "Seç", "Çýkýþ");
				}
            }
			if(listitem == 1)
            {
          		   if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 562 ||
            	   GetVehicleModel(GetPlayerVehicleID(playerid)) == 565 ||
	               GetVehicleModel(GetPlayerVehicleID(playerid)) == 559 ||
	               GetVehicleModel(GetPlayerVehicleID(playerid)) == 561 ||
                   GetVehicleModel(GetPlayerVehicleID(playerid)) == 560)
		           {
			        
			        if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 562)
			        {
			            AddVehicleComponent(GetPlayerVehicleID(playerid),1172);
			            PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
			            SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch X-Flow ön tamponu Elegy'ye baþarýyla ekledin.");
			            ShowPlayerDialog(playerid, DIALOG_TUNE+4, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Ön Tampon", "Wheel Arch Alien Tampon\nWheel Arch X-Flow Tampon\nLocos Low Chromer Tampon\nLocos Low Slamin Tampon\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 565)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1152);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch X-Flow ön tamponu Flash'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+4, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Ön Tampon", "Wheel Arch Alien Tampon\nWheel Arch X-Flow Tampon\nLocos Low Chromer Tampon\nLocos Low Slamin Tampon\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 559)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1173);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch X-Flow ön tamponu Jester'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+4, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Ön Tampon", "Wheel Arch Alien Tampon\nWheel Arch X-Flow Tampon\nLocos Low Chromer Tampon\nLocos Low Slamin Tampon\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 561)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1157);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch X-Flow ön tamponu Stratum'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+4, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Ön Tampon", "Wheel Arch Alien Tampon\nWheel Arch X-Flow Tampon\nLocos Low Chromer Tampon\nLocos Low Slamin Tampon\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 560)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1170);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch X-Flow ön tamponu Sultan'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+4, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Ön Tampon", "Wheel Arch Alien Tampon\nWheel Arch X-Flow Tampon\nLocos Low Chromer Tampon\nLocos Low Slamin Tampon\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 558)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1165);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch X-Flow ön tamponu Uranus'e baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+4, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Ön Tampon", "Wheel Arch Alien Tampon\nWheel Arch X-Flow Tampon\nLocos Low Chromer Tampon\nLocos Low Slamin Tampon\n[Geri]", "Seç", "Çýkýþ");
					}
					}
					else
					{
				    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Bu parçayý sadece Wheel Arch Angels tipi araçlara ekleyebilirsin!");
					ShowPlayerDialog(playerid, DIALOG_TUNE, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Araç Modifiye","Paint Job\nRenkler\nEgzostlar\nÖn Tampon\nArka Tampon\nÇatý\nSpoiler\nYan Etekler\nBullbar\nTekerlerkler\nAraç Ses Sistemi\n[Diðer Sayfa]", "Seç", "Çýkýþ");
					}
		    }
			if(listitem == 2)
            {
                if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 575 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 534 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 567 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 536 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 576 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 535)
				{
			        
			        if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 575)
			        {
			            AddVehicleComponent(GetPlayerVehicleID(playerid),1174);
			            PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
			            SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Locos Low Chromer ön tamponu Brodway'e baþarýyla ekledin.");
			            ShowPlayerDialog(playerid, DIALOG_TUNE+4, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Ön Tampon", "Wheel Arch Alien Tampon\nWheel Arch X-Flow Tampon\nLocos Low Chromer Tampon\nLocos Low Slamin Tampon\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 534)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1179);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Locos Low Chromer ön tamponu Remington'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+4, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Ön Tampon", "Wheel Arch Alien Tampon\nWheel Arch X-Flow Tampon\nLocos Low Chromer Tampon\nLocos Low Slamin Tampon\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 567)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1189);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Locos Low Chromer ön tamponu Savanna'ya baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+4, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Ön Tampon", "Wheel Arch Alien Tampon\nWheel Arch X-Flow Tampon\nLocos Low Chromer Tampon\nLocos Low Slamin Tampon\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 536)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1182);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Locos Low Chromer ön tamponu Blade'e baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+4, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Ön Tampon", "Wheel Arch Alien Tampon\nWheel Arch X-Flow Tampon\nLocos Low Chromer Tampon\nLocos Low Slamin Tampon\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 535)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1115);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Locos Low Chromer ön tamponu Slamvan'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+4, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Ön Tampon", "Wheel Arch Alien Tampon\nWheel Arch X-Flow Tampon\nLocos Low Chromer Tampon\nLocos Low Slamin Tampon\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 576)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1191);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Locos Low Chromer ön tamponu Tornado'ya baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+4, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Ön Tampon", "Wheel Arch Alien Tampon\nWheel Arch X-Flow Tampon\nLocos Low Chromer Tampon\nLocos Low Slamin Tampon\n[Geri]", "Seç", "Çýkýþ");
					}
					}
					else
					{
				    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Bu parçayý yanlýzca Locos Low tipi araçlara ekleyebilirsin!");
					ShowPlayerDialog(playerid, DIALOG_TUNE, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Araç Modifiye","Paint Job\nRenkler\nEgzostlar\nÖn Tampon\nArka Tampon\nÇatý\nSpoiler\nYan Etekler\nBullbar\nTekerlerkler\nAraç Ses Sistemi\n[Diðer Sayfa]", "Seç", "Çýkýþ");
					}
			}
			if(listitem == 3)
            {
                if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 575 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 534 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 567 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 536 ||
	            GetVehicleModel(GetPlayerVehicleID(playerid)) == 576 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 576)
			    {
			        
			        if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 575)
			        {
			            AddVehicleComponent(GetPlayerVehicleID(playerid),1175);
			            PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
			            SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Locos Low Slamin ön tamponu Brodway'e baþarýyla ekledin.");
			            ShowPlayerDialog(playerid, DIALOG_TUNE+4, DIALOG_STYLE_LIST, "Ön Tampon", "Wheel Arch Alien Tampon\nWheel Arch X-Flow Tampon\nLocos Low Chromer Tampon\nLocos Low Slamin Tampon\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 534)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1185);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Locos Low Slamin ön tamponu Remington'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+4, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Ön Tampon", "Wheel Arch Alien Tampon\nWheel Arch X-Flow Tampon\nLocos Low Chromer Tampon\nLocos Low Slamin Tampon\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 567)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1188);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Locos Low Slamin ön tamponu Savanna'ya baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+4, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Ön Tampon", "Wheel Arch Alien Tampon\nWheel Arch X-Flow Tampon\nLocos Low Chromer Tampon\nLocos Low Slamin Tampon\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 536)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1181);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Locos Low Slamin ön tamponu Blade'e baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+4, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Ön Tampon", "Wheel Arch Alien Tampon\nWheel Arch X-Flow Tampon\nLocos Low Chromer Tampon\nLocos Low Slamin Tampon\n[Geri]", "Seç", "Çýkýþ");
					}
                    else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 535)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1116);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Locos Low Slamin ön tamponu Slamvan'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+4, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Ön Tampon", "Wheel Arch Alien Tampon\nWheel Arch X-Flow Tampon\nLocos Low Chromer Tampon\nLocos Low Slamin Tampon\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 576)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1190);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Locos Low Slamin ön tamponu Tornado'ya baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+4, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Ön Tampon", "Wheel Arch Alien Tampon\nWheel Arch X-Flow Tampon\nLocos Low Chromer Tampon\nLocos Low Slamin Tampon\n[Geri]", "Seç", "Çýkýþ");
					}
					}
					else
					{
				    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Bu parçayý sadece Locos Low tipi araçlara ekleyebilirsin!");
					ShowPlayerDialog(playerid, DIALOG_TUNE, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Araç Modifiye","Paint Job\nRenkler\nEgzostlar\nÖn Tampon\nArka Tampon\nÇatý\nSpoiler\nYan Etekler\nBullbar\nTekerlerkler\nAraç Ses Sistemi\n[Diðer Sayfa]", "Seç", "Çýkýþ");
                    }
            }
			if(listitem == 4)
            {
                 ShowPlayerDialog(playerid, DIALOG_TUNE, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Araç Modifiye","Paint Job\nRenkler\nEgzostlar\nÖn Tampon\nArka Tampon\nÇatý\nSpoiler\nYan Etekler\nBullbar\nTekerlerkler\nAraç Ses Sistemi\n[Diðer Sayfa]", "Seç", "Çýkýþ");
            }
        }
   }

	if(dialogid == DIALOG_TUNE+5)
	{
		if(response)
		{
			if(listitem == 0)
			{
                if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 562 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 565 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 559 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 561 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 560)
		        {
                    
		            if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 562)
		            {
		            	AddVehicleComponent(GetPlayerVehicleID(playerid),1149);
		            	PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
	              		SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch Alien arka tamponu Elegy'ye baþarýyla ekledin.");
		            	ShowPlayerDialog(playerid, DIALOG_TUNE+5, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Arka Tampon", "Wheel Arch Alien Tampon\nWheel Arch X-Flow Tampon\nLocos Low Chromer Tampon\nLocos Low Slamin Tampon\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 565)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1150);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch Alien arka tamponu Flssh'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+5, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Arka Tampon", "Wheel Arch Alien Tampon\nWheel Arch X-Flow Tampon\nLocos Low Chromer Tampon\nLocos Low Slamin Tampon\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 559)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1159);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch Alien arka tamponu Jester'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+5, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Arka Tampon", "Wheel Arch Alien Tampon\nWheel Arch X-Flow Tampon\nLocos Low Chromer Tampon\nLocos Low Slamin Tampon\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 561)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1154);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch Alien arka tamponu Stratum'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+5, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Arka Tampon", "Wheel Arch Alien Tampon\nWheel Arch X-Flow Tampon\nLocos Low Chromer Tampon\nLocos Low Slamin Tampon\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 560)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1141);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch Alien arka tamponu Sultan'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+5, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Arka Tampon", "Wheel Arch Alien Tampon\nWheel Arch X-Flow Tampon\nLocos Low Chromer Tampon\nLocos Low Slamin Tampon\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 558)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1168);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
				 	    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch Alien arka tamponu Uranus'e baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+5, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Arka Tampon", "Wheel Arch Alien Tampon\nWheel Arch X-Flow Tampon\nLocos Low Chromer Tampon\nLocos Low Slamin Tampon\n[Geri]", "Seç", "Çýkýþ");
					}
					}
					else
					{
				    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Bu parçayý yanlýzca Wheel Arch Angels tipi araçlara ekleyebilirsin!");
					ShowPlayerDialog(playerid, DIALOG_TUNE, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Araç Modifiye","Paint Job\nRenkler\nEgzostlar\nÖn Tampon\nArka Tampon\nÇatý\nSpoiler\nYan Etekler\nBullbar\nTekerlerkler\nAraç Ses Sistemi\n[Diðer Sayfa]", "Seç", "Çýkýþ");
					}
            }
			if(listitem == 1)
            {
                if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 562 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 565 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 559 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 561 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 560)
		        {

					
			        if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 562)
			        {
			            AddVehicleComponent(GetPlayerVehicleID(playerid),1148);
			            PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
			            SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch  X-Flow arka tamponu Elegy'ye baþarýyla ekledin.");
		                ShowPlayerDialog(playerid, DIALOG_TUNE+5, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Arka Tampon", "Wheel Arch Alien Tampon\nWheel Arch X-Flow Tampon\nLocos Low Chromer Tampon\nLocos Low Slamin Tampon\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 565)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1151);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch  X-Flow arka tamponu Flash'a baþarýyla ekledin.");
				        ShowPlayerDialog(playerid, DIALOG_TUNE+5, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Arka Tampon", "Wheel Arch Alien Tampon\nWheel Arch X-Flow Tampon\nLocos Low Chromer Tampon\nLocos Low Slamin Tampon\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 559)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1161);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch  X-Flow arka tamponu Jester'a baþarýyla ekledin.");
				        ShowPlayerDialog(playerid, DIALOG_TUNE+5, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Arka Tampon", "Wheel Arch Alien Tampon\nWheel Arch X-Flow Tampon\nLocos Low Chromer Tampon\nLocos Low Slamin Tampon\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 561)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1156);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch  X-Flow arka tamponu Stratum'a baþarýyla ekledin.");
				        ShowPlayerDialog(playerid, DIALOG_TUNE+5, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Arka Tampon", "Wheel Arch Alien Tampon\nWheel Arch X-Flow Tampon\nLocos Low Chromer Tampon\nLocos Low Slamin Tampon\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 560)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1140);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch  X-Flow arka tamponu Sultan'a baþarýyla ekledin.");
				        ShowPlayerDialog(playerid, DIALOG_TUNE+5, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Arka Tampon", "Wheel Arch Alien Tampon\nWheel Arch X-Flow Tampon\nLocos Low Chromer Tampon\nLocos Low Slamin Tampon\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 558)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1167);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch  X-Flow arka tamponu Uranus'e baþarýyla ekledin.");
				        ShowPlayerDialog(playerid, DIALOG_TUNE+5, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Arka Tampon", "Wheel Arch Alien Tampon\nWheel Arch X-Flow Tampon\nLocos Low Chromer Tampon\nLocos Low Slamin Tampon\n[Geri]", "Seç", "Çýkýþ");
					}
					}
					else
					{
				    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Bu parçayý yanlýzca Wheel Arch Angels tipi araçlara ekleyebilirsin!");
					ShowPlayerDialog(playerid, DIALOG_TUNE, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Araç Modifiye","Paint Job\nRenkler\nEgzostlar\nÖn Tampon\nArka Tampon\nÇatý\nSpoiler\nYan Etekler\nBullbar\nTekerlerkler\nAraç Ses Sistemi\n[Diðer Sayfa]", "Seç", "Çýkýþ");
					}
            }
			if(listitem == 2)
            {
                if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 575 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 534 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 567 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 536 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 576 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 535)
			    {
			        
			        if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 575)
			        {
			            AddVehicleComponent(GetPlayerVehicleID(playerid),1176);
			            PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
			            SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Locos Low Chromer arka tamponu Brodway'e baþarýyla ekledin.");
			            ShowPlayerDialog(playerid, DIALOG_TUNE+5, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Arka Tampon", "Wheel Arch Alien Tampon\nWheel Arch X-Flow Tampon\nLocos Low Chromer Tampon\nLocos Low Slamin Tampon\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 534)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1180);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Locos Low Chromer arka tamponu Remington'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+5, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Arka Tampon", "Wheel Arch Alien Tampon\nWheel Arch X-Flow Tampon\nLocos Low Chromer Tampon\nLocos Low Slamin Tampon\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 567)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1187);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Locos Low Chromer arka tamponu Savanna'ya baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+5, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Arka Tampon", "Wheel Arch Alien Tampon\nWheel Arch X-Flow Tampon\nLocos Low Chromer Tampon\nLocos Low Slamin Tampon\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 536)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1184);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Locos Low Chromer arka tamponu Blade'e baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+5, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Arka Tampon", "Wheel Arch Alien Tampon\nWheel Arch X-Flow Tampon\nLocos Low Chromer Tampon\nLocos Low Slamin Tampon\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 535)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1109);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Locos Low Chromer arka tamponu Slamvan'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+5, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Arka Tampon", "Wheel Arch Alien Tampon\nWheel Arch X-Flow Tampon\nLocos Low Chromer Tampon\nLocos Low Slamin Tampon\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 576)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1192);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Locos Low Chromer arka tamponu Tornado'ya baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+5, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Arka Tampon", "Wheel Arch Alien Tampon\nWheel Arch X-Flow Tampon\nLocos Low Chromer Tampon\nLocos Low Slamin Tampon\n[Geri]", "Seç", "Çýkýþ");
					}
					}
					else
					{
				    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Bu parçayý yanlýzca Locos Low tipi araçlara ekleyebilirsin!");
					ShowPlayerDialog(playerid, DIALOG_TUNE, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Araç Modifiye","Paint Job\nRenkler\nEgzostlar\nÖn Tampon\nArka Tampon\nÇatý\nSpoiler\nYan Etekler\nBullbar\nTekerlerkler\nAraç Ses Sistemi\n[Diðer Sayfa]", "Seç", "Çýkýþ");
					}
            }
			if(listitem == 3)
            {
                if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 575 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 534 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 567 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 536 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 576 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 535)
			    {
			        
			        if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 575)
			        {
			            AddVehicleComponent(GetPlayerVehicleID(playerid),1177);
			            PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
			            SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Locos Low Slamin arka tamponu Brodway'e baþarýyla ekledin.");
			            ShowPlayerDialog(playerid, DIALOG_TUNE+5, DIALOG_STYLE_LIST, "Arka Tampon", "Wheel Arch Alien Tampon\nWheel Arch X-Flow Tampon\nLocos Low Chromer Tampon\nLocos Low Slamin Tampon\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 534)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1178);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Locos Low Slamin arka tamponu Remington'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+5, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Arka Tampon", "Wheel Arch Alien Tampon\nWheel Arch X-Flow Tampon\nLocos Low Chromer Tampon\nLocos Low Slamin Tampon\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 567)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1186);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Locos Low Slamin arka tamponu Savanna'ya baþarýyla ekledin..");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+5, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Arka Tampon", "Wheel Arch Alien Tampon\nWheel Arch X-Flow Tampon\nLocos Low Chromer Tampon\nLocos Low Slamin Tampon\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 536)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1183);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Locos Low Slamin arka tamponu Blade'e baþarýyla ekledin..");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+5, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Arka Tampon", "Wheel Arch Alien Tampon\nWheel Arch X-Flow Tampon\nLocos Low Chromer Tampon\nLocos Low Slamin Tampon\n[Geri]", "Seç", "Çýkýþ");
					}

					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 535)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1110);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Locos Low Slamin arka tamponu Slamvan'a baþarýyla ekledin..");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+5, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Arka Tampon", "Wheel Arch Alien Tampon\nWheel Arch X-Flow Tampon\nLocos Low Chromer Tampon\nLocos Low Slamin Tampon\n[Geri]", "Seç", "Çýkýþ");
					}

					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 576)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1193);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Locos Low Slamin arka tamponu Tornado'ya baþarýyla ekledin..");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+5, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Arka Tampon", "Wheel Arch Alien Tampon\nWheel Arch X-Flow Tampon\nLocos Low Chromer Tampon\nLocos Low Slamin Tampon\n[Geri]", "Seç", "Çýkýþ");
					}
                    }
					else
					{
				    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Bu parçayý yanlýzca Locos Low tipi araçlara ekleyebilirsin!");
					ShowPlayerDialog(playerid, DIALOG_TUNE, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Araç Modifiye","Paint Job\nRenkler\nEgzostlar\nÖn Tampon\nArka Tampon\nÇatý\nSpoiler\nYan Etekler\nBullbar\nTekerlerkler\nAraç Ses Sistemi\n[Diðer Sayfa]", "Seç", "Çýkýþ");
					}
            }
            if(listitem == 4)
            {
                 ShowPlayerDialog(playerid, DIALOG_TUNE, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Araç Modifiye","Paint Job\nRenkler\nEgzostlar\nÖn Tampon\nArka Tampon\nÇatý\nSpoiler\nYan Etekler\nBullbar\nTekerlerkler\nAraç Ses Sistemi\n[Diðer Sayfa]", "Seç", "Çýkýþ");
            }
        }
   }

   	if(dialogid == DIALOG_TUNE+6)
   	{
		if(response)
		{
			if(listitem == 0)
			{
                if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 562 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 565 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 559 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 561 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 560)
		        {

		            
		            if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 562)
		            {
		            	AddVehicleComponent(GetPlayerVehicleID(playerid),1035);
		            	PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
	              		SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch Alien çatýyý Elegy'ye baþarýyla ekledin.");
		            	ShowPlayerDialog(playerid, DIALOG_TUNE+6, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Çatý", "Wheel Arch Alien Çatý\nWheel Arch X-Flow Çatý\nLocos Low Hardtop Çatý\nLocos Low Softtop Çatý\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 565)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1054);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch Alien çatýyý Flash'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+6, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Çatý", "Wheel Arch Alien Çatý\nWheel Arch X-Flow Çatý\nLocos Low Hardtop Çatý\nLocos Low Softtop Çatý\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 559)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1067);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch Alien çatýyý Jester'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+6, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Çatý", "Wheel Arch Alien Çatý\nWheel Arch X-Flow Çatý\nLocos Low Hardtop Çatý\nLocos Low Softtop Çatý\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 561)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1055);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch Alien çatýyý Stratum'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+6, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Çatý", "Wheel Arch Alien Çatý\nWheel Arch X-Flow Çatý\nLocos Low Hardtop Çatý\nLocos Low Softtop Çatý\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 560)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1032);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch Alien çatýyý Sultan'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+6, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Çatý", "Wheel Arch Alien Çatý\nWheel Arch X-Flow Çatý\nLocos Low Hardtop Çatý\nLocos Low Softtop Çatý\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 558)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1088);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
				 	    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch Alien çatýyý Uranus'e baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+6, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Çatý", "Wheel Arch Alien Çatý\nWheel Arch X-Flow Çatý\nLocos Low Hardtop Çatý\nLocos Low Softtop Çatý\n[Geri]", "Seç", "Çýkýþ");
					}
					}
					else
					{
				    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Bu parçayý yanlýzca Wheel Arch Angels tipi araçlara ekleyebilirsin!");
					ShowPlayerDialog(playerid, DIALOG_TUNE, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Araç Modifiye","Paint Job\nRenkler\nEgzostlar\nÖn Tampon\nArka Tampon\nÇatý\nSpoiler\nYan Etekler\nBullbar\nTekerlerkler\nAraç Ses Sistemi\n[Diðer Sayfa]", "Seç", "Çýkýþ");
					}
            }
	        if(listitem == 1)
			{
                if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 562 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 565 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 559 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 561 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 560)
		        {
			        if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 562)
			        {
			            AddVehicleComponent(GetPlayerVehicleID(playerid),1035);
			            PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
			            SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch X-Flow çatýyý Elegy'ye baþarýyla ekledin.");
			            ShowPlayerDialog(playerid, DIALOG_TUNE+6, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Çatý", "Wheel Arch Alien Çatý\nWheel Arch X-Flow Çatý\nLocos Low Hardtop Çatý\nLocos Low Softtop Çatý\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 565)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1053);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch X-Flow çatýyý Flash'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+6, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Çatý", "Wheel Arch Alien Çatý\nWheel Arch X-Flow Çatý\nLocos Low Hardtop Çatý\nLocos Low Softtop Çatý\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 559)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1068);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch X-Flow çatýyý Jester'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+6, DIALOG_STYLE_LIST, "Çatý", "Wheel Arch Alien Çatý\nWheel Arch X-Flow Çatý\nLocos Low Hardtop Çatý\nLocos Low Softtop Çatý\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 561)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1061);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch X-Flow çatýyý Stratum'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+6, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Çatý", "Wheel Arch Alien Çatý\nWheel Arch X-Flow Çatý\nLocos Low Hardtop Çatý\nLocos Low Softtop Çatý\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 560)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1033);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch X-Flow çatýyý Sultan'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+6, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Çatý", "Wheel Arch Alien Çatý\nWheel Arch X-Flow Çatý\nLocos Low Hardtop Çatý\nLocos Low Softtop Çatý\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 558)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1091);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch X-Flow çatýyý Uranus'e baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+6, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Çatý", "Wheel Arch Alien Çatý\nWheel Arch X-Flow Çatý\nLocos Low Hardtop Çatý\nLocos Low Softtop Çatý\n[Geri]", "Seç", "Çýkýþ");
					}
					}
					else
					{
				    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Bu parçayý yanlýzca Wheel Arch Angels tipi araçlara ekleyebilirsin!");
					ShowPlayerDialog(playerid, DIALOG_TUNE, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Araç Modifiye","Paint Job\nRenkler\nEgzostlar\nÖn Tampon\nArka Tampon\nÇatý\nSpoiler\nYan Etekler\nBullbar\nTekerlerkler\nAraç Ses Sistemi\n[Diðer Sayfa]", "Seç", "Çýkýþ");
					}
			}
			if(listitem == 2)
			{
                if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 567 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 536)
			    {
			        
			        if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 567)
			        {
			            AddVehicleComponent(GetPlayerVehicleID(playerid),1130);
			            PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
			            SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Locos Low Hardtop çatýyý Brodway'e baþarýyla ekledin.");
			            ShowPlayerDialog(playerid, DIALOG_TUNE+6, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Çatý", "Wheel Arch Alien Çatý\nWheel Arch X-Flow Çatý\nLocos Low Hardtop Çatý\nLocos Low Softtop Çatý\n[Geri]", "Seç", "Çýkýþ");
					}
	   				else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 536)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1128);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Locos Low Hardtop çatýyý Blade'e baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+6, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Çatý", "Wheel Arch Alien Çatý\nWheel Arch X-Flow Çatý\nLocos Low Hardtop Çatý\nLocos Low Softtop Çatý\n[Geri]", "Seç", "Çýkýþ");
					}
					}
					else
					{
				    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Bu parçayý yanlýzca Locos Low tipi Savanna ve Blade'e ekleyebilirsin!");
					ShowPlayerDialog(playerid, DIALOG_TUNE, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Araç Modifiye","Paint Job\nRenkler\nEgzostlar\nÖn Tampon\nArka Tampon\nÇatý\nSpoiler\nYan Etekler\nBullbar\nTekerlerkler\nAraç Ses Sistemi\n[Diðer Sayfa]", "Seç", "Çýkýþ");
					}
            }
		    if(listitem == 3)
			{
                 if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 567 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 536)
			    {
			        
			        if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 567)
			        {
			            AddVehicleComponent(GetPlayerVehicleID(playerid),1131);
			            PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
			            SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Locos Low Softtop çatýyý Brodway'e baþarýyla ekledin.");
			            ShowPlayerDialog(playerid, DIALOG_TUNE+6, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Çatý", "Wheel Arch Alien Çatý\nWheel Arch X-Flow Çatý\nLocos Low Hardtop Çatý\nLocos Low Softtop Çatý\n[Geri]", "Seç", "Çýkýþ");
					}
	   				else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 536)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1103);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Locos Low Softtop çatýyý Blade'e baþarýyla ekledin.");
                        ShowPlayerDialog(playerid, DIALOG_TUNE+6, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Çatý", "Wheel Arch Alien Çatý\nWheel Arch X-Flow Çatý\nLocos Low Hardtop Çatý\nLocos Low Softtop Çatý\n[Geri]", "Seç", "Çýkýþ");
					}
					}
					else
					{
   					SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Bu parçayý yanlýzca Locos Low tipi Savanna ve Blade'e ekleyebilirsin!");
					ShowPlayerDialog(playerid, DIALOG_TUNE, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Araç Modifiye","Paint Job\nRenkler\nEgzostlar\nÖn Tampon\nArka Tampon\nÇatý\nSpoiler\nYan Etekler\nBullbar\nTekerlerkler\nAraç Ses Sistemi\n[Diðer Sayfa]", "Seç", "Çýkýþ");
					}
            }
            if(listitem == 4)
            {
                 ShowPlayerDialog(playerid, DIALOG_TUNE, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Araç Modifiye","Paint Job\nRenkler\nEgzostlar\nÖn Tampon\nArka Tampon\nÇatý\nSpoiler\nYan Etekler\nBullbar\nTekerlerkler\nAraç Ses Sistemi\n[Diðer Sayfa]", "Seç", "Çýkýþ");
            }
	     }
   }

   	if(dialogid == DIALOG_TUNE+7)
   	{
		if(response)
		{
			if(listitem == 0)
			{
                if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 562 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 565 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 559 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 561 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 560)
		        {

		            
		            if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 562)
		            {
		            	AddVehicleComponent(GetPlayerVehicleID(playerid),1147);
		            	PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
	              		SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch Alien Spoiler'ý Elegy'ye baþarýyla ekledin.");
		            	ShowPlayerDialog(playerid, DIALOG_TUNE+7, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Spoiler", "Alien Spoiler\nX-Flow Spoiler\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 565)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1049);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch Alien Spoiler'ý Flash'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+7, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Spoiler", "Alien Spoiler\nX-Flow Spoiler\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 559)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1162);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch Alien Spoiler'ý Jester'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+7, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Spoiler", "Alien Spoiler\nX-Flow Spoiler\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 561)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1158);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch Alien Spoiler'ý Stratum'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+7, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Spoiler", "Alien Spoiler\nX-Flow Spoiler\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 560)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1138);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch Alien Spoiler'ý Sultan'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+7, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Spoiler", "Alien Spoiler\nX-Flow Spoiler\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 558)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1164);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
				 	    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch Alien Spoiler'ý Uranus'e baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+7, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Spoiler", "Alien Spoiler\nX-Flow Spoiler\n[Geri]", "Seç", "Çýkýþ");
					}
					}
					else
					{
				    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Bu parçayý yanlýzca Wheel Arch Angels tipi araçlara ekleyebilirsin!");
					ShowPlayerDialog(playerid, DIALOG_TUNE, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Araç Modifiye","Paint Job\nRenkler\nEgzostlar\nÖn Tampon\nArka Tampon\nÇatý\nSpoiler\nYan Etekler\nBullbar\nTekerlerkler\nAraç Ses Sistemi\n[Diðer Sayfa]", "Seç", "Çýkýþ");
					}
    	    }
            if(listitem == 1)
			{
                if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 562 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 565 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 559 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 561 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 560)
		        {
                    
			        if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 562)
			        {
			            AddVehicleComponent(GetPlayerVehicleID(playerid),1146);
			            PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
			            SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch X-Flow Spoiler'ý Elegy'ye baþarýyla ekledin.");
			            ShowPlayerDialog(playerid, DIALOG_TUNE+7, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Spoiler", "Alien Spoiler\nX-Flow Spoiler\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 565)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1150);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch X-Flow Spoiler'ý Flash'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+7, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Spoiler", "Alien Spoiler\nX-Flow Spoiler\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 559)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1158);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch X-Flow Spoiler'ý Jester'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+7, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Spoiler", "Alien Spoiler\nX-Flow Spoiler\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 561)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1060);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch X-Flow Spoiler'ý Stratum'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+7, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Spoiler", "Alien Spoiler\nX-Flow Spoiler\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 560)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1139);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch X-Flow Spoiler'ý Sultan'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+7, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Spoiler", "Alien Spoiler\nX-Flow Spoiler\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 558)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1163);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch X-Flow Spoiler'ý Uranus'e baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+7, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Spoiler", "Alien Spoiler\nX-Flow Spoiler\n[Geri]", "Seç", "Çýkýþ");
					}
					}
					else
					{
				    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Bu parçayý yanlýzca X-Flow Arch Angels tipi araçlara ekleyebilirsin!");
					ShowPlayerDialog(playerid, DIALOG_TUNE, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Araç Modifiye","Paint Job\nRenkler\nEgzostlar\nÖn Tampon\nArka Tampon\nÇatý\nSpoiler\nYan Etekler\nBullbar\nTekerlerkler\nAraç Ses Sistemi\n[Diðer Sayfa]", "Seç", "Çýkýþ");
					}
            }
            if(listitem == 2)
            {
                 ShowPlayerDialog(playerid, DIALOG_TUNE, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Araç Modifiye","Paint Job\nRenkler\nEgzostlar\nÖn Tampon\nArka Tampon\nÇatý\nSpoiler\nYan Etekler\nBullbar\nTekerlerkler\nAraç Ses Sistemi\n[Diðer Sayfa]", "Seç", "Çýkýþ");
            }
	   	 }
   }

   	if(dialogid == DIALOG_TUNE+8)
   	{
		if(response)
		{
			if(listitem == 0)
			{
                if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 562 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 565 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 559 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 561 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 560)
		        {

		            
		            if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 562)
		            {
		            	AddVehicleComponent(GetPlayerVehicleID(playerid),1036);
		            	AddVehicleComponent(GetPlayerVehicleID(playerid),1040);
		            	PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
	              		SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch Alien Yan Eteði Elegy'ye baþarýyla ekledin.");
		            	ShowPlayerDialog(playerid, DIALOG_TUNE+8, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Yan Etek", "Wheel Arch Alien Yan Etek\nWheel Arch X-Flow Yan Etek\nLocos Low Chrome Strip\nLocos Low Chrome Flames\nLocos Low Chrome Arches\nLocos Low Chrome Trim\nLocos Low Wheelcovers\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 565)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1047);
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1051);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch Alien Yan Eteði Flash'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+8, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Yan Etek", "Wheel Arch Alien Yan Etek\nWheel Arch X-Flow Yan Etek\nLocos Low Chrome Strip\nLocos Low Chrome Flames\nLocos Low Chrome Arches\nLocos Low Chrome Trim\nLocos Low Wheelcovers\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 559)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1069);
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1071);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch Alien Yan Eteði Jester'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+8, DIALOG_STYLE_LIST, "Yan Etek", "Wheel Arch Alien Yan Etek\nWheel Arch X-Flow Yan Etek\nLocos Low Chrome Strip\nLocos Low Chrome Flames\nLocos Low Chrome Arches\nLocos Low Chrome Trim\nLocos Low Wheelcovers\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 561)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1056);
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1062);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch Alien Yan Eteði Stratum'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+8, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Yan Etek", "Wheel Arch Alien Yan Etek\nWheel Arch X-Flow Yan Etek\nLocos Low Chrome Strip\nLocos Low Chrome Flames\nLocos Low Chrome Arches\nLocos Low Chrome Trim\nLocos Low Wheelcovers\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 560)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1026);
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1027);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch Alien Yan Eteði Sultan'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+8, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Yan Etek", "Wheel Arch Alien Yan Etek\nWheel Arch X-Flow Yan Etek\nLocos Low Chrome Strip\nLocos Low Chrome Flames\nLocos Low Chrome Arches\nLocos Low Chrome Trim\nLocos Low Wheelcovers\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 558)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1090);
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1094);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
				 	    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch Alien Yan Eteði Uranus'e baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+8, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Yan Etek", "Wheel Arch Alien Yan Etek\nWheel Arch X-Flow Yan Etek\nLocos Low Chrome Strip\nLocos Low Chrome Flames\nLocos Low Chrome Arches\nLocos Low Chrome Trim\nLocos Low Wheelcovers\n[Geri]", "Seç", "Çýkýþ");
					}
					}
					else
					{
				    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Bu parçayý yanlýzca Wheel Arch Angels tipi araçlara ekleyebilirsin!");
					ShowPlayerDialog(playerid, DIALOG_TUNE, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Araç Modifiye","Paint Job\nRenkler\nEgzostlar\nÖn Tampon\nArka Tampon\nÇatý\nSpoiler\nYan Etekler\nBullbar\nTekerlerkler\nAraç Ses Sistemi\n[Diðer Sayfa]", "Seç", "Çýkýþ");
					}
		    }
	   	    if(listitem == 1)
			{
                if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 562 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 565 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 559 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 561 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 560)
		        {
				    
			        if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 562)
			        {
			            AddVehicleComponent(GetPlayerVehicleID(playerid),1039);
			            AddVehicleComponent(GetPlayerVehicleID(playerid),1041);
			            PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
			            SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch X-Flow Yan Eteði Elegy'ye baþarýyla ekledin.");
			            ShowPlayerDialog(playerid, DIALOG_TUNE+8, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Yan Etek", "Wheel Arch Alien Yan Etek\nWheel Arch X-Flow Yan Etek\nLocos Low Chrome Strip\nLocos Low Chrome Flames\nLocos Low Chrome Arches\nLocos Low Chrome Trim\nLocos Low Wheelcovers\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 565)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1048);
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1052);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch X-Flow Yan Eteði Flash'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+8, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Yan Etek", "Wheel Arch Alien Yan Etek\nWheel Arch X-Flow Yan Etek\nLocos Low Chrome Strip\nLocos Low Chrome Flames\nLocos Low Chrome Arches\nLocos Low Chrome Trim\nLocos Low Wheelcovers\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 559)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1070);
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1072);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch X-Flow Yan Eteði Jester'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+8, DIALOG_STYLE_LIST, "Yan Etek", "Wheel Arch Alien Yan Etek\nWheel Arch X-Flow Yan Etek\nLocos Low Chrome Strip\nLocos Low Chrome Flames\nLocos Low Chrome Arches\nLocos Low Chrome Trim\nLocos Low Wheelcovers\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 561)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1057);
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1063);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch X-Flow Yan Eteði Stratum'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+8, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Yan Etek", "Wheel Arch Alien Yan Etek\nWheel Arch X-Flow Yan Etek\nLocos Low Chrome Strip\nLocos Low Chrome Flames\nLocos Low Chrome Arches\nLocos Low Chrome Trim\nLocos Low Wheelcovers\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 560)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1031);
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1030);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch X-Flow Yan Eteði Sultan'a baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+8, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Yan Etek", "Wheel Arch Alien Yan Etek\nWheel Arch X-Flow Yan Etek\nLocos Low Chrome Strip\nLocos Low Chrome Flames\nLocos Low Chrome Arches\nLocos Low Chrome Trim\nLocos Low Wheelcovers\n[Geri]", "Seç", "Çýkýþ");
					}
					else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 558)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1093);
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1095);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wheel Arch X-Flow Yan Eteði Uranus'e baþarýyla ekledin.");
					    ShowPlayerDialog(playerid, DIALOG_TUNE+8, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Yan Etek", "Wheel Arch Alien Yan Etek\nWheel Arch X-Flow Yan Etek\nLocos Low Chrome Strip\nLocos Low Chrome Flames\nLocos Low Chrome Arches\nLocos Low Chrome Trim\nLocos Low Wheelcovers\n[Geri]", "Seç", "Çýkýþ");
					}
					}
					else
					{
				    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Bu parçayý yanlýzca Wheel Arch Angels tipi araçlara ekleyebilirsin!");
					ShowPlayerDialog(playerid, DIALOG_TUNE, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Araç Modifiye","Paint Job\nRenkler\nEgzostlar\nÖn Tampon\nArka Tampon\nÇatý\nSpoiler\nYan Etekler\nBullbar\nTekerlerkler\nAraç Ses Sistemi\n[Diðer Sayfa]", "Seç", "Çýkýþ");
					}
		    }
		    if(listitem == 2)
			{
                 if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 575 ||
	               GetVehicleModel(GetPlayerVehicleID(playerid)) == 536 ||
	               GetVehicleModel(GetPlayerVehicleID(playerid)) == 576 ||
		 	       GetVehicleModel(GetPlayerVehicleID(playerid)) == 567)
                   {
			        
			        if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 575)
			        {
	       		        AddVehicleComponent(GetPlayerVehicleID(playerid),1042);
	       		        AddVehicleComponent(GetPlayerVehicleID(playerid),1099);
	       		        PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
			            SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Locos Low Chrome Strip Yan Eteði Brodway'e baþarýyla ekledin.");
			            ShowPlayerDialog(playerid, DIALOG_TUNE+8, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Yan Etek", "Wheel Arch Alien Yan Etek\nWheel Arch X-Flow Yan Etek\nLocos Low Chrome Strip\nLocos Low Chrome Flames\nLocos Low Chrome Arches\nLocos Low Chrome Trim\nLocos Low Wheelcovers\n[Geri]", "Seç", "Çýkýþ");
					}
	   				else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 567)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1102);
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1133);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Locos Low Chrome Strip Yan Eteði Savanna'ya baþarýyla ekledin.");
	    		        ShowPlayerDialog(playerid, DIALOG_TUNE+8, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Yan Etek", "Wheel Arch Alien Yan Etek\nWheel Arch X-Flow Yan Etek\nLocos Low Chrome Strip\nLocos Low Chrome Flames\nLocos Low Chrome Arches\nLocos Low Chrome Trim\nLocos Low Wheelcovers\n[Geri]", "Seç", "Çýkýþ");
	                }
	                else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 576)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1134);
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1137);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Locos Low Chrome Strip Yan Eteði Tornado'ya baþarýyla ekledin.");
	    		        ShowPlayerDialog(playerid, DIALOG_TUNE+8, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Yan Etek", "Wheel Arch Alien Yan Etek\nWheel Arch X-Flow Yan Etek\nLocos Low Chrome Strip\nLocos Low Chrome Flames\nLocos Low Chrome Arches\nLocos Low Chrome Trim\nLocos Low Wheelcovers\n[Geri]", "Seç", "Çýkýþ");
	                }
	                else if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 536)
					{
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1108);
					    AddVehicleComponent(GetPlayerVehicleID(playerid),1107);
					    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Locos Low Chrome Strip Yan Eteði Blade'e baþarýyla ekledin.");
	                    ShowPlayerDialog(playerid, DIALOG_TUNE+8, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Yan Etek", "Wheel Arch Alien Yan Etek\nWheel Arch X-Flow Yan Etek\nLocos Low Chrome Strip\nLocos Low Chrome Flames\nLocos Low Chrome Arches\nLocos Low Chrome Trim\nLocos Low Wheelcovers\n[Geri]", "Seç", "Çýkýþ");
	                }
					}
					else
					{
				    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Bu parçayý yanlýzca Locos Low tipi Brodway, Savanna Tornado ve Blade'e ekleyebilirsin!");
					ShowPlayerDialog(playerid, DIALOG_TUNE, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Araç Modifiye","Paint Job\nRenkler\nEgzostlar\nÖn Tampon\nArka Tampon\nÇatý\nSpoiler\nYan Etekler\nBullbar\nTekerlerkler\nAraç Ses Sistemi\n[Diðer Sayfa]", "Seç", "Çýkýþ");
					}
	        }
	  	    if(listitem == 3)
			{
                if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 534 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 534)
			    {
			        
			        if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 534)
			        {
			            AddVehicleComponent(GetPlayerVehicleID(playerid),1122);
			            AddVehicleComponent(GetPlayerVehicleID(playerid),1101);
			            PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
			            SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Locos Low Chrome Flames Yan eteði Remington'a baþarýyla ekledin.");
			            ShowPlayerDialog(playerid, DIALOG_TUNE+8, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Yan Etek", "Wheel Arch Alien Yan Etek\nWheel Arch X-Flow Yan Etek\nLocos Low Chrome Strip\nLocos Low Chrome Flames\nLocos Low Chrome Arches\nLocos Low Chrome Trim\nLocos Low Wheelcovers\n[Geri]", "Seç", "Çýkýþ");
					}
					}
					else
					{
				    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Bu parçayý sadece Locos Low Car tipi Remington'a ekleyebilirsin!");
					ShowPlayerDialog(playerid, DIALOG_TUNE, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Araç Modifiye","Paint Job\nRenkler\nEgzostlar\nÖn Tampon\nArka Tampon\nÇatý\nSpoiler\nYan Etekler\nBullbar\nTekerlerkler\nAraç Ses Sistemi\n[Diðer Sayfa]", "Seç", "Çýkýþ");
					}
			}
			if(listitem == 4)
			{
                if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 534 ||
				GetVehicleModel(GetPlayerVehicleID(playerid)) == 534)
			    {
			        
			        if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 534)
			        {
			            AddVehicleComponent(GetPlayerVehicleID(playerid),1106);
			            AddVehicleComponent(GetPlayerVehicleID(playerid),1124);
			            PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
			            SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Locos Low Chrome Arches Yan Eteði Remington'a baþarýyla ekledin.");
			            ShowPlayerDialog(playerid, DIALOG_TUNE+8, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Yan Etek", "Wheel Arch Alien Yan Etek\nWheel Arch X-Flow Yan Etek\nLocos Low Chrome Strip\nLocos Low Chrome Flames\nLocos Low Chrome Arches\nLocos Low Chrome Trim\nLocos Low Wheelcovers\n[Geri]", "Seç", "Çýkýþ");
					}
					}
					else
					{
				    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Bu parçayý sadece Locos Low Car tipi Remington'a ekleyebilirsin!");
					ShowPlayerDialog(playerid, DIALOG_TUNE, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Araç Modifiye","Paint Job\nRenkler\nEgzostlar\nÖn Tampon\nArka Tampon\nÇatý\nSpoiler\nYan Etekler\nBullbar\nTekerlerkler\nAraç Ses Sistemi\n[Diðer Sayfa]", "Seç", "Çýkýþ");
					}
			}
			if(listitem == 5)
			{
                if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 535)

			    {
			        
			        if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 535)
			        {
			            AddVehicleComponent(GetPlayerVehicleID(playerid),1118);
			            AddVehicleComponent(GetPlayerVehicleID(playerid),1120);
			            PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
			            SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Locos Low Chrome Trim yan eteði Slamvan'a baþarýyla ekledin.");
			            ShowPlayerDialog(playerid, DIALOG_TUNE+8, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Yan Etek", "Wheel Arch Alien Yan Etek\nWheel Arch X-Flow Yan Etek\nLocos Low Chrome Strip\nLocos Low Chrome Flames\nLocos Low Chrome Arches\nLocos Low Chrome Trim\nLocos Low Wheelcovers\n[Geri]", "Seç", "Çýkýþ");
					}
					}
					else
					{
				    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Bu parçayý sadece Locos Low Car tipi Slamvan'a ekleyebilirsin!");
					ShowPlayerDialog(playerid, DIALOG_TUNE, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Araç Modifiye","Paint Job\nRenkler\nEgzostlar\nÖn Tampon\nArka Tampon\nÇatý\nSpoiler\nYan Etekler\nBullbar\nTekerlerkler\nAraç Ses Sistemi\n[Diðer Sayfa]", "Seç", "Çýkýþ");
					}
			}
			if(listitem == 6)
			{
                if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 535)

			    {
			        
			        if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 535)
			        {
			            AddVehicleComponent(GetPlayerVehicleID(playerid),1119);
			            AddVehicleComponent(GetPlayerVehicleID(playerid),1121);
			            PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
			            SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Locos Low Chrome Wheelcover'ý Slamvan'a baþarýyla ekledin.");
			            ShowPlayerDialog(playerid, DIALOG_TUNE+8, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Yan Etek", "Wheel Arch Alien Yan Etek\nWheel Arch X-Flow Yan Etek\nLocos Low Chrome Strip\nLocos Low Chrome Flames\nLocos Low Chrome Arches\nLocos Low Chrome Trim\nLocos Low Wheelcovers\n[Geri]", "Seç", "Çýkýþ");
					}
					}
					else
					{
				    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Bu parçayý sadece Locos Low Car tipi Slamvan'a ekleyebilirsin!");
					ShowPlayerDialog(playerid, DIALOG_TUNE, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Araç Modifiye","Paint Job\nRenkler\nEgzostlar\nÖn Tampon\nArka Tampon\nÇatý\nSpoiler\nYan Etekler\nBullbar\nTekerlerkler\nAraç Ses Sistemi\n[Diðer Sayfa]", "Seç", "Çýkýþ");
					}
			}
			if(listitem == 7)
            {
                 ShowPlayerDialog(playerid, DIALOG_TUNE, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Araç Modifiye","Paint Job\nRenkler\nEgzostlar\nÖn Tampon\nArka Tampon\nÇatý\nSpoiler\nYan Etekler\nBullbar\nTekerlerkler\nAraç Ses Sistemi\n[Diðer Sayfa]", "Seç", "Çýkýþ");
            }
         }
   }
   	if(dialogid == DIALOG_TUNE+9)
   	{
		if(response)
		{
			if(listitem == 0)
			{
                if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 534)

			    {
			        
			        if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 534)
			        {
			            AddVehicleComponent(GetPlayerVehicleID(playerid),1100);
			            PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
			            SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Locos Low Chrome Grill parçasýný Remington'a baþarýyla ekledin.");
			            ShowPlayerDialog(playerid, DIALOG_TUNE+9, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Bullbar", "Locos Low Chrome Grill\nLocos Low Chrome Bars\nLocos Low Chrome Lights\nLocos Low Chrome Bullbar\n[Geri]", "Seç", "Çýkýþ");
			        }
					}
					else
					{
				    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Bu parçayý sadece Locos Low Car tipi Remington'a ekleyebilirsin!");
					ShowPlayerDialog(playerid, DIALOG_TUNE, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Araç Modifiye","Paint Job\nRenkler\nEgzostlar\nÖn Tampon\nArka Tampon\nÇatý\nSpoiler\nYan Etekler\nBullbar\nTekerlerkler\nAraç Ses Sistemi\n[Diðer Sayfa]", "Seç", "Çýkýþ");
					}
			}
			if(listitem == 1)
			{
                 if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 534)

			    {
			        
			        if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 534)
			        {
			            AddVehicleComponent(GetPlayerVehicleID(playerid),1123);
			            PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
			            SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Locos Low Chrome Bars parçasýný Remington'a baþarýyla ekledin.");
			            ShowPlayerDialog(playerid, DIALOG_TUNE+9, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Bullbar", "Locos Low Chrome Grill\nLocos Low Chrome Bars\nLocos Low Chrome Lights\nLocos Low Chrome Bullbar\n[Geri]", "Seç", "Çýkýþ");
					}
					}
					else
					{
				    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Bu parçayý sadece Locos Low Car tipi Remington'a ekleyebilirsin!");
					ShowPlayerDialog(playerid, DIALOG_TUNE, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Araç Modifiye","Paint Job\nRenkler\nEgzostlar\nÖn Tampon\nArka Tampon\nÇatý\nSpoiler\nYan Etekler\nBullbar\nTekerlerkler\nAraç Ses Sistemi\n[Diðer Sayfa]", "Seç", "Çýkýþ");
					}
			}
			if(listitem == 2)
			{
                if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 534)

			    {
			        
			        if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 534)
			        {
			            AddVehicleComponent(GetPlayerVehicleID(playerid),1125);
			            PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
			            SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Locos Low Chrome Lights parçasýný Remington'a baþarýyla ekledin.");
			            ShowPlayerDialog(playerid, DIALOG_TUNE+9, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Bullbar", "Locos Low Chrome Grill\nLocos Low Chrome Bars\nLocos Low Chrome Lights\nLocos Low Chrome Bullbar\n[Geri]", "Seç", "Çýkýþ");
					}
					}
					else
					{
				    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Bu parçayý sadece Locos Low Car tipi Remington'a ekleyebilirsin!");
					ShowPlayerDialog(playerid, DIALOG_TUNE, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Araç Modifiye","Paint Job\nRenkler\nEgzostlar\nÖn Tampon\nArka Tampon\nÇatý\nSpoiler\nYan Etekler\nBullbar\nTekerlerkler\nAraç Ses Sistemi\n[Diðer Sayfa]", "Seç", "Çýkýþ");
					}
			}
			if(listitem == 3)
			{
                if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 535)

			    {
			        
			        if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 535)
			        {
			            AddVehicleComponent(GetPlayerVehicleID(playerid),1117);
			            PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
			            SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Locos Low Chrome Lights parçasýný Slamvan'a baþarýyla ekledin.");
			            ShowPlayerDialog(playerid, DIALOG_TUNE+9, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Bullbar", "Locos Low Chrome Grill\nLocos Low Chrome Bars\nLocos Low Chrome Lights\nLocos Low Chrome Bullbar\n[Geri]", "Seç", "Çýkýþ");
					}
					}
					else
					{
				    SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Bu parçayý sadece Locos Low Car tipi Slamvan'a ekleyebilirsin!");
					ShowPlayerDialog(playerid, DIALOG_TUNE, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Araç Modifiye","Paint Job\nRenkler\nEgzostlar\nÖn Tampon\nArka Tampon\nÇatý\nSpoiler\nYan Etekler\nBullbar\nTekerlerkler\nAraç Ses Sistemi\n[Diðer Sayfa]", "Seç", "Çýkýþ");
					}
			}
			if(listitem == 4)
            {
                 ShowPlayerDialog(playerid, DIALOG_TUNE, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Araç Modifiye","Paint Job\nRenkler\nEgzostlar\nÖn Tampon\nArka Tampon\nÇatý\nSpoiler\nYan Etekler\nBullbar\nTekerlerkler\nAraç Ses Sistemi\n[Diðer Sayfa]", "Seç", "Çýkýþ");
            }
       }
   }

   	if(dialogid == DIALOG_TUNE+10)
   	{
		if(response)
		{
			if(listitem == 0)
			{
                 
		         AddVehicleComponent(GetPlayerVehicleID(playerid),1025);
		         PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
                 SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF} Offroad tekerleði aracýna baþarýyla ekledin.");
	             ShowPlayerDialog(playerid, DIALOG_TUNE+10, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Tekerlek", "Offroad\nMega\nWires\nTwist\nGrove\nImport\nAtomic\nAhab\nVirtual\nAccess\n[Diðer Sayfa]\n[Geri]", "Seç", "Çýkýþ");
	        }
            if(listitem == 1)
			{
                 
			     AddVehicleComponent(GetPlayerVehicleID(playerid),1074);
			     PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
			     SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Mega tekerleði aracýna baþarýyla ekledin.");
			     ShowPlayerDialog(playerid, DIALOG_TUNE+10, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Tekerlek", "Offroad\nMega\nWires\nTwist\nGrove\nImport\nAtomic\nAhab\nVirtual\nAccess\n[Diðer Sayfa]\n[Geri]", "Seç", "Çýkýþ");
			}
            if(listitem == 2)
			{
                 
	             AddVehicleComponent(GetPlayerVehicleID(playerid),1076);
			     PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
		         SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Wires tekerleði aracýna baþarýyla ekledin.");
			     ShowPlayerDialog(playerid, DIALOG_TUNE+10, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Tekerlek", "Offroad\nMega\nWires\nTwist\nGrove\nImport\nAtomic\nAhab\nVirtual\nAccess\n[Diðer Sayfa]\n[Geri]", "Seç", "Çýkýþ");
			}
	        if(listitem == 3)
			{
                 
			     AddVehicleComponent(GetPlayerVehicleID(playerid),1078);
			     PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
			     SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Twist tekerleði aracýna baþarýyla ekledin.");
			     ShowPlayerDialog(playerid, DIALOG_TUNE+10, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Tekerlek", "Offroad\nMega\nWires\nTwist\nGrove\nImport\nAtomic\nAhab\nVirtual\nAccess\n[Diðer Sayfa]\n[Geri]", "Seç", "Çýkýþ");
			}
			if(listitem == 4)
			{
                 
			     AddVehicleComponent(GetPlayerVehicleID(playerid),1081);
			     PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
			     SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Groove tekerleði aracýna baþarýyla ekledin.");
		         ShowPlayerDialog(playerid, DIALOG_TUNE+10, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Tekerlek", "Offroad\nMega\nWires\nTwist\nGrove\nImport\nAtomic\nAhab\nVirtual\nAccess\n[Diðer Sayfa]\n[Geri]", "Seç", "Çýkýþ");
			}
			if(listitem == 5)
			{
                 
                 AddVehicleComponent(GetPlayerVehicleID(playerid),1082);
                 PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
   			     SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Import tekerleði aracýna baþarýyla ekledin.");
			     ShowPlayerDialog(playerid, DIALOG_TUNE+10, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Tekerlek", "Offroad\nMega\nWires\nTwist\nGrove\nImport\nAtomic\nAhab\nVirtual\nAccess\n[Diðer Sayfa]\n[Geri]", "Seç", "Çýkýþ");
			}
			if(listitem == 6)
			{
                 
			     AddVehicleComponent(GetPlayerVehicleID(playerid),1085);
			     PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
			     SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Atomic tekerleði aracýna baþarýyla ekledin.");
                 ShowPlayerDialog(playerid, DIALOG_TUNE+10, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Tekerlek", "Offroad\nMega\nWires\nTwist\nGrove\nImport\nAtomic\nAhab\nVirtual\nAccess\n[Diðer Sayfa]\n[Geri]", "Seç", "Çýkýþ");
			}
			if(listitem == 7)
			{
                 
			     AddVehicleComponent(GetPlayerVehicleID(playerid),1096);
			     PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
	          	 SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Ahab tekerleði aracýna baþarýyla ekledin.");
			     ShowPlayerDialog(playerid, DIALOG_TUNE+10, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Tekerlek", "Offroad\nMega\nWires\nTwist\nGrove\nImport\nAtomic\nAhab\nVirtual\nAccess\n[Diðer Sayfa]\n[Geri]", "Seç", "Çýkýþ");
			}
			if(listitem == 8)
			{
                 
                 AddVehicleComponent(GetPlayerVehicleID(playerid),1097);
                 PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
	           	 SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Virtual tekerleði aracýna baþarýyla ekledin.");
                 ShowPlayerDialog(playerid, DIALOG_TUNE+10, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Tekerlek", "Offroad\nMega\nWires\nTwist\nGrove\nImport\nAtomic\nAhab\nVirtual\nAccess\n[Diðer Sayfa]\n[Geri]", "Seç", "Çýkýþ");
			}
			if(listitem == 9)
			{
                 
			     AddVehicleComponent(GetPlayerVehicleID(playerid),1098);
			     PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
	         	 SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Access tekerleði aracýna baþarýyla ekledin.");
			     ShowPlayerDialog(playerid, DIALOG_TUNE+10, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Tekerlek", "Offroad\nMega\nWires\nTwist\nGrove\nImport\nAtomic\nAhab\nVirtual\nAccess\n[Diðer Sayfa]\n[Geri]", "Seç", "Çýkýþ");
			}
			if(listitem == 10)
			{
                 ShowPlayerDialog(playerid, DIALOG_TUNE+13, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Tekerlek", "Trance\nShadow\nRimshine\nClassic\nCutter\nSwitch\nDollar\n[Geri]", "Seç", "Çýkýþ");
			}
			if(listitem == 11)
            {
                 ShowPlayerDialog(playerid, DIALOG_TUNE, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Araç Modifiye","Paint Job\nRenkler\nEgzostlar\nÖn Tampon\nArka Tampon\nÇatý\nSpoiler\nYan Etekler\nBullbar\nTekerlerkler\nAraç Ses Sistemi\n[Diðer Sayfa]", "Seç", "Çýkýþ");
            }

		}
   }

	if(dialogid == DIALOG_TUNE+11)
 	{
		if(response)
		{
			if(listitem == 0)
			{
                 
		         AddVehicleComponent(GetPlayerVehicleID(playerid),1086);
		         PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
		         SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Stereo Bass Bost sistemini aracýna baþarýyla ekledin.");
		         ShowPlayerDialog(playerid, DIALOG_TUNE+11, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Ses Sistemi", "Bass Boost\nSuper Bass Boost\nUltra Bass Boost\nKing Bass Boost\n[Geri]", "Seç", "Çýkýþ");
			}
			if(listitem == 1)
			{
		         
		         AddVehicleComponent(GetPlayerVehicleID(playerid),1086);
		         PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
		         SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Stereo Super Bass Bost sistemini aracýna baþarýyla ekledin.");
		         ShowPlayerDialog(playerid, DIALOG_TUNE+11, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Ses Sistemi", "Bass Boost\nSuper Bass Boost\nUltra Bass Boost\nKing Bass Boost\n[Geri]", "Seç", "Çýkýþ");
			}
			if(listitem == 2)
			{
		         
		         AddVehicleComponent(GetPlayerVehicleID(playerid),1086);
                 PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
		         SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Ultra Bass Bost sistemini aracýna baþarýyla ekledin.");
		         ShowPlayerDialog(playerid, DIALOG_TUNE+11, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Ses Sistemi", "Bass Boost\nSuper Bass Boost\nUltra Bass Boost\nKing Bass Boost\n[Geri]", "Seç", "Çýkýþ");
			}
			if(listitem == 3)
			{
		         
		         AddVehicleComponent(GetPlayerVehicleID(playerid),1086);
		         PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
		         SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}King Stereo Bass Bost sistemini aracýna baþarýyla ekledin.");
		         ShowPlayerDialog(playerid, DIALOG_TUNE+11, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Ses Sistemi", "Bass Boost\nSuper Bass Boost\nUltra Bass Boost\nKing Bass Boost\n[Geri]", "Seç", "Çýkýþ");
			}
			if(listitem == 4)
            {
                 ShowPlayerDialog(playerid, DIALOG_TUNE, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Araç Modifiye","Paint Job\nRenkler\nEgzostlar\nÖn Tampon\nArka Tampon\nÇatý\nSpoiler\nYan Etekler\nBullbar\nTekerlerkler\nAraç Ses Sistemi\n[Diðer Sayfa]", "Seç", "Çýkýþ");
            }
		}
   }

   	if(dialogid == DIALOG_TUNE+12)
   	{
		if(response)
		{
			if(listitem == 0)
			{
		         
		         AddVehicleComponent(GetPlayerVehicleID(playerid),1087);
		         PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
		         SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Hidrolikleri aracýna baþarýyla ekledin.");
		         ShowPlayerDialog(playerid, DIALOG_TUNE+12, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Modifiye Menüsü", "Hidrolikler\nNitro x10\nAraç Tamir\n[Geri]", "Seç", "Çýkýþ");
			}
			if(listitem == 1)
			{
		         
		         AddVehicleComponent(GetPlayerVehicleID(playerid),1010);
		         PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
		         SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}10x Nitro'yu aracýna baþarýyla ekledin.");
		         ShowPlayerDialog(playerid, DIALOG_TUNE+12, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Modifiye Menüsü", "Hidrolikler\nNitro x10\nAraç Tamir\n[Geri]", "Seç", "Çýkýþ");
			}
			if(listitem == 2)
			{
		         
		         SetVehicleHealth(GetPlayerVehicleID(playerid),1000);
		         PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
		         SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Aracý Baþarýyla Tamir Ettin.");
		         ShowPlayerDialog(playerid, DIALOG_TUNE+12, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Modifiye Menüsü", "Hidrolikler\nNitro x10\nAraç Tamir\n[Geri]", "Seç", "Çýkýþ");
			}
			if(listitem == 3)
            {
                 ShowPlayerDialog(playerid, DIALOG_TUNE, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Araç Modifiye","Paint Job\nRenkler\nEgzostlar\nÖn Tampon\nArka Tampon\nÇatý\nSpoiler\nYan Etekler\nBullbar\nTekerlerkler\nAraç Ses Sistemi\n[Diðer Sayfa]", "Seç", "Çýkýþ");
            }
		}
	}

   	if(dialogid == DIALOG_TUNE+13)
   	{
		if(response)
		{
			if(listitem == 0)
            {
		         
		         AddVehicleComponent(GetPlayerVehicleID(playerid),1084);
		         PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
		         SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Trance tekerleði aracýna baþarýyla ekledin.");
		         ShowPlayerDialog(playerid, DIALOG_TUNE+13, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Tekerlek", "Trance\nShadow\nRimshine\nClassic\nCutter\nSwitch\nDollar\n[Geri]", "Seç", "Çýkýþ");
            }
            if(listitem == 1)
            {
		         
		         AddVehicleComponent(GetPlayerVehicleID(playerid),1073);
		         PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
		         SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Shadow tekerleði aracýna baþarýyla ekledin.");
		         ShowPlayerDialog(playerid, DIALOG_TUNE+13, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Tekerlek", "Trance\nShadow\nRimshine\nClassic\nCutter\nSwitch\nDollar\n[Geri]", "Seç", "Çýkýþ");
            }
            if(listitem == 2)
            {
		         
		         AddVehicleComponent(GetPlayerVehicleID(playerid),1075);
		         PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
		         SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Rimshine tekerleði aracýna baþarýyla ekledin.");
		         ShowPlayerDialog(playerid, DIALOG_TUNE+13, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Tekerlek", "Trance\nShadow\nRimshine\nClassic\nCutter\nSwitch\nDollar\n[Geri]", "Seç", "Çýkýþ");
            }
            if(listitem == 3)
            {
		         
		         AddVehicleComponent(GetPlayerVehicleID(playerid),1077);
		         PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
		         SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Classic tekerleði aracýna baþarýyla ekledin.");
		         ShowPlayerDialog(playerid, DIALOG_TUNE+13, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Tekerlek", "Trance\nShadow\nRimshine\nClassic\nCutter\nSwitch\nDollar\n[Geri]", "Seç", "Çýkýþ");
            }
            if(listitem == 4)
            {
		         
		         AddVehicleComponent(GetPlayerVehicleID(playerid),1079);
		         PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
		         SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Cutter tekerleði aracýna baþarýyla ekledin.");
		         ShowPlayerDialog(playerid, DIALOG_TUNE+13, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Tekerlek", "Trance\nShadow\nRimshine\nClassic\nCutter\nSwitch\nDollar\n[Geri]", "Seç", "Çýkýþ");
            }
            if(listitem == 5)
            {
		         
		         AddVehicleComponent(GetPlayerVehicleID(playerid),1080);
		         PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
		         SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Switch tekerleði aracýna baþarýyla ekledin.");
		         ShowPlayerDialog(playerid, DIALOG_TUNE+13, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Tekerlek", "Trance\nShadow\nRimshine\nClassic\nCutter\nSwitch\nDollar\n[Geri]", "Seç", "Çýkýþ");
            }
            if(listitem == 6)
            {
		         AddVehicleComponent(GetPlayerVehicleID(playerid),1083);
		         PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
		         SendClientMessage(playerid,0x666600FF,"Tune » {FFFFFF}Dollar tekerleði aracýna baþarýyla ekledin.");
		         ShowPlayerDialog(playerid, DIALOG_TUNE+13, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Tekerlek", "Trance\nShadow\nRimshine\nClassic\nCutter\nSwitch\nDollar\n[Geri]", "Seç", "Çýkýþ");
            }
            if(listitem == 7)
            {
		         ShowPlayerDialog(playerid, DIALOG_TUNE+10, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Tekerlek", "Offroad\nMega\nWires\nTwist\nGrove\nImport\nAtomic\nAhab\nVirtual\nAccess\n[Diðer Sayfa]\n[Geri]", "Seç", "Çýkýþ");
            }
         }
    }
	if(dialogid == DIALOG_MYCAR)
	{
		if(response)PVS->Int->FireKey[playerid]->listitem;
		else PVS->Int->HKey[playerid]->listitem;
		switch(response)
		{
			case 0:
			{
				switch(listitem)
				{
					case 0: SendClientMessage(playerid,0xFF9900FF,"Mycar » {FFFFFF}H tuþu boþ olarak ayarlandi!");
					case 1: SendClientMessage(playerid,0xFF9900FF,"Mycar » {FFFFFF}H tuþu hiz olarak ayarlandi!");
					case 2: SendClientMessage(playerid,0xFF9900FF,"Mycar » {FFFFFF}H tuþu ziplama olarak ayarlandi!");
					case 3: SendClientMessage(playerid,0xFF9900FF,"Mycar » {FFFFFF}H tuþu yon x olarak ayarlandi!");
					case 4: SendClientMessage(playerid,0xFF9900FF,"Mycar » {FFFFFF}H tuþu yon y olarak ayarlandi!");
					case 5: SendClientMessage(playerid,0xFF9900FF,"Mycar » {FFFFFF}H tuþu yon z olarak ayarlandi!");
					case 6: SendClientMessage(playerid,0xFF9900FF,"Mycar » {FFFFFF}H tuþu çevirme olarak ayarlandi!");
					case 7: SendClientMessage(playerid,0xFF9900FF,"Mycar » {FFFFFF}H tuþu renk olarak ayarlandi!");
					case 8: SendClientMessage(playerid,0xFF9900FF,"Mycar » {FFFFFF}H tuþu fren olarak ayarlandi!");
					case 9: SendClientMessage(playerid,0xFF9900FF,"Mycar » {FFFFFF}H tuþu bagaj olarak ayarlandi!");
					case 10: SendClientMessage(playerid,0xFF9900FF,"Mycar » {FFFFFF}H tuþu kaput olarak ayarlandi!");
					case 11: SendClientMessage(playerid,0xFF9900FF,"Mycar » {FFFFFF}H tuþu alarm olarak ayarlandi!");
					case 12: SendClientMessage(playerid,0xFF9900FF,"Mycar » {FFFFFF}H tuþu far olarak ayarlandi!");
					case 13: SendClientMessage(playerid,0xFF9900FF,"Mycar » {FFFFFF}H tuþu motor olarak ayarlandi!");
					case 14: SendClientMessage(playerid,0xFF9900FF,"Mycar » {FFFFFF}H tuþu kilit olarak ayarlandi!");
				}
			}
			case 1:
			{
				switch(listitem)
				{
					case 0: SendClientMessage(playerid,0xFF9900FF,"Mycar » {FFFFFF}Ateþ etme tuþu boþ olarak ayarlandi!");
					case 1: SendClientMessage(playerid,0xFF9900FF,"Mycar » {FFFFFF}Ateþ etme tuþu hiz olarak ayarlandi!");
					case 2: SendClientMessage(playerid,0xFF9900FF,"Mycar » {FFFFFF}Ateþ etme tuþu ziplama olarak ayarlandi!");
					case 3: SendClientMessage(playerid,0xFF9900FF,"Mycar » {FFFFFF}Ateþ etme tuþu yon x olarak ayarlandi!");
					case 4: SendClientMessage(playerid,0xFF9900FF,"Mycar » {FFFFFF}Ateþ etme tuþu yon y olarak ayarlandi!");
					case 5: SendClientMessage(playerid,0xFF9900FF,"Mycar » {FFFFFF}Ateþ etme tuþu yon z olarak ayarlandi!");
					case 6: SendClientMessage(playerid,0xFF9900FF,"Mycar » {FFFFFF}Ateþ etme tuþu çevirme olarak ayarlandi!");
					case 7: SendClientMessage(playerid,0xFF9900FF,"Mycar » {FFFFFF}Ateþ etme tuþu renk olarak ayarlandi!");
					case 8: SendClientMessage(playerid,0xFF9900FF,"Mycar » {FFFFFF}Ateþ etme tuþu fren olarak ayarlandi!");
					case 9: SendClientMessage(playerid,0xFF9900FF,"Mycar » {FFFFFF}Ateþ etme tuþu bagaj olarak ayarlandi!");
					case 10: SendClientMessage(playerid,0xFF9900FF,"Mycar » {FFFFFF}Ateþ etme tuþu kaput olarak ayarlandi!");
					case 11: SendClientMessage(playerid,0xFF9900FF,"Mycar » {FFFFFF}Ateþ etme tuþu alarm olarak ayarlandi!");
					case 12: SendClientMessage(playerid,0xFF9900FF,"Mycar » {FFFFFF}Ateþ etme tuþu far olarak ayarlandi!");
                    case 13: SendClientMessage(playerid,0xFF9900FF,"Mycar » {FFFFFF}Ateþ etme tuþu motor olarak ayarlandi!");
                    case 14: SendClientMessage(playerid,0xFF9900FF,"Mycar » {FFFFFF}Ateþ etme tuþu kilit olarak ayarlandi!");
				}
			}
		}
	}
	if(dialogid == DIALOG_DUEL_WEAPON)
	{
	    if(response)
	    {
	        new weaponid;
	        switch(listitem)
			{
				case 0: weaponid = 9;
				case 1: weaponid = 16;
				case 2: weaponid = 18;
				case 3: weaponid = 22;
				case 4: weaponid = 23;
				case 5: weaponid = 24;
				case 6: weaponid = 25;
				case 7: weaponid = 26;
				case 8: weaponid = 27;
				case 9: weaponid = 28;
				case 10: weaponid = 29;
				case 11: weaponid = 30;
				case 12: weaponid = 31;
				case 13: weaponid = 32;
				case 14: weaponid = 33;
				case 15: weaponid = 34;
			}
			Oyuncu[playerid][DuelSilah1] = weaponid;
			Oyuncu[Oyuncu[playerid][DuelRakip]][DuelSilah1] = weaponid;
            SendClientMessage(playerid, 0x99CC00FF, "Duel » {FFFFFF}2. duello silahýný seçiniz.");
            new str[512];
            format(str, 512, "{FF0000}» {FFFFFF}Testere\n{FF0000}» {FFFFFF}El Bombasý\n{FF0000}» {FFFFFF}Molotof\n{FF0000}» {FFFFFF}9mm\n{FF0000}» {FFFFFF}Silenced\n{FF0000}» {FFFFFF}Deagle\n{FF0000}» {FFFFFF}Shotgun\n{FF0000}» {FFFFFF}Sawn Off\n{FF0000}» {FFFFFF}Combat\n{FF0000}» {FFFFFF}Uzi\n{FF0000}» {FFFFFF}Mp5\n{FF0000}» {FFFFFF}Ak-47\n{FF0000}» {FFFFFF}M4\n{FF0000}» {FFFFFF}Tec-9\n{FF0000}» {FFFFFF}Rifle\n{FF0000}» {FFFFFF}Sniper");
			ShowPlayerDialog(playerid, DIALOG_DUEL_WEAPON2, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Duello Silah 2", str, "Sec", "Iptal");
	    }
	}
	if(dialogid == DIALOG_DUEL_WEAPON2)
	{
	    if(response)
	    {
	        new weaponid;
	        switch(listitem)
			{
				case 0: weaponid = 9;
				case 1: weaponid = 16;
				case 2: weaponid = 18;
				case 3: weaponid = 22;
				case 4: weaponid = 23;
				case 5: weaponid = 24;
				case 6: weaponid = 25;
				case 7: weaponid = 26;
				case 8: weaponid = 27;
				case 9: weaponid = 28;
				case 10: weaponid = 29;
				case 11: weaponid = 30;
				case 12: weaponid = 31;
				case 13: weaponid = 32;
				case 14: weaponid = 33;
				case 15: weaponid = 34;
			}
			Oyuncu[playerid][DuelSilah2] = weaponid;
			Oyuncu[Oyuncu[playerid][DuelRakip]][DuelSilah2] = weaponid;
            SendClientMessage(playerid, 0x99CC00FF, "Duel » {FFFFFF}Duello mapini seçiniz.");
			ShowPlayerDialog(playerid, DIALOG_DUEL_MAP, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Duello Map", "{FF0000}» {FFFFFF}T 25\n\
																													   {FF0000}» {FFFFFF}Stadium\n\
	 																												   {FF0000}» {FFFFFF}RC Battlefield", "Sec", "Iptal");
	    }
	}
	if(dialogid == DIALOG_DUEL_MAP)
	{
	    if(response)
	    {
	        new mapid;
	        switch(listitem)
	        {
	            case 0: mapid = 0;
	            case 1: mapid = 1;
	            case 2: mapid = 2;
	        }
			Oyuncu[playerid][DuelMap] = mapid;
			Oyuncu[Oyuncu[playerid][DuelRakip]][DuelMap] = mapid;
            if(!IsPlayerConnected(Oyuncu[playerid][DuelRakip])) return SendClientMessage(playerid, 0x99CC00FF, "Duel » {FFFFFF}Rakip oyunda deðil.");
			if(Oyuncu[Oyuncu[playerid][DuelRakip]][Duelde]) return SendClientMessage(playerid, 0x99CC00FF, "Duel » {FFFFFF}Rakip zaten bir duelloda.");
			new string[256];
			format(string, sizeof(string), "Duel » {FFFFFF}%s(%i)'a duello isteði attýn.", PlayerName(Oyuncu[playerid][DuelRakip]), Oyuncu[playerid][DuelRakip]);
		    SendClientMessage(playerid, 0x99CC00FF, string);
			format(string, sizeof(string), "Duel » {FFFFFF}Duello silahlari %s ve %s.",ReturnWeaponNameEx(Oyuncu[playerid][DuelSilah1]), ReturnWeaponNameEx(Oyuncu[playerid][DuelSilah2]));
			SendClientMessage(playerid, 0x99CC00FF, string);
			format(string, sizeof(string), "Duel » {FFFFFF}Duello mapi %s", ReturnMapName(Oyuncu[playerid][DuelMap]));
			SendClientMessage(playerid, 0x99CC00FF, string);
	        format(string, sizeof(string), "{FF0000}» {FFFFFF}Rakip: %s(%i)\n\n\
											{FF0000}» {FFFFFF}Silah 1: %s\n\
											{FF0000}» {FFFFFF}Silah 2: %s\n\n\
											{FF0000}» {FFFFFF}Map: %s", PlayerName(playerid), playerid, ReturnWeaponNameEx(Oyuncu[playerid][DuelSilah1]), ReturnWeaponNameEx(Oyuncu[playerid][DuelSilah2]) , ReturnMapName(Oyuncu[playerid][DuelMap]));
	        ShowPlayerDialog(Oyuncu[playerid][DuelRakip], DIALOG_DUEL, DIALOG_STYLE_MSGBOX, "{FF0000}LYNX DRIFT - {FFFFFF}Duello", string, "Kabul", "Red");
	    }
 	}
	if(dialogid == DIALOG_DUEL)
	{
	    if(!response)
	    {
	        SendClientMessage(Oyuncu[playerid][DuelRakip], 0x99CC00FF, "Duel » {FFFFFF}Rakip duelloyu reddetti.");
	        Oyuncu[Oyuncu[playerid][DuelRakip]][Duelde] = false;
	        Oyuncu[Oyuncu[playerid][DuelRakip]][DuelRakip] = INVALID_PLAYER_ID;
	        Oyuncu[Oyuncu[playerid][DuelRakip]][DuelSilah1] = 0;
	        Oyuncu[Oyuncu[playerid][DuelRakip]][DuelSilah2] = 0;
	        Oyuncu[playerid][Duelde] = false;
	        Oyuncu[playerid][DuelRakip] = INVALID_PLAYER_ID;
	        Oyuncu[playerid][DuelSilah1] = 0;
	        Oyuncu[playerid][DuelSilah2] = 0;
	    }else
	    if(response)
	    {
            if(!IsPlayerConnected(Oyuncu[playerid][DuelRakip])) return SendClientMessage(playerid, 0x99CC00FF, "Duel » {FFFFFF}Rakip oyunda deðil.");
			if(Oyuncu[Oyuncu[playerid][DuelRakip]][Duelde]) return SendClientMessage(playerid, 0x99CC00FF, "Duel » {FFFFFF}Rakip zaten bir duelloda.");
			ResetPlayerWeapons(playerid);
			SilahVer(playerid, Oyuncu[playerid][DuelSilah1], 5000);
			SilahVer(playerid, Oyuncu[playerid][DuelSilah2], 5000);
			SetPlayerHealth(playerid, 100.0);
			SetPlayerArmour(playerid, 100.0);
			ResetPlayerWeapons(Oyuncu[playerid][DuelRakip]);
			SilahVer(Oyuncu[playerid][DuelRakip], Oyuncu[playerid][DuelSilah1], 5000);
			SilahVer(Oyuncu[playerid][DuelRakip], Oyuncu[playerid][DuelSilah2], 5000);
			SetPlayerHealth(Oyuncu[playerid][DuelRakip], 100.0);
			SetPlayerArmour(Oyuncu[playerid][DuelRakip], 100.0);
			switch(Oyuncu[playerid][DuelMap])
			{
			    case 0:
			    {
					SetPlayerPos(playerid, 1097.1639, 1063.6047, 10.8359);
					SetPlayerVirtualWorld(playerid, playerid+10);
                    SetCameraBehindPlayer(playerid);
					SetPlayerPos(Oyuncu[playerid][DuelRakip], 1081.3628, 1080.4985, 10.8359);
					SetPlayerVirtualWorld(Oyuncu[playerid][DuelRakip], playerid+10);
					SetCameraBehindPlayer(Oyuncu[playerid][DuelRakip]);
				}
			    case 1:
			    {
					SetPlayerPos(playerid, 3374.6348, -1734.9648, 9.2609);
					SetPlayerVirtualWorld(playerid, playerid+10);
                    SetCameraBehindPlayer(playerid);
					SetPlayerPos(Oyuncu[playerid][DuelRakip], 3341.7039, -1766.2764, 9.2609);
					SetPlayerVirtualWorld(Oyuncu[playerid][DuelRakip], playerid+10);
					SetCameraBehindPlayer(Oyuncu[playerid][DuelRakip]);
				}
			    case 2:
			    {
					SetPlayerPos(playerid, -1131.9055, 1057.8958, 1346.4146);
					SetPlayerInterior(playerid, 10);
					SetPlayerVirtualWorld(playerid, playerid+10);
                    SetCameraBehindPlayer(playerid);
					SetPlayerPos(Oyuncu[playerid][DuelRakip], -974.6671, 1060.8036, 1345.6719);
					SetPlayerInterior( Oyuncu[playerid][DuelRakip], 10);
					SetPlayerVirtualWorld( Oyuncu[playerid][DuelRakip], playerid+10);
					SetCameraBehindPlayer(Oyuncu[playerid][DuelRakip]);
				}
			}
			TogglePlayerControllable(playerid, false);
			TogglePlayerControllable(Oyuncu[playerid][DuelRakip], false);
			Duello_Sayac[playerid] = 6;
			KillTimer(Duello_Timer[playerid]);
	 		Duello_Timer[playerid] = SetTimerEx("Duello_Sayim", 1000, true, "i", playerid);
			Duello_Sayac[Oyuncu[playerid][DuelRakip]] = 6;
			KillTimer(Duello_Timer[Oyuncu[playerid][DuelRakip]]);
		 	Duello_Timer[Oyuncu[playerid][DuelRakip]] = SetTimerEx("Duello_Sayim", 1000, true, "i", Oyuncu[playerid][DuelRakip]);
	        Oyuncu[Oyuncu[playerid][DuelRakip]][Duelde] = true;
	        Oyuncu[playerid][Duelde] = true;
			return 1;
	    }
	}
    if(dialogid == DIALOG_RACE)
    {
	    if(!response) return 1;
	    if(RaceBusy != 0x00) return 1;
		LoadRace(playerid, RaceNames[listitem]);
	}
	switch(dialogid)
	{
	    case 599:
	    {
	        if(!response) return BuildRace = 0;
	        switch(listitem)
	        {
	        	case 0: BuildRaceType = 0;
	        	case 1: BuildRaceType = 3;
			}
			ShowDialog(playerid, 600);
	    }
	    case 600..601:
	    {
	        if(!response) return ShowDialog(playerid, 599);
	        if(!strlen(inputtext)) return ShowDialog(playerid, 601);
	        if(strlen(inputtext) < 1 || strlen(inputtext) > 20) return ShowDialog(playerid, 601);
	        strmid(BuildName, inputtext, 0, strlen(inputtext), sizeof(BuildName));
	        ShowDialog(playerid, 602);
	    }
	    case 602..603:
	    {
	        if(!response) return ShowDialog(playerid, 600);
	        if(!strlen(inputtext)) return ShowDialog(playerid, 603);
	        if(isNumeric(inputtext))
	        {

	            if(!IsValidVehicle(strval(inputtext))) return ShowDialog(playerid, 603);
				new Float: pPos[4];
				GetPlayerPos(playerid, pPos[0], pPos[1], pPos[2]);
				GetPlayerFacingAngle(playerid, pPos[3]);
				BuildModeVID = strval(inputtext);
				BuildCreatedVehicle = (BuildCreatedVehicle == 0x01) ? (DestroyVehicle(BuildVehicle), BuildCreatedVehicle = 0x00) : (DestroyVehicle(BuildVehicle), BuildCreatedVehicle = 0x00);
	            BuildVehicle = CreateVehicle(strval(inputtext), pPos[0], pPos[1], pPos[2], pPos[3], -1, -1, (60 * 60));
	            PutPlayerInVehicle(playerid, BuildVehicle, 0);
				BuildCreatedVehicle = 0x01;
				ShowDialog(playerid, 604);
			}else
	        {
	            if(!IsValidVehicle(ReturnVehicleID(inputtext))) return ShowDialog(playerid, 603);
				new Float: pPos[4];
				GetPlayerPos(playerid, pPos[0], pPos[1], pPos[2]);
				GetPlayerFacingAngle(playerid, pPos[3]);
				BuildModeVID = ReturnVehicleID(inputtext);
				BuildCreatedVehicle = (BuildCreatedVehicle == 0x01) ? (DestroyVehicle(BuildVehicle), BuildCreatedVehicle = 0x00) : (DestroyVehicle(BuildVehicle), BuildCreatedVehicle = 0x00);
	            BuildVehicle = CreateVehicle(ReturnVehicleID(inputtext), pPos[0], pPos[1], pPos[2], pPos[3], -1, -1, (60 * 60));
	            PutPlayerInVehicle(playerid, BuildVehicle, 0);
				BuildCreatedVehicle = 0x01;
				ShowDialog(playerid, 604);
	        }
	    }
	    case 604:
	    {
	        if(!response) return ShowDialog(playerid, 602);
			SendClientMessage(playerid, -1, ">> Go to the start line on the left road and press 'KEY_FIRE' and do the same with the right road block.");
			SendClientMessage(playerid, -1, "   - When this is done, you will see a dialog to continue.");
			BuildVehPosCount = 0;
	        BuildTakeVehPos = true;
	    }
	    case 605:
	    {
	        if(!response) return ShowDialog(playerid, 604);
	        SendClientMessage(playerid, -1, ">> Start taking checkpoints now by clicking 'KEY_FIRE'.");
	        SendClientMessage(playerid, -1, "   - IMPORTANT: Press 'ENTER' when you're done with the checkpoints! If it doesn't react press again and again.");
	        BuildCheckPointCount = 0;
	        BuildTakeCheckpoints = true;
	    }
	    case 606:
	    {
	        if(!response) return ShowDialog(playerid, 606);
	        BuildRace = 0;
	        BuildCheckPointCount = 0;
	        BuildVehPosCount = 0;
	        BuildTakeCheckpoints = false;
	        BuildTakeVehPos = false;
	        BuildCreatedVehicle = (BuildCreatedVehicle == 0x01) ? (DestroyVehicle(BuildVehicle), BuildCreatedVehicle = 0x00) : (DestroyVehicle(BuildVehicle), BuildCreatedVehicle = 0x00);
	    }
	}
	if(dialogid == DIALOG_TDM)
	{
		if(!response) return 1;
		if(TDMInfo[t_Aktif] == true) return SendClientMessage(playerid, 0x990000FF,"TDM » {FFFFFF}TDM zaten aktif!");
		switch(listitem)
		{
		    case 0:
			{
			    TDM_Baslat(playerid,"ballasgrove");
			    OnPlayerCommandText(playerid, "/tdmkatil");
				SendClientMessage(playerid, 0x990000FF,"TDM » {FFFFFF}TDM basariyla baslatildi.");
			}
		    case 1:
			{
			    TDM_Baslat(playerid,"korsankaptan");
			    OnPlayerCommandText(playerid, "/tdmkatil");
				SendClientMessage(playerid, 0x990000FF,"TDM » {FFFFFF}TDM basariyla baslatildi.");
			}
		    case 2:
			{
			    TDM_Baslat(playerid,"swatuyusturucu");
			    OnPlayerCommandText(playerid, "/tdmkatil");
				SendClientMessage(playerid, 0x990000FF,"TDM » {FFFFFF}TDM basariyla baslatildi.");
			}
		    case 3:
			{
			    TDM_Baslat(playerid,"itfaiyeinsaat");
			    OnPlayerCommandText(playerid, "/tdmkatil");
				SendClientMessage(playerid, 0x990000FF,"TDM » {FFFFFF}TDM basariyla baslatildi.");
			}
		    case 4:
			{
			    TDM_Baslat(playerid,"askerterorist");
			    OnPlayerCommandText(playerid, "/tdmkatil");
				SendClientMessage(playerid, 0x990000FF,"TDM » {FFFFFF}TDM basariyla baslatildi.");
			}
		    case 5:
			{
			    TDM_Baslat(playerid,"iscilerpatronlar");
			    OnPlayerCommandText(playerid, "/tdmkatil");
				SendClientMessage(playerid, 0x990000FF,"TDM » {FFFFFF}TDM basariyla baslatildi.");
			}
		    case 6:
			{
			    TDM_Baslat(playerid,"driftciotopark");
			    OnPlayerCommandText(playerid, "/tdmkatil");
				SendClientMessage(playerid, 0x990000FF,"TDM » {FFFFFF}TDM basariyla baslatildi.");
			}
			case 7:
			{
				switch(random(7))
				{
				    case 0: TDM_Baslat(playerid,"ballasgrove");
				    case 1: TDM_Baslat(playerid,"korsankaptan");
				    case 2: TDM_Baslat(playerid,"swatuyusturucu");
				    case 3: TDM_Baslat(playerid,"itfaiyeinsaat");
				    case 4: TDM_Baslat(playerid,"askerterorist");
				    case 5: TDM_Baslat(playerid,"iscilerpatronlar");
				    case 6: TDM_Baslat(playerid,"driftciotopark");
				}
			    OnPlayerCommandText(playerid, "/tdmkatil");
				SendClientMessage(playerid, 0x990000FF,"TDM » {FFFFFF}TDM basariyla baslatildi.");
			}
		}
	}
	return 1;
}
public OnPlayerCommandText(playerid, cmdtext[])
{
	if(Oyuncu[playerid][Giris] == false)
	{
		SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Giriþ yapmadan komut kullanamazsýnýz.");
		return 1;
	}
	if(GetPlayerState(playerid) == PLAYER_STATE_WASTED || GetPlayerState(playerid) == PLAYER_STATE_NONE)
	{
	    SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Spawn olmadan komut kullanamazsýnýz.");
	    return 1;
	}
	if(GetTickCount() < Oyuncu[playerid][YaraliTime])
 	{
		new str[128];
    	format(str, sizeof(str),"Hata » {FFFFFF}Yarali iken komut kullanamazsýn. (%d Saniye)", ConvertTimer(Oyuncu[playerid][YaraliTime] - GetTickCount()));
		SendClientMessage(playerid, 0xFF0000FF, str);
 		return 1;
	}
	if(GetPVarInt(playerid, "KomutEngelEx") == 1) return 1;
	if(!strcmp(cmdtext, "/credits", true))
	{
	    new str[450] = "{FFFFFF}Server sahipliðini {E23243}CyreX {FFFFFF}yapmaktadýr.\n\
						Sunucu modu sýfýrdan {1ABC9C}Excision {FFFFFF}tarafýndan yazýlmýþtýr.\n\
						Mapler {fcf00a}MrKinq {FFFFFF}tarafýndan dizayn edilmiþtir.\n\
						Sunucunun ilk açýlýþ tarihi {3399FF}11.12.2016 {FFFFFF}olup, o günden beri devamlý geliþtirilmektedir.\n\n\
						Bu zamana kadar hep yanýmýzda bulunan {9966FF}Levi, Hwang ve NexoR'a {FFFFFF}teþekkür ederiz.";
		ShowPlayerDialog(playerid, DIALOG_CREDITS, DIALOG_STYLE_MSGBOX, "{FF0000}LYNX DRIFT - {FFFFFF}Yapýmcýlar", str, "Tamam", "");
		return 1;
	}
	dcmd(mapyenile, 9, cmdtext);
	dcmd(setlevel, 8, cmdtext);
	dcmd(setarmour, 9, cmdtext);
	dcmd(setheal, 7, cmdtext);
 	dcmd(setdj, 5, cmdtext);
	dcmd(setscore, 8, cmdtext);
	dcmd(givecash, 8, cmdtext);
	dcmd(giveexp, 7, cmdtext);
	dcmd(ban, 3, cmdtext);
	dcmd(unbanip, 7, cmdtext);
	dcmd(slock, 5, cmdtext);
	dcmd(nban, 4, cmdtext);
	dcmd(kick, 4, cmdtext);
	dcmd(mute, 4, cmdtext);
	dcmd(unmute, 6, cmdtext);
	dcmd(sarki,5,cmdtext);
	dcmd(goto, 4, cmdtext);
	dcmd(get, 3, cmdtext);
	dcmd(setallweather, 13, cmdtext);
	dcmd(setalltime, 10, cmdtext);
	dcmd(mkapat,6,cmdtext);
	dcmd(yayinac,7,cmdtext);
	dcmd(pm, 2, cmdtext);
	dcmd(re, 2, cmdtext);
	dcmd(pmon, 4, cmdtext);
	dcmd(pmoff, 5, cmdtext);
	dcmd(l, 1, cmdtext);
	dcmd(jetpack, 7, cmdtext);
	dcmd(gopos,5,cmdtext);
	dcmd(setcolor,8,cmdtext);
	dcmd(aka, 3, cmdtext);
	dcmd(spec, 4, cmdtext);
	dcmd(specoff, 7, cmdtext);
	dcmd(rac, 3, cmdtext);
	dcmd(pmspec, 6, cmdtext);
	dcmd(pmspecoff, 9, cmdtext);
	dcmd(otorenk,7,cmdtext);
	dcmd(yarisekle, 9, cmdtext);
	dcmd(yarisdurdur, 11, cmdtext);
	dcmd(myskin, 6, cmdtext);
	dcmd(saveskin, 8, cmdtext);
	dcmd(mytime, 6, cmdtext);
	dcmd(t, 1, cmdtext);
	dcmd(myweather, 9, cmdtext);
	dcmd(w, 1, cmdtext);
	dcmd(radio, 5, cmdtext);
	dcmd(dinle, 5, cmdtext);
    if (strcmp("/gungamecik", cmdtext, true) == 0)
	{
	    if(Oyuncu[playerid][GunGamede] == false) return SendClientMessage(playerid,0xFF0000FF, "Hata » {FFFFFF}Zaten gungamede degilsiniz!");
		Oyuncu[playerid][GunGamede] = false;
		Oyuncu[playerid][GunGameLevel] = 0;
		SpawnPlayer(playerid);
		return 1;
	}
	if(Oyuncu[playerid][GunGamede] == true)
	{
	    SendClientMessage(playerid,0xFF0000FF, "Hata » {FFFFFF}Su an gungamede bulunuyorsunuz. Cikmak icin /gungamecik yazin.");
	    return 1;
	}
   	if (strcmp("/dmcik", cmdtext, true) == 0)
	{
	    if(Oyuncu[playerid][Dmde] == false) return SendClientMessage(playerid,0xFF0000FF, "Hata » {FFFFFF}Zaten dmde degilsiniz!");
		Oyuncu[playerid][DMModu] = 0;
		Oyuncu[playerid][Dmde] = false;
		ResetPlayerWeapons(playerid);
		SpawnPlayer(playerid);
		SetPlayerHealth(playerid, 100);
		SetPlayerArmour(playerid, 0);
		SetPlayerVirtualWorld(playerid, 0);
		SetPlayerInterior(playerid, 0);
		return 1;
	}
    if(Oyuncu[playerid][Dmde] == true)
	{
		SendClientMessage(playerid,0xFF0000FF, "Hata » {FFFFFF}Su an dmde bulunuyorsunuz. Cikmak icin /dmcik yazin.");
		return 1;
	}
	if (strcmp("/sos", cmdtext, true) == 0)
	{
		if(Oyuncu[playerid][Yarista] == false) return SendClientMessage(playerid,0xFF0000FF, "Hata » {FFFFFF}Bu komutu kullanabilmek için yarýþta olmalýsýnýz.");
		if(RaceStarted == false) return SendClientMessage(playerid,0xFF0000FF, "Hata » {FFFFFF}Yarýþýn baþlamasýný bekleyin.");
		SetPlayerPos(playerid, SosPos[playerid][0], SosPos[playerid][1], SosPos[playerid][2]);
		DestroyVehicle(CreatedRaceVeh[playerid]);
		CreatedRaceVeh[playerid] = CreateVehicle(RaceVehicle, SosPos[playerid][0], SosPos[playerid][1], SosPos[playerid][2], SosPos[playerid][3], -1, -1, -1);
		SetVehicleNumberPlate(CreatedRaceVeh[playerid], "{FF0000}LYNX");
	    SetVehicleVirtualWorld(CreatedRaceVeh[playerid], GetPlayerVirtualWorld(playerid));
	    PutPlayerInVehicle(playerid, CreatedRaceVeh[playerid], 0);
	    PlayerPlaySound(playerid, 1137, 0.0, 0.0, 0.0);
		SetVehiclePos(CreatedRaceVeh[playerid], SosPos[playerid][0], SosPos[playerid][1], SosPos[playerid][2]);
		SetVehicleZAngle(CreatedRaceVeh[playerid], SosPos[playerid][3]);
		SetVehicleVelocity(CreatedRaceVeh[playerid], SosHiz[playerid][0], SosHiz[playerid][1], SosHiz[playerid][2]);
		return 1;
	}
   	if (strcmp("/yariscik", cmdtext, true) == 0)
	{
	    if(Oyuncu[playerid][Yarista] == false) return SendClientMessage(playerid,0xFF0000FF, "Hata » {FFFFFF}Zaten yarýþta degilsiniz!");
	    JoinCount--;
		Oyuncu[playerid][Yarista] = false;
		DisableRemoteVehicleCollisions(playerid, 0);
		DestroyVehicle(CreatedRaceVeh[playerid]);
		DisablePlayerRaceCheckpoint(playerid);
		RemovePlayerMapIcon(playerid, RaceIcon);
		PlayerTextDrawHide(playerid, RaceInfo[playerid]);
		CPProgess[playerid] = 0;
		KillTimer(InfoTimer[playerid]);
		TogglePlayerControllable(playerid, true);
		SetCameraBehindPlayer(playerid);
		SetPlayerVirtualWorld(playerid, 0);
		SpawnPlayer(playerid);
		return 1;
	}
    if(Oyuncu[playerid][Yarista] == true)
	{
		SendClientMessage(playerid,0xFF0000FF, "Hata » {FFFFFF}Su an yarýþta bulunuyorsunuz. Cikmak icin /yariscik yazin.");
		return 1;
	}
	if(Oyuncu[playerid][Duelde])
	{
	    SendClientMessage(playerid,0xFF0000FF, "Hata » {FFFFFF}Su an duelloda bulunuyorsunuz. Duello bitmeden komut kullanamazsýnýz.");
		return 1;
	}
   	if (strcmp("/tdmcik", cmdtext, true) == 0)
	{
	    if(Oyuncu[playerid][TDM] == false)return SendClientMessage(playerid,0xFF0000FF, "Hata » {FFFFFF}Zaten tdmde degilsiniz!");
		Oyuncu[playerid][TDM_Team] = -1;
		Oyuncu[playerid][TDM] = false;
		TextDrawHideForPlayer(playerid, TDMTextdraw);
		LabelAyarla(playerid);
		SpawnPlayer(playerid);
		return 1;
	}
	if(Oyuncu[playerid][TDM] == true)
	{
        SendClientMessage(playerid,0xFF0000FF, "Hata » {FFFFFF}Su an tdmde bulunuyorsunuz. Cikmak icin /tdmcik yazin.");
		return 1;
	}
	dcmd(tdmler,6,cmdtext);
	dcmd(tdmkatil,8,cmdtext);
	dcmd(yariskatil, 10, cmdtext);
	dcmd(yarislar, 8, cmdtext);
	dcmd(gungame, 7, cmdtext);
	dcmd(duel, 4, cmdtext);
	dcmd(v1, 2, cmdtext);
	dcmd(v2, 2, cmdtext);
	dcmd(v3, 2, cmdtext);
	dcmd(v4, 2, cmdtext);
	dcmd(v5, 2, cmdtext);
	dcmd(v6, 2, cmdtext);
	dcmd(v7, 2, cmdtext);
	dcmd(v8, 2, cmdtext);
	dcmd(v9, 2, cmdtext);
	dcmd(v10, 3, cmdtext);
	dcmd(v11, 3, cmdtext);
	dcmd(v12, 3, cmdtext);
	dcmd(v13, 3, cmdtext);
	dcmd(v14, 3, cmdtext);
	dcmd(v15, 3, cmdtext);
	dcmd(v16, 3, cmdtext);
	dcmd(v17, 3, cmdtext);
	dcmd(veh, 3, cmdtext);
	dcmd(vrenk, 5, cmdtext);
	dcmd(vc, 2, cmdtext);
	dcmd(cc, 2, cmdtext);
	dcmd(savepos, 7, cmdtext);
	dcmd(loadpos, 7, cmdtext);
	dcmd(s, 1,cmdtext);
	dcmd(r, 1, cmdtext);
	dcmd(stats, 5, cmdtext);
	dcmd(admins, 6, cmdtext);
	dcmd(adminlistesi, 12, cmdtext);
	dcmd(djlistesi, 9, cmdtext);
	dcmd(djs, 3, cmdtext);
	dcmd(nickdegis,9,cmdtext);
	dcmd(sifredegis,10,cmdtext);
	dcmd(tune, 4, cmdtext);
	dcmd(mycar, 5, cmdtext);
	dcmd(ojump, 5, cmdtext);
	dcmd(dmzone, 6, cmdtext);
	dcmd(mg1, 3, cmdtext);
	dcmd(mg2, 3, cmdtext);
	dcmd(mg3, 3, cmdtext);
	dcmd(deagle, 6, cmdtext);
	dcmd(rpg, 3, cmdtext);
	dcmd(knifedm, 7, cmdtext);
	dcmd(sniperdm, 8, cmdtext);
	dcmd(pb1, 3, cmdtext);
	dcmd(pb2, 3, cmdtext);
	dcmd(pb3, 3, cmdtext);
	dcmd(snipshot, 8, cmdtext);
	dcmd(dgshot, 6, cmdtext);
	dcmd(topskor, 7, cmdtext);
	dcmd(toppara, 7, cmdtext);
	dcmd(topkill, 7, cmdtext);
	dcmd(topdeath, 8, cmdtext);
	dcmd(toponline, 9, cmdtext);
	if(!strcmp(cmdtext, "/drift1", true)){
        TeleportInfo(playerid, "Drift 1", "drift1");
		SetPlayerPosEx(playerid, -301.6903,1526.9238,75.3594);
        return 1;
    }
	if(!strcmp(cmdtext, "/drift2", true)){
        TeleportInfo(playerid, "Drift 2", "drift2");
		SetPlayerPosEx(playerid, 2326.6311,1389.7100,42.8203);
        return 1;
    }
	if(!strcmp(cmdtext, "/drift3", true)){
        TeleportInfo(playerid, "Drift 3", "drift3");
		SetPlayerPosEx(playerid, 1244.9348,-2043.1870,59.8570);
        return 1;
    }
	if(!strcmp(cmdtext, "/drift4", true)){
        TeleportInfo(playerid, "Drift 4", "drift4");
		SetPlayerPosEx(playerid, -2399.9873, -598.6679, 132.6484);
        return 1;
    }
	if(!strcmp(cmdtext, "/drift5", true)){
        TeleportInfo(playerid, "Drift 5", "drift5");
		SetPlayerPosEx(playerid, 1146.2200,2178.7068,10.8203);
        return 1;
    }
	if(!strcmp(cmdtext, "/drift6", true)){
        TeleportInfo(playerid, "Drift 6", "drift6");
		SetPlayerPosEx(playerid, 1886.9543,1813.2212,18.9339);
        return 1;
    }
 	if(!strcmp(cmdtext, "/drift7", true)){
        TeleportInfo(playerid, "Drift 7", "drift7");
		SetPlayerPosEx(playerid, -766.7427,-1730.1228,95.9759);
        return 1;
    }
  	if(!strcmp(cmdtext, "/drift8", true)){
        TeleportInfo(playerid, "Drift 8", "drift8");
		SetPlayerPosEx(playerid, 711.8475,2581.5981,25.2460);
        return 1;
    }
  	if(!strcmp(cmdtext, "/drift9", true)){
        TeleportInfo(playerid, "Drift 9", "drift9");
		SetPlayerPosEx(playerid, -2418.8452,81.8775,34.6797);
        return 1;
    }
  	if(!strcmp(cmdtext, "/drift10", true)){
        TeleportInfo(playerid, "Drift 10", "drift10");
		SetPlayerPosEx(playerid, 915.9879,-685.1018,116.0321);
        return 1;
    }
  	if(!strcmp(cmdtext, "/drift11", true)){
        TeleportInfo(playerid, "Drift 11", "drift11");
		SetPlayerPosEx(playerid, -771.1682,-100.2281,64.8293);
        return 1;
    }
  	if(!strcmp(cmdtext, "/drift12", true)){
        TeleportInfo(playerid, "Drift 12", "drift12");
		SetPlayerPosEx(playerid, 2847.8616,-758.0251,10.4511);
        return 1;
    }
  	if(!strcmp(cmdtext, "/drift13", true)){
        TeleportInfo(playerid, "Drift 13", "drift13");
		SetPlayerPosEx(playerid, -1822.0422,2670.2593,54.7437);
        return 1;
    }
  	if(!strcmp(cmdtext, "/drift14", true)){
        TeleportInfo(playerid, "Drift 14", "drift14");
		SetPlayerPosEx(playerid, 1636.9423,-1154.2665,23.6056);
        return 1;
    }
  	if(!strcmp(cmdtext, "/drift15", true)){
        TeleportInfo(playerid, "Drift 15", "drift15");
		SetPlayerPosEx(playerid, 1978.7637,2238.7798,26.8968);
        return 1;
    }
  	if(!strcmp(cmdtext, "/lvap", true)){
        TeleportInfo(playerid, "Las Venturas Airport", "lvap");
		SetPlayerPosEx(playerid, 1331.7628,1285.3923,10.8203);
        return 1;
    }
   	if(!strcmp(cmdtext, "/sfap", true)){
        TeleportInfo(playerid, "San Fierro Airport", "sfap");
		SetPlayerPosEx(playerid, -1294.6156,-13.6585,13.8755);
        return 1;
    }
   	if(!strcmp(cmdtext, "/olap", true)){
        TeleportInfo(playerid, "Old Airport", "olap");
		SetPlayerPosEx(playerid, 407.0780,2444.4668,18.4074);
        return 1;
    }
   	if(!strcmp(cmdtext, "/lsap", true)){
        TeleportInfo(playerid, "Los Santos Airport", "lsap");
		SetPlayerPosEx(playerid, 1954.2603,-2629.1553,13.6468);
        return 1;
    }
   	if(!strcmp(cmdtext, "/dag", true)){
        TeleportInfo(playerid, "Mount Chilliad", "dag");
		SetPlayerPosEx(playerid, -2317.5840,-1642.9214,483.7031);
        return 1;
    }
   	if(!strcmp(cmdtext, "/djmekan", true))
  	{
        TeleportInfo(playerid, "DJ Mekan", "djmekan");
     	SetPlayerPos(playerid, 1967.9197, 1912.4851, 936.6108);
     	SpawnDondur(playerid, 2);
        return 1;
    }
   	if(!strcmp(cmdtext, "/skilledinf", true))
   	{
        TeleportInfo(playerid, "Skilled Infernus", "skilledinf");
     	SetPlayerPos(playerid, -214.542678, -8175.392578, 35.225547);
     	SpawnDondur(playerid, 2);
        return 1;
    }
   	if(!strcmp(cmdtext, "/superstunt", true))
   	{
        TeleportInfo(playerid, "Super Stunt", "superstunt");
     	SetPlayerPos(playerid, 2410.961669,4172.320312,54.680434);
     	SpawnDondur(playerid, 2);
        return 1;
    }
   	if(!strcmp(cmdtext, "/cz", true))
  	{
		new Float:czz[2], Float:total, str[128];
		GetPlayerHealth(playerid, czz[0]);
		GetPlayerArmour(playerid, czz[1]);
		total = czz[0] + czz[1];
		if(total == 200) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Canýnýz full iken cz komutunu kullanamazsýnýz.");
		format(str, sizeof(str), "Bilgi » {FFFFFF}%d can+zirh aldýnýz. Ücret %d$", floatround(200-total), (floatround(200-total)*5));
		SendClientMessage(playerid, 0x66FFFFFF, str);
		SetPlayerHealth(playerid, 100);
		SetPlayerArmour(playerid, 100);
		GivePlayerCash(playerid, -(floatround(200-total)*5));
        return 1;
    }
    return HataliKomut(playerid, cmdtext);
}
dcmd_yarisekle(playerid, params[])
{
    #pragma unused params
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Bu komutu kullanmak için yetkiniz bulunmamakta.");
	if(BuildRace != 0) return 1;
	if(RaceBusy == 0x01) return 1;
	if(IsPlayerInAnyVehicle(playerid)) return 1;
	BuildRace = playerid+1;
	ShowDialog(playerid, 599);
	return 1;
}
dcmd_yarisdurdur(playerid, params[])
{
    #pragma unused params
   	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Bu komutu kullanmak için yetkiniz bulunmamakta.");
    if(RaceBusy == 0x00 || RaceStarted == false) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Zaten aktif bir yarýþ yok!");
	SendClientMessageToAll(0x66FFFFFF, "Bilgi » {FFFFFF}Admin yarýþý durdurdu.");
	StopRace();
	return 1;
}
dcmd_yariskatil(playerid, params[])
{
    #pragma unused params
	if(RaceStarted == true) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Yarýþ zaten baþladý. Bitmesini bekleyin!");
	if(RaceBusy == 0x00) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Baþlamýþ bir yarýþ yok. /Yarislar komutu ile istediðiniz yarýþý baþlatabilirsiniz.");
	if(Oyuncu[playerid][Yarista] == true) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Zaten yarýþa katýldýnýz.");
	if(IsPlayerInAnyVehicle(playerid))
	{
        SetTimerEx("SetupRaceForPlayer", 1000, 0, "e", playerid);
	 	RemovePlayerFromVehicle(playerid);
	 	Oyuncu[playerid][Yarista] = true;
	 	return 1;
	}
	SetupRaceForPlayer(playerid);
	Oyuncu[playerid][Yarista] = true;
	return 1;
}
dcmd_yarislar(playerid, params[])
{
    #pragma unused params
 	if(RaceBusy == 0x01) return SendClientMessage(playerid,0xFF0000FF, "Hata » {FFFFFF}Yarýþ daha bitmedi!");
	ShowPlayerDialog(playerid, DIALOG_RACE, DIALOG_STYLE_LIST,"{FF0000}LYNX DRIFT - {FFFFFF}Yaris Listesi", YarislarEx, "Baslat", "Iptal");
	return 1;
}
dcmd_mapyenile(playerid, params[])
{
    #pragma unused params
    if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Bu komutu kullanmak için yetkiniz bulunmamakta.");
 	LoadRaceNames();
	SendClientMessageToAll(0x66FFFFFF, "Bilgi » {FFFFFF}Yarýþ mapleri yenilendi");
	return 1;
}
dcmd_gungame(playerid, params[])
{
	#pragma unused params
	if(Oyuncu[playerid][GunGamede] == true) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Zaten gungame desin.");
	DeathmatchInfo(playerid, "GunGame","gungame");
	Oyuncu[playerid][GunGamede] = true;
	SetPlayerInterior(playerid, 10);
	SetPlayerVirtualWorld(playerid, 95);
	switch(random(5))
	{
	    case 0: SetPlayerPos(playerid, -975.1050, 1061.5844, 1345.6755);
	    case 1: SetPlayerPos(playerid, -1042.6305, 1031.9932, 1342.7920);
	    case 2: SetPlayerPos(playerid, -1089.8619, 1094.6024, 1343.4906);
	    case 3: SetPlayerPos(playerid, -1130.3995, 1057.9498, 1346.4141);
	    case 4: SetPlayerPos(playerid, -1078.9012, 1020.9278, 1342.7163);
	}
	SetCameraBehindPlayer(playerid);
	SetPlayerHealth(playerid, 100), SetPlayerArmour(playerid, 100);
 	GivePlayerGunLevel(playerid);
	return 1;
}
dcmd_duel(playerid, params[])
{
	if(Oyuncu[playerid][Duelde]) return SendClientMessage(playerid, 0x99CC00FF, "Duel » {FFFFFF}Zaten duellodasýnýz.");
	new target;
	if(sscanf(params, "i", target)) return SendClientMessage(playerid, 0x99CC00FF, "Duel » {FFFFFF}/duel <ID>");
	if(!IsPlayerConnected(target)) return SendClientMessage(playerid, 0x99CC00FF, "Duel » {FFFFFF}Rakip oyunda deðil.");
	if(Oyuncu[target][Duelde]) return SendClientMessage(playerid, 0x99CC00FF, "Duel » {FFFFFF}Rakip zaten bir duelloda.");
	if(target == playerid) return SendClientMessage(playerid, 0x99CC00FF, "Duel » {FFFFFF}Kendine duello isteði atamazsýn.");
	Oyuncu[playerid][DuelRakip] = target;
	Oyuncu[target][DuelRakip] = playerid;
	SendClientMessage(playerid, 0x99CC00FF, "Duel » {FFFFFF}1. duello silahýný seçiniz.");
 	new str[512];
  	format(str, 512, "{FF0000}» {FFFFFF}Testere\n{FF0000}» {FFFFFF}El Bombasý\n{FF0000}» {FFFFFF}Molotof\n{FF0000}» {FFFFFF}9mm\n{FF0000}» {FFFFFF}Silenced\n{FF0000}» {FFFFFF}Deagle\n{FF0000}» {FFFFFF}Shotgun\n{FF0000}» {FFFFFF}Sawn Off\n{FF0000}» {FFFFFF}Combat\n{FF0000}» {FFFFFF}Uzi\n{FF0000}» {FFFFFF}Mp5\n{FF0000}» {FFFFFF}Ak-47\n{FF0000}» {FFFFFF}M4\n{FF0000}» {FFFFFF}Tec-9\n{FF0000}» {FFFFFF}Rifle\n{FF0000}» {FFFFFF}Sniper");
	ShowPlayerDialog(playerid, DIALOG_DUEL_WEAPON, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Duello Silah 1", str, "Sec", "Iptal");
	return 1;
}
dcmd_setlevel(playerid, params[])
{
	new level, id;
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Bu komutu kullanmak için yetkiniz bulunmamakta.");
	if(sscanf(params, "ui", id, level)) return SendClientMessage(playerid, 0xFFCC33FF, "Kullanim » {FFFFFF}/setlevel <Player/ID> <Level>");
	if(!IsPlayerConnected(id)) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Oyuncu oyunda deðil.");
	if(level < 0 || level > 5) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Maximum level 5, minimum level 0 girebilirsiniz!");
	if(Oyuncu[playerid][Admin] < Oyuncu[id][Admin]) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Bu yöneticiye bu komutu kullanamazsýnýz.");
	new string[100];
	format(string, sizeof(string), "Bilgi » {FFFFFF}%s sizi %i seviye yonetici yapti.", PlayerName(playerid), level);
	SendClientMessage(id, 0x66FFFFFF, string);
	format(string, sizeof(string), "Bilgi » {FFFFFF}%s isimli oyuncuyu %i seviye yonetici yaptiniz.", PlayerName(id), level);
	SendClientMessage(playerid, 0x66FFFFFF, string);
	Oyuncu[id][Admin] = level;
	Oyuncu[id][DJ] = 0;
	LabelAyarla(id);
	return 1;
}
dcmd_setdj(playerid, params[])
{
	new level, id;
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Bu komutu kullanmak için yetkiniz bulunmamakta.");
	if(sscanf(params, "ui", id, level)) return SendClientMessage(playerid, 0xFFCC33FF, "Kullanim » {FFFFFF}/setdj <Player/ID> <Level>");
	if(!IsPlayerConnected(id)) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Oyuncu oyunda deðil.");
	if(level < 0 || level > 3) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Maximum level 3, minimum level 0 girebilirsiniz!");
	new string[100];
	format(string, sizeof(string), "Bilgi » {FFFFFF}%s sizi %i seviye DJ yapti.", PlayerName(playerid), level);
	SendClientMessage(id, 0x66FFFFFF, string);
	format(string, sizeof(string), "Bilgi » {FFFFFF}%s isimli oyuncuyu %i seviye DJ yaptiniz.", PlayerName(id), level);
	SendClientMessage(playerid, 0x66FFFFFF, string);
	Oyuncu[id][DJ] = level;
	Oyuncu[id][Admin] = 0;
	LabelAyarla(id);
	return 1;
}
dcmd_kick(playerid, params[])
{
	new id, sebep[76];
	if(Oyuncu[playerid][Admin] < 2) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Bu komutu kullanmak için yetkiniz bulunmamakta.");
	if(sscanf(params, "us[76]", id, sebep)) return SendClientMessage(playerid, 0xFFCC33FF, "Kullanim » {FFFFFF}/kick <Nick/ID> <Sebep>");
	if(!IsPlayerConnected(id)) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Oyuncu oyunda deðil.");
	if(Oyuncu[playerid][Admin] < Oyuncu[id][Admin]) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Bu yöneticiye bu komutu kullanamazsýnýz.");
	KickReason(id, sebep, PlayerName(playerid));
	return 1;
}
dcmd_ban(playerid, params[])
{
	new id, sebep[76];
	if(Oyuncu[playerid][Admin] < 3) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Bu komutu kullanmak için yetkiniz bulunmamakta.");
	if(sscanf(params, "us[76]", id, sebep)) return SendClientMessage(playerid, 0xFFCC33FF, "Kullanim » {FFFFFF}/ban <Nick/ID> <Sebep>");
	if(!IsPlayerConnected(id)) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Oyuncu oyunda deðil.");
	if(Oyuncu[playerid][Admin] < Oyuncu[id][Admin]) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Bu yöneticiye bu komutu kullanamazsýnýz.");
	BanReason(id, sebep, PlayerName(playerid));
	return 1;
}
dcmd_unbanip(playerid, params[])
{
	new ip[16],iString[128];
	if(Oyuncu[playerid][Admin] < 3) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Bu komutu kullanmak için yetkiniz bulunmamakta.");
	if(sscanf(params, "s[16]", ip)) return SendClientMessage(playerid, 0xFFCC33FF, "Kullanim » {FFFFFF}/unbanip <IP>");
	format(iString, sizeof(iString), "unbanip %s", params);
	SendRconCommand(iString);
	SendRconCommand("reloadbans");
	return 1;
}
dcmd_slock(playerid, params[])
{
	new lock[16],iString[128];
	if(Oyuncu[playerid][Admin] < 3) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Bu komutu kullanmak için yetkiniz bulunmamakta.");
	switch(Locked)
	{
	    case true:
		{
		    Locked = false;
			SendRconCommand("password 0");
		}
	    case false:
		{
		    if(sscanf(params, "s[16]", lock)) return SendClientMessage(playerid, 0xFFCC33FF, "Kullanim » {FFFFFF}/slock <Sifre>");
		    Locked = true;
		    format(iString, sizeof(iString), "password %s", lock);
			SendRconCommand(iString);
		}
	}
	return 1;
}
dcmd_nban(playerid, params[])
{
	new id, sebep[76];
	if(Oyuncu[playerid][Admin] < 3) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Bu komutu kullanmak için yetkiniz bulunmamakta.");
	if(sscanf(params, "us[76]", id, sebep)) return SendClientMessage(playerid, 0xFFCC33FF, "Kullanim » {FFFFFF}/nban <Nick/ID> <Sebep>");
	if(!IsPlayerConnected(id)) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Oyuncu oyunda deðil.");
	if(Oyuncu[playerid][Admin] < Oyuncu[id][Admin]) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Bu yöneticiye bu komutu kullanamazsýnýz.");
	Oyuncu[id][NBan] = 1;
	new query[128];
	mysql_format(g_SQL, query, sizeof(query), "UPDATE `hesaplar` SET `player_nban` = '1' WHERE `player_id` = '%i'", Oyuncu[id][SQL]);
	mysql_tquery(g_SQL, query);
  	NBanReason(id, sebep, PlayerName(playerid));
	return 1;
}
dcmd_mute(playerid, params[])
{
	new id, sebep[76];
	if(Oyuncu[playerid][Admin] < 1) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Bu komutu kullanmak için yetkiniz bulunmamakta.");
	if(sscanf(params, "us[76]", id, sebep)) return SendClientMessage(playerid, 0xFFCC33FF, "Kullanim » {FFFFFF}/mute <Nick/ID> <Sebep>");
	if(!IsPlayerConnected(id)) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Oyuncu oyunda deðil.");
	if(Oyuncu[playerid][Admin] < Oyuncu[id][Admin]) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Bu yöneticiye bu komutu kullanamazsýnýz.");
	new string[156];
	format(string,sizeof(string),"Bilgi » {FFFFFF}Admin %s, %s'i muteledi. - Sebep: %s", PlayerName(playerid), PlayerName(id), sebep);
	SendClientMessageToAll(0x66FFFFFF, string);
	Oyuncu[id][Muted] = true;
	return 1;
}
dcmd_unmute(playerid, params[])
{
	new id;
	if(Oyuncu[playerid][Admin] < 1) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Bu komutu kullanmak için yetkiniz bulunmamakta.");
	if(sscanf(params, "u", id)) return SendClientMessage(playerid, 0xFFCC33FF, "Kullanim » {FFFFFF}/unmute <Nick/ID>");
	if(!IsPlayerConnected(id)) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Oyuncu oyunda deðil.");
	if(Oyuncu[playerid][Admin] < Oyuncu[id][Admin]) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Bu yöneticiye bu komutu kullanamazsýnýz.");
	new string[156];
	format(string,sizeof(string),"Bilgi » {FFFFFF}Admin %s, %s'i un-muteledi.", PlayerName(playerid), PlayerName(id));
 	SendClientMessageToAll(0x66FFFFFF, string);
	Oyuncu[id][Muted] = false;
	return 1;
}
dcmd_setcolor(playerid, params[])
{
	if(Oyuncu[playerid][Admin] < 1) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Bu komutu kullanmak için yetkiniz bulunmamakta.");
	new id, hex;
	if(sscanf(params,"uh",id, hex)) return SendClientMessage(playerid, 0xFFCC33FF, "Kullanim » {FFFFFF}/setcolor <Player/ID> <Hex>");
	SetPlayerColor(id, hex);
	LabelAyarla(id);
	SendClientMessage(id, 0x66FFFFFF, "Bilgi » {FFFFFF}Nick renginiz baþarýlý bir þekilde deðiþtirildi.");
	return 1;
}
dcmd_aka(playerid,params[])
{
 	new id, str[156];
	if(Oyuncu[playerid][Admin] < 2) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Bu komutu kullanmak için yetkiniz bulunmamakta.");
	if(sscanf(params, "u", id)) return SendClientMessage(playerid, 0xFFCC33FF, "Kullanim » {FFFFFF}/aka <Player/ID>");
	if(!IsPlayerConnected(id)) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Oyuncu oyunda deðil.");
	if(Oyuncu[playerid][Admin] < Oyuncu[id][Admin]) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Bu yöneticiye bu komutu kullanamazsýnýz.");
	format(str,sizeof(str),"{FFFFFF}%s", dini_Get("LYNX/Diger/Aka.txt", Oyuncu[id][IP]));
	ShowPlayerDialog(playerid, DIALOG_AKA, DIALOG_STYLE_MSGBOX, "{FF0000}LYNX DRIFT - {FFFFFF}Aka", str, "Tamam", "");
	return 1;
}
dcmd_givecash(playerid, params[])
{
	new id, miktar;
	if(Oyuncu[playerid][Admin] < 5) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Bu komutu kullanmak için yetkiniz bulunmamakta.");
	if(sscanf(params, "ud", id, miktar)) return SendClientMessage(playerid, 0xFFCC33FF, "Kullanim » {FFFFFF}/givecash <Player/ID> <Para>");
	if(!IsPlayerConnected(id)) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Oyuncu oyunda deðil.");
	if(Oyuncu[playerid][Admin] < Oyuncu[id][Admin]) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Bu yöneticiye bu komutu kullanamazsýnýz.");
	new string[100];
	format(string, sizeof(string), "Bilgi » {FFFFFF}%s(%i) isimli oyuncuya $%d verdiniz.", PlayerName(id), id, miktar);
	SendClientMessage(playerid, 0x66FFFFFF, string);
	format(string, sizeof(string), "Bilgi » {FFFFFF}Admin %s(%i) size $%d verdi.", PlayerName(playerid), playerid, miktar);
	SendClientMessage(id, 0x66FFFFFF, string);
	GivePlayerCash(id, miktar);
	return 1;
}
dcmd_giveexp(playerid, params[])
{
	new id, miktar;
	if(Oyuncu[playerid][Admin] < 5) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Bu komutu kullanmak için yetkiniz bulunmamakta.");
	if(sscanf(params, "ud", id, miktar)) return SendClientMessage(playerid, 0xFFCC33FF, "Kullanim » {FFFFFF}/giveexp <Player/ID> <Exp>");
	if(!IsPlayerConnected(id)) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Oyuncu oyunda deðil.");
	if(Oyuncu[playerid][Admin] < Oyuncu[id][Admin]) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Bu yöneticiye bu komutu kullanamazsýnýz.");
	new string[100];
	format(string, sizeof(string), "Bilgi » {FFFFFF}%s(%i) isimli oyuncuya %d exp verdiniz.", PlayerName(id), id, miktar);
	SendClientMessage(playerid, 0x66FFFFFF, string);
	format(string, sizeof(string), "Bilgi » {FFFFFF}Admin %s(%i) size %d exp verdi.", PlayerName(playerid), playerid, miktar);
	SendClientMessage(id, 0x66FFFFFF, string);
	GivePlayerExp(id, miktar);
	return 1;
}
dcmd_setscore(playerid, params[])
{
	new id, miktar;
	if(Oyuncu[playerid][Admin] < 5) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Bu komutu kullanmak için yetkiniz bulunmamakta.");
	if(sscanf(params, "ud", id, miktar)) return SendClientMessage(playerid, 0xFFCC33FF, "Kullanim » {FFFFFF}/setscore <Player/ID> <Skor>");
	if(!IsPlayerConnected(id)) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Oyuncu oyunda deðil.");
	if(Oyuncu[playerid][Admin] < Oyuncu[id][Admin]) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Bu yöneticiye bu komutu kullanamazsýnýz.");
	new string[100];
	format(string, sizeof(string), "Bilgi » {FFFFFF}%s(%i) isimli oyuncunun skorunu %d olarak ayarladiniz.", PlayerName(id), id, miktar);
	SendClientMessage(playerid, 0x66FFFFFF, string);
	format(string, sizeof(string), "Bilgi » {FFFFFF}Admin %s(%i) sizin skorunuzu %d olarak ayarladi.", PlayerName(playerid), playerid, miktar);
	SendClientMessage(id, 0x66FFFFFF, string);
	SetPlayerScore(id, miktar);
	return 1;
}
dcmd_setheal(playerid, params[])
{
	new id, miktar;
	if(Oyuncu[playerid][Admin] < 5) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Bu komutu kullanmak için yetkiniz bulunmamakta.");
	if(sscanf(params, "ud", id, miktar)) return SendClientMessage(playerid, 0xFFCC33FF, "Kullanim » {FFFFFF}/setheal <Player/ID> <Can>");
	if(!IsPlayerConnected(id)) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Oyuncu oyunda deðil.");
	if(Oyuncu[playerid][Admin] < Oyuncu[id][Admin]) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Bu yöneticiye bu komutu kullanamazsýnýz.");
	new string[100];
	format(string, sizeof(string), "Bilgi » {FFFFFF}%s(%i) isimli oyuncunun canýný %d olarak ayarladiniz.", PlayerName(id), id, miktar);
	SendClientMessage(playerid, 0x66FFFFFF, string);
	format(string, sizeof(string), "Bilgi » {FFFFFF}Admin %s(%i) sizin canýnýzý %d olarak ayarladi.", PlayerName(playerid), playerid, miktar);
	SendClientMessage(id, 0x66FFFFFF, string);
	SetPlayerHealth(id, miktar);
	return 1;
}
dcmd_setarmour(playerid, params[])
{
	new id, miktar;
	if(Oyuncu[playerid][Admin] < 5) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Bu komutu kullanmak için yetkiniz bulunmamakta.");
	if(sscanf(params, "ud", id, miktar)) return SendClientMessage(playerid, 0xFFCC33FF, "Kullanim » {FFFFFF}/setarmour <Player/ID> <Zirh>");
	if(!IsPlayerConnected(id)) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Oyuncu oyunda deðil.");
	if(Oyuncu[playerid][Admin] < Oyuncu[id][Admin]) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Bu yöneticiye bu komutu kullanamazsýnýz.");
	new string[100];
	format(string, sizeof(string), "Bilgi » {FFFFFF}%s(%i) isimli oyuncunun zýrhýný %d olarak ayarladiniz.", PlayerName(id), id, miktar);
	SendClientMessage(playerid, 0x66FFFFFF, string);
	format(string, sizeof(string), "Bilgi » {FFFFFF}Admin %s(%i) sizin zýrhýnýzý %d olarak ayarladi.", PlayerName(playerid), playerid, miktar);
	SendClientMessage(id, 0x66FFFFFF, string);
	SetPlayerArmour(id, miktar);
	return 1;
}
dcmd_sarki(playerid, params[])
{
	new miktar[256];
	if(Oyuncu[playerid][Admin] < 1 && Oyuncu[playerid][DJ] < 1) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Bu komutu kullanmak için yetkiniz bulunmamakta.");
	if(sscanf(params, "s[256]", miktar)) return SendClientMessage(playerid, 0xFFCC33FF, "Kullanim » {FFFFFF}/sarki <Url>");
	new string[160];
	format(string, sizeof(string), "Bilgi » {FFFFFF}%s bir muzik baslatti. Kapatmak istiyorsanýz /mkapat yaziniz.", PlayerName(playerid));
	SendClientMessageToAll(0x66FFFFFF, string);
	PlayAudioStreamForAll(miktar);
	return 1;
}
dcmd_mkapat(playerid, params[])
{
	#pragma unused params
	Oyuncu[playerid][MuzikIzin] = false;
	StopAudioStreamForPlayer(playerid);
    SendClientMessage(playerid, 0x66FFFFFF, "Bilgi » {FFFFFF}Çalan müziði kapattýnýz. Tekrar dinlemek için /yayinac yaziniz.");
	return 1;
}
dcmd_dinle(playerid, params[])
{
	new miktar[256];
	if(sscanf(params, "s[256]", miktar)) return SendClientMessage(playerid, 0xFFCC33FF, "Kullanim » {FFFFFF}/dinle <Url>");
	Oyuncu[playerid][MuzikIzin] = false;
	SendClientMessage(playerid, 0x66FFFFFF, "Bilgi » {FFFFFF}Kendinize bi müzik açtýnýz.");
	StopAudioStreamForPlayer(playerid);
	PlayAudioStreamForPlayer(playerid, miktar);
	return 1;
}
dcmd_yayinac(playerid, params[])
{
 	#pragma unused params
    Oyuncu[playerid][MuzikIzin] = true;
    StopAudioStreamForPlayer(playerid);
    PlayAudioStreamForPlayer(playerid, SonMuzik);
	SendClientMessage(playerid, 0x66FFFFFF, "Bilgi » {FFFFFF}En son açýlan müziði açtýnýz. Kapatmak için /mkapat yaziniz.");
	return 1;
}
dcmd_goto(playerid, params[])
{
    new id, String[128];
	if(Oyuncu[playerid][Admin] < 1) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Bu komutu kullanmak için yetkiniz bulunmamakta.");
	if(sscanf(params,"u", id)) return SendClientMessage(playerid, 0xFFCC33FF, "Kullanim » {FFFFFF}/goto <Player/ID>");
    if(!IsPlayerConnected(id)) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Oyuncu oyunda deðil.");
    if(playerid == id) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Kendinize teleport olamazsýnýz.");
    new Float:x, Float:y, Float:z;
    GetPlayerPos(id, x, y, z);
    SetPlayerPosEx(playerid, x+1, y+1, z+1);
    SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(id));
    SetPlayerInterior(playerid, GetPlayerInterior(id));
   	format(String, sizeof(String), "Bilgi » {FFFFFF}%s(%i) adlý oyuncuya ýþýnlandýnýz.", PlayerName(id), id);
    SendClientMessage(playerid, 0x66FFFFFF, String);
	format(String, sizeof(String), "Bilgi » {FFFFFF}%s(%i) adlý oyuncu size ýþýnlandý.", PlayerName(playerid), playerid);
    SendClientMessage(id, 0x66FFFFFF, String);
	return 1;
}
dcmd_get(playerid, params[])
{
	new id, Float:MyPos[3], String[128];
	if(Oyuncu[playerid][Admin] < 1) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Bu komutu kullanmak için yetkiniz bulunmamakta.");
	if(sscanf(params,"u", id)) return SendClientMessage(playerid, 0xFFCC33FF, "Kullanim » {FFFFFF}/get <Player/ID>");
	if(!IsPlayerConnected(id)) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Oyuncu oyunda deðil.");
	if(playerid == id) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Kendinizi çekemezsiniz.");
	GetPlayerPos(playerid, MyPos[0], MyPos[1], MyPos[2]);
	SetPlayerPosEx(id, MyPos[0], MyPos[1], MyPos[2]);
    SetPlayerVirtualWorld(id, GetPlayerVirtualWorld(playerid));
    SetPlayerInterior(id, GetPlayerInterior(playerid));
    format(String, sizeof(String), "Bilgi » {FFFFFF}%s(%i) adlý oyuncuyu çektiniz.", PlayerName(id), id);
    SendClientMessage(playerid, 0x66FFFFFF, String);
    format(String, sizeof(String), "Bilgi » {FFFFFF}%s(%i) adlý admin sizi çekti.", PlayerName(playerid), playerid);
    SendClientMessage(id, 0x66FFFFFF, String);
	return 1;
}
dcmd_rac(playerid, params[])
{
    #pragma unused params
    new str[128];
	if(Oyuncu[playerid][Admin] < 1) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Bu komutu kullanmak için yetkiniz bulunmamakta.");
	format(str, sizeof(str),"Bilgi » {FFFFFF}%s isimli admin kullanýlmayan araçlarý spawnladý", PlayerName(playerid));
	SendClientMessageToAll(0x66FFFFFF, str);
	for(new a = 1; a <= MAX_VEHICLES; a++)
	{
	    if(IsVehicleEmpty(a)) SetVehicleToRespawn(a);
	}
	return 1;
}
dcmd_setalltime(playerid, params[])
{
	new id;
	if(Oyuncu[playerid][Admin] < 4) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Bu komutu kullanmak için yetkiniz bulunmamakta.");
	if(sscanf(params, "i", id)) return SendClientMessage(playerid, 0xFFCC33FF, "Kullanim » {FFFFFF}/setalltime <Saat>");
 	if(id < 0 || id > 24) return 1;
	new string[128];
	format(string, 156, "Bilgi » {FFFFFF}%s tarafindan zaman %d olarak ayarlandi.", PlayerName(playerid), id, id);
	SetWorldTime(id);
	SendClientMessageToAll(0x66FFFFFF, string);
	return 1;
}
dcmd_setallweather(playerid, params[])
{
	new id;
	if(Oyuncu[playerid][Admin] < 4) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Bu komutu kullanmak için yetkiniz bulunmamakta.");
	if(sscanf(params, "i", id)) return SendClientMessage(playerid, 0xFFCC33FF, "Kullanim » {FFFFFF}/setallweather <Hava>");
	new string[156];
	format(string, 156, "Bilgi » {FFFFFF}%s tarafindan hava %d olarak ayarlandi.", PlayerName(playerid), id, id);
	SetWeather(id);
	SendClientMessageToAll(0x66FFFFFF, string);
	return 1;
}
dcmd_gopos(playerid,params[])
{
	if(Oyuncu[playerid][Admin]<5)return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Bu komutu kullanmak için yetkiniz bulunmamakta.");
	new Float:x, Float:y, Float:z;
	if(sscanf(params,"p<,>fff", x, y, z))return SendClientMessage(playerid, 0xFFCC33FF, "Kullanim » {FFFFFF}/gopos <X> <Y> <Z>");
	SetPlayerPos(playerid, x, y, z);
	return 1;
}
dcmd_cc(playerid, params[])
{
 	#pragma unused params
	if(Oyuncu[playerid][Admin] < 1 && Oyuncu[playerid][DJ] < 2) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Bu komutu kullanmak için yetkiniz bulunmamakta.");
	for(new i = 0; i < 50; i++) SendClientMessageToAll(-1, "");
	new string[75];
	format(string, sizeof(string), "Bilgi » {FFFFFF}%s Sohbeti Temizledi.", PlayerName(playerid));
	SendClientMessageToAll(0x66FFFFFF, string);
	return 1;
}
dcmd_spec(playerid,params[])
{
	new id;
	if(Oyuncu[playerid][Admin] < 1) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Bu komutu kullanmak için yetkiniz bulunmamakta.");
	if(sscanf(params, "u", id)) return SendClientMessage(playerid, 0xFFCC33FF, "Kullanim » {FFFFFF}/spec <Player/ID>");
	if(!IsPlayerConnected(id)) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Oyuncu oyunda deðil.");
	if(Oyuncu[playerid][Admin] < Oyuncu[id][Admin]) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Bu yöneticiye bu komutu kullanamazsýnýz.");
	if(playerid == id) return 1;
	StartSpectate(playerid, id);
	return 1;
}

dcmd_specoff(playerid,params[])
{
    #pragma unused params
	if(Oyuncu[playerid][Admin] < 1) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Bu komutu kullanmak için yetkiniz bulunmamakta.");
	if(Oyuncu[playerid][SpecType] == ADMIN_SPEC_TYPE_NONE) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Zaten specte deðilsin.");
	StopSpectate(playerid);
	SendClientMessage(playerid, 0x66FFFFFF,"Bilgi » {FFFFFF}Izleme gorevi sona erdi.");
	return 1;
}
dcmd_pmspec(playerid,params[])
{
    #pragma unused params
	if(Oyuncu[playerid][Admin] < 4) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Bu komutu kullanmak için yetkiniz bulunmamakta.");
    for(new j = 0; j < 7; j++) TextDrawShowForPlayer(playerid, PmText[j]);
	return 1;
}
dcmd_pmspecoff(playerid,params[])
{
    #pragma unused params
	if(Oyuncu[playerid][Admin] < 4) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Bu komutu kullanmak için yetkiniz bulunmamakta.");
    for(new j = 0; j < 7; j++) TextDrawHideForPlayer(playerid, PmText[j]);
	return 1;
}
dcmd_pm(playerid, params[])
{
	new id, pm[128], string[40+128];
	if(sscanf(params, "us[128]", id, pm)) return SendClientMessage(playerid, 0xFFCC33FF, "Kullanim » {FFFFFF}/pm <Player/ID> <Mesaj>");
	if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Oyuncu oyunda deðil.");
	if(Oyuncu[id][PMengel] == false) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Özel mesaj alýmý kapalý.");
	PlayerPlaySound(id, 1085, 0.0, 0.0, 0.0);
	format(string, sizeof(string), "» PM Gönderildi {%06x}%s(%d) : {FFFFFF}%s", GetPlayerColor(id) >>> 8, PlayerName(id),id, pm);
	SendClientMessage(playerid, 0xFFFF00FF, string);
	format(string, sizeof(string), "» PM Geldi {%06x}%s(%d) : {FFFFFF}%s", GetPlayerColor(playerid) >>> 8, PlayerName(playerid),playerid, pm);
	SendClientMessage(id, 0xFFFF00FF, string);
    Oyuncu[playerid][LastPM] = id;
    Oyuncu[id][LastPM] = playerid;
    PmYolla(playerid, id, pm);
 	return 1;
}
dcmd_re(playerid, params[])
{
    #define isnull(%1) ((!(%1[0])) || (((%1[0]) == '\1') && (!(%1[1]))))
	new string[40+128];
	new id = Oyuncu[playerid][LastPM];
	if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Daha önce özel mesaj almamýþsýnýz.");
	if(Oyuncu[id][PMengel] == false) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Özel mesaj alýmý kapalý.");
	if(!IsPlayerConnected(id)) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Oyuncu oyunda deðil.");
	if(isnull(params)) return SendClientMessage(playerid, 0xFFCC33FF, "Kullanim » {FFFFFF}/re <Mesaj>");
	PlayerPlaySound(id, 1085, 0.0, 0.0, 0.0);
	format(string, sizeof(string), "» PM Gönderildi {%06x}%s(%d) : {FFFFFF}%s", GetPlayerColor(id) >>> 8, PlayerName(id),id, params);
	SendClientMessage(playerid, 0xFFFF00FF, string);
	format(string, sizeof(string), "» PM Geldi {%06x}%s(%d) : {FFFFFF}%s", GetPlayerColor(playerid) >>> 8, PlayerName(playerid),playerid, params);
	SendClientMessage(id, 0xFFFF00FF, string);
	Oyuncu[playerid][LastPM] = id;
 	Oyuncu[id][LastPM] = playerid;
	PmYolla(playerid, id, params);
	return 1;
}
stock PmYolla(playerid, id, msg[])
{
	new str[256];
    new j = 0;
    while(msg[j] != EOS)
    {
        if(msg[j] == '~') msg[j] = ' ';
        j++;
    }
    format(str, sizeof(str), "~g~~h~~h~[PM] ~r~~h~%s(%d) ~w~~h~>> ~b~~h~%s(%d): ~w~~h~%s", PlayerName(playerid), playerid, PlayerName(id), id, msg);
    SendPMToBox(TurkceKarakter(str));
    return 1;
}
dcmd_pmon(playerid, params[])
{
    #pragma unused params
    Oyuncu[playerid][PMengel] = true;
    SendClientMessage(playerid,0x66FFFFFF,"Bilgi » {FFFFFF}PM açýldý.");
	return 1;
}
dcmd_pmoff(playerid, params[])
{
    #pragma unused params
    Oyuncu[playerid][PMengel] = false;
    SendClientMessage(playerid,0x66FFFFFF,"Bilgi » {FFFFFF}PM kapatýldý.");
	return 1;
}
dcmd_l(playerid, params[])
{
    new Float:X,Float:Y,Float:Z, String[128], Yazi[128];
    if(sscanf(params,"s[128]", Yazi)) return SendClientMessage(playerid, 0xFFCC33FF, "Kullanim » {FFFFFF}/l <Mesaj>");
   	GetPlayerPos(playerid,X,Y,Z);
    format(String, sizeof(String), "« LOCAL » {FFFFFF}%s(%d): {0099FF}%s", PlayerName(playerid),playerid, Yazi);
    foreach(new i: Player)
	{
    	if(IsPlayerInRangeOfPoint(i, 50, X, Y, Z))
    	{
    		SendClientMessage(i, GetPlayerColor(playerid), String);
    	}
    }
    SetPlayerChatBubble(playerid, Yazi, GetPlayerColor(playerid), 100.0, 10000);
	return 1;
}
dcmd_v1(playerid, params[])
{
    #pragma unused params
	ShowModelSelectionMenu(playerid, v1, "~r~~h~V1");
	return 1;
}
dcmd_v2(playerid, params[])
{
    #pragma unused params
	ShowModelSelectionMenu(playerid, v2, "~r~~h~V2");
	return 1;
}
dcmd_v3(playerid, params[])
{
    #pragma unused params
	ShowModelSelectionMenu(playerid, v3, "~r~~h~V3");
	return 1;
}
dcmd_v4(playerid, params[])
{
    #pragma unused params
	ShowModelSelectionMenu(playerid, v4, "~r~~h~V4");
	return 1;
}
dcmd_v5(playerid, params[])
{
    #pragma unused params
	ShowModelSelectionMenu(playerid, v5, "~r~~h~V5");
	return 1;
}
dcmd_v6(playerid, params[])
{
    #pragma unused params
	ShowModelSelectionMenu(playerid, v6, "~r~~h~V6");
	return 1;
}
dcmd_v7(playerid, params[])
{
    #pragma unused params
	ShowModelSelectionMenu(playerid, v7, "~r~~h~V7");
	return 1;
}
dcmd_v8(playerid, params[])
{
    #pragma unused params
	ShowModelSelectionMenu(playerid, v8, "~r~~h~V8");
	return 1;
}
dcmd_v9(playerid, params[])
{
    #pragma unused params
	ShowModelSelectionMenu(playerid, v9, "~r~~h~V9");
	return 1;
}
dcmd_v10(playerid, params[])
{
    #pragma unused params
	ShowModelSelectionMenu(playerid, v10, "~r~~h~V10");
	return 1;
}
dcmd_v11(playerid, params[])
{
    #pragma unused params
	ShowModelSelectionMenu(playerid, v11, "~r~~h~V11");
	return 1;
}
dcmd_v12(playerid, params[])
{
    #pragma unused params
	ShowModelSelectionMenu(playerid, v12, "~r~~h~V12");
	return 1;
}
dcmd_v13(playerid, params[])
{
    #pragma unused params
	ShowModelSelectionMenu(playerid, v13, "~r~~h~V13");
	return 1;
}
dcmd_v14(playerid, params[])
{
    #pragma unused params
	ShowModelSelectionMenu(playerid, v14, "~r~~h~V14");
	return 1;
}
dcmd_v15(playerid, params[])
{
    #pragma unused params
	ShowModelSelectionMenu(playerid, v15, "~r~~h~V15");
	return 1;
}
dcmd_v16(playerid, params[])
{
    #pragma unused params
	ShowModelSelectionMenu(playerid, v16, "~r~~h~V16");
	return 1;
}
dcmd_v17(playerid, params[])
{
    #pragma unused params
	ShowModelSelectionMenu(playerid, v17, "~r~~h~V17");
	return 1;
}
dcmd_dmzone(playerid, params[])
{
    #pragma unused params
	new dialogyazi[1000];
	format(dialogyazi, sizeof(dialogyazi),"{FF0000}DMZone\t\t{FF0000}Komut\n\
										   {FFFFFF}Minigun DM\t\t/mg1\n\
											       Minigun-2 DM\t\t/mg2\n\
												   Minigun-3 DM\t\t/mg3\n\
												   Deagle DM\t\t/deagle\n\
												   RPG DM\t\t/rpg\n\
												   Knife DM\t\t/knifedm\n\
												   Sniper DM\t\t/sniperdm\n\
												   Paint Ball\t\t/pb1\n\
												   Paint Ball-2\t\t/pb2\n\
										 		   Paint Ball-3\t\t/pb3\n\
												   Sniper-Shotgun\t\t/snipshot\n\
												   Deagle-Shotgun\t\t/dgshot");
	ShowPlayerDialog(playerid, DIALOG_DMZONE, DIALOG_STYLE_TABLIST_HEADERS, "{FF0000}LYNX DRIFT - {FFFFFF}DMZone", dialogyazi, "Sec", "Iptal");
	return 1;
}
dcmd_s(playerid, params[]) return dcmd_savepos(playerid, params);
dcmd_savepos(playerid, params[])
{
    #pragma unused params
 	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Bir araçta olmalýsýnýz");
	GetPlayerPos(playerid, myPos[playerid][0], myPos[playerid][1], myPos[playerid][2]);
	GetVehicleZAngle(GetPlayerVehicleID(playerid), myPos[playerid][3]);
	Oyuncu[playerid][Posaldim] = true;
	SendClientMessage(playerid,0x66FFFFFF,"Bilgi » {FFFFFF}Bulunduðunuz alan kayýt edildi!");
	return 1;
}
dcmd_r(playerid, params[])return dcmd_loadpos(playerid, params);
dcmd_loadpos(playerid, params[])
{
    #pragma unused params
	if(Oyuncu[playerid][Posaldim] == false) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Ilk önce /savepos komutunu kullanýn.");
	SetPlayerPosEx(playerid,  myPos[playerid][0], myPos[playerid][1], myPos[playerid][2]);
	SetVehicleZAngle(GetPlayerVehicleID(playerid), myPos[playerid][3]);
	SendClientMessage(playerid,0x66FFFFFF,"Bilgi » {FFFFFF}Kayýt ettiðiniz bölgeye gittiniz.");
	return 1;
}
dcmd_saveskin(playerid, params[])
{
    #pragma unused params
	Oyuncu[playerid][Skin] = GetPlayerSkin(playerid);
	SendClientMessage(playerid,0x66FFFFFF,"Bilgi » {FFFFFF}Skininiz kayýt edildi!");
	return 1;
}
dcmd_veh(playerid,params[])
{
	new aracid, Float:X, Float:Y, Float:Z, Float:Angle;
	if(!strlen(params)) return SendClientMessage(playerid, 0xFFCC33FF, "Kullanim » {FFFFFF}/veh <Arac ID/Isim>");
	if(!IsNumeric(params))
	{
 		aracid = AracIsimiGiris(params);
	}else
	{
		aracid = strval(params);
	}
	if(aracid < 400 || aracid > 611) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Böyle bir araç yok.");
	if((aracid == 520 || aracid == 432 || aracid == 425 || aracid == 447 || aracid == 464 || aracid == 465) && Oyuncu[playerid][Admin] < 5)return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Bu aracý alamazsýnýz.");
    if(Oyuncu[playerid][Araba] == true)
	{
		DestroyVehicle(Oyuncu[playerid][Arabam]);
		Oyuncu[playerid][Araba] = false;
	}
    GetPlayerPos(playerid,X,Y,Z);
	GetPlayerFacingAngle(playerid,Angle);
	Oyuncu[playerid][Arabam] = CreateVehicle(aracid,X,Y,Z,Angle,-1,-1,-1);
	SetVehicleNumberPlate(Oyuncu[playerid][Arabam], "{FF0000}LYNX");
	SetVehicleVirtualWorld(Oyuncu[playerid][Arabam],GetPlayerVirtualWorld(playerid));
	LinkVehicleToInterior(Oyuncu[playerid][Arabam],GetPlayerInterior(playerid));
	PutPlayerInVehicle(playerid,Oyuncu[playerid][Arabam],0);
	Oyuncu[playerid][Araba] = true;
	return 1;
}
dcmd_vc(playerid,params[])return dcmd_vrenk(playerid,params);
dcmd_vrenk(playerid, params[])
{
    new color1,color2;
    if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Araçta bulunmalýsýnýz.");
    if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Sürücü olmalýsýnýz.");
   	if(sscanf(params,"ii", color1, color2)) return SendClientMessage(playerid, 0xFFCC33FF, "Kullanim » {FFFFFF}/vrenk <Renk 1> <Renk 2>");
    if(color1 < 0 || color1 > 255 || color2 < 0 || color2 > 255) return 1;
    ChangeVehicleColor(GetPlayerVehicleID(playerid), color1, color2);
    SendClientMessage(playerid,0x66FFFFFF, "Bilgi » {FFFFFF}Araç renginizi deðiþtirdiniz.");
    return 1;
}
dcmd_t(playerid,params[])return dcmd_mytime(playerid,params);
dcmd_mytime(playerid, params[])
{
    new time;
   	if(sscanf(params,"i", time)) return SendClientMessage(playerid, 0xFFCC33FF, "Kullanim » {FFFFFF}/mytime <Saat>");
    if(time < 0 || time > 24) return 1;
    SetPlayerTime(playerid, time,0);
	SendClientMessage(playerid,0x66FFFFFF, "Bilgi » {FFFFFF}Oyun saatini deðiþtirdiniz.");
    return 1;
}
dcmd_w(playerid,params[])return dcmd_myweather(playerid,params);
dcmd_myweather(playerid, params[])
{
    new weather;
   	if(sscanf(params,"i", weather)) return SendClientMessage(playerid, 0xFFCC33FF, "Kullanim » {FFFFFF}/myweather <Hava>");
    SetPlayerWeather(playerid, weather);
	SendClientMessage(playerid,0x66FFFFFF, "Bilgi » {FFFFFF}Oyun havasýný deðiþtirdiniz.");
    return 1;
}
dcmd_myskin(playerid, params[])
{
	if(strlen(params) < 1) return SendClientMessage(playerid, 0xFFCC33FF, "Kullanim » {FFFFFF}/myskin <Skin>");
	if(strval(params) < 0 || strval(params) > 311) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Böyle bir skin bulunmamakta.");
	SetPlayerSkin(playerid, strval(params));
	Oyuncu[playerid][Skin] = strval(params);
	SendClientMessage(playerid,0x66FFFFFF,"Bilgi » {FFFFFF}Skininizi deðiþtirdiniz.");
	return 1;
}
dcmd_radio(playerid, params[])
{
 	#pragma unused params
    new list[500];
    for(new i; i <= sizeof(Radiolar); i++)
    {
        if(i == sizeof(Radiolar)) format(list, 500,"%s\n", list);
        else format(list, sizeof(list), "%s\n{FF0000}%02d\t{FFFFFF}%s",list, i+1, Radiolar[i][1]);
    }
	ShowPlayerDialog(playerid, DIALOG_RADIO, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Radio", list, "Dýnle", "Iptal");
	return 1;
}
dcmd_adminlistesi(playerid, params[])
{
	#pragma unused params
	foreach(new i: Player) SavePlayer(i);
	new	query[256],list[1024], IsimCek[MAX_PLAYER_NAME], levell;
	mysql_format(g_SQL, query, sizeof(query), "SELECT `player_name`, `player_admin` FROM `hesaplar` WHERE `player_admin` > 0 ORDER BY `player_admin` DESC");
	new Cache:VeriCek = mysql_query(g_SQL, query);
	new rows = cache_num_rows();
	if(rows)
	{
	    for(new i = 0; i < rows; ++i)
	    {
	        cache_get_value_name(i, "player_name", IsimCek, 24);
	        cache_get_value_name_int(i, "player_admin", levell);
			format(list,sizeof(list),"%s{FFFFFF}%02d\t\t%d\t\t\t%s\n", list, i+1, levell, IsimCek);
		}
	}
	cache_delete(VeriCek);
	ShowPlayerDialog(playerid, DIALOG_STUFFS, DIALOG_STYLE_MSGBOX, "{FF0000}LYNX DRIFT - {FFFFFF}Admin Listesi", list, "Tamam", "");
	return 1;
}
dcmd_djlistesi(playerid, params[])
{
	#pragma unused params
	foreach(new i: Player) SavePlayer(i);
	new	query[256],list[1024], IsimCek[MAX_PLAYER_NAME], levell;
	mysql_format(g_SQL, query, sizeof(query), "SELECT `player_name`, `player_dj` FROM `hesaplar` WHERE `player_dj` > 0 ORDER BY `player_dj` DESC");
	new Cache:VeriCek = mysql_query(g_SQL, query);
	new rows = cache_num_rows();
	if(rows)
	{
	    for(new i = 0; i < rows; ++i)
	    {
	        cache_get_value_name(i, "player_name", IsimCek, 24);
	        cache_get_value_name_int(i, "player_dj", levell);
			format(list,sizeof(list),"%s{FFFFFF}%02d\t\t%d\t\t\t%s\n", list, i+1, levell, IsimCek);
		}
	}
	cache_delete(VeriCek);
	ShowPlayerDialog(playerid, DIALOG_STUFFS, DIALOG_STYLE_MSGBOX, "{FF0000}LYNX DRIFT - {FFFFFF}DJ Listesi", list, "Tamam", "");
	return 1;
}
dcmd_topskor(playerid, params[])
{
	#pragma unused params
	foreach(new i: Player) SavePlayer(i);
	new	query[256],list[1024], IsimCek[MAX_PLAYER_NAME], levell;
	format(list, sizeof(list),"{FF0000}Sira\t\tSkor\t\t\tIsim\n");
	mysql_format(g_SQL, query, sizeof(query), "SELECT `player_name`, `player_skor` FROM `hesaplar` ORDER BY `player_skor` DESC LIMIT 5");
	new Cache:VeriCek =	mysql_query(g_SQL, query);
	new rows = cache_num_rows();
	if(rows)
	{
	    for(new i = 0; i < rows; ++i)
	    {
	        cache_get_value_name(i, "player_name", IsimCek, 24);
	        cache_get_value_name_int(i, "player_skor", levell);
			format(list,sizeof(list),"%s{FFFFFF}%02d\t\t%d\t\t\t%s\n", list, i+1, levell, IsimCek);
		}
	}
	cache_delete(VeriCek);
	ShowPlayerDialog(playerid, DIALOG_STUFFS, DIALOG_STYLE_MSGBOX, "{FF0000}LYNX DRIFT - {FFFFFF}Top Skor", list, "Tamam", "");
	return 1;
}
dcmd_toppara(playerid, params[])
{
	#pragma unused params
	foreach(new i: Player) SavePlayer(i);
	new	query[256],list[1024], IsimCek[MAX_PLAYER_NAME], levell;
	format(list, sizeof(list),"{FF0000}Sira\t\tPara\t\t\tIsim\n");
	mysql_format(g_SQL, query, sizeof(query), "SELECT `player_name`, `player_para` FROM `hesaplar` ORDER BY `player_para` DESC LIMIT 5");
	new Cache:VeriCek =	mysql_query(g_SQL, query);
	new rows = cache_num_rows();
	if(rows)
	{
	    for(new i = 0; i < rows; ++i)
	    {
	        cache_get_value_name(i, "player_name", IsimCek, 24);
	        cache_get_value_name_int(i, "player_para", levell);
			format(list,sizeof(list),"%s{FFFFFF}%02d\t\t%d\t\t\t%s\n", list, i+1, levell, IsimCek);
		}
	}
	cache_delete(VeriCek);
	ShowPlayerDialog(playerid, DIALOG_STUFFS, DIALOG_STYLE_MSGBOX, "{FF0000}LYNX DRIFT - {FFFFFF}Top Para", list, "Tamam", "");
	return 1;
}
dcmd_topkill(playerid, params[])
{
	#pragma unused params
	foreach(new i: Player) SavePlayer(i);
	new	query[256],list[1024], IsimCek[MAX_PLAYER_NAME], levell;
	format(list,sizeof(list),"{FF0000}Sira\t\tOldurme\t\tÝsim\n");
	mysql_format(g_SQL, query, sizeof(query), "SELECT `player_name`, `player_oldurme` FROM `hesaplar` ORDER BY `player_oldurme` DESC LIMIT 5");
	new Cache:VeriCek =	mysql_query(g_SQL, query);
	new rows = cache_num_rows();
	if(rows)
	{
	    for(new i = 0; i < rows; ++i)
	    {
	        cache_get_value_name(i, "player_name", IsimCek, 24);
	        cache_get_value_name_int(i, "player_oldurme", levell);
			format(list,sizeof(list),"%s{FFFFFF}%02d\t\t%d\t\t\t%s\n", list, i+1, levell, IsimCek);
		}
	}
	cache_delete(VeriCek);
	ShowPlayerDialog(playerid, DIALOG_STUFFS, DIALOG_STYLE_MSGBOX, "{FF0000}LYNX DRIFT - {FFFFFF}Top Kill", list, "Tamam", "");
	return 1;
}
dcmd_topdeath(playerid, params[])
{
	#pragma unused params
	foreach(new i: Player) SavePlayer(i);
	new	query[256],list[1024], IsimCek[MAX_PLAYER_NAME], levell;
	format(list,sizeof(list),"{FF0000}Sira\t\tOlum\t\t\tÝsim\n");
	mysql_format(g_SQL, query, sizeof(query), "SELECT `player_name`, `player_olum` FROM `hesaplar` ORDER BY `player_olum` DESC LIMIT 5");
	new Cache:VeriCek =	mysql_query(g_SQL, query);
	new rows = cache_num_rows();
	if(rows)
	{
	    for(new i = 0; i < rows; ++i)
	    {
	        cache_get_value_name(i, "player_name", IsimCek, 24);
	        cache_get_value_name_int(i, "player_olum", levell);
			format(list,sizeof(list),"%s{FFFFFF}%02d\t\t%d\t\t\t%s\n", list, i+1, levell, IsimCek);
		}
	}
	cache_delete(VeriCek);
	ShowPlayerDialog(playerid, DIALOG_STUFFS, DIALOG_STYLE_MSGBOX, "{FF0000}LYNX DRIFT - {FFFFFF}Top Death", list, "Tamam", "");
	return 1;
}
dcmd_toponline(playerid, params[])
{
	#pragma unused params
	foreach(new i: Player) SavePlayer(i);
	new	query[256],list[1024], IsimCek[MAX_PLAYER_NAME], levell;
	format(list,sizeof(list),"{FF0000}Sira\t\tSure\t\t\t\tÝsim\n");
	mysql_format(g_SQL, query, sizeof(query), "SELECT `player_name`, `player_online` FROM `hesaplar` ORDER BY `player_online` DESC LIMIT 5");
	new Cache:VeriCek =	mysql_query(g_SQL, query);
	new rows = cache_num_rows();
	if(rows)
	{
	    for(new i = 0; i < rows; ++i)
	    {
			cache_get_value_name(i, "player_name", IsimCek, 24);
			cache_get_value_name_int(i, "player_online", levell);
			format(list,sizeof(list),"%s{FFFFFF}%02d\t\t%s\t\t\t%s\n", list, i+1, TimeConvertEx(levell), IsimCek);
		}
	}
	cache_delete(VeriCek);
	ShowPlayerDialog(playerid, DIALOG_STUFFS, DIALOG_STYLE_MSGBOX, "{FF0000}LYNX DRIFT - {FFFFFF}Top Online", list, "Tamam", "");
	return 1;
}
dcmd_djs(playerid, params[]) return dcmd_admins(playerid, params);
dcmd_admins(playerid, params[])
{
	#pragma unused params
	new adminler = 0, djler = 0, string[128], string2[1000];
	strcat(string2, "{FF0000}Admin Listesi\n");
    foreach(new i: Player)
    {
	    if(Oyuncu[i][Admin] >= 1)
	    {
            format(string, sizeof(string), "{FF9933}%s (Level %d)\n", PlayerName(i), Oyuncu[i][Admin]);
            strcat(string2, string);
	        adminler++;
        }
    }
    if(adminler == 0) strcat(string2, "{FF9933}Online Admin Yok.\n");
	strcat(string2, "\n{FF0000}DJ Listesi\n");
	foreach(new x: Player)
    {
	    if(Oyuncu[x][DJ] >= 1)
	    {
     		format(string, sizeof(string), "{FF66FF}%s (Level %d)\n\n", PlayerName(x), Oyuncu[x][DJ]);
	        strcat(string2, string);
			djler++;
        }
    }
    if(djler == 0) strcat(string2, "{FF66FF}Online DJ Yok.\n\n");
    format(string, sizeof(string), "\t\t\t\t{FF0000}Admin: {FFFFFF}%d\n", adminler);
    strcat(string2, string);
    format(string, sizeof(string), "\t\t\t\t{FF0000}DJ: {FFFFFF}%d\n", djler);
    strcat(string2, string);
    format(string, sizeof(string), "\t\t\t\t{FF0000}Bütün yetkililer: {FFFFFF}%d\n", adminler+djler);
    strcat(string2, string);
    ShowPlayerDialog(playerid,DIALOG_STUFFS,DIALOG_STYLE_MSGBOX,"{FF0000}LYNX DRIFT - {FFFFFF}Online Yöneticiler",string2,"Tamam","");
	return 1;
}
dcmd_stats(playerid, params[]){
	new id;
	if(sscanf(params, "u", id)) return SendClientMessage(playerid, 0xFFCC33FF, "Kullanim » {FFFFFF}/stats <Player/ID>");
 	if(!IsPlayerConnected(id)) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Oyuncu oyunda deðil.");
	new dialog[949], string[156], str[16];
	switch(IsPlayerPaused(id))
	{
 		case true: format(str,16,"Evet");
		case false: format(str, 16, "Hayýr");
	}
	format(string, sizeof(string), "{FF0000}» {FFFFFF}Admin Level:\t\t{FF0000}%d\n", Oyuncu[id][Admin]);
	strcat(dialog, string);
	format(string, sizeof(string), "{FF0000}» {FFFFFF}DJ Level:\t\t{FF0000}%d\n", Oyuncu[id][DJ]);
	strcat(dialog, string);
	format(string, sizeof(string), "{FF0000}» {FFFFFF}Para:\t\t\t{FF0000}$%s\n", formatInt(Oyuncu[id][Para]));
	strcat(dialog, string);
	format(string, sizeof(string), "{FF0000}» {FFFFFF}Skor:\t\t\t{FF0000}%d\n", GetPlayerScore(id));
	strcat(dialog, string);
	format(string, sizeof(string), "{FF0000}» {FFFFFF}Exp:\t\t\t{FF0000}%d\n", Oyuncu[id][Exp]);
	strcat(dialog, string);
	format(string, sizeof(string), "{FF0000}» {FFFFFF}Exp Level:\t\t{FF0000}%d\n", Oyuncu[id][ExpLevel]);
	strcat(dialog, string);
	format(string, sizeof(string), "{FF0000}» {FFFFFF}Ping:\t\t\t{FF0000}%d\n", GetPlayerPing(id));
	strcat(dialog, string);
	format(string, sizeof(string), "{FF0000}» {FFFFFF}Kayit:\t\t\t{FF0000}%s\n", DateConvert(Oyuncu[id][Kayit]));
	strcat(dialog, string);
	format(string, sizeof(string), "{FF0000}» {FFFFFF}Oldurme:\t\t{FF0000}%d\n", Oyuncu[id][Oldurme]);
	strcat(dialog, string);
	format(string, sizeof(string), "{FF0000}» {FFFFFF}Olum:\t\t\t{FF0000}%d\n", Oyuncu[id][Olum]);
	strcat(dialog, string);
	format(string, sizeof(string), "{FF0000}» {FFFFFF}Skin:\t\t\t{FF0000}%d\n", Oyuncu[id][Skin]);
	strcat(dialog, string);
	format(string, sizeof(string), "{FF0000}» {FFFFFF}Giris Sayisi:\t\t{FF0000}%d\n", Oyuncu[id][GirisSayisi]);
	strcat(dialog, string);
	format(string, sizeof(string), "{FF0000}» {FFFFFF}Online Suresi:\t{FF0000}%s\n", TimeConvertEx(Oyuncu[id][Online]));
	strcat(dialog, string);
	format(string, sizeof(string), "{FF0000}» {FFFFFF}AFK:\t\t\t{FF0000}%s\n", str);
	strcat(dialog, string);
	format(string, sizeof(string), "{FF0000}LYNX DRIFT - {%06x}%s", GetPlayerColor(id) >>> 8, PlayerName(id));
	ShowPlayerDialog(playerid, DIALOG_STATS, DIALOG_STYLE_MSGBOX, string, dialog, "Tamam", "");
	return 1;
}
dcmd_jetpack(playerid, params[])
{
    #pragma unused params
	if(Oyuncu[playerid][Admin] < 2) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Bu komutu kullanmak için yetkiniz bulunmamakta.");
 	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USEJETPACK);
	SendClientMessage(playerid, 0x66FFFFFF,"Bilgi » {FFFFFF}Yeni bir jetpack spawn ettiniz!");
	return 1;
}
dcmd_nickdegis(playerid, params[])
{
	if(strlen(params) == 0) return SendClientMessage(playerid, 0xFFCC33FF, "Kullanim » {FFFFFF}/nickdegis <Nick>");
 	if(strlen(params) < 3) return SendClientMessage(playerid, 0xFFCC33FF, "Kullanim » {FFFFFF}/nickdegis <Nick>");
	if(strlen(params) > 32) return SendClientMessage(playerid, 0xFFCC33FF, "Kullanim » {FFFFFF}/nickdegis <Nick>");
    if(NickKontrol(params) == 0) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Bu nick kullanýlýyor, baþka bir nick deneyin.");
	if(SureYasagi(playerid, "MyNick", 45)) return 1;
	
	new eskiname[24];
	format(eskiname, 24, PlayerName(playerid));
	if(SetPlayerName(playerid, params) == 1)
	{
		new query[176];
		mysql_format(g_SQL, query, sizeof(query), "UPDATE `hesaplar` SET `player_name` = '%e' WHERE `player_id` = '%d'", params, Oyuncu[playerid][SQL]);
		mysql_tquery(g_SQL, query);
		format(query, sizeof(query), "Bilgi » {FFFFFF}Basariyla isminizi %s olarak degistirdiniz!", params);
		SendClientMessage(playerid, 0x66FFFFFF, query);
		SetPlayerName(playerid, params);
	}else return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Izinsiz karakter içeriyor, baþka bir nick deneyin.");
	return 1;
}

dcmd_sifredegis(playerid, params[])
{
	if(strlen(params) == 0) return SendClientMessage(playerid, 0xFFCC33FF, "Kullanim » {FFFFFF}/mypass <Sifre>");
 	if(strlen(params) < 3) return SendClientMessage(playerid, 0xFFCC33FF, "Kullanim » {FFFFFF}/mypass <Sifre>");
	if(strlen(params) > 32) return SendClientMessage(playerid, 0xFFCC33FF, "Kullanim » {FFFFFF}/mypass <Sifre>");
	new str[256];
	mysql_format(g_SQL, str, sizeof(str), "UPDATE `hesaplar` SET `player_sifre` = md5('%e'), `player_gsifre` = '%e' WHERE `player_id` = '%d'", params, params, Oyuncu[playerid][SQL]);
	mysql_tquery(g_SQL, str);
	SendClientMessage(playerid, 0x66FFFFFF,"Bilgi » {FFFFFF}Sifrenizi basariyla degistirdiniz.");
	return 1;
}
dcmd_tune(playerid, params[])
{
    #pragma unused params
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Araçta olmalýsýnýz.");
	ModCar(playerid);
	return 1;
}
dcmd_mycar(playerid, params[])
{
	#pragma unused params
	if(Oyuncu[playerid][Admin] < 5) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Bu komutu kullanmak için yetkiniz bulunmamakta.");
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Araçta olmalýsýnýz.");
	new mStr[1200];
	strcat(mStr, "{FFFFFF}Islem\t{FFFFFF}Açiklama\n");
 	strcat(mStr, "{FF0000}Bos\t{C3C3C3}[Tusu islevsiz birakir]\n");
  	strcat(mStr, "{FF0000}Hiz\t{C3C3C3}[Tusu bastiginizda araci hizlandirir]\n");
  	strcat(mStr, "{FF0000}Zipla\t{C3C3C3}[Tusu bastiginizda araci ziplatir]\n");
   	strcat(mStr, "{FF0000}Yon X\t{C3C3C3}[Tusu bastiginizda araci X ekseni etrafinda dondürür]\n");
    strcat(mStr, "{FF0000}Yon Y\t{C3C3C3}[Tusu bastiginizda araci Y ekseni etrafinda dondürür]\n");
    strcat(mStr, "{FF0000}Yon Z\t{C3C3C3}[Tusu bastiginizda araci Z ekseni etrafinda dondürür]\n");
    strcat(mStr, "{FF0000}Cevir\t{C3C3C3}[Tusu bastiginizda araci düzeltir]\n");
    strcat(mStr, "{FF0000}Renk\t{C3C3C3}[Tusu bastiginizda aracin rengi degisir]\n");
    strcat(mStr, "{FF0000}Fren\t{C3C3C3}[Tusu bastiginizda araci durdurur]\n");
    strcat(mStr, "{FF0000}Bagaj\t{C3C3C3}[Tusu bastiginizda aracin bagajini acar kapatir]\n");
    strcat(mStr, "{FF0000}Kaput\t{C3C3C3}[Tusu bastiginizda aracin kaputunu acar kapatir]\n");
    strcat(mStr, "{FF0000}Alarm\t{C3C3C3}[Tusu bastiginizda aracin alarmini acar kapatir]\n");
    strcat(mStr, "{FF0000}Far\t{C3C3C3}[Tusu bastiginizda aracin farlarini acar kapatir]\n");
    strcat(mStr, "{FF0000}Motor\t{C3C3C3}[Tusu bastiginizda aracin motorunu acar kapatir]\n");
    strcat(mStr, "{FF0000}Kilit\t{C3C3C3}[Tusu bastiginizda aracin kapilarini acar kapatir]\n");
    ShowPlayerDialog(playerid, DIALOG_MYCAR, DIALOG_STYLE_TABLIST_HEADERS, "{FF0000}LYNX DRIFT - {FFFFFF}MyCar",mStr,"Ates etme","H tusu");
	return 1;
}
dcmd_ojump(playerid, params[])
{
    #pragma unused params
    switch(Oyuncu[playerid][eJump])
    {
        case false:
        {
			Oyuncu[playerid][eJump] = true;
			SendClientMessage(playerid, 0x66FFFFFF,"Bilgi » {FFFFFF}Süper zýplama acýldý.");
        }
        case true:
        {
			Oyuncu[playerid][eJump] = false;
			SendClientMessage(playerid, 0x66FFFFFF,"Bilgi » {FFFFFF}Süper zýplama kapatýldý.");
        }
    }
	return 1;
}
dcmd_mg1(playerid, params[])
{
    #pragma unused params
	SendClientMessage(playerid, 0x66FFFFFF, "DMZone » {FFFFFF}Minigun adlý DM alanýna spawn oldunuz.");
	SendClientMessage(playerid, 0x66FFFFFF,"Bilgi » {FFFFFF}DM alanýndan çýkmak istiyorsanýz /dmcik yazabilirsiniz.");
	DeathmatchInfo(playerid, "Minigun","mg1");
	Oyuncu[playerid][DMModu] = 1;
	Oyuncu[playerid][Dmde] = true;
	ResetPlayerWeapons(playerid);
	SilahVer(playerid, 38, 5000);
	SetPlayerHealth(playerid, 100);
	SetPlayerArmour(playerid, 100);
	new RandomSpawn = random(sizeof(MinigunSpawn));
	SetPlayerPos(playerid, MinigunSpawn[RandomSpawn][0], MinigunSpawn[RandomSpawn][1], MinigunSpawn[RandomSpawn][2]);
	SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, 58);
	SetPlayerFacingAngle(playerid, 0);
	return 1;
}
dcmd_mg2(playerid, params[])
{
    #pragma unused params
	SendClientMessage(playerid, 0x66FFFFFF, "DMZone » {FFFFFF}Minigun-2 adlý DM alanýna spawn oldunuz.");
	SendClientMessage(playerid, 0x66FFFFFF,"Bilgi » {FFFFFF}DM alanýndan çýkmak istiyorsanýz /dmcik yazabilirsiniz.");
	DeathmatchInfo(playerid, "Minigun 2","mg2");
	Oyuncu[playerid][DMModu] = 2;
	Oyuncu[playerid][Dmde] = true;
	ResetPlayerWeapons(playerid);
	SilahVer(playerid, 38, 5000);
	SetPlayerHealth(playerid, 100);
	SetPlayerArmour(playerid, 100);
	new RandomSpawn = random(sizeof(Minigun2Spawn));
	SetPlayerPos(playerid, Minigun2Spawn[RandomSpawn][0], Minigun2Spawn[RandomSpawn][1], Minigun2Spawn[RandomSpawn][2]);
	SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, 58);
	SetPlayerFacingAngle(playerid, 0);
	return 1;
}
dcmd_mg3(playerid, params[])
{
    #pragma unused params
	SendClientMessage(playerid, 0x66FFFFFF, "DMZone » {FFFFFF}Minigun-3 adlý DM alanýna spawn oldunuz.");
	SendClientMessage(playerid, 0x66FFFFFF,"Bilgi » {FFFFFF}DM alanýndan çýkmak istiyorsanýz /dmcik yazabilirsiniz.");
	DeathmatchInfo(playerid, "Minigun 3","mg3");
	Oyuncu[playerid][DMModu] = 3;
	Oyuncu[playerid][Dmde] = true;
	ResetPlayerWeapons(playerid);
	SilahVer(playerid, 38, 5000);
	SetPlayerHealth(playerid, 100);
	SetPlayerArmour(playerid, 100);
	new RandomSpawn = random(sizeof(Minigun3Spawn));
	SetPlayerPos(playerid, Minigun3Spawn[RandomSpawn][0], Minigun3Spawn[RandomSpawn][1], Minigun3Spawn[RandomSpawn][2]);
	SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, 58);
	SetPlayerFacingAngle(playerid, 0);
	return 1;
}
dcmd_deagle(playerid, params[])
{
    #pragma unused params
	SendClientMessage(playerid, 0x66FFFFFF, "DMZone » {FFFFFF}Deagle adlý DM alanýna spawn oldunuz.");
	SendClientMessage(playerid, 0x66FFFFFF,"Bilgi » {FFFFFF}DM alanýndan çýkmak istiyorsanýz /dmcik yazabilirsiniz.");
	DeathmatchInfo(playerid, "Deagle","deagle");
	Oyuncu[playerid][DMModu] = 4;
	Oyuncu[playerid][Dmde] = true;
	ResetPlayerWeapons(playerid);
	SilahVer(playerid, 24, 5000);
	SetPlayerHealth(playerid, 100);
	SetPlayerArmour(playerid, 100);
	new RandomSpawn = random(sizeof(DeagleSpawn));
	SetPlayerPos(playerid, DeagleSpawn[RandomSpawn][0], DeagleSpawn[RandomSpawn][1], DeagleSpawn[RandomSpawn][2]);
	SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, 58);
	SetPlayerFacingAngle(playerid, 0);
	return 1;
}
dcmd_rpg(playerid, params[])
{
    #pragma unused params
	SendClientMessage(playerid, 0x66FFFFFF, "DMZone » {FFFFFF}RPG adlý DM alanýna spawn oldunuz.");
	SendClientMessage(playerid, 0x66FFFFFF,"Bilgi » {FFFFFF}DM alanýndan çýkmak istiyorsanýz /dmcik yazabilirsiniz.");
	DeathmatchInfo(playerid, "RPG","rpg");
	Oyuncu[playerid][DMModu] = 5;
	Oyuncu[playerid][Dmde] = true;
	ResetPlayerWeapons(playerid);
	SilahVer(playerid, 35, 5000);
	SetPlayerHealth(playerid, 100);
	SetPlayerArmour(playerid, 100);
	new RandomSpawn = random(sizeof(RPGSpawn));
	SetPlayerPos(playerid, RPGSpawn[RandomSpawn][0], RPGSpawn[RandomSpawn][1], RPGSpawn[RandomSpawn][2]);
	SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, 58);
	SetPlayerFacingAngle(playerid, 0);
	return 1;
}
dcmd_knifedm(playerid, params[])
{
    #pragma unused params
	SendClientMessage(playerid, 0x66FFFFFF, "DMZone » {FFFFFF}Knife adlý DM alanýna spawn oldunuz.");
	SendClientMessage(playerid, 0x66FFFFFF,"Bilgi » {FFFFFF}DM alanýndan çýkmak istiyorsanýz /dmcik yazabilirsiniz.");
	DeathmatchInfo(playerid, "Knife","knifedm");
	Oyuncu[playerid][DMModu] = 6;
	Oyuncu[playerid][Dmde] = true;
	ResetPlayerWeapons(playerid);
	SilahVer(playerid, 4, 1);
	SetPlayerHealth(playerid, 1);
	SetPlayerArmour(playerid, 0);
	new RandomSpawn = random(sizeof(KnifeSpawn));
	SetPlayerPos(playerid, KnifeSpawn[RandomSpawn][0], KnifeSpawn[RandomSpawn][1], KnifeSpawn[RandomSpawn][2]);
	SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, 58);
	SetPlayerFacingAngle(playerid, 0);
	return 1;
}
dcmd_sniperdm(playerid, params[])
{
    #pragma unused params
	SendClientMessage(playerid, 0x66FFFFFF, "DMZone » {FFFFFF}Sniper adlý DM alanýna spawn oldunuz.");
	SendClientMessage(playerid, 0x66FFFFFF,"Bilgi » {FFFFFF}DM alanýndan çýkmak istiyorsanýz /dmcik yazabilirsiniz.");
	DeathmatchInfo(playerid, "Sniper","sniperdm");
	Oyuncu[playerid][DMModu] = 7;
	Oyuncu[playerid][Dmde] = true;
	ResetPlayerWeapons(playerid);
	SilahVer(playerid, 34, 5000);
	SetPlayerHealth(playerid, 100);
	SetPlayerArmour(playerid, 100);
	new RandomSpawn = random(sizeof(SniperSpawn));
	SetPlayerPos(playerid, SniperSpawn[RandomSpawn][0], SniperSpawn[RandomSpawn][1], SniperSpawn[RandomSpawn][2]);
	SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, 58);
	SetPlayerFacingAngle(playerid, 0);
	return 1;
}
dcmd_pb1(playerid, params[])
{
    #pragma unused params
	SendClientMessage(playerid, 0x66FFFFFF, "DMZone » {FFFFFF}PaintBall adlý DM alanýna spawn oldunuz.");
	SendClientMessage(playerid, 0x66FFFFFF,"Bilgi » {FFFFFF}DM alanýndan çýkmak istiyorsanýz /dmcik yazabilirsiniz.");
	DeathmatchInfo(playerid, "PaintBall","pb1");
	Oyuncu[playerid][DMModu] = 9;
	Oyuncu[playerid][Dmde] = true;
	ResetPlayerWeapons(playerid);
	SilahVer(playerid, WEAPON_SILENCED, 5000);
	SetPlayerHealth(playerid, 1);
	SetPlayerArmour(playerid, 0);
	new RandomSpawn = random(sizeof(PBSpawn));
	SetPlayerPos(playerid, PBSpawn[RandomSpawn][0], PBSpawn[RandomSpawn][1], PBSpawn[RandomSpawn][2]);
	SetPlayerInterior(playerid, 15);
	SetPlayerVirtualWorld(playerid, 58);
	SetPlayerFacingAngle(playerid, 0);
	return 1;
}
dcmd_pb2(playerid, params[])
{
    #pragma unused params
	SendClientMessage(playerid, 0x66FFFFFF,  "DMZone » {FFFFFF}PaintBall-2 adlý DM alanýna spawn oldunuz.");
	SendClientMessage(playerid, 0x66FFFFFF,"Bilgi » {FFFFFF}DM alanýndan çýkmak istiyorsanýz /dmcik yazabilirsiniz.");
	DeathmatchInfo(playerid, "PaintBall 2","pb2");
	Oyuncu[playerid][DMModu] = 10;
	Oyuncu[playerid][Dmde] = true;
	ResetPlayerWeapons(playerid);
	SilahVer(playerid, WEAPON_SILENCED, 5000);
	SetPlayerHealth(playerid, 1);
	SetPlayerArmour(playerid, 0);
	new RandomSpawn = random(sizeof(PB2Spawn));
	SetPlayerPos(playerid, PB2Spawn[RandomSpawn][0], PB2Spawn[RandomSpawn][1], PB2Spawn[RandomSpawn][2]);
	SetPlayerInterior(playerid, 18);
	SetPlayerVirtualWorld(playerid, 58);
	SetPlayerFacingAngle(playerid, 0);
	return 1;
}
dcmd_pb3(playerid, params[])
{
    #pragma unused params
	SendClientMessage(playerid, 0x66FFFFFF, "DMZone » {FFFFFF}PaintBall-3 adlý DM alanýna spawn oldunuz.");
	SendClientMessage(playerid, 0x66FFFFFF,"Bilgi » {FFFFFF}DM alanýndan çýkmak istiyorsanýz /dmcik yazabilirsiniz.");
	DeathmatchInfo(playerid, "PaintBall 3","pb3");
	Oyuncu[playerid][DMModu] = 11;
	Oyuncu[playerid][Dmde] = true;
	ResetPlayerWeapons(playerid);
	SilahVer(playerid, WEAPON_SILENCED, 5000);
	SetPlayerHealth(playerid, 1);
	SetPlayerArmour(playerid, 0);
	new RandomSpawn = random(sizeof(PB3Spawn));
	SetPlayerPos(playerid, PB3Spawn[RandomSpawn][0], PB3Spawn[RandomSpawn][1], PB3Spawn[RandomSpawn][2]);
	SetPlayerInterior(playerid, 17);
	SetPlayerVirtualWorld(playerid, 58);
	SetPlayerFacingAngle(playerid, 0);
	return 1;
}
dcmd_snipshot(playerid, params[])
{
    #pragma unused params
	SendClientMessage(playerid, 0x66FFFFFF, "DMZone » {FFFFFF}Sniper-Shotgun adlý DM alanýna spawn oldunuz.");
	SendClientMessage(playerid, 0x66FFFFFF,"Bilgi » {FFFFFF}DM alanýndan çýkmak istiyorsanýz /dmcik yazabilirsiniz.");
	DeathmatchInfo(playerid, "Sniper-Shotgun","snipshot");
	Oyuncu[playerid][DMModu] = 12;
	Oyuncu[playerid][Dmde] = true;
	ResetPlayerWeapons(playerid);
	SilahVer(playerid, 25, 5000);
	SilahVer(playerid, 34, 5000);
	SetPlayerHealth(playerid, 100);
	SetPlayerArmour(playerid, 100);
	new RandomSpawn = random(sizeof(DeagleSpawn));
	SetPlayerPos(playerid, DeagleSpawn[RandomSpawn][0], DeagleSpawn[RandomSpawn][1], DeagleSpawn[RandomSpawn][2]);
	SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, 59);
	SetPlayerFacingAngle(playerid, 0);
	return 1;
}
dcmd_dgshot(playerid, params[])
{
    #pragma unused params
	SendClientMessage(playerid, 0x66FFFFFF,  "DMZone » {FFFFFF}Deagle-Shotgun adlý DM alanýna spawn oldunuz.");
	SendClientMessage(playerid, 0x66FFFFFF,"Bilgi » {FFFFFF}DM alanýndan çýkmak istiyorsanýz /dmcik yazabilirsiniz.");
	DeathmatchInfo(playerid, "Deagle-Shotgun","dgshot");
	Oyuncu[playerid][DMModu] = 13;
	Oyuncu[playerid][Dmde] = true;
	ResetPlayerWeapons(playerid);
	SilahVer(playerid, 25, 5000);
	SilahVer(playerid, 24, 5000);
	SetPlayerHealth(playerid, 100);
	SetPlayerArmour(playerid, 100);
	new RandomSpawn = random(sizeof(DeagleSpawn));
	SetPlayerPos(playerid, DeagleSpawn[RandomSpawn][0], DeagleSpawn[RandomSpawn][1], DeagleSpawn[RandomSpawn][2]);
	SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, 60);
	SetPlayerFacingAngle(playerid, 0);
	return 1;
}
dcmd_otorenk(playerid, params[])
{
    #pragma unused params
	if(Oyuncu[playerid][Admin] < 1 && Oyuncu[playerid][DJ] < 1) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Bu komutu kullanmak için yetkiniz bulunmamakta.");
	switch(Oyuncu[playerid][rDurum])
	{
	    case false:
	    {
	        Oyuncu[playerid][rDurum] = true;
	        SendClientMessage(playerid, 0x66FFFFFF, "Bilgi » {FFFFFF}Otomatik renk aktif. Chatte attýðýnýz her mesajda renginiz deðiþecektir.");
	        PlayerPlaySound(playerid, 1057, 0, 0, 0);
	    }
	    case true:
		{
 			Oyuncu[playerid][rDurum] = false;
 			SendClientMessage(playerid, 0x66FFFFFF, "Bilgi » {FFFFFF}Otomatik renk de-aktif.");
 			PlayerPlaySound(playerid, 1057, 0, 0, 0);
		}
	}
	return 1;
}
public OnPlayerDeath(playerid, killerid, reason)
{
    if(Oyuncu[playerid][Yarista] == true)
    {
		JoinCount--;
		Oyuncu[playerid][Yarista] = false;
		DestroyVehicle(CreatedRaceVeh[playerid]);
		DisablePlayerRaceCheckpoint(playerid);
		RemovePlayerMapIcon(playerid, RaceIcon);
		PlayerTextDrawHide(playerid, RaceInfo[playerid]);
		CPProgess[playerid] = 0;
		KillTimer(InfoTimer[playerid]);
		SetPlayerVirtualWorld(playerid, 0);
	}
	if(BuildRace == playerid+1) BuildRace = 0;
	
	if(killerid != INVALID_PLAYER_ID)
	{
	 	switch(Oyuncu[playerid][TDM_Team])
	 	{
	 	    case TEAM_1: TDMInfo[Team2_Score]++;
	 	    case TEAM_2: TDMInfo[Team1_Score]++;
	 	}
    	if(Oyuncu[killerid][GunGamede] == true)
		{
            Oyuncu[killerid][GunGameLevel]++;
            GivePlayerGunLevel(killerid);
		}
		SendDeathMessage(killerid, playerid, reason);
	 	GivePlayerCash(playerid, -1000);
	    Oyuncu[killerid][Oldurme]++;
	    Oyuncu[playerid][Olum]++;
		Oyuncu[playerid][Spree] = 0;
	    Oyuncu[killerid][Spree]++;
	    switch(Oyuncu[killerid][Spree])
	    {
	        case 1: GameTextForPlayer(killerid, "~n~~n~~w~~h~~h~> ~r~~h~~h~First Blood ~w~~h~~h~<", 1500, 3), GivePlayerScore(killerid,1), GivePlayerCash(killerid, 1000),GivePlayerExp(killerid, 5);
            case 2: GameTextForPlayer(killerid, "~n~~n~~w~~h~~h~> ~r~~h~~h~Double Kill ~w~~h~~h~<", 1500, 3), GivePlayerScore(killerid,4), GivePlayerCash(killerid, 3000),GivePlayerExp(killerid, 20);
            case 3: GameTextForPlayer(killerid, "~n~~n~~w~~h~~h~> ~r~~h~~h~Triple Kill ~w~~h~~h~<", 1500, 3), GivePlayerScore(killerid,6), GivePlayerCash(killerid, 6000),GivePlayerExp(killerid, 30);
            case 5: GameTextForPlayer(killerid, "~n~~n~~w~~h~~h~> ~r~~h~~h~Dominating ~w~~h~~h~<", 1500, 3), GivePlayerScore(killerid,9), GivePlayerCash(killerid, 9000),GivePlayerExp(killerid, 50);
            case 7: GameTextForPlayer(killerid, "~n~~n~~w~~h~~h~> ~r~~h~~h~Killing Spree ~w~~h~~h~<", 1500, 3), GivePlayerScore(killerid,11), GivePlayerCash(killerid, 1100),GivePlayerExp(killerid, 60);
            case 10: GameTextForPlayer(killerid, "~n~~n~~w~~h~~h~> ~r~~h~~h~Monster Kill ~w~~h~~h~<", 1500, 3), GivePlayerScore(killerid,13), GivePlayerCash(killerid, 1300),GivePlayerExp(killerid, 80);
            case 11: GameTextForPlayer(killerid, "~n~~n~~w~~h~~h~> ~r~~h~~h~Wicked Sick ~w~~h~~h~<", 1500, 3), GivePlayerScore(killerid,15), GivePlayerCash(killerid, 1500),GivePlayerExp(killerid, 100);
			case 13: GameTextForPlayer(killerid, "~n~~n~~w~~h~~h~> ~r~~h~~h~Ludicrous Kill ~w~~h~~h~<", 1500, 3), GivePlayerScore(killerid,17), GivePlayerCash(killerid, 1700),GivePlayerExp(killerid, 110);
			case 15: GameTextForPlayer(killerid, "~n~~n~~w~~h~~h~> ~r~~h~~h~Ultra Kill ~w~~h~~h~<", 1500, 3), GivePlayerScore(killerid,19), GivePlayerCash(killerid, 1900),GivePlayerExp(killerid, 130);
			case 17: GameTextForPlayer(killerid, "~n~~n~~w~~h~~h~> ~r~~h~~h~Unstoppable ~w~~h~~h~<", 1500, 3), GivePlayerScore(killerid,21), GivePlayerCash(killerid, 2100),GivePlayerExp(killerid, 150);
			case 20: GameTextForPlayer(killerid, "~n~~n~~w~~h~~h~> ~r~~h~~h~Godlike ~w~~h~~h~<", 1500, 3), GivePlayerScore(killerid,23), GivePlayerCash(killerid, 2300),GivePlayerExp(killerid, 200);
		}
	}else if(killerid == INVALID_PLAYER_ID)
	{
	    SendDeathMessage(INVALID_PLAYER_ID, playerid, reason);
		Oyuncu[playerid][Olum]++;
		Oyuncu[playerid][Spree] = 0;
		GivePlayerCash(playerid,-1000);
 	}
	if(Oyuncu[playerid][Duelde])
	{
	    new string[144];
	    format(string, sizeof(string), "Duel » {FFFFFF}%s duelloda %s'yý maðlup etti. Silahlar: {FF9900}%s & %s {FFFFFF}Sure: {FF9900}%s", PlayerName(Oyuncu[playerid][DuelRakip]), PlayerName(playerid), ReturnWeaponNameEx(Oyuncu[playerid][DuelSilah1]),ReturnWeaponNameEx(Oyuncu[playerid][DuelSilah2]), ConvertTime(GetTickCount() - Oyuncu[playerid][DuelTick]));
	    SendClientMessageToAll(0x99CC00FF, string);
        Oyuncu[Oyuncu[playerid][DuelRakip]][Duelde] = false;
	    Oyuncu[Oyuncu[playerid][DuelRakip]][DuelRakip] = INVALID_PLAYER_ID;
	    Oyuncu[Oyuncu[playerid][DuelRakip]][DuelSilah1] = 0;
	    Oyuncu[Oyuncu[playerid][DuelRakip]][DuelSilah2] = 0;
	    Oyuncu[Oyuncu[playerid][DuelRakip]][DuelMap] = 0;
        Oyuncu[playerid][Duelde] = false;
        Oyuncu[playerid][DuelRakip] = INVALID_PLAYER_ID;
        Oyuncu[playerid][DuelSilah1] = 0;
        Oyuncu[playerid][DuelSilah2] = 0;
        Oyuncu[playerid][DuelMap] = 0;
        SpawnPlayer(killerid);
	}
   	return 1;
}
public OnPlayerUpdate(playerid)
{
	if(GetPlayerMoney(playerid) != Oyuncu[playerid][Para]) ResetPlayerMoney(playerid), GivePlayerMoney(playerid, Oyuncu[playerid][Para]);
	if(GetPlayerWeapon(playerid) != GetPVarInt(playerid, "OyuncuGecerliSilah"))
	{
		OyuncuSilahDegistirdi(playerid, GetPVarInt(playerid, "OyuncuGecerliSilah"), GetPlayerWeapon(playerid));
		SetPVarInt(playerid, "OyuncuGecerliSilah", GetPlayerWeapon(playerid));
	}
	return 1;
}
public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	new str[3];
	format(str, sizeof(str), "%d", clickedplayerid);
	return dcmd_stats(playerid, str);
}
public OnPlayerRequestSpawn(playerid)
{
	if(Oyuncu[playerid][Giris] != true)
	{
    	SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Giriþ yapmadan spawn olamazsýnýz.");
    	return 0;
	}
    ClearAnimations(playerid);
	SetPlayerColor(playerid, PlayerColors[random(200)]);
	LabelAyarla(playerid);
	StopAudioStreamForPlayer(playerid);
 	PlayAudioStreamForPlayer(playerid, SonMuzik);
	ExpGuncelle(playerid);
	TextDrawShowForPlayer(playerid, LYNX);
	ShowPlayerProgressBar(playerid, ExpBar[playerid]);
	PlayerTextDrawShow(playerid, ExpText[playerid]);
	TextDrawShowForPlayer(playerid, ParaBox);
	PlayerTextDrawShow(playerid, ParaText[playerid]);
	return 1;
}
public OnPlayerRequestClass(playerid, classid)
{
    if(GetPVarInt(playerid, "ClassSecOc") == 0)
	{
		InterpolateCameraPos(playerid, 1715.780151, 2823.544189, 36.216690, 1471.657958, 2773.792968, 28.092153, 2000);
		InterpolateCameraLookAt(playerid, 1720.558837, 2824.614990, 35.208034, 1466.663818, 2773.906494, 28.306930, 2000);
		SetPVarInt(playerid, "ClassSecOc", 1);
	}
	SetPlayerPos(playerid, 1451.924438, 2773.822265, 27.432954);
	SetPlayerFacingAngle(playerid, 270.432495);
	Oyuncu[playerid][Skin] = classid;
 	switch(random(4))
	{
		case 0: ClearAnimations(playerid), SetPlayerSpecialAction(playerid, SPECIAL_ACTION_DANCE1);
        case 1: ClearAnimations(playerid), SetPlayerSpecialAction(playerid, SPECIAL_ACTION_DANCE2);
        case 2: ClearAnimations(playerid), SetPlayerSpecialAction(playerid, SPECIAL_ACTION_DANCE3);
        case 3: ClearAnimations(playerid), SetPlayerSpecialAction(playerid, SPECIAL_ACTION_DANCE4);
	}
	return 1;
}
public OnPlayerSpawn(playerid)
{
	if(Oyuncu[playerid][pSpawn] == false)
    {
		CheckS0beit(playerid);
		return 1;
    }
	if(IgnoreSpawn[playerid] == true)
	{
	    IgnoreSpawn[playerid] = false;
	    return 1;
	}
	SetPlayerSkin(playerid, Oyuncu[playerid][Skin]);
	if(Oyuncu[playerid][TDM] == true)
	{
	    TDMYolla(playerid);
	    return 1;
 	}
    LabelAyarla(playerid);
    if(Oyuncu[playerid][GunGamede] == true)
    {
		Oyuncu[playerid][GunGamede] = true;
		SetPlayerInterior(playerid, 10);
		SetPlayerVirtualWorld(playerid, 95);
		switch(random(5))
		{
		    case 0: SetPlayerPos(playerid, -975.1050, 1061.5844, 1345.6755);
		    case 1: SetPlayerPos(playerid, -1042.6305, 1031.9932, 1342.7920);
		    case 2: SetPlayerPos(playerid, -1089.8619, 1094.6024, 1343.4906);
		    case 3: SetPlayerPos(playerid, -1130.3995, 1057.9498, 1346.4141);
		    case 4: SetPlayerPos(playerid, -1078.9012, 1020.9278, 1342.7163);
		}
		SetCameraBehindPlayer(playerid);
		SetPlayerHealth(playerid, 100);
	 	SetPlayerArmour(playerid, 100);
	 	GivePlayerGunLevel(playerid);
        return 1;
	}
	if(Oyuncu[playerid][Duelde])
	{
	    new string[144];
	    format(string, sizeof(string), "Duel » {FFFFFF}%s duelloda %s'yý maðlup etti. Silahlar: {FF9900}%s & %s {FFFFFF}Sure: {FF9900}%s", PlayerName(Oyuncu[playerid][DuelRakip]), PlayerName(playerid), ReturnWeaponNameEx(Oyuncu[playerid][DuelSilah1]),ReturnWeaponNameEx(Oyuncu[playerid][DuelSilah2]), ConvertTime(GetTickCount() - Oyuncu[playerid][DuelTick]));
	    SendClientMessageToAll(0x99CC00FF, string);
        Oyuncu[Oyuncu[playerid][DuelRakip]][Duelde] = false;
	    Oyuncu[Oyuncu[playerid][DuelRakip]][DuelRakip] = INVALID_PLAYER_ID;
	    Oyuncu[Oyuncu[playerid][DuelRakip]][DuelSilah1] = 0;
	    Oyuncu[Oyuncu[playerid][DuelRakip]][DuelSilah2] = 0;
	    Oyuncu[Oyuncu[playerid][DuelRakip]][DuelMap] = 0;

        Oyuncu[playerid][Duelde] = false;
        Oyuncu[playerid][DuelRakip] = INVALID_PLAYER_ID;
        Oyuncu[playerid][DuelSilah1] = 0;
        Oyuncu[playerid][DuelSilah2] = 0;
        Oyuncu[playerid][DuelMap] = 0;
	}
	Oyuncu[playerid][Duelde] = false;
 	Oyuncu[playerid][DuelRakip] = INVALID_PLAYER_ID;
	Oyuncu[playerid][DuelSilah1] = 0;
	Oyuncu[playerid][DuelSilah2] = 0;
	Oyuncu[playerid][DuelMap] = 0;
	
	if(Oyuncu[playerid][DMModu] == 1)
	{
		Oyuncu[playerid][Dmde] = true;
		ResetPlayerWeapons(playerid);
		SilahVer(playerid, 38, 5000);
		SetPlayerHealth(playerid, 100);
		SetPlayerArmour(playerid, 100);
		new RandomSpawn = random(sizeof(MinigunSpawn));
		SetPlayerPos(playerid, MinigunSpawn[RandomSpawn][0], MinigunSpawn[RandomSpawn][1], MinigunSpawn[RandomSpawn][2]);
		SetPlayerInterior(playerid, 0);
		SetPlayerVirtualWorld(playerid, 58);
		SetPlayerFacingAngle(playerid, 0);
  		return 1;
	}
	if(Oyuncu[playerid][DMModu] == 2)
	{
		Oyuncu[playerid][Dmde] = true;
		ResetPlayerWeapons(playerid);
		SilahVer(playerid, 38, 5000);
		SetPlayerHealth(playerid, 100);
		SetPlayerArmour(playerid, 100);
		new RandomSpawn = random(sizeof(Minigun2Spawn));
		SetPlayerPos(playerid, Minigun2Spawn[RandomSpawn][0], Minigun2Spawn[RandomSpawn][1], Minigun2Spawn[RandomSpawn][2]);
		SetPlayerInterior(playerid, 0);
		SetPlayerVirtualWorld(playerid, 58);
		SetPlayerFacingAngle(playerid, 0);
		return 1;
	}
	if(Oyuncu[playerid][DMModu] == 3)
	{
		Oyuncu[playerid][Dmde] = true;
		ResetPlayerWeapons(playerid);
		SilahVer(playerid, 38, 5000);
		SetPlayerHealth(playerid, 100);
		SetPlayerArmour(playerid, 100);
		new RandomSpawn = random(sizeof(Minigun3Spawn));
		SetPlayerPos(playerid, Minigun3Spawn[RandomSpawn][0], Minigun3Spawn[RandomSpawn][1], Minigun3Spawn[RandomSpawn][2]);
		SetPlayerInterior(playerid, 0);
		SetPlayerVirtualWorld(playerid, 58);
		SetPlayerFacingAngle(playerid, 0);
		return 1;
	}
	if(Oyuncu[playerid][DMModu] == 4)
	{
		Oyuncu[playerid][Dmde] = true;
		ResetPlayerWeapons(playerid);
		SilahVer(playerid, 24, 5000);
		SetPlayerHealth(playerid, 100);
		SetPlayerArmour(playerid, 100);
		new RandomSpawn = random(sizeof(DeagleSpawn));
		SetPlayerPos(playerid, DeagleSpawn[RandomSpawn][0], DeagleSpawn[RandomSpawn][1], DeagleSpawn[RandomSpawn][2]);
		SetPlayerInterior(playerid, 0);
		SetPlayerVirtualWorld(playerid, 58);
		SetPlayerFacingAngle(playerid, 0);
		return 1;
	}
	if(Oyuncu[playerid][DMModu] == 5)
	{
		Oyuncu[playerid][Dmde] = true;
		ResetPlayerWeapons(playerid);
		SilahVer(playerid, 35, 5000);
		SetPlayerHealth(playerid, 100);
		SetPlayerArmour(playerid, 100);
		new RandomSpawn = random(sizeof(RPGSpawn));
		SetPlayerPos(playerid, RPGSpawn[RandomSpawn][0], RPGSpawn[RandomSpawn][1], RPGSpawn[RandomSpawn][2]);
		SetPlayerInterior(playerid, 0);
		SetPlayerVirtualWorld(playerid, 58);
		SetPlayerFacingAngle(playerid, 0);
		return 1;
	}
	if(Oyuncu[playerid][DMModu] == 6)
	{
		Oyuncu[playerid][Dmde] = true;
		ResetPlayerWeapons(playerid);
		SilahVer(playerid, 4, 1);
		SetPlayerHealth(playerid, 1);
		SetPlayerArmour(playerid, 0);
		new RandomSpawn = random(sizeof(KnifeSpawn));
		SetPlayerPos(playerid, KnifeSpawn[RandomSpawn][0], KnifeSpawn[RandomSpawn][1], KnifeSpawn[RandomSpawn][2]);
		SetPlayerInterior(playerid, 0);
		SetPlayerVirtualWorld(playerid, 58);
		SetPlayerFacingAngle(playerid, 0);
		return 1;
	}
	if(Oyuncu[playerid][DMModu] == 7)
	{
		Oyuncu[playerid][Dmde] = true;
		ResetPlayerWeapons(playerid);
		SilahVer(playerid, 34, 5000);
		SetPlayerHealth(playerid, 100);
		SetPlayerArmour(playerid, 100);
		new RandomSpawn = random(sizeof(SniperSpawn));
		SetPlayerPos(playerid, SniperSpawn[RandomSpawn][0], SniperSpawn[RandomSpawn][1], SniperSpawn[RandomSpawn][2]);
		SetPlayerInterior(playerid, 0);
		SetPlayerVirtualWorld(playerid, 58);
		SetPlayerFacingAngle(playerid, 0);
		return 1;
	}
	if(Oyuncu[playerid][DMModu] == 9)
	{
		Oyuncu[playerid][Dmde] = true;
		ResetPlayerWeapons(playerid);
		SilahVer(playerid, WEAPON_SILENCED, 5000);
		SetPlayerHealth(playerid, 1);
		SetPlayerArmour(playerid, 0);
		new RandomSpawn = random(sizeof(PBSpawn));
		SetPlayerPos(playerid, PBSpawn[RandomSpawn][0], PBSpawn[RandomSpawn][1], PBSpawn[RandomSpawn][2]);
		SetPlayerInterior(playerid, 15);
		SetPlayerVirtualWorld(playerid, 58);
		SetPlayerFacingAngle(playerid, 0);
    	return 1;
	}
	if(Oyuncu[playerid][DMModu] == 10)
	{
		Oyuncu[playerid][Dmde] = true;
		ResetPlayerWeapons(playerid);
		SilahVer(playerid, WEAPON_SILENCED, 5000);
		SetPlayerHealth(playerid, 1);
		SetPlayerArmour(playerid, 0);
		new RandomSpawn = random(sizeof(PB2Spawn));
		SetPlayerPos(playerid, PB2Spawn[RandomSpawn][0], PB2Spawn[RandomSpawn][1], PB2Spawn[RandomSpawn][2]);
		SetPlayerInterior(playerid, 18);
		SetPlayerVirtualWorld(playerid, 58);
		SetPlayerFacingAngle(playerid, 0);
	    return 1;
	}
	if(Oyuncu[playerid][DMModu] == 11)
	{
		Oyuncu[playerid][Dmde] = true;
		ResetPlayerWeapons(playerid);
		SilahVer(playerid, WEAPON_SILENCED, 5000);
		SetPlayerHealth(playerid, 1);
		SetPlayerArmour(playerid, 0);
		new RandomSpawn = random(sizeof(PB3Spawn));
		SetPlayerPos(playerid, PB3Spawn[RandomSpawn][0], PB3Spawn[RandomSpawn][1], PB3Spawn[RandomSpawn][2]);
		SetPlayerInterior(playerid, 17);
		SetPlayerVirtualWorld(playerid, 58);
		SetPlayerFacingAngle(playerid, 0);
    	return 1;
	}
	if(Oyuncu[playerid][DMModu] == 12)
	{
		Oyuncu[playerid][Dmde] = true;
		ResetPlayerWeapons(playerid);
		SilahVer(playerid, 34, 5000);
		SilahVer(playerid, 25, 5000);
		SetPlayerHealth(playerid, 100);
		SetPlayerArmour(playerid, 100);
		new RandomSpawn = random(sizeof(DeagleSpawn));
		SetPlayerPos(playerid, DeagleSpawn[RandomSpawn][0], DeagleSpawn[RandomSpawn][1], DeagleSpawn[RandomSpawn][2]);
		SetPlayerInterior(playerid, 0);
		SetPlayerVirtualWorld(playerid, 59);
		SetPlayerFacingAngle(playerid, 0);
    	return 1;
	}
	if(Oyuncu[playerid][DMModu] == 13)
	{
		Oyuncu[playerid][Dmde] = true;
		ResetPlayerWeapons(playerid);
		SilahVer(playerid, 24, 5000);
		SilahVer(playerid, 25, 5000);
		SetPlayerHealth(playerid, 100);
		SetPlayerArmour(playerid, 100);
		new RandomSpawn = random(sizeof(DeagleSpawn));
		SetPlayerPos(playerid, DeagleSpawn[RandomSpawn][0], DeagleSpawn[RandomSpawn][1], DeagleSpawn[RandomSpawn][2]);
		SetPlayerInterior(playerid, 0);
		SetPlayerVirtualWorld(playerid, 60);
		SetPlayerFacingAngle(playerid, 0);
    	return 1;
	}
	TextDrawHideForPlayer(playerid, TDMTextdraw);
	SetPlayerTeam(playerid, NO_TEAM);
	SetPlayerPos(playerid, -307.9476, 1555.0444, 80.1332);
	SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, 0);
	SetPlayerHealth(playerid, 100);
	SetPlayerArmour(playerid, 100);
	SilahVer(playerid,WEAPON_CAMERA,100);
    SpawnDondur(playerid, 2);
	return 1;
}
public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(GetPlayerState(playerid) == 9 && Oyuncu[playerid][Specte] == false)
	{
	    KickReason(playerid, "Invisible Hack","Sistem");
	}
	if(Oyuncu[playerid][Yarista] == true)
	{
	    if(oldstate == PLAYER_STATE_DRIVER)
	    {
	        PutPlayerInVehicle(playerid, CreatedRaceVeh[playerid], 0);
	    }
	}
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
	    ShowPlayerProgressBar(playerid, SpeedoBar[playerid]);
		PlayerTextDrawShow(playerid, SpeedoText[playerid]);
	}else
	{
	    HidePlayerProgressBar(playerid, SpeedoBar[playerid]);
		PlayerTextDrawHide(playerid, SpeedoText[playerid]);
	}
	if(oldstate == PLAYER_STATE_DRIVER) KillTimer(Oyuncu[playerid][NosTimer]);
	if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER)
	{
		if(IsABike(GetPlayerVehicleID(playerid)))
		{
			switch(GetPlayerSkin(playerid))
			{
				#define SPAO{%0,%1,%2,%3,%4,%5} SetPlayerAttachedObject(playerid, 1, 18645, 2, (%0), (%1), (%2), (%3), (%4), (%5));
				case 0, 65, 74, 149, 208, 273:  SPAO{0.070000, 0.000000, 0.000000, 88.000000, 75.000000, 0.000000}
            	case 1..6, 8, 14, 16, 22, 27, 29, 33, 41..49, 82..84, 86, 87, 119, 289: SPAO{0.070000, 0.000000, 0.000000, 88.000000, 77.000000, 0.000000}
            	case 7, 10: SPAO{0.090000, 0.019999, 0.000000, 88.000000, 90.000000, 0.000000}
            	case 9: SPAO{0.059999, 0.019999, 0.000000, 88.000000, 90.000000, 0.000000}
            	case 11..13: SPAO{0.070000, 0.019999, 0.000000, 88.000000, 90.000000, 0.000000}
            	case 15: SPAO{0.059999, 0.000000, 0.000000, 88.000000, 82.000000, 0.000000}
            	case 17..21: SPAO{0.059999, 0.019999, 0.000000, 88.000000, 82.000000, 0.000000}
            	case 23..26, 28, 30..32, 34..39, 57, 58, 98, 99, 104..118, 120..131: SPAO{0.079999, 0.019999, 0.000000, 88.000000, 82.000000, 0.000000}
            	case 40: SPAO{0.050000, 0.009999, 0.000000, 88.000000, 82.000000, 0.000000}
            	case 50, 100..103, 148, 150..189, 222: SPAO{0.070000, 0.009999, 0.000000, 88.000000, 82.000000, 0.000000}
            	case 51..54: SPAO{0.100000, 0.009999, 0.000000, 88.000000, 82.000000, 0.000000}
            	case 55, 56, 63, 64, 66..73, 75, 76, 78..81, 133..143, 147, 190..207, 209..219, 221, 247..272, 274..288, 290..293: SPAO{0.070000, 0.019999, 0.000000, 88.000000, 82.000000, 0.000000}
            	case 59..62: SPAO{0.079999, 0.029999, 0.000000, 88.000000, 82.000000, 0.000000}
            	case 77: SPAO{0.059999, 0.019999, 0.000000, 87.000000, 82.000000, 0.000000}
            	case 85, 88, 89: SPAO{0.070000, 0.039999, 0.000000, 88.000000, 82.000000, 0.000000}
            	case 90..97: SPAO{0.050000, 0.019999, 0.000000, 88.000000, 82.000000, 0.000000}
            	case 132: SPAO{0.000000, 0.019999, 0.000000, 88.000000, 82.000000, 0.000000}
            	case 144..146: SPAO{0.090000, 0.000000, 0.000000, 88.000000, 82.000000, 0.000000}
            	case 220: SPAO{0.029999, 0.019999, 0.000000, 88.000000, 82.000000, 0.000000}
            	case 223, 246: SPAO{0.070000, 0.050000, 0.000000, 88.000000, 82.000000, 0.000000}
            	case 224..245: SPAO{0.070000, 0.029999, 0.000000, 88.000000, 82.000000, 0.000000}
            	case 294: SPAO{0.070000, 0.019999, 0.000000, 91.000000, 84.000000, 0.000000}
            	case 295: SPAO{0.050000, 0.019998, 0.000000, 86.000000, 82.000000, 0.000000}
            	case 296..298: SPAO{0.064999, 0.009999, 0.000000, 88.000000, 82.000000, 0.000000}
    			case 299: SPAO{0.064998, 0.019999, 0.000000, 88.000000, 82.000000, 0.000000}
			}
		}
	}else
   	{
		RemovePlayerAttachedObject(playerid, 1);
   	}
	return 1;
}
public OnPlayerEnterRaceCheckpoint(playerid)
{
	if(CPProgess[playerid] == TotalCP -1)
	{
		new TimeStamp,TotalRaceTime,string[256],rFile[256],rTime[3],Prize[3],TempTotalTime,TempTime[3];
		Position++;
		TimeStamp = GetTickCount();
		TotalRaceTime = TimeStamp - RaceTick;
		ConvertTimeEx(var, TotalRaceTime, rTime[0], rTime[1], rTime[2]);
		switch(Position)
		{
		    case 1: Prize[0] = (random(random(5000)) + 10000), Prize[1] = 10, Prize[2] = 80;
		    case 2: Prize[0] = (random(random(4500)) + 9000), Prize[1] = 9, Prize[2] = 70;
		    case 3: Prize[0] = (random(random(4000)) + 8000), Prize[1] = 8, Prize[2] = 60;
		    case 4: Prize[0] = (random(random(3500)) + 7000), Prize[1] = 7, Prize[2] = 50;
		    case 5: Prize[0] = (random(random(3000)) + 6000), Prize[1] = 6, Prize[2] = 40;
		    case 6: Prize[0] = (random(random(2500)) + 5000), Prize[1] = 5, Prize[2] = 30;
		    case 7: Prize[0] = (random(random(2000)) + 4000), Prize[1] = 4, Prize[2] = 20;
		    case 8: Prize[0] = (random(random(1500)) + 3000), Prize[1] = 3, Prize[2] = 15;
		    case 9: Prize[0] = (random(random(1000)) + 2000), Prize[1] = 2, Prize[2] = 10;
		    default: Prize[0] = random(random(1000)), Prize[1] = 1, Prize[2] = 5;
		}
		format(string, sizeof(string), "Race » {FFFFFF}%s yarýþý %d. bitirdi. Süre %d:%d:%d Odul: $%d + %d skor + %d exp", PlayerName(playerid), Position, rTime[0], rTime[1], rTime[2], Prize[0], Prize[1], Prize[2]);
		SendClientMessageToAll(0x999900FF, string);
		if(FinishCount <= 5)
		{
			format(rFile, sizeof(rFile), "LYNX/Yaris/%s.RRACE", RaceName);
		    format(string, sizeof(string), "BestRacerTime_%d", TimeProgress);
		    TempTotalTime = dini_Int(rFile, string);
		    ConvertTimeEx(var1, TempTotalTime, TempTime[0], TempTime[1], TempTime[2]);
		    if(TotalRaceTime <= dini_Int(rFile, string) || TempTotalTime == 0)
		    {
		        dini_IntSet(rFile, string, TotalRaceTime);
				format(string, sizeof(string), "BestRacer_%d", TimeProgress);
				dini_Set(rFile, string, PlayerName(playerid));
				TimeProgress++;
		    }
		}
		FinishCount++;
		GivePlayerCash(playerid, Prize[0]);
		GivePlayerScore(playerid, Prize[1]);
		GivePlayerExp(playerid, Prize[2]);
		DisablePlayerRaceCheckpoint(playerid);
		DisableRemoteVehicleCollisions(playerid, 0);
		SetPlayerVirtualWorld(playerid, 0);
		PlayerTextDrawHide(playerid, RaceInfo[playerid]);
		Oyuncu[playerid][Yarista] = false;
		OnPlayerSpawn(playerid);
		CPProgess[playerid]++;
		if(FinishCount >= JoinCount) return StopRace();
    }else
	{
		CPProgess[playerid]++;
		CPCoords[CPProgess[playerid]][3]++;
	    SetCP(playerid, CPProgess[playerid], CPProgess[playerid]+1, TotalCP, RaceType);
	    PlayerPlaySound(playerid, 1137, 0.0, 0.0, 0.0);
		GetVehiclePos(GetPlayerVehicleID(playerid), SosPos[playerid][0], SosPos[playerid][1], SosPos[playerid][2]);
		GetVehicleZAngle(GetPlayerVehicleID(playerid), SosPos[playerid][3]);
		GetVehicleVelocity(GetPlayerVehicleID(playerid), SosHiz[playerid][0], SosHiz[playerid][1], SosHiz[playerid][2]);
	}
    return 1;
}
public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
	if(Oyuncu[playerid][Admin] > 1)	SetPlayerPosEx(playerid, fX, fY, fZ);
    return 1;
}
public OnPlayerDamage(&playerid, &Float:amount, &issuerid, &weapon, &bodypart)
{
    if(issuerid != INVALID_PLAYER_ID)
	{
        if(IsPlayerPaused(playerid)) return 0;
		if(weapon == 34 && bodypart == 9)
		{
			GameTextForPlayer(issuerid,"~g~HeadShot",2000,1);
			GameTextForPlayer(playerid,"~r~HeadShot",2000,1);
			amount = 0.0;
		}
		if(IsValidWeapon(weapon)) Oyuncu[playerid][YaraliTime] = GetTickCount() + 3000;
	}
	return 1;
}
public OnRejectedHit(playerid, hit[E_REJECTED_HIT])
{
	new iString[128];
	format(iString, sizeof(iString), "Rejected hit: {C0BFC2}(%s -> %s) {FFFFFF}%s", ReturnWeaponNameEx(hit[e_Weapon]), hit[e_Name], g_HitRejectReasons[hit[e_Reason]]);
	SendClientMessage(playerid, 0x970209FF, iString);
    PlayerPlaySound(playerid, 1135, 0.0, 0.0, 0.0);
    return 1;
}
public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
	if(fX > 2140000000 || fY > 2140000000 || fZ > 2140000000)
	{
		KickReason(playerid, "Bullet Crash", "Sistem");
        return 0;
    }
    return 1;
}
bool:CheckPlayerSprintMacro(playerid, newkeys, oldkeys)
{
	if(PRESSED(KEY_SPRINT))
	{
		if(GetPlayerVehicleID(playerid) != 0)
		{
			UpdatePlayerSprintMacroData(playerid, GetPlayerSpeed(playerid), GetTickCount(), true);
			return false;
		}
		if(GetPlayerSurfingVehicleID(playerid) != INVALID_VEHICLE_ID)
		{
			UpdatePlayerSprintMacroData(playerid, GetPlayerSpeed(playerid), GetTickCount(), true);
			return false;
		}
		if(GetPlayerSpeed(playerid) < 40)
		{
			UpdatePlayerSprintMacroData(playerid, GetPlayerSpeed(playerid), GetTickCount(), true);
			return false;
		}
		if((GetPlayerSpeed(playerid) - Oyuncu[playerid][LastMonitoredSpeed]) < 0)
		{
			UpdatePlayerSprintMacroData(playerid, GetPlayerSpeed(playerid), GetTickCount(), true);
			return false;
		}
		new diff = GetTickCount() - Oyuncu[playerid][LastTimeSprinted];
		if(diff >= 65 || diff == 0)
		{
			UpdatePlayerSprintMacroData(playerid, GetPlayerSpeed(playerid), GetTickCount(), true);
			return false;
		}
		Oyuncu[playerid][TimesWarned] ++;
		Oyuncu[playerid][LastTimeWarned] = GetTickCount();
		if(Oyuncu[playerid][TimesWarned] == 3)
		{
			Oyuncu[playerid][TimesWarned] = 0;
			Oyuncu[playerid][LastTimeWarned] = 0;
			new str[128];
			format(str, sizeof str, "Macro kapat kardeþim %s", PlayerName(playerid));
			SendClientMessageToAll(0xFF0000FF, str);
			TogglePlayerControllable(playerid, false);
			TogglePlayerControllable(playerid, true);
			return true;
		}
		UpdatePlayerSprintMacroData(playerid, GetPlayerSpeed(playerid), GetTickCount(), false);
	}
	return false;
}
public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    if(CheckPlayerSprintMacro(playerid, newkeys, oldkeys) == true) return 1;
    if(newkeys == 160 && (GetPlayerWeapon(playerid) == 0 || GetPlayerWeapon(playerid) == 1) && !IsPlayerInAnyVehicle(playerid))
	{
	    if(SureYasagi(playerid, "Sync", 5)) return 1;
		SyncPlayer(playerid);
		return 1;
	}
    if(newkeys & KEY_FIRE && IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER && Oyuncu[playerid][Yarista] == false)
    {
        MyCarPress(playerid, PVG->Int->FireKey[playerid]);
        return 1;
    }
    if(newkeys & KEY_CROUCH && IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER && Oyuncu[playerid][Yarista] == false)
    {
        MyCarPress(playerid, PVG->Int->HKey[playerid]);
        return 1;
    }
	if(newkeys & KEY_JUMP && Oyuncu[playerid][eJump] == true && Oyuncu[playerid][TDM] == false && Oyuncu[playerid][GunGamede] == false && Oyuncu[playerid][Dmde] == false)
	{
 		if(!SureYasagi2(playerid, "eJumpx", 5))return 1;
		new Float:ePos[3];
		GetPlayerVelocity(playerid, ePos[0], ePos[1], ePos[2]);
		SetPlayerVelocity(playerid, ePos[0], ePos[1], ePos[2]+5);
  	}
 	if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING && Oyuncu[playerid][Specte] == true && Oyuncu[playerid][SpecID] != INVALID_PLAYER_ID)
	{
	    switch(newkeys)
	    {
	        case KEY_JUMP: AdvanceSpectate(playerid);
	        case KEY_SPRINT: ReverseSpectate(playerid);
	    }
	}
    if(newkeys & KEY_YES && IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
        new Float:angle;
        GetVehicleZAngle(GetPlayerVehicleID(playerid), angle);
        SetVehicleZAngle(GetPlayerVehicleID(playerid), angle);
        return 1;
    }
    if(newkeys & KEY_LOOK_BEHIND && IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
     	SetVehicleHealth(GetPlayerVehicleID(playerid), 1000.0);
   	 	AddVehicleComponent(GetPlayerVehicleID(playerid), 1010);
       	RepairVehicle(GetPlayerVehicleID(playerid));
       	PlayerPlaySound(playerid,1133,0.0,0.0,0.0);
       	return 1;
	}
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		new nos = GetVehicleComponentInSlot(GetPlayerVehicleID(playerid), CARMODTYPE_NITRO);
		if(nos == 0) return 1;
		if(((newkeys & KEY_FIRE) && !(oldkeys & KEY_FIRE)) || ((newkeys & KEY_ACTION) && !(oldkeys & KEY_ACTION)))
		{
			KillTimer(Oyuncu[playerid][NosTimer]);
			Oyuncu[playerid][NosTimer] = SetTimerEx("UpdatePlayerNos", 2000, true, "i", playerid);
		}
		if(((oldkeys & KEY_FIRE) && !(newkeys & KEY_FIRE)) || ((oldkeys & KEY_ACTION) && !(newkeys & KEY_ACTION)))
		{
			RemoveVehicleComponent(GetPlayerVehicleID(playerid), nos);
			AddVehicleComponent(GetPlayerVehicleID(playerid), nos);
			KillTimer(Oyuncu[playerid][NosTimer]);
		}
	}
	new	string[256], rFile[256], Float: vPos[4];
	if(newkeys & KEY_FIRE)
	{
	    if(BuildRace == playerid+1)
	    {
		    if(BuildTakeVehPos == true)
		    {
		    	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, -1, ">> You need to be in a vehicle");
				format(rFile, sizeof(rFile), "LYNX/Yaris/%s.RRACE", BuildName);
				GetVehiclePos(GetPlayerVehicleID(playerid), vPos[0], vPos[1], vPos[2]);
				GetVehicleZAngle(GetPlayerVehicleID(playerid), vPos[3]);
		        dini_Create(rFile);
				dini_IntSet(rFile, "vModel", BuildModeVID);
				dini_IntSet(rFile, "rType", BuildRaceType);
		        format(string, sizeof(string), "vPosX_%d", BuildVehPosCount), dini_FloatSet(rFile, string, vPos[0]);
		        format(string, sizeof(string), "vPosY_%d", BuildVehPosCount), dini_FloatSet(rFile, string, vPos[1]);
		        format(string, sizeof(string), "vPosZ_%d", BuildVehPosCount), dini_FloatSet(rFile, string, vPos[2]);
		        format(string, sizeof(string), "vAngle_%d", BuildVehPosCount), dini_FloatSet(rFile, string, vPos[3]);
		        format(string, sizeof(string), ">> Vehicle Pos '%d' has been taken.", BuildVehPosCount+1);
		        SendClientMessage(playerid, -1, string);
				BuildVehPosCount++;
			}
   			if(BuildVehPosCount >= 2)
		    {
		        BuildVehPosCount = 0;
		        BuildTakeVehPos = false;
		        ShowDialog(playerid, 605);
		    }
			if(BuildTakeCheckpoints == true)
			{
			    if(BuildCheckPointCount > MAX_RACE_CHECKPOINTS_EACH_RACE) return SendClientMessage(playerid, -1, ">> You reached the maximum amount of checkpoints!");
			    if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, -1, ">> You need to be in a vehicle");
				format(rFile, sizeof(rFile), "LYNX/Yaris/%s.RRACE", BuildName);
				GetVehiclePos(GetPlayerVehicleID(playerid), vPos[0], vPos[1], vPos[2]);
				format(string, sizeof(string), "CP_%d_PosX", BuildCheckPointCount), dini_FloatSet(rFile, string, vPos[0]);
				format(string, sizeof(string), "CP_%d_PosY", BuildCheckPointCount), dini_FloatSet(rFile, string, vPos[1]);
				format(string, sizeof(string), "CP_%d_PosZ", BuildCheckPointCount), dini_FloatSet(rFile, string, vPos[2]);
    			format(string, sizeof(string), ">> Checkpoint '%d' has been setted!", BuildCheckPointCount+1);
		        SendClientMessage(playerid, -1, string);
				BuildCheckPointCount++;
			}
		}
	}
	if(newkeys & KEY_SECONDARY_ATTACK)
	{
	    if(BuildTakeCheckpoints == true)
	    {
	        ShowDialog(playerid, 606);
			TotalRaces = dini_Int("LYNX/Yaris/YarisIsimleri/RaceNames.txt", "TotalRaces");
			TotalRaces++;
			dini_IntSet("LYNX/Yaris/YarisIsimleri/RaceNames.txt", "TotalRaces", TotalRaces);
			format(string, sizeof(string), "Race_%d", TotalRaces-1);
			format(rFile, sizeof(rFile), "LYNX/Yaris/%s.RRACE", BuildName);
			dini_Set("LYNX/Yaris/YarisIsimleri/RaceNames.txt", string, BuildName);
			dini_IntSet(rFile, "TotalCP", BuildCheckPointCount);
			Loop(x, 5)
			{
				format(string, sizeof(string), "BestRacerTime_%d", x);
				dini_Set(rFile, string, "0");
				format(string, sizeof(string), "BestRacer_%d", x);
				dini_Set(rFile, string, "noone");
			}
	    }
	}
	return 1;
}
public OnQueryError(errorid, const error[], const callback[], const query[], MySQL:handle)
{
    printf("[MySQL]: HATAID: %d | HATA: %s | CALLBACK: %s | QUERY: %s", errorid, error, callback, query);
	return 1;
}
function UpdatePlayerNos(playerid)
{
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		new nos = GetVehicleComponentInSlot(GetPlayerVehicleID(playerid), CARMODTYPE_NITRO);
		if(nos == 0) return 1;
		AddVehicleComponent(GetPlayerVehicleID(playerid), nos);
	}
	return 1;
}
stock IsNumeric(const string[])
{
	for(new i = 0, j = strlen(string); i < j; i++)
	{
		if (string[i] > '9' || string[i] < '0') return 0;
	}
    return 1;
}
stock IsValidWeapon(weaponid)
{
    if(weaponid >= 0 && weaponid < 19 || weaponid > 21 && weaponid < 47) return 1;
    return 0;
}
function KickReason(id, reason[], admin[])
{
	new string[156], yazi[256],	h, m, s, g, a, y;
	for(new cc = 0; cc < 20; cc++) SendClientMessage(id, 0xFFFFFFFF, "");
	format(string,sizeof(string),"[KICK] {FFFFFF}%s, %s'i kickledi. Sebep %s", admin, PlayerName(id), reason);
	SendClientMessageToAll(0xFF0000FF,string);
	gettime(h,m,s),getdate(g,a,y);
    format(yazi,sizeof(yazi),"{FF0000}Kickleyen:\t\t\t{FFFFFF}%s\n{FF0000}Sebep:\t\t\t{FFFFFF}%s\n{FF0000}Saat:\t\t\t{FFFFFF}%02d:%02d:%02d\n{FF0000}Tarih:\t\t\t{FFFFFF}%d/%d/%d",admin, reason, h, m, s, g, a, y);
    ShowPlayerDialog(id,DIALOG_CEZA,DIALOG_STYLE_MSGBOX,"{FF0000}LYNX DRIFT - {FFFFFF}Kick",yazi,"Tamam","");
	KickPlayer(id);
	return 1;
}
function BanReason(id, reason[], admin[])
{
	new string[156], yazi[256], h, m, s, g, a, y;
	for(new cc = 0; cc < 20; cc++) SendClientMessage(id, 0xFFFFFFFF, "");
	format(string,sizeof(string),"[BAN] {FFFFFF}%s, %s'i banladý. Sebep %s", admin, PlayerName(id), reason);
	SendClientMessageToAll(0xFF0000FF,string);
	gettime(h,m,s),getdate(g,a,y);
    format(yazi,sizeof(yazi),"{FF0000}Banlayan:\t\t\t{FFFFFF}%s\n{FF0000}Sebep:\t\t\t{FFFFFF}%s\n{FF0000}Saat:\t\t\t{FFFFFF}%02d:%02d:%02d\n{FF0000}Tarih:\t\t\t{FFFFFF}%d/%d/%d",admin, reason, h, m, s, g, a, y);
    ShowPlayerDialog(id,DIALOG_CEZA,DIALOG_STYLE_MSGBOX,"{FF0000}LYNX DRIFT - {FFFFFF}Ban",yazi,"Tamam","");
	BanPlayer(id);
	return 1;
}
function NBanReason(id, reason[], admin[])
{
	new string[156], yazi[256], h, m, s, g, a, y;
	for(new cc = 0; cc < 20; cc++) SendClientMessage(id, 0xFFFFFFFF, "");
	format(string,sizeof(string),"[NBAN] {FFFFFF}%s, %s'i nbanladý. Sebep %s", admin, PlayerName(id), reason);
	SendClientMessageToAll(0xFF0000FF,string);
	gettime(h,m,s), getdate(g,a,y);
    format(yazi,sizeof(yazi),"{FF0000}NBanlayan:\t\t\t{FFFFFF}%s\n{FF0000}Sebep:\t\t\t{FFFFFF}%s\n{FF0000}Saat:\t\t\t{FFFFFF}%02d:%02d:%02d\n{FF0000}Tarih:\t\t\t{FFFFFF}%d/%d/%d",admin, reason, h, m, s, g, a, y);
    ShowPlayerDialog(id,DIALOG_CEZA,DIALOG_STYLE_MSGBOX,"{FF0000}LYNX DRIFT - {FFFFFF}N-Ban",yazi,"Tamam","");
  	BanPlayer(id);
	return 1;
}
function LoginKick(playerid)
{
	ShowPlayerDialog(playerid, -1, 0, " ", " ", " ", " ");
	SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}40 saniye içinde giriþ yapmalýydýnýz. Kicklendiniz!");
	KickPlayer(playerid);
	return 1;
}
function SavePlayer(playerid)
{
	if(Oyuncu[playerid][Giris] != true) return 1;
	if(Oyuncu[playerid][SQL] <= 0) return 1;
	new query[256];
	Oyuncu[playerid][Skor] = GetPlayerScore(playerid);
	mysql_format(g_SQL, query, sizeof(query), "UPDATE `hesaplar` SET `player_admin` = '%d', `player_dj` = '%d' WHERE `player_id` = '%i'", Oyuncu[playerid][Admin], Oyuncu[playerid][DJ], Oyuncu[playerid][SQL]);
	mysql_tquery(g_SQL, query);
	mysql_format(g_SQL, query, sizeof(query), "UPDATE `hesaplar` SET `player_skor` = '%d', `player_para` = '%d' WHERE `player_id` = '%i'", Oyuncu[playerid][Skor], Oyuncu[playerid][Para], Oyuncu[playerid][SQL]);
	mysql_tquery(g_SQL, query);
	mysql_format(g_SQL, query, sizeof(query), "UPDATE `hesaplar` SET `player_giris` = '%d' WHERE `player_id` = '%i'", Oyuncu[playerid][GirisSayisi], Oyuncu[playerid][SQL]);
	mysql_tquery(g_SQL, query);
	mysql_format(g_SQL, query, sizeof(query), "UPDATE `hesaplar` SET `player_oldurme` = '%d', `player_olum` = '%d' WHERE `player_id` = '%i'", Oyuncu[playerid][Oldurme], Oyuncu[playerid][Olum], Oyuncu[playerid][SQL]);
	mysql_tquery(g_SQL, query);
	mysql_format(g_SQL, query, sizeof(query), "UPDATE `hesaplar` SET `player_online` = '%d', `player_skin` = '%d' WHERE `player_id` = '%i'", Oyuncu[playerid][Online], Oyuncu[playerid][Skin], Oyuncu[playerid][SQL]);
	mysql_tquery(g_SQL, query);
	mysql_format(g_SQL, query, sizeof(query), "UPDATE `hesaplar` SET `player_exp` = '%d', `player_explevel` = '%d' WHERE `player_id` = '%i'", Oyuncu[playerid][Exp], Oyuncu[playerid][ExpLevel], Oyuncu[playerid][SQL]);
	mysql_tquery(g_SQL, query);
	mysql_format(g_SQL, query, sizeof(query), "UPDATE `hesaplar` SET `player_ates` = '%d', `player_h` = '%d' WHERE `player_id` = '%i'", PVG->Int->FireKey[playerid], PVG->Int->HKey[playerid], Oyuncu[playerid][SQL]);
	mysql_tquery(g_SQL, query);
	return 1;
}
function OnConnection(playerid)
{
	new Query[128];
	mysql_format(g_SQL, Query, sizeof(Query),"SELECT * FROM `hesaplar` WHERE `player_name` = '%e' LIMIT 1", PlayerName(playerid));
	new Cache:VeriCek = mysql_query(g_SQL, Query);
	if(cache_num_rows())
	{
	    cache_get_value_name_int(0, "player_nban", Oyuncu[playerid][NBan]);
	    if(Oyuncu[playerid][NBan] == 1)
	    {
	        cache_delete(VeriCek);
	        KickReason(playerid, "Name Ban", "Sistem");
	        return 1;
	    }
	    new xdd[16];
	    cache_get_value_name(0, "player_ip", xdd, 16);
	    if(!strcmp(Oyuncu[playerid][IP], xdd, true))
	    {
            cache_delete(VeriCek);
	        LoadStats(playerid);
			SendClientMessage(playerid, 0x66FFFFFF, "Bilgi » {FFFFFF}Otomatik giriþ yaptýnýz. Ýyi eðlenceler!");
	        Oyuncu[playerid][Giris] = true;
         	LabelAyarla(playerid);
	        return 1;
	    }
  		KillTimer(Oyuncu[playerid][LoginTimer]);
		Oyuncu[playerid][LoginTimer] = SetTimerEx("LoginKick",40*1000,false,"d",playerid);
		new String[128], str[350];
		strcat(str, "{FF0000}LYNX DRIFT{FFFFFF}'e Hoþgeldiniz!\n");
		format(String, sizeof(String), "{FFFFFF}Sunucu veritabanýnda {FF0000}%s(%i) {FFFFFF}adýnda bir kullanýcý bulunuyor.\n", PlayerName(playerid), playerid);
		strcat(str, String);
		strcat(str, "{FFFFFF}Giriþ yapmak için aþaðýdaki kutucuða þifrenizi giriniz.\n\n");
		strcat(str, "{FF0000}Bilgi » {FFFFFF}Þifrenizi 40 saniye içinde girmelisiniz.");
		ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "{FF0000}LYNX DRIFT - {FFFFFF}Giriþ", str, "Giriþ", "Çýkýþ");
	}else
	{
		new String[128], str[350];
		strcat(str, "{FF0000}LYNX DRIFT{FFFFFF}'e Hoþgeldiniz!\n");
		format(String, sizeof(String), "{FFFFFF}Sunucu veritabanýnda {FF0000}%s(%i) {FFFFFF}adýnda bir kullanýcý bulunmuyor.\n", PlayerName(playerid), playerid);
		strcat(str, String);
		strcat(str, "{FFFFFF}Kayýt olmak için aþaðýdaki kutucuða þifrenizi giriniz.\n\n");
		strcat(str, "{FF0000}Bilgi » {FFFFFF}Þifreniz en az 4, en fazla 32 karakterden oluþabilir.");
		ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "{FF0000}LYNX DRIFT - {FFFFFF}Kayýt", str, "Kayýt", "Çýkýþ");
	}
	cache_delete(VeriCek);
	return 1;
}
stock NickKontrol(nick[])
{
	new query[156];
	mysql_format(g_SQL, query, sizeof(query), "SELECT * FROM `hesaplar` WHERE `player_name` = '%e'", nick);
	new Cache:VeriCek = mysql_query(g_SQL, query);
	if(cache_num_rows())
	{
		cache_delete(VeriCek);
		return 0;
	}
	cache_delete(VeriCek);
	return 1;
}
stock AracIsimiGiris(vname[])
{
	for(new i = 0; i < 211; i++)
	{
		if(strfind(AracIsimler[i], vname, true) != -1) return i + 400;
	}
	return -1;
}
function ServerTimer()
{
    foreach(new i: Player)
	{
		if(GetPlayerPing(i) >= 1000)
		{
			KickReason(i, "Max Ping", "Sistem");
			return 1;
		}
		if(!IsPlayerPaused(i)) Oyuncu[i][Online]++;
  		new str[25];
		format(str, sizeof(str), "$%08i", Oyuncu[i][Para]);
		PlayerTextDrawSetString(i, ParaText[i], str);
 	}
	return 1;
}
function RekorCheck(playerid)
{
	if(Iter_Count(Player) > RekorInfo[r_Oyuncu])
	{
	    if(dini_Exists("LYNX/Diger/Rekor.ini"))
	    {
	        new string[156];
		    RekorInfo[r_Oyuncu] = Iter_Count(Player);
		    RekorInfo[r_MOyuncu] = GetMaxPlayers();
		    RekorInfo[r_Tarih] = gettime();
	    	dini_IntSet("LYNX/Diger/Rekor.ini", "oyuncu", RekorInfo[r_Oyuncu]);
	    	dini_IntSet("LYNX/Diger/Rekor.ini", "tarih", RekorInfo[r_Tarih]);
	    	dini_IntSet("LYNX/Diger/Rekor.ini", "maxoyuncu", RekorInfo[r_MOyuncu]);
	    	printf("Rekor » Sunucu yeni bir rekor kirdi. (%d/%d oyuncu ile)", Iter_Count(Player), GetMaxPlayers());
	    	format(string, sizeof(string), "Rekor » {FFFFFF}Sunucu {FF0000}%d/%d {FFFFFF}oyuncu ile rekor kirdi.", Iter_Count(Player), GetMaxPlayers());
            SendClientMessageToAll(0xFF0000FF, string);
	    }
	    return 1;
	}
	return 1;
}
stock Rekorlar()
{
	if(dini_Exists("LYNX/Diger/Rekor.ini"))
	{
		RekorInfo[r_Oyuncu] = strval(dini_Get("LYNX/Diger/Rekor.ini", "oyuncu"));
		RekorInfo[r_Tarih] = strval(dini_Get("LYNX/Diger/Rekor.ini", "tarih"));
		RekorInfo[r_MOyuncu] = strval(dini_Get("LYNX/Diger/Rekor.ini", "maxoyuncu"));
		printf("Rekor » Sunucu rekoru yuklendi. %d/%d (%s)", RekorInfo[r_Oyuncu], RekorInfo[r_MOyuncu], DateConvert(RekorInfo[r_Tarih]));
	}else
	{
		dini_Create("LYNX/Diger/Rekor.ini");
		printf("Rekor » dosyasi olmadigi icin yeni rekor dosyasi olusturuldu.");
	}
	return 1;
}
stock Akalar()
{
	if(!dini_Exists("LYNX/Diger/Aka.txt"))
	{
		dini_Create("LYNX/Diger/Aka.txt");
		printf("Aka » dosyasi olmadigi icin yeni aka dosyasi olusturuldu.");
	}
	return 1;
}
stock TeleportInfo(playerid, telname[], komut[])
{
	new string[126];
	format(string, sizeof(string), "Teleport » {FFFFFF}%s {FFCC33}>> {FFFFFF}%s ({FFCC33}/%s{FFFFFF})", PlayerName(playerid), telname, komut);
	SendClientMessageToAll(0xFFCC33FF,string);
	GameTextForPlayer(playerid, telname, 1000, 3);
	return 1;
}
stock DeathmatchInfo(playerid, telname[], komut[])
{
	new string[126];
	format(string, sizeof(string), "Deathmatch » {FFFFFF}%s {9999FF}>> {FFFFFF}%s ({9999FF}/%s{FFFFFF})", PlayerName(playerid),telname,komut);
	SendClientMessageToAll(0x9999FFFF,string);
	GameTextForPlayer(playerid, telname, 1000, 3);
	return 1;
}
stock SetPlayerPosEx(playerid, Float:pX, Float:pY, Float:pZ)
{
	if(IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
 		SetVehiclePos(GetPlayerVehicleID(playerid), pX, pY, pZ);
 		SetVehicleZAngle(GetPlayerVehicleID(playerid), 0);
	}else
	{
 		SetPlayerPos(playerid, pX, pY, pZ);
	}
}
stock LoadStats(playerid)
{
    new query[356];
    mysql_format(g_SQL, query, sizeof(query), "SELECT * FROM `hesaplar` WHERE `player_name` = '%e'", PlayerName(playerid));
	new Cache:VeriCek = mysql_query(g_SQL, query);
    if(cache_num_rows())
	{
	    cache_get_value_name_int(0, "player_id", Oyuncu[playerid][SQL]);
	    cache_get_value_name_int(0, "player_para", Oyuncu[playerid][Para]);
	    cache_get_value_name_int(0, "player_skor", Oyuncu[playerid][Skor]);
	    cache_get_value_name_int(0, "player_kayit", Oyuncu[playerid][Kayit]);
	    cache_get_value_name_int(0, "player_admin", Oyuncu[playerid][Admin]);
	    cache_get_value_name_int(0, "player_dj", Oyuncu[playerid][DJ]);
	    cache_get_value_name_int(0, "player_olum", Oyuncu[playerid][Olum]);
	    cache_get_value_name_int(0, "player_oldurme", Oyuncu[playerid][Oldurme]);
	    cache_get_value_name_int(0, "player_giris", Oyuncu[playerid][GirisSayisi]);
	    cache_get_value_name_int(0, "player_online", Oyuncu[playerid][Online]);
	    cache_get_value_name_int(0, "player_skin", Oyuncu[playerid][Skin]);
	    cache_get_value_name_int(0, "player_exp", Oyuncu[playerid][Exp]);
	    cache_get_value_name_int(0, "player_explevel", Oyuncu[playerid][ExpLevel]);
	    new aq;
	    cache_get_value_name_int(0, "player_ates", aq);
	    PVS->Int->FireKey[playerid]->aq;
	    cache_get_value_name_int(0, "player_h", aq);
	    PVS->Int->HKey[playerid]->aq;
    }
    cache_delete(VeriCek);
	mysql_format(g_SQL, query, sizeof(query), "UPDATE `hesaplar` SET `player_ip` = '%s' WHERE `player_id` = '%i'", Oyuncu[playerid][IP], Oyuncu[playerid][SQL]);
	mysql_tquery(g_SQL, query);
	Oyuncu[playerid][GirisSayisi]++;
	SetPlayerScore(playerid, Oyuncu[playerid][Skor]);
	ResetPlayerMoney(playerid), GivePlayerMoney(playerid, Oyuncu[playerid][Para]);
	return 1;
}
stock PlayerName(playerid)
{
	new oName[MAX_PLAYER_NAME];
	GetPlayerName(playerid, oName, sizeof oName);
	return oName;
}
stock DateConvert(timestamp, _form=0)
{
    new
		year = 1970, day = 0, month = 0, hour = 0, mins = 0, sec = 0,
		days_of_month[12] = {31,28,31,30,31,30,31,31,30,31,30,31},
		names_of_month[12][10] = {"Ocak","Subat","Mart","Nisan","Mayis","Haziran","Temmuz","Agustos","Eylul","Ekim","Kasim","Aralik"},
		returnstring[56];
    while(timestamp > 31622400)
	{
        timestamp -= 31536000;
        if(((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0)) timestamp -= 86400;
        year++;
    }
    if(((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0))
	{
        days_of_month[1] = 29;
    }else
    {
        days_of_month[1] = 28;
    }
	while(timestamp > 86400)
	{
        timestamp -= 86400, day++;
        if(day == days_of_month[month]) day = 0, month++;
    }
    while(timestamp > 60)
	{
        timestamp -= 60, mins++;
        if(mins == 60) mins = 0, hour++;
    }
    sec = timestamp;
    switch( _form )
	{
        case 1: format(returnstring, 56, "%02d/%02d/%d %02d:%02d:%02d", day+1, month+1, year, hour, mins, sec);
        case 2: format(returnstring, 56, "%s %02d, %d, %02d:%02d:%02d", names_of_month[month],day+1,year, hour, mins, sec);
        case 3: format(returnstring, 56, "%d %c%c%c %d, %02d:%02d", day+1,names_of_month[month][0],names_of_month[month][1],names_of_month[month][2], year,hour,mins);
        case 4: format(returnstring, 56, "%d %c%c%c %d, %02d:%02d", day+1,names_of_month[month][0],names_of_month[month][1],names_of_month[month][2], year,hour,mins);
        case 5: format(returnstring, 56, "%02d/%02d/%d", day+1, month+1, year);
        default: format(returnstring, 56, "%02d/%02d/%d %02d:%02d:%02d", day+1, month+1, year, hour, mins, sec);
    }
    return returnstring;
}
public AntiFly(playerid)
{
	KickReason(playerid, "Fly Hack","Sistem");
 	return 1;
}
stock OnPlayerWeaponHack(playerid, aldigisilah)
{
	new str[128];
	format(str, sizeof(str), "Weapon Hack (%s)", ReturnWeaponNameEx(aldigisilah));
	KickReason(playerid, str, "Sistem");
	return 1;
}
stock OyuncuSilahDegistirdi(playerid, eskisilah, yenisilah)
{
    #pragma unused eskisilah
	if(OyuncununSilahlari[playerid][0] != 1 && GetPlayerWeapon(playerid) == 1)
	{
	    OnPlayerWeaponHack(playerid,yenisilah);
	}
	if(OyuncununSilahlari[playerid][1] != 2 && GetPlayerWeapon(playerid) == 2)
	{
	    OnPlayerWeaponHack(playerid,yenisilah);
	}
	if(OyuncununSilahlari[playerid][1] != 3 && GetPlayerWeapon(playerid) == 3)
	{
	    OnPlayerWeaponHack(playerid,yenisilah);
	}
	if(OyuncununSilahlari[playerid][1] != 4 && GetPlayerWeapon(playerid) == 4)
	{
	    OnPlayerWeaponHack(playerid,yenisilah);
	}
	if(OyuncununSilahlari[playerid][1] != 5 && GetPlayerWeapon(playerid) == 5)
	{
	    OnPlayerWeaponHack(playerid,yenisilah);
	}
	if(OyuncununSilahlari[playerid][1] != 6 && GetPlayerWeapon(playerid) == 6)
	{
	    OnPlayerWeaponHack(playerid,yenisilah);
	}
	if(OyuncununSilahlari[playerid][1] != 7 && GetPlayerWeapon(playerid) == 7)
	{
	    OnPlayerWeaponHack(playerid,yenisilah);
	}
	if(OyuncununSilahlari[playerid][1] != 8 && GetPlayerWeapon(playerid) == 8)
	{
	    OnPlayerWeaponHack(playerid,yenisilah);
	}
	if(OyuncununSilahlari[playerid][1] != 9 && GetPlayerWeapon(playerid) == 9)
	{
	    OnPlayerWeaponHack(playerid,yenisilah);
	}
	if(OyuncununSilahlari[playerid][10] != 10 && GetPlayerWeapon(playerid) == 10)
	{
	    OnPlayerWeaponHack(playerid,yenisilah);
	}
	if(OyuncununSilahlari[playerid][10] != 11 && GetPlayerWeapon(playerid) == 11)
	{
	    OnPlayerWeaponHack(playerid,yenisilah);
	}
	if(OyuncununSilahlari[playerid][10] != 12 && GetPlayerWeapon(playerid) == 12)
	{
	    OnPlayerWeaponHack(playerid,yenisilah);
	}
	if(OyuncununSilahlari[playerid][10] != 13 && GetPlayerWeapon(playerid) == 13)
	{
	    OnPlayerWeaponHack(playerid,yenisilah);
	}
	if(OyuncununSilahlari[playerid][10] != 14 && GetPlayerWeapon(playerid) == 14)
	{
	    OnPlayerWeaponHack(playerid,yenisilah);
	}
	if(OyuncununSilahlari[playerid][10] != 15 && GetPlayerWeapon(playerid) == 15)
	{
	    OnPlayerWeaponHack(playerid,yenisilah);
	}
	if(OyuncununSilahlari[playerid][8] != 16 && GetPlayerWeapon(playerid) == 16)
	{
	    OnPlayerWeaponHack(playerid,yenisilah);
	}
	if(OyuncununSilahlari[playerid][8] != 17 && GetPlayerWeapon(playerid) == 17)
	{
	    OnPlayerWeaponHack(playerid,yenisilah);
	}
	if(OyuncununSilahlari[playerid][8] != 18 && GetPlayerWeapon(playerid) == 18)
	{
	    OnPlayerWeaponHack(playerid,yenisilah);
	}
	if(OyuncununSilahlari[playerid][2] != 22 && GetPlayerWeapon(playerid) == 22)
	{
	    OnPlayerWeaponHack(playerid,yenisilah);
	}
	if(OyuncununSilahlari[playerid][2] != 23 && GetPlayerWeapon(playerid) == 23)
	{
	    OnPlayerWeaponHack(playerid,yenisilah);
	}
	if(OyuncununSilahlari[playerid][2] != 24 && GetPlayerWeapon(playerid) == 24)
	{
	    OnPlayerWeaponHack(playerid,yenisilah);
	}
	if(OyuncununSilahlari[playerid][3] != 25 && GetPlayerWeapon(playerid) == 25)
	{
	    OnPlayerWeaponHack(playerid,yenisilah);
	}
	if(OyuncununSilahlari[playerid][3] != 26 && GetPlayerWeapon(playerid) == 26)
	{
	    OnPlayerWeaponHack(playerid,yenisilah);
	}
	if(OyuncununSilahlari[playerid][3] != 27 && GetPlayerWeapon(playerid) == 27)
	{
	    OnPlayerWeaponHack(playerid,yenisilah);
	}
	if(OyuncununSilahlari[playerid][4] != 28 && GetPlayerWeapon(playerid) == 28)
	{
	    OnPlayerWeaponHack(playerid,yenisilah);
	}
	if(OyuncununSilahlari[playerid][4] != 29 && GetPlayerWeapon(playerid) == 29)
	{
	    OnPlayerWeaponHack(playerid,yenisilah);
	}
	if(OyuncununSilahlari[playerid][5] != 30 && GetPlayerWeapon(playerid) == 30)
	{
	    OnPlayerWeaponHack(playerid,yenisilah);
	}
	if(OyuncununSilahlari[playerid][5] != 31 && GetPlayerWeapon(playerid) == 31)
	{
	    OnPlayerWeaponHack(playerid,yenisilah);
	}
	if(OyuncununSilahlari[playerid][4] != 32 && GetPlayerWeapon(playerid) == 32)
	{
	    OnPlayerWeaponHack(playerid,yenisilah);
	}
	if(OyuncununSilahlari[playerid][6] != 33 && GetPlayerWeapon(playerid) == 33)
	{
	    OnPlayerWeaponHack(playerid,yenisilah);
	}
	if(OyuncununSilahlari[playerid][6] != 34 && GetPlayerWeapon(playerid) == 34)
	{
	    OnPlayerWeaponHack(playerid,yenisilah);
	}
	if(OyuncununSilahlari[playerid][7] != 35 && GetPlayerWeapon(playerid) == 35)
	{
	    OnPlayerWeaponHack(playerid,yenisilah);
	}
	if(OyuncununSilahlari[playerid][7] != 36 && GetPlayerWeapon(playerid) == 36)
	{
	    OnPlayerWeaponHack(playerid,yenisilah);
	}
	if(OyuncununSilahlari[playerid][7] != 37 && GetPlayerWeapon(playerid) == 37)
	{
	    OnPlayerWeaponHack(playerid,yenisilah);
	}
	if(OyuncununSilahlari[playerid][7] != 38 && GetPlayerWeapon(playerid) == 38)
	{
	    OnPlayerWeaponHack(playerid,yenisilah);
	}
	if(OyuncununSilahlari[playerid][8] != 39 && GetPlayerWeapon(playerid) == 39)
	{
	    OnPlayerWeaponHack(playerid,yenisilah);
	}
	if(OyuncununSilahlari[playerid][9] != 41 && GetPlayerWeapon(playerid) == 41)
	{
	    OnPlayerWeaponHack(playerid,yenisilah);
	}
	if(OyuncununSilahlari[playerid][9] != 42 && GetPlayerWeapon(playerid) == 42)
	{
	    OnPlayerWeaponHack(playerid,yenisilah);
	}
	if(OyuncununSilahlari[playerid][9] != 43 && GetPlayerWeapon(playerid) == 43)
	{
	    OnPlayerWeaponHack(playerid,yenisilah);
	}
	if(OyuncununSilahlari[playerid][11] != 44 && GetPlayerWeapon(playerid) == 44)
	{
	    OnPlayerWeaponHack(playerid,yenisilah);
	}
	if(OyuncununSilahlari[playerid][11] != 45 && GetPlayerWeapon(playerid) == 45)
	{
	    OnPlayerWeaponHack(playerid,yenisilah);
	}
	return 1;
}
stock SilahVer(playerid, Silah, Mermi)
{
	switch(Silah)
	{
	    case 0, 1:
	    {
     		OyuncununSilahlari[playerid][0] = Silah;
      		GivePlayerWeapon(playerid, Silah, Mermi);
	    }
	    case 2, 3, 4, 5, 6, 7, 8, 9:
	    {
		    OyuncununSilahlari[playerid][1] = Silah;
		    GivePlayerWeapon(playerid, Silah, Mermi);
	    }
	    case 22, 23, 24:
	    {
		    OyuncununSilahlari[playerid][2] = Silah;
		    GivePlayerWeapon(playerid, Silah, Mermi);
	    }
	    case 25, 26, 27:
	    {
		    OyuncununSilahlari[playerid][3] = Silah;
		    GivePlayerWeapon(playerid, Silah, Mermi);
	    }
	    case 28, 29, 32:
	    {
		    OyuncununSilahlari[playerid][4] = Silah;
		    GivePlayerWeapon(playerid, Silah, Mermi);
	    }
	    case 30, 31:
	    {
		    OyuncununSilahlari[playerid][5] = Silah;
		    GivePlayerWeapon(playerid, Silah, Mermi);
	    }
	    case 33, 34:
	    {
		    OyuncununSilahlari[playerid][6] = Silah;
		    GivePlayerWeapon(playerid, Silah, Mermi);
	    }
	    case 35, 36, 37, 38:
	    {
		    OyuncununSilahlari[playerid][7] = Silah;
		    GivePlayerWeapon(playerid, Silah, Mermi);
	    }
	    case 39, 16, 17, 18, 40:
	    {
		    OyuncununSilahlari[playerid][8] = Silah;
		    GivePlayerWeapon(playerid, Silah, Mermi);
	    }
	    case 41, 42, 43:
	    {
		    OyuncununSilahlari[playerid][9] = Silah;
		    GivePlayerWeapon(playerid, Silah, Mermi);
	    }
	    case 10, 11, 12, 13, 14, 15:
	    {
		    OyuncununSilahlari[playerid][10] = Silah;
		    GivePlayerWeapon(playerid, Silah, Mermi);
		}
	    case 44, 45, 46:
	    {
		    OyuncununSilahlari[playerid][11] = Silah;
		    GivePlayerWeapon(playerid, Silah, Mermi);
	    }
	}
    return 1;
}
stock AKA(playerid)
{
	new string[128];
	if(strlen(dini_Get("LYNX/Diger/Aka.txt", Oyuncu[playerid][IP])) == 0)
	{
		dini_Set("LYNX/Diger/Aka.txt", Oyuncu[playerid][IP], PlayerName(playerid));
 	}else
	{
	    if(strfind(dini_Get("LYNX/Diger/Aka.txt", Oyuncu[playerid][IP]), PlayerName(playerid), true) == -1)
		{
		    format(string,sizeof(string),"%s,%s", dini_Get("LYNX/Diger/Aka.txt", Oyuncu[playerid][IP]), PlayerName(playerid));
		    dini_Set("LYNX/Diger/Aka.txt", Oyuncu[playerid][IP], string);
		}
	}
	return 1;
}
stock IsABike(vehicleid)
{
	new result;
	switch(GetVehicleModel(vehicleid))
	{
		case 509, 481, 510, 462, 448, 581, 522, 461, 521, 523, 463, 586, 468, 471: result = GetVehicleModel(vehicleid);
		default: result = 0;
	}
	return result;
}
function LabelAyarla(playerid)
{
	switch(Oyuncu[playerid][TDM])
	{
		case true:
		{
			new string[56];
		    switch(Oyuncu[playerid][TDM_Team])
			{
				case TEAM_1: format(string,sizeof(string), "%s", TDMInfo[Team1]);
				case TEAM_2: format(string,sizeof(string), "%s", TDMInfo[Team2]);
			}
			Update3DTextLabelText(Oyuncu[playerid][Label], GetPlayerColor(playerid), string);
		}
		case false:
		{
			if(Oyuncu[playerid][Admin] > 0)
			{
				Update3DTextLabelText(Oyuncu[playerid][Label], GetPlayerColor(playerid), "Administrator");
		 	}else
		 	if(Oyuncu[playerid][DJ] > 0)
		 	{
				Update3DTextLabelText(Oyuncu[playerid][Label], GetPlayerColor(playerid), "DJ Görevlisi");
			}
		}
	}
	return 1;
}
stock CheckS0beit(playerid)
{
	SetPlayerVirtualWorld(playerid, 100+playerid);
	ResetPlayerWeapons(playerid);
	Oyuncu[playerid][Arabam] = CreateVehicle(457, 2109.1763, 1503.0453, 32.2887, 82.2873, 0, 1, 60);
	SetVehicleVirtualWorld(Oyuncu[playerid][Arabam], 100+playerid);
	PutPlayerInVehicle(playerid, Oyuncu[playerid][Arabam], 0);
	RemovePlayerFromVehicle(playerid);
	DestroyVehicle(Oyuncu[playerid][Arabam]);
	SetPlayerPos(playerid, 0.0, 0.0, 10000.0);
	SetTimerEx("AntiS0bek", 1000, false, "i", playerid);
   	return 1;
}
function AntiS0bek(playerid)
{
	new dt[2];
	GetPlayerWeaponData(playerid, WEAPON_GOLFCLUB-1, dt[0], dt[1]);
	if(dt[0] == WEAPON_GOLFCLUB)
	{
		KickReason(playerid, "Sobeit", "Sistem");
	}else
	{
		ResetPlayerWeapons(playerid);
		Oyuncu[playerid][pSpawn] = true;
		SpawnPlayer(playerid);
	}
	return 1;
}
public OnPlayerModelSelection(playerid, response, listid, modelid)
{
    if(listid == v1 || v2 || v3 || v4 || v5 || v6 || v7  || v8 || v9 || v10 || v11 || v12 || v13 || v14 || v15 || v16 || v17)
    {
        if(response)
        {
            new vehix[16];
            format(vehix,sizeof(vehix),"%d",modelid);
			dcmd_veh(playerid, vehix);
		}
	}
   	return 1;
}
stock SureYasagi(playerid, _0xyasakIsim[], _n0xsure)
{
	new _v3r1[35], string[128], _@0xsaniye;
	format(_v3r1, sizeof(_v3r1), "nTempSure_%s", _0xyasakIsim);
	if(GetPVarInt(playerid, _v3r1) > GetTickCount())
	{
	    new verilenSure = (GetPVarInt(playerid, _v3r1) - GetTickCount()) / 1000;
		_@0xsaniye = floatround(verilenSure);
		format(string, sizeof(string), "Hata » {FFFFFF}Bu komutu tekrar kullanmanýz için %d saniye beklemelisiniz.", _@0xsaniye);
	    return SendClientMessage(playerid, 0xFF0000FF, string);
	}else
	{
	    SetPVarInt(playerid, _v3r1, GetTickCount() + _n0xsure * 1000);
	    return 0;
	}
}
stock SureYasagi2(playerid, const szSpam[], iTime)
{
	static s_szPVar[32],s_iPVar;
	format(s_szPVar, sizeof(s_szPVar), "pv_iSpam_%s", szSpam);
	s_iPVar = GetPVarInt(playerid, s_szPVar);
	if((GetTickCount() - s_iPVar) < iTime * 1000)
	{
		return 0;
	}else
	{
		SetPVarInt(playerid, s_szPVar, GetTickCount());
	}
	return 1;
}
stock StartSpectate(playerid, specplayerid)
{
	foreach(new x: Player) if(GetPlayerState(x) == PLAYER_STATE_SPECTATING && Oyuncu[x][SpecID] == playerid) AdvanceSpectate(x);
	SetPlayerInterior(playerid,GetPlayerInterior(specplayerid));
	SetPlayerVirtualWorld(playerid,GetPlayerVirtualWorld(specplayerid));
	TogglePlayerSpectating(playerid, 1);
	Oyuncu[playerid][Specte] = true;
	if(IsPlayerInAnyVehicle(specplayerid))
	{
		PlayerSpectateVehicle(playerid, GetPlayerVehicleID(specplayerid));
		Oyuncu[playerid][SpecID] = specplayerid;
		Oyuncu[playerid][SpecType] = ADMIN_SPEC_TYPE_VEHICLE;
	}else
	{
		PlayerSpectatePlayer(playerid, specplayerid);
		Oyuncu[playerid][SpecID] = specplayerid;
		Oyuncu[playerid][SpecType] = ADMIN_SPEC_TYPE_PLAYER;
	}
	return 1;
}
stock StopSpectate(playerid)
{
    Oyuncu[playerid][Specte] = false;
	TogglePlayerSpectating(playerid, 0);
	SetPlayerVirtualWorld(playerid,0);
	Oyuncu[playerid][SpecID] = INVALID_PLAYER_ID;
	Oyuncu[playerid][SpecType] = ADMIN_SPEC_TYPE_NONE;
	GameTextForPlayer(playerid,"~n~~n~~n~~n~~g~Spec Modu Kapandi.",2000,3);
	return 1;
}
stock AdvanceSpectate(playerid)
{
	if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING && Oyuncu[playerid][SpecID] != INVALID_PLAYER_ID)
	{
	    for(new x=Oyuncu[playerid][SpecID]+1; x<=MAX_PLAYERS; x++)
		{
	    	if(x == MAX_PLAYERS) x = 0;
	        if(IsPlayerConnected(x) && x != playerid)
			{
				if(GetPlayerState(x) == PLAYER_STATE_SPECTATING && Oyuncu[x][SpecID] != INVALID_PLAYER_ID || (GetPlayerState(x) != 1 && GetPlayerState(x) != 2 && GetPlayerState(x) != 3))
				{
					continue;
				}else
				{
					StartSpectate(playerid, x);
					break;
				}
			}
		}
	}
	return 1;
}
stock ReverseSpectate(playerid)
{
    if(Iter_Count(Player) == 2) return StopSpectate(playerid);
	if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING && Oyuncu[playerid][SpecID] != INVALID_PLAYER_ID)
	{
	    for(new x = Oyuncu[playerid][SpecID]-1; x >= 0; x--)
		{
	    	if(x == 0) x = MAX_PLAYERS;
	        if(IsPlayerConnected(x) && x != playerid)
			{
				if(GetPlayerState(x) == PLAYER_STATE_SPECTATING && Oyuncu[x][SpecID] != INVALID_PLAYER_ID || (GetPlayerState(x) != 1 && GetPlayerState(x) != 2 && GetPlayerState(x) != 3))
				{
					continue;
				}else
				{
					StartSpectate(playerid, x);
					break;
				}
			}
		}
	}
	return 1;
}
function MyCarPress(playerid, keyy)
{
	if(keyy == 0)return 1;
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Bir aracin soforu olmaniz lazim!");
	new Float:T[4], motor, isiklar, alarm, kapilar, kaput, bagaj, objective;
	switch(keyy)
	{
		case 1:
		{
			GetVehicleZAngle(GetPlayerVehicleID(playerid), T[3]);
			GetVehicleVelocity(GetPlayerVehicleID(playerid), T[0], T[1], T[2]);
			SetVehicleVelocity(GetPlayerVehicleID(playerid),((floatadd(T[0],floatmul(1.01,floatsin(-T[3],degrees))/3.0))), ((floatadd(T[1],floatmul(1.01,floatcos(-T[3],degrees))/3.0))), T[2]);
		}
		case 2:
		{
			GetVehicleVelocity(GetPlayerVehicleID(playerid), T[0], T[1], T[2]);
			SetVehicleVelocity(GetPlayerVehicleID(playerid), T[0], T[1], (T[2]+0.4));
		}
		case 3:
		{
			GetVehicleZAngle(GetPlayerVehicleID(playerid), T[3]);
			SetVehicleAngularVelocity(GetPlayerVehicleID(playerid), ((floatadd(0,floatmul(1.01,floatcos(T[3],degrees))))*2)/5, ((floatadd(0,floatmul(1.01,floatsin(T[3],degrees))))*2)/5, 0.0);
		}
		case 4:
		{
			GetVehicleZAngle(GetPlayerVehicleID(playerid), T[3]);
			SetVehicleAngularVelocity(GetPlayerVehicleID(playerid), ((floatadd(0,floatmul(1.01,floatsin(-T[3],degrees))))*2)/5, ((floatadd(0,floatmul(1.01,floatcos(-T[3],degrees))))*2)/5, 0.0);
		}
		case 5: SetVehicleAngularVelocity(GetPlayerVehicleID(playerid), 0.0, 0.0, 0.3);
		case 6:
		{
			GetVehicleZAngle(GetPlayerVehicleID(playerid),T[3]);
			SetVehicleZAngle(GetPlayerVehicleID(playerid),T[3]);
		}
		case 7: ChangeVehicleColor(GetPlayerVehicleID(playerid),random(256),random(256));
		case 8: SetVehicleVelocity(GetPlayerVehicleID(playerid), 0, 0, 0);
		case 9:
		{
			GetVehicleParamsEx(GetPlayerVehicleID(playerid),motor,isiklar,alarm,kapilar,kaput,bagaj,objective);
			SetVehicleParamsEx(GetPlayerVehicleID(playerid),motor,isiklar,alarm,kapilar,kaput,(PVG->Int->bagaj[playerid] == 0) ? (VEHICLE_PARAMS_ON) : (VEHICLE_PARAMS_OFF),objective);
			PVS->Int->bagaj[playerid]->!PVG->Int->bagaj[playerid];
		}
		case 10:
		{
			GetVehicleParamsEx(GetPlayerVehicleID(playerid),motor,isiklar,alarm,kapilar,kaput,bagaj,objective);
			SetVehicleParamsEx(GetPlayerVehicleID(playerid),motor,isiklar,alarm,kapilar,(PVG->Int->kaput[playerid] == 0) ? (VEHICLE_PARAMS_ON) : (VEHICLE_PARAMS_OFF),bagaj,objective);
			PVS->Int->kaput[playerid]->!PVG->Int->kaput[playerid];
		}
		case 11:
		{
			GetVehicleParamsEx(GetPlayerVehicleID(playerid),motor,isiklar,alarm,kapilar,kaput,bagaj,objective);
			SetVehicleParamsEx(GetPlayerVehicleID(playerid),motor,isiklar,(PVG->Int->alarm[playerid] == 0) ? (VEHICLE_PARAMS_ON) : (VEHICLE_PARAMS_OFF),kapilar,kaput,bagaj,objective);
			PVS->Int->alarm[playerid]->!PVG->Int->alarm[playerid];
		}
		case 12:
		{
			GetVehicleParamsEx(GetPlayerVehicleID(playerid),motor,isiklar,alarm,kapilar,kaput,bagaj,objective);
			SetVehicleParamsEx(GetPlayerVehicleID(playerid),motor,(PVG->Int->isiklar[playerid] == 0) ? (VEHICLE_PARAMS_ON) : (VEHICLE_PARAMS_OFF),alarm,kapilar,kaput,bagaj,objective);
			PVS->Int->isiklar[playerid]->!PVG->Int->isiklar[playerid];
		}
		case 13:
		{
			GetVehicleParamsEx(GetPlayerVehicleID(playerid),motor,isiklar,alarm,kapilar,kaput,bagaj,objective);
			SetVehicleParamsEx(GetPlayerVehicleID(playerid),(PVG->Int->motor[playerid] == 0) ? (VEHICLE_PARAMS_ON) : (VEHICLE_PARAMS_OFF),isiklar,alarm,kapilar,kaput,bagaj,objective);
			PVS->Int->motor[playerid]->!PVG->Int->motor[playerid];
		}
		case 14:
		{
			GetVehicleParamsEx(GetPlayerVehicleID(playerid),motor,isiklar,alarm,kapilar,kaput,bagaj,objective);
			SetVehicleParamsEx(GetPlayerVehicleID(playerid),motor,isiklar,alarm,(PVG->Int->kapilar[playerid] == 0) ? (VEHICLE_PARAMS_ON) : (VEHICLE_PARAMS_OFF),kaput,bagaj,objective);
			PVS->Int->kapilar[playerid]->!PVG->Int->kapilar[playerid];
		}
	}
	return 1;
}
function RandomMessage()
{
	switch(random(8))
	{
		case 0:	SendClientMessageToAll(0xFF6600FF, "Server »{FFFFFF} Araç spawn etmek istersen {FF0000}/veh (arac id) {FFFFFF}yazmalýsýn.");
		case 1: SendClientMessageToAll(0xFF6600FF, "Server »{FFFFFF} Sunucuyu favorilere eklemeyi unutmayýn!");
		case 2: SendClientMessageToAll(0xFF6600FF, "Server »{FFFFFF} LYNX DRIFT Ýyi Oyunlar Diler!");
		case 3: SendClientMessageToAll(0xFF6600FF, "Server »{FFFFFF} Yapýmcýlar'a bakmak için {FF0000}/credits {FFFFFF}yazmalýsýn.");
		case 4: SendClientMessageToAll(0xFF6600FF, "Server »{FFFFFF} Aracýn rengini deðiþtirmek istersen {FF0000}/vc (renk1) (renk2) {FFFFFF}komutunu kulanmalýsýn.");
        case 5: SendClientMessageToAll(0xFF6600FF, "Server »{FFFFFF} Bize katilmak istersen siteye bakmalýsýn. {FF0000}www.LynxSlidaz.tk");
        case 6: SendClientMessageToAll(0xFF6600FF, "Server »{FFFFFF} Yarýþ baþlatmak istersen {FF0000}/Yarislar {FFFFFF}komutu ile istediðin yarýþý baþlatabilirsin!");
        case 7: SendClientMessageToAll(0xFF6600FF, "Server »{FFFFFF} TDM baþlatmak istersen {FF0000}/Tdmler {FFFFFF}komutu ile istediðin tdmi baþlatabilirsin!");
	}
	return 1;
}
stock SpawnDondur(playerid, sure)
{
    SetPVarInt(playerid, "KomutEngelEx", 1);
	TogglePlayerControllable(playerid, false);
    GameTextForPlayer(playerid, "~g~~h~~h~Objeler Yukleniyor", sure*1000, 3);
	KillTimer(Oyuncu[playerid][TeleTimer]);
	Oyuncu[playerid][TeleTimer] = SetTimerEx("SpawnDondur_Ex", sure*1000, false, "i", playerid);
	return 1;
}
function SpawnDondur_Ex(playerid)
{
	SetPVarInt(playerid, "KomutEngelEx", 0);
    TogglePlayerControllable(playerid, true);
	GameTextForPlayer(playerid, "~r~~h~~h~Objeler Yuklendi", 2000, 3);
	return 1;
}
stock KickPlayer(playerid)
{
    PlayerPlaySound(playerid, 1190, 0.0, 0.0, 0.0);
	SetTimerEx("IslemUygula", (GetPlayerPing(playerid) + 70), false, "ii", playerid, 1);
    return 1;
}
stock BanPlayer(playerid)
{
    PlayerPlaySound(playerid, 1190, 0.0, 0.0, 0.0);
	SetTimerEx("IslemUygula", (GetPlayerPing(playerid) + 70), false, "ii", playerid, 2);
    return 1;
}
function IslemUygula(playerid, islem)
{
	switch(islem)
	{
 		case 1: Kick(playerid);
     	case 2: Ban(playerid);
	}
    return 1;
}
stock SendPMToBox(msg[])
{
    for(new j = 1; j < 7; j++)
    {
        format(LinesText[j - 1], 128, "%s", LinesText[j]);
        TextDrawSetString(PmText[j - 1], LinesText[j - 1]);
    }
    format(LinesText[6], 128, "%s", msg);
    TextDrawSetString(PmText[6], LinesText[6]);
}
stock TurkceKarakter(txt[])
{
    new converted[256];
    strcat(converted, txt);

    for (new i = 0; i < 256; i++)
    {
        switch (converted[i])
        {
            case 'ð': converted[i] = 'g';
            case 'Ð': converted[i] = 'G';
            case 'þ': converted[i] = 's';
            case 'Þ': converted[i] = 'S';
            case 'ý': converted[i] = 'i';
            case 'ö': converted[i] = 'o';
            case 'Ö': converted[i] = 'O';
            case 'ç': converted[i] = 'c';
            case 'Ç': converted[i] = 'C';
            case 'ü': converted[i] = 'u';
            case 'Ü': converted[i] = 'U';
            case 'Ý': converted[i] = 'I';
        }
    }
    return converted;
}
stock ExpGuncelle(id)
{
	if(Oyuncu[id][ExpLevel] >= 1 && Oyuncu[id][ExpLevel] <= 35)
	{
    	new str[256];
	    if(Oyuncu[id][Exp] >= 0 && Oyuncu[id][Exp] <= LevelLimit(id))
	    {
            SetPlayerProgressBarMaxValue(id, ExpBar[id], LevelLimit(id));
            format(str, sizeof(str),"~b~~h~~h~Exp: ~w~~h~~h~%i/%i ~b~~h~~h~Level: ~w~~h~~h~%i/35",Oyuncu[id][Exp], LevelLimit(id), Oyuncu[id][ExpLevel]);
			PlayerTextDrawSetString(id, ExpText[id], str);
            SetPlayerProgressBarValue(id, ExpBar[id], Oyuncu[id][Exp]);
	    }else
		{
		    Oyuncu[id][ExpLevel] ++;
		    Oyuncu[id][Exp] = 0;
	        ExpGuncelle(id);
	        format(str, sizeof(str), "~g~~h~~h~Level ~b~~h~~h~Up!~n~~w~~h~~h~%i~n~~y~~h~Hedef Exp~n~~w~~h~~h~%i",Oyuncu[id][ExpLevel], LevelLimit(id));
	        PlayerTextDrawSetString(id, ExpOdul[id], str);
		    TextDrawShowForPlayer(id, ExpOdulBox);
		    TextDrawShowForPlayer(id, ExpOdulBox2);
		    PlayerTextDrawShow(id, ExpOdul[id]);
		    SetTimerEx("LevelGizleAmk", 4000, false, "i", id);
		}
	}
	return 1;
}
function LevelGizleAmk(id)
{
	TextDrawHideForPlayer(id, ExpOdulBox);
	TextDrawHideForPlayer(id, ExpOdulBox2);
	PlayerTextDrawHide(id, ExpOdul[id]);
	return 1;
}
stock LevelLimit(id)
{
	new lim;
	switch(Oyuncu[id][ExpLevel])
	{
	    case 1: lim = 75;
	    case 2: lim = 150;
	    case 3: lim = 200;
	    case 4: lim = 300;
	    case 5: lim = 400;
	    case 6: lim = 500;
	    case 7: lim = 600;
	    case 8: lim = 700;
	    case 9: lim = 800;
	    case 10: lim = 900;
	    case 11: lim = 1000;
	    case 12: lim = 1100;
	    case 13: lim = 1200;
	    case 14: lim = 1300;
	    case 15: lim = 1400;
	    case 16: lim = 1500;
	    case 17: lim = 1600;
	    case 18: lim = 1700;
	    case 19: lim = 1800;
	    case 20: lim = 1900;
	    case 21: lim = 2000;
	    case 22: lim = 2100;
	    case 23: lim = 2200;
	    case 24: lim = 2300;
	    case 25: lim = 2400;
	    case 26: lim = 2500;
	    case 27: lim = 2600;
	    case 28: lim = 2700;
	    case 29: lim = 2800;
	    case 30: lim = 2900;
	    case 31: lim = 3000;
	    case 32: lim = 3100;
	    case 33: lim = 3200;
	    case 34: lim = 3300;
	    case 35: lim = 3400;
	}
	return lim;
}
UpdatePlayerSprintMacroData(playerid, speed, tickcount, bool:forget)
{
	Oyuncu[playerid][LastTimeSprinted] = tickcount;
	Oyuncu[playerid][LastMonitoredSpeed] = speed;
	if(forget && Oyuncu[playerid][TimesWarned] > 0)
	{
		if((tickcount - Oyuncu[playerid][LastTimeWarned]) >= (900 - GetPlayerPing(playerid)))
			Oyuncu[playerid][TimesWarned] = 0;
	}
	return 1;
}
stock GetPlayerSpeed(playerid)
{
    new Float:velocity[4];
    GetPlayerVelocity(playerid,velocity[0],velocity[1],velocity[2]);
    velocity[3] = floatsqroot(floatpower(floatabs(velocity[0]), 2.0) + floatpower(floatabs(velocity[1]), 2.0) + floatpower(floatabs(velocity[2]), 2.0)) * 179.28625;
    return floatround(velocity[3]);
}
function ReactionTest()
{
	new str[256];
	new RandomLetter[][] =
	{
		"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
		"N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
		"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
		"n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"
	};
	switch(random(17))
    {
        case 0..4:
        {
	        format(rTestStr, 10, "%d%d%s%s%s%d%s%d%s%d",
			random(5), random(9), RandomLetter[random(sizeof(RandomLetter))], RandomLetter[random(sizeof(RandomLetter))], RandomLetter[random(sizeof(RandomLetter))], random(9) , RandomLetter[random(sizeof(RandomLetter))], random(9) , RandomLetter[random(sizeof(RandomLetter))], random(9));
	        rMoney = 7000, rScore = 30, rExp = 20;
        }
        case 5..8:
        {
	        format(rTestStr, 10, "%d%d%d%d%s%d%s%d%d%d",
			random(5), random(9), random(9), random(9), RandomLetter[random(sizeof(RandomLetter))], random(9) , RandomLetter[random(sizeof(RandomLetter))], random(9) , random(9), random(9));
	        rMoney = 7000, rScore = 30, rExp = 20;
        }
		case 9..12:
		{
			format(rTestStr, 10, "%s%s%s%s%s%s%s%d%s%d",
			RandomLetter[random(sizeof(RandomLetter))], RandomLetter[random(sizeof(RandomLetter))], RandomLetter[random(sizeof(RandomLetter))], RandomLetter[random(sizeof(RandomLetter))], RandomLetter[random(sizeof(RandomLetter))], RandomLetter[random(sizeof(RandomLetter))] , RandomLetter[random(sizeof(RandomLetter))], random(9) , RandomLetter[random(sizeof(RandomLetter))], random(9));
        	rMoney = 7000, rScore = 30, rExp = 20;
	 	}
	 	case 13: format(rTestStr, 10, "<(-__-)>"), rMoney = 5000, rScore = 20, rExp = 10;
	 	case 14: format(rTestStr, 45, "I <3 EXCISION"), rMoney = 7000, rScore = 50, rExp = 30;
	 	case 15: format(rTestStr, 45, "I <3 LYNX"), rMoney = 4000, rScore = 40, rExp = 30;
	 	case 16: format(rTestStr, 45, "I FUCK LEVI"), rMoney = 7000, rScore = 50, rExp = 40;
    }
    rTest = true;
	format(str, sizeof(str), "Reaction » {FFFFFF}Ýlk önce kim {00D799}%s {FFFFFF}yazarsa reaction testi kazanýr!", rTestStr);
	SendClientMessageToAll(0x10869EFF, str);
	rTestcount = GetTickCount();
	return 1;
}
stock ConvertTime(time)
{
	new
		str[16],
		minutes=time/60000,
		ms=time-((minutes)*60000),
		seconds=(ms)/1000;
    ms-=seconds*1000;
	format(str, sizeof(str), "%02d:%02d.%03d", minutes, seconds, ms);
	return str;
}
function GivePlayerGunLevel(playerid)
{
	ResetPlayerWeapons(playerid);
 	switch(Oyuncu[playerid][GunGameLevel])
  	{
  		case 0: SilahVer(playerid, 23, 5000);
		case 1: SilahVer(playerid, 33, 5000);
		case 2: SilahVer(playerid, 34, 5000);
 		case 3: SilahVer(playerid, 24, 5000);
 		case 4: SilahVer(playerid, 29, 5000);
 		case 5: SilahVer(playerid, 30, 5000);
 		case 6: SilahVer(playerid, 31, 5000);
 		case 7: SilahVer(playerid, 25, 5000);
 		case 8: SilahVer(playerid, 28, 5000);
 		case 9: SilahVer(playerid, 32, 5000);
 		case 10: SilahVer(playerid, 25, 5000);
 		case 11: SilahVer(playerid, 26, 5000);
 		case 12: SilahVer(playerid, 35, 5000);
 		case 13: SilahVer(playerid, 38, 5000);
		case 14: SilahVer(playerid, 35, 5000);
 		case 15: SilahVer(playerid, 9, 1);
  		case 16:
	 	{
			new string[128];
			GivePlayerCash(playerid, GunGamePlayer()*1000);
			GivePlayerScore(playerid, GunGamePlayer()*10);
			GivePlayerExp(playerid, GunGamePlayer()*20);
			format(string, sizeof(string), "Bilgi » {FFFFFF}%s(%i) gungame yi kazandý! Ödül: $%d, %d skor, %d exp", PlayerName(playerid), playerid, GunGamePlayer()*1000, GunGamePlayer()*10, GunGamePlayer()*20);
			foreach(new i: Player)
 	    	{
				if(Oyuncu[i][GunGamede] == true) SendClientMessage(i, 0x66FFFFFF, string);
	 	    	Oyuncu[i][GunGameLevel] = 0;
	 	    	GivePlayerGunLevel(i);
			}
		}
	}
	return 1;
}
stock GunGamePlayer()
{
	new o_P = 0;
    foreach(new i: Player) if(Oyuncu[i][GunGamede] == true) o_P++;
	return o_P;
}
function LoadRaceNames()
{
	new string[64];
	YarislarEx[0]=EOS;
	TotalRaces = dini_Int("LYNX/Yaris/YarisIsimleri/RaceNames.txt", "TotalRaces");
	Loop(x, TotalRaces)
	{
	    format(string, sizeof(string), "Race_%d", x), strmid(RaceNames[x], dini_Get("LYNX/Yaris/YarisIsimleri/RaceNames.txt", string), 0, 20, sizeof(RaceNames));
	    format(YarislarEx, sizeof(YarislarEx), "%s{FF0000}» {FFFFFF}%s\n", YarislarEx, RaceNames[x]);
	}
	return 1;
}
function LoadRace(playerid, rName[])
{
	new	rFile[256],	string[256];
	format(rFile, sizeof(rFile), "LYNX/Yaris/%s.RRACE", rName);
	if(!dini_Exists(rFile)) return printf("Race %s doesn't exist!", rName);
	strmid(RaceName, rName, 0, strlen(rName), sizeof(RaceName));
	RaceVehicle = dini_Int(rFile, "vModel");
	RaceType = dini_Int(rFile, "rType");
	TotalCP = dini_Int(rFile, "TotalCP");
	Loop(x, 2)
	{
		format(string, sizeof(string), "vPosX_%d", x), RaceVehCoords[x][0] = dini_Float(rFile, string);
		format(string, sizeof(string), "vPosY_%d", x), RaceVehCoords[x][1] = dini_Float(rFile, string);
		format(string, sizeof(string), "vPosZ_%d", x), RaceVehCoords[x][2] = dini_Float(rFile, string);
		format(string, sizeof(string), "vAngle_%d", x), RaceVehCoords[x][3] = dini_Float(rFile, string);
	}
	Loop(x, TotalCP)
	{
 		format(string, sizeof(string), "CP_%d_PosX", x), CPCoords[x][0] = dini_Float(rFile, string);
 		format(string, sizeof(string), "CP_%d_PosY", x), CPCoords[x][1] = dini_Float(rFile, string);
 		format(string, sizeof(string), "CP_%d_PosZ", x), CPCoords[x][2] = dini_Float(rFile, string);
	}
	Position = 0;
	FinishCount = 0;
	JoinCount = 0;
	Loop(x, 2) PlayersCount[x] = 0;
	Oyuncu[playerid][Yarista] = true;
	CountAmount = 30;
	RaceStarter = playerid;
	RaceTime = 300;
	RaceBusy = 0x01;
	TimeProgress = 0;
	CountTimer = SetTimer("CountTillRace", 1000, 1);
	if(IsPlayerInAnyVehicle(playerid))
	{
        SetTimerEx("SetupRaceForPlayer", 1000, 0, "e", playerid);
	 	RemovePlayerFromVehicle(playerid);
	 	Oyuncu[playerid][Yarista] = true;
	 	return 1;
	}
	SetupRaceForPlayer(playerid);
	Oyuncu[playerid][Yarista] = true;
	return 1;
}
function SetCP(playerid, PrevCP, NextCP, MaxCP, Type)
{
	if(Type == 0)
	{
		if(NextCP == MaxCP)
		{
			SetPlayerRaceCheckpoint(playerid, 1, CPCoords[PrevCP][0], CPCoords[PrevCP][1], CPCoords[PrevCP][2], CPCoords[NextCP][0], CPCoords[NextCP][1], CPCoords[NextCP][2], 10);
			RemovePlayerMapIcon(playerid, RaceIcon);
		}else
		{
			SetPlayerRaceCheckpoint(playerid, 0, CPCoords[PrevCP][0], CPCoords[PrevCP][1], CPCoords[PrevCP][2], CPCoords[NextCP][0], CPCoords[NextCP][1], CPCoords[NextCP][2], 10);
			SetPlayerMapIcon(playerid, RaceIcon, CPCoords[NextCP][0], CPCoords[NextCP][1], CPCoords[NextCP][2], 0, 0xFF0000FF, MAPICON_LOCAL);
		}
	}else
	if(Type == 3)
	{
		if(NextCP == MaxCP)
		{
			SetPlayerRaceCheckpoint(playerid, 4, CPCoords[PrevCP][0], CPCoords[PrevCP][1], CPCoords[PrevCP][2], CPCoords[NextCP][0], CPCoords[NextCP][1], CPCoords[NextCP][2], 10);
		}else
		{
			SetPlayerRaceCheckpoint(playerid, 3, CPCoords[PrevCP][0], CPCoords[PrevCP][1], CPCoords[PrevCP][2], CPCoords[NextCP][0], CPCoords[NextCP][1], CPCoords[NextCP][2], 10);
		}
	}
	return 1;
}
function SetupRaceForPlayer(playerid)
{
    DisableRemoteVehicleCollisions(playerid, 1);
	ResetPlayerWeapons(playerid);
    SetPlayerVirtualWorld(playerid, 10);
	CPProgess[playerid] = 0;
	TogglePlayerControllable(playerid, false);
	CPCoords[playerid][3] = 0;
	SetCP(playerid, CPProgess[playerid], CPProgess[playerid]+1, TotalCP, RaceType);
	#define IsOdd(%1) ((%1) & 1)
	if(IsOdd(playerid)) Index = 1;
	    else Index = 0;

	switch(Index)
	{
		case 0:
		{
		    if(PlayersCount[0] == 1)
		    {
				RaceVehCoords[0][0] -= (6 * floatsin(-RaceVehCoords[0][3], degrees));
		 		RaceVehCoords[0][1] -= (6 * floatcos(-RaceVehCoords[0][3], degrees));
		   		CreatedRaceVeh[playerid] = CreateVehicle(RaceVehicle, RaceVehCoords[0][0], RaceVehCoords[0][1], RaceVehCoords[0][2]+2, RaceVehCoords[0][3], -1, -1, (60 * 60));
                SetVehicleVirtualWorld(CreatedRaceVeh[playerid], 10);
				SetPlayerPos(playerid, RaceVehCoords[0][0], RaceVehCoords[0][1], RaceVehCoords[0][2]+2);
				SetPlayerFacingAngle(playerid, RaceVehCoords[0][3]);
				PutPlayerInVehicle(playerid, CreatedRaceVeh[playerid], 0);
				Camera(playerid, RaceVehCoords[0][0], RaceVehCoords[0][1], RaceVehCoords[0][2], RaceVehCoords[0][3], 20);
				SosPos[playerid][0] = RaceVehCoords[0][0];
				SosPos[playerid][1] = RaceVehCoords[0][1];
				SosPos[playerid][2] = RaceVehCoords[0][2];
				SosPos[playerid][3] = RaceVehCoords[0][3];
			}
		}
		case 1:
 		{
 		    if(PlayersCount[1] == 1)
 		    {
				RaceVehCoords[1][0] -= (6 * floatsin(-RaceVehCoords[1][3], degrees));
		 		RaceVehCoords[1][1] -= (6 * floatcos(-RaceVehCoords[1][3], degrees));
		   		CreatedRaceVeh[playerid] = CreateVehicle(RaceVehicle, RaceVehCoords[1][0], RaceVehCoords[1][1], RaceVehCoords[1][2]+2, RaceVehCoords[1][3], -1, -1, (60 * 60));
                SetVehicleVirtualWorld(CreatedRaceVeh[playerid], 10);
				SetPlayerPos(playerid, RaceVehCoords[1][0], RaceVehCoords[1][1], RaceVehCoords[1][2]+2);
				SetPlayerFacingAngle(playerid, RaceVehCoords[1][3]);
				PutPlayerInVehicle(playerid, CreatedRaceVeh[playerid], 0);
				Camera(playerid, RaceVehCoords[1][0], RaceVehCoords[1][1], RaceVehCoords[1][2], RaceVehCoords[1][3], 20);
				SosPos[playerid][0] = RaceVehCoords[1][0];
				SosPos[playerid][1] = RaceVehCoords[1][1];
				SosPos[playerid][2] = RaceVehCoords[1][2];
				SosPos[playerid][3] = RaceVehCoords[1][3];
    		}
 		}
	}
	switch(Index)
	{
	    case 0:
		{
			if(PlayersCount[0] != 1)
			{
		   		CreatedRaceVeh[playerid] = CreateVehicle(RaceVehicle, RaceVehCoords[0][0], RaceVehCoords[0][1], RaceVehCoords[0][2]+2, RaceVehCoords[0][3], -1, -1, (60 * 60));
                SetVehicleVirtualWorld(CreatedRaceVeh[playerid], 10);
				SetPlayerPos(playerid, RaceVehCoords[0][0], RaceVehCoords[0][1], RaceVehCoords[0][2]+2);
				SetPlayerFacingAngle(playerid, RaceVehCoords[0][3]);
				PutPlayerInVehicle(playerid, CreatedRaceVeh[playerid], 0);
				Camera(playerid, RaceVehCoords[0][0], RaceVehCoords[0][1], RaceVehCoords[0][2], RaceVehCoords[0][3], 20);
			    PlayersCount[0] = 1;
				SosPos[playerid][0] = RaceVehCoords[0][0];
				SosPos[playerid][1] = RaceVehCoords[0][1];
				SosPos[playerid][2] = RaceVehCoords[0][2];
				SosPos[playerid][3] = RaceVehCoords[0][3];
		    }
	    }
	    case 1:
	    {
			if(PlayersCount[1] != 1)
			{
		   		CreatedRaceVeh[playerid] = CreateVehicle(RaceVehicle, RaceVehCoords[1][0], RaceVehCoords[1][1], RaceVehCoords[1][2]+2, RaceVehCoords[1][3], -1, -1, (60 * 60));
                SetVehicleVirtualWorld(CreatedRaceVeh[playerid], 10);
				SetPlayerPos(playerid, RaceVehCoords[1][0], RaceVehCoords[1][1], RaceVehCoords[1][2]+2);
				SetPlayerFacingAngle(playerid, RaceVehCoords[1][3]);
				PutPlayerInVehicle(playerid, CreatedRaceVeh[playerid], 0);
				Camera(playerid, RaceVehCoords[1][0], RaceVehCoords[1][1], RaceVehCoords[1][2], RaceVehCoords[1][3], 20);
				PlayersCount[1] = 1;
				SosPos[playerid][0] = RaceVehCoords[1][0];
				SosPos[playerid][1] = RaceVehCoords[1][1];
				SosPos[playerid][2] = RaceVehCoords[1][2];
				SosPos[playerid][3] = RaceVehCoords[1][3];
		    }
   		}
	}
	PlayerTextDrawShow(playerid, RaceInfo[playerid]);
	InfoTimer[playerid] = SetTimerEx("TextInfo", 200, 1, "e", playerid);
	JoinCount++;
	return 1;
}
function CountTillRace()
{
	switch(CountAmount)
	{
 		case 0:
	    {
			foreach(new i: Player)
			{
			    switch(Oyuncu[i][Yarista])
			    {
					case false:	SendClientMessage(i, 0x999900FF, "Race » {FFFFFF}Katýlýmlar sona erdi. Yarýþ baþladý!");
					case true:	SendClientMessage(i, 0x999900FF, "Race » {FFFFFF}Yarýþ baþladý. Her hangi bir sorun ile karþýlarþýrsanýz /sos yazabilirsiniz.");
				}
			}
			StartRace();
	    }
	    case 1..5:
	    {
	        new string[10];
			format(string, sizeof(string), "~g~~h~%d", CountAmount);
			foreach(new i: Player)
			{
			    if(Oyuncu[i][Yarista] == true)
			    {
			    	GameTextForPlayer(i, string, 1000, 5);
			    	PlayerPlaySound(i, 1056, 0.0, 0.0, 0.0);
			    }
			}
	    }
	    case 30:
	    {
	        new string[128];
			format(string, sizeof(string), "Race » {FFFFFF}%s isimli oyuncu yarýþ baþlattý. (%s) Katýlmak için /Yariskatil komutunu kullanýn!", PlayerName(RaceStarter), RaceName);
			SendClientMessageToAll(0x999900FF, string);
	    }
	}
	return CountAmount--;
}
function StartRace()
{
	foreach(new i: Player)
	{
	    if(Oyuncu[i][Yarista] == true)
	    {
	        TogglePlayerControllable(i, true);
	        PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
  			GameTextForPlayer(i, "~r~~h~Basla!", 2000, 5);
			SetCameraBehindPlayer(i);
	    }
	}
	rCounter = SetTimer("RaceCounter", 1000, 1);
	RaceTick = GetTickCount();
	RaceStarted = true;
	KillTimer(CountTimer);
	return 1;
}
function StopRace()
{
	KillTimer(rCounter);
	RaceStarted = false;
	RaceTick = 0;
	RaceBusy = 0x00;
	JoinCount = 0;
	FinishCount = 0;
    TimeProgress = 0;
	foreach(new i: Player)
	{
	    if(Oyuncu[i][Yarista] == true)
	    {
	    	DisablePlayerRaceCheckpoint(i);
	    	DisableRemoteVehicleCollisions(i, 0);
	    	DestroyVehicle(CreatedRaceVeh[i]);
	    	Oyuncu[i][Yarista] = false;
	    	RemovePlayerMapIcon(i, RaceIcon);
			PlayerTextDrawHide(i, RaceInfo[i]);
			CPProgess[i] = 0;
			KillTimer(InfoTimer[i]);
		}
	}
	return 1;
}
function RaceCounter()
{
	if(RaceStarted == true)
	{
		RaceTime--;
		if(JoinCount <= 0) StopRace();
	}
	if(RaceTime <= 0) StopRace();
	return 1;
}
function TextInfo(playerid)
{
	new string[256];
	format(string, sizeof(string), "~y~~h~Yaris Bilgileri~n~~r~~h~~h~Isim: ~w~~h~~h~%s~n~~g~~h~~h~Checkpoint: ~w~~h~~h~%d/%d~n~~b~~h~~h~Sure: ~w~~h~~h~%s", RaceName, CPProgess[playerid], TotalCP, TimeConvertEx(RaceTime));
	PlayerTextDrawSetString(playerid, RaceInfo[playerid], string);
	return 1;
}
function Camera(playerid, Float:X, Float:Y, Float:Z, Float:A, Mul)
{
	SetPlayerCameraLookAt(playerid, X, Y, Z);
	SetPlayerCameraPos(playerid, X + (Mul * floatsin(-A, degrees)), Y + (Mul * floatcos(-A, degrees)), Z+6);
}
function ShowDialog(playerid, dialogid)
{
	switch(dialogid)
	{
		case 599: ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_LIST, CreateCaption("Build New Race"), "\
		Normal Race\n\
		Air Race", "Next", "Exit");

	    case 600: ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_INPUT, CreateCaption("Build New Race (Step 1/4)"), "\
		Step 1:\n\
		********\n\
		 Welcome to wizard 'Build New Race'.\n\
		Before getting started, I need to know the name (e.g. SFRace) of the to save it under.\n\n\
		>> Give the NAME below and press 'Next' to continue.", "Next", "Back");

	    case 601: ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_INPUT, CreateCaption("Build New Race (Step 1/4)"), "\
  	  ERROR: Name too short or too long! (min. 1 - max. 20)\n\n\n\
		Step 1:\n\
		********\n\
		 Welcome to wizard 'Build New Race'.\n\
		Before getting started, I need to know the name (e.g. SFRace) of the to save it under.\n\n\
		>> Give the NAME below and press 'Next' to continue.", "Next", "Back");

		case 602: ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_INPUT, CreateCaption("Build New Race (Step 2/4)"), "\
		Step 2:\n\
		********\n\
		Please give the ID or NAME of the vehicle that's going to be used in the race you are creating now.\n\n\
		>> Give the ID or NAME of the vehicle below and press 'Next' to continue. 'Back' to change something.", "Next", "Back");

		case 603: ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_INPUT, CreateCaption("Build New Race (Step 2/4)"), "\
		ERROR: Invalid Vehilce ID/Name\n\n\n\
		Step 2:\n\
		********\n\
		Please give the ID or NAME of the vehicle that's going to be used in the race you are creating now.\n\n\
		>> Give the ID or NAME of the vehicle below and press 'Next' to continue. 'Back' to change something.", "Next", "Back");

		case 604: ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_MSGBOX, CreateCaption("Build New Race (Step 3/4)"),
		"\
		Step 3:\n\
		********\n\
		We are almost done! Now go to the start line where the first and second car should stand.\n\
		Note: When you click 'OK' you will be free. Use 'KEY_FIRE' to set the first position and second position.\n\
		Note: After you got these positions you will automaticly see a dialog to continue the wizard.\n\n\
		>> Press 'OK' to do the things above. 'Back' to change something.", "OK", "Back");

		case 605: ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_MSGBOX, CreateCaption("Build New Race (Step 4/4)"),
		"\
		Step 4:\n\
		********\n\
		Welcome to the last stap. In this stap you have to set the checkpoints; so if you click 'OK' you can set the checkpoints.\n\
		You can set the checkpoints with 'KEY_FIRE'. Each checkpoint you set will save.\n\
		You have to press 'ENTER' button when you're done with everything. You race is aviable then!\n\n\
		>> Press 'OK' to do the things above. 'Back' to change something.", "OK", "Back");

		case 606: ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_MSGBOX, CreateCaption("Build New Race (Done)"),
		"\
		You have created your race and it's ready to use now.\n\n\
		>> Press 'Finish' to finish. 'Exit' - Has no effect.", "Finish", "Exit");
	}
	return 1;
}
CreateCaption(arguments[])
{
	new string[128 char];
	format(string, sizeof(string), "RyDeR's Race System - %s", arguments);
	return string;
}
stock IsValidVehicle(vehicleid)
{
	if(vehicleid < 400 || vehicleid > 611) return false;
	    else return true;
}
ReturnVehicleID(vName[])
{
	Loop(x, 211)
	{
	    if(strfind(AracIsimler[x], vName, true) != -1)
		return x + 400;
	}
	return -1;
}
TimeConvertEx(seconds)
{
	new
		tmp[16],
		minutes = floatround(seconds/60);
  	seconds -= minutes*60;
   	format(tmp, sizeof(tmp), "%02d:%02d", minutes, seconds);
   	return tmp;
}
dcmd_tdmler(playerid, params[])
{
	#pragma unused params
    if(TDMInfo[t_Aktif] == true) return SendClientMessage(playerid, 0x990000FF,"TDM » {FFFFFF}TDM zaten aktif!");
	ShowPlayerDialog(playerid, DIALOG_TDM, DIALOG_STYLE_LIST,"{FF0000}LYNX DRIFT - {FFFFFF}TDM Listesi","{FF0000}» {FFFFFF}Ballas vs Grove\n\
																										 {FF0000}» {FFFFFF}Korsanlar vs Kaptanlar\n\
																				   						 {FF0000}» {FFFFFF}SWAT vs Uyusturucu Kacakcisi\n\
																				   						 {FF0000}» {FFFFFF}Itfaiyeciler vs Insaatcilar\n\
																				   						 {FF0000}» {FFFFFF}Askerler vs Teroristler\n\
																										 {FF0000}» {FFFFFF}Isciler vs Patronlar\n\
																										 {FF0000}» {FFFFFF}Driftciler vs Otoparkcilar\n\
																										 {FF0000}» {FFFFFF}Rastgele Baþlat","Baslat","Iptal");
	return 1;
}
function TDM_Baslat(playerid, tdmadi[])
{
	if(TDMInfo[Sure] > 0) return 1;
	new dosya[156];
	format(dosya, sizeof dosya, "LYNX/TDM/%s.txt", tdmadi);
	if(dini_Exists(dosya))
	{
	    new string[256];
	    printf("[TDM] %s yuklendi, basliyor..", dini_Get(dosya, "tdm"));
	    format(TDMInfo[TDM], 56, "%s", dini_Get(dosya, "tdm"));
	    format(TDMInfo[Team1], 56, "%s", dini_Get(dosya, "takim1"));
	    format(TDMInfo[Team2], 56, "%s", dini_Get(dosya, "takim2"));
	    TDMInfo[Team1_Skin] = strval(dini_Get(dosya, "takim1skin"));
	    TDMInfo[Team2_Skin] = strval(dini_Get(dosya, "takim2skin"));
	    TDMInfo[Team1_X] = floatstr(dini_Get(dosya, "team1_x"));
	    TDMInfo[Team1_Y] = floatstr(dini_Get(dosya, "team1_y"));
	    TDMInfo[Team1_Z] = floatstr(dini_Get(dosya, "team1_z"));
	    TDMInfo[Team2_X] = floatstr(dini_Get(dosya, "team2_x"));
	    TDMInfo[Team2_Y] = floatstr(dini_Get(dosya, "team2_y"));
	    TDMInfo[Team2_Z] = floatstr(dini_Get(dosya, "team2_z"));
	    TDMInfo[Starts] = true;
	    TDMInfo[t_Aktif] = true;
	    TDMInfo[Sure] = 300;
	    TDMInfo[Team1_Score] = 0;
	    TDMInfo[Team2_Score] = 0;
	    format(string, sizeof(string), "TDM » {FFFFFF}%s isimli oyuncu tdm baþlattý. (%s) Katilmak icin /Tdmkatil komutunu kullanýn!", PlayerName(playerid), TDMInfo[TDM]);
		SendClientMessageToAll(0x990000FF, string);
		SetTimer("TDM_Over", 30*1000, false);
		format(string, sizeof(string), "~y~~h~TDM Bilgileri~n~~r~~h~%s: ~w~~h~~h~00~n~~g~~h~~h~%s: ~w~~h~~h~~h~00~n~~b~~h~~h~~h~Sure: ~w~~h~~h~--:--", TDMInfo[Team1], TDMInfo[Team2]);
		TextDrawSetString(TDMTextdraw, string);
	}else
	{
		printf("%s bu isimde bir tdm dosyasi bulunamadi.", tdmadi);
	}
	return 1;
}
stock OnlineTDM()
{
	new o_P = 0;
	foreach(new i: Player) if(Oyuncu[i][TDM] == true) o_P++;
	return o_P;
}
function TDM_Over()
{
	TDMInfo[Starts] = false;
	TDMInfo[Sayac] = 6;
	if(OnlineTDM() >= 2)
	{
		TDMInfo[Timer] = SetTimer("TDM_Sayac", 1000, true);
		SendClientMessageToAll(0x990000FF,"TDM » {FFFFFF}Katilimlar sona erdi, tdm basliyor.");
	}else
	{
	    KillTimer(TDMInfo[Timer]);
	    TDMInfo[Sure] = 0;
	    TDMInfo[t_Aktif] = false;
	    SendClientMessageToAll(0x990000FF,"TDM » {FFFFFF}Katilimlar sona erdi, yetersiz oyuncu.");
		foreach(new i: Player) if(Oyuncu[i][TDM] == true) OnPlayerCommandText(i, "/tdmcik");
	}
	return 1;
}
function TDM_Update()
{
	if(OnlineTDM() <= 1)
	{
	    KillTimer(TDMInfo[Timer]);
	    KillTimer(TDMInfo[Timer2]);
        TDMInfo[t_Aktif] = false;
	    TDMInfo[Sure] = 0;
	   	SendClientMessageToAll(0x990000FF,"TDM » {FFFFFF}Oyun durdu. Oyuncular ayrildi.");
		foreach(new i: Player) if(Oyuncu[i][TDM] == true) OnPlayerCommandText(i, "/tdmcik");
		return 1;
	}
    TDMInfo[Sure]--;
	new string[256];
	format(string, sizeof(string), "~y~~h~TDM Bilgileri~n~~r~~h~~h~%s: ~w~~h~~h~%02d~n~~g~~h~~h~%s: ~w~~h~~h~%02d~n~~b~~h~~h~~h~Sure: ~w~~h~~h~%s", TDMInfo[Team1], TDMInfo[Team1_Score], TDMInfo[Team2], TDMInfo[Team2_Score], TimeConvertEx(TDMInfo[Sure]));
	TextDrawSetString(TDMTextdraw, string);
	if(TDMInfo[Sure] <= 0)
	{
	    TDMInfo[t_Aktif] = false;
	    KillTimer(TDMInfo[Timer2]);
     	new	s_Rand = (random(15)+5), k_Rand = (random(15)+5), p_Rand = (random(10000)+5000);
	    if(TDMInfo[Team1_Score] > TDMInfo[Team2_Score])
	    {
	        format(string, sizeof(string), "TDM » {FFFFFF}Oyunu %s takimi kazandi.", TDMInfo[Team1]);
	        SendClientMessageToAll(0x990000FF, string);
	        foreach(new i: Player)
	        {
				if(Oyuncu[i][TDM_Team] == TEAM_1)
    			{
       				GivePlayerScore(i, s_Rand);
           			GivePlayerCash(i, p_Rand);
           			GivePlayerExp(i, k_Rand);
              		TextDrawHideForPlayer(i, TDMTextdraw);
					Oyuncu[i][TDM] = false;
					SetPlayerHealth(i, 0);
					format(string, sizeof(string), "~w~~h~%i skor + %i exp + $%i",s_Rand, k_Rand, p_Rand);
					GameTextForPlayer(i, string, 1000, 0);
					Oyuncu[i][TDM_Team] = -1;
     			}else
			 	if(Oyuncu[i][TDM_Team] == TEAM_2)
     			{
        			TextDrawHideForPlayer(i, TDMTextdraw);
					Oyuncu[i][TDM] = false;
					SetPlayerHealth(i, 0);
					Oyuncu[i][TDM_Team] = -1;
     			}
	        }
	    }else
		if(TDMInfo[Team2_Score] > TDMInfo[Team1_Score])
	    {
	        format(string, sizeof(string), "TDM » {FFFFFF}Oyunu %s takimi kazandi.", TDMInfo[Team2]);
	        SendClientMessageToAll(0x990000FF,string);
	        foreach(new i: Player)
	        {
	 			if(Oyuncu[i][TDM_Team] == TEAM_2)
     			{
        			GivePlayerScore(i, s_Rand);
           			GivePlayerCash(i, p_Rand);
           			GivePlayerExp(i, k_Rand);
              		TextDrawHideForPlayer(i, TDMTextdraw);
					Oyuncu[i][TDM_Team] = -1;
					Oyuncu[i][TDM] = false;
					SetPlayerHealth(i, 0);
					format(string, sizeof(string), "~w~~h~%i skor + %i exp + $%i",s_Rand, k_Rand, p_Rand);
					GameTextForPlayer(i, string, 1000, 0);
     			}else
	 			if(Oyuncu[i][TDM_Team] == TEAM_1)
     			{
        			TextDrawHideForPlayer(i, TDMTextdraw);
					Oyuncu[i][TDM] = false;
					Oyuncu[i][TDM_Team] = -1;
					SetPlayerHealth(i, 0);
	            }
	        }
	    }else
		if(TDMInfo[Team2_Score] == TDMInfo[Team1_Score])
	    {
	        SendClientMessageToAll(0x990000FF,"TDM » {FFFFFF}Oyun berabere bitti.");
	        foreach(new i: Player)
	        {
				if(Oyuncu[i][TDM_Team] == TEAM_2 || Oyuncu[i][TDM_Team] == TEAM_1)
    			{
       				GivePlayerScore(i, s_Rand/2);
           			GivePlayerCash(i, p_Rand/2);
           			GivePlayerExp(i, k_Rand/2);
              		TextDrawHideForPlayer(i, TDMTextdraw);
					Oyuncu[i][TDM_Team] = -1;
					Oyuncu[i][TDM] = false;
					SetPlayerHealth(i, 0);
					format(string, sizeof(string), "~w~~h~%i skor + %i exp + $%i",s_Rand/2, k_Rand/2, p_Rand/2);
					GameTextForPlayer(i, string, 1000, 0);
	            }
	        }
	    }
	}
	return 1;
}
function TDM_Sayac()
{
	TDMInfo[Sayac] --;
	new str[76];
	switch(TDMInfo[Sayac])
	{
	    case 1..5: format(str, sizeof str, "~g~~h~%d", TDMInfo[Sayac]);
	    case 0:
	    {
	        KillTimer(TDMInfo[Timer]);
			TDMInfo[Timer2] = SetTimer("TDM_Update", 1000, true);
			foreach(new t: Player) if(Oyuncu[t][TDM] == true) GameTextForPlayer(t, "~r~~h~Basla!", 1000, 5), TogglePlayerControllable(t, true);
			return 1;
		}
	}
	foreach(new t: Player) if(Oyuncu[t][TDM] == true) GameTextForPlayer(t, str, 1000, 5);
	return 1;
}
dcmd_tdmkatil(playerid, params[])
{
	#pragma unused params
	if(TDMInfo[Starts] == false) return SendClientMessage(playerid, 0x990000FF,"TDM » {FFFFFF}TDM Katilimlar kapali!");
	if(Oyuncu[playerid][TDM] == true) return SendClientMessage(playerid, 0x990000FF,"TDM » {FFFFFF}Zaten TDM de bulunuyorsun!");
 	new string[156];
	switch(TDMInfo[Plus])
	{
	    case true:
	    {
	        TDMInfo[Plus] = false;
	        SetPlayerTeam(playerid, TEAM_1);
	        SetPlayerColor(playerid, 0xDF3535FF);
	        LabelAyarla(playerid);
	        SetPlayerPos(playerid, TDMInfo[Team1_X], TDMInfo[Team1_Y], TDMInfo[Team1_Z]);
	        SetPlayerSkin(playerid, TDMInfo[Team1_Skin]);
	        Oyuncu[playerid][Skin] = TDMInfo[Team1_Skin];
	        format(string, sizeof(string), "TDM » {FFFFFF}Takiminiz %s olarak belirlendi.", TDMInfo[Team1]);
	        SendClientMessage(playerid, 0x990000FF, string);
	        Oyuncu[playerid][TDM_Team] = TEAM_1;
	    }
	    case false:
	    {
	        TDMInfo[Plus] = true;
	        SetPlayerTeam(playerid, TEAM_2);
	        SetPlayerColor(playerid, 0x55DF35FF);
	        LabelAyarla(playerid);
	        SetPlayerPos(playerid, TDMInfo[Team2_X], TDMInfo[Team2_Y], TDMInfo[Team2_Z]);
	        SetPlayerSkin(playerid, TDMInfo[Team2_Skin]);
	        Oyuncu[playerid][Skin] = TDMInfo[Team2_Skin];
	        format(string, sizeof(string), "TDM » {FFFFFF}Takiminiz %s olarak belirlendi.", TDMInfo[Team2]);
	        SendClientMessage(playerid, 0x990000FF, string);
	        Oyuncu[playerid][TDM_Team] = TEAM_2;
	    }
	}
	ResetPlayerWeapons(playerid);
	Oyuncu[playerid][TDM] = true;
	switch(random(2))
	{
		case 0:
		{
			SilahVer(playerid, 24, 120);
			SilahVer(playerid, 28, 400);
			SilahVer(playerid, 30, 400);
			SilahVer(playerid, 4, 1);
		}
		case 1:
		{
			SilahVer(playerid, 25, 50);
			SilahVer(playerid, 31, 400);
			SilahVer(playerid, 22, 400);
			SilahVer(playerid, 2, 1);
		}
	}
	SetPlayerVirtualWorld(playerid, 25);
	SetPlayerInterior(playerid, 0);
 	TogglePlayerControllable(playerid, false);
 	TextDrawShowForPlayer(playerid, TDMTextdraw);
    SetPlayerHealth(playerid, 100.0);
	SetPlayerArmour(playerid, 100.0);
	return 1;
}
function TDMYolla(playerid)
{
	switch(Oyuncu[playerid][TDM_Team])
	{
	    case TEAM_1:
	    {
	        SetPlayerTeam(playerid, TEAM_1);
	        SetPlayerColor(playerid, 0xDF3535FF);
	        LabelAyarla(playerid);
	        SetPlayerPos(playerid, TDMInfo[Team1_X], TDMInfo[Team1_Y], TDMInfo[Team1_Z]);
	        SetPlayerSkin(playerid, TDMInfo[Team1_Skin]);
	        Oyuncu[playerid][Skin] = TDMInfo[Team1_Skin];
	        SetPlayerHealth(playerid, 100.0),
			SetPlayerArmour(playerid, 100.0);
	        Oyuncu[playerid][TDM_Team] = TEAM_1;
	    }
	    case TEAM_2:
	    {
	        SetPlayerTeam(playerid, TEAM_2);
	        SetPlayerColor(playerid, 0x55DF35FF);
	        LabelAyarla(playerid);
	        SetPlayerPos(playerid, TDMInfo[Team2_X], TDMInfo[Team2_Y], TDMInfo[Team2_Z]);
	        SetPlayerSkin(playerid, TDMInfo[Team2_Skin]);
	        Oyuncu[playerid][Skin] = TDMInfo[Team2_Skin];
	        SetPlayerHealth(playerid, 100.0),
			SetPlayerArmour(playerid, 100.0);
	        Oyuncu[playerid][TDM_Team] = TEAM_2;
	    }
	}
	ResetPlayerWeapons(playerid);
	switch(random(2))
	{
		case 0:
		{
			SilahVer(playerid, 24, 120);
			SilahVer(playerid, 28, 400);
			SilahVer(playerid, 30, 400);
			SilahVer(playerid, 4, 1);
		}
		case 1:
		{
			SilahVer(playerid, 25, 50);
			SilahVer(playerid, 31, 400);
			SilahVer(playerid, 22, 400);
			SilahVer(playerid, 2, 1);
		}
	}
	return 1;
}
stock ReturnWeaponNameEx(weaponid)
{
	new weaponstr[45];
	switch(weaponid)
	{
	    case 0: weaponstr = "Fist";
	    case 18: weaponstr = "Molotov Cocktail";
        case 44: weaponstr = "Night Vision Goggles";
        case 45: weaponstr = "Thermal Goggles";
        default: GetWeaponName(weaponid, weaponstr, sizeof(weaponstr));
	}
	return weaponstr;
}
stock ReturnMapName(mapid)
{
	new mapstr[56];
	switch(mapid)
	{
	    case 0: mapstr = "T 25";
	    case 1: mapstr = "Stadium";
        case 2: mapstr = "RC Battlefield";
	}
	return mapstr;
}
function Duello_Sayim(playerid)
{
	switch(Duello_Sayac[playerid])
	{
	    case 0:
		{
			GameTextForPlayer(playerid, "~r~~h~Basla!", 2000, 5), PlayerPlaySound(playerid,1057,0.0,0.0,0.0);
			KillTimer(Duello_Timer[playerid]);
			TogglePlayerControllable(playerid, true);
			Oyuncu[playerid][DuelTick] = GetTickCount();
		}
	    case 1: GameTextForPlayer(playerid, "~r~~h~~h~~h~1", 1000, 5), PlayerPlaySound(playerid,1056,0.0,0.0,0.0);
	    case 2: GameTextForPlayer(playerid, "~b~~h~~h~~h~2", 1000, 5), PlayerPlaySound(playerid,1056,0.0,0.0,0.0);
	    case 3: GameTextForPlayer(playerid, "~g~~h~~h~~h~3", 1000, 5), PlayerPlaySound(playerid,1056,0.0,0.0,0.0);
	    case 4: GameTextForPlayer(playerid, "~g~~h~~h~4", 1000, 5), PlayerPlaySound(playerid,1056,0.0,0.0,0.0);
	    case 5: GameTextForPlayer(playerid, "~g~~h~5", 1000, 5), PlayerPlaySound(playerid,1056,0.0,0.0,0.0);
		case 6: GameTextForPlayer(playerid, "~g~HAZIR", 1000, 5);
	}
	Duello_Sayac[playerid]--;
	return 1;
}
stock GivePlayerCash(playerid, mik)
{
	Oyuncu[playerid][Para] += mik;
	GivePlayerMoney(playerid, mik);
	return 1;
}
stock GivePlayerExp(playerid, mik)
{
	Oyuncu[playerid][Exp] += mik;
	ExpGuncelle(playerid);
	return 1;
}
stock GivePlayerScore(playerid, mik)
{
    SetPlayerScore(playerid, GetPlayerScore(playerid) + mik);
	return 1;
}
stock ResetPlayerCash(playerid)
{
	Oyuncu[playerid][Para] = 0;
	ResetPlayerMoney(playerid);
	return 1;
}
function ModCar(playerid)
{
	switch(GetVehicleModel(GetPlayerVehicleID(playerid)))
	{
        case 562,565,559,561,560,575,534,567,536,535,576,411,579,602,496,518,527,589,597,419,
		533,526,474,545,517,410,600,436,580,439,549,491,445,604,507,585,587,466,492,546,551,516,
		426,547,405, 409,550,566,406,540,421,529,431,438,437,420,525,552,416,433,427,490,528,
		407,544,470,598,596,599,601,428,499,609,524,578,486,573,455,588,403,514,423,
		414,443,515,456,422,482,530,418,572,413,440,543,583,478,554,402,542,603,475,568,504,457,
        483,508,429,541,415,480,434,506,451,555,477,400,404,489,479,442,458,467,558:
		{
        	ShowPlayerDialog(playerid, DIALOG_TUNE, DIALOG_STYLE_LIST, "{FF0000}LYNX DRIFT - {FFFFFF}Araç Modifiye","Paint Job\nRenkler\nEgzostlar\nÖn Tampon\nArka Tampon\nÇatý\nSpoiler\nYan Etekler\nBullbar\nTekerlerkler\nAraç Ses Sistemi\n[Diðer Sayfa]", "Seç", "Çýkýþ");
			return 1;
		}
		default: return SendClientMessage(playerid, 0xFF0000FF, "Hata » {FFFFFF}Bu aracý modifiye edemezsiniz.");
	}
	return 1;
}
function GostergeYenile(x)
{
	new	string[12];
	if(GetPlayerState(x) == PLAYER_STATE_DRIVER)
	{
		format(string, sizeof(string), "~w~~h~%02d", GetVehicleSpeed(GetPlayerVehicleID(x)));
		PlayerTextDrawSetString(x, SpeedoText[x], string);
		if(GetVehicleSpeed(GetPlayerVehicleID(x)) <= 500)
		{
			SetPlayerProgressBarValue(x, SpeedoBar[x], GetVehicleSpeed(GetPlayerVehicleID(x)));
		}else
		{
		    SetPlayerProgressBarValue(x, SpeedoBar[x], 500);
		}
	}
	return 1;
}
stock GetVehicleSpeed(vehicleid)
{
	new Float:x, Float:y, Float:z, vel;
	GetVehicleVelocity( vehicleid, x, y, z );
	vel = floatround( floatsqroot( x*x + y*y + z*z ) * 180 );
	return vel;
}
stock GetNumberOfPlayersOnThisIP(test_ip[])
{
	new count = 0;
	foreach(new x: Player)
	{
		if(!strcmp(Oyuncu[x][IP], test_ip)) count++;
	}
	return count;
}
stock RenkKontrol(text[])
{
	new tString[16],I = -1,String[256];
    strmid(String, text, 0, 128, sizeof(String));
    for(new C = 0; C != sizeof(RenkInfo); C++)
    {
        format(tString, sizeof(tString), "(%s)", RenkInfo[C][ColorName]);
        while((I = strfind(String, tString, true, (I + 1))) != -1)
        {
            new tLen = strlen(tString);
            format(tString, sizeof(tString), "{%s}", RenkInfo[C][ColorID]);
            if(tLen < 8) for(new C2 = 0; C2 != (8 - tLen); C2 ++) strins(String, " ", I);
            for(new tVar; ((String[I] != 0) && (tVar != 8)); I ++, tVar ++) String[I] = tString[tVar];
            if(tLen > 8) strdel(String, I, (I + (tLen - 8)));
        }
    }
    return String;
}
stock ConvertTimer(time)
{
	new verilenSure = time / 1000;
	return floatround(verilenSure);
}
stock HataliKomut(playerid, komut[])
{
	new a[128], str[56], countex = 0;
	for(new i = 0; i < sizeof(Komutlar); i++)
	{
  		new namelen = strlen(Komutlar[i]);
  		for(new pos = 0; pos <= namelen; pos++)
		{
			if(strfind(Komutlar[i], komut, true) == pos)
			{
			    if(countex == 3) break;
			    countex++;
				format(str,sizeof(str),"%s%s\n", str, Komutlar[i][k_Name]);
			}
		}
 	}
 	switch(countex)
 	{
		case 0: format(a, 128, "Hata » {FFFFFF}Bilinmeyen komut.");
		case 1: format(a, 128, "Hata » {FFFFFF}Bilinmeyen komut. Yakýn komut %s", str);
		case 2, 3: format(a, 128, "Hata » {FFFFFF}Bilinmeyen komut. Yakýn komutlar %s", str);
 	}
	return SendClientMessage(playerid, 0xFF0000FF, a);
}
stock PlayAudioStreamForAll(link[])
{
	format(SonMuzik, sizeof(SonMuzik), "%s",link);
    foreach(new ex: Player)
	{
		switch(Oyuncu[ex][MuzikIzin])
  		{
  		    case true:
			{
 	  			StopAudioStreamForPlayer(ex);
				PlayAudioStreamForPlayer(ex, link);
			}
			case false: SendClientMessage(ex, 0x66FFFFFF, "Bilgi » {FFFFFF}Müzik dinlemek istemediðiniz için müzik sizde çalmadý. Eðer dinlemek istiyorsanýz /yayinac yaziniz.");
		}
	}
	return 1;
}
stock IsVehicleEmpty(vehicleid)
{
	foreach(new i: Player) if(IsPlayerInVehicle(i, vehicleid)) return 0;
	return 1;
}
stock formatInt(value)
{
    new stringx[24];
    format(stringx, sizeof(stringx), "%d", value);
    for(new i = (strlen(stringx) - 3); i > (value < 0 ? 1 : 0) ; i -= 3)
    {
        strins(stringx[i], ",", 0);
	}
    return stringx;
}
SyncPlayer(playerid)
{
	if(IsPlayerInAnyVehicle(playerid)) return 1;

	new Float:Pos[4], Weapons[13][2], Float:HP[2], skin, team;
	GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
	GetPlayerFacingAngle(playerid, Pos[3]);
	GetPlayerHealth(playerid, HP[0]);
	GetPlayerArmour(playerid, HP[1]);
	skin = GetPlayerSkin(playerid);
	team = GetPlayerTeam(playerid);
	for(new i = 0; i < 13; i++)
	{
		GetPlayerWeaponData(playerid, i, Weapons[i][0], Weapons[i][1]);
	}
	IgnoreSpawn[playerid] = true;
	SpawnPlayer(playerid);

	SetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]), SetPlayerFacingAngle(playerid, Pos[3]);
	SetPlayerInterior(playerid, GetPlayerInterior(playerid)), SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(playerid));
	SetPlayerHealth(playerid, HP[0]), SetPlayerArmour(playerid, HP[1]);
	SetPlayerSkin(playerid, skin);
	SetPlayerTeam(playerid, team);
	for(new i = 0; i < 13; i ++)
	{
		SilahVer(playerid, Weapons[i][0], Weapons[i][1]);
	}
	SetPlayerArmedWeapon(playerid, 0);
	return 1;
}
