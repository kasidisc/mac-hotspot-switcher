import CoreWLAN
import Foundation

let ssid = "Kasidis\u{2019}s iPhone 17 Pro"
let password = "servmode"

let iface = CWWiFiClient.shared().interface()!

// Check if already on hotspot
let task = Process()
task.executableURL = URL(fileURLWithPath: "/usr/sbin/ipconfig")
task.arguments = ["getifaddr", "en0"]
let pipe = Pipe()
task.standardOutput = pipe
try? task.run(); task.waitUntilExit()
let ip = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
if ip.hasPrefix("172.20.10.") { print("ALREADY_CONNECTED"); exit(0) }

do {
    let networks = try iface.scanForNetworks(withName: ssid)
    guard let network = networks.first else { print("NOT_VISIBLE"); exit(2) }
    try iface.associate(to: network, password: password)
    print("CONNECTED")
} catch {
    print("ERROR:\(error)")
    exit(3)
}
