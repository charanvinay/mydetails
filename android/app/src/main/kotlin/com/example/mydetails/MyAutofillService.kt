package com.example.mydetails

import android.service.autofill.AutofillService
import android.service.autofill.FillRequest
import android.service.autofill.FillResponse
import android.service.autofill.SaveRequest
import android.service.autofill.SaveInfo
import android.view.autofill.AutofillId
import android.service.autofill.FillCallback
import android.service.autofill.SaveCallback
import android.app.assist.AssistStructure
import android.view.autofill.AutofillValue
import android.util.Log
import android.widget.RemoteViews
import android.service.autofill.CustomDescription
import android.service.autofill.CharSequenceTransformation
import java.util.regex.Pattern
import android.content.pm.PackageManager

class MyAutofillService : AutofillService() {
    
    override fun onFillRequest(request: FillRequest, cancellationSignal: android.os.CancellationSignal, callback: FillCallback) {
        val structure = request.fillContexts.last().structure
        val parser = AutofillStructureParser(structure)
        
        Log.d("MyAutofillService", "Detected package: ${parser.packageName}, domain: ${parser.webDomain}")
        
        val responseBuilder = FillResponse.Builder()
        var hasData = false
        
        // If we find fields, we tell the OS we are interested in saving them
        if (parser.usernameId != null && parser.passwordId != null) {
            val saveInfoBuilder = SaveInfo.Builder(
                SaveInfo.SAVE_DATA_TYPE_PASSWORD,
                arrayOf(parser.usernameId!!, parser.passwordId!!)
            )

            // Setup custom description layout
            val remoteViews = RemoteViews(packageName, R.layout.autofill_save_custom)
            
            // Set the app/domain name
            val friendlyName = when {
                parser.webDomain != null -> formatDomain(parser.webDomain!!)
                parser.packageName != null -> getAppLabel(parser.packageName!!)
                else -> "Unknown App"
            }
            remoteViews.setTextViewText(R.id.autofill_save_app, friendlyName)

            // Bind the username field to show the entered value
            val usernameTrans = CharSequenceTransformation.Builder(
                parser.usernameId!!,
                Pattern.compile("^(.*)$"),
                "$1"
            ).build()

            val customDescription = CustomDescription.Builder(remoteViews)
                .addChild(R.id.autofill_save_username, usernameTrans)
                .build()

            saveInfoBuilder.setCustomDescription(customDescription)
            
            responseBuilder.setSaveInfo(saveInfoBuilder.build())
            hasData = true
        }
        
        if (hasData) {
            callback.onSuccess(responseBuilder.build())
        } else {
            callback.onSuccess(null)
        }
    }

    override fun onSaveRequest(request: SaveRequest, callback: SaveCallback) {
        val structure = request.fillContexts.last().structure
        val parser = AutofillStructureParser(structure)
        
        val appName = if (parser.webDomain != null) {
            formatDomain(parser.webDomain!!)
        } else if (parser.packageName != null) {
            getAppLabel(parser.packageName!!)
        } else {
            "Unknown App"
        }

        val username = parser.usernameValue
        val password = parser.passwordValue
        
        Log.d("MyAutofillService", "User confirmed save for: $appName")
        Log.d("MyAutofillService", "Credentials: $username / $password")
        
        callback.onSuccess()
    }

    private fun getAppLabel(packageName: String): String {
        return try {
            val pm = packageManager
            val info = pm.getApplicationInfo(packageName, 0)
            pm.getApplicationLabel(info).toString()
        } catch (e: Exception) {
            // Smart Fallback: com.instagram.android -> Instagram
            packageName.split('.')
                .filter { it != "com" && it != "android" && it != "google" && it != "apps" }
                .lastOrNull()?.replaceFirstChar { it.uppercase() } ?: packageName
        }
    }

    private fun formatDomain(domain: String): String {
        return domain.substringBefore('.').replaceFirstChar { it.uppercase() }
    }
}

class AutofillStructureParser(structure: AssistStructure) {
    var usernameId: AutofillId? = null
    var passwordId: AutofillId? = null
    var usernameValue: String? = null
    var passwordValue: String? = null
    var packageName: String? = null
    var webDomain: String? = null

    init {
        val nodes = structure.windowNodeCount
        for (i in 0 until nodes) {
            val windowNode = structure.getWindowNodeAt(i)
            // Capture the package name of the app being filled
            parseNode(windowNode.rootViewNode)
        }
    }

    private fun parseNode(node: AssistStructure.ViewNode) {
        // Capture domain for web views (Chrome, Firefox, etc.)
        if (node.webDomain != null) {
            webDomain = node.webDomain
        }
        
        // Capture package name for native apps
        if (node.idPackage != null) {
            packageName = node.idPackage
        }

        val hints = node.autofillHints
        if (hints != null) {
            for (hint in hints) {
                if (hint.contains("username", ignoreCase = true) || hint.contains("email", ignoreCase = true)) {
                    usernameId = node.autofillId
                    usernameValue = node.autofillValue?.textValue?.toString()
                }
                if (hint.contains("password", ignoreCase = true)) {
                    passwordId = node.autofillId
                    passwordValue = node.autofillValue?.textValue?.toString()
                }
            }
        }

        for (i in 0 until node.childCount) {
            parseNode(node.getChildAt(i))
        }
    }
}
