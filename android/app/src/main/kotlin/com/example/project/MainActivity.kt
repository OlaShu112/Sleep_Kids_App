package com.example.project

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import android.app.AlertDialog
import android.content.DialogInterface
import com.google.firebase.FirebaseApp  // Ensure Firebase import is included

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        FirebaseApp.initializeApp(this)  // Initializes Firebase
    }

    override fun onBackPressed() {
        val dialog = AlertDialog.Builder(this)
            .setMessage("Are you sure you want to exit?")
            .setCancelable(false)
            .setPositiveButton("Yes") { _, _ ->
                super.onBackPressed()  // Exit the app
            }
            .setNegativeButton("No") { dialogInterface, _ ->
                dialogInterface.dismiss()  // Dismiss the dialog
            }
            .create()

        dialog.show()
    }
}
