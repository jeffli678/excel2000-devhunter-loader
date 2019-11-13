# excel2000-devhunter-loader
A loader to run the devhunter game from Excel 2000 on Windows 10

## Getting Started

Download the [latest release](https://github.com/jeffli678/excel2000-devhunter-loader/releases/download/v1.0/devhunter-loader.zip) and run loader.exe. 

See a video at: https://youtu.be/B2jlbsmL2fQ

## How?

Devhunter is a car racing game embedded in Excel 2000. To extract it, I installed a Windows XP VM with Office 2000. Then I followed the instructions online to export a webpage that can launch the game. I inspected the webpage and found it references CLSID 0002E510-0000-0000-C000-000000000046, which turns out to be pointing to a MSOWC.DLL in the Office installation directory. 

I then loaded this dll with BinaryNinja and searched for relevant strings. Luckily, the search for "Dev Hunter" immediately sent me to the function 0x3c7dc79b, which inits the game. After analysis, I found its parent function, i.e., 0x3c7dc946, contains all the code for the game. So I simply wrote a loader to call this function. The loader also does proper preparation before handing the control to the game. 

Since the original MSOWC.DLL is meant to display an Excel table within IE, it contains lot of extra code that is irrelevant to the game, which makes it as large as ~3MB. Besides, I have to make ~10 patches to the DLL to make it run properly outside of IE. All patches are made to the function 0x3c7dc79b. Both the original and patched version of MSOWC.DLL are provided. In the future, it is possible to remove the irrelevant code and keep only those for the game. 

DDraw is broken on Windows 10. Thanks to DDrawCompat which makes the game run properly on Win10! I did not test it on Win7/8/Vista, but it probably works. 

## Loader

The function 0x3c7dc79b follows thiscall convetion. The ecx is expected to hold an opaque class. It is huge because I see reference to offset 0x9a914 of it. Luckily, the Devhunter games does not depend on any prior arrangment of it. So I simply allocate a 0x100000 size buffer, zero it and handle it over to ecx. 

There are three parameters on the stack. The first one is a handle to the MSOWC.DLL and the second must be 0. The third one controls the color of the player's car, e.g., if I change it from 0x7fa87860 to 0x7fa87820, the car becomes darker blue. It is not yet clear how does it work. 

## Credits

1. Microsoft for Excel 2000, MSOWC (MS Office Web Component), and DevHunter 
2. narzoul for DDrawCompat (https://github.com/narzoul/DDrawCompat)
3. nalsakas for pe.inc (https://github.com/nalsakas/pe)
