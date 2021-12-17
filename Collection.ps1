#Setting: Message box #
Add-Type -AssemblyName PresentationCore, PresentationFramework
# Setting: Input box #
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

########### CALL FUNCTION #####################################################################
#Call: Collection.PS1 para1 para2
#Para1: ModuleType(Value[1,2] 1: CollectionNet 2: CollectionNet_Z)
#Para2: MethodType(Value[null,(int)]) null or NOT equal[1;2]: Default 1: Method1 2: Methode2

##### WSHスクリプト指定 ########################################################################
$formWaiting = New-Object system.Windows.Forms.Form
$formInputNumber = New-Object system.Windows.Forms.Form
$formDisplayResult = New-Object System.Windows.Forms.Form
$WSC = new-object -comobject wscript.shell

######################################################################## WSHスクリプト指定 #####

<#--------START Variable--------#>
[Int]$MODULE_TYPE = -1
[Int]$METHOD_TYPE = -1

## Define module constant
[Int] $MODULE_COLLECTION = 1
[Int] $MODULE_COLLECTION_Z = 2

#Shared
$ROOT_COLLECTION_FOLDER = "C:\Collection" 

$TMP_DIR = "$ROOT_COLLECTION_FOLDER\tmp"
$DT_DIR = "$ROOT_COLLECTION_FOLDER\DATA"

$VER = "VER_12.21"
##LogfilePath
$LOG_FILE_PATH = "$ROOT_COLLECTION_FOLDER\dataget.log"

## Module collectionNet
$global:BACK_DIR = "\\js-server\master"
$global:kaku_in = ""
$global:file_name = "list.txt"
$global:lzhn = ""
$global:r = 1
$global:TMP_DRV = ""
$global:slc = ""
$global:extensions_collection_path = "$ROOT_COLLECTION_FOLDER\Collection.ini"
##END collectionNet

####### Setting Module collectionNet_Z#################

############FUNCTION_WLZH############# 
$Get_dir_CM = "CM"
$Get_dir_Z = "Z"
$Get_dir_TB = "TB"
$BACK_DIR1_MAKEDATA = "\\JS-Server\makedata"
$BACK_DIR2_MAKEDATA_CM = "\\JS-Server\makedata\MAKEDATA_CM"
$BACK_DIR3_MAKEDATA_TB = "\\JS-Server\makedata\MAKEDATA_TB"
########END_FUNCTION_WLZH############# 

#Method type 1
$BACK_DIR_Z_F1_REVISED = "\\kc-server\orchestra\Overseas\MASTER\F1_revised" 
$serv_method_1 = "擬似Sドライブ"  
#Method type 2
$BACK_DIR_Z_DATA = "\\kc-server\テロップグレードアップ\DATA"
$serv_method_2 = "テロップグレードアップ"  
#Default method
$BACK_DIR_Z_MAKE_DATA = "\\JS-Server\makedata"  
$global:BACK_DIR1 = "\\JS-Server\makedata"
$global:BACK_DIR2 = "\\JS-Server\makedata\MAKEDATA_CM"
$global:BACK_DIR3 = "\\JS-Server\makedata\MAKEDATA_TB"
$global:serv = "MAKEDATA"
$global:dirflg = "Z"
$global:Get_dir = "Z"
###### END Module collectionNet_Z#################

$UNLHA_EXE_PATH = "C:\CMS5\XINGTOOL\unlha.exe"
    
#Stop thread
$global:isEndThread = $false
$global:isError = $false
$global:IsStartThread = $true

<#-------------END Variable -------------#>

function EXIT_THREAD {
    if ($formWaiting.Visible -eq $true) {
        $formWaiting.Close()
    }
    if ($formDisplayResult.Visible -eq $true) {
        $formDisplayResult.Close()
    }  
    if ($formInputNumber.Visible -eq $true) {
        $formInputNumber.Close()
    }  
}

<#------------ START CHECK INPUT -------------------#>
#Not input parameter
if ($args.Length -eq 0) {
    $WSC.popup("You must input parameter: Para1 Para2 `nPara1: ModuleType(Value[1,2]) (1: CollectionNet 2: CollectionNet_Z)`nPara2: MethodType(Value[Empty,Int]) (Empty or NOT equal[1;2]: Default 1: Method1 2: Methode2)", 0, "`t<< ERROR >>", 0)
	EXIT_THREAD
    exit
}
#Get para1
$MODULE_TYPE = $args[0]

##Input 1 parameter run collectionNet
if ($args.Length -eq 1 -and $MODULE_TYPE -ne $MODULE_COLLECTION_Z) {
    if ($args[0] -ne $MODULE_COLLECTION) {
        $WSC.popup("Run CollectionNet has one parameter [par = 1]", 0, "`t<< ERROR >>", 0)
		EXIT_THREAD
        exit
    }
}

##Input 2 parameters run collectionNet_Z
if ($args.Length -eq 2 ) { 
    if ($MODULE_TYPE -ne $MODULE_COLLECTION_Z) {
        $WSC.popup("Run CollectionNet_Z has tow parameters [par1 = 2 par2 = (null or 1-n)]", 0, "`t<< ERROR >>", 0)
		EXIT_THREAD
        exit
    }
    #Get para2
    $METHOD_TYPE = $args[1]
}

