param (
    [switch]$l, # małe litery
    [switch]$u, # duże litery
    [switch]$d, # cyfry
    [switch]$s, # znaki specjalne
    [int]$c = 8 # długość hasła (domyślnie 8)
)

function New-Password {
    param (
        [switch]$l,
        [switch]$u,
        [switch]$d,
        [switch]$s,
        [int]$c
    )

    $pool = @()
    if ($l) { $pool += [char[]](97..122) }
    if ($u) { $pool += [char[]](65..90) }
    if ($d) { $pool += [char[]](48..57) }
    if ($s) { $pool += [char[]](33, 35, 36) }

    if (-not $pool) { throw "Wybierz przynajmniej jeden typ znaków." }

    -join (1..$c | ForEach-Object { $pool | Get-Random -Count 1 })
}

New-Password -l:$l -u:$u -d:$d -s:$s -c:$c