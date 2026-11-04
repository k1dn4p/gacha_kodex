# Local placeholder artwork; no downloads or third-party graphics required.
# Run from any directory: powershell -File tools/generate_advent_assets.ps1
Add-Type -AssemblyName System.Drawing
$assetDir = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../assets/images/advent'))
[IO.Directory]::CreateDirectory($assetDir) | Out-Null
function Brush($color) { [Drawing.SolidBrush]::new([Drawing.ColorTranslator]::FromHtml($color)) }
function Rect($color, $x, $y, $w, $h) {
    $b = Brush $color
    $script:g.FillRectangle($b, [single]$x, [single]$y, [single]$w, [single]$h)
    $b.Dispose()
}
function Oval($color, $x, $y, $w, $h) {
    $b = Brush $color
    $script:g.FillEllipse($b, [single]$x, [single]$y, [single]$w, [single]$h)
    $b.Dispose()
}
function Poly($color, $coords) {
    $points = for ($i=0; $i -lt $coords.Length; $i+=2) { [Drawing.PointF]::new($coords[$i],$coords[$i+1]) }
    $b = Brush $color
    $script:g.FillPolygon($b, [Drawing.PointF[]]$points)
    $b.Dispose()
}
function Line($color, $width, $x1, $y1, $x2, $y2) {
    $p = [Drawing.Pen]::new([Drawing.ColorTranslator]::FromHtml($color),[single]$width)
    $script:g.DrawLine($p,[single]$x1,[single]$y1,[single]$x2,[single]$y2)
    $p.Dispose()
}
function Asset($name, $width, $height, [scriptblock]$draw) {
    $bitmap = [Drawing.Bitmap]::new(($width*2),($height*2))
    $script:g = [Drawing.Graphics]::FromImage($bitmap)
    $script:g.SmoothingMode = [Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $script:g.Clear([Drawing.Color]::Transparent)
    $script:g.ScaleTransform(2,2)
    & $draw
    $bitmap.Save((Join-Path $assetDir "$name.png"),[Drawing.Imaging.ImageFormat]::Png)
    $script:g.Dispose()
    $bitmap.Dispose()
}

Asset 'exterior' 540 520 {
    # Chimney, body and snowy pitched roof. The door leaf is NOT part of this asset.
    Rect '#984D4D' 395 28 54 113
    Rect '#E9F1ED' 388 20 68 18
    Rect '#D7AC86' 45 150 450 310
    Rect '#C18E6F' 45 420 450 40
    for ($row=0; $row -lt 7; $row++) {
        Line '#CDA07D' 2 48 (195+$row*35) 492 (195+$row*35)
    }
    Poly '#734550' @(5,160,265,18,535,160)
    Poly '#AE6360' @(22,145,265,37,518,145)
    Poly '#F6F6EB' @(5,145,265,2,535,145,524,162,265,25,14,163)
    for ($i=0; $i -lt 10; $i++) { Oval '#F6F6EB' (24+$i*50) 142 36 18 }
    Rect '#643C3D' 36 160 468 15
    # Sign at world 160,270. Labels are decoration; day numbers are Flutter widgets.
    Rect '#795047' 130 125 280 72
    Rect '#315448' 136 131 268 60
    Line '#D9BB7D' 2 142 137 398 137
    Line '#D9BB7D' 2 142 184 398 184
    $font = [Drawing.Font]::new('Georgia',23,[Drawing.FontStyle]::Bold,[Drawing.GraphicsUnit]::Pixel)
    $b = Brush '#F5E5BC'
    $script:g.DrawString('NOEL BAKERY',$font,$b,[single]153,[single]145)
    $font.Dispose(); $b.Dispose()
    # Window recess: world 100,360 (local 70,220), 175 x 165.
    Rect '#694238' 63 213 189 181
    Rect '#1D3443' 70 220 175 165
    Rect '#254252' 76 226 163 153
    Rect '#87604B' 151 220 12 165
    Rect '#87604B' 70 296 175 10
    Rect '#FAF5EB' 57 386 201 12
    Oval '#FAF5EB' 56 382 202 15
    # Empty doorway frame. Both replaceable door assets have identical bounds.
    Rect '#694238' 313 203 144 244
    Rect '#1D3443' 320 210 130 230
    Rect '#EAE0CA' 308 440 154 14
    Rect '#C8C6B8' 298 454 174 14
    # Snowbanks and little winter pines, without bread or a wreath.
    Oval '#F6F6EB' 0 466 540 42
    Poly '#315448' @(4,462,30,355,56,462)
    Poly '#436A56' @(0,430,30,365,61,430)
    Poly '#FAF5EB' @(10,408,30,365,48,408)
    Poly '#315448' @(478,468,510,339,540,468)
    Poly '#FAF5EB' @(493,388,510,339,525,388)
    Oval '#F6F6EB' 0 468 95 20
    Oval '#F6F6EB' 461 468 78 20
}
Asset 'window_light' 175 165 {
    Rect '#D9A45B' 0 0 175 165
    Rect '#FFE9A5' 6 6 163 153
    Rect '#FFF1C4' 15 12 145 143
    Rect '#87604B' 81 0 12 165
    Rect '#87604B' 0 76 175 10
    Poly '#C37268' @(6,6,44,6,6,64)
    Poly '#C37268' @(169,6,131,6,169,64)
    Rect '#E4C286' 7 148 161 11
}
Asset 'closed_door' 130 230 {
    Rect '#315448' 0 0 130 230
    Rect '#436A56' 7 7 116 215
    Rect '#D4B780' 15 15 100 94
    Rect '#203C4D' 21 21 88 82
    Rect '#315448' 60 21 9 82
    Rect '#315448' 21 60 88 8
    Rect '#315448' 16 126 98 85
    Rect '#436A56' 23 133 84 71
    Oval '#E7CB8E' 104 116 12 12
}
Asset 'open_door' 130 230 {
    Rect '#E7BF7A' 0 0 130 230
    Rect '#FFE9AE' 7 5 116 214
    Rect '#F5D596' 8 5 114 35
    Rect '#B78255' 8 205 114 25
    for ($i=0; $i -lt 4; $i++) { Line '#D6A367' 2 (10+$i*29) 205 (5+$i*31) 230 }
    # Open leaf stays within the very same asset bounds as the closed leaf.
    Poly '#315448' @(0,0,31,18,31,214,0,230)
    Poly '#436A56' @(5,13,25,25,25,206,5,216)
    Poly '#719385' @(7,24,22,32,22,95,7,92)
    Oval '#E7CB8E' 20 112 7 9
}
Asset 'bread' 92 110 {
    Rect '#795047' 3 36 86 7
    Rect '#795047' 3 82 86 7
    Rect '#674535' 8 37 6 73
    Rect '#674535' 77 37 6 73
    for ($i=0; $i -lt 3; $i++) {
        Oval '#B7773D' (7+$i*27) 11 23 25
        Oval '#E3AA60' (8+$i*27) 10 21 21
        Line '#FADE9B' 2 (14+$i*27) 13 (11+$i*27) 22
        Line '#FADE9B' 2 (21+$i*27) 13 (18+$i*27) 22
    }
    Oval '#C38A4D' 7 55 36 26
    Oval '#E9B76B' 9 53 32 24
    Oval '#C38A4D' 49 55 36 26
    Oval '#E9B76B' 51 53 32 24
    Line '#FADE9B' 3 18 58 15 67
    Line '#FADE9B' 3 28 58 25 67
    Line '#FADE9B' 3 60 58 57 67
    Line '#FADE9B' 3 70 58 67 67
}
Asset 'wreath' 90 90 {
    # A transparent centre, so the facade remains visible through the wreath.
    for ($i=0; $i -lt 16; $i++) {
        $a = $i * [Math]::PI / 8
        $x = 35 + 27*[Math]::Cos($a)
        $y = 35 + 27*[Math]::Sin($a)
        Oval '#254F43' $x $y 20 20
        Oval '#49745B' ($x+2) ($y+2) 10 10
    }
    foreach ($p in @(@(18,24),@(63,25),@(15,55),@(64,57),@(39,9))) { Oval '#B64F51' $p[0] $p[1] 9 9 }
    Poly '#B64F51' @(44,67,22,58,25,80,44,72,65,81,67,58)
    Oval '#E7CB8E' 39 63 12 12
}
Get-ChildItem -LiteralPath $assetDir -Filter '*.png' | Select-Object Name,Length