## Check Module Z set variable
if ($MODULE_TYPE -eq $MODULE_COLLECTION_Z) {                            
    if ($METHOD_TYPE -eq 1) {
        $global:BACK_DIR = $BACK_DIR_Z_F1_REVISED
        $global:serv = $serv_method_1     
        $global:Get_dir = ""      
    }
    elseif ($METHOD_TYPE -eq 2) {
        $global:BACK_DIR = $BACK_DIR_Z_DATA
        $global:serv = $serv_method_2
        $global:Get_dir = ""
    }
    else {
        $global:BACK_DIR = $BACK_DIR_Z_MAKE_DATA    
    }
} 
<#------------ END CHECK INPUT ---------------------#>

<#------------START FUNCTIONS ----------#>
<#
:/ ----------------
:/   選曲番号入力  
:/ ----------------
#>


<#
.Load extensions and save extension selected
#>
function GetExtensionSelectedFromFile
{    
    Param( 
        [Parameter(Mandatory = $True)]
        [String] $collectionFilePath
    )

    $filePath = $collectionFilePath
    $fileSelectedPath = $selectedFilePath

    $form = New-Object System.Windows.Forms.Form
    $form.Text = '選択'
    $form.Size = New-Object System.Drawing.Size(350,400)
    $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
    $form.MaximizeBox = $false
    $form.StartPosition = 'CenterScreen'
  
    $OKButton = New-Object System.Windows.Forms.Button
    $OKButton.Location = New-Object System.Drawing.Point(95,330)
    $OKButton.Size = New-Object System.Drawing.Size(75,23)
    $OKButton.Text = 'OK'
    $OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $OKButton
    $form.Controls.Add($OKButton)
  
    $CancelButton = New-Object System.Windows.Forms.Button
    $CancelButton.Location = New-Object System.Drawing.Point(180,330)
    $CancelButton.Size = New-Object System.Drawing.Size(75,23)
    $CancelButton.Text = 'Cancel'
    $CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $CancelButton
    $form.Controls.Add($CancelButton)
  
    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10,5)
    $label.Size = New-Object System.Drawing.Size(280,20)
    $label.Text = '収集対案を選択してください。'
    $form.Controls.Add($label)
  
    $CheckedListBox = New-Object -TypeName System.Windows.Forms.CheckedListBox;
    # Add the CheckedListBox to the Form
    $form.Controls.Add($CheckedListBox);
  
    $CheckedListBox.Location = New-Object System.Drawing.Point(10,25)
    # Widen the CheckedListBox
    $CheckedListBox.Width = 315;
    $CheckedListBox.Height = 300;
    $CheckedListBox.CheckOnClick = $true;
  
    #load extension from file 
    foreach($line in [System.IO.File]::ReadLines($filePath))
    {
      $CheckedListBox.Items.Add($line)| Out-Null 
    }
       
    $form.Topmost = $true
  
    $result = $form.ShowDialog()
    
    if ($result -eq [System.Windows.Forms.DialogResult]::OK)
    {       
        return $CheckedListBox.CheckedItems 
    }
}

<#
.Execute collect by song number
#>
function ExecuteCollection{
    param ( 
        [Parameter(Mandatory = $true, Position = 0)]
        [String]$songNumber     
    )    

    Set-Location $TMP_DIR

    $global:bk_dir = ""
    $global:slc = ""

    $global:slc = $songNumber

    if ($LASTEXITCODE -eq 2 -or $LASTEXITCODE -eq 1) {
        $global:isEndThread = $true                    
        return
    }

    if ($global:slc.Length -eq 1) {
        $global:slc = "0000$global:slc"
    }
    elseif ($global:slc.Length -eq 2) {
        $global:slc = "000$global:slc"
    }
    elseif ($global:slc.Length -eq 3) {
        $global:slc = "00$global:slc"
    }
    elseif ($global:slc.Length -eq 4) {
        $global:slc = "0$global:slc"
    }
    elseif ($global:slc.Length -eq 5) {        
    }
    elseif ($global:slc.Length -eq 6) {       
    }
    else {       
        ##Write to file 
        $contents = "$global:slc,The selection song number is unknown"
        WriteLog $contents         
        return
    }

    $global:bk_dir = $global:slc
    if ($global:slc.Length -eq 255) {      
        $contents = "$global:slc,The selection song number is unknown"
        WriteLog $contents 
      
        return
    }
    
    ##格納ディレクトリ指定  
    $global:bk_dir = [String]([Math]::floor(([int]$global:slc - 1) / 100 + 1) * 100)

    if ($global:bk_dir.Length -eq 3) {
        $global:bk_dir = "00$global:bk_dir"
    }
    elseif ($global:bk_dir.Length -eq 4) {
        $global:bk_dir = "0$global:bk_dir"
    }
    elseif ($global:bk_dir.Length -eq 5) {      
    }
    elseif ($global:bk_dir.Length -eq 6) {      
        $re = $global:bk_dir.Substring(0, 1)
        switch ($re) {
            1 {
                $re = "_10\"
                break
            }
            2 {
                $re = "_20\"
                break
            }
            3 {
                $re = "_30\"
                break
            }
            4 {
                $re = "_40\"
                break
            }
            5 {
                $re = "_50\"
                break
            }
            6 {
                $re = "_60\"
                break
            }
            7 {
                $re = "_70\"
                break
            }
            8 {
                $re = "_80\"
                break
            }
            9 {
                $re = "_90\"
                break
            }
            Default {
                break
            }           
        }

        $global:bk_dir = "$re$global:bk_dir"
    }
    else {            
        $contents = "$global:slc,The selection song number is unknown"
        WriteLog $contents 
        return
    }
  
    #Copy file to temprary directory
    CopyFilesToTemporaryDirectory
}

