# Game of Life
#
# This is a PowerShell implementation of John H. Conway's Game of Life
#
# Rules
# 1) A dead cell with exactly three living neighbors becomes alive.
# 2) A living cell with two or three living neighbors remains alive.
# 3) In all other cases, the cell becomes (or remains) dead.
#
# How I plan to implement it into PowerShell
#
# Create a grid of specified size
# Implement cell calculation methods.
# Calculate a generation of the full grid to determine which cells will live and which will die
# Apply the calculated changes at the end of each generation
# Grid size can grow to a defined limit beyond the starting size
#
# TODO:
# Implement System.Windows.Forms.DataGrid to draw the output of each generation in a window containing the grid

# Enums
Enum CellState
{
    Dead = 0
    Alive = 1
}

# Classes
Class Grid
{
    $Generation = 0
    $SizeX = 20
    $SizeY = 20
    $Grid = (New-Object 'object[,]' $this.SizeX,$this.SizeY)
    Grid() {
        $this.PopulateGrid()
    }
    Grid([int]$SizeX,[int]$SizeY)
    {
        $this.SizeX = $SizeX
        $this.SizeY = $SizeY
        $this.Grid = New-Object 'object[,]' $this.SizeX,$this.SizeY
        $this.PopulateGrid()
    }
    [void]PopulateGrid() {
        For ($x = 0; $x -lt $this.SizeX; $x++)
        {
            For ($y = 0; $y -lt $this.SizeY; $y++){
                $this.Grid[$x,$y] = [Cell]::new($x,$y,[CellState]::Dead)
            }
        }
    }
    [void]MakeGlider($XPos, $YPos) {
        $this.Grid[($XPos + 1),($YPos)].State = [CellState]::Alive
        $this.Grid[($XPos + 2),($YPos + 1)].State = [CellState]::Alive
        $this.Grid[($XPos),($YPos + 2)].State = [CellState]::Alive
        $this.Grid[($XPos + 1),($YPos + 2)].State = [CellState]::Alive
        $this.Grid[($XPos + 2),($YPos + 2)].State = [CellState]::Alive
    }
    [void]ProcessGeneration()
    {
        $ToRevive = @()
        $ToKill = @()
        For ($x = 0; $x -lt $this.SizeX; $x++) {
            For ($y = 0; $y -lt $this.SizeY; $y++) {
                $LiveNeighbors = $this.Grid[$x,$y].GetLivingNeighbors($this)
                $LiveNeighborCount = ($LiveNeighbors | Measure-Object).Count
                If ($this.Grid[$x,$y].State -eq [CellState]::Dead -and $LiveNeighborCount -eq 3) {
                    $ToRevive += $this.Grid[$x,$y]
                }
                ElseIf ($this.Grid[$x,$y].State -eq [CellState]::Alive -and $LiveNeighborCount -ge 2 -and $LiveNeighborCount -le 3) {
                    $ToRevive += $this.Grid[$x,$y]
                }
                Else {
                    $ToKill += $this.Grid[$x,$y]
                }
            }
        }
        ForEach ($Cell in $ToRevive) {
            $Cell.Revive()
        }
        ForEach ($Cell in $ToKill) {
            $Cell.Kill()
        }
        $this.Generation++
    }
}

Class Cell
{
    $PosX = 0
    $PosY = 0
    $State = [CellState]::Dead
    Cell([int]$PosX,[int]$PosY,[CellState]$State)
    {
        $this.PosX = $PosX
        $this.PosY = $PosY
        $this.State = [CellState]::Dead
    }
    [void]Revive() {
        if ($this.State -eq [CellState]::Dead)
        {
            $this.State = [CellState]::Alive
        }
    }
    [void]Kill() {
        if ($this.State -eq [CellState]::Alive)
        {
            $this.State = [CellState]::Dead
        }
    }
    [array]GetNeighbors([Grid]$Grid) {
        $Neighbors = @()
        $Neighbors += $Grid.Grid[($this.PosX - 1),($this.PosY - 1)]
        $Neighbors += $Grid.Grid[($this.PosX - 1),($this.PosY)]
        $Neighbors += $Grid.Grid[($this.PosX - 1),($this.PosY + 1)]
        $Neighbors += $Grid.Grid[($this.PosX),($this.PosY - 1)]
        $Neighbors += $Grid.Grid[($this.PosX),($this.PosY + 1)]
        $Neighbors += $Grid.Grid[($this.PosX + 1),($this.PosY - 1)]
        $Neighbors += $Grid.Grid[($this.PosX + 1),($this.PosY)]
        $Neighbors += $Grid.Grid[($this.PosX + 1),($this.PosY + 1)]
        Return $Neighbors
    }
    [array]GetLivingNeighbors([Grid]$Grid) {
        Return $this.GetNeighbors($Grid) | Where-Object {$_.State -eq [CellState]::Alive}
    }
    [array]GetDeadNeighbors([Grid]$Grid) {
        Return $this.GetNeighbors($Grid) | Where-Object {$_.State -eq [CellState]::Dead}
    }
    [array]GetNeighborsAndSelf([Grid]$Grid) {
        $Neighbors = $this.GetNeighbors($Grid)
        $Neighbors += $Grid.Grid[($this.PosX),($this.PosY)] # Self
        Return $Neighbors
    }
}

#$Grid = [Grid]::new()
$Grid = [Grid]::new(30,30)
$Grid.MakeGlider(0,9)
$Grid.MakeGlider(9,9)
$Grid.MakeGlider(19,9)

For ($i = 0; $i -lt 100; $i++) {
    Write-Host "Processsing Generation"
    $Grid.ProcessGeneration()
    Write-Host "New Generation: Living Cells"
    $Grid.Grid | Where-Object {$_.State -eq ([CellState]::Alive)}
}
