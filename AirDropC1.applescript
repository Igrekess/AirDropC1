------------------------------------------
-- AirDropC1 V 0.2.1
-- Created by: Yan Senez
------------------------------------------

------------------------------------------
-- PREREQUISITES
------------------------------------------
-- 1. Install the "Airdrop Selected" shortcut from the Shortcuts app
-- 2. Make sure the shortcut is properly configured and working
-- Note: The script won't work without this shortcut installed
------------------------------------------

use AppleScript version "2.7" -- Monterey (12.0) or later
use framework "Foundation"
use scripting additions

-- Constants
property recipeName : "AIRDROP"
property outputSubFolder : "AIRDROPED_JPEG"
property jpegQuality : 85
property longEdgeSize : 1920

-- Global variables (kept for compatibility)
global selecVars, currentDocument, outputFiles, rootFolder, fullList, AirDropRecipe

set outputFiles to {}
set fullList to ""

--···············································································································
-- PROCESS
--···············································································································
try
	getJpeg()
	ProcessJpeg()
	AirdropFilesWithShortcut()
on error errMsg number errNum
	if errNum is not -128 then
		display dialog "Error " & errNum & ": " & errMsg buttons {"OK"} default button "OK" with title "AirDrop C1" with icon caution
	end if
end try

--···············································································································
-- FUNCTIONS
--···············································································································

on getJpeg()
	tell application "Capture One"
		set rootFolder to folder of current document
		set selecVars to (get selected variants)
		set currentDocument to current document
		
		if selecVars is {} then
			display dialog "No Variants selected!" buttons {"Cancel"} default button "Cancel" with icon stop with title "ERROR"
			error number -128
		end if
		
		tell currentDocument
			try
				set AirDropRecipe to recipe recipeName
				set AirDropRecipe's root folder type to output location
				set AirDropRecipe's output sub folder to outputSubFolder
				
			on error
				-- Create AIRDROP recipe if not exist
				set AirDropRecipe to make new recipe with properties {name:recipeName, output format:JPEG, JPEG quality:jpegQuality, color profile:"sRGB Color Space Profile", pixels per inch:96, export crop method:respect, ignore crop:false, include annotations:true, include Camera Metadata:true, include copyright:true, root folder type:output location, output sub folder:outputSubFolder, sharpening:for screen, sharpening amount:60.0, sharpening distance:100.0, sharpening distance type:percent of diagonal, sharpening radius:0.600000023842, sharpening threshold:0.0, thumbnails:false}
				tell AirDropRecipe to set {its enabled, its scaling method, its scaling unit, its primary scaling value} to {false, Long_Edge, pixels, longEdgeSize}
			end try
		end tell
		
		repeat with i in selecVars
			set fullList to fullList & (name of i) & ".jpg" & return
		end repeat
	end tell
end getJpeg

on ProcessJpeg()
	tell application "Capture One"
		tell currentDocument to set rflAlias to its output
		set rfl to POSIX path of rflAlias
		set rfl to rfl & AirDropRecipe's output sub folder & "/"
		
		repeat with v in selecVars
			set outputFileName to rfl & v's name & ".jpg"
			
			try
				tell application "System Events" to if (exists file outputFileName) then delete file outputFileName
				set outputResult to process v recipe recipeName
			on error errMsg number errNum
				if errNum is -43 then -- invalid output location
					set AirDropRecipe's root folder location to file rootFolderLocation
					set outputResult to process v recipe recipeName
				else
					error errMsg number errNum
				end if
			end try
			
			copy outputFileName to end of outputFiles
		end repeat
	end tell
	
	tell application "System Events"
		repeat with f in outputFiles
			repeat while not (exists file f)
				delay 0.1 -- Reduced delay time for better performance if your computer is fast enough
			end repeat
			log f & " exist"
		end repeat
	end tell
end ProcessJpeg

on AirdropFilesWithShortcut()
	set finderWindow to missing value
	tell application "Finder"
		activate
		
		-- Open the folder with the files to airdrop
		set firstFile to (first item of outputFiles) as POSIX file
		reveal firstFile
		delay 0.3 -- Adjust the delay depending of your computer
		
		-- Memorize the Finder window
		set finderWindow to window 1
		
		-- Select all the file(s)
		set theFiles to {}
		repeat with f in outputFiles
			set end of theFiles to (f as POSIX file)
		end repeat
		select theFiles
		delay 0.1 -- Slightly reduced delay
		
		-- Run the workflow through the Shortcuts app
		try
			tell application "Shortcuts"
				run shortcut "Airdrop Selected"
			end tell
		on error number -128
			-- Silently handle user cancellation
		end try
	end tell
	
	-- Wait for user to choose a recipient or cancel
	tell application "System Events"
		set timeoutCount to 0
		repeat
			if not (exists (window 1 of process "Finder" whose name is "AirDrop")) then
				exit repeat
			end if
			delay 0.1
			set timeoutCount to timeoutCount + 1
		end repeat
	end tell
	
	-- Return to Capture One and close the Finder window
	tell application "Finder"
		if finderWindow is not missing value then
			try
				close finderWindow
			end try
		end if
	end tell
	
	tell application "Capture One" to activate
end AirdropFilesWithShortcut
