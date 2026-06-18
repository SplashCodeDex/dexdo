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
}
