Outfile "Arogy_Installer.exe"
InstallDir "$PROGRAMFILES\Arogy"

Section

    SetOutPath $INSTDIR

    # Copy the entire Release folder contents
    File /r "C:\myprojects\integrated projects\git\arogy\arogy\build\windows\x64\runner\Release\*.*"

    # Copy your Flask server (change path if needed)
    File "C:\myprojects\integrated projects\git\arogy\arogy\dist\app.exe"

    # Create a desktop shortcut to the Flutter app
    CreateShortCut "$DESKTOP\Arogy.lnk" "$INSTDIR\arogy.exe"

    # (Optional) Start the Flask server silently
    Exec "$INSTDIR\app.exe"

SectionEnd
