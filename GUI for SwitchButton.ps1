Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "10x10 Switch Button Grid"
$form.ClientSize = New-Object System.Drawing.Size(520, 520)
$form.StartPosition = "CenterScreen"

$buttonSize = 50
$gridSize = 10

# Function to switch the state of a button
function Switch-ButtonState {
    param($btnText)
    $btn = $form.Controls | Where-Object { $_.Text -eq $btnText }
    if ($btn.BackColor -eq [System.Drawing.Color]::LightGreen) {
        $btn.BackColor = [System.Drawing.Color]::LightGray
    }
    else {
        $btn.BackColor = [System.Drawing.Color]::LightGreen
    }
    $btn.Tag = [int]$btn.Tag + 1
}

# Initialize the grid of buttons
for ($row = 0; $row -lt $gridSize; $row++) {
    for ($col = 0; $col -lt $gridSize; $col++) {
        $x = ($col * $buttonSize) + 2
        $y = ($row * $buttonSize) + 2
        $button = New-Object System.Windows.Forms.Button
        $button.Width = $buttonSize - 4
        $button.Height = $buttonSize - 4
        $button.Location = New-Object System.Drawing.Point($x, $y)
        $button.Tag = 0
        $button.Text = ($row * $gridSize + $col + 1) # store button number 1..100
        $button.BackColor = [System.Drawing.Color]::LightGray
        $button.Font = New-Object System.Drawing.Font("Arial",10,[System.Drawing.FontStyle]::Bold)
        $button.FlatStyle = "Flat"
        $button.FlatAppearance.BorderSize = 1

        $button.Add_Click({
            param($sender, $eventArgs)
            Switch-ButtonState $sender.Text
        })

        $form.Controls.Add($button)
    }
}

$form.Add_Click({
    for ($i = 1; $i -le 100; $i++) {
        # Write-Host $i
        foreach ($btn in $form.Controls) {
            if (($btn.Text % $i) -eq 0) {
                # Write-Host $btn.Text
                Switch-ButtonState $btn.Text
            }
        }
        $form.Refresh()
        Start-Sleep -Milliseconds 250
    }
})

$form.ShowDialog()

$form.controls | Select-Object Text, Tag