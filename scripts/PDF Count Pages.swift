#!/usr/bin/swift

// COUNT PAGES: Cumulative total of all PDFs passed
// v1.0 by Ben Byram-Wigfield

import Foundation
import Quartz

func pageCount(filepath: String) -> Int {
    var count = 0
    let localUrl  = filepath as CFString
    if let pdfURL = CFURLCreateWithFileSystemPath(nil, localUrl, CFURLPathStyle.cfurlposixPathStyle, false) {
        if let pdf = CGPDFDocument(pdfURL) {
            count = pdf.numberOfPages
        }
    }
    return count
}

func tellUser(messageTitle: String, messageText: String) -> Bool {
    print(messageTitle, messageText)
let alert = NSAlert()
    alert.messageText = messageTitle
    alert.informativeText = messageText
    alert.addButton(withTitle: "OK")
    
 // self.present(alert, animated: true, completion: nil)
    return alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
}

// "main"
if CommandLine.argc > 1 {
    var pages: Int = 0
for (index, args) in CommandLine.arguments.enumerated() {
    if index > 0 {
        pages += pageCount(filepath: args)
    }
    }
    tellUser(messageTitle: "PDF Page Count", messageText: String(pages))
    
} else {
        tellUser(messageTitle: "Alert!", messageText: "PDF filenames required as arguments")
}
