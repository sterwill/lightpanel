function HP1000(appContext as object) as object
    this = lpScreen(appContext)
    this.id = "hp1000"
    this.title = "HP 1000 E-Series Minicomputer"
    this.info = [
        "Image: Autopilot (Wikipedia)"
        "Source: http://commons.wikimedia.org/wiki/File:HP_1000_E-Series_minicomputer.jpg"
        "License: CC BY-SA 3.0"
    ]
    this.spriteGroups = [
        [0, 1], [ 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17],
        [18],   [19, 20, 21], [22, 23, 24, 25, 26, 27]
    ]
    if (this.IsHD())
        this.CreateSprites = hp1000_create_hd_sprites
    else
        this.CreateSprites = hp1000_create_sd_sprites
    end if
    
    return this
end function