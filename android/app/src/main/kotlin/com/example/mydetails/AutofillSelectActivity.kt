package com.example.mydetails

import android.app.Activity
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.autofill.AutofillManager
import android.view.autofill.AutofillValue
import android.widget.Button
import android.widget.LinearLayout
import android.widget.RemoteViews
import android.service.autofill.Dataset
import android.service.autofill.FillResponse
import android.util.Log

class AutofillSelectActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Final fix for black screen: Force transparent background via code
        window.setBackgroundDrawable(android.graphics.drawable.ColorDrawable(android.graphics.Color.TRANSPARENT))
        window.setLayout(android.view.ViewGroup.LayoutParams.MATCH_PARENT, android.view.ViewGroup.LayoutParams.MATCH_PARENT)
        
        setContentView(R.layout.autofill_selection)

        // Close when tapping outside the sheet
        findViewById<android.view.View>(R.id.autofill_root_overlay).setOnClickListener {
            setResult(Activity.RESULT_CANCELED)
            finish()
        }

        // Intercept clicks on the sheet content so they don't trigger the close action
        findViewById<android.view.View>(R.id.bottom_sheet_container).setOnClickListener {
            // Do nothing, just intercept
        }

        val friendlyName = intent.getStringExtra("app_name") ?: "Unknown App"
        val container = findViewById<LinearLayout>(R.id.autofill_items_container)

        // Read the vault
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val savedItems = prefs.getStringSet("flutter.autofill_vault", emptySet())
        
        savedItems?.forEach { item ->
            val parts = item.split("|")
            if (parts.size >= 3) {
                val savedApp = parts[0]
                val savedUser = parts[1]
                val savedPass = parts[2]

                // Show item if it matches the current app
                if (savedApp.equals(friendlyName, ignoreCase = true)) {
                    val itemView = layoutInflater.inflate(R.layout.autofill_account_item, container, false)
                    val usernameText = itemView.findViewById<android.widget.TextView>(R.id.account_username)
                    usernameText.text = savedUser
                    
                    itemView.setOnClickListener {
                        finishWithDataset(savedUser, savedPass)
                    }
                    
                    container.addView(itemView)
                }
            }
        }
    }

    private fun finishWithDataset(username: String, password: String) {
        val replyIntent = Intent()
        Log.d("AutofillSelectActivity", "Selected: $username")

        val usernameId = if (android.os.Build.VERSION.SDK_INT >= 33) {
            intent.getParcelableExtra("username_id", android.view.autofill.AutofillId::class.java)
        } else {
            @Suppress("DEPRECATION")
            intent.getParcelableExtra("username_id")
        }

        val passwordId = if (android.os.Build.VERSION.SDK_INT >= 33) {
            intent.getParcelableExtra("password_id", android.view.autofill.AutofillId::class.java)
        } else {
            @Suppress("DEPRECATION")
            intent.getParcelableExtra("password_id")
        }

        if (usernameId != null && passwordId != null) {
            // Restore the standard lock icon presentation for the result
            val presentation = RemoteViews(packageName, R.layout.autofill_dataset_item)
            presentation.setTextViewText(R.id.autofill_item_title, "Autofill from MyDetails")
            presentation.setTextViewText(R.id.autofill_item_subtitle, "Select a saved account")

            val dataset = Dataset.Builder()
                .setValue(usernameId, AutofillValue.forText(username), presentation)
                .setValue(passwordId, AutofillValue.forText(password), presentation)
                .build()

            replyIntent.putExtra(AutofillManager.EXTRA_AUTHENTICATION_RESULT, dataset)
            setResult(RESULT_OK, replyIntent)
            Log.d("AutofillSelectActivity", "Stable Dataset result sent")
        } else {
            setResult(RESULT_CANCELED)
        }
        
        finish()
    }
}