<#
:/ ----------------------------------------------
:/   ファイルをテンポラリーディレクトリへコピー  
:/ ----------------------------------------------
#>
function CopyFilesToTemporaryDirectory {
       
    if ($global:kaku_in -eq "R88") {
        $global:lzhn = "8RC"
        $global:kaku = "R88"
        WLZH    
    }    
    elseif ($global:kaku_in -eq "PDF") {
        $global:lzhn = "PDF"
        $global:kaku = "PDF"
        WLZH    
    }
    elseif ($global:kaku_in -eq "CSV") {
        $global:lzhn = "PDF"
        $global:kaku = "CSV"
        WLZH    
    } 
    elseif ($global:kaku_in -eq "FMD") {
        $global:lzhn = "FMD"
        $global:kaku = "FMD"
        WLZH    
    }    
    elseif ($global:kaku_in -eq "JD5") {
        $global:lzhn = "5WK"
        $global:kaku = "JD5"
        WLZH    
    } 
    elseif ($global:kaku_in -eq "PLA") {
        $global:lzhn = "PLA"
        $global:kaku = "PLA"
        WLZH    
    }
    elseif ($global:kaku_in -eq "DDA") {
        $global:lzhn = "AWK"
        $global:kaku = "DDA"
        WLZH    
    }
    elseif ($global:kaku_in -eq "1DT") {
        $global:lzhn = "AWK"
        $global:kaku = "1DT"
        WLZH    
    }
    elseif ($global:kaku_in -eq "BMA") {
        $global:lzhn = "AWK"
        $global:kaku = "BMA"
        WLZH    
    }
    elseif ($global:kaku_in -eq "MP2") {       
        $global:kaku = "MP2"
        W25    
    }
    elseif ($global:kaku_in -eq "RAA") {       
        $global:lzhn = "AWK"
        $global:kaku = "RAA"
        WLZH    
    }
    elseif ($global:kaku_in -eq "MPT") {       
        $global:lzhn = "AWK"
        $global:kaku = "MPT"
        WLZH    
    }
    elseif ($global:kaku_in -eq "RBB") {       
        $global:lzhn = "AWK"
        $global:kaku = "RBB"
        WLZH    
    }
    elseif ($global:kaku_in -eq "WAV") {       
        $global:lzhn = "WAV"
        $global:kaku = "WAV"
        WLZH    
    }
    elseif ($global:kaku_in -eq "PLB") {       
        $global:lzhn = "PLB"
        $global:kaku = "PLB"
        WLZH    
    }
    elseif ($global:kaku_in -eq "DDC") {       
        $global:lzhn = "CWK"
        $global:kaku = "DDC"
        WLZH    
    }
    elseif ($global:kaku_in -eq "RCC") {       
        $global:lzhn = "CWK"
        $global:kaku = "RCC"
        WLZH    
    }
    elseif ($global:kaku_in -eq "SAI") {       
        $global:lzhn = "CWK"
        $global:kaku = "SAI"
        WLZH    
    }   
    elseif ($global:kaku_in -eq "PLC") {       
        $global:lzhn = "PLC"
        $global:kaku = "PLC"
        WLZH    
    }
    elseif ($global:kaku_in -eq "JD6") {       
        $global:lzhn = "9WK"
        $global:kaku = "JD6"
        WLZH    
    }
    elseif ($global:kaku_in -eq "PL9") {       
        $global:lzhn = "9PL"
        $global:kaku = "PL9"
        WLZH    
    }   
    elseif ($global:kaku_in -eq "DBN") {       
        $global:kaku = "DBN"
        W25     
    }
    elseif ($global:kaku_in -eq "DDB") {       
        $global:kaku = "DDB"
        W25     
    }    
    elseif ($global:kaku_in -eq "BMP") {       
        $global:kaku = "BMP"
        W25     
    }
    elseif ($global:kaku_in -eq "PTN") {       
        $global:kaku = "PTN"
        W25     
    }
    elseif ($global:kaku_in -eq "PLD") {       
        $global:lzhn = "PLD"
        $global:kaku = "PLD"
        WLZH     
    }
    elseif ($global:kaku_in -eq "PLE") {    
        $global:lzhn = "PLE"   
        $global:kaku = "PLE"
        WLZH     
    }
    elseif ($global:kaku_in -eq "REE") {    
        $global:lzhn = "EWK"   
        $global:kaku = "REE"
        WLZH     
    }
    elseif ($global:kaku_in -eq "DDE") {    
        $global:lzhn = "EWK"   
        $global:kaku = "DDE"
        WLZH     
    }
    elseif ($global:kaku_in -eq "RDD") {    
        $global:lzhn = "CWK"   
        $global:kaku = "RDD"
        WLZH     
    }
    elseif ($global:kaku_in -eq "JD7") { 
        $global:lzhn = "7WK"   
        $global:kaku = "JD7"
        WLZH     
    }
    elseif ($global:kaku_in -eq "MID") {    
        $global:lzhn = "CMD"   
        $global:kaku = "MID"
        WLZH     
    }
    elseif ($global:kaku_in -eq "MSY") {    
        $global:lzhn = "MSY"   
        $global:kaku = "MSY"
        WLZH     
    }
    elseif ($global:kaku_in -eq "MTJ") {    
        $global:lzhn = "UGA"   
        $global:kaku = "MTJ"
        WLZH     
    }
    elseif ($global:kaku_in -eq "UMID") {    
        $global:lzhn = "UGA"   
        $global:kaku = "MID"
        WLZH     
    }
    elseif ($global:kaku_in -eq "ETIM") {    
        $global:lzhn = "FWK"   
        $global:kaku = "ETIM"
        WLZH     
    }
    elseif ($global:kaku_in -eq "HAC") {    
        $global:lzhn = "FWK"   
        $global:kaku = "HAC"
        WLZH     
    }
    elseif ($global:kaku_in -eq "PLF") {    
        $global:lzhn = "PLF"   
        $global:kaku = "PLF"
        WLZH     
    }
    elseif ($global:kaku_in -eq "R01") {    
        $global:lzhn = "FWK"   
        $global:kaku = "MID"
        WLZH     
    }
    elseif ($global:kaku_in -eq "DBM") {    
        $global:lzhn = "EWK"   
        $global:kaku = "DBM"
        WLZH     
    }
    elseif ($global:kaku_in -eq "PLG") {    
        $global:lzhn = "PLG"   
        $global:kaku = "PLG"
        WLZH     
    }
    elseif ($global:kaku_in -eq "R02") {    
        $global:lzhn = "GWK"   
        $global:kaku = "MID"
        WLZH     
    }
    elseif ($global:kaku_in -eq "RB2") {    
        $global:lzhn = "GWK"   
        $global:kaku = "MID"
        WLZH     
    }
    elseif ($global:kaku_in -eq "RN2") {    
        $global:lzhn = "GWK"   
        $global:kaku = "MID"
        WLZH     
    }
    elseif ($global:kaku_in -eq "R02_B") {    
        $global:lzhn = "GWK"   
        $global:kaku = "MID"
        WLZH     
    }
    elseif ($global:kaku_in -eq "RB2_B") {    
        $global:lzhn = "GWK"   
        $global:kaku = "MID"
        WLZH     
    }
    elseif ($global:kaku_in -eq "AAC") {    
        $global:lzhn = "GWK"   
        $global:kaku = "AAC"
        WLZH     
    }
    elseif ($global:kaku_in -eq "AVE") {    
        $global:lzhn = "GWK"   
        $global:kaku = "AVE"
        WLZH     
    }
    #new collection
    elseif ($global:kaku_in -eq "RFB"){
        $global:lzhn = "FWK"   
        $global:kaku = "MID"
        WLZH 
    }elseif ($global:kaku_in -eq "RFN"){
        $global:lzhn = "FWK"   
        $global:kaku = "MID"
        WLZH 
    }elseif ($global:kaku_in -eq "DLF"){
        $global:lzhn = "7WK"   
        $global:kaku = "DLF"
        WLZH 
    }elseif ($global:kaku_in -eq "DLG"){
        $global:lzhn = "7WK"   
        $global:kaku = "DLG"
        WLZH 
    }elseif ($global:kaku_in -eq "KENTTL"){
        $global:kaku = "TXT"
        W25 
    }elseif ($global:kaku_in -eq "WTXT"){
        $global:kaku = "TXT"
        W25 
    }elseif ($global:kaku_in -eq "ATXT"){
        $global:kaku = "TXT"
        W25 
    }
}

