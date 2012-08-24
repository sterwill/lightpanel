' lpScreen is an abstract type meant to be extended for displaying
' individual computer picture animations using an roScreen.

function lpScreen(appContext as object) as object
    this = {}
    ' Constants
    this.class = "lpScreen"
    this.helpTitle = "Welcome to Light Panel HD"
    this.helpInfo = [
        "You can use the buttons on the remote to control the program, or just sit back and let it change"
        "automatically."
        ""
        "  [Play] shows or hides this help text"
        "  [Right] changes the light program"
        "  [Select] changes the computer"
        "  [Info] shows information about the computer"
        "  [Back] exits back to the home screen"
        ""
    ]
    this.helpFooter = "The Light Panel HD icon was adapted from the HP E-Series 1000 image by Autopilot (Wikipedia)"
    ' Private Fields
    this.appContext = appContext
    this.hd = invalid
    this.screen = invalid
    this.compositor = invalid
    this.sprites = invalid
    ' Protected Fields
    this.title = "Untitled"
    this.info = []
    this.footer = invalid
    this.background = ""
    this.overlay = ""
    this.spriteGroups = []
    this.uuads = [
        light_panel_screen_uuad_random_sprite
        light_panel_screen_uuad_random_sprites_fast
        light_panel_screen_uuad_random_sprites_slow
        light_panel_screen_uuad_sequential_sprites
        light_panel_screen_uuad_binary_count
    ]
    ' Public methods
    this.IsHD = light_panel_screen_is_hd
    this.Show = light_panel_screen_show ' (duration) as integer
    ' Protected methods
    this.GetScreenContext = light_panel_screen_get_screen_context ' (id) as object
    ' Virtual methods
    this.CreateSprites = invalid ' (overlayBitmap, compositor) as void
    this.SelectNextUpdateAndDrawImpl = light_panel_screen_select_next_update_and_draw_impl ' () as object
    ' Private methods
    this.Animate = light_panel_screen_animate ' (duration) as integer
    this.DrawInfoText = light_panel_screen_draw_info_text ' (titleFont, infoFont) as void
    this.LoadImage = light_panel_screen_load_image ' (id, layer, resolution) as object
    this.CurrentUpdateAndDrawImpl = invalid ' () as void

    return this
end function

function light_panel_screen_is_hd() as boolean
    if (m.hd = invalid)
        deviceInfo = CreateObject("roDeviceInfo")
        ' TODO Do something smarter than only testing aspect ratio?
        ar = deviceInfo.GetDisplayAspectRatio()
        if (ar = "16x9")
            m.hd = true
        else
            m.hd = false
        end if 
    end if
    return m.hd
end function

' Shows a light panel screen for the specified duration (seconds) or until 
' a button is pressed, after which the screen is hidden.
'
' Returns the following values:
' 
'  0: the full duration elapsed with no button press
'  1: the user wants to skip to the next animation
'  2: the user wants to quit the application
function light_panel_screen_show(duration as integer) as integer
    ' Always use a resolution with square pixels
    if (m.IsHD())
        width = 1280
        height = 720
        resolution = "hd" 
    else
        width = 640
        height = 480
        resolution = "sd"
    end if

    ' Double buffered screen with alpha blending for fading 
    ' and text.    
    m.screen = CreateObject("roScreen", true, width, height)
    if type(m.screen) <> "roScreen"
        print "Unable to open screen as " ; width ; "x" ; height
        stop
    endif
    m.screen.SetAlphaEnable(true)
    m.screen.Clear(0)
    m.screen.SwapBuffers()
    
    ' A message port for events.
    msgport = CreateObject("roMessagePort")
    if type(msgport) <> "roMessagePort"
        print "Unable to open message port"
        stop
    endif
    m.screen.SetPort(msgport)
    
    ' Controls sprites.
    m.compositor = CreateObject("roCompositor")
    m.compositor.SetDrawTo(m.screen, &hFF)
    
    bgBitmap = m.LoadImage(m.id, "background", resolution)
    bgRegion = CreateObject("roRegion", bgBitmap, 0, 0, bgBitmap.GetWidth(), bgBitmap.getHeight())
    bgSprite = m.compositor.NewSprite(0, 0, bgRegion, 0)
    overlayBitmap = m.LoadImage(m.id, "overlay", resolution)
    m.sprites = m.CreateSprites(overlayBitmap, compositor)
    
    ' Each light is initially not visible
    for each sprite in m.sprites
        sprite.SetDrawableFlag(false)
    end for
    
    ret = m.Animate(duration)
    m.screen.Finish()
    return ret
