# Add-Type -AssemblyName WindowsBase
# Add-Type -AssemblyName PresentationCore

class SnakePart{
    [int]$X = 0
    [int]$Y = 0
    [int]$PrevX = 0
    [int]$PrevY = 0
    SnakePart(
        [int]$x,
        [int]$y
    ){
        $this.X = $x
        $this.Y = $y
    }
}

function Update-Snake{
    param (
        $Snake,
        $Direction
    )
    if ($Direction -eq "Down"){
        $Snake[0].PrevX = $Snake[0].X
        $Snake[0].PrevY = $Snake[0].Y
        $Snake[0].y += 1
        if ($Snake[0].y -gt 9){
            return $false
        }
    }
    elseif ($Direction -eq "Up"){
        $Snake[0].PrevX = $Snake[0].X
        $Snake[0].PrevY = $Snake[0].Y
        $Snake[0].y -= 1
        if ($Snake[0].y -lt 0){
            return $false
        }       
    }
    elseif ($Direction -eq "Left"){
        $Snake[0].PrevX = $Snake[0].X
        $Snake[0].PrevY = $Snake[0].Y
        $Snake[0].x -= 1
        if ($Snake[0].x -lt 0){
            return $false
        }       
    }
    elseif ($Direction -eq "Right"){
        $Snake[0].PrevX = $Snake[0].X
        $Snake[0].PrevY = $Snake[0].Y
        $Snake[0].x += 1
        if ($Snake[0].x -gt 9){
            return $false
        }       
    }


    for ($i = 1; $i -lt $Snake.length; $i++){
        $Snake[$i].PrevX = $Snake[$i].X
        $Snake[$i].PrevY = $Snake[$i].Y
        $Snake[$i].X = $Snake[$i - 1].PrevX
        $Snake[$i].Y = $Snake[$i - 1].PrevY
    }

    return $true
}

function Update-Powerup{
    param (
        $Snake
    )

    if ($Snake[-1].x -lt $Snake[-2].x){
        $Snake += [SnakePart]::new($Snake[-1].x - 1, $Snake[-1].y)
    }
    elseif ($Snake[-1].x -gt $Snake[-2].x){
        $Snake += [SnakePart]::new($Snake[-1].x + 1, $Snake[-1].y)
    }
    elseif ($Snake[-1].y -lt $Snake[-2].y){
        $Snake += [SnakePart]::new($Snake[-1].x, $Snake[-1].y - 1)
    }
    elseif ($Snake[-1].y -gt $Snake[-2].y){
        $Snake += [SnakePart]::new($Snake[-1].x, $Snake[-1].y + 1)
    }

    return $Snake
}

function Start-Snake{
    $difficulty = $null
    $speed

    while (-not $difficulty){
        $difficulty = Read-Host "Enter a difficulty (1, 2, 3)"
        if ($difficulty -eq 1){
            $speed = 0.7
        }
        elseif ($difficulty -eq 2){
            $speed = 0.5
        }
        elseif ($difficulty -eq 3){
            $speed = 0.3
        }
        elseif ($difficulty -eq "EXTREMEGAMER"){
            $speed = 0.15
        }
        else{
            $difficulty = $null
        }
    }

    $board = @(@('[ ]', '[ ]', '[ ]', '[ ]', '[ ]', '[ ]', '[ ]', '[ ]', '[ ]', '[ ]'),
    @('[ ]', '[ ]', '[ ]', '[ ]', '[ ]', '[ ]', '[ ]', '[ ]', '[ ]', '[ ]'),
    @('[ ]', '[ ]', '[ ]', '[ ]', '[ ]', '[ ]', '[ ]', '[ ]', '[ ]', '[ ]'),
    @('[ ]', '[ ]', '[ ]', '[ ]', '[ ]', '[ ]', '[ ]', '[ ]', '[ ]', '[ ]'),
    @('[ ]', '[ ]', '[ ]', '[ ]', '[ ]', '[ ]', '[ ]', '[ ]', '[ ]', '[ ]'),
    @('[ ]', '[ ]', '[ ]', '[ ]', '[ ]', '[ ]', '[ ]', '[ ]', '[ ]', '[ ]'),
    @('[ ]', '[ ]', '[ ]', '[ ]', '[ ]', '[ ]', '[ ]', '[ ]', '[ ]', '[ ]'),
    @('[ ]', '[ ]', '[ ]', '[ ]', '[ ]', '[ ]', '[ ]', '[ ]', '[ ]', '[ ]'),
    @('[ ]', '[ ]', '[ ]', '[ ]', '[ ]', '[ ]', '[ ]', '[ ]', '[ ]', '[ ]')
    )

    $score = 0

    $snake = @([SnakePart]::new(2, 4), [SnakePart]::new(2, 3), [SnakePart]::new(2, 2))

    $game_running = $true

    $direction = "Down"

    $powerup_flag = $false

    $blockX, $blockY = 0, 0

    while ($game_running){
        if ([Console]::KeyAvailable)
        {
            $keyInfo = [Console]::ReadKey($true)
            $key = $keyInfo.Key
            if ($key -eq "UpArrow" -and $direction -ne "Down"){
                $direction = "Up"
            }
            elseif ($key -eq "DownArrow" -and $direction -ne "Up"){
                $direction = "Down"
            }
            elseif ($key -eq "LeftArrow" -and $direction -ne "Right"){
                $direction = "Left"
            }
            elseif ($key -eq "RightArrow" -and $direction -ne "Left"){
                $direction = "Right"
            }
        }

        for($i = 0; $i -lt $board.length; $i ++){
            for($j = 0; $j -lt $board[$i].length; $j++){
                $board[$i][$j] = '[ ]'
            }
        }
        
        if (-not $powerup_flag){
            $blockX = Get-Random -Minimum 0 -Maximum 10
            $blockY = Get-Random -Minimum 0 -Maximum 10

            while($board[$blockX][$blockY] -eq '[ ]'){
                $blockX = Get-Random -Minimum 0 -Maximum 10
                $blockY = Get-Random -Minimum 0 -Maximum 10           
            }
            $powerup_flag = $true
        }
        $board[$blockX][$blockY] = '[*]'

        $game_running = Update-Snake $Snake $direction

        if (-not $game_running){
            break
        }

        foreach ($part in $snake){
            if ($board[$part.y][$part.x] -eq '[*]'){
                $Snake = Update-Powerup $Snake
                $powerup_flag = $false
                $score += 10
            }
            if ($board[$part.y][$part.x] -eq '[O]'){
                $game_running = $false
            }
            else{
                $board[$part.y][$part.x] = '[O]'
            }
        }

        foreach($line in $board){
            $line = -join $line
            write-host $line
        }
         
        Start-Sleep -Seconds $speed
        
        Clear-Host
    }
    write-host "Final Score:" $score

    return $Null
}

Start-Snake