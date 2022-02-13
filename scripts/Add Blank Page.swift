#!/usr/bin/swift

// # Add Blank Page to a PDF.
// v1.0 by Ben Byram-Wigfield

import Quartz
import Foundation

func addPage(filepath: String) -> Void {
let A4p = CGRect.init(x: 0.0, y: 0.0, width: 595.0, height: 842.0)
let mediabox = PDFDisplayBox.mediaBox

if let pdfDoc = PDFDocument(url: URL(fileURLWithPath: filepath)) {
    if let pageBounds = pdfDoc.page(at: 0)?.bounds(for: mediabox) {
        let blankPage = PDFPage.init()
        blankPage.setBounds(pageBounds, for: mediabox)
        pdfDoc.insert(blankPage, at: 0)
        pdfDoc.write(to: URL(fileURLWithPath: filepath)) // save the PDF file
       }
}
}

// "main"
if CommandLine.argc > 1 {
    for (index, args) in CommandLine.arguments.enumerated() {
        if index > 0 {
            addPage(filepath: args)
            
        }
}
}
