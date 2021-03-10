#Send mail through SMTP relay to all guardians who meet the following criteria
# 1) Student is active and enrolled
# 2) Student in Grades 6-SS
# 3) Valid email address is present on Contact_ID
# 4) Contact type is Guardian
# 5) Access code has not been used
#
#There is an optional $blding variable that lets you pull a single building instead of all buildings.
# Using Cognos Report Mail-Merge-HAC-Access-6-12 or Mail-Merge-HAC-Access-Building 
#Reports are in the SMS->
#
#Prep work to be done:
# Log into Eschool and go to Registration->Utilities->Tools_ Generate HAC Credentials, schedule this to run as often as you want (recommended minimum once per day)
#Author
#Charlie Weber
#Rogers Public Schools 
#Add logging to catch errors and record the reason(s)
#
#If using Office365 the user account needs to have a licensed mailbox and auth to the SMTP server
#Parameters for commandline calls
Param(
    [parameter(Mandatory = $false, HelpMessage = "What LEA # building do you want to Download.")]
    [string]$blding = "",
    [parameter(Mandatory = $false, HelpMessage = "Do you want to test the file.")]
    [switch]$testing,
    [parameter(Mandatory = $false, HelpMessage = "SkipDownloading from Cognos")]
    [switch]$skipCognos
)

Start-Transcript -path "c:\scripts\logs\HAC-ParentContact-$(Get-date -format yyyy-MM-dd-HH-mm).log" 
Measure-Command{
#Get a specific building
if($skipCognos) {}else{
If ($blding -gt 1) {
    c:\scripts\Importfiles\Scripts\Cognosdownload.ps1  -report "Mail-Merge-HAC-Access-Building" -savepath "c:\scripts\"  -teamcontent -Cognosfolder "_District Shared/Automated-Daily-Reports/"  -reportparams "p_Building=$blding" -username "0405cweber"
    $parentCSV = import-csv ".\Mail-Merge-HAC-Access-Building.csv"
}
else {
    #Get ALL 6-12 students
    c:\scripts\Importfiles\Scripts\Cognosdownload.ps1  -report "Mail-Merge-HAC-Access-6-12" -savepath "c:\scripts\"  -teamcontent -Cognosfolder "_District Shared/Rogers/Automated-Daily-Reports/" -username "0405cweber"
    $parentCSV = import-csv ".\Mail-Merge-HAC-Access-6-12.csv"
}} #close Skip Cognos loop
#Variables
#$smtpserver = "domain.mail.protection.outlook.com"
$passwordfile = "c:\scripts\HAC-notification.txt"
$smtpserver = "smtp.office365.com"
$smtpport = "587"
$from = "noreply-hac@domain"
$subject = "Your Guardian HAC access code"
$testRecipient = "user@domain"
$school = "School"
$countAttempt = 0
$countError = 0
if($testing){
$parentCSV = import-csv ".\Mail-Merge-HAC-Access.csv"
}
if ((Test-Path ($passwordfile))) {
    $password = Get-Content $passwordfile | ConvertTo-SecureString
} else {
    Write-Host("Password file does not exist! [$passwordfile]. Please enter a password to be saved on this computer for scripts") -ForeGroundColor Yellow
    Read-Host "Enter Password" -AsSecureString |  ConvertFrom-SecureString | Out-File $passwordfile
    $password = Get-Content $passwordfile | ConvertTo-SecureString
}

$cred = New-Object System.Management.Automation.PSCredential -ArgumentList $from, $password


#Raw code, should not need to edit below unless you want to change wording.
Foreach ($parent in $parentCSV) {
    $to = $parent.email
    $hactoken = $parent."HAC-Access"
    $studentfName = $parent."S-F-Name"
    $studentLName = $parent."S-L-Name"
    $contactID = $parent.Contact_ID
    $studentid = $parent.Student_ID
$countAttempt++
    $body = "
Parent or Guardian of $studentFname $studentLName,
<p>Home Access Center (HAC) is available for you to access your student's school information over the Internet.  <br>
<p>Through HAC, you can view a daily summary of your student's attendance, schedule, and classwork.  In addition, interim progress reports, report cards, and discipline information may be available.<br>

<p>To access HAC, use the following URL: http://hac20.esp.k12.ar.us<br>

<p>An Access Code has been created for you to access your child's HAC record.  Follow the steps below to use your access code...<br>
<p>1.  Access the HAC Website at http://hac20.esp.k12.ar.us<br>
<p>2.  Below the Password box click on the link labeled <i>Click Here to Register With Access Code.</i><br>
<p>3.  Select the district name $school Public Schools<br>
<p>4.  Enter your Access Code, <strong>$hactoken</strong>  in the Access Code box.<br>
<p>5.  Enter the birthdate of one of your children in a MM/DD/YYYY format.<br>
<p>6.  Select Sign In and the focus moves to the My Account page.<br>
<p>7.  Enter the desired password in the New Password fields.<br>
<p>8.  You must compose and answer three,  security challenge questions  if you have not done so before.<br>
<p>Any questions and answers entered here should be recorded and kept in a secure location.<br>
<p>This information can be used to access HAC in the case of a forgotten or an expired password.<br>
<p>9.  Once the password is entered and the required security question(s) are created, select the button labeled <i>Continue to Home Access Center</i>, which opens the HAC login screen.<br>
<p>At this point, select $school Public Schools and enter your login and password to access HAC.<br>

<p>If you have any questions or problems with HAC, please call your child's school office.<br>

<p>Sincerely,<br>
<p>$school Public Schools<br>
"
    # If Testing Is Enabled - Email Administrator
    if ($testing) {
     
        $to = $testRecipient
        
        Send-MailMessage -SmtpServer $smtpserver -From $from -To $to -Body $body -BodyAsHtml -Subject $subject -port $smtpport -UseSsl -Credential $cred
        break
    }#End testing


    Send-MailMessage -SmtpServer $smtpserver -From $from -To $to -Body $body -BodyAsHtml -Subject $subject -port $smtpport -UseSsl -Credential $cred

}#Close For-each Loop
$totalSuccess = $countAttempt - $countError
Write-Host "Attempted counts $countAttempt"
Write-Host "contacts with Errors $countError"
Write-host "Successful mails sent $totalSuccess"
}#Close Measure-Command
