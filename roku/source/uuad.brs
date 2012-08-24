' This file contains UpdateAndDraw implementations for use by 
' lpScreens.  A screen can use these general implementations or 
' supply their own.

' An UpdateAndDraw implementation that toggles one randomly chosen sprite's
' visibility.
function light_panel_screen_uuad_random_sprite() as void
    sprites = m.sprites
    i = rnd(sprites.Count()) - 1
    sprites[i].SetDrawableFlag(sprites[i].GetDrawableFlag() = false)
    m.compositor.DrawAll()
end function

' An UpdateAndDraw implementation that toggles a random number of sprites'
' visibility as fast as possible.
function light_panel_screen_uuad_random_sprites_fast() as void
    light_panel_screen_uuad_random_sprites(m)
end function

' An UpdateAndDraw implementation that toggles a random number of sprites'
' visibility twice per second.
function light_panel_screen_uuad_random_sprites_slow() as void
    timer = m.randomSpritesSlowTimer
    if timer = invalid
        timer = CreateObject("roTimespan")
        m.randomSpritesSlowTimer = timer
        timer.Mark()
    end if
    
    if timer.TotalMilliseconds() > 500
        light_panel_screen_uuad_random_sprites(m)
        timer.Mark()
    else
        m.compositor.DrawAll()
    end if
end function

function light_panel_screen_uuad_random_sprites(screen as object) as void
    sprites = screen.sprites
    for num = 1 to rnd(sprites.Count())
        i = rnd(sprites.Count()) - 1
        sprites[i].SetDrawableFlag(sprites[i].GetDrawableFlag() = false)
    end for
    screen.compositor.DrawAll()
end function

' An UpdateAndDraw implementation that toggles sprite visibility sequentially.
function light_panel_screen_uuad_sequential_sprites() as void
    i = m.sequentialSpritesLastIndex
    if (i = invalid)
        i = 0
    end if
    
    thisSprite = m.sprites[i]
    if (i = 0)
        prevSprite = m.sprites[m.sprites.Count() - 1]
    else
        prevSprite = m.sprites[i - 1]
    end if

    prevSprite.SetDrawableFlag(false)
    thisSprite.SetDrawableFlag(true)
    
    nextIndex = i + 1
    if (nextIndex >= m.sprites.Count())
        nextIndex = 0
    end if
    
    m.sequentialSpritesLastIndex = nextIndex
    m.compositor.DrawAll()
end function

' An UpdateAndDraw implementation that counts up in binary in each
' sprite group.
function light_panel_screen_uuad_binary_count() as void
    groupValues = m.binaryCountGroupValues
    if (groupValues = invalid)
        ' Clear all the lights the first time through, because left-over lights from 
        ' previous animations make the counter inaccurate.
        for each sprite in m.sprites
            sprite.SetDrawableFlag(false)
        end for 
        
        groupValues = {}
        m.binaryCountGroupValues = groupValues
    end if
        
    groupNum = 0
    for each group in m.spriteGroups
        value = groupValues[str(groupNum)]
        if (value = invalid)
            value = 0
            groupValues[str(groupNum)] = value
        end if
        
        ' Flip on the bits (big endian) for the value
        for i = group.Count() - 1 to 0 step -1
            m.sprites[group[i]].SetDrawableFlag(value and 2 ^ (group.Count() - i))
        end for
        
        ' Save the new value for this group
        groupValues[str(groupNum)] = value + 1
        
        ' Do the next group
        groupNum = groupNum + 1
    end for
    m.compositor.DrawAll()
end function
