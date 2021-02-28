! The RTL Stop() is too simple and is confusing to users.
! It's not clear the ABORT button will shutdown the application
! This is easily improved by using SYSTEM{PROP:StopHook}
  PROGRAM

  MAP
StopHookTest  PROCEDURE(<STRING Message>)   !About the same to test StopHook
StopBetter    PROCEDURE(<STRING Message>)   !Better 

Test_Stop_Hook   PROCEDURE()  !Code test call STOP() - End of Call Stack
First_Procedure  PROCEDURE()  !Top of Call Stack
Alpha_Proc   PROCEDURE()     
Beta_Proc    PROCEDURE()    
  END

  CODE
  First_Procedure()
!----------------------------------------------------
Test_Stop_Hook PROCEDURE()     !Create call stack
TestNo BYTE
    CODE
    LOOP TestNo=1 TO 3     
        !IF TestNo <  3 THEN CYCLE. !Skip the Normal and Basic Hook?
        CASE TestNo
        OF 1 ; SYSTEM{PROP:StopHook} = 0
        OF 2 ; SYSTEM{PROP:StopHook} = ADDRESS(StopHookTest)
        OF 3 ; SYSTEM{PROP:StopHook} = ADDRESS(StopBetter)
        END
        
        STOP()  !Test Empty    
        STOP('ADD LogFile Error 37 File Not Open' & |
             CHOOSE(TestNo,'',' - [StopHookTest]',' - [StopBetter]',' - [?Test' & TestNo ) ) 
    END
    RETURN 

!===============================================================
!      !!! <summary>
!      !!! Suspends program execution and displays a message window.
!      !!! </summary>
!      !!! <param name="message">An optional string expression (up to 64K) which displays in the error window.</param>
!      STOP(<STRING message>),NAME('Cla$STOP')
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
    OF 3 ; ASSERT(0,'Stop Assert')
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