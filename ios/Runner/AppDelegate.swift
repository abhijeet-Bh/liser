import Flutter
import UIKit
import MediaPlayer
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
    
    private var volumeViewSlider: UISlider?
    private var eventSink: FlutterEventSink?
    private var volumeObservation: NSKeyValueObservation?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        setupVolumeSlider()
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
        
        guard let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "liser_volume_plugin") else {
            return
        }
        let messenger = registrar.messenger()
        
        let volumeChannel = FlutterMethodChannel(name: "liser/volume_control",
                                                 binaryMessenger: messenger)
        
        let volumeEventChannel = FlutterEventChannel(name: "liser/volume_events",
                                                     binaryMessenger: messenger)
        
        volumeChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            guard let self = self else { return }
            
            if call.method == "getVolume" {
                do {
                    try AVAudioSession.sharedInstance().setActive(true)
                    result(Double(AVAudioSession.sharedInstance().outputVolume))
                } catch {
                    result(1.0)
                }
            } else if call.method == "setVolume" {
                if let args = call.arguments as? [String: Any],
                   let vol = args["volume"] as? Double {
                    self.volumeViewSlider?.setValue(Float(vol), animated: false)
                    result(nil)
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENT", message: "Volume missing", details: nil))
                }
            } else {
                result(FlutterMethodNotImplemented)
            }
        })
        
        volumeEventChannel.setStreamHandler(VolumeStreamHandler(appDelegate: self))
    }
    
    private func setupVolumeSlider() {
        let volumeView = MPVolumeView(frame: .zero)
        for view in volumeView.subviews {
            if let slider = view as? UISlider {
                volumeViewSlider = slider
                break
            }
        }
    }
    
    func registerVolumeObserver(sink: @escaping FlutterEventSink) {
        self.eventSink = sink
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set active audio session")
        }
        self.volumeObservation = AVAudioSession.sharedInstance().observe(\.outputVolume, options: [.initial, .new]) { (audioSession, change) in
            if let newVolume = change.newValue {
                sink(Double(newVolume))
            }
        }
    }
    
    func unregisterVolumeObserver() {
        self.volumeObservation?.invalidate()
        self.volumeObservation = nil
        self.eventSink = nil
    }
}

class VolumeStreamHandler: NSObject, FlutterStreamHandler {
    weak var appDelegate: AppDelegate?
    
    init(appDelegate: AppDelegate) {
        self.appDelegate = appDelegate
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        appDelegate?.registerVolumeObserver(sink: events)
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        appDelegate?.unregisterVolumeObserver()
        return nil
    }
}
