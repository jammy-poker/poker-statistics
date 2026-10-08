
function Main {
    $inputName = "hands.csv";
    $indexes = @(0, 2, 40, 42, 44);
	$count = 0;
    foreach ($line in [System.IO.File]::ReadLines($inputName)) {
		$array = $line -split ",";
		$cards = [System.Collections.Generic.List[string]]::new();
		foreach($i in $indexes) {
			$cards.Add($array[$i]);
		}
		$ret = Is-Boat -CardValues $cards.ToArray();		
		if ($ret -eq $true) {
			$count ++;
			Write-Output "cards: $cards";
			Write-Output "count: $count";
		}
	}
}

function Is-Boat {
    param (
        [string[]]$CardValues 
    )
	
	$ids = Get-Same-Kind -CardValues $CardValues -Count 3; 		
	if ($($ids.Count) -eq 0) { return $false; }
	$ids | Sort-Object -Descending;
	$cardName = Get-Card-Name -CardId $ids[0];
	$cardValues = $CardValues | Where-Object { $_ -ne $cardName };
	$ids = Get-Same-Kind -CardValues $cardValues -Count 2; 		
	if ($($ids.Count) -eq 0) { return $false; }
	
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

function Get-Card-Name {
    param (
        [int]$CardId 
    )
	$names = @("", "", "2", "3", "4","5","6","7","8",
	"9","T","J","Q","K","A");
    return $names[$CardId];
}

function Get-Same-Kind {
	param (
        [string[]]$CardValues, 
		[int] $Count
    )
	$values = @{};
	for ($i = 0; $i -lt $CardValues.Length; $i ++) {
		if ($values.ContainsKey($CardValues[$i])) {
			$values[$CardValues[$i]] += 1;	
		} else {
			$values[$CardValues[$i]] = 1;
		}
    }
	$keys = New-Object System.Collections.Generic.List[int]; 
	foreach ($item in $values.GetEnumerator()) {
		if ($($item.Value) -lt $Count) { continue; }
		$id = Get-Card-Id -CardValue $($item.Key);
		$keys.Add($id); 
	}
	return , $keys
}

Main

