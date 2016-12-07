$list = gc .\list.txt

##EMAIL Setings
$msg = new-object Net.Mail.MailMessage
$smtpServer = "mx1.smtp.net" 
$smtp = New-Object Net.Mail.SmtpClient($smtpServer) 
$msg.From = “from@email.com” 
$msg.To.Add("trevor.dodds@email.com”)

$warning = "80"
$critical = "90"
$warn = "W"
$crit = "C"


foreach ($server in $list)
{

$pegasus = gwmi Win32_LogicalDisk -filter drivetype=3 -computer $server

	foreach ($item in $pegasus)
		{
		$Device = $item.DeviceID
		$Disk = gwmi Win32_LogicalDisk -filter drivetype=3 -computer $server | where {$_.DeviceID -match "$Device"}
		
		[long]$total = $Disk.Size
		[long]$free = $Disk.Freespace
		$used = $total - $free
		$percent = $used / $total * 100
		$percent = ([math]::Round([decimal]"$percent", 0))
		$size = ($Disk.size/1gb)
		$size = ([math]::Round([decimal]"$size", 2))
		$frees = ($Disk.Freespace/1gb)
		$frees = ([math]::Round([decimal]"$frees", 2))

		if ($percent -gt $critical)
			{
			$attmp = "$server$Device"
			$atlantis = ($attmp).replace(":", "")
			$tmp = Test-Path $atlantis".lck"
			Write-Host Does LCK Exist: $tmp -f 10

			if ($tmp -ne "False")
				{
				$crit | out-file $atlantis".lck"
				$msg.Subject = "Space Critical on", ($server)
				$msg.Body = "Server:",($server), "-", "Total Size GB:", $size, "-", "Free Space GB:", $frees, "-", "Percent:", ($percent), "-", "Threshold:", ($critical),"%"
#				Write-Host $msg.Subject
#				Write-Host $msg.Body
				$smtp.Send($msg)
				}
			else	{
				$power = (get-date).AddDays(-3)
				$zpm = get-childitem $atlantis".lck"
				$status = gc $atlantis".lck"

				if ($status -eq "W") 	{
					$crit | out-file $atlantis".lck"
					$msg.Subject = "Space Escalated to Critical on", ($server)
					$msg.Body = "Server:",($server) , "-", "Total Size GB:", $size, "-", "Free Space GB:", $frees, "-", "Percent:", ($percent), "-", "Threshold:", ($critical),"%"
#					Write-Host $msg.Subject
#					Write-Host $msg.Body
					$smtp.Send($msg)
					}
				elseif ($zpm.LastWriteTime -gt $power) 
					{
					Write-Host Less than Three Days!
					}
				else 	{
#					out-file $atlantis".lck"
					$msg.Subject = "Space Critical on", ($server), "for over 3 days!"
					$msg.Body = "Server:",($server) , "-", "Total Size GB:", $size, "-", "Free Space GB:", $frees, "-", "Percent:", ($percent), "-", "Threshold:", ($critical),"%"
#					Write-Host $msg.Subject
#					Write-Host $msg.Body
					$smtp.Send($msg)
					}
				}
			}
		elseif ($percent -gt $warning)
			{
			$attmp = "$server$Device"
			$atlantis = ($attmp).replace(":", "")
			$tmp = Test-Path $atlantis".lck"
			Write-Host Does TMP Exist: $tmp -f 10

			if ($tmp -ne "False")
				{
				$warn | out-file $atlantis".lck"
				$msg.Subject = "Space Warning on", ($server)
				$msg.Body = "Server:",($server) , "-", "Total Size GB:", $size, "-", "Free Space GB:", $frees, "-", "Percent:", ($percent), "-", "Threshold:", ($warning),"%"
#				Write-Host $msg.Subject
#				Write-Host $msg.Body
				$smtp.Send($msg)
				}
			else	{
				$power = (get-date).AddDays(-3)
				$zpm = get-childitem $atlantis".lck"
				$status = gc $atlantis".lck"

				if ($status -eq "C") 	{
					$warn | out-file $atlantis".lck"
					$msg.Subject = "Space Downgraded to Warning on", ($server)
					$msg.Body = "Server:",($server) , "-", "Total Size GB:", $size, "-", "Free Space GB:", $frees, "-", "Percent:", ($percent), "-", "Threshold:", ($warning),"%"
#					Write-Host $msg.Subject
#					Write-Host $msg.Body
					$smtp.Send($msg)
					}
				elseif ($zpm.LastWriteTime -gt $power) 
					{
					Write-Host Less than Three Days!
					}
				else 	{
#					out-file $atlantis".lck"
					$msg.Subject = "Space Warning on", ($server), "for over 3 days!"
					$msg.Body = "Server:",($server) , "-", "Total Size GB:", $size, "-", "Free Space GB:", $frees, "-", "Percent:", ($percent), "-", "Threshold:", ($warning),"%"
#					Write-Host $msg.Subject
#					Write-Host $msg.Body
					$smtp.Send($msg)
					}
				}
			}
		else
			{
			$attmp = "$server$Device"
			$atlantis = ($attmp).replace(":", "")
			$tmp = Test-Path $atlantis".lck"
			Write-Host Does LCK Exist: $tmp -f 10

			if ($tmp -eq "True")
				{
				$zpm = get-childitem $atlantis".lck"
				$zpm.Delete()
				$msg.Subject = "Space Recovered on", ($server)
				$msg.Body = "Server:",($server) , "-", "Total Size GB:", $size, "-", "Free Space GB:", $frees, "-", "Percent:", ($percent)
#				Write-Host $msg.Subject
#				Write-Host $msg.Body
				$smtp.Send($msg)
				}
			else 	{
				Write-Host ($server) - Percent: $percent is less than $warning and $critical 
				}
			}
		}

}
