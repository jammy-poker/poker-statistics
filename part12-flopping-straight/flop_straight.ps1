
function Main {
    $inputName = "hands.csv";
    $indexes = @(0, 2, 40, 42, 44);
	$count = 0;
	$n = 0;
    foreach ($line in [System.IO.File]::ReadLines($inputName)) {
		$array = $line -split ",";
		[System.Collections.Generic.List[string]]$cards = 
		[System.Collections.Generic.List[string]]::new();
		foreach($i in $indexes) {
			$cards.Add($array[$i]);
		}
		$ret = Is-Straight -CardValues $cards.ToArray();		
		if ($ret -eq $true) {
			$count ++;
			Write-Output "cards: $cards";
			Write-Output "count: $count";
		}
	}
}

function Is-Straight {
    param (
        [string[]]$CardValues 
    )
	
	[System.Collections.Generic.List[int]]$ids = 
	[System.Collections.Generic.List[int]]::new();
    foreach ($card in $CardValues) {
		$id = Get-Card-Id -CardValue $card;
		$ids.Add($id);
    }
	$ids = $ids | Sort-Object;
	if (($ids[0] -eq 2) -and ($ids[1] -eq 3) -and 
	($ids[2] -eq 4) -and ($ids[3] -eq 5) -and ($ids[4] -eq 14)) { 
		return $true; 
	}
	for ($i = 1; $i -lt $ids.Count; $i ++) {
		$difference = $ids[$i] - $ids[$i-1];
        if ($difference -ne 1) { return $false; }
    }	
	return $true;
}

function Get-Card-Id {
    param (
        [string]$CardValue 
    )
	$names = @("", "", "2", "3", "4","5","6","7","8",
	"9","T","J","Q","K","A");
    for ($i = 0; $i -lt $names.Length; $i ++) {
        if ($CardValue -eq $names[$i]) { return $i; }
    }
	return -1;
}

Main

