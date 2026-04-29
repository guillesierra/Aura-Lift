package com.example.aura_lift

import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.HealthConnectClient.Companion.SDK_AVAILABLE
import androidx.health.connect.client.permission.HealthPermission
import androidx.health.connect.client.records.HeartRateRecord
import androidx.health.connect.client.request.ReadRecordsRequest
import androidx.health.connect.client.time.TimeRangeFilter
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.time.Instant
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

class MainActivity : FlutterActivity() {
	private val appScope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)
	private val streamHandler by lazy { WearableHeartRateStreamHandler(this, appScope) }

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		EventChannel(
			flutterEngine.dartExecutor.binaryMessenger,
			"aura_lift/heart_rate_stream/events",
		).setStreamHandler(streamHandler)

		MethodChannel(
			flutterEngine.dartExecutor.binaryMessenger,
			"aura_lift/heart_rate_stream/methods",
		).setMethodCallHandler { call, result ->
			when (call.method) {
				"start" -> streamHandler.start(call, result)
				"stop" -> {
					streamHandler.stop()
					result.success(null)
				}
				else -> result.notImplemented()
			}
		}
	}

	override fun onDestroy() {
		streamHandler.stop()
		appScope.cancel()
		super.onDestroy()
	}
}

private class WearableHeartRateStreamHandler(
	private val activity: FlutterActivity,
	private val scope: CoroutineScope,
) : EventChannel.StreamHandler {
	private var eventSink: EventChannel.EventSink? = null
	private var pollingJob: Job? = null
	private var startedAt: Instant = Instant.now().minusSeconds(900)
	private var lastRead: Instant = startedAt
	private val emittedKeys = HashSet<String>()

	override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
		eventSink = events
		val args = arguments as? Map<*, *>
		val startedAtMillis = (args?.get("startedAtMillis") as? Number)?.toLong()
		if (startedAtMillis != null) {
			startedAt = Instant.ofEpochMilli(startedAtMillis)
			lastRead = startedAt
			emittedKeys.clear()
		}
	}

	override fun onCancel(arguments: Any?) {
		eventSink = null
		stop()
	}

	fun start(call: MethodCall, result: MethodChannel.Result) {
		val sdkStatus =
			HealthConnectClient.getSdkStatus(activity, "com.google.android.apps.healthdata")
		if (sdkStatus != SDK_AVAILABLE) {
			result.error("unsupported", "Health Connect is not available", null)
			return
		}

		val args = call.arguments as? Map<*, *>
		val startedAtMillis = (args?.get("startedAtMillis") as? Number)?.toLong()
		if (startedAtMillis != null) {
			startedAt = Instant.ofEpochMilli(startedAtMillis)
			lastRead = startedAt
			emittedKeys.clear()
		}

		val client = HealthConnectClient.getOrCreate(activity)
		scope.launch {
			val readPermission = HealthPermission.getReadPermission(HeartRateRecord::class)
			val granted = client.permissionController.getGrantedPermissions()
			if (!granted.contains(readPermission)) {
				result.error("denied", "Health Connect read heart-rate permission is missing", null)
				return@launch
			}

			stop()
			pollingJob = scope.launch {
				while (true) {
					readAndEmit(client)
					delay(5000)
				}
			}
			result.success(null)
		}
	}

	fun stop() {
		pollingJob?.cancel()
		pollingJob = null
	}

	private suspend fun readAndEmit(client: HealthConnectClient) {
		val until = Instant.now()
		val response = client.readRecords(
			ReadRecordsRequest(
				recordType = HeartRateRecord::class,
				timeRangeFilter = TimeRangeFilter.between(lastRead, until),
			),
		)

		for (record in response.records) {
			val source = "android_health_connect:${record.metadata.dataOrigin.packageName}"
			for (sample in record.samples) {
				val key = "${sample.time.toEpochMilli()}-${sample.beatsPerMinute}-$source"
				if (!emittedKeys.add(key)) {
					continue
				}

				val payload = hashMapOf<String, Any>(
					"bpm" to sample.beatsPerMinute,
					"timestampMillis" to sample.time.toEpochMilli(),
					"source" to source,
				)
				scope.launch(Dispatchers.Main) {
					eventSink?.success(payload)
				}
			}
		}

		// Keep a small overlap to avoid missing records written around the polling edge.
		lastRead = until.minusSeconds(2)
	}
}
