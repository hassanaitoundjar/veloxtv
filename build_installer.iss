#define AppName "IPTV Player Premium"
#define AppVersion "1.0.0"
#define AppPublisher "VeloxTV"
#define AppExeName "player_premium.exe"
#define ReleaseFolder "build\windows\x64\runner\Release"

[Setup]
AppId={{45F6E9D2-8A3B-4C1E-9D2A-7F3B1A2C4D5E}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
AppPublisherURL=https://veloxtv.com
AppSupportURL=https://veloxtv.com/support
AppUpdatesURL=https://veloxtv.com/download
DefaultDirName={autopf}\IPTV Player
DefaultGroupName={#AppName}
OutputDir=.\Output
OutputBaseFilename=IPTV_Player_Premium_Setup
Compression=lzma
SolidCompression=yes
ArchitecturesInstallIn64BitMode=x64
ArchitecturesAllowed=x64
PrivilegesRequired=admin
AlwaysShowDirOnReadyPage=yes
AlwaysShowGroupOnReadyPage=yes
ShowTasksTreeLines=yes
WizardStyle=modern
LicenseFile=LICENSE.md

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#ReleaseFolder}\{#AppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#ReleaseFolder}\*.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#ReleaseFolder}\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#AppName}"; Filename: "{app}\{#AppExeName}"; IconFilename: "{app}\{#AppExeName}"; WorkingDir: "{app}"
Name: "{group}\Uninstall {#AppName}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExeName}"; IconFilename: "{app}\{#AppExeName}"; WorkingDir: "{app}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#AppExeName}"; WorkingDir: "{app}"; Flags: nowait postinstall skipifsilent; Description: "{cm:LaunchProgram,{#StringChange(AppName, '&', '&&')}}"

[UninstallRun]
Filename: "{app}\{#AppExeName}"; Parameters: "--shutdown"; Flags: runhidden

[Code]
procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
    begin
      { Add any post-installation tasks here }
      MsgBox('IPTV Player Premium has been installed successfully!', mbInformation, MB_OK);
    end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usPostUninstall then
    begin
      { Add any post-uninstallation cleanup here }
      MsgBox('IPTV Player Premium has been uninstalled.', mbInformation, MB_OK);
    end;
end;
