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
property outputSubFolder : "AIRDROPPED_JPEG"
property jpegQuality : 85
property longEdgeSize : 1920

-- Global variables
global selecVars, currentDocument, outputFiles, rootFolder, fullList, AirDropRecipe, fileExtension

set outputFiles to {}
set fullList to ""
set fileExtension to ".jpg"

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
				-- Ne pas modifier root folder type pour préserver l'export location personnalisé

			on error
				-- Create AIRDROP recipe if not exist
				set AirDropRecipe to make new recipe with properties {name:recipeName, output format:JPEG_QuickProof, color profile:"sRGB Color Space Profile", pixels per inch:96, export crop method:respect, ignore crop:false, include annotations:true, include Camera Metadata:true, include copyright:true, root folder type:output location, output sub folder:outputSubFolder, sharpening:for screen, sharpening amount:60.0, sharpening distance:100.0, sharpening distance type:percent of diagonal, sharpening radius:0.600000023842, sharpening threshold:0.0, thumbnails:false}
				tell AirDropRecipe to set {its enabled, its scaling method, its scaling unit, its primary scaling value} to {false, Long_Edge, pixels, longEdgeSize}
			end try
		end tell

		-- Déterminer l'extension en fonction du format d'export
		set recipeFormat to output format of AirDropRecipe
		set fileExtension to my getExtensionForFormat(recipeFormat)

		repeat with i in selecVars
			set fullList to fullList & (name of i) & fileExtension & return
		end repeat
	end tell
end getJpeg

on ProcessJpeg()
	tell application "Capture One"
		-- Récupérer le chemin d'export depuis la recette
		set recipeRootType to AirDropRecipe's root folder type
		if recipeRootType is output location then
			tell currentDocument to set rflAlias to its output
		else
			set rflAlias to AirDropRecipe's root folder location
		end if
		set rfl to POSIX path of rflAlias
		set recipeSubFolder to AirDropRecipe's output sub folder
		if recipeSubFolder is not "" then
			set rfl to rfl & recipeSubFolder & "/"
		end if
		
		repeat with v in selecVars
			set outputFileName to rfl & v's name & fileExtension

			try
				tell application "System Events" to if (exists file outputFileName) then delete file outputFileName
				set outputResult to process v recipe recipeName
			on error errMsg number errNum
				if errNum is -43 then -- invalid output location
					set AirDropRecipe's root folder location to rootFolder
					set rfl to POSIX path of (rootFolder as alias)
					if recipeSubFolder is not "" then
						set rfl to rfl & recipeSubFolder & "/"
					end if
					set outputFileName to rfl & v's name & fileExtension
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
		repeat
			if not (exists (window 1 of process "Finder" whose name is "AirDrop")) then
				exit repeat
			end if
			delay 0.1
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
	-- Close Shortcuts
	try
    		quit application "Shortcuts"
    	on error errMsg number errNum
    		log "Error closing Shortcuts.app : " & errMsg
	end try

	tell application "Capture One" to activate
end AirdropFilesWithShortcut

on getExtensionForFormat(outputFormat)
	-- Convertir le format en texte pour la comparaison
	set formatStr to outputFormat as text

	if formatStr contains "JPEG" then
		return ".jpg"
	else if formatStr contains "TIFF" then
		return ".tif"
	else if formatStr contains "PNG" then
		return ".png"
	else if formatStr contains "PSD" then
		return ".psd"
	else if formatStr contains "DNG" then
		return ".dng"
	else if formatStr contains "HEIF" or formatStr contains "HEIC" then
		return ".heic"
	else if formatStr contains "AVIF" then
		return ".avif"
	else if formatStr contains "WebP" then
		return ".webp"
	else
		-- Fallback par défaut
		return ".jpg"
	end if
end getExtensionForFormat
