
function Main {
    $inputName = "randomfile.bin";
    $outputName = "hands.csv";
    $handsCount = 1000000;
    Generate-Data -FileName $inputName -Size (55 * $handsCount)
	Format-Data -InputName $inputName -OutputName $outputName -DataSize $handsCount
}

function Generate-Data {
    param (
        [string]$FileName,
		[int]$Size
    )
	Write-Host "Generate Data"
	$rng = [System.Security.Cryptography.RandomNumberGenerator]::Create(); 
	$bytes = [byte[]]::new($Size); 
	$tmp = [byte[]]::new($Size); 
	$rng.GetBytes($bytes); 
	$j = 0;
	for (;;) {
		$rng.GetBytes($tmp);
		for ($i = 0; $i -lt $Size; $i ++) {
			if ($tmp[$i] -lt 1 ) { continue; }
		    if ($tmp[$i] -gt 52 ) { continue; }
			$bytes[$j] = $tmp[$i] ;
			$j ++;
			if ($j -eq $Size) { break; }
		}
	    if ($j -eq $Size) { break; }
	}
	[System.IO.File]::WriteAllBytes($FileName, $bytes);
}

function Format-Data {
    param (
        [string]$InputName,
		[string]$OutputName,
		[int]$DataSize
    )
	Write-Host "Format Data"
	$ids = @("2", "3", "4","5","6","7","8","9","T","J","Q","K","A")
	$suits = @("C","D","H","S")
	$inputPath = [System.IO.Path]::GetFullPath($InputName);
	$sourceStream = [System.IO.FileStream]::new($InputPath,[System.IO.FileMode]::Open, [System.IO.FileAccess]::Read);
	$outputPath = $inputPath -replace $InputName,  $OutputName;
	$buffer = [byte[]]::new(50);
	$lines = [System.Collections.Generic.List[string]]::new();
	$size = $DataSize + ($DataSize / 10);
	
	Write-Host "size:$($size) DataSize:$($DataSize)"
	
	$bytesRead = 0;
	for ($i = 0; $i -lt $size; $i ++) {
		$bytesRead = $sourceStream.Read($buffer, 0, $buffer.Length);
		$hashSet = [System.Collections.Generic.HashSet[byte]]::new($buffer);
		$uniqueBytes = New-Object byte[] $hashSet.Count;
		$hashSet.CopyTo($uniqueBytes);
		if ($uniqueBytes.Length -lt (25)) {
			continue
		}
		$cardBytes = [byte[]]::new(50);
		$k = 0;
		for ($j = 0; $j -lt $cardBytes.Length; $j += 2) {
			$cardBytes[$j], $cardBytes[$j+1] = Get-Card -OrderId $uniqueBytes[$k];
			$k ++;
		}
		
		$hand = [string[]]::new(50);
		for ($j = 0; $j -lt $cardBytes.Length; $j += 2) {
			$hand[$j] = $ids[$cardBytes[$j]-1];
			$hand[$j+1] = $suits[$cardBytes[$j+1]-1];
			if ([string]::IsNullOrEmpty($hand[$j])) {
				Write-Host " id empty $($cardBytes[$j])";
			}
			if ([string]::IsNullOrEmpty($hand[$j+1])) {
				Write-Host " suid empty $($cardBytes[$j+1])";
			}
		}
		
		$viewString = $hand -join ','; 
		$lines.Add($viewString);
		if($lines.Count -eq $DataSize) {
			break
		}
		if ($lines.Count % ($size - $DataSize) -eq 0) {
			Write-Host "$($lines.Count)";
		}
	}
	[System.IO.File]::WriteAllLines($outputPath, $lines);
	$sourceStream.Close();
}

function Get-Card {
    param (
        [int]$OrderId
    )
	
	$suit = $OrderId / 13;
	if ($suit -le 1) {
		$suit = 1; 
	}
	elseif ($suit -le 2){
		$suit = 2;
	} elseif ($suit -le 3) {
		$suit = 3;
	}	else {
		$suit = 4;
	}
	
	$id = $OrderId % 13;
	if ($id -eq 0) {
		$id = 13;
	}
    return $id, $suit;
}

Main