<#WLZH#>
function WLZH {
    ## Check module collectionnet_Z
    if ($MODULE_TYPE -eq $MODULE_COLLECTION_Z) {
        if ($global:dirflg -eq "Z") {
            if ((CheckExistPath("$global:BACK_DIR1\$global:bk_dir\$global:lzhn$global:slc.lzh")) -eq $true) {
                $global:BACK_DIR = $BACK_DIR1_MAKEDATA
                $global:Get_dir = $Get_dir_Z
            }
            elseif ((CheckExistPath("$global:BACK_DIR2\$global:bk_dir\$global:lzhn$global:slc.lzh")) -eq $true) {
                $global:BACK_DIR = $BACK_DIR2_MAKEDATA_CM
                $global:Get_dir = $Get_dir_CM
            }
            elseif ((CheckExistPath("$global:BACK_DIR3\$global:bk_dir\$global:lzhn$global:slc.lzh")) -eq $true) {
                $global:BACK_DIR = $BACK_DIR3_MAKEDATA_TB
                $global:Get_dir = $Get_dir_TB
            }
        }
    }

    if ((CheckExistPath("$global:BACK_DIR\$global:bk_dir\$global:lzhn$global:slc.lzh")) -eq $true) {
        Copy ("$global:BACK_DIR\$global:bk_dir\$global:lzhn$global:slc.lzh") ("$TMP_DIR")
    }
    else {  
        $contents = "$global:slc,$global:lzhn's LZH does not exist"        
        WriteLog $contents 
        return
    }

    $exeFilePath = $UNLHA_EXE_PATH
    $param = "e -m1 $global:lzhn$global:slc.lzh *.*"
    RunExE $exeFilePath $param

    if ($global:kaku -eq "MPT") {
        if ( (CheckExistPath("$global:BACK_DIR\$global:bk_dir\EWK$global:slc.lzh")) -eq $true) {
            Copy ("$global:BACK_DIR\$global:bk_dir\EWK$global:slc.lzh") ("$TMP_DIR")

            $exeFilePath = $UNLHA_EXE_PATH
            $param = " e -m1 EWK$global:slc.lzh *.*"
            RunExE $exeFilePath $param
        }

        if ( (CheckExistPath("$global:BACK_DIR\$global:bk_dir\FWK$global:slc.lzh")) -eq $true) {
            Copy ("$global:BACK_DIR\$global:bk_dir\FWK$global:slc.lzh") ("$TMP_DIR")

            $exeFilePath = $UNLHA_EXE_PATH
            $param = " e -m1 FWK$global:slc.lzh *.*"
            RunExE $exeFilePath $param
        }

        if ( (CheckExistPath("$global:BACK_DIR\$global:bk_dir\GWK$global:slc.lzh")) -eq $true) {
            Copy ("$global:BACK_DIR\$global:bk_dir\GWK$global:slc.lzh") ("$TMP_DIR")

            $exeFilePath = $UNLHA_EXE_PATH
            $param = " e -m1 GWK$global:slc.lzh *.*"
            RunExE $exeFilePath $param
        }
    }

    DTCP  
}

