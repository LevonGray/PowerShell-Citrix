###################################################################################################################################################
### The following script will extract all the required information from Citrix Virtual Apps Published Applications and Active Directory         ###
### and export it to an XML file to be copied into group policy preferences shortcuts for use in a Published Desktop. This needs to be run      ###
### on a server with the Citrix PowerShell modules as well as the Active Directory Remote Server Administration Tools (RSAT) Powershell modules ###
### Created by Levon Gray 2020-02-21                                                                                                            ###
###################################################################################################################################################

#Import required modules and snapins
add-pssnapin Citrix*
import-module activedirectory

#Get  user input for destination file and Delivery group
$Path = Read-Host "Enter Filename and Path e.g c:\temp\shortcuts.xml"
try {
    New-Item $Path -ItemType File -Force -ErrorAction Stop
}
catch {
    Write-Host "Invalid file or path. make sure the path is valid and you have write permission." -ForegroundColor Yellow
    break
}
$Deliverygroup = Read-Host "Enter Citrix Delivery Group to export Published applications from"
try {
    $MainDG = get-brokerdesktopgroup $Deliverygroup -ErrorAction Stop
}
catch {
    Write-Host "Invalid Delivery Group Name. Try one of the following:" -ForegroundColor Yellow
    (Get-BrokerDesktopGroup).name
    break
}

#Get Published application information 
$APPS = Get-BrokerApplication -DesktopGroupUid $MainDG.Uid

# get an XMLTextWriter to create the XML
$XmlWriter = New-Object System.XMl.XmlTextWriter($Path,$Null)

#Root Element Shortcuts
$xmlWriter.WriteStartDocument()
$xmlWriter.WriteStartElement('Shortcuts')
$xmlWriter.WriteAttributeString('disabled','0')
$xmlWriter.WriteAttributeString('CLSID','')
$xmlWriter.WriteAttributeString('Name','Shortcuts')
#create each Shortcut
$changed = (get-date -UFormat "%Y-%m-%d %R:%S")
foreach ($App in $APPS) { $USERS = $App.AssociatedUserFullNames
    $Domain = ($Apps.associatedusernames).split("\")[0]
    foreach ($User in $USERS){
        # Create Shortcut Child Node
        $xmlWriter.WriteStartElement('Shortcut')
        $xmlwriter.WriteAttributeString("clsid","{4F2F7C55-2790-433e-8127-0739D1CFA327}");
        $xmlwriter.WriteAttributeString("name","$($App.applicationname)");
        $xmlwriter.WriteAttributeString("status","$($App.applicationname)");
        $xmlwriter.WriteAttributeString("image","1");
        $xmlwriter.WriteAttributeString("changed","$($changed)");
        $xmlwriter.WriteAttributeString("uid","");
        $xmlwriter.WriteAttributeString("removePolicy","1");
        $xmlwriter.WriteAttributeString("userContext","1");
        $xmlwriter.WriteAttributeString("bypassErrors","1");
            # Create Properties Child Node under Shortcut
            $xmlWriter.WriteStartElement('Properties')
            $xmlwriter.WriteAttributeString("pidl","");
            $xmlwriter.WriteAttributeString("targetType","FILESYSTEM");
            $xmlwriter.WriteAttributeString("action","R");
            $xmlwriter.WriteAttributeString("comment","");
            $xmlwriter.WriteAttributeString("shortcutKey","0");
            $xmlwriter.WriteAttributeString("startIn","$($App.WorkingDirectory)");
            $xmlwriter.WriteAttributeString("arguments","$($App.CommandLineArguments)");
            $xmlwriter.WriteAttributeString("iconIndex","0");
            $xmlwriter.WriteAttributeString("targetPath","$($App.CommandLineExecutable)");
            $xmlwriter.WriteAttributeString("iconPath","$($App.CommandLineExecutable)");
            $xmlwriter.WriteAttributeString("window","");
            $xmlwriter.WriteAttributeString("shortcutPath","%StartMenuDir%\$($App.AdminFolderName)");
            $xmlWriter.WriteEndElement()
            #Filtergroups based on user Filtering in Xenapp Delivery Group
            if ($App.UserFilterEnabled -eq $true){   
            $ADObject = Get-ADObject -filter 'samaccountname -eq $User' -properties * 
            # Create Filters Child Node under Shortcut
            $xmlWriter.WriteStartElement('Filters')
            # Create Filtergroup Child Node under Filters
                $xmlWriter.WriteStartElement('FilterGroup')
                $xmlwriter.WriteAttributeString("bool","AND");
                $xmlwriter.WriteAttributeString("not","0");
                $xmlwriter.WriteAttributeString("name","$($Domain)\$($User)");
                $xmlwriter.WriteAttributeString("sid","$($ADObject.objectsid.value)");
                $xmlwriter.WriteAttributeString("userContext","1");
                $xmlwriter.WriteAttributeString("primaryGroup","0");
                $xmlwriter.WriteAttributeString("localGroup","0");
                #End FilterGroup Node
                $xmlWriter.WriteEndElement()
            #End Filters Node
            $xmlWriter.WriteEndElement()
            }
        #End Shortcut Node
        $xmlWriter.WriteEndElement()
    #End User Loop
    }
#End App Loop
}
#End Shortcuts Node and write document
$xmlWriter.WriteEndElement()
$xmlWriter.WriteEndDocument()
$xmlWriter.Flush()
$xmlWriter.Close()

Write-host "File can be found here: $($Path)"
 
