! StopBetter by Carl Barnes released under the MIT License
!---------------------------------------------------------
! The RTL Stop() is too simple and is confusing to users.
! It's not clear the ABORT button will shutdown the application
! This is easily improved by using SYSTEM{PROP:StopHook}
! 2/28/21 added similar for HALT()
 
  PROGRAM

  MAP
StopHookTest  PROCEDURE(<STRING Message>)   !About the same to test StopHook
StopBetter    PROCEDURE(<STRING Message>)   !Better 
HaltBetter    PROCEDURE(UNSIGNED errorLevel=0, <STRING Message>)

Test_Stop_Hook  PROCEDURE()  !Code test call STOP() - End of Call Stack
First_Procedure PROCEDURE()  !Top of Call Stack
Alpha_Proc      PROCEDURE()     
Beta_Proc       PROCEDURE()    
  END

Glo:TestHalt    BOOL
  CODE
  !----- STOP Tests ----------
  IF 1 THEN                !Change to "IF 0" to skip STOP tests
     Glo:TestHalt=0        !0=STOP Test, 1+ are HALT Tests (do below)
     First_Procedure()
  END

  !----- HALT Tests ----------
  IF 1 THEN                !Change to "IF 0" to skip HALT tests
     SYSTEM{PROP:HaltHook} = ADDRESS(HaltBetter)  !Comment to see RTL HALT
     Glo:TestHalt=1        ! 1=HALT(,'text')  2=HALT(,'')  3=HALT()
     First_Procedure() 
  END
  RETURN
!----------------------------------------------------
Test_Stop_Hook PROCEDURE()     !Create call stack
TestNo BYTE
    CODE
    !--- HALT Testing -------------------------------------------------
    CASE Glo:TestHalt
    OF 1 ; HALT(0,'File Creation Error!')  !e.g. Warn:CreateError   
    OF 2 ; HALT(,'')   !Blank text does show dialog
    OF 3 ; HALT(666)
    END
    !--- STOP Testing -------------------------------------------------
    LOOP TestNo=1 TO 3   !Test what: Default RTL, Better, HookTest
        IF TestNo > 2 THEN CYCLE. !Skip the StopHookTest Basic Hook?
        CASE TestNo
        OF 1 ; SYSTEM{PROP:StopHook} = 0                      ! RTL Default STOP
        OF 2 ; SYSTEM{PROP:StopHook} = ADDRESS(StopBetter)
        OF 3 ; SYSTEM{PROP:StopHook} = ADDRESS(StopHookTest)  !Simple Hook
        END

        STOP()  !Test Empty    
        STOP('ADD LogFile Error 37 File Not Open' & |
             CHOOSE(TestNo,'  [RTL]','  [StopBetter]','  [StopHookTest]','  [?Test#' & TestNo ) ) 
    END
    RETURN 

!===========================================================================
!   STOP(<STRING message>),NAME('Cla$STOP')
!!! Suspends program execution and displays a message window.
!!! message - An optional string expression (up to 64K) which displays in the error window.</param>
!===========================================================================
! STOP with Better Buttons and Footer Text to tell user this is unexpected
!---------------------------------------------------------------------------
StopBetter  PROCEDURE(<STRING pMessage>)
BlankMsg    STRING('Exit Application?')  !for called as STOP()
StopMessage &STRING
FooterText  STRING('<13,10>_{60}' & |
            '<13,10>This message is displayed for an unexpected condition.' & |
            '<13,10>Take a screen capture and note the steps you took.' & |
            '<13,10>Please contact Technical Support for assistance.' )
AssertBtn   PSTRING(24)
    CODE
    IF ~OMITTED(pMessage) AND pMessage THEN
        StopMessage &= pMessage 
    ELSE
        StopMessage &= BlankMsg   !Called as STOP() or STOP('')
    END
    
    COMPILE('** debug **',_Debug_) !w/o Debug *No Assert() or Stack Trace
    AssertBtn='|Stack Trace'        
            !** debug **            

    CASE MESSAGE(CLIP(StopMessage) & FooterText, | ! Message Text
                 'Stop - Unexpected Condition',  | ! Caption
                 ICON:Hand,                      | ! Icon 
                 'Continue|Close Application' & AssertBtn, | 
                   1, MSGMODE:CANCOPY)
    OF 2 ; HALT()         !Close Application
    OF 3 ; ASSERT(0,'STOP() Stack Trace Assert')
    END
    RETURN
    