<# W25 #>
function W25 {
    if ((CheckExistPath("$global:BACK_DIR\$global:bk_dir\WRK$global:slc.lzh")) -eq $true) {
        Copy ("$global:BACK_DIR\$global:bk_dir\WRK$global:slc.lzh") ("$TMP_DIR")

        $exeFilePath = $UNLHA_EXE_PATH
        $param = " e -m1 WRK$global:slc.lzh *.*"
        RunExE $exeFilePath $param
    }

    if ((CheckExistPath("$global:BACK_DIR\$global:bk_dir\2WK$global:slc.lzh")) -eq $true) {
        Copy ("$global:BACK_DIR\$global:bk_dir\2WK$global:slc.lzh") ("$TMP_DIR")

        $exeFilePath = $UNLHA_EXE_PATH
        $param = " e -m1 2WK$global:slc.lzh *.*"
        RunExE $exeFilePath $param
    }

    if ((CheckExistPath("$global:BACK_DIR\$global:bk_dir\5WK$global:slc.lzh")) -eq $true) {
        Copy ("$global:BACK_DIR\$global:bk_dir\5WK$global:slc.lzh") ("$TMP_DIR")

        $exeFilePath = $UNLHA_EXE_PATH
        $param = " e -m1 5WK$global:slc.lzh *.*"
        RunExE $exeFilePath $param
    }

    if ((CheckExistPath("$global:BACK_DIR\$global:bk_dir\AWK$global:slc.lzh")) -eq $true) {
        Copy ("$global:BACK_DIR\$global:bk_dir\AWK$global:slc.lzh") ("$TMP_DIR")

        $exeFilePath = $UNLHA_EXE_PATH
        $param = " e -m1 AWK$global:slc.lzh *.*"
        RunExE $exeFilePath $param
    }

    if ((CheckExistPath("$global:BACK_DIR\$global:bk_dir\CWK$global:slc.lzh")) -eq $true) {
        Copy ("$global:BACK_DIR\$global:bk_dir\CWK$global:slc.lzh") ("$TMP_DIR")

        $exeFilePath = $UNLHA_EXE_PATH
        $param = " e -m1 CWK$global:slc.lzh *.*"
        RunExE $exeFilePath $param
    }

    if ((CheckExistPath("$global:BACK_DIR\$global:bk_dir\EWK$global:slc.lzh")) -eq $true) {
        Copy ("$global:BACK_DIR\$global:bk_dir\EWK$global:slc.lzh") ("$TMP_DIR")

        $exeFilePath = $UNLHA_EXE_PATH
        $param = " e -m1 EWK$global:slc.lzh *.*"
        RunExE $exeFilePath $param
    }

    if ((CheckExistPath("$global:BACK_DIR\$global:bk_dir\7WK$global:slc.lzh")) -eq $true) {
        Copy ("$global:BACK_DIR\$global:bk_dir\7WK$global:slc.lzh") ("$TMP_DIR")

        $exeFilePath = $UNLHA_EXE_PATH
        $param = " e -m1 7WK$global:slc.lzh *.*"
        RunExE $exeFilePath $param
    }

    if ((CheckExistPath("$global:BACK_DIR\$global:bk_dir\FWK$global:slc.lzh")) -eq $true) {
        Copy ("$global:BACK_DIR\$global:bk_dir\FWK$global:slc.lzh") ("$TMP_DIR")

        $exeFilePath = $UNLHA_EXE_PATH
        $param = " e -m1 FWK$global:slc.lzh *.*"
        RunExE $exeFilePath $param
    }

    if ((CheckExistPath("$global:BACK_DIR\$global:bk_dir\GWK$global:slc.lzh")) -eq $true) {
        Copy ("$global:BACK_DIR\$global:bk_dir\GWK$global:slc.lzh") ("$TMP_DIR")

        $exeFilePath = $UNLHA_EXE_PATH
        $param = " e -m1 GWK$global:slc.lzh *.*"
        RunExE $exeFilePath $param
    }
  
    if ((CheckExistPath("$TMP_DIR\???$global:slc.lzh")) -eq $false) { 
        $contents = "$global:slc,LZH does not exist"
        WriteLog $contents       
        return
    }

    DTCP
}


