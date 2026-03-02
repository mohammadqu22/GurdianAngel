# Guardian Angel: Source Code Structure
> **Note:** This file tracks the logic and UI components inside the `/lib` directory.

## 🔄 How to Update
To refresh this map after adding new screens or models, run:
`tree lib /f /a | Out-File -FilePath STRUCTURE.md -Encoding utf8`
----------------------------------------------------------------
|   main.dart
|   
+---core
|       constants.dart
|       routes.dart
|       
+---models
|       emergency.dart
|       step.dart
|       
+---screens
|       emergency_screen.dart
|       home_screen.dart
|       step_screen.dart
|       
+---services
|       protocol_loader.dart
|       tts_service.dart
|       
\---widgets
        emergency_card.dart
        step_widget.dart
        
