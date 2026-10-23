$ErrorActionPreference = 'Stop'

function Generate-Sound([string]$outPath, [double]$freq, [double]$duration) {
    $sampleRate = 22050
    $samples = [int]($sampleRate * $duration)
    $bytesPerSample = 2
    $subChunk2Size = $samples * $bytesPerSample
    $chunkSize = 36 + $subChunk2Size

    $fs = [System.IO.File]::Create($outPath)
    $bw = New-Object System.IO.BinaryWriter($fs)

    # RIFF header
    $bw.Write([System.Text.Encoding]::ASCII.GetBytes("RIFF"))
    $bw.Write([int]$chunkSize)
    $bw.Write([System.Text.Encoding]::ASCII.GetBytes("WAVE"))

    # fmt chunk
    $bw.Write([System.Text.Encoding]::ASCII.GetBytes("fmt "))
    $bw.Write([int]16)
    $bw.Write([int16]1)
    $bw.Write([int16]1)
    $bw.Write([int]$sampleRate)
    $bw.Write([int]($sampleRate * $bytesPerSample))
    $bw.Write([int16]$bytesPerSample)
    $bw.Write([int16]16)

    # data chunk
    $bw.Write([System.Text.Encoding]::ASCII.GetBytes("data"))
    $bw.Write([int]$subChunk2Size)

    for ($i = 0; $i -lt $samples; $i++) {
        $t = [double]$i / $sampleRate
        $envelope = [Math]::Exp(-2.5 * $t / $duration)
        $val = [Math]::Sin(2.0 * [Math]::PI * $freq * $t) * $envelope
        $sample = [int16]($val * 24000)
        $bw.Write($sample)
    }

    $bw.Close()
    $fs.Close()
}

New-Item -ItemType Directory -Force -Path 'android/app/src/main/res/raw'

Generate-Sound 'assets/audio/adhan_cairo.mp3' 440.0 2.5
Generate-Sound 'assets/audio/adhan_fajr.mp3' 520.0 2.5
Generate-Sound 'assets/audio/adhan_takbeer.mp3' 390.0 2.0
Generate-Sound 'assets/audio/alert_chime.mp3' 660.0 1.2

Copy-Item 'assets/audio/adhan_cairo.mp3' 'android/app/src/main/res/raw/adhan_cairo.mp3' -Force
Write-Host "Audio files generated successfully."