<#DTCP#>
function DTCP {    
    #Default extension to collect
     $extension ="*.$global:kaku"
    
    if($global:kaku_in -eq "R01" -or $global:kaku_in -eq "R02" -or $global:kaku_in -eq "RB2" -or $global:kaku_in -eq "RN2" -or $global:kaku_in -eq "RFB" -or $global:kaku_in -eq "RFN"){        
        $extension ="*W_$global:kaku_in.$global:kaku"
    }elseif ($global:kaku_in -eq "KENTTL"){
        $extension ="*_$global:kaku_in.$global:kaku"
    }elseif ($global:kaku_in -eq "WTXT"){
        $extension ="*W.$global:kaku"
    }elseif ($global:kaku_in -eq "ATXT"){
        $extension ="*A.$global:kaku"
    }
    
    if ((CountFileExtention("$TMP_DIR") ($extension)) -gt 0) {

        Copy ("$TMP_DIR\$extension") ("$DT_DIR")

        if ($? -eq $true) { 
            $contents = "$global:slc,$global:kaku_in,GET"
            if ($MODULE_TYPE -eq $MODULE_COLLECTION_Z) {
                $contents = "$global:slc,$global:kaku_in,GET,$global:Get_dir"
            }              
        }
        else {            
            $contents = "$global:slc,$global:kaku_in,Copy failure"
        }
    }
    else {
        $contents = "$global:slc,$global:kaku_in does not exist"              
    }
  
    WriteLog $contents  
}

<#Final#>
function Final {    
    #Pause   
    $global:BACK_DIR = ""
    $global:slc = ""  
}

<#End function#>
function TheEnd { 
    #Pause
    if ((CheckExistPath($LOG_FILE_PATH)) -eq $true) {       
        $contents = ReadAllText($LOG_FILE_PATH) 
        DisplayText "Result" $contents
    } 

    if ($formWaiting.Visible -eq $true) {
        $formWaiting.Close()
    }  
    
    exit
}

<#--------------END FUNCTIONS ----------#>

<#-------------START Utils -------------#>
function ReadAllText {
    Param(
        [Parameter(Mandatory = $True)]
        [String] $filePath
    )
    
    $contents = ""
    if ((CheckExistPath($filePath)) -eq $True) {          
        $newstreamreader = New-Object System.IO.StreamReader($filePath)      
        while ($null -ne ($readeachline = $newstreamreader.ReadLine())) {           
            $contents += "$readeachline`n"
        }
        $newstreamreader.Dispose()
    }

    return $contents 
}

<#Count file in folder#>
function CountFileExtention {
    Param(
        [Parameter(Mandatory = $True)]
        [String] $folderPath,
        [Parameter(Mandatory = $True)]
        [String] $extention
    )
    
    return (Get-ChildItem $folderPath -Recurse -Filter "$extention").Count
}

<#Copy data#>
function Copy {
    Param(
        [Parameter(Mandatory = $True)]
        [String] $filePathSource,
        [Parameter(Mandatory = $True)]
        [String] $filePathDes
    )

    if ($global:isEndThread -eq $True) {        
        return
    }

    try {
        Copy-Item -Path $filePathSource -Destination $filePathDes  -Recurse
    }
    catch {
        Write-Host $Error[0].Exception.Message
    }    
}

<#
Delete file (folderpath\*.*)
Delete folder (folderPath\)
#>
function DeleteFileOrFolder {
    Param(
        [Parameter(Mandatory = $True)]
        [String] $filePath
    )
    if ((CheckExistPath($filePath)) -eq $True) {
        Remove-Item -Path $filePath 
    }   
}

