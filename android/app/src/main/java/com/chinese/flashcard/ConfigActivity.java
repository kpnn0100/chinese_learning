package com.chinese.flashcard;

import android.app.AlertDialog;
import android.os.Bundle;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Spinner;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

public class ConfigActivity extends AppCompatActivity {

    private FlashcardManager manager;
    private Spinner spinnerHskLevel;
    private EditText etWordsPerPatch;
    private Button btnResetProgress, btnSave;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_config);

        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        setTitle("Configuration");

        manager = new FlashcardManager(this);

        initViews();
        loadCurrentSettings();
        setupListeners();
    }

    private void initViews() {
        spinnerHskLevel = findViewById(R.id.spinnerHskLevel);
        etWordsPerPatch = findViewById(R.id.etWordsPerPatch);
        btnResetProgress = findViewById(R.id.btnResetProgress);
        btnSave = findViewById(R.id.btnSave);

        // Setup HSK level spinner
        String[] hskLevels = {"HSK 1", "HSK 2", "HSK 3", "HSK 4", "HSK 5", "HSK 6"};
        ArrayAdapter<String> adapter = new ArrayAdapter<>(this,
                android.R.layout.simple_spinner_item, hskLevels);
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        spinnerHskLevel.setAdapter(adapter);
    }

    private void loadCurrentSettings() {
        spinnerHskLevel.setSelection(manager.getHskLevel() - 1);
        etWordsPerPatch.setText(String.valueOf(manager.getWordsPerPatch()));
    }

    private void setupListeners() {
        btnSave.setOnClickListener(v -> saveSettings());

        btnResetProgress.setOnClickListener(v -> {
            new AlertDialog.Builder(this)
                .setTitle("Reset Progress")
                .setMessage("Are you sure you want to reset progress? This will reshuffle all words and start from the beginning.")
                .setPositiveButton("Yes", (dialog, which) -> {
                    manager.resetProgress();
                    Toast.makeText(this, "Progress has been reset!", Toast.LENGTH_SHORT).show();
                })
                .setNegativeButton("No", null)
                .show();
        });
    }

    private void saveSettings() {
        try {
            int newHskLevel = spinnerHskLevel.getSelectedItemPosition() + 1;
            int newWordsPerPatch = Integer.parseInt(etWordsPerPatch.getText().toString());

            if (newWordsPerPatch <= 0) {
                Toast.makeText(this, "Please enter a positive number for words per patch", 
                             Toast.LENGTH_SHORT).show();
                return;
            }

            int oldHskLevel = manager.getHskLevel();
            manager.setHskLevel(newHskLevel);
            manager.setWordsPerPatch(newWordsPerPatch);

            if (newHskLevel != oldHskLevel) {
                Toast.makeText(this, "HSK level changed. Progress has been reset.", 
                             Toast.LENGTH_LONG).show();
            } else {
                Toast.makeText(this, "Configuration saved!", Toast.LENGTH_SHORT).show();
            }

            finish();
        } catch (NumberFormatException e) {
            Toast.makeText(this, "Please enter a valid number for words per patch", 
                         Toast.LENGTH_SHORT).show();
        }
    }

    @Override
    public boolean onSupportNavigateUp() {
        finish();
        return true;
    }
}
