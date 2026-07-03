import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    // Keep the shell usable: with no floor the 3-pane layout can be dragged
    // into unusable slivers. The app is responsive below this, but a desktop
    // window that small is never intentional.
    self.minSize = NSSize(width: 640, height: 480)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
