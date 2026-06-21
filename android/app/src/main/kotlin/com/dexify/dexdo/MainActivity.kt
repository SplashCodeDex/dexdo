package com.dexify.dexdo

import android.os.Bundle
import android.util.Base64
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import androidx.credentials.CredentialManager
import androidx.credentials.GetCredentialRequest
import androidx.credentials.GetDigitalCredentialOption
import androidx.credentials.DigitalCredential
import androidx.lifecycle.lifecycleScope
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.launch
import java.security.SecureRandom

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.dexify.dexdo/credentials"

    override fun onCreate(savedInstanceState: Bundle?) {
        // Handle the splash screen transition.
        installSplashScreen()

        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getVerifiedEmail") {
                getVerifiedEmail(call, result)
            } else {
                result.notImplemented()
            }
        }
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.dexify.dexdo/audio").setMethodCallHandler { call, result ->
            if (call.method == "playVoiceTrigger") {
                playChime()
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }

    @kotlin.OptIn(androidx.credentials.ExperimentalDigitalCredentialApi::class)
    private fun getVerifiedEmail(call: io.flutter.plugin.common.MethodCall, result: MethodChannel.Result) {
        val credentialManager = CredentialManager.create(this)
        
        val nonce = call.argument<String>("nonce") ?: return result.error("INVALID_ARGUMENT", "nonce is required", null)

        val openId4vpRequest = """
        {
          "requests": [
            {
              "protocol": "openid4vp-v1-unsigned",
              "data": {
                "response_type": "vp_token",
                "response_mode": "dc_api",
                "nonce": "$nonce",
                "dcql_query": {
                  "credentials": [
                    {
                      "id": "user_info_query",
                      "format": "dc+sd-jwt",
                       "meta": { 
                          "vct_values": ["UserInfoCredential"] 
                       },
                      "claims": [ 
                        {"path": ["email"]}, 
                        {"path": ["name"]},  
                        {"path": ["given_name"]},
                        {"path": ["family_name"]},
                        {"path": ["picture"]},
                        {"path": ["hd"]},
                        {"path": ["email_verified"]}
                      ]
                    }
                  ]
                }
              }
            }
          ]
        }
        """.trimIndent()

        val getDigitalCredentialOption = GetDigitalCredentialOption(requestJson = openId4vpRequest)
        val request = GetCredentialRequest(listOf(getDigitalCredentialOption))

        lifecycleScope.launch {
            try {
                val credentialResult = credentialManager.getCredential(this@MainActivity, request)
                val credential = credentialResult.credential
                if (credential is DigitalCredential) {
                    val responseJsonString = credential.credentialJson
                    result.success(responseJsonString)
                } else {
                    result.error("UNEXPECTED_CREDENTIAL", "Received credential is not a DigitalCredential", null)
                }
            } catch (e: Exception) {
                result.error("CREDENTIAL_ERROR", e.message, null)
            }
        }
    }

    private fun playChime() {
        val sampleRate = 44100
        val duration1 = 0.12 // seconds
        val duration2 = 0.28 // seconds
        val numSamples1 = (duration1 * sampleRate).toInt()
        val numSamples2 = (duration2 * sampleRate).toInt()
        val totalSamples = numSamples1 + numSamples2
        val sample = DoubleArray(totalSamples)
        val generatedSnd = ByteArray(2 * totalSamples)

        val freqOfTone1 = 523.25 // C5
        val freqOfTone2 = 659.25 // E5

        // Generate C5 tone (fade out)
        for (i in 0 until numSamples1) {
            val t = i.toDouble() / sampleRate
            val envelope = (numSamples1 - i).toDouble() / numSamples1
            sample[i] = Math.sin(2.0 * Math.PI * freqOfTone1 * t) * envelope * 0.4
        }

        // Generate E5 tone (fade out)
        for (i in 0 until numSamples2) {
            val t = i.toDouble() / sampleRate
            val envelope = (numSamples2 - i).toDouble() / numSamples2
            sample[numSamples1 + i] = Math.sin(2.0 * Math.PI * freqOfTone2 * t) * envelope * 0.4
        }

        var idx = 0
        for (dVal in sample) {
            val valShort = (dVal * 32767).toInt().toShort()
            generatedSnd[idx++] = (valShort.toInt() and 0x00ff).toByte()
            generatedSnd[idx++] = ((valShort.toInt() and 0xff00) ushr 8).toByte()
        }

        try {
            val audioTrack = android.media.AudioTrack(
                android.media.AudioManager.STREAM_MUSIC,
                sampleRate,
                android.media.AudioFormat.CHANNEL_OUT_MONO,
                android.media.AudioFormat.ENCODING_PCM_16BIT,
                generatedSnd.size,
                android.media.AudioTrack.MODE_STATIC
            )
            audioTrack.write(generatedSnd, 0, generatedSnd.size)
            audioTrack.play()
        } catch (e: Exception) {
            android.util.Log.e("MainActivityChime", "Error playing chime: ${e.message}", e)
        }
    }
}
