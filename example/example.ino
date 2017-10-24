#include <ESP8266WiFi.h>


//1>						Code_Title
/******************************************************************************
dscr: This is a description for this title.
******************************************************************************/

//1>						 Global Vars
/******************************************************************************/
/* Some vars. */
char NUM0 = 0;
char NUM1 = 9;
int  ENUM = 9;
int OTHER = 879879879;

//Code name
#define CODENAME Example_bla_bla_bla

/* --- Define IO --- */
#define SCL_RTC 5  // D1
#define SDA_RTC 4  // D2


/************************* End Visible Global Vars ****************************/

/* Hidden vars */
char *ssid = "************";
char *password = "********";

#ifdef DEBUG_CODE_VERSION
#define PrintDegug(x,y) do {if(y < DEBUG){if(Serial){Serial.print(x);}else{Serial.begin(BaudRate); Serial.print(""); Serial.print(x); Serial.end();}}} while(0)
#else
#define PrintDegug(x,y)
#endif

#define countof(a) (sizeof(a) / sizeof(a[0]))

/*************************** End Global Vars **********************************/


//1>						My Functions
/******************************************************************************/
//2>            HandleRoot
/******************************************************************************
args: ()
rtrn: void
dscr: Verifies that you are connected to the esp.
******************************************************************************/
void handleRoot()
{
  PrintDegug("<handleRoot> \n", 1);
  server.send(200, "text/html", "<center> <h1>You are connected!");
}

//1>						 Setup Functions
/******************************************************************************/

//2>						SetUpFileSystem
/******************************************************************************
args: ()
rtrn: void
dscr: Start FileSistem
******************************************************************************/
void setUpFileSystem()
{
	PrintDegug("\n>>Start SPIFFS \n \n", 1);
	SPIFFS.begin();
}


//2>						SetUpServerOn
/******************************************************************************
args: ()
rtrn: void
dscr: Setup Server interrupts
******************************************************************************/
void setUpServerOn()
{
	PrintDegug("\n>>Start server.on \n \n", 1);

	server.on("/", handleRoot);
  server.on("/other", other);

	server.onNotFound([]() {
		if (!handleFileRead(server.uri()))
			server.send(404, "text/plain", "FileNotFound");
	});
}

//1>						Arduino setup and loop
/******************************************************************************/

//2>						Setup
/******************************************************************************
Setup arduino:
dscr: Start file system.
Check if config.txt exists and is valid.
Start WiFi AP & STA. AP's ssid and pass are read from config.txt if the file is valid
    ***************************************************************************/
void setup()
{
	/*File system*/
	setUpFileSystem();

  //code on ...

	/*Setup server*/
	setUpServerOn();
}

/*****************************************************************************/

//2>						Loop
/******************************************************************************
dscr: Main loop in arduino
   ***************************************************************************/
void loop()
{
  // More code
}
/******************************************************************************/
