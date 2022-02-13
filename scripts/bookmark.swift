#!/usr/bin/swift

// BOOKLET PDF: Make booklet-order spreads from PDFs supplied
// v1.0 by Ben Byram-Wigfield

import Quartz
import Foundation

// OPTIONS
let A3landscape = CGRect(x: 0, y: 0, width: 1190.55, height: 841.88)
let A4landscape = CGRect(x: 0, y: 0, width: 841.88, height: 595.28)
let USLetter = CGRect(x: 0, y: 0, width: 792, height: 612)
let Tabloid = CGRect(x: 0, y: 0, width: 1224, height: 792)

let suffix = " booklet.pdf"
var sheetSize = A3landscape
let hasSignatures = false
var signatureSize = 16
let creep = 0.5
let pagesPerSheet = 4 // Don't change this!


// Get the page order for the imposition
// No check for odd-numbered input, btw
func imposition(pageRange: Array<Int>) -> Array<Int> {
	var localOrder = [Int]()
	let half = pageRange.count/2
	for i in stride(from: 0, to: half, by: 2) {
		// First we do one side
		let backi = (pageRange.count)-i-1
		localOrder.append(pageRange[backi])
		localOrder.append(pageRange[i])
		// Then we do the other
		localOrder.append(pageRange[i+1])
		localOrder.append(pageRange[backi-1])
	}
	return localOrder
	}

// Makes sure pages are in portrait orientation
func getRotation(pdfpage: CGPDFPage) -> Int32 {
	var displayAngle = 0 as Int32
	let rotValue = pdfpage.rotationAngle
	let mediaBox = pdfpage.getBoxRect(CGPDFBox.mediaBox)
		let x = mediaBox.width
		let y = mediaBox.height
 // X and Y of mediabox doesn't change with rotation
		if (x > y) {
			displayAngle = -90
		}
			displayAngle -= rotValue		
	return displayAngle
}

func getDocInfo(filename: String) -> CFDictionary {
	var metadata: CFDictionary = [:] as CFDictionary
	let pdfURL = URL(fileURLWithPath: filename)
	let pdfDoc = PDFDocument.init(url: pdfURL)
	if pdfDoc != nil {
		metadata = pdfDoc?.documentAttributes as! CFDictionary
	} 
	return metadata
}

func makeBooklet(filename: String) -> Void {
	var leftPage = sheetSize
	var rightPage = sheetSize

	let shift = (sheetSize.width)/2
	leftPage.size.width = shift
	rightPage.origin.x = shift/2
	let pdfDictionary = getDocInfo(filename: filename)

	var blanks = 0
	var newName = (filename as NSString).deletingPathExtension
	newName += suffix
	let outURL = URL(fileURLWithPath: newName) as CFURL
	// Need to init with dict in the future
	let writeContext = CGContext.init(outURL, mediaBox: &sheetSize, pdfDictionary)
	let sourceURL = URL(fileURLWithPath: filename) as CFURL
	if let sourcePDF = CGPDFDocument.init(sourceURL) {
		var totalPages = sourcePDF.numberOfPages
		
		// Add 0 to array for extra blank pages needed to make full sheet
		var UnsortedOrder = Array(1...totalPages)
		if (totalPages % pagesPerSheet != 0) {
			blanks = pagesPerSheet - (totalPages % pagesPerSheet)
			for i in 1...blanks {
				UnsortedOrder.append(0)
			}
			totalPages = UnsortedOrder.count
		}
		// Get sorted page order
		if !hasSignatures {
			signatureSize = totalPages
		}
		var imposedOrder = [Int]()
		for chunk in stride(from: 0, to: totalPages, by: signatureSize) {
			imposedOrder.append(contentsOf: (imposition(pageRange: Array(UnsortedOrder[chunk...(chunk+signatureSize-1)]))))
		}
		// Take sorted order and lay them out
		let Sides = (totalPages) / 2
		var count = 0
		for n in 1...Sides {
			writeContext?.beginPage(mediaBox: &sheetSize)
			let spread = [leftPage, rightPage]
			for position in spread {
				if imposedOrder[count] != 0 {
					if let page = sourcePDF.page(at: imposedOrder[count]) {
					writeContext?.saveGState()
					let angle = getRotation(pdfpage: page)

					let transform = page.getDrawingTransform(CGPDFBox.mediaBox, rect: position, rotate: angle, preserveAspectRatio: true)
					writeContext?.concatenate(transform)
					// Draw rule around each page
					// writeContext?.stroke(leftPage, width: 2.0)
				writeContext?.drawPDFPage(page)
				writeContext?.restoreGState()
				}
				}
				count += 1
			}
				writeContext?.endPDFPage()
		}
	}
	writeContext?.closePDF()
}

// "main"
if CommandLine.argc > 1 {
	for (index, args) in CommandLine.arguments.enumerated() {
		if index > 0 {
			makeBooklet(filename: args)			
		}
}
}
