# AirDropC1

AirDropC1 is an AppleScript that allows you to quickly AirDrop selected images from Capture One. It automatically exports the selected variants and opens AirDrop to share them.

This script have been tested on Sonoma 14.4.1 and Capture One Pro 16.5.3.1.

## Prerequisites

- macOS Monterey (12.00) or later
- Capture One
- Shortcuts app installed

## Installation

### 1. Install the Script

1. Download the `AirDropC1.applescript` file
2. Copy it to the Capture One Scripts folder:
   ```
   ~/Library/Scripts/Capture One Scripts/
   ```
   If the directory doesn't exist, create it.

### 2. Install the Shortcut

1. Download the `Airdrop Selected.shortcut` file from this repository
2. Double-click the shortcut file to install it in the Shortcuts app
3. When prompted, click "Add Shortcut"

### 3. Set Up the Keyboard Shortcut

1. Open System Settings (or System Preferences)
2. Go to "Keyboard" > "Keyboard Shortcuts" > "App Shortcuts"
3. Click the "+" button to add a new shortcut
4. Choose "Capture One" from the Application dropdown
5. Enter the exact name of the script in the Menu Title field, "AirDropC1"
6. Set your desired keyboard shortcut
   - Recommended: ⌃⌥⌘A (Control + Option + Command + A)

## Usage

1. Open Capture One
2. Select one or more images
3. Use the keyboard shortcut you configured or run the script from the Scripts menu
4. The script will:
   - Export the selected images
   - Open Finder with the exported files selected
   - Launch AirDrop for sharing
   - Return to Capture One when done

## Features

- Automatically creates an export recipe if it doesn't exist
- Exports to JPEG format with optimal settings for sharing
- Uses the "AIRDROPPED_JPEG" subfolder to keep your exports organized
- Quick return to Capture One after sharing
- Handles user cancellation gracefully

### Recipe Customization

Once the AIRDROP recipe is created in Capture One, you can customize it to your needs:
- Modify any export settings
- Add watermarks
- Change process settings
- etc.

As long as you keep the recipe name as "AIRDROP", your customizations will be preserved and the script won't overwrite them. The script only creates the recipe if it doesn't exist.

## Export Settings

The script uses the following export settings:
- Format: JPEG
- Quality: 85
- Color Space: sRGB
- Resolution: 96 PPI
- Long Edge: 1920 pixels
- Sharpening: For Screen

## Troubleshooting

1. **Script not appearing in Capture One**
   - Make sure the script is in the correct folder
   - Restart Capture One

2. **Keyboard shortcut not working**
   - Check if there are any conflicts in System Settings
   - Try setting a different key combination

3. **AirDrop not launching**
   - Verify the "Airdrop Selected" shortcut is properly installed
   - Try running the shortcut directly from the Shortcuts app to test it

## Credits

Created by Yan Senez  

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

GNU GPLv3 in short:
- You can freely use, modify and distribute this software
- If you modify and distribute it, you must:
  - Use the same GNU GPLv3 license
  - Make the source code available
  - State your changes
- No warranty provided
