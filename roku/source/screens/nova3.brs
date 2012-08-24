function Nova3(appContext as object) as object
    this = lpScreen(appContext)
    this.id = "nova3"
    this.title = "Data General Nova 3"
    this.info = [
        "Image: Qu1j0t3 (Wikipedia)"
        "Source: http://commons.wikimedia.org/wiki/File:Dg-nova3.jpg"
        "License: The copyright holder of this work allows anyone to use it for"
        "  any purpose including unrestricted redistribution, commercial use," 
        "  and modification."
    ]
    this.spriteGroups = [
                                                          [16], 
        [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
    ]
    if (this.IsHD())
        this.CreateSprites = nova3_create_hd_sprites
    else
        this.CreateSprites = nova3_create_sd_sprites
    end if
    
    return this
end function
