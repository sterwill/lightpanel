function CrayXMP48(appContext as object) as object
    this = lpScreen(appContext)
    this.id = "crayxmp48"
    this.title = "Cray X-MP/48"
    this.info = [
        "Image: Rama (Wikimedia Commons)"
        "Source: http://commons.wikimedia.org/wiki/File:Cray-XMP48-p1010244.jpg"
        "License: CC BY-SA 2.0 France"
    ]
    this.spriteGroups = [
        [0, 1], [2, 3], 
        [4, 5], [6, 7]
    ]
    if (this.IsHD())
        this.CreateSprites = crayxmp48_create_hd_sprites
    else
        this.CreateSprites = crayxmp48_create_sd_sprites
    end if
    
    ' The Cray has just a few lights, so the more complex animations
    ' don't work very well. 
    
    ' Cycle through these animations
    this.uuads = [
        light_panel_screen_uuad_random_sprite
    ]
    
    return this
end function
