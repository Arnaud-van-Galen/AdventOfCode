# Define the grid size
$gridRows = 20
$gridColumns = 10

# Initialize the grid
$grid = New-Object 'object[,]' $gridRows, $gridColumns

# Define a custom shape as an array of coordinates
$shape1 = @(
    @(0, 0),
    @(0, 1),
    @(1, 0),
    @(1, 1)
)

# Define another custom shape
$shape2 = @(
    @(0, 0),
    @(0, 1),
    @(1, 1),
    @(2, 1)
)

# Function to rotate a shape
function Rotate-Shape($shape) {
    # Transpose the shape and reverse the rows
    $shape | ForEach-Object { [array]::Reverse($_) } | ConvertFrom-Csv -Delimiter " "
}

# Function to move a shape within the grid
function Move-Shape($shape, $x, $y) {
    # Add the x and y offsets to each coordinate
    $shape | ForEach-Object { [pscustomobject]@{ X = $_[0] + $x; Y = $_[1] + $y } }
}

# Function to draw the grid and shapes to the screen
function Draw-Game($grid, $shapes) {
    # Clear the screen
    Clear-Host
    
    # Loop through the rows and columns of the grid
    for ($row = 0; $row -lt $gridRows; $row++) {
        for ($col = 0; $col -lt $gridColumns; $col++) {
            # Check if the cell is occupied by a shape
            $occupied = $false
            foreach ($shape in $shapes) {
                foreach ($coordinate in $shape) {
                    if ($coordinate.X -eq $col -and $coordinate.Y -eq $row) {
                        $occupied = $true
                        break
                    }
                }
                if ($occupied) { break }
            }
            
            # Output a dash for an empty cell, or an X for an occupied cell
            if ($occupied) {
                Write-Host -NoNewline "X"
            }
            else {
                Write-Host -NoNewline "-"
            }
        }
        # Start a new line after each row
        Write-Host
    }
}

# Main game loop
while ($true) {
    # Rotate and move the shapes
    $shapes = @()
    $shapes += Rotate-Shape $shape1 | Move-Shape -X 4 -Y 0
    $shapes += Rotate-Shape $shape2 | Move-Shape -X 0 -Y 4
