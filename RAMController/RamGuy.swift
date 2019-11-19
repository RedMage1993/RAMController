//
//  RamGuy.swift
//  RAMController
//
//  Created by Fritz Ammon on 11/18/19.
//  Copyright © 2019 Fritz Ammon. All rights reserved.
//

import Foundation

private let HOST_VM_INFO64_COUNT: mach_msg_type_number_t = UInt32(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size)

class RamGuy {
    fileprivate let machHost = mach_host_self()
}

fileprivate extension RamGuy {
    func VMStatistics64() -> vm_statistics64? {
        var size = HOST_VM_INFO64_COUNT
        let hostInfo = vm_statistics64_t.allocate(capacity: 1) // pointer to location with enough mem for 1 vm_statistics64_t object
        
        let result = hostInfo.withMemoryRebound(to: integer_t.self, capacity: Int(size)) {
            host_statistics64(machHost, HOST_VM_INFO64, $0, &size)
        }

        let data = hostInfo.move()
        hostInfo.deallocate()
         
        guard result == KERN_SUCCESS else { return nil }
         
        return data
    }
}

extension RamGuy {
    struct RAMUsage {
        var usedRam: UInt64 = 0
        var activeRam: UInt64 = 0
        var inactiveRam: UInt64 = 0
        var wiredRam: UInt64 = 0
        var freeRam: UInt64 = 0
        var pageIns: UInt64 = 0
        var pageOuts: UInt64 = 0
        var pageFaults: UInt64 = 0
    }
}

extension RamGuy {
    func calculateRAMUsage() -> RAMUsage? {
        let pageSize: vm_size_t = 4096
    
        // For some reason, this is giving back a page size of 16384, which is incorrect.
//        if host_page_size(machHost, &pageSize) != KERN_SUCCESS {
//            pageSize = 4096
//        }
         
        guard let vm_stat = VMStatistics64() else { return nil }
        
        var usage = RAMUsage()

        usage.usedRam = UInt64((vm_stat.active_count + vm_stat.inactive_count + vm_stat.wire_count)) * UInt64(pageSize)
        usage.activeRam = UInt64(vm_stat.active_count) * UInt64(pageSize)
        usage.inactiveRam = UInt64(vm_stat.inactive_count) * UInt64(pageSize)
        usage.wiredRam = UInt64(vm_stat.wire_count) * UInt64(pageSize)
        usage.freeRam = ProcessInfo.processInfo.physicalMemory - usage.usedRam
        usage.pageIns = vm_stat.pageins
        usage.pageOuts = vm_stat.pageouts
        usage.pageFaults = vm_stat.faults
        
        return usage
    }
}
