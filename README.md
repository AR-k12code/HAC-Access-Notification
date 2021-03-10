# HAC-Access-Notification
Mail merge using Cognos report to mail Parents HAC access Codes
pre-requisties include:
Setting up automatic generation of HAC access code/information in eschool:</br>
Registration->Utilities-> Generate HAC Credentials </br>
<strong> DO NOT CHECK <i> OVERRIDE EXISTING LOGINS</i> </strong></br>
This can be scheduled to run daily, if you want to run it multiple times a day repeat the run daily-> and set the time.

Send mail through SMTP to all guardians who meet the following criteria</br>
1) Student is active and enrolled</br>
2) Student in Grades 6-SS</br>
3) Valid email address is present on Contact_ID</br>
4) Contact type is Guardian </br>
5) Access code has not been used </br>

Cognos Report(s) can be found at: </br>
<b>SMS Shared Content->Shared Between Districts->_temporarilly shared between districts->Rogers</b>

Two reports are made by default </br>
Uses a parameter to specify a specific building
<b> Mail-Merge-HAC-Access-Building</b>

All active students 6-12</br>
<b>Mail-Merge-HAC-Access-6-12</b></br>

Feel free to copy and modify the reports as you need.

# Setup set guardian information for allow Web Access in Eschool 
<strong>Download definition</strong></br>
Additional SQL:</br>
<p class="tab">join reg</br>
on<br>
reg.student_id=reg_stu_contact.student_id </br>
where reg.current_status='A'</br>
and reg_stu_contact.contact_type='G'</br<
and reg_stu_contact.web_access<>'Y'</p>
![image](https://user-images.githubusercontent.com/72268962/110702727-84fbeb80-81b8-11eb-8360-dea7543722a4.png)
</br>
<strong> HAC upload definition</strong></br>
![image](https://user-images.githubusercontent.com/72268962/110702889-b5dc2080-81b8-11eb-9f05-ea91b54bf1fa.png)