!*FYI  ASSERT can fire in Release with Project Define "asserts=>on" (case sensitive)
!      But the ASSERT() dialog will NOT have a Stack Trace
!      You can test with: COMPILE('** Asserts=On **',asserts)
!===========================================================================
!This STOP is almost identical to RTL but makes Ignore the Default Button  
!---------------------------------------------------------------------------
StopHookTest  PROCEDURE(<STRING pMessage>)
BlankMsg    STRING('Exit Application?')  !RTL uses 'Exit?'
StopMessage &STRING
    CODE
    IF ~OMITTED(pMessage) AND pMessage THEN
        StopMessage &= pMessage 
    ELSE
        StopMessage &= BlankMsg    !Called as STOP()
    END 
    CASE MESSAGE(StopMessage, |
                 'Stop Application ?',       | !Caption
                 ICON:Hand,                  | !Icon HAND Red X
                 BUTTON:ABORT+BUTTON:IGNORE, | !Buttons ABORT and IGNORE
                              BUTTON:IGNORE, | !<-- Default Ignore
                 MSGMODE:CANCOPY )             !ALlow Copy Text
    OF BUTTON:ABORT 
       HALT()
    END
    RETURN
!==================================================================
! Test procedures to create a Call Stack for Assert Demo
!------------------------------------------------------------------
First_Procedure  PROCEDURE() !Create call stack 
    CODE    
    Alpha_Proc()
!-----------    
Alpha_Proc   PROCEDURE()     !Create call stack 
    CODE
    DO RoutineZULU
RoutineZULU ROUTINE    
    Beta_Proc()
!-----------
Beta_Proc    PROCEDURE()     !Create call stack    
    CODE
    DO RoutineYANKEE
    RETURN
RoutineYANKEE ROUTINE    
    Test_Stop_Hook() 
    EXIT

!================================================================== 
!   HALT(UNSIGNED errorLevel=0, <STRING message>),NAME('Cla$HALT')
!!! Immediately terminates the program.
!!! errorLevel - A positive integer constant or variable which is the exit code to pass to DOS, setting the DOS ERRORLEVEL. If omitted, the default is zero.</param>
!!! message    - A string constant or variable which is typed on the screen after program termination.</param>      
!===========================================================================
! HALT with Footer Text to tell user this is unexpected, and Stack Trace
!--------------------------------------------------------------------------- 
HaltBetter    PROCEDURE(UNSIGNED pErrorLevel=0, <STRING pMessage>)
BlankMsg    STRING('HALT with Blank Reason.')  !for HALT('')
HaltMessage &STRING
FooterText  STRING('<13,10>_{60}' & |
            '<13,10>This message is displayed for an unexpected condition.' & |
            '<13,10>The Application WILL CLOSE and NOT SAVE current data.' & |
            '<13,10>Take a screen capture and note the steps you took.' & |
            '<13,10>Please contact Technical Support for assistance.' )
AssertBtn   PSTRING(24)
    CODE
    SYSTEM{PROP:HaltHook}=0     !So HALT() does RTL HALT() 
    IF OMITTED(pMessage) THEN 
       HALT(pErrorLevel)
    ELSIF pMessage THEN
        HaltMessage &= pMessage 
    ELSE
        HaltMessage &= BlankMsg   !Was HALT('') or HALT(Var) where Var=''
    END
    
    COMPILE('** debug **',_Debug_) !w/o Debug *No Assert() or Stack Trace
    AssertBtn='|Stack Trace'        
            !** debug **            

    CASE MESSAGE(CLIP(HaltMessage) & FooterText, | ! Message Text
                 'HALT - Unexpected Condition',  | ! Caption
                 ICON:Hand,                      | ! Icon 
                 'Close Application'& AssertBtn, | 
                   1, MSGMODE:CANCOPY)
    OF 2 ; ASSERT(0,'HALT() Stack Trace Assert')
    END 
    !IF ~BAND(KEYSTATE(),0300h) THEN 
    !   ... could check for Ctrl+Shift down and Continue. Will need to Restore Prop:HaltHook
    HALT(pErrorLevel)
    RETURN    