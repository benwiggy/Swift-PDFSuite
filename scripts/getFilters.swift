#!/usr/bin/swift

import Quartz
import Foundation

// Domain constants are documented, but anything seems to work.
// kQuartzFilterApplicationDomain kQuartzFilterPDFWorkflowDomain kQuartzFilterPrintingDomain
let myDomain: [Any] = [0]

func listFilters() -> Void {
	if let theFilters = QuartzFilterManager.filters(inDomains: myDomain) {
	for eachFilter in theFilters as! [QuartzFilter] {
		print(eachFilter.localizedName()!, ":", eachFilter.url().path)
	}
}
}
listFilters()

