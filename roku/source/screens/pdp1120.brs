function PDP1120(appContext as object) as object
    this = lpScreen(appContext)
    this.id = "pdp1120"
    this.title = "Digital Equipment Corporation PDP-11/20"
    this.info = [
        "Image: Rama & Musée Bolo (Wikimedia Commons)"
        "Source: http://commons.wikimedia.org/wiki/File:Digital_PDP11-IMG_1498.jpg"
        "License: CC BY-SA 2.0 France"
    ]
    this.spriteGroups = [
        [ 0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 17], [18], [19], [20, 21],
                [22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37], [38], [39], [40, 41]
    ]
    if (this.IsHD())
        this.CreateSprites = pdp1120_create_hd_sprites
    else
        this.CreateSprites = pdp1120_create_sd_sprites
    end if
    
    return this
end function