#Write log
function WriteLog {
    param (      
        [Parameter(Mandatory = $True)]
        [String] $contents
    )
    
    WriteToFile $LOG_FILE_PATH $contents
}

<#Save data to file#>
function WriteToFile {
    Param(
        [Parameter(Mandatory = $True)]
        [String] $filePath,
        [Parameter(Mandatory = $True)]
        [String] $contents
    )

    if ((CheckExistPath($filePath)) -eq $True) {
        Add-Content -Path $filePath -Value $contents -Force
    }
    else {
        Set-Content -Path $filePath -Value $contents
    }   
}


<#Run exe#>
function RunExE {
    Param(
        [Parameter(Mandatory = $True)]
        [String] $fileExe,
        [Parameter(Mandatory = $True)]
        [String[]] $arg
    )
    if ((CheckExistPath($fileExe)) -eq $True) {
        $args = [system.String]::Join(" ", $arg)    
            
        cmd.exe /c $fileExe $args
    }
}


<#Check file or folder exist#>
function CheckExistPath {
    Param(
        [Parameter(Mandatory = $True)]
        [String] $checkPath
    )
   
    if ([String]::IsNullOrWhiteSpace($checkPath)) {
        ShowMessageError "ETTT" "emtystring"
        return $false
    }
    if (-not (Test-Path -Path $checkPath)) {
        return $false
    }
    else {      
        return $True
    }
}

<#Form input number#>
function InputSongNumber {
    Param(       
        [String] $lblText,
        [String] $defaultText = ""
    )  

    $formInputNumber = New-Object System.Windows.Forms.Form
    $formInputNumber.Text = 'Input Data'
    $formInputNumber.Size = New-Object System.Drawing.Size(570, 300)
    $formInputNumber.StartPosition = 'CenterScreen'
    $formInputNumber.MaximizeBox = $False
    $formInputNumber.FormBorderStyle = 'FixedDialog'

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Font = New-Object System.Drawing.Font("Lucida Console", 12, [System.Drawing.FontStyle]::Regular)
    $okButton.Location = New-Object System.Drawing.Point(120, 155)
    $okButton.Size = New-Object System.Drawing.Size(102, 40)
    $okButton.Text = 'OK'   
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $formInputNumber.AcceptButton = $okButton
    $formInputNumber.Controls.Add($okButton)

    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Font = New-Object System.Drawing.Font("Lucida Console", 12, [System.Drawing.FontStyle]::Regular)
    $cancelButton.Location = New-Object System.Drawing.Point(270, 155)
    $cancelButton.Size = New-Object System.Drawing.Size(150, 40)
    $cancelButton.Text = 'Cancel'   
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel    
    $formInputNumber.Controls.Add($cancelButton)

    $label = New-Object System.Windows.Forms.Label     
    $label.Font = New-Object System.Drawing.Font("Lucida Console", 12, [System.Drawing.FontStyle]::Regular)   
    $label.Location = New-Object System.Drawing.Point(20, 28)
    $label.Size = New-Object System.Drawing.Size(600, 30)
    $label.Text = $lblText
    $formInputNumber.Controls.Add($label)

    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Font = New-Object System.Drawing.Font("Lucida Console", 20, [System.Drawing.FontStyle]::Regular)
    $textBox.Multiline = $true   
    $textBox.Location = New-Object System.Drawing.Point(25, 75)
    $textBox.Size = New-Object System.Drawing.Size(500, 37)
    $textBox.Text = $defaultText    
    $formInputNumber.Controls.Add($textBox)

    $formInputNumber.Topmost = $true

    $formInputNumber.Add_Shown( { $formInputNumber.Activate() })
    $formInputNumber.Add_Shown( { $textBox.Select() })
    $result = $formInputNumber.ShowDialog()
    $x = ""
    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        $x = $textBox.Text       
    }

    return $x
}

#DisplayText
function DisplayText {
    Param(  
        [String] $titleText,
        [String] $defaultText = ""
    )  
        
    $formDisplayResult.Text = $titleText
    $formDisplayResult.Size = New-Object System.Drawing.Size(500, 400)
    $formDisplayResult.StartPosition = 'CenterScreen'
    $formDisplayResult.MaximizeBox = $False
    $formDisplayResult.FormBorderStyle = 'FixedDialog'

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(397, 333)
    $okButton.Size = New-Object System.Drawing.Size(75, 23)
    $okButton.Text = 'OK'   
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
   
    $formDisplayResult.AcceptButton = $okButton
    $formDisplayResult.Controls.Add($okButton)

    $textBox = New-Object System.Windows.Forms.RichTextBox
    $textBox.Location = New-Object System.Drawing.Point(12, 12)
    $textBox.Size = New-Object System.Drawing.Size(460, 315)
    $textBox.Multiline = $true
    $textBox.AppendText($defaultText)
    $formDisplayResult.Controls.Add($textBox)

    $formDisplayResult.Topmost = $false

    $formDisplayResult.Add_Shown( { $textBox.Select() })
    $formDisplayResult.ShowDialog()     
}

