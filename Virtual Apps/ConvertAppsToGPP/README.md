Created by Levon Gray 2020-02-21  

The following script will extract all the required information from Citrix Virtual Apps Published Applications and Active Directory and export it to an XML file to be copied into group policy preferences shortcuts for use in a Published Desktop. 

<b>This needs to be run on a server with the Citrix PowerShell modules as well as the Active Directory Remote Server Administration Tools (RSAT) Powershell modules </b>

2020-02-25:
	Update script to accept user input for filepath\name and delivery group. Add Error handling for that input (script stops if invalid)

2020-02-24: 
	Initial push of script. 
 

