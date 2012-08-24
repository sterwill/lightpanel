' An object that holds the application's run-time context.

function lpAppContext(id as string) as object
    this = {}
    ' Constants
    this.class = "lpAppContext"
    ' Private fields
    this.id = id
    ' Public fields
    this.screenContexts = {}
    ' (transient fields)
    this.screenSaver = false
    ' (persisted fields)
    this.showInfo = false
    this.showHelp = true
    ' Public methods
    this.Save = app_context_save ' () as void
    ' Virtual methods
    ' Private methods
    
    return app_context_load(this)
end function

function app_context_load(appContext as object) as object
    print "Loading app context " ; appContext.id ; " from registry"
    sec = CreateObject("roRegistrySection", appContext.id)
    if (sec <> invalid)
        appContext.showInfo = app_context_load_boolean(sec, "showInfo")
        appContext.showHelp = app_context_load_boolean(sec, "showHelp")
    end if
    return appContext
end function

function app_context_save() as void
    print "Saving app context " ; m.id ; " to registry"
    sec = CreateObject("roRegistrySection", m.id)
    app_context_save_boolean(sec, "showInfo", m.showInfo)
    app_context_save_boolean(sec, "showHelp", m.showHelp)
    sec.Flush()
end function

function app_context_load_boolean(sec as object, key as string) as boolean
    if sec.Exists(key) and sec.Read(key) = "true"
        ret = true
    else
        ret = false
    end if
    print " " ; key ; " <- " ; ret
    return ret
end function

function app_context_save_boolean(sec as object, key as string, value as boolean) as void
    print " " ; key ; " -> " ; value
    if value
        sec.Write(key, "true")
    else
        sec.Write(key, "false")
    end if
end function