end function

' Calls m.UpdateAndDraw as fast as possible for the specified duration (seconds), or
' until a button is pressed.
'
' Same return codes as Show
function light_panel_screen_animate(duration as integer) as integer
    msgport = m.screen.getPort()
    width = m.screen.GetWidth()
    height = m.screen.GetHeight()

    ' Title font is 1.5 time size of info font
    fontRegistry = CreateObject("roFontRegistry")
    if (m.IsHD())
        titleFontSize = 36
        infoFontSize = 24
        footerFontSize = 22
    else
        titleFontSize = 18
        infoFontSize = 12
        footerFontSize = 10
    end if
    titleFont = fontRegistry.GetDefaultFont(titleFontSize, true, false) 
    infoFont = fontRegistry.GetDefaultFont(infoFontSize, false, false) 
    footerFont = fontRegistry.GetDefaultFont(footerFontSize, false, true) 

    ' fading in and out
    fadeColor = &h000000FF
    fadeTime = 1000
    ' Assume some constant FPS (better to guess low than high)
    fadeDelta = 256.0 * (fadeTime / 1000.0 / 30.0)
    
    showTime = duration * 1000
    showTimer = CreateObject("roTimespan")
    
    showTimer.Mark()
    
    ' Use a local for the loop
    screen = m.screen
    
    ' Store this as a private field so we can invoke it with "m" context
    m.CurrentUpdateAndDrawImpl = m.SelectNextUpdateAndDrawImpl()
    
    while (true)
        ' Check for finish
        frameTime = showTimer.TotalMilliseconds()
        if (frameTime > showTime)
            exit while
        end if
        
        msg = wait(1, msgport)
        if type(msg) = "roUniversalControlEvent" then 
            if (msg.GetInt() = 10)
                ' Info pressed (show info)
                m.appContext.showHelp = false
                m.appContext.showInfo = (m.appContext.showInfo = false)
                m.appContext.Save()
            else if (msg.GetInt() = 0)
                ' Back pressed (quit)
                return 2
            else if msg.GetInt() = 5
                ' Right pressed (next UUAD and reset timer)
                m.CurrentUpdateAndDrawImpl = m.SelectNextUpdateAndDrawImpl()
                showTimer.Mark()
            else if msg.GetInt() = 13
                ' Play/pause pressed (show help again)
                m.appContext.showHelp = (m.appContext.showHelp = false)
                m.appContext.showInfo = false
                m.appContext.Save()
            else if msg.GetInt() = 6
                ' Select pressed (next screen)
                return 1
            end if
        end if
        
        ' Update and draw the sprites
        m.CurrentUpdateAndDrawImpl()

        ' Render text if enabled (and not screensaver)
        if m.appContext.screenSaver = false
            if (m.appContext.showInfo)
                m.DrawInfoText(m.title, titleFont, m.info, infoFont, m.footer, footerFont)
            else if (m.appContext.showHelp)
                m.DrawInfoText(m.helpTitle, titleFont, m.helpInfo, infoFont, m.helpFooter, footerFont)
            end if
        end if

        ' Calculate fade color
        if (frameTime < fadeTime)
            fadeColor = fadeColor - fadeDelta
        else if (frameTime > showTime - fadeTime)
            fadeColor = fadeColor + fadeDelta
        else
            fadeColor = &h00
        end if
        
        if (fadeColor < &h00)
            fadeColor = &h00
        else if (fadeColor > &hFF)
            fadeColor = &hFF
        end if
        
        ' Blend the fade color
        screen.DrawRect(0, 0, width, height, fadeColor)
        
        screen.SwapBuffers()
    end while
    
    ' Full time elapsed
    return 0
