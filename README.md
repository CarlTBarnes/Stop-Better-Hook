### STOP() Happens use Stop Hook to display a better dialog

STOP() should never be in production code, but sometimes :poop: happens.
 The STOP() statement shows an ugly window that is confusing to users.
 There is no hint the ABORT button halts the program, and its the default!
 
![STOP normal](images/readme1.png) 

Using `System{PROP:StopHook}` it is easy to replace the RTL Stop Dialog with your own Procedure.
 My dialog below renames the buttons in an attempt to make their purpose obvious.
 The "Continue" button (aka IGNORE) is first, and the default, to imply to the user CLICK ME.
 The "Close Application" button's purpose is more obvious than "ABORT" and placed second.

Most STOP() left in code have terse text, e.g. `STOP('Add Log ' & ERROR())`.
 I add a footer to explain to the user this is not normal, this is an "Unexpected Condition".
 You'll want to adapt this to your software product. For custom software mine might say "Call Carl Now!".

![STOP better](images/readme2.png) 

And the BEST part .... where was this STOP() in my code?

Debug Build's add a "Stack Track" button that calls ASSERT() which shows a Stack Trace making it easy to find the code with this STOP.
 Be sure to use the Debug ClaRUN.dll to get
 [Procedure Names in the stack Trace.](https://clarionhub.com/t/how-to-improve-the-call-stack-when-your-program-gpfs-to-show-procedure-names/188?u=carlbarnes)
 I included my RED files.

![assert](images/readme3.png) 

The code to hook STOP and display a replacment uses MESSAGE() so is simple. Below are some snippets.

```Clarion
StopBetter PROCEDURE(<STRING Message>) 

  SYSTEM{PROP:StopHook} = ADDRESS(StopBetter)  !Tell RTL for STOP to call StopBetter()
  
!---------------------------------------------------------------------------
StopBetter  PROCEDURE(<STRING pMessage>)
BlankMsg    STRING('Exit Application?')  !for STOP('')
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

```

If you use CapeSoft MessageBox you will need to implement similar code in ds_Stop Procedure. More on that in the future.
