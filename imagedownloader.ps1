# Create output directory if it doesn't exist
$outputDir = "pokemon_images"
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir
}

# Function to download image
function Download-PokemonImage {
    param(
        [int]$pokemonId
    )
    
    try {
        # Construct the PokeAPI URL for the Pokemon
        $apiUrl = "https://pokeapi.co/api/v2/pokemon/$pokemonId"
        
        # Get Pokemon data from API
        $pokemonData = Invoke-RestMethod -Uri $apiUrl
        
        # Get front sprite URL
        $spriteUrl = $pokemonData.sprites.front_default
        
        if ($spriteUrl) {
            # Download sprite with Pokemon ID as filename
            $outputPath = Join-Path $outputDir ("{0:D3}.png" -f $pokemonId)
            Invoke-WebRequest -Uri $spriteUrl -OutFile $outputPath
            Write-Host "Downloaded sprite for Pokemon #$pokemonId"
        }
        
        # Add a small delay to avoid overwhelming the API
        Start-Sleep -Milliseconds 500
    }
    catch {
        Write-Error ("Failed to download Pokemon #{0}: {1}" -f $pokemonId, $_.Exception.Message)
    }
}

# Download images for Pokemon from Gen 1-3 (1-386)
Write-Host "Starting Pokemon image download (Gen 1-3)..."

# Create a counter for progress tracking
$total = 386
$current = 0

1..386 | ForEach-Object {
    $current++
    $percentComplete = [math]::Round(($current / $total) * 100, 2)
    Write-Progress -Activity "Downloading Pokemon Images" -Status "Processing Pokemon #$_" -PercentComplete $percentComplete
    Download-PokemonImage -pokemonId $_
}

Write-Host "Download complete! All Pokemon images have been saved to $outputDir"