<#Display message error#>
function  ShowMessageError {
    param ( 
        [String]$msgTitle,   
        [String]$msgBody      
    ) 
    $msgButton = "OK"
    $msgIcon = "Error"
    $WSC.popup(" $msgBody", 0, "`t<< $msgTitle >>", 0)
    #ShowMessage $msgTitle $msgBody $msgButton $msgIcon  
}

<#-------------END Utils -------------#>

<#
.NOTES
Running collection
#>
function START_COLLECTION {

    if ((CheckExistPath($global:extensions_collection_path)) -eq $false) {       
        ShowMessageError "ERROR" "File collection path:$global:extensions_collection_path not exist!!!"
        EXIT_THREAD
        exit
    }

    $global:file_name = InputSongNumber("Please input the file name (.txt) `nto be a list Ex: list.txt") $global:file_name
    
    $filepath = "$ROOT_COLLECTION_FOLDER\$global:file_name"

    if ((CheckExistPath($filePath)) -eq $false) {       
        ShowMessageError "ERROR" "File collection extension selected path:$filepath not exist!!!"
        EXIT_THREAD
        exit
    }

    if ($global:file_name.Length -eq 1 -or [string]::IsNullOrWhiteSpace($global:file_name) -eq $true) {  
        ShowMessageError "ERROR" "File name is empty!" 
        EXIT_THREAD
        exit
    }
        
    #Delete log file 
    DeleteFileOrFolder($LOG_FILE_PATH)    

    #Crete Log file    
    if ($MODULE_TYPE -eq $MODULE_COLLECTION) {
        $contents = "Song selection Number, Extension, Result"
    }
    elseif ($MODULE_TYPE -eq $MODULE_COLLECTION_Z) {
        $contents = "Song selection Number, Extension, Result, Location"
    }
    
    WriteLog $contents 
     #Get extension
    $extensions = GetExtensionSelectedFromFile $global:extensions_collection_path 
    
    $reader = New-Object IO.StreamReader $filepath       
    $global:isError = $false     

    while ($null -ne ($data = $reader.ReadLine())) {  
        if ($global:isEndThread -eq $true -or $global:isError -eq $true) {    
            break
        }  
        
        #Reset folder collect data by extension
        DeleteFileOrFolder("$TMP_DIR\*.*") 

        foreach ($extension in $extensions) {      

            if ($global:isEndThread -eq $true) {    
                break
            }  

            $global:kaku_in = [String]$extension        
            if ($global:kaku_in.Length -eq 1 -or [string]::IsNullOrWhiteSpace($global:kaku_in) -eq $true) {                      
                Final           
                continue
            }
            try 
            {
                ExecuteCollection $data
            }
            catch 
            {     

            }        
        }
    }

    Final
          
    TheEnd
}

function WAITING {
    $contents = "CPYDTNET  [$VER]  for Windows2000 `nData is getting from $global:serv.`nPlease Wait..."

    if ($MODULE_TYPE -eq $MODULE_COLLECTION_Z) {
        $contents = "CPYDTNET_Z  [$VER]  for Windows7 `nGetting data from $global:serv`nPlease Wait..."
    }
  
    $Label = New-Object System.Windows.Forms.Label
    $formWaiting.Text = "WAITTING";
    $formWaiting.MaximizeBox = $False
    $formWaiting.FormBorderStyle = 'FixedDialog'
    $formWaiting.Size = New-Object System.Drawing.Size(440, 240)
    $formWaiting.Controls.Add($Label)
    $formWaiting.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen;
    $Label.Text = $contents
    $label.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 10, [System.Drawing.FontStyle]::Regular)   
    $label.Location = New-Object System.Drawing.Point(12, 35)
    $label.Size = New-Object System.Drawing.Size(440, 60)     

    #stop button
    $stopButton = New-Object System.Windows.Forms.Button
    $stopButton.Location = New-Object System.Drawing.Point(324, 157)
    $stopButton.Size = New-Object System.Drawing.Size(88, 32)
    $stopButton.Text = 'STOP'   

    $formWaiting.Controls.Add($stopButton)
    $formWaiting.Add_Shown( { $formWaiting.Activate() })
    
    $stopButton.Add_Click( {  
            if ($formInputNumber.Visible -eq $true) {
                $formInputNumber.Close()
            }  
            if ($formDisplayResult.Visible -eq $true) {
                $formDisplayResult.Close()
            }   

            $global:isEndThread = $true        
        })     

    $formWaiting.Add_Closing( {
            if ($formInputNumber.Visible -eq $true) {
                $formInputNumber.Close()
            }  
            if ($formDisplayResult.Visible -eq $true) {
                $formDisplayResult.Close()
            }                     
        })
  
    $rs = [Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace()
    $rs.Open()

    $rs.SessionStateProxy.SetVariable("formWaiting", $formWaiting)

    $p = $rs.CreatePipeline( { [void] $formWaiting.ShowDialog() })

    $p.Input.Close()
    $p.InvokeAsync()

    Start-Sleep 1
  
    START_COLLECTION
    
    if ($formWaiting.Visible -eq $true) {
        $formWaiting.Close()   
    } 

    $rs.Close()   
}
####################START_PROGRAM########################
WAITING
####################END_PROGRAM########################