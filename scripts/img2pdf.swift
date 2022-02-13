#!/usr/bin/swift

// IMAGES TO PDF: convert selected images into one PDF
// v1.0 by Ben Byram-Wigfield

import Quartz
import Foundation

func getFilename(prefix: String, filename: String) -> String {
	var fullname = prefix + "/" + filename + ".pdf"
	var myIndex = 0
	while (FileManager.default.fileExists(atPath: fullname)) {
		myIndex += 1		
		fullname = prefix + "/" + filename + " " + String(format: "%02d", myIndex) + ".pdf"
	}
	return fullname
}

func imageToPDF(incomingFiles: Array<String>) -> Void {
	let prefix = (incomingFiles[0] as NSString).deletingLastPathComponent
	let filename = "Combined"
	let pdfoutputName = getFilename(prefix: prefix, filename: filename)
	
	// Initialise PDF object
	let myPDF = PDFDocument.init()
	var isItAnImage = false
	for (index, eachFile) in incomingFiles.enumerated() {
		if let image = NSImage.init(contentsOfFile: eachFile) {
			if let page = PDFPage.init(image: image) {
			myPDF.insert(page, at: index)
			isItAnImage = true
			}
			}
		}
	if isItAnImage {
		myPDF.write(toFile: pdfoutputName)
	}
	}

// Supply all files at once
if CommandLine.argc > 1 {
	let fileslice = Array(CommandLine.arguments.suffix(from: 1))
	imageToPDF(incomingFiles: fileslice)
}