-- Project Redirection for Clarion 10.0 just to get the Clarion10\Bin\Debug DLLs

-- This RED has a [Copy] *.dll = %BIN%\debug
-- {include clarion_DebugDllCopy.red}

[DEBUG]
*.dll = %BIN%\debug

-- this is the normal RED --                                     
-- {include %REDDIR%\%REDNAME%}

-- Default Redirection for Clarion 11.0

[Copy]
-- Directories only used when copying dlls
*.dll = %BIN%;%BIN%\AddIns\BackendBindings\ClarionBinding\Common;%ROOT%\Accessory\bin

[Debug]
*.obj = obj\debug
*.res = obj\debug
*.rsc = obj\debug
*.lib = obj\debug
*.FileList.xml = obj\debug
*.map = map\debug
*.dll = %BIN%

[Release]
*.obj = obj\release
*.res = obj\release
*.rsc = obj\release
*.lib = obj\release
*.FileList.xml = obj\release
*.map = map\release

[Common]
*.chm = %BIN%;%ROOT%\Accessory\bin
*.tp? = %ROOT%\template\win
*.trf = %ROOT%\template\win
*.txs = %ROOT%\template\win
*.stt = %ROOT%\template\win
*.*   = .; %ROOT%\libsrc\win; %ROOT%\images; %ROOT%\template\win; %ROOT%\convsrc
*.lib = %ROOT%\lib
*.obj = %ROOT%\lib
*.res = %ROOT%\lib
*.dll = %BIN%
*.tp? = %ROOT%\Accessory\template\win
*.trf = %ROOT%\Accessory\template\win
*.txs = %ROOT%\Accessory\template\win
*.stt = %ROOT%\Accessory\template\win
*.*   = %ROOT%\Accessory\libsrc\win; %ROOT%\Accessory\images; %ROOT%\Accessory\resources; %ROOT%\Accessory\template\win
*.lib = %ROOT%\Accessory\lib
*.obj = %ROOT%\Accessory\lib
*.res = %ROOT%\Accessory\lib
*.dll = %ROOT%\Accessory\bin


