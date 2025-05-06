package com.aadi.arogy

import android.os.Bundle
import android.widget.*
import androidx.appcompat.app.AppCompatActivity
import org.json.JSONObject
import java.io.*
import java.net.HttpURLConnection
import java.net.URL
import kotlin.concurrent.thread

class MainActivity : AppCompatActivity() {

    private val supabaseUrl = "https://rsefkfixakbuqxqtsfww.supabase.co"
    private val supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJzZWZrZml4YWtidXF4cXRzZnd3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUyMjc0NDcsImV4cCI6MjA2MDgwMzQ0N30.y4RUJCw5xhpVBbRToZIZ-Jg7jJBlUKg_pMO41VP-1BU" // Use 'Bearer ' prefix
    private val tableUrl = "$supabaseUrl/rest/v1/predictions"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        val emailInput = findViewById<EditText>(R.id.emailInput)
        val fetchButton = findViewById<Button>(R.id.fetchButton)
        val reportView = findViewById<TextView>(R.id.reportView)

        fetchButton.setOnClickListener {
            val email = emailInput.text.toString().trim()
            if (email.isNotEmpty()) {
                reportView.text = "🔄 Fetching..."
                fetchReport(email) { result ->
                    runOnUiThread {
                        reportView.text = result
                    }
                }
            }
        }
    }

    private fun fetchReport(email: String, callback: (String) -> Unit) {
        thread {
            try {
                val url = URL("$tableUrl?email=eq.$email&order=created_at.desc&limit=1")
                val connection = url.openConnection() as HttpURLConnection
                connection.setRequestProperty("apikey", supabaseKey.removePrefix("Bearer "))
                connection.setRequestProperty("Authorization", supabaseKey)
                connection.setRequestProperty("Accept", "application/json")

                val responseCode = connection.responseCode
                val stream = if (responseCode == 200) connection.inputStream else connection.errorStream
                val reader = BufferedReader(InputStreamReader(stream))
                val response = reader.readText()

                val jsonArray = JSONObject("{\"data\": $response}").getJSONArray("data")
                if (jsonArray.length() > 0) {
                    val report = jsonArray.getJSONObject(0)
                    val reportText = """
                        ✅ Report for ${report.getString("email")}
                        Age: ${report.getInt("age")}
                        Blood Pressure: ${report.getInt("blood_pressure")}
                        Cholesterol: ${report.getInt("cholesterol")}
                        Result: ${report.getString("result")}
                        Date: ${report.getString("created_at")}
                    """.trimIndent()
                    callback(reportText)
                } else {
                    callback("⚠️ No report found for this email.")
                }

            } catch (e: Exception) {
                callback("❌ Error: ${e.message}")
            }
        }
    }
}
