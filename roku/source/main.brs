sub Main()
    LightPanel(false)
end sub

sub RunScreenSaver()
    LightPanel(true)
end sub

function IsHD() as boolean
    deviceInfo = CreateObject("roDeviceInfo")
    return deviceInfo.GetDisplayMode() = "720p" and deviceInfo.GetDisplayAspectRatio() = "16x9"
end function

function LightPanel(screenSaver as boolean) as void
    ' Remove this if you want to play with SD resolution images.
    if IsHD() = false
        if screenSaver = false
            ShowHDErrorScreen()
        end if
        return
    end if

    ' Top level screen for the application.
    screen = CreateObject("roScreen", true)
    if type(screen) <> "roScreen"
        print "Unable to open screen"
        return
    end if
    screen.SetAlphaEnable(true)
    screen.Clear(0)
    screen.SwapBuffers()
    
    appContext = lpAppContext("MainAppContext")
    appContext.screenSaver = screenSaver
    
    screens = [ 
        Nova3(appContext)
        PDP1120(appContext)
        HP1000(appContext)
        CrayXMP48(appContext)
    ]
    
    duration = 30
    while true
        for each s in screens
            if s.Show(duration) = 2
                exit while
            end if
        end for
    end while
    
    screen.Finish()
end function

function ShowHDErrorScreen() as void
    port = CreateObject("roMessagePort")
    screen = CreateObject("roParagraphScreen")
    screen.SetMessagePort(port)
    screen.SetTitle("Light Panel HD")
    screen.AddHeaderText("Sorry, your television is not supported")
    screen.AddParagraph("Light Panel HD only supports high definition televisions.  Your display must be 720p or higher and configured to use the 16:9 aspect ratio.")
    screen.AddButton(1, "Close")
    screen.Show()
    while (true)
        msg = wait(0, screen.GetMessagePort())
        if (type(msg) = "roParagraphScreenEvent")
            if (msg.isScreenClosed())
                exit while
            else if (msg.isButtonPressed() and msg.GetIndex() = 1)
                exit while
            end if
        endif
    end while
end function