package com.example.mydetails

import android.service.autofill.AutofillService
import android.service.autofill.Dataset
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
import android.content.Context
import android.content.Intent
import android.app.PendingIntent

class MyAutofillService : AutofillService() {
    
    override fun onFillRequest(request: FillRequest, cancellationSignal: android.os.CancellationSignal, callback: FillCallback) {
        val structure = request.fillContexts.last().structure
        val parser = AutofillStructureParser(structure)
        
        val friendlyName = when {
            parser.webDomain != null -> formatDomain(parser.webDomain!!)
            parser.packageName != null -> getAppLabel(parser.packageName!!)
            else -> "Unknown App"
        }
        
        Log.d("MyAutofillService", "Fill request for: $friendlyName")
        
        val responseBuilder = FillResponse.Builder()
        var hasData = false

        // 0. FETCH THE VAULT
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val savedItems = try {
            prefs.getStringSet("flutter.autofill_vault", null)
        } catch (e: Exception) {
            null
        }

        // 1. KEYBOARD TRIGGER: High-compatibility dataset authentication
        if (savedItems != null && savedItems.isNotEmpty() && parser.usernameId != null && parser.passwordId != null) {
            val intent = Intent(this, AutofillSelectActivity::class.java).apply {
                putExtra("app_name", friendlyName)
                putExtra("username_id", parser.usernameId)
                putExtra("password_id", parser.passwordId)
            }
            
            val intentSender = PendingIntent.getActivity(
                this, 0, intent, 
                PendingIntent.FLAG_CANCEL_CURRENT or PendingIntent.FLAG_MUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
            ).intentSender

            val presentation = createPresentation("Autofill from MyDetails", "Select a saved account")
            
            // We authenticate the DATASET (not the response). This is the key to keyboard visibility.
            val dataset = Dataset.Builder()
                .setAuthentication(intentSender)
                .setValue(parser.usernameId!!, null, presentation)
                .setValue(parser.passwordId!!, null, presentation)
                .build()

            responseBuilder.addDataset(dataset)
            // 2 corresponds to FillResponse.FLAG_TRACK_CONTEXT
            responseBuilder.setFlags(2)
            hasData = true
        }
        
        // 2. ENABLE SAVING: If we see fields, allow the user to save new ones
        if (parser.usernameId != null && parser.passwordId != null) {
            val saveInfoBuilder = SaveInfo.Builder(
                SaveInfo.SAVE_DATA_TYPE_PASSWORD,
                arrayOf(parser.usernameId!!, parser.passwordId!!)
            )

            val remoteViews = RemoteViews(packageName, R.layout.autofill_save_custom)
            remoteViews.setTextViewText(R.id.autofill_save_app, friendlyName)

            val usernameTrans = CharSequenceTransformation.Builder(
                parser.usernameId!!, Pattern.compile("^(.*)$"), "$1"
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

    private fun createPresentation(title: String, subtitle: String): RemoteViews {
        val presentation = RemoteViews(packageName, R.layout.autofill_dataset_item)
        presentation.setTextViewText(R.id.autofill_item_title, title)
        presentation.setTextViewText(R.id.autofill_item_subtitle, subtitle)
        return presentation
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

        val username = parser.usernameValue ?: ""
        val password = parser.passwordValue ?: ""
        
        // Save to the exact file and key format that Flutter's shared_preferences expects
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val currentSaves = try {
            prefs.getStringSet("flutter.autofill_vault", mutableSetOf())?.toMutableSet() ?: mutableSetOf()
        } catch (e: Exception) {
            mutableSetOf<String>()
        }
        
        // Use a simple pipe-delimited string for the transfer
        currentSaves.add("$appName|$username|$password")
        prefs.edit().putStringSet("flutter.autofill_vault", currentSaves).apply()

        Log.d("MyAutofillService", "Data persisted for Flutter: $appName")
        
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
