import Flutter
import HealthKit
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let wearableHeartRateHandler = WearableHeartRateStreamHandler()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let messenger = engineBridge.binaryMessenger
    let methodChannel = FlutterMethodChannel(
      name: "aura_lift/heart_rate_stream/methods",
      binaryMessenger: messenger)
    let eventChannel = FlutterEventChannel(
      name: "aura_lift/heart_rate_stream/events",
      binaryMessenger: messenger)

    eventChannel.setStreamHandler(wearableHeartRateHandler)
    methodChannel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(FlutterError(code: "internal", message: "App delegate released", details: nil))
        return
      }

      switch call.method {
      case "start":
        let args = call.arguments as? [String: Any]
        let startedAtMillis = args?["startedAtMillis"] as? Int64
        self.wearableHeartRateHandler.start(startedAtMillis: startedAtMillis) { error in
          if let error {
            result(error)
            return
          }
          result(nil)
        }
      case "stop":
        self.wearableHeartRateHandler.stop()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}

private final class WearableHeartRateStreamHandler: NSObject, FlutterStreamHandler {
  private let healthStore = HKHealthStore()
  private let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)
  private var eventSink: FlutterEventSink?
  private var observerQuery: HKObserverQuery?
  private var anchoredQuery: HKAnchoredObjectQuery?
  private var anchor: HKQueryAnchor?
  private var startedAt: Date?

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    eventSink = events
    if let args = arguments as? [String: Any],
       let startedAtMillis = args["startedAtMillis"] as? Int64 {
      startedAt = Date(timeIntervalSince1970: TimeInterval(startedAtMillis) / 1000.0)
    }
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    stop()
    return nil
  }

  func start(startedAtMillis: Int64?, completion: @escaping (FlutterError?) -> Void) {
    guard HKHealthStore.isHealthDataAvailable(), let heartRateType else {
      completion(FlutterError(code: "unsupported", message: "HealthKit not available", details: nil))
      return
    }

    if let startedAtMillis {
      startedAt = Date(timeIntervalSince1970: TimeInterval(startedAtMillis) / 1000.0)
    }

    healthStore.requestAuthorization(toShare: nil, read: [heartRateType]) { [weak self] granted, error in
      guard let self else { return }
      if let error {
        completion(FlutterError(code: "failed", message: error.localizedDescription, details: nil))
        return
      }
      if !granted {
        completion(FlutterError(code: "denied", message: "HealthKit permission denied", details: nil))
        return
      }

      self.startObserverAndInitialRead(for: heartRateType)
      completion(nil)
    }
  }

  func stop() {
    if let observerQuery {
      healthStore.stop(observerQuery)
    }
    if let anchoredQuery {
      healthStore.stop(anchoredQuery)
    }
    observerQuery = nil
    anchoredQuery = nil
    anchor = nil
  }

  private func startObserverAndInitialRead(for type: HKQuantityType) {
    stop()

    let predicate: NSPredicate?
    if let startedAt {
      predicate = HKQuery.predicateForSamples(withStart: startedAt, end: nil, options: .strictStartDate)
    } else {
      predicate = nil
    }

    let observer = HKObserverQuery(sampleType: type, predicate: predicate) { [weak self] _, completion, _ in
      self?.runAnchoredQuery(sampleType: type, predicate: predicate)
      completion()
    }
    observerQuery = observer
    healthStore.execute(observer)

    runAnchoredQuery(sampleType: type, predicate: predicate)
  }

  private func runAnchoredQuery(sampleType: HKQuantityType, predicate: NSPredicate?) {
    let query = HKAnchoredObjectQuery(
      type: sampleType,
      predicate: predicate,
      anchor: anchor,
      limit: HKObjectQueryNoLimit
    ) { [weak self] _, samples, _, newAnchor, _ in
      self?.anchor = newAnchor
      self?.emitHeartRateSamples(samples)
    }

    query.updateHandler = { [weak self] _, samples, _, newAnchor, _ in
      self?.anchor = newAnchor
      self?.emitHeartRateSamples(samples)
    }

    anchoredQuery = query
    healthStore.execute(query)
  }

  private func emitHeartRateSamples(_ samples: [HKSample]?) {
    guard let sink = eventSink, let quantitySamples = samples as? [HKQuantitySample] else {
      return
    }

    let unit = HKUnit.count().unitDivided(by: HKUnit.minute())
    for sample in quantitySamples {
      let bpm = Int(sample.quantity.doubleValue(for: unit).rounded())
      if bpm <= 0 {
        continue
      }

      let payload: [String: Any] = [
        "bpm": bpm,
        "timestampMillis": Int64(sample.startDate.timeIntervalSince1970 * 1000.0),
        "source": sample.sourceRevision.source.bundleIdentifier,
      ]
      DispatchQueue.main.async {
        sink(payload)
      }
    }
  }
}