end function

' Draws the info text on the screen.
function light_panel_screen_draw_info_text(title as string, titleFont as object, info as object, infoFont as object, footer as object, footerFont as object) as void
    white = &hFFFFFFFF
    grey = &h00000077
    
    ' Layout goes like:
    ' 
    ' [indent][top]
    '         title
    '         [large spacer]
    '         info[0]
    '         [small spacer]
    '         info[1]
    '         [small spacer]
    '         footer
    '         [bottom]
    
    if (m.IsHD())
        indent = 45
        top = 35
        largeSpacer = 22
        smallSpacer = 6
        bottom = 30
    else
        indent = 35
        top = 25
        largeSpacer = 10
        smallSpacer = 4
        bottom = 10
    end if
    
    titleLineHeight = titleFont.GetOneLineHeight()
    infoLineHeight = infoFont.GetOneLineHeight()
    footerLineHeight = footerFont.GetOneLineHeight()
    
    ' A spacer between each info line (if there are any)
    if (info.Count() > 1)
        smallSpacerCount = info.Count() - 1
    else
        smallSpacerCount = 0
    end if
    
    ' One more small spacer before the footer (if there is one)
    if (footer <> invalid)
        smallSpacerCount = smallSpacerCount + 1
    end if
    
    ' Background box (with optional footer line)
    boxHeight = top + titleLineHeight + largeSpacer + (info.Count() * infoLineHeight) + (smallSpacerCount * smallSpacer) + bottom
    if (footer <> invalid)
        boxHeight = boxHeight + largeSpacer + footerLineHeight
    end if
    m.screen.DrawRect(0, 0, m.screen.GetWidth(), boxHeight, grey)
    
    ' Title line
    m.screen.DrawText(title, indent, top, white, titleFont)
    
    ' Info lines
    if (info.Count() > 0)
        y = top + titleLineHeight + largeSpacer    
        i = 0            
        for each line in info
            ' Only space between lines
            if (i > 0)
                y = y + smallSpacer
            end if          
                  
            m.screen.DrawText(line, indent, y, white, infoFont)
            y = y + infoLineHeight

            i = i + 1
        end for
    end if
    
    ' Optional footer line
     if (footer <> invalid)
        y = y + largeSpacer
        m.screen.DrawText(footer, indent, y, white, footerFont)
    end if
end function

' Loads an image or stops the application if it can't be loaded
function light_panel_screen_load_image(id as string, layer as string, resolution as string) as object
    path = "pkg:/images/" + id + "-" + layer + "-" + resolution + ".jpg"
    bitmap = CreateObject("roBitmap", path)
    if type(bitmap) <> "roBitmap"
        print "Unable to load bitmap from path " ; path
        stop
    endif
    return bitmap
end function

' Gets the screen context (a child of the app context) for this screen (known
' by m.id).
function light_panel_screen_get_screen_context() as object
    screenContexts = m.appContext.screenContexts
    screenContext = screenContexts[m.id]
    if (screenContext = invalid)
        screenContext = {}
        screenContexts[m.id] = screenContext
        print "created screen context for " ; m.id 
    end if
    return screenContext
end function

' Default implementation.  Selects the "next" UUAD from the array, 
' consulting the screen context for the UUAD index used last time.  
' Rolls around to index 0 after hitting the max index.
'
' May be overridden by subtypes to select from m.uuads or use some
' other source.
'
' You might write a similar method to select a random UUAD.
function light_panel_screen_select_next_update_and_draw_impl() as object
    if m.uuads = invalid or m.uuads.Count() = 0
        print "UUAD list is invalid or empty"
        stop
    end if
    
    screenContext = m.GetScreenContext()
    
    ' Get the last index and increment
    i = screenContext["lastUUAD"]
    if (i = invalid)
        i = 0
    else
        i = i + 1
        if (i > m.uuads.Count() - 1)
            i = 0
        end if
    end if

    ' Save the index used this time
    screenContext["lastUUAD"] = i
    
    print "chose UUAD " ; i ; " from " ; m.uuads.Count() ; " choices for " ; m.id
    return m.uuads[i]
end function
